# Supervised Machine Learning (SML) Model: delimitR

### 00_raw_data
nextRAD libraries 
cut sequence: GTGTAGAGCC

de novo reference genome
> ref_skink.fasta
SNP data
> skink.vcf

### 01_inputs


#### easySFS

sh'''
#set up
conda create -n easySFS
conda install -c conda-forge numpy pandas scipy -y
git clone https://github.com/isaacovercast/easySFS.git
cd easySFS
chmod 777 easySFS.py

#step 1
./easySFS.py -i skink.vcf -p pops_file.txt --preview

#step2
'''

