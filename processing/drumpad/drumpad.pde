/*
* DrumPad (Processing code)
* Copyright (c) 2018 Anand Chowdhary
* MIT License
*/

import processing.serial.*;
import processing.sound.*;
Serial IO;

// The array will store the initialized background images
PImage[] bg = new PImage[3];

// Number of inputs, currently hardcoded to `4`
int nInputs = 4;

// This global array will contain list of available instruments
String[] instruments = {};

// This global array will contain list of exported files
String[] exportedFiles;

// This global variable will contain the current instrument
String currentInstrument;

// This global array will contain the image for each instrument
PImage[] instrumentImages;

// Tracks which page the user is currently on
/*
* 0 -> "Your Band" home screen
* 1 -> "Your Recordings" import screen
*/
int currentPage = 1;

// Volume reading from the potentiometer stored here (0 to 100)
int volumeReading = 0;

// Keep track of whether we are currently recording or playing
int recording = 0, playing = 0;

// These variables store recording metadata and body
long recordingStartValue = 0;
String[] recordingNotes = {};

// This function fetches files from the `exports` folder
// and assigns the global array `exportedFiles` with its value
void fetchNewFiles() {
	File file = new File(sketchPath() + "/exports");
	exportedFiles = new String[file.list().length];
	for (int i = 0; i < file.list().length; i++) {
		File subFile = new File(sketchPath() + "/exports/" + file.list()[i]);
		exportedFiles[i] = subFile.getName();
	}
}

// These global variables will contain metadata about the currently
// playing file, e.g., length of track, current position, etc.
int nowplaying_file = -1;
long nowPlaying_start = 0;
int nowPlaying_length = 0;
int nowPlaying_played = 0;

// The function plays the audio file after user clicks on the title
// and assigns the global metadata above
void playFile(String fileName) {
	playing = 1;
	String[] soundInstructions = {};
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
	nowPlaying_length = int(split(soundInstructions[soundInstructions.length - 1], " ")[1]);
	nowPlaying_start = millis();
}

// This function takes any milisecond value and returns
// a string in the format `MM:SS` (minutes:seconds)
String millisToMMSS(int millis) {
	int minutes = 0, seconds;
	seconds = int((float(millis)) / 1000);
	minutes = seconds / 60;
	seconds = seconds % 60;
	return (minutes > 9 ? minutes : "0" + minutes) + ":" + (seconds > 9 ? seconds : "0" + seconds);
}

void setup() {

	// Basic UI
	size(800, 500);

	// Load background images
	bg[0] = loadImage("bg-default.png");
	bg[1] = loadImage("bg-recording.png");
	bg[2] = loadImage("bg-import.png");

	// Fetch exported sound files from disk
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
	// Load images for each instrument
	// Uses an unofficial Bing Image Search API that I discovered
	instrumentImages = new PImage[instruments.length + 2];
	for (int i = 0; i < instruments.length; i++) {
		instrumentImages[i] = loadImage("https://tse2.mm.bing.net/th?q=" + instruments[i] + "&w=200&h=200", "jpeg");
	}
	instrumentImages[instruments.length] = loadImage("https://tse2.mm.bing.net/th?q=music+folder+icon&w=200&h=200", "jpeg");
	instrumentImages[instruments.length + 1] = loadImage("https://tse2.mm.bing.net/th?q=volume+icon&w=200&h=200", "jpeg");
	// Set the current instrument as `drum` because why not
	currentInstrument = instruments[4];

	// Start listening to Arduino's serial
	try {
		IO = new Serial(this, Serial.list()[3], 9600);
	} catch(RuntimeException e) {
		IO = new Serial(this, Serial.list()[0], 9600);
	}

}

void draw() {

	// This is the heading text displayed on each screen
	// The following `switch` statement assigns this value
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
				if (nowplaying_file == i) {
					image(instrumentImages[instruments.length + 1], 710, 130 + i * 45 - 21, 30, 30);
				}
				stroke(0, 0, 0, 50);
				fill(0, 0, 0, 10);
				if (mouseX > 300 && mouseX < 747 && mouseY > 130 + i * 45 - 24 && mouseY < 141 + i * 45) {
					rect(300, 130 + i * 45 - 24, 447, 35, 7);
				}
			}
			textSize(12);
			if (playing == 1) {
				fill(0);
				text(millisToMMSS(nowPlaying_played), 300, 447);
				text(millisToMMSS(nowPlaying_length), 715, 447);
				stroke(0, 0, 0, 0);
				fill(225, 225, 225);
				rect(345, 440, 360, 5);
				fill(155, 89, 282);
				rect(345, 440, map(nowPlaying_played, 0, nowPlaying_length, 0, 360), 5);
				ellipse(map(nowPlaying_played, 0, nowPlaying_length, 345, 700), 443, 12, 12);
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

	// Display the heading on screen
	fill(0);
	textSize(24);
	text(heading, 310, 80); 

	// Display potentiometer's volume reading
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

				// If we're currently recording, add this line
				// in the global array `recordingNotes`
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

	// If we're currently playing from the file system,
	// update `nowPlaying_played`, or stop if we're done
	if (playing == 1) {
		nowPlaying_played = int(millis() - nowPlaying_start);
		if (nowPlaying_played > nowPlaying_length) {
			playing = 0;
			nowplaying_file = -1;
		}
	}

}

// There are several occassions when a user
// may click on something on the screen
void mouseClicked() {

	// Click handler for the "Record" button
	if (mouseX > 70 && mouseX < 210 && mouseY > 235 && mouseY < 275) {
		// Check if we're currently recording
		// If we are, stop recording and save file
		if (recording == 1) {
			recording = 0;
			if (recordingNotes.length > 0) {
				// This saves the values in a file with title:
				// YYYY-MM-DD-HHMMSS-XXXXX.drumpad
				// where XXXXX is a 5-digit pseudorandom number
				saveStrings("exports/" + year() + "-" + (month() > 9 ? month() : "0" + month()) + "-" + (day() > 9 ? day() : "0" + day()) + "-" + (hour() > 9 ? hour() : "0" + hour()) + (minute() > 9 ? minute() : "0" + minute()) + (second() > 9 ? second() : "0" + second()) + "-" + str(int(random(100000))) + ".drumpad", recordingNotes);
			}
		// If we're not, start recording
		} else {
			currentPage = 0;
			recording = 1;
			recordingStartValue = millis();
		}

	// Click handler for the "Import" button
	// Toggle between "Your Recordings" and "Your Band" pages
	} else if (mouseX > 70 && mouseX < 210 && mouseY > 365 && mouseY < 405) {
		if (currentPage == 1) {
			currentPage = 0;
		} else {
			fetchNewFiles();
			currentPage = 1;
		}

	// Click handler for music files in "Your Recordings"
	} else {
		for (int i = 0; i < exportedFiles.length; i++) {
			// Check if any of the recordings have been clicked
			if (mouseX > 300 && mouseX < 747 && mouseY > 130 + i * 45 - 24 && mouseY < 141 + i * 45) {
				// If yes, start playing that file
				nowplaying_file = i;
				playFile(exportedFiles[i]);
			}
		}
	}

}