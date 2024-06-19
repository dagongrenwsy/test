# python 3.x

import logging
import random
import time
import schedule

from paho.mqtt import client as mqtt_client

BROKER = 'a385rrmxek726j-ats.iot.us-west-2.amazonaws.com'
PORT = 8883
TOPICS_UP = ["uc/6805E03194600021/uplink", "uc/6805E03965640028/uplink"]
TOPICS_DOWN = ["uc/6805E03194600021/downlink", "uc/6805E03965640028/downlink"]
# generate client ID with pub prefix randomly
CLIENT_ID = f'msmqtt-client-{random.randint(0, 1000)}'
USERNAME = 'emqx'
PASSWORD = 'public'
CA_CERTS = 'D:\\share\\AWS证书\\aws-ca.crt'
CERTFILE = 'D:\\share\\AWS证书\\aws-client.crt'
KEYFILE = 'D:\\share\\AWS证书\\aws-key.key'

FIRST_RECONNECT_DELAY = 1
RECONNECT_RATE = 2
MAX_RECONNECT_COUNT = 12
MAX_RECONNECT_DELAY = 60

FLAG_EXIT = False

# 连接成功回调
def on_connect(client, userdata, flags, rc):
    if rc == 0 and client.is_connected():
        logging.info(f'Connected to MQTT Broker `{BROKER}`!')
            # 订阅所有上行数据的主题
        for topic in TOPICS_UP:
            client.subscribe(topic)
            logging.info(f'Subscribe to `{topic}` successfully')
    else:
        print(f'Failed to connect, return code {rc}')
        logging.error(f'Failed to connect, return code {rc}')

# 断开连接回调
def on_disconnect(client, userdata, rc):
    logging.info("Disconnected with result code: %s", rc)
    reconnect_count, reconnect_delay = 0, FIRST_RECONNECT_DELAY
    while reconnect_count < MAX_RECONNECT_COUNT:
        logging.info("Reconnecting in %d seconds...", reconnect_delay)
        time.sleep(reconnect_delay)

        try:
            client.reconnect()
            logging.info("Reconnected successfully!")
            return
        except Exception as err:
            logging.error("%s. Reconnect failed. Retrying...", err)

        reconnect_delay *= RECONNECT_RATE
        reconnect_delay = min(reconnect_delay, MAX_RECONNECT_DELAY)
        reconnect_count += 1
    logging.info("Reconnect failed after %s attempts. Exiting...", reconnect_count)
    global FLAG_EXIT
    FLAG_EXIT = True

# 消息到达回调
def on_message(client, userdata, msg):
    print(f'Received `{msg.payload.hex()}` from `{msg.topic}` topic')
    logging.info(f'Received `{msg.payload.hex()}` from `{msg.topic}` topic')


def connect_mqtt():
    client = mqtt_client.Client(CLIENT_ID)
    client.tls_set(ca_certs=CA_CERTS, certfile=CERTFILE, keyfile=KEYFILE)
    client.username_pw_set(USERNAME, PASSWORD)
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(BROKER, PORT, keepalive=120)
    client.on_disconnect = on_disconnect
    return client

# 定时发送下行数据
def publish_downlink_data(client):
    downlink_data  = "FF1DA1023C0000"  # 这里填写你需要发送的字符串数据
    try:
            binary_data = bytes.fromhex(downlink_data)
            for topic in TOPICS_DOWN:
                client.publish(topic, binary_data)
                logging.info(f"Published downlink data: `{downlink_data}` to `{topic}`")
    except Exception as e:
        logging.info(f"Error encoding data: {e}")

def run():
    logging.basicConfig(filename='./../../mqtt.log', format='[%(asctime)s] - %(levelname)s: %(message)s',
                        level=logging.DEBUG)
    client = connect_mqtt()
    client.loop_start()

    try:
        while True:
            # 定时发布下行数据
            time.sleep(120)
            publish_downlink_data(client)
    except KeyboardInterrupt:
        print("Exiting...")
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == '__main__':
    run()