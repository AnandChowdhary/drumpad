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

void setup() {

	// Turning off recalibration for all sensors
	// capacitiveSensor1.set_CS_AutocaL_Millis(0xFFFFFFFF);
	// capacitiveSensor2.set_CS_AutocaL_Millis(0xFFFFFFFF);
	// capacitiveSensor3.set_CS_AutocaL_Millis(0xFFFFFFFF);
	// capacitiveSensor4.set_CS_AutocaL_Millis(0xFFFFFFFF);

	pinMode(2, OUTPUT);

	// Prepare to send data on 9600
	Serial.begin(9600);

}

void loop() {

	// long start = millis();
	// long total1 = capacitiveSensor1.capacitiveSensor(30);
	// Serial.print(millis() - start); // check on performance in milliseconds
	Serial.println(String(capacitiveSensors[0].capacitiveSensor(30)) + " " + String(capacitiveSensors[1].capacitiveSensor(30)) + " " + String(capacitiveSensors[2].capacitiveSensor(30)) + " " + String(capacitiveSensors[3].capacitiveSensor(30)));
	// print sensor output 1 - this is also the value you can use to use this in other projects
	digitalWrite(2, LOW);
	delay(500); // arbitrary delay to limit data to serial port

}