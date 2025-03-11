"""
This is the class that handles the data that is output from the Delsys Trigno Base.
Create an instance of this and pass it a reference to the Trigno base for initialization.
See CollectDataController.py for a usage example.
"""
import numpy as np
import time

class DataKernel():
    def __init__(self, trigno_base):
        self.trigno_base = trigno_base
        self.TrigBase = trigno_base.TrigBase
        self.packetCount = 0
        self.sampleCount = 0
        self.allcollectiondata = []
        self.channel1time = []
        self.channel_guids = []


#     def processData(self, data_queue):
#         """Processes the data from the DelsysAPI, writes sensor data to a text file in a simple format, and places it in the data_queue argument"""
#         outArr = self.GetData()  # Retrieve data from the DelsysAPI via the GetData method.
#         if outArr is not None:
#             # --- NEW CODE BLOCK FOR FILE OUTPUT ---
#             with open('C:\\Users\\dv2g21\\OneDrive - University of Southampton\\4th_year\\Medical\\delsys_emg\\matlab\\raw_emg_data.txt', 'w') as file:
#                 # Loop through each sensor's data in the output array.
#                 for i, sensor_data in enumerate(outArr):
#                     # Convert the first element of sensor_data (assumed to be a numpy array) to a list.
#                     # This conversion ensures the data is in a human-readable format.
                    
#                     sensor_values = sensor_data[0].tolist() if sensor_data else []
#                     # Write a line to the file with a label for the sensor and its corresponding data.
#                     file.write(f"Sensor {i+1}: {sensor_values}\n")

#             # --- END OF NEW CODE BLOCK ---

#             # Existing code that processes the data further for internal storage and queueing.
#             for i in range(len(outArr)):
#                 self.allcollectiondata[i].extend(outArr[i][0].tolist())
#             try:
#                 for i in range(len(outArr[0])):
#                     if np.asarray(outArr[0]).ndim == 1:
#                         data_queue.append(list(np.asarray(outArr, dtype='object')[0]))
#                     else:
#                         data_queue.append(list(np.asarray(outArr, dtype='object')[:, i]))
#                 try:
#                     self.packetCount += len(outArr[0])
#                     self.sampleCount += len(outArr[0][0])
#                 except Exception as e:
#                     print("Exception updating counters:", e)
#             except IndexError as e:
#                 print("Index error in processing data:", e)

# import time
# import numpy as np

