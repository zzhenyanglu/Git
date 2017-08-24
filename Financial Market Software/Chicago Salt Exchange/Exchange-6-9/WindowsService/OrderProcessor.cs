using System;
using System.Collections;
using System.Collections.Generic;
using OME.Storage;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace OME
{
    class OrderProcessor
    {
        Queue msgQueue;
        Queue mktOrderQueue;
        Thread msgDispatcher;
        ManualResetEvent processSignaller;
        BizDomain bizDomain;

        public OrderProcessor(BizDomain domain, string wspName)
        {
            bizDomain = domain;
            msgQueue = Queue.Synchronized(new Queue());
            mktOrderQueue = Queue.Synchronized(new Queue());
            processSignaller = new ManualResetEvent(false);
            msgDispatcher = new Thread(new ThreadStart(ProcessQueue));

            msgDispatcher.Start();
        }

        public void EnQueue(object newOrder)
        {
            msgQueue.Enqueue(newOrder);
            processSignaller.Set();
        }
        public void EnQueueMkt(object newOrder)
        {
            mktOrderQueue.Enqueue(newOrder);
            processSignaller.Set();
        }
        private void ProcessQueue()
        {
            while (true)
            {
                processSignaller.WaitOne(1000, false);
                while ((msgQueue.Count + mktOrderQueue.Count) > 0)
                {
                    while (mktOrderQueue.Count > 0)// Market orders get priority
                    {
                        Order order = mktOrderQueue.Dequeue() as Order;
                        //bizDomain.OrderBook.ProcessMktOrder(order);
                        Task.Factory.StartNew(() => bizDomain.OrderBook.ProcessMktOrder(order));
                    }
                    if (msgQueue.Count > 0)
                    {
                        Order order2 = msgQueue.Dequeue() as Order;
                        //bizDomain.OrderBook.Process(order2);
                        if (order2.OrderType == "Stop")
                            Task.Factory.StartNew(() => bizDomain.OrderBook.ProcessStopOrder(order2));
                        else
                            Task.Factory.StartNew(() => bizDomain.OrderBook.Process(order2));
                    }
                }
            }
        }
    }
    public class BizDomain
    {
        private Hashtable oprocItems = Hashtable.Synchronized(new Hashtable());
        private string[] oprocNames;
        private OrderBook orderBook = new OrderBook();
        

        public BizDomain(string domainName, string[] workNames)
        {
            oprocNames = workNames;
        }
        public OrderBook OrderBook
        {
            get { return orderBook; }
        }
        public void Start()
        {
            for (int ctr = 0; ctr < oprocNames.Length; ctr++)
            {
                OrderProcessor wrkObj = new OrderProcessor(this, oprocNames[ctr]);
                oprocItems[oprocNames[ctr]] = wrkObj;
            }
        }

        public void SubmitOrder(string procName, Order order)
        {
            string goodOrder = ValidateOrder(order);
            if (goodOrder != "")
            {
                Console.WriteLine(goodOrder); // actually change this to return order to sender
                //return;
            }
            else
            {
                orderBook.ordersInProcess.Add(order.OrderID.ToString(), order);
                OrderProcessor orderProcessor = oprocItems[procName] as OrderProcessor;
                if (order.OrderType.ToString() == "Market")
                    orderProcessor.EnQueueMkt(order);
                else
                    orderProcessor.EnQueue(order);
            }
        }

        public string ValidateOrder(Order order)// we'll probably change the type just made it string for now
        {
            // here we will check that quatity, price, order type, instrument, and buysell are all valid
            string errorMessage=""; //this is just for now

            errorMessage += oprocItems.Contains(order.Instrument) == false ? "Not valid instrument/" : "";
            errorMessage += order.BuySell != "B" && order.BuySell != "S" ? "Have not stated whether order is to buy or sel/l" : "";
            errorMessage += order.OrderType != "Stop" && order.OrderType != "Limit" && order.OrderType != "Market" ? "Not a valid order type, only allowed orders are 'Market', 'Limit', 'Stop'/" : "";
            errorMessage += order.Quantity > 50000000 ? "Too large of order/" : ""; //we can decided what to put here, probably have to make it a variable that can be updated based on order volume
            errorMessage += order.Price > 50000000 ? "Price too high/" : order.Price < .01 ? "price too low/" : ""; //prob use another variable here just need to decide what kind of range we should allow
            errorMessage += order.Active == false ? "Order has been canceled/" : "";
            if (errorMessage == "")
                return errorMessage;
            else
                return errorMessage;
        }

        public bool DeleteOrder(string procName, Order delOrder)
        {
            bool deleted;
            if (orderBook.ordersInProcess.ContainsKey(delOrder.OrderID.ToString()) == true)
            {
                Order removeOrder = orderBook.ordersInProcess[delOrder.OrderID.ToString()] as Order;
                removeOrder.Active = false;
                orderBook.ordersInProcess.Remove(removeOrder.OrderID.ToString());
                deleted = true;
            }
            else
                deleted = orderBook.Delete(delOrder);
            if (deleted == true) Console.WriteLine("Order successfully deleted");
            return deleted;
        }

        public void PriceQuote(string Instrument, string BuySell)
        {
            Console.WriteLine(orderBook.CurrentPrice(Instrument, BuySell).Price.ToString());
        }

        // This only works if you have the original order instrument, type, and by or sell
        public void UpdateOrder(Order newOrder, Order origOrder)
        {
            bool orderDeleted;
            orderDeleted = DeleteOrder(origOrder.Instrument.ToString(), origOrder);
            

            if (orderDeleted == true)
            {
                orderBook.ordersInProcess.Add(newOrder.OrderID.ToString(), newOrder);
                OrderProcessor orderProcessor = oprocItems[newOrder.Instrument] as OrderProcessor;
                orderProcessor.EnQueue(newOrder);
                Console.WriteLine("Updated order being submited");
            }
            else
                Console.WriteLine("Order not found - updated order not submitted");
        }
    }
}
