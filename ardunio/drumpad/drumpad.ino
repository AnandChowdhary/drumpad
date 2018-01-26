/*
 * DrumPad
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

void setup() {

	// Turning off recalibration for all sensors
	// capacitiveSensor1.set_CS_AutocaL_Millis(0xFFFFFFFF);
	// capacitiveSensor2.set_CS_AutocaL_Millis(0xFFFFFFFF);
	// capacitiveSensor3.set_CS_AutocaL_Millis(0xFFFFFFFF);
	// capacitiveSensor4.set_CS_AutocaL_Millis(0xFFFFFFFF);

	// Setting pins 2 to 5 to output for LEDs
	for (int i = 2; i < 6; i++) {
		pinMode(i, OUTPUT);
	}

	// Prepare to send data on 9600
	Serial.begin(9600);

}

void loop() {

	String sendValues = "[ ";

	for (int i = 0; i < 4; i++) {
		previousValues[i] = 0;
		digitalWrite(i + 2, LOW);
		if (capacitiveSensors[i].capacitiveSensor(30) > 500 && previousValues[i] == 0) {
			previousValues[i] = 1;
			digitalWrite(i + 2, HIGH);
		}
		sendValues += String(previousValues[i]) + " ";
	}

	sendValues += "]";

	if (sendValues != "[ 0 0 0 0 ]") {
		Serial.println(sendValues);
	}

	// long start = millis();
	// long total1 = capacitiveSensor1.capacitiveSensor(30);
	// Serial.print(millis() - start); // check on performance in milliseconds
	// Serial.println(String(capacitiveSensors[0].capacitiveSensor(30)) + " " + String(capacitiveSensors[1].capacitiveSensor(30)) + " " + String(capacitiveSensors[2].capacitiveSensor(30)) + " " + String(capacitiveSensors[3].capacitiveSensor(30)));
	// print sensor output 1 - this is also the value you can use to use this in other projects
	delay(50); // arbitrary delay to limit data to serial port

}