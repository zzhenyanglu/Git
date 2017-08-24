def poly(coefficients,x,degree):
    if len(coefficients)!=degree+1:
        print 'Number of coefficients does not agree with order of degree'
        return
    else:
        sum=0
        for i in range(degree+1):
           sum+=x**(degree-i)*coefficients[i]
    return sum

