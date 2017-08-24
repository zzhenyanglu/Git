import sys
import time
import threading
import datetime
import socket
import json
from datetime import datetime
import os
import select
import time
import simplefix
from fixmessage import FixMessage

class getaway(object):

    def __init__(self,sys_name,exchange_name,exchange_port,getaway_name,debug=True):

        # setting
        self.recv_buffer = 1024
        self.exchange_name = exchange_name
        self.exchange_host = socket.gethostbyname(exchange_name)
        self.exchange_port = exchange_port
        self.system_name = str.upper(sys_name)
        self.msg_compiler = FixMessage()
        self.log_file = "logs.log"
        self.logs = open(self.log_file,'a+')
        # intiate sequence number
        self.sequence_number = 1
        self.getaway_name = getaway_name
        self.debug = debug

        # self.client_socket is whatever the process that
        # connect to getaway as a client and submit info
        # in getawayIN, it's the bookbuilder
        # in getawayOUT, it's the trader
        # see function client_connect below
        self.client_socket = None
        # this function assigns client_socket
        self.accept_client_connect(self.client_connect_port)

        # a client(trader or bookbuilder) must connects first
        # so that there is no information lost.
        if self.client_socket is None:
            self.log("A client must connect to getaway!")
            return

        # server_socket is the exchange's socket
        self.server_socket = socket.socket()
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.connect((self.exchange_host, self.exchange_port))
        self.log("Successfully connected to exchange data socket: "+self.exchange_host+"@"+str(self.exchange_port))

        # log on to exchange
        self.logon()


    def send_to_exchange(self,msg):
        self.server_socket.send(msg)
        self.log("Sent message to exchange: "+msg)


    def recv_from_exchange(self):
        msg = self.server_socket.recv(self.recv_buffer)
        #self.log("Received message from exchange: "+msg)
        return msg

    def log(self,msg):

        self.logs.write(datetime.now().strftime('%Y-%m-%d:%H:%M:%S')+' [GETAWAY]'+msg)
        if self.debug:
            print('['+self.getaway_name+']'+msg)


    # log on to exchange
    def logon(self):
        # compile a logon message
        logon_msg = self.msg_compiler.aloha(self.system_name,self.exchange_name,self.sequence_no())
        # send LOGON message
        self.send_to_exchange(logon_msg)
        # recv LOGON message ack
        msg_back = self.recv_from_exchange()

        if self.msg_compiler.get_tag_value(msg_back,35) == 'A':
            self.log("Sucessfully logon to exchange...")
            return True

        return False


    def logout(self):
        # compile a logon message
        logout_msg = self.msg_compiler.goodbye(self.system_name,self.exchange_name,self.sequence_no())
        # send LOGON message
        self.send_to_exchange(logout_msg)
        # recv LOGON message ack
        msg_back = self.recv_from_exchange()

        if self.msg_compiler.get_tag_value(msg_back,35) == '5':
            self.log("Log out of exchange...")
            return True

        return False

    # this functions listens for client's connection like a server
    # in getawayIN, it's used to send data to bookbuilder
    # in getawayOUT, it's used to receive trader's order
    def accept_client_connect(self, port):
        sock = socket.socket()
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind((socket.gethostname(), port))
        self.log("Waiting for client to connect..")
        sock.listen(1)
        self.client_socket,_ = sock.accept()


    def sequence_no(self):
        self.sequence_number = self.sequence_number +1
        return self.sequence_number-1
                                        
