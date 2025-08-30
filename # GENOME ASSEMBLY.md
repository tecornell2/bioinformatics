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

## 1. Concatenate 

### HiFi raw data
  ```sh
  # concat hifi reads from different runs into a single file
  cat Nfasc-CLP0000_WGS_blood_hifi-1.fastq.gz Nfasc-CLP0000_WGS_blood_hifi-2.fastq.gz >
   Nfasc-CLP0000_WGS_blood_hifi_v2.fastq.gz
  ```

### Hi-C raw data
  ```sh
  #concat HiC R1s (forward) and the R2s (reverse) into a single file
  cat 0000_HiC_S1_R1_Run1_val_1.fq.gz S2_R1_001_val_1.fq.gz > 0000_HiC_combined_R1.fq.gz
  cat 0000_HiC_S1_R2_Run1_val_2.fq.gz S2_R2_001_val_2.fq.gz > 0000_HiC_combined_R2.fq.gz
  ```

## 2. Assembly [hifiasm]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name 02_hifiasm
#SBATCH --output 02_hifiasm_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 00gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user

  module load anaconda3/2023.09-0
  source activate hifiasm

  cd /project/viper/venom/Taryn/species/sample/02_hifiasm
  hifiasm -o Nclar-CLP0000_assembled_blood -t 40 Nclar-CLP0000_WGS_blood_hifi_v2.fastq.gz
    
  # converts output .bp.p_ctg.gfa file from hifiasm to .fasta file for next steps
  awk '/^S/{print ">"$2;print $3}' Nclar-CLP0000_assembled_blood.bp.p_ctg.gfa > Nclar-CLP0000_assembled_blood.bp.p_ctg.fasta
```

hifiasm requires input reads in FASTQ format
-t sets the number of CPUs
-o sets the output file prefix, *do not include suffixes*

**Hi-C integration**
```sh 
hifiasm -o 0000_assembled_blood_DoubleHiC -t 50 --h1 0000_HiC_combined_R1.fq.gz --h2 0000_HiC_combined_R2.fq.gz
 CLP0000_HiFi_reads.fastq.gz
```

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
bbstats.sh in=Nclar-CLP0000_assembled_blood.bp.p_ctg.fasta out=Nclar-CLP0000_assembled_blood.bp.p_ctg.fasta.stats.txt Xmx64g
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

## 3. Quality of Assembly [BUSCO]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name 03_BUSCO
#SBATCH --output 03_BUSCO_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 50
#SBATCH --mem 00gb
#SBATCH --time 00:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user

  module load anaconda3/2023.09-0
  # activate conda environment busco
  source activate busco

  # change to directory with genome file
  cd /project/viper/venom/Taryn/species/sample/03_BUSCO

  # Run BUSCO on genome
  busco -i Nclar-CLP0000_assembled_blood.bp.p_ctg.fasta  -m genome
   -l /home/user/busco_downloads/lineages/tetrapoda_odb12 -c 50 -o 03_BUSCO
```

Documentation: https://busco.ezlab.org/ 

---
**Hi-C integration and scaffolding**
##### <index and align> [BWA+MEM] [samtools]
##### <scaffolding> [YaHs]

# GENOME ANNOTATION

## 4. Transposable Element Annotation and Repeat Masking [EDTA]

### .job file
```sh
#!/bin/bash
#SBATCH --job-name 04_EDTA
#SBATCH --output 04_EDTA_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 000gb
#SBATCH --time 00:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user

 module load anaconda3/2023.09-0
 source activate edta

 cd /project/viper/venom/Taryn/species/04_EDTA

 perl /home/user/.conda/envs/edta/share/EDTA/EDTA.pl \
 --genome ../genome.fa \
 --species others \
 --step all \
 --sensitive 1 \
 --threads 24 \
 --force 1
```
Documentation: https://github.com/oushujun/EDTA?tab=readme-ov-file

## 5. Annotation [funannotate]



