sNMF

module load anaconda3/2023.09-0
source activate LEA

# navigate to directory with sNMF_model2.1.R

Rscript sNMF_model2.1.R <VCF_File> <K_val>

Rscript ../../sNMF_model2.1.R subset.recode.vcf 10

Rscript ../../Make_MapMixture_Files2.R *snmfProject 5 popmap_geog_subset.txt

Rscript ../../MapMixture3.R Admixture_Dataframe.csv sites_subset.csv -p colors.txt -s site_order.txt --outfile map3 --figure both

# run5 standard dataset subset for popualtions with 4 indiviudals or more