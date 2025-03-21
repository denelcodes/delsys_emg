function update_plot(sensor1_new, sensor2_new)

    % Persistent variables store cumulative data an d handles
    persistent hFig1 hFig2 hLine1 hLine2 sensor1_data sensor2_data

    % Initialize cumulative data if empty
    if isempty(sensor1_data)
        sensor1_data = [];
    end
    if isempty(sensor2_data)
        sensor2_data = [];
    end

    processed_sensor1 = process_data(sensor1_new);
    processed_sensor2 = process_data(sensor2_new);

    % processed_sensor1 = sensor1_new;
    % processed_sensor2 = sensor2_new;

    % assignin('base', 'sensor1_new', sensor1_new);

    % apppend new data to the cumulative history
    sensor1_data = [sensor1_data, processed_sensor1];
    sensor2_data = [sensor2_data, processed_sensor2];


    %Define threshold  for both sensors

    % Sensor 1 thresholds
    thresholds1.index_lower  = 0.004213576;
    thresholds1.index_upper  = 0.005482864;
    thresholds1.middle_lower = 0.002375097;
    thresholds1.middle_upper = 0.007241913;
    thresholds1.ring_lower   = 0.002664693;
    thresholds1.ring_upper   = 0.007166327;
    thresholds1.pinky_lower  = 0.002264329;
    thresholds1.pinky_upper  = 0.004432841;

    % Sensor 2 thresholds
    thresholds2.index_lower  = 0.009820486;
    thresholds2.index_upper  = 0.011985614;
    thresholds2.middle_lower = 0.004097787;
    thresholds2.middle_upper = 0.005650073;
    thresholds2.ring_lower   = 0.003733016;
    thresholds2.ring_upper   = 0.004955364;
    thresholds2.pinky_lower  = 0.008331226;
    thresholds2.pinky_upper  = 0.010205404;


    %Update Sensor 1 Plot 
    if isempty(hFig1) || ~isvalid(hFig1)
        % Create figure and initial plot for Sensor 1
        hFig1 = figure('Name', 'Sensor 1 Data');
        hLine1 = plot(sensor1_data);
        xlabel('Sample Index');
        ylabel('Sensor 1 Value');
        title('Real-Time Sensor 1 Data');
        grid on;

        hold on;
        % Add threshold lines for Sensor 1
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
        % Update the existing plot for Sensor 1
        set(hLine1, 'XData', 1:length(sensor1_data), 'YData', sensor1_data);
        drawnow;
        axis auto 
    end

    %  Update Sensor 2 Plot 
    if isempty(hFig2) || ~isvalid(hFig2)
        % Create figure and initial plot for Sensor 2
        hFig2 = figure('Name', 'Sensor 2 Data');
        hLine2 = plot(sensor2_data);
        xlabel('Sample Index');
        ylabel('Sensor 2 Value');
        title('Real-Time Sensor 2 Data');
        grid on;

        hold on;
        % Add threshold lines for Sensor 2
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
        % Update the existing plot for Sensor 2
        set(hLine2, 'XData', 1:length(sensor2_data), 'YData', sensor2_data);
        drawnow;
        axis auto 
    end


    % Use the threshold-checking function for each sensor
    check_threshold(sensor1_data, 'Sensor1', thresholds1);
    check_threshold(sensor2_data, 'Sensor2', thresholds2);


end


function processed = process_data(new_data)
    % Define sampling parameters
    Fs = 2148.148;         % Sampling frequency in Hz
    f_upper = 200;
    f_lower = 100;
    
    % Number of samples to average
    averagingsize = 800;
    
    % Low Pass Filter 
    cutoffFreq2 = 8;       % Cutoff frequency in Hz (adjust as needed)
    [b,a] = butter(2, cutoffFreq2/(Fs/2));

    % Bandpass the data to limit frequencies above f_upper and below f_lower
    bandpassed = bandpass(new_data,[f_lower f_upper],Fs);
    % Rectify (half-wave rectification)
    rectified = abs(bandpassed);

    averaged = movmean(rectified,averagingsize);

    processed = filtfilt(b, a, averaged);

end



function check_threshold(sensor_data, sensorLabel, thresholds)
    % Persistent structure to hold current state for each sensor
    persistent sensorStates
    if isempty(sensorStates)
        sensorStates = struct();
    end
    if ~isfield(sensorStates, sensorLabel)
        sensorStates.(sensorLabel) = '';
    end

    if ~isempty(sensor_data)
        currentValue = sensor_data(end);  % Latest envelope value
        newFinger = '';

        % Check thresholds in descending order of priority:
        if (currentValue >= thresholds.index_lower) && (currentValue <= thresholds.index_upper)
            newFinger = 'i';
        elseif (currentValue >= thresholds.middle_lower) && (currentValue <= thresholds.middle_upper)
            newFinger = 'm';
        elseif (currentValue >= thresholds.ring_lower) && (currentValue <= thresholds.ring_upper)
            newFinger = 'r';
        elseif (currentValue >= thresholds.pinky_lower) && (currentValue <= thresholds.pinky_upper)
            newFinger = 'p';
        end

        % Log event if threshold state has changed
        if ~isempty(newFinger) && ~strcmp(newFinger, sensorStates.(sensorLabel))
            log_threshold_event(sensorLabel, newFinger);
            sensorStates.(sensorLabel) = newFinger;
        end

        % Reset the trigger state if the signal falls below the pinky lower threshold
        if currentValue < thresholds.pinky_lower
            sensorStates.(sensorLabel) = '';
        end
    end
end


function log_threshold_event(sensorLabel, finger)
    % This function logs the threshold event to a text file and prints it to the console.
    fid_out = fopen('finger_output.txt', 'a');
    fprintf(fid_out, '%s: %s\n', sensorLabel, finger);
    fclose(fid_out);
    disp([sensorLabel ': ' finger]);
end