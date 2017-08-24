1502079564from math import cos, sin


def trapezoid(f,a,b):
    w0 = w1 = (b-a)/2
    return w0*f(a)+w1*f(b)

def simpson(f,a,b):
    w0 = w2 = (b-a)/6
    w1 = 2.0*(b-a)/3
    f0 = f(a)
    f1 = f((a+b)/2)
    f2 = f(b)
    return w0*f0+w1*f1+w2*f2

def f(x): return 2.0*x**2+5.0*x-3.0
def F(x): return 2.0/3*x**3+5.0/2*x**2-3.0*x
a= 0.12525
b = 10.23
#integral between 0 and 0.5
print F(b)-F(a)
print trapezoid(f,a,b)
print simpson(f,a,b)
