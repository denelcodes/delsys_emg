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
    // Read the entire line until newline
    String input = Serial.readStringUntil('\n');
    input.trim();
    
    // Iterate over each character in the input string
    for (int i = 0; i < input.length(); i++) {
      char finger = input.charAt(i);
      
      // in case its \r instead of \n at the end of the string skip it
      if (finger == '\r') {
          continue;
      }
      
      // Only process if it's a valid command: p, r, m, or i
      if (finger == 'p' || finger == 'r' || finger == 'm' || finger == 'i') {
          actuateFinger(finger);
      }
    }
  }
}
void actuateFinger(char finger) {
  Servo* servo1 = nullptr;
  int delay1 = 300;
  
  switch(finger) {
    case 'p': servo1 = &servoPinky; break;
    case 'r': servo1 = &servoRing; break;
    case 'm': servo1 = &servoMiddle; break;
    case 'i': servo1 = &servoIndex; break;
    default: return; // unknown command; do nothing
  }
  
  if (servo1 != nullptr) {
    // Actuate  open 110 to closed 10 degre and then back to open 110
    servo1->write(10);
    delay(delay1);  // aadjust delay as needed for the movement
    servo1->write(110);
    delay(delay1);
  }
}
