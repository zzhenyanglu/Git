MPCS 51024 - Final Project
Student name: Zhenyang Lu 

#########################################################################################################
TABLE OF CONTENTS:
#########################################################################################################
0. BEFORE START
1. NOTICE
2. FILES
3. AUTO-GENERATED FILES
4. PROTOCOLS
5. UNIT-TEST INTRODUCTION
6. RUNNING UNIT-TEST
7. EVALUATING UNIT-TEST
8. THANK-YOU

#########################################################################################################
0. BEFORE START: 
#########################################################################################################

when I was testing and perfecting my homework on Linux Server on Aug 18, Thursday, which is my due day. I constantly experienced the following errors: 

OSError: [Errno 122] Disk quota exceeded 

So I couldn't test the project thoroughly because in order to test it, some disk space is needed for backup database for market data and order manager. While I believe I finished 95% of it, there may be some minor issues with cancel/modify order functionalities in getawayOut and Exchange side, as I've not tested it yet. But the rest of it should be fine, so if you want to test broadcast, please submit new order and see message being broadcasted.     

If you need to talk to me when you debug and grade my project, please call 312-804-2532 or send me email zzhenyanglu@uchicago.edu , I will be more than happy to meet you in person to answer your questions.

#########################################################################################################
1. NOTICE: 
#########################################################################################################

a. This project was done by me alone. The exchange server is not simply fake, rather it's fully capable of doing everything. 

b. This homework is written completely on Uchicago LINUX server, running on windows or other platform is not recommended, because it requires multiprocessing, based on my own test, Python 2.7 on windows does not support it at all.  

c. It's also highly suggested to test this homework on the same machine, otherwise you have to specify host names many times. when I did
this homework, I usually opened 5 putty(1 for exchange, 4 for traders) connecting to the same server(either Linux1 or Linux2.uchicago.edu). 

#########################################################################################################
2. FILES: 
#########################################################################################################

a. fixmessage.py: 
this file contains object called FixMessage(), which is a simply fix message composer and parser. All the fix messages needed throughout the whole project is stored as method. Unlike quickfix package, FixMessage() object only composes message, it's not going to handle processes or automatically receive or send message to or from itself, so that it allows more flexibility than quickfix does. 

* DISCLAIMER: fixmessage.py is built on top of a library called simplefix, which is not my work. Everything you will see inside simplefix folder is borrowed from python official package shop. Author is David Arnold. fixmessage.py is my own work as part of this project.  

b. match_engine.py:
This file contains a class called match_engine(), which is nothing much like a wrapper sit on top of a python dictionary that's used to store orders submitted to the exchange, and bunch of functions like submit_order() or cancel_order(), that manage the orders. Each exchange will have a match_engine() object that contains orders submitted by traders. 

c. database_setup.py:
This file is automatically called by bookbuilder of each trading system. You don't have to run it before running anything. When called, it will create a database that has too tables(marketbook for market info populated by bookbuilder, orderbook acts as order managers controlled by getawayOut). Database name can be specified as an input of bookbuilder() class, talk about it later. Like in robot_trader1_unittest.py, the database name is 'market1.db'. 

d. exchange.py:
it contains Exchange() class, which is the exchange server. It has 8 ports open as project description required, 4 for market info, 4 for order submission and contains a MatchEgine() object that keeps orders received. Each port has its own thread and is binded to a socket. When a client successfully logs out, the socket will be reused to accept for new clients. Each time a new order received, 35=X Fix message is broadcasted to all connected clients' getawayIn and execution report will be sent out to the getawayOut that submits the order. exchange's order id starts from 100. 

e. getaway.py:
getaway() inside this file is a parent class of getawayIn() and getawayOut() in each corresponding files. It only implements some common functions like connect to server and accept clients. 

f. getawayIn.py:
This file contains getawayIn() class, which is a child one of getaway(). It connects to exchange and pass through market data received from exchange to bookbuilder. When it tries to log on to exchange server, it will say 35 = A fix message, and exchange replies back. Then it subscribes to a symbol and keeps listening. getawayIn() translates FIX message to internal messages(talk about the difference later in section 4 - PROTOCOLS).

g. getawayOut.py:
This file has getawayOut(), which connects to a trader and exchange. It passes order submitted by trader and stores the order info into  orderbook table of a database whose name is specified when bookbuilder calls database_steup.py. When it logs onto exchange, it also has the full 35=A fix protocol message sent and received. when trader submits an order, it expects execution fix message 35=8 and passes order number back to trader, so that trader can cancel an order based on the order number. getawayOut() translates internal message to FIX message(talk about the difference later in section 4 - PROTOCOLS).

