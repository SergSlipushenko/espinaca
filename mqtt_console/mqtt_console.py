#!/usr/bin/env python
import easyargs
import serial
import signal
import subprocess
import shlex
import sys
import time
import uuid

import paho.mqtt.client as mqtt

MASTER_PTY = '/var/tmp/master'
SLAVE_PTY = '/var/tmp/slave'


def create_pair(master,slave):
    p = subprocess.Popen(
        shlex.split('/usr/bin/socat -d -d '
                    'pty,link=%s,raw,echo=0 '
                    'pty,link=%s,raw,echo=0' % (master, slave)),
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    time.sleep(3)

    def signal_handler(sign, frame):
        p.kill()
        time.sleep(3)
        p.wait()
        print 'socat killed'
        prev_handler(sign, frame)
    prev_handler = signal.signal(signal.SIGINT, signal_handler)

    return p


class Router(object):

    def __init__(self):
        self.routes = dict()

    def on_message(self, client, userdata, message):
        if message.topic in self.routes:
            self.routes[message.topic](message.payload)


def on_connect(client, userdata, flags, rc):
    if rc != 0:
        print("Connection returned result: %d" % rc)
        sys.exit(1)
    else:
        print("Connected!")


def setup(server, port, user, passwd, node, ser_out, ser_in):
    router = Router()
    mq = mqtt.Client(client_id='mq_console_%s' % uuid.uuid4().hex[:8])
    mq.username_pw_set(user, passwd)

    def on_node_stdout(data):
        ser_out.write(data)
        ser_out.flush()
        if ser_out != sys.stdout:
            sys.stdout.write(data)
            sys.stdout.flush()

    router.routes['node/%s/stdout' % node] = on_node_stdout
    mq.on_connect = on_connect
    mq.on_message = router.on_message
    mq.connect(server, port=port)

    def signal_handler(sign, frame):
        mq.disconnect()
        print 'MQTT disconnected'
        prev_handler(sign, frame)
    prev_handler = signal.signal(signal.SIGINT, signal_handler)

    signal.signal(signal.SIGINT, signal_handler)
    mq.loop_start()
    mq.subscribe('node/%s/stdout' % node)
    mq.publish('node/%s/stdin' % node, ' ')
    while True:
        # inp = raw_input()
        inp = ser_in.readline()
        # inp = inp.strip('\n')
        if ser_out != sys.stdout:
            sys.stdout.write(inp)
            sys.stdout.flush()
        mq.publish('node/%s/stdin' % node, inp)
        if inp == ':q!':
            exit()


@easyargs
def main(cli=False, server='pi', port=1883, user='user', passwd='passwd',
         node='NODE-XXX'):
    if cli:
        setup(server, port, user, passwd, node, sys.stdout, sys.stdin)
    else:
        create_pair(MASTER_PTY, SLAVE_PTY)
        print('Link on virtual serial: %s' % SLAVE_PTY)
        with serial.Serial('/var/tmp/master', 115200,
                           rtscts=True, dsrdtr=True) as ser:
            setup(server, port, user, passwd, node, ser, ser)

main()
