<?php
include 'credentials.php';
// Connection parameters 

// Attempting to connect
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Getting the input parameter (user):
$username = $_REQUEST['username'];
$password = $_REQUEST['password'];


// Get the attributes of the user with the given username
$query = "call login('$username','$password')";
$result = mysqli_query($dbcon, $query)
  or die('Query failed: ' . mysqli_error($dbcon));


while ($tuple = mysqli_fetch_row($result)) {
		# if credential correct
   	if ($tuple[0] == 1){
   		  session_start();
   		  $_SESSION["username"] = "$username";
        $_SESSION["password"] = "$password";
        echo "Welcome back, ".$_SESSION["password"]. "!<br>";
        
        header('Location: https://mpcs53001.cs.uchicago.edu/~zzhenyanglu/SemiFinal.html');
   	} 
   	# if credential incorrect
   	else { 
   		header('Location: https://mpcs53001.cs.uchicago.edu/~zzhenyanglu/wrong_credentials.html'); 
    }
}

echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to login() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 