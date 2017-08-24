def fetchdata(database='Chinese Futures Market.db',table= '''pair_trade_o_y''' ):
   # This guy fetches data from the database and return the column names and data 
   import sqlite3 
   conn = sqlite3.connect(database)
   datalink = conn.execute('''select * from '''+ table)
   columns = [i[0] for i in datalink.description]
   return columns, datalink



