using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MyNewReflectionExample
{
    public partial class Exchange_Starter : Form
    {
        public Exchange_Starter()
        {
            InitializeComponent();
        }

        private void starterForm_Load(object sender, EventArgs e)
        {

        }


        private void button1_Click_1(object sender, EventArgs e)
        {
            ReflectionExamples2.Plug_inFactory.Start(ReflectionExamples2.Plug_inFactory.assembly, ReflectionExamples2.Plug_inFactory.instantiateClass, "Start");
        }

        private void button2_Click(object sender, EventArgs e)
        {
            ReflectionExamples2.Plug_inFactory.Start(ReflectionExamples2.Plug_inFactory.assembly, ReflectionExamples2.Plug_inFactory.instantiateClass, "Stop");
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }
    }
}
