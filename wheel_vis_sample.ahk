;
; AutoHotkey Version: 1.0.47.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Dabbler, edit from stuff by ribbet.1 and  others
;
; Script Function:
; Reads values from wheel and CC1 and displays them as progressbars
;	midi in, select device from shortcut menu, needs midi_in_lib.ahk and midi_in.dll in folder
; 
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance, Force

Gui, -Caption +Border  +ToolWindow
Gui, Color, EEAA99
Gui, +LastFound
WinSet, TransColor, EEAA99
Gui, Add, Progress,      w384 h10 cBlue -0x1 Range0-127 vbar_X  ; value goes upto 127, bar length is 384
Gui, Add, Progress, x+10 w384 h10 cRed   -0x1 Range0-16384 vbar_Y ; value goes upto 16384 (my CC1 controller's output), bar length is 384
Gui, Show, x5 y707 , W_Meter                  ; position and show, Adjust X & Y to suit your screen res

OnExit, sub_exit
if (midi_in_Open(0))
   ExitApp

;--------------------  Midi "hotkey" mappings  -----------------------

listenCC(1, "do_cc_one", 0)
listenWheel("do_wheel", 0)
return
;----------------------End of auto execute section--------------------

sub_exit:
   midi_in_Close()
ExitApp

;-------------------------Miscellaneous hotkeys-----------------------
Esc::ExitApp

;----------------------------------------------
;experiment

do_cc_one(ccnumber, ccvel)
{
   if (ccvel)
   {
left_bar :=  ccvel
GuiControl,, bar_X, %left_bar%
;    ccvel is the value
    
   }
}


do_wheel(wheelin)
{
right_bar :=  wheelin
GuiControl,, bar_Y, %right_bar%
;    wheelin is the value
    
}
;-------------------------  Midi input library  ----------------------
#include midi_in_lib.ahk