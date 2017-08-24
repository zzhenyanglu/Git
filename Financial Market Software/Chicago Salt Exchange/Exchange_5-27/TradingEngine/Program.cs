using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Net.Sockets;
using System.Net;
using System.IO;
using System.Xml.Serialization;

namespace TradingEngine
{

    class Program
    {
        const int threadCount=10;
        static void Main(string[] args)
        {



            

            //Console.WriteLine("Press any key to continue...");
            //Console.ReadKey(false);

            
            //Console.WriteLine(data_in.ReadToEnd());

            ////when we're done, close up shop.
            //data_in.Close();
            //tcp.Close();

            //this is just to pause the console so you can see what's going on.
            Console.WriteLine("Press any key to continue...");
            //Console.ReadKey(false);
        

            RandomGauss rand = new RandomGauss();


            

            Task[] tasks = new Task[threadCount];
            
            for (int i = 0; i < threadCount; i++)
            {
                //RandomGauss rand = new RandomGauss();
                tasks[i] = Task.Factory.StartNew(() => rand.starter());
            }
            Task.WaitAll(tasks);

            XMLBlaster server = new XMLBlaster();
            RandomGauss rand2 = new RandomGauss();
            //rand2.start2();
            server.myXML = rand.getOrders();
            server.Begin();

            //TcpClient tcp = new TcpClient(AddressFamily.InterNetwork);
            //tcp.Connect(IPAddress.Loopback, 12345);


            //StreamReader data_in = new StreamReader(tcp.GetStream());
            //string myxml = data_in.ReadToEnd();

            //EquityOrder[] newOrder = LoadFromXMLString(myxml);

            //data_in.Close();

            //rand.getOrders();


            //Console.WriteLine(rand.getOrders());
           
            Console.WriteLine("Press any key to continue");
            Console.ReadLine();

        }

        public string ToXML(object trade)
        {
            var stringwriter = new System.IO.StringWriter();
            var serializer = new XmlSerializer(trade.GetType());
            serializer.Serialize(stringwriter, trade);
            return stringwriter.ToString();
        }

        public static EquityOrder[] LoadFromXMLString(string xmlText)
        {
            var stringReader = new System.IO.StringReader(xmlText);
            var serializer = new XmlSerializer(typeof(EquityOrder[]));
            return serializer.Deserialize(stringReader) as EquityOrder[];

            //XmlSerializer xmlSerializer = new XmlSerializer(typeof(Order));
            //StringReader stringReader = new StringReader(xmlText /* result is the value from the database */);
            //Order deserializedEntity = (Order)xmlSerializer.Deserialize(stringReader);
            //return deserializedEntity as Order;
        }

        class XMLBlaster
        {
            Thread myThread;

            public XMLBlaster()
            {
                myThread = new Thread(Start);
            }

            public void Begin()
            {
                myThread.Start();
            }

            //This will listen for a connection on port 12345, and send a tiny XML document
            //to the first person to connect.
            public string myXML;

            protected void Start()
            {
                TcpListener tcp = new TcpListener(IPAddress.Any, 12345);
                tcp.Start(1);

                TcpClient client = tcp.AcceptTcpClient();

                StreamWriter data = new StreamWriter(client.GetStream());

                data.Write(myXML);
                //data.Write("<myxmldocument><node1><node2></node2></node1></myxmldocument>");

                data.Close();
                client.Close();
            }
        }
    }
}
