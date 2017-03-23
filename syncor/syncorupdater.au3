$file_url = "" ; URL of latest version of EXE

If ($CmdLine[0]>0 And $CmdLine[1]=="-update") Then
	ProcessWaitClose("Syncor86.exe")
	InetGet($file_url,"Syncor86-Update.exe")
	sleep(5000) ; <- bad idea, don't do this
	If FileExists("Syncor86-Update.exe") Then
		FileMove("Syncor86-Update.exe","Syncor86.exe",1)
	EndIf
	Run("Syncor86.exe")
Else
	MsgBox(0,"Syncor Updater","Do not run updater manually")
EndIf

