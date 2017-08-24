using System;
using OME;
using OME.Storage;
using System.Diagnostics;
using System.ServiceProcess;
using System.Collections.Generic;
using System.ServiceProcess;
using System.Text;
using System.Timers;
using System.Threading;
using System.Net;
using System.Net.Sockets;


namespace WindowsService
{
    class WindowsService : ServiceBase
    {
        /// <summary>
        /// Public Constructor for WindowsService.
        /// - Put all of your Initialization code here.
        /// </summary>
        public BizDomain equityDomain;
        EquityMatchingEngine.EquityMatchingLogic equityMatchingLogic;
        ManualResetEvent processSignaller;
        public WindowsService()
        {
            this.ServiceName = "My Windows Service";
            this.EventLog.Log = "Application";

            // These Flags set whether or not to handle that specific
            //  type of event. Set to true if you need it, false otherwise.
            this.CanHandlePowerEvent = true;
            this.CanHandleSessionChangeEvent = true;
            this.CanPauseAndContinue = true;
            this.CanShutdown = true;
            this.CanStop = true;

        }

        /// <summary>
        /// The Main Thread: This is where your Service is Run.
        /// </summary>
        static void Main()
        {
            

                ServiceBase[] ServiceToRun;
                ServiceToRun = new ServiceBase[] { new WindowsService() };
                ServiceBase.Run(ServiceToRun);

            
        }

        private void WriteLogEntry(object sender, ElapsedEventArgs e)
        {
            EventLog.WriteEntry("Service Active :" + e.SignalTime);
        }


        /// <summary>
        /// Dispose of objects that need it here.
        /// </summary>
        /// <param name="disposing">Whether
        ///    or not disposing is going on.</param>
        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
        }

        /// <summary>
        /// OnStart(): Put startup code here
        ///  - Start threads, get inital data, etc.
        /// </summary>
        /// <param name="args"></param>
        protected override void OnStart(string[] args)
        {
            EventLog.WriteEntry("In OnStart");
            //Thread listenerThread = new Thread(new ThreadStart(Starter));
            //listenerThread.Start();
            System.Diagnostics.Process.Start(@"C:\Users\Mike\Documents\Visual Studio 2012\Projects\Exchange\Exchange\bin\Debug\Exchange.exe");
        }

        /// <summary>
        /// OnStop(): Put your stop code here
        /// - Stop threads, set final data, etc.
        /// </summary>
        protected override void OnStop()
        {
            base.OnStop();

        }

        /// <summary>
        /// OnPause: Put your pause code here
        /// - Pause working threads, etc.
        /// </summary>
        protected override void OnPause()
        {
            base.OnPause();
        }

        /// <summary>
        /// OnContinue(): Put your continue code here
        /// - Un-pause working threads, etc.
        /// </summary>
        protected override void OnContinue()
        {
            base.OnContinue();
        }

        /// <summary>
        /// OnShutdown(): Called when the System is shutting down
        /// - Put code here when you need special handling
        ///   of code that deals with a system shutdown, such
        ///   as saving special data before shutdown.
        /// </summary>
        protected override void OnShutdown()
        {
            base.OnShutdown();
        }

        /// <summary>
        /// OnCustomCommand(): If you need to send a command to your
        ///   service without the need for Remoting or Sockets, use
        ///   this method to do custom methods.
        /// </summary>
        /// <param name="command">Arbitrary Integer between 128 & 256</param>
        protected override void OnCustomCommand(int command)
        {
            //  A custom command can be sent to a service by using this method:
            //#  int command = 128; //Some Arbitrary number between 128 & 256
            //#  ServiceController sc = new ServiceController("NameOfService");
            //#  sc.ExecuteCommand(command);

            base.OnCustomCommand(command);
        }

        /// <summary>
        /// OnPowerEvent(): Useful for detecting power status changes,
        ///   such as going into Suspend mode or Low Battery for laptops.
        /// </summary>
        /// <param name="powerStatus">The Power Broadcast Status
        /// (BatteryLow, Suspend, etc.)</param>
        protected override bool OnPowerEvent(PowerBroadcastStatus powerStatus)
        {
            return base.OnPowerEvent(powerStatus);
        }

        /// <summary>
        /// OnSessionChange(): To handle a change event
        ///   from a Terminal Server session.
        ///   Useful if you need to determine
        ///   when a user logs in remotely or logs off,
        ///   or when someone logs into the console.
        /// </summary>
        /// <param name="changeDescription">The Session Change
        /// Event that occured.</param>
        protected override void OnSessionChange(
                  SessionChangeDescription changeDescription)
        {
            base.OnSessionChange(changeDescription);
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

            //send new order to exchange here


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