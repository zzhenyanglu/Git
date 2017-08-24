using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Xml.Serialization;
using System.Net.Sockets;
using System.Net;
using System.IO;

namespace TradingEngine
{

    public static class Price
    {
        private static double instrumentPrice = 100;

        public static double InstrumentPrice { get { return instrumentPrice; }}

        public static void SetCurrentPrice(string instrument, string buyOffer, string sellOffer)
        {
            //need to have an if here to update different prices//need to look into why no prices 
            if (buyOffer == "N/A" && sellOffer != "") instrumentPrice = Convert.ToDouble(sellOffer);
            else if (sellOffer == "N/A" && buyOffer != "") instrumentPrice = Convert.ToDouble(buyOffer);
            else if (buyOffer == "" || sellOffer == "")
                Console.WriteLine("No price");
            else instrumentPrice = (Convert.ToDouble(buyOffer) + Convert.ToDouble(sellOffer)) / 2.0;
            Console.WriteLine(instrumentPrice.ToString());
        }
    }

    public class RandomGauss
    {

        public static Hashtable ordersInProcess = new Hashtable();
        //internal ManualResetEvent Finished = new ManualResetEvent(false);
        GaussianRandom GaussRand;
        TcpClientTest2 newConnection;
        int trader;
        int orderNumber;
        
        double randOther = 0.0;
        Random rand = new Random();
        readonly double sigma = 10;
        int i = -1;

        public RandomGauss(int traderNum)
        {
            trader = traderNum;
            GaussRand = new GaussianRandom();
            rand = RandomProvider.GetThreadRandom();
            newConnection = new TcpClientTest2();
            newConnection.StartConnection();
        }
        
        public void start(FuturesOrder newOrder)
        {
            double gusassRadVar;
            orderNumber = Interlocked.Increment(ref i) + (trader * 1000000);
            

            double v1, v2, v3, v4, v5;
            rand = RandomProvider.GetThreadRandom();

            v1 = rand.NextDouble();
            v2 = rand.NextDouble();
            v3 = rand.NextDouble();
            v4 = rand.NextDouble();
            v5 = rand.NextDouble();
            //Order order = new Order();

            gusassRadVar = GaussRand.StartNextGaussian();

            newOrder.CustomerID = trader;

            newOrder.OrderAction = OrderAction(v5);

            if (newOrder.OrderAction == "NEW")
            {

                newOrder.OrderType = OrderType(v3);
                newOrder.OrderID = orderNumber;

                if (newOrder.OrderType == "LIMIT")
                {
                    newOrder.BuySell = BuySell(v2);
                    gusassRadVar = (newOrder.BuySell == "B" ? Math.Min(1.0, gusassRadVar) : Math.Max(-1, gusassRadVar));//to prevent buy orders from meing too high and sell orders too low
                    newOrder.LimitPrice = Math.Round(Price.InstrumentPrice + this.sigma * gusassRadVar,2);
                    newOrder.Instrument = Instrument(v1);
                    newOrder.Quantity = Quantity(v4);
                    newOrder.OrigQuantity = newOrder.Quantity;
                    
                }
                else if (newOrder.OrderType == "MARKET")
                {
                    newOrder.LimitPrice = Price.InstrumentPrice;
                    newOrder.Instrument = Instrument(v1);
                    newOrder.BuySell = BuySell(v2);
                    newOrder.Quantity = Quantity(v4);
                    newOrder.OrigQuantity = newOrder.Quantity;
                }
                else if (newOrder.OrderType == "STOP")
                {
                    newOrder.StopPrice = Math.Round(Price.InstrumentPrice + this.sigma * gusassRadVar, 2);
                    newOrder.Instrument = Instrument(v1);
                    newOrder.BuySell = BuySell(v2);
                    newOrder.Quantity = Quantity(v4);
                    newOrder.OrigQuantity = newOrder.Quantity;
                }
                else
                {
                    Console.WriteLine("Not valid order type");
                }
            }
            else if (newOrder.OrderAction == "DELETE")
            {
                //have to pull from previous orders some how 
                // we need original order ID , customer ID, instrumnet, and BuySell
                int orders = ordersInProcess.Count;
                if ( orders != 0)//not working
                {
                    int orderToDel = rand.Next(ordersInProcess.Count);
                    int iter=0;
                    foreach (DictionaryEntry order in ordersInProcess)
                    {
                        if (iter==orderToDel)
                        {
                            newOrder = order.Value as FuturesOrder;
                            break;
                        }
                        iter++;
                    }
                    ordersInProcess.Remove(newOrder.OrderID.ToString());
                    newOrder.OrderAction = "DELETE";
                }
                else
                    return;
            }
            else //(newOrder.OrderAction == "Update")
            {
                //have to pull from previous orders some how 
                // we need original order ID , customer ID, instrumnet, and BuySell
                int orders = ordersInProcess.Count;
                if (orders != 0)//not working
                {
                    int orderToUpdate = rand.Next(ordersInProcess.Count);
                    int iter = 0;
                    foreach (DictionaryEntry order in ordersInProcess)
                    {
                        if (iter == orderToUpdate)
                        {
                            newOrder = order.Value as FuturesOrder;
                            break;
                        }
                        iter++;
                    }
                    ordersInProcess.Remove(newOrder.OrderID.ToString());
                    newOrder.OrderAction = "UPDATE";
                    newOrder.LimitPrice = Price.InstrumentPrice + this.sigma * gusassRadVar; //submits update order with new price, uses same order number
                    newOrder.Quantity = Quantity(v4);
                }
                else
                    return;
            }
            lock (this)
            {
                newConnection.sendOrders(ToXML(newOrder));
            }
            if (newOrder.OrderAction == "NEW")
                ordersInProcess.Add(newOrder.OrderID.ToString(), newOrder);// orders will be stored here until order is executed
        }

