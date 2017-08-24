using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TradingEngine
{
    class Trade2
    {
        double mean = 100.0;
        double std = 5.0;
        double j;
        Random rand = new Random();
        int number = 0;


        public  void trade2t()
        {
            for (int threadNumber = 0; threadNumber < 5; threadNumber++)
            {
                number = number + 1;
                Console.WriteLine(number.ToString());
                trade2t(rand, mean, std);
            }
            return;
        }
        private static void trade2t(Random rand, double mean, double std)
        {

            double u1 = rand.NextDouble();
            double u2 = rand.NextDouble();
            double randStdNorm = Math.Sqrt(-2.0 * Math.Log(u1)) * Math.Sin(2.0 * Math.PI * u2);
            double RandNormal = mean + std * randStdNorm;
            
            Console.WriteLine(RandNormal.ToString());
        }

        
        private static double SimulateAsset(double s0, double mu, double sigma, double tau, double delta_t, double g)
        {
            //Purpose:  Simulates an Asset Price run using a random walk and returns a final asset price.
            // so = Price of the asset at time 0 (current time)
            // mu = Historical Mean
            // sigma =  Historical Volatility (variance)
            // delta_t = period of time (% of a year or a day)
            // g = Random variable
            double s = s0;
            // Made the steps = to the number of days which is the same as daily changes.     
            double nSteps = tau;
            for (int i = 0; i < (int)nSteps; i++)
            {
                // s = s0 * (1 + mean + standard deviation * gaussian random number * squareRoot of the time period.
                // s = s * (1 + mu * delta_t + sigma * g.gaussian() * Math.Sqrt(delta_t));
            }
            //Returns the final Price
            return s;
        }
    }
}
