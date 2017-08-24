using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Net;
using System.Net.Sockets;
using client;
using System.Xml;
using System.Collections;

namespace server2
{
    class Program
    {
        
       public  void start_exchange()
        {
            try
            {
                //   ThreadPool.SetMaxThreads(1000, 1000);


                BizDomain equityDomain;
                equityDomain = new BizDomain("Equity Domain", new string[] { "MSFT", "BAC", "GE", "WFC" });// for us, instument means maturity?

                equityDomain.OrderBook.OrderPriority = new PriceTimePriority();
                equityDomain.OrderBook.OrderPriorityForMarket = new TimePriorityForMarket();

                EquityMatchingLogic equityMatchingLogic = new EquityMatchingLogic(equityDomain);

                equityDomain.Start();
                equityDomain.Start2();


             //test
                bool validOrder;

                /*
                FuturesOrder MarketOrder = new FuturesOrder("MSFT", "Market", "B", 30.0, 50, "New");
                 validOrder = equityDomain.checkMargin(MarketOrder);
               
                if(validOrder)
                    equityDomain.SubmitOrder("MSFT", MarketOrder);

                FuturesOrder MarketOrder2 = new FuturesOrder("MSFT", "Market", "S", 25.0, 30, "New");
                validOrder = equityDomain.checkMargin(MarketOrder2);
             
                if (validOrder)
                    equityDomain.SubmitOrder("MSFT", MarketOrder2);
                */

                /*
              FuturesOrder LimitOrder = new FuturesOrder("MSFT", "Limit", "B", 22.0, 60, "New");
               validOrder = equityDomain.checkMargin(LimitOrder);
               //Console.WriteLine("order could be submitted, true or false:                  " + validOrder);
                if (validOrder)
                    equityDomain.SubmitOrder("MSFT", LimitOrder);

                FuturesOrder LimitOrder2 = new FuturesOrder("MSFT", "Limit", "S", 19.0, 60, "New");
                validOrder = equityDomain.checkMargin(LimitOrder2);
                //Console.WriteLine("order could be submitted, true or false:                  " + validOrder);
                if (validOrder)
                    equityDomain.SubmitOrder("MSFT", LimitOrder2);

                */

                /*
                FuturesOrder StopOrder = new FuturesOrder("MSFT", "Stop", "B", 25, 60, "New");
                validOrder = equityDomain.checkMargin(StopOrder);
                //     Console.WriteLine("order could be submitted, true or false:                  " + validOrder);
               if (validOrder)
                equityDomain.SubmitOrder("MSFT", StopOrder);

               FuturesOrder LimitOrder3 = new FuturesOrder("MSFT", "Limit", "B", 26.0, 60, "New");
               validOrder = equityDomain.checkMargin(LimitOrder3);
               //Console.WriteLine("order could be submitted, true or false:                  " + validOrder);
               if (validOrder)
                   equityDomain.SubmitOrder("MSFT", LimitOrder3);

               FuturesOrder LimitOrder4 = new FuturesOrder("MSFT", "Limit", "S", 26.0, 60, "New");
               validOrder = equityDomain.checkMargin(LimitOrder4);
               //Console.WriteLine("order could be submitted, true or false:                  " + validOrder);
               if (validOrder)
                   equityDomain.SubmitOrder("MSFT", LimitOrder4);
                */


                /*
                //update order 
                Console.WriteLine("Update order");

                FuturesOrder LimitOrder4 = new FuturesOrder("MSFT", "Limit", "S", 26.0, 60, "New");
                validOrder = equityDomain.checkMargin(LimitOrder4);
                if (validOrder)
                    equityDomain.SubmitOrder("MSFT", LimitOrder4);

                FuturesOrder UpdateOrder = new FuturesOrder("MSFT", "Limit", "S", 2, 2, "Update");
                UpdateOrder.OrderID = LimitOrder4.OrderID;
                validOrder = equityDomain.checkMargin(UpdateOrder);

                equityDomain.SubmitOrder("MSFT", UpdateOrder);

               
               
                //Cancel order
                Console.WriteLine("Cancel order");
                FuturesOrder CancelOrder = new FuturesOrder("MSFT", "Limit", "S", 1, 1, "Cancel");
                CancelOrder.OrderID = UpdateOrder.OrderID;
                validOrder = equityDomain.checkMargin(CancelOrder);
                equityDomain.SubmitOrder("MSFT", CancelOrder);
               
                */

                /*
                 //if update order lead to lack of margin; update order rejected
                FuturesOrder LimitOrder = new FuturesOrder("MSFT", "Limit", "B", 22.0, 60, "New");
                LimitOrder.OrderID = 310000000;
                validOrder = equityDomain.checkMargin(LimitOrder);
                Console.WriteLine("order info  ID " + LimitOrder.OrderID + " order action " + LimitOrder.OrderAction);
                Console.WriteLine("order could be submitted, true or false:                  " + validOrder);
                if (validOrder)
                    equityDomain.SubmitOrder("MSFT", LimitOrder);

                FuturesOrder LimitOrder2 = new FuturesOrder("MSFT", "Limit", "B", 19.0, 99, "Update");
                LimitOrder2.OrderID = 310000000;
                validOrder = equityDomain.checkMargin(LimitOrder2);
                Console.WriteLine("order info  ID " + LimitOrder2.OrderID+" order action "+LimitOrder2.OrderAction);
                Console.WriteLine("update order could be submitted, true or false:                  " + validOrder);
                if (validOrder)
                    equityDomain.SubmitOrder("MSFT", LimitOrder2);
                */

                //if quote updated and margin is not enough, clear all position.
               /*
                FuturesOrder LimitOrder = new FuturesOrder("MSFT", "Limit", "B", 500,50, "New");
                LimitOrder.OrderID = 310000000;
                validOrder = equityDomain.checkMargin(LimitOrder);
                Console.WriteLine("order info  ID " + LimitOrder.OrderID + " order action " + LimitOrder.OrderAction);
                Console.WriteLine("order could be submitted, true or false:                  " + validOrder);
                if (validOrder)
                    equityDomain.SubmitOrder("MSFT", LimitOrder);

               
                FuturesOrder LimitOrder4 = new FuturesOrder("MSFT", "Limit", "S", 19.5, 10, "New");
                LimitOrder4.OrderID = 310000001;
                validOrder = equityDomain.checkMargin(LimitOrder4);
                Console.WriteLine("order info  ID " + LimitOrder4.OrderID + " order action " + LimitOrder4.OrderAction);
                Console.WriteLine("update order could be submitted, true or false:                  " + validOrder);
                if (validOrder)
                    equityDomain.SubmitOrder("MSFT", LimitOrder4);
                */






                //host: 127.0.0.1
                IPAddress ipAddress = IPAddress.Parse("127.0.0.1");
                TcpListener tcpListener = new TcpListener(ipAddress, 500);
                tcpListener.Start();
                

                while (true)
                {
                    //chatClient listen to client
                    ChatClient chatClient = new ChatClient(tcpListener.AcceptTcpClient(),equityDomain);
                }
            }
            catch (Exception e) 
            { 
                Console.WriteLine("exception: " + e.ToString());           
            }
            finally {
            
            }
        }
    }

