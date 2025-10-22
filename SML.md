# Supervised Machine Learning (SML) Model: delimitR

### 00_raw_data
nextRAD libraries 
cut sequence: GTGTAGAGCC

de novo reference genome: ref_skink.fasta
SNP data: skink.vcf

#### filtering
```sh
module load vcftools

vcftools --vcf skink.vcf --remove-indels --maf 0.05 --max-missing 0.9 \
--recode --stout | zip -c > skink_filtered.vcf
```

```sh
bcftools sort skink_filtered_sorted.vcf -0z -o
bcftools index -t skink_filtered_sorted.vcf 
```

### easySFS

```sh
# set up
conda create -n easySFS
conda install -c conda-forge numpy pandas scipy -y
git clone https://github.com/isaacovercast/easySFS.git
cd easySFS
chmod 777 easySFS.py

# step 1
~/easySFS/easySFS.py -i skink.vcf -p Pegre_id_pop_2018.txt --preview

# step2
~/easySFS/easySFS.py -i skink.vcf -p Pegre_id_pop_2018.txt --proj 20,20
```

---
### sNMF
snmf estimates admixture coefficients using sparse Non-Negative Matrix Factorization algorithms
```sh
test
```
