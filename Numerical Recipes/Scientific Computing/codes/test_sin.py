import math

def mysin(x,ap=0.001,rp=0.01,ns=1000):
    if x<0:
        return -mysin(-x)
    N = int(x/(2.0*math.pi))
    x = x - 2.0*math.pi*N

    if x>math.pi:
        return mysin(x-math.pi)
    if x>math.pi/2:
        return math.sqrt(abs(1.0-mysin(x-math.pi/2)**2))

    """term = float(x)
    fn = term
    for i in range(3,ns,2):
        term = -term * x*x/i/(i-1)
        fn += term
        reminder = abs(term)
        if i>10 and (reminder < ap or reminder < rp*abs(fn)):
            break
    else:
        raise Exception("no convergence")
    return"""

for x in [0.1, 1.0, 10.0, 100.0]:
    print x, mysin(x,ns=10), math.sin(x)
