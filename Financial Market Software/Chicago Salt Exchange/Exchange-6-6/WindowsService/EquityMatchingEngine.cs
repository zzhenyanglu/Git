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

namespace EquityMatchingEngine
{

    public class Test
    {
        public BizDomain equityDomain;

        public Test()
        {
            ManualResetEvent processSignaller = new ManualResetEvent(false);
            //BizDomain equityDomain;
            equityDomain = new BizDomain("Equity Domain", new string[] { "MSFT", "BAC", "GE", "WFC" });

            equityDomain.OrderBook.OrderPriority = new PriceTimePriority();

            EquityMatchingLogic equityMatchingLogic = new EquityMatchingLogic(equityDomain);

            equityDomain.Start();
        } 
    }
    public class OMEHost
    {
        public BizDomain equityDomain;

        public OMEHost()
        {

        } 
        public void test()
        {
            ManualResetEvent processSignaller = new ManualResetEvent(false);
            //BizDomain equityDomain;
            equityDomain = new BizDomain("Equity Domain", new string[] { "MSFT", "BAC", "GE", "WFC" });

            equityDomain.OrderBook.OrderPriority = new PriceTimePriority();

            EquityMatchingLogic equityMatchingLogic = new EquityMatchingLogic(equityDomain);

            equityDomain.Start();
        }

        public void Starter()
        {
            ManualResetEvent processSignaller = new ManualResetEvent(false);
            BizDomain equityDomain;
            equityDomain = new BizDomain("Equity Domain", new string[] { "MSFT", "BAC", "GE", "WFC" });

            equityDomain.OrderBook.OrderPriority = new PriceTimePriority();

            EquityMatchingLogic equityMatchingLogic = new EquityMatchingLogic(equityDomain);

            equityDomain.Start();
            //TcpClient tcp = new TcpClient(AddressFamily.InterNetwork);
            //tcp.Connect(IPAddress.Loopback, 12345);
            //TcpListener tcpListener = null;

            //try
            //{
            //    tcpListener = new TcpListener(IPAddress.Loopback, 12345);
            //    tcpListener.Start();
            //    Console.WriteLine("Waiting for a connection...");
            //}
            //catch (Exception e)
            //{
            //    string output;
            //    output = "Error: " + e.ToString();
            //    Console.WriteLine(output);
            //}
            //TcpClient tcp = tcpListener.AcceptTcpClient( );
            ////Socket tcp = tcpListener.AcceptSocket(); 
            //StreamReader data_in = new StreamReader(tcp.GetStream());

            //string myxml = data_in.ReadToEnd();
            //Console.WriteLine(myxml);
            //EquityOrder[] order = LoadFromXMLString(myxml);
            //data_in.Close();
            //tcp.Close();

            //foreach (EquityOrder curOrder in order)
            //{
            //    equityDomain.SubmitOrder(curOrder.Instrument, curOrder);
            //}



            equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 17, 1, 2));
                //Console.ReadLine();
                //equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Market", "B", 20, 2, 2));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "S", 18, 1, 3));


                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Stop", "B", 20, 5, 13));


                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 20, 5, 4));
                //equityDomain.UpdateOrder(new FuturesOrder("MSFT", "Regular", "B", 19, 10, 8), new FuturesOrder("MSFT", "Regular", "B", 20, 5, 4));

                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "S", 29, 7, 5));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", .1, 8, 6));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 20, 8, 7));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 20, 8, 8));
                equityDomain.DeleteOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 20, 8, 6));

                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "S", 45, 8, 9));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "S", 30, 8, 10));
                
                processSignaller.WaitOne(1000, false);
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 20, 1, 11));
                equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 25, 6, 12));
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
            int priceComp = orderx.Price.CompareTo(orderY.Price);
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
                        int quantity = e.Order.Quantity;
                        curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.Price.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
                    }

                    else if (curOrder.Price <= e.Order.Price && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Trade..");
                        int quantity = e.Order.Quantity;
                        curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.Price.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
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
                        int quantity = e.Order.Quantity;
                        curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.Price.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
                    }
                    else if (curOrder.Price >= e.Order.Price && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Trade..");
                        int quantity = e.Order.Quantity;
                        curOrder.Quantity = curOrder.Quantity - e.Order.Quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.Price.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString());
                    }
                    else { break; }
                }
            }
        }
}
