<?php

// Connection parameters 
include 'credentials.php';
session_start();


// Attempting to connect 
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

$new_psw = $_REQUEST["new_psw"];
$user_name = $_SESSION["username"];

// Selecting a database
//   Unnecessary in this case because we have already selected 
//   the right database with the connect statement.  
mysqli_select_db($dbcon, $database)
   or die('Could not select database');

// Listing tables in your database
$query = "update users set passcode = '$new_psw' where user_name = '$user_name' ;";

$result = mysqli_query($dbcon, $query)
  or die('Resetting password failed: ' . mysqli_error());

// Printing table names in HTML

echo "USER $user_name has reset password!<p>";
echo "NOTICE: this page corresponse to no procedure in SOURCE CODE folder, just a plain update command";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 