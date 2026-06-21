### --------------------------------
### Align reads to reference genome
### --------------------------------
```sh



# Create BWA database
# bwa index skink.genome.fasta


# set directory
work=/project/viper/venom/Taryn/Plestiodon/Pegregius/RADseq/STACKS

# Open the popmap file, and loop over the samples with a `while` loop
cat $work/popmap/popmap_spp.txt | cut -f 1 |
while read sample; do
    # Create variables for each sample
    fq1=$work/01_process/${sample}.fq.gz # Forward reads
    bam=$work/01_process/aligned/${sample}.bam      # BAM output
    
    # Align reads and process alignments
    bwa mem $work/03_refmap/genome/Pegre-CLP3001_assembled_blood.scaffold.fasta $fq1 | \   # Align with BWA mem
        samtools view -b -h | \                            # Compress alignments
        samtools sort -o $bam                              # Sort and save to BAM
done

```

### --------------------------------
###
### --------------------------------

ref_map.pl \
    --samples ./03_refmap/aligned_samples \ # Aligned samples 
    --popmap ./03_refmap/info/popmap.tsv \ # Popmap 
    --out-path ./03_refmap/refmap_rm_pcr_dups \ # Output directory 
    --rm-pcr-duplicates # Remove PCR duplicates





###########################

#!/bin/bash
#SBATCH --job-name STACKS_03_ref_ragtag_v1
#SBATCH --output STACKS_03_ref_ragtag_v1_output
#SBATCH --nodes 1
#SBATCH --cpus-per-task 30
#SBATCH --mem 125gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user email@clemson.edu

# load package
module load biocontainers
module load stacks/2.68
module load bwa
module load samtools

### --------------------------------
### Align reads to reference genome
### --------------------------------

# Create BWA database
# bwa index skink.genome.fasta

# set directory
work=/project/viper/venom/Taryn/Plestiodon/Pegregius/RADseq/STACKS

# Open the popmap file, and loop over the samples with a `while` loop
cat $work/01_process/aa.files.txt |
while read sample; do
    # Create variables for each sample
    fq1=$work/01_process/${sample}.fq.gz # Forward reads
    bam=$work/01_process/aligned/${sample}.bam      # BAM output

    # Align reads and process alignments
    bwa mem -t 29 $work/03_ref_map/genome/Pegre-CLP3001_assembled_blood.scaffold.fasta $fq1 | \   # Align with BWA mem
        samtools view -b -h | \                            # Compress alignments
        samtools sort -o $bam                              # Sort and save to BAM
done

### --------------------------------
### Run STACKS ref_map.pl
### --------------------------------

ref_map.pl \
	-T 29 \
	-o $work/03_ref_map/ \
	--popmap $work/popmap/popmap_spp.txt \
	--samples $work/01_process/aligned/ \
	-X "populations:--fstats --vcf"