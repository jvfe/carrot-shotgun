# README

## 1\. Data sources

This workflow analyzes a **shotgun metagenomics dataset** from the study titled **"Shotgun metagenomics dataset of the core rhizo-microbiome of monoculture and soybean-precedent carrot"**. The raw sequencing data is publicly available from the Sequence Read Archive (SRA) under accession **SRP539180** and was generated using **Illumina** sequencing.

The raw FASTQ files and associated metadata are stored in the `data/` directory and are the primary inputs for this analysis.

-----

## 2\. How to download and prepare data

```bash
cd data/

bash download.sh

bash subsample.sh
```

-----

## 3\. How the workflow works

The main analysis is located in the `workflow/` directory. It consists of two scripts that perform quality control, metagenomic assembly, gene prediction, and downstream analysis.

### Step 1 – Run Pipeline (`run_pipeline.sh`)

**Purpose:** This script processes the subsampled reads to generate a set of assembled contigs and predict protein-coding genes from them. It involves three main stages: quality control, assembly, and gene annotation. 🔬

**Tools:** `fastp`, `MultiQC`, `MEGAHIT`, `Prodigal`

**Inputs:**

  * Subsampled paired-end FASTQ files (`data/sra_data_downsampled/`)

**Command:**

```bash
bash workflow/run_pipeline.sh
```

-----

### Step 2 – Answer Question 5 (`question_5.R`)

**Purpose:** This script uses the predicted protein data to answer a question.

**Tools:** `R`

**Command:**

```bash
Rscript workflow/question_5.R
```
