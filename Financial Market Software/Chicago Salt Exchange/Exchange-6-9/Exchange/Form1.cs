using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Exchange
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (EquityMatchingEngine.OMEHost.running == false)
            {
                EquityMatchingEngine.OMEHost.running = true;
                EquityMatchingEngine.OMEHost.startTime = DateTime.Now;
                System.Threading.Thread t = new System.Threading.Thread(new System.Threading.ThreadStart(EquityMatchingEngine.OMEHost.Start));
                t.Start();
                
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (EquityMatchingEngine.OMEHost.running == true)
            {
                EquityMatchingEngine.OMEHost.running = false;
                EquityMatchingEngine.OMEHost.open = false;
            }
        }
    }
}
