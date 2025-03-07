import time
import serial

# Set up the serial connection (adjust 'COM3' and baud rate as needed)
ser = serial.Serial('COM3', 9600, timeout=1)

def main():
    # Open the finger output file in read mode and seek to the end
    with open("finger_output.txt", "r") as f:
        f.seek(0, 2)  # Move to the end of file
        sensor1_cmd = 'n'
        sensor2_cmd = 'n'
        
        while True:
            # During each cycle (0.5 sec window), check for new lines.
            start_time = time.time()
            while time.time() - start_time < 0.5:
                line = f.readline()
                if line:
                    line = line.strip()
                    # Expecting lines like "Sensor1: p" or "Sensor2: i"
                    if line.startswith("Sensor1:"):
                        parts = line.split(":")
                        sensor1_cmd = parts[1].strip() if len(parts) > 1 else 'n'
                    elif line.startswith("Sensor2:"):
                        parts = line.split(":")
                        sensor2_cmd = parts[1].strip() if len(parts) > 1 else 'n'
                else:
                    time.sleep(0.1)  # Small delay to avoid busy-waiting
            
            # Prepare combined message. Even if no new command, 'n' is sent.
            message = f"S1:{sensor1_cmd};S2:{sensor2_cmd}\n"
            print("Sending:", message.strip())
            ser.write(message.encode('utf-8'))
            
            # Reset commands for next cycle
            sensor1_cmd = 'n'
            sensor2_cmd = 'n'

if __name__ == "__main__":
    main()
