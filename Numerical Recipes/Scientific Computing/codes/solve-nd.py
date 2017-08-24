from numeric import *

def to_matrix(x):
    X = Matrix(len(x),1)
    for i in range(len(x)):
        X[i,0] = x[i]
    return X

def to_list(X):
    return [X[i,0] for i in range(X.rows)]


# def D(f,h=1e-6): return lambda x: (f(x+h)-f(x))/h

def partial(f,i,x,h=1e-5):
    x[i]+=h
    f1 = f(x)
    x[i]-=h
    f2 = f(x)
    return (f1-f2)/h

def solve_newton(f,x,ap=1e-4,rp=1e-4,ns=100):    
    n = len(f)
    m = len(x)
    if n!=m:
        raise RuntimeError("num of functions must match number of variables")
    x =  to_matrix(x)

    for k in range(ns):
        x_old = x        
        A = Matrix(n,n)
        for i in range(n):
            for j in range(n):
                A[i,j] = partial(f[i],j,to_list(x))

        v = Matrix(n,1)
        for i in range(n):
            v[i,0] = f[i](to_list(x))                        
        print 'x=',x
        print 'f(x)=',v
        print 'Jacobian A=',A

        x = x - (1.0/A)*v

        if k>3 and norm(x-x_old)<max(ap,rp*norm(x)):
            return to_list(x) 
    raise RuntimeError("no convergence")

x = [2,1,1]
def f0(x):
    return x[0]+x[1]+x[2]-4
def f1(x):
    return (x[0]+2)**0.5+x[1]-3*x[2]**2
def f2(x):
    return (x[0]+2)**0.5-x[1]-x[2]

#f0(x) = 0
#f1(x) = 0

x = solve_newton([f0,f1,f2],[0.0,0.0,0.0])
print x

