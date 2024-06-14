import logging
import logging.config
import serial
import serial.tools.list_ports
from datetime import datetime

log_file_check = datetime.now().strftime('%Y-%m-%d') + '_check' + '.log'
log_file_serial = datetime.now().strftime('%Y-%m-%d') + '_serial' + '.log'

class Logger:
    def __init__(self, config=None, name='app_logger', log_file='app_logger.log'):
        if config:
            logging.config.dictConfig(config)
            self.logger = logging.getLogger(name)
        else:
            self.logger = logging.getLogger(name)
            self.logger.setLevel(logging.DEBUG)

            # 创建一个文件处理器
            fh = logging.FileHandler(log_file)
            fh.setLevel(logging.DEBUG)

            # 创建一个控制台处理器
            ch = logging.StreamHandler()
            ch.setLevel(logging.DEBUG)

            # 创建一个格式器并将其添加到处理器
            #formatter = logging.Formatter('[%(asctime)s] - %(name)s - %(levelname)s - %(message)s')
            formatter = logging.Formatter('[%(asctime)s]%(message)s')
            fh.setFormatter(formatter)
            ch.setFormatter(formatter)

            # 将处理器添加到日志器
            self.logger.addHandler(fh)
            self.logger.addHandler(ch)

    def get_logger(self):
        return self.logger

# 初始化日志
logger_check = Logger(name='check', log_file=log_file_check).get_logger()
logger_serial = Logger(name='serial', log_file=log_file_serial).get_logger()

class SerialHandler:
    def __init__(self, port, baudrate, timeout=1):
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.ser = None

    def list_serial_ports(self):
        ports = list(serial.tools.list_ports.comports())
        for port in ports:
            logger_check.debug(port)
    
    def open_serial_port(self):
        try:
            self.ser = serial.Serial(self.port, self.baudrate, timeout=self.timeout)
            logger_check.info(f"Serial port {self.port} opened successfully")
        except serial.SerialException as e:
            logger_check.error(f"Failed to open serial port {self.port}: {e}")

    def close_serial_port(self):
        if self.ser and self.ser.is_open:
            self.ser.close()
            logger_check.info(f"Serial port {self.port} closed")

    def write_data(self, data):
        if self.ser and self.ser.is_open:
            try:
                self.ser.write(data.encode('utf-8'))
                logger_check.info(f"Sent: {data}")
            except serial.SerialTimeoutException:
                logger_check.error("Write timeout")
            except serial.SerialException as e:
                logger_check.error(f"Serial error: {e}")

    def read_data(self):
        if self.ser and self.ser.is_open:
            try:
                line = self.ser.readline().decode('utf-8').strip()
                if line:
                    logger_serial.info(f"{line}")
                return line
            except serial.SerialException as e:
                logger_check.error(f"Serial error: {e}")
                return None

    def check_and_handle_events(self, target_strings_and_handlers):
        line = self.read_data()
        if line:
            for target_string, handler in target_strings_and_handlers.items():
                if target_string in line:
                    handler(line)




# 示例事件处理函数
def handle_event(data):
    logger_check.info(f"Event triggered! Received data: {data}")

# 示例主程序
def main():
    # 创建SerialHandler实例
    serial_handler = SerialHandler(port='COM11', baudrate=115200, timeout=1)
    
    # 列出所有可用的串口
    serial_handler.list_serial_ports()
    
    # 打开串口
    serial_handler.open_serial_port()

    # 定义要检查的字符串和对应的事件处理函数
    target_strings_and_handlers = {
        'recv error format data': handle_event,
        'cellular device wait response timeout': handle_event,
        
        # 可以添加更多的字符串和对应的处理函数
    }
    
    try:
        while True:
            # 检查并处理特定字符串事件
            serial_handler.check_and_handle_events(target_strings_and_handlers)
    
    except KeyboardInterrupt:
        logger_check.info("Closing serial port")
    
    finally:
        serial_handler.close_serial_port()

if __name__ == "__main__":
    main()
