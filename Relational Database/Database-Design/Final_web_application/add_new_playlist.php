<?php
session_start();
// Connection parameters 
include 'credentials.php';
$user_name = $_SESSION['username'];
$playlist_name = $_REQUEST['playlist_name'];

// Attempting to connect 
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Selecting a database
//   Unnecessary in this case because we have already selected 
//   the right database with the connect statement.  
mysqli_select_db($dbcon, $database)
   or die('Could not select database');

// Listing tables in your database
$query = "call add_new_playlist('$playlist_name', '$user_name');";
$result = mysqli_query($dbcon, $query)
  or die('Adding playlist failed: ' . mysqli_error($dbcon));

echo "New playlist $playlist_name has been created!";
echo "<a href='https://mpcs53001.cs.uchicago.edu/~zzhenyanglu/show_playlists_by_user.php'> GO BACK</a>";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 