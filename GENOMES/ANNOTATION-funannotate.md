**incomplete and untested past funnannotate predict**

# GENOME ANNOTATION
<information>

## 4. Transposable Element Annotation and Repeat Masking [EDTA]
Extensive De-novo TE Annotator (EDTA) performs RepeatModeler/RepeatMasker

### .job file
```sh
#!/bin/bash
#SBATCH --job-name 04_EDTA_Nfasc
#SBATCH --output 04_EDTA_Nfasc_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 256gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

 module load anaconda3/2023.09-0
 source activate edta

 cd /project/viper/venom/Taryn/Nerodia/Nfasciata/04_EDTA

 # run EDTA on assembled genome
 perl /home/tecorn/.conda/envs/edta/share/EDTA/EDTA.pl \
 --genome ../Nfasc-CLP2811_genome.fasta \
 --species others \
 --step all \
 --sensitive 1 \
 --anno 1 \
 --force 1 \
 --threads 40
```
force [0|1] Use rice TEs to continue when no confident TE candidates are found (1)
sensitive [0|1]	Use RepeatModeler to identify remaining TEs (1)
overwrite [0|1] Use to overwrite previous steps (files) produced by EDTA (default, 0)
\
<details><summary>EDTA .txt output file</summary>

```sh
Repeat Classes
==============
Total Sequences: 818
Total Length: 1869125421 bp
Class                  Count        bpMasked    %masked
=====                  =====        ========     =======
LINE                   --           --           --   
    CR1                507180       145848654    7.80% 
    I                  1438         1685270      0.09% 
    Jockey             71510        10406728     0.56% 
    L1                 106504       71958335     3.85% 
    L2                 121256       94359993     5.05% 
    R4                 38377        20381725     1.09% 
    RTE                68143        22012823     1.18% 
    Rex                43671        16118414     0.86% 
    unknown            93137        20445522     1.09% 
LTR                    --           --           --   
    Bel_Pao            922          342281       0.02% 
    Copia              2104         1624158      0.09% 
    Gypsy              90251        51742929     2.77% 
    Retrovirus         13526        5432366      0.29% 
    unknown            381683       135374110    7.24% 
SINE                   --           --           --   
    MIR                48465        8247873      0.44% 
TIR                    --           --           --   
    CACTA              104699       23411162     1.25% 
    Mutator            60853        12893056     0.69% 
    PIF_Harbinger      34957        6241495      0.33% 
    Sola               98           22357        0.00% 
    Tc1_Mariner        17743        4424369      0.24% 
    hAT                393445       89318664     4.78% 
    polinton           858          1205364      0.06% 
nonLTR                 --           --           --   
    DIRS_YR            1385         475764       0.03% 
    Penelope           71888        15420535     0.83% 
nonTIR                 --           --           --   
    helitron           305769       78207949     4.18% 
repeat_fragment        228664       58572821     3.13% 
                      ---------------------------------
    total interspersed 2808526      896174717    47.95%

snRNA                  94           25595        0.00% 
---------------------------------------------------------
Total                  2808620      896200312    47.95%

Repeat Stats
============
Total Sequences: 818
Total Length: 1869125421 bp

```
**concatenated output**
</details>
Documentation: https://github.com/oushujun/EDTA?tab=readme-ov-file
https://www.repeatmasker.org/ 

---
### 4.1 Soft Masking [RepeatMasker]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name 05_EDTA_Nclar
#SBATCH --output 04_EDTA_Nclar_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 256gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

cd /project/viper/venom/Taryn/Nerodia/Nclarkii/04_EDTA

RepeatMasker -pa 24 -e ncbi -lib Nclar-CLP2810_genome.fasta.mod.EDTA.TElib.fa \
  -gff -xsmall Nclar-CLP2810_genome.fasta
```
lib = library input file\
pa = parallel mode\
xsmall = masks repeats in the input genome sequence using soft-masking\

#### Check soft-masking output
```sh
# input this code into an interactive node to print the percentage of lowercase nucleotides (pct_masked)
# must be in the correct directory with the output .masked file
awk 'BEGIN{uc=lc=0} /^>/ {next} {
    for(i=1;i<=length($0);i++){
        c=substr($0,i,1); if(c~/[A-Z]/) uc++; else if(c~/[a-z]/) lc++;
    }
} END{printf "upper: %d\nlower: %d\npct_masked: %.2f\n", uc, lc, lc/(uc+lc)*100}' Nclar-CLP2810_genome.fasta.masked
```

## 5. Annotation [funannotate]

### 5.1 Training

### .job file
```sh
#!/bin/bash

#SBATCH --job-name 06_1_funannotate_Nclar
#SBATCH --output 06_1_funannotate_Nclar_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 256gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

