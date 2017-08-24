from numeric import *
from math import *

def cdf(z):
    if z > 6.0:
        I = 1.0
    elif z < -6.0:
        I = 0.0
    else:
        a = abs(z)
        b1 = 0.31938153
        b2 = -0.356563782
        b3 = 1.781477937
        b4 = -1.821255978
        b5 = 1.330274429
        p1 = 0.2316419
        c1 = 0.398923
        t = 1.0/(1.0+a*p1)
        I = 1.0 - c1*exp(-z*z/2)*((((b5*t+b4)*t+b3)*t+b2)*t+b1)*t
        if z<0:
            I = 1.0-I
    return I

def price_BS(S, X, r, sigma, t):
    sqrt_t = sqrt(t)
    d1 = (log(S/X)+r*t)/(sigma*sqrt_t)+0.5*sigma*sqrt_t
    d2 = d1 - sigma*sqrt_t
    c = S*cdf(d1)-X*exp(-r*t)*cdf(d2)
    return c

    
v = []    
for S in range(1,20):
     v.append((S,price_BS(S,10.0,0.2,0.5,90.0/250)))

def f(x):
    call = 0.2
    dollars = 1.0
    years = 1.0
    S = 11.0*dollars
    r = 0.2
    sigma = x
    X = 10.0*dollars
    T = 90.0/250*years
    return price_BS(S,X,r,sigma,T) - call*dollars

call = 0.2
dollars = 1.0
years = 1.0
S = 11.0*dollars
r = 0.2
#sigma = x
X = 10.0*dollars
T = 90.0/250*years

v = []
for k in range(1,100):
    sigma = 0.1*k
    v.append((k,price_BS(S,X,r,sigma,T)))

#implied_volatility = solve_newton(f,0.5)
#print implied_volatility
Canvas(xlab='sigma',ylab='Call Price').plot(v).save('ecall.png')

