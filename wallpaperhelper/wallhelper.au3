#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#include <Array.au3>
#include <File.au3>
#include <ExtProp.au3>

Opt("GUIOnEventMode", 1)

Dim $programName = "Wallpaper Helper v 1.0"

Global $folder = '', $filter = 1, $action = 1, $resX, $resY, $resRatio

#Region ### START Koda GUI section ### Form=d:\autoit3-scripts\wallpaperhelper\wallhelper.kxf
$formMain = GUICreate($programName, 426, 362, 192, 124)
GUISetOnEvent($GUI_EVENT_CLOSE, "formMainClose")
$inputFolderDir = GUICtrlCreateInput("", 16, 48, 313, 25)
GUICtrlSetState($inputFolderDir, $GUI_DISABLE)
GUICtrlSetOnEvent($inputFolderDir, "inputFolderDirChange")
$buttonSelectFolder = GUICtrlCreateButton("Select Folder", 336, 48, 75, 25)
GUICtrlSetOnEvent($buttonSelectFolder, "buttonSelectFolderClick")
$inputResX = GUICtrlCreateInput("", 74, 120, 121, 21)
GUICtrlSetOnEvent($inputResX, "inputResXChange")
$lblConst1 = GUICtrlCreateLabel("Folder with wallpapers:", 16, 24, 111, 17)
$lblConst2 = GUICtrlCreateLabel("Your screen resolution:", 16, 96, 112, 17)
$lblConst6 = GUICtrlCreateLabel("x", 210, 120, 9, 17)
$inputResY = GUICtrlCreateInput("", 234, 120, 121, 21)
GUICtrlSetOnEvent($inputResY, "inputResYChange")
$lblConst3 = GUICtrlCreateLabel("Aspect Ratio:", 136, 152, 150, 17)
$lblAspectRatio = GUICtrlCreateLabel("", 208, 152, 50, 21)
$GroupFilter = GUICtrlCreateGroup("  Select wallpapers with same:  ", 8, 192, 193, 105)
$radioFilterRatio = GUICtrlCreateRadio("Aspect Ratio and >= Res", 18, 264, 150, 17)
GUICtrlSetOnEvent($radioFilterRatio, "radioFilterRatioClick")
$radioFilterRes = GUICtrlCreateRadio("Resolution", 18, 240, 150, 17)
GUICtrlSetOnEvent($radioFilterRes, "radioFilterResClick")
$radioFilterBoth = GUICtrlCreateRadio("Res and bigger", 18, 216, 150, 17)
GUICtrlSetState($radioFilterBoth, $GUI_CHECKED)
GUICtrlSetOnEvent($radioFilterBoth, "radioFilterBothClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$GroupAction = GUICtrlCreateGroup("  Action:  ", 224, 192, 193, 105)
$radioActionRemoveNotMatching = GUICtrlCreateRadio("Remove not matching", 234, 264, 150, 17)
GUICtrlSetOnEvent($radioActionRemoveNotMatching, "radioActionRemoveNotMatchingClick")
$radioActionMoveMatching = GUICtrlCreateRadio("Move matching to new folder", 234, 216, 161, 17)
GUICtrlSetState($radioActionMoveMatching, $GUI_CHECKED)
GUICtrlSetOnEvent($radioActionMoveMatching, "radioActionMoveMatchingClick")
$radioMoveNotMatching = GUICtrlCreateRadio("Move not matching to new folder", 234, 240, 177, 17)
GUICtrlSetOnEvent($radioMoveNotMatching, "radioMoveNotMatchingClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$btnRun = GUICtrlCreateButton("RUN", 151, 312, 123, 41)
GUICtrlSetOnEvent($btnRun, "btnRunClick")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Main()

While 1
	Sleep(100)
WEnd

#Region GUI Events
Func buttonSelectFolderClick()
	$folder = FileSelectFolder("Select folder with your wallpapers.",GUICtrlRead($inputFolderDir),0,GUICtrlRead($inputFolderDir))
	If ($folder <> '') Then GUICtrlSetData($inputFolderDir,$folder)
EndFunc

Func formMainClose()
	Exit
EndFunc

Func inputFolderDirChange()
	$folder = GUICtrlRead($inputFolderDir)
	If Not FileExists($folder) Then
		MsgBox(0,$programName,"Invalid path.")
		buttonSelectFolderClick()
	EndIf
	If (StringRight($folder,1) == "\") Then GUICtrlSetData($inputFolderDir,StringTrimRight($folder,1))
EndFunc

Func inputResXChange()
	$resX = GUICtrlRead($inputResX)
	$resRatio = $resX/$resY
	GUICtrlSetData($lblAspectRatio,$resRatio)
EndFunc

Func inputResYChange()
	If (GUICtrlRead($inputResY) = 0) Then
		MsgBox(0,$programName,"Invalid resolution.")
		GUICtrlSetData($inputResY,@DesktopHeight)
	EndIf
	$resY = GUICtrlRead($inputResY)
	$resRatio = $resX/$resY
	GUICtrlSetData($lblAspectRatio,$resRatio)
EndFunc

Func radioActionMoveMatchingClick()
	$action = 1
EndFunc

Func radioActionRemoveNotMatchingClick()
	$action = 3
EndFunc

Func radioFilterBothClick()
	$filter = 1
EndFunc

Func radioFilterRatioClick()
	$filter = 3
EndFunc

Func radioFilterResClick()
	$filter = 2
EndFunc

Func radioMoveNotMatchingClick()
	$action = 2
EndFunc

#EndRegion

Func Main()
	$resX = @DesktopWidth
	$resY = @DesktopHeight
	$resRatio = $resX/$resY
	GUICtrlSetData($inputResX,$resX)
	GUICtrlSetData($inputResY,$resY)
	GUICtrlSetData($lblAspectRatio,$resRatio)
EndFunc

Func btnRunClick()
	If ($folder <> '') Then
		Local $wallpapersList = _FileListToArrayRec($folder, "*.png;*.jpg;*.jpeg;*.bmp",1,Default,Default,0)
		If (@error==1 And @extended == 9) Then
			MsgBox(0,$programName,"No wallpapers found in specified folder.")
			Return
		EndIf

		Local $wallpapersCount = $wallpapersList[0]

		Local $matchingList[0]
		Local $notMatchingList[0]

		For $i = 1 To $wallpapersCount
			Local $info = StringSplit(StringStripWS(_GetExtProperty($folder&"\"&$wallpapersList[$i],31),8),"x",2)
			Local $infoX = Number(StringTrimLeft($info[0],1))
			Local $infoY = Number(StringTrimRight($info[1],1))
			Local $infoRatio = $infoX/$infoY

			Switch $filter
				Case 1 ; Bigger than specified resolution
					If (($infoX>=$resX) And ($infoY>=$resY)) Then
						_ArrayAdd($matchingList,$wallpapersList[$i])
					Else
						_ArrayAdd($notMatchingList,$wallpapersList[$i])
					EndIf
				Case 2 ; Bigger than specified resolution but with same aspect ratio
					If (($infoRatio==$resRatio) And ($infoX>=$resX) And ($infoY>=$resY)) Then
						_ArrayAdd($matchingList,$wallpapersList[$i])
					Else
						_ArrayAdd($notMatchingList,$wallpapersList[$i])
					EndIf
				Case 3 ; Exact same resolution
					If (($infoX==$resX) And ($infoY==$resY)) Then
						_ArrayAdd($matchingList,$wallpapersList[$i])
					Else
						_ArrayAdd($notMatchingList,$wallpapersList[$i])
					EndIf
			EndSwitch
		Next

		Switch $action
			Case 1 ; Move matching to new folder
				Local $newDir = $folder&"\[WallHelper] Matching"
				DirCreate($newDir)
				Local $arraySize = UBound($matchingList)
				For $i = 0 To $arraySize-1
					FileMove($folder&"\"&$matchingList[$i],$newDir&"\"&$matchingList[$i])
				Next
			Case 2 ; Move not matching to new folder
				Local $newDir = $folder&"\[WallHelper] Not Matching"
				DirCreate($newDir)
				Local $arraySize = UBound($notMatchingList)
				For $i = 0 To $arraySize-1
					FileMove($folder&"\"&$notMatchingList[$i],$newDir&"\"&$notMatchingList[$i])
				Next
			Case 3 ; Remove not matching
				Local $arraySize = UBound($notMatchingList)
				For $i = 0 To $arraySize-1
					FileDelete($folder&"\"&$notMatchingList[$i])
				Next
		EndSwitch

		MsgBox(0,$programName,"Done.")

	Else
		MsgBox(0,$programName,"No folder specified.")
	EndIf
EndFunc
