import sqlite3
import sys

# database should be directory that stores the database file
database = sys.argv[1]

conn = sqlite3.connect(database)
c = conn.cursor()

c.execute('''drop table if exists marketbook''' )
c.execute('''drop table if exists orderbook''' )
c.execute('''CREATE TABLE IF NOT EXISTS marketbook(stock_name text, update_time datetime, symbol text, volumn bigint, price real, order_type text, venue text)''')
c.execute('''CREATE TABLE IF NOT EXISTS orderbook(submitter text, update_time datetime, symbol text, volumn bigint, price real, side text, order_type text, venue text,order_id bigint)''')

conn.commit()
conn.close()
