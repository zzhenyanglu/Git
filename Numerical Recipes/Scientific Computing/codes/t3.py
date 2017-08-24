

primes = []
for i in range(2,100):
    is_prime = True
    for j in primes:
        if i % j == 0:
            is_prime = False
            break
    if is_prime:
        primes.append(i)
        print i
