#!/bin/bash

#SBATCH --job-name 02_align_52-60
#SBATCH --output 02_align_output
#SBATCH --partition nodeviper
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 128gb
#SBATCH --time 100:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load gnuparallel/20210222

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/

ref="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/04_YaHs/Pegre-CLP3001_hifi_hic_scaffold_genome.fasta"
export ref

parallel -a 00_samples_list3.txt -j 4 -k --colsep '\t' 'echo {1} started

    module load anaconda3/2023.09-0
    source activate bio
	module load bwa
	module load samtools

    cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/

	mkdir -p ./01_trim_galore/{1}/fastqc/
	mkdir -p ./00_raw/fastq/fastqc

	###############################################################################
	############ Make directories for alignments and align sequences ##############
	###############################################################################

	sample={1}

	trim_dir="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/01_trim_galore/${sample}"
	align_dir="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/${sample}"

	mkdir -p "${align_dir}"
	cd "${align_dir}"

	r1_set1="${trim_dir}/${sample}_R1.run1.fq.gz"
	r2_set1="${trim_dir}/${sample}_R2.run1.fq.gz"

	r1_set2="${trim_dir}/${sample}_R1.run2.fq.gz"
	r2_set2="${trim_dir}/${sample}_R2.run2.fq.gz"

	bam_set1="${sample}_set1_sorted.bam"
	bam_set2="${sample}_set2_sorted.bam"
	merged_bam="${sample}_merged_RG.bam"
	dedup_bam="${sample}_aligned_sorted_marked_RG.bam"


	######################
	###### PIPELINE ######
	######################

	if [ ! -s "${bam_set1}" ]; then
		echo "Aligning run 1 reads for ${sample}..."
		bwa mem -t 8 \
			-R "@RG\tID:${sample}_1\tSM:${sample}\tLB:${sample}_1\tPL:ILLUMINA\tPU:${sample}_1" \
			"${ref}" "${r1_set1}" "${r2_set1}" 2> "${sample}_set1_aligned.log" | \
			samtools sort -@ 4 -o "${bam_set1}"
	fi

	if [ ! -s "${bam_set2}" ]; then
		echo "Aligning run 2 reads for ${sample}..."
		bwa mem -t 8 \
			-R "@RG\tID:${sample}_2\tSM:${sample}\tLB:${sample}_2\tPL:ILLUMINA\tPU:${sample}_2" \
			"${ref}" "${r1_set2}" "${r2_set2}" 2> "${sample}_set2_aligned.log" | \
			samtools sort -@ 4 -o "${bam_set2}"
	fi

	if [ ! -s "${merged_bam}" ]; then
		samtools merge -f "${merged_bam}" "${bam_set1}" "${bam_set2}"
	fi

	if [ ! -s "${dedup_bam}" ]; then
		echo "Marking duplicates for ${sample}..."
		picard -Xmx64g MarkDuplicates \
			-I "${merged_bam}" \
			-O "${dedup_bam}" \
			-M "${sample}_marked_dup_metrics.txt"

		samtools index "${dedup_bam}"
		samtools stats "${dedup_bam}" > "${sample}_merged_RG_marked.stats"
	fi

	echo "${sample} finished"
'
