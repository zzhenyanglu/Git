run: webserver serverthread
	java webserver --serverPort=5557

webserver: serverthread.java webserver.java
	javac webserver.java

serverthread: serverthread.java
	javac serverthread.java

.PHONY: clean
clean:
	rm serverthread.class webserver.class


