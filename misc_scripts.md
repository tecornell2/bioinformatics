## GNU parallel
```sh
#!/bin/bash
#SBATCH --job-name Nero_trim_reads
#SBATCH --output Nero_trim_reads_output
#SBATCH --ntasks 30
#SBATCH --mem 20gb 
#SBATCH --node viper
#SBATCH --time 7:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load gnuparallel/20210222

parallel -a 00_samples_list.txt -j 30 -k --colsep '\t' 'echo {1} started
	
	module load anaconda3/2023.09-0
	source activate bio

	cd /project/viper/venom/Taryn/Nerodia/00_raw/{1}/

    for R1 in *_R1_001.fastq.gz; do
        R2=${R1/_R1_001/_R2_001}
        mkdir -p /project/viper/venom/Taryn/Nerodia/01_trimmed/{1}
        trim_galore --paired --phred33 -o /project/viper/venom/Taryn/Nerodia/01_trimmed/{1}/ $R1 $R2 &> /project/viper/venom/Taryn/Nerodia/01_trimmed/{1}/trim_log.txt
    done

echo {1} finished ' 
```

## GNU parallel
```sh
#################
salloc --nodes=1 --ntasks=1 --cpus-per-task=20 --mem=40G --time=2:00:00
# 20 cpus on one node with 2GB per cpu (job)

parallel -j 20 --progress fastqc -q -o fastqc/ {} ::: *.fastq.gz
```

## rename fasta files bulk
```sh
#!/bin/bash
#SBATCH --job-name rename_run816
#SBATCH --output rename_run816_output
#SBATCH --ntasks 1
#SBATCH --mem 10gb 
#SBATCH --time 1:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

# Script to rename FASTQ files based on barcode file
# Usage: ./rename_fastq.sh barcodes_run.txt

BARCODE_FILE="/project/viper/venom/Taryn/Plestiodon/Pegregius/RADseq_clean/01_trim_galore/816/barcodes_run816.txt"

if [ ! -f "$BARCODE_FILE" ]; then
    echo "Error: Barcode file not found: $BARCODE_FILE"
    exit 1
fi

# Read the barcode file and process each line
while IFS=$'\t' read -r combined_barcode sampleID; do
    # Find matching R1 files
    for file in *_${combined_barcode}_*_R1_*_trimmed.fq.gz; do
        # Extract the lane/run prefix (e.g., "816")
        prefix=${file%%_*}
        
        # Extract the S### identifier (e.g., "S383")
        s_number=$(echo "$file" | grep -oP 'S\d+')
        
        # Create new name with S### included
        new_name="${prefix}_${sampleID}_${s_number}_trimmed.fq.gz"
        
        mv "$file" "$new_name"
        echo "$new_name"
    done
    
done < "$BARCODE_FILE"
```

