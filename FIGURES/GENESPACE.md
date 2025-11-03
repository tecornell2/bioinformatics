https://github.com/jtlovell/GENESPACE

### Installation GENESPACE
```sh
# had issues with old version of compiler for non-CUGBF R module (gcc 12.2)
# use CUGBF R module to default to gcc 13.2
module load r/CUGBF-4.4.0
R
# add lib path if R cannot find personal library to write to
.libPaths()

# "/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4" 
install.packages("devtools")
# could not load GENESPACE without specifying personal library
devtools::install_github("jtlovell/GENESPACE", lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")

BiocManager::install("Biostrings",lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")
BiocManager::install("rtracklayer",lib="/home/tecorn/R/x86_64-pc-linux-gnu-library/4.4")
# rtracklayer Execution failed

# also if you use install.packages("rtracklayer")
# package is not available for this version of R

```

### Installation Orthofinder
```sh
conda create -n orthofinder
conda activate orthofinder
conda install -c bioconda orthofinder=2.5.5
```

