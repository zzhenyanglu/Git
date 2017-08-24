using System;
using System.Collections.Generic;
using System.Collections;
using System.Data;
using System.Threading;
using System.Xml;
using System.Xml.Linq;

namespace OME.Storage
{

    public class Container : IEnumerable 
    {
        protected string contName;
        public ManualResetEvent newQuote;
        //public ManualResetEvent openPriceFound;
        protected ContainerCollection leafItems = new ContainerCollection();
        protected OrderBook orderBook;
        protected Container parentContainer;
        public static double currentPrice;

        public ContainerCollection ChildContainers
        {
            get { return leafItems; }
        }

        public Container(OrderBook oBook, string name, Container parent)
        {
            orderBook = oBook;
            contName = name;
            parentContainer = parent;
            
        }

        public virtual void ProcessOrder(Order newOrder)
        { }
        public virtual void CheckStopOrders()
        { }
        public virtual void AddStopOrder(Order newOrder)
        { }
        public virtual object CurrentMktOrder
        { get { return true; } }
        public virtual bool MoveNextMktOrder()
        { return true; }
        public virtual void ResetMktOrder()
        { }
        public virtual object Current
        { get { return true; } }
        public virtual bool MoveNext()
        { return true; }
        public virtual void Reset()
        { }
        public virtual IEnumerator GetEnumerator()
        {
            return null;
        }

        public void newPriceQuote(Object a)
        {
            while (true)
            {
                newQuote.WaitOne(10000, false);

                LeafContainer buyBook = this.parentContainer.ChildContainers["B"] as LeafContainer;
                LeafContainer sellBook = this.parentContainer.ChildContainers["S"] as LeafContainer;
                
                if (buyBook != null && sellBook != null)
                {

                    


                    if (buyBook.OrderQuote() == "" || sellBook.OrderQuote() == "")
                        Console.WriteLine("No price");

                    string buyBookQuote = buyBook.OrderQuote();
                    string sellBookQuote = sellBook.OrderQuote();

                    //currentPrice = buyBookQuote == "N/A" ? Convert.ToDouble(sellBookQuote) : sellBookQuote == "N/A" ? 
                    //    Convert.ToDouble(buyBookQuote) : (Convert.ToDouble(buyBook.OrderQuote()) + Convert.ToDouble(sellBook.OrderQuote())) / 2.0;

                    XElement xml = new XElement("Method");
                    xml.Add(new XAttribute("PriceQuote", "RSXM"));
                    xml.Add(new XElement("Field", new XAttribute("Name", "Buy"), buyBookQuote),
                    new XElement("Field", new XAttribute("Name", "Sell"), sellBookQuote));


                    string quote = this.parentContainer.contName + "," + buyBook.OrderQuote() + "," + sellBook.OrderQuote();
                    Exchange.QuoteSender.sendQuote(xml.ToString());
                }
                newQuote.Reset();
            }
        }
    }

    public class ContainerCollection
    {
        Hashtable contCollection = new Hashtable();

        public bool Exists(string containerName)
        {
            return contCollection.ContainsKey(containerName);
        }
        public Container this[string name]
        {
            get { return contCollection[name] as Container; }
            set { contCollection[name] = value; }
        }

    }

    public class LeafContainer : Container, IEnumerable, IEnumerator
    {
        private int rowPos = -1;
        private int rowPosMktOrder = -1;
        private static int usingResource = 0;
        public static bool exchangeRunning = false;
        //Queue tmpQueue = new Queue();
        ArrayList orderDataStore = ArrayList.Synchronized(new ArrayList());
        ArrayList stopOrderDataStore = ArrayList.Synchronized(new ArrayList());
        ArrayList tmpMktorderDataStore = ArrayList.Synchronized(new ArrayList());
        public static ManualResetEvent openPriceFound = new ManualResetEvent(true);
        public LeafContainer(OrderBook oBook, string name, Container parent)
            : base(oBook, name, parent)
        {
            newQuote = new ManualResetEvent(false);
            ThreadPool.QueueUserWorkItem(new WaitCallback(newPriceQuote)); 
        }


        public override IEnumerator GetEnumerator()
        {
            Reset();
            return this;
        }

