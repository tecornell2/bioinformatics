#!/bin/bash
#SBATCH --job-name mpile_nextRAD
#SBATCH --output mpileup_output
#SBATCH --nodes 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 100gb
#SBATCH --time 6:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

# load package
module load bcftools
module load gnuparallel

# Create BWA database
# bwa index genome.fasta
# index .bam files of each sample

REF="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/hifi_only_pipeline/Pegre-CLP3001_assembled_blood.fa"
export REF

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/

mkdir -p ./03_mpileup/variants

parallel -a 00_samples_list.txt  -j 5 \
  '
  echo "Start {1}"
  
### --------------------------------
### Call variants
### --------------------------------

  if  [ ! -f ./03_mpileup/variants/{1}.vcf.gz ]; then

   bcftools mpileup -Ou \
    -q 20 -Q 20 -P ILLUMINA \
    -a FORMAT/DP,FORMAT/AD \
    -f $REF ./02_align/{1}_aligned_sorted_RG.bam | \
   bcftools call -mv \
    --threads 8 \
    -f GQ \
    -a GQ,GP \
    -Oz \
    -o ./03_mpileup/variants/{1}.vcf.gz
  fi

  cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/03_mpileup/variants/

  if [ ! -f {1}.vcf.gz.csi ]; then
	bcftools index {1}.vcf.gz
  fi

  echo "Finished {1}"
  '




