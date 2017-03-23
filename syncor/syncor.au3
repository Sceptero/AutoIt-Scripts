#include <TCP.au3>
#include <Date.au3>
#include <String.au3>
#include <Misc.au3>
#include <IE.au3>

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Opt("GUIOnEventMode", 1)
Opt("TrayIconHide", 1)
Opt("WinTitleMatchMode", -2)
TraySetState(2)


Dim $ver = "2.0", $nick = "Anon", $oIE = Null
Dim $v = "XcUHHUXaD-I"
Dim $params = "?rel=0&autoplay=1&autohide=1&controls=1&showinfo=0&vq=hd720&cc_load_policy=0&iv_load_policy=3&modestbranding=1"


Dim $HOST_NAME = "" ; hostname of server
Dim $INI_URL = "" ; url of ini file with latest version number for checks

#Region ### START Koda GUI section ### Form=d:\autoit3-scripts\syncor\syncor.kxf
$Form1_1 = GUICreate("Syncor v"&$ver, 769, 365, 256, 262)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form1Close")
$status = _GUICtrlStatusBar_Create($Form1_1)
_GUICtrlStatusBar_SetSimple($status)
_GUICtrlStatusBar_SetText($status, "")
$iURL = GUICtrlCreateInput("", 584, 152, 161, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
$btnRequest = GUICtrlCreateButton("REQUEST", 588, 187, 153, 49)
GUICtrlSetOnEvent(-1, "btnRequestClick")
GUICtrlSetState(-1, $GUI_DISABLE)
$lblTite = GUICtrlCreateLabel("Syncor v"&$ver, 303, 8, 162, 27, $SS_CENTER)
GUICtrlSetFont(-1, 14, 800, 0, "Tahoma")
$lblCopyright = GUICtrlCreateLabel("Copyright by peXu", 672, 320, 90, 17)
$lblYouTube = GUICtrlCreateLabel("YouTube URL", 602, 112, 133, 27, $SS_CENTER)
GUICtrlSetFont(-1, 14, 800, 0, "Tahoma")
$iChat = GUICtrlCreateInput("", 88, 312, 473, 21)
GUICtrlSetLimit(-1, 255)
GUICtrlSetState(-1, $GUI_DISABLE)
$btnNick = GUICtrlCreateButton("SET NICK", 8, 312, 73, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "btnNickClick")
$Edit1 = GUICtrlCreateEdit("", 16, 40, 545, 265, BitOR($ES_READONLY,$ES_WANTRETURN,$WS_HSCROLL))
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

$hClient = _TCP_Client_Create(TCPNameToIP($HOST_NAME), 88)
_TCP_RegisterEvent($hClient, $TCP_RECEIVE, "__Received")
_TCP_RegisterEvent($hClient, $TCP_CONNECT, "__Connected")
_TCP_RegisterEvent($hClient, $TCP_DISCONNECT, "__Disconnected")

$ver2 = _StringExplode(BinaryToString(InetRead($INI_URL)),@CRLF)
If (Number($ver2[1])>Number($ver)) Then
	MsgBox(0,"Update","New version ("&$ver2[1]&") available."&@CRLF&"Client will now update.")
	Run("SyncorUpdater.exe -update")
	Form1Close()
EndIf

Func __Connected($hSocket, $iError)
	If not $iError Then
		status("Connected to server")
		GUICtrlSetState($btnRequest, $GUI_ENABLE)
		GUICtrlSetState($iURL, $GUI_ENABLE)
		GUICtrlSetState($btnNick, $GUI_ENABLE)
		GUICtrlSetState($iChat, $GUI_ENABLE)
		$hServer = $hSocket
	Else
		status("Can't connect to server")
		sleep(1000)
		_TCP_Client_Stop($hClient)
		_Connect()
	EndIf
EndFunc

Func __Received($hSocket, $sReceived, $iError)
	status("Received data")
	$data = _StringExplode($sReceived,"#@#")
	Switch $data[0]
	Case "msg"
		MsgBox(0,"Broadcast",$data[1])
	Case "load"
		If ($oIE<>Null) Then FormPlayerClose()
		$v = $data[1]
		Global $oIE = _IECreateEmbedded()
		Global $FormPlayer = GUICreate("Syncor Player", 853, 480)
		GUISetOnEvent($GUI_EVENT_CLOSE, "FormPlayerClose")
		Global $GUIActiveX = GUICtrlCreateObj($oIE, 0, 0, 853, 480)

		_IENavigate($oIE, "about:blank")

		$oIE.document.body.scroll = "no"
		$oIE.document.body.style.margin = "0"
		$oIE.document.body.style.padding = "0"

		_IEBodyWriteHTML($oIE, '<iframe id="yt" width="853" height="480" src="https://www.youtube.com/embed/'&$v&$params&'" frameborder="0" allowfullscreen></iframe>')
		GUISetState(@SW_SHOW,$FormPlayer)

		sleep(5000)
		ControlClick("Syncor Player","","[CLASS:MacromediaFlashPlayerActiveX; INSTANCE:1]","left",1,100,100)

	Case "play"
		If WinExists("Syncor Player") Then
			sleep(1000)
			ControlSend("Syncor Player","","[CLASS:MacromediaFlashPlayerActiveX; INSTANCE:1]","{home}")
			sleep(500)
			ControlSend("Syncor Player","","[CLASS:MacromediaFlashPlayerActiveX; INSTANCE:1]","{space}")
		EndIf
	Case "pause"
		If WinExists("Syncor Player") Then
			ControlSend("Syncor Player","","[CLASS:MacromediaFlashPlayerActiveX; INSTANCE:1]","{space}")
		EndIf
	Case "chat"
		local $tmp = GUICtrlRead($Edit1)
		local $arr = _StringExplode($tmp,@CRLF)
		If (UBound($arr)==18) Then
			$arr = _StringExplode($tmp,@CRLF,1)
			GUICtrlSetData($Edit1,$arr[1]&$data[1]&@CRLF)
		Else
			GUICtrlSetData($Edit1,$tmp&$data[1]&@CRLF)
		EndIf
	Case "exec"
		; exec
	Case Else
		status("Received unknown data")
	EndSwitch
EndFunc

Func __Disconnected($hSocket, $iError)
	status("Connection lost or closed")
	GUICtrlSetState($btnRequest, $GUI_DISABLE)
	GUICtrlSetState($iURL, $GUI_DISABLE)
	GUICtrlSetState($btnNick, $GUI_DISABLE)
	GUICtrlSetState($iChat, $GUI_DISABLE)
	_TCP_Client_Stop($hClient)
	_Connect()
EndFunc

Func _Connect()
$hClient = _TCP_Client_Create(@IPAddress1, 88)
_TCP_RegisterEvent($hClient, $TCP_RECEIVE, "__Received")
_TCP_RegisterEvent($hClient, $TCP_CONNECT, "__Connected")
_TCP_RegisterEvent($hClient, $TCP_DISCONNECT, "__Disconnected")
EndFunc

Func status($param)
	_GUICtrlStatusBar_SetText($status, _NowTime(5) & " >> " & $param)
EndFunc

#Region GUI EVENTS
Func btnRequestClick()
	If (StringLen(GUICtrlRead($iURL))>0) Then _TCP_Send($hClient,"url#@#"& GUICtrlRead($iURL))
EndFunc

Func btnNickClick()
	local $ans = InputBox("Set Nickname","Enter your new nickname",Default,Default,250,130)
	If (StringLen($ans)>10 Or StringLen($ans)<1) Then
		status("Nickname has to be 1-10 characters long")
	Else
		$nick = $ans
		GUICtrlSetData($btnNick,$nick)
	EndIf
EndFunc

Func Form1Close()
	_TCP_Client_Stop($hClient)
	Exit
EndFunc

Func FormPlayerClose()
	GUIDelete($FormPlayer)
	$oIE = Null
EndFunc
#EndRegion

While 1
	Sleep(10)
	If (WinActive($Form1_1) And _IsPressed("0D")) Then
		Switch ControlGetFocus($Form1_1)
		Case "Edit1" ; request
			btnRequestClick()
		Case "Edit2" ; chat
			If (StringLen(GUICtrlRead($iChat))>0) Then
				_TCP_Send($hClient,"chat#@#"&$nick&": "&GUICtrlRead($iChat))
				GUICtrlSetData($iChat,"")
			EndIf
		EndSwitch

		While _IsPressed("0D")
			sleep(10)
		WEnd
	EndIf
WEnd