def processData(self, data_queue):
    """
    Processes data from the DelsysAPI. Only sensor 1 and sensor 2 data are collected.
    Data is aggregated over a 50ms window and then written to a text file.
    """
    # Start a 50ms collection window
    start_time = time.time()
    sensor1_data_collection = []
    sensor2_data_collection = []
    
    # Collect data repeatedly for 50ms
    while (time.time() - start_time) < 0.05:
        outArr = self.GetData()  # Retrieve data from the DelsysAPI.
        # Ensure there are at least two sensors in the output.
        if outArr is not None and len(outArr) >= 2:
            # Assuming each sensor's data is stored as a nested array, e.g. sensor_data[0] contains the data array.
            sensor1_values = outArr[0][0].tolist() if outArr[0] else []
            sensor2_values = outArr[1][0].tolist() if outArr[1] else []
            sensor1_data_collection.append(sensor1_values)
            sensor2_data_collection.append(sensor2_values)
        # A small sleep can prevent a too-tight loop (adjust as needed)
        time.sleep(0.001)
    
    # Write the 50ms aggregated sensor data to file.
    with open('C:\\Users\\dv2g21\\OneDrive - University of Southampton\\4th_year\\Medical\\delsys_emg\\matlab\\raw_emg_data.txt', 'a') as file:
        file.write("Sensor 1 (50ms window): " + str(sensor1_data_collection) + "\n")
        file.write("Sensor 2 (50ms window): " + str(sensor2_data_collection) + "\n")
    
    # If you need to process the data further, for example to add it to a queue,
    # you can package the 50ms window's data into a dict or list.
    data_queue.append({
        "sensor1": sensor1_data_collection,
        "sensor2": sensor2_data_collection
    })
    
    # If you still need to update internal storage counters, you can do that here as needed.
    try:
        # Example: update counters based on the length of one of the sensor collections.
        self.packetCount += len(sensor1_data_collection)
        # If each sensor1_value is an array, update sampleCount using its length.
        if sensor1_data_collection and sensor1_data_collection[0]:
            self.sampleCount += len(sensor1_data_collection[0])
    except Exception as e:
        print("Exception updating counters:", e)



    def processYTData(self, data_queue):
        """Processes the data from the DelsysAPI and place it in the data_queue argument"""
        outArr = self.GetYTData()
        if outArr is not None:
            for i in range(len(outArr)):
                self.allcollectiondata[i].extend(outArr[i][0].tolist())
            try:
                yt_outArr = []
                for i in range(len(outArr)):
                    chan_yt = outArr[i]
                    chan_ydata = np.asarray([k.Item2 for k in chan_yt[0]], dtype='object')
                    yt_outArr.append(chan_ydata)

                data_queue.append(list(yt_outArr))

                try:
                    self.packetCount += len(outArr[0])
                    self.sampleCount += len(outArr[0][0])
                except:
                    pass
            except IndexError:
                pass

    def GetData(self):
        """ Check if data ready from DelsysAPI via Aero CheckDataQueue() - Return True if data is ready
            Get data (PollData)
            Organize output channels by their GUID keys

            Return array of all channel data
        """

        dataReady = self.TrigBase.CheckDataQueue()                      # Check if DelsysAPI real-time data queue is ready to retrieve
        if dataReady:
            try:
                DataOut = self.TrigBase.PollData()                          # Dictionary<Guid, List<double>> (key = Guid (Unique channel ID), value = List(Y) (Y = sample value)
                if len(list(DataOut.Keys)) > 0:
                    outArr = [[] for i in range(len(self.trigno_base.channel_guids))]             # Set output array size to the amount of channels set during ConfigureCollectionOutput() in TrignoBase.py

                    for j in range(len(self.trigno_base.channel_guids)):            #Loop all channels set during configuration (default behavior is all channels unless updated)
                        chan_data = DataOut[self.trigno_base.channel_guids[j]]      # Index a single channels data from the dictionary based on unique channel GUID (key)
                        outArr[j].append(np.asarray(chan_data, dtype='object'))     # Create a NumPy array of the channel data and add to the output array

                    return outArr
            except Exception as e:
                print("Exception occured in GetData() - " + str(e))
        else:
            return None

    def GetYTData(self):
        """ YT Data stream only available when passing 'True' to Aero Start() command i.e. TrigBase.Start(True)
            Check if data ready from DelsysAPI via Aero CheckYTDataQueue() - Return True if data is ready
            Get data (PollYTData)
            Organize output channels by their GUID keys

            Return array of all channel data
        """

        dataReady = self.TrigBase.CheckYTDataQueue()                        # Check if DelsysAPI real-time data queue is ready to retrieve
        if dataReady:
            try:
                DataOut = self.TrigBase.PollYTData()                            # Dictionary<Guid, List<(double, double)>> (key = Guid (Unique channel ID), value = List<(T, Y)> (T = time stamp in seconds Y = sample value)
                if len(list(DataOut.Keys)) > 0:
                    outArr = [[] for i in range(len(self.trigno_base.channel_guids))]  # Set output array size to the amount of channels set during ConfigureCollectionOutput() in TrignoBase.py

                    for j in range(len(self.trigno_base.channel_guids)):            #Loop all channels set during configuration (default behavior is all channels unless updated)
                        chan_yt_data = DataOut[self.trigno_base.channel_guids[j]]    # Index a single channels data from the dictionary based on unique channel GUID (key)
                        outArr[j].append(np.asarray(chan_yt_data, dtype='object'))  # Create a NumPy array of the channel data and add to the output array

                    return outArr

            except Exception as e:
                print("Exception occured in GetYTData() - " + str(e))
        else:
            return None
