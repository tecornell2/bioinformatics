#!/bin/bash

#SBATCH --job-name test_chr_WGS_GATK
#SBATCH --output test_chr_WGS_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 2
#SBATCH --partition nodeviper
#SBATCH --constraint=cpu_gen_genoa
#SBATCH --mem 32gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

####################### Set inputs and Load packages ##############################
module load anaconda3/2023.09-0
source activate bio
module load samtools

BASE="/project/viper/venom/Taryn/Plestiodon/Pegregius"
REF="${BASE}/WGS/genome/Pegre-CLP3001_assembled_blood.fa"
OUTDIR="${BASE}/GATK/output_chr"
TMPDIR="/scratch/${USER}/gatk_chr_tmp"
THREADS=2

GVCF="${OUTDIR}/CLPT1254.REF_ptg000013l.g.vcf.gz"
INPUT_BAM="${BASE}/GATK/chr/CLPT1254/CLPT1254_aligned_sorted_marked_RG.REF_ptg000013l.bam"
SAMPLE_MAP="${BASE}/GATK/sample_map_chr13.tsv"

mkdir -p "$OUTDIR" "$TMPDIR"

####################### Create sample map ##############################

echo "Per chromosome test for CLPT1254 chr ptg000013l"

cd ${BASE}/GATK/chr/CLPT1254/

# Create .bai index file if it does not exist
[ -f "${INPUT_BAM}.bai" ]] || samtools index "$INPUT_BAM"

gatk --java-options "-Xmx32g" HaplotypeCaller \
    -R "$REF" \
    -I "$INPUT_BAM" \
    -O "$GVCF" \
    -ERC GVCF \
    --native-pair-hmm-threads "$THREADS"

echo "Importing GVCFs to GenomicsDB..."

gatk --java-options "-Xmx32g -Xms4g" GenomicsDBImport \
  --genomicsdb-workspace-path "${OUTDIR}/cohort_db" \
  --overwrite-existing-genomicsdb-workspace true \
  --sample-name-map "$SAMPLE_MAP" \
  --tmp-dir "$TMPDIR" \
  -L "${BASE}/WGS/genome/genome.intervals"

echo "Joint genotyping..."

gatk --java-options "-Xmx32g" GenotypeGVCFs \
  -R "$REF" \
  -V "gendb://${OUTDIR}/cohort_db" \
  -O "${OUTDIR}/cohort.raw.vcf.gz"

echo "Completed GATK pipeline for CLPT1254 chr 13"
