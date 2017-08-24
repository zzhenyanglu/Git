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
using OME.Storage;

namespace EquityMatchingEngine
{
    class OMEHost
    {
        //Mutex syncExchange = new Mutex(false, "SyncExchange");
      
        [STAThread]
        static void Main(string[] args)
        {


           
           // ManualResetEvent processSignaller = new ManualResetEvent(false);
            BizDomain equityDomain;
            equityDomain = new BizDomain("Equity Domain", new string[] { "MSFT", "BAC", "GE", "WFC" });

            equityDomain.OrderBook.OrderPriority = new PriceTimePriority();
            equityDomain.OrderBook.OrderPriorityForMarket = new TimePriorityForMarket();
             
            EquityMatchingLogic equityMatchingLogic = new EquityMatchingLogic(equityDomain);
           // HandleStop handleStop=new HandleStop(equityDomain);
     //       equityDomain.OrderBook.StopToMarketEvent += new OrderEventHandler(equityMatchingLogic.OrderBook_StopToMarket);
            equityDomain.Start();

          //test Market order
           // equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Market", "B", 20, 3, "Trader1","new"));
         //   equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Market", "S", 16, 5, "Trader1","new"));

            //test limit order
            // equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 25, 3, "Trader1","new"));
            //   equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "S", 10, 5, "Trader1","new"));
        
            //test cancel order; orderID should be send by client
           /*
            FuturesOrder OriOrder = new FuturesOrder("MSFT", "Limit", "B", 25, 3, "Trader1", "New");
            FuturesOrder testDelete = new FuturesOrder("MSFT", "Limit", "B", 25, 3, "Trader1", "Cancel");
            testDelete.OrderID = OriOrder.OrderID;

            equityDomain.SubmitOrder("MSFT", OriOrder);
            equityDomain.SubmitOrder("MSFT", testDelete);
         
            //test update order;orderID should be send by client
          
           FuturesOrder UOrder = new FuturesOrder("MSFT", "Limit", "B", 25, 3, "Trader1", "New");
            FuturesOrder testUpdate = new FuturesOrder("MSFT", "Limit", "B", 20, 5, "Trader1", "Update");
            testUpdate.OrderID = UOrder.OrderID;
            equityDomain.SubmitOrder("MSFT", UOrder);
            equityDomain.SubmitOrder("MSFT", testUpdate);
          
            FuturesOrder UOrder = new FuturesOrder("MSFT", "Market", "B", 25, 3, "Trader1", "New");
            FuturesOrder testUpdate = new FuturesOrder("MSFT", "Market", "B", 20, 5, "Trader1", "Update");
            testUpdate.OrderID = UOrder.OrderID;
            equityDomain.SubmitOrder("MSFT", UOrder);
            equityDomain.SubmitOrder("MSFT", testUpdate);
           */
            FuturesOrder SOrder = new FuturesOrder("MSFT", "Stop", "S", 15, 3, "Trader1", "New");
            equityDomain.SubmitOrder("MSFT", SOrder);
       
            equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "S", 10, 5, "Trader1","New"));
            equityDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Limit", "B", 25, 3, "Trader1","New"));



       
            Console.ReadLine();

            return;
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

    public class TimePriorityForMarket : IComparer
    {
        public int Compare(object x, object y)
        {
            Order orderX = x as Order;
            Order orderY = y as Order;
            int timeComp = orderX.TimeStamp.CompareTo(orderY.TimeStamp);
            return timeComp;
        }
    }

        public class EquityMatchingLogic
        {
            //private OrderBook orderBook = new OrderBook();
            Object syc = new Object();
            BizDomain tempDomain;
            public EquityMatchingLogic(BizDomain bizDomain)
            {  bizDomain.OrderBook.StopToMarketEvent += new OrderEventHandler(OrderBook_StopToMarket);
                bizDomain.OrderBook.OrderBeforeInsert += new OrderEventHandler(OrderBook_OrderBeforeInsert);
                tempDomain = bizDomain;
               // Console.WriteLine("register handler");
            }
            public void OrderBook_StopToMarket(object sender, OrderEventArgs e)
            {
               // Console.WriteLine("enter EquityMatchingLogic OrderBook_StopToMarket(object sender, OrderEventArgs e)");
               // Console.WriteLine(OrderBook.marketPrice);
                foreach (Order curBuyOrder in e.BuyBook)
                {
                    if(OrderBook.marketPrice>curBuyOrder.Price){
                        Order temp = curBuyOrder;
                        curBuyOrder.Quantity = 0;
                        tempDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Market", "B", temp.Price, temp.Quantity, temp.Owner, "New"));
                        Console.WriteLine("buy stop becomes market");
                    }
            }

                foreach (Order curSellOrder in e.SellBook)
                {
                    if (OrderBook.marketPrice < curSellOrder.Price)
                    {
                        Order temp = curSellOrder;
                        curSellOrder.Quantity = 0;
                        tempDomain.SubmitOrder("MSFT", new FuturesOrder("MSFT", "Market", "S", temp.Price, temp.Quantity, temp.Owner, "New"));
                    }
                    Console.WriteLine("sell stop becomes market");
                }


            }

