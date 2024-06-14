import openpyxl
import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QPushButton, QFileDialog, QTextEdit

class ExcelProcessorApp(QMainWindow):
    def __init__(self):
        super().__init__()

        self.initUI()

    def initUI(self):
        self.setGeometry(100, 100, 800, 600)
        self.setWindowTitle('Excel Processor')

        self.text_edit = QTextEdit(self)
        self.text_edit.setGeometry(10, 10, 780, 40)

        self.process_button = QPushButton('Process Excel', self)
        self.process_button.setGeometry(10, 500, 150, 40)
        self.process_button.clicked.connect(self.process_excel)

    def process_excel(self):
        file_dialog = QFileDialog()
        file_dialog.setNameFilter("Excel Files (*.xlsx *.xls)")
        file_dialog.setFileMode(QFileDialog.ExistingFiles)

        if file_dialog.exec_():
            file_paths = file_dialog.selectedFiles()
            for file_path in file_paths:
                # 在此处执行处理Excel文件的代码，将处理结果显示在self.text_edit中
                # 您可以使用您之前提到的Excel处理代码

                # 打开Excel文件
                workbook = openpyxl.load_workbook(file_path)

                # 选择要处理的工作表
                sheet = workbook['TestSuite']  # 将 'Sheet1' 替换为您的工作表名称

                # 遍历要处理的单元格范围，假设范围是A1到A10
                for row in sheet.iter_rows(min_row=4, max_row=86, min_col=3, max_col=5):
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
                workbook.save('D:\\xmind2tapd\\modified_excel_file.xlsx')

                # 关闭工作簿
                workbook.close()
                pass

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = ExcelProcessorApp()
    ex.show()
    sys.exit(app.exec_())
