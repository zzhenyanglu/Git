using System;
using System.Collections;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Net.Sockets;
using System.Net;
using System.IO;
using client;


namespace server2
{

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
        
        Object syc = new Object();
        BizDomain tempDomain;
        public EquityMatchingLogic(BizDomain bizDomain)
        {
            bizDomain.OrderBook.StopToMarketEvent += new OrderEventHandler(OrderBook_StopToMarket);
            bizDomain.OrderBook.OrderBeforeInsert += new OrderEventHandler(OrderBook_OrderBeforeInsert);
            tempDomain = bizDomain;
           
        }
        public void OrderBook_StopToMarket(object sender, OrderEventArgs e)
        {
           
            foreach (Order curBuyOrder in e.BuyBook)
            {
                if (OrderBook.marketPrice > curBuyOrder.Price)
                {
                 //   Order temp = curBuyOrder;
                    FuturesOrder order = new FuturesOrder("MSFT", "Market", "B", curBuyOrder.Price, curBuyOrder.Quantity, "New");

                    curBuyOrder.Quantity = 0;
                    tempDomain.deleteOrder(curBuyOrder);
                   
                   
                    tempDomain.checkMargin(order);
                    tempDomain.SubmitOrder("MSFT", order);
                    Console.WriteLine("one buy stop becomes market.  New Market order is ID " + order.OrderID + " order type " + order.OrderType + " buysell " + order.BuySell + " Price "+order.Price+ " quantity " + order.Quantity + " action " + order.OrderAction);
                }
            }

            foreach (Order curSellOrder in e.SellBook)
            {
                if (OrderBook.marketPrice < curSellOrder.Price)
                {
                    Order temp = curSellOrder;
                    curSellOrder.Quantity = 0;
                    FuturesOrder order = new FuturesOrder("MSFT", "Market", "S", temp.Price, temp.Quantity, "New");
                    tempDomain.SubmitOrder("MSFT", order);
              
                Console.WriteLine("one sell stop becomes market.  New Market order is ID " + order.OrderID + " order type " + order.OrderType + " buysell " + order.BuySell + " Price "+order.Price+ " quantity " + order.Quantity + " action " + order.OrderAction);
           
                }  
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
            }
            else if (e.Order.OrderAction == "Cancel")
            {
                if (e.Order.BuySell == "B")
                    CancelBuyLogic(e);
                else
                    CancelSellLogic(e);

            }
            else if (e.Order.OrderAction == "Update")
            {
              
                if (e.Order.BuySell == "B")
                    UpdateBuyLogic(e);
                else
                    UpdateSellLogic(e);

            }
        }
        private void UpdateBuyLogic(OrderEventArgs e)
        {
            bool findOrder = false;
            foreach (Order curOrder in e.BuyBook)
            {
                
                if (curOrder.OrderID == e.Order.OrderID)
                {
                    
                    curOrder.Quantity = e.Order.Quantity;
                    curOrder.Price = e.Order.Price;
                    curOrder.TimeStamp = e.Order.TimeStamp;
                    Console.WriteLine("one buy order updated,  ID " + curOrder.OrderID + " order type " + curOrder.OrderType + " buysell " + curOrder.BuySell + " Price " + curOrder.Price + " quantity " + curOrder.Quantity + " action " + curOrder.OrderAction);
                    findOrder = true;
                    break;
                }

            }
            if (findOrder == false)
            {
                Console.WriteLine("Order not found: orderID is " + e.Order.OrderID + " order type " + e.Order.OrderType + " buysell " + e.Order.BuySell + " Price " + e.Order.Price + " quantity " + e.Order.Quantity + " action " + e.Order.OrderAction);

            }
        }
        private void UpdateSellLogic(OrderEventArgs e)
        {
            bool findOrder = false;
          //  Console.WriteLine("enter sell");
            foreach (Order curOrder in e.SellBook)
            {
                if (curOrder.OrderID == e.Order.OrderID)
                {
                    curOrder.Quantity = e.Order.Quantity;
                    curOrder.Price = e.Order.Price;
                    curOrder.TimeStamp = e.Order.TimeStamp;
                   Console.WriteLine("one sell order updated,  ID " + curOrder.OrderID + " order type " + curOrder.OrderType + " buysell " + curOrder.BuySell );
                    findOrder = true;
                    break;
                }

            }
            if (findOrder == false)
            {
                Console.WriteLine("Order not found: orderID is " + e.Order.OrderID + " order type " + e.Order.OrderType + " buysell " + e.Order.BuySell + " Price " + e.Order.Price + " quantity " + e.Order.Quantity + " action " + e.Order.OrderAction);

            }
        }

