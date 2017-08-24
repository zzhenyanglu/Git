using System;
using System.Threading;


namespace OME.Storage
{
    public abstract class Order
    {
        string owner;
        string orderAction;//new update cancel
        string instrument;
        string buySell;
        string orderType;
        double price;
        int quantity;
        static long globalOrderId;
        long orderId;
        bool active=true;
        DateTime orderTimeStamp;
        public Order()
        {
           orderId = Interlocked.Increment(ref globalOrderId);
           orderTimeStamp = DateTime.Now;
        }
        public DateTime TimeStamp
        {
            get { return orderTimeStamp; }
            set { orderTimeStamp = value; }
        }
        public string Instrument
        {
            get { return instrument; }
            set { instrument = value; }
        }
        public string OrderAction
        {
            get { return orderAction; }
            set { orderAction = value; }
        }
        public string Owner
        {
            get { return owner; }
            set { owner = value; }
        }
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
        public double Price
        {
            get { return price; }
            set { price = value; }
        }
        public int Quantity
        {
            get { return quantity; }
            set { quantity = (value < 0 ? 0 : value);}
        }
        public long OrderID
        {
            get { return orderId; }
            set { orderId = value; }
        }
    }

    public class FuturesOrder : Order
    {
   
        public FuturesOrder(string instrument, string orderType, string buySell, double price, int quantity,string owner, string action )
        {
            this.Owner = owner;
            this.Instrument = instrument;
            this.OrderType = orderType;
            this.BuySell = buySell;
            this.Price = price;
            this.Quantity = quantity;
            this.OrderAction = action;
        }
        public FuturesOrder() { }
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
}





