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

namespace Exchange
{
    class QuoteSender
    {
        public static void sendQuote(string quote) //
        {
            NameValueCollection configuration = ConfigurationManager.AppSettings;
            IPAddress GroupAddress = IPAddress.Parse(configuration["GroupAddress"]);
            int localPort = int.Parse(configuration["LocalPort"]);
            int remotePort = int.Parse(configuration["RemotePort"]);
            int ttl = int.Parse(configuration["TTL"]);


            Socket sock = new Socket(AddressFamily.InterNetwork, SocketType.Dgram,
                        ProtocolType.Udp);
            IPEndPoint iep1 = new IPEndPoint(IPAddress.Broadcast, remotePort);
            //IPEndPoint iep2 = new IPEndPoint(IPAddress.Parse("192.168.1.255"), remotePort);
            string hostname = Dns.GetHostName();
            byte[] data = Encoding.ASCII.GetBytes(quote);
            sock.SetSocketOption(SocketOptionLevel.Socket,
                      SocketOptionName.Broadcast, 1);
            sock.SendTo(data, iep1);
            //sock.SendTo(data, iep2);
            sock.Close();
        }
    }
}





