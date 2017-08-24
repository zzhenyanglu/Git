using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Net.Sockets;
using System.Xml.Linq;


namespace client1
{
    class Program
    {
        static void Main(string[] args)
        {
            //xml file
            XDocument trader1 = new XDocument(new XElement("Trader1", new XElement("generatedOrder","first")));
            trader1.Save("C:\\Users\\chuan\\Desktop\\CSC559\\projectTest\\trader1.xml");
            //connect server
                TcpClient tcpClient ;
                tcpClient = new TcpClient("127.0.0.1", 500);
                int num = 1;
                NetworkStream networkStream;
                byte[] sendMessage;
                byte[] receiveMessage;


                while (true)
                {
                    Thread.Sleep(3000);

                    //send message
                    networkStream = tcpClient.GetStream();
                    sendMessage = Encoding.UTF8.GetBytes("Client1 request connection! " + num);
                    num++;
                    networkStream.Write(sendMessage, 0, sendMessage.Length);
                    networkStream.Flush();

                    //receive message
                    receiveMessage = new byte[1024];
                    int count = networkStream.Read(receiveMessage, 0, 1024);
                    Console.WriteLine(Encoding.UTF8.GetString(receiveMessage));

                }
               

           
                Console.ReadKey();
            
        }
    }
}
