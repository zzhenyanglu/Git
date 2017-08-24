def timeline(from_date='03/1/2014', output = 'timeline.csv'):
   import csv
   from datetime import datetime
   import pandas as pd

   open_dataset=open('trade_date.csv','r')
   dataset = csv.reader(open_dataset)
   date = [line for line in dataset]
   date = [datetime.strptime(point[0],'%m/%d/%Y') for point in date]

   open_dataset_1=open('friday.csv','r')
   dataset = csv.reader(open_dataset_1)
   friday = [line for line in dataset]
   friday = [datetime.strptime(point[0],'%I:%M:%S %p').time() for point in friday]

   open_dataset_2=open('weekday.csv','r')
   dataset = csv.reader(open_dataset_2)
   weekday = [line for line in dataset]
   weekday = [datetime.strptime(point[0],'%I:%M:%S %p').time() for point in weekday]

   open_dataset_3=open('sunday.csv','r')
   dataset = csv.reader(open_dataset_3)
   sunday = [line for line in dataset]
   sunday = [datetime.strptime(point[0],'%I:%M:%S %p').time() for point in sunday]

   open_dataset.close()
   open_dataset_1.close()
   open_dataset_2.close()
   open_dataset_3.close()

   from_date = datetime.strptime(from_date,'%m/%d/%Y')
   timeline = []
   
   for i in date:     #extract date
      if i <= from_date:
         break
      if datetime.weekday(i)== 6:
         for j in sunday:   # extract time    
            timeline.append(datetime.combine(i,j))
      elif datetime.weekday(i)==4:
         for j in friday:   # extract time    
            timeline.append(datetime.combine(i,j))
      else:
         for j in weekday:   # extract time    
            timeline.append(datetime.combine(i,j))
            
   timeline=pd.DataFrame(timeline)

   open_dataset = open(output,'wb') #open the target file and write in
   timeline.to_csv(open_dataset,index=False,header=False)
   open_dataset.close()

   
            
   