apptainer exec \
    --bind /project/viper/venom/Taryn/bin:/opt/tools,/project/viper/venom/Taryn/Nerodia/Nclarkii/06_funannotate:/data \
    /project/viper/venom/Taryn/Nerodia/Nclarkii/06_funannotate/funannotate_latest.sif \
    funannotate train \
        -i /data/Nclar-CLP2810_genome.fasta.masked \
        -o /data/01_train_output \
        --left /data/RNA/Nclar-CLP2810_RNA_heart_R1_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_kidney_R1_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_liver_R1_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_pancreas_R1_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_SmIntest_R1_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_stomach_R1_trim.fastq.gz \
        --right /data/RNA/Nclar-CLP2810_RNA_heart_R2_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_kidney_R2_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_liver_R2_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_pancreas_R2_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_SmIntest_R2_trim.fastq.gz /data/RNA/Nclar-CLP2810_RNA_stomach_R2_trim.fastq.gz \
        --no_trimmomatic \
        --max_intronlen 30000 \
        --cpus 24

```

### 5.2 Prediction
```sh
#!/bin/bash

#SBATCH --job-name 06_2_funannotate_Nclar
#SBATCH --output 06_2_funannotate_Nclar_output
#SBATCH --nodes 1
#SBATCH --partition nodeviper
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 256gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu


apptainer exec \
    --bind /project/viper/venom/Taryn/bin:/opt/tools,/project/viper/venom/Taryn/Nerodia/Nclarkii/06_funannotate:/data \
    /project/viper/venom/Taryn/Nerodia/Nclarkii/06_funannotate/funannotate_latest.sif \
    funannotate predict \
        -i /data/Nclar-CLP2810_genome.fasta.masked \
        -o /data/02_predict_output \
        --species "Nerodia clarkii" \
        --rna_bam /data/01_train_output/training/funannotate_train.coordSorted.bam \
        --transcript_evidence /data/01_train_output/training/funannotate_train.pasa.gff3 \
        --cpus 24
```

### 5.3 Update

```sh
#SBATCH --job-name 06_3_funannotate_Nfasc
#SBATCH --output 06_3_funannotate_Nfasc_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 156gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

# training folder from 01_training_output must be added to 02_predict_output to access both 01 and 02 outputs for 03_update
apptainer exec \
    --bind /project/viper/venom/Taryn/bin:/opt/tools,/project/viper/venom/Taryn/Nerodia/Nfasciata/06_funannotate:/data \
    /project/viper/venom/Taryn/Nerodia/Nfasciata/06_funannotate/funannotate_latest.sif \
    funannotate update \
      -i /data/02_predict_output \
      -o /data/03_update_output \
      --cpus 16 \
      --pasa_db mysql
```

### 5.4 Functional Annotation


#### Run Eggnog Mapper, SignalP and InterProScan seperately

```sh
#!/bin/bash
#SBATCH --job-name 06_eggnog_Nfasc
#SBATCH --output 06_eggnog_Nfsac_output
#SBATCH --nodes 1
#SBATCH --partition nodeviper
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 100gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load anaconda3/2023.09-0
source activate eggnog

cd /project/viper/venom/Taryn/Nerodia/Nfasciata/06_funannotate/02_predict_output/predict_results

python /project/viper/venom/Taryn/bin/eggnog-mapper/emapper.py -i Nerodia_fasciata.proteins.fa -o emapper --cpu 24
```
```sh
#!/bin/bash
#SBATCH --job-name=SignalP_Nfasc
#SBATCH --output=SignalP_Nfasc_output
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100gb
#SBATCH --time=48:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=tecorn@clemson.edu

INPUT=/project/viper/venom/Taryn/Nerodia/Nfasciata/06_funannotate/02_predict_output/predict_results/Nerodia_fasciata.proteins.fa
OUTDIR=/project/viper/venom/Taryn/Nerodia/Nfasciata/06_funannotate/signalp_output
PREFIX=Nerodia_fasciata

mkdir -p $OUTDIR
cd /project/viper/venom/Taryn/bin/signalp/signalp5/bin || { echo "cd failed"; exit 1; }

# Run SignalP
./signalp \
  -fasta $INPUT \
  -org euk \
  -format short \
  -prefix $OUTDIR/$PREFIX
```

```sh
#!/bin/bash
#SBATCH --job-name=InterPro_Nfasc
#SBATCH --output=InterPro_Nfasc_output
#SBATCH --error=InterPro_error
#SBATCH --nodes=1
#SBATCH --partition=nodeviper
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=370gb
#SBATCH --time=120:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=tecorn@clemson.edu

# Load Java (required by InterProScan)
module load java/11.0.2

INTERPROSCAN=/home/johnhen/Databases/funannotate_databases/interproscan-5.75-106.0/interproscan.sh
INPUT=/project/viper/venom/Taryn/Nerodia/Nfasciata/06_funannotate/02_predict_output/predict_results/Nerodia_fasciata.proteins.fa
OUTDIR=/project/viper/venom/Taryn/Nerodia/Nfasciata/06_funannotate/interpro_output

