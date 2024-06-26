import openpyxl
import os

file_path  = input("请输入Excel文件路径：")
work_sheet = input("请输入处理的工作表：")
s_min_row  = (int)(input("请输入起始行数："))
s_max_row  = (int)(input("请输入结束行数："))
s_min_col  = (int)(input("请输入起始列数："))
s_max_col  = (int)(input("请输入结束列数："))

directory = os.path.dirname(file_path)
out_file_path = os.path.join(directory, 'modified_excel_file.xlsx')
# print(file_path)

# 打开Excel文件
workbook = openpyxl.load_workbook(file_path)

# 选择要处理的工作表
sheet = workbook[work_sheet]

# 遍历要处理的单元格范围，假设范围是A1到A10
for row in sheet.iter_rows(min_row=s_min_row, max_row=s_max_row, min_col=s_min_col, max_col=s_max_col):
    for cell in row:
        # 获取当前单元格的值
        cell_value = cell.value

        # 将多行内容拆分成行，并添加序号
        if cell_value:
            lines = cell_value.split('\n')
            numbered_lines = [f"{i + 1}. {line}" for i, line in enumerate(lines)]
            new_cell_value = '\n'.join(numbered_lines)
            cell.value = new_cell_value

# 保存修改后的Excel文件
workbook.save(out_file_path)
print("修改后的文件路径：" + out_file_path)

# 关闭工作簿
workbook.close()
