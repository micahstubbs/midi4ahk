SendMode Input 
SetWorkingDir %A_ScriptDir% 

OnExit, sub_exit 
if (midi_in_Open(0)) 
   ExitApp 

;--------------------  Midi "hotkey" mappings  ----------------------- 
listenNote(55, "space") 

listenNote(36, "note36") 
listenNote(37, "note37") 
listenNote(38, "note38") 
listenNote(39, "note39") 
listenNote(40, "note40") 
listenNote(41, "note41") 
listenNote(42, "note42") 
listenNote(43, "note43") 
listenNote(44, "note44") 
listenNote(45, "note45") 
listenNote(46, "note46") 
listenNote(47, "note47") 
listenNote(48, "note48") 
listenNote(49, "note49") 
listenNote(50, "note50") 
listenNote(51, "note51") 
listenNote(52, "note52") 
listenNote(53, "note53") 
listenNote(54, "note54") 
listenNote(55, "note55") 
listenNote(56, "note56") 
listenNote(57, "note57") 
listenNote(58, "note58") 
listenNote(59, "note59") 
listenNote(60, "note60") 
listenNote(61, "note61") 
listenNote(62, "note62") 
listenNote(63, "note63") 
listenNote(64, "note64") 
listenNote(65, "note65") 
listenNote(66, "note66") 
listenNote(67, "note67") 
listenNote(68, "note68") 
listenNote(69, "note69") 
listenNote(70, "note70") 
listenNote(71, "note71") 
listenNote(72, "note72") 
listenNote(73, "note73") 
listenNote(74, "note74") 
listenNote(75, "note75") 
listenNote(76, "note76") 
listenNote(77, "note77") 
listenNote(78, "note78") 
listenNote(79, "note79") 
listenNote(80, "note80") 
listenNote(81, "note81") 
listenNote(82, "note82") 
listenNote(83, "note83") 
listenNote(84, "note84") 

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

note36(note, vel) 
{ 
   if (vel)
   Send {Enter}{Tab 2}THE WITNESS:*.{Space 2}
   ;else
   ;Send {}
} 

note38(note, vel)
{
if (vel)
Send {Enter}{Tab 2}THE COURT:*.{Space 2}
}


note40(note, vel)
{
	if (vel)
	Send {Enter}{Tab 2}ATTY A:*.{Space 2}
}


note41(note, vel)
{
	if (vel)
	Send {Enter}{Tab 2}ATTY B:*.{Space 2} 
}


note43(note, vel)
{
	if (vel)
	Send {Enter}{Tab 2}ATTY C:*.{Space 2} 
}

note45(note, vel)
{
	if (vel)
	Send {Enter}{Tab 2}ATTY D:*.{Space 2} 
}

note47(note, vel)
{
	if (vel)
	Send {Enter} {Tab 2}BY ATTY A:*.  
}

note48(note, vel)
{
	if (vel)
	Send {Enter}{Tab 2}BY ATTY B:*.
}

note50(note, vel)
{
	if (vel)
	Send {Enter} {Tab 2}BY ATTY C:*.
}

note52(note, vel)
{
	if (vel)
	Send {Enter} {Tab 2}BY ATTY D:*.
}

note53(note, vel)
{
	if (vel)
	Send {Enter} {Tab 2} Q:*.  
}

note55(note, vel)
{
	if (vel)
	Send {Enter} {Tab 2} A:*.
}

note57(note, vel)
{
	if (vel)
	Send .  {Enter} {Tab 2}Q:*.
}

note59(note, vel)
{
	if (vel)
	Send ?  {Enter} {Tab 2}Q:*.
}


;-------------------------  Midi input library  ---------------------- 
#include midi_in_lib.ahk