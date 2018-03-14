from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import urlparse,json,urllib
import pandas as pd
import numpy as np
from datetime import datetime

# GLOBAL SETTING: 
data_file = './ra_data_classifier.csv' # this is the ra_data_classifier.csv file 
port = 28884  # which port to listen for client 


class server(BaseHTTPRequestHandler):

    def _set_headers(self,number):
     
        self.send_response(number)
        self.send_header('Content-type','text/html')
        self.end_headers()

    # open log file if not open and log detailed activities 
    def open_log(self):
        try:
            self.log = open('./server_history.txt','a')
        except:
            self.log = open('./server_history.txt','a')


    def do_GET(self):

        self.open_log()
        parsed_path = urlparse.urlparse(self.path)
        self.log.write("["+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"]Received GET request: "+ str(parsed_path)+'\n')

        # to submit a GET to the http server, run:
        # http://localhost:28884/get?hid=123
        
        
        if str.lower(parsed_path.path) == '/get' and parsed_path.query:
            # json_message is a map that will be dumped into a json after query the hid
            json_message ={'records':[]}
            hid = parsed_path.query.split('=')[1] # get hid requested
            
            self.log.write("["+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"]Requested HID: "+hid+'\n')
            # read the ra_data_classifier.csv as pandas dataframe
            database = pd.read_csv(data_file,encoding='latin-1') 
            record = database[database.iloc[:,0]==hid]

            # if found a record with the requested hid, create json object, and send it over
            if len(record) >0:
                
                for i in range(len(record)):
                    new_record = { 'hid':record.iloc[i,0],'chunk':record.iloc[i,1],'has_space':int(record.iloc[i,2])}
                    json_message['records'].append(new_record)

                self._set_headers(200)
                self.log.write("["+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"]Sent JSON Object to client: " + str(json_message)+'\n')
                self.wfile.write(json.dumps(json_message,encoding='latin-1'))

            # if not found a record with the requested hid, send a empty json object
            else:
                self._set_headers(200)
                self.log.write("["+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"]Requested HID not found: "+hid+'\n')
                #self.wfile.write("<html><body><h1>Hid Not Found ..</h1></body></html>")       
                self.wfile.write(json.dumps(json_message,encoding='latin-1'))
         
        # a client call this http server not with the following format:
        # http://localhost:28884/get?hid=123, send an instruction on how to call it
        else:
            self._set_headers(200)
            self.log.write("["+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"]Bad Requested: "+parsed_path.path+'\n')
            self.wfile.write("<html><body><h1>Bad Request!<br/> Valid GET request: http://localhost:28888/get?hid=3R6RZGK0XFZ2GCFBH7K7ZIXFJ0KVY </h1></body></html>")
        

    def do_HEAD(self):
        self._set_headers(200)    


    def do_POST(self):
        # read the json object
        post_len = int(self.headers.getheader('content-length',0))
        post_data = json.loads(self.rfile.read(post_len))['records']
        
        self.open_log()
        self.log.write("["+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"]Received POST : "+str(post_data)+'\n')
        
        # extract information from the json object and write it to 
        # the local copy of ra_data_classifier.csv file 
        with open(data_file,'ab') as f:
            f.write("\n")
            for i in range(len(post_data)):
                new_record = post_data[i]['hid'] + ","+post_data[i]['chunk'] +","+ post_data[i]['has_space']
                f.write(new_record)
                self.log.write("["+datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"] Writing new record received: "+str(post_data)+'\n')
        
        self._set_headers(200)
        self.wfile.write("<html><body><h1>Data Received!</h1></body></html>")

    # stop the server
    def shutdown(self,shutdown):
        
        try:
            self.log.close()
        except:
            pass
        self.shutdown() 


def run(server_class = HTTPServer,handler_class=server, port = port):
    try:
        address = ('',port)
        http_server = server_class(address,handler_class)
        http_server.serve_forever()

    except:
        http_server.shutdown()


if __name__ == "__main__":
    run()
