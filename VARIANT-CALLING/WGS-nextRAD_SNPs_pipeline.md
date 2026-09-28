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

### Identify overlap

```sh

```
