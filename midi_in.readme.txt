Here's a list of all exported functions in midi_in.dll with some explanation of how they (should)work.




	int open(HWND targetWindowHandle, int deviceID)
		
		targetWindowHandle should be a handle to the script itself
		deviceID is passed to winmm.dll\midiInOpen unchecked so you'll have to check possible values with winmm.dll\midiInGetNumDevs and winmm.dll\midiInGetDevCaps
	
	
		Returns:
		0 - success
		50 - window handle was null
		60 - hMidiIn was not null
		anything else - error code from winmm.dll\midiInOpen
	
	
	
	int close()
	
		Closes the midi in device (unless already closed) and resets the internal midiIn handle
		This function must be called before openMidiIn can be called again.
		Unloading (detatching) the DLL automatically calls this function.
	
	
	void start()
	
		calls midiInStart(hMidiIn)

	void stop()
	
		calls midiInStop(hMidiIn)

	int getNumDevs()
	
		calls midiInGetNumDevs()
		returns the number of installed midi input devices
		
	char* getDevName(int deviceID)
		
		returns a midi input device name
		

These are used to determine when closing and opening midi input is necessary

	char* getCurDevName()
	int getCurDevID()
	

	The midi data is sent to the ahk script with windows messages.
Which messages are sent on which midi input are specified by "adding listeners".
Internally these functions just write message number values in 2d and 1d arrays
(e.g. notes x channels, or just channel for pitch wheel)	

  	listenNoteRange(int rangeStart, int rangeEnd, int modeFlags, int channel, int msgNumber)
		
		wParam - note number
		lParam - velocity (0x00 - 0x7F)

		rangeStart, rangeEnd
			midi note numbers (0x00 - 0x7F)
	
		msgNumber
			the (first) message number to be sent

		modeFlags (default = 0)
			& 0x01 - use increasing msgNumbers for subsequent notes
			& 0x02 - ignore black keys on note range
			& 0x04 - ignore white keys on note range

		channel
			if 0, listen to all channels (default), otherwise 1-16
		

  	listenNote(int noteNumber, int channel, int msgNumber

	int listenCC(int ccNumber, int channel, int msgNumber)

		wParam - cc number (0x00 - 0x7F)
		lParam - cc value (0x00 - 0x7F)


	int listenWheel(int channel, int msgNumber)

		wParam - wheel position
			value range is 0x0000 - 0x3FFF, middle = 0x2000		


	int listenChanAT(int channel, int msgNumber)

		wParam - channel aftertouch value (0x00 - 0x7F)


	void removeAllListeners()

		Resets all "listener" arrays to zero. Not really sure if this is useful.
	

The dll also stores the most recent values of controller data even when nothing is sent forward.

	int getNoteOn(int noteNumber, int channel)

		Returns 0 if key is up, otherwise the last key down velocity
	
	int getCC(int ccNumber, int channel)
	int getWheel(int channel)
	int getChanAT(int channel)