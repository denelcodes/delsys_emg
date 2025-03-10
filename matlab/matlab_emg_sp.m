%% Initialization

% ----- Sensor 1 Figure & UI -----
figure(1);
set(gcf,'Units','normalized','Position',[0.05 0.1 0.75 0.8]);  % Adjust figure size

% Create Sensor 1 axes for plots (using a 3x1 layout)
ax1_s1 = subplot(3,1,1);  % Raw Data
title(ax1_s1, 'Sensor 1: Raw Data');
xlabel(ax1_s1, 'Sample Number'); ylabel(ax1_s1, 'Amplitude');

ax2_s1 = subplot(3,1,2);  % Band-Pass + Abs
title(ax2_s1, 'Sensor 1: Band-Pass + Abs');
xlabel(ax2_s1, 'Sample Number'); ylabel(ax2_s1, 'Amplitude');

ax3_s1 = subplot(3,1,3);  % Envelope
title(ax3_s1, 'Sensor 1: Low-Pass Smoothed Envelope');
xlabel(ax3_s1, 'Sample Number'); ylabel(ax3_s1, 'Amplitude');

% Create slider controls for Sensor 1 thresholds with labels
% Pinky Lower
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.85, 0.1, 0.03],'String','Pinky Lower');
slider_s1_pinky_lower = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.82, 0.1, 0.03],'Min',0,'Max',1,'Value',0.01);

% Pinky Upper
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.79, 0.1, 0.03],'String','Pinky Upper');
slider_s1_pinky_upper = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.76, 0.1, 0.03],'Min',0,'Max',1,'Value',0.02);

% Ring Lower
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.73, 0.1, 0.03],'String','Ring Lower');
slider_s1_ring_lower = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.70, 0.1, 0.03],'Min',0,'Max',1,'Value',0.02);

% Ring Upper
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.67, 0.1, 0.03],'String','Ring Upper');
slider_s1_ring_upper = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.64, 0.1, 0.03],'Min',0,'Max',1,'Value',0.03);

% Middle Lower
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.61, 0.1, 0.03],'String','Middle Lower');
slider_s1_middle_lower = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.58, 0.1, 0.03],'Min',0,'Max',1,'Value',0.03);

% Middle Upper
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.55, 0.1, 0.03],'String','Middle Upper');
slider_s1_middle_upper = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.52, 0.1, 0.03],'Min',0,'Max',1,'Value',0.04);

% Index Lower
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.49, 0.1, 0.03],'String','Index Lower');
slider_s1_index_lower = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.46, 0.1, 0.03],'Min',0,'Max',1,'Value',0.04);

% Index Upper
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.43, 0.1, 0.03],'String','Index Upper');
slider_s1_index_upper = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.40, 0.1, 0.03],'Min',0,'Max',1,'Value',0.05);

% ----- Sensor 2 Figure & UI -----
figure(2);
set(gcf,'Units','normalized','Position',[0.05 0.1 0.75 0.8]);  % Adjust figure size

ax1_s2 = subplot(3,1,1);  % Raw Data
title(ax1_s2, 'Sensor 2: Raw Data');
xlabel(ax1_s2, 'Sample Number'); ylabel(ax1_s2, 'Amplitude');

ax2_s2 = subplot(3,1,2);  % Band-Pass + Abs
title(ax2_s2, 'Sensor 2: Band-Pass + Abs');
xlabel(ax2_s2, 'Sample Number'); ylabel(ax2_s2, 'Amplitude');

ax3_s2 = subplot(3,1,3);  % Envelope
title(ax3_s2, 'Sensor 2: Low-Pass Smoothed Envelope');
xlabel(ax3_s2, 'Sample Number'); ylabel(ax3_s2, 'Amplitude');

% Create slider controls for Sensor 2 thresholds with labels
% Pinky Lower
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.85, 0.1, 0.03],'String','Pinky Lower');
slider_s2_pinky_lower = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.82, 0.1, 0.03],'Min',0,'Max',1,'Value',0.01);

% Pinky Upper
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.79, 0.1, 0.03],'String','Pinky Upper');
slider_s2_pinky_upper = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.76, 0.1, 0.03],'Min',0,'Max',1,'Value',0.02);

% Ring Lower
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.73, 0.1, 0.03],'String','Ring Lower');
slider_s2_ring_lower = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.70, 0.1, 0.03],'Min',0,'Max',1,'Value',0.02);

% Ring Upper
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.67, 0.1, 0.03],'String','Ring Upper');
slider_s2_ring_upper = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.64, 0.1, 0.03],'Min',0,'Max',1,'Value',0.03);

% Middle Lower
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.61, 0.1, 0.03],'String','Middle Lower');
slider_s2_middle_lower = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.58, 0.1, 0.03],'Min',0,'Max',1,'Value',0.03);

