## OTHER

Other package snippets

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

#### for loop example
```sh
for dir in */; do 
	dir="${dir%/}"
	bam="./${dir}/${dir}_aligned_sorted_marked_RG.bam"
	if [[ -f "$bam" ]]; then 
		samtools depth -@ 8 "$bam" > "${dir}_depth.txt"
		echo "Report generated for $dir"
	else 
		echo "No BAM file found"
	fi
done
```

#### juicer
```sh
 wget https://s3.amazonaws.com/hicfiles.tc4ga.com/public/juicer/juicer_tools_1.22.01.jar

#!/bin/bash
#SBATCH --job-name=juicer_pre
#SBATCH --output=juicer_pre_sort.out
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 120gb
#SBATCH --time 72:00:00

module load anaconda3/2023.09-0
source activate yahs_env

# working directory
cd /project/viper/venom/John_Henry/Scutulatus_Genomes/CLP_1832_Genome/04_Contact_Map

# Run juicer pre and pipe into sort
juicer pre blood_hic_algn_sorted.bam \
    yahs.out_scaffolds_final.agp \
    CLP1832_assembled_blood_plusHiC.hic.p_ctg.fasta.fai | \
sort -k2,2d -k6,6d -T ./ --parallel=24 -S120G | \
awk 'NF' > hic-to-contigs.txt

# creates the .txt file with the HiC associations

# run juicer
 java -Xmx32G -jar juicer_tools_1.22.01.jar pre hic-to-contigs.txt output.contact.map scaffolds_final.chrom.sizes
```


#### seqkit comparison of two fastas
```sh
seqkit sum <fasta1> <fasta2>
```

#### samtools extract contigs/scaffolds
```sh
Pull out a chromosome:
samtools faidx Scutulatus_Genome.fa scaffold_166 scaffold_84 > scutulatus_chr16_like.fa
samtools faidx Scutulatus_Genome.fa scaffold_11 scaffold_120 > scutulatus_chr9_like.fa
```

#### regex 
```sh
for i in $( ls *001.fastq.gz | perl -pe "s/_R(1|2).*//g" | uniq );
do
echo $i ;
done`
```

#### mosdepth 
```sh
for i in */; do sample="${i%/}"; mkdir -p ${sample}/mosdepth/ ; cd ${sample}/mosdepth/ ; echo "start mosdepth for $sample"; input="../${sample}_aligned_sorted_marked_RG.bam"; mosdepth --threads 8 --mapq 20 $sample $input ; cd ../.. ; done
```

#### BEDtools
```sh
bedtools getfasta \
  -fi ${FASTA} \
  -bed ${GFF} \
  -s \
  -name \
  -fo ${1}_features.fasta
```
