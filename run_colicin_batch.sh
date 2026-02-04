#!/bin/bash
set -euo pipefail

# 1) 输入：620个faa所在目录
FAA_DIR="/sdh/backup_home/hty/ST602/faa"

# 2) 你的自建细菌素蛋白BLAST库（前缀）
DB="/dell-11T/home/tianyang/Colicin-database/大肠杆菌细菌素/protein_sequences/colicin_tagdb"

# 3) 输出目录
OUTDIR="/sdh/backup_home/hty/ST602/colicin_scan_out"

# 4) 线程数（按机器改）
THREADS=16

mkdir -p "$OUTDIR/per_sample"

echo "[1/2] blastp 批量扫描开始..."
for faa in "$FAA_DIR"/*.faa; do
  base="$(basename "$faa" .faa)"
  out="$OUTDIR/per_sample/${base}.colicin.tsv"

  blastp -query "$faa" -db "$DB" \
    -evalue 1e-5 -max_target_seqs 5 -max_hsps 1 -seg yes -qcov_hsp_perc 60 -num_threads "$THREADS" \
    -outfmt "6 qseqid sseqid pident qcovhsp length evalue bitscore stitle" \
  | awk -F'\t' -v OFS='\t' -v FILE="$(basename "$faa")" \
      'BEGIN{print "FILE","QUERY","HIT","%IDENT","%COV","ALN_LEN","E-VALUE","BITSCORE","PRODUCT"} \
       {print FILE,$1,$2,$3,$4,$5,$6,$7,$8}' \
  > "$out"
done

echo "[2/2] 汇总为Excel（明细 + summary + presence/absence）..."

python3 - <<'PY'
import glob, os, re
import pandas as pd

outdir = "/sdh/backup_home/hty/ST602/colicin_scan_out"
files = sorted(glob.glob(os.path.join(outdir, "per_sample", "*.colicin.tsv")))

all_rows = []
for fp in files:
    df = pd.read_csv(fp, sep="\t")
    if df.shape[0] == 0:
        continue
    # 去掉可能重复的完全相同行
    df = df.drop_duplicates()
    all_rows.append(df)

# 1) 全部命中明细（long）
if all_rows:
    hits_long = pd.concat(all_rows, ignore_index=True)
else:
    hits_long = pd.DataFrame(columns=["FILE","QUERY","HIT","%IDENT","%COV","ALN_LEN","E-VALUE","BITSCORE","PRODUCT"])

# 2) summary（类似 abricate --summary）
# immunity 判定：PRODUCT里包含 immunity（不区分大小写）
def is_immunity(x: str) -> bool:
    return bool(re.search(r"immunity", str(x), flags=re.I))

summary_rows = []
for fp in files:
    sample = os.path.basename(fp).replace(".colicin.tsv","")
    df = pd.read_csv(fp, sep="\t")
    df = df.drop_duplicates()
    if df.shape[0] == 0:
        summary_rows.append({
            "SAMPLE": sample,
            "TOTAL_HITS": 0,
            "IMMUNITY_HITS": 0,
            "TOXIN_HITS": 0,
            "UNIQUE_DB_HITS": 0,
            "DB_HITS_LIST": ""
        })
        continue

    imm = df["PRODUCT"].apply(is_immunity)
    total = int(df.shape[0])
    imm_n = int(imm.sum())
    tox_n = int((~imm).sum())
    uniq_db = int(df["HIT"].nunique())
    db_list = ";".join(sorted(df["HIT"].unique()))

    summary_rows.append({
        "SAMPLE": sample,
        "TOTAL_HITS": total,
        "IMMUNITY_HITS": imm_n,
        "TOXIN_HITS": tox_n,
        "UNIQUE_DB_HITS": uniq_db,
        "DB_HITS_LIST": db_list
    })

summary = pd.DataFrame(summary_rows)

# 3) presence/absence 矩阵（按 HIT 列）
# 列数量不大（你库45条左右），适合放Excel
all_db = sorted(set(hits_long["HIT"].unique()))
pa = pd.DataFrame({"SAMPLE": [os.path.basename(fp).replace(".colicin.tsv","") for fp in files]})
pa = pa.set_index("SAMPLE")
for dbhit in all_db:
    pa[dbhit] = 0

for fp in files:
    sample = os.path.basename(fp).replace(".colicin.tsv","")
    df = pd.read_csv(fp, sep="\t")
    if df.shape[0] == 0:
        continue
    for dbhit in set(df["HIT"].tolist()):
        pa.loc[sample, dbhit] = 1

pa = pa.reset_index()

# 输出：TSV + Excel
hits_long_tsv = os.path.join(outdir, "all_hits.long.tsv")
summary_tsv   = os.path.join(outdir, "abricate_like.summary.tsv")
pa_tsv        = os.path.join(outdir, "presence_absence.tsv")

hits_long.to_csv(hits_long_tsv, sep="\t", index=False)
summary.to_csv(summary_tsv, sep="\t", index=False)
pa.to_csv(pa_tsv, sep="\t", index=False)

xlsx = os.path.join(outdir, "colicin_scan_results.xlsx")
with pd.ExcelWriter(xlsx, engine="openpyxl") as w:
    hits_long.to_excel(w, sheet_name="hits_long", index=False)
    summary.to_excel(w, sheet_name="summary", index=False)
    pa.to_excel(w, sheet_name="presence_absence", index=False)

print("DONE")
print("Excel:", xlsx)
print("TSV  :", hits_long_tsv, summary_tsv, pa_tsv)
PY

echo "完成：结果在 $OUTDIR 下（colicin_scan_results.xlsx + 3个tsv）"
