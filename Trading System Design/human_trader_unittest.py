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
# packages related to this homework
from exchange import Exchange
from getawayIn import getawayIn
from bookbuilder import bookbuilder
from trader import trader
from getawayOut import getawayOut

#-------------------------------------
# THIS UNIT TEST DOES THE FOLLOWING:
#  1. launch 3 trading systems, each
#     system consists of getawayIn,
#     getawayOut, bookbuilder and a
#     robot trader
#-------------------------------------


# NOTICE: since every part of this homework is an scalable and indepedent piece of the whole
#         system, and they need to communicate with each other via sockets, ideally each part
#         sould be run on a single machine. To make it easier to test the trading system, I'm
#         putting getawayIn, bookbuilder, trader and getawayOut together in one single unit
#         test using many processes, each of which is handling a single part(etc getawayIn,
#         bookbuilder..), good thing about this is that you don't have to launch so many putty
#         bad thing is that it's kind of hard to eye ball each message. To mitigate this, I
#         also created log files for each piece of the trading system at LOGS folder


# To modify and cancel order, you have to remember order number given by exchange!

subscribe_symbol = 'MQ' # subscribe a currency pair
system_name = 'human_trader' # system's name, used for logging system
database = 'market_human.db' # database to store market data and order submitted
exchange_name = socket.gethostname() # host name of the machine that exchange runs on
book_port = 6355        # internal socket between bookbuilder and getawayIN
order_port = 6356       # internal socket between trader and getawayOUT
exchange_data_port = 5554 # exchange port to broadcast market data
exchange_order_port = 5564 # exchange port to receive order
robot_trader_style = 'conservative' # robot trader's style,not used for human trader
robot_trader_strategy = 'spread'  # robot trader's strategy, not used for human trader
is_robot_trader = False   # this is a robot trader, who submit random orders according to style and strategy
trade_interval = 1  # sleep time between each trade
debug = False  # if True prints out communication details to screen, useful for debug


# this function initiate the whole trading system from getawayIn to getawayOut
# with 4 independent processes
def trading_system(subscribe_symbol, system_name, database, exchange_name, book_port, order_port, exchange_data_port, exchange_order_port, robot_trader_style, robot_trader_strategy, is_robot_trader,trade_interval,debug):

    print("\nNOTICE: To modify or cancel order, you have to remember order number submitted!")
    print("           Submit an order and remember its order number!\n")
    if not debug:
        print("NOTICE: No debug messages printed to screen, see it at LOGS folder if needed.. ")

    # launch getawayIn, must be paralell with bookbuilder
    p1 = Process(target=launch_getawayIn,args=(system_name,book_port,exchange_name,exchange_data_port,subscribe_symbol,debug,))
    p1.start()
    # to synchronize bookbuilder and getawayIN... otherwise bookbuilder
    # start before getawayIn
    time.sleep(2)
    # launch bookbuilder with a new process
    p2 = Process(target=launch_bookbuilder,args=(system_name,database,book_port,exchange_name,debug))
    p2.start()
    # to synchronize bookbuilder and getawayIN... otherwise bookbuilder
    # start before getawayIn
    time.sleep(2)
    # launch getawayOut with a new process
    p3 = Process(target=launch_getawayOut,args=(system_name,database,order_port,exchange_name,exchange_order_port,debug))
    p3.start()
    # to synchronize bookbuilder and getawayIN... otherwise bookbuilder
    # start before getawayIn
    time.sleep(2)

    # launch trader and market data viewer
    trader1=trader(trade_interval,database,order_port,system_name,robot_trader_style,robot_trader_strategy,is_robot_trader,debug)
    trader1.market_price_viewer(subscribe_symbol)


def launch_getawayIn(system_name,book_port,exchange_name,exchange_data_port,subscribe_symbol,debug):
    # launch getawayIN
    getawayIN =getawayIn(system_name,book_port,exchange_name,exchange_data_port,debug)
    getawayIN.subscribe(subscribe_symbol)


def launch_bookbuilder(system_name,database,book_port,exchange_name,debug):
    # launch book builder, parallel with getawayIn
    book = bookbuilder(system_name,database,book_port,exchange_name,debug)


def launch_getawayOut(system_name,database,order_port,exchange_name,exchange_order_port,debug):
    # launch getawayOut
    getawayOUT = getawayOut(system_name,database,order_port,exchange_name,exchange_order_port,debug)
    getawayOUT.handle_client()


# launch a trader/trading system: trader1
trader3 = trading_system(subscribe_symbol, system_name, database, exchange_name, book_port, order_port, exchange_data_port, exchange_order_port, robot_trader_style, robot_trader_strategy, is_robot_trader,trade_interval,debug)
