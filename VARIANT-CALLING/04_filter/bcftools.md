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
# filter pt 1
bcftools filter -S . -i 'FMT/DP >= 5 & FMT/GQ >= 20' catalog.vcf.gz |  \
  bcftools view -i 'F_MISSING < 0.5' -Oz -o filtered_catalog.GQ-20.minDP-5.F_MISS-50.vcf.gz

# retain sites were depth is >= 5 and at least 50% of samples have a genotype call
# nextRAD: 6
# WGS: 10,436,620
```
```sh
# calculate percent missingness per sample
bcftools filter -S . \
  -i 'FMT/DP >= 5 & FMT/GQ >= 20' \
  catalog.vcf.gz -Ou |
bcftools query -f '[%SAMPLE\t%GT\n]' |
awk '
{
    total[$1]++;
    if ($2 == "./." || $2 == ".|.") missing[$1]++;
}
END {
    for (s in total)
        printf "%s\t%d\t%d\t%.4f\n",
        s, total[s], missing[s], missing[s]/total[s]
}' | sort -k4,4nr

# sample  total_sites  missing_sites  missing_fraction

### output

CLPT742	23701989	23695690	0.9997
CLPT745	23701989	23693815	0.9997
CLPT752	23701989	23692613	0.9996
...
CLPT685	23701989	23353159	0.9853
CLPT826	23701989	23307430	0.9834
CLPT839	23701989	23268977	0.9817

# ok so remove the 99% i guess what the hell
```

At this point I reran mpileup two times and went over the SLURM script multiple times. I reviewed the STACKS output and reran the STACKS_pipeline.job to have an updated library to compare to. 

1. Filter variant sites with >= 50% missing genotypes
```sh
bcftools +fill-tags catalog.snps.vcf.gz -Ou -- -t F_MISSING | bcftools view -i 'F_MISSING<=0.5' -Oz -o catalog.snps.0.5missing.vcf.gz
# 84088 sites remaining
```
3. Set genotypes to null if depth is not within filter constraints

5. Set genotypes to null for samples with high missingess (from STACKS run) 

6. Filter variant sites (again)


---

```sh
bcftools filter -Oz -o catalog.snps.0.5missing.meanDP>5.vcf.gz -S . -e 'MEAN(FMT/DP) < 5' catalog.snps.0.5missing.vcf.gz
# 84088 sites remaining
# no change
# deleted file
```

#### nextRAD-WGS overlap pipeline
```sh
bcftools view \
  -m2 -M2 -v snps \
  -i 'QUAL>=20 && INFO/DP>=5' \
  filtered_catalog.GQ-20.minDP-5.F_MISS-50.vcf.gz \
  -Oz -o WGS.snps.0.5missing.qual20.DP5.biallelic.vcf.gz
# 8555981 sites

bcftools view
  -m2 -M2 -v snps \
  -i 'QUAL>=20 && INFO/DP>=5' \
  catalog.snps.0.5missing.vcf.gz -Oz \
  -o nextRAD.snps.0.5missing.qual20.DP5.biallelic.vcf.gz
# 72392 sites

# index files
bcftools index -t WGS.snps.0.5missing.qual20.DP5.biallelic.vcf.gz
bcftools index -t nextRAD.snps.0.5missing.qual20.DP5.biallelic.vcf.gz

# identify shared sites
bcftools isec \
  -n=2 \
  -c none \
  -w 1 \
  WGS*.vcf.gz \
  nextRAD*.vcf.gz \
  -Oz -o WGS-nextRAD.overlap.snps.vcf.gz
# c requires identical REF and ALT alleles
# w writes csv of inputs

# 62700 sites

bcftools index -t WGS-nextRAD.overlap.snps.vcf.gz

### restrict either dataset to their shared sites
# make tsv
bcftools query \
  -f '%CHROM\t%POS\t%REF\t%ALT\n' \
  WGS-nextRAD.overlap.snps.vcf.gz > overlap.sites.tsv

# pull out sites
bcftools view -R overlap.sites.tsv \
  WGS.snps.0.5missing.qual20.DP5.biallelic.vcf.gz -Oz -o wgs.overlap.vcf.gz

bcftools view -R overlap.sites.tsv \
  nextRAD/nextRAD.snps.0.5missing.qual20.DP5.biallelic.vcf.gz -Oz -o nextRAD.overlap.vcf.gz

bcftools index -t WGS.overlap.vcf.gz
bcftools index -t nextRAD.overlap.vcf.gz

# merge datasets
bcftools merge \
  wgs.common.vcf.gz \
  rad.common.vcf.gz \
  -Oz -o combined.common.vcf.gz

bcftools index -t combined.common.vcf.gz

```
