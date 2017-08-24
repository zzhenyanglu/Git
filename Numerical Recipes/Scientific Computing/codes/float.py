


def float_repr(x):
    x = float(x)
    s=''
    if x<0:
        s='-'
        x = -x
    else:
        s='+'
    E = 0
    if x==0:
        return '+(0.0)*2^0'
    while x>2:
        x=x/2
        E=E+1
    while x<1:
        x=x*2
        E=E-1
    d = ''
    while len(d)<30:
        if x>1:
            x=x-1
            d=d+'1'
        else:
            d=d+'0'
        x=x*2
    s = s + ('(%s)*2^%s' % (d,E))
    return s

x=129
print x, '->', float_repr(x)
#x=0.003452346
#print x, '->', float_repr(x)
#
#x=0
#print x, '->', float_repr(x)
