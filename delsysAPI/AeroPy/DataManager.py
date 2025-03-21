import numpy as np
import matlab.engine
import os

class DataKernel():
    def __init__(self, trigno_base):
        self.trigno_base = trigno_base
        self.TrigBase = trigno_base.TrigBase
        
        self.packetCount = 0
        self.sampleCount = 0

        # These lists store the entire history of data for each channel.
        # Make sure you have as many sublists here as you have channels.
        # If your code configures e.g. 2 channels in trigno_base.channel_guids,
        # you’ll have 2 empty lists below.
        self.channel_guids = self.trigno_base.channel_guids  # or however you retrieve them
        self.allcollectiondata = [[] for _ in range(len(self.channel_guids))]
        
        self.channel1time = []

        # Start MATLAB engine
        self.eng = matlab.engine.start_matlab()

        # add the folder containing 'update_plot.m' to the MATLAB path NOT the .m file itself
        # Adjust this path to point to the folder, not the file.
        matlab_folder = r"C:\Users\Den\OneDrive - University of Southampton\4th_year\Medical\delsys_emg\matlab"
        self.eng.addpath(matlab_folder, nargout=0)

        # Optional: Confirm that MATLAB can find 'update_plot.m'
        found_func = self.eng.which('update_plot.m', nargout=1)
        print("MATLAB sees update_plot.m at:", found_func)

        # Initialize local sensor histories for your real-time plotting
        self.sensor1_history = []
        self.sensor2_history = []

    def processData(self, data_queue):
        """
        Processes the real-time data from the Delsys API, writes sensor data
        to a queue, and calls into MATLAB to update/plot the data.
        """
        outArr = self.GetData()
        
        if outArr is not None:
            # Extract the new samples for each sensor
            sensor1_new = []
            sensor2_new = []

            if len(outArr) > 0 and len(outArr[0]) > 0:
                sensor1_new = outArr[0][0].tolist()
            if len(outArr) > 1 and len(outArr[1]) > 0:
                sensor2_new = outArr[1][0].tolist()

            # append data
            self.sensor1_history.extend(sensor1_new)
            self.sensor2_history.extend(sensor2_new)

            #  call MATLAB with only the new data
            self.eng.update_plot(
                matlab.double(sensor1_new),
                matlab.double(sensor2_new),
                nargout=0
            )

            print(sensor1_new)
            print(sensor2_new)

            # ------------------------------------------------
            # original code to process data for internal storage + queue stuff
            # --------------------------------------------------------
            for i in range(len(outArr)):
                # Extend each channel’s historical list with new samples
                self.allcollectiondata[i].extend(outArr[i][0].tolist())

            # Now enqueue data packets
            try:
                # outArr[0] is the first channel’s data
                # We assume each channel has the same number of packets
                for i in range(len(outArr[0])):
                    # If the data for the first sensor is 1D, only one packet
                    if np.asarray(outArr[0]).ndim == 1:
                        data_queue.append(list(np.asarray(outArr, dtype='object')[0]))
                    else:
                        # Extract the i-th data packet from each channel
                        data_queue.append(list(np.asarray(outArr, dtype='object')[:, i]))

                # Update counters (packets & samples)
                try:
                    self.packetCount += len(outArr[0])          # number of packets
                    self.sampleCount += len(outArr[0][0])       # samples per packet in sensor 0
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
