#!/bin/bash
#SBATCH --job-name 03_RAD-WGS_GATK_chr
#SBATCH --output 03_GATK_nextRAD_WGS_chr_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 32
#SBATCH --partition nodeviper
#SBATCH --constraint=cpu_gen_genoa
#SBATCH --mem 384gb
#SBATCH --time 168:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

set -euo pipefail

####################### Set inputs and load packages ##############################

module load anaconda3/2023.09-0
source activate bio
module load samtools
module load gnuparallel
module load gatk/4

BASE="/project/viper/venom/Taryn/Plestiodon/Pegregius"
REF="${BASE}/WGS/genome/Pegre-CLP3001_assembled_blood.fa"
OUTDIR="${BASE}/GATK/output_chr"
SAMPLE_INFO="${BASE}/GATK/00_sample_sheet.txt"
TMPDIR="/scratch/${USER}/gatk_chr_tmp"

# File containing one contig/chromosome name per line
CONTIG_LIST="${BASE}/WGS/genome/contigs.list"

# Number of chromosomes/contigs processed at the same time
CHR_JOBS=3
# Threads per HaplotypeCaller process
THREADS_PER_HC=4

# Java memory per process. Make sure concurrent jobs fit inside total --mem.
HC_JAVA_MEM="16g"
JAVA_MEM="128g"

export BASE REF OUTDIR SAMPLE_INFO TMPDIR CONTIG_LIST
export THREADS_PER_HC GENOMICSDB_READER_THREADS
export HC_JAVA_MEM GDB_JAVA_MEM GG_JAVA_MEM

mkdir -p "$OUTDIR" "$TMPDIR"

####################### Reference prep ##############################

# samtools faidx "$REF"
# gatk CreateSequenceDictionary -R "$REF"

####################### Build contig list if missing ##############################

# samtools faidx "$REF"
# cut -f1 "${REF}.fai" > contigs.list

####################### Check sample sheet ##############################

if [[ ! -s "$SAMPLE_INFO" ]]; then
  echo "ERROR: sample sheet not found or empty: $SAMPLE_INFO" >&2
  exit 1
fi

echo "Samples:"
grep -v -e '^#' -e '^[[:space:]]*$' "$SAMPLE_INFO" || true

echo "Contigs/chromosomes:"
cat "$CONTIG_LIST"

####################### Function: process one chromosome ##############################

