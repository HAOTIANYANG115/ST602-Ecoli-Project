# Genomic Epidemiology and Bacteriocin Profiling of *E. coli* ST602

T## 📂 Repository Contents

* `run_blast_screen.sh`: A Bash script to perform high-throughput BLASTP screening against the bacteriocin database.
* `bacteriocin_profiler.py`: A Python script to parse BLASTP results, calculate bacteriocin prevalence, and analyze co-occurrence patterns.
* `data/`: (Optional) Example datasets.

## 🚀 Usage

### Step 1: BLAST Screening (Bash)
First, screen the genome assemblies (protein FASTA files) against the bacteriocin database.

```bash
# Make the script executable
chmod +x run_blast_screen.sh

# Run the pipeline
# Usage: ./run_blast_screen.sh <path_to_faa_files> <path_to_blast_db>
./run_blast_screen.sh ./genomes ./database/colicin_db
