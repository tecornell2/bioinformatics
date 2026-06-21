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
  cat Nfasc-CLP2811_WGS_blood_hifi-1.fastq.gz Nfasc-CLP2811_WGS_blood_hifi-2.fastq.gz > Nfasc-CLP2811_WGS_blood_hifi_v2.fastq.gz
  ```

### Hi-C raw data
  ```sh
  #concat HiC R1s (forward) and the R2s (reverse) into a single file
  cat 1832_HiC_S1_R1_Run1_val_1.fq.gz Parkinson_S2_R1_001_val_1.fq.gz > 1832_HiC_combined_R1.fq.gz
  cat 1832_HiC_S1_R2_Run1_val_2.fq.gz Parkinson_S2_R2_001_val_2.fq.gz > 1832_HiC_combined_R2.fq.gz
  ```

## 2. Trim [Trim Galore!]
Documentation: https://github.com/FelixKrueger/TrimGalore

## 3. Assembly [hifiasm]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name 01_hifiasm_Pegre
#SBATCH --output 01_hifiasm_Pegre_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 260gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  module load anaconda3/2023.09-0
  source activate hifiasm

  cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/01_hifiasm
  hifiasm -o Pegre-CLP3001_assembled_blood -t 40 /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/00_raw/Pegre-CLP3001/WGS/Blood/2026_03_27_UDel_PacBio_HiFi/00_raw/Pegre-CLP3001_WGS_blood_hifi.fastq.gz
    
  # converts output .bp.p_ctg.gfa file from hifiasm to .fasta file for next steps
  awk '/^S/{print ">"$2;print $3}' Pegre-CLP3001_assembled_blood.bp.p_ctg.gfa > Pegre-CLP3001_assembled_blood.bp.p_ctg.fasta
```

hifiasm requires input reads in FASTQ format
-t sets the number of CPUs
-o sets the output file prefix, *do not include suffixes*

**Hi-C integration**
```sh 
hifiasm -o 1832_assembled_blood_DoubleHiC -t 50 --h1 1832_HiC_combined_R1.fq.gz --h2 1832_HiC_combined_R2.fq.gz CLP1832_HiFi_reads.fastq.gz
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
bbstats.sh in=Pegre-CLP3001_assembled_blood.bp.p_ctg.fasta out=Pegre-CLP3001_assembled_blood.bp.p_ctg.fasta.stats.txt Xmx64g
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
```

```sh
cat Pegre-CLP3001_assembled_blood.bp.p_ctg.fasta.stats.txt
A       C       G       T       N       IUPAC   Other   GC      GC_stdev
0.2722  0.2279  0.2277  0.2721  0.0000  0.0000  0.0000  0.4557  0.0485

Main genome scaffold total:             38
Main genome contig total:               38
Main genome scaffold sequence total:    1514.737 Mb
Main genome contig sequence total:      1514.737 Mb     0.000% gap
Main genome scaffold N/L50:             4/164.3 Mbp
Main genome contig N/L50:               4/164.3 Mbp
Main genome scaffold N/L90:             9/49.038 Mbp
Main genome contig N/L90:               9/49.038 Mbp
Max scaffold length:                    298.402 Mbp
Max contig length:                      298.402 Mbp
Number of scaffolds > 50 KB:            23
% main genome in scaffolds > 50 KB:     99.97%
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
#SBATCH --job-name 02_BUSCO_Pegre
#SBATCH --output 02_BUSCO_Pegre_output
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

  # change to working directory
  cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/

  # run BUSCO on genome
  busco -i ./01_hifiasm/Pegre-CLP3001_assembled_blood.bp.p_ctg.fasta  -m genome -l /home/tecorn/busco_downloads/lineages/tetrapoda_odb12 -c 50 -o ./02_BUSCO/
```

Documentation: https://busco.ezlab.org/ 

## 5. Align and Index [BWA+MEM] [samtools]

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name=bwa_turtle_hic_align
#SBATCH --output=bwa_turtle_hic_align_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 50
#SBATCH --mem 240gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user johnhen@clemson.edu

  module load anaconda3/2023.09-0
  source activate yahs_env

  cd /project/viper/venom/John_Henry/Turtle
  # Define variables
  THREADS=50
  READ1="turtle_S4_R1_001_val_1.fq.gz"
  READ2="turtle_S4_R2_001_val_2.fq.gz"
  GENOME="Turtle_assembled_blood_plusHiC.hic.p_ctg.fasta"
  OUT_BAM="turtle_hic_algn.bam"
  SORTED_BAM="turtle_hic_algn_sorted.bam"

  # Index genome if needed
  if [ ! -f "${GENOME}.bwt" ]; then
      echo "[INFO] Indexing genome with BWA..."
      bwa index $GENOME
  fi

  # Run BWA-MEM and process with samtools
  bwa mem -5SP -t $THREADS $GENOME $READ1 $READ2 | \
      samtools view -@ $THREADS -b -h -F 2316 - | \
      samtools sort -@ $THREADS -o $SORTED_BAM

  # Index the sorted BAM
  samtools index $SORTED_BAM
```

## 6. Scaffolding [YaHs]

Input file type required: .fai
Run:
```sh
samtools faidx Turtle_assembled_blood_plusHiC.hic.p_ctg.fasta
```

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name yahs
#SBATCH --output yahs_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 50
#SBATCH --mem 240gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user johnhen@clemson.edu

module load anaconda3/2023.09-0
source activate yahs_env

/project/viper/venom/John_Henry/Turtle
yahs Turtle_assembled_blood_plusHiC.hic.p_ctg.fasta turtle_hic_algn_sorted.bam
```

# GENOME ANNOTATION
<information>

## 7. Transposable Element Annotation and Repeat Masking [EDTA]
Extensive De-novo TE Annotator (EDTA) performs RepeatModeler/RepeatMasker

### .job file
```sh
#!/bin/bash
#SBATCH --job-name 03_EDTA_Pegre
#SBATCH --output 03_EDTA_Pegre_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 256gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

 module load anaconda3/2023.09-0
 source activate edta

 cd /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/03_EDTA

 # run EDTA on assembled genome
 perl /home/tecorn/.conda/envs/edta/share/EDTA/EDTA.pl \
 --genome ../Pegre-CLP3001_genome.fasta \
 --species others \
 --step all \
 --sensitive 1 \
 --anno 1 \
 --force 1 \
 --threads 24
```
force [0|1] Use rice TEs to continue when no confident TE candidates are found (1)
sensitive [0|1]	Use RepeatModeler to identify remaining TEs (1)
overwrite [0|1] Use to overwrite previous steps (files) produced by EDTA (default, 0)
Documentation: https://github.com/oushujun/EDTA?tab=readme-ov-file
https://www.repeatmasker.org/ 

---
### Soft Masking [RepeatMasker]

```sh
RepeatMasker -pa 24 -e ncbi -lib Pegre-CLP3001_genome.fa.mod.EDTA.TElib.fa \
  -dir ./EDTA_out \
  -gff -xsmall Pegre-CLP3001_genome.fa
```
lib = library input file
pa = parallel mode
xsmall = masks repeats in the input genome sequence using soft-masking