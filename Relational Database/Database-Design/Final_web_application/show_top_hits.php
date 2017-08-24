<?php
include 'credentials.php';
// Connection parameters 

// Attempting to connect
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Get the attributes of the user with the given username
$query = "call show_top_hits()";
$result = mysqli_query($dbcon, $query)
  or die('Query failed: ' . mysqli_error($dbcon));

echo "Last month top rated musics:<p>"; 

echo '<ul>';
while ($tuple = mysqli_fetch_row($result)) {
   echo "<li><a href='song_page.php?table_name=$tuple[0]'> $tuple[0]</a>";
}
echo '</ul>';
echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to show_top_hits() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 