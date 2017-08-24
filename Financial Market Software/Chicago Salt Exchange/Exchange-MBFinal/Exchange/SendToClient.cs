using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Net;
using System.Net.Sockets;
using System.IO;

namespace ExecutedOrdersToSend
{
    class TcpClientTest
    {
        private const int portNum = 10117;

        static public void SendOrder(string newOrder)
        {

            TcpClient tcpClient = new TcpClient();
            try
            {
                tcpClient.Connect("localhost", portNum);
                NetworkStream networkStream = tcpClient.GetStream();

                if (networkStream != null && networkStream.CanWrite && networkStream.CanRead)
                {

                    String DataToSend = "";


                    DataToSend = newOrder;


                    Byte[] sendBytes = Encoding.ASCII.GetBytes(DataToSend);
                    networkStream.Write(sendBytes, 0, sendBytes.Length);


                    // Reads the NetworkStream into a byte buffer.
                    byte[] bytes = new byte[tcpClient.ReceiveBufferSize];
                    int BytesRead = networkStream.Read(bytes, 0, (int) tcpClient.ReceiveBufferSize);

                    // Returns the data received from the host to the console.
                    string returndata = Encoding.ASCII.GetString(bytes, 0 , BytesRead);
                    Console.WriteLine(returndata);
                    
                    networkStream.Close();
                    tcpClient.Close();
                }
                else if (!networkStream.CanRead)
                {
                    Console.WriteLine("You can not write data to this stream");
                    tcpClient.Close();
                }
                else if (!networkStream.CanWrite)
                {
                    Console.WriteLine("You can not read data from this stream");
                    tcpClient.Close();
                }
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
        }       // Main() 


        static public void Connect(string message)
        {
            string output = "";

            try
            {
                // Create a TcpClient. 
                // The client requires a TcpServer that is connected 
                // to the same address specified by the server and port 
                // combination.

                TcpClient client = new TcpClient("localhost", portNum);

                // Translate the passed message into ASCII and store it as a byte array.
                Byte[] data = new Byte[256];
                data = System.Text.Encoding.ASCII.GetBytes(message);

                // Get a client stream for reading and writing. 
                // Stream stream = client.GetStream();
                NetworkStream stream = client.GetStream();

                // Send the message to the connected TcpServer. 
                stream.Write(data, 0, data.Length);

                output = "Sent: " + message;
                //MessageBox.Show(output);

                // Buffer to store the response bytes.
                data = new Byte[256];

                // String to store the response ASCII representation.
                String responseData = String.Empty;

                // Read the first batch of the TcpServer response bytes.
                Int32 bytes = stream.Read(data, 0, data.Length);
                responseData = System.Text.Encoding.ASCII.GetString(data, 0, bytes);
                output = "Received: " + responseData;
                //MessageBox.Show(output);

                // Close everything.
                stream.Close();
                client.Close();
            }
            catch (ArgumentNullException e)
            {
                output = "ArgumentNullException: " + e;
                //MessageBox.Show(output);
            }
            catch (SocketException e)
            {
                output = "SocketException: " + e.ToString();
                //MessageBox.Show(output);
            }
            catch (Exception)
            {
                Console.WriteLine("Connection Lost");
            }
        }
    } // class TcpClientTest {
}
