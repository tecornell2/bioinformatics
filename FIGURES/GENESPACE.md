https://github.com/jtlovell/GENESPACE

### Installation GENESPACE
```sh
module load r/4.4.0
R
# add lib path if R cannot find personal library to write to

.libPaths()
# "/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4"
# could not load GENESPACE without specifying personal library

install.packages("devtools")
devtools::install_github("jtlovell/GENESPACE", lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")

BiocManager::install("Biostrings",lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")
BiocManager::install("rtracklayer",lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")

# rtracklayer Execution failed
# if you use install.packages("rtracklayer")
# package is not available for this version of R

```
##### scratch that and return to r/4.4.0 in palmetto

##### Interactive Apps/RStudio Server
* R v4.4.0
* CPU cores: 4-16 CPU, depending on amount of genomes
* List of modules to be loaded: orthofinder/2.5.4
* Open GENESPACE R script



### Installation Orthofinder
```sh
conda create -n orthofinder
conda activate orthofinder
conda install -c bioconda orthofinder=2.5.5
```

