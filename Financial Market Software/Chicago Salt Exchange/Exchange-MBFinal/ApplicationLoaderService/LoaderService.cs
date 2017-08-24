using System;
using System.ServiceProcess;

namespace Toolkit
{
    public partial class LoaderService : ServiceBase
    {
        public LoaderService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            // the name of the application to launch;
            // to launch an application using the full command path simply escape
            // the path with quotes, for example to launch firefox.exe:
            //      String applicationName = "\"C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe\"";

            //@"C:\Exchange\MyNewReflectionExample\bin\Debug\MyNewReflectionExample.exe";

            String applicationName = @"C:\Exchange\Exchange\bin\Debug\Exchange.exe";

            // launch the application
            ApplicationLoader.PROCESS_INFORMATION procInfo;
            ApplicationLoader.StartProcessAndBypassUAC(applicationName, out procInfo);
        }

        protected override void OnStop()
        {
        }
    }
}
