#include <windows.h>

#define DLLEXPORT __declspec(dllexport)

extern "C" {
	DLLEXPORT int open(HWND targetWindowHandle, int deviceID);
	DLLEXPORT int close();
	DLLEXPORT void start();
	DLLEXPORT void stop();

	DLLEXPORT int getNumDevs();
	DLLEXPORT char* getDevName(int deviceID);
	DLLEXPORT char* getCurDevName();
	DLLEXPORT int getCurDevID();

	DLLEXPORT int listenNoteRange(int rangeStart, int rangeEnd, int modeFlags, int channel, int msgNumber);
	DLLEXPORT int listenNote(int noteNumber, int channel, int msgNumber);
	DLLEXPORT int listenCC(int ccNumber, int channel, int msgNumber);
	DLLEXPORT int listenWheel(int channel, int msgNumber);
	DLLEXPORT int listenChanAT(int channel, int msgNumber);

	DLLEXPORT void setMinInterval(int minInterval);

	DLLEXPORT void removeAllListeners();

	DLLEXPORT int getNoteOn(int noteNumber, int channel);
	DLLEXPORT int getCC(int ccNumber, int channel);
	DLLEXPORT int getWheel(int channel);
	DLLEXPORT int getChanAT(int channel);

}
