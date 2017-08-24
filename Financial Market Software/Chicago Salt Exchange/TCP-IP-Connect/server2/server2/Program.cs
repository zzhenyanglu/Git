using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Net;
using System.Net.Sockets;

namespace server2
{
    class Program
    {
        static void Main(string[] args)
        {
            
            ThreadPool.SetMaxThreads(1000, 1000);

            //host: 127.0.0.1
            IPAddress ipAddress = IPAddress.Parse("127.0.0.1");
            TcpListener tcpListener = new TcpListener(ipAddress, 500);
            tcpListener.Start();

            
            while (true)
            {   //chatClient listen to client
                ChatClient chatClient = new ChatClient(tcpListener.AcceptTcpClient());
            }
        }
    }

    public class ChatClient
    {
        public TcpClient tcpClient;
        public byte[] byteMessage;
        public string clientEndPoint;

        public ChatClient(TcpClient tcpClient1)
        {
            tcpClient = tcpClient1;
            byteMessage = new byte[tcpClient.ReceiveBufferSize];

            //client info
            clientEndPoint = tcpClient.Client.RemoteEndPoint.ToString();
            Console.WriteLine("Client's endpoint is " + clientEndPoint);

            //read async
            NetworkStream networkStream = tcpClient.GetStream();
            networkStream.BeginRead(byteMessage, 0, tcpClient.ReceiveBufferSize,
                                         new AsyncCallback(ReceiveAsyncCallback), null);
        }

        public void ReceiveAsyncCallback(IAsyncResult iAsyncResult)
        {
            //
            Thread.Sleep(100);
            ThreadPoolMessage("\nMessage is receiving");

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
            Console.WriteLine("Message:" + message);

            //send back message
            byte[] sendMessage = Encoding.UTF8.GetBytes("Message is received!");
            NetworkStream networkStreamWrite = tcpClient.GetStream();
            networkStreamWrite.BeginWrite(sendMessage, 0, sendMessage.Length,
                                            new AsyncCallback(SendAsyncCallback), null);
        }

        
        public void SendAsyncCallback(IAsyncResult iAsyncResult)
        {
           
            Thread.Sleep(100);
            ThreadPoolMessage("\nMessage is sending");

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
