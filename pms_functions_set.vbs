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
			MsgBox "Подумай ещё раз! Прошло времени меньше, чем выделено на ответ.", 48, "Защита от слепого закрытия окон."
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
			MsgBox "Подумай ещё раз! Прошло времени меньше, чем выделено на ответ.", 48, "Защита от слепого закрытия окон."
			mintime=mintime+(Timer-pt1)
		Else
		If an="" Then
			pt1=Timer
			MsgBox "Ошибка: Поле ввода не может оставаться пустым!", 48, "Защита от слепого закрытия окон."
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
