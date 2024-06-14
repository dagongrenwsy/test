import serial
import serial.tools.list_ports

class SerialHandler:
    def __init__(self, port, baudrate, timeout=1):
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.ser = None

    def list_serial_ports(self):
        ports = list(serial.tools.list_ports.comports())
        for port in ports:
            print(port)
    
    def open_serial_port(self):
        try:
            self.ser = serial.Serial(self.port, self.baudrate, timeout=self.timeout)
            print(f"Serial port {self.port} opened successfully")
        except serial.SerialException as e:
            print(f"Failed to open serial port {self.port}: {e}")

    def close_serial_port(self):
        if self.ser and self.ser.is_open:
            self.ser.close()
            print(f"Serial port {self.port} closed")

    def write_data(self, data):
        if self.ser and self.ser.is_open:
            try:
                self.ser.write(data.encode('utf-8'))
                print(f"Sent: {data}")
            except serial.SerialTimeoutException:
                print("Write timeout")
            except serial.SerialException as e:
                print(f"Serial error: {e}")

    def read_data(self):
        if self.ser and self.ser.is_open:
            try:
                line = self.ser.readline().decode('utf-8').strip()
                if line:
                    print(f"{line}")
                return line
            except serial.SerialException as e:
                print(f"Serial error: {e}")
                return None

    def check_and_handle_event(self, target_string, event_handler):
        line = self.read_data()
        if line and target_string in line:
            event_handler(line)

# 示例事件处理函数
def handle_event(data):
    print(f"Event triggered! Received data: {data}")