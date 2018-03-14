from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import urlparse,json,urllib2
import pandas as pd
import numpy as np
from datetime import datetime

# TEST POST
server = 'http://localhost:28884/'

#
## TEST GET 
hids = ['33BFF6QPI1YEFYISIWWDVQKGH8R3Z',
'3HUR21WDDUCUK1K6HMLPN3U0ZBSYX0',
'3566S7OX5D63FG3CNKAIFH62QX517B',
'3GV1I4SEO9CX1NTBXKN9TIFKTSQ6LN',
'37SDSEDIN9P7FU8VXP2OTH2X1HB18Y',
'3CIS7GGG6564XS9KCGY8WT3GNH6UEP',
'3CMIQF80GND8SK9OPPV54EE3YD6QC',
'3RWB1RTQDJAAWMRXIRDEUDKV4XGP8P',
'3EGKVCRQFWFN7YH5CQT7Y638G84BY4',
'3Z56AA6EK4NH75BWXWOOTVU9TXG6MP',
'32FESTC2NHDP0UP6GPSD653D25TUCW',
'3ZVPAMTJWNQA1EDUEHTRRL18THRGZ',
'38LRF35D5LJ1NUTNNWHCD2ZJWSGU3Y',
'39RRBHZ0AUO2L2PGDTMQDP6HPUOVZL',
'3GMLHYZ0LEK23XQBCHA23WVW5TBYU8',
'32L724R85L73LS3ARDP572E97TLPIX',
'3LG268AV38TCH0H38M33RIGWG2ER5',
'32ZCLEW0BZ7ZG3NG9VA5J3T9K8APJ9']


print "Currently testing GET"

for hid in hids:
    req = json.load(urllib2.urlopen(server+'get?hid='+hid))
    
    if req['records']:
        print 'Record received: '+ str(req)
    else:
        print 'No record received with the following Hid: '+hid
    print '\n'
    
print "End of testing GET"



print "Currently testing POST"

for i in range(20):
    data = {'records': [{'chunk': 'test_chunk', 'hid': 'test_hid', 'has_space': '0'}]}
    print "Sending data to http server:" + str(data) + "\n"
    req = urllib2.Request(server)
    req.add_header('Content-Type','application/json')
    response = urllib2.urlopen(req,json.dumps(data))    
    print "Received response html: "+response.read() + "\n"
    
print "End of testing POST"

