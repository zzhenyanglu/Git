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
using System.Xml.Serialization;
using System.Xml;
using System.Xml.XPath;

namespace EquityMatchingEngine
{
    public class OMEHost
    {
        //Mutex syncExchange = new Mutex(false, "SyncExchange");
        [STAThread]
        static void Main(string[] args)
        {
            ManualResetEvent processSignaller = new ManualResetEvent(false);
            BizDomain equityDomain;
            equityDomain = new BizDomain("Salt Futures", new string[] { "MSFT", "BAC", "GE", "WFC" });

            equityDomain.OrderBook.OrderPriority = new PriceTimePriority();

            EquityMatchingLogic equityMatchingLogic = new EquityMatchingLogic(equityDomain);

            equityDomain.Start();
            equityMatchingLogic.updateClearingCorp();



            equityDomain.checkMargin();



            equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 17, 1, 2,2));
            equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 17, 1, 50, 50));
                //Console.ReadLine();
                //equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Market", "B", 20, 2, 2));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "S", 18, 1, 3,3));


                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Stop", "B", 20, 5, 13,13));

                processSignaller.WaitOne(2000, false);
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 20, 5, 4,4));
                //equityDomain.UpdateOrder(new FuturesOrder("MSFT", "Regular", "B", 19, 10, 8), new FuturesOrder("MSFT", "Regular", "B", 20, 5, 4));

                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "S", 29, 7, 5,5));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", .1, 8, 6,6));

                
                processSignaller.WaitOne(2000, false);
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 20, 1, 11,11));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 25, 6, 12,12));
                //equityDomain.PriceQuote("MSFT", "B");
                //equityDomain.PriceQuote("MSFT", "S");
            

            Console.ReadLine();
            Console.WriteLine("Press any key to stop");
            Console.ReadLine();

            return;
        }
        public static FuturesOrder[] LoadFromXMLString(string xmlText)
        {
            //var stringReader = new System.IO.StringReader(xmlText);
            //var serializer = new XmlSerializer(typeof(Order));
            //return serializer.Deserialize(stringReader) as Order;

            XmlSerializer xmlSerializer = new XmlSerializer(typeof(FuturesOrder[]));
            StringReader stringReader = new StringReader(xmlText /* result is the value from the database */);
            FuturesOrder[] deserializedEntity = (FuturesOrder[])xmlSerializer.Deserialize(stringReader);
            return deserializedEntity as FuturesOrder[];
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
                if (e.Order.BuySell == "B")
                    MatchBuyLogic(e);
                else
                    MatchSellLogic(e);
            }


            private void MatchBuyLogic(OrderEventArgs e)
            {
                foreach (Order curOrder in e.SellBook)
                {
                    if(e.Order.OrderType=="Market" && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Market Order Trade..");
                        int quantity = Math.Min(e.Order.Quantity,curOrder.Quantity) ; //need to check this 
                        curOrder.Quantity = curOrder.Quantity - quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.LimitPrice.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
                        // write executed orders to xml file 
                        ExecutedOrders executedOrder1 = new ExecutedOrders(e.Order, quantity, curOrder.LimitPrice);
                        ExecutedOrders executedOrder2 = new ExecutedOrders(curOrder, quantity, curOrder.LimitPrice);
                        recordMathcedTrades(executedOrder1);
                        recordMathcedTrades(executedOrder2); // saves as xml document also need to send execution notification back to client and clearing corp
                    }

                    else if (curOrder.LimitPrice <= e.Order.LimitPrice && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Trade..");
                        int quantity = Math.Min(e.Order.Quantity, curOrder.Quantity);
                        curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.LimitPrice.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
                       
                        ExecutedOrders executedOrder1 = new ExecutedOrders(e.Order, curOrder.Quantity, curOrder.LimitPrice);
                        ExecutedOrders executedOrder2 = new ExecutedOrders(curOrder, curOrder.Quantity, curOrder.LimitPrice);
                        recordMathcedTrades(executedOrder1);
                        recordMathcedTrades(executedOrder2); // saves as xml document also need to send execution notification back to client and clearing corp
                        
                    }
                    else { break; }
                }
            }
            private void MatchSellLogic(OrderEventArgs e)
            {
                foreach (Order curOrder in e.BuyBook)
                {
                    if (e.Order.OrderType == "Market" && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Market Order Trade..");
                        int quantity = Math.Min(e.Order.Quantity, curOrder.Quantity);
                        curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.LimitPrice.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
                        
                        ExecutedOrders executedOrder1 = new ExecutedOrders(e.Order, curOrder.Quantity, curOrder.LimitPrice);
                        ExecutedOrders executedOrder2 = new ExecutedOrders(curOrder, curOrder.Quantity, curOrder.LimitPrice);
                        recordMathcedTrades(executedOrder1);
                        recordMathcedTrades(executedOrder2); // saves as xml document also need to send execution notification back to client and clearing corp
                    }
                    else if (curOrder.LimitPrice >= e.Order.LimitPrice && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Trade..");
                        int quantity = Math.Min(e.Order.Quantity, curOrder.Quantity);
                        curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.LimitPrice.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
                        
                        ExecutedOrders executedOrder1 = new ExecutedOrders(e.Order, curOrder.Quantity, curOrder.LimitPrice);
                        ExecutedOrders executedOrder2 = new ExecutedOrders(curOrder, curOrder.Quantity, curOrder.LimitPrice);
                        recordMathcedTrades(executedOrder1);
                        recordMathcedTrades(executedOrder2); // saves as xml document also need to send execution notification back to client and clearing corp
                    }
                    else { break; }
                }
            }

            void recordMathcedTrades(ExecutedOrders executedOrder)
            {
                string filePath = ConfigurationManager.AppSettings["executionXMLPath"].ToString() + "orderID" + executedOrder.OrderID + ".xml";

                System.Xml.Serialization.XmlSerializer writer =
                    new System.Xml.Serialization.XmlSerializer(typeof(ExecutedOrders));
                
                System.IO.StreamWriter file = new System.IO.StreamWriter(filePath); 
                writer.Serialize(file, executedOrder);
                file.Close();

                updateClearingCorp();
            }

            public void updateClearingCorp()
            {

                //XPathDocument document = new XPathDocument(@"C:\Users\Mike\Documents\Visual Studio 2012\Projects\Exchange\clearingLog.xml");
                //XPathNavigator navigator = document.CreateNavigator();
                //XmlNamespaceManager manager = new XmlNamespaceManager(navigator.NameTable);
                //manager.AddNamespace("bk", "http://www.contoso.com/books");

                ////XPathNavigator node = navigator.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Balance", manager);
                //navigator.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Balance", manager).SetValue("50");

                //document.Save(@"C:\Users\Mike\Documents\Visual Studio 2012\Projects\Exchange\clearingLog.xml");

                XmlDocument doc = new XmlDocument();
                doc.Load(@"C:\Users\Mike\Documents\Visual Studio 2012\Projects\Exchange\clearingLog.xml");
                doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Balance").InnerText = "56";

                doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='1']/Positions/Ticker[@Ticker='WFC']/Quantity").InnerText = "50";
                doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Positions/Ticker[@Ticker='BAC']/Quantity").InnerText = "50";
                try
                {
                    doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Positions/Ticker[@Ticker='C']/Quantity").InnerText = "50";
                }
                catch
                {
                    XmlElement quant = doc.CreateElement("Quantity");
                    quant.InnerText = "0";
                    XmlElement Ticker2 = doc.CreateElement("Ticker");

                    Ticker2.SetAttribute("Ticker", "C");
                    Ticker2.AppendChild(quant);
                    
                    doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Positions").AppendChild(Ticker2);

                }
                doc.Save(@"C:\Users\Mike\Documents\Visual Studio 2012\Projects\Exchange\clearingLog.xml");

            }
        }
}
