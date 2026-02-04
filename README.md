# Genomic Epidemiology and Bacteriocin Profiling of *E. coli* ST602

This repository contains the custom Bash and Python scripts used for the bioinformatic analysis in the study:
**"Genomic surveillance of blaNDM-5-carrying Escherichia coli ST602 from an integrated duck-egg farming ecosystem in China"** (Submitted, 2026).

## 📂 Repository Contents

* `batch_blastp_analysis.sh`: A Bash script to perform high-throughput BLASTP screening against the bacteriocin database.
* `run_colicin_batch.sh`: A wrapper script to manage batch processing tasks.
* `bacteriocin_profiler.py`: A Python script to parse BLASTP results, calculate bacteriocin prevalence, and analyze co-occurrence patterns.
* `data/`: (Optional) Example datasets.

## 🚀 Usage

### Step 1: BLAST Screening (Bash)
First, screen the genome assemblies (protein FASTA files) against the bacteriocin database.

```bash
# Make the scripts executable
chmod +x batch_blastp_analysis.sh

# Run the pipeline
# Usage: ./batch_blastp_analysis.sh <path_to_faa_files> <path_to_blast_db>
./batch_blastp_analysis.sh ./genomes ./database/colicin_db
