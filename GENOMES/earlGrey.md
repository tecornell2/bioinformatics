# Earl Grey

### Installation

```sh
conda create -n earlgrey
source activate earlgrey

conda install -c conda-forge mamba
mamba install bioconda::earlgrey
```

```sh
earlGrey -g test/test.fasta -s test -o test/output_dir -t 8
# this produced a terminal output:
# WARNING: Earl Grey v7.3.1 uses Dfam v4.0.
# Before using Earl Grey, you MUST download the required partitions from Dfam (https://dfam.org/releases/Dfam_4.0/families/FamDB/)

# A script for modification and automation of these steps has been generated .../configure_dfam40.sh
```

```sh
 wget https://dfam.org/releases/Dfam_4.0/families/FamDB/dfam40.0.h5.gz
```


