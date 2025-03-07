% live_plot_separate_thresholds.m
% This script continuously reads live_data.txt, accumulates sensor data,
% processes it in three stages, and displays the results in separate figures.
%
% For each sensor, the processing stages are:
%   1. Raw Live Data
%   2. Band-Pass Filtered + Absolute Value
%   3. Low-Pass Filtered (Smoothed Envelope) with Threshold Lines
%
% Threshold lines for four finger groups (Pinky, Ring, Middle, Index) are
% drawn only on the low-pass smoothed envelope plots.

%% Threshold Variables change these pls
% Sensor 1 thresholds
sensor1_pinky_lower  = 0.01;
sensor1_pinky_upper  = 0.02;
sensor1_ring_lower   = 0.02;
sensor1_ring_upper   = 0.03;
sensor1_middle_lower = 0.03;
sensor1_middle_upper = 0.04;
sensor1_index_lower  = 0.04;
sensor1_index_upper  = 0.05;

% Sensor 2 thresholds
sensor2_pinky_lower  = 0.01;
sensor2_pinky_upper  = 0.02;
sensor2_ring_lower   = 0.02;
sensor2_ring_upper   = 0.03;
sensor2_middle_lower = 0.03;
sensor2_middle_upper = 0.04;
sensor2_index_lower  = 0.04;
sensor2_index_upper  = 0.05;

%% Filter Design Parameters
fs = 1000;  % Sampling frequency in Hz (adjust as needed)

% Butterworth band-pass filter (e.g., 20-450 Hz for EMG)
order_bp = 4;
low_cutoff = 20;   % Hz
high_cutoff = 450; % Hz
[b_bp, a_bp] = butter(order_bp, [low_cutoff high_cutoff] / (fs/2));

% Butterworth low-pass filter for envelope smoothing (e.g., 4 Hz cutoff)
order_lp = 4;
lp_cutoff = 4;   % Hz
[b_lp, a_lp] = butter(order_lp, lp_cutoff / (fs/2));

%% Initialize History Arrays
sensor1_history = [];
sensor2_history = [];

% Create two figures (one for each sensor)
figure(1); % Sensor 1
figure(2); % Sensor 2

while true
    % Open the file for reading
    fid = fopen('live_data.txt', 'r');
    if fid == -1
        disp('Cannot open file. Check the filename or file path.');
        pause(1);
        continue;
    end
    
    % Read entire file content as a string
    fileText = fscanf(fid, '%c');
    fclose(fid);
    
    % Extract sensor data using regular expressions
    sensor1_tokens = regexp(fileText, 'Sensor\s*1:\s*\[(.*?)\]', 'tokens');
    sensor2_tokens = regexp(fileText, 'Sensor\s*2:\s*\[(.*?)\]', 'tokens');
    
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
    % For each sensor: 
    %   1. Band-Pass Filter then take Absolute Value
    %   2. Low-Pass Filter for envelope smoothing
    sensor1_bp_abs = abs(filter(b_bp, a_bp, sensor1_history));
    sensor1_env    = filter(b_lp, a_lp, sensor1_bp_abs);
    
    sensor2_bp_abs = abs(filter(b_bp, a_bp, sensor2_history));
    sensor2_env    = filter(b_lp, a_lp, sensor2_bp_abs);
    
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
    
    % Subplot 3: Low-Pass Smoothed Envelope with Thresholds
    subplot(3,1,3);
    plot(sensor1_env, 'b');
    title('Sensor 1: Low-Pass Smoothed Envelope');
    xlabel('Sample Number'); ylabel('Amplitude');
    hold on;
    yline(sensor1_pinky_lower,  '--g', 'Pinky Lower');
    yline(sensor1_pinky_upper,  '--g', 'Pinky Upper');
    yline(sensor1_ring_lower,   '--m', 'Ring Lower');
    yline(sensor1_ring_upper,   '--m', 'Ring Upper');
    yline(sensor1_middle_lower, '--c', 'Middle Lower');
    yline(sensor1_middle_upper, '--c', 'Middle Upper');
    yline(sensor1_index_lower,  '--k', 'Index Lower');
    yline(sensor1_index_upper,  '--k', 'Index Upper');
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
    
    % Subplot 3: Low-Pass Smoothed Envelope with Thresholds
    subplot(3,1,3);
    plot(sensor2_env, 'r');
    title('Sensor 2: Low-Pass Smoothed Envelope');
    xlabel('Sample Number'); ylabel('Amplitude');
    hold on;
    yline(sensor2_pinky_lower,  '--g', 'Pinky Lower');
    yline(sensor2_pinky_upper,  '--g', 'Pinky Upper');
    yline(sensor2_ring_lower,   '--m', 'Ring Lower');
    yline(sensor2_ring_upper,   '--m', 'Ring Upper');
    yline(sensor2_middle_lower, '--c', 'Middle Lower');
    yline(sensor2_middle_upper, '--c', 'Middle Upper');
    yline(sensor2_index_lower,  '--k', 'Index Lower');
    yline(sensor2_index_upper,  '--k', 'Index Upper');
    hold off;
    
    drawnow;
    pause(0.5);  % Adjust pause interval as needed
end
