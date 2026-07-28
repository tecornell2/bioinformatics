#!/bin/bash

#SBATCH --job-name 01_wgs_assemble_Plest
#SBATCH --output 01_assemble_wgs_output
#SBATCH --partition nodeviper
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 128gb
#SBATCH --time 100:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

set -euo pipefail

module load gnuparallel/20210222

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/

# bwa index Pegre-CLP3001_assembled_blood.fa

parallel -a 00_samples_list.txt -j 2 -k --colsep '\t' 'echo {1} started

        cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/

	module load anaconda3/2023.09-0
	source activate bio
	module load bwa
	module load samtools

        ###############################################################################
        ############ Make directories for alignments and align sequences ##############
        ###############################################################################

	trim_dir="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/01_trim_galore/{1}"

	mkdir -p /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/{1}/

        cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/{1}/

        trimmed_R1="$trim_dir/{1}_R1.trim.fq.gz"
        trimmed_R2="$trim_dir/{1}_R2.trim.fq.gz"

        if [ ! -s {1}_aligned_sorted.bam ]; then

		bwa mem -t 8 /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/04_YaHs/Pegre-CLP3001_hifi_hic_scaffold_genome.fasta \
                	"$trimmed_R1" "$trimmed_R2" 2> {1}_aligned.log | \
			samtools sort -o {1}_aligned_sorted.bam

        fi

        ###############################################################################
        #################### Add read group info to BAM file ##########################
        ###############################################################################


        if [ ! -f {1}_aligned_sorted_RG.bam ]; then

                picard -Xmx24g AddOrReplaceReadGroups \
                -I {1}_aligned_sorted.bam \
                -O {1}_aligned_sorted_RG.bam \
                -RGID {1} \
                -RGLB {1} \
                -RGPL ILLUMINA \
                -RGPU {1} \
                -RGSM {1}
        fi

        ###############################################################################
        ###################### Mark duplicates in BAM file ############################
        ###############################################################################


        if [ ! -f {1}_aligned_sorted_marked_RG.bam ]; then

                picard -Xmx64g MarkDuplicates \
                -I {1}_aligned_sorted_RG.bam \
                -O {1}_aligned_sorted_marked_RG.bam \
                -M metrics.txt
        fi

        ###############################################################################
        ######################### Get stats on assembly ###############################
        ###############################################################################


        if [ -f {1}_aligned_sorted_marked_RG.bam ]; then

                samtools stats {1}_aligned_sorted_marked_RG.bam > {1}_aligned_sorted_marked_RG.stats
		samtools index {1}_aligned_sorted_marked_RG.bam
        fi

echo {1} finished'
