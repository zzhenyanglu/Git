import sys
import time
import threading
import datetime
import socket
import json
from datetime import datetime
import os
import select
from multiprocessing import Process,Pipe
from fixmessage import FixMessage
from match_engine import match_engine
import sqlite3


# bookbuilder is nothing more than a API that gets market data from
# getawayIN and put it into a database.
# Trader will query the database directly to read in market data.
# So there is no need for bookbuilder to connect with trader

class bookbuilder():
    # if you don't specify a host that the getawayIN server runs on
    # it will pick the current machine as the host
    def __init__(self, system_name, database, server_port, getawayIN_host=None, debug=True):

        self.server_port = server_port
        # set up log files system
        self.system_name = str.upper(system_name)
        self.debug = debug

        # set up log file system
        self.log_file = os.path.join('LOGS',self.system_name,'BOOKBUILDER.log')
        directory = os.path.join('LOGS',self.system_name)

        if not os.path.isdir(directory):
            os.makedirs(directory)

        self.logs = open(self.log_file,'a+')
        
        # set up book database
        self.database = database
        self.table = 'marketbook'
        self.lock = threading.Lock()

        # if there is no market database, then setup one
        if not os.path.isfile(self.database):
            os.system('python database_setup.py '+self.database)

        time.sleep(1)

        # connect to getawayIN
        # self.server_host is the getawayIN's hostname
        if getawayIN_host is None:
            self.server_host = socket.gethostname()
        else:
            self.server_host = getawayIN_host

        # port number that getawayIN listen for bookbuilder
        self.server_socket = None
        self.recv_buffer = 1024

        # connect to getawayIN
        self.connect_getaway()
        self.build_book()


    def connect_getaway(self):

        # connect to getawayIN
        self.server_socket = socket.socket()
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.connect((self.server_host, self.server_port))
        self.log('Connected to getawayIN server: '+self.server_socket.getpeername()[0]+'@'+str(self.server_socket.getpeername()[1]))


   def build_book(self):

        self.stop_build = False
        with sqlite3.connect(self.database) as database_connect:

            C = database_connect.cursor()
            while not self.stop_build:

                try:
                    msg = self.server_socket.recv(self.recv_buffer)

                    if msg is None:
                        return

                    self.log("Received message from getawayIN: " + msg)
                    # parse command here
                    cmd,symbol,side,price,vol,order_id = msg.split(" ")

                except:
                    continue

                # just in case
                if cmd == 'CLEAR':
                    C.execute('delete from '+self.table+' where symbol = \''+symbol+'\'')
                    database_connect.commit()
                # new order
                elif cmd == 'A':
                    C.execute('insert into '+ self.table +' values(\''+symbol+'\',\''+datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')+\
                              '\',\''+ symbol +'\','+vol+','+ price +',\''+side+'\',\''+'exchange'+'\')')
                    database_connect.commit()
                # order modified
                elif cmd == 'M':
                    #update volume
                    C.execute('update '+self.table +' set volumn = '+ vol + ' where symbol = \''+\
                              symbol + '\' and order_type = \''+side+'\' and update_time = (select max(update_time)'+\
                           ' from marketbook where symbol = \''+symbol+'\' and order_type = \'' +side+ '\''+ ' and venue = \''+'exchange' +'\')')
                    # update price
                    C.execute('update '+self.table+' set price= ' +price + ' where symbol = \''+\
                             symbol + '\' and order_type = \''+side+'\' and update_time = (select max(update_time)'+\
                          ' from marketbook where symbol = \''+symbol+'\' and order_type = \'' +side+ '\''+ ' and venue = \''+'exchange' +'\')')
                    # update update_time
                    C.execute('update '+self.table+' set update_time = \'' +datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f') + \
                            '\' where symbol = \''+ symbol + '\' and order_type = \''+side+'\' and update_time = (select max(update_time)'+\
                             ' from marketbook where symbol = \''+symbol+'\' and order_type = \'' +side+ '\''+ ' and venue = \''+'exchange' +'\')')
                    database_connect.commit()
                # order cancel
                elif cmd == 'D':
                    # to sync up with biewer

                    for try_times in range(0,10):
                        try:
                            C.execute('delete from '+self.table+' where symbol = \''+symbol + '\' and order_type = \''+side+'\' and venue = \''+'exchange' +\
                             '\' and update_time = (select max(update_time) from marketbook where symbol = \''+symbol\
                              +'\' and order_type = \'' +side+ '\''+ ' and venue =\'' + 'exchange' +'\')')

                            database_connect.commit()
                        except :
                            continue
                else:
                    self.log("Commmand unknown: " + msg+"\n")
                    return

    def shutdown(self):
        self.stop_build = True


    def log(self,msg):
        self.logs.write(datetime.now().strftime('%Y-%m-%d:%H:%M:%S')+' [BOOKBUILDER]'+msg)
        if self.debug:
           print('[BOOKBUILDER]'+msg)


                                                                      
