#!/bin/bash
#SBATCH --job-name mpileup_nextRAD
#SBATCH --output mpileup_output
#SBATCH --nodes 1
#SBATCH --cpus-per-task 30
#SBATCH --mem 50gb
#SBATCH --time 6:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

# load package
module load bcftools
module load gnuparallel

### --------------------------------
### Call variants
### --------------------------------

# Create BWA database
# bwa index genome.fasta
# index .bam files of each sample

REF="/project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/genome/Pegre-CLP3001_hifi_hic_genome.clean.fa"
export REF

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/

mkdir -p ./03_mpileup/variants

parallel -a 00_samples_list.txt  -j 5 \
  '
  echo "Start {1}"

  if  [ ! -f ./03_mpileup/variants/{1}.vcf.gz ]; then

   bcftools mpileup -Ou \
    -q 20 -Q 20 -P ILLUMINA \
    -a FORMAT/DP,FORMAT/AD \
    -f $REF ./02_align/no_rmdup/{1}/{1}_aligned_sorted_RG.bam | \
   bcftools call -mv \
    --threads 6 \
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

### --------------------------------
### Merge samples
### --------------------------------

  bcftools merge *.vcf.gz \
	-Oz -o catalog.vcf.gz

### --------------------------------
### Add tags and keep SNPs only
### --------------------------------

  bcftools view \
    -v snps \
    catalog.vcf.gz -Ou |
  bcftools +fill-tags -Ou -- -t AC,AN,AF,NS |
  bcftools sort -Oz -o catalog.snps.vcf.gz
