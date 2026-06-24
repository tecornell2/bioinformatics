#!/bin/bash

#SBATCH --job-name 01_assemble_wgs_Plest
#SBATCH --output 01_assemble_wgs_Plest_output
#SBATCH --partition nodeviper
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 128gb
#SBATCH --time 100:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

set -euo pipefail

module load anaconda3/2023.09-0
module load samtools
module load gnuparallel/20210222

source activate bio

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/

# bwa index Pegre-CLP3001_assembled_blood.fa 

parallel -a 00_samples_list.txt -j 2 -k --colsep '\t' 'echo {1} started

        cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/

        ###############################################################################
        ############ Make directories for alignments and align sequences ##############
        ###############################################################################

	sample="{1}"
	trim_dir="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/01_trim_galore/$sample"

	mkdir -p /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/{1}/

        cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/{1}/

        trimmed_R1="$trim_dir/${sample}_R1_trim.fastq.gz"
        trimmed_R2="$trim_dir/${sample}_R2_trim.fastq.gz"

        if [ ! -s {1}_aligned_sorted.bam ]; then

		bwa mem -t 8 /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/genome/Pegre-CLP3001_assembled_blood.fa \
                	"$trimmed_R1" "$trimmed_R2" 2> {1}_aligned.log | \
			samtools sort -o {1}_aligned_sorted.bam

        fi

        ###############################################################################
        ###################### Mark duplicates in BAM file ############################
        ###############################################################################


        if [ ! -f {1}_aligned_sorted_marked.bam ]; then

                picard -Xmx24g MarkDuplicates \
                I={1}_aligned_sorted.bam \
                O={1}_aligned_sorted_marked.bam \
                M=metrics.txt
        fi

        ###############################################################################
        #################### Add read group info to BAM file ##########################
        ###############################################################################


        if [ ! -f {1}_aligned_sorted_marked_RG.bam ]; then

                picard -Xmx24g AddOrReplaceReadGroups \
                I={1}_aligned_sorted_marked.bam \
                O={1}_aligned_sorted_marked_RG.bam \
                RGID={1} \
                RGLB={1} \
                RGPL=ILLUMINA \
                RGPU={1} \
                RGSM={1}
        fi

        ###############################################################################
        ######################### Get stats on assembly ###############################
        ###############################################################################


        if [ -f {1}_aligned_sorted_marked_RG.bam ]; then

                samtools stats {1}_aligned_sorted_marked_RG.bam > {1}_aligned_sorted_marked_RG.stats
        fi

echo {1} finished'