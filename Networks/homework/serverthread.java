import java.net.*;
import java.io.*;
import java.util.*;

public class serverthread extends Thread {
    private Socket socket = null;

    public serverthread(Socket socket) {
        super("serverthread");
        this.socket = socket;
    }
    
    public void run() 
    {
       try
       (
          // out is a handler to send streams to client
          DataOutputStream out = new DataOutputStream(socket.getOutputStream());
          // in is streams from clients
          BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
       )

       {
          // query is request from clients 
          // e.g. GET /foo/bar.html HTTP/1.1
          String query = in.readLine();

          // if the client binds the webserver but does not send any request
          // then ignore it and return. 
          if (query == null) return;

          String[] request = query.split(" ");

          // method can be GET HEAD 
          String method = request[0];
          // requested_object can be /foo/bar.html or /cats
          String requested_object = request[1];

          // header fields
          String response_status; // for example 200, 404
          String server = "MPCS54001 Web Server";
          String content_type = null;
          String location = null;

          // print out client IP and http method and requested objects to screen
          System.out.println("Client " + socket.getRemoteSocketAddress().toString()+ " is visiting..");
          System.out.println("HTTP METHOD: " + method);
          System.out.println("REQUESTED OBJECT: " + requested_object);

          // handling GET and HEAD method: 
          if (method.equals("GET") || method.equals("HEAD")) 
          {

             // CASE 1: 
             // if the requested file is redirect.defs 
             // tell 404 not found
             if(requested_object.equals("/redirect.defs"))
             {
                response_status = "HTTP/1.1 404 Not Found";
 
                out.writeBytes(response_status+"\r\n");
                out.writeBytes("Server: "+ server +"\r\n");
                out.writeBytes("Connection: close\r\n");
                out.writeBytes("\r\n");      
                return;        
             }

             // CASE 2:
             // if the requested file exists. 
             else if(new File("./www" + requested_object).exists())
             {
                // 1. Set up response code
                response_status = "HTTP/1.1 200 OK";
                
                // 2. figure out content type
                if (requested_object.endsWith(".html")){content_type ="text\\html"; }
                else if (requested_object.endsWith(".txt")){content_type ="text\\plain";}
                else if (requested_object.endsWith(".pdf")){content_type ="application\\pdf"; }
                else if (requested_object.endsWith(".png")){content_type ="image\\png"; }
                else if (requested_object.endsWith(".jpeg")){content_type ="image\\jpeg"; }
                else {content_type ="application/octet-stream"; }

                // HTTP header for cases when the requeste objects exist
                out.writeBytes(response_status+"\r\n");
                out.writeBytes("Server: " + server+"\r\n");
                out.writeBytes("Content-Type: " + content_type+"\r\n");
                out.writeBytes("\r\n"); 

                // 3. IF it's a GET method, prepare for the http body data
                if (method.equals("GET"))
                {

                   FileInputStream mime_object = new FileInputStream("./www" + requested_object);
                   byte[] buffer = new byte[10240];
                   int read_in_bytes;

                   while ((read_in_bytes = mime_object.read(buffer)) != -1 ) 
                   {
                      out.write(buffer, 0, read_in_bytes);
                   } 
                   
                   mime_object.close();
                }
                return;
             }

             // CASE 3:
             // if the requested object can be redirected 
             // OR 
             // ibf the requested object is not found

             else 
             {
                // redirect_buffer is the handler that contains redirects of objects
                FileInputStream  redirect = new FileInputStream("./www/redirect.defs");
                BufferedReader redirect_buffer = new BufferedReader(new InputStreamReader(redirect));

                // each line of redirect.defs
                String line;

                while ((line = redirect_buffer.readLine()) != null) 
                {
                   // original can be /cats
                   String original  = line.split(" ")[0];
                   // move to can be http://en.wikipedia.org/wiki/Cat
                   String move_to  = line.split(" ")[1];
               
                   // if object can be redirected, send a 301 message
                   if(original.equals(requested_object))
                   {
                      response_status = "HTTP/1.1 301 Moved Permanently";
                      location = move_to;
                     
                      out.writeBytes(response_status+"\r\n");
                      out.writeBytes("Server: " + server+"\r\n");
                      out.writeBytes("Location: " + location+"\r\n");
                      out.writeBytes("\r\n");

                      redirect.close();
                      redirect_buffer.close(); 
                      return;
                   }
                }
 
                // CASE 4: 
                // requested object is not found or redirected.
                response_status = "HTTP/1.1 404 Not Found";
                      
                out.writeBytes(response_status+"\r\n");
                out.writeBytes("Server: " + server+"\r\n");
                out.writeBytes("Connection: close\r\n");
                out.writeBytes("\r\n"); 
                     
                redirect.close();
                redirect_buffer.close(); 
                return;
             }
          }

          // if it's any other methods from client than GET or HEAD
          // tell 403 
          // For now, I'm not differentiating between POST and any
          // other types of commands or even invalid request, which
          // means if the request is anything other than HEAD or GET
          // the client will get 403 

          else 
          {
             response_status = "HTTP/1.1 403 Forbidden";

             out.writeBytes(response_status+"\r\n");
             out.writeBytes("Server: " + server+"\r\n");
             out.writeBytes("Connection: close\r\n");
             out.writeBytes("\r\n");        
             return;      
          }
       }

       catch (IOException e) {
          System.out.println(e.toString());
          System.out.println("Exception caught when trying to listen on port "+ socket.getLocalPort() + " or listening for a connection");
       }
    }
}
