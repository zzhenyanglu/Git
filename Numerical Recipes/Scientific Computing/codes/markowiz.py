from numeric import *

def mpt(stocks, r_free=0.02/365):
    storage = []
    for stock in stocks:
        storage.append(YStock(stock).historical()[-250*2:])
    x = []
    for h in storage:
        v = [day['arithmetic_return'] for day in h[1:]]
        average_daily_return = sum(v)/len(v)
        x.append(average_daily_return)
    A = compute_covariance(storage)


    x = Matrix(len(stocks),1,lambda r,c: x[r])
    c = (1.0/A)*(x-r_free)
    s = sum(c[r,0] for r in range(len(stocks)))
    c = c/s
    return_portfolio = c*x
    risk_portfolio = sqrt(c*(A*c))
    return c, return_portfolio, risk_portfolio

def mpt_subjective(stocks,risk_free=0.02/365,sigma=0.01):
    c, return_portfolio, risk_portfolio = mpt(stocks,risk_free)
    alpha = 1.0 - sigma/risk_portfolio
    return_portfolio = alpha*risk_free + (1.0- alpha)*risk_portfolio
    return alpha, c, return_portfolio

stocks = ['aapl','msft','mo','coco','yhoo','bby']
alpha, c, return_portfolio = mpt_subjective(stocks,sigma=0.01)
for i in range(len(stocks)):
    print stocks[i], str(int(c[i,0]*100))+'%'

print 'alpha=',alpha
print 'return=',return_portfolio
#print 'risk2=',risk_portfolio
