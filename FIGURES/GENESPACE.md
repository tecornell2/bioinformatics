https://github.com/jtlovell/GENESPACE

## Installation GENESPACE
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

## Clemson.OnDemand/RStudio-Server
* R v4.4.0
* CPU cores: two CPU per comparisons (ex. 2 genomes --> 4 comparisons = 4 CPUs) 
* List of modules to be loaded: orthofinder/2.5.4
* Open GENESPACE R script

### Run orthofinder in terminal separately
```sh
orthofinder -f /project/viper/venom/Taryn/Nerodia/Synt/GENESPACE/genespace_work/tmp -t 4 -a 4 -X -o /project/viper/venom/Taryn/Nerodia/Synt/GENESPACE/genespace_work/orthofinder/
```

### Installation Orthofinder
```sh
conda create -n orthofinder
conda activate orthofinder
conda install -c bioconda orthofinder=2.5.4

# alternatively, on HPC
module load orthofinder/2.5.4
```

