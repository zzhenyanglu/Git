<?php

include 'credentials.php';

// Attempting to connect 
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

//   Selecting a database
//   Unnecessary in this case because we have already selected 
//   the right database with the connect statement.  
mysqli_select_db($dbcon, $database)
   or die('Could not select database');

// Listing tables in your database
$query = 'SHOW TABLES';
$result = mysqli_query($dbcon, $query)
  or die('Show tables failed: ' . mysqli_error());

echo  "PLEASE notice that some of the following are VIEWS<br>";
echo "The tables in $database database are:<br>";

// Printing table names in HTML
echo '<ul>';
while ($tuple = mysqli_fetch_row($result)) {
   echo "<li>$tuple[0]";
}
echo '</ul>';
echo '<p>'; 
echo '<p>'; 
echo '<p>'; 
echo "NOTICE: this page corresponse to SHOW_TABLES query procedure in SOURCE CODE folder";
// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 