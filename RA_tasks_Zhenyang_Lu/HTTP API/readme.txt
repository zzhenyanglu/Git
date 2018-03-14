1. Please make sure the following libraries have been installed before running the code: 

	BaseHTTPServer 
	urlparse
	json
	urllib
	pandas
	numpy
	datetime

2. Running the http server:
	
	after installing the previous libs, please run http_server.py. To modify the port, please open http_server.py and modify line 9. 

	please make sure there is a ra_data_classifier.csv file inside the local folder from which the server runs from. 

3. GET: 

	GET is implemented with do_GET function(), which receives a Hid and open the ra_data_classifier.csv 
	file as a pandas DataFrame, and look up the hid (we could also load the csv file into a SQL database and query against it for the hid, but for now as an illastration, the http server interacts with the csv file).

	in order to manually test GET function, you could open a browser and type in the following: 
		http://localhost:<port>/get?hid=<hid>

	If the requested hid was found, GET will return a json object like this:

	{'records': [{'chunk': u'A powerful tool for developers, the MySQL Database Server module provides a schema editor, table data browser, dump and execute SQL features, and the ability to stop and start the MySQL server from the GUI. Virtualmin also provides a similarly capable PostgreSQL module, and Install Scripts for phpmyadmin and phppgadmin.', 'hid': u'3566S7OX5D63FG3CNKAIFH62QX517B', 'has_space': 0}]} 

	otherwise, GET will return to indicate requested hid was found: 
	{'records': []}


4. POST: 
	POST is implemented with do_POST function(), which receives a json object, extract the info from it , write it to the ra_data_classifier.csv file and finally send out a html page to confirm POST succeed ( there should a step that checks if the hid has already existed, but for now, I'm skipping it). You could test POST manually type in a http address or with the following Python scripts: 

		    data = {'records': [{'chunk': 'test_chunk', 'hid': 'test_hid', 'has_space': '0'}]}
    		req = urllib2.Request(server)
    		req.add_header('Content-Type','application/json')
    		response = urllib2.urlopen(req,json.dumps(data))   


5. Automated test: 
	I wrote a test program, client_tester.py in the zip file submitted. Feel free to use it to test the http server. To run it, first make sure the http_server is on, and launch the client_tester.py by 

			py client_tester.py 

6. log files:
	After launching http_server.py, there will be a log file called server_history.txt created in the local folder, which contains the detail activities for debug. 