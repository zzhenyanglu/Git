using System;
using System.Net;
using System.IO;
using System.Net.Sockets;
using System.Text;
using System.Collections;
using System.Threading;
using OME.Storage;
using OME;
using System.Threading.Tasks;

class ClientConnectionPool
{

    // Creates a synchronized wrapper around the Queue.
    private Queue SyncdQ = Queue.Synchronized(new Queue());

    public void Enqueue(ClientHandler client)
    {
        SyncdQ.Enqueue(client);
    }

    public ClientHandler Dequeue()
    {
        return (ClientHandler)(SyncdQ.Dequeue());
    }

    public int Count
    {
        get { return SyncdQ.Count; }
    }

    public object SyncRoot
    {
        get { return SyncdQ.SyncRoot; }
    }

} // class ClientConnectionPool

class ClientService
{

    const int NUM_OF_THREAD = 10;

    private ClientConnectionPool ConnectionPool;
    private bool ContinueProcess = false;
    private Thread[] ThreadTask = new Thread[NUM_OF_THREAD];

    public ClientService(ClientConnectionPool ConnectionPool)
    {
        this.ConnectionPool = ConnectionPool;
    }

    public void Start()
    {
        ContinueProcess = true;
        // Start threads to handle Client Task
        for (int i = 0; i < ThreadTask.Length; i++)
        {

            ThreadTask[i] = new Thread(new ThreadStart(this.Process));
            ThreadTask[i].Start();
        }
    }

    private void Process()
    {
        while (ContinueProcess)
        {

            ClientHandler client = null;
            lock (ConnectionPool.SyncRoot)
            {
                if (ConnectionPool.Count > 0)
                    client = ConnectionPool.Dequeue();
            }
            if (client != null)
            {
                client.Process(); // Provoke client
                // if client still connect, schedufor later processingle it 
                if (client.Alive)
                    ConnectionPool.Enqueue(client);
            }

            Thread.Sleep(100);
        }
    }

    public void Stop()
    {
        ContinueProcess = false;
        for (int i = 0; i < ThreadTask.Length; i++)
        {
            if (ThreadTask[i] != null && ThreadTask[i].IsAlive)
                ThreadTask[i].Join();
        }

        // Close all client connections
        while (ConnectionPool.Count > 0)
        {
            ClientHandler client = ConnectionPool.Dequeue();
            client.Close();
            Console.WriteLine("Client connection is closed!");
        }
    }

} // class ClientService

public class SynchronousSocketListener
{

    private const int portNum = 10116;
    

    public static void StartListening(BizDomain equityDomain)
    {

        ManualResetEvent waitForConnect = new ManualResetEvent(false);
        ClientService ClientTask;
        IPAddress localAddr = IPAddress.Parse("127.0.0.1");

        // Client Connections Pool
        ClientConnectionPool ConnectionPool = new ClientConnectionPool();

        // Client Task to handle client requests
        ClientTask = new ClientService(ConnectionPool);

        ClientTask.Start();

        TcpListener listener = new TcpListener(localAddr, portNum);
        try
        {
            listener.Start();

            int TestingCycle = 3; // Number of testing cycles
            int ClientNbr = 0;

            // Start listening for connections.
            Console.WriteLine("Waiting for a connection...");
            while (TestingCycle > 0 && EquityMatchingEngine.OMEHost.running == true)
            {

                TcpClient handler = listener.AcceptTcpClient();

                if (handler != null)
                {
                    Console.WriteLine("Client#{0} accepted!", ++ClientNbr);

                    // An incoming connection needs to be processed.
                    ConnectionPool.Enqueue(new ClientHandler(handler, equityDomain));

                    //--TestingCycle;
                }
                else
                    break;
                waitForConnect.WaitOne(100); // 
            }
            listener.Stop();
            Console.WriteLine("Order Listener Stoped");
            // Stop client requests handling
            ClientTask.Stop();


        }
        catch (Exception e)
        {
            Console.WriteLine(e.ToString());
        }

        Console.WriteLine("\nHit enter to continue...");
        Console.Read();
    }
}


class ClientHandler
{

    private TcpClient ClientSocket;
    private NetworkStream networkStream;
    bool ContinueProcess = false;
    private byte[] bytes; 		// Data buffer for incoming data.
    private StringBuilder sb = new StringBuilder(); // Received data string.
    //ArrayList ordersRecd = new ArrayList();
    private string data = null; // Incoming data from the client.
    BizDomain domain;
    public static string orderIDs = "";

    public ClientHandler(TcpClient ClientSocket, BizDomain equityDomain)
    {
        ClientSocket.ReceiveTimeout = 100; // 100 miliseconds
        this.ClientSocket = ClientSocket;
        networkStream = ClientSocket.GetStream();
        bytes = new byte[ClientSocket.ReceiveBufferSize];
        ContinueProcess = true;
        domain = equityDomain;
    }

    public void Process()
    {

        if (EquityMatchingEngine.OMEHost.running == false)
        {
            networkStream.Close();
            ClientSocket.Close();
            ContinueProcess = false;
            Console.WriteLine("Exchange is closed!");
        }

        try
        {
            int BytesRead = networkStream.Read(bytes, 0, (int)bytes.Length);
            if (BytesRead > 0)
            {
                // There might be more data, so store the data received so far.
                sb.Append(Encoding.ASCII.GetString(bytes, 0, BytesRead));
            }

            else
                // All the data has arrived; put it in response.
                ProcessDataReceived();

        }
        catch (IOException)
        {
            //Console.WriteLine(sb.Length.ToString());
            // All the data has arrived; put it in response.
            ProcessDataReceived();
        }
        catch (SocketException)
        {
            networkStream.Close();
            ClientSocket.Close();
            ContinueProcess = false;
            Console.WriteLine("Conection is broken!");
        }

    }  // Process()

    private void ProcessDataReceived()
    {

        try
        {
            if (sb.Length > 0)
            {
                bool bQuit = (String.Compare(sb.ToString(), "quit", true) == 0);

                data = sb.ToString();

                sb.Length = 0; // Clear buffer

                Console.WriteLine("Text received from client:");

                FuturesOrder newOrder = EquityMatchingEngine.OMEHost.LoadFromXMLString(data);

                orderIDs += newOrder.OrderID.ToString() + ",";
                Task.Factory.StartNew(() => domain.SubmitOrder(newOrder));

                string response;

                response = (" Order Received");

                // Echo the data back to the client.
                byte[] sendBytes = Encoding.ASCII.GetBytes(response.ToString());
                networkStream.Write(sendBytes, 0, sendBytes.Length);

                // Client stop processing
                if (bQuit)
                {
                    networkStream.Close();
                    ClientSocket.Close();
                    ContinueProcess = false;
                }
            }
        }

        catch (Exception)
        {
            networkStream.Close();
            ClientSocket.Close();
            ContinueProcess = false;
        }
    }
    public void Close()
    {
        networkStream.Close();
        ClientSocket.Close();
    }

    public bool Alive
    {
        get
        {
            return ContinueProcess;
        }
    }

} // class ClientHandler 

