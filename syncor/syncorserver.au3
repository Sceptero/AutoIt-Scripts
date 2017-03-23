#include <TCP.au3>
#include <Date.au3>
#include <Array.au3>
#include <String.au3>

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Opt("GUIOnEventMode", 1)
Opt("TrayIconHide", 1)
TraySetState(2)

Dim $ver = "2.0", $concounter = 0

#Region ### START Koda GUI section ### Form=d:\autoit3-scripts\syncor\syncorserver.kxf
$Form1_1 = GUICreate("Syncor Server v"&$ver, 385, 532, 265, 168)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form1Close")
$status = _GUICtrlStatusBar_Create($Form1_1)
_GUICtrlStatusBar_SetSimple($status)
_GUICtrlStatusBar_SetText($status, "")
$iURL = GUICtrlCreateInput("", 16, 400, 273, 21)
$btnLoad = GUICtrlCreateButton("LOAD", 20, 427, 153, 49)
GUICtrlSetOnEvent(-1, "btnLoadClick")
$lblTite = GUICtrlCreateLabel("Syncor Server v"&$ver, 78, 24, 229, 27, $SS_CENTER)
GUICtrlSetFont(-1, 14, 800, 0, "Tahoma")
$lblCopyright = GUICtrlCreateLabel("Copyright by peXu", 280, 488, 90, 17)
$btnPlay = GUICtrlCreateButton("START", 180, 427, 105, 25)
GUICtrlSetOnEvent(-1, "btnPlayClick")
$btnPause = GUICtrlCreateButton("PLAY/PAUSE", 180, 451, 105, 25)
GUICtrlSetOnEvent(-1, "btnPauseClick")
$iTime = GUICtrlCreateInput("0h0m0s", 296, 400, 65, 21)
$list = GUICtrlCreateList("", 39, 72, 313, 305, BitOR($LBS_NOTIFY,$WS_VSCROLL,$WS_BORDER))
GUICtrlSetOnEvent(-1, "listClick")
$btnUsers = GUICtrlCreateButton("USERS", 24, 480, 65, 17)
GUICtrlSetOnEvent(-1, "btnUsersClick")
$btnBC = GUICtrlCreateButton("BC", 105, 480, 65, 17)
GUICtrlSetOnEvent(-1, "btnBCClick")
$btnKick = GUICtrlCreateButton("KICK", 184, 480, 65, 17)
GUICtrlSetOnEvent(-1, "btnKickClick")
$btnExec = GUICtrlCreateButton("EXEC", 296, 440, 65, 25)
GUICtrlSetOnEvent(-1, "btnExecClick")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


$hServer = _TCP_Server_Create(88)

_TCP_RegisterEvent($hServer, $TCP_RECEIVE, "__Received")
_TCP_RegisterEvent($hServer, $TCP_NEWCLIENT, "__NewClient")
_TCP_RegisterEvent($hServer, $TCP_DISCONNECT, "__Disconnect")

#Region GUI EVENTS
Func btnLoadClick()
	local $tmp = GUICtrlRead($iURL)
	$tmp = _StringExplode($tmp,"?v=",1)
	$tmp = _StringExplode($tmp[1],"&",1)
	_TCP_Server_Broadcast("load#@#"&$tmp[0])
EndFunc

Func btnPauseClick()
	_TCP_Server_Broadcast("pause#@#")
EndFunc

Func btnPlayClick()
	_TCP_Server_Broadcast("play#@#")
EndFunc

Func btnKickClick()
	local $ans = InputBox("Kick User","Enter SocketID of user you want to kick","",Default,250,130)
	If (Number($ans)>0) Then
		_TCP_Server_DisconnectClient(Number($ans))
		status("Kicking user "&$ans)
	EndIf
EndFunc

Func btnExecClick()
	_TCP_Server_Broadcast("exec#@#")
EndFunc

Func btnUsersClick()
	local $arrusers = _TCP_Server_ClientList()
	_ArrayDisplay($arrusers,"Connected Users")
EndFunc

Func btnBCClick()
	local $msg = InputBox("MSG","Enter the message you want to broadcast",Default,Default,250,130)
	If (StringLen($msg)>0) Then _TCP_Server_Broadcast("msg#@#"&$msg)
EndFunc

Func listClick()
	GUICtrlSetData($iURL,GUICtrlRead($list))
EndFunc

Func Form1Close()
	_TCP_Server_Stop()
	Exit
EndFunc
#EndRegion

Func __Received($hSocket, $sReceived, $iError)
	status("Received data")
	$data = _StringExplode($sReceived,"#@#")
	Switch $data[0]
	Case "url"
		GUICtrlSetData($list,$data[1])
	Case "chat"
		_TCP_Server_Broadcast("chat#@#"&$data[1])
	Case Else
		status("Received unknown data: "&$data[0])
	EndSwitch
EndFunc

Func __NewClient($hSocket, $iError)
	$concounter += 1
	status("New client connected!")
EndFunc

Func __Disconnect($hSocket, $iError)
	$concounter -= 1
	status("Client disconnected!")
EndFunc

Func status($param)
	_GUICtrlStatusBar_SetText($status, _NowTime(5) & " >> " & $param)
EndFunc

While 1
	Sleep(100)
WEnd