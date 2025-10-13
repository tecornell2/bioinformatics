## List of Other Packages

Name | Type | Use
--- | --- | ---
SRA Tool Kit | x | Access NCBI SRA data
MiniMap2 | map | Align reference genomes
name | type | note

---
#### MiniMap2 alignment
```sh
# download ncbi genome to align to
wget -O ThaEle.zip '{API URL}'
unzip ThaEle.zip
# rename .fna to .fa
```

```sh
#!/bin/bash

#SBATCH --job-name synt_Nfasc_Tele
#SBATCH --output synt_Nfasc_Tele_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 10
#SBATCH --mem 64gb
#SBATCH --time 6:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

cd /project/viper/venom/Taryn/Nerodia/Synt

module load anaconda3/2023.09-0
source activate minimap2
minimap2 -ax asm20 Thamnophis_elegans/ThaEle.pri_genomic.fa Nerodia_fasciata.fa > Nfasc_Teleg_aln.sam
conda deactivate

source activate bbmap
samtools fasta Nclar_Tele_aln.sam > Nclar_Tele_aln.pfa
```
---
#### SRA tools loop for .fastq data
```sh
for i in *
  do fasterq-dump $i
done
```
---
#### perl
```sh
# find and replace
perl -pi -e 's/old/new/g' <file_name>
```