        public void OpenExchange()
        {
            Container buyBook = parentContainer.ChildContainers["B"];
            Container sellBook = parentContainer.ChildContainers["S"];

            OrderEventArgs orderArgs = new OrderEventArgs(buyBook, sellBook);
            orderBook.OnOrderBeforeInsert(orderArgs);

        }
        //Mike B
        public override void ProcessOrder(Order newOrder)
        {
            if (EquityMatchingEngine.OMEHost.open == false)//during staging period
            {
                if(newOrder.OrderType == "MARKET")
                {
                    orderBook.ordersInProcess.Remove(newOrder.OrderID.ToString());//need to put this somewhere else
                    tmpMktorderDataStore.Add(newOrder);
                    tmpMktorderDataStore.Sort(orderBook.OrderPriority);
                }
                else if (newOrder.OrderType == "LIMIT")
                {
                orderBook.ordersInProcess.Remove(newOrder.OrderID.ToString());
                orderDataStore.Add(newOrder);
                orderDataStore.Sort(orderBook.OrderPriority);
                }
                else if (newOrder.OrderType == "STOP")
                {
                    orderBook.ordersInProcess.Remove(newOrder.OrderID.ToString());
                    stopOrderDataStore.Add(newOrder);
                    orderDataStore.Sort(orderBook.OrderPriority);
                }
                return;
            }
            if (exchangeRunning == false && EquityMatchingEngine.OMEHost.open == true)//matched trades already in book
            {
                exchangeRunning = true;
                openPriceFound.Reset();
                OpenExchange();
            }
            openPriceFound.WaitOne();//wait for open

                Container buyBook = parentContainer.ChildContainers["B"];
                Container sellBook = parentContainer.ChildContainers["S"];

                OrderEventArgs orderArgs = new OrderEventArgs(newOrder, buyBook, sellBook);


                orderBook.ordersInProcess.Remove(newOrder.OrderID.ToString());
                if (newOrder.Active == true)
                {
                    orderBook.OnOrderBeforeInsert(orderArgs);

                    if (newOrder.Quantity > 0 && newOrder.OrderType == "MARKET")//no available limit orders to match orders with so send back to client
                    {
                        newOrder.Message = "Order could not be completed, not enough open orders";
                        ExecutedOrdersToSend.TcpClientTest.Connect(EquityMatchingEngine.OMEHost.ToXML(newOrder));
                    }
                    else if (newOrder.Quantity > 0)
                    {
                        orderDataStore.Add(newOrder);

                        orderDataStore.Sort(orderBook.OrderPriority);
                        orderBook.OnOrderInsert(orderArgs);
                    }
                }
                newQuote.Set();
                if (stopOrderDataStore.Count > 0)
                {
                    useResource();
                }
        }
        //Chuan(Nathan)
        public override void AddStopOrder(Order newOrder)
        {

            orderBook.ordersInProcess.Remove(newOrder.OrderID.ToString());
            if (newOrder.Active == true)
            {
                stopOrderDataStore.Add(newOrder);
                stopOrderDataStore.Sort(orderBook.OrderPriority);
            }

        }
        public bool useResource()
        {
            if (0 == Interlocked.Exchange(ref usingResource, 1))
            {
                if (stopOrderDataStore.Count> 0) CheckStopOrders();
                Interlocked.Exchange(ref usingResource, 0);
                return true;
            }
            else return false;
        }
        public bool useResourceAddStop(Order newOrder)
        {
            if (0 == Interlocked.Exchange(ref usingResource, 1))
            {
                AddStopOrder(newOrder);
                Interlocked.Exchange(ref usingResource, 0);
                return true;
            }
            else return false;
        }
        //Chuan(Nathan)
        public override void CheckStopOrders()
        {
            if (orderDataStore.Count < 1) 
                return;
            Order order = orderDataStore[0] as Order;
            Order tmpOrder;
            if (order.BuySell == "B")
            {
                for (int i = 0; i < stopOrderDataStore.Count; i++ )
                {
                    tmpOrder = stopOrderDataStore[i] as Order;
                    if (order.LimitPrice >= tmpOrder.StopPrice)
                    {
                        Console.WriteLine("Stop order {0} converted to market order", order.OrderID.ToString());
                        stopOrderDataStore.Remove(tmpOrder);
                        tmpOrder.OrderType = "MARKET";
                        orderBook.Process(tmpOrder);
                        i--;
                    }
                    else
                        break;
                }
            }
            else
            {
                
                for (int i = 0; i < stopOrderDataStore.Count; i++)
                {
                    tmpOrder = stopOrderDataStore[i] as Order;
                    if (tmpOrder.StopPrice <= order.LimitPrice)
                    {
                        Console.WriteLine("Stop order {0} converted to market order", order.OrderID.ToString());
                        stopOrderDataStore.Remove(tmpOrder);
                        tmpOrder.OrderType = "MARKET";
                        orderBook.Process(tmpOrder);
                        i--;
                    }
                    else
                        break;
                }
            }
        }

        public bool DeleteOrder(Order delOrder)
        {
            if (delOrder.OrderType == "LIMIT")
            {
                foreach (Order order in orderDataStore)
                {
                    if (order.OrderID == delOrder.OrderID)
                    {
                        orderDataStore.Remove(order);
                        return true;
                    }
                }
            }
            else if (delOrder.OrderType == "STOP")
            {
                foreach (Order order in stopOrderDataStore)
                {
                    if (order.OrderID == delOrder.OrderID)
                    {
                        stopOrderDataStore.Remove(order);
                        return true;
                    }
                }
            }
            return false;
        }

        public string OrderQuote()
        {
            if (orderDataStore.Count > 0)
            {
                return (orderDataStore[0] as Order).LimitPrice.ToString("#.##");
            }
            return "N/A";
        }

        public override void Reset()
        {
            rowPos = -1;
        }
        public override object Current
        {
            get { return orderDataStore[rowPos]; }
        }
        public override bool MoveNext()
        {
            rowPos++;
            while (rowPos < orderDataStore.Count)
            {
                Order curOrder = orderDataStore[rowPos] as Order;
                if (curOrder.Quantity == 0)
                    orderDataStore.RemoveAt(rowPos);
                else
                    return true;
            }
            Reset();
            return false;
        }
        public override object CurrentMktOrder
        {
            get { return tmpMktorderDataStore[rowPosMktOrder]; }
        }
        public override bool MoveNextMktOrder()
        {
            rowPosMktOrder++;
            while (rowPosMktOrder < tmpMktorderDataStore.Count)
            {
                Order curOrder = tmpMktorderDataStore[rowPosMktOrder] as Order;
                if (curOrder.Quantity == 0)
                    tmpMktorderDataStore.RemoveAt(rowPosMktOrder);
                else
                    return true;
            }
            ResetMktOrder();
            return false;
        }
        public override void ResetMktOrder()
        {
            rowPosMktOrder = -1;
        }
    }
}