mkdir -p $OUTDIR

$INTERPROSCAN \
  -i $INPUT \
  -f XML,GFF3,TSV \
  -dp \
  -cpu 24 \
  -appl Pfam,SMART,TIGRFAM,CDD \
  -iprlookup \
  -goterms \
```

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name 06_4_funannotate_Nclar
#SBATCH --output 06_4_funannotate_Nclar_output
#SBATCH --nodes 1
#SBATCH --partition nodeviper
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 356gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load java/11.0.2

# Paths
FUNANNOTATE_CONTAINER=/project/viper/venom/Taryn/Nerodia/Nclarkii/06_funannotate/funannotate_latest.sif
FUNANNOTATE_DB=/home/tecorn/Databases/funannotate_databases
TOOLS=/project/viper/venom/Taryn/bin
PREDICT_OUTPUT=/project/viper/venom/Taryn/Nerodia/Nclarkii/06_funannotate/06_2_predict
ANNOTATE_OUTPUT=/project/viper/venom/Taryn/Nerodia/Nclarkii/06_funannotate/06_4_annotate

# External results
EGGNOG=/project/viper/venom/Taryn/Nerodia/Nclarkii/06_Funannotate/funannotate_predict_output/predict_results/emapper.emapper.annotations
IPRSCAN=/project/viper/venom/Taryn/Nerodia/Nclarkii/06_Funannotate/interproscan_output/Geoemyda_japonica_iprscan.tsv
SIGNALP=/project/viper/venom/Taryn/Nerodia/Nclarkii/06_Funannotate/signalp_output/Geoemyda_japonica_summary.signalp5

# Make sure annotate output directory exists
mkdir -p $ANNOTATE_OUTPUT

# Run annotation
apptainer exec \
  --bind $TOOLS:/opt/tools,\
$PREDICT_OUTPUT:/data/predictions,\
$ANNOTATE_OUTPUT:/data/funannotate_annotate_output,\
$FUNANNOTATE_DB:/funannotate_db \
  --env FUNANNOTATE_DB=/funannotate_db \
  $FUNANNOTATE_CONTAINER \
  funannotate annotate \
    -i /data/predictions \
    -o /data/funannotate_annotate_output \
    --species "Nerodia clarkii" \
    --eggnog $EGGNOG \
    --iprscan $IPRSCAN \
    --signalp $SIGNALP \
    --cpus 24
```
## 6. Cleaning 


---

```sh
./blobtools2/blobtools create \
    --fasta /project/viper/venom/Taryn/Nerodia/Nclarkii/04_EDTA/Nclar-CLP2810_genome.fasta \
    Nclarkii
```

```sh
-c /project/viper/venom/Ramses/HiFi/Apisc-DRR0068/WGS/blood/Combined_PacBio_HiFi/05_annotate/annotate/update_misc/pasa/annotCompare.txt \
--PASACONF /home/ramsesr/.conda/envs/funannotate_env/opt/pasa-2.5.2/pasa_conf/conf.txt \
-g /project/viper/venom/Ramses/HiFi/Apisc-DRR0068/WGS/blood/Combined_PacBio_HiFi/05_annotate/annotate/update_misc/genome.fa \
-t /project/viper/venom/Ramses/HiFi/Apisc-DRR0068/WGS/blood/Combined_PacBio_HiFi/05_annotate/annotate/update_misc/trinity.fasta.clean -A -L --CPU 50 \
--annots /project/viper/venom/Ramses/HiFi/Apisc-DRR0068/WGS/blood/Combined_PacBio_HiFi/05_annotate/annotate/update_misc/pasa/Agkistrodon_piscivorus_pasa.gene_structures_post_PASA_updates.880002.gff3 &> pasa-comparison2.5.log
```

---
## BRAKER

```sh
#!/bin/bash
#SBATCH --job-name 06_BRAKER_Nfasc
#SBATCH --output 06_BRAKER_Nfasc_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 180gb
#SBATCH --time 96:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

cd /project/viper/venom/Taryn/Nerodia/Nfasciata/06_BRAKER

singularity exec braker3.sif braker.pl \
      --species=nerodiaFasciata \
      --genome=Nfasc-CLP2811_genome.scaffold.masked.fasta \
      --rnaseq_sets_ids=Nfasc-CLP2811_RNA_heart_mapped.sorted,Nfasc-CLP2811_RNA_kidney_mapped.sorted,Nfasc-CLP2811_RNA_liver_mapped.sorted,Nfasc-CLP2811_RNA_stomach_mapped.sorted,Nfasc-CLP2811_RNA_pancreas_mapped.sorted,Nfasc-CLP2811_RNA_SmIntest_mapped.sorted \
      --rnaseq_sets_dirs=./RNA/ \
      --workingdir=braker_output \
      --threads=8
```
