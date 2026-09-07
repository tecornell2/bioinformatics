#!/bin/bash

#SBATCH --job-name 02_align_nextRAD
#SBATCH --output 02_align_nextRAD_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 64gb
#SBATCH --time 48:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load anaconda3/2023.09-0
module load gnuparallel/20210222

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/

REF="/project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/genome/Pegre-CLP3001_assembled_blood.fa"
TRIM_DIR="/project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/01_trim_galore"
export REF TRIM_DIR

parallel -a 00_samples_list.txt -j 4 -k --colsep '\t' 'echo {1} started

        source activate bio
        module load samtools

        sample={1}
        sorted_bam="${sample}_aligned_sorted.bam"
        dedup_bam="${sample}_aligned_sorted_dedup.bam"

        cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/02_align/
        mkdir -p "${sample}"
        cd "${sample}"

        ###########################################
        ############ Align sequences ##############
        ###########################################

        if [ ! -s {1}_aligned_sorted.bam ]; then

        bwa mem -t 6 \
          -R "@RG\tID:${sample}\tSM:${sample}\tLB:${sample}\tPL:ILLUMINA\tPU:${sample}" \
          "$REF" "${TRIM_DIR}/${sample}.trim.fq.gz" | \
          samtools sort -@ 4 -o "${sorted_bam}"
        fi

        ###########################################
        ########### Remove duplicates #############
        ###########################################

        samtools rmdup -s "${sorted_bam}" "${dedup_bam}"

        ##########################################
        ########### Index final .bam #############
        ##########################################


        if [ ! -f "${dedup_bam}.bai" ]; then

            samtools index "${dedup_bam}"
	          samtools stats "${dedup_bam}" > "${sample}_aligned_sorted_dedup.stats"

        fi

'
