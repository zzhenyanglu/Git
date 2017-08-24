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
                processSignaller.Reset();

                if (msgQueue.Count > 0)
                {

                    Order order2 = msgQueue.Dequeue() as Order;
                    bizDomain.OrderBook.Process(order2);
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
            /*string goodOrder = ValidateOrder(order);
            if (goodOrder != "")
            {
                Console.WriteLine(goodOrder); // actually change this to return order to sender
                //return;
            }
            else
            {
                */
            //Console.WriteLine("enter......");
            //orderBook.ordersInProcess.Add(order.OrderID.ToString(), order);
            OrderProcessor orderProcessor = oprocItems[procName] as OrderProcessor;
            //  if (order.OrderType.ToString() == "Market")
            //      orderProcessor.EnQueueMkt(order);
            //   else
            orderProcessor.EnQueue(order);
            //  }

        }

    




        // This only works if you have the original order instrument, type, and by or sell

    }
}
