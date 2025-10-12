## List of Other Packages

Name | Type | Use
--- | --- | ---
SRA Tool Kit | x | Access NCBI SRA data
MiniMap2 | map | Align reference genomes
name | type | note

---
#### MiniMap2 align Nerodia
```sh
# download ncbi genome to align to
wget -O ThaEle.zip 'https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/GCF_009769535.1/download?include_annotation_type=GENOME_FASTA'
unzip ThaEle.zip

minimap2 -ax asm20 ref.fa asm.fa > aln.sam       # assembly to assembly/ref alignment
```
---
#### SRA tools loop for .fastq data
```sh
for i in *
  do fasterq-dump $i
done
```
