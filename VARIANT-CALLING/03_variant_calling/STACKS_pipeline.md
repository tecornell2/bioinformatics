# version: STACKS 2.68

## Before STACKS pipeline
1. Trim and QC reads
2. Create a population map .txt file

	**Example:**
	```sh
	cat popmap_spp.txt
	CLP3001     egregius
	CLP3002     insularis
	CLP3003     outgroup
	<sample_id>     <phenotype abbrev>
	```

---

### SLURM script
```sh
#!/bin/bash
#SBATCH --job-name STACKS_pipeline
#SBATCH --output STACKS_pipeline_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 100gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load stacks
module load bwa
module load gnuparallel
module load samtools

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/03_STACKS/

#mkdir -p 01_process_radtags
mkdir -p 02_align
mkdir -p 03_ref_map

BASE="/project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD"
INPUT="${BASE}/01_trim_galore"
REF="${BASE}/genome/Pegre-CLP3001_hifi_hic_genome.clean.fa"
SAMPLE_LIST="${BASE}/00_samples_list.txt"
OUTDIR="${BASE}/03_STACKS/03_ref_map/"


export BASE REF INPUT SAMPLE_LIST

## --------------------------------
### Process radtags
### --------------------------------

#echo "Processing radtags..."

#process_radtags -p $INPUT -o ./01_process_radtags \
# --disable_rad_check -r -c -q --truncate 140 --threads 30

## --------------------------------
### Align reads to reference genome
### --------------------------------

parallel -a $SAMPLE_LIST -j 8 '

if [ ! -f ./02_align/{}.bam ]; then
	echo "Aligning {sample} to reference..."
	bwa mem -t 3 $REF ./01_process_radtags/{}.trim.fq.gz | \
 	 samtools view -b -h | \
 	 samtools sort -@ 3 -o ./02_align/{}.bam
fi
  '

### --------------------------------
### Run STACKS ref_map.pl
### --------------------------------

echo "Starting STACKS ref_map.pl..."

ref_map.pl \
	-T 12 \
	-o $OUTDIR \
	--popmap 00_popmap.txt \
	--samples ${BASE}/03_STACKS/02_align/ \
	-X "gstacks: --min-mapq 20" \
	-X "populations: --fstats --vcf --ordered-export"
```

---

### How to QC before/after process_radtags
```sh
# salloc interactive node in the terminal
module load fastqc/0.12.1
# navigate to directory with cleaned files
fastqc --outdir /path/to/output/folder/ -t 20 *.fasta.gz
# this could take some time depending on the # files and # threads
# but probably not much (mine was 10 min)

module load multiqc/1.28
multiqc .
# download the multiqc.html via On Demand to view stats on all samples
```
