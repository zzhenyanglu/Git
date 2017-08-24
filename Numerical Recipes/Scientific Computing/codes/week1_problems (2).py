import math

def problem11():
    a = 1
    for n in range(1,30):
        a = a*n
        b = math.sqrt(2.0*math.pi*n)*(math.e/n)**(-n)
        absolute_error = abs(a-b)
        relative_error = absolute_error/a
        print n, 100.0*relative_error

def check_overflow():
    a = 1.0
    while True:
        b=a
        a=a*2
        if a==float("inf"):
            print b
            break

def check_underflow():
    a = 1.0
    while True:
        b=a
        a=a/2
        if a==0.0:
            print b
            break

def check_epsilon():
    a=1.0
    b=1.0
    while True:
        b=b/2
        if a+b == a:
            print math.log(b,2)
            break

check_epsilon()
