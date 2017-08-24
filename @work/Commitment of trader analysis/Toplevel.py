from Tkinter import *
root = Tk()
class Addcase:
    def mains(self):
        master = Tk()
        master.wm_title("Add")
        self.content = StringVar()
        self.text = StringVar()
        self.bz = Button(master,text="add",command=self.add)
        self.bz.pack()
        self.l = Label(master,text="ok")
        self.l.pack()
        self.e = Entry(master,textvariable=self.content)
        self.e.pack()
        print self.content.get() + "hello"
        master.mainloop()
    def add(me):
            print "this is the entered text"
            print me.content.get()

def calladd():
    z = Addcase()
    z.mains  


def main():
    calling = Addcase()
    root.wm_title("Hello, me")
    b = Button(root, text="Add a case",command=calling.mains)
    b.pack()
    mainloop()

if __name__ == '__main__':
  main()



# master = Toplevel @Line 5
