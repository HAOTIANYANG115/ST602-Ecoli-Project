import pandas as pd
import sys

def analyze_colicins(file_path):
    print(f"正在读取文件: {file_path} ...")
    
    try:
        # 读取 TSV 文件 (假设第一列是 Sample ID，后面是细菌素基因，0表示无，1表示有)
        # 如果是 XLSX，请改用 pd.read_excel(file_path)
        df = pd.read_csv(file_path, sep='\t', index_col=0)
        
        # 确保数据是数值型 (0/1)
        df = df.apply(pd.to_numeric, errors='coerce').fillna(0)
        
        # 1. 总体携带率 (Prevalence)
        total_strains = len(df)
        colicin_counts = df.sum(axis=0).sort_values(ascending=False)
        colicin_prevalence = (colicin_counts / total_strains) * 100
        
        # 2. 每个菌株携带的细菌素数量分布 (Burden)
        per_strain_counts = df.sum(axis=1)
        avg_colicins = per_strain_counts.mean()
        max_colicins = per_strain_counts.max()
        
        print("-" * 50)
        print("📊 细菌素 (Colicin) 分析结果概览")
        print("-" * 50)
        print(f"分析菌株总数: {total_strains}")
        print(f"平均每株携带数量: {avg_colicins:.2f}")
        print(f"单株最大携带数量: {max_colicins}")
        print("-" * 50)
        
        print("🏆 Top 10 最常见的细菌素:")
        for gene, count in colicin_counts.head(10).items():
            prev = (count / total_strains) * 100
            print(f"  - {gene}: {count} 株 ({prev:.2f}%)")
            
        print("-" * 50)
        
        # 3. 检查是否有共现性 (简易版)
        # 看看最常见的两个是否经常一起出现
        top_genes = colicin_counts.head(2).index.tolist()
        if len(top_genes) >= 2:
            gene_a, gene_b = top_genes[0], top_genes[1]
            co_occurrence = df[(df[gene_a] > 0) & (df[gene_b] > 0)].shape[0]
            print(f"🔗 共现分析 (Co-occurrence):")
            print(f"  - {gene_a} 和 {gene_b} 同时出现的菌株数: {co_occurrence}")
            
        print("-" * 50)
        print("💡 写作建议:")
        if avg_colicins > 1:
            print("  - ST602 普遍携带多种细菌素，具有很强的生态竞争优势。")
        if 'ColV' in colicin_counts.index or 'cvaC' in colicin_counts.index:
             print("  - 检测到 ColV 相关基因，这与之前的 IncFIB 质粒结果完美呼应！(ColV 质粒通常以此命名)")

    except Exception as e:
        print(f"发生错误: {e}")

# --- 执行部分 ---
# 请根据你的实际文件名修改这里
input_file = "presence_absence.tsv" 
analyze_colicins(input_file)
