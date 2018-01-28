/*
* DrumPad (Processing code)
* Copyright (c) 2018 Anand Chowdhary
* MIT License
*/

import processing.serial.*;
import processing.sound.*;
Serial IO;
PImage[] bg = new PImage[3];

// Number of inputs, currently hardcoded to `4`
int nInputs = 4;

// This global array will contain list of available instruments
String[] instruments = {};

// This global array will contain list of exported files
String[] exportedFiles;

// This global variable will contain the current instrument
String currentInstrument;

// This global variable will contain the currently playing file
int currentPlaying = -1;

// This global array will contain the image for each instrument
PImage[] instrumentImages;

int currentPage = 1;
int volumeReading = 0;
int recording = 0, playing = 0;
long recordingStartValue = 0;
String[] recordingNotes = {};

void fetchNewFiles() {
	File file = new File(sketchPath() + "/exports");
	exportedFiles = new String[file.list().length];
	for (int i = 0; i < file.list().length; i++) {
		File subFile = new File(sketchPath() + "/exports/" + file.list()[i]);
		exportedFiles[i] = subFile.getName();
	}
}

void playFile(String fileName) {
	String[] soundInstructions = {};
	String songLength;
	// Try to play the file
	// Will catch exception if file doesn't exist
	try {
		String[] musicLines = loadStrings(sketchPath() + "/exports/" + fileName);
		for (int i = 0; i < musicLines.length; i++) {
			if (!musicLines[i].equals("")) {
				soundInstructions = append(soundInstructions, musicLines[i]);
			}
		}
	} catch(RuntimeException e) {
		println("Error: Could not find the required sound file");
	}
	songLength = soundInstructions[soundInstructions.length - 1];
	println("LENGTH: " + songLength);
}

void setup() {

	// Basic UI
	size(800, 500);
	bg[0] = loadImage("bg-default.png");
	bg[1] = loadImage("bg-recording.png");
	bg[2] = loadImage("bg-import.png");

	// Fetch exported sound files
	fetchNewFiles();

	// Find available instruments from samples folder
	File file = new File(sketchPath() + "/data/samples");
	for (int i = 0; i < file.list().length; i++) {
		File subFile = new File(sketchPath() + "/data/samples/" + file.list()[i]);
		// Make sure it's a directory containing samples
		if (subFile.isDirectory()) {
			instruments = append(instruments, subFile.getName());
		}
	}
	instrumentImages = new PImage[instruments.length + 2];
	for (int i = 0; i < instruments.length; i++) {
		instrumentImages[i] = loadImage("https://tse2.mm.bing.net/th?q=" + instruments[i] + "&w=200&h=200", "jpeg");
	}
	instrumentImages[instruments.length] = loadImage("https://tse2.mm.bing.net/th?q=music+folder+icon&w=200&h=200", "jpeg");
	instrumentImages[instruments.length + 1] = loadImage("https://tse2.mm.bing.net/th?q=volume+icon&w=200&h=200", "jpeg");
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

	String heading;

	switch (currentPage) {
		case 1:
			background(bg[2]);
			heading = "Your Recordings";
			textSize(16);
			for (int i = 0; i < exportedFiles.length; i++) {
				fill(0);
				text(exportedFiles[i], 355, 130 + i * 45);
				image(instrumentImages[instruments.length], 310, 130 + i * 45 - 21, 30, 30);
				if (currentPlaying == i) {
					image(instrumentImages[instruments.length + 1], 710, 130 + i * 45 - 21, 30, 30);
				}
				stroke(0, 0, 0, 50);
				fill(0, 0, 0, 10);
				if (mouseX > 300 && mouseX < 747 && mouseY > 130 + i * 45 - 24 && mouseY < 141 + i * 45) {
					rect(300, 130 + i * 45 - 24, 447, 35, 7);
				}
			}
			break;
		default:
			background(recording == 0 ? bg[0] : bg[1]);
			heading = "Your Band";
			fill(0);
			textSize(16);
			for (int i = 0; i < instruments.length; i++) {
				fill(0);
				text(instruments[i].substring(0, 1).toUpperCase() + instruments[i].substring(1) + (currentInstrument == instruments[i] ? " (current)" : ""), 375, 130 + i * 45);
				image(instrumentImages[i], 310, 130 + i * 45 - 25, 30, 30);
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

				if (recording == 1) {
					recordingNotes = append(recordingNotes, currentInstrument + " " + str(int(millis() - recordingStartValue)) + " " + readIoString);
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

void mouseClicked() {
	if (mouseX > 70 && mouseX < 210 && mouseY > 235 && mouseY < 275) {
		if (recording == 1) {
			recording = 0;
			if (recordingNotes.length > 0) {
				saveStrings("exports/" + year() + "-" + (month() > 9 ? month() : "0" + month()) + "-" + (day() > 9 ? day() : "0" + day()) + "-" + (hour() > 9 ? hour() : "0" + hour()) + (minute() > 9 ? minute() : "0" + minute()) + (second() > 9 ? second() : "0" + second()) + "-" + str(int(random(100000))) + ".drumpad", recordingNotes);
			}
		} else {
			currentPage = 0;
			recording = 1;
			recordingStartValue = millis();
		}
	} else if (mouseX > 70 && mouseX < 210 && mouseY > 365 && mouseY < 405) {
		if (currentPage == 1) {
			currentPage = 0;
		} else {
			fetchNewFiles();
			currentPage = 1;
		}
	} else {
		for (int i = 0; i < exportedFiles.length; i++) {
			if (mouseX > 300 && mouseX < 747 && mouseY > 130 + i * 45 - 24 && mouseY < 141 + i * 45) {
				currentPlaying = i;
				playFile(exportedFiles[i]);
			}
		}
	}
}