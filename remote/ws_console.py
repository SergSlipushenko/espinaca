#!/usr/bin/env python
import easyargs
import serial
import signal
import subprocess
import shlex

import websocket
from threading import Thread
import time
import sys


MASTER_PTY = '/var/tmp/master'
SLAVE_PTY = '/var/tmp/slave'


def create_pair(master,slave):
    print 'starting socat'
    p = subprocess.Popen(
        shlex.split('/usr/bin/socat -d -d '
                    'pty,link=%s,raw,echo=0 '
                    'pty,link=%s,raw,echo=0' % (master, slave)),
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    time.sleep(3)
    prev_handler = None

    def signal_handler(sign, frame):
        p.kill()
        time.sleep(3)
        p.wait()
        print 'socat killed'
        if callable(prev_handler):
            prev_handler(sign, frame)
    prev_handler = signal.signal(signal.SIGINT, signal_handler)

    return p


def setup(server, ser_out, ser_in, node):

    shared = {'terminate': False}

    def serial_loop(ws):
        while True:
            try:
                inp = ser_in.readline()
                ser_out.write(inp)
                ser_out.flush()
                if ser_out != sys.stdout:
                    sys.stdout.write(inp)
                    sys.stdout.flush()

            except serial.SerialException as e:
                print(e)
                exit()
            if shared['terminate']:
                exit()
            ws.send(inp)
            if inp == ':q!' or shared['terminate']:
                exit()

    def on_message(ws, message):
        message = message.strip('\n') + '\n' if message.strip() != '>' else message
        ser_out.write(message)
        ser_out.flush()
        if ser_out != sys.stdout:
            sys.stdout.write(message)
            sys.stdout.flush()

    def on_open(ws):
        ws.send('join %s' % node)
        print("Connected!")
        Thread(target=serial_loop, args=(ws,)).start()

    def on_close(ws):
        print("Closed!")
        shared['terminate'] = True

    def on_error(ws, error):
        print(error)

    ws = websocket.WebSocketApp(server,
                                on_open=on_open,
                                on_message=on_message,
                                on_error=on_error,
                                on_close=on_close)
    ws.run_forever()



@easyargs
def main(cli=False, server='pi.lcl', node=''):
    if cli:
        setup(server, sys.stdout, sys.stdin, node)
    else:
        create_pair(MASTER_PTY, SLAVE_PTY)
        print('Link on virtual serial: %s' % SLAVE_PTY)
        with serial.Serial('/var/tmp/master', 115200,
                           rtscts=True, dsrdtr=True) as ser:
            setup(server, ser, ser, node)

main()