% Middle Upper
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.55, 0.1, 0.03],'String','Middle Upper');
slider_s2_middle_upper = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.52, 0.1, 0.03],'Min',0,'Max',1,'Value',0.04);

% Index Lower
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.49, 0.1, 0.03],'String','Index Lower');
slider_s2_index_lower = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.46, 0.1, 0.03],'Min',0,'Max',1,'Value',0.04);

% Index Upper
uicontrol('Style','text','Units','normalized',...
    'Position',[0.87, 0.43, 0.1, 0.03],'String','Index Upper');
slider_s2_index_upper = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.87, 0.40, 0.1, 0.03],'Min',0,'Max',1,'Value',0.05);

%% Other Initialization Variables

fs = 1000;  % Sampling frequency
order_bp = 4;
low_cutoff = 20; high_cutoff = 450;
[b_bp, a_bp] = butter(order_bp, [low_cutoff high_cutoff] / (fs/2));

order_lp = 4;
lp_cutoff = 4;
[b_lp, a_lp] = butter(order_lp, lp_cutoff / (fs/2));

sensor1_history = [];
sensor2_history = [];

% For delayed file writes (if desired)
delay_threshold = 1;  % seconds
sensor1_last_write = tic; % tic and toc matlab timer
sensor2_last_write = tic;

