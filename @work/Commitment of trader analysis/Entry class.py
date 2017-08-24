from Tkinter import *

class a():
   def __init__(self):
      self.top = Tk()
      self.L1 = Label(self.top, text="User Name")
      self.L1.pack( side = LEFT)
      self.a=StringVar()
      self.E1 = Entry(self.top, bd =5,textvariable = self.a).pack()
      self.button_go = Button(self.top, command=self.printf, text='GO').pack()
      self.top.mainloop()

   def printf(self):
      print  self.a.get()
