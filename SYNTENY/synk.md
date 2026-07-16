# Synk

Synk is a wrapper to produce synteny plots. This is a tool made by Jon Hoffman. 

```sh
python ~/Synk/synk.py \
  --main_name Pegre-CLP3001_scaff \
  --main_assembly /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/04_YaHs/Pegre-CLP3001_hifi_hic_scaffold_genome.fasta \
  --compare fasciatus=/project/viper/venom/Taryn/Plestiodon/Pfasciatus/00_raw/ncbi_dataset/rPleFas1.1.fa \
  --compare gilberti=/project/viper/venom/Taryn/Plestiodon/Pgilberti/any2fasta/rPleGil1.0.hap2.fa \
  --lineage sauropsida \
  --threads 12 \
  --outdir output \
  --plot
```

```sh
#!/bin/bash

#SBATCH --job-name synk
#SBATCH --output synk_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 88gb
#SBATCH --time 12:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

cd /project/viper/venom/Taryn/Plestiodon/synteny/Synk/

python ~/Synk/synk.py \
  --main_name Pegre-CLP3001_scaff \
  --main_assembly /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/04_YaHs/Pegre-CLP3001_hifi_hic_scaffold_genome.fasta \
  --compare fasciatus=/project/viper/venom/Taryn/Plestiodon/Pfasciatus/00_raw/ncbi_dataset/rPleFas1.1.fa \
  --compare gilberti=/project/viper/venom/Taryn/Plestiodon/Pgilberti/any2fasta/rPleGil1.0.hap2.fa \
  --reuse_compleasm \
  --min_contig_length \
  --lineage sauropsida \
  --threads 16  \
  --outdir output \
  --plot
```
