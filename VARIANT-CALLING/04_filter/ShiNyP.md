# ShiNyP

### Installation

```sh
docker --version
# Docker version 29.1.3, build 29.1.3-0ubuntu3~24.04.2
docker run -d -p 3838:3838 teddyenn/shinyp-platform
```

---
### 20260907
I filtered the WGS dataset loosely and uploaded the following dataset to ShiNyP for visualization: `filtered_catalog.GQ-20.minDP-5.F_MISS-50.snps.vcf.gz`

```sh
# converted bcftools .vcf.gz to PLINK .bed format and back to .vcf.gz
# extract .vcf

plink2 \
  --vcf filtered.vcf.gz \
  --make-bed \
  --max-alleles 2 \
  --out {name}.biallelic

plink2 \
  --bfile {name}.biallelic \
  --export vcf bgz \
  --out {name}.biallelic

# output: filtered_catalog.GQ-20.minDP-5.F_MISS-50.biallelic.snps.vcf.gz
```

1. Input VCF File
2. Transform to data.frame (download RDS to reupload later)
3. Sample QC, SNP QC, SNP Density
```sh
Removed SNPs with missing rate > 0.2, MAF < 0.05, heterozygosity rate < 0, and heterozygosity rate > 0.1
File name: data.frame_23_147583SNPs
Number of samples: 23
Number of SNPs: 147583
Type: data.frame
```
4. Population Structure
- I could not color the groupings (subspecies) for the PCA because program required at least 2 per population assignment

I filtered the nextRAD mpileup data and uploaded the following dataset to ShiNyP: `catalog.snps.0.5missing.meanDP5.vcf.gz`


```sh
# Sample QC
Removed samples with missing rate > 0.5 and heterozygosity rate > 0.5
File name: data.frame_176_72392SNPs
Number of samples: 176
Number of SNPs: 72392
Type: data.frame

# SNP QC
Removed SNPs with missing rate > 0.3, MAF < 0.05, heterozygosity rate < 0, and heterozygosity rate > 0.7
File name: data.frame_176_6484SNPs
Number of samples: 176
Number of SNPs: 6484
Type: data.frame
```

---
