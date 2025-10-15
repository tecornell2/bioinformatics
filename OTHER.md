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
