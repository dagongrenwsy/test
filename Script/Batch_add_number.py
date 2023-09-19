import openpyxl

s_min_row = (int)(input("请输入起始行数："))
s_max_row = (int)(input("请输入结束行数："))
s_min_col = (int)(input("请输入起始列数："))
s_max_col = (int)(input("请输入结束列数："))
file_path = input("请输入Excel文件路径：")
print(file_path)

# 打开Excel文件
workbook = openpyxl.load_workbook(file_path)

# 选择要处理的工作表
sheet = workbook['TestSuite']  # 将 'Sheet1' 替换为您的工作表名称

# 遍历要处理的单元格范围，假设范围是A1到A10
for row in sheet.iter_rows(min_row=s_min_row, max_row=s_max_row, min_col=s_min_col, max_col=s_max_col):
    for cell in row:
        # 获取当前单元格的值
        cell_value = cell.value

        # 将多行内容拆分成行，并添加序号
        if cell_value:
            lines = cell_value.split('\n')
            numbered_lines = [f"{i + 1}: {line}" for i, line in enumerate(lines)]
            new_cell_value = '\n'.join(numbered_lines)
            cell.value = new_cell_value

# 保存修改后的Excel文件
workbook.save('.\\modified_excel_file.xlsx')

# 关闭工作簿
workbook.close()
