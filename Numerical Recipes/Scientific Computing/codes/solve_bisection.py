from math import *

def f(x):
    return exp(x)-x**2

a=-1.0
b=0.0

def solve_bisection(f,a,b,ap=1e-7):
    f_a = f(a)
    f_b = f(b)
    if f_a==0:
        return a
    elif f_b==0:
        return b
    elif f_a*f_b>0:
        raise RuntimeError("Doh!")
    while abs(b-a)>ap:
        x = (a+b)/2
        f_x = f(x)
        #print a,x,b
        if f_a*f_x<0:
            b=x
            f_b = f_x
        elif f_x*f_b<0:
            a=x
            f_a=f_x
        else:
            return x
    return (b+a)/2

print solve_bisection(f,a,b)
        
