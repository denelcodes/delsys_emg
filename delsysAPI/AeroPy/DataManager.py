"""
This is the class that handles the data that is output from the Delsys Trigno Base.
Create an instance of this and pass it a reference to the Trigno base for initialization.
See CollectDataController.py for a usage example.
"""
import numpy as np
import matlab.engine

class DataKernel():
    def __init__(self, trigno_base):
        self.trigno_base = trigno_base
        self.TrigBase = trigno_base.TrigBase
        self.packetCount = 0
        self.sampleCount = 0
        self.allcollectiondata = []
        self.channel1time = []
        self.channel_guids = []
        
        # Start MATLAB engine
        self.eng = matlab.engine.start_matlab()

        # (Optional) if you need to add the folder that contains 'update_plot.m' to the MATLAB path
        # self.eng.addpath(r'C:\path\to\folder\with\update_plot')

        # Example: set up filter parameters in Python if needed,
        # or you can keep everything in MATLAB.

        # Initialize local sensor histories
        self.sensor1_history = []
        self.sensor2_history = []

    def processData(self, data_queue):
        """Processes the data from the DelsysAPI, writes sensor data to a text file in a simple format, and places it in the data_queue argument"""
        # Retrieve data from the DelsysAPI via the GetData method
        # call GetData() to retrieve new data
        # outArr will be a list of lists where each inner list corresponds to one sensor's data.
        outArr = self.GetData()  
        
        # check if outArr contian data Only process if new data is available
        if outArr is not None:
            
            # extract the new samples for each sensor
            sensor1_new = []
            sensor2_new = []

            #  outArr[0] is sensor1, outArr[1] is sensor2, etc
            if len(outArr) > 0 and len(outArr[0]) > 0:
                sensor1_new = outArr[0][0].tolist()
            if len(outArr) > 1 and len(outArr[1]) > 0:
                sensor2_new = outArr[1][0].tolist()

            # Append these new samples to our local histories
            self.sensor1_history.extend(sensor1_new)
            self.sensor2_history.extend(sensor2_new)

            # -----------------------------------------------------------
            #  call into MATLAB to process & plot everything
            # Pass the entire history each time
            # We need to convert Python lists to MATLAB arrays, e.g. matlab.double()
            # If your data is large, you may want a more optimized approach.
            # -----------------------------------------------------------
            self.eng.update_plot(
                matlab.double(self.sensor1_history),
                matlab.double(self.sensor2_history),
                nargout=0  # no output expected
            )


        #-------- orginal code that processes the data further for internal storage + queueing

            # For each sensor extend its existing data collection with the new data
            # for i in range(len(outArr)) goes through each index i corresponding to a sensor If outArr has data for 2 sensors, i will be 0, 1,
            for i in range(len(outArr)):
                # Convert the sensor data (assumed to be in the first element of each sublist) to a list 
                # and append it to the corresponding sensor's stored data in allcollectiondata
                self.allcollectiondata[i].extend(outArr[i][0].tolist()) # self.allcollectiondata[i]  is the list that holds all previously collected data for the sensor at index i
            try:
                #iterates over each packet in the first sensor’s data 
                # Since all sensors are expected to have the same number of packets
                # this loop also corresponds to the packets in the other sensors.
                for i in range(len(outArr[0])):
                    # It checks if the data for the first sensor is one-dimensional.
                    #If 1D then it means there's only one packet of data, and  code handles it in a straightforward way.
                    if np.asarray(outArr[0]).ndim == 1:
                        # This takes the first sensor's data and appends it to the queue as a list.
                        data_queue.append(list(np.asarray(outArr, dtype='object')[0]))
                    else:
                        #This extracts the ith data packet from each sensor 
                        data_queue.append(list(np.asarray(outArr, dtype='object')[:, i]))
                try:
                     # Update the packet counter by adding the number of packets from sensor 0.
                    self.packetCount += len(outArr[0])
                    # Update the sample counter by adding the number of samples in the first packet of sensor 0.
                    self.sampleCount += len(outArr[0][0])
                except Exception as e:
                    print("Exception updating counters:", e)
            except IndexError as e:
                print("Index error in processing data:", e)

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
