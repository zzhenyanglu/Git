from numeric import *
import random
import pickle

storage = []
for i in range(100):
    ti = 0.1*i
    yi = 3.0*(ti**2) + random.gauss(0,2)
    if i==5: dyi = 10.0
    else: dyi = 10.0
    storage.append((ti,yi,dyi))

def f0(x): return 1
def f1(x): return x
def f2(x): return x**2
def f3(x): return exp(x)


f = [f0, f1, f2, f3]
c, chi2, f = fit_least_squares(storage, f)    
print c, chi2

points = []
for ti, yi, w in storage:
    #print ti, yi, f(ti)
    points.append((ti,f(ti)))

Canvas().errorbar(storage).plot(points).save('mydata.png')
