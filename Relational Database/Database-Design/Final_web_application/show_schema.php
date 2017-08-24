<?php
include 'credentials.php';
// Connection parameters 

// Attempting to connect
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Getting the input parameter (user):
$table = $_REQUEST['table_name'];

// Get the attributes of the user with the given username
$query = "call show_schema('$table')";
$result = mysqli_query($dbcon, $query)
  or die('Query failed: ' . mysqli_error($dbcon));

echo "The columns in $table are:<p>"; 

echo    "COLUMN_NAME | DATA_TYPE <p>";
while ($tuple = mysqli_fetch_row($result)) {
   echo " $tuple[0] | $tuple[1]<br>";
}
echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to show_schema() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 