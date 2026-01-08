# GENOME ANNOTATION
<information>

## Transposable Element Annotation and Repeat Masking [EDTA]
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
### Soft Masking [RepeatMasker]

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

## RNA transcript to Protein Databases [HISTAT2]

### .job file
```sh
#!/bin/bash

#SBATCH --job-name HISTAT2_Nfasc
#SBATCH --output HISTAT2_Nfasc_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 20
#SBATCH --mem 96gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load hisat2
module load samtools

cd /project/viper/venom/Taryn/Nerodia/Nfasciata/06_GALBA
hisat2-build -p 20 Nfasc-CLP2811_genome.scaffold.masked.fasta GINDEX

cd /project/viper/venom/Taryn/Nerodia/Nfasciata/06_GALBA/RNA
while read SAMPLE; do
    echo "Processing ${SAMPLE}..."
    hisat2 -p 20 --rg-id ${SAMPLE} --rg SM:${SAMPLE} \
        --summary-file ${SAMPLE}_hisat2_summary.txt \
        -x GINDEX \
        -1 ${SAMPLE}_R1_trim_1.fastq.gz \
        -2 ${SAMPLE}_R2_trim_2.fastq.gz \
        -S ${SAMPLE}.sam

    rm ${SAMPLE}.sam
    samtools view -@ 20 -b -F 4 ${SAMPLE}.bam > ${SAMPLE}_mapped.bam
    rm ${SAMPLE}.bam
    samtools sort -@ 20 ${SAMPLE}_mapped.bam -o ${SAMPLE}_mapped.sorted.bam"
    rm ${SAMPLE}_mapped.bam
    samtools index ${SAMPLE}_mapped.sorted.bam

done < RNA_list.txt

```

## Protein Prediction [CodAn]

merge protein databases
```sh
cat CodAn_output/PEP_sequences.fasta ProteinDB.fasta > FINALProteinDB.fasta
```

## Annotation [GALBA]
```sh
#!/bin/bash

#SBATCH --job-name 06_GALBA_Nfasc
#SBATCH --output 06_GALBA_Nfasc_output
#SBATCH --nodes 1
#SBATCH --partition nodeviper
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 20
#SBATCH --mem 256gb
#SBATCH --time 128:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

galba.pl --threads 20 --genome=Nfasc-CLP2811_assembled_blood.scaffold.fasta.masked --prot_seq=FINALProteinDB.fasta

```

## Cleaning
