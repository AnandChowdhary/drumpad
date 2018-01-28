/*
* DrumPad (Arduino code)
* Copyright (c) 2018 Anand Chowdhary
* MIT License
*/

#include <CapacitiveSensor.h>

// These is a 1 megaogm resistor between each pair of sending and receiving pins
// Calling function CapacitiveSensor(byte sendPin, byte receivePin) for each pair
// For incresed efficiency, making an array of all capacitve sensors
CapacitiveSensor capacitiveSensors[4] = {
	CapacitiveSensor(12, 13),
	CapacitiveSensor(10, 11),
	CapacitiveSensor(8, 9),
	CapacitiveSensor(6, 7)
};
int previousValues[4] = { 0, 0, 0, 0 };
String prevSendValue = "0000";

void setup() {

	// Setting pins 2 to 5 to output for LEDs
	for (int i = 2; i < 6; i++) {
		pinMode(i, OUTPUT);
	}

	// Prepare to send data on 9600
	Serial.begin(9600);

}

void loop() {

	// Initialize `sendValues` variable
	String sendValues = "";

	// Send potentiometer and volume readings
	Serial.println("Potentiometer reading: " +  String(analogRead(A1)));
	Serial.println("Volume reading: " +  String(analogRead(A0)));

	// Loop through each instrument value
	for (int i = 0; i < 4; i++) {

		// By default, user has not tapped
		// and corresponsing LED is off
		previousValues[i] = 0;
		digitalWrite(i + 2, LOW);

		// Check if user has tapped on instrument
		if (capacitiveSensors[i].capacitiveSensor(30) > 500 && previousValues[i] == 0) {
			previousValues[i] = 1;
			// Turn LED on in case they have
			digitalWrite(i + 2, HIGH);
		}
	
		// Append to `sendValues` variable
		sendValues += String(previousValues[i]);

	}

	// Send to serial if it's different from the previously
	// sent variable value
	if (sendValues != prevSendValue) {
		Serial.println(sendValues);
		prevSendValue = sendValues;
	}

	delay(50); // Arbitrary delay to limit data to serial port

}
