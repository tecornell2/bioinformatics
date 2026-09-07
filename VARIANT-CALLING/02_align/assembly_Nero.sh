#!/bin/bash

#SBATCH --job-name 01_Nero
#SBATCH --output 01_assemble_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 30
#SBATCH --partition nodeviper
#SBATCH --mem 100gb
#SBATCH --time 100:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

set -euo pipefail

module load gnuparallel/20210222
module load samtools
module load anaconda3/2023.09-0

cd /project/viper/venom/Taryn/Nerodia/popgen/

# Ensure you have a file with sample names to feed into parallel
# Run the assembly pipeline for each sample through parallel

# bwa index Nfasc-CLP2811_assembled_blood.scaffold.fasta

parallel -a 00_samples_list.txt -j 2 -k --colsep '\t' 'echo {1} started

        source activate bio

        cd /project/viper/venom/Taryn/Nerodia/popgen/

        ###############################################################################
        ############ Make directory for trimmed reads and trim sequences ##############
        ###############################################################################

        mkdir -p 02_trim/{1}

        if ! compgen -G "02_trim/{1}/{1}*_R2_trim.fastq.gz" > /dev/null; then

		R1=(/project/viper/venom/Taryn/Nerodia/popgen/01_concat/{1}/{1}*_R1*.fastq.gz)
		R2=(/project/viper/venom/Taryn/Nerodia/popgen/01_concat/{1}/{1}*_R2*.fastq.gz)

                trim_galore --paired -j 6 --fastqc -o 02_trim/{1} "${R1[0]}" "${R2[0]}" \
                &> 02_trim/{1}/{1}_tg.log

                mv 02_trim/{1}/{1}*_R1_val_1.fq.gz 02_trim/{1}/{1}_R1_trim.fastq.gz
                mv 02_trim/{1}/{1}*_R2_val_2.fq.gz 02_trim/{1}/{1}_R2_trim.fastq.gz
        fi

        ###############################################################################
        ############ Make directories for alignments and align sequences ##############
        ###############################################################################

	sample="{1}"
	trim_dir="/project/viper/venom/Taryn/Nerodia/popgen/02_trim/$sample"

	mkdir -p /project/viper/venom/Taryn/Nerodia/popgen/03_align/{1}/

        cd /project/viper/venom/Taryn/Nerodia/popgen/03_align/{1}/

    # Accept either naming scheme:
    #   1) sample_R1_trim.fastq.gz
    #   2) sample_WGS_blood_R1_trim.fastq.gz
    trimmed_R1=""
    trimmed_R2=""

	if [[ -s "$trim_dir/${sample}_R1_trim.fastq.gz" && -s "$trim_dir/${sample}_R2_trim.fastq.gz" ]]; then
 	   trimmed_R1="$trim_dir/${sample}_R1_trim.fastq.gz"
	    trimmed_R2="$trim_dir/${sample}_R2_trim.fastq.gz"
	elif [[ -s "$trim_dir/${sample}_WGS_blood_R1_trim.fastq.gz" && -s "$trim_dir/${sample}_WGS_blood_R2_trim.fastq.gz" ]]; then
	    trimmed_R1="$trim_dir/${sample}_WGS_blood_R1_trim.fastq.gz"
	    trimmed_R2="$trim_dir/${sample}_WGS_blood_R2_trim.fastq.gz"
	else
	    echo "No trimmed FASTQs found for $sample" >&2
	    exit 1
	fi

        if [ ! -s {1}_aligned_sorted.bam ]; then

		bwa mem -t 8 /project/viper/venom/Taryn/Nerodia/popgen/genome/Nfasc-CLP2811_assembled_blood.scaffold.fasta \
                	"$trimmed_R1" "$trimmed_R2" 2> {1}_aligned.log | \
			samtools sort -o {1}_aligned_sorted.bam

        fi

        ###############################################################################
        #################### Add read group info to BAM file ##########################
        ###############################################################################


        if [ ! -f {1}_aligned_sorted_RG.bam ]; then

                picard -Xmx45g AddOrReplaceReadGroups \
                I={1}_aligned_sorted.bam \
                O={1}_aligned_sorted_RG.bam \
                RGID={1} \
                RGLB={1} \
                RGPL=ILLUMINA \
                RGPU={1} \
                RGSM={1}
        fi


        ###############################################################################
        ###################### Mark duplicates in BAM file ############################
        ###############################################################################


        if [ ! -f {1}_aligned_sorted_marked_RG.bam ]; then

                picard -Xmx45g MarkDuplicates \
                I={1}_aligned_sorted_RG.bam \
                O={1}_aligned_sorted_marked_RG.bam \
                M=metrics.txt
        fi

        ###############################################################################
        ######################### Get stats on assembly ###############################
        ###############################################################################


        if [ -f {1}_aligned_sorted_marked_RG.bam ]; then

                samtools stats {1}_aligned_sorted_marked_RG.bam > {1}_aligned_sorted_marked_RG.stats
        fi

echo {1} finished'
