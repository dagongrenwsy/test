import pandas as pd
import json

# 读取Excel文件
excel_data = pd.read_excel('your_excel_file.xlsx')

# 将Excel数据转换为字典列表
data = []
for index, row in excel_data.iterrows():
    data.append(dict(row))

# 将字典列表转换为JSON字符串
json_data = json.dumps(data)

# 可选择保存为JSON文件
with open('output.json', 'w') as f:
    f.write(json_data)