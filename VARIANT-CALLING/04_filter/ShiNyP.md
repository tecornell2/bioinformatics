# ShiNyP

### Installation

```sh
docker --version
# Docker version 29.1.3, build 29.1.3-0ubuntu3~24.04.2
docker run -d -p 3838:3838 teddyenn/shinyp-platform
```

---
### 20260907
I filtered the WGS dataset loosley and uploaded the following dataset to ShiNyP for visualization: `filtered_catalog.GQ-20.minDP-5.F_MISS-50.snps.vcf.gz`

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
