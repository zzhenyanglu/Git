using System;
using System.Reflection;
using System.Windows.Forms;
using System.Threading.Tasks;

namespace ReflectionExamples2
{
    public sealed class Plug_inFactory
    {
        // This is a common pattern for implementing an object from another assembly.  This can also 
        // be accomplished by using the static methods CreateInstance and CreateInstanceFrom in 
        //System.Activator.  In this pattern the type is found from class and assembly name using
        //reflection on that type.  The constructors for that object type are then found and any types
        //can be passed in.  In this case a default constructor is used (Type.EmptyType) and the 
        // the properties can be done at configuration time.  The other approach is to provide 
        // documentation for any parameters for the constructors.  Once the constructor is found
        // the object can be invoked (created).
        // Neat ey!

        public static void Start(string assembly_name, string plug_in_name,  string description)
        {
            Assembly assembly = Assembly.LoadFile(assembly_name);
            Type type = assembly.GetType(plug_in_name);

            //ConstructorInfo cInfo = type.GetConstructor(Type.EmptyTypes);

            //IPlug_in plug_in = (IPlug_in)cInfo.Invoke(null);
            object calcInstance = Activator.CreateInstance(type);

            //type.InvokeMember("Start", BindingFlags.InvokeMethod | BindingFlags.Instance | BindingFlags.Public, null, calcInstance, null);
            Task.Factory.StartNew(() => type.InvokeMember(description, BindingFlags.InvokeMethod | BindingFlags.Static | BindingFlags.Public, null, null, null));

            //plug_in.Description = description;
            //return plug_in;
        }
       
        public static string assembly = @"C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Exchange\v4.0_1.0.0.2__2826632d9194fefe\Exchange.dll";
        public static string instantiateClass = "EquityMatchingEngine.OMEHost";

        public static void Main(string[] args)
        {
            //This is where the plugin will be called from.  Add the assembly name, the class name and its 
            // description.  The factory will use reflection to create this object.//<class name including path>
            //@"C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Exchange\v4.0_1.0.0.2__2826632d9194fefe\Exchange.dll", "EquityMatchingEngine.Test", "Starting Exchange");
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MyNewReflectionExample.Exchange_Starter());
            
        }
    }
}
