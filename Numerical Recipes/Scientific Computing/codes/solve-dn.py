import random

def D(f,h=1e-6): return lambda x: (f(x+h)-f(x))/h

def solve_newton(f,x,ap=1e-4,rp=1e-4,ns=100):    
    for k in range(ns):
        x_old = x
        x = x - f(x)/D(f)(x)
        if k>3 and abs(x-x_old)<max(ap,rp*abs(x)): return x 
    raise RuntimeError("no convergence")

def optimize_newton(f,x,ap=1e-4,rp=1e-4,ns=100,h=1e-6):    
    for k in range(ns):
        x_old = x        
        fxp = f(x+h)
        fxm = f(x-h)
        Dfx = (fxp-fxm)/(2.0*h)
        DDfx =(fxp-2.0*f(x)+fxm)/(h*h)
        x = x - Dfx/DDfx
        if k>3 and abs(x-x_old)<max(ap,rp*abs(x)): return x 
    return x
    raise RuntimeError("no convergence")


def f(x): 
    return x**4-2*x**2+x

# Df(x) = 2x -3

for k in range(-20,20):
    print  solve_newton(f,float(k)/10,ap=1e-7,rp=1e-7)
    #print  optimize_newton(f,float(k),ap=1e-7,rp=1e-7)

#print "x0=", x0
#DDfx0 = D(D(f))(x0)

#h = 1e-4
#a,b,c =  f(x0-h), f(x0), f(x0+h)
#if b>a and b>c: print 'maximum'
#elif b<a and b<c: print 'minimum'
#else: print "not a maximum or minimum"
# if abs(DDfx0)<1e-5:
#     print 'I cannot say'
# elif DDfx0<0: print 'maximum'
# elif DDfx0>0: print 'minimum'

