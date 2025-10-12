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
wget -O ThaEle.zip 'https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/GCF_009769535.1/download?include_annotation_type=GENOME_FASTA'
unzip ThaEle.zip
# rename .fna to .fa
```

```sh
cd /project/viper/venom/Taryn/Nerodia/Synt
minimap2 -ax asm20 Thamnophis_elegans/ThaEle.pri_genomic.fa Nerodia_clarkii.fa > Nfasc_Teleg_aln.sam       # assembly to assembly/ref alignment
```
---
#### SRA tools loop for .fastq data
```sh
for i in *
  do fasterq-dump $i
done
```
