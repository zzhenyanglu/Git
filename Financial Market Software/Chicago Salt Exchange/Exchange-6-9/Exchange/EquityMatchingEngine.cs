using System;
using System.Collections;
using OME.Storage;
using OME;
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
using System.Windows.Forms;

using ReflectionExamples2;


//this is now a class library so can not run from here, MyNewReflectionExample runs exchange using reflection
//to run using MyNewReflectionExample assembly must be loaded in GAC using gacutil
//run from comand line
//C:\Program Files (x86)\Microsoft SDKs\Windows\v8.0A\bin\NETFX 4.0 Tools\gacutil.exe /i C:\Exchange\Exchange\bin\Debug\Exchange.dll
namespace EquityMatchingEngine
{
    public class OMEHost
    {
        public static bool running = false;
        public static bool open = false;
        public static DateTime startTime;
        public static TimeSpan stagingTime = TimeSpan.FromMinutes(1);//after exchaange is started the exchange takes orders and finds opening price for one minute
        
        //If you want to run as console application instead of class program un comment this and change settings to console app
        //static void Main(string[] args)
        //{
        //     Application.EnableVisualStyles();
        //    Application.SetCompatibleTextRenderingDefault(false);
        //    Application.Run(new Exchange.Form1());
        //    
        //}
        
        public static void Stop()
        {
            if (EquityMatchingEngine.OMEHost.running == true)
            {
                EquityMatchingEngine.OMEHost.running = false;
                
            }
        }

        public static void ContinueExchange()
        {
            //if(EquityMatchingEngine.OMEHost.open == true)
                EquityMatchingEngine.OMEHost.running = true;
        }
        
