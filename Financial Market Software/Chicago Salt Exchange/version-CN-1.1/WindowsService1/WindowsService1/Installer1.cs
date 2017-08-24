using System;
using System.ServiceProcess;
using System.ComponentModel;
using System.Configuration.Install;


namespace WindowsService1
{
    [RunInstaller(true)]
    public partial class Installer1 : System.Configuration.Install.Installer
    {
        public Installer1()
        {
            InitializeComponent();
            ServiceProcessInstaller serviceExampleProcess = new ServiceProcessInstaller();
            serviceExampleProcess.Account = ServiceAccount.LocalSystem;
            ServiceInstaller serviceExampleInstaller = new ServiceInstaller();
            serviceExampleInstaller.DisplayName = "Service win";

            serviceExampleProcess.Account = ServiceAccount.LocalSystem;
            serviceExampleProcess.Username = null;
            serviceExampleProcess.Password = null;

            serviceExampleInstaller.ServiceName = "Sample Service";
            serviceExampleInstaller.StartType = ServiceStartMode.Automatic;
            Installers.Add(serviceExampleInstaller);
            Installers.Add(serviceExampleProcess);
        }
    }
}
