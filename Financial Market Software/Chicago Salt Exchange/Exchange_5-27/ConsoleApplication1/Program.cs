using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            List<List<Order>> newTestOrder = new List<List<Order>>();

            //ArrayList[] neworder
            Order newOrder1 = new Order(20, 123);

            newTestOrder[0].Add(newOrder1);

            Order newOrder = new Order(20, 123);
            for (int i = 0; i < 10; i++)
            {
                int sort;
                foreach (Order tOrder in newTestOrder[0])
                {
                    sort = tOrder.Price.CompareTo(newOrder.Price);
                    if (sort > 1)
                        Console.WriteLine("WORKS");
                    else if (sort == 0)
                        Console.WriteLine("samePrice");
                    else
                        Console.WriteLine("new price");
                }
                
            }
        }
    }
    class Order
    {
        public double Price {get; set;}
        long ID;
        public Order(double price, long iD) 
        {
            this.Price = price;
            this.ID = iD;
        }

    }
}
