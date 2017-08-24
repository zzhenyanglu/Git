def __init__(self):
       print 'Hello World! This is a Tool kit for parse dataset Created by Felix! '
       
def add_table(source, source2, output):
   import pandas as pd
   a=pd.read_csv(source,parse_dates=True,index_col='Datetime')
   print 'Done timeline'
   b=pd.read_csv(source2, parse_dates=True, index_col='Datetime')
   print 'Done cme'
   c=pd.merge(a,b,left_index=True,right_index=True,how='left')
   print 'Done merging'
   c.to_csv(output)
   print 'Done output'
   
def add_column(timeline, output,*arg):                    #   add a column to a dataset !
      # You have to make sure the datetime column in each file NAMED "Datetime" Case sensitive !
      # Please don't specify the function's keywords when you call it, just type in the file name according to the order specified in the function definition!
      # This function add the second column from a CSV file with Datetime as index to a standard timeline table. 
      import pandas as pd
      import os
      
      table=pd.read_csv(timeline,parse_dates=True,index_col='Datetime')
      print 'Done creating benchmark dataset'
      print timeline, output,arg

      for i in arg:
         column_added = pd.read_csv(i, parse_dates=True, index_col='Datetime')
         print 'Done reading %s'  % (i)
         #print column_added
         table=pd.merge(table, column_added , left_index=True, right_index=True, how='left')
         print 'Done merging timeline CSV with %s' %(i)
         
      table.to_csv(output, index=True, header=True)
      print 'You get it, it\'s on %s folder named %s ! ' % (os.getcwd(),output)

def parse_white_space(self,dataset_root, target_line):   # parse whitespace
        import csv
        open_dataset=open(dataset_root,'r')
        dataset = csv.reader(open_dataset)
        data_set = [line for line in dataset]
        open_dataset.close()
   
        for i in data_set:
            i[target_line] = i[target_line].strip(' ')

        open_dataset=open(dataset_root,'wb')
        writer = csv.writer(open_dataset)

        for i in data_set:
            writer.writerow(i)
        open_dataset.close()

def form_proxy(DataFile = ' ', method = 'MaxOi',Output = 'proxy.csv'):   # to form a proxy for all active contracts
        import csv
        open_dataset = open(DataFile,'r')
        dataset = csv.reader(open_dataset)
        DataSet = [line for line in dataset]
        open_dataset.close()
        Proxy = []

        ContractDict={2:DataSet[0][1],4:DataSet[0][3],6:DataSet[0][5]}
        Proxy.append(['Date','Close','OI','Contract'])

        for i in DataSet[1:]:
            if i[2] == '':
                i[2] ='0'
            if i[4] =='':
                i[4] ='0'
            if i[6] =='':
                i[6] ='0'

        MaxOi = str(max([int(i[2]),int(i[4]),int(i[6])])  )
        MaxOi = i.index(MaxOi)   #check which contract has the max OI

        if MaxOi in(1,3,5):
            MaxOi = MaxOi + 1
            
        Proxy.append([i[0],i[MaxOi-1],i[MaxOi],ContractDict[MaxOi]])

        open_dataset = open(Output,'wb')
        writer = csv.writer(open_dataset)
        for i in Proxy:
           writer.writerow(i)
        open_dataset.close()

def interpolation_column(DataFile, col_num, TargetFile, indicateinterpolation=True):
       import csv
       open_dataset = open(DataFile,'r')
       dataset = csv.reader(open_dataset)
       DataSet =[]
       if indicateinterpolation ==True:
              for i in dataset:
                     DataSet.append([i[col_num],0])
              DataSet[0][1] = 'Interpolated' 
              open_dataset.close()

              startline = 0
              if DataSet[0][0]== str:    # deal with the column name
                     startline = startline +1
              if DataSet[1][0] == '':     # deal with missing value on the first row
                     startline += 1
                     DataSet[1][0] = DataSet[2][0]
                     DataSet[1][1] = 1
              if DataSet[-1][0] =='':      # deal with the case that the last data is missing.
                     m = 1
                     while(DataSet[-1-m][0] == ''):
                            m=m+1
                     DataSet[-1][0] = DataSet[-1-m][0]
                     DataSet[-1][1] = 1
                     
              for i in range(startline, len(DataSet)):
                     if DataSet[i][0]== '':                        # if id a missing data
                            m = 1
                            while(DataSet[i+m][0] == ''):
                                   m+=1
                            intra = (float(DataSet[i+m][0])- float(DataSet[i-1][0]))/(m+1)

                            for j in range(m):
                                   DataSet[i+j][0] =str(float(DataSet[i-1][0])+intra*(j+1))
                                   DataSet[i+j][1] = 1
                                   
       if indicateinterpolation ==False:
              for i in dataset:
                     DataSet.append(i[col_num])
              open_dataset.close()

              startline = 0
              if DataSet[0]== str:    # deal with the column name
                     startline = startline +1
              if DataSet[1]== '':     # deal with missing value on the first row
                     startline += 1
                     DataSet[1] = DataSet[2]
                     DataSet[1] = 1
              if DataSet[-1] =='':      # deal with the case that the last data is missing.
                     m = 1
                     while(DataSet[-1-m] == ''):
                            m=m+1
                     DataSet[-1] = DataSet[-1-m]
                     DataSet[-1] = 1
                     
              for i in range(startline, len(DataSet)):
                     if DataSet[i] == '':                        # if id a missing data
                            m = 1
                            while(DataSet[i+m] == ''):
                                   m+=1
                            intra = (float(DataSet[i+m])- float(DataSet[i-1]))/(m+1)

                            for j in range(m):
                                   DataSet[i+j] =str(float(DataSet[i-1])+intra*(j+1))
                                   DataSet[i+j] = 1
       open_dataset = open(TargetFile,'wb') #open the target file and write in
       writer = csv.writer(open_dataset)
       for p in DataSet:
              writer.writerow(p)
       open_dataset.close()

        
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

   
            
   


              
                     
       
       
       
