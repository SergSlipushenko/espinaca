import os
import pty
import serial
import signal
import sys
import time

import paho.mqtt.client as mqtt

class Router(object):

    def __init__(self, ser=None):
        self.routes = dict()

    def on_message(self, client, userdata, message):
        if message.topic in self.routes:
            self.routes[message.topic](message.payload)


def on_connect(client, userdata, rc):
    print("Connection returned result: "+str(rc))

def main():
    mq = mqtt.Client(client_id='python')
    mq.username_pw_set('node', '1qazse4')

    with serial.Serial('/dev/pts/26', 115200, rtscts=True,dsrdtr=True) as ser:
        r = Router(ser=ser)

        def on_node_stdout(data):
            ser.write(data)
            ser.flush()

        r.routes['node/stdout'] = on_node_stdout
        mq.on_connect = on_connect
        mq.on_message = r.on_message
        mq.connect('pi.lcl', port=1883)
        def signal_handler(signal, frame):
                print('You pressed Ctrl+C!')
                mq.disconnect()
                sys.exit(0)

        signal.signal(signal.SIGINT, signal_handler)
        mq.loop_start()
        mq.subscribe('node/stdout')
        mq.publish('node/stdin', ' ')
        while True:
            # inp = raw_input()
            inp = ser.readline()
            ser.write(inp)
            ser.flush()
            mq.publish('node/stdin', inp)
            if inp == ':q!':
                exit()

main()
