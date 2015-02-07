#include <windows.h>
#include <stdio.h>
#include "midi_in.h"

#define DEVNAME_BUFFER_SIZE 100
#define DEVNAME_NONE "No input"

const int isBlackKey[12] = {0,1,0,1,0,0,1,0,1,0,1,0};

HMIDIIN hMidiIn = NULL;
HWND hTargetWindow = NULL;
int curDevID = -1;
char curDevName[DEVNAME_BUFFER_SIZE] = DEVNAME_NONE;
char namebuf[DEVNAME_BUFFER_SIZE];

// Every element of these arrays is a message
// number to send to the target window

UINT ruleNoteOn[128][16];
UINT ruleNoteOff[128][16];
UINT ruleCC[128][16];
UINT ruleWheel[16];
UINT ruleAT[16];

int minControllerDataInterval=5;

int noteDown[128][16];
int ccValue[128][16];
int wheelValue[16];
int chanATValue[16];

//#define DEBUG
#ifdef DEBUG
void debug_output(char* string, int value1, int value2) {
	char buffer[4000];
	sprintf(buffer, string, value1, value2);
	MessageBox(0,buffer,"debug output from midi_in.dll", MB_OK);
}
#endif
BOOL WINAPI DllMain( HANDLE hinstDLL, DWORD dwReason, LPVOID lpvReserved) {
	switch (dwReason) {
		case DLL_PROCESS_ATTACH:
			removeAllListeners();
			break;

		case DLL_PROCESS_DETACH:
			stop();
			close();
	}
	return TRUE;
}

void CALLBACK midiInProc(HMIDIIN handle, UINT wMsg, DWORD dwInstance, DWORD midi_message, DWORD midi_timestamp) {
	BYTE statusbyte, byte2, byte3;
	UINT outMsg;
	if (wMsg == MIM_DATA) {
		statusbyte = (midi_message & 0x0000FF);
		byte2      = (midi_message & 0x007F00)>>8;
		byte3      = (midi_message & 0x7F0000)>>16;
		if (statusbyte > 0xEF) return; // status >= 0xF0 are machine control codes, sysex etc..
		int channel = statusbyte & 0x0f;
#ifdef DEBUG
//		debug_output("callback function called\nmidi_message = %x\nbyte2 = %i", midi_message, byte2);
#endif

		switch (statusbyte & 0xf0) {
			// note off
			case 0x80:
case0x80: // goto statement is 10 lines down.

				noteDown[byte2][channel] = 0;
				if (outMsg = ruleNoteOff[byte2][channel])
					// wParam = note number, lParam = velocity
					PostMessage(hTargetWindow, outMsg, byte2, byte3);
				break;

			// note on
			case 0x90:
				if (byte3 == 0) goto case0x80; 
				noteDown[byte2][channel] = byte3;
				if (outMsg = ruleNoteOn[byte2][channel])
					// wParam = note number, lParam = velocity
					PostMessage(hTargetWindow, outMsg, byte2, byte3);
				break;

			// control change
			case 0xB0:
				ccValue[byte2][channel] = byte3;
				if (outMsg = ruleCC[byte2][channel])
					// wParam = cc number, lParam = cc value
					PostMessage(hTargetWindow, outMsg, byte2, byte3);
				break;

			// channel aftertouch
			case 0xD0:	
				chanATValue[channel] = byte2;
				if (outMsg = ruleAT[channel])
					// wParam = ChanAT value
					PostMessage(hTargetWindow, outMsg, byte2, 0);
				break;

			// pitch wheel
			case 0xE0:	
				wheelValue[channel] = (byte3 << 7) | byte2;
				if (outMsg = ruleWheel[channel])
					// wParam = pitch wheel value
					PostMessage(hTargetWindow, outMsg, wheelValue[channel], 0);
				break;
		}
	}
	return;
}

