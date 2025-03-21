import time
import serial
import matlab.engine

# Set up the serial connection (adjust port and baud rate as needed)
ser = serial.Serial('COM6', 9600, timeout=1)

def main():
    # Start MATLAB engine
    eng = matlab.engine.start_matlab()
    
    # (Make sure your MATLAB process is running update_plot continuously, e.g., via a timer or loop)
    # Here we simply poll for the combined command.
    
    while True:
        # Get the combined finger command from MATLAB.
        # This returns a string like "p,,m,i" or ",r,,," etc.
        combined_cmd = eng.get_combined_finger_command(nargout=1)
        
        # Append newline for Arduino's readStringUntil('\n') and send over serial.
        message = combined_cmd + "\n"
        print("Sending:", message.strip())
        ser.write(message.encode('utf-8'))
        
        time.sleep(0.5)  # Adjust polling rate as needed.

if __name__ == "__main__":
    main()