sh```
conda create -n eggnog_env bioconda -c eggnog-mapper

download this database inside eggnog_mapper in the bin
python download_eggnog_data.py -d data

#!/bin/bash
#SBATCH --job-name EggNOG
#SBATCH --output EggNOG_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 100gb
#SBATCH --time 48:00:00

module load anaconda3/2023.09-0
source activate eggnog_env

cd /project/viper/venom/

python ~/eggnog-mapper/emapper.py -i species.proteins.fa -o emapper --cpu 24
```
