% live_plot_separate_thresholds.m
% This script continuously reads raw_emg_data.txt (written by your Python code),
% accumulates sensor data, processes it in three stages, and displays the results 
% in separate figures.
%
% Processing stages for each sensor:
%   1. Raw Live Data
%   2. Band-Pass Filtered + Absolute Value
%   3. Low-Pass Filtered (Smoothed Envelope) with Threshold Lines
%
% Threshold lines for four finger groups (Pinky, Ring, Middle, Index) are
% drawn only on the low-pass smoothed envelope plots.

%% Threshold Variables (adjust as needed)
% Sensor 1 thresholds
sensor1_pinky_lower  = 0.002264329;
sensor1_pinky_upper  = 0.004432841;
sensor1_ring_lower   = 0.002664693;
sensor1_ring_upper   = 0.007166327;
sensor1_middle_lower = 0.002375097;
sensor1_middle_upper = 0.007241913;
sensor1_index_lower  = 0.004213576;
sensor1_index_upper  = 0.005482864;

% Sensor 2 thresholds
sensor2_pinky_lower  = 0.008331226;
sensor2_pinky_upper  = 0.010205404;
sensor2_ring_lower   = 0.003733016;
sensor2_ring_upper   = 0.004955364;
sensor2_middle_lower = 0.004097787;
sensor2_middle_upper = 0.005650073;
sensor2_index_lower  = 0.009820486;
sensor2_index_upper  = 0.011985614;

%% Filter Design Parameters
Fs = 1000;  % Sampling frequency in Hz

% Butterworth band-pass filter (e.g., 20-450 Hz for EMG)
order_bp = 2;
low_cutoff = 20;   % Hz
high_cutoff = 450; % Hz
[b_bp, a_bp] = butter(order_bp, [low_cutoff high_cutoff] / (Fs/2));

% Butterworth low-pass filter for envelope smoothing (e.g., 4 Hz cutoff)
order_lp = 2;
lp_cutoff = 4;   % Hz
[b_lp, a_lp] = butter(order_lp, lp_cutoff / (Fs/2));

%% Initialize History Arrays
sensor1_history = [];
sensor2_history = [];

% Initialize state variables for threshold detection
sensor1_current_finger = '';
sensor2_current_finger = '';

% Create figures for Sensor 1 and Sensor 2
figure(1); % Sensor 1
figure(2); % Sensor 2

