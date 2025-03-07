#include <Servo.h>

// Create servo objects for each finger
Servo servoPinky;
Servo servoRing;
Servo servoMiddle;
Servo servoIndex;

// Assign pins (adjust as needed)
const int pinPinky = 1;
const int pinRing = 2;
const int pinMiddle = 3;
const int pinIndex = 4;

void setup() {
  Serial.begin(9600);
  
  servoPinky.attach(pinPinky);
  servoRing.attach(pinRing);
  servoMiddle.attach(pinMiddle);
  servoIndex.attach(pinIndex);
  
  // Initialize all servos to open position (110 degrees)
  servoPinky.write(110);
  servoRing.write(110);
  servoMiddle.write(110);
  servoIndex.write(110);
}

void loop() {
  if (Serial.available() > 0) {
    // Read an entire line from serial (expecting format: S1:<cmd>;S2:<cmd>)
    String input = Serial.readStringUntil('\n');
    input.trim();
    
    // Parse input if it contains both sensor commands
    int sepIndex = input.indexOf(';');
    if (sepIndex != -1) {
      String sensor1Part = input.substring(0, sepIndex);
      String sensor2Part = input.substring(sepIndex + 1);
      
      char cmd1 = parseCommand(sensor1Part);
      char cmd2 = parseCommand(sensor2Part);
      
      // Actuate for sensor 1 if command is not 'n'
      if (cmd1 != 'n') {
        actuateFinger(cmd1);
      }
      // Actuate for sensor 2 if command is not 'n' and not duplicate
      if (cmd2 != 'n' && cmd2 != cmd1) {
        actuateFinger(cmd2);
      }
    }
  }
}

char parseCommand(String sensorString) {
  // Expected format: "S1:<cmd>" or "S2:<cmd>"
  int colonIndex = sensorString.indexOf(':');
  if (colonIndex != -1 && sensorString.length() > colonIndex + 1) {
    char cmd = sensorString.charAt(colonIndex + 1);
    // If the command is one of the valid letters, return it; otherwise, return 'n'
    if (cmd == 'p' || cmd == 'r' || cmd == 'm' || cmd == 'i') {
      return cmd;
    }
  }
  return 'n'; // default: no command
}

void actuateFinger(char finger) {
  Servo* targetServo = nullptr;
  switch(finger) {
    case 'p': targetServo = &servoPinky; break;
    case 'r': targetServo = &servoRing; break;
    case 'm': targetServo = &servoMiddle; break;
    case 'i': targetServo = &servoIndex; break;
    default: return; // unknown command; do nothing
  }
  
  if (targetServo != nullptr) {
    // Actuation: move from open (110°) to closed (10°) and back to open (110°)
    targetServo->write(10);
    delay(300);  // Adjust delay as needed for movement
    targetServo->write(110);
    delay(300);
  }
}
