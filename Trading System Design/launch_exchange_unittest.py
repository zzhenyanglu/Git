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
from exchange import Exchange


#-------------------------------------
# THIS UNIT TEST DOES THE FOLLOWING:
#  1. launch exchange

exchange = Exchange()
# launch both market data(5551-5554) and order socket(5561-5564)
exchange.launch(market_data_socket=True,order_socket=True)
# keep it running for minutes and then logout
#time.sleep(360)
#exchange.shutdown()
