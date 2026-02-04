#!/bin/bash
set -euo pipefail

# 输入目录和 BLAST 数据库路径
FAA_DIR="/sdh/backup_home/hty/ST602/faa"
DB="/dell-11T/home/tianyang/Colicin-database/大肠杆菌细菌素/protein_sequences/colicin_blast_db"
THREADS=16

# 检查 BLAST 数据库是否存在
if [ ! -d "$DB" ]; then
  echo "BLAST 数据库路径不存在: $DB"
  exit 1
fi

# 遍历每个 .faa 文件
for faa in "$FAA_DIR"/*.faa; do
  base="$(basename "$faa" .faa)"
  out="${FAA_DIR}/${base}.colicin.tsv"  # 输出结果文件名

  echo "Running: $base"

  # 运行 BLASTp 比对
  blastp -query "$faa" -db "$DB" \
    -evalue 1e-5 -max_target_seqs 5 -max_hsps 1 -seg yes -qcov_hsp_perc 60 -num_threads "$THREADS" \
    -outfmt "6 qseqid sseqid pident qcovhsp length evalue bitscore stitle" \
  | awk -F'\t' -v OFS='\t' -v FILE="$base" \
      'BEGIN {print "FILE","QUERY","HIT","%IDENT","%COV","ALN_LEN","E-VALUE","BITSCORE","PRODUCT"} \
       {print FILE,$1,$2,$3,$4,$5,$6,$7,$8}' \
  > "$out"

  echo "Results saved to: $out"
done

echo "All BLASTp analyses are complete."
