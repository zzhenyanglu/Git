from numeric import *

def quadrature(f,a,b,N=1):
    A = Matrix(N+1,N+1)
    v = Matrix(N+1,1)
    h = float(b-a)/N
    for i in range(N+1):
        xi = a + h*i
        for j in range(N+1):
            A[j,i] = xi**j
    #print 'A=',A
    for j in range(N+1):
        k = j+1
        v[j,0] = (b**k-a**k)/k
    #print 'v=',v
    w = (1.0/A)*v
    #print 'w=',w
    I = 0.0
    for i in range(0,N+1):
        xi = a + h*i
        I += w[i,0]*f(xi)
    return I



def itegrate_q(f,a,b,N):
    a = float(a)
    b = float(b)
    s = 0.0
    h = (b-a)/N
    for i in range(1,N):
        xi = a+h*i
        s += quadrature(f,xi,xi+h,4)
    #print N,s
    return s


def integrate(f,a,b,ap=1e-4,rp=1e-4,ns=1000):
    I = itegrate_q(f,a,b,1)
    for k in range(10,ns): # need to do at least 10 steps
        I_old = I
        I = itegrate_q(f,a,b,k)
        if abs(I-I_old) < max(ap,rp*abs(I)): return I
    raise RuntimeError("No convergence")


def f(x):
    return x**3+2.0*x-5
def F(x):
    return x**4/4+x**2-5.0*x

a=0.0
b=3.0
print F(b)-F(a)
print integrate(f,a,b,ap=1e-4,rp=1e-4)