    public class ChatClient
    {
        public TcpClient tcpClient;
        public byte[] byteMessage;
        public string clientEndPoint;
        public string receiveMessage = null;
        BizDomain equityDomain = null;
        public ChatClient(TcpClient tcpClient1, BizDomain bizDomain)
        {
            equityDomain = bizDomain;

            tcpClient = tcpClient1;
            byteMessage = new byte[tcpClient.ReceiveBufferSize];

            //read async
            NetworkStream networkStream = tcpClient.GetStream();
            networkStream.BeginRead(byteMessage, 0, tcpClient.ReceiveBufferSize,
                                         new AsyncCallback(ReceiveAsyncCallback), null);

         }

        public void ReceiveAsyncCallback(IAsyncResult iAsyncResult)
        {
            
            // Thread.Sleep(100);
            //ThreadPoolMessage("\nMessage is receiving");

            // endRead
            NetworkStream networkStreamRead = tcpClient.GetStream();
            int length = networkStreamRead.EndRead(iAsyncResult);

            //check message
            if (length < 1)
            {
                tcpClient.GetStream().Close();
                throw new Exception("Disconnection!");
            }

            //show received message
            string message = Encoding.UTF8.GetString(byteMessage, 0, length);
          

            FuturesOrder order1 = (FuturesOrder)new XmlObjectSerializer().Deserialize(message);
            Console.WriteLine("Order received");

            equityDomain.checkMargin(order1);

            equityDomain.SubmitOrder("MSFT", order1 as Order);
            

           //send back message
           byte[] sendMessage = Encoding.UTF8.GetBytes(DateTime.Now +" From Server: Message is received!");
           NetworkStream networkStreamWrite = tcpClient.GetStream();
           networkStreamWrite.BeginWrite(sendMessage, 0, sendMessage.Length,  new AsyncCallback(SendAsyncCallback), null);
           
        }


        public void SendAsyncCallback(IAsyncResult iAsyncResult)
        {

            // Thread.Sleep(100);
            // ThreadPoolMessage("\nMessage is sending");

            //end write
            tcpClient.GetStream().EndWrite(iAsyncResult);

            //listen again
            tcpClient.GetStream().BeginRead(byteMessage, 0, tcpClient.ReceiveBufferSize,
                                               new AsyncCallback(ReceiveAsyncCallback), null);
        }

        //



        static void ThreadPoolMessage(string data)
        {
            int a, b;
            ThreadPool.GetAvailableThreads(out a, out b);
            string message = string.Format("{0}\n  CurrentThreadId is {1}\n  " +
                  "WorkerThreads is:{2}  CompletionPortThreads is :{3}\n",
                  data, Thread.CurrentThread.ManagedThreadId, a.ToString(), b.ToString());

            Console.WriteLine(message);
        }
    }
}
