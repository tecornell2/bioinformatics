#!/bin/bash
#SBATCH --job-name 
#SBATCH --output _output
#SBATCH --nodes 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 100gb
#SBATCH --time 6:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

# load package
module load samtools
module load GNUparallel

### --------------------------------
### Call variants
### --------------------------------

# Create BWA database
# bwa index genome.fasta
# index .bam files of each sample

REF="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/04_YaHs/Pegre-CLP3001_hifi_hic_scaffold_genome.fasta"
export REF

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/

parallel -a ./01_process/aa.files.txt  -j 5 \
  '
  echo {}
   bcftools mpileup -Ou \
    -q 20 -Q 20 -P ILLUMINA \
    -a FORMAT/DP,FORMAT/AD \
    -f $REF | \
   bcftools call -mv \
    --threads 8 \
    -f GQ \
    -a GQ,GP \
    -Oz \
    -o variants/{1}.vcf.gz
  '





