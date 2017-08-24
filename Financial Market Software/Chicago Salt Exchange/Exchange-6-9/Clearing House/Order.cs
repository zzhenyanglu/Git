using System;
using System.Collections;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Net.Sockets;
using System.Net;
using System.IO;
using System.Xml.Serialization;
using System.Xml.Linq;
using System.Configuration;
using System.Xml;
using System.Xml.XPath;

namespace OME.Storage
{
    public abstract class Order
    {
        string instrument;
        string status;
        string message;
        string orderAction;
        string buySell;
        string orderType;
        double stopPrice;
        double limitPrice;
        int origQuantity;
        int orderQuantity;
        static long globalOrderId;
        long orderId;
        long customerID;
        bool active = true;
        DateTime orderTimeStamp;

        public Order()
        {
            orderId = Interlocked.Increment(ref globalOrderId);
            orderTimeStamp = DateTime.Now;
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
        public string OrderAction
        {
            get { return orderAction; }
            set { orderAction = value; }
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
    }

    public class FuturesOrder : Order
    {
        public FuturesOrder(string instrument, string orderType, string buySell, double price, int quantity, long orderID, long custID, string orderAction, string status="Initiated")
        {
            this.Instrument = instrument;
            this.OrderType = orderType;
            this.BuySell = buySell;
            this.LimitPrice = (orderType == "Limit" ? price : 0);
            this.StopPrice = (orderType == "Stop" ? price : 0);
            this.Quantity = quantity;
            this.OrigQuantity = quantity;
            this.OrderID = orderID;
            this.CustomerID = custID;
            this.OrderAction = orderAction;
            this.Status = status;
        }
        public FuturesOrder() { }
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
            this.Status = order.Status;
            this.Message = order.Message;
        }
        public ExecutedOrders() { }
    }
}
