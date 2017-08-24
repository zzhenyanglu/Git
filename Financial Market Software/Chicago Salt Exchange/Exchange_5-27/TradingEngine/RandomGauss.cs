using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Xml.Serialization;


namespace TradingEngine
{
    public class RandomGauss
    {
        //internal ManualResetEvent Finished = new ManualResetEvent(false);
        

        double randOther = 0.0;
        Random rand = new Random();        
        readonly double mu = 100;
        readonly double sigma=10;
        int i = -1;

        public EquityOrder order = new EquityOrder();
        public EquityOrder[] orders = new EquityOrder[10];
        public ArrayList ordersss = new ArrayList();

        public void getList()
        {
            
            for (int i = 0; i < 3; i++)
            {
                Console.WriteLine("Order " + i.ToString());
                Console.WriteLine("Instrument: " + orders[i].Instrument.ToString());
                Console.WriteLine("Buy or Sell: " + orders[i].BuySell.ToString());
                Console.WriteLine("Order Type: " + orders[i].OrderType.ToString());
                Console.WriteLine("Price: " + orders[i].Price.ToString());
                Console.WriteLine("Quantity: " + orders[i].Quantity.ToString());
                Console.WriteLine("Time Stamp: " + orders[i].TimeStamp.ToString());
                Console.WriteLine("OrderID: " + orders[i].OrderID.ToString());
            }
        }

        public string getOrders()
        {
            return ToXML(orders);
        }
        public string getOrder()
        {
            return ToXML(order);
        }
        public void start2()
        {
               double gusassRadVar;
            

            double v1, v2, v3, v4;
            rand = RandomProvider.GetThreadRandom();

            v1 = rand.NextDouble();
            v2 = rand.NextDouble();
            v3 = rand.NextDouble();
            v4 = rand.NextDouble();

                //Order order = new Order();

                lock (this)
                {
                    gusassRadVar = guass();
                    
                };

                this.order.Price = this.mu + this.sigma * gusassRadVar;
                this.order.Instrument = Instrument(v1);
                this.order.BuySell = BuySell(v2);
                this.order.OrderType = OrderType(v3);
                this.order.Quantity = Quantity(v4);
                //ordersss.Add(this.orders[trader]);

        }
        
        
        public void starter()
        {
            int trader = Interlocked.Increment(ref i);
            double gusassRadVar;
            

            double v1, v2, v3, v4;
            rand = RandomProvider.GetThreadRandom();

            v1 = rand.NextDouble();
            v2 = rand.NextDouble();
            v3 = rand.NextDouble();
            v4 = rand.NextDouble();

            orders[trader] = new EquityOrder();

                lock (this)
                {
                    gusassRadVar = guass();
                    
                };
               
                this.orders[trader].Price = this.mu + this.sigma * gusassRadVar;
                this.orders[trader].Instrument = Instrument(v1);
                this.orders[trader].BuySell = BuySell(v2);
                this.orders[trader].OrderType = OrderType(v3);
                this.orders[trader].Quantity = Quantity(v4);
                //ordersss.Add(this.orders[trader]);

        }
        public string ToXML(object orders)
        {
            var stringwriter = new System.IO.StringWriter();
            var serializer = new XmlSerializer(orders.GetType());
            serializer.Serialize(stringwriter, orders);
            return stringwriter.ToString();
        }


        private string Instrument(double rand)
        {
            if ( rand < .5)
                return "BAC";
            else
                return  "WFC";
        }

        public string BuySell(double rand)
        {
            if (rand < .5)
                return "B";
            else
                return "S";
        }
        public string OrderType(double rand)
        {
            if (rand < .5)
                return "LIMIT";
            else
                return "MARKET";
        }
        public int Quantity(double rand)
        {
            return (Int32)(rand * 1000);
        }


        public double guass()
        {
            double randGauss = 0.0;
            double v1, v2, r;
            rand = RandomProvider.GetThreadRandom();

            if (randOther != 0)
            {
                randGauss = randOther;
                randOther = 0.0;
            }
            else
            {
                while (true)
                {
                    v1 = rand.NextDouble() * 2 - 1;
                    v2 = rand.NextDouble() * 2 - 1;
                    r = v1 * v1 + v2 * v2;
                    if (r < 1.0) break;
                }
                randGauss = Math.Sqrt(-2.0 * Math.Log(r) / r) * v1;
                randOther = Math.Sqrt(-2.0 * Math.Log(r) / r) * v2;
            }
            return randGauss;
        }
    }

    public static class RandomProvider
    {
        private static int seed = Environment.TickCount;

        private static ThreadLocal<Random> randomWrapper = new ThreadLocal<Random>(() =>
            new Random(Interlocked.Increment(ref seed))
        );

        public static Random GetThreadRandom()
        {
            return randomWrapper.Value;
        }
    }
    public class Order  //removed abstract
    {
        private string instrument;
        private string buySell;
        private string orderType;
        private double price;
        private int quantity;
        private static long globalOrderId;
        private long orderId;
        private DateTime orderTimeStamp;
        public Order()
        {
            this.orderId = Interlocked.Increment(ref globalOrderId);
            this.orderTimeStamp = DateTime.Now;
        }
        public DateTime TimeStamp
        {
            get { return orderTimeStamp; }
        }
        public string Instrument
        {
            get { return this.instrument; }
            set { this.instrument = value; }
        }
        public string OrderType
        {
            get { return this.orderType; }
            set { this.orderType = value; }
        }
        public string BuySell
        {
            get { return this.buySell; }
            set { this.buySell = value; }
        }
        public double Price
        {
            get { return this.price; }
            set { this.price = value; }
        }
        public int Quantity
        {
            get { return quantity; }
            set { quantity = (value < 0 ? 0 : value); }
        }
        public long OrderID
        {
            get { return orderId; }
            set { orderId = value; }
        }
    }

    public class EquityOrder : Order
    {
        public EquityOrder(string instrument, string orderType, string buySell, double price, int quantity)
        {
            this.Instrument = instrument;
            this.OrderType = orderType;
            this.BuySell = buySell;
            this.Price = price;
            this.Quantity = quantity;
        }
        public EquityOrder() { }
    }
}
