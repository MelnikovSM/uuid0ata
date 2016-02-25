<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<form method="post">
 <p>Post data: <input type="text" name="data" /></p>
 <p><input type="submit" /></p>
</form>
<?php
$dt=date("Y/m/d H:i:s");
$input=$_POST['data'];
if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
    $ip = $_SERVER['HTTP_CLIENT_IP'];
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
} else {
    $ip = $_SERVER['REMOTE_ADDR'];
}
if(!empty($input)):
	$str='['.$dt.' '.$ip.'] '.$input.PHP_EOL;
	file_put_contents('telemetric_log.txt', $str, FILE_APPEND);
	print "[INFO] POST Request data saved!<br>".PHP_EOL."Date details: ".$dt."<br>".PHP_EOL."Input details: ".$input."<br>";
else:
	print "[INFO] Empty data POST request!";
endif;
?>
