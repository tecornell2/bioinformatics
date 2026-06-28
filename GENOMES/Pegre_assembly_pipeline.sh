## SLURM script

#!/bin/bash
#SBATCH --job-name Pegre_assembly_hifi_hic
#SBATCH --output Pegre_assembly_hifi_hic_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 200gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load anaconda3/2023.09-0

  ###### VARIABLES
  THREADS=40
  WORK_DIR="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome"
  R1="${WORK_DIR}/00_raw/Pegre-CLP3001/HiC/Muscle/2026_06_24_CUGBF_Illumina_HiC/01_trim_galore/CLP3001_S7_R1_001_val_1.fq.gz"
  R2="${WORK_DIR}/00_raw/Pegre-CLP3001/HiC/Muscle/2026_06_24_CUGBF_Illumina_HiC/01_trim_galore/CLP3001_S7_R2_001_val_2.fq.gz"
  HIFI="${WORK_DIR}/00_raw/Pegre-CLP3001/WGS/Blood/2026_03_27_UDel_PacBio_HiFi/00_raw/Pegre-CLP3001_WGS_blood_hifi.fastq.gz"
  OUTPUT="Pegre-CLP3001_blood_hifi_hic"

  ###### HIFIASM
  source activate hifiasm

  cd $WORK_DIR
  mkdir 01_hifiasm
  cd 01_hifiasm

  echo "Assembling draft genome with hifiasm..."
  hifiasm -o $OUTPUT -t $THREADS --h1 $R1 --h2 $R2 $HIFI
  awk '/^S/{print ">"$2;print $3}' ${OUTPUT}.bp.p_ctg.gfa > ${OUTPUT}.bp.p_ctg.fasta
  conda deactivate

  source activate bbmap
  echo "Calculating assembly statistics..."
  bbstats.sh in=${OUTPUT}.bp.p_ctg.fasta out=${OUTPUT}.bp.p_ctg.fasta.stats.txt Xmx64g
  conda deactivate

  ####### BUSCO
  source activate busco

  cd $WORK_DIR
  mkdir 02_BUSCO
  cd 02_BUSCO

  echo "Running BUSCO..."
  busco -i ../01_hifiasm/${OUTPUT}.bp.p_ctg.fasta -m genome -l /home/tecorn/busco_downloads/lineages/tetrapoda_odb12 -c $THREADS
  conda deactivate

  ###### BWA MEM
  module load bwa
  module load samtools

  cd $WORK_DIR
  mkdir 03_BWA-MEM
  cd 03_BWA-MEM

  cp ../01_hifiasm/${OUTPUT}.bp.p_ctg.fasta .
  bwa index ${OUTPUT}.bp.p_ctg.fasta
  samtools faidx ${OUTPUT}.bp.p_ctg.fasta

  echo "Aligning HiC reads to BWA-MEM..."
  bwa mem -t $THREADS ../01_hifiasm/${OUTPUT}.bp.p_ctg.fasta $R1 $R2 | \
      samtools sort -@ $THREADS -o ${OUTPUT}_aligned_sorted.bam

  samtools index ${OUTPUT}_aligned_sorted.bam

  ###### YAHS
  source activate yahs

  cd $WORK_DIR
  mkdir 04_YaHs
  cd 04_YaHs

  echo "Scaffolding with YaHs..."
  yahs ../03_BWA-MEM/${OUTPUT}.bp.p_ctg.fasta ../03_BWA-MEM/${OUTPUT}_aligned_sorted.bam
  conda deactivate