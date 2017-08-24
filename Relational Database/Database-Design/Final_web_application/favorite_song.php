<?php
session_start();
// Connection parameters 
include 'credentials.php';

$song = $_REQUEST['song_name'];
$user_name =  $_SESSION['username'];

// Attempting to connect 
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Selecting a database
//   Unnecessary in this case because we have already selected 
//   the right database with the connect statement.  
mysqli_select_db($dbcon, $database)
   or die('Could not select database');

// Listing tables in your database
$query = "call favorite_a_song('$user_name', '$song');";
$result = mysqli_query($dbcon, $query)
  or die('Failed to favorite a song ' . mysqli_error());

echo "$user_name has favored song $song!<p>";
header('Location: ' . $_SERVER['HTTP_REFERER']);
// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 