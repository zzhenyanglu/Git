from math import *

# x = g(x)

def f(x):
    return sqrt(x+2)-x

def g(x):
    return f(x)+x
    
def solve_fixed_point(g,x0,ap=1e-5):
    x = x0
    while True:
        x_old = x
        x = g(x)
        if abs(x-x_old)<ap: break
        print x
    return x

print solve_fixed_point(g,1.0)