        private void CancelBuyLogic(OrderEventArgs e)
        {
            bool findOrder = false;
            foreach (Order curOrder in e.BuyBook)
            {
                if (curOrder.OrderID == e.Order.OrderID)
                {
                    curOrder.Quantity = 0;
                    e.Order.Quantity = 0;
                //    Console.WriteLine("one buy order cancelled, orderID is " + curOrder.OrderID + " order type " + curOrder.OrderType + " buysell " + curOrder.BuySell + " Price " + curOrder.Price + " quantity " + curOrder.Quantity + " action " + curOrder.OrderAction);
                    findOrder = true;
                    break;
                }

            }
            if(findOrder==false){
                Console.WriteLine("Order not found: orderID is " + e.Order.OrderID );
            
            }
        }
        private void CancelSellLogic(OrderEventArgs e)
        {
            bool findOrder = false;
            foreach (Order curOrder in e.SellBook)
            {
                if (curOrder.OrderID == e.Order.OrderID)
                {
                    curOrder.Quantity = 0;
                    e.Order.Quantity = 0;
                    Console.WriteLine("one sell order cancelled, orderID is " + curOrder.OrderID );
                    findOrder = true;
                    break;
                }

            }
            if (findOrder == false)
            {
                Console.WriteLine("Order not found: orderID is " + e.Order.OrderID + " order type " + e.Order.OrderType + " buysell " + e.Order.BuySell + " Price " + e.Order.Price + " quantity " + e.Order.Quantity + " action " + e.Order.OrderAction);

            }
        }

        private void MatchBuyLogic(OrderEventArgs e)
        {
            foreach (Order curOrder in e.SellBook)
            {
                if (e.Order.OrderType == "Market" && e.Order.Quantity > 0)
                {
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
                    MatchedOrderArgs args = new MatchedOrderArgs(curOrder.OrderID, e.Order.OrderID, quantity, OrderBook.marketPrice);
                    tempDomain.onOrderMatched(args, curOrder.OrderID);
                    tempDomain.onOrderMatched(args, e.Order.OrderID);

                    Console.WriteLine( "Market order matched at buy logic" + " at price" + OrderBook.marketPrice + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() +  " matched quantity "+quantity);
               
                }

                else if (e.Order.OrderType == "Limit" && curOrder.Price <= e.Order.Price && e.Order.Quantity > 0)
                {
                    
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
 
                    MatchedOrderArgs args = new MatchedOrderArgs(curOrder.OrderID, e.Order.OrderID, quantity, OrderBook.marketPrice);
                    tempDomain.onOrderMatched(args, curOrder.OrderID);
                    tempDomain.onOrderMatched(args, e.Order.OrderID);


                    Thread thread = new Thread(tempDomain.OrderBook.StopToMarket);
                    thread.Start(new FuturesOrder("MSFT", "Stop", "B", 1, 1, "New"));//just instrument ,order type and Buysell are useful; check stop order

                    Console.WriteLine(" Limit order matched at buy logic" + " at price " + curOrder.Price + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() + "matched Quantity " + quantity);
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
                    //Console.WriteLine("Match found..Generate Market Order Trade..");
                    int quantity=0;
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
                    MatchedOrderArgs args = new MatchedOrderArgs(curOrder.OrderID, e.Order.OrderID, quantity, OrderBook.marketPrice);
                   // Console.WriteLine(curOrder.OrderID);
                   // Console.WriteLine(e.Order.OrderID);
                    tempDomain.onOrderMatched(args, curOrder.OrderID);

                    tempDomain.onOrderMatched(args, e.Order.OrderID);
                    Console.WriteLine("Market order matched at buy logic" + " at price" + OrderBook.marketPrice + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() + " matched quantity " + quantity);
                
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
                    MatchedOrderArgs args = new MatchedOrderArgs(curOrder.OrderID, e.Order.OrderID, quantity, OrderBook.marketPrice);
                    tempDomain.onOrderMatched(args, curOrder.OrderID);
                    tempDomain.onOrderMatched(args, e.Order.OrderID);
                    Thread thread = new Thread(tempDomain.OrderBook.StopToMarket);
                    thread.Start(new FuturesOrder("MSFT", "Stop", "B", 1, 1, "New"));//just instrument and ordertype are useful

                    Console.WriteLine(" Limit order matched at buy logic" + " at price " + curOrder.Price + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() + "matched Quantity " + quantity);
                  //  Console.WriteLine(" Limit order matched at buy logic" + " at price" + OrderBook.marketPrice + " order ID's " + curOrder.OrderID.ToString() + " & " + e.Order.OrderID.ToString() + " current quote " + OrderBook.marketPrice);
               
                }
                else
                { 
                    break;
                }
            }
        }
    }
}
