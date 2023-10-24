import os

file_path = input("请输入文件路径：")
directory = os.path.dirname(file_path)
out_file_path = os.path.join(directory, 'modified_excel_file.xlsx')
print(file_path)
print(directory)
print("修改后的文件路径：" + out_file_path)