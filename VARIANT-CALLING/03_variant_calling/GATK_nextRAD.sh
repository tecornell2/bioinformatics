#!/bin/bash

#SBATCH --job-name 03_nextRAD_GATK
#SBATCH --output 03_GATK_nextRAD_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 10
#SBATCH --constraint=cpu_gen_genoa
#SBATCH --mem 32gb
#SBATCH --time 72:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

####################### Set inputs and Load packages ##############################
module load anaconda3/2023.09-0
source activate bio

module load samtools
# conda bio samtools version acting weird

BASE="/project/viper/venom/Taryn/Plestiodon/Pegregius"
REF="${BASE}/WGS/genome/Pegre-CLP3001_assembled_blood.fa"
OUTDIR="${BASE}/nextRAD/03_GATK"
SAMPLE_LIST="${BASE}/nextRAD/00_samples_list.txt"
TMPDIR="/scratch/${USER}/gatk_tmp"
THREADS=1

export BASE REF OUTDIR TMPDIR THREADS

mkdir -p "$OUTDIR" "$TMPDIR"

####################### Create sample map ##############################

SAMPLE_MAP="${OUTDIR}/sample_map.tsv"
: > "$SAMPLE_MAP"

####################### Create additional ref files ##############################

# samtools faidx "$REF"
# gatk CreateSequenceDictionary -R "$REF"

####################### Begin pipeline ##############################

echo "Per-sample calling to GVCF..."

parallel -a $SAMPLE_LIST --colsep '\t' -j 8 --joblog "${OUTDIR}/parallel_hc.log" '
  SAMPLE={1}

  INPUT_BAM="${BASE}/nextRAD/02_align/${SAMPLE}_aligned_sorted_RG.bam"
  GVCF="${OUTDIR}/${SAMPLE}.g.vcf.gz"

  echo "Start ${SAMPLE}"

  # Create .bai index file if it does not exist
  [[ -f "${INPUT_BAM}.bai" ]] || samtools index "$INPUT_BAM"

  gatk --java-options "-Xmx3g" HaplotypeCaller \
    -R "$REF" \
    -I "$INPUT_BAM" \
    -O "$GVCF" \
    -ERC GVCF \
    --native-pair-hmm-threads "$THREADS"

'

# Create sample map
  # sets SAMPLE_MAP to empty
while IFS=$'\t' read -r SAMPLE; do
  printf "%s\t%s/%s.g.vcf.gz\n" "$SAMPLE" "$OUTDIR" "$SAMPLE" >> "$SAMPLE_MAP"
done < <(grep -v '^#' "$SAMPLE_LIST")

echo "Importing GVCFs to GenomicsDB..."

gatk --java-options "-Xmx32g" GenomicsDBImport \
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

echo "GATK Joint calling completed successfully. This file has not been hard filtered."
