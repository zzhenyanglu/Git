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
from getaway import getaway
from multiprocessing import Process, Pipe


class getawayIn(getaway):


    def __init__(self, sys_name,client_port,exchange_name, exchange_port,debug):

        # port that connects to bookbuilder
        self.client_connect_port = client_port
        # socket used to connect to bookbuilder
        # initiated by getaway class __init__()
        self.client_socket = None

        # see getaway.py method log()
        self.getaway_name = 'GETAWAYIN'

        self.system_name = str.upper(sys_name)
        self.debug = debug

        # call __init__ of parent class
        super(getawayIn,self).__init__(sys_name, exchange_name, exchange_port, 'GETAWAYIN',self.debug)
        self.server_socket.settimeout(10)

        # set up log system
        self.log_file = os.path.join('LOGS',self.system_name,'GETAWAY_IN.log')
        directory = os.path.join('LOGS',self.system_name)

        if not os.path.isdir(directory):
            os.makedirs(directory)

        self.logs = open(self.log_file,'a+')


    def subscribe(self,ticker):

        msg = self.msg_compiler.subscribe(ticker,self.system_name,self.exchange_name,self.sequence_no())
        # this is inherited function from getaway() class
        self.send_to_exchange(msg)
        # call a new process to listen to exchange server
        p = Process(target=self._listen,args=())
        p.start()


    def _listen(self):

        keep_listen = True
        while keep_listen:

            try:
                msg = self.recv_from_exchange()
                msg_type = self.msg_compiler.get_tag_value(msg,35)
            except socket.timeout:
                continue

            # new order
            if msg_type == 'W':
                price = self.msg_compiler.get_tag_value(msg,270)
                volume = self.msg_compiler.get_tag_value(msg,271)
                symbol = self.msg_compiler.get_tag_value(msg,55)
                side = self.msg_compiler.get_tag_value(msg,269)
                self.client_socket.send('A '+symbol+' '+side+' '+price+' '+volume+' 0')
                self.log('Got an full refresh(35=V) message: '+msg)

            # order modified
            elif msg_type == 'X':
                price = self.msg_compiler.get_tag_value(msg,270)
                volume = self.msg_compiler.get_tag_value(msg,271)
                symbol = self.msg_compiler.get_tag_value(msg,55)
                side = self.msg_compiler.get_tag_value(msg,269)
                order_id = self.msg_compiler.get_tag_value(msg,37)
                change_type = self.msg_compiler.get_tag_value(msg,279)

                if change_type =='0':
                    cmd_type ='A '
                elif change_type =='1':
                    cmd_type = 'M '
                else:
                    cmd_type = 'D '

                self.client_socket.send(cmd_type+symbol+' '+side+' '+price+' '+volume +' '+order_id)
                self.log('Got an update(35=X) message: '+msg)

            # cancel order
            elif msg_type =='F':
                symbol = self.msg_compiler.get_tag_value(msg,55)
                order_id = self.msg_compiler.get_tag_value(msg,37)
                self.client_socket.send('D '+symbol+' _ _ _ '+order_id)
                self.log('Got an cancel(35=F) message: '+msg)

            # log out message
            elif msg_type == '5':
                self.log('Successfully log out of exchange')
                # if keep listening to exchange
                keep_listen = False


    # don't use inherited logout because _listen can handle logout message
    # from exchange
    def logout(self):
        # compile a logon message
        # self.sequence_no is inherited function from getaway()
        logout_msg = self.msg_compiler.goodbye(self.system_name,self.exchange_name,self.sequence_no())
        # send LOGOUT message
        self.log("Logout message sent to exchange")
        self.send_to_exchange(logout_msg)
        return False

                                  
