from math import *

def f(x):
    return 5-(x-2)**2*exp(0.01*x)

def D(f,h=1e-5): return lambda x,h=h: (f(x+h)-f(x))/h

def solve_newton(f,x0,ap=1e-5):
    x = x0
    while True:
        x_old = x
        x = x - f(x)/D(f)(x) 
        if abs(x-x_old)<ap: break
        print x
    return x

def solve_newton_stabilized(f,a,b,ap=1e-5,rp=1e-5,ns=20):
    if b>a: (a,b) = (b,a)
    f_a = f(a)
    f_b = f(b)
    if abs(f_a)<ap: return a
    elif abs(f_b)<ap: return b
    elif f_a*f_b>0: raise RuntimeError("no good range")
    xk = (a+b)/2
    for k in range(ns):
        fxk = f(xk)
        xk1 = xk - fxk/D(f)(xk) 
        if k>3 and abs(xk1-xk)<max(ap,rp*abs(xk1)):
            return xk1
        if f_a*fxk<0:
            b = xk
            f_b = fxk
        else:
            a = xk
            f_a = fxk
        if xk1<a or xk1>b:
            xk1 = (a+b)/2            
        xk = xk1
        print xk
    raise RuntimeError('no convergence')


