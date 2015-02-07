SendMode Input 
SetWorkingDir %A_ScriptDir% 

OnExit, sub_exit 
if (midi_in_Open(0)) 
   ExitApp 

;--------------------  Midi "hotkey" mappings  ----------------------- 
listenNote(55, "space") 

listenNote(60, "note60") 
listenNote(62, "note62") 
listenNote(63, "note63") 
listenNote(64, "note64") 

return 
;----------------------End of auto execute section-------------------- 

sub_exit: 
   midi_in_Close() 
ExitApp 

;-------------------------Miscellaneous hotkeys----------------------- 
Esc::ExitApp 

;-------------------------Midi "hotkey" functions--------------------- 
space(note, vel) 
{ 
	if (vel)
	Send {Space down}
	else
	Send {Space up}
} 

note60(note, vel) 
{ 
   if (vel)
   Send {Left down}
   else
   Send {Left up}
} 
note62(note, vel) 
{ 
   if (vel)
   Send {Down down}
   else
   Send {Down up}
} 
note63(note, vel) 
{ 
   if (vel)
   Send {Up down}
   else
   Send {Up up}
} 
note64(note, vel) 
{ 
   if (vel)
   Send {Right down}
   else
   Send {Right up}
} 

;-------------------------  Midi input library  ---------------------- 
#include midi_in_lib.ahk