            private void OrderBook_OrderBeforeInsert(object sender, OrderEventArgs e)
            {
                if (e.Order.OrderAction == "New")
                {
                    if (e.Order.BuySell == "B")
                        MatchBuyLogic(e);
                    else
                        MatchSellLogic(e);
                }else if (e.Order.OrderAction == "Cancel")
                {
                    if (e.Order.BuySell == "B")
                        CancelBuyLogic(e);
                    else
                        CancelSellLogic(e);

                }
                else if (e.Order.OrderAction == "Update")
                {
                   // Console.WriteLine("enter......");
                    if (e.Order.BuySell == "B")
                        UpdateBuyLogic(e);
                    else
                        UpdateSellLogic(e);

                }
            }
            private void UpdateBuyLogic(OrderEventArgs e)
            {
             //   Console.WriteLine("enter......");
                foreach (Order curOrder in e.BuyBook)
                {
                    //Console.WriteLine("enter......");
                    if (curOrder.OrderID == e.Order.OrderID)
                    {
                       // Console.WriteLine("enter......");
                        curOrder.Quantity = e.Order.Quantity;
                        curOrder.Price = e.Order.Price;
                        curOrder.TimeStamp = e.Order.TimeStamp;
                        Console.WriteLine("one buy order updated, orderID is " + curOrder.OrderID+" now quantity = "+curOrder.Quantity+" price= "+curOrder.Price);
                        break;
                    }

                }
            }
            private void UpdateSellLogic(OrderEventArgs e)
            {
                foreach (Order curOrder in e.SellBook)
                {
                    if (curOrder.OrderID == e.Order.OrderID)
                    {
                        curOrder.Quantity = e.Order.Quantity;
                        curOrder.Price = e.Order.Price;
                        curOrder.TimeStamp = e.Order.TimeStamp;
                        Console.WriteLine("one sell order updated, orderID is " + curOrder.OrderID);
                        break;
                    }

                }
            }

            private void CancelBuyLogic(OrderEventArgs e)
            {
                foreach (Order curOrder in e.BuyBook)
                {
                    if(curOrder.OrderID==e.Order.OrderID){
                        curOrder.Quantity = 0;
                        e.Order.Quantity = 0;
                        Console.WriteLine("one buy order cancelled, orderID is " + curOrder.OrderID);
                        break;
                    }
                  
                }
            }
            private void CancelSellLogic(OrderEventArgs e)
            {
                foreach (Order curOrder in e.SellBook)
                {
                    if (curOrder.OrderID == e.Order.OrderID)
                    {
                        curOrder.Quantity = 0;
                        e.Order.Quantity = 0;
                        Console.WriteLine("one sell order cancelled, orderID is " + curOrder.OrderID);
                        break;
                    }

                }
            }

            private void MatchBuyLogic(OrderEventArgs e)
            {
                foreach (Order curOrder in e.SellBook)
                {
                    if (e.Order.OrderType=="Market" && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Market Order Trade..");
                        int quantity;
                        if(curOrder.Quantity>=e.Order.Quantity )
                        {
                            quantity = e.Order.Quantity;
                        }else{
                            quantity = curOrder.Quantity;
                        }
                        curOrder.Quantity = curOrder.Quantity - quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine("entered buy logic");
                        Console.WriteLine(quantity.ToString() + " market matched" + " at " + OrderBook.marketPrice + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() + " current market price " + OrderBook.marketPrice);
                    }

                    else if (curOrder.Price <= e.Order.Price && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Trade..");
                        int quantity;
                        if (curOrder.Quantity >= e.Order.Quantity)
                        {
                            quantity = e.Order.Quantity;
                        }
                        else
                        {
                            quantity = curOrder.Quantity;
                        }
                        curOrder.Quantity = curOrder.Quantity - quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        lock (syc)
                        {
                            OrderBook.marketPrice = curOrder.Price;
                        }
                        Thread thread = new Thread(tempDomain.OrderBook.StopToMarket);
                        thread.Start(new FuturesOrder("MSFT", "Stop", "B", 1, 1, "Trader1", "New"));//just instrument and ordertype are useful

                        Console.WriteLine("entered buy logic");
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.Price.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() + " current market price " + OrderBook.marketPrice);
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
                        int quantity;
                        if (curOrder.Quantity >= e.Order.Quantity)
                        {
                            quantity = e.Order.Quantity;
                        }
                        else
                        {
                            quantity = curOrder.Quantity;
                        }
                        curOrder.Quantity = curOrder.Quantity - quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        Console.WriteLine("entered sell logic");
                        Console.WriteLine(quantity.ToString() + " market matched" + " at " + OrderBook.marketPrice + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() + " current market price " + OrderBook.marketPrice);
                    }
                    else if (curOrder.Price >= e.Order.Price && e.Order.Quantity > 0)
                    {
                        Console.WriteLine("Match found..Generate Trade..");
                        int quantity;
                        if (curOrder.Quantity >= e.Order.Quantity)
                        {
                            quantity = e.Order.Quantity;
                        }
                        else
                        {
                            quantity = curOrder.Quantity;
                        }
                        curOrder.Quantity = curOrder.Quantity - quantity;
                        e.Order.Quantity = e.Order.Quantity - quantity;
                        lock (syc)
                        {
                            OrderBook.marketPrice = curOrder.Price;
                        }
                        Thread thread = new Thread(tempDomain.OrderBook.StopToMarket);
                        thread.Start(new FuturesOrder("MSFT", "Stop", "B", 1, 1, "Trader1", "New"));//just instrument and ordertype are useful

                        Console.WriteLine("entered sell logic");
                        Console.WriteLine(quantity.ToString() + " " + curOrder.Instrument.ToString() + " at " + curOrder.Price.ToString() + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() + " current market price " + OrderBook.marketPrice);
                    }
                    else { break; }
                }
            }
        }
}
