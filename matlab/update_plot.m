% function update_plot(sensor1_data, sensor2_data)
%     % UPDATE_PLOT  Processes and plots EMG data from two sensors.
% 
%     %% -----------------------------
%     % 1) Make filter coefficients, etc. persistent so they are not rebuilt
%     %    every function call.
%     %% -----------------------------
%     persistent b_bp a_bp b_lp a_lp fs ...
%                sensor1_current_finger sensor2_current_finger ...
%                fig1 fig2
% 
%     if isempty(fs)
%         % Initialize filter parameters once
%         fs = 2148.148;  % Sampling frequency in Hz
% 
%         % Butterworth band-pass filter (e.g., 100-200 Hz for your EMG)
%         order_bp    = 2;
%         low_cutoff  = 100;   % Hz
%         high_cutoff = 200;   % Hz
%         [b_bp, a_bp] = butter(order_bp, [low_cutoff high_cutoff] / (fs/2));
% 
%         % Butterworth low-pass filter for envelope smoothing (e.g., 10 Hz)
%         order_lp = 2;
%         lp_cutoff = 10;   % Hz
%         [b_lp, a_lp] = butter(order_lp, lp_cutoff / (fs/2));
% 
%         sensor1_current_finger = '';
%         sensor2_current_finger = '';
% 
%         % Create figures once
%         fig1 = figure('Name','Sensor 1','NumberTitle','off');
%         fig2 = figure('Name','Sensor 2','NumberTitle','off');
%     end
% 
%     %% -----------------------------
%     % 2) Threshold Variables
%     %% -----------------------------
%     sensor1_pinky_lower  = 0.002264329;
%     sensor1_pinky_upper  = 0.004432841;
%     sensor1_ring_lower   = 0.002664693;
%     sensor1_ring_upper   = 0.007166327;
%     sensor1_middle_lower = 0.002375097;
%     sensor1_middle_upper = 0.007241913;
%     sensor1_index_lower  = 0.004213576;
%     sensor1_index_upper  = 0.005482864;
% 
%     sensor2_pinky_lower  = 0.008331226;
%     sensor2_pinky_upper  = 0.010205404;
%     sensor2_ring_lower   = 0.003733016;
%     sensor2_ring_upper   = 0.004955364;
%     sensor2_middle_lower = 0.004097787;
%     sensor2_middle_upper = 0.005650073;
%     sensor2_index_lower  = 0.009820486;
%     sensor2_index_upper  = 0.011985614;
% 
%     %% -----------------------------
%     % 3) Convert input to row vectors & do filtering
%     %% -----------------------------
%     sensor1_history = sensor1_data(:).';  % ensure row
%     sensor2_history = sensor2_data(:).';
% 
% 
%     % --- Processing Sensor Data ---
%     % Stage 1 & 2: Band-Pass Filter + Absolute Value
%     sensor1_bp_abs = abs(filter(b_bp, a_bp, sensor1_history));
%     sensor2_bp_abs = abs(filter(b_bp, a_bp, sensor2_history));
% 
%     % Stage 3: First Low-Pass Filter (Envelope)
%     sensor1_env = filter(b_lp, a_lp, sensor1_bp_abs);
%     sensor2_env = filter(b_lp, a_lp, sensor2_bp_abs);
% 
%     % % Stage 4: Averaging
%     % averaging1 = size(sensor1_env);
%     % averaging2 = size(sensor2_env);
%     % for i = 1:length(sensor1_env)
%     %     averaging1(i) = mean(sensor1_env);
%     % end
%     % for i = 1:length(sensor2_env)
%     %     averaging2(i) = mean(sensor2_env);
%     % end
%     % 
%     % % Stage 5: Low pass filter again
%     % cutoffFreq2 = 3;       % Cutoff frequency in Hz (adjust as needed)
%     % [b2,a2] = butter(2, cutoffFreq2/(fs/2));
%     % sensor1_env = filtfilt(b2, a2, averaging1);
%     % sensor2_env = filtfilt(b2, a2, averaging2);
%     % 
%     % %% -----------------------------
%     % Threshold detection (Sensor 1)
%     %% -----------------------------
%     if ~isempty(sensor1_env)
%         currentValue = sensor1_env(end);
%         newFinger = '';
%         if currentValue >= sensor1_index_lower
%             newFinger = 'i';
%         elseif currentValue >= sensor1_middle_lower
%             newFinger = 'm';
%         elseif currentValue >= sensor1_ring_lower
%             newFinger = 'r';
%         elseif currentValue >= sensor1_pinky_lower
%             newFinger = 'p';
%         end
% 
%         if ~isempty(newFinger) && ~strcmp(newFinger, sensor1_current_finger)
%             fid_out = fopen('finger_output.txt', 'a');
%             fprintf(fid_out, 'Sensor1: %s\n', newFinger);
%             fclose(fid_out);
%             disp(['Sensor 1: ' newFinger]);
%             sensor1_current_finger = newFinger;
%         end
% 
%         if currentValue < sensor1_pinky_lower
%             sensor1_current_finger = '';
%         end
%     end
% 
%     %% -----------------------------
%     % Threshold detection (Sensor 2)
%     %% -----------------------------
%     if ~isempty(sensor2_env)
%         currentValue2 = sensor2_env(end);
%         newFinger2 = '';
%         if currentValue2 >= sensor2_index_lower
%             newFinger2 = 'i';
%         elseif currentValue2 >= sensor2_middle_lower
%             newFinger2 = 'm';
%         elseif currentValue2 >= sensor2_ring_lower
%             newFinger2 = 'r';
%         elseif currentValue2 >= sensor2_pinky_lower
%             newFinger2 = 'p';
%         end
% 
%         if ~isempty(newFinger2) && ~strcmp(newFinger2, sensor2_current_finger)
%             fid_out = fopen('finger_output.txt', 'a');
%             fprintf(fid_out, 'Sensor2: %s\n', newFinger2);
%             fclose(fid_out);
%             disp(['Sensor 2: ' newFinger2]);
%             sensor2_current_finger = newFinger2;
%         end
% 
%         if currentValue2 < sensor2_pinky_lower
%             sensor2_current_finger = '';
%         end
%     end
% 
%     %% -----------------------------
%     % Plot results
%     %% -----------------------------
%     figure(fig1);
%     % clf;
%     % Subplot 1: Raw
%     subplot(3,1,1);
%     plot(sensor1_history, 'b');
%     title('Sensor 1: Raw');
%     xlabel('Sample'); ylabel('Amplitude');
%     ylim([-0.5 0.5])
% 
%     % Subplot 2: Band-Pass + Abs
%     subplot(3,1,2);
%     plot(sensor1_bp_abs, 'b');
%     title('Sensor 1: BP + Abs');
%     xlabel('Sample'); ylabel('Amplitude');
%     ylim([0 0.5])
% 
%     % Subplot 3: Envelope w/ thresholds
%     subplot(3,1,3);
%     plot(sensor1_env, 'b');
%     title('Sensor 1: Envelope (After 2nd LP)');
%     xlabel('Sample'); ylabel('Amplitude');
%     ylim([0 0.5])
% 
%     hold on;
%     yline(sensor1_pinky_lower,  '--g', 'Pinky Lower');
%     yline(sensor1_pinky_upper,  '--g', 'Pinky Upper');
%     yline(sensor1_ring_lower,   '--m', 'Ring Lower');
%     yline(sensor1_ring_upper,   '--m', 'Ring Upper');
%     yline(sensor1_middle_lower, '--c', 'Middle Lower');
%     yline(sensor1_middle_upper, '--c', 'Middle Upper');
%     yline(sensor1_index_lower,  '--k', 'Index Lower');
%     yline(sensor1_index_upper,  '--k', 'Index Upper');
%     hold off;
%     drawnow;
% 
%     figure(fig2);
%     % clf;
% 
%     % Subplot 1: Raw
%     subplot(3,1,1);
%     plot(sensor2_history, 'r');
%     title('Sensor 2: Raw');
%     xlabel('Sample'); ylabel('Amplitude');
%     ylim([-0.5 0.5])
% 
%     % Subplot 2: Band-Pass + Abs
%     subplot(3,1,2);
%     plot(sensor2_bp_abs, 'r');
%     title('Sensor 2: BP + Abs');
%     xlabel('Sample'); ylabel('Amplitude');
%     ylim([0 0.5])
% 
%     % Subplot 3: Envelope w/ thresholds
%     subplot(3,1,3);
%     plot(sensor2_env, 'r');
%     title('Sensor 2: Envelope (After 2nd LP)');
%     xlabel('Sample'); ylabel('Amplitude');
%     ylim([0 0.5])
% 
%     hold on;
%     yline(sensor2_pinky_lower,  '--g', 'Pinky Lower');
%     yline(sensor2_pinky_upper,  '--g', 'Pinky Upper');
%     yline(sensor2_ring_lower,   '--m', 'Ring Lower');
%     yline(sensor2_ring_upper,   '--m', 'Ring Upper');
%     yline(sensor2_middle_lower, '--c', 'Middle Lower');
%     yline(sensor2_middle_upper, '--c', 'Middle Upper');
%     yline(sensor2_index_lower,  '--k', 'Index Lower');
%     yline(sensor2_index_upper,  '--k', 'Index Upper');
%     hold off;
%     drawnow;
% end


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

    %Update Sensor 1 Plot 

    
    if isempty(hFig1) || ~isvalid(hFig1)
        % Create figure and initial plot for Sensor 1
        hFig1 = figure('Name', 'Sensor 1 Data');
        hLine1 = plot(sensor1_data);
        xlabel('Sample Index');
        ylabel('Sensor 1 Value');
        title('Real-Time Sensor 1 Data');
        grid on;
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
    else
        % Update the existing plot for Sensor 2
        set(hLine2, 'XData', 1:length(sensor2_data), 'YData', sensor2_data);
        drawnow;
        axis auto 
    end

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

    %{
    if length(new_data) <= averagingsize
        for i = length(new_data)
            averaged(i) = mean(rectified);
        end
    end
    %}
    averaged = movmean(rectified,averagingsize);


    processed = filtfilt(b, a, averaged);

end