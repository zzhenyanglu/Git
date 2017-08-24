<?php
include 'credentials.php';
// Connection parameters 

// Attempting to connect
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Getting the input parameter (user):
session_start();

$username = $_SESSION["username"];
$card_no = $_REQUEST['card_no'];
$expiration = $_REQUEST['expiration'];
$security = $_REQUEST['security'];
$address_1 = $_REQUEST['address_1'];
$address_2 = $_REQUEST['address_2'];
$first_name = $_REQUEST['first_name'];
$last_name = $_REQUEST['last_name'];
$zip = $_REQUEST['zip'];
$state = $_REQUEST['state'];
$City = $_REQUEST['City'];


$query = "call upgrade_user( '$username' ,'$card_no', '$address_1', '$address_2','$first_name', '$last_name','$zip','$state', '$City','$expiration','$security')";

$result = mysqli_query($dbcon, $query) or die('Upgrade failed: ' . mysqli_error($dbcon));

header('Location: https://mpcs53001.cs.uchicago.edu/~zzhenyanglu/SemiFinal.html');

echo "<p>";
echo "<p>";
echo "<p>";
echo "NOTICE: this page corresponse to upgrade_user() procedure in SOURCE CODE folder";

// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 