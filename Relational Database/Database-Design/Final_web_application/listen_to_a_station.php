<?php
include 'credentials.php';
// Connection parameters 

// Attempting to connect
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Getting the input parameter (user):
$by = $_REQUEST['by_in'];
$keyword = $_REQUEST['keyword_in'];

// Get the attributes of the user with the given username
$query = "call create_station('$by','$keyword')";
$result = mysqli_query($dbcon, $query)
  or die('Query failed: ' . mysqli_error($dbcon));

echo "You are listening to $by $keyword <p>"; 

$rowcount=mysqli_num_rows($result);
if ($rowcount == 0){echo "Station $table has no songs yet! <p>"; }
else{
	echo '<ul>';
	while ($tuple = mysqli_fetch_row($result)) {
	   		//echo " $tuple[0] | $tuple[1] | $tuple[2] | $tuple[3] | $tuple[4] | $tuple[5] | $tuple[6] | $tuple[7] | $tuple[8] | $tuple[9]<br> ";
	   echo "<li><a href='song_page.php?table_name=$tuple[0]'> $tuple[0]</a>";
	}
}

echo '</ul>';
echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to create_station() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 