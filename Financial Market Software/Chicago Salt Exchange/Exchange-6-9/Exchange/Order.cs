using System;
using System.Threading;
using System.Xml.Serialization;
using System.Xml.Linq;
using System.Configuration;
using System.Xml;
using System.Xml.XPath;
using System.Collections;

namespace OME.Storage
{
    public abstract class Order : ICloneable
    {
        string instrument;
        string status;
        string message;
        string buySell;
        string orderType;
        string orderAction;
        double stopPrice;
        double limitPrice;
        int origQuantity;
        int orderQuantity;
        static long globalOrderId;
        long orderId;
        long customerID;
        bool active = true;
        DateTime orderTimeStamp;
        public double executionPrice;
        public int executionQuantity;
        public DateTime executionTimeStamp;


        public Order()
        {
            orderId = Interlocked.Increment(ref globalOrderId);
            orderTimeStamp = DateTime.Now;
        }

        public double ExecutionPrice
        {
            get { return executionPrice; }
            set { executionPrice = value; }
        }
        public int ExecutionQuantity
        {
            get { return executionQuantity; }
            set { executionQuantity = value; }
        }
        public DateTime ExecutionTimeStamp
        {
            get { return executionTimeStamp; }
            set { executionTimeStamp = value; }
        }
        public DateTime TimeStamp
        {
            get { return orderTimeStamp; }
        }
        public string Instrument
        {
            get { return instrument; }
            set { instrument = value; }
        }
        public string Status
        {
            get { return status; }
            set { status = value; }
        }
        public string Message
        {
            get { return message; }
            set { message = value; }
        }
        public string OrderAction
        {
            get { return orderAction; }
            set { orderAction = value; }
        }
        [XmlIgnore]
        public bool Active
        {
            get { return active; }
            set { active = value; }
        }
        public string OrderType
        {
            get { return orderType; }
            set { orderType = value; }
        }
        public string BuySell
        {
            get { return buySell; }
            set { buySell = value; }
        }
        public double LimitPrice
        {
            get { return limitPrice; }
            set { limitPrice = value; }
        }
        public double StopPrice
        {
            get { return stopPrice; }
            set { stopPrice = value; }
        }
        public int Quantity
        {
            get { return orderQuantity; }
            set { orderQuantity = (value < 0 ? 0 : value); }
        }
        public long OrderID
        {
            get { return orderId; }
            set { orderId = value; }
        }
        public long CustomerID
        {
            get { return customerID; }
            set { customerID = value; }
        }
        public int OrigQuantity
        {
            get { return origQuantity; }
            set { origQuantity = value; }
        }
        public object Clone()
        {
            return this.MemberwiseClone();
        }
    }

    public class FuturesOrder : Order
    {
        public FuturesOrder(string instrument, string orderType, string buySell, double price, int quantity, long orderID, long custID, string orderAction)
        {
            this.Instrument = instrument;
            this.OrderType = orderType;
            this.BuySell = buySell;
            this.LimitPrice = (orderType == "LIMIT" ? price : 0);
            this.StopPrice = (orderType == "STOP" ? price : 0);
            this.Quantity = quantity;
            this.OrigQuantity = quantity;
            this.OrderID = orderID;
            this.CustomerID = custID;
            this.OrderAction = orderAction;
        }
        public FuturesOrder() { }

        public object Clone()
        {
            return this.MemberwiseClone();
        }
    }
    public class ExecutedOrders : Order
    {
        public double ExecutionPrice;
        public double ExecutionQuantity;
        public DateTime executionTimeStamp;

        public ExecutedOrders(Order order, int executionQuantity, double executionPrice)
        {
            this.Instrument = order.Instrument;
            this.OrderType = order.OrderType;
            this.BuySell = order.BuySell;
            this.LimitPrice = order.LimitPrice;
            this.StopPrice = order.StopPrice;
            this.OrigQuantity = order.OrigQuantity;
            this.OrderID = order.OrderID;
            this.CustomerID = order.CustomerID;
            this.ExecutionPrice = executionPrice;
            this.ExecutionQuantity = executionQuantity;
            this.executionTimeStamp = DateTime.Now;
        }
        public ExecutedOrders() { }
    }


    public class OrderEventArgs
    {
        private Order order;
        private Container buyBook;
        private Container sellBook;

        public OrderEventArgs(Order newOrder, Container bBook, Container sBook)
        {
            order = newOrder;
            buyBook = bBook;
            sellBook = sBook;
        }
        public OrderEventArgs(Container bBook, Container sBook)
        {
            buyBook = bBook;
            sellBook = sBook;
        }
        public Order Order
        {
            get { return order; }
        }
        public Container BuyBook
        {
            get { return buyBook; }
        }
        public Container SellBook
        {
            get { return sellBook; }
        }
    }

