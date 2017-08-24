from Tkinter import *
root = Tk()
root.title("MyApp")

myvar = StringVar()
def mywarWritten(*args):
    print "mywarWritten",myvar.get()

myvar.trace("w", mywarWritten)

label = Label(root, textvariable=myvar)
label.pack()

text_entry = Entry(root, textvariable=myvar)
text_entry.pack()

root.mainloop()
