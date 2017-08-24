from datetime import datetime

class order():

    def __init__(self,ticker,price,volume, side, order_type,submitter):

        time = datetime.now().strftime('%Y-%m-%d:%H:%M:%S')
        self.ticker = ticker
        self.price = price
        self.volume = volume
        self.side = side
        self.type = order_type
        self.timestamp = time
        self.submitter = submitter


class match_engine():

    def __init__(self,sequence_no = 100):

        # initial sequence number
        self.sequence_no = sequence_no
        self.orders = {}

        # set up log files
        self.log_file = os.path.join('LOGS','Exchange','MATCH_ENGINE.log')
        directory = os.path.join('LOGS','Exchange')

        if not os.path.isdir(directory):
            os.makedirs(directory)

        self.logs = open(self.log_file,'a+')


    def submit_order(self, ticker,price,volume, side, order_type, submitter):

        if float(price)<=0:
            self.log("Price negative:"+price)
            return

        new_order = order(ticker,price,volume, side, order_type,submitter)
        self.orders[self.sequence_no] = new_order
        self.log("Order Submitted: "+ str(self.sequence_no))
        self.sequence_no = self.sequence_no + 1

        return self.sequence_no-1


    def log(self,msg):
        self.logs.write(datetime.now().strftime('%Y-%m-%d:%H:%M:%S')+'[MATCH ENGINE]'+msg)
        print('[MATCH ENGINE]'+msg)


    def order_exists(self,order_number):
        return (order_number in self.orders.keys())


    def cancel_order(self,order_number,requester):

        order_number = int(order_number)
        if self.order_exists(order_number):

            if self.orders[order_number].type == 'market':
                self.log("Market order can not cancel: "+ str(order_number))
                return

            self.log("Order Cancelled: "+ str(order_number))
            del self.orders[order_number]

        else:
            self.log("Order being cancelled not found: "+ str(order_number))
            return


    def amend_order(self, order_number, price, volume, order_type):

        if self.order_exists(order_number):

            if self.orders[order_number].type == 'market':
                self.log("Market order can not be amend: "+ str(order_number))
                return

            self.orders[order_number].price = price
            self.orders[order_number].volume = volume
            self.orders[order_number].order_type = order_type
            self.orders[order_number].time = time = datetime.now().strftime('%Y-%m-%d:%H:%M:%S')
            self.log("Order modified: "+ str(order_number))

        else:
            self.log("Order being amended not found: "+ str(order_number))
            return


    def total_volume(self,ticker):

        volume = 0
        for order in self.orders.values():
            if order.ticker == ticker:
                volume = volume + order.volume

        self.log("Volume of "+ ticker + ": "+ str(volume))
        return volume



    # return current highest bid price and its volume
    def get_current_price(self,ticker):

        max_price = 0
        max_volume = 0

        for order in self.orders.values():
            if order.ticker == ticker and order.price > max_price:
                max_price = order.price
                max_volume = order.volume

        self.log("current price queried: "+ ticker + "="+ str(max_price) )
        return max_price, max_volume

                                             
