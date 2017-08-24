from Tkinter import *

window = Tk()
window.title('Configeration ')
window.geometry('300x200+200+200')
symbol1 = StringVar()
symbol2 = StringVar()
Droptable = BooleanVar()

def a():
   print 'Ð¡Àö ¹þ¹þ'

image1 = PhotoImage(file="baozi.gif")
label = Label(window, text = 'input the contract code: ').grid()
entry1 = Entry(window, textvariable =  symbol1).grid()
entry2 = Entry(window, textvariable =  symbol2).grid()
check1 = Checkbutton(window,text = ' Recreate Database? ',variable =Droptable).grid()
button1 = Button(window, comman=window.destroy,image = image1).grid()
view1 = View(window).grid()
window.mainloop()


from Tkinter import *
root=Tk()
root.title('ii')
Label(root,text = 'HELLO').pack(expand=YES, fill=Y)
root.mainloop()
