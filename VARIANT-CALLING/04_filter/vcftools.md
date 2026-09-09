# VCFtools
Source: https://speciationgenomics.github.io/filtering_vcfs/ 

### VCFtools QC
```
vcftools --vcf final.recode.vcf --freq2 --max-alleles 2

vcftools --vcf final.recode.vcf --depth

vcftools --vcf final.recode.vcf --site-mean-depth

vcftools --vcf final.recode.vcf --site-quality 

vcftools --vcf final.recode.vcf --missing-indv

vcftools --vcf final.recode.vcf --missing-site

vcftools --vcf final.recode.vcf --het
```
---

### 202604
STACKS filtering .vcf aligned to ragtaged reference genome
```sh
Extracting indiviudals to remove:
awk '$5 > 0.8 {print $1}' out.imiss > remove.txt
```
```sh
vcftools \
  --vcf *populations.snps.vcf \
  --remove 0.8_missing_and_out.txt \
  --minDP 5 \
  --maxDP 30 \
  --recode \
  --out step1

vcftools \
  --vcf step1.recode.vcf \
  #--maf 0.05 \
  --min-meanDP 5 \
  --max-meanDP 25 \
  --max-missing 0.5 \
  --remove-indels \
  --recode \
  --out final
```
---
### 20260519

STACKS filtering .vcf aligned to reference genome (hifi only)

#### SFS dataset
Using above step1.vcf to remove singletons (--mac 2) (and no --maf 0.05 )

```sh
vcftools \
  --vcf step1.recode.vcf \
  --mac 2 \
  --min-meanDP 5 \
  --max-meanDP 25 \
  --max-missing 0.5 \
  --remove-indels \
  --recode \
  --out demographic_dataset
# this dataset can be used for site frequency spectrum, which relies on maf
# this dataset can be used for sNMF
```

---
### 20260630
STACKS filtering .vcf aligned to reference genome (hifi only)

```sh
vcftools \
  --vcf populations.snps.vcf \
  --remove 0.75_missing_and_out.txt \
  --minDP 5 \
  --maxDP 30 \
  --recode \
  --out step1

vcftools \
  --vcf step1.recode.vcf \
  --min-meanDP 5 \
  --max-meanDP 40 \
  --max-missing 0.7 \
  --remove-indels \
  --thin 141 \
  --recode \
  --out final

** After filtering, kept 168 out of 168 Individuals
Outputting VCF file...
After filtering, kept 860 out of a possible 6972639 Sites **

vcftools \
  --vcf step1.recode.vcf \
  --mac 2
  --min-meanDP 5 \
  --max-meanDP 50 \
  --max-missing 0.6 \
  --remove-indels \
  --thin 141 \
  --recode \
  --out sNMF

** After filtering, kept 168 out of 168 Individuals
Outputting VCF file...
After filtering, kept 860 out of a possible 6972639 Sites **
```

---

### 20260907

Filtering combined WGS-nextRAD dataset (biallelic SNPs). 
```sh
# removed samples: CLPT247, CLPT685, CLPT843

vcftools --gzvcf WGS-nextRAD.combined.snps.vcf.gz \
  --remove ./vcftools/WGS-nextRAD.combined.snps/indv_60missingess.txt \
  --recode --out WGS-nextRAD.50indmiss.combined.snps.vcf.gz
# 203 individuals retained

# filtered minDP maxDP 5-30x
vcftools --gzvcf WGS-nextRAD.50indmiss.combined.snps.vcf.gz.recode.vcf \
  --minDP 5 --maxDP 30 --recode \
  --out WGS-nextRAD.50indmiss.minDP5.maxDP30.combined.snps.vcf.gz 
# 62700 sites

# removed samples (remaining outgroup)
 vcftools --vcf WGS-nextRAD.50indmiss.minDP5.maxDP30.combined.snps.vcf.gz.recode.vcf \
  --remove outgroup_indv.txt --recode \
  --out WGS-nextRAD.50indmiss.minDP5.maxDP30.no-out.combined.snps.vcf.gz.recode.vcf

# thinned
vcftools --vcf WGS-nextRAD.50indmiss.minDP5.maxDP30.no-out.combined.snps.vcf.gz.recode.vcf.recode.vcf \
  --thin 150 --recode -\
  -out WGS-nextRAD.50indmiss.minDP5.maxDP30.no-out.thin150.combined.snps.vcf.gz.recode.vcf.recode.vcf 
# 42163 sites
```

### 20260908
```sh

vcftools --vcf WGS-nextRAD.50indmiss.minDP5.maxDP30.no-out.combined.snps.vcf.gz.recode.vcf.recode.vcf \
  --max-missing 0.75 --recode --out WGS-nextRAD.50indmiss.minDP5.maxDP30.no-out.75geno.combined.snps
# 203 sites

```

---

### 20260909
```sh
# STACKS raw output
  # populations params r = 0.75 min-gt-depth = 5
  # 558298
bcftools view -i 'F_MISSING<=0.10 & FMT/DP>=10' -H populations.snps.vcf | wc -l
# 278505 sites

# mpileup
bcftools view -i 'F_MISSING<=0.10 & FMT/DP>=10' -H catalog.snps.vcf.gz | wc -l
# 11959 sites
```
