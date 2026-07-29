#!/bin/bash

#SBATCH --job-name 02_align_run1_Plest
#SBATCH --output 02_align_run1_output
#SBATCH --partition nodeviper
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 128gb
#SBATCH --time 100:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

set -euo pipefail

module load gnuparallel

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/

ref="/project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/genome/Pegre-CLP3001_hifi_hic_genome.clean.fa"
export ref

parallel -a 00_samples_list3.txt -j 2 -k 'echo {1} started

    module load anaconda3/2023.09-0
    source activate bio
    module load bwa
    module load samtools

    ############ align sequences ##############
    sample={1}
    trim_dir="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/01_trim_galore/${sample}"
    mkdir -p /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/${sample}/
    cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/${sample}/

    trimmed_R1="$trim_dir/${sample}_R1.trim.fq.gz"
    trimmed_R2="$trim_dir/${sample}_R2.trim.fq.gz"

    if [ ! -s "${sample}_aligned_sorted_RG.bam" ]; then
        bwa mem -t 8 \
            -R "@RG\tID:${sample}_1\tSM:${sample}\tLB:${sample}_1\tPL:ILLUMINA\tPU:${sample}_1" \
            "$ref" "$trimmed_R1" "$trimmed_R2" 2> "${sample}_aligned.log" | \
        samtools sort -@ 4 -o "${sample}_aligned_sorted_RG.bam"
    fi

    ########## mark duplicates ###########

    if [ ! -f "${sample}_aligned_sorted_marked_RG.bam" ]; then
        picard -Xmx64g MarkDuplicates \
            -I "${sample}_aligned_sorted_RG.bam" \
            -O "${sample}_aligned_sorted_marked_RG.bam" \
            -M metrics.txt
    fi

    ######### stats #########

    if [ -f "${sample}_aligned_sorted_marked_RG.bam" ]; then
        samtools stats "${sample}_aligned_sorted_marked_RG.bam" > "${sample}_aligned_sorted_marked_RG.stats"
        samtools index "${sample}_aligned_sorted_marked_RG.bam"
    fi

echo ${sample} finished'
