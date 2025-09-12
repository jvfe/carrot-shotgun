#!/bin/bash

set -e
set -u
set -o pipefail

if [ "$#" -ne 1 ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 <input_fastq.gz>"
    exit 1
fi

INPUT_FQ="$1"
BASENAME=$(basename "$INPUT_FQ" .fastq.gz)
RESULTS_DIR="${BASENAME}_results"

mkdir -p "$RESULTS_DIR"

echo "--- Starting Pipeline for ${BASENAME} ---"
echo "--- Results will be saved in ${RESULTS_DIR} ---"

TRIMMED_FQ="${RESULTS_DIR}/${BASENAME}_trimmed.fastq.gz"
FASTP_HTML="${RESULTS_DIR}/${BASENAME}_fastp_report.html"
FASTP_JSON="${RESULTS_DIR}/${BASENAME}_fastp_report.json"

echo "[$(date)] Running fastp for quality trimming..."
fastp \
    --in1 "$INPUT_FQ" \
    --out1 "$TRIMMED_FQ" \
    --html "$FASTP_HTML" \
    --json "$FASTP_JSON" \
    --thread 4 \
    --detect_adapter_for_pe

echo "[$(date)] fastp completed. Trimmed file: ${TRIMMED_FQ}"

MEGAHIT_OUTDIR="${RESULTS_DIR}/${BASENAME}_megahit_assembly"

echo "[$(date)] Running MEGAHIT for assembly..."
megahit \
    -r "$TRIMMED_FQ" \
    -o "$MEGAHIT_OUTDIR" \
    --min-contig-len 500 \
    --mem-flag 0 \
    --k-min 21 --k-max 121 --k-step 20 \
    --no-mercy \
    -t 4

CONTIGS="${MEGAHIT_OUTDIR}/final.contigs.fa"
echo "[$(date)] MEGAHIT completed. Assembled contigs: ${CONTIGS}"

PRODIGAL_OUTDIR="${RESULTS_DIR}/${BASENAME}_prodigal_prediction"
mkdir -p "$PRODIGAL_OUTDIR"
echo "[$(date)] Running Prodigal for gene prediction..."
prodigal \
    -i "$CONTIGS" \
    -o "${PRODIGAL_OUTDIR}/${BASENAME}_genes.gff" \
    -a "${PRODIGAL_OUTDIR}/${BASENAME}_proteins.faa" \
    -d "${PRODIGAL_OUTDIR}/${BASENAME}_genes.fna" \
    -p meta

echo "[$(date)] Prodigal gene prediction completed. Results in ${PRODIGAL_OUTDIR}"

MULTIQC_OUTDIR="${RESULTS_DIR}/multiqc_report"
echo "[$(date)] Running MultiQC to aggregate reports..."
multiqc "$RESULTS_DIR" --outdir "$MULTIQC_OUTDIR"

echo "[$(date)] MultiQC report generated in ${MULTIQC_OUTDIR}"
echo "--- Pipeline Finished Successfully for ${BASENAME} ---"


