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
#### Download Dfam partitions
```sh
# make script executable
chmod +x configure_dfam40.sh
# run interactively
# script will assist in Dfam download and configuration (for RepeatMasker)
bash configure_dfam40.sh
```
#### Verify Dfam partitions
```sh
conda activate earlgrey

FAMDB="$CONDA_PREFIX/share/famdb-3.0.0/Libraries/famdb"

du -sh "$FAMDB"
find "$FAMDB" -maxdepth 1 -type f -printf '%f\n' | sort
# check donwloaded partitions are present
famdb.py -i "$FAMDB" info
```
#### Run Earl Grey

```sh
#!/bin/sh
#SBATCH --job-name 07_earlgrey_Pegre
#SBATCH --output 07_earlgrey_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 300gb
#SBATCH --partition nodeviper
#SBATCH --time 96:00:00

 module load anaconda3/2023.09-0
 source activate earlgrey

 cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/07_earlgrey

 earlGrey -g /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/05_YaHs/Pegre-CLP3001_final_genome.fa \
	-s Pegregius -o output -t 24 -d yes -e yes
```