run_one_contig() {
  CONTIG="$1"

  CHR_OUTDIR="${OUTDIR}/${CONTIG}"
  GVCF_DIR="${CHR_OUTDIR}/gvcfs"
  LOG_DIR="${CHR_OUTDIR}/logs"
  CHR_TMPDIR="${TMPDIR}/${CONTIG}"
  SAMPLE_MAP="${CHR_OUTDIR}/sample_map.${CONTIG}.tsv"
  COHORT_DB="${CHR_OUTDIR}/cohort_db.${CONTIG}"
  RAW_VCF="${CHR_OUTDIR}/cohort.${CONTIG}.raw.vcf.gz"

  mkdir -p "$CHR_OUTDIR" "$GVCF_DIR" "$LOG_DIR" "$CHR_TMPDIR"

  echo "======================================================================"
  echo "Starting contig/chromosome: ${CONTIG}"
  echo "Output directory: ${CHR_OUTDIR}"
  echo "======================================================================"

  ####################### Per-sample HaplotypeCaller for this chromosome #######################

  : > "$SAMPLE_MAP"

  while IFS=$'\t' read -r SAMPLE TYPE; do
    [[ -z "${SAMPLE:-}" ]] && continue
    [[ "${SAMPLE}" =~ ^# ]] && continue


    # Expected chromosome-split BAM for all data types, including RADseq and WGS:
    INPUT_BAM="${BASE}/GATK/chr/${SAMPLE}/${SAMPLE}.REF_${CONTIG}.bam"

    if [[ ! -f "$INPUT_BAM" ]]; then
      echo "ERROR: missing chromosome BAM for sample '${SAMPLE}', contig '${CONTIG}':" >&2
      echo "       $INPUT_BAM" >&2
      exit 1
    fi

    [[ -f "${INPUT_BAM}.bai" ]] || samtools index "$INPUT_BAM"

    GVCF="${GVCF_DIR}/${SAMPLE}.${CONTIG}.g.vcf.gz"

    echo "HaplotypeCaller: sample=${SAMPLE}, type=${TYPE}, contig=${CONTIG}"

    gatk --java-options "-Xmx${HC_JAVA_MEM} -Djava.io.tmpdir=${CHR_TMPDIR}" HaplotypeCaller \
      -R "$REF" \
      -I "$INPUT_BAM" \
      -O "$GVCF" \
      -ERC GVCF \
      -L "$CONTIG" \
      --native-pair-hmm-threads "$THREADS_PER_HC" \
      > "${LOG_DIR}/${SAMPLE}.${CONTIG}.HaplotypeCaller.log" 2>&1

    printf "%s\t%s\n" "$SAMPLE" "$GVCF" >> "$SAMPLE_MAP"

  done < <(grep -v -e '^#' -e '^[[:space:]]*$' "$SAMPLE_INFO")

  ####################### GenomicsDBImport for this chromosome #######################

  echo "GenomicsDBImport: contig=${CONTIG}"

  gatk --java-options "-Xmx${JAVA_MEM} -Xms4g -Djava.io.tmpdir=${CHR_TMPDIR}" GenomicsDBImport \
    --genomicsdb-workspace-path "$COHORT_DB" \
    --overwrite-existing-genomicsdb-workspace true \
    --sample-name-map "$SAMPLE_MAP" \
    --tmp-dir "$CHR_TMPDIR" \
    -L "$CONTIG" \
    > "${LOG_DIR}/${CONTIG}.GenomicsDBImport.log" 2>&1

  ####################### Joint genotyping for this chromosome #######################

  echo "GenotypeGVCFs: contig=${CONTIG}"

  gatk --java-options "-Xmx${JAVA_MEM} -Djava.io.tmpdir=${CHR_TMPDIR}" GenotypeGVCFs \
    -R "$REF" \
    -V "gendb://${COHORT_DB}" \
    -O "$RAW_VCF" \
    -L "$CONTIG" \
    > "${LOG_DIR}/${CONTIG}.GenotypeGVCFs.log" 2>&1

  echo "[$(date)] Completed contig/chromosome: ${CONTIG}"
  echo "Raw VCF: ${RAW_VCF}"
}

export -f run_one_contig

####################### Run chromosomes in parallel ##############################

echo "Beginning chromosome-parallel GATK pipeline..."
echo "CHR_JOBS=${CHR_JOBS}"
echo "THREADS_PER_HC=${THREADS_PER_HC}"
echo "GENOMICSDB_READER_THREADS=${GENOMICSDB_READER_THREADS}"

parallel \
  -j "$CHR_JOBS" \
  --joblog "${OUTDIR}/parallel_by_chromosome.log" \
  run_one_contig :::: "$CONTIG_LIST"














####################### Optional: gather chromosome VCFs ##############################
#
# This creates one genome-wide VCF after all per-chromosome VCFs finish.
# If you prefer to keep one VCF per chromosome only, comment this section out.
#
# IMPORTANT: GatherVcfs expects all input VCFs to follow reference contig order.
# The loop below uses CONTIG_LIST order.

#GATHER_ARGS="${OUTDIR}/gather_vcfs.args"
#: > "$GATHER_ARGS"

#while read -r CONTIG; do
#  [[ -z "${CONTIG:-}" ]] && continue
#  CONTIG="${CONTIG//[^A-Za-z0-9_.-]/_}"
#  VCF="${OUTDIR}/${CONTIG}/cohort.${CONTIG}.raw.vcf.gz"
#  if [[ ! -f "$VCF" ]]; then
#    echo "ERROR: expected VCF not found for gathering: $VCF" >&2
#    exit 1
#  fi
#  echo "-I ${VCF}" >> "$GATHER_ARGS"
#done < "$CONTIG_LIST"

#echo "Gathering per-chromosome VCFs into genome-wide raw VCF..."

#gatk --java-options "-Xmx16g -Djava.io.tmpdir=${TMPDIR}" GatherVcfs \
#  --arguments_file "$GATHER_ARGS" \
#  -O "${OUTDIR}/cohort.all_contigs.raw.vcf.gz"

echo "GATK joint calling completed successfully."
#echo "Per-chromosome outputs are in: ${OUTDIR}/<contig>/"
#echo "Combined raw VCF: ${OUTDIR}/cohort.all_contigs.raw.vcf.gz"
#echo "This file has not been hard filtered."
