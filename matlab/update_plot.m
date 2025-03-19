function update_plot(sensor1_data, sensor2_data)
    % UPDATE_PLOT  Processes and plots EMG data from two sensors.

    %% -----------------------------
    % 1) Make filter coefficients, etc. persistent so they are not rebuilt
    %    every function call.
    %% -----------------------------
    persistent b_bp a_bp b_lp a_lp fs ...
               sensor1_current_finger sensor2_current_finger ...
               fig1 fig2

    if isempty(fs)
        % Initialize filter parameters once
        fs = 2148.148;  % Sampling frequency in Hz
        
        % Butterworth band-pass filter (e.g., 100-200 Hz for your EMG)
        order_bp    = 2;
        low_cutoff  = 100;   % Hz
        high_cutoff = 200;   % Hz
        [b_bp, a_bp] = butter(order_bp, [low_cutoff high_cutoff] / (fs/2));

        % Butterworth low-pass filter for envelope smoothing (e.g., 10 Hz)
        order_lp = 2;
        lp_cutoff = 10;   % Hz
        [b_lp, a_lp] = butter(order_lp, lp_cutoff / (fs/2));
        
        sensor1_current_finger = '';
        sensor2_current_finger = '';

        % Create figures once
        fig1 = figure('Name','Sensor 1','NumberTitle','off');
        fig2 = figure('Name','Sensor 2','NumberTitle','off');
    end

    %% -----------------------------
    % 2) Threshold Variables
    %% -----------------------------
    sensor1_pinky_lower  = 0.002264329;
    sensor1_pinky_upper  = 0.004432841;
    sensor1_ring_lower   = 0.002664693;
    sensor1_ring_upper   = 0.007166327;
    sensor1_middle_lower = 0.002375097;
    sensor1_middle_upper = 0.007241913;
    sensor1_index_lower  = 0.004213576;
    sensor1_index_upper  = 0.005482864;

    sensor2_pinky_lower  = 0.008331226;
    sensor2_pinky_upper  = 0.010205404;
    sensor2_ring_lower   = 0.003733016;
    sensor2_ring_upper   = 0.004955364;
    sensor2_middle_lower = 0.004097787;
    sensor2_middle_upper = 0.005650073;
    sensor2_index_lower  = 0.009820486;
    sensor2_index_upper  = 0.011985614;

    %% -----------------------------
    % 3) Convert input to row vectors & do filtering
    %% -----------------------------
    sensor1_history = sensor1_data(:).';  % ensure row
    sensor2_history = sensor2_data(:).';

    % Stage 1 & 2: Band-Pass Filter + Absolute Value
    sensor1_bp_abs = abs(filter(b_bp, a_bp, sensor1_history));
    sensor2_bp_abs = abs(filter(b_bp, a_bp, sensor2_history));

    % Stage 3: First Low-Pass Filter (Envelope)
    sensor1_env = filter(b_lp, a_lp, sensor1_bp_abs);
    sensor2_env = filter(b_lp, a_lp, sensor2_bp_abs);

    %% -----------------------------
    % 4) Averaging (example from your snippet)
    %% -----------------------------
    % Instead of looping, we call smoothdata/movmean once per vector.
    % smoothdata(..., 'movmean', 10) is a moving average over 10 samples.
    averaging1 = smoothdata(sensor1_env, 'movmean', 10);  
    averaging2 = movmean(sensor2_env, 1);  % 'movmean' with window=1 => effectively same data

    %% -----------------------------
    % 5) Another Low-pass filter
    %% -----------------------------
    cutoffFreq2 = 3;  % Hz
    [b2, a2] = butter(2, cutoffFreq2/(fs/2));
    sensor1_env = filtfilt(b2, a2, averaging1);
    sensor2_env = filtfilt(b2, a2, averaging2);

    %% -----------------------------
    % Threshold detection (Sensor 1)
    %% -----------------------------
    if ~isempty(sensor1_env)
        currentValue = sensor1_env(end);
        newFinger = '';
        if currentValue >= sensor1_index_lower
            newFinger = 'i';
        elseif currentValue >= sensor1_middle_lower
            newFinger = 'm';
        elseif currentValue >= sensor1_ring_lower
            newFinger = 'r';
        elseif currentValue >= sensor1_pinky_lower
            newFinger = 'p';
        end

        if ~isempty(newFinger) && ~strcmp(newFinger, sensor1_current_finger)
            fid_out = fopen('finger_output.txt', 'a');
            fprintf(fid_out, 'Sensor1: %s\n', newFinger);
            fclose(fid_out);
            disp(['Sensor 1: ' newFinger]);
            sensor1_current_finger = newFinger;
        end

        if currentValue < sensor1_pinky_lower
            sensor1_current_finger = '';
        end
    end

    %% -----------------------------
    % Threshold detection (Sensor 2)
    %% -----------------------------
    if ~isempty(sensor2_env)
        currentValue2 = sensor2_env(end);
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

        if ~isempty(newFinger2) && ~strcmp(newFinger2, sensor2_current_finger)
            fid_out = fopen('finger_output.txt', 'a');
            fprintf(fid_out, 'Sensor2: %s\n', newFinger2);
            fclose(fid_out);
            disp(['Sensor 2: ' newFinger2]);
            sensor2_current_finger = newFinger2;
        end

        if currentValue2 < sensor2_pinky_lower
            sensor2_current_finger = '';
        end
    end

    %% -----------------------------
    % Plot results
    %% -----------------------------
    figure(fig1);
    clf;
    % Subplot 1: Raw
    subplot(3,1,1);
    plot(sensor1_history, 'b');
    title('Sensor 1: Raw');
    xlabel('Sample'); ylabel('Amplitude');

    % Subplot 2: Band-Pass + Abs
    subplot(3,1,2);
    plot(sensor1_bp_abs, 'b');
    title('Sensor 1: BP + Abs');
    xlabel('Sample'); ylabel('Amplitude');

    % Subplot 3: Envelope w/ thresholds
    subplot(3,1,3);
    plot(sensor1_env, 'b');
    title('Sensor 1: Envelope (After 2nd LP)');
    xlabel('Sample'); ylabel('Amplitude');
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
    drawnow;

    figure(fig2);
    clf;
    % Subplot 1: Raw
    subplot(3,1,1);
    plot(sensor2_history, 'r');
    title('Sensor 2: Raw');
    xlabel('Sample'); ylabel('Amplitude');

    % Subplot 2: Band-Pass + Abs
    subplot(3,1,2);
    plot(sensor2_bp_abs, 'r');
    title('Sensor 2: BP + Abs');
    xlabel('Sample'); ylabel('Amplitude');

    % Subplot 3: Envelope w/ thresholds
    subplot(3,1,3);
    plot(sensor2_env, 'r');
    title('Sensor 2: Envelope (After 2nd LP)');
    xlabel('Sample'); ylabel('Amplitude');
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
end
