<?php
include 'credentials.php';
// Connection parameters 

// Attempting to connect
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Getting the input parameter (user):
$username = $_REQUEST['username'];
$password = $_REQUEST['password'];
$birthday = $_REQUEST['birthday'];

// Get the attributes of the user with the given username
$query = "call create_user('$username','$password', '$birthday')";
$result = mysqli_query($dbcon, $query)
  or die('Signup failed: ' . mysqli_error($dbcon));

session_start();
$_SESSION["username"] = "$username";
$_SESSION["password"] = "$password";


header('Location: https://mpcs53001.cs.uchicago.edu/~zzhenyanglu/SemiFinal.html');

echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to create_user() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 