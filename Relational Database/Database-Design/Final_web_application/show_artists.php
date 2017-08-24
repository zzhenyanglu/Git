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
$query = 'call show_artists();';
$result = mysqli_query($dbcon, $query)
  or die('Show tables failed: ' . mysqli_error());

echo "List of artists in FakeSpotify:<br>";

// Printing table names in HTML
echo '<ul>';
while ($tuple = mysqli_fetch_row($result)) {
   echo "<li><a href='show_song_by_artist.php?table_name=$tuple[0]'> $tuple[0]</a>";
}
echo '</ul>';
echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to show_artists() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 