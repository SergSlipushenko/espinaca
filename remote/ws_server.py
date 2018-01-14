#!/usr/bin/env python

import logging
import logging.handlers

import StringIO
import sys

from SimpleWebSocketServer import WebSocket, SimpleWebSocketServer
import easyargs

rooms = {}
clients = {}

REDIRECT_OUTPUT = True

handler = logging.handlers.SysLogHandler(address='/dev/log')
#handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter('%(filename)s[%(process)d]: %(message)s'))
logger = logging.getLogger('ws_server')
logger.setLevel(logging.INFO)
logger.addHandler(handler)

def _exit(status=0, message=None):
    print(message)
    raise RuntimeError


def _error(message):
    print(message)
    raise RuntimeError


def join_client_room(client, room):
    if room not in rooms:
        rooms[room] = [client]
    else:
        rooms[room].append(client)
    print('_="Joined %s:%s to %s"' % (client.address[0], client.address[1], room))
    clients[client.address] = room


class SimpleChat(WebSocket):

    def handleMessage(self):
        room = clients[self.address]
        if room:
            for client in rooms[room]:
                if client != self:
                    client.sendMessage(self.data)
        else:
            client = self
            @easyargs.decorators.make_easy_args(auto_call=False)
            class Commands(object):
                """A git clone"""

                def list(self):
                    for room in rooms:
                        print(room)

                def join(self, room):
                    join_client_room(client, room)

            parser = Commands()
            line = self.data
            out = StringIO.StringIO()
            if REDIRECT_OUTPUT:
                sys.stdout = out
                sys.stderr = out
            parser.exit = _exit
            parser.error = _error
            for _,sparser in parser._actions[1].choices.items():
                sparser.exit = _exit
                sparser.error = _error
            try:
                args = vars(parser.parse_args(args=line.split()))
                try:
                    function = args.pop('func')
                except KeyError:
                    return
                function(**args)
            except RuntimeError:
                pass
            if REDIRECT_OUTPUT:
                sys.stdout = sys.__stdout__
                sys.stderr = sys.__stderr__
            self.sendMessage(out.getvalue().strip('\n'))

    def handleConnected(self):
        logger.info('%s:%s connected to %s', self.address[0], self.address[1], self.request.path)
        room = self.request.path.strip('/')
        if room:
            if REDIRECT_OUTPUT:
                out = StringIO.StringIO()
                sys.stdout = out
                sys.stderr = out
                join_client_room(self, room)
                sys.stdout = sys.__stdout__
                sys.stderr = sys.__stderr__
                for client in rooms[room]:
                    if client != self:
                        client.sendMessage(out.getvalue().strip('\n'))
            else:
                join_client_room(self, room)
        else:
            clients[self.address] = None

    def handleClose(self):
        room = clients.pop(self.address)
        if room:
            rooms[room].remove(self)
        if not rooms[room]:
            rooms.pop(room)
        logger.info('%s disconnected', self.address)

server = SimpleWebSocketServer('0.0.0.0', 8008, SimpleChat)

try:
    server.serveforever()
except KeyboardInterrupt:
    server.close()
    logger.info('Killed')
