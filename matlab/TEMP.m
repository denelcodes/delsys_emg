% Open the file for reading
fid = fopen('raw_emg_data.txt', 'r');
if fid == -1
    error('File not found or cannot be opened.');
end
fileText = fscanf(fid, '%c');
fclose(fid);

% Use regular expressions to extract Sensor 1 and Sensor 2 data
sensor1_tokens = regexp(fileText, 'Sensor\s*1.*?:\s*\[(.*?)\]', 'tokens');
sensor2_tokens = regexp(fileText, 'Sensor\s*2.*?:\s*\[(.*?)\]', 'tokens');

if ~isempty(sensor1_tokens)
    sensor1 = str2num(sensor1_tokens{1}{1});  %#ok<ST2NM>
else
    error('No data found for Sensor 1.');
end

if ~isempty(sensor2_tokens)
    sensor2 = str2num(sensor2_tokens{1}{1});  %#ok<ST2NM>
else
    error('No data found for Sensor 2.');
end

% Plot the data
figure;

subplot(2,1,1);
plot(sensor1, 'b-');
title('Sensor 1 Data');
xlabel('Sample Number');
ylabel('Amplitude');

subplot(2,1,2);
plot(sensor2, 'r-');
title('Sensor 2 Data');
xlabel('Sample Number');
ylabel('Amplitude');
