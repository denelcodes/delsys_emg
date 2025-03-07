#include <Servo.h>

// Define servo objects for the index, middle, ring, and pinky fingers
Servo index1;
Servo middle;
Servo ring;
Servo pinky;

// Define PWM pins for each finger
#define INDEX_PIN 2
#define MIDDLE_PIN 3
#define RING_PIN 4
#define PINKY_PIN 5

// Define threshold levels for each finger to start moving (adjust as needed)
const float INDEX_THRESHOLD = 1.0;
const float MIDDLE_THRESHOLD = 1.0;
const float RING_THRESHOLD = 1.0;
const float PINKY_THRESHOLD = 1.0;

// Define the maximum expected EMG voltage value (update this value as needed)
const float EMG_MAX_VALUE = 2.0; // Example: 2.0 volts

void setup() {
  // Start the serial communication
  Serial.begin(115200);  // Ensure baud rate matches the one in your Python code (115200)
  
  // Attach the servos to the defined pins
  index1.attach(INDEX_PIN);
  middle.attach(MIDDLE_PIN);
  ring.attach(RING_PIN);
  pinky.attach(PINKY_PIN);
  
  // Initialize servos to the closed position (0 degrees)
  index1.write(0);
  middle.write(0);
  ring.write(0);
  pinky.write(0);
  
  delay(1000);
}

void loop() {
  // Check if data is available to read
  if (Serial.available() > 0) {
    // Read the incoming string until newline
    String input = Serial.readStringUntil('\n');
    input.trim();  // Remove any extra whitespace
    
    // Expect a comma-separated list of four values: index, middle, ring, pinky
    // Example input: "1.2,2.5,3.0,0.8"
    int firstComma = input.indexOf(',');
    int secondComma = input.indexOf(',', firstComma + 1);
    int thirdComma = input.indexOf(',', secondComma + 1);
    
    if (firstComma == -1 || secondComma == -1 || thirdComma == -1) {
      Serial.println("Error: Expected four comma-separated values.");
      return;
    }
    
    // Parse the values
    float indexVal = input.substring(0, firstComma).toFloat();
    float middleVal = input.substring(firstComma + 1, secondComma).toFloat();
    float ringVal = input.substring(secondComma + 1, thirdComma).toFloat();
    float pinkyVal = input.substring(thirdComma + 1).toFloat();
    
    // Validate values are in the expected range (adjust if necessary)
    if (indexVal < 0.0 || indexVal > EMG_MAX_VALUE ||
        middleVal < 0.0 || middleVal > EMG_MAX_VALUE ||
        ringVal < 0.0 || ringVal > EMG_MAX_VALUE ||
        pinkyVal < 0.0 || pinkyVal > EMG_MAX_VALUE) {
      Serial.println("Value out of range (expected 0 to maximum EMG voltage for all fingers).");
      return;
    }
    
    // Default angles are set to closed (0°)
    int indexAngle = 0, middleAngle = 0, ringAngle = 0, pinkyAngle = 0;
    
    // If the input is equal to or above the threshold, map from [threshold, EMG_MAX_VALUE] to [0, 120]
    if (indexVal >= INDEX_THRESHOLD) {
      indexAngle = map((indexVal - INDEX_THRESHOLD) * 100, 0, (EMG_MAX_VALUE - INDEX_THRESHOLD) * 100, 0, 120);
    }
    if (middleVal >= MIDDLE_THRESHOLD) {
      middleAngle = map((middleVal - MIDDLE_THRESHOLD) * 100, 0, (EMG_MAX_VALUE - MIDDLE_THRESHOLD) * 100, 0, 120);
    }
    if (ringVal >= RING_THRESHOLD) {
      ringAngle = map((ringVal - RING_THRESHOLD) * 100, 0, (EMG_MAX_VALUE - RING_THRESHOLD) * 100, 0, 120);
    }
    if (pinkyVal >= PINKY_THRESHOLD) {
      pinkyAngle = map((pinkyVal - PINKY_THRESHOLD) * 100, 0, (EMG_MAX_VALUE - PINKY_THRESHOLD) * 100, 0, 120);
    }
    
    // Move each servo to its corresponding angle
    index1.write(indexAngle);
    middle.write(middleAngle);
    ring.write(ringAngle);
    pinky.write(pinkyAngle);
    
    // Print debug information
    Serial.print("Received values: ");
    Serial.print(indexVal);
    Serial.print(", ");
    Serial.print(middleVal);
    Serial.print(", ");
    Serial.print(ringVal);
    Serial.print(", ");
    Serial.println(pinkyVal);
    
    Serial.print("=> Angles: Index: ");
    Serial.print(indexAngle);
    Serial.print(" Middle: ");
    Serial.print(middleAngle);
    Serial.print(" Ring: ");
    Serial.print(ringAngle);
    Serial.print(" Pinky: ");
    Serial.println(pinkyAngle);
  }
}
