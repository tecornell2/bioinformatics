# GENOME ASSEMBLY

The following pipeline is heavily based on a free tutorial from Rhett Rautsaw (https://github.com/RhettRautsaw/Bioinformatics/blob/master/tutorials/HiFi_Genomics.md) and notes from PhD candidate John Henry.

## 0. Raw Data (PacBio HiFi reads)

### File Types
| abbrev    | type                        |
|-----------|-----------------------------|
| .fasta    | Fast-All                    |
| .fastq    |                             |
| .gfa      | Graphical Fragment Assembly |
| .gz       |                             |


## 0.1 Concatenate 

### HiFi raw data
  ```sh
  # concat hifi reads from different runs into a single file
  cat Nfasc-CLP2811_WGS_blood_hifi-1.fastq.gz Nfasc-CLP2811_WGS_blood_hifi-2.fastq.gz > Nfasc-CLP2811_WGS_blood_hifi_v2.fastq.gz
  ```

## 2. Trim [Trim Galore!] <optional>
Documentation: https://github.com/FelixKrueger/TrimGalore

## 3. Assembly [hifiasm]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name 02_hifiiasm_Nclar
#SBATCH --output 02_hifiasm_Nclar_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 260gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load anaconda3/2023.09-0
  source activate hifiasm

  cd /project/viper/venom/Taryn/Nerodia/Nclarkii/02_hifiasm
  hifiasm -o Nclar-CLP2810_assembled_blood -t 40 Nclar-CLP2810_WGS_blood_hifi_v2.fastq.gz
    
  # converts output .bp.p_ctg.gfa file from hifiasm to .fasta file for next steps
  awk '/^S/{print ">"$2;print $3}' Nclar-CLP2810_assembled_blood.bp.p_ctg.gfa > Nclar-CLP2810_assembled_blood.bp.p_ctg.fasta
```

hifiasm requires input reads in FASTQ format
-t sets the number of CPUs
-o sets the output file prefix, *do not include suffixes*

#### hifiasm Outputs
1. Primary contigs (bp.p_ctg.gfa)
    - For reference genome, downstream annotation or synteny
2. Haplotype-resolved contigs (bp.hap1.p_ctg.gfa and bp.hap2.p_ctg.gfa)
    - For heterozygosity, parental haplotypes

Resource: https://hifiasm.readthedocs.io/en/latest/interpreting-output.html 

---
### Stats on Assembly [bbstats]
Run basic statistics on assmebly (N50) prior to next step.

```sh
bbstats.sh in=Nclar-CLP2810_assembled_blood.bp.p_ctg.fasta out=Nclar-CLP2810_assembled_blood.bp.p_ctg.fasta.stats.txt Xmx64g
```

<details><summary> bbstats .txt output file</summary>


```sh
A       C       G       T       N       IUPAC   Other   GC      GC_stdev
0.2936  0.2065  0.2064  0.2934  0.0000  0.0000  0.0000  0.4130  0.0523

Main genome scaffold total:             652
Main genome contig total:               652
Main genome scaffold sequence total:    1868.768 Mb
Main genome contig sequence total:      1868.768 Mb     0.000% gap
Main genome scaffold N/L50:             15/40.169 Mbp
Main genome contig N/L50:               15/40.169 Mbp
Main genome scaffold N/L90:             87/2.16 Mbp
Main genome contig N/L90:               87/2.16 Mbp
Max scaffold length:                    132.563 Mbp
Max contig length:                      132.563 Mbp
Number of scaffolds > 50 KB:            523
% main genome in scaffolds > 50 KB:     99.76%


Minimum         Number          Number          Total           Total           Scaffold
Scaffold        of              of              Scaffold        Contig          Contig
Length          Scaffolds       Contigs         Length          Length          Coverage
--------        --------------  --------------  --------------  --------------  --------
    All                    652             652   1,868,768,395   1,868,768,395   100.00%
 10 Kbp                    652             652   1,868,768,395   1,868,768,395   100.00%
 25 Kbp                    632             632   1,868,341,481   1,868,341,481   100.00%
 50 Kbp                    523             523   1,864,196,645   1,864,196,645   100.00%
100 Kbp                    399             399   1,855,130,931   1,855,130,931   100.00%
250 Kbp                    287             287   1,836,953,774   1,836,953,774   100.00%
500 Kbp                    214             214   1,810,236,164   1,810,236,164   100.00%
  1 Mbp                    138             138   1,756,125,051   1,756,125,051   100.00%
2.5 Mbp                     84              84   1,676,024,224   1,676,024,224   100.00%
  5 Mbp                     53              53   1,567,080,144   1,567,080,144   100.00%
 10 Mbp                     36              36   1,455,695,369   1,455,695,369   100.00%
 25 Mbp                     25              25   1,284,235,163   1,284,235,163   100.00%
 50 Mbp                      9               9     695,168,459     695,168,459   100.00%
100 Mbp                      2               2     252,884,988     252,884,988   100.00%
```

</details>
<p></p>

**Three dimensions (3 C's) of *de novo* genome assembly:**
1. Contiguity: the length of continuous stretches of DNA sequence [N50, or similar measures]
2. Completeness: the presence of highly conserved genes [BUSCO analysis]
3. Correctness: the accuracy of basepair readings

Reference Article: https://www.pacb.com/blog/beyond-contiguity/

## 4. Quality of Assembly [BUSCO]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name 04_BUSCO_Nclar
#SBATCH --output 04_BUSCO_Nclar_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 50
#SBATCH --mem 256gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load anaconda3/2023.09-0
  # activate conda environment busco
  source activate busco

  # change to directory with genome file
  cd /project/viper/venom/Taryn/Nerodia/Nclarkii/04_BUSCO

  # run BUSCO on genome
  busco -i Nclar-CLP2810_assembled_blood.bp.p_ctg.fasta  -m genome -l /home/tecorn/busco_downloads/lineages/tetrapoda_odb12 -c 80 -o 04_BUSCO
```

Documentation: https://busco.ezlab.org/ 


# GENOME ANNOTATION
<information>

## 7. Transposable Element Annotation and Repeat Masking [EDTA]
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

#### Output
<details><summary>EDTA output file</summary>

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
</details>
Documentation: https://github.com/oushujun/EDTA?tab=readme-ov-file
https://www.repeatmasker.org/ 

---
### Soft Masking [RepeatMasker]

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

## 8. Annotation [funannotate]

### 8.1 Training
### .job file
```sh
```

### 8.2

### 8.3


## 9. Cleaning 
