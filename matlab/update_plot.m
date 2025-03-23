function update_plot(sensor1_new, sensor2_new, pauseFlag)
    % needs to be tested
    if nargin < 3
        pauseFlag = false;
    end

    if pauseFlag
        disp('Plot update paused.');
        return;
    end

    % persistent variables store cumulative data, and arduino serial local scope
    persistent hFig1 hFig2 hLine1 hLine2 sensor1_data sensor2_data arduinoSerial
    if isempty(sensor1_data)
        sensor1_data = [];
    end
    if isempty(sensor2_data)
        sensor2_data = [];
    end

    % Process the incoming sensor data
    processed_sensor1 = process_data(sensor1_new);
    processed_sensor2 = process_data(sensor2_new);

    % Append new data to the cumulative history
    sensor1_data = [sensor1_data, processed_sensor1];
    sensor2_data = [sensor2_data, processed_sensor2];

    % Define threshold structures for both sensors
    % Sensor 1 thresholds
    thresholds1.index_lower  = 0.0020;
    thresholds1.index_upper  = 0.0040;
    thresholds1.middle_lower = 0.0035;
    thresholds1.middle_upper = 0.0082;
    thresholds1.ring_lower   = 0.0031;
    thresholds1.ring_upper   = 0.0037;
    thresholds1.pinky_lower  = 0.00371;
    thresholds1.pinky_upper  = 0.005;

    % Sensor 2 thresholdss
    thresholds2.index_lower  = 0.00571;
    thresholds2.index_upper  = 0.009;
    thresholds2.middle_lower = 0.0021;
    thresholds2.middle_upper = 0.0057;
    thresholds2.ring_lower   = 0.0085;
    thresholds2.ring_upper   = 0.0200;
    thresholds2.pinky_lower  = 0.0096;
    thresholds2.pinky_upper  = 0.0130;

    %% Update Sensor 1 Plot 
    if isempty(hFig1) || ~isvalid(hFig1)
        hFig1 = figure('Name', 'Sensor 1 Data');
        hLine1 = plot(sensor1_data);
        xlabel('Sample Index');
        ylabel('Sensor 1 Value');
        title('Real-Time Sensor 1 Data');
        grid on;
        hold on;
        yline(thresholds1.index_lower, '--r', 'Index Lower');
        yline(thresholds1.index_upper, '--r', 'Index Upper');
        yline(thresholds1.middle_lower, '--g', 'Middle Lower');
        yline(thresholds1.middle_upper, '--g', 'Middle Upper');
        yline(thresholds1.ring_lower, '--b', 'Ring Lower');
        yline(thresholds1.ring_upper, '--b', 'Ring Upper');
        yline(thresholds1.pinky_lower, '--k', 'Pinky Lower');
        yline(thresholds1.pinky_upper, '--k', 'Pinky Upper');
        hold off;
    else
        set(hLine1, 'XData', 1:length(sensor1_data), 'YData', sensor1_data);
        drawnow;
        axis auto;
    end

    %% Update Sensor 2 Plot 
    if isempty(hFig2) || ~isvalid(hFig2)
        hFig2 = figure('Name', 'Sensor 2 Data');
        hLine2 = plot(sensor2_data);
        xlabel('Sample Index');
        ylabel('Sensor 2 Value');
        title('Real-Time Sensor 2 Data');
        grid on;
        hold on;
        yline(thresholds2.index_lower, '--r', 'Index Lower');
        yline(thresholds2.index_upper, '--r', 'Index Upper');
        yline(thresholds2.middle_lower, '--g', 'Middle Lower');
        yline(thresholds2.middle_upper, '--g', 'Middle Upper');
        yline(thresholds2.ring_lower, '--b', 'Ring Lower');
        yline(thresholds2.ring_upper, '--b', 'Ring Upper');
        yline(thresholds2.pinky_lower, '--k', 'Pinky Lower');
        yline(thresholds2.pinky_upper, '--k', 'Pinky Upper');
        hold off;
    else
        set(hLine2, 'XData', 1:length(sensor2_data), 'YData', sensor2_data);
        drawnow;
        axis auto;
    end

    % get the finger value based on current sensor data and thresholds
    finger = check_threshold(sensor1_data, sensor2_data, thresholds1, thresholds2);

    % if  finger detected send it to arduino via serial port 
    if ~isempty(finger)
        if isempty(arduinoSerial) || ~isvalid(arduinoSerial)
            arduinoSerial = serialport('COM6', 9600);
        end
        writeline(arduinoSerial, finger);
        fprintf('Sent finger: %c\n', finger)
         
        % just in case Write the finger into a text file
        % fid = fopen('finger_log.txt', 'a');
        % fprintf(fid, '%c\n', finger);
        % fclose(fid);
    end
end


function processed = process_data(new_data)
    % Define sampling parameters
    Fs = 2148.148;         % Sampling frequency in Hz
    f_upper = 200;
    f_lower = 100;
    averagingsize = 800;     % Number of samples for moving average
    cutoffFreq2 = 7;         % Low-pass filter cutoff frequency in Hz
    [b,a] = butter(2, cutoffFreq2/(Fs/2));

    % Filter and process the data
    bandpassed = bandpass(new_data, [f_lower f_upper], Fs);
    rectified = abs(bandpassed);
    averaged = movmean(rectified, averagingsize);
    processed = filtfilt(b, a, averaged);
end

function finger = check_threshold(sensor_data1, sensor_data2, thresholds1, thresholds2)
    finger = ''; % Default is no finger detected
    if ~isempty(sensor_data1) && ~isempty(sensor_data2)
       currentValue1 = sensor_data1(end);  % Latest processed value from sensor_data1
       currentValue2 = sensor_data2(end);  

       % Check thresholds and assign the corresponding letter to "finger" LOGIC/ALGORITHM 
       if thresholds1.middle_lower <= currentValue1 && currentValue1 <= thresholds1.middle_upper && ...
          thresholds2.middle_lower <= currentValue2 && currentValue2 <= thresholds2.middle_upper
           finger = 'm';
       elseif thresholds1.pinky_lower <= currentValue1 && currentValue1 <= thresholds1.pinky_upper && ...
              thresholds2.pinky_lower <= currentValue2 && currentValue2 <= thresholds2.pinky_upper
           finger = 'p';
       elseif thresholds1.ring_lower <= currentValue1 && currentValue1 <= thresholds1.ring_upper && ...
              thresholds2.ring_lower <= currentValue2 && currentValue2 <= thresholds2.ring_upper && ...
              currentValue2 >= thresholds2.index_upper  
           finger = 'r';
       elseif thresholds1.index_lower <= currentValue1 && currentValue1 <= thresholds1.index_upper && ...
              thresholds2.index_lower <= currentValue2 && currentValue2 <= thresholds2.index_upper
           finger = 'i';
       end
    end
end



