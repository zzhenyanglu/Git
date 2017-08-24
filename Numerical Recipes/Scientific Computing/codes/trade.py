from numeric import *
from math import log

d = PersistentDictionary('storage')
if not 'goog' in d:
    d['goog'] = YStock('goog').historical()
goog = d['goog'][-250:]

v = [(k,day['adjusted_close'],1.0) for k,day in enumerate(goog)]

# c, chi2, f = fit_least_squares(v[-15:],POLYNOMIAL(2))

class Trader(object):

    def __init__(self,alpha):
        self.alpha = alpha

    def model(self,window,next_day):
        c, chi2, f = fit_least_squares(window,POLYNOMIAL(2))
        self.c = c
        self.chi2 = chi2
        self.f = f
        self.prediction = f(next_day)

    def strategy(self,current):
        if self.c[2]>self.alpha:
            return 'buy'
        elif self.c[2]<-self.alpha:
            return 'sell'
        else:
            return 'stay'

    def simulate(self, points,dt=14, bank=1000000.0,
                 daily_bank_interest=0.02/365):
        initial_bank = bank
        stocks = 0.0
        T = len(points)
        for t in range(0,T-dt):
            window = points[t:t+dt]
            today =  points[t+dt-1][1]
            self.model(window,points[t+dt][0])
            suggestion = self.strategy(today)
            # print t+dt, points[t+dt][1], prediction, suggestion
            if bank and suggestion=='buy':
                n = int(bank/today)
                stocks += n
                bank -= n*today
            elif stocks and suggestion=='sell':
                bank = stocks*today
                stocks = 0
            bank = bank*(1.0+daily_bank_interest)
        years = (len(points)-dt)*1.0/250
        return log((bank+stocks*points[-1][1])/(initial_bank))/years

def f(alpha,v=v):
    r = 0.02
    return Trader(alpha).simulate(v,daily_bank_interest=r/365)

v = []
for k in range(-20,20):
    alpha = 0.1*k
    v.append((alpha, f(alpha)))
Canvas().plot(v).save('alpha.png')

#alpha =  optimize_golden_search(f,-1.5,-1.0)
#print 'log_return(alpha=0.0)=',f(0.0)
#print 'alpha=',alpha
#print 'log_return=',f(alpha)