%% Main Loop
while true
    %% Update Threshold Values from Sliders
    % Sensor 1 thresholds:
    sensor1_pinky_lower  = get(slider_s1_pinky_lower, 'Value');
    sensor1_pinky_upper  = get(slider_s1_pinky_upper, 'Value');
    sensor1_ring_lower   = get(slider_s1_ring_lower, 'Value');
    sensor1_ring_upper   = get(slider_s1_ring_upper, 'Value');
    sensor1_middle_lower = get(slider_s1_middle_lower, 'Value');
    sensor1_middle_upper = get(slider_s1_middle_upper, 'Value');
    sensor1_index_lower  = get(slider_s1_index_lower, 'Value');
    sensor1_index_upper  = get(slider_s1_index_upper, 'Value');
    
    % Sensor 2 thresholds:
    sensor2_pinky_lower  = get(slider_s2_pinky_lower, 'Value');
    sensor2_pinky_upper  = get(slider_s2_pinky_upper, 'Value');
    sensor2_ring_lower   = get(slider_s2_ring_lower, 'Value');
    sensor2_ring_upper   = get(slider_s2_ring_upper, 'Value');
    sensor2_middle_lower = get(slider_s2_middle_lower, 'Value');
    sensor2_middle_upper = get(slider_s2_middle_upper, 'Value');
    sensor2_index_lower  = get(slider_s2_index_lower, 'Value');
    sensor2_index_upper  = get(slider_s2_index_upper, 'Value');
    
    %% Read and Process Data File
    if ~exist('raw_emg_data.txt', 'file')
        disp('raw_emg_data.txt does not exist.');
        pause(1);
        continue;
    end
    
    fid = fopen('raw_emg_data.txt', 'r');
    if fid == -1
        disp('Cannot open file.');
        pause(1);
        continue;
    end
    fileText = fscanf(fid, '%c');
    fclose(fid);
    
    sensor1_tokens = regexp(fileText, 'Sensor\s*1:\s*\[(.*?)\]', 'tokens');
    sensor2_tokens = regexp(fileText, 'Sensor\s*2:\s*\[(.*?)\]', 'tokens');
    
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
    
    sensor1_history = [sensor1_history, sensor1_data];  %#ok<AGROW>
    sensor2_history = [sensor2_history, sensor2_data];  %#ok<AGROW>
    
    %% Process Sensor Data (Filtering)
    sensor1_bp_abs = abs(filter(b_bp, a_bp, sensor1_history));
    sensor2_bp_abs = abs(filter(b_bp, a_bp, sensor2_history));
    
    sensor1_env = filter(b_lp, a_lp, sensor1_bp_abs);
    sensor2_env = filter(b_lp, a_lp, sensor2_bp_abs);
    
    %% Sensor 1: Threshold Check & (Delayed) Logging
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
        
        if ~isempty(newFinger) && toc(sensor1_last_write) >= delay_threshold
            fid_out = fopen('finger_output.txt', 'a');
            if fid_out ~= -1
                fprintf(fid_out, 'Sensor1: %s\n', newFinger);
                fclose(fid_out);
            else
                warning('Could not open finger_output.txt for writing.');
            end
            disp(['Sensor 1: ' newFinger]);
            sensor1_last_write = tic;
        end
    end
    
    %% Sensor 2: Threshold Check & (Delayed) Logging
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
        
        if ~isempty(newFinger2) && toc(sensor2_last_write) >= delay_threshold
            fid_out = fopen('finger_output.txt', 'a');
            if fid_out ~= -1
                fprintf(fid_out, 'Sensor2: %s\n', newFinger2);
                fclose(fid_out);
            else
                warning('Could not open finger_output.txt for writing.');
            end
            disp(['Sensor 2: ' newFinger2]);
            sensor2_last_write = tic;
        end
    end
    
    %% Update Sensor 1 Plots (using cla so sliders persist)
    axes(ax1_s1); cla(ax1_s1);
    plot(ax1_s1, sensor1_history, 'b');
    title(ax1_s1, 'Sensor 1: Raw Data');
    xlabel(ax1_s1, 'Sample Number'); ylabel(ax1_s1, 'Amplitude');
    
    axes(ax2_s1); cla(ax2_s1);
    plot(ax2_s1, sensor1_bp_abs, 'b');
    title(ax2_s1, 'Sensor 1: Band-Pass + Abs');
    xlabel(ax2_s1, 'Sample Number'); ylabel(ax2_s1, 'Amplitude');
    
    axes(ax3_s1); cla(ax3_s1);
    plot(ax3_s1, sensor1_env, 'b');
    title(ax3_s1, 'Sensor 1: Low-Pass Smoothed Envelope');
    xlabel(ax3_s1, 'Sample Number'); ylabel(ax3_s1, 'Amplitude');
    hold(ax3_s1, 'on');
    yline(ax3_s1, sensor1_pinky_lower, '--g', sprintf('Pinky Lower: %.2f', sensor1_pinky_lower));
    yline(ax3_s1, sensor1_pinky_upper, '--g', sprintf('Pinky Upper: %.2f', sensor1_pinky_upper));
    yline(ax3_s1, sensor1_ring_lower, '--m', sprintf('Ring Lower: %.2f', sensor1_ring_lower));
    yline(ax3_s1, sensor1_ring_upper, '--m', sprintf('Ring Upper: %.2f', sensor1_ring_upper));
    yline(ax3_s1, sensor1_middle_lower, '--c', sprintf('Middle Lower: %.2f', sensor1_middle_lower));
    yline(ax3_s1, sensor1_middle_upper, '--c', sprintf('Middle Upper: %.2f', sensor1_middle_upper));
    yline(ax3_s1, sensor1_index_lower, '--k', sprintf('Index Lower: %.2f', sensor1_index_lower));
    yline(ax3_s1, sensor1_index_upper, '--k', sprintf('Index Upper: %.2f', sensor1_index_upper));
    hold(ax3_s1, 'off');
    
    %% Update Sensor 2 Plots
    axes(ax1_s2); cla(ax1_s2);
    plot(ax1_s2, sensor2_history, 'r');
    title(ax1_s2, 'Sensor 2: Raw Data');
    xlabel(ax1_s2, 'Sample Number'); ylabel(ax1_s2, 'Amplitude');
    
    axes(ax2_s2); cla(ax2_s2);
    plot(ax2_s2, sensor2_bp_abs, 'r');
    title(ax2_s2, 'Sensor 2: Band-Pass + Abs');
    xlabel(ax2_s2, 'Sample Number'); ylabel(ax2_s2, 'Amplitude');
    
    axes(ax3_s2); cla(ax3_s2);
    plot(ax3_s2, sensor2_env, 'r');
    title(ax3_s2, 'Sensor 2: Low-Pass Smoothed Envelope');
    xlabel(ax3_s2, 'Sample Number'); ylabel(ax3_s2, 'Amplitude');
    hold(ax3_s2, 'on');
    yline(ax3_s2, sensor2_pinky_lower, '--g', sprintf('Pinky Lower: %.2f', sensor2_pinky_lower));
    yline(ax3_s2, sensor2_pinky_upper, '--g', sprintf('Pinky Upper: %.2f', sensor2_pinky_upper));
    yline(ax3_s2, sensor2_ring_lower, '--m', sprintf('Ring Lower: %.2f', sensor2_ring_lower));
    yline(ax3_s2, sensor2_ring_upper, '--m', sprintf('Ring Upper: %.2f', sensor2_ring_upper));
    yline(ax3_s2, sensor2_middle_lower, '--c', sprintf('Middle Lower: %.2f', sensor2_middle_lower));
    yline(ax3_s2, sensor2_middle_upper, '--c', sprintf('Middle Upper: %.2f', sensor2_middle_upper));
    yline(ax3_s2, sensor2_index_lower, '--k', sprintf('Index Lower: %.2f', sensor2_index_lower));
    yline(ax3_s2, sensor2_index_upper, '--k', sprintf('Index Upper: %.2f', sensor2_index_upper));
    hold(ax3_s2, 'off');
    
    drawnow;
    pause(0.5);  % Adjust pause as needed for processing/plot updates
end
