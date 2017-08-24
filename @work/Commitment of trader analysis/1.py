import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys
from ttk import *
from Tkinter import * 

class OTC():
   
   def __init__(self, file):
      self.dataset=pd.read_csv(file)
      self.dataset['As_of_Date_In_Form_YYMMDD'] = self.dataset['As_of_Date_In_Form_YYMMDD'].apply(str)
      self.dataset['As_of_Date_In_Form_YYMMDD'] = self.dataset['As_of_Date_In_Form_YYMMDD'].apply('{:0>6}'.format)
      self.dataset['As_of_Date_In_Form_YYMMDD'] = self.dataset['As_of_Date_In_Form_YYMMDD'].apply(pd.to_datetime)

   def __fuzzy__(self, lists, keyword):
      keyword_index_list =[]
      for i in range(len(lists)):
            index= lists[i].find(keyword)
            if index ==-1:
               continue 
            else:
               keyword_index_list.append(i)
      return keyword_index_list

   def code_query(self, keyword=None):
      query=pd.concat([self.dataset['CFTC_Contract_Market_Code'], self.dataset['Market_and_Exchange_Names']], axis=1)
      result = query.drop_duplicates()
      result = result.dropna()
      output = {}
      
      if keyword == None or '':
         for i in range(len(result)):
            output[result.iat[i,1]]=result.iat[i,0]
      else:
         contract_list=result['Market_and_Exchange_Names'].tolist()
         keyword_index = self.__fuzzy__(contract_list,keyword.upper())

         for i in keyword_index:
            output[result.iat[i,1]]=result.iat[i,0]
      return output 

   def net_pos(self, code, net_pos_only = True, subplot = False):
          query=pd.concat([self.dataset['CFTC_Contract_Market_Code'], self.dataset['Market_and_Exchange_Names'], \
                                         self.dataset['Prod_Merc_Positions_Long_ALL'], self.dataset['Prod_Merc_Positions_Short_ALL'], \
                                         self.dataset['As_of_Date_In_Form_YYMMDD'],self.dataset['Close_Price']], axis=1)
               
          index=query['CFTC_Contract_Market_Code'] == code
          result = query[index]
          result['net position'] = result['Prod_Merc_Positions_Long_ALL']-result['Prod_Merc_Positions_Short_ALL']

          if subplot == True:
             if net_pos_only == True:
                del result['CFTC_Contract_Market_Code']
                del result['Market_and_Exchange_Names']
                del result['Prod_Merc_Positions_Long_ALL']
                del result['Prod_Merc_Positions_Short_ALL']
             elif net_pos_only == False:
                del result['CFTC_Contract_Market_Code']
                del result['Market_and_Exchange_Names']

             result.plot( x=['As_of_Date_In_Form_YYMMDD'], legend =True, subplots = subplot, title = ' Net Position as of report date' )
          elif subplot == False:
             if net_pos_only == True:
                result.plot( x=['As_of_Date_In_Form_YYMMDD'], y = ['net position','Close_Price'], secondary_y = ['Close_Price'], \
                                    legend =True, title = ' Net Position as of report date' )
             elif net_pos_only == False:
                result.plot( x=['As_of_Date_In_Form_YYMMDD'], y = ['net position','Close_Price','Prod_Merc_Positions_Short_ALL', \
                                  'Prod_Merc_Positions_Long_ALL'], secondary_y = ['Close_Price'], legend =True, title = ' Net Position as of report date' )
          plt.show()
          
   def view_table(self):
      return self.dataset

#########################################################################################################################
   
