#include <PUtils.au3>

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

OnAutoItExitRegister("Koniec")

Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=D:\AutoIt3-Scripts\reminder\formReminder.kxf
$formReminder = GUICreate("Reminder", 250, 177, 192, 124)
GUISetOnEvent($GUI_EVENT_CLOSE, "Koniec")
$iHours = GUICtrlCreateInput("0", 16, 32, 41, 37)
GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
$lblHours = GUICtrlCreateLabel("h", 64, 40, 17, 33)
GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
$iMinutes = GUICtrlCreateInput("0", 96, 32, 41, 37)
GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
$lblMinutes = GUICtrlCreateLabel("m", 144, 40, 24, 33)
GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
$iSeconds = GUICtrlCreateInput("0", 176, 32, 41, 37)
GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
$lblSeconds = GUICtrlCreateLabel("s", 224, 40, 16, 33)
GUICtrlSetFont(-1, 17, 400, 0, "MS Sans Serif")
$btnStart = GUICtrlCreateButton("START", 56, 96, 129, 65)
GUICtrlSetOnEvent(-1, "btnStartClick")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $running = False, $ileCzekac = 0, $timer = 0

Func Tick()
	If (TimerDiff($timer) >= $ileCzekac) Then
		AdlibUnRegister("Tick")
		WinSetTitle($formReminder,"","Reminder - [ready]")
		global $formReady = GUICreate("READY",@DesktopWidth,@DesktopHeight,Default,Default,$WS_POPUP,$WS_EX_TOPMOST)
		global $btnReady = GUICtrlCreateButton("READY",(@DesktopWidth/2)-200,(@DesktopHeight/2)-100,400,200)
		GUICtrlSetFont(-1, 24, 800, 0, "Tahoma")
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, 0xFFFFFF)
		GUICtrlSetOnEvent(-1, "EndReady")
		GUISetState(@SW_SHOW,$formReady)
		AdlibRegister("Blink",100)
		ChangeState()
	Else
		local $zostalo = $ileCzekac - TimerDiff($timer)
		local $godziny = Int($zostalo / (60*60*1000))
		local $minuty = Int(($zostalo - ($godziny*60*60*1000)) / (60*1000))
		local $sekundy = Int( ($zostalo - ($godziny*60*60*1000) - ($minuty*60*1000)) / 1000)

		WinSetTitle($formReminder,"","Reminder - [" & $godziny & ":" & $minuty & ":" & $sekundy & "]")
		GUICtrlSetData($iHours,$godziny)
		GUICtrlSetData($iMinutes,$minuty)
		GUICtrlSetData($iSeconds,$sekundy)
	EndIf
EndFunc

Func Blink()
	GUICtrlSetBkColor($btnReady, "0x" & Hex(Random(0,55924),6))
	GUISetBkColor("0x" & Hex(Random(0,16777215),6),$formReady)
EndFunc

Func EndReady()
	AdlibUnRegister("Blink")
	GUIDelete($formReady)
EndFunc

Func btnStartClick()
	If (Not $running) Then
		If (StringIsInt(GUICtrlRead($iHours)) And StringIsInt(GUICtrlRead($iMinutes)) And StringIsInt(GUICtrlRead($iSeconds)) And IsInRange(Number(GUICtrlRead($iHours)),0,60) And IsInRange(Number(GUICtrlRead($iMinutes)),0,60) And IsInRange(Number(GUICtrlRead($iSeconds)),0,60)) Then
			$ileCzekac = Number(GUICtrlRead($iHours))*60*60*1000 + Number(GUICtrlRead($iMinutes))*60*1000 + Number(GUICtrlRead($iSeconds))*1000
			$timer = TimerInit()
			AdlibRegister("Tick",1000)
		Else
			MsgBox(0,"Reminder","Wprowadzone dane s¹ nie prawid³owe.")
			Return False
		EndIf
	Else
		AdlibUnRegister("Tick")
	EndIf
	ChangeState()
EndFunc

Func ChangeState()
	If ($running) Then
		GUICtrlSetData($btnStart,"START")
		GUICtrlSetState($iHours,$GUI_ENABLE)
		GUICtrlSetState($iMinutes,$GUI_ENABLE)
		GUICtrlSetState($iSeconds,$GUI_ENABLE)
	Else
		GUICtrlSetData($btnStart,"STOP")
		GUICtrlSetState($iHours,$GUI_DISABLE)
		GUICtrlSetState($iMinutes,$GUI_DISABLE)
		GUICtrlSetState($iSeconds,$GUI_DISABLE)
	EndIf
	$running = Not $running
EndFunc

While 1
	Sleep(100)
WEnd

Func Koniec()
	Exit
EndFunc