<?php
include 'credentials.php';
// Connection parameters 
session_start();

// Attempting to connect
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Getting the input parameter (user):
$table = $_SESSION["username"];

// Get the attributes of the user with the given username
$query = "call user_account_setting('$table')";
$result = mysqli_query($dbcon, $query)
  or die('Failed to retrieve user profiles: ' . mysqli_error($dbcon));

echo "<h1> Profile of user $table: </h1><p>"; 

while ($tuple = mysqli_fetch_row($result)) {
   echo " User name: $tuple[0] <br>";
   echo " Birthday: $tuple[1] <br>";
   echo " Member since: $tuple[2] <br>";
   echo " Credit card: $tuple[3] <br>";
   echo " Address 1: $tuple[4] <br>";
   echo " Address 2: $tuple[5] <br>";
   echo " First name: $tuple[6] <br>";
   echo " Last name: $tuple[7] <br>";
   echo " Zip: $tuple[8] <br>";
   echo " State: $tuple[9] <br>";
   echo " City: $tuple[10] <br>";
   echo " Card expiration date: $tuple[11] <br>";
   echo " Account type: $tuple[12] <br>";
}
$link_address = 'https://mpcs53001.cs.uchicago.edu/~zzhenyanglu/upgrade_page.html';
$link_address = 'https://mpcs53001.cs.uchicago.edu/~zzhenyanglu/change_payment.html';
echo "<p><a href='$link_address'> UPGRADE TO PREMIUM</a>";
echo "<p><a href='$link_address'> CHANGE PAYMENT PROFILE</a>";
echo "<p>";
echo "<p>";
echo "<p>";

echo "<form method=post action='change_password.php'><b>Input new password, if you want to reset?</b><br><input type='text' name='new_psw'><BR><input type='Submit' value='Submit'></form>";

echo "NOTICE: this page corresponse to user_account_setting() procedure in SOURCE CODE folder<p>";
echo "NOTICE: the login credentials will be remembered by _SESSION['username'] until you close all the pages.<p>";
// Free result
mysqli_free_result($result);

// Closing connection
mysqli_close($dbcon);
?> 