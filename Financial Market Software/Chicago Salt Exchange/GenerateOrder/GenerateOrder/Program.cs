using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

namespace GenerateOrder
{
    class Program
    {
        //for trader n  id start from n*1000000
        int id = 1000000;
        static double[] historic={21,23,21,24,21,23,24,24,25};

        static int testNum=0;
        static void Main(string[] args)
        {
           /***
            * the code professor given in the class, I do not want to use it. 
            * question:  double tau: what is it? how to assign? 
            * 
            * **/
        /*   double mean = MeasureMeanFromHistoric(historic, 0.5, historic.Length);
            Console.WriteLine(mean);

            double vola = MeasureVolatilityFromHistoric(historic, 0.5, historic.Length);
            Console.WriteLine(vola);

            double newPrice = SimulateAsset(29.1, mean, vola, 10, 0.5);
            Console.WriteLine(newPrice);
            */
        

            /****
             * To update order or cancel order will choose one order from TraderN.xml that record trader's balance and order infomation
             * 
             * ***/
            Console.WriteLine(newOrder());

          

            
            Console.Read();
        }

      
        static string newOrder() 
        {
            string instument = generateInstument();
            string orderType = generateOrderType();
            string BuySell = generateBuySell();
            double price = generatePrice();
            int quantity = generateQuantity();
            string newOrder = instument + " " + orderType + " " + BuySell + " " + price + " " + quantity;
            return newOrder;
        
        }

       static string generateInstument()
        {
            return "Salt";
            //maybe indicate maturity 
        }
       static string generateOrderType()
        {
            Random rnd = new Random();
            int mIndex = rnd.Next(1, 3);
            if (mIndex == 1)
            {
                return "Regular";
            }
            else
            {
                return "Market";
            }
        }
        static double generatePrice()
        {
            //newPrice=mean + standardDeviation*gaussRandom();
            
            double m = mean(historic, historic.Length);
            double stde = std(historic, historic.Length, m);
           
            double newPrice = m + stde * gaussRandom();
            newPrice = Math.Round(newPrice, 2);
           
            return newPrice;

        }
       static string generateBuySell()
        {
            Random rnd = new Random();
            int mIndex = rnd.Next(1, 3);
            if (mIndex == 1)
            {
                return "Buy";
            }
            else
            {
                return "Sell";
            }
        }
      static  int generateQuantity()
        {
            return 3;
        }
        int generateOrderId(ref int id)
        {//for trader n  id start from n*1000000
            id = id + 1;
            return id - 1;
        }

        static double mean(double[] input,int length)
        {
            double sum=0;
            foreach(var i in input)
            {
                sum=sum+i;
            }
            double mean=sum/length;
            return mean;
        
        }
        //va_X2=sum((row[X]-mu_X)**2 for row in table)/len(table)
         static double std(double[] input,int length,double mean)
        {
            double sum=0;
            foreach(var i in input)
            {
                double temp=(i-mean)*(i-mean);
                sum=sum+temp;
            }
            double std=sum/length;
            return std;
        
        }
          static double gaussRandom() 
        {
            Random rand = new Random((int) DateTime.Now.Ticks & 0x0000FFFF); //reuse this if you are generating many
            double u1 = rand.NextDouble(); //these are uniform(0,1) random doubles
            double u2 = rand.NextDouble();
            double r = Math.Sqrt(-2.0 * Math.Log(u1));
            double theta = 2.0 * Math.PI * u2;
            return r * Math.Sin(theta);

        }

        public static double SimulateAsset(double s0, double mu, double sigma, double tau, double delta_t)
        {
            //Purpose:  Simulates an Asset Price run using a random walk and returns a final asset price.
            // so = Price of the asset at time 0 (current time)
            // mu = Historical Mean
            // sigma =  Historical Volatility (variance)
            // delta_t = period of time (% of a year or a day)  assume 6 month maturity 0.5
            
            double s = s0;
            // Made the steps = to the number of days which is the same as daily changes.     
            double nSteps = tau;
            for (int i = 0; i < (int)nSteps; i++)
            { 
                // s = s0 * (1 + mean + standard deviation * gaussian random number * squareRoot of the time period.
                s = s * (1 + mu * delta_t + sigma * gaussRandom() * Math.Sqrt(delta_t));
            }
            //Returns the final Price
            return s;
        }


        public static double MeasureVolatilityFromHistoric(double[] historic, double delta_t, int length)
        {
            // Purpose: Measures the Volatility for scaled prices.

            double sum = 0;
            double variance = 0;
            double volatility = 0;
            // length - 1 instead of length since n prices generates n-1 returns
            for (int i = 0; i < length - 1; i++)
            {
                //Random variable X^2
                sum = sum + Math.Pow((historic[i + 1] - historic[i]) / historic[i], 2);  
            }
            // E[X^2] - E[X]^2 
            variance =    sum / (length - 1) - Math.Pow(MeasureMeanFromHistoric(historic, delta_t, length) * delta_t, 2);
            // Volatility = SquareRoot(variance/ dt) which is the standard deviation scaled for a time increment
            volatility = Math.Sqrt(variance / delta_t);
            return volatility;
        }
        public static double MeasureMeanFromHistoric(double[] historic, double delta_t, int length)
        {
            //Purpose: Measures the mean of the scaled prices. (Scaled indicates that the level of the
            //         Prices is not important.

            double sum = 0;
            double average = 0;
            double waverage = 0;
            double returns = 0;
            //length-1 because the scaling requires n prices to generate a sequence of n-1 scaled returns.
            for (int i = 0; i < (length - 1); i++)
            {
                // Scales the returns and sums them
                returns = (historic[i + 1] - historic[i]) / historic[i];
                sum = sum + returns;
            }
            //computes the average of the returns
            average = sum / (length - 1);
            // divides the average by dt so that the average applies to each time increment
            waverage = average / delta_t;
            return waverage;
        }

    }
 }