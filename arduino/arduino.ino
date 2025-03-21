#include <Servo.h>

// Create servo objects for each finger
Servo servoPinky;
Servo servoRing;
Servo servoMiddle;
Servo servoIndex;

// Assign pins (adjust as needed)
const int pinPinky = 5;
const int pinRing = 4;
const int pinMiddle = 3;
const int pinIndex = 2;

// Define servo positions and movement delay
const int openPos = 110;
const int closedPos = 10;
const int moveDelay = 300;  // milliseconds

void setup() {
  Serial.begin(9600);
  
  servoPinky.attach(pinPinky);
  servoRing.attach(pinRing);
  servoMiddle.attach(pinMiddle);
  servoIndex.attach(pinIndex);
  
  // intalize  all servos to open position
  servoPinky.write(openPos);
  servoRing.write(openPos);
  servoMiddle.write(openPos);
  servoIndex.write(openPos);
}

void loop() {
  if (Serial.available() > 0) {
    // Read a command from the serial port until newline
    String input = Serial.readStringUntil('\n');
    input.trim();
    
    if (input.length() > 0) {
      // Use only the first character as the command
      char finger = input.charAt(0);
      
      // Process only valid commands: 'p', 'r', 'm', or 'i'
      if (finger == 'p' || finger == 'r' || finger == 'm' || finger == 'i') {
        actuateFinger(finger);
      }
    }
  }
}

void actuateFinger(char finger) {
  Servo* targetServo = nullptr;
  
  switch(finger) {
    case 'p': targetServo = &servoPinky; break;
    case 'r': targetServo = &servoRing; break;
    case 'm': targetServo = &servoMiddle; break;
    case 'i': targetServo = &servoIndex; break;
    default: return; // Unknown command; do nothing
  }
  
  if (targetServo != nullptr) {
    // Actuate the servo: move from open to closed, then back to open
    targetServo->write(closedPos);
    delay(moveDelay);
    targetServo->write(openPos);
    delay(moveDelay);
  }
}
