
primes = []
for i in range(2,10000):
    for j in primes:
        if i % j == 0:
            break
    else:
        primes.append(i)
print primes