        public static void OrderExecuted(FuturesOrder ExOrder)//removes executed orders from data store
        {

            if (ordersInProcess.ContainsKey(ExOrder.OrderID.ToString()) == true)
            {
                ordersInProcess.Remove(ExOrder.OrderID.ToString());
            }
            else
            {
                Console.WriteLine("No record of order");
            }
        }
        private string Instrument(double rand)
        {
            return "RSXM";
            //if ( rand < .5)
            //    return "BAC";
            //else
            //    return  "WFC";
        }
        private string OrderAction(double rand)
        {
            if (rand < .9)
                return "NEW";
            else if (rand < .95)
                return "DELETE";
            else
                return "UPDATE";
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
            if (rand < .7)
                return "LIMIT";
            else if (rand < .8)
                return "STOP";
            else
                return "MARKET";
        }
        public int Quantity(double rand)
        {
            return (Int32)(rand * 1000);
        }
    
        
            public string ToXML(object orders)
            {
                var stringwriter = new System.IO.StringWriter();
                var serializer = new XmlSerializer(orders.GetType());
                serializer.Serialize(stringwriter, orders);
                return stringwriter.ToString();
            }


            
            public double guassLock()
            {
                double value;
                lock (this)
                {
                    value = guass();
                }
                return value;
            }

