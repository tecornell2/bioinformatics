
	######################################################
	############ fastQC and trim reads run1 ##############
	######################################################

    trim_galore --paired -j 8 -o ./01_trim_galore/{1}/ \
        00_raw/fastq/{1}_*_R1_001.fastq.gz \
		00_raw/fastq/{1}_*_R2_001.fastq.gz

    mv ./01_trim_galore/{1}/{1}*_val_1.fq.gz ./01_trim_galore/{1}/{1}_R1.run1.fq.gz
    mv ./01_trim_galore/{1}/{1}*_val_2.fq.gz ./01_trim_galore/{1}/{1}_R2.run1.fq.gz


	fastqc \
        -o ./01_trim_galore/{1}/fastqc \
        -m 1000 \
		-t 6 \
        ./01_trim_galore/{1}/{1}_R1.run1.fq.gz \
        ./01_trim_galore/{1}/{1}_R2.run1.fq.gz

	######################################################
	############ fastQC and trim reads run2 ##############
	######################################################

    trim_galore --paired -j 8 -o ./01_trim_galore/{1}/ \
        00_raw/fastq2/{1}_*_R1_001.fastq.gz \
		00_raw/fastq2/{1}_*_R2_001.fastq.gz

    mv ./01_trim_galore/{1}/{1}*_val_1.fq.gz ./01_trim_galore/{1}/{1}_R1.run2.fq.gz
    mv ./01_trim_galore/{1}/{1}*_val_2.fq.gz ./01_trim_galore/{1}/{1}_R2.run2.fq.gz

	fastqc \
        -o ./01_trim_galore/{1}/fastqc \
        -m 1000 \
		-t 6 \
        ./01_trim_galore/{1}/{1}_R1.run2.fq.gz \
        ./01_trim_galore/{1}/{1}_R2.run2.fq.gz