extern "C" {
DLLEXPORT int open(HWND hWnd, int deviceID) {
	MMRESULT result;
	if (hWnd == NULL) 
		return 50;
	else hTargetWindow = hWnd;

	if (hMidiIn != NULL)
		return 60;

	if ((result = midiInOpen(&hMidiIn, deviceID, (DWORD_PTR)midiInProc, 0, CALLBACK_FUNCTION)) != MMSYSERR_NOERROR)
		return result;

	curDevID = deviceID;
	strcpy_s(curDevName, DEVNAME_BUFFER_SIZE, getDevName(curDevID));

	return 0;
}

DLLEXPORT int close() {
	if (hMidiIn) {
		MMRESULT result = midiInClose(hMidiIn);
		if (result)
			return result;
		else
			hMidiIn = NULL;
	}

	curDevID = -1;
	strcpy_s(curDevName, DEVNAME_BUFFER_SIZE, DEVNAME_NONE);

	return 0;
}
DLLEXPORT void stop() {
	if (hMidiIn)
		midiInStop(hMidiIn);
}
DLLEXPORT void start() {
#ifdef DEBUG
	debug_output("start() called\nhMidiIn = %x", (int)hMidiIn,0);
#endif
	if (hMidiIn)
		midiInStart(hMidiIn);
}



/*
  	listenNoteOnOff(rangeStart, rangeEnd, msgNumber, modeFlags=0x18, channel=0)
		
		wParam - note number
		lParam - velocity (0x00 - 0x7F)

		rangeStart, rangeEnd
			(0x00 - 0x7F)
	
		msgNumber
			the (first) message number to be captured with OnMessage()

		modeFlags (default = 0)
			& 0x01 - use increasing msgNumbers for subsequent notes, where every note increments msgNumber by either 1 or 2 (see flag 0x08)
				If disabled, NoteOffs make velocity=0
			& 0x02 - ignore black keys on note range
			& 0x04 - ignore white keys on note range

			(& 0x08) - sends NoteOffs to msgNumber 1 higher than the corresponding NoteOn (NoteOn vel=0 -> NoteOff)
				If disabled, send both NoteOn and NoteOff to same msgNumber, (NoteOff -> NoteOn vel=0)
			(& 0x10) - uses relative note numbering for wParam inside the range if flag 0x01 is not used

		channel
			if 0, listen to all channels (default), otherwise 1-16


		Returns:
			0 - success
			1 - bad note range
			2 - bad channel

*/
DLLEXPORT int listenNoteRange(int rangeStart, int rangeEnd, int modeFlags, int channel, int msgNumber) {
	int firstMsgNumber = msgNumber;
	if (rangeStart > 127 || rangeStart < 0 || rangeEnd > 127 || rangeEnd < 0 || rangeStart > rangeEnd)
		return -1;

	if (channel < 0 || channel > 16)
		return -2;

	if ((modeFlags & 0x06) == 0x06)
		return 0;

	int blackKeyCounter = rangeStart % 12;

	for (int currNote = rangeStart; currNote <= rangeEnd; currNote++, blackKeyCounter++) {
		if (blackKeyCounter > 11) blackKeyCounter -= 12;
		if ((modeFlags & 0x02) && isBlackKey[blackKeyCounter]) continue;
		else if ((modeFlags & 0x04) && !isBlackKey[blackKeyCounter]) continue;

		if (channel == 0) for (int i=0; i<16; i++) {
			ruleNoteOn[currNote][i] = msgNumber;
			ruleNoteOff[currNote][i] = msgNumber;
		}
		else {
			ruleNoteOn[currNote][channel-1] = msgNumber;
			ruleNoteOff[currNote][channel-1] = msgNumber;
		}

		if (modeFlags & 0x01) msgNumber++;
	}
	return msgNumber - firstMsgNumber + 1;
}

DLLEXPORT int listenNote(int noteNumber, int channel, int msgNumber) {
	if (noteNumber < 0 || noteNumber > 127)
		return -1;
	if (channel < 0 || channel > 16)
		return -2;

	if (channel == 0) for (int i=0; i<16; i++) {
		ruleNoteOn[noteNumber][i] =
		ruleNoteOff[noteNumber][i] = msgNumber;
	}
	else {
		ruleNoteOn[noteNumber][channel-1] =
		ruleNoteOff[noteNumber][channel-1] = msgNumber;
	}

	return 0;
}

DLLEXPORT int listenCC(int ccNumber, int channel, int msgNumber) {
	if (ccNumber < 0 || ccNumber > 127)
		return -1;
	if (channel < 0 || channel > 16)
		return -2;

	if (channel == 0) for (int i=0; i<16; i++)
		ruleCC[ccNumber][i] = msgNumber;
	else
		ruleCC[ccNumber][channel-1] = msgNumber;
	return 0;
}

DLLEXPORT int listenWheel(int channel, int msgNumber) {
	if (channel < 0 || channel > 16)
		return -2;

	if (channel == 0) for (int i=0; i<16; i++)
		ruleWheel[i] = msgNumber;
	else
		ruleWheel[channel-1] = msgNumber;
	return 0;
}                                                  

DLLEXPORT int listenChanAT(int channel, int msgNumber) {
	if (channel < 0 || channel > 16)
		return -2;

	if (channel == 0) for (int i=0; i<16; i++)
		ruleAT[i] = msgNumber;
	else
		ruleAT[channel-1] = msgNumber;
	return 0;
}

	DLLEXPORT void removeAllListeners() {
		for (int j=0; j<16; j++) {
			for (int i=0; i<128; i++) {
				ruleNoteOn[i][j]=0;
				ruleNoteOff[i][j]=0;
				ruleCC[i][j]=0;
				noteDown[i][j]=0;
				ccValue[i][j]=0;
			}
			ruleWheel[j]=0;
			ruleAT[j]=0;
			wheelValue[j]=0;
			chanATValue[j]=0;
		}

	}

	DLLEXPORT void setMinInterval(int minInterval) {
		minControllerDataInterval = minInterval;
	}

	DLLEXPORT int getNoteOn(int noteNumber, int channel) {
		if (noteNumber < 0 || noteNumber > 127) return -1;
		if (channel < 1 || channel > 16) return -2;
		return noteDown[noteNumber][channel-1];
	}
	DLLEXPORT int getCC(int ccNumber, int channel) {
		if (ccNumber < 0 || ccNumber > 127) return -1;
		if (channel < 1 || channel > 16) return -2;
		return ccValue[ccNumber][channel-1];
	}
	DLLEXPORT int getWheel(int channel) {
		if (channel < 1 || channel > 16) return -2;
		return wheelValue[channel-1];
	}
	DLLEXPORT int getChanAT(int channel) {
		if (channel < 1 || channel > 16) return -2;
		return chanATValue[channel-1];
	}

	DLLEXPORT int getNumDevs() {
		return midiInGetNumDevs();
	}

	DLLEXPORT char* getDevName(int deviceID) {
		MIDIINCAPS caps;

		MMRESULT result = midiInGetDevCaps(deviceID, &caps, sizeof(caps));
		if (result != MMSYSERR_NOERROR)
			return NULL;
		
		strcpy_s(namebuf, DEVNAME_BUFFER_SIZE, caps.szPname);
		return namebuf;
	}

	DLLEXPORT char* getCurDevName() {
		return curDevName;
	}

	DLLEXPORT int getCurDevID() {
		return curDevID;
	}

}