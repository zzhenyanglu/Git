MPCS 54001 - Project 3

Files contained: 
    PingClient.java 

Compilation: 
    javac PingClient.java

Run: 
    1. Initiate PingServer
    2. Initiate Pingclient by the following code: 
       java PingClient --server_ip=<ServerIP> --server_port=<ServerPort> --count=<count> --period=<period> --timeout =<timeout>

The PingClient class contains two functions: 
       1. main(): parses arguments, and initate a socket object and launch a scheduled at fixed rate job at <period> interval. Then waits for reply messages
                  back from server with a timeout value as <timeout>.
       2. run(): each time called, the run function will ping the server. If it reach <count> times, cancel the scheduled tasks.

Things to notice: 
    1. run() function is a container of each thread, which send a PING message to server. Each thread must be quick enough, so that it does not screw up the        ScheduledAtFixedRate() scheduler. For example, if each run() takes 1000 MS while the ScheduledAtFixedRate() function is set up to run at an interval 
       of only 100 MS, then you will see the <period> argument does not really work as expected. So that's why in my code, the receiving-from-server section        is not placed into the thread. 

    2. When you call the PingClient, if the <timeout> is smaller than <period>, then you will notice that the PingClient sends out PING STATISTIC even before       the last PING being sent to server, so I believe that's a not a correct set of arguments to use, but I don't assert it in the code to stop the 
       PingClient. I would hope the user will keep that in mind.  
