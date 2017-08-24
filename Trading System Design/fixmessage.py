from simplefix import FixMessage as Message,FixParser as Parser


# this class implements fix message and tools.
# every function of FixMessage class compiles a type of FIX message
#
class FixMessage():

    def __init__(self):
        self.header = "FIX.4.2"


    def msg_type(self,message):

        parser = Parser()
        parser.append_buffer(message)
        message_recv = parser.get_message()
        return message_recv.get(35)


    def aloha(self,sender,target,seq_no=1):

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,seq_no) # sequence no
        msg.append_pair(35,'A') # msgType = logon
        msg.append_pair(49,sender)
        msg.append_time(52) # timestamp
        msg.append_pair(56,target)
        msg.append_pair(98,0) # encrypt type
        msg.append_pair(108,30) # heart beat
        msg.append_pair(141,'N') # reset sequence number
        return msg.encode()


    def aloha_back(self,message):

        parser = Parser()
        parser.append_buffer(message)
        message_recv = parser.get_message()

        # compile new message
        msg = Message()
        msg.append_pair(8,self.header)

        # reset sequence number?
        if message_recv.get(141) == 'Y':
            msg.append_pair(34,1)
        else:
            msg.append_pair(34,int(message_recv.get(34))+1)

        msg.append_pair(35,'A')
        msg.append_pair(49,message_recv.get(56))
        msg.append_time(52)
        msg.append_pair(56,message_recv.get(49))
        msg.append_pair(98,0)
        msg.append_pair(108,30)
        msg.append_pair(141,'Y')
        return msg.encode()

    # compile a subscribe sent by getawayIn to exchange
    def subscribe(self,ticker,sender,target,seq_no=1,rep_seq=1):

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,seq_no) # sequence no
        msg.append_pair(35,'V') # msgType = logon
        msg.append_pair(49,sender)
        msg.append_time(52) # timestamp
        msg.append_pair(56,target)
        msg.append_pair(146,rep_seq) # repeating sequence
        msg.append_pair(55,ticker) # subscribed ticker
        msg.append_pair(262,1)
        msg.append_pair(263,1)
        msg.append_pair(264,1)
        msg.append_pair(265,1)
        msg.append_pair(267,2)
        msg.append_pair(269,0)

        return msg.encode()


        # compile a subscribe sent by getawayIn to exchange
    def full_refresh(self, message, price, volume, side):

        parser = Parser()
        parser.append_buffer(message)
        message_recv = parser.get_message()

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,int(message_recv.get(34))+1) # sequence no
        msg.append_pair(35,'W') # msgType = logon
        msg.append_pair(49,message_recv.get(56))
        msg.append_time(52) # timestamp
        msg.append_pair(56,message_recv.get(49))
        msg.append_pair(55,message_recv.get(55)) # subscribed ticker
        msg.append_pair(268,1)

        # side
        if str.lower(side) == 'bid':
            msg.append_pair(269,'0') # order side
        elif str.lower(side) == 'ask':
            msg.append_pair(269,'1')
        else:
            print('[FIXMESSAGE]Unknown side..')
            return

        msg.append_pair(271,volume) #volume
        msg.append_pair(270,price) #price

        return msg.encode()


    # get value of a specified FIX tag
    def get_tag_value(self,message,tag):

        parser = Parser()
        parser.append_buffer(message)
        message_recv = parser.get_message()

        # translate order side
        if tag in (269,54) :
            if message_recv.get(tag)== '0':
                return 'BID'
            else:
                return 'ASK'

        return message_recv.get(tag)


    # compile update message sent by getawayOut to exchange
    def update(self,ticker,price,volume,side,order_id,seq_no,sender,target,update_type='change'):

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,seq_no) # sequence no
        msg.append_pair(35,'X') # msgType
        msg.append_pair(49,sender)
        msg.append_time(52) # timestamp
        msg.append_pair(56,target)
        msg.append_pair(55,ticker) # subscribed ticker
        msg.append_pair(37,order_id) # orderID
        msg.append_pair(268,1) # number of message

        # if new order
        if str.lower(update_type) =='new':
            msg.append_pair(279,'0')
        elif str.lower(update_type) =='change':
            msg.append_pair(279,'1')
        else:
            msg.append_pair(279,'2')

        # side
        if str.lower(side) == 'bid':
            msg.append_pair(269,'0') # order side
        else:
            msg.append_pair(269,'1')

        msg.append_pair(271,volume) #volume
        msg.append_pair(270,price)
        return msg.encode()

    def goodbye(self, sender,target,seq_no):

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,seq_no) # sequence no
        msg.append_pair(35,'5') # msgType = logout
        msg.append_pair(49,sender)
        msg.append_time(52) # timestamp
        msg.append_pair(56,target)
        return msg.encode()


    def goodbye_back(self,message):

        parser = Parser()
        parser.append_buffer(message)
        message_recv = parser.get_message()

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34, int(message_recv.get(34))+1) # sequence no
        msg.append_pair(35,'5') # msgType = logout
        msg.append_pair(49,message_recv.get(56))
        msg.append_time(52) # timestamp
        msg.append_pair(56,message_recv.get(49))
        return msg.encode()



    def execution_report(self,message, filled_qty,trasaction_type,order_id,symbol):

        parser = Parser()
        parser.append_buffer(message)
        message_recv = parser.get_message()

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,int(message_recv.get(34))+1) # sequence no
        msg.append_pair(35,'8') # msgType = logon
        msg.append_pair(49,message_recv.get(56))
        msg.append_time(52) # timestamp
        msg.append_pair(56,message_recv.get(49))
        msg.append_pair(14,filled_qty)
        msg.append_pair(31,message_recv.get(44))
        msg.append_pair(32,message_recv.get(38))
        msg.append_pair(54,message_recv.get(54))
        msg.append_pair(37,order_id) # orderID
        msg.append_pair(39,'0') # order status, now it's all filled
        msg.append_pair(55,symbol) # subscribed ticker

        if str.lower(trasaction_type) == 'new':
            msg.append_pair(279,'0')
        elif str.lower(trasaction_type) == 'cancel':
            msg.append_pair(279,'2')
        elif str.lower(trasaction_type) == 'amend':
            msg.append_pair(279,'1')

        return msg.encode()



    def new_order(self,ticker, price, volume, order_type, side, sender, target,seq_no):

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,seq_no) # sequence no
        msg.append_pair(35,'D') # msgType = logon
        msg.append_pair(49,sender)
        msg.append_time(52) # timestamp
        msg.append_pair(56,target)
        msg.append_pair(55,ticker) # subscribed ticker
        msg.append_pair(38,volume)
        msg.append_pair(21,'3')
        msg.append_pair(44,price)

        # side
        if str.lower(side) == 'bid':
            msg.append_pair(54,'0') # order side
        else:
            msg.append_pair(54,'1')

        # order type
        if str.lower(order_type) == 'market':
            msg.append_pair(40,'1')
        elif str.lower(order_type) == 'limit':
            msg.append_pair(40,'2')

        return msg.encode()


    def cancel_order(self,order_id, sender,target,sequence_no):

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,sequence_no) # sequence no
        msg.append_pair(35,'F') # msgType = logon
        msg.append_pair(49,sender)
        msg.append_time(52) # timestamp
        msg.append_pair(56,target)
        # cancel order by order_id
        msg.append_pair(37,order_id) # orderID

        return msg.encode()


    def amend_order(self,order_id, price, volume, order_type, sender,target,sequence_no):

        msg = Message()
        msg.append_pair(8,self.header)
        msg.append_pair(34,sequence_no) # sequence no
        msg.append_pair(35,'G') # msgType = logon
        msg.append_pair(49,sender)
        msg.append_time(52) # timestamp
        msg.append_pair(56,target)
        # cancel order by order_id
        msg.append_pair(37,order_id) # orderID
        msg.append_pair(44,price)
        msg.append_pair(38,volume)

        # side
        if str.lower(order_type) == 'market':
            msg.append_pair(40,'1') # order side
        else:
            msg.append_pair(40,'2')

        return msg.encode()


                            
