# trade frequency 
def trade_freq(band ):
   import csv
   open_dataset = open('1.csv','r')
   dataset = csv.reader(open_dataset)
   rawdata=[i for i in dataset]
   for i in rawdata[1:]:
      i[5] = float(i[5])
   diff=[float(i[5]) for i in rawdata[1:]]
   maketrade =[]

   for i in rawdata[1:]:
      a=float(i[5])
      if a >=band or a < -band:
         maketrade.append(i)

   return float(len(maketrade))/len(rawdata)

# # test:

for i in range(0, 400):
	print 'when band=',i*0.0001, ' ,you can make ', trade_freq(i*0.0001),' trade.'
# end of trade frequency 



# research on unbalanced band
import csv
open_dataset = open('1.csv','r')
dataset = csv.reader(open_dataset)
rawdata=[i for i in dataset]
for i in rawdata[1:]:
   i[5] = float(i[5])
diff=[float(i[5]) for i in rawdata[1:]]

neg=[]
zero=[]
pos=[]

for i in diff:
	if i==0:
		zero.append(i)
	elif i<0:
		neg.append(i)
	else:
		pos.append(i)

print len(neg),len(zero),len(pos)
print sum(neg)/len(neg),sum(pos)/len(pos)

# end of research on unbalanced band




# simulate trade routine, band = 0.001

import csv
band =0.001
open_dataset = open('1.csv','r')
dataset = csv.reader(open_dataset)
rawdata=[i for i in dataset]
routine = []

for i in rawdata[1:]:
   i[1],i[2],i[5] = float(i[1]),float(i[2]),float(i[5])

for i in range(len(rawdata[1:])):
   if rawdata[i][5] >band or rawdata[i][5] <-band :
      routine.append(rawdata[i])
      routine.append(rawdata[i+1])

good_trade =0
bad_trade =0
account =0

for i in range(2, len(routine),2):
   if routine[i][5] >0:
      print 'buy o sell y'
      account= account -routine[i][2]+routine[i][1]
      account=account+routine[i+1][2]-routine[i+1][1]
      if routine[i+1][5]<0:
         good_trade+=1
         continue
      elif routine[i+1][5]>0:
         bad_trade+=1
         continue
   elif routine[i][5] <0:
      print 'buy y sell o'
      account= account +routine[i][2]-routine[i][1]
      account=account-routine[i+1][2]+routine[i+1][1]
      if routine[i+1][5]>0:
         good_trade+=1
         continue
      elif routine[i+1][5]<0:
         bad_trade+=1
         continue

print float(good_trade)/(good_trade+bad_trade)

# end of simulate trade routine 

