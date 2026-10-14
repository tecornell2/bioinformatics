# GENESPACE

### 1. Set up a GENESPACE directory

It is important the the .gff and the .fasta files have the same name (ie. Pegregius). The gff files are actually .gff3 files that I changed the suffixes of (It does not matter if you use a .gff or .gff3, but the suffix needs to be .gff)
```sh
├── raw_genomes
│   ├── Pegregius.fasta
│   ├── Pegregius.gff
│   ├── Pgilberti.fasta
│   └── Pgilberti.gff
├── scripts
│   ├── bed
│   ├── format_genespace.sh
│   ├── formatgff2bed.sh
│   ├── get_genes_gtf.py
│   └── gtf_class.py
└── working_dir
```

### 2. Format files
Use `./format_genespace.sh` to format the bed and peptide files. This script uses other scripts (Translate_RARG.py Linearize.py Extract_CDS_v2.py) that you will need to add to your `.bashrc` path.

```sh
PATH="$PATH:/project/viper/venom/Ramses/bin/RamsesScripts/Extract_CDS/"
PATH="$PATH:/project/viper/venom/Ramses/bin/RhettGit/Bioinformatics/scripts/"
PATH="$PATH:/project/viper/venom/Ramses/bin/RamsesScripts/PyScripts/"

export PATH
```
Copy these scripts to your `GENESPACE/scripts` directory:
```sh
cp /project/viper/venom/Ramses/HiFi/GENESPACE/format_genespace.sh .
cp /project/viper/venom/Ramses/HiFi/GENESPACE/formatgff2bed.sh .
cp /project/viper/venom/Ramses/HiFi/GENESPACE/get_genes_gtf.py .
cp /project/viper/venom/Ramses/HiFi/GENESPACE/gtf_class.py .
```
Run `./format_genespace.sh` on each genome. Use a shared prefix for .fasta and .gff files
```sh
cd raw_genomes/
../scripts/format_genespace.sh Pgilberti ../working_dir/
```

### 3. Run orthofinder

GENESPACE in R will also run Orthofinder (if a compatible version is loaded in), but I could not get it to run in R. So I ran the program in my terminal on Palmetto. 
```sh
module load orthofinder

orthofinder -f <peptide dir> -t 12 -a 1 -X \
  -o /project/viper/venom/Taryn/Plestiodon/synteny/GENESPACE/working_dir/orthofinder
```

### 4. Run Rstudio script

#### Clemson.OnDemand/RStudio-Server
* R v4.4.0
* CPU cores: two CPU per comparisons (ex. 2 genomes --> 4 comparisons = 4 CPUs) 
* List of modules to be loaded: orthofinder/2.5.4 (NOT required if Orthofinder was run earlier in terminal)

```sh
GENESPACE.R

library("Biostrings")
library("rtracklayer")
library("GENESPACE")

setwd("/project/viper/venom/Taryn/Plestiodon/synteny/GENESPACE")
wd <- "/project/viper/venom/Taryn/Plestiodon/synteny/GENESPACE/working_dir"
path2mcscanx <- "/project/viper/venom/Taryn/bin/MCScanX-1.0.0"

### format tips, fasta must be linearized, and no ":" should be used in the names of the genes

### --------------------------------
### Run orthofinder
### --------------------------------

### for some reason orthofinder is not running all the diamond pairwise comparisons
# do it manually and rerun the script

### bash terminal command:
#orthofinder -f <peptide dir> -t 12 -a 1 -X \
  # -o /project/viper/venom/Taryn/Plestiodon/synteny/GENESPACE/working_dir/orthofinder

### --------------------------------
### Run GENESPACE
### --------------------------------

gpar <- init_genespace(
  wd = wd,
  path2mcscanx = path2mcscanx,
  genomeIDs = c("Pegregius","Pgilberti"),
  nCores=10,
  ploidy = 1 )

gpar$shellCalls$orthofinder <- "orthofinder"
gpar$shellCalls$diamond <- "diamond"

out <- run_genespace(gpar, overwrite = T)

### --------------------------------
### Plot results
### --------------------------------

## plot base pairs 
ripd <- plot_riparian(gsParam = gpar,
                      refGenome = "Pegregius",
                      useRegions = F,
                      useOrder= F,
                      chrLabFontSize=6,
                      invertTheseChrs = invchr,
                      syntenyWeight = 0.5,
                      chrLabFun = function(x) gsub("* scaffold_","",
                                                   gsub("scaffold","",x),perl = T))
### plots gene number
ripd_genes <- plot_riparian(gsParam = gpar,
                            refGenome = "Pegregius",
                            chrLabFontSize=9,
                            invertTheseChrs = invchr,
                            syntenyWeight = 0.5,
                            chrLabFun = function(x) gsub("JANXHW0100000","", # query genome substitute
                                                         gsub("scaffold_","",x),perl = T)) # ref genome substitute


### --------------------------------
### Invert Chrs
### --------------------------------

invchr<-data.frame(genome =c(rep("Pegregius",5),rep("Pgilberti",3)),
                   chr = c(paste0("scaffold_",c(4,5,6,7,8)),
                           paste0("JANXHW0100000",c(11,12,13))))

invchr

# save plot as an svg
```
---

