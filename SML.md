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
module load bcftools

bcftools sort skink_filtered.vcf.gz -Oz -o skink_filtered_sorted.vcf.gz 
bcftools view -S Pegre_id_2018.txt skink_filtered_sorted.vcf.gz > skink_filtered_sorted_subset.vcf.gz
bcftools index -t skink_filtered_sorted_subset.vcf
```
### sNMF
snmf estimates admixture coefficients using sparse Non-Negative Matrix Factorization algorithms
```sh
conda create -n LEA
# load R and R package LEA and argsparser
source activate LEA
Rscript sNMF_model2.1.R skink_filtered_sorted_subset.vcf 7
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
