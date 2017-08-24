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
import sqlite3


class getawayOut(getaway):

    def __init__(self,sys_name,database,client_port,exchange_name,exchange_port,debug=True):

        # port that connects by trader
        self.client_connect_port = client_port
        # socket used tmjno connect to bookbuilder
        # initiated by getaway class __init__()
        self.client_socket = None
        self.getaway_name = 'GETAWAYOUT'
        self.system_name = str.upper(sys_name)
        self.debug = debug

        # call __init__ of parent class
        super(getawayOut,self).__init__(self.system_name, exchange_name, exchange_port,self.getaway_name,self.debug)
        # set up log system
        self.log_file = os.path.join('LOGS',self.system_name,'GETAWAY_OUT.log')
        directory = os.path.join('LOGS',self.system_name)

        if not os.path.isdir(directory):
            os.makedirs(directory)

        self.logs = open(self.log_file,'a+')
        self.client_socket.settimeout(10)

        # set up database to record orders
        self.database = database
        self.table = 'orderbook'
        self.database_connect = sqlite3.connect(self.database)


    def handle_client(self):

        self.log("Listening for client request..")
        keep_listen= True
        C = self.database_connect.cursor()

        while keep_listen:
            try:
                # listen for trader's order
                msg = self.client_socket.recv(self.recv_buffer)
                # A MMM BID 169.11 10.0 1
                msg_type,symbol,side,price,vol,order_type,order_id = msg.split(" ")
            except socket.timeout:
                continue

            self.log("Message received: "+msg)
            # new order
            if msg_type == 'A':

                # logs message received
                self.log('Got an new-order message: '+msg)
                msg_to_exchange = self.msg_compiler.new_order(symbol, price,vol, order_type, side, self.system_name, self.exchange_name,self.sequence_no())
                self.send_to_exchange(msg_to_exchange)
                msg_back = self.recv_from_exchange()

                if self.msg_compiler.get_tag_value(msg_back,35) =='8':
                    order_id =self.msg_compiler.get_tag_value(msg_back,37)
                    # record order status in market.orderbook SQL table
                    C.execute('insert into '+ self.table +' values(\''+self.system_name+'\',\''+datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')+\
                          '\',\''+ symbol +'\','+vol+','+ price +',\''+side+'\',\''+order_type+'\',\''+self.exchange_name+'\','+order_id+')')
                    self.database_connect.commit()
                    # send to trader the order ID
                    self.client_socket.send("Order ID: "+order_id)

            # order modified
            elif msg_type == 'M':
                self.log('Got an update-order message: '+msg)

                msg_to_exchange = self.msg_compiler.amend_order(order_id,price,vol,order_type,self.system_name,self.exchange_name,self.sequence_no)
                self.send_to_exchange(msg_to_exchange)
                msg_back = self.recv_from_exchange()

                if self.msg_compiler.get_tag_value(msg_back,35) =='8':

                    order_id = self.msg_compiler.get_tag_value(msg_from_exchange,34)
                    # record order status in market.orderbook SQL table
                    C.execute('update '+ self.table +' set submitter =\''+self.system_name+'\' where order_id = '+order_id)
                    C.execute('update '+ self.table +' set update_time =\''+datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')+'\' where order_id = '+order_id)
                    C.execute('update '+ self.table +' set volumn=\''+vol+'\' where order_id = '+order_id)
                    C.execute('update '+ self.table +' set price=\''+price+'\' where order_id = '+order_id)
                    C.execute('update '+ self.table +' set side=\''+side+'\' where order_id = '+order_id)
                    C.execute('update '+ self.table +' set order_type=\''+order_type+'\' where order_id = '+order_id)
                    self.database_connect.commit()

                    # send to trader the order ID
                    self.client_socket.send("Order confirmed")

            # cancel order
            elif msg_type =='C':
                self.log('Got an cancel-order message: '+msg)
                msg_to_exchange = self.msg_compiler.cancel_order(order_id,self.system_name,self.exchange_name,self.sequence_no())
                self.send_to_exchange(msg_to_exchange)
                msg_back = self.recv_from_exchange()

                if self.msg_compiler.get_tag_value(msg_back,35) =='8':
                    C.execute('delete from '+ self.table + ' where order_id = '+order_id)
                    self.client_socket.send("Order cancelled")
            else:
                self.log('Unrecogized message from trader: '+msg)
                continue


    # shut down getawayOut
    def shutdown(self):
        # compile a logon message
        # self.sequence_no is inherited function from getaway()
        logout_msg = self.msg_compiler.goodbye(self.system_name,self.exchange_name,self.sequence_no())
        # send LOGOUT message
        self.log("Logout message sent to exchange")
        self.send_to_exchange(logout_msg)
        return False
