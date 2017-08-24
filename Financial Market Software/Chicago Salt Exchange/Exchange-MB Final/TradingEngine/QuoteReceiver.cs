using System;
using System.Collections.Generic;
using System.Collections;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.IO;
using System.Net.Sockets;
using System.Net;
using System.Net.Configuration;
using System.Text.RegularExpressions;
using System.Threading;
using System.Windows;
using System.Xml.Linq;

namespace TradingEngine
{
    class QuoteReceiver
    {
        ManualResetEvent orderSignaler;
        public QuoteReceiver()
        {
        orderSignaler = new ManualResetEvent(false);
        }

        public void startQuoteListener(Object a)
        {
            RandomGauss randLink = a as RandomGauss;
            while (true)
            {
                orderSignaler.WaitOne(1000);
                ReceiveQuote(randLink);
                
            }
        }

        public static void ReceiveQuote(RandomGauss randLink)
        {
            NameValueCollection configuration = ConfigurationManager.AppSettings;
            IPAddress GroupAddress = IPAddress.Parse(configuration["GroupAddress"]);
            int localPort = int.Parse(configuration["LocalPort"]);
            int remotePort = int.Parse(configuration["RemotePort"]);
            int ttl = int.Parse(configuration["TTL"]);

            Socket sock = new Socket(AddressFamily.InterNetwork,
                    SocketType.Dgram, ProtocolType.Udp);
            IPEndPoint iep = new IPEndPoint(IPAddress.Any, remotePort);
            sock.Bind(iep);
            EndPoint ep = (EndPoint)iep;
            //Console.WriteLine("Ready to receive…");
            byte[] data = new byte[1024];
            int recv = sock.ReceiveFrom(data, ref ep);
            string stringData = Encoding.ASCII.GetString(data, 0, recv);
            //Console.WriteLine("received: {0} from: {1}", stringData, ep.ToString());
            data = new byte[1024];
            recv = sock.ReceiveFrom(data, ref ep);
            stringData = Encoding.ASCII.GetString(data, 0, recv);

            //Console.WriteLine("received: {0} from: {1}", stringData, ep.ToString());
            sock.Close();
            
            //randLink.SetCurrentPrice(quote[0].ToString(), quote[1].ToString(), quote[2].ToString());

            string[] quote = stringData.Split(',');
            //
            string Ticker = XElement.Parse(stringData).Attribute("PriceQuote").Value;
            string BuyPrice = XElement.Parse(stringData).Descendants("Field").First().Value;
            string SellPrice = XElement.Parse(stringData).Descendants("Field").ElementAt(1).Value;



            Price.SetCurrentPrice(Ticker, BuyPrice, SellPrice);


        }
    }
}
