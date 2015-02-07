/* 
	This code is written by orbik and others,
        I somewhat hacked it.
	
1. Try this just using the tool tip first, when that makes sense, comment the tool tip out
	
2. Then Uncomment the lines at 112 for sending text
		- TAKES A MIDI NOTE AND CONVERTS IT TO A KEYPRESS.
		- IT WILL SEND NOTE ON TEXT WHEN NOTE 60 (MIDILE c) AND
*/

;;"#defines"

; SET THIS DEVICEiD TO YOUR MIDI INPUT PORT, 0 IS THE FIRST MIDI PORT, 
; IF YOU DON'T KNOW THE MIDI PORT USE MIDIOX TO FIND OUT. 
DeviceID := 8 
CALLBACK_WINDOW := 0x10000

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

Gui, +LastFound
hWnd := WinExist()

;MsgBox, hWnd = %hWnd%`nPress OK to open winmm.dll library

OpenCloseMidiAPI()
OnExit, Sub_Exit

;MsgBox, winmm.dll loaded.`nPress OK to open midi device`nDevice ID = %DeviceID%`nhWnd = %hWnd%`ndwFlags = CALLBACK_WINDOW

hMidiIn =
VarSetCapacity(hMidiIn, 4, 0)

result := DllCall("winmm.dll\midiInOpen", UInt,&hMidiIn, UInt,DeviceID, UInt,hWnd, UInt,0, UInt,CALLBACK_WINDOW, "UInt")

	If result
	{
		MsgBox, error, midiInOpen returned %result%`n
		GoSub, sub_exit
	}

hMidiIn := NumGet(hMidiIn) ; because midiInOpen writes the value in 32 bit binary number, AHK stores it as a string


;MsgBox, Midi input device opened successfully`nhMidiIn = %hMidiIn%`n`nPress OK to start the midi device

result := DllCall("winmm.dll\midiInStart", UInt,hMidiIn)
If result
	{
		MsgBox, error, midiInStart returned %result%`n
		GoSub, sub_exit
	}


; #define MM_MIM_OPEN 0x3C1 /* MIDI input */
; #define MM_MIM_CLOSE 0x3C2
; #define MM_MIM_DATA 0x3C3
; #define MM_MIM_LONGDATA 0x3C4
; #define MM_MIM_ERROR 0x3C5
; #define MM_MIM_LONGERROR 0x3C6

OnMessage(0x3C1, "midiInHandler") ; calling the function below 
OnMessage(0x3C2, "midiInHandler")
OnMessage(0x3C3, "midiInHandler")
OnMessage(0x3C4, "midiInHandler")
OnMessage(0x3C5, "midiInHandler")
OnMessage(0x3C6, "midiInHandler")

return

;--------End of auto-execute section-----

; =============== this will exit the app when esc is pushed

sub_exit:

	If (hMidiIn)
	DllCall("winmm.dll\midiInClose", UInt,hMidiIn)
	OpenCloseMidiAPI()

	ExitApp



OpenCloseMidiAPI() ; calls the winmm.dll to close midi port
	{
		Static hModule
		If hModule
		DllCall("FreeLibrary", UInt,hModule), hModule := ""
		If (0 = hModule := DllCall("LoadLibrary",Str,"winmm.dll")) 
		{
			MsgBox Cannot load library winmm.dll
			ExitApp
		}
	}


midiInHandler(hInput, midiMsg, wMsg) ; THIS IS THE MIDI IN FUNCTION WHERE THE MIDI MESSAGE IS BROKEN UP 
{
	statusbyte 	:= midiMsg & 0xFF			; EXTRACT THE STATUS BYTE (WHAT KIND OF MIDI MESSAGE IS IT)
	chan 		:= (statusbyte & 0x0f) + 1	; WHAT MIDI CHANNEL IS THE MESSAGE ON?
	byte1 		:= (midiMsg >> 8) & 0xFF	; THIS IS DATA1 VALUE = NOTE NUMBER OR CC NUMBER
	byte2 		:= (midiMsg >> 16) & 0xFF	; DATA2 VALUE IS NOTE VELEOCITY OR CC VALUE


;THIS SECTION WILL SEND TEXT - OPEN NOTEPAD AND GIVE IT FOCUS WITH THIS RUNNING
;UNCOMMENT THIS SECTION BELOW TO HAVE THE midi note >TEXT ;SENT.

/*  
	If ((byte1 = 60) & (statusbyte = 144))  ; test note number and status for Note ON (144) and note number middle C
		{
			send, Note %byte1% on, 			; TYPES TEXT WITH THE NOTE NUMBER VAR.  
		}
		Else if ((byte1 = 60) & (statusbyte = 128)) ; test for note off
		{
			send, Note %byte1% off
		}
	
	; Just trying the same idea on a different note a differnt way
	If (byte1 = 62) ; test for note 62 - attempt at splitting the test up
		{
			if (statusbyte = 144) ; is the note above on?
			{
				send, Note %byte1% on 
			}
			Else if (statusbyte = 128) ; is the note off
			{
				send, Note %byte1% off 
			}
		}
*/

;AFTER YOU PLAY WITH THIS FOR A LITTLE WHILE AND SEE IT WORK COMMENT THIS OUT OR USE IT FOR KNOWING WHAT MESSAGES ARE DOING

;/*
ToolTip, ; THIS WILL SHOW A TOOL TIP OF THE MIDI DATA FROM EACH KEYPRESS OR CC PRESS.
(
Received a message: %wMsg%
wParam = %hInput%
lParam = %midiMsg%
statusbyte = %statusbyte%
chan = %chan%
byte1 = %byte1%
byte2 = %byte2%
)
; */ 

}
Return

Esc::GoSub, sub_exit

/*
below is written by orbik

My dll approach is a bit different. The idea was to have the dll call a specified window with messages specified separately for each input type, note/cc number and channel, and then only send messages where it's specified. And since I doubt the code tag would display c++ code properly, i put all relevant files to http://ihme.org/~orbik/midi4ahk/

Some parts of the scripts are borrowed from various fellow ahk users, and I wish I remembered who they were.
*/