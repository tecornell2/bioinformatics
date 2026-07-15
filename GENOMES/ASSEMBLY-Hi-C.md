# GENOME ASSEMBLY

The following pipeline is a general pipeline for PacBio HiFi genome assembly with HiC integration. It is heavily based on a open source tutorials from Rhett Rautsaw (https://github.com/RhettRautsaw/Bioinformatics/blob/master/tutorials/HiFi_Genomics.md), Pedro Nachtigall (https://github.com/pedronachtigall/HI-genome-assembly-pipeline), and notes from PhD candidate John Henry.

## 00. Raw Data
* Pacific Biosciences HiFi long reads are provided as one fastq file
* Hi-C short reads are provided as rtwo fastq files (paired end)

### 0.2 Quality Check [fastQC]
```sh
```
## 01. Trim [Trim Galore!]
Documentation: https://github.com/FelixKrueger/TrimGalore
```sh

```

### 1.1 Clean Contamination [kraken2]
```sh
#!/bin/bash
#SBATCH --job-name kraken2
#SBATCH --output kraken2_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 15
#SBATCH --mem 100gb
#SBATCH --time 10:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load kraken2

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/

## download databases
# can take 14+ hours
#kraken2-build --use-ftp --download-taxonomy --db db
#kraken2-build --use-ftp --download-library bacteria --db db
#kraken2-build --use-ftp --download-library UniVec_Core --db db

# add relevant closely related genome
kraken2-build --add-to-library /project/viper/venom/Taryn/Plestiodon/Pfasciatus/00_raw/ncbi_dataset/rPleFas1.1.fa --db db

## build complete database
kraken2-build --build --db db --threads 15

## run kraken2
kraken2 --threads 15 Pegre-CLP3001_WGS_blood_hifi.fastq.gz --db db --report reports/Pegre-CLP3001.hifi.kraken.report.txt --output output/Pegre-CLP3001.hifi.kraken.output.txt

## extract relevant matches
module load anaconda3
source activate kraken2

extract_kraken_reads.py
  -s /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/00_raw/Pegre-CLP3001/WGS/Blood/2026_03_27_UDel_PacBio_HiFi/00_raw/Pegre-CLP3001_WGS_blood_hifi.fastq.gz \
  -k ../output/Pegre-CLP3001.hifi.kraken.output.txt \
  --report ../reports/Pegre-CLP3001.hifi.kraken.report.txt \
  -t 32561 \
  -o Pegre-CLP3001_cleaned_hifi.fastq \
  --include-children

# -t 32561 = keeping all Sauria reads
```

## 02. Assembly [hifiasm]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name hifiasm
#SBATCH --output hifiasm_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 100gb
#SBATCH --time 3:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load anaconda3/2023.09-0
  source activate hifiasm

  cd /project/viper/venom/Taryn/Nerodia/Nclarkii/02_hifiasm
hifiasm -o Pegre-CLP3001_assembled_blood_hic -t 32 --h1 CLP3001_S7_R1_001_val_1.fq.gz --h2 CLP3001_S7_R2_001_val_2.fq.gz Pegre-CLP3001_WGS_blood_hifi.fastq.gz
    
  # converts output .bp.p_ctg.gfa file from hifiasm to .fasta file for next steps
  awk '/^S/{print ">"$2;print $3}' Pegre-CLP3001_assembled_blood_hic.bp.p_ctg.gfa > Pegre-CLP3001_assembled_blood_hic.bp.p_ctg.fasta
```

hifiasm requires input reads in FASTQ format
-t sets the number of CPUs
-o sets the output file prefix, *do not include suffixes*

#### hifiasm Outputs
1. Primary contigs (bp.p_ctg.gfa)
    - For reference genome, downstream annotation or synteny
2. Haplotype-resolved contigs (bp.hap1.p_ctg.gfa and bp.hap2.p_ctg.gfa)
    - For heterozygosity, parental haplotypes

Resource: https://hifiasm.readthedocs.io/en/latest/interpreting-output.html 

---
### 2.1 Stats on Assembly [bbstats]
Run basic statistics on assmebly prior to next step.

```sh
bbstats.sh in=Pegre-CLP3001_assembled_blood_hic.bp.p_ctg.fasta out=Pegre-CLP3001_assembled_blood_hic.bp.p_ctg.fasta.stats.txt Xmx64g
```

<details><summary> bbstats .txt output file</summary>


```sh
A       C       G       T       N       IUPAC   Other   GC      GC_stdev
0.2936  0.2065  0.2064  0.2934  0.0000  0.0000  0.0000  0.4130  0.0523

Main genome scaffold total:             652
Main genome contig total:               652
Main genome scaffold sequence total:    1868.768 Mb
Main genome contig sequence total:      1868.768 Mb     0.000% gap
Main genome scaffold N/L50:             15/40.169 Mbp
Main genome contig N/L50:               15/40.169 Mbp
Main genome scaffold N/L90:             87/2.16 Mbp
Main genome contig N/L90:               87/2.16 Mbp
Max scaffold length:                    132.563 Mbp
Max contig length:                      132.563 Mbp
Number of scaffolds > 50 KB:            523
% main genome in scaffolds > 50 KB:     99.76%


Minimum         Number          Number          Total           Total           Scaffold
Scaffold        of              of              Scaffold        Contig          Contig
Length          Scaffolds       Contigs         Length          Length          Coverage
--------        --------------  --------------  --------------  --------------  --------
    All                    652             652   1,868,768,395   1,868,768,395   100.00%
 10 Kbp                    652             652   1,868,768,395   1,868,768,395   100.00%
 25 Kbp                    632             632   1,868,341,481   1,868,341,481   100.00%
 50 Kbp                    523             523   1,864,196,645   1,864,196,645   100.00%
100 Kbp                    399             399   1,855,130,931   1,855,130,931   100.00%
250 Kbp                    287             287   1,836,953,774   1,836,953,774   100.00%
500 Kbp                    214             214   1,810,236,164   1,810,236,164   100.00%
  1 Mbp                    138             138   1,756,125,051   1,756,125,051   100.00%
2.5 Mbp                     84              84   1,676,024,224   1,676,024,224   100.00%
  5 Mbp                     53              53   1,567,080,144   1,567,080,144   100.00%
 10 Mbp                     36              36   1,455,695,369   1,455,695,369   100.00%
 25 Mbp                     25              25   1,284,235,163   1,284,235,163   100.00%
 50 Mbp                      9               9     695,168,459     695,168,459   100.00%
100 Mbp                      2               2     252,884,988     252,884,988   100.00%
```

</details>
<p></p>

**Three dimensions (3 C's) of *de novo* genome assembly:**
1. Contiguity: the length of continuous stretches of DNA sequence [N50, or similar measures]
2. Completeness: the presence of highly conserved genes [BUSCO analysis]
3. Correctness: the accuracy of basepair readings

Reference Article: https://www.pacb.com/blog/beyond-contiguity/

## 03. Quality of Assembly [BUSCO]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name BUSCO
#SBATCH --output BUSCO_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 50
#SBATCH --mem 120gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load anaconda3/2023.09-0
  source activate busco

  cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/04_BUSCO

  busco -i Pegre-CLP3001_assembled_blood_hic.bp.p_ctg.fasta  -m genome -l /home/tecorn/busco_downloads/lineages/tetrapoda_odb12 -c 50 -o 04_BUSCO
```

Documentation: https://busco.ezlab.org/ 

## 04. Align and Index [BWA+MEM] [samtools]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name=YaHs_align
#SBATCH --output=YaHs_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 100gb
#SBATCH --time 6:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load bwa
  module load anaconda3/2023.09-0
  source activate yahs
  module load samtools

  cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/03_YaHs

  # Define variables
  THREADS=32
  R1="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/00_raw/Pegre-CLP3001/HiC/Muscle/2026_06_24_CUGBF_Illumina_HiC/01_trim_galore/CLP3001_S7_R1_001_val_1.fq.gz"
  R2="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/00_raw/Pegre-CLP3001/HiC/Muscle/2026_06_24_CUGBF_Illumina_HiC/01_trim_galore/CLP3001_S7_R2_001_val_2.fq.gz"
  REF="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/genome/Pegre-CLP3001_assembled_blood.fa"
  OUT_BAM="Pegre-CLP3001_HiC_aligned.bam"
  SORTED_BAM="Pegre-CLP3001_HiC_aligned_sorted.bam"

# Input file type required for scaffolding: .fai
  samtools faidx <reference>

  # Index genome if needed
  if [ ! -f "${GENOME}.bwt" ]; then
      echo "[INFO] Indexing genome with BWA..."
      bwa index $GENOME
  #fi

  # Run BWA-MEM and process with samtools
  bwa mem -t $THREADS $REF $R1 $R2 | \
      samtools sort -@ $THREADS -o $SORTED_BAM

  # Index the sorted BAM
  samtools index $SORTED_BAM

```

## 05. Scaffold [YaHs]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name=YaHs_align
#SBATCH --output=03_YaHs_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 100gb
#SBATCH --time 6:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

 ###### YAHS                                                                                                                                                                                                                                     
  source activate yahs                                                                                                                                                                                                                            

  cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome
  mkdir 04_YaHs
  cd 04_YaHs

  yahs ../03_BWA-MEM/Pegre-CLP3001_blood_hifi.hic.p_ctg.fasta ../03_BWA-MEM/Pegre-CLP3001_hic_aligned_sorted.bam
```

### 5.1 Stats on Assembly [bbstats]
Run basic statistics on assmebly (N50) prior to next step.

```sh
bbstats.sh in=Pegre-CLP3001_assembled_blood_hic.bp.p_ctg.fasta out=Pegre-CLP3001_assembled_blood_hic.bp.p_ctg.fasta.stats.txt Xmx64g
```

## 06. Pre-text Viewer
```sh
#!/bin/bash
#SBATCH --job-name=Pegre-PretextMap
#SBATCH --output=Pegre-PretextMap_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 100gb
#SBATCH --time 20:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load anaconda3/2023.09-0
  source activate pretext
  module load bwa
  module load samtools

  cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/05_PretextMap

  # Define variables
  THREADS=32
  R1="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/00_raw/Pegre-CLP3001/HiC/Muscle/2026_06_24_CUGBF_Illumina_HiC/01_trim_galore/CLP3001_S7_R1_001_val_1.fq.gz"
  R2="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/00_raw/Pegre-CLP3001/HiC/Muscle/2026_06_24_CUGBF_Illumina_HiC/01_trim_galore/CLP3001_S7_R2_001_val_2.fq.gz"
  REF="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/04_YaHs/Pegre-CLP3001_hifi_hic_scaffold_genome.fasta"
  SORTED_BAM="Pegre-CLP3001_HiC_scaffold_aligned_sorted.bam"

  samtools faidx $REF

  if [ ! -f "${REF}.bwt" ]; then
      echo "[INFO] Indexing genome with BWA..."
      bwa index $REF
  fi

  bwa mem -t $THREADS $REF $R1 $R2 | \
      samtools sort -@ $THREADS -o $SORTED_BAM

  samtools index $SORTED_BAM

  samtools view -h $SORTED_BAM | PretextMap -o Pegre-CLP3001_hic_map.standard.pretext
```

# GENOME ANNOTATION
<information>

## 7. Transposable Element Annotation and Repeat Masking [EDTA]
Extensive De-novo TE Annotator (EDTA) performs RepeatModeler/RepeatMasker

### .job file
```sh
#!/bin/bash
#SBATCH --job-name 04_EDTA_Nfasc
#SBATCH --output 04_EDTA_Nfasc_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 256gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

 module load anaconda3/2023.09-0
 source activate edta

 cd /project/viper/venom/Taryn/Nerodia/Nfasciata/04_EDTA

 # run EDTA on assembled genome
 perl /home/tecorn/.conda/envs/edta/share/EDTA/EDTA.pl \
 --genome ../Nfasc-CLP2811_genome.fasta \
 --species others \
 --step all \
 --sensitive 1 \
 --anno 1 \
 --force 1 \
 --threads 40
```
force [0|1] Use rice TEs to continue when no confident TE candidates are found (1)\
sensitive [0|1]	Use RepeatModeler to identify remaining TEs (1)\
overwrite [0|1] Use to overwrite previous steps (files) produced by EDTA (default, 0)\
Documentation: https://github.com/oushujun/EDTA?tab=readme-ov-file \ https://www.repeatmasker.org/ 

---
### 7.1 Soft Masking [RepeatMasker]

```sh
#!/bin/bash
#SBATCH --job-name 07_RepeatMask_Nfasc
#SBATCH --output 07_RepeatMask_Nfasc_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 256gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

 module load anaconda3/2023.09-0
 source activate edta

 cd /project/viper/venom/Taryn/Nerodia/Nfasciata/04_EDTA

 RepeatMasker -pa 24 -e ncbi -lib Nfasc-CLP2811_genome.fasta.mod.EDTA.TElib.fa \
  -gff -xsmall Nfasc-CLP2811_genome.fasta
```
lib = library input file
pa = parallel mode
xsmall = masks repeats in the input genome sequence using soft-masking

 ---
 Notes
 ### 0.1 Concatenate 
If you are combining data from multiple runs, you can concatenate the reads into one file for the subsequent analyses. 
  HiFi Example
  ```Nfasc-CLP2811_WGS_blood_hifi-1.fastq.gz Nfasc-CLP2811_WGS_blood_hifi-2.fastq.gz > Nfasc-CLP2811_WGS_blood_hifi_v2.fastq.gz```

---
```sh
## SLURM script

#!/bin/bash
#SBATCH --job-name genome_assembly_hifi_hic
#SBATCH --output genome_assembly_hifi_hic_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 256gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load anaconda3/2023.09-0

  ###### VARIABLES
  THREADS=32
  WORK_DIR="/project/viper/venom/Taryn/Nerodia/genomes/Nclarkii"
  R1="/project/viper/venom/Taryn/Nerodia/genomes/Nclarkii/00_raw/HiC/Muscle/2026_06_24_CUGBF_Illumina_HiC/01_trim_galore/CLP2810_S4_R1_001.fastq.gz"
  R2="/project/viper/venom/Taryn/Nerodia/genomes/Nclarkii/00_raw/HiC/Muscle/2026_06_24_CUGBF_Illumina_HiC/01_trim_galore/CLP2810_S4_R2_001.fastq.gz"
  HIFI="/project/viper/venom/Taryn/Nerodia/genomes/Nclarkii/01_concat/Nclar-CLP2810_WGS_blood_hifi_v2.fastq.gz"
  OUTPUT="Nclar-CLP2810_blood_hifi_hic"

  ###### HIFIASM
  source activate hifiasm

  cd $WORK_DIR
  mkdir 01_hifiasm
  cd 01_hifiasm

  echo "Assembling draft genome with hifiasm..."
  hifiasm -o $OUTPUT -t $THREADS --h1 $R1 --h2 $R2 $HIFI
  awk '/^S/{print ">"$2;print $3}' ${OUTPUT}.bp.p_ctg.gfa > ${OUTPUT}.bp.p_ctg.fasta
  bbstats.sh in=${OUTPUT}.bp.p_ctg.fasta out=${OUTPUT}.bp.p_ctg.fasta.stats.txt Xmx64g
  conda deactivate

  ### ### BUSCO
  source activate busco

  cd $WORK_DIR
  mkdir 02_BUSCO
  cd 02_BUSCO

  echo "Running BUSCO..."
  busco -i ../01_hifiasm/${OUTPUT}.bp.p_ctg.fasta -m genome -l /home/tecorn/busco_downloads/lineages/tetrapoda_odb12 -c $THREADS
  source deactivate

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
      samtools sort -@ $THREADS -o ${OUTPUT}_sorted.bam
  samtools index ${OUTPUT}_sorted.bam

  ###### YAHS
  source activate yahs

  cd $WORK_DIR
  mkdir 04_YaHs
  cd 04_YaHs

  echo "Scaffolding with YaHs..."
  yahs ../03_BWA-MEM/${OUTPUT}.bp.p_ctg.fasta ../03_BWA-MEM/${OUTPUT}_sorted.bam
```
