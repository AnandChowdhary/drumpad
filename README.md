# Drumpad

Drumpad is an Ardunio-based music generator built for my Programming and Physical Computing project, Module 2 (Smart Environments) of Creative Technology BSc at the University of Twente.

## Screenshots

### *Your Band* screen

![Your Band screen on Drumpad](https://user-images.githubusercontent.com/2841780/35483170-45d617f4-043f-11e8-80a1-d5977891d1f8.png)

### *Your Recordings* screen

![Your Recordings screen on Drumpad](https://user-images.githubusercontent.com/2841780/35483171-45f17602-043f-11e8-95ef-ea94c69a0ab4.png)

### Real-life shot

![Arduino image](https://user-images.githubusercontent.com/2841780/35484050-57e60e4e-044a-11e8-9c55-215c004f9fa5.jpg)

## Toolkit

### Materials
- Arduino Uno
- 4 × 1MΩ resistors for capacitive sensors
- 4 × 330Ω resistors for LEDs
- 4 × conductive input surfaces
- 4 × LEDs for output
- 2 × potentiometers

### Sounds
- [Kawai R50 drumkit](https://sampleswap.org/filebrowser-new.php?d=DRUMS+%28FULL+KITS%29%2Fkawai+R50+drumkit%2F) from SampleSwap (Public Domain)
- [Casio 1000P synthesizer pack](https://freesound.org/people/acollier123/packs/17687/) by Auto-Pilot from Freesound (CC BY 3.0)
- Samples from the [Music Technology Group](https://www.upf.edu/recercaupf/en/grups/gr-mtg.html), [Department of Information and Communications Technologies](https://www.upf.edu/recercaupf/en/departaments/dtecn.html), [Universitat Pompeu Fabra, Barcelona](https://www.upf.edu/en/) (CC BY 3.0)

### Libraries
- [CapacitiveSense.h](https://github.com/PaulStoffregen/CapacitiveSensor) by Paul Bagder (2009), updated by Paul Stoffregen (2010–2016) (MIT License)
- Libraries part of the Processing project (LGPL License)
	- [PSerial](https://github.com/processing/processing/tree/master/java/libraries/serial) – class for serial port goodness
	- [Processing Sound](https://github.com/processing/processing-sound) by Wilm Thoben


## How it works

### Fritzing structure

![Fritzing structure](https://user-images.githubusercontent.com/2841780/35483888-ced36f86-0447-11e8-9c0c-a82fb746e37f.png)

### Directory Structure

```
.
├── arduino
│   ├── CapacitiveSensor.h
│   └── drumpad.ino
└── processing
    ├── drumpad.pde
    ├── data
    ├── exports
    └── samples
	    └── instrument_name
		    └── 0.wav … n.wav
```

### Instruments
Drumpad automatially fetches instruments from the `processing/drumpad/samples` folder. Each instrument should have a corresponsing folder with WAV files from 0 to n, based on the number of input capacitive sensors. This means that it's completely agnostic to the instruments, users have the ability to add or remove instruments from their collection.

### Recording
Users can press the "Record" button to start recording their music. On completion, a data file with the extension `.drumpad` is created in the `processing/drumpad/exports` folder. When a user goes to the "Import" screen, they see a lit of their recordings, which then can be played.

## License

MIT; see LICENSE.md