import pandas as pd

# 文件路径
resistance_file = "/sdh/backup_home/hty/anysis/resistance.txt"
arg_file = "/sdh/backup_home/hty/anysis/arg.txt"

# 读取 resistance 文件
resistance_data = pd.read_csv(resistance_file, sep="\t", header=None, names=["Gene", "Category"])

# 创建耐药基因到抗生素类别的映射字典
gene_to_category = dict(zip(resistance_data["Gene"], resistance_data["Category"]))

# 读取 arg 文件
arg_data = pd.read_csv(arg_file, sep="\t")

# 提取菌株 ID
strain_ids = arg_data["#FILE"]

# 初始化结果
results = []

# 遍历每个菌株，统计耐药基因的类型
for index, row in arg_data.iterrows():
    strain_id = row["#FILE"]
    gene_types = set()  # 使用集合来避免重复类型
    
    # 遍历每一列（基因列）
    for gene, value in row.items():
        if gene == "#FILE":
            continue  # 跳过菌株ID列
        
        # 判断基因是否存在
        if isinstance(value, str) and value != ".":  # 非"."的值表示存在耐药基因
            if gene in gene_to_category:  # 确保基因在字典中
                gene_types.add(gene_to_category[gene])
    
    # 统计菌株的耐药基因类型数
    num_types = len(gene_types)
    
    # 判断是否为MDR/XDR/PDR
    if num_types >= 12:
        resistance_type = "PDR"
    elif num_types >= 8:
        resistance_type = "XDR"
    elif num_types >= 3:
        resistance_type = "MDR"
    else:
        resistance_type = "Non-MDR"
    
    # 保存结果
    results.append({"Strain": strain_id, "Num_Types": num_types, "Resistance_Type": resistance_type})

# 转换结果为 DataFrame
results_df = pd.DataFrame(results)

# 保存结果到文件
output_file = "/sdh/backup_home/hty/anysis/multidrug_resistance_summary.csv"
results_df.to_csv(output_file, index=False)

print(f"结果已保存到 {output_file}")
