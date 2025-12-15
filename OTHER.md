## List of Other Packages

Name | Type | Use
--- | --- | ---
SRA Tool Kit | import | Access NCBI SRA data
MiniMap2 | gene mapping | Align reference genomes
liftoff | gene mapping | Move gene annotations from reference to query genome
GNUparallel | parallel jobs | note
name | type | note
name | type | note

---
#### SRA tools loop for .fastq data
```sh
for i in *
  do fasterq-dump $i
done
```

#### liftoff
```sh
module load anaconda3/2023.09-0
source activate liftoff
module load minimap2/2.17

cd /project/viper/venom/Taryn/Nerodia/Nclarkii/liftoff

liftoff -g ../../Synt/Thamnophis_elegans/ThaEle1.pri_genomic.gff3 \
-o Nclar_liftoff_Teleg.gff3 -p 10 -polish \
../04_ragtag/ragtag_output/Nclar-CLP2810_assembled_blood.scaffold.fasta \
../../Synt/Thamnophis_elegans/ThaEle.pri_genomic.fa
```

#### GNU parallel
```sh
module load gnuparallel/20210222

# ensure job has 30 cpus
parallel -a list_run1476.txt -j 30 -k --colsep '\t' 'echo {1} started
	
	module load anaconda3/2023.09-0
	source activate bio

	cd /project/viper/venom/Taryn/Plestiodon/Pegregius/01_STACKS/00_raw/1476/

	trim_galore --phred33 -o trimmed/{1}_L006_R1_001.fastq.gz &> trim/{1}.log

echo {1} finished ' 
```

parallel -j 20 --progress fastqc -q -o fastqc/ {} ::: *.fastq.gz

---
#### rename files batch job
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

#### perl
```sh
# find and replace
perl -pi -e 's/old/new/g' <file_name>
# copy file names in cd as a .txt file
ls | perl -pe "s/_L006.*//g" > list.txt
```

#### R
```sh
module load R/4.5
# open R in terminal to install packages
R
  > install.packages("devtools")
quit()
# run an Rscript in terminal
Rscript <name>
```
