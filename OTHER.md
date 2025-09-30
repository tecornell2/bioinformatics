## List of Other Packages

Name | Type | Use
--- | --- | ---
SRA Tool Kit | x | Access NCBI SRA data
name | type | note

---
#### SRA tools loop for .fastq data
```sh
for i in *
  do fasterq-dump $i
done
```
