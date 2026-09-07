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
#SBATCH --cpus-per-task 36
#SBATCH --mem 70gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load biocontainers
module load stacks/2.68
module load bwa/0.7.19
module load parallel
module load samtools

# set directory
cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/03_STACKS/

BASE="/project/viper/venom/Taryn/Plestiodon/Pegregius"
INPUT="${BASE}/nextRAD/01_trim_galore"
REF="${BASE}/WGS/genome/Pegre-CLP3001_assembled_blood.fa"
SAMPLE_LIST="${BASE}/nextRAD/00_samples_list.txt"

export REF SAMPLE_LIST

## --------------------------------
### 01 process_radtags
### --------------------------------

echo "Processing radtags..."

process_radtags -p $INPUT -o ./01_process_radtags \
 --disable_rad_check -r -c -q --truncate 140 --threads 36

## --------------------------------
### 02 align to reference genome
### --------------------------------

parallel -a $SAMPLE_LIST -j 12 '

sample={}

   if [ ! -f ./02_align/{sample}.bam ]; then
	echo "Aligning {sample} to reference..."
	bwa mem -t 3 $REF ./01_process_radtags/{sample}.trim.fq.gz | \
 	 samtools view -b -h | \
  	 samtools sort -@ 3 -o ./02_align/{sample}.bam
   fi
  '

### --------------------------------
### 03 STACKS ref_map.pl
### --------------------------------

echo "Completed 01_process_radtag and 02_align"
echo "Starting STACKS ref_map.pl..."

ref_map.pl \
	-T 36 \
	-o ./03_ref_map \
	--popmap 00_popmap.txt \
	--samples ./02_aligned/ \
	-X "gstacks: --min-mapq 20" \
	-X "populations: --fstats --vcf"

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

# after completetion, there is a .html file for each sample with stats!
# but there are so many? let's use something else to make one mega report

module load multiqc/1.28
multiqc .
# download the multiqc.html via On Demand to view stats on all samples
```
