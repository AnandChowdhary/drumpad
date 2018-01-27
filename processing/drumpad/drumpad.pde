/*
* DrumPad (Processing code)
* Copyright (c) 2018 Anand Chowdhary
* MIT License
*/

import processing.serial.*;
import processing.sound.*;
Serial IO;
PImage bg;

// Number of inputs, currently hardcoded to `4`
int nInputs = 4;

// This global array will contain list of available instruments
String[] instruments = {};

// This global variable will contain the current instrument
String currentInstrument;
PImage[] instrumentImages;

int currentPage = 0;
int volumeReading = 0;

void setup() {

	// Basic UI
	size(800, 500);
	bg = loadImage("bg-default.png");

	// Find available instruments from samples folder
	File file = new File(sketchPath() + "/data/samples");
	for (int i = 0; i < file.list().length; i++) {
		File subFile = new File(sketchPath() + "/data/samples/" + file.list()[i]);
		// Make sure it's a directory containing samples
		if (subFile.isDirectory()) {
			instruments = append(instruments, subFile.getName());
		}
	}
	instrumentImages = new PImage[instruments.length];
	for (int i = 0; i < instruments.length; i++) {
		instrumentImages[i] = loadImage("https://tse2.mm.bing.net/th?q=" + instruments[i] + "&w=200&h=200", "jpeg");
	}
	// Set the current instrument as `drum`
	currentInstrument = instruments[4];

	// Start listening to Arduino's serial
	try {
		IO = new Serial(this, Serial.list()[3], 9600);
	} catch(RuntimeException e) {
		IO = new Serial(this, Serial.list()[0], 9600);
	}

}

void draw() {

	background(bg);

	String heading;

	switch (currentPage) {
		default:
			heading = "Your Band";
			fill(0);
			textSize(16);
			for (int i = 0; i < instruments.length; i++) {
				text(instruments[i].substring(0, 1).toUpperCase() + instruments[i].substring(1) + (currentInstrument == instruments[i] ? " (current)" : ""), 375, 130 + i * 45);
				image(instrumentImages[i], 300, 130 + i * 45 - 25, 50, 50);
			}
			break;
	}

	fill(0);
	textSize(24);
	text(heading, 310, 80); 

	textSize(13);
	text(str(volumeReading) + "%", 177, 323);

	// Check if Arduino is sending something
	if (IO.available() > 0) {

		// Start reading until new line
		String readIoString = IO.readStringUntil('\n');

		// Make sure we don't get `null` as input
		// Recommendation: https://stackoverflow.com/a/29507239/1656944
		if (readIoString != null) {

			// Check whether we have potentiometer reading or instrument
			if (!readIoString.contains("Potentiometer") && !readIoString.contains("Volume")) {

				// Loop through each instrument in input
				// and play song if user pressed the input
				for (int i = 0; i < nInputs; i++) {
					if (readIoString.charAt(i) == '1') {

						SoundFile audioSample;

						// Try to play the file
						// Will catch exception if file doesn't exist
						try {
							audioSample = new SoundFile(this, "samples/" + currentInstrument + "/" + str(i) + ".wav");
							audioSample.amp(float(volumeReading) / 100);
							audioSample.play();
						} catch(RuntimeException e) {
							println("Error: Could not find the required sound file");
						}

					}
				}

			// Check if volume knob has moved and update volume
			} else if (readIoString.contains("Volume reading")) {
				volumeReading = int(map(int(readIoString.replace("Volume reading: ", "").trim()), 0, 1023, 0, 100));
			} else {

				// Get the value of new instrument using potentiometer
				// Map potentiometer value to 0 to instruments.length
				// and get value using instruments[mapped value]
				String newInstrument = instruments[int(map(int(readIoString.replace("Potentiometer reading: ", "").trim()), 0, 1023, 0, float(instruments.length) - 0.001))];

				// If we have a new instrument, switch to that
				if (!currentInstrument.equals(newInstrument)) {
					currentInstrument = newInstrument;
				}

			}

		}

	}

}
