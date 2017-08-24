<?php
include 'credentials.php';
// Connection parameters 
session_start();

// Attempting to connect
$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

// Getting the input parameter (user):
$table = $_REQUEST['table_name'];
$user_name = $_SESSION['username'];

// Get the attributes of the user with the given username
$query = "call fetch_a_song('$table')";
$result = mysqli_query($dbcon, $query)
  or die('Query failed: ' . mysqli_error($dbcon));

echo "You are listening to $table <p>"; 


while ($tuple = mysqli_fetch_row($result)) {
   $headshot = $tuple[7];
   $music = $tuple[8];
   $song_name = $tuple[0];
   echo "<img src='$headshot' alt='headshot' style='width:100px;height:50px;'> ";
   echo "<p>";
   echo "<audio controls><source src='$music' type='audio/mp3'></audio>";
   echo "<p>";
   echo "You are listening: $tuple[0]<br>";
   echo "From album: $tuple[1]<br>";
   echo "By artist: $tuple[6]<br>";
   echo "Genre: $tuple[4]<br>";
   echo "Language: $tuple[5]<br>";
}
# LIKE IT
echo "<a href='favorite_song.php?song_name=$song_name' > LIKE IT</a>";

# ADD TO PLAYLIST
echo "<form method=post action='add_to_playlist.php?song_name=$song_name'><b>add this song to which of your playlist:</b><br><input type='text' name='playlist_name'><BR><input type='Submit' value='Submit'></form>";

# REMOVE FROM A PLAYLIST
echo "<form method=post action='remove_from_playlist.php?song_name=$song_name'><b>remove this song from which of your playlist:</b><br><input type='text' name='playlist_name'><BR><input type='Submit' value='Submit'></form>";

// Free result
mysqli_free_result($result);
mysqli_close($dbcon);

$dbcon = mysqli_connect($host, $username, $password, $database)
   or die('Could not connect: ' . mysqli_connect_error());

$query2 = "call show_user_playlists('$user_name')";
$result2 = mysqli_query($dbcon, $query2)
  or die('Query failed: ' . mysqli_error($dbcon));

echo "<hr>";

# show user's playlist
echo "Your Playlists: <p>"; 
echo '<ul>';
while ($tuple = mysqli_fetch_row($result2)) {
   echo "<li><a href='show_song_in_playlist.php?table_name=$tuple[1]'> $tuple[1]</a>";
}
echo '</ul>';
echo "<p>";
echo "<p>";
echo "<p>";
echo "<hr>";
echo "NOTICE: I used insert/delete ignore for functionalities in this page, so there is no message when you perform an action, but it actually happens in database level<p>";
echo "NOTICE: it should be no action when you click LIKE IT. But it actually inserts a row into favorites table<p>";
echo "NOTICE: it should be no action when you add it to a playlist. But it actually inserts a row into song_in_playlist table<p>";
echo "NOTICE: it should be no action when you remove it from a playlist. But it actually remove a row into song_in_playlist table<p>";
echo "NOTICE: this page corresponse to fetch_a_song() procedure in SOURCE CODE folder<p>";

// Free result
mysqli_free_result($result2);

// Closing connection
mysqli_close($dbcon);
?> 