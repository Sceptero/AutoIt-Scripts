#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Opt("GUIOnEventMode", 1)

Dim $ver = 0.1

#Region ### START Koda GUI section ### Form=d:\autoit3-scripts\easyshutdown.kxf
$Form1_1 = GUICreate("Windows EasyShutdown v " & $ver & " by peXu", 338, 226, 192, 124)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form1_1Close")
$radShutdown = GUICtrlCreateRadio("Shutdown", 68, 16, 73, 17)
GUICtrlSetOnEvent(-1, "radShutdownClick")
$radLogoff = GUICtrlCreateRadio("Logoff", 212, 16, 57, 17)
GUICtrlSetOnEvent(-1, "radLogoffClick")
$radRestart = GUICtrlCreateRadio("Restart", 148, 16, 57, 17)
GUICtrlSetOnEvent(-1, "radRestartClick")
$cboxForceClose = GUICtrlCreateCheckbox("Force running applications to close", 24, 56, 297, 17)
$cboxTimer = GUICtrlCreateCheckbox("Timer", 24, 80, 57, 17)
GUICtrlSetOnEvent($cboxTimer, "cboxTimerClick")
$iHours = GUICtrlCreateInput("0", 96, 80, 25, 21)
GUICtrlSetState($iHours, $GUI_DISABLE)
$lblHours = GUICtrlCreateLabel("h", 128, 80, 12, 20)
GUICtrlSetFont($lblHours, 10, 800, 0, "System")
$iMinutes = GUICtrlCreateInput("0", 144, 80, 25, 21)
GUICtrlSetState($iMinutes, $GUI_DISABLE)
$iSeconds = GUICtrlCreateInput("0", 192, 80, 25, 21)
GUICtrlSetState($iSeconds, $GUI_DISABLE)
$lblMinutes = GUICtrlCreateLabel("m", 176, 80, 16, 20)
GUICtrlSetFont($lblMinutes, 10, 800, 0, "System")
$lblSeconds = GUICtrlCreateLabel("s", 224, 80, 12, 20)
GUICtrlSetFont($lblSeconds, 10, 800, 0, "System")
$cboxComment = GUICtrlCreateCheckbox("Comment", 24, 104, 65, 17)
GUICtrlSetOnEvent($cboxComment, "cboxCommentClick")
$iComment = GUICtrlCreateInput("", 96, 104, 209, 21)
GUICtrlSetState($iComment, $GUI_DISABLE)
$cboxPlanned = GUICtrlCreateCheckbox("Planned", 24, 126, 73, 17)
GUICtrlSetState($cboxPlanned, $GUI_CHECKED)
$btnExecute = GUICtrlCreateButton("EXECUTE", 60, 160, 105, 33)
GUICtrlSetOnEvent($btnExecute, "btnExecuteClick")
$btnAbort = GUICtrlCreateButton("ABORT", 172, 160, 105, 33)
GUICtrlSetOnEvent($btnAbort, "btnAbortClick")
$btnAbout = GUICtrlCreateButton("about", 132, 200, 73, 17)
GUICtrlSetOnEvent($btnAbout, "btnAboutClick")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	Sleep(100)
WEnd

Func Form1_1Close()
	Exit
EndFunc   ;==>Form1_1Close

Func radShutdownClick()
	GUICtrlSetState($cboxComment, $GUI_ENABLE)
	GUICtrlSetState($cboxForceClose, $GUI_ENABLE)
	GUICtrlSetState($cboxPlanned, $GUI_ENABLE)
	GUICtrlSetState($cboxTimer, $GUI_ENABLE)
	cboxTimerClick()
	cboxCommentClick()
EndFunc   ;==>radShutdownClick

Func radRestartClick()
	GUICtrlSetState($cboxComment, $GUI_ENABLE)
	GUICtrlSetState($cboxForceClose, $GUI_ENABLE)
	GUICtrlSetState($cboxPlanned, $GUI_ENABLE)
	GUICtrlSetState($cboxTimer, $GUI_ENABLE)
	cboxTimerClick()
	cboxCommentClick()
EndFunc   ;==>radRestartClick

Func radLogoffClick()
	GUICtrlSetState($cboxComment, $GUI_DISABLE)
	GUICtrlSetState($cboxForceClose, $GUI_DISABLE)
	GUICtrlSetState($cboxPlanned, $GUI_DISABLE)
	GUICtrlSetState($cboxTimer, $GUI_DISABLE)
	GUICtrlSetState($iComment, $GUI_DISABLE)
	GUICtrlSetState($iHours, $GUI_DISABLE)
	GUICtrlSetState($iMinutes, $GUI_DISABLE)
	GUICtrlSetState($iSeconds, $GUI_DISABLE)
EndFunc   ;==>radLogoffClick

Func cboxCommentClick()
	If (GUICtrlRead($cboxComment) == 1) Then
		GUICtrlSetState($iComment, $GUI_ENABLE)
	Else
		GUICtrlSetState($iComment, $GUI_DISABLE)
	EndIf
EndFunc   ;==>cboxCommentClick

Func cboxTimerClick()
	If (GUICtrlRead($cboxTimer) == 1) Then
		GUICtrlSetState($iHours, $GUI_ENABLE)
		GUICtrlSetState($iMinutes, $GUI_ENABLE)
		GUICtrlSetState($iSeconds, $GUI_ENABLE)
	Else
		GUICtrlSetState($iHours, $GUI_DISABLE)
		GUICtrlSetState($iMinutes, $GUI_DISABLE)
		GUICtrlSetState($iSeconds, $GUI_DISABLE)
	EndIf
EndFunc   ;==>cboxTimerClick

Func btnAbortClick()
	$CMD = "shutdown -a"
	RunWait(@ComSpec & " /c " & $CMD, @WindowsDir, @SW_SHOW)
EndFunc   ;==>btnAbortClick

Func btnAboutClick()
	MsgBox(0, "About", "Gonna edit this later~")
EndFunc   ;==>btnAboutClick

$CMD = ""

Func btnExecuteClick()
	If (GUICtrlRead($radShutdown) == 1) Then
		$CMD = "shutdown -s"
	ElseIf (GUICtrlRead($radRestart) == 1) Then
		$CMD = "shutdown -r"
	ElseIf (GUICtrlRead($radLogoff) == 1) Then
		$CMD = "shutdown -l"
		RunWait(@ComSpec & " /c " & $CMD, @WindowsDir, @SW_SHOW)
		Return 1
	Else
		MsgBox(0, "", "You haven't specified the action you're trying to execute.")
		Return 0
	EndIf

	If (GUICtrlRead($cboxForceClose) == 1) Then $CMD = $CMD & " -f"
	If (GUICtrlRead($cboxComment) == 1) Then $CMD = $CMD & ' -c "' & GUICtrlRead($iComment) & '"'
	If (GUICtrlRead($cboxTimer) == 1) Then $CMD = $CMD & " -t " & (60 * 60 * GUICtrlRead($iHours) + 60 * GUICtrlRead($iMinutes) + GUICtrlRead($iSeconds))
	If (GUICtrlRead($cboxPlanned) == 1) Then $CMD = $CMD & " -d p:0:0"

	RunWait(@ComSpec & " /c " & $CMD, @WindowsDir, @SW_SHOW)
	Return 1
EndFunc   ;==>btnExecuteClick
