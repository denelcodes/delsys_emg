import time
import serial

# Set up the serial connection (adjust port and baud rate as needed)
ser = serial.Serial('COM6', 9600, timeout=1)

def read_finger_from_file(filename):
    try:
        with open(filename, 'r') as f:
            finger = f.read().strip()  # Read the file content and remove any whitespace
        return finger
    except Exception as e:
        print("Error reading file:", e)
        return ""

def main():
    while True:
        try:
            # Read the current finger command from the text file
            finger_cmd = read_finger_from_file("finger.txt")
            
            # Append newline for Arduino's readStringUntil('\n') and send over serial.
            message = finger_cmd + "\n"
            print("Sending:", message.strip())
            ser.write(message.encode('utf-8'))
        except Exception as e:
            print("Error:", e)
        
        time.sleep(0.5)  # Adjust polling rate as needed.

if __name__ == "__main__":
    main()
