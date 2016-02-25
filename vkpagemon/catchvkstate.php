<?php
$url="http://api.vkontakte.ru/method/users.get?uids=XXXXXXXXX&fields=online,last_seen";
$mass=json_decode(file_get_contents($url), true);
if ($mass["response"][0]["online"]==1) $online="ONLINE ";
else $online="OFFLINE";
switch ($mass["response"][0]["last_seen"]["platform"]){
    case 1: $platform="mobile";break;
    case 2: $platform="iphone";break;
    case 3: $platform="ipad";break;
    case 4: $platform="android";break;
    case 5: $platform="wphone";break;
    case 6: $platform="windows";break;
    case 7: $platform="web";break;
}
//echo 'Target: '.$mass["response"][0]["first_name"].' '.$mass["response"][0]["last_name"].PHP_EOL;
echo $online.' '.date('H:i:s d.m.Y', $mass["response"][0]["last_seen"]["time"]).' '.$platform.PHP_EOL;
?>
