import serial.tools.list_ports

def get_serial_ports():
    ports = serial.tools.list_ports.comports()
    port_mappings = []

    for port in ports:
        port_info = {
            "device": port.device,          # This is the path to the serial port
            "name": port.name,
            "description": port.description,
            "hwid": port.hwid,
            "vid": port.vid,
            "pid": port.pid,
            "serial_number": port.serial_number,
            "location": port.location,
            "manufacturer": port.manufacturer,
            "product": port.product,
            "interface": port.interface
        }
        port_mappings.append(port_info)

    return port_mappings

if __name__ == "__main__":
    port_mappings = get_serial_ports()
    for port_info in port_mappings:
        print(f"Device Path: {port_info['device']}")
        print(f"  Name: {port_info['name']}")
        print(f"  Description: {port_info['description']}")
        print(f"  HWID: {port_info['hwid']}")
        print(f"  VID: {port_info['vid']}")
        print(f"  PID: {port_info['pid']}")
        print(f"  Serial Number: {port_info['serial_number']}")
        print(f"  Location: {port_info['location']}")
        print(f"  Manufacturer: {port_info['manufacturer']}")
        print(f"  Product: {port_info['product']}")
        print(f"  Interface: {port_info['interface']}")
        print("\n")
