# BCFtools


### view

```sh
# header information
bcftools view -h catalog.vcf.gz
bcftools view -h catalog.vcf.gz | grep 'FORMAT'

```sh
# count of variant sites
bcftools view -H catalog.vcf.gz | wc -l
```

### filter

`bcftools filter -S . -i 'FMT/DP >= 5 & FMT/GQ >= 20' catalog.vcf.gz` 

&nbsp; &nbsp; **DP** (depth)
* -e and -i allow for including or excluding sites
* E.g., -e 'FMT/DP < 10' removes sites where any sample has DP < 10
* -e 'MEAN(FMT/DP) < 10' removes sites where average depth across samples is < 10

&nbsp; &nbsp; &nbsp; &nbsp; Explanation: https://github.com/samtools/bcftools/issues/1391#issue-798620000

&nbsp; &nbsp; **AF** (allele frequency)

&nbsp; &nbsp; **GQ** (Phred-scaled genotype quality)

&nbsp; &nbsp; **QUAL** (fraction of missing genotypes)

&nbsp; &nbsp; **F_MISSING** (fraction of missing genotypes)

### query
```sh
# Print only samples with alternate (non-reference) genotypes
bcftools query -f'[%CHROM:%POS %SAMPLE %GT\n]' -i'GT="alt"' file.bcf

# Use default string for filtered-out samples
bcftools query -i 'DP>5' -F '.' -f '[%CHROM\t%POS\t%SAMPLE\t%DP\n]' input.vcf.gz
```


---

## filter scheme notes

```sh
# add F_MISSING
bcftools +fill-tags input.vcf.gz -Ou -- -t F_MISSING | bcftools view -Oz -o output_with_f_missing.vcf.gz


bcftools filter -S . -i 'FMT/DP >= 5 & FMT/GQ >= 20' catalog.vcf.gz |  \
  bcftools view -i 'F_MISSING < 0.5' -Oz -o filtered_catalog.GQ20.minDP5.50F_MISS.vcf.gz

```
---
