#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui +LastFound
hWnd := WinExist()

OpenCloseMidiDLL()
OnExit, Sub_Exit

result := DllCall("midi_in.dll\open", UInt,hWnd, Int,0, Int)
If result
{
	MsgBox, midi_in.dll\open(%hWnd%, %0%) returned:`n%result%
	GoSub, Sub_Exit
}

DllCall("midi_in.dll\listenWheel", Int,0, Int,0x1000)
OnMessage(0x1000, "PitchWheel")
OnMessage(0x200, "RemoveToolTip") ; WM_MOUSEMOVE

DllCall("midi_in.dll\start")

return
;--------End of auto-execute section-----
;----------------------------------------

sub_exit:
OpenCloseMidiDLL()
ExitApp
return ; unnecessary redundancy?

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return


OpenCloseMidiDLL() {
   Static hModule 
   If hModule 
      DllCall("FreeLibrary", UInt,hModule), hModule := "" 
   If (0 = hModule := DllCall("LoadLibrary",Str, A_ScriptDir . "\midi_in.dll")) { 
      MsgBox Cannot load library midi_in.dll 
      ExitApp
   } 
} 


PitchWheel(wParam)
{
	ToolTip, %wParam%
	SetTimer, RemoveToolTip, 100
}

Esc::GoSub, sub_exit

^.::
	value := DllCall("midi_in.dll\getChanAT", Int,1, Int)
	MsgBox, getChanAT(1) returned %value%

return