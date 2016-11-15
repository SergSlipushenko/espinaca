import os
import pty
import serial
import signal
import subprocess
import shlex
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
    if rc != 0:
        print("Connection returned result: %d" % rc)
        sys.exit(1)
    else:
        print("Connected!")

def main():
    p = subprocess.Popen(
        shlex.split('/usr/bin/socat -d -d '
                    'pty,link=/var/tmp/master,raw,echo=0 '
                    'pty,link=/var/tmp/slave,raw,echo=0'),
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    time.sleep(3)
    print('Link on virtual serial: /var/tmp/slave')
    mq = mqtt.Client(client_id='python')
    mq.username_pw_set('node', '1qazse4')

    with serial.Serial('/var/tmp/master', 115200,
                       rtscts=True, dsrdtr=True) as ser:
        r = Router(ser=ser)

        def on_node_stdout(data):
            ser.write(data)
            ser.flush()
            sys.stdout.write(data)
            sys.stdout.flush()

        r.routes['node/stdout'] = on_node_stdout
        mq.on_connect = on_connect
        mq.on_message = r.on_message
        mq.connect('pi.lcl', port=1883)

        def signal_handler(signal, frame):
            print('You pressed Ctrl+C!')
            mq.disconnect()
            p.kill()
            time.sleep(3)
            p.wait()
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
            sys.stdout.write(inp)
            sys.stdout.flush()
            mq.publish('node/stdin', inp)
            if inp == ':q!':
                exit()

main()
