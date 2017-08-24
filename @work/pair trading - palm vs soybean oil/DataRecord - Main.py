# Felix, created on Aug 2014

import urllib as url
from datetime import datetime as dt
import time
import sqlite3
from Tkinter import *
print ' importing modules done'

window = Tk()
window.title('Welcome! ')
window.geometry('300x300')
window.mainloop()


print Droptable

# configuration
cmdt1 = ' Soybean Oil'
cmdt2 = 'Palm Oil'
Exchange = 'Dalian Commodity Exchange'
symbol1 = 'Y1501'
symbol2 = 'P1501'
api= 'http://hq.sinajs.cn/list='

# configuration

print 'Creating datatable on database..'

conn = sqlite3.connect('Chinese Futures Market.db')
createTable = '''CREATE TABLE pair_trade_o_y (
                 markettime                          datetime,
                 bid_Palm_oil                    number(4),
                 bid_soybean_oil               number(4),

                 CONSTRAINT pair_trade_o_y  PRIMARY KEY (markettime)
              );'''

if Droptable ==True:
   print 'Continuing recording data' 

elif Droptable ==True:
   conn.execute('DROP TABLE IF EXISTS pair_trade_o_y');
   conn.execute(createTable)
   print 'Starting new data recording datatable' 
   
print 'Creating datatable successful..' 
print 'Connecting to database successful..'
print 'Connecting to API.......'

# Tools

link = url.urlopen    #  constant to remember the current quote
cursor = conn.cursor()

# Tools 

while(True):                                                # Still, this needs a more delicate design to solve many problems, e.g.,
                                                                       # if we stop the while loop, when we start it again, we have to reload the data by listening.
   try:                                                                    
      print 'Freshing quote...'
      current_quote_y = link(api+symbol1).read().split('"')
      current_quote_o = link(api+symbol2).read().split('"')
      # localtime = str(dt.now())[:19]
      #  reading soybean oil quote
      contract_y, markettime, open_y, high_y, low_y, last_close_y, bid_y, ask_y, current_y, settlement_y, last_settlement_y, \
      bid_vol_y, ask_vol_y, OI_y, volume_y, exchange_y, cmdt_y, date = current_quote_y[1].split(',')
      #  reading canola oil quote
      contract_o, markettime, open_o, high_o, low_o, last_close_o, bid_o, ask_o, current_o, settlement_o, last_settlement_o, \
      bid_vol_o, ask_vol_o, OI_o, volume_o, exchange_o, cmdt_o, date = current_quote_o[1].split(',')

      year, month, day = map(int, date.split('-'))
      hour, minute, second = map(int, [markettime[0:2], markettime[2:4], markettime[4:6]])
      markettime = dt(year,month,day,hour,minute,second)

      conn.execute('INSERT OR IGNORE INTO pair_trade_o_y VALUES(?,?,?)', [str(markettime), float(bid_y),float(bid_o)])
      # conn.execute('INSERT INTO pair_trade_o_y VALUES(?,?,?)', [str(markettime), float(bid_y),float(bid_o)])
      conn.commit()

      print 'Current time: ', str(markettime), \
               cmdt1, ' :', current_y, \
               cmdt2, ' :', current_o, '\n'
      
      time.sleep(8)# This API refresh data every 10 sec! we make trade decisi5on on every 5 minutes
   
   except KeyboardInterrupt:
      conn.close()
      print ' Connection to Database closed...'

