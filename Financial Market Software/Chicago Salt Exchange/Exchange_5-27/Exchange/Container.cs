using System;
using System.Collections.Generic;
using System.Collections;
using System.Data;
using System.Threading;


namespace OME.Storage
{

    public class Container : IEnumerable 
    {
        protected string contName;

        protected ContainerCollection leafItems = new ContainerCollection();
        protected OrderBook orderBook;
        protected Container parentContainer;

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
        public virtual void ProcessMktOrder(Order newOrder)
        { }
        public virtual void CheckStopOrders()
        { }
        public virtual void AddStopOrder(Order newOrder)
        { }
        public virtual IEnumerator GetEnumerator()
        {
            return null;
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
        private static int usingResource = 0;
        ArrayList orderDataStore = ArrayList.Synchronized(new ArrayList());
        ArrayList stopOrderDataStore = ArrayList.Synchronized(new ArrayList());
        
        //List<List<Order>> newTestOrder = new List<List<Order>>();

        public LeafContainer(OrderBook oBook, string name, Container parent)
            : base(oBook, name, parent)
        { }

        public override IEnumerator GetEnumerator()
        {
            Reset();
            return this;
        }

        public override void ProcessOrder(Order newOrder)
        {


            Container buyBook = parentContainer.ChildContainers["B"];
            Container sellBook = parentContainer.ChildContainers["S"];

            OrderEventArgs orderArgs = new OrderEventArgs(newOrder, buyBook, sellBook);
            orderBook.ordersInProcess.Remove(newOrder.OrderID.ToString());
            if (newOrder.Active == true)
            {
                orderBook.OnOrderBeforeInsert(orderArgs);
                if (newOrder.Quantity > 0)
                {
                    orderDataStore.Add(newOrder);

                    orderDataStore.Sort(orderBook.OrderPriority);
                    orderBook.OnOrderInsert(orderArgs);
                }

                //Thread thread = new Thread(new ThreadStart(orderBook.CheckStopOrders));
            }
            if (stopOrderDataStore.Count > 0)
            {
                useResource();
            }
        }

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

        public override void CheckStopOrders()
        {

            Order order = orderDataStore[0] as Order;

            if (order.BuySell == "B")
            {

                for (int i = 0; i < stopOrderDataStore.Count; i++ )
                {
                    if (order.LimitPrice >= (stopOrderDataStore[i] as Order).StopPrice)
                    {
                        Console.WriteLine("Stop order {0} converted to market order", order.OrderID.ToString());
                        (stopOrderDataStore[i] as Order).OrderType = "Market";
                        orderBook.ProcessMktOrder(stopOrderDataStore[i] as Order);
                        stopOrderDataStore.Remove(stopOrderDataStore[i] as Order);
                    }
                    else
                        break;
                }
            }
            else
            {
                for (int i = 0; i < stopOrderDataStore.Count; i++)
                {
                    if ((stopOrderDataStore[i] as Order).StopPrice <= order.LimitPrice)
                    {
                        (stopOrderDataStore[i] as Order).OrderType = "Market";
                        orderBook.ProcessMktOrder(stopOrderDataStore[i] as Order);
                        stopOrderDataStore.Remove(stopOrderDataStore[i] as Order);
                    }
                    else
                        break;
                }
            }

        }

        public override void ProcessMktOrder(Order newOrder)
        {
            Container buyBook = parentContainer.ChildContainers["B"];
            Container sellBook = parentContainer.ChildContainers["S"];

            OrderEventArgs orderArgs = new OrderEventArgs(newOrder, buyBook, sellBook);
            orderBook.ordersInProcess.Remove(newOrder.OrderID.ToString());
            if (newOrder.Active == true)
                orderBook.OnOrderBeforeInsert(orderArgs);
        }
        public bool DeleteOrder(Order delOrder)
        {
            if (delOrder.OrderType == "Limit")
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
            else if (delOrder.OrderType == "Stop")
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

        public Order OrderQuote()
        {
            return orderDataStore[0] as Order;
        }

        public void Reset()
        {
            rowPos = -1;
        }
        public object Current
        {
            get { return orderDataStore[rowPos]; }
        }
        public bool MoveNext()
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
    }
}
