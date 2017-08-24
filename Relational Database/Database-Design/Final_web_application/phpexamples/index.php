<?php
	if (!isset($_REQUEST['race']))
  {
    include 'form.php';
  }
  else
  {
    $race = $_REQUEST['race'];
    if ($race == 'Starved Rock Country Marathon')
    {
      $output = 'Yeah right, you haven\'t run in forevers FOR REALZZZZZ!';
    }
    else
    {
      $output = 'Nice! ' . htmlspecialchars($race, ENT_QUOTES, 'UTF-8') . ' sounds like a good one!';
    }
    
    include 'running.php';   
  }
?>