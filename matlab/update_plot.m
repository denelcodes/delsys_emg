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