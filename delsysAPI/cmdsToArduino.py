import time
import serial
import matlab.engine

# Set up the serial connection (adjust port and baud rate as needed)
ser = serial.Serial('COM6', 9600, timeout=1)

def main():
    # Start MATLAB engine
    eng = matlab.engine.start_matlab()
    matlab_folder = r"C:\Users\Den\OneDrive - University of Southampton\4th_year\Medical\delsys_emg\matlab"
    eng.addpath(matlab_folder, nargout=0)
    
    # Optionally: Run update_plot to update sensor data and global variable.
    # If update_plot requires sensor data, you'll need to pass that.
    # For demonstration, we're calling it without actual sensor data.
    eng.update_plot(0, 0, False, nargout=0)
    
    while True:
        try:
            # Optionally update the plot (if needed) with new sensor data.
            # eng.update_plot(new_sensor1, new_sensor2, False, nargout=0)
            
            # Retrieve the combined command from MATLAB.
            combined_cmd = eng.get_combined_finger_command(nargout=1)
            
            # Append newline for Arduino's readStringUntil('\n') and send over serial.
            message = combined_cmd + "\n"
            print("Sending:", message.strip())
            ser.write(message.encode('utf-8'))
        except Exception as e:
            print("Error:", e)
        
        time.sleep(0.5)  # Adjust polling rate as needed.

if __name__ == "__main__":
    main()
