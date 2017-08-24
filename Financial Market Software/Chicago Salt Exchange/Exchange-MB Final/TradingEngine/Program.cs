using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Net.Sockets;
using System.Net;
using System.IO;
using System.Xml.Serialization;
using System.Timers;

namespace TradingEngine
{

    class Program
    {
        const int threadCount=5;
        static void Main(string[] args)
        {
            ManualResetEvent orderSignaler  = new ManualResetEvent(false);

            RandomGauss[] traders = new RandomGauss[threadCount];

            for (int i = 0; i < threadCount; i++)
            {
                traders[i] = new RandomGauss(i);
            }

            //sets up listener for price quotes
            QuoteReceiver newQuote = new QuoteReceiver();
            ThreadPool.QueueUserWorkItem(new WaitCallback(newQuote.startQuoteListener));

            //SynchronousSocketListener newExecutedOrderListener = new SynchronousSocketListener();
            Task.Factory.StartNew(() => SynchronousSocketListener.StartListening());



            Task[] tasks = new Task[threadCount];


            for (int j = 0; j < 10000; j++)
            {
                for (int trader = 0; trader < threadCount; trader++)
                {

                    tasks[trader] = Task.Factory.StartNew(() => traders[trader].start(new FuturesOrder()));

                    orderSignaler.WaitOne(1000);//we can update this to be a random pause
                }
                //Task.WaitAll(tasks); if we have the pause I don't think we need to wait for all threads to finish

            }
            //Task.WaitAll(tasks);
            Console.WriteLine("Press any key to continue");
            Console.ReadLine();

        }

        public static string ToXML(object trade)
        {
            var stringwriter = new System.IO.StringWriter();
            var serializer = new XmlSerializer(trade.GetType());
            serializer.Serialize(stringwriter, trade);
            return stringwriter.ToString();
        }
        public static FuturesOrder LoadFromXMLString(string xmlText)
        {
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(FuturesOrder));
            StringReader stringReader = new StringReader(xmlText /* result is the value from the database */);
            FuturesOrder deserializedEntity = (FuturesOrder)xmlSerializer.Deserialize(stringReader);
            return deserializedEntity as FuturesOrder;
        }
    }

class TcpClientTest2
{

    private const int portNum = 10116;
    TcpClient tcpClient ;
    NetworkStream networkStream;

    public void StartConnection()
    {
        tcpClient = new TcpClient();
        try
        {
            tcpClient.Connect("localhost", portNum);
            networkStream = tcpClient.GetStream();
        }
        catch (SocketException)
        {
            Console.WriteLine("Sever not available!");
        }
        catch (System.IO.IOException)
        {
            Console.WriteLine("Sever not available!");
        }
        catch (Exception e)
        {
            Console.WriteLine(e.ToString());
        }
    }


    public  void sendOrders(string newOrder)
    {
        try
        {
            if (networkStream!= null && networkStream.CanWrite && networkStream.CanRead)
            {

                String DataToSend = "";

                //while ( DataToSend != "quit" ) {

                //Console.WriteLine("\nType a text to be sent:");
                DataToSend = newOrder;
                //if ( DataToSend.Length == 0 ) break ;

                Byte[] sendBytes = Encoding.ASCII.GetBytes(DataToSend);
                networkStream.Write(sendBytes, 0, sendBytes.Length);
                networkStream.Flush();


                // Reads the NetworkStream into a byte buffer.
                byte[] bytes = new byte[tcpClient.ReceiveBufferSize];
                int BytesRead = networkStream.Read(bytes, 0, (int)tcpClient.ReceiveBufferSize);

                // Returns the data received from the host to the console.
                string returndata = Encoding.ASCII.GetString(bytes, 0, BytesRead);
                Console.WriteLine(returndata);

            }
            else
            {
                StartConnection();
                sendOrders(newOrder);
            }
        }
        catch(Exception)
        {
            StartConnection();
            sendOrders(newOrder);
        }
    }
    public void quit()
    {
        networkStream.Close();
        tcpClient.Close();
    }
     // Main() 
} // class TcpClientTest {
    
}
