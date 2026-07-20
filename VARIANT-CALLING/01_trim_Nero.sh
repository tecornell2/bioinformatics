#!/bin/bash
#SBATCH --job-name trim_Nero
#SBATCH --output trim_Nero_output
#SBATCH --ntasks 30
#SBATCH --mem 20gb
#SBATCH --partition nodeviper
#SBATCH --time 36:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load gnuparallel/20210222

cd /project/viper/venom/Taryn/Nerodia/00_raw/ 

parallel -a 00_samples_list.txt -j 30 -k --colsep '\t' 'echo {1} started
	
	module load anaconda3/2023.09-0
	source activate bio

	cd /project/viper/venom/Taryn/Nerodia/00_raw/{1}/

    for R1 in *_R1_001.fastq.gz; do
        R2=${R1/_R1_001/_R2_001}
        mkdir -p /project/viper/venom/Taryn/Nerodia/01_trimmed/{1}
        trim_galore --paired --fastqc -o /project/viper/venom/Taryn/Nerodia/01_trimmed/{1}/ $R1 $R2 &> /project/viper/venom/Taryn/Nerodia/01_trimmed/{1}/trim_log.txt
    done

echo {1} finished ' 