        //Mutex syncExchange = new Mutex(false, "SyncExchange");
        //[STAThread]
        public static void Start()
        {
            LeafContainer.openPriceFound.Set();
            EquityMatchingEngine.OMEHost.open = false;
            EquityMatchingEngine.OMEHost.running = true;
            
            EquityMatchingEngine.OMEHost.startTime = DateTime.Now;
            ManualResetEvent exchangeOpen = new ManualResetEvent(false);
            ManualResetEvent processSignaller = new ManualResetEvent(false);
            BizDomain equityDomain;
            equityDomain = new BizDomain("Salt Futures", new string[] { "RSXH", "RSXM", "RSXU", "RSXZ" });

            equityDomain.OrderBook.OrderPriority = new PriceTimePriority();

            EquityMatchingLogic equityMatchingLogic = new EquityMatchingLogic(equityDomain);

            equityDomain.Start();

            //starts listening for orders
            Task.Factory.StartNew(() => SynchronousSocketListener.StartListening(equityDomain));
            

            while (true)
            {
                if (DateTime.Now > startTime + stagingTime)
                {
                    //equityDomain.findOpenPrice();
                    open = true;
                    break;
                }
                else
                    exchangeOpen.WaitOne(10);
            }
        }
        public static FuturesOrder LoadFromXMLString(string xmlText)
        {
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(FuturesOrder));
            StringReader stringReader = new StringReader(xmlText /* result is the value from the database */);
            FuturesOrder deserializedEntity = (FuturesOrder)xmlSerializer.Deserialize(stringReader);
            return deserializedEntity as FuturesOrder;
        }
        public static string ToXML(object trade)
        {
            var stringwriter = new System.IO.StringWriter();
            var serializer = new XmlSerializer(trade.GetType());
            serializer.Serialize(stringwriter, trade);
            return stringwriter.ToString();
        }


    }

    public class PriceTimePriority : IComparer
    {
        public int CompareOrder(Order orderx, Order orderY, int sortingOrder)
        {
            int priceComp = orderx.LimitPrice.CompareTo(orderY.LimitPrice);
            if (priceComp == 0)
            {
                int timeComp = orderx.TimeStamp.CompareTo(orderY.TimeStamp);
                return timeComp;
            }
            return priceComp * sortingOrder;
        }
        public int Compare(object x, object y)
        {
            Order orderX = x as Order;
            Order orderY = y as Order;

            if (orderX.BuySell == "B")
                return CompareOrder(orderX, orderY, -1);
            else
                return CompareOrder(orderX, orderY, 1);
        }
    }

    public class EquityMatchingLogic
    {
        public EquityMatchingLogic(BizDomain bizDomain)
        {
            bizDomain.OrderBook.OrderBeforeInsert += new OrderEventHandler(OrderBook_OrderBeforeInsert);
        }
        private void OrderBook_OrderBeforeInsert(object sender, OrderEventArgs e)
        {
            if (e.Order == null)
                MatchOpen(e);
            else if (e.Order.BuySell == "B")
                MatchBuyLogic(e);
            else
                MatchSellLogic(e);
        }
        private void MatchOpen(OrderEventArgs e)
        {
            bool ordersLeft = true;
                double BuyQuantity = 0;
                double  SellQuantity = 0;
                ArrayList matchedLimitOrders = new ArrayList();
                ArrayList matchedMarketOrders = new ArrayList();
                e.BuyBook.Reset();
                e.SellBook.Reset();

                e.BuyBook.MoveNext();
                e.SellBook.MoveNext();

                Order BuyOrder = e.BuyBook.Current as Order;
                Order SellOrder = e.SellBook.Current as Order;
                int quantityMatched;
                while (true)//need to pull the orders off of the datastore
                {
                    if (SellOrder.LimitPrice < BuyOrder.LimitPrice)
                    {
                        if (BuyOrder.Quantity < SellOrder.Quantity)
                        {
                            quantityMatched=BuyOrder.Quantity;
                            BuyQuantity += BuyOrder.Quantity;
                            BuyOrder.Quantity = 0;
                            FuturesOrder executedOrder1 = (FuturesOrder)BuyOrder.Clone();
                            executedOrder1.ExecutionQuantity = quantityMatched;
                            //ExecutedOrders executedOrder1 = new ExecutedOrders(BuyOrder, quantityMatched, 0);
                            //BuyOrder.ExecutionQuantity = quantityMatched;
                            matchedLimitOrders.Add(executedOrder1);
                            SellOrder.Quantity = SellOrder.Quantity - quantityMatched;
                            FuturesOrder executedOrder2 = (FuturesOrder)SellOrder.Clone();
                            executedOrder1.ExecutionQuantity = quantityMatched;

                            //ExecutedOrders executedOrder2 = new ExecutedOrders(SellOrder, quantityMatched, 0);
                            matchedLimitOrders.Add(executedOrder2);
                            
                            if (ordersLeft = e.BuyBook.MoveNext() == false) break;
                            BuyOrder = e.BuyBook.Current as Order;
                        }
                        else
                        {
                            quantityMatched=SellOrder.Quantity;
                            SellQuantity += SellOrder.Quantity;

                            SellOrder.Quantity = 0;
                            BuyOrder.Quantity = BuyOrder.Quantity - quantityMatched;

                            FuturesOrder executedOrder1 = (FuturesOrder)BuyOrder.Clone();//make copy so original order is not effected in case of partial fill
                            executedOrder1.ExecutionQuantity = quantityMatched;

                            FuturesOrder executedOrder2 = (FuturesOrder)SellOrder.Clone();
                            executedOrder1.ExecutionQuantity = quantityMatched;

                            matchedLimitOrders.Add(executedOrder1);
                            
                            //SellOrder.ExecutionQuantity = quantityMatched;
                            matchedLimitOrders.Add(executedOrder2);
                            
                            if(e.SellBook.MoveNext()==false) break;
                            SellOrder = e.SellBook.Current as Order;
                        }
                        
                    }
                    else
                    {
                        break;
                    }
                }

                double openPrice = Math.Round((SellOrder.LimitPrice + BuyOrder.LimitPrice) / 2.0, 2);

                e.BuyBook.ResetMktOrder();
                e.SellBook.ResetMktOrder();
                ordersLeft = true;

                ordersLeft=e.BuyBook.MoveNextMktOrder();
                if (ordersLeft == false)
                {
                    e.SellBook.MoveNextMktOrder();
                    Task.Factory.StartNew(() => e.SellBook.ProcessOrder(e.SellBook.CurrentMktOrder as Order));
                    while (e.SellBook.MoveNextMktOrder())
                        Task.Factory.StartNew(() => e.SellBook.ProcessOrder(e.SellBook.CurrentMktOrder as Order));
                    LeafContainer.openPriceFound.Set();
                    Task.Factory.StartNew(() => processMatchedLimitOrders(matchedLimitOrders, openPrice));
                    return;
                }
                ordersLeft = e.SellBook.MoveNextMktOrder();
                if (ordersLeft == false)
                {
                    e.BuyBook.MoveNextMktOrder();
                    Task.Factory.StartNew(() => e.BuyBook.ProcessOrder(e.BuyBook.CurrentMktOrder as Order));
                    while (e.BuyBook.MoveNextMktOrder())
                        Task.Factory.StartNew(() => e.BuyBook.ProcessOrder(e.BuyBook.CurrentMktOrder as Order));
                    LeafContainer.openPriceFound.Set();
                    Task.Factory.StartNew(() => processMatchedLimitOrders(matchedLimitOrders, openPrice));
                    return;
                }
                    
                Order MktBuyOrder = e.BuyBook.CurrentMktOrder as Order;
                Order MktSellOrder = e.SellBook.CurrentMktOrder as Order;
                int ordersMatched;
            while (true)
            {
                if (MktBuyOrder.Quantity > MktSellOrder.Quantity)
                {
                    ordersMatched = MktSellOrder.Quantity;
                    MktSellOrder.Quantity = 0;
                    //ExecutedOrders executedOrder1 = new ExecutedOrders(MktSellOrder, ordersMatched, openPrice);
                    MktBuyOrder.Quantity = MktBuyOrder.Quantity - ordersMatched;

                    FuturesOrder executedOrder1 = (FuturesOrder)MktSellOrder.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = ordersMatched;
                    FuturesOrder executedOrder2 = (FuturesOrder)MktBuyOrder.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = ordersMatched;

                    matchedMarketOrders.Add(executedOrder1);
                    matchedMarketOrders.Add(executedOrder2);
                    //ExecutedOrders executedOrder2 = new ExecutedOrders(MktBuyOrder, ordersMatched, openPrice);
                    //send executed order back
                    if (e.SellBook.MoveNextMktOrder() == false)
                    {
                        //do something with remaining Market Sell orders
                        LeafContainer.openPriceFound.Set();
                        Task.Factory.StartNew(() => e.BuyBook.ProcessOrder(MktBuyOrder));
                        while (e.BuyBook.MoveNextMktOrder())
                            e.BuyBook.ProcessOrder(e.BuyBook.CurrentMktOrder as FuturesOrder);
                        break;
                    }
                }
                else //(MktBuyOrder.Quantity < MktSellOrder.Quantity)
                {
                    ordersMatched = MktBuyOrder.Quantity;
                    MktBuyOrder.Quantity = 0;
                    //ExecutedOrders executedOrder2 = new ExecutedOrders((e.SellBook.CurrentMktOrder as Order), ordersMatched, openPrice);
                    MktSellOrder.Quantity = MktSellOrder.Quantity - ordersMatched;

                    FuturesOrder executedOrder1 = (FuturesOrder)MktSellOrder.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = ordersMatched;
                    FuturesOrder executedOrder2 = (FuturesOrder)MktBuyOrder.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = ordersMatched;

                    matchedMarketOrders.Add(executedOrder1);
                    matchedMarketOrders.Add(executedOrder2);

                    //ExecutedOrders executedOrder1 = new ExecutedOrders(e.Order, ordersMatched, openPrice);
                    if (e.BuyBook.MoveNextMktOrder() == false)
                    {
                        //do something with remaining Market Buy orders
                        LeafContainer.openPriceFound.Set();
                        Task.Factory.StartNew(() => e.SellBook.ProcessOrder(MktSellOrder));
                        while (e.SellBook.MoveNextMktOrder())
                            e.SellBook.ProcessOrder(e.SellBook.CurrentMktOrder as FuturesOrder);
                        break;
                    }
                }
            }
            LeafContainer.openPriceFound.Set();
            Task.Factory.StartNew(() => processMatchedLimitOrders(matchedLimitOrders, openPrice, matchedMarketOrders));
        }

        private void processMatchedLimitOrders(ArrayList limitOrders, double openPrice, ArrayList marketOrders=null)
        {
            FuturesOrder processOrder;

            

            while (limitOrders.Count > 0)
            {
                processOrder = (limitOrders[0] as FuturesOrder);
                limitOrders.RemoveAt(0);
                if (processOrder.Quantity != 0)
                    Console.WriteLine("0");
                processOrder.executionPrice = openPrice;
                processOrder.ExecutionTimeStamp = DateTime.Now;
                ClearingHouseTest.UpdateMarginForExucutedOrder(processOrder); //to update margin account with execution price
                ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(processOrder));
                //send back to client
            }
            if (marketOrders != null)
            {
                while (marketOrders.Count > 0)
                {
                    processOrder = (marketOrders[0] as FuturesOrder);
                    marketOrders.RemoveAt(0);
                    if (processOrder.Quantity != 0)
                        Console.WriteLine("0");
                    processOrder.executionPrice = openPrice;
                    processOrder.ExecutionTimeStamp = DateTime.Now;
                    //send back to client
                    ClearingHouseTest.UpdateMarginForExucutedOrder(processOrder);//used to update margin with actual execution price
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(processOrder));
                }
            }
        }

        private void MatchBuyLogic(OrderEventArgs e)
        {
            foreach (Order curOrder in e.SellBook)
            {
                if (e.Order.OrderType == "MARKET" && e.Order.Quantity > 0)
                {
                    Console.WriteLine("Match found..Generate Market Order Trade..");
                    int quantity = Math.Min(e.Order.Quantity, curOrder.Quantity); //need to check this 
                    curOrder.Quantity = curOrder.Quantity - quantity;
                    e.Order.Quantity = e.Order.Quantity - quantity;
                    Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.LimitPrice.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
                    // write executed orders to xml file 

                    //records trade info and sends executed order info back to client
                    FuturesOrder executedOrder1 = (FuturesOrder)curOrder.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = quantity;
                    executedOrder1.executionPrice = curOrder.LimitPrice;
                    executedOrder1.ExecutionTimeStamp = DateTime.Now;
                    FuturesOrder executedOrder2 = (FuturesOrder)e.Order.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = quantity;
                    executedOrder2.executionPrice = curOrder.LimitPrice;
                    executedOrder2.ExecutionTimeStamp = DateTime.Now;
                    //send executed order back to client
                    ClearingHouseTest.UpdateMarginForExucutedOrder(executedOrder1);//used to update margin with actual execution price
                    ClearingHouseTest.UpdateMarginForExucutedOrder(executedOrder2);//used to update margin with actual execution price
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(executedOrder1));
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(executedOrder2));
                }

                else if (curOrder.LimitPrice <= e.Order.LimitPrice && e.Order.Quantity > 0)
                {
                    Console.WriteLine("Match found..Generate Trade..");
                    int quantity = Math.Min(e.Order.Quantity, curOrder.Quantity);
                    curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                    e.Order.Quantity = e.Order.Quantity - quantity;
                    Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.LimitPrice.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());

                    //records trade info and sends executed order info back to client
                    FuturesOrder executedOrder1 = (FuturesOrder)curOrder.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = quantity;
                    executedOrder1.executionPrice = curOrder.LimitPrice;
                    executedOrder1.ExecutionTimeStamp = DateTime.Now;
                    FuturesOrder executedOrder2 = (FuturesOrder)e.Order.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = quantity;
                    executedOrder2.executionPrice = curOrder.LimitPrice;
                    executedOrder2.ExecutionTimeStamp = DateTime.Now;
                    ClearingHouseTest.UpdateMarginForExucutedOrder(executedOrder1);//used to update margin with actual execution price
                    ClearingHouseTest.UpdateMarginForExucutedOrder(executedOrder2);//used to update margin with actual execution price
                    //send executed order back to client
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(executedOrder1));
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(executedOrder2));
                }
                else
                { break; }
            }
        }
        private void MatchSellLogic(OrderEventArgs e)
        {
            foreach (Order curOrder in e.BuyBook)
            {
                if (e.Order.OrderType == "MARKET" && e.Order.Quantity > 0)
                {
                    Console.WriteLine("Match found..Generate Market Order Trade..");
                    int quantity = Math.Min(e.Order.Quantity, curOrder.Quantity);
                    curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                    e.Order.Quantity = e.Order.Quantity - quantity;
                    Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.LimitPrice.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());

                    //records trade info and sends executed order info back to client
                    FuturesOrder executedOrder1 = (FuturesOrder)curOrder.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = quantity;
                    executedOrder1.executionPrice = curOrder.LimitPrice;
                    executedOrder1.ExecutionTimeStamp = DateTime.Now;
                    FuturesOrder executedOrder2 = (FuturesOrder)e.Order.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = quantity;
                    executedOrder2.executionPrice = curOrder.LimitPrice;
                    executedOrder2.ExecutionTimeStamp = DateTime.Now;
                    ClearingHouseTest.UpdateMarginForExucutedOrder(executedOrder1);//used to update margin with actual execution price
                    ClearingHouseTest.UpdateMarginForExucutedOrder(executedOrder2);//used to update margin with actual execution price
                    //send executed order back to client
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(executedOrder1));
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(executedOrder2));

                }
                else if (curOrder.LimitPrice >= e.Order.LimitPrice && e.Order.Quantity > 0)
                {
                    Console.WriteLine("Match found..Generate Trade..");
                    int quantity = Math.Min(e.Order.Quantity, curOrder.Quantity);
                    curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                    e.Order.Quantity = e.Order.Quantity - quantity;
                    Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.LimitPrice.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());

                    //records trade info and sends executed order info back to client
                    FuturesOrder executedOrder1 = (FuturesOrder)curOrder.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = quantity;
                    executedOrder1.executionPrice = curOrder.LimitPrice;
                    executedOrder1.ExecutionTimeStamp = DateTime.Now;
                    FuturesOrder executedOrder2 = (FuturesOrder)e.Order.Clone();//make copy so original order is not effected in case of partial fill
                    executedOrder1.ExecutionQuantity = quantity;
                    executedOrder2.executionPrice = curOrder.LimitPrice;
                    executedOrder2.ExecutionTimeStamp = DateTime.Now;
                    ClearingHouseTest.UpdateMarginForExucutedOrder(executedOrder1);//used to update margin with actual execution price
                    ClearingHouseTest.UpdateMarginForExucutedOrder(executedOrder2);//used to update margin with actual execution price
                    //send executed order back to client
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(executedOrder1));
                    ExecutedOrdersToSend.TcpClientTest.Connect(OMEHost.ToXML(executedOrder2));
                }
                else 
                { break; }
            }
        }

        void recordMathcedTrades(ExecutedOrders executedOrder)//need to put back in, or send order back to client and save there
        {
            //string filePath = ConfigurationManager.AppSettings["executionXMLPath"].ToString() + "orderID" + executedOrder.OrderID + ".xml";

            //System.Xml.Serialization.XmlSerializer writer =
            //    new System.Xml.Serialization.XmlSerializer(typeof(ExecutedOrders));

            //System.IO.StreamWriter file = new System.IO.StreamWriter(filePath);
            //writer.Serialize(file, executedOrder);
            //file.Close();
            // also need to send trade execution to trade generator and clearing corp
        }
    }
}
