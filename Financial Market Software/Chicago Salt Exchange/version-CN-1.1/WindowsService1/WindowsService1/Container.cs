using System;
using System.Collections.Generic;
using System.Collections;
using System.Data;
using System.Threading;
using client;

namespace server2
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
        //   private static int usingResource = 0;
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
        public void ProcessStopOrder(Order order)
        {
            //   Console.WriteLine("enter leafContainer.processStoporder");
            Container buyBook = parentContainer.ChildContainers["B"];
            Container sellBook = parentContainer.ChildContainers["S"];

            OrderEventArgs orderArgs = new OrderEventArgs(order, buyBook, sellBook);
            orderBook.OnStopToMarket(orderArgs);


        }
        public override void ProcessOrder(Order newOrder)
        {
           // Console.WriteLine("enter.. ProcessOrder(Order newOrder)");

            Container buyBook = parentContainer.ChildContainers["B"];
            Container sellBook = parentContainer.ChildContainers["S"];

            OrderEventArgs orderArgs = new OrderEventArgs(newOrder, buyBook, sellBook);

          

            if (newOrder.OrderType != "Stop")
                orderBook.OnOrderBeforeInsert(orderArgs);

        
            if (newOrder.Quantity > 0 && newOrder.OrderAction == "New")
            {
                orderDataStore.Add(newOrder);
              //  Console.WriteLine("An order added. ID " + newOrder.OrderID + " order type " + newOrder.OrderType + " buysell   " + newOrder.BuySell + " Price " + newOrder.Price + " quantity " + newOrder.Quantity + " action " + newOrder.OrderAction);
                if (newOrder.OrderType == "Limit")
                {
                    orderDataStore.Sort(orderBook.OrderPriority);
                }
                else
                {
                    
                    orderDataStore.Sort(orderBook.OrderPriorityForMarket);
                }
                
            }
            else if (newOrder.Quantity > 0 && newOrder.OrderAction == "Update")
            {

                if (newOrder.OrderType == "Limit")
                {
                    orderDataStore.Sort(orderBook.OrderPriority);
                }
                else
                {
                    orderDataStore.Sort(orderBook.OrderPriorityForMarket);
                }


            }

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
