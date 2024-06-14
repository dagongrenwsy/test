import paho.mqtt.client as mqtt
import logging

#配置日志
logging.basicConfig(filename='mqtt.log', filemode='w', format='%(name)s - %(levelname)s - %(message)s', level=logging.INFO)

# 定义回调函数
def on_connect(client, userdata, flags, rc):
    print(f"Connected with result code {rc}")
    # 订阅主题
    client.subscribe("uc/6805E03084010025/uplink")

def on_message(client, userdata, msg):
    try:
        hex_message = msg.payload.hex()
        print(f"'{msg.topic}' : '{hex_message}'")
    except Exception as e:
        print(f"Error processing message: {e}")

def on_publish(client, userdata, mid):
    print(f"Message {mid} published")
    

def on_subscribe(client, userdata, mid, granted_qos):
    print(f"Subscribed to topic, QOS: {granted_qos}")


# 创建MQTT客户端
client = mqtt.Client(client_id="mqtttest")

# 设置回调函数
client.on_connect = on_connect
client.on_message = on_message
client.on_publish = on_publish
client.on_subscribe = on_subscribe

# 配置最大消息大小限制
client.max_inflight_messages_set(200)
client.max_queued_messages_set(200)


# 连接到MQTT代理
client.connect("broker.emqx.io", 1883, 300)

# 发布消息
client.publish("uc/test/up", payload="Hello, MQTT!", qos=0, retain=False)

# 开始阻塞式的网络循环，处理网络流量和回调函数
client.loop_forever()
