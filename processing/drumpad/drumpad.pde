/*
* DrumPad (Processing code)
* Copyright (c) 2018 Anand Chowdhary
* MIT License
*/

import processing.serial.*;
import processing.sound.*;
Serial IO;

// Number of inputs, currently hardcoded to `4`
int nInputs = 4;

// This global array will contain list of available instruments
String[] instruments = {};

// This global variable will contain the current instrument
String currentInstrument;

void setup() {

	// Find available instruments from samples folder
	File file = new File(sketchPath() + "/data/samples");
	for (int i = 0; i < file.list().length; i++) {
		File subFile = new File(sketchPath() + "/data/samples/" + file.list()[i]);
		// Make sure it's a directory containing samples
		if (subFile.isDirectory()) {
			instruments = append(instruments, subFile.getName());
		}
	}
	// Set the current instrument as `drum`
	currentInstrument = instruments[4];

	// Start listening to Arduino's serial
	IO = new Serial(this, Serial.list()[3], 9600);

	printArray(instruments);

}

void draw() {

	// Basic UI
	size(100, 100);

	// Check if Arduino is sending something
	if (IO.available() > 0) {

		// Start reading until new line
		String readIoString = IO.readStringUntil('\n');

		// Make sure we don't get `null` as input
		// Recommendation: https://stackoverflow.com/a/29507239/1656944
		if (readIoString != null) {

			// Check whether we have potentiometer reading or instrument
			if (!readIoString.contains("Potentiometer")) {

				// Loop through each instrument in input
				// and play song if user pressed the input
				for (int i = 0; i < nInputs; i++) {
					if (readIoString.charAt(i) == '1') {

						SoundFile audioSample;

						// Try to play the file
						// Will catch exception if file doesn't exist
						try {
							audioSample = new SoundFile(this, "samples/" + currentInstrument + "/" + str(i) + ".wav");
							audioSample.play();
						} catch(RuntimeException e) {
							println("Error: Could not find the required sound file");
						}

					}
				}

			} else {

				// Get the value of new instrument using potentiometer
				// Map potentiometer value to 0 to instruments.length
				// and get value using instruments[mapped value]
				String newInstrument = instruments[int(map(int(readIoString.replace("Potentiometer reading: ", "").trim()), 0, 1023, 0, float(instruments.length) - 0.001))];

				// If we have a new instrument, switch to that
				if (!currentInstrument.equals(newInstrument)) {
					currentInstrument = newInstrument;
					println(newInstrument);
				}

			}

		}

	}

}