while true
    % Open the file for reading
    fid = fopen('raw_emg_data.txt', 'r');
    if fid == -1
        disp('Cannot open file. Check the filename or file path.');
        pause(1);
        continue;
    end
    
    % Read entire file content as a string
    fileText = fscanf(fid, '%c');
    fclose(fid);
    
    % --- Updated Regular Expressions ---
    % The regex now allows additional text between the sensor number and the colon.
    sensor1_tokens = regexp(fileText, 'Sensor\s*1.*?:\s*\[(.*?)\]', 'tokens');
    sensor2_tokens = regexp(fileText, 'Sensor\s*2.*?:\s*\[(.*?)\]', 'tokens');
    
    % Convert tokens to numeric arrays if available
    if ~isempty(sensor1_tokens)
        sensor1_data = str2num(sensor1_tokens{1}{1});  %#ok<ST2NM>
    else
        sensor1_data = [];
    end
    
    if ~isempty(sensor2_tokens)
        sensor2_data = str2num(sensor2_tokens{1}{1});  %#ok<ST2NM>
    else
        sensor2_data = [];
    end
    
    % Append new data to the cumulative history
    sensor1_history = [sensor1_history, sensor1_data];
    sensor2_history = [sensor2_history, sensor2_data];
    
    % --- Processing Sensor Data ---
    % Stage 1 & 2: Band-Pass Filter then take Absolute Value
    sensor1_bp_abs = abs(filter(b_bp, a_bp, sensor1_history));
    sensor2_bp_abs = abs(filter(b_bp, a_bp, sensor2_history));
    
    % Stage 3: Low-Pass Filter for envelope smoothing
    sensor1_env = filter(b_lp, a_lp, sensor1_bp_abs);
    sensor2_env = filter(b_lp, a_lp, sensor2_bp_abs);

    % Stage 4: Averaging
    averaging1 = size(sensor1_env);
    averaging2 = size(sensor2_env);

    for i = 1:floor(length(sensor1_env))/4:length(sensor1_env)
        idx = i:min(i+floor(length(sensor1_env))-1, length(sensor1_env)); % Get indices for the current group
        avgValue = mean(sensor1_env(idx)); % Compute the mean of the  values
        averaging1(idx) = avgValue; % Assign the mean to all  positions
    end

    for i = 1:floor(length(sensor2_env))/4:length(sensor2_env)
        idx = i:min(i+floor(length(sensor2_env))-1, length(sensor2_env)); % Get indices for the current group
        avgValue = mean(sensor2_env(idx)); % Compute the mean of the values
        averaging2(idx) = avgValue; % Assign the mean to all positions
    end
    
    % Stage 5: Low pass filter again
    cutoffFreq2 = 3;       % Cutoff frequency in Hz (adjust as needed)
    [b2,a2] = butter(2, cutoffFreq2/(Fs/2));
    sensor1_env = filtfilt(b2, a2, averaging1);
    sensor2_env = filtfilt(b2, a2, averaging2);

    % --- Check for Sensor 1 Threshold Crossing ---
    if ~isempty(sensor1_env)
        currentValue = sensor1_env(end);  % Latest envelope value for Sensor 1
        newFinger = '';  % Determine which threshold is currently met
    
        % Check thresholds in descending order (higher thresholds take precedence)
        if currentValue >= sensor1_index_lower
            newFinger = 'i';
        elseif currentValue >= sensor1_middle_lower
            newFinger = 'm';
        elseif currentValue >= sensor1_ring_lower
            newFinger = 'r';
        elseif currentValue >= sensor1_pinky_lower
            newFinger = 'p';
        end
    
        % Log new event only if the threshold state has changed
        if ~isempty(newFinger) && ~strcmp(newFinger, sensor1_current_finger)
            fid_out = fopen('finger_output.txt', 'a');
            fprintf(fid_out, 'Sensor1: %s\n', newFinger);
            fclose(fid_out);
            disp(['Sensor 1: ' newFinger]);  % Print to console
            sensor1_current_finger = newFinger;
        end
 
        % Reset the trigger state when the signal drops below the pinky threshold
        if currentValue < sensor1_pinky_lower
            sensor1_current_finger = '';
        end
    end
    
    % --- Check for Sensor 2 Threshold Crossing ---
    if ~isempty(sensor2_env)
        currentValue2 = sensor2_env(end);  % Latest envelope value for Sensor 2
        newFinger2 = '';
    
        if currentValue2 >= sensor2_index_lower
            newFinger2 = 'i';
        elseif currentValue2 >= sensor2_middle_lower
            newFinger2 = 'm';
        elseif currentValue2 >= sensor2_ring_lower
            newFinger2 = 'r';
        elseif currentValue2 >= sensor2_pinky_lower
            newFinger2 = 'p';
        end
            
        % Log new event only if the threshold state has changed
        if ~isempty(newFinger2) && ~strcmp(newFinger2, sensor2_current_finger)
            fid_out = fopen('finger_output.txt', 'a');
            fprintf(fid_out, 'Sensor2: %s\n', newFinger2);
            fclose(fid_out);
            disp(['Sensor 2: ' newFinger2]);  % Print to console
            sensor2_current_finger = newFinger2;
        end

        if currentValue2 < sensor2_pinky_lower
            sensor2_current_finger = '';
        end
    end
    
    % --- Plotting for Sensor 1 ---
    figure(1);
    clf;  % Clear figure
    % Subplot 1: Raw Data
    subplot(3,1,1);
    plot(sensor1_history, 'b');
    title('Sensor 1: Raw Data');
    xlabel('Sample Number'); ylabel('Amplitude');
    
    % Subplot 2: Band-Pass Filtered + Absolute Value
    subplot(3,1,2);
    plot(sensor1_bp_abs, 'b');
    title('Sensor 1: Band-Pass + Abs');
    xlabel('Sample Number'); ylabel('Amplitude');
    
    % Subplot 3: Low-Pass Smoothed Envelope with Threshold Lines
    subplot(3,1,3);
    plot(sensor1_env, 'b');
    title('Sensor 1: Low-Pass Smoothed Envelope');
    xlabel('Sample Number'); ylabel('Amplitude');
    hold on;
    yline(sensor1_pinky_lower, '--g', 'Pinky Lower');
    yline(sensor1_pinky_upper, '--g', 'Pinky Upper');
    yline(sensor1_ring_lower, '--m', 'Ring Lower');
    yline(sensor1_ring_upper, '--m', 'Ring Upper');
    yline(sensor1_middle_lower, '--c', 'Middle Lower');
    yline(sensor1_middle_upper, '--c', 'Middle Upper');
    yline(sensor1_index_lower, '--k', 'Index Lower');
    yline(sensor1_index_upper, '--k', 'Index Upper');
    hold off;
    
    % --- Plotting for Sensor 2 ---
    figure(2);
    clf;  % Clear figure
    % Subplot 1: Raw Data
    subplot(3,1,1);
    plot(sensor2_history, 'r');
    title('Sensor 2: Raw Data');
    xlabel('Sample Number'); ylabel('Amplitude');
    
    % Subplot 2: Band-Pass Filtered + Absolute Value
    subplot(3,1,2);
    plot(sensor2_bp_abs, 'r');
    title('Sensor 2: Band-Pass + Abs');
    xlabel('Sample Number'); ylabel('Amplitude');
    
    % Subplot 3: Low-Pass Smoothed Envelope with Threshold Lines
    subplot(3,1,3);
    plot(sensor2_env, 'r');
    title('Sensor 2: Low-Pass Smoothed Envelope');
    xlabel('Sample Number'); ylabel('Amplitude');
    hold on;
    yline(sensor2_pinky_lower, '--g', 'Pinky Lower');
    yline(sensor2_pinky_upper, '--g', 'Pinky Upper');
    yline(sensor2_ring_lower, '--m', 'Ring Lower');
    yline(sensor2_ring_upper, '--m', 'Ring Upper');
    yline(sensor2_middle_lower, '--c', 'Middle Lower');
    yline(sensor2_middle_upper, '--c', 'Middle Upper');
    yline(sensor2_index_lower, '--k', 'Index Lower');
    yline(sensor2_index_upper, '--k', 'Index Upper');
    hold off;
    
    drawnow;
    pause(0.5);  % Adjust pause interval as needed
end