Documentation: https://github.com/jtlovell/GENESPACE

#### Customize Riparian Plots
https://htmlpreview.github.io/?https://github.com/jtlovell/tutorials/blob/main/riparianGuide.html

---

# Installation

### GENESPACE
```sh
module load r/4.4.0
R
# add lib path if R cannot find personal library to write to

.libPaths()
# "/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4"
# could not load GENESPACE without specifying personal library

install.packages("devtools")
devtools::install_github("jtlovell/GENESPACE", lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")

install.packages("BiocManager")
BiocManager::install("Biostrings",lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")
BiocManager::install("rtracklayer",lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")

# rtracklayer Execution failed
# if you use install.packages("rtracklayer")
# package is not available for this version of R

```

### Orthofinder
```sh
conda create -n orthofinder
conda activate orthofinder
conda install -c bioconda orthofinder=2.5.4

# alternatively, on HPC
module load orthofinder/2.5.4
```

### MCScanX
Download separately onto HPC

# Troubleshooting
Installing GENESPACE and its dependencies were a long process likely due to the univeristy HPC. Try a few versions of R (I used R/4.4.0) if you cannot download all the dependencies. Use the BiocManager repository for `rtracklayers` and `Biostrings`.
<p>
Be sure to allocate enough memory to the job. If Orthofinder is failing, check how many CPUs and RAM is allocated.
</p>

For several attempts, I recieved the following error when running Orthofinder:
  ```sh
2025-11-04 10:49:24 : Starting OrthoFinder 2.5.4
...

Running diamond all-versus-all
------------------------------
Using 4 thread(s)
2025-11-04 11:18:27 : This may take some time....
2025-11-04 11:18:27 : Done 0 of 4

ERROR: external program called by OrthoFinder returned an error code: -4

Command: diamond blastp -d /project/viper/venom/Taryn/Nerodia/Synt/GENESPACE/genespace_work/orthofinder/Results_Nov04/WorkingDirectory/diamondDBSpecies0 -q /project/viper/venom/Taryn/Nerodia/Synt/GENESPACE/genespace_work/orthofinder/Results_Nov04/WorkingDirectory/Species0.fa -o /project/viper/venom/Taryn/Nerodia/Synt/GENESPACE/genespace_work/orthofinder/Results_Nov04/WorkingDirectory/Blast0_0.txt --more-sensitive -p 1 --quiet -e 0.001 --compress 1

...

2025-11-04 11:00:53 : Done all-versus-all sequence search

Running OrthoFinder algorithm
-----------------------------
2025-11-04 11:00:53 : Initial processing of each species
WARNING: Too few hits between species 0 and species 0 to normalise the scores, these hits will be ignored
WARNING: Too few hits between species 1 and species 1 to normalise the scores, these hits will be ignored
2025-11-04 11:01:05 : Initial processing of species 0 complete

...
```
This fixed itself when I used a newer version of Orthofinder (v2.5.5) in an anaconda environment, instead of using the module of orthofinder (v2.4.5) available through the HPC. 
