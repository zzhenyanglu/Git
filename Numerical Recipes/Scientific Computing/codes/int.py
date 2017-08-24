from numeric import *
from math import cos, sin, pi, exp, sqrt

def f(x): return exp(x)

def itegrate_trapezoid(f,a,b,N):
    a = float(a)
    b = float(b)
    s = 0.0
    h = (b-a)/N
    for i in range(1,N):
        s += f(a + i*h)
    return h*(0.5*f(a)+0.5*f(b)+s)

def integrate(f,a,b,ap=1e-4,rp=1e-4,ns=1000):
    I = itegrate_trapezoid(f,a,b,1)
    for k in range(10,ns): # need to do at least 10 steps
        I_old = I
        I = itegrate_trapezoid(f,a,b,2**k)
        if abs(I-I_old) < max(ap,rp*abs(I)): return I
    raise RuntimeError("No convergence")


def option_price_black_scholes(S,F,sigma,T,r):
    def f(x,F=F,sigma=sigma,T=T):
        return max(x-F,0.0)*(2.0*pi*T*sigma**2)**(-0.5)*exp(
            -(x-S)**2/(2.0*T*sigma**2))
    S_min = F
    S_max = max(F,S*(1.0+3.0*sigma*sqrt(T)))
    return integrate(f,S_min,S_max)*exp(-r*T)

v = []
for k in range(0,100):
    S = 98+0.04*k
    call = option_price_black_scholes(S,F=100.0,sigma=0.60,T=1.0,r=0.0)
    v.append((S, call))

Canvas().plot(v).save('european_option.png')


"""
def itegrate_naive(f,a,b,N):
    I = 0.0
    h = (b-a)/N
    for i in range(N):
        xi = a + i*h
        height_rectangle = f(xi)
        area_rectangle = height_rectangle*h
        I += area_rectangle
    return I
"""

