import matplotlib.pyplot as plot
from FetchData import fetchdata
import pandas as pd

cols, data=fetchdata().fetchall()
datalines=pd.DataFrame(data,columns=cols, index={cols[0]})

plot.plot(datalines[cols[1]],datalines[cols[2]])
plot.xlabel(cols[1])
plot.ylabel(cols[2])
plot.title('Correlation')
plot.grid(True)
plot.show()

