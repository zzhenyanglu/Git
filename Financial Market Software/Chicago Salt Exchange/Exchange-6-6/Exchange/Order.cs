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
        bool active=true;
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
            this.LimitPrice = (orderType == "LIMIT" ? price: 0);
            this.StopPrice = (orderType == "STOP" ? price: 0);
            this.Quantity = quantity;
            this.OrigQuantity = quantity;
            this.OrderID = orderID;
            this.CustomerID= custID;
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

        public ExecutedOrders(Order order, int executionQuantity , double executionPrice)
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
            double newReqMargin, newInitialOrderMargin, maint, price;
            int sign;
            if (order.OrderAction == "DELETE") // will be handled when exchange sends confirmation
            {
                //trader log will be updated when trade is executed
                return true;
            }

            if (!traderMarginAcct.ContainsKey(order.CustomerID)) StartMarginAcct(order.CustomerID);

            initaltraderMargin temp = (initaltraderMargin)traderMarginAcct[order.CustomerID];
            sign = (order.BuySell == "B" ? 1 : -1);
            
            newInitialOrderMargin = order.LimitPrice * order.Quantity * Convert.ToDouble(ConfigurationManager.AppSettings["initialMargin"])*sign;
            newReqMargin = order.LimitPrice * order.Quantity * Convert.ToDouble(ConfigurationManager.AppSettings["maintMargin"]) * sign;
            
            
            if ( Math.Abs(temp.RequiredMargin + newInitialOrderMargin) > temp.AccountBalance)//probably need to make this work better
            {
                price = (temp.Price * temp.Positions + order.Quantity * order.LimitPrice) / (temp.Positions + order.Quantity);
                temp.Price = price;
                temp.Positions += order.Quantity* sign;
                temp.RequiredMargin += newReqMargin* sign;
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

            //still need to do this
        }
        public static void UpdateMarginForDeletedOrder(Order order)
        {

            //still need to do this
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
            accountBalance=100000;
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
    //public class Instrument: initaltraderMargin
    //{
    //    public Instrument(string inst)
    //    {
    //        instrument = inst;
    //    }

    //    public static int positions = 0;
    //    public static double price = 0;
    //    public static string instrument;
    //    public int Positions
    //    {
    //        get { return positions; }
    //        set { positions = value; }
    //    }
    //    public double Price
    //    {
    //        get { return price; }
    //        set { price = value; }
    //    }


    //}

    public static class ClearingHouse
    {

        static ReaderWriterLockSlim rw = new ReaderWriterLockSlim();
        public static bool checkTraderMargin(Order newOrder)
        {
            double accountBalance;
            double requiredMargin;
            double newInitialOrderMargin;
            double newOrderMaintMargin;
            int curQuantity;
            double price;

            
            //rw.EnterWriteLock();
            if (newOrder.OrderAction == "DELETE") // will be handled when exchange sends confirmation
            {
                //trader log will be updated when trade is executed
                return true;
            }
            XmlDocument doc = new XmlDocument();
            String traderLog = Environment.CurrentDirectory.ToString() + "\\clearingLog.xml"; //can do this but would have to put the xml in bin folder
            String ID = newOrder.CustomerID.ToString();
            

            

            rw.EnterUpgradeableReadLock();

            //String traderLog = ConfigurationManager.AppSettings["ClearingTraderLogPath"].ToString();
            doc.Load(@traderLog);

            XmlNode traderNode = doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='" + ID + "']");



            try // may be a better way to do this
            {
                
                accountBalance = Convert.ToDouble(traderNode.SelectSingleNode("Balance").InnerText);
                requiredMargin = Convert.ToDouble(traderNode.SelectSingleNode("RequiredMargin").InnerText);
                newInitialOrderMargin = newOrder.LimitPrice * newOrder.Quantity * Convert.ToDouble(ConfigurationManager.AppSettings["initialMargin"]);
                double maint = Convert.ToDouble(ConfigurationManager.AppSettings["maintMargin"]);
                newOrderMaintMargin = newOrder.LimitPrice * newOrder.Quantity * Convert.ToDouble(ConfigurationManager.AppSettings["maintMargin"]);

                if (accountBalance - requiredMargin > newInitialOrderMargin)
                {//will need to update for stop orders and market orders
                    //send order to exchange
                    rw.TryEnterWriteLock(100000);
                    
                    //need to think of a better way to do this update required margin
                    curQuantity = Convert.ToInt32(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText);
                    price = Convert.ToDouble(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText);
                    price = (price * curQuantity + newOrder.Quantity * newOrder.LimitPrice) / (curQuantity + newOrder.Quantity);
                    traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText = price.ToString("#.##");
                    traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText = (newOrder.Quantity + curQuantity).ToString();
                    traderNode.SelectSingleNode("RequiredMargin").InnerText = (requiredMargin + newOrderMaintMargin).ToString("#.##");
                    doc.Save(@traderLog);
                    rw.ExitWriteLock();
                }
                else
                {
                    rw.ExitUpgradeableReadLock();
                    Console.WriteLine("not enough margin");
                    return false;
                }
                
                
                return true;
                ////////////

                //traderLog = Environment.CurrentDirectory.ToString() + "\\clearingLog.xml";

                //XDocument objDoc = XDocument.Load(traderLog);
                //var acctBal = objDoc.Descendants("Balance");
                
                //foreach (var bal in acctBal)
                //{
                //    Console.WriteLine(bal);
                //}
            }
            catch(Exception e)
            {
                //rw.ExitWriteLock();
                Console.WriteLine(e.ToString());
                Console.WriteLine("No trader with id: {0}", ID);  // send order back to client no account with clearing house
                return false;
            }

        }

        public static void tradeExecuted(ExecutedOrders newOrder)
        {
            double accountBalance;
            double requiredMargin;
            int curQuantity;
            double price;
            double newPrice;

            
            XmlDocument doc = new XmlDocument();
            String traderLog = Environment.CurrentDirectory.ToString() + "\\clearingLog.xml";// can do this but would have to put the xml in bin folder
            //String traderLog = ConfigurationManager.AppSettings["ClearingTraderLogPath"].ToString();

            String ID = newOrder.CustomerID.ToString();

            rw.TryEnterUpgradeableReadLock(1000);
            doc.Load(@traderLog);
            

            XmlNode traderNode = doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='" + ID + "']");


            
            if ((newOrder.OrderAction == "DELETE" && newOrder.Status == "E") || newOrder.Status == "D") //E for executed D for denied
            {
                
                //remove order from trade log and update req margin
                curQuantity = Convert.ToInt32(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText);
                price = Convert.ToDouble(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText);
                newPrice = (price * curQuantity - newOrder.ExecutionQuantity * newOrder.LimitPrice) / (curQuantity - newOrder.ExecutionQuantity);
                requiredMargin = Convert.ToDouble(traderNode.SelectSingleNode("RequiredMargin").InnerText);
                requiredMargin = (requiredMargin - (newOrder.LimitPrice * newOrder.ExecutionQuantity) * Convert.ToDouble(ConfigurationManager.AppSettings["maintMargin"]));
               

                rw.TryEnterWriteLock(1000);
                traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText = newPrice.ToString("#.##");
                 //traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.ExecutionPrice + "']/Quantity").InnerText = (newOrder.Quantity + curQuantity).ToString();

                 traderNode.SelectSingleNode("RequiredMargin").InnerText = (requiredMargin).ToString("#.##");

            }
            else
            {
                accountBalance = Convert.ToDouble(traderNode.SelectSingleNode("Balance").InnerText);
                curQuantity = Convert.ToInt32(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText);
                price = Convert.ToDouble(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText);
                newPrice = (price * curQuantity - newOrder.ExecutionQuantity * (newOrder.LimitPrice - newOrder.ExecutionPrice)) / (curQuantity);
                requiredMargin = Convert.ToDouble(traderNode.SelectSingleNode("RequiredMargin").InnerText);
                requiredMargin = (requiredMargin + (newPrice - price) * newOrder.ExecutionQuantity);

                rw.TryEnterWriteLock(1000);
                traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText = newPrice.ToString("#.##");
                
                //traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.ExecutionPrice + "']/Quantity").InnerText = (newOrder.Quantity + curQuantity).ToString();

                
                traderNode.SelectSingleNode("RequiredMargin").InnerText = (requiredMargin).ToString("#.##");


                if (accountBalance < requiredMargin)
                {//\
                    // do something here, either cancel order or ask for a deposit
                }
            }
            doc.Save(@traderLog);
            rw.ExitWriteLock();
        }

    }
}





