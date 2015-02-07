#SingleInstance force
SendMode Input
SetWorkingDir %A_ScriptDir% 

OnExit, sub_exit
if (midi_in_Open(0))
	ExitApp
Menu TRAY, Icon, icon4.ico

;--------------------  Midi "hotkey" mappings  -----------------------
listenNoteRange(48, 52, "playSomeSounds", 0x02)

return
;----------------------End of auto execute section--------------------

sub_exit:
	midi_in_Close()
ExitApp

;-------------------------Miscellaneous hotkeys-----------------------
Esc::ExitApp

;-------------------------Midi "hotkey" functions---------------------
playSomeSounds(note, vel)
{
	if (vel) ; vel == 0 means note off
	{
		SoundPlay drum%note%.wav
	}
}

;-------------------------  Midi input library  ----------------------
#include midi_in_lib.ahk
