using System;
using System.Reflection;
namespace ReflectionExamples
{
    public interface IPlug_in
    {
        //create and interface forcing all of the plugins to implement start and stop and adding
        // descriptions.  To create your interface add your own method prototypes and values.
        // notice the get and set values that will force the description to implement getters and setters.

        string Description { get; set; }
        void Start();
        void Stop();
    }

         public abstract class APlug_in : IPlug_in
     {
         //implement the interface.  Notice that the methods are declared as abstract which will then
         //be overridden by whatever plug in you want to implement.  Notice that the description 
         //implements the setter and getter methods so that the functionality will be passed into the 
          //plugin.
 
          private string description = "";
          
          public string Description
          {
                get { return description; }
                set {description = value; }
           }
 
           public abstract void Start();
           public abstract void Stop();
       }
 
       //public class SamplePlug_in: APlug_in
       //{
       //    // This is the plugin that is implemented.  For this example it is in the same class as the rest of 
       //    // the code but to use the factory this plugin would be in another assembly.
 
       //     public override void Start()
       //      {
       //           // Add some code here for what you want to happen when something starts
       //      }
 
       //     public override void Stop()
       //     {
       //            //Add some more code for what else you want to happen
       //     }
       // }
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

                public static APlug_in CreatePlug_in(string assembly_name, string plug_in_name, 
                                                                                string description)
             {
                 Assembly assembly = Assembly.LoadFile(assembly_name);
                 Type type = assembly.GetType(plug_in_name);

                 //var obj = Activator.CreateInstance(type);
                 //Type objType = obj.GetType();

                   //Type type = Type.GetType(plug_in_name + "," + assembly_name);
                   ConstructorInfo cInfo = type.GetConstructor(Type.EmptyTypes);

                   (type)plug_in = (type)cInfo.Invoke(null);
                   

                   plug_in.Description = description;
                   return plug_in;
             }
 
          public static void Main(string[] args)
           {
              //This is where the plugin will be called from.  Add the assembly name, the class name and its 
              // description.  The factory will use reflection to create this object.//<class name including path>
              //@"C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Exchange\v4.0_1.0.0.2__2826632d9194fefe\Exchange.dll", "EquityMatchingEngine.Test", "Starting Exchange");
               APlug_in plug_in = Plug_inFactory.CreatePlug_in(@"C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Exchange\v4.0_1.0.0.2__2826632d9194fefe\Exchange.dll", "EquityMatchingEngine.Test", "Starting Exchange");
               plug_in.Start();
               plug_in.Stop();
           }
     }
        }
