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

cd /project/viper/venom/Taryn/Nerodia/Nclarkii/liftoff

liftoff -g /project/viper/venom/Taryn/Nerodia/Synt/Thamnophis_elegans/ThaEle1.pri_genomic.gff3 \
-o Nclar_liftoff_Teleg.gff3 -p 40 -polish \
../04_ragtag/ragtag_output/Nclar-CLP2810_assembled_blood.scaffold.fasta \
/project/viper/venom/Taryn/Nerodia/Synt/Thamnophis_elegans/ThaEle.pri_genomic.fa
```

