# sNMF and MapMixture

1. Filter .vcf file

3. Run sNMF to determine K-cluster
```sh
module load anaconda3/2023.09-0
source activate LEA

# Rscript sNMF_model2.1.R <file.vcf> <K_val>
Rscript sNMF_model2.1.R --cpus 12 subset.recode.vcf 10
```
Read output .pdf

3. Generate the Map Mixture files
```sh
Rscript ../../Make_MapMixture_Files2.R *snmfProject 5 popmap_geog_subset.txt
```

5. Run plotting script
```sh
source deactivate
source activate sf

Rscript ../../MapMixture3.R Admixture_Dataframe.csv sites_subset.csv -p colors.txt -s site_order.txt --outfile map3 --figure both
```
