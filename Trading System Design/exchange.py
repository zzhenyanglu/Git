import sys
import time
from threading import Thread
import datetime
import socket
import json
from datetime import datetime
import os
import select
from multiprocessing import Process,Pipe,Value,Manager
from fixmessage import FixMessage
from match_engine import match_engine


class Exchange():


    def __init__(self):

        self.recv_buffer = 2048
        self.exchange_name = 'Exchange'
        self.idle_ports = [5551,5552,5553,5554,5561,5562,5563,5564]
        self.exchange_host = socket.gethostname()
        self.market_data_socket = {}
        self.order_socket = {}
        self.market_port =[5551,5552,5553,5554]


        # set up log files
        self.log_file = os.path.join('LOGS','Exchange','Exchange.log')
        directory = os.path.join('LOGS','Exchange')

        if not os.path.isdir(directory):
            os.makedirs(directory)

        self.logs = open(self.log_file,'a+')

        # a match engine that stores the orders received
        self.match_engine = match_engine()

        # submit a seed order so that there is something when
        # a client subscribe
        print("submitting a seed order..")
        self.match_engine.submit_order('MQ',100,5000,'bid','limit','self')
        self.match_engine.submit_order('MQ',101,3800,'bid','limit','self')
        self.subscribe_list = {}
        # shutdown exchange server
        self.shutdown = False

        self.order_id = 100


    def log(self,msg):
        self.logs.write(datetime.now().strftime('%Y-%m-%d:%H:%M:%S')+' [EXCHANGE]'+msg)
        print('[EXCHANGE]'+msg)


    # if market_data_socket true, open all sockets that broadcast
    # market data, if order_socket True, open sockets that
    # receive market order.
    def launch(self,market_data_socket= True,order_socket=False):

        self.broadcast_list = {}
        self.active_process =[]

        if market_data_socket:
            self.process(self.exchange_host,5551,'market_data')
            self.process(self.exchange_host,5552,'market_data')
            self.process(self.exchange_host,5553,'market_data')
            self.process(self.exchange_host,5554,'market_data')

        if order_socket:
            self.process(self.exchange_host,5561,'order')
            self.process(self.exchange_host,5562,'order')
            self.process(self.exchange_host,5563,'order')
            self.process(self.exchange_host,5564,'order')

        # waiting for process to finish
        for p in self.active_process:
            p.join()


    # intiate a new process that handles a socket
    def process(self, host, port,socket_type = 'market_data'):

        if socket_type not in ('market_data','order'):
            print('Valid socket_type: market_data or data')
            return

        elif socket_type == 'market_data':
            p = Thread(target=self.data_connect, args=(host, port,))
            self.active_process.append(p)
            p.start()

        elif socket_type == 'order':
            p = Thread(target=self.order_connect, args=(host, port,))
            self.active_process.append(p)
            p.start()


    # to be connected by a getawayIN
    # reuse is set to True if a previous client log out
    # and the current process and port are to be reused
    # to accept new client
    def data_connect(self, host, port, reuse=False):

        if reuse == False:
            self.log('Data service listening on port '+ str(port))
            sock = socket.socket()
            self.market_data_socket[port]= sock
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR,1)
            sock.bind((host, port))
            sock.listen(1)

        else:
            sock = self.market_data_socket[port]

        client_socket, client_addr = sock.accept()
        self.log('Client connected to market data port: '+ str(client_socket.getpeername()[0])+'@'+str(client_socket.getpeername()[1]))

        # register broadcast socket
        self.broadcast_list[port]=client_socket

        # logon
        if self.logon(client_socket):
            self.request_handle(client_socket)


    def logon(self,client_socket):

        # LOGON initiation(aloha message)
        msg = client_socket.recv(self.recv_buffer)
        # package to compile fix message
        msg_compiler = FixMessage()
        # must receive a logon, otherwise won't start sending data
        if msg_compiler.get_tag_value(msg,35)=='A':

            sender = msg_compiler.get_tag_value(msg,49)
            self.log("received logon message from "+ str(sender)+": "+msg)
            msg_back = msg_compiler.aloha_back(msg)
            self.log("sent logon message back to "+ str(sender)+": "+msg_back)
            client_socket.send(msg_back)
            return True

        return False



    def request_handle(self,client_socket):

        msg_compiler = FixMessage()
        port = client_socket.getpeername()[0]

        while not self.shutdown:

            self.log("Listening for client request..")
            msg = client_socket.recv(self.recv_buffer)
            msg_type =  msg_compiler.get_tag_value(msg,35)

            self.log("received message from "+ str(port)+": "+msg)

            # full refresh upon subscribe
            if msg_type == 'V':

                # subscribe
                ticker = msg_compiler.get_tag_value(msg,55)
                sender = msg_compiler.get_tag_value(msg,49)

                self.subscribe(ticker,sender)
                # query the current market price(highest bid)
                ticker = msg_compiler.get_tag_value(msg,55)
                price,volume = self.match_engine.get_current_price(ticker)
                # current price is set to be highest bid, so side is 'bid'
                msg_back = msg_compiler.full_refresh(msg, price,volume,'bid')
                self.log("sent full refresh message: "+ msg_back)
                client_socket.send(msg_back)

            # new order
            elif msg_type == 'D':
                symb = msg_compiler.get_tag_value(msg,55)
                side = msg_compiler.get_tag_value(msg,54)
                price = msg_compiler.get_tag_value(msg,44)
                vol = msg_compiler.get_tag_value(msg,38)
                order_type = msg_compiler.get_tag_value(msg,40)
                seq_no = int(msg_compiler.get_tag_value(msg,34))+1
                recv = msg_compiler.get_tag_value(msg,49)
                sender = msg_compiler.get_tag_value(msg,56)

                # submit an new order to match engine
                self.match_engine.submit_order(symb,price,vol,side,order_type,sender)
                # compile execution report to the submitted
                msg_execution = msg_compiler.execution_report(msg,vol,'new',self.get_order_id(),symb)
                client_socket.send(msg_execution)
                # info subscribers
                # self,symbol,price,vol,side,seq_no,sender,target,upd_type
                self.broadcast(symb,price,vol,side,seq_no,sender,recv,'new')

            # modify order
            elif msg_type == 'G':
                order_id = msg_compiler.get_tag_value(msg,37)

                if int(order_id) in  self.match_engine.orders.keys():
                    symb = self.match_engine.orders[int(order_id)].ticker
                else:
                    symb = None

                price = msg_compiler.get_tag_value(msg,44)
                vol = msg_compiler.get_tag_value(msg,38)
                order_type = msg_compiler.get_tag_value(msg,40)
                seq_no = int(msg_compiler.get_tag_value(msg,34))+1
                submitter = msg_compiler.get_tag_value(msg,49)
                recv = msg_compiler.get_tag_value(msg,49)
                sender = msg_compiler.get_tag_value(msg,56)
                side = self.match_engine.orders[order_id].side

                self.match_engine.amend_order(order_id,price,vol,order_type)
                msg_execution = msg_compiler.execution_report(msg,vol,'amend',self.get_order_id(),symb)
                client_socket.send(msg_execution)
                # info subscribers
                self.broadcast(symb,price,vol,side,self.get_order_id(),seq_no,sender,recv,'change')

            # cancel order
            elif msg_type == 'F':

                order_id = msg_compiler.get_tag_value(msg,37)

                if int(order_id) in  self.match_engine.orders.keys():
                    symb = self.match_engine.orders[int(order_id)].ticker
                else:
                    symb = None

                submitter = msg_compiler.get_tag_value(msg,49)
                seq_no = int(msg_compiler.get_tag_value(msg,34))+1
                recv = msg_compiler.get_tag_value(msg,49)
                sender = msg_compiler.get_tag_value(msg,56)

                self.match_engine.cancel_order(order_id,submitter)
                msg_execution = msg_compiler.execution_report(msg,'0','cancel',self.get_order_id(),symb)
                client_socket.send(msg_execution)
                # info subscribers
                self.broadcast(symb,'0','0','bid',seq_no,sender,recv,'cancel')

            # log out message
            elif msg_type == '5':
                # unsubscribe the sender
                msg_back = msg_compiler.goodbye_back(msg)
                client_socket.send(msg_back)
                self.unsubscribe(msg_compiler.get_tag_value(msg,49),int(client_socket.getpeername()[1]))
                self.log('Client logged out: '+ str(client_socket.getpeername()[0])+'@'+str(client_socket.getpeername()[1]))

                # port reuse:depends on if it's a market data or order socket
                # data or order connect will be call to accept new clients
                # so after a client log out, the exchange server is able to
                # serve a new client without being relaunch.
                reuse_port = client_socket.getsockname()[1]
                # market data port - 555X
                if str(reuse_port)[2] == '5':
                    self.data_connect(self.exchange_host,reuse_port,reuse=True)
                else:
                    self.order_connect(self.exchange_host,reuse_port,reuse=True)

    # connected by a getawayOUT
    def order_connect(self, host, port,reuse=False):

        if reuse == False:
            self.log('Order service listening on port '+ str(port))
            sock = socket.socket()
            self.order_socket[port]= sock
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind((host, port))
            sock.listen(1)

        # if reuse a socket
        else:
            sock = self.order_socket[port]

        client_socket, client_addr = sock.accept()
        self.log('Client connected: '+ client_addr[0]+"@"+str(client_addr[1]))
        # logon
        if self.logon(client_socket):
            self.request_handle(client_socket)


    # the following three functions work with self.subscribe_list
    def subscribe(self,ticker,subscriber):

        if subscriber in self.subscribe_list.keys():
            self.subscribe_list[subscirber].append(ticker)
        else:
            self.subscribe_list[subscriber] = []


    # if a subsriber subscribed a ticker
    def subscribed(self,ticker,subscriber):
        return ticker in self.subscribe_list[subscriber]


    # call only when log out
    def unsubscribe(self, subscriber,port):
        del(self.subscribe_list[subscriber])
        del(self.broadcast_socket[port])


    def shutdown(self):
        self.shutdown = True


    def get_order_id(self):
        self.order_id = self.order_id +1
        return self.order_id -1


    def broadcast(self,symbol,price,vol,side,seq_no,sender,target,upd_type):

        msg_compiler = FixMessage()
        # compile a market update message to be broadcast
        msg_broadcast = msg_compiler.update(symbol,price,vol,side,self.get_order_id(),seq_no,sender,target,upd_type)

        for port in self.broadcast_list.keys():
            self.log('Broadcast market update to: '+ str(self.broadcast_list[port].getpeername()[0])+'@'+str(self.broadcast_list[port].getpeername()[1])+msg_broadcast)
            self.broadcast_list[port].send(msg_broadcast)

        return




