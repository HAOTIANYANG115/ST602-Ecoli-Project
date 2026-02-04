# Genomic Epidemiology and Bacteriocin Profiling of *E. coli* ST602

This repository contains the custom Bash and Python scripts used for the bioinformatic analysis in the study:
**"Genomic surveillance of blaNDM-5-carrying Escherichia coli ST602 from an integrated duck-egg farming ecosystem in China"** (Submitted, 2026).

## 📂 Repository Contents

### Core Scripts
* `batch_blastp_analysis.sh`: A Bash script to perform high-throughput BLASTP screening of proteomes against the bacteriocin reference database.
* `run_colicin_batch.sh`: A wrapper script to manage batch processing tasks for large datasets.
* `bacteriocin_profiler.py`: A Python script to parse BLASTP output tables, calculate bacteriocin prevalence, and analyze gene co-occurrence patterns.
* `classify_mdr.py`: A Python script to classify isolates into **MDR** (Multidrug-Resistant), **XDR** (Extensively Drug-Resistant), or **PDR** (Pandrug-Resistant) categories based on antimicrobial resistance gene (ARG) profiles.

### Data
* `data/`: (Optional) Contains example datasets or mapping files required for the analysis.

## ⚙️ Requirements

The analysis pipeline requires the following dependencies:

* **NCBI BLAST+** (v2.15.0+ recommended)
* **Python 3.x** with the following libraries:
  * `pandas`
  * `argparse`

To install Python dependencies:
```bash
pip install pandas argparse
Usage Pipeline
Step 1: Bacteriocin Screening (Bash)
Screen the genome assemblies (protein FASTA files) against the local bacteriocin database.

Bash
# 1. Make the scripts executable
chmod +x batch_blastp_analysis.sh

# 2. Run the BLAST pipeline
# Usage: ./batch_blastp_analysis.sh <path_to_faa_files> <path_to_blast_db>
./batch_blastp_analysis.sh ./genomes ./database/colicin_db
Step 2: Bacteriocin Profiling (Python)
Process the raw BLAST outputs to generate statistical summaries and presence/absence matrices for bacteriocin genes.

Bash
# Usage: python bacteriocin_profiler.py --input <blast_results_directory>
python bacteriocin_profiler.py --input blast_results/
Step 3: MDR/XDR Classification (Python)
Classify the isolates based on the diversity of their resistance mechanisms. This step requires:

A gene-to-category mapping file (e.g., resistance.txt format: Gene\tCategory).

An ARG presence/absence matrix (e.g., arg.txt format: #FILE\tGene1\tGene2...).

Bash
# Usage: python classify_mdr.py -r <mapping_file> -a <matrix_file> -o <output_csv>

python classify_mdr.py -r ./data/resistance_mapping.txt -a ./data/arg_matrix.txt -o mdr_summary.csv
Note: The classification criteria used in this study are: MDR (≥3 antimicrobial classes), XDR (≥8 classes), and PDR (≥12 classes).
