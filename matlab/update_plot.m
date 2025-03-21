function update_plot(sensor1_new, sensor2_new, pauseFlag)

    %needs to be tested
    if nargin < 3
        pauseFlag = false;
    end

    if pauseFlag
        disp('Plot update paused.');
        return;
    end


    % Persistent variables store cumulative data and handles
    persistent hFig1 hFig2 hLine1 hLine2 sensor1_data sensor2_data
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

    % Check thresholds for each sensor and update internal state
    check_threshold_generic(sensor1_data, 'Sensor1', thresholds1);
    check_threshold_generic(sensor2_data, 'Sensor2', thresholds2);
end

function processed = process_data(new_data)
    % Define sampling parameters
    Fs = 2148.148;         % Sampling frequency in Hz
    f_upper = 200;
    f_lower = 100;
    averagingsize = 800;     % Number of samples for moving average
    cutoffFreq2 = 8;         % Low-pass filter cutoff frequency in Hz
    [b,a] = butter(2, cutoffFreq2/(Fs/2));

    % Filter and process the data
    bandpassed = bandpass(new_data, [f_lower f_upper], Fs);
    rectified = abs(bandpassed);
    averaged = movmean(rectified, averagingsize);
    processed = filtfilt(b, a, averaged);
end

function check_threshold_generic(sensor_data, sensorLabel, thresholds)
    % Persistent structure to hold current state for each sensor
    persistent sensorStates
    if isempty(sensorStates)
        sensorStates = struct();
    end
    if ~isfield(sensorStates, sensorLabel)
        sensorStates.(sensorLabel) = '';
    end

    if ~isempty(sensor_data)
        currentValue = sensor_data(end);  % Latest processed value
        newFinger = '';

        % Check thresholds in order of priority: index > middle > ring > pinky
        if (currentValue >= thresholds.index_lower) && (currentValue <= thresholds.index_upper)
            newFinger = 'i';
        elseif (currentValue >= thresholds.middle_lower) && (currentValue <= thresholds.middle_upper)
            newFinger = 'm';
        elseif (currentValue >= thresholds.ring_lower) && (currentValue <= thresholds.ring_upper)
            newFinger = 'r';
        elseif (currentValue >= thresholds.pinky_lower) && (currentValue <= thresholds.pinky_upper)
            newFinger = 'p';
        end

        % Update the state if there is a change
        if ~isempty(newFinger) && ~strcmp(newFinger, sensorStates.(sensorLabel))
            sensorStates.(sensorLabel) = newFinger;
        end

        % Reset the state if the value falls below the pinky lower threshold
        if currentValue < thresholds.pinky_lower
            sensorStates.(sensorLabel) = '';
        end
    end
end


% --- New function that combines sensor states into one command string ---
function combined_cmd = get_combined_finger_command()
    % This function is intended to be called from Python via the MATLAB Engine API.
    % It returns a string with four comma-separated tokens representing:
    % [pinky, ring, middle, index]
    persistent sensorStates
    if isempty(sensorStates)
        sensorStates = struct('Sensor1','', 'Sensor2','');
    else
        if ~isfield(sensorStates, 'Sensor1')
            sensorStates.Sensor1 = '';
        end
        if ~isfield(sensorStates, 'Sensor2')
            sensorStates.Sensor2 = '';
        end
    end

    sensor1_cmd = sensorStates.Sensor1;
    sensor2_cmd = sensorStates.Sensor2;
    
    % For each finger, if either sensor indicates that finger, mark it active.
    pinky  = '';
    ring   = '';
    middle = '';
    index  = '';
    
    if strcmp(sensor1_cmd, 'p') || strcmp(sensor2_cmd, 'p')
        pinky = 'p';
    end
    if strcmp(sensor1_cmd, 'r') || strcmp(sensor2_cmd, 'r')
        ring = 'r';
    end
    if strcmp(sensor1_cmd, 'm') || strcmp(sensor2_cmd, 'm')
        middle = 'm';
    end
    if strcmp(sensor1_cmd, 'i') || strcmp(sensor2_cmd, 'i')
        index = 'i';
    end
    
    % Create the combined command string (exactly four comma-separated tokens)
    combined_cmd = [pinky, ring, middle, index];
end