h. bookbuilder.py: 
bookbuilder() inside this file connects to getawayIn () to receive market data and stores it into marketbook database. The trader can query the database for current market quotes.  

i. trader.py: 
This contains trader(), which is an trader object that connects to a getawayOut(). The market quote viewer is implemented as an method of the class. There are two types of traders, human_trader and robot_trader. robot trader can only submit market/limit bid/ask according to some strategy and trading style(please take a look at trader.py for more). human_trader can submit, modify and cancel orders, which has been impelmented as user-prompted command and controls. When modify or cancel an order, you will have to specify order number(order id) that you want to cancel. So when test it, it's better to submit a new order first and remember the order id, then cancel it.  Again, there may be some minor errors with cancel or modify orders functionalites, as I haven't tested it before Linux server runs no disk space for me. 

j. *_unittest.py:
These are unit test files. Talk about them in section 5.

#########################################################################################################
3. AUTO-GENERATED FILES: 
#########################################################################################################

a. LOGS folder:
There will be a folder called LOGS shown up after the trading systems being launched. For example, if you launch exchange server, then you will see /LOGS/Exchange/EXCHANGE.log and /LOGS/Exchange/MATCH_ENGINE.log file. When you launch a trading system called 'trader1', you will see the following files: 

/LOGS/TRADER1/GETAWAYIN.log
/LOGS/TRADER1/GETAWAYOUT.log
/LOGS/TRADER1/BOOKBUILDER.log
/LOGS/TRADER1/TRADER.log

b. *.db:
Each time you launch a bookbuilder(), there will be a *.db file generated(you input name of that *.db file as an argument of bookbuilder()), which is a database that contains 2 tables: marketbook, orderbook. Like mentioned above, one is for market data and the other is order manager. 

#########################################################################################################
4. PROTOCOLS:
#########################################################################################################

a. communication between exchange server and getaways: 
FIX message as specified by the project description:  
LOGON: 35=A
LOGOUT: 35=5
NEW ORDER: 35=D
Modify order: 35=G
Full refresh: 35=W
Request full refresh: 35=V
Update: 35=X
Execution confirm: 35=8


b. internal communications: 
When communications happen among getaways, trader and bookbuilder: 

    format: message_type symbol side price volume order_id 

    Example: "A MQ BID 1.9 100 1130"

    options: 
        message_type: A=new order D=Delet order M=Modify order C=Cancel 
        side: 'limit' or 'market' 

#########################################################################################################
5. UNIT-TEST INTRODUCTION:
#########################################################################################################

To put all pieces together and test the whole system, I provided a scenario of 4 trading systems and 1 exchange. Let me introduce them briefly: 
    
    Exchange: nothing much than a full-stack exchange that can do whatever mentioned in previous sections. 

    Trading Systems: each trading system has a getawayIN, getawayOUT, bookbuilder, a trader, a log file folder and one database that has two tables. Each of them is a independent process. So each trading system has 4 processes. 3 of the 4 trading system have a robot trader sit behind it, each has its own trading strategy and style. Put it in a financial term, the 3 robot traders make the market, they don't cancel or modify orders. The last 1 trading system is a human trader, which takes in command and controls to submit, modify and cancel orders as you wish. Again, the canceling and modifying orders functions may or may not have some issue, as I haven't tested it yet before uchicago linux server is out of space for me. But submit new orders is definitely working fine.    

#########################################################################################################
6. RUNNING UNIT-TEST:
#########################################################################################################

To launch the full scenario, you have to have 5 console open on Uchicago's Linux server, and all of them use the same machine. Like you open putty.exe 5 times and each time you point to linux1.uchicago.edu. 

    a. Open a new putty.exe and go to the directory where you save my project and do: 
                     "python launch_exchange_unittest.py"

    b. Open a new putty.exe and go to the directory where you save my project and do:
                     "python robot_trader1_unittest.py"

    c. Open a new putty.exe and go to the directory where you save my project and do:
                     "python robot_trader2_unittest.py"

    d. Open a new putty.exe and go to the directory where you save my project and do:
                     "python robot_trader3_unittest.py"

    b. Open a new putty.exe and go to the directory where you save my project and do:
                     "python human_trader_unittest.py"

#########################################################################################################
7. EVALUATING UNIT-TEST: 
#########################################################################################################

To evaluate if every part is doing the right thing, you could read the log files at /LOGS folder. 

notice: you could go to each of the 5 unit-test files and modify a global variable called "debug", True means print system details to both screen and log files, False means prints details only to log files. I suggest True for robot and False for human, which is the default settings. 


#########################################################################################################
8. THANK-YOU: 
#########################################################################################################

Thank you very much for the course, I've learnt a lot, especially about multiprocess, multithread, socket-programming. Wish you best in future! 