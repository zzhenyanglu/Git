import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from Tkinter import *
from ttk import *

default = default ='C:/Users/felix/Dropbox/JP/FL/working_data/OTC project/COTdata.csv'

class OTC():
   
   def __init__(self, file):
      self.dataset=pd.read_csv(file)
      self.dataset['As_of_Date_In_Form_YYMMDD'] = self.dataset['As_of_Date_In_Form_YYMMDD'].apply(str)
      self.dataset['As_of_Date_In_Form_YYMMDD'] = self.dataset['As_of_Date_In_Form_YYMMDD'].apply('{:0>6}'.format)
      self.dataset['As_of_Date_In_Form_YYMMDD'] = self.dataset['As_of_Date_In_Form_YYMMDD'].apply(pd.to_datetime)

                   
   def test(self):
      return self.dataset

table = OTC(default).test()

main = Tk()
main.geometry("800x800")

scrollbar = Scrollbar(main)
scrollbar.pack(side=RIGHT, fill=Y)

tree = Treeview(main,selectmode="extended", yscrollcommand=scrollbar.set)

tree["columns"] =[table.columns[0],table.columns[1], \
                            table.columns[3],table.columns[7],table.columns[8],table.columns[9],table.columns[-1]]

tree.column("#0",width=40 )
tree.column("#1",width=200 )
tree.column("#2",width=120 )
tree.column("#3",width=50 )
tree.column("#4",width=50 )
tree.column("#5",width=50 )
tree.column("#6",width=50 )
tree.column("#7",width=50 )

for i in tree["columns"]:
	tree.heading(i, text = i)

for i in range(len(table)):
   tree.insert("",i, text = str(i), values=(table.ix[i][0],table.ix[i][1], table.ix[i][3],table.ix[i][7],table.ix[i][8],table.ix[i][9],table.ix[i][-1]))

scrollbar.config(command=tree.yview)

tree.pack(expand=NO, fill=Y, side=RIGHT)
main.mainloop()
