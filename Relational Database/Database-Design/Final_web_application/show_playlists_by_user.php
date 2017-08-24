<?php
// Connection parameters 
include 'credentials.php';
session_start();
$user_name = $_SESSION['username'];

// Attempting to connect 
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Selecting a database
//   Unnecessary in this case because we have already selected 
//   the right database with the connect statement.  
mysqli_select_db($dbcon, $database)
   or die('Could not select database');

// Listing tables in your database
$query = "call show_user_playlists('$user_name');";
$result = mysqli_query($dbcon, $query)
  or die('Show tables failed: ' . mysqli_error());

echo "User $user_name has the following playlists: <br>";

// Printing table names in HTML
echo '<ul>';
while ($tuple = mysqli_fetch_row($result)) {
   echo "<li><a href='show_song_in_playlist.php?table_name=$tuple[1]'> $tuple[1]</a>";
}
echo '</ul>';

echo "<form method=post action='add_new_playlist.php'><b>create a new playlist:</b><br><input type='text' name='playlist_name'><BR><input type='Submit' value='Submit'></form>";

echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to show_public_playlists() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 