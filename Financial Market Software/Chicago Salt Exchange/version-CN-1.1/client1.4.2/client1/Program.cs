using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Net.Sockets;
using System.Xml.Linq;
using client;
using System.Xml;
using System.Collections;
/*for different trader change:
 * 1, for trader n  id starts from n*100000000; class Order
  *      static long beginId = 100000000;
 * 
 * 
*/
namespace client1
{
    class Program
    {
        static int countNum = 0;

        static ArrayList currentOrders = ArrayList.Synchronized(new ArrayList());
        object syc = new object();
      static  XmlDocument xmlDoc = new XmlDocument();

       static  FuturesOrder PickOne(int traderID, ref  bool found)
        {
            xmlDoc.Load("C:\\Users\\chuan\\Desktop\\CSC559\\Final Project\\exchange\\Exchange1.9\\server2\\bin\\Debug\\ClearingHouse.xml");

            found = false;
            XmlNodeList nodeList = xmlDoc.SelectSingleNode("ClearingHouse").ChildNodes;
              FuturesOrder order=null;
            foreach (XmlNode xn in nodeList)//遍历所有子节点
            {
                XmlElement xe = (XmlElement)xn;//将子节点类型转换为XmlElement类型

                if (int.Parse(xe.GetAttribute("ID")) == traderID)//find trader
                {

                    XmlNodeList nodeListOfOrder = xe.ChildNodes;
                    int count = nodeListOfOrder.Count;
                    if (count == 0)
                    {
                        return order;
                    }
                    else
                    {
                        Random rnd = new Random();
                        int mIndex = rnd.Next(0, nodeListOfOrder.Count);
                        int num = 0;
                        foreach (XmlNode ordn in nodeListOfOrder)
                        {
                            if (num == mIndex)
                            {
                                found = true;
                                XmlElement ord = (XmlElement)ordn;
                                string instrument=ord.GetAttribute("Instrument");
                                long orderId=long.Parse(ord.GetAttribute("OrderID"));
                               string ordertype= ord.GetAttribute("OrderType");
                                string buysell=ord.GetAttribute("BuySell");
                                double price=double.Parse(ord.GetAttribute("Price"));
                                int quantity=int.Parse(ord.GetAttribute("Quantity"));

                                order = new FuturesOrder(instrument,ordertype,buysell,price,quantity,"None");
                                order.OrderID = orderId;
                                return order;
                            
                            }
                            num++;
                        }


                    }
                }
            }
            return order;
        }

        static void Main(string[] args)
        {

            //connect server
            try
            {
                bool found=false;
               FuturesOrder orders= PickOne(2, ref found);
               Console.WriteLine(found);


                TcpClient tcpClient;
                tcpClient = new TcpClient("127.0.0.1", 500);

                NetworkStream networkStream;

                networkStream = tcpClient.GetStream();
                byte[] sendMessage;
                byte[] receiveMessage;


                while (true)
                {

                    Thread.Sleep(1000);

                    //here generate order
                    FuturesOrder order = newOrder();
                    countNum++;
                    string xml = new XmlObjectSerializer().Serialize(order).OuterXml;

                    sendMessage = Encoding.UTF8.GetBytes(xml);


                    networkStream.Write(sendMessage, 0, sendMessage.Length);
                    networkStream.Flush();

                    //receive message
                    receiveMessage = new byte[1024];
                    int count = networkStream.Read(receiveMessage, 0, 1024);
                    Console.WriteLine(Encoding.UTF8.GetString(receiveMessage));

                }
                //   networkStream.Close();
                //  tcpClient.Close();





            }
            catch (Exception e)
            {
                Console.WriteLine("exception: " + e.ToString());
            }
            finally
            {


            }


            Console.ReadKey();

        }


        static FuturesOrder newOrder()
        {
            string OrderAction = generateOrder.generateOrderAction();
            string instrument;
            string buySell;
            double price;
            int quantity;
            string orderType;
            FuturesOrder newOrder = null;

            bool generateSucessful = false;

            while (generateSucessful == false)
            {

                if (OrderAction.Equals("New"))
                {
                    //new order
                    instrument = generateOrder.generateInstument();
                    buySell = generateOrder.generateBuySell();
                    price = generateOrder.generatePrice();
                    quantity = generateOrder.generateQuantity();
                    orderType = generateOrder.generateOrderType();
                    newOrder = new FuturesOrder(instrument, orderType, buySell, price, quantity, OrderAction);
                    generateSucessful = true;

                }
                else if (OrderAction.Equals("Update"))
                {

                    if (currentOrders.Count == 0 || countNum < 60)
                    {
                        OrderAction = "New";
                    }
                    else
                    {
                        Random rnd = new Random();
                        int mIndex = rnd.Next(0, currentOrders.Count);
                        bool found=false;
                        newOrder = PickOne(2,ref found);
                        if (found == false)
                        {
                            OrderAction = "New";
                        }
                        else
                        {
                            newOrder.OrderAction = "Update";
                            newOrder.Quantity = newOrder.Quantity + 1;//what is the action of update..here just add 1 quantity 
                            newOrder.Price = generateOrder.generatePrice();
                            newOrder.TimeStamp = DateTime.Now;
                            generateSucessful = true;
                        }
                    }
                }
                else
                {
                    //choose one from current hold order to cancel
                    if (currentOrders.Count == 0 || countNum < 60)
                    {
                        OrderAction = "New";
                    }
                    else
                    {
                        Random rnd = new Random();
                        int mIndex = rnd.Next(0, currentOrders.Count);
                        bool found = false;
                        newOrder = PickOne(2,ref found);
                        if (found == false)
                        {
                            OrderAction = "New";
                        }
                        else
                        {
                            newOrder.OrderAction = "Cancel";
                            generateSucessful = true;
                        }
                    }

                }
            }

            return newOrder;

        }

    }
}
