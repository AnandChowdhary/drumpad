/*
* DrumPad (Processing code)
* Copyright (c) 2018 Anand Chowdhary
* MIT License
*/

import processing.serial.*;
import processing.sound.*;
Serial myPort;

void setup() {
	myPort = new Serial(this, Serial.list()[3], 9600);
}

void draw() {
	size(100, 100);
	if (myPort.available() > 0) {
		String inByte = myPort.readStringUntil('\n');
		if (inByte != null) {
			for (int i = 0; i < 4; i++) {
				if (inByte.charAt(i) == '1') {
					SoundFile file;
					file = new SoundFile(this, str(i) + ".aif");
					file.play();
				}
			}
		}
	}
}