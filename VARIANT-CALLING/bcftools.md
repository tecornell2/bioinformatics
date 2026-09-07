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

&nbsp; &nbsp; **F_MISSING** (fraction of missing genotypes)

### query
```sh
# Print only samples with alternate (non-reference) genotypes
bcftools query -f'[%CHROM:%POS %SAMPLE %GT\n]' -i'GT="alt"' file.bcf

# Use default string for filtered-out samples
bcftools query -i 'DP>5' -F '.' -f '[%CHROM\t%POS\t%SAMPLE\t%DP\n]' input.vcf.gz
```

---

## 20260907

I rerun the nextRAD mpileup pipeline because the reference genome used was an older assembly. I added a portion in the mpileup script to add additional tags (ex. AF) and keep only SNPs.

```sh
# test 1
bcftools filter -S . -i 'FMT/DP >= 5 & FMT/GQ >= 20' catalog.vcf.gz |  \
  bcftools view -i 'F_MISSING < 0.5' -Oz -o filtered_catalog.GQ-20.minDP-5.F_MISS-50.vcf.gz

# nextRAD:
# WGS: 10,436,620
```
