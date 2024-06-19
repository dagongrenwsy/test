import sys
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QPushButton, QVBoxLayout

# 定义主窗口类
class MyApp(QWidget):
    def __init__(self):
        super().__init__()

        # 设置窗口标题
        self.setWindowTitle('My First PyQt App')

        # 设置窗口大小
        self.resize(300, 200)

        # 创建标签和按钮
        self.label = QLabel('Hello, PyQt!', self)
        self.button = QPushButton('Click Me', self)

        # 连接按钮点击事件到方法
        self.button.clicked.connect(self.on_button_click)

        # 设置布局
        layout = QVBoxLayout()
        layout.addWidget(self.label)
        layout.addWidget(self.button)
        self.setLayout(layout)

    # 按钮点击事件处理方法
    def on_button_click(self):
        self.label.setText('Button Clicked!')

# 主程序入口
if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()
    sys.exit(app.exec_())
