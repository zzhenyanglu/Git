using System;
using System.Collections;
using System.Collections.Generic;
using OME.Storage;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Xml.Serialization;
using System.Xml.Linq;
using System.Xml;
using System.Xml.XPath;
using System.Configuration;

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
                    LeafContainer.openPriceFound.WaitOne();
                    while (mktOrderQueue.Count > 0)// Market orders get priority
                    {
                        Order order = mktOrderQueue.Dequeue() as Order;
                        //bizDomain.OrderBook.ProcessMktOrder(order);
                        Task.Factory.StartNew(() => bizDomain.OrderBook.Process(order));
                    }
                    if (msgQueue.Count > 0)
                    {
                        Order order2 = msgQueue.Dequeue() as Order;
                        //bizDomain.OrderBook.Process(order2);
                        if (order2.OrderType == "LIMIT")
                            Task.Factory.StartNew(() => bizDomain.OrderBook.Process(order2));
                        else
                            Task.Factory.StartNew(() => bizDomain.OrderBook.ProcessStopOrder(order2));
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
        static String IDs="";

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
        

        public void SubmitOrder(Order order, string procName = "")
        {
            IDs += order.OrderID.ToString() + ",";
            procName = (procName ==""? order.Instrument : procName);
            Console.WriteLine("Order number " +order.OrderID);
            
            if (order.OrderAction=="NEW")
                {
                    orderBook.ordersInProcess.Add(order.OrderID.ToString(), order);//stop orders are not getting pulled off 
                    if (!ValidateOrder(order))
                    {
                        Console.WriteLine("order can not be processed " + order.Message.ToString()); // actually change this to return order to sender order.message should contain the reason
                        orderBook.ordersInProcess.Remove(order.OrderID.ToString());
                        order.OrderAction = "RETURNED";

                        ExecutedOrdersToSend.TcpClientTest.Connect(EquityMatchingEngine.OMEHost.ToXML(order));//send order can not be filled back to client
                        //send order back to client
                    }
                    else
                    {
                        //orderBook.ordersInProcess.Add(order.OrderID.ToString(), order);
                        OrderProcessor orderProcessor = oprocItems[procName] as OrderProcessor;
                        if (order.OrderType.ToString() == "MARKET")
                            orderProcessor.EnQueueMkt(order);
                        else
                            orderProcessor.EnQueue(order);
                    }
            }
            else if (order.OrderAction == "UPDATE")
            {
                UpdateOrder(order);
            }
            else if (order.OrderAction == "DELETE")
            {
                DeleteOrder(order.Instrument, order);
            }
            else { Console.WriteLine("Invalid Order Action"); }

        }
        //   Jason validates incoming orders
        private bool ValidateOrder(Order order)
        {
            bool marginCheck;
            
            
            //marginCheck = true; // ClearingHouse.checkTraderMargin(order); // turned off for now
            
            
            if(!oprocItems.Contains(order.Instrument))
            {
                order.Message = order.Instrument +" is not a valid instrument";
                return false;
            }
            if(order.BuySell != "B" && order.BuySell != "S")
            {
                order.Message ="Have not stated whether order is to buy or sell";
                return false;
            }
            if(order.OrderType != "STOP" && order.OrderType != "LIMIT" && order.OrderType != "MARKET")
            {
                order.Message = "Not a valid order type, only allowed orders are 'Market', 'Limit', 'Stop'";
                return false;
            }
            if (order.LimitPrice < 1.00 && order.OrderType == "LIMIT" || order.StopPrice < 1.00 && order.OrderType == "STOP")
            {
                order.Message = "price too low";
                return false;
            }
            if(order.Active == false)
            {
                order.Message = "Order has been canceled";
                return false;
            }
            //locked for testing
            lock (this) { marginCheck = ClearingHouseTest.CheckMarginAmount(order); }
            if (!marginCheck)
            {
                order.Message = "Does not meet margin requirement";
                return false;
            }
            return true;
        }

        private bool DeleteOrder(string procName, Order delOrder)
        {
            bool deleted;
            if (orderBook.ordersInProcess.ContainsKey(delOrder.OrderID.ToString()) == true)
            {
                Order removeOrder = orderBook.ordersInProcess[delOrder.OrderID.ToString()] as FuturesOrder;
                removeOrder.Active = false;
                delOrder.OrderAction = "DELETED";
                delOrder.Quantity = 0;
                orderBook.ordersInProcess.Remove(removeOrder.OrderID.ToString());
                deleted = true;
            }
            else
                deleted = orderBook.Delete(delOrder);
            if (deleted == true) //also send sucessfully deleted confirmation back to client
            {
                ClearingHouseTest.UpdateMarginForDeletedOrder(delOrder);//used to update margin with actual execution price
                Console.WriteLine("Order Deleted");
            }
            return deleted;
        }


        // This only works if you have the original order instrument, type, and by or sell
        private void UpdateOrder(Order newOrder)// for now assuming orderID, instrument, and BuySell are the same as original order
        {
            bool orderDeleted;
            orderDeleted = DeleteOrder(newOrder.Instrument.ToString(), newOrder);

            if (orderDeleted == true)
            {
                newOrder.OrderAction = "NEW";
                SubmitOrder(newOrder, newOrder.Instrument);
                newOrder.OrderAction = "DELETED";
                newOrder.Message = "Order succesfully deleted";
                ExecutedOrdersToSend.TcpClientTest.Connect(EquityMatchingEngine.OMEHost.ToXML(newOrder));
            }
            else
            {
                Console.WriteLine("Order not found - updated order not submitted"); //send order back to client, can not be completed
                newOrder.OrderAction = "RETURNED";
                newOrder.Message = "Order could not be deleted";
                ExecutedOrdersToSend.TcpClientTest.Connect(EquityMatchingEngine.OMEHost.ToXML(newOrder));
            }
        }
    }
}
