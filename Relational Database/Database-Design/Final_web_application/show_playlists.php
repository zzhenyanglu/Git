<?php
// Connection parameters 
include 'credentials.php';

// Attempting to connect 
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Selecting a database
//   Unnecessary in this case because we have already selected 
//   the right database with the connect statement.  
mysqli_select_db($dbcon, $database)
   or die('Could not select database');

// Listing tables in your database
$query = 'call show_public_playlists();';
$result = mysqli_query($dbcon, $query)
  or die('Error: ' . mysqli_error($dbcon));

echo "List of public playlists FakeSpotify<br>";

// Printing table names in HTML
echo '<ul>';
while ($tuple = mysqli_fetch_row($result)) {
   echo "<li><a href='show_song_in_playlist.php?table_name=$tuple[1]'> $tuple[1]</a>";
}
echo '</ul>';

echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to show_public_playlists() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 