            public double guass()
            {
                double randGauss = 0.0;
                double v1, v2, r;


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

    public sealed class GaussianRandom
        {
            private bool _hasDeviate;
            private double _storedDeviate;
            private Random _random;
            public ArrayList averages = ArrayList.Synchronized(new ArrayList());

            public GaussianRandom(Random random = null)
            {
                _random = random ?? new Random();

            }

            /// <summary>
            /// Obtains normally (Gaussian) distributed random numbers, using the Box-Muller
            /// transformation.  This transformation takes two uniformly distributed deviates
            /// within the unit circle, and transforms them into two independently
            /// distributed normal deviates.
            /// </summary>
            /// <param name="mu">The mean of the distribution.  Default is zero.</param>
            /// <param name="sigma">The standard deviation of the distribution.  Default is one.</param>
            /// <returns></returns>
            /// 
            public double StartNextGaussian(double mu = 0, double sigma = 1)
            {
                double value;
                lock (this)
                {
                    value = NextGaussian();
                }
                return value;

            }
            public double NextGaussian(double mu = 0, double sigma = 1)
            {
                _random = RandomProvider.GetThreadRandom();
                if (sigma <= 0)
                    throw new ArgumentOutOfRangeException("sigma", "Must be greater than zero.");

                if (_hasDeviate)
                {
                    _hasDeviate = false;
                    return _storedDeviate * sigma + mu;
                }

                double v1, v2, rSquared;
                do
                {
                    // two random values between -1.0 and 1.0
                    v1 = 2 * _random.NextDouble() - 1;
                    v2 = 2 * _random.NextDouble() - 1;
                    rSquared = v1 * v1 + v2 * v2;
                    // ensure within the unit circle
                } while (rSquared >= 1 || rSquared == 0);

                // calculate polar tranformation for each deviate
                var polar = Math.Sqrt(-2 * Math.Log(rSquared) / rSquared);
                // store first deviate
                _storedDeviate = v2 * polar;
                _hasDeviate = true;
                // return second deviate
                return v1 * polar * sigma + mu;
            }
        }
        public sealed class GaussianRandomv2
        {
            private bool _hasDeviate;
            private double _storedDeviate;
            private Random _random;
            public ArrayList averages = ArrayList.Synchronized(new ArrayList());

            public GaussianRandomv2(Random random = null)
            {
                _random = random ?? new Random();
                _random = RandomProvider.GetThreadRandom();
            }

            /// <summary>
            /// Obtains normally (Gaussian) distributed random numbers, using the Box-Muller
            /// transformation.  This transformation takes two uniformly distributed deviates
            /// within the unit circle, and transforms them into two independently
            /// distributed normal deviates.
            /// </summary>
            /// <param name="mu">The mean of the distribution.  Default is zero.</param>
            /// <param name="sigma">The standard deviation of the distribution.  Default is one.</param>
            /// <returns></returns>
            /// 
            public double StartNextGaussian(double mu = 0, double sigma = 1)
            {
                double value;
                lock (this)
                {
                    value = NextGaussian();
                }
                return value;

            }
            public double NextGaussian(double mu = 0, double sigma = 1)
            {
                //_random = RandomProvider.GetThreadRandom();
                if (sigma <= 0)
                    throw new ArgumentOutOfRangeException("sigma", "Must be greater than zero.");

                if (_hasDeviate)
                {
                    _hasDeviate = false;
                    return _storedDeviate * sigma + mu;
                }

                double v1, v2, rSquared;
                do
                {
                    // two random values between -1.0 and 1.0
                    v1 = 2 * _random.NextDouble() - 1;
                    v2 = 2 * _random.NextDouble() - 1;
                    rSquared = v1 * v1 + v2 * v2;
                    // ensure within the unit circle
                } while (rSquared >= 1 || rSquared == 0);

                // calculate polar tranformation for each deviate
                var polar = Math.Sqrt(-2 * Math.Log(rSquared) / rSquared);
                // store first deviate
                _storedDeviate = v2 * polar;
                _hasDeviate = true;
                // return second deviate
                return v1 * polar * sigma + mu;
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
        public abstract class Order
        {
            string instrument;
            string status;
            string message;
            string buySell;
            string orderType;
            string orderAction;
            double stopPrice;
            double limitPrice;
            int origQuantity;
            int orderQuantity;
            static long globalOrderId;
            long orderId;
            long customerID;
            bool active = true;
            DateTime orderTimeStamp;
            public double executionPrice;
            public int executionQuantity;
            public DateTime executionTimeStamp;

            public Order()
            {
                orderId = Interlocked.Increment(ref globalOrderId);
                orderTimeStamp = DateTime.Now;
            }
            public double ExecutionPrice
            {
                get { return executionPrice; }
                set { executionPrice = value; }
            }
            public int ExecutionQuantity
            {
                get { return executionQuantity; }
                set { executionQuantity = value; }
            }
            public DateTime ExecutionTimeStamp
            {
                get { return executionTimeStamp; }
                set { executionTimeStamp = value; }
            }
            public DateTime TimeStamp
            {
                get { return orderTimeStamp; }
            }
            public string Instrument
            {
                get { return instrument; }
                set { instrument = value; }
            }
            public string Status
            {
                get { return status; }
                set { status = value; }
            }
            public string Message
            {
                get { return message; }
                set { message = value; }
            }
            public string OrderAction
            {
                get { return orderAction; }
                set { orderAction = value; }
            }
            [XmlIgnore]
            public bool Active
            {
                get { return active; }
                set { active = value; }
            }
            public string OrderType
            {
                get { return orderType; }
                set { orderType = value; }
            }
            public string BuySell
            {
                get { return buySell; }
                set { buySell = value; }
            }
            public double LimitPrice
            {
                get { return limitPrice; }
                set { limitPrice = value; }
            }
            public double StopPrice
            {
                get { return stopPrice; }
                set { stopPrice = value; }
            }
            public int Quantity
            {
                get { return orderQuantity; }
                set { orderQuantity = (value < 0 ? 0 : value); }
            }
            public long OrderID
            {
                get { return orderId; }
                set { orderId = value; }
            }
            public long CustomerID
            {
                get { return customerID; }
                set { customerID = value; }
            }
            public int OrigQuantity
            {
                get { return origQuantity; }
                set { origQuantity = value; }
            }
        }

        public class FuturesOrder : Order
        {
            public FuturesOrder(string instrument, string orderType, string buySell, double price, int quantity, long orderID, long custID, string orderAction)
            {
                this.Instrument = instrument;
                this.OrderType = orderType;
                this.BuySell = buySell;
                this.LimitPrice = (orderType == "LIMIT" ? price : 0);
                this.StopPrice = (orderType == "STOP" ? price : 0);
                this.Quantity = quantity;
                this.OrigQuantity = quantity;
                this.OrderID = orderID;
                this.CustomerID = custID;
                this.OrderAction = orderAction;
            }
            public FuturesOrder() { }
        }
        public class ExecutedOrders : Order
        {
            public double ExecutionPrice;
            public double ExecutionQuantity;
            public DateTime executionTimeStamp;

            public ExecutedOrders(Order order, int executionQuantity, double executionPrice)
            {
                this.Instrument = order.Instrument;
                this.OrderType = order.OrderType;
                this.BuySell = order.BuySell;
                this.LimitPrice = order.LimitPrice;
                this.StopPrice = order.StopPrice;
                this.OrigQuantity = order.OrigQuantity;
                this.OrderID = order.OrderID;
                this.CustomerID = order.CustomerID;
                this.ExecutionPrice = executionPrice;
                this.ExecutionQuantity = executionQuantity;
                this.executionTimeStamp = DateTime.Now;
            }
            public ExecutedOrders() { }
        }

}
    
