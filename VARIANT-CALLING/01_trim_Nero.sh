#!/bin/bash
#SBATCH --job-name trim_Nero_fastqc
#SBATCH --output trim_Nero_fastqc_output
#SBATCH --ntasks 30
#SBATCH --mem 20gb 
#SBATCH --partition nodeviper
#SBATCH --time 6:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load gnuparallel/20210222
module load anaconda3/2023.09-0
source activate bio

find /project/viper/venom/Taryn/Nerodia/01_trimmed/*/ -name "*_val_*.fq.gz" | \
parallel -j 30 'fastqc {} -o $(dirname {})'
