using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using client;
using System.Xml;

namespace server2
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

        public void EnQueue(object order1)
        {

            msgQueue.Enqueue(order1);
            FuturesOrder order = (FuturesOrder)order1;
            Console.WriteLine();
            //    Console.WriteLine("An order submitted: ID " + order.OrderID + " order type " + order.OrderType + " buysell   " + order.BuySell + " Price " + order.Price + " quantity " + order.Quantity + " action " + order.OrderAction);

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

        XmlDocument xmlDoc;
        XmlDocument xmlDocAll;
        private object sync = new object();

        public BizDomain(string domainName, string[] workNames)
        {
            oprocNames = workNames;


        }

        public void insertIntoOrderHistory(Order order)
        {
            XmlNode nodeListAll = xmlDocAll.SelectSingleNode("OrderHistory");//
            //update order history
            XmlElement ord = xmlDocAll.CreateElement("Order");//创建一个节点
            ord.SetAttribute("Instrument", order.Instrument.ToString());
            ord.SetAttribute("OrderID", order.OrderID.ToString());
            ord.SetAttribute("OrderType", order.OrderType.ToString());
            ord.SetAttribute("BuySell", order.BuySell.ToString());
            ord.SetAttribute("Price", order.Price.ToString());
            ord.SetAttribute("Quantity", order.Quantity.ToString());
            ord.SetAttribute("TimeStamp", order.TimeStamp.ToString());
            ord.SetAttribute("Action", order.OrderAction.ToString());
            nodeListAll.AppendChild(ord);

            xmlDocAll.Save("OrderHistroy.xml");
        }

        public void onOrderMatched(MatchedOrderArgs orderArgs,long id1)
        {
            lock (sync)
            {
                XmlNodeList nodeList = xmlDoc.SelectSingleNode("ClearingHouse").ChildNodes;//
                long ID1 = id1 / 100000000;
               

                foreach (XmlNode xn in nodeList)//遍历所有子节点
                {
                    XmlElement xe = (XmlElement)xn;
                    if (long.Parse(xe.GetAttribute("ID")) == ID1)//find trader
                    {
                        int oriTotal = int.Parse(xe.GetAttribute("TotalOrder"));
                        int newTotal = oriTotal - orderArgs.Quantity;
                        if (newTotal < 0) { newTotal = 0; }

                        xe.SetAttribute("TotalOrder", newTotal.ToString());
                        xe.SetAttribute("CurrentQuote", orderArgs.Quote.ToString());

                       

                        double requiredMargin = newTotal * orderArgs.Quote * 0.02 * 0.9;
                        double marginAccount = double.Parse(xe.GetAttribute("MarginAccount"));
                        double bankAccount = double.Parse(xe.GetAttribute("BankAccount"));

                        if (marginAccount >= requiredMargin)
                        {
                            //change order info
                            XmlNodeList nodeListOfOrder = xe.ChildNodes;
                            foreach (XmlNode ordn in nodeListOfOrder)
                            {
                                XmlElement orde = (XmlElement)ordn;
                                if (orde.GetAttribute("OrderID") == id1.ToString())
                                {
                                   // Console.WriteLine(orderArgs.ID1 + " orderArgs.ID1");
                                  
                                    string oriQuantitiy = orde.GetAttribute("Quantity");
                                   // Console.WriteLine(oriQuantitiy + "  oriQuantitiy");

                                    int newQuantity = int.Parse(oriQuantitiy) - orderArgs.Quantity;
                                    orde.SetAttribute("Quantity", newQuantity.ToString());
                                    if (newQuantity < 0)
                                    {
                                        Console.WriteLine("after matching, one order has quantity<0, may be caused by modifying one xml file by multithreads");
                                        Console.WriteLine("orderId "+id1);
                                    }
                                    if (newQuantity == 0)
                                    {
                                        xe.RemoveChild(orde);
                                    }

                                }
                            }
                        }
                        else if ((marginAccount + bankAccount) >= requiredMargin)
                        {

                            //put more into margin account
                            double amount = (requiredMargin - marginAccount);
                            marginAccount = marginAccount + amount;
                            bankAccount = bankAccount - amount;

                            xe.SetAttribute("MarginAccount", marginAccount.ToString());
                            xe.SetAttribute("BankAccount", bankAccount.ToString());



                            //change order info
                            XmlNodeList nodeListOfOrder = xe.ChildNodes;
                            foreach (XmlNode ordn in nodeListOfOrder)
                            {
                                XmlElement orde = (XmlElement)ordn;
                                if (orde.GetAttribute("OrderID") == id1.ToString())
                                {
                                    string oriQuantitiy = orde.GetAttribute("Quantity");
                                    int newQuantity = int.Parse(oriQuantitiy) - orderArgs.Quantity;
                                    orde.SetAttribute("Quantity", newQuantity.ToString());
                                    if (newQuantity < 0)
                                    {
                                        Console.WriteLine("after matching, one order has quantity<0, may be caused by modifying one xml file by multithreads");
                                    }
                                    if (newQuantity == 0)
                                    {
                                        xe.RemoveChild(orde);
                                    }

                                }
                            }

                        }
                        else
                        {
                            // not have enough money;clear all
                            XmlNodeList nodeListOfOrder = xe.ChildNodes;
                            foreach (XmlNode ordn in nodeListOfOrder)
                            {
                                //Console.WriteLine("delete................");
                                XmlElement orde = (XmlElement)ordn;
                                string instrument = orde.GetAttribute("Instrument");
                                string orderType = orde.GetAttribute("OrderType");
                                string buySell = orde.GetAttribute("BuySell");
                                double price = double.Parse(orde.GetAttribute("Price"));
                                int quantity = int.Parse(orde.GetAttribute("Quantity"));
                                long orderID = long.Parse(orde.GetAttribute("OrderID"));
                                FuturesOrder order = new FuturesOrder(instrument, orderType, buySell, price, quantity, "Cancel");
                                order.OrderID = orderID;
                                SubmitOrder("MSFT", order);
                                insertIntoOrderHistory(order);
    
                                xe.RemoveChild(ordn);
                            }

                            xe.SetAttribute("TotalOrder","0");
                        }

                    }
                }

                xmlDoc.Save("ClearingHouse.xml");
            }



        }

        public void deleteOrder(Order order)
        {
            lock (sync)
            {
                XmlNodeList nodeList = xmlDoc.SelectSingleNode("ClearingHouse").ChildNodes;//

                foreach (XmlNode xn in nodeList)//遍历所有子节点
                {
                    XmlElement xe = (XmlElement)xn;//将子节点类型转换为XmlElement类型
                    long traderId = order.OrderID / 100000000;

                    if (long.Parse(xe.GetAttribute("ID")) == traderId)//find trader
                    {
                        XmlNodeList nodeListOfOrder = xe.ChildNodes;
                        foreach (XmlNode ordn in nodeListOfOrder)
                        {
                            XmlElement orde = (XmlElement)ordn;
                            if (orde.GetAttribute("OrderID") == order.OrderID.ToString())
                            {

                                int deduction = int.Parse(orde.GetAttribute("Quantity"));
                                int oriTotal = int.Parse(xe.GetAttribute("TotalOrder"));
                                int newTotal = oriTotal - deduction;
                                xe.SetAttribute("TotalOrder", newTotal.ToString());
                                xe.RemoveChild(orde);
                                xmlDoc.Save("ClearingHouse.xml");
                                return;
                            }
                        }
                    }
                }
            }

        }

        public bool checkMargin(Order order)
        {

            lock (sync)
            {
                if (order.Quantity > 100) { return false; }//also we could set other criteria 


                XmlNodeList nodeList = xmlDoc.SelectSingleNode("ClearingHouse").ChildNodes;//

                if (order.OrderAction == "Cancel")
                {

                    insertIntoOrderHistory(order);

                    foreach (XmlNode xn in nodeList)//遍历所有子节点
                    {
                        XmlElement xe = (XmlElement)xn;//将子节点类型转换为XmlElement类型
                        long traderId = order.OrderID / 100000000;

                        if (long.Parse(xe.GetAttribute("ID")) == traderId)//find trader
                        {
                            XmlNodeList nodeListOfOrder = xe.ChildNodes;
                            foreach (XmlNode ordn in nodeListOfOrder)
                            {
                                XmlElement orde = (XmlElement)ordn;
                                if (orde.GetAttribute("OrderID") == order.OrderID.ToString())
                                {

                                    int deduction = int.Parse(orde.GetAttribute("Quantity"));
                                    int oriTotal = int.Parse(xe.GetAttribute("TotalOrder"));
                                    int newTotal = oriTotal - deduction;
                                    xe.SetAttribute("TotalOrder", newTotal.ToString());
                                    xe.RemoveChild(orde);
                                    xmlDoc.Save("ClearingHouse.xml");
                                    return true;
                                }
                            }
                        }
                    }
                    return true;
                }

                if (order.OrderAction == "New")
                {
                    foreach (XmlNode xn in nodeList)//遍历所有子节点
                    {
                        XmlElement xe = (XmlElement)xn;//将子节点类型转换为XmlElement类型
                        long traderId = order.OrderID / 100000000;

                        if (long.Parse(xe.GetAttribute("ID")) == traderId)//find trader
                        {

                            int currentOrderNum = int.Parse(xe.GetAttribute("TotalOrder"));
                            double currentQuote = double.Parse(xe.GetAttribute("CurrentQuote"));
                            double requiredMargin = currentOrderNum * currentQuote * 0.02 * 0.9 + order.Quantity * currentQuote * 0.02;
                            Console.WriteLine("Required Margin: " + requiredMargin);

                            //check margin account and bank account
                            double marginAccount = double.Parse(xe.GetAttribute("MarginAccount"));
                            double bankAccount = double.Parse(xe.GetAttribute("BankAccount"));

                            if (marginAccount >= requiredMargin)
                            {
                                insertIntoOrderHistory(order);

                                //add order
                                XmlElement ord = xmlDoc.CreateElement("Order");//创建一个节点
                                ord.SetAttribute("Instrument", order.Instrument.ToString());
                                ord.SetAttribute("OrderID", order.OrderID.ToString());
                                ord.SetAttribute("OrderType", order.OrderType.ToString());
                                ord.SetAttribute("BuySell", order.BuySell.ToString());
                                ord.SetAttribute("Price", order.Price.ToString());
                                ord.SetAttribute("Quantity", order.Quantity.ToString());
                                ord.SetAttribute("TimeStamp", order.TimeStamp.ToString());
                                xe.AppendChild(ord);

                                int oriTotal = int.Parse(xe.GetAttribute("TotalOrder"));
                                int newTotal = oriTotal + order.Quantity;
                                xe.SetAttribute("TotalOrder", newTotal.ToString());

                                xmlDoc.Save("ClearingHouse.xml");
                                return true;
                            }
                            else if ((marginAccount + bankAccount) >= requiredMargin)
                            {
                                //put more into margin account
                                double amount = (requiredMargin - marginAccount);
                                marginAccount = marginAccount + amount;
                                bankAccount = bankAccount - amount;

                                xe.SetAttribute("MarginAccount", marginAccount.ToString());

                                xe.SetAttribute("BankAccount", bankAccount.ToString());

                                //add order
                                XmlElement ord = xmlDoc.CreateElement("Order");//创建一个节点
                                ord.SetAttribute("Instrument", order.Instrument.ToString());
                                ord.SetAttribute("OrderID", order.OrderID.ToString());
                                ord.SetAttribute("OrderType", order.OrderType.ToString());
                                ord.SetAttribute("BuySell", order.BuySell.ToString());
                                ord.SetAttribute("Price", order.Price.ToString());
                                ord.SetAttribute("Quantity", order.Quantity.ToString());
                                ord.SetAttribute("TimeStamp", order.TimeStamp.ToString());

                                xe.AppendChild(ord);
                                int oriTotal = int.Parse(xe.GetAttribute("TotalOrder"));
                                int newTotal = oriTotal + order.Quantity;
                                xe.SetAttribute("TotalOrder", newTotal.ToString());

                                xmlDoc.Save("ClearingHouse.xml");
                                insertIntoOrderHistory(order);
                                return true;
                            }
                            else
                            {
                                return false;
                            }
                        }
                    }
                }
                if (order.OrderAction == "Update")
                {
                  
                    foreach (XmlNode xn in nodeList)//遍历所有子节点
                    {
                        XmlElement xe = (XmlElement)xn;//将子节点类型转换为XmlElement类型
                        long traderId = order.OrderID / 100000000;

                        //Console.WriteLine("enter..." + order.OrderID);
                        if (long.Parse(xe.GetAttribute("ID")) == traderId)//find trader
                        {
                            XmlNodeList nodeListOfOrder = xe.ChildNodes;
                            foreach (XmlNode ordn in nodeListOfOrder)
                            {
                                XmlElement orde = (XmlElement)ordn;
                                if (orde.GetAttribute("OrderID") == order.OrderID.ToString())
                                {
                                   
                                    int change = order.Quantity - int.Parse(orde.GetAttribute("Quantity"));
                                    int oriTotal = int.Parse(xe.GetAttribute("TotalOrder"));
                                    int newTotal = oriTotal + change;
                                   

                                    if (change > 0)
                                    {
                                        //update marginaccount and bankaccount
                                        double marginAccount = double.Parse(xe.GetAttribute("MarginAccount"));
                                        double bankAccount = double.Parse(xe.GetAttribute("BankAccount"));
                                        double currentQuote = double.Parse(xe.GetAttribute("CurrentQuote"));
                                        double requiredMargin = marginAccount + change * currentQuote * 0.02;
                                        Console.WriteLine("Required Margin: " + requiredMargin);

                                        if (marginAccount >= requiredMargin)
                                        {
                                            insertIntoOrderHistory(order);
                                            orde.SetAttribute("Quantity", order.Quantity.ToString());
                                            orde.SetAttribute("Price", order.Price.ToString());
                                            xe.SetAttribute("TotalOrder", newTotal.ToString());

                                            return true;
                                        }

                                        if ((marginAccount + bankAccount) >= requiredMargin)
                                        {
                                            double amount = (requiredMargin - marginAccount);

                                            marginAccount = marginAccount + amount;

                                            bankAccount = bankAccount - amount;


                                            xe.SetAttribute("MarginAccount", marginAccount.ToString());
                                            xe.SetAttribute("BankAccount", bankAccount.ToString());
                                            orde.SetAttribute("Quantity", order.Quantity.ToString());
                                            orde.SetAttribute("Price", order.Price.ToString());
                                            xe.SetAttribute("TotalOrder", newTotal.ToString());
                                            insertIntoOrderHistory(order);
                                            return true;

                                        }
                                        else
                                        {
                                            return false;
                                        }
                                    }
                                    else
                                    {
                                        orde.SetAttribute("Quantity", order.Quantity.ToString());
                                        orde.SetAttribute("Price", order.Price.ToString());
                                        xe.SetAttribute("TotalOrder", newTotal.ToString());
                                        insertIntoOrderHistory(order);
                                    }

                                    xmlDoc.Save("ClearingHouse.xml");
                                    return true;
                                }
                            }
                        }
                    }
                }

                return false;
            }
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

            xmlDoc = new XmlDocument();
            XmlDeclaration dec = xmlDoc.CreateXmlDeclaration("1.0", "utf-8", null);
            xmlDoc.AppendChild(dec);

            //创建根节点 
            XmlElement root = xmlDoc.CreateElement("ClearingHouse");
            xmlDoc.AppendChild(root);

            XmlElement xe1 = xmlDoc.CreateElement("Trader");//创建一个节点
            xe1.SetAttribute("ID", "1");//设置该节点ID属性
            xe1.SetAttribute("BankAccount", "500");//设置该节点BankAccount属性
            xe1.SetAttribute("MarginAccount", "0");//设置该节点Margin属性
            xe1.SetAttribute("TotalOrder", "0");//设置该节点number of order属性
            xe1.SetAttribute("CurrentQuote", "20.0");//设置该节点ID属性

            /* XmlElement ord = xmlDoc.CreateElement("Order");//创建一个节点
             ord.SetAttribute("Instrument", "MSFT");
             ord.SetAttribute("OrderID", "100000000");
             ord.SetAttribute("OrderType", "Limit");
             ord.SetAttribute("BuySell", "B");
             ord.SetAttribute("Price", "10");
             ord.SetAttribute("Quantity", "100");
             ord.SetAttribute("TimeStamp", "this order is just for xml test");
 
             xe1.AppendChild(ord);
             */
            root.AppendChild(xe1);//添加到节点中



            XmlElement xe2 = xmlDoc.CreateElement("Trader");//创建一个节点
            xe2.SetAttribute("ID", "2");//设置该节点ID属性
            xe2.SetAttribute("BankAccount", "1000");//设置该节点BankAccount属性
            xe2.SetAttribute("MarginAccount", "0");//设置该节点Margin属性
            xe2.SetAttribute("TotalOrder", "0");//设置该节点number of order属性
            xe2.SetAttribute("CurrentQuote", "20.0");//设置该节点ID属性

            root.AppendChild(xe2);//添加到节点中

            XmlElement xe3 = xmlDoc.CreateElement("Trader");//创建一个节点
            xe3.SetAttribute("ID", "3");//设置该节点ID属性
            xe3.SetAttribute("BankAccount", "30");//设置该节点BankAccount属性
            xe3.SetAttribute("MarginAccount", "0");//设置该节点Margin属性
            xe3.SetAttribute("TotalOrder", "0");//设置该节点number of order属性
            xe3.SetAttribute("CurrentQuote", "20.0");//设置该节点ID属性

            root.AppendChild(xe3);//添加到节点中

            xmlDoc.Save("ClearingHouse.xml");

        }
        public void Start2()
        {

            xmlDocAll = new XmlDocument();
            XmlDeclaration dec = xmlDocAll.CreateXmlDeclaration("1.0", "utf-8", null);
            xmlDocAll.AppendChild(dec);

            //创建根节点 
            XmlElement root = xmlDocAll.CreateElement("OrderHistory");
            xmlDocAll.AppendChild(root);


            xmlDocAll.Save("OrderHistroy.xml");



        }
        public void SubmitOrder(string procName, Order order)
        {
            OrderProcessor orderProcessor = oprocItems[procName] as OrderProcessor;
            orderProcessor.EnQueue(order);


        }








    }
}
