### Variant calling
```sh
# load package
module load bcftools

### --------------------------------
### Call nextRAD variants
### --------------------------------

# bwa index genome.fasta
REF="/project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/genome/Pegre-CLP3001_hifi_hic_genome.clean.fa"

BAMS="/project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/02_align/no_rmdup/00_samples_bam_list.txt"

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/03_mpileup/variants

bcftools mpileup -Ou -f $REF -b $BAMS --threads 8 -a FORMAT/DP \
  | bcftools call -m -v -f GQ --threads 8 -a GQ,GP -Oz -o joint.vcf.gz

### --------------------------------
### Call WGS variants
### --------------------------------

BAMS="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/00_samples_bam_list.txt"

cd /project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/03_mpileup/variants

bcftools mpileup -Ou -f $REF -b $BAMS --threads 16 -a FORMAT/DP \
  | bcftools call -m -v -f GQ --threads 16 -a GQ,GP -Oz -o joint.vcf.gz
```

### Pre-processing
```sh
bcftools +fill-tags joint.vcf.gz -Ou -- -t F_MISSING | bcftools view -Oz -o joint.tags.vcf.gz


bcftools filter
  -S . -i 'FMT/DP >= 5 & FMT/GQ >= 20' catalog.vcf.gz |  \ # minDP 5 and GQ 20 per sample (else replace genotype call with missing '.')
  bcftools view -m2 -M2 -v snps \ # biallelic snps only
  -i 'F_MISSING < 0.5' \ # sites with genotypes in at least 50% population
  -Oz -o rad.minDP5.GQ20.FMISS50.biallelic.snps.joint.tags.vcf.gz
```

### Pre-merge filtering
```sh
cd /project/viper/venom/Taryn/Plestiodon/Pegregius/mpileup/01_input

# filter
bcftools view \
  -m2 -M2 -v snps \ # biallelic snps only
  -i 'QUAL>=20 & INFO/DP>=5' \ 
  filtered_catalog.GQ-20.minDP-5.F_MISS-50.vcf.gz \
  -Oz -o WGS.snps.0.5missing.qual20.DP5.biallelic.vcf.gz

bcftools view
  -m2 -M2 -v snps \
  -i 'QUAL>=20 & INFO/DP>=5' \
  catalog.snps.0.5missing.vcf.gz -Oz \
  -o nextRAD.snps.0.5missing.qual20.DP5.biallelic.vcf.gz

# index files
bcftools index -t WGS.snps.0.5missing.qual20.DP5.biallelic.vcf.gz
bcftools index -t nextRAD.snps.0.5missing.qual20.DP5.biallelic.vcf.gz
```

### Identify overlap

```sh
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
