# Synk

Synk is a wrapper to produce synteny plots. This is a tool made by Jon Hoffman. 

```sh
#!/bin/bash

#SBATCH --job-name synk
#SBATCH --output synk_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 20
#SBATCH --mem 140gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

cd /project/viper/venom/Taryn/Plestiodon/synteny/Synk/

python ~/Synk/synk.py \
  --main_name egregius \
  --main_assembly /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/04_YaHs/Pegre-CLP3001_hifi_hic_scaffold_genome.13scaff.fasta \
  --compare fasciatus=/project/viper/venom/Taryn/Plestiodon/Pfasciatus/00_raw/ncbi_dataset/rPleFas1.1.fa \
  --compare gilberti=/project/viper/venom/Taryn/Plestiodon/Pgilberti/00_raw/ncbi_dataset/ncbi_dataset/data/GCA_026170595.1/GCA_026170595.1_rPleGil1.0.hap2_genomic.fna \
  --compare duperreyi=/project/viper/venom/Taryn/Plestiodon/synteny/Aduperreyi/00_raw/ncbi_dataset/data/GCA_041722995.2/GCA_041722995.2_BASDU_1.0_genomic.fna \
  --lineage sauropsida \
  --threads 20  \
  --outdir output \
  --plot
```
