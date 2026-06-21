
# STACKS 2.68

## 01 process_radtags

### 1. Identify the type of index barcode for RADseq data (single or paired-end data)

My data is nextRAD, single-end 150bp with a selective primer 'GTGTAGAGCC' and dual index (i7+i5)

### 2. Create a file that relates barcode to sample_id
```sh
cat barcodes.txt
<barcode>       <sample_id>
<barcode>       <sample_id>
<barcode>       <sample_id>
<barcode>       <sample_id>
```
If you have two barcodes, create another middle column with the other barcodes.

### 3. Run process_radtags

#### batch .job file

```sh
#!/bin/bash
#SBATCH --job-name STACKS_01_process
#SBATCH --output STACKS_01_process_output
#SBATCH --nodes 1
#SBATCH --cpus-per-task 30
#SBATCH --mem 28gb
#SBATCH --time 20:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user email@clemson.edu

# load package
module load biocontainers
module load stacks/2.68

# set directory
cd /project/viper/venom/Taryn/Plestiodon/Pegregius/RADseq/STACKS

# create a directory for outputs
process_radtags -P -p ../clean_data/02_clean/ -b barcodes_list.txt -o ./01_process/ -r -c -q -e <enzyme> --filter-illumina --threads 29
```

-P is paired reads

Either before or after this step you can use *clone_filter* to remove PCR duplicates sequences from samples

### 4. Review clean data
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

This is RADseq data, so duplicate sequences are inevitable and will be present in the reports. However, we need to check for adapter contamination, the amount of raw reads, GC content, etc. 

## 02_denovo_map.pl

### 1. Create a population map .txt file that the pipeline will use to associate the sample with a locality
Example for geographic delineations
```sh
cat popmap_geo.txt
<sample_id>     <location abbrev>
<sample_id>     <location abbrev>
<sample_id>     <location abbrev>
```

Example for species, phenotype, or ecotype delineations
```sh
cat popmap_spp.txt
CLP3001     egregius
CLP3002     insularis
CLP3003     outgroup
<sample_id>     <phenotype abbrev>
```


### 2. Optimize parameters (in this order: m, M, n)
Either run a .job individually (using denovo_map.pl) for each parameter (m=3-7, M=1-8..) change **or** write 1 .job file that iterates over the parameters you are changing (running ustacks, cstacks...populations modules by hand).

### batch .job file (for "little" m)

THIS DOES NOT WORK YET:
```sh
#!/bin/bash
#SBATCH --job-name STACKS_02_m3-7
#SBATCH --output STACKS_02_m3-7_output
#SBATCH --partition nodeviper
#SBATCH --nodes 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 48gb
#SBATCH --time 70:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

# stolen code
# set directory
cd /project/viper/venom/Taryn/Plestiodon/Pegregius/RADseq/STACKS/02_denovo_pipeline/

# load list of files
files=../01_process/aa.files.txt

# optimize params
for i in {3..7}
do

mkdir stacks_m$i

#Run ustacks with m equal to the current iteration (3-7) for each sample
id=1
while read -r sample
do
    ustacks -f ../01_process/${sample}.fq.gz -o stacks_m$i -i $id -m $i -p 15
    let "id+=1"
done < "$files"

## Run cstacks to compile stacks between samples
cstacks -P stacks_m$i -M ../popmap/popmap_spp_subset_v2.txt -p 15
## Run sstacks. Match all samples supplied in the population map against the catalog.
sstacks -P stacks_m$i -M ../popmap/popmap_spp_v2.txt -p 15
## Run tsv2bam to transpose the data so it is stored by locus, instead of by sample.
tsv2bam -P stacks_m$i -M ../popmap/popmap_spp_v2.txt -t 15
## Run gstacks to align reads per sample, call variant sites in the population, genotypes in each individual.
gstacks -P stacks_m$i -M ../popmap/popmap_spp_v2.txt -t 15
## Run populations completely unfiltered and output unfiltered vcf, for input to the RADstackshelpR package
populations -P stacks_m$i -M ../popmap/popmap_spp_v2.txt --vcf -t 15

done
```
Use the R package RADstackshelpR to visualize the loci retained, SNPs retained, and coverage among your samples. Using these data, pick the optimal m value to use for subseqeunt optimization of M and n.

```sh
# code for optimizing 'big' M 
```

```sh
# code for optimizing n 
```

### 3. Run the pipeline

### batch .job file
```sh
#!/bin/bash
#SBATCH --job-name STACKS_02_denovo_M1
#SBATCH --output STACKS_02_denovo_M1_output
#SBATCH --partition nodeviper
#SBATCH --nodes 1
#SBATCH --cpus-per-task 14
#SBATCH --mem 38gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

# load package
module load biocontainers
module load stacks/2.68

# set directory
cd /project/viper/venom/Taryn/Plestiodon/Pegregius/RADseq/STACKS

# working example with M=1
denovo_map.pl -T 13 -M 1 -o ./02_denovo_pipeline/spp_M1/ \
--samples ./01_process/ \
--min-samples-per-pop 0.80 \
--popmap ./popmap/popmap_spp.txt \
--catalog-popmap ./popmap/popmap_spp_subset.txt
```
-M is the num of mismatches allowed
--min-samples-per-pop is for the r80 method mentioned in the linked publication (2.) to evaluate parameters
--catalog-popmap is a subset of the samples to use for the cstacks (catalog) step, to reduce error from all (n=186) samples




## P. egregius specific
Run process_radtags on demulitplexed data to remove low quality reads and trim to a uniform size for STACKS pipeline (--truncate 140)
```sh
process_radtags -p ../clean_data/02_clean/ -o ./01_process/ --disable-rad-check -r -c -q --filter-illumina --truncate 140 --threads 39
```

```sh
# rename files to remove .trim. in file name
for file in *.fq.gz; do mv "$file" "${file/.trim.fq.gz/.fq.gz}"; done
```