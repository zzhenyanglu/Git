class StrategyBook():
   def __init__(self, Datalink, columns):
      # Data is a link to the database, which can fetchall(), fetchone() 
      import pandas as pd
      import time
      
      self.datalink = Datalink  # this is very important, this parameter dictates where is your rawdata from. In this case, it's our SQLITE3 database. 
      self.commodity=columns
      self.rawdata = self.datalink.fetchall()
      self.dataline=pd.DataFrame(self.rawdata, columns=self.commodity, index =self.commodity[0])
      
      print ' Reading Historical Data Sucessful, Continuing....'
   def cl (self, sleeping, CL_level):
      # This strategy make its assumption on mean-reversion. Please see the attached quant research
      # on the 5-minute difference between canola and soybean oil, which dictates that usually this difference
      # is between -0.4% to + 0.4%. CL_level means the band of the difference. If CL_level is 0.002 then we
      # make trade if the difference of two return is larger than 0.2% or smaller than -0.2%.
      # sleeping means the frequency of your trade, 300 means you makde trade or trade decision on every 5 minutes,
      # which is 300 seconds.

      while True:
         try:
            return_canola = self.dataline['bid_Canola_oil'][-1:] / self.dataline['bid_Canola_oil'][-2:-1] -1
            return_soybean = self.dataline['bid_soybean_oil'][-1:] / self.dataline['bid_soybean_oil'][-2:-1] -1
            
            if return_canola - return_soyean < CL_level or return_canola - return_soyean > -CL_level:
               return 'No Trade', 'Last 5 minutes return of canola oil is ', return_canola, 'and return of soybean oil is ', return_soyean

            elif return_canola - return_soyean > CL_level:
               return 'Buy soybean oil and sell canola oil', 'Last 5 minutes return of canola oil is ', return_canola, 'Last 5 minutes return of soybean oil is ', return_soyean

            elif return_canola - return_soyean < -CL_level:
               return 'Sell soybean oil and buy canola oil', 'Last 5 minutes return of canola oil is ', return_canola, 'Last 5 minutes return of soybean oil is ', return_soyean
            time.sleep(sleeping)
         except KeyboardInterrupt:
            print 'CL strategy has stopped working' 
            
          
      

      
   
