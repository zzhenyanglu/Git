import random
import math

x = [math.exp(random.gauss(0,100)) for i in range(100)]

print math.sqrt(sum(i*i for i in x))

x.sort()
x.reverse()
s = 0.0
first = x[0]
for item in x[1:]:
    s = s + (item/first)**2
print abs(first)*math.sqrt(1.0+s)