    //Mike Initial idea was to use xml to store data but it was too slow
    public static class ClearingHouseTest
    {

        public static Hashtable traderMarginAcct = new Hashtable();

        public static void StartMarginAcct(long clientID)
        {
            traderMarginAcct.Add(clientID, new initaltraderMargin());

        }
        public static bool CheckMarginAmount(Order order)
        {
            double newReqMargin, newInitialOrderMargin, price;
            double orderPrice;
            int sign;

            if (order.OrderAction == "DELETE") // will be handled when exchange sends confirmation
            {
                //trader log will be updated when trade is executed
                return true;
            }
            //uses current price for market orders

            if (!traderMarginAcct.ContainsKey(order.CustomerID)) StartMarginAcct(order.CustomerID);

            orderPrice = (order.OrderType == "LIMIT" ? order.LimitPrice : order.OrderType == "STOP" ? order.StopPrice : Container.currentPrice);

            initaltraderMargin temp = (initaltraderMargin)traderMarginAcct[order.CustomerID];
            sign = (order.BuySell == "B" ? 1 : -1);

            newInitialOrderMargin = orderPrice * order.Quantity * 0.02 * sign;
            newReqMargin = orderPrice * order.Quantity * 0.018 * sign;


            if (Math.Abs(temp.RequiredMargin + newInitialOrderMargin) < temp.AccountBalance)//probably need to make this work better
            {
                price = (temp.Price * temp.Positions + order.Quantity * orderPrice * sign) / (temp.Positions + order.Quantity);

                double gain = (temp.Price - price) * sign;

                if (temp.Positions < temp.Positions + order.Quantity * sign) //closing out some positions need to work on this
                    temp.AccountBalance = temp.AccountBalance + gain * (temp.Positions + order.Quantity * sign);

                temp.Price = price;
                temp.Positions += order.Quantity * sign;
                temp.RequiredMargin += newReqMargin * sign;
                return true;
            }
            else
            {
                //return trade, insuficient margin
                return false;
            }

        }

        public static void UpdateMarginForExucutedOrder(Order order)
        {
            double orderPrice, newReqMargin, price;
            int sign;
            orderPrice = (order.OrderType == "LIMIT" ? order.LimitPrice : order.OrderType == "STOP" ? order.StopPrice : Container.currentPrice);
            orderPrice = orderPrice - order.executionPrice;

            initaltraderMargin temp = (initaltraderMargin)traderMarginAcct[order.CustomerID];
            sign = (order.BuySell == "B" ? 1 : -1);//revesed since order is being deleted


            newReqMargin = orderPrice * order.Quantity * 0.018 * sign;

            price = (temp.Price * temp.Positions + order.Quantity * orderPrice * sign) / (temp.Positions + order.Quantity);
            temp.Price = price;
            temp.Positions += order.Quantity * sign;
            temp.RequiredMargin += newReqMargin * sign;
            
        }
        public static void UpdateMarginForDeletedOrder(Order order)
        {
            double orderPrice, newReqMargin, price;
            int sign;
            orderPrice = (order.OrderType == "LIMIT" ? order.LimitPrice : order.OrderType == "STOP" ? order.StopPrice : Container.currentPrice);

            initaltraderMargin temp = (initaltraderMargin)traderMarginAcct[order.CustomerID];
            sign = (order.BuySell == "B" ? -1 : 1);//revesed since order is being deleted

            
            newReqMargin = orderPrice * order.Quantity * 0.018 * sign;

                price = (temp.Price * temp.Positions + order.Quantity * orderPrice * sign) / (temp.Positions + order.Quantity);
                temp.Price = price;
                temp.Positions += order.Quantity * sign;
                temp.RequiredMargin += newReqMargin * sign;
                //return true;

        }
    }
    public class initaltraderMargin
    {
        public static double accountBalance;
        public static double requiredMargin;
        //public Instrument instument;//probably should make this work for more
        public static int positions = 0;
        public static double price = 0;
        public static string instrument;


        public initaltraderMargin()
        {
            accountBalance = 100000;
            requiredMargin = 0;
            instrument = "RSXM";
            positions = 0;
            price = 0;
        }
        public int Positions
        {
            get { return positions; }
            set { positions = value; }
        }
        public double Price
        {
            get { return price; }
            set { price = value; }
        }
        public double AccountBalance
        {
            get { return accountBalance; }
            set { accountBalance = value; }
        }
        public double RequiredMargin
        {
            get { return requiredMargin; }
            set { requiredMargin = value; }
        }

    }
}