class GUI():
   def __init__(self):
      self.main = Tk() # data
      self.main.title('CTO PLOT Interface')
      self.main.geometry('200x200+200+200')
      self.message = Label(self.main, text = 'HELLO! CTO ANALYSIS')
      self.message.pack(fill = X)
      self.button_quit = Button(self.main, command=self.quitHandler,text='QUIT')
      self.button_quit.pack(fill = X)
      self.button_new_CSV = Button(self.main, command=self.get_csv,text='NEW STUDY')
      self.button_new_CSV.pack(fill = X)
      self.keyword= StringVar()
      self.main.mainloop()
      
   def quitHandler(self):
      print 'GOODBYE......You can close Python GUI now'
      self.main.destroy()
   def quitHandler_study(self):
      self.study_window.destroy()

   def get_csv(self):
      self.file_directory= StringVar()
      button=Button(self.main, command=self.studywindow,text='GO')
      button.pack(side=BOTTOM)
      entry=Entry(self.main, textvariable  = self.file_directory)
      entry.pack(side=BOTTOM)
      self.file_directory.set('C:/Users/felix/Dropbox/JP/OTC project/COTdata.csv')
      label=Label(self.main, text = 'Please input the file source: ')
      label.pack(side=BOTTOM)

   def studywindow(self):
      self.otc = OTC(self.file_directory.get())
      self.study_window = Tk()
      self.study_window .geometry("750x650")
      
      button_quit = Button(self.study_window, command=self.quitHandler_study,text='    QUIT    ')
      button_quit.grid(row=0, column=0)
      button_show_table =Button(self.study_window, command=self.showtable,text='SHOW TABLE')
      button_show_table.grid(row=1, column=0)
      button_chart = Button(self.study_window, command=self.chart_window,text='SHOW CHART')
      button_chart.grid(row=2, column=0)#
      button_query = Button(self.study_window, command=self.query_code_window,text='QUERY CODE')
      button_query.grid(row=3, column=0)#
      self.study_window .mainloop()
      
   def showtable(self):
      scrollbar = Scrollbar(self.study_window )
      scrollbar.grid(column=2,sticky=S+N)
      table = self.otc.view_table()
      tree = Treeview(self.study_window ,selectmode="extended", height = 25, yscrollcommand=scrollbar.set)
      tree["columns"] =[table.columns[0],table.columns[1], \
               table.columns[3],table.columns[7],table.columns[8],table.columns[9],table.columns[-1]]
      
      tree.column("#0",width=50 )
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
      tree.grid(row =4, column = 1)
            
   def query_code_window(self):
      self.query_window = Toplevel()
      self.query_window.geometry("350x300")
      self.input = StringVar()
      
      label=Label(self.query_window, text = 'KEYWORD')
      ent=Entry(self.query_window, textvariable=self.input)
      button=Button(self.query_window, command=self.query_result,text='GO')
      button.pack()
      label.pack()
      ent.pack()
      self.query_window.mainloop()

   def query_result(self):

      label=Label(self.query_window, text = self.input.get())
      label.pack(fill=BOTH)
      result = self.otc.code_query(self.input.get())
      self.code_list = Listbox(self.query_window,height = 20, width = 200)
      self.code_list.insert(END, 'Contract:  '+ self.input.get())
      for i in result:
         self.code_list.insert(END,i+'   :   '+str(result[i]))
      self.code_list.pack()

   def chart_window(self):
      self.chart_window = Toplevel()
      self.chart_window.geometry("300x300")
      self.code = StringVar()
      self.net_pos =BooleanVar()
      self.subplot = BooleanVar()
      
      message1 = Label(self.chart_window, text = 'CONTRACT CODE: ')
      entry1 =Entry(self.chart_window, textvariable  = self.code)
      check1= Checkbutton(self.chart_window, text= 'NET POSITION ONLY: ', variable=self.net_pos)
      check2= Checkbutton(self.chart_window, text= 'SUBPLOTS: ', variable=self.subplot)
      button_go = Button(self.chart_window, command=self.chart,text='GO')

      message1.pack()
      entry1.pack()
      check1.pack()
      check2.pack()
      button_go.pack()

      self.chart_window.mainloop()      

   def chart(self):
      self.otc.net_pos(code = int(self.code.get()), net_pos_only = self.net_pos.get(), subplot = self.subplot.get())      
      
default ='C:/Users/felix/Dropbox/JP/OTC project/COTdata.csv'

a=GUI()



