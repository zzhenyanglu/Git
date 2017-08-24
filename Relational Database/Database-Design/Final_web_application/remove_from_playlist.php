<?php
session_start();
// Connection parameters 
include 'credentials.php';

$playlist_name = $_REQUEST['playlist_name'];
$song_name =  $_REQUEST['song_name'];

echo "$song";
// Attempting to connect 
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Selecting a database
//   Unnecessary in this case because we have already selected 
//   the right database with the connect statement.  
mysqli_select_db($dbcon, $database)
   or die('Could not select database');

// Listing tables in your database
$query = "call remove_from_playlist('$playlist_name', '$song_name');";
$result = mysqli_query($dbcon, $query)
  or die('ERROR: ' . mysqli_error($dbcon));

header('Location: ' . $_SERVER['HTTP_REFERER']);
// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 