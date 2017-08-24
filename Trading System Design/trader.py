import sqlite3
from datetime import datetime
import time
import threading
import socket
import random
import os
from multiprocessing import Process,Pipe
from fixmessage import FixMessage


class trader(object):

    # style:  conservative, neutral, riskseeker
    # strategy: spread, volatility, random
    # spread: always trade a price within the highest bid and lowest ask
    # volatility: trade a price far away from highest bid or lowest ask
    # random: just submit a price whatever it is
    def __init__(self,interval, database, getawayOut_port,trader,style,strategy,dummy_trader=True,debug=True):

        # connect to market book database
        self.database = database
        self.table = 'orderbook'
        self.trader_name = str.upper(trader)
        self.dummy_trader = dummy_trader
        self.style = style
        self.strategy = strategy
        self.getawayOut_port = getawayOut_port
        self.recv_buffer = 1024
        self.debug = debug

        # this variable controls sleep time of each trade
        self.interval = interval

        # set up log file system
        self.log_file = os.path.join('LOGS',self.trader_name,'TRADER.log')
        directory = os.path.join('LOGS',str.upper(self.trader_name))

        if not os.path.isdir(directory):
            os.makedirs(directory)
        self.logs = open(self.log_file,'a+')

        # connect to getawayOUT
        self.connect_getaway()



    # connect to getawayOUT
    def connect_getaway(self):
        # connect to getawayOUT
        self.getaway_port = self.getawayOut_port
        self.getaway_host = socket.gethostname()
        self.getaway_socket = socket.socket()

        self.getaway_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.getaway_socket.connect((self.getaway_host, self.getaway_port))
        self.log('Connected to getawayOUT server: '+self.getaway_socket.getpeername()[0]+'@'+str(self.getaway_socket.getpeername()[1]))



    # this function print current market price
    def market_price(self,symbol, rows=3):

        database_connect = sqlite3.connect(self.database)
        C = database_connect.cursor()
        time.sleep(2)
        BID= C.execute('select symbol, price, sum(volumn) from marketbook where symbol =\''+symbol+'\' and order_type = \'BID\' group by price order by price desc limit '+str(rows)).fetchall()
        ASK= C.execute('select symbol, price, sum(volumn) from marketbook where symbol =\''+symbol+'\' and order_type = \'ASK\' group by price order by price limit '+str(rows)).fetchall()
        price_list = 'Market Quotes:\nCurrent time: '+datetime.now().strftime('%Y-%m-%d %H:%M:%S')+'\n'+'SYMBOL: '+symbol+'\n'

        for i in range(len(ASK)):
            price_list = price_list + "ASK " + str(ASK[len(ASK)-i-1][1])+"\n"
        for i in range(len(BID)):
            price_list = price_list + "BID " + str(BID[i][1])+"\n"

        # this is useful for random trader to decide on a random price to submit
        # this is to avoid error when the exchange has no order yet
        self.lowest_ask = 90
        self.highest_bid = 89
        self.lowest_bid = 87
        self.highest_ask = 91

        # for strategy
        if len(ASK) != 0:
            self.lowest_ask = ASK[0][1]
            self.highest_ask = ASK[-1][1]
        if len(BID) != 0:
            self.highest_bid = BID[-1][1]
            self.lowest_bid  = BID[0][1]

        return price_list



    # this functions repeats calling market_price
    # if you want to simulate trade with a dummy trader, say dummy_trade = True
    def market_price_viewer(self,symbol,simulate_trade = True, rows=3):

        self.refresh_market = True
        while self.refresh_market:

           price = self.market_price(symbol,rows)

           print(price)
           
           if not self.dummy_trader:
               self.human_trader(symbol)

           elif simulate_trade:
           # Call dummy trader to trade
               self.robot_trader(symbol)

           time.sleep(self.interval)


    # turn off market_price_viewer function
    def stop_market_viewer(self):
        self.refresh_market = False


    # this is a trader,who trade based on probability of uniform distribution
    # and its trading style.
    # protocol: price_change|bid|DDD|16.7
    def _roll_dice(self, style='riskseeker'):

        rand = random.random()
        if style == 'conservative' and rand > 0.8:
            return True
        elif style == 'neutral' and rand > 0.5:
            return True
        elif style == 'riskseeker' and rand > 0.2:
            return True
        else:
            return False


    # with human trader, you could submit your order
    # protocol: A MQ ASK 12.96 5 limit 110
    def human_trader(self,symbol):

        msg = 'Trade on '+symbol+' ? 1=NEW 2=MODIFY 3=CANCEL or ELSE=NO: '
        if_trade = input(msg)
        side = "_ "
        price = "_ "
        vol = "_ "
        order_type ="_ "

        # user prompt
        if if_trade in (1,2):

            msg_type = 'A ' if if_trade ==1 else 'M '
            user_input_side = input('1=BID or ELSE=ASK:')
            user_input_type = input('1=market or ELSE=limit:')
            price = str(input('Input price:'))+" "
            vol = str(input('Input volume:'))+" "
            side = 'BID ' if user_input_side == 1 else 'ASK '
            order_type = '1 ' if user_input_type ==1 else '2 '
            # placeholder for protocol format
            order_id ="_"

        if if_trade in (2,3):
            msg_type = 'C ' if if_trade == 3 else msg_type
            order_id = str(input('Order id being cancelled/modified:'))

        elif if_trade not in (1,2,3):
            self.log('Human trader not trade.')
            return
        
        # if_trade compose order message to getaway
        if if_trade in (1,2,3):

            msg = msg_type+symbol+" "+side+price+vol+order_type+ order_id
            self.log('Order submit: '+ msg)
            self.getaway_socket.send(msg)
            # print out order ID of the submitted order
            self.execution_report()


    # this function prints out order ID
    def execution_report(self):
        msg = self.getaway_socket.recv(self.recv_buffer)
        self.log("Order confirmed by getawayOut: "+msg+'\n')

        if not self.debug:
            print("Order confirmed by getawayOut: "+msg+'\n')

    # robot_trader CAN NOT cancel order
    # robot trader: submit market/limit bid/ask with random price
    # strategy:
    # spread: price = self.highest_bid+random(0,1)*(spread btw bid and ask)
    # volatility: price = random(0,1) + self.lowest_bid/self.highest_ask
    # random: price = self.highest_bid + random(0,1)
    def robot_trader(self,symbol):

        # random a price
        if self._roll_dice(self.style):

            side  = 'BID ' if random.random()>0.5 else 'ASK '
            order_type  = 'limit ' if random.random() >= 0.5 else 'market '
            vol = random.randint(10,100)
            msg_type = 'A '

            # protocol: A DDD ASK 12.96 5.0 limit 110, last is order_id,
            order_id = "_"

            if self.strategy == 'spread':
                price = self.highest_bid + round(random.random()*(self.lowest_ask - self.highest_bid),2)

            elif self.strategy == 'volatility':
                if random.random() >= 0.5:
                    price = self.lowest_bid + round(random.random()*(self.lowest_bid - self.highest_bid),2)
                else:
                    price = self.highest_ask + round(random.random()*(self.highest_ask - self.highest_bid),2)

            elif self.strategy == 'random':
                price = self.highest_bid + round(random.random()*(self.lowest_ask - self.highest_bid),2)

            else:
                self.log('Unknown strategy')
                return
        else:
            self.log('Trader does not trader this time.\n')
            return

        msg = msg_type+symbol+" "+side+str(price)+" "+str(vol)+" "+order_type+order_id
        self.log('Order submitted: '+ msg)
        self.getaway_socket.send(msg)
        # print out order ID of the submitted order
        self.execution_report()

        # protocol to getawayOUT: A DDD ASK 12.96 5.0 limit 110
        self.log('Order submitted: symbol='+ symbol+' price='+str(price)+' volume='+str(vol)+' side='+side+'order_type='+order_type+'order id='+order_id)


    def log(self,msg):
        self.logs.write(datetime.now().strftime('%Y-%m-%d:%H:%M:%S')+' [BOOKBUILDER]'+msg)
        if self.debug :
            print('['+self.trader_name+']'+msg)

