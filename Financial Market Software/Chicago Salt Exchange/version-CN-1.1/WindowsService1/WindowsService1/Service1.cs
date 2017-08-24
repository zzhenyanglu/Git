using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using server2;
//using client;
using System.Threading;
namespace WindowsService1
{
    public partial class Service1 : ServiceBase
    {
        private System.Timers.Timer timer;

        public Service1()
        {
            InitializeComponent();
            ServiceName = "WinService";
            CanStop = true;
            CanPauseAndContinue = true;
            AutoLog = true;

        }

        private void WriteLogEntry(object sender, ElapsedEventArgs e)
        {
            EventLog.WriteEntry("Service Active :" + e.SignalTime);
        }

        protected override void OnStart(string[] args)
        {
            double interval;
            try
            {
                Program pro = new Program();
                
                interval = Double.Parse(args[0]);
                interval = Math.Max(1000, interval);
                Thread thread = new Thread(new ThreadStart(pro.start_exchange));
                thread.Start();
              
            }
            catch
            {
                interval = 5000;
            }


            EventLog.WriteEntry(String.Format("Service Starting. "
                                                   + "Write Log Entries every {0} milliseconds...", interval));
            timer = new System.Timers.Timer();
            timer.Interval = interval;
            timer.AutoReset = true;
            timer.Elapsed += new ElapsedEventHandler(WriteLogEntry);
            timer.Start();

        }

        protected override void OnStop()
        { 
        }

        protected override void OnPause()
        { }

        protected override void OnContinue()
        { }

        protected override void
                 OnSessionChange(SessionChangeDescription changeDescription)
        { }

    }
}
