## List of Other Packages

Name | Type | Use
--- | --- | ---
SRA Tool Kit | x | Access NCBI SRA data
MiniMap2 | map | Align reference genomes
name | type | note

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
---
#### liftoff
```sh
module load anaconda3/2023.09-0
source activate liftoff
module load minimap2/2.17

cd /project/viper/venom/Taryn/Nerodia/Nclarkii/liftoff

liftoff -g ../../Synt/Thamnophis_elegans/ThaEle1.pri_genomic.gff3 \
-o Nclar_liftoff_Teleg.gff3 -p 10 -polish \
../04_ragtag/ragtag_output/Nclar-CLP2810_assembled_blood.scaffold.fasta \
../../Synt/Thamnophis_elegans/ThaEle.pri_genomic.fa
```
---
#### R
```sh
module load R/4.5
# open R in terminal to install packages
R
  > install.packages("devtools")
quit()
# run an Rscript in terminal
Rscript <name>
```
