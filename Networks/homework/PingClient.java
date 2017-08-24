import java.io.*;
import java.net.*;
import java.util.*;
import java.time.*;
import java.time.format.*;

public class PingClient extends TimerTask{

   // user-input arguments 
   public static int timeout = 0;
   public static int count = 0;
   public static int period = 0;
   public static int server_port = -1;
   public static String server_ip = "";

   // max min avg rtt of pings
   public static int total =0;
   public static int max =0;
   public static int min =0;

   // record how many ping reply received
   public static float received =0;
   // sequence number 
   public static int sequence =0;
   // timer that schedule the Ping jobs. 
   public static Timer timer = new Timer();
   // server is PingServer's IP in format of xxx.xxx.xxx.xxx
   public static InetAddress server; 
   // socket is UDP connection socket
   public static DatagramSocket socket;
   // request datagram
   public static DatagramPacket request;
   // response from server
   public static DatagramPacket response = new DatagramPacket(new byte[1024], 1024);
   // record the start time of PING jobs
   public static ZonedDateTime start_time;



   public void run() {
   
      // if sequence is larger than count then stop the scheduled at fix rate tasks.     
      if(sequence >= count){ 
         timer.cancel();
       
         return;
      }
   
      sequence++; 

      try{

         // preparing for datagram
         String payload = "PING "+ Integer.toString(sequence) +" " + ZonedDateTime.now().toString() + "\r\n";
         byte[] buf = payload.getBytes();           
 
         //System.out.println("Sending request on " +ZonedDateTime.now().format(DateTimeFormatter.RFC_1123_DATE_TIME));
 
         // sending datagram via UDP socket
         request = new DatagramPacket(buf, buf.length, server, server_port);
         socket.send(request);

         return;

      } //try

      catch (SocketException e ){
        System.out.println(e.toString());
      }

      catch (IOException e){
         System.out.println(e.toString());
      }
   }

   
   public static void main(String[] argv){

      for (String arg : argv) {

         String[] splitArg = arg.split("=");

         // handle server_ip
         if (splitArg.length == 2 && splitArg[0].equals("--server_ip")) {
            server_ip = splitArg[1];
         }

         // handle serverport
         else if (splitArg.length == 2 && splitArg[0].equals("--server_port")) {
            server_port = Integer.parseInt(splitArg[1]);
         } 
  
         // handle count
         else if (splitArg.length == 2 && splitArg[0].equals("--count")) {
            count = Integer.parseInt(splitArg[1]);
         }

         // handle period
         else if (splitArg.length == 2 && splitArg[0].equals("--period")) {
            period = Integer.parseInt(splitArg[1]);
         }
 
         // handle timeout
         else if (splitArg.length == 2 && splitArg[0].equals("--timeout")) {
            timeout = Integer.parseInt(splitArg[1]);
         }    

         else {
            System.err.println("USAGE:    ");
            System.err.println("java PingClient --server_ip=<server ip addr>"); 
            System.err.println("                --server_port=<server port>");
            System.err.println("                --count=<number of pings to send>");
            System.err.println("                --period=<wait interval>");
            System.err.println("                --timeout=<timeout>");
         
            return;
         }
      }          

      // Check IP address.
      if (server_ip.isEmpty()) {
         System.err.println("Must specify server IP address with --server_ip");
         return;
      }

      // Check port number.
      if (server_port == -1) {
         System.err.println("Must specify server port with --serverport");
         return;
      }

      if (server_port <= 1024) {
         System.err.println("Avoid potentially reserved port number: " + server_port + " (should be > 1024)");
         return;
      }

      // check count,period,timeout
      if (count <=0) {
         System.err.println("Must specify a number of datagrams sent larger than 0 with --count");
         return;
      }

      if (period <=0) {
         System.err.println("Each ping request must be separated by larger than 0 milliseconds specified by --period");
         return;
      }

      if (timeout <=0) {
         System.err.println("Must specify a timeout period larger than 0 with --timeout");
         return;
      }               

   // initiate UDP connection 

   // server is the address of server
   try{
      
      socket = new DatagramSocket();

      // socket is UDP connection socket
      socket.setSoTimeout(timeout);
      server = InetAddress.getByName(server_ip);
   }
  
   catch (SocketException | UnknownHostException e ){
      System.out.println(e.toString());
   }


   // remember start time        
   start_time = ZonedDateTime.now();

   // call the scheduled at fix rate Ping tasks    
   System.out.println("PING " + server.getHostAddress());
   PingClient task = new PingClient();
   timer.scheduleAtFixedRate(task, period, period);
  
  
   // listen to response
   for(int i =1;i<=count;i++)
   { 
      // listening to response
      try {
         socket.receive(response);
         byte[] buffer = response.getData();

         // Calculate RTT
         String response_timestamp_str = new String(buffer).split(" ")[2];                        
   
         // sequence number of response email got from server
         String response_sequence = new String(buffer).split(" ")[1];                        
         ZonedDateTime response_timestamp = ZonedDateTime.parse(response_timestamp_str.trim());
         Duration rtt = Duration.between(response_timestamp,ZonedDateTime.now());
         int rtt_int = (int)rtt.toMillis();

         System.out.println("PONG " + server.getHostAddress() + ": seq="+response_sequence +" time=" + rtt_int + " ms");       
            
         // for statistics, how many reply received. 
         received++;

         // record max min and total
         if (max ==0 && min ==0){max =rtt_int; min=rtt_int;}
         if (rtt_int > max){max = rtt_int;}         
         if (rtt_int < min){min = rtt_int;}  

         total = total + rtt_int;
      }

      // if Socket timeouts 
      catch (IOException e) {
         // more to come here! 
         continue;
      }
   }

   // calculate total time elapsed. 
   Duration time_elapsed = Duration.between(start_time, ZonedDateTime.now());

   // print out task stats as soon as it stops. 
   System.out.println("\n--- " + server.getHostAddress() +" ping statistics ---");
      
   System.out.println(count+" transmitted, "+ (int)received+" received, "+String.format("%.0f%%",(count-received)/count*100)+" loss, time "+time_elapsed.toMillis() + " ms");
      
   if (received ==0){
      System.out.println("rtt min/avg/max = 0/0/0 ms\n" );
   }
         
   else {
      System.out.println("rtt min/avg/max = " + min + "/" + (int)total/(int)received +"/" +max +" ms\n" );
   }   
       
   return;
   
   }//main()
}
