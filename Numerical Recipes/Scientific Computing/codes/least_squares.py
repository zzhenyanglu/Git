from numeric import *
import random
import pickle

storage = []
for i in range(20):
    ti = 0.1*i
    yi = 3.0*(ti**2) + random.gauss(0,2)
    if i==5: dyi = 0.01
    else: dyi = 1.0
    storage.append((ti,yi,dyi))
    
#pickle.dump(storage,open('mydata','w'))
#storage = pickle.load(open('mydata'))

n = len(storage)
def f0(x): return 1.0 
def f1(x): return x 
def f2(x): return x**2
m = 3


y = Matrix(n)
A = Matrix(n,m)
i=0
for ti, yi, dyi in storage:
    y[i,0] = yi/dyi
    A[i,0] = f0(ti)/dyi
    A[i,1] = f1(ti)/dyi
    A[i,2] = f2(ti)/dyi
    i+=1

# A = n x m
# y = n x 1
# A.t = m x n
# A.t * y = m x 1
# A.t * A = m x n x n x m = m x m 
# 1.0/(A.t*A) = m x m
# A.t * y = m x 1
c = (1.0/(A.t * A))*A.t * y
print c

def f(x):
    return c[0,0]*f0(x)+c[1,0]*f1(x)+c[2,0]*f2(x)

points = []
for ti, yi, w in storage:
    print ti, yi, f(ti)
    points.append((ti,f(ti)))

Canvas().errorbar(storage).plot(points).save('mydata.png')
