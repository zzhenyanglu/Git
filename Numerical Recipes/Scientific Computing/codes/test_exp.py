from math import *


def f(x):
    return exp(x)

def fact(n):
    r = 1
    for i in range(1,n+1):
        r = r*i
    return r

def fn_old(n,x):
    fn = 1.0
    for i in range(1,n+1): # for(i=1; i<n+1; i++)
        fn = fn + (x**i)/fact(i)
    return fn

def myexp(x,ap=0.01,ns=1000):    
    x = float(x)
    #if x>1:
    #    return (2.6881171418161356e+43)*myexp(x/100,ap=ap/1000)
    term = 1.0
    fn = term
    for i in range(1,ns):
        term = term * x/i
        print 'term',term
        fn += term
        print 'fn',fn
        reminder = abs(term)
        print 'reminder',reminder
        if reminder < ap:
            break
    print i
    return fn

#ap=1.0
#x=90.0
#for k in range(8):
#    print myexp(x, ap=ap), ap
#    ap=ap/10
#print exp(x), 'exact'

print myexp(+90.0,ap=0.0001)
#print myexp(-90,ap=0.0001)
