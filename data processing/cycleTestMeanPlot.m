clear; close all;
% Adjust as necessary
addpath(genpath('helper functions'));

% Toggle for applying the digital low-pass filter for visibility
applyFilter = false; % Set to true to apply the filter, false to skip it

% Filter parameters (adjust as necessary)
filterOrder = 1;
cutoffFrequency = 0.2;

% Call the helper function to get data and file number
[data, fileNumber] = getDataFile();

if isempty(data)
    return; % Exit if no file was selected
end

% Assumes time in column 1, pressure in column 2, cycle completion in column 5
time = data(2:end, 1) / 1000; % Convert from milliseconds to seconds
pressure = data(2:end, 2);
cycle_complete = data(2:end, 5); % New column indicating the completion of a cycle

% Apply digital low-pass filter if toggle is on
if applyFilter
    [b, a] = butter(filterOrder, cutoffFrequency, 'low');
    pressure = filtfilt(b, a, pressure);
end

% Identify end indices of each cycle based on the cycle_complete column
end_indices = find(cycle_complete == 1);

% Initialize cell arrays to store cycles data
cycles = {};

% Extract and store each cycle's data
start_index = 1;
for i = 1:length(end_indices)
    end_index = end_indices(i);
    cycle_indices = start_index:end_index;
    % Normalize time to start at zero
    cycles{i}.time = time(cycle_indices) - time(cycle_indices(1)); 
    cycles{i}.pressure = pressure(cycle_indices);
    start_index = end_index + 1; 
end

% Find the maximum cycle duration to establish a common time vector
max_cycle_time = max(cellfun(@(x) max(x.time), cycles));
normalized_time = linspace(0, max_cycle_time, 1000); % Interpolating with 1000 points

% Interpolate pressure data for each cycle to match the normalized time axis
interpolated_pressures = zeros(length(cycles), length(normalized_time));

for i = 1:length(cycles)
    interpolated_pressures(i, :) = interp1(cycles{i}.time, cycles{i}.pressure, normalized_time, 'linear', 'extrap');
end

% Calculate the mean and standard deviation at each time point
mean_pressure = mean(interpolated_pressures, 1);
std_pressure = std(interpolated_pressures, 0, 1);

% Calculate the 95% confidence interval using the t-distribution
n = size(interpolated_pressures, 1); % Number of cycles
df = n - 1;  % Degrees of freedom
t_critical = tinv(0.975, df); % t critical value for a 95% confidence level

% Confidence interval calculation with t-distribution
conf_interval = t_critical * (std_pressure / sqrt(n));

% Plot the mean pressure with the 95% confidence interval as a shaded area
figure;
hold on;

% Select trajectory [period and magnitude adjustable in function def]
% 1 for step
% 2 for triangle
% 3 for sawtooth
% 4 for reverse sawtooth
% 5 for sine wave
% 6 for burst ramp
trajSelect = 1;
[trajTimes, trajPressures] = getTrajectory(trajSelect);

% Plot the mean pressure line
plot(normalized_time, mean_pressure, 'b', 'LineWidth', 2);

% Plot the shaded area for the confidence interval
fill([normalized_time, fliplr(normalized_time)], ...
    [mean_pressure - conf_interval, fliplr(mean_pressure + conf_interval)], ...
    'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

plot(trajTimes, trajPressures, 'k--', 'LineWidth', 3);

% Add labels and title
xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'Bold'); % Now in seconds
ylabel('Pressure (PSI)', 'FontSize', 14, 'FontWeight', 'Bold');
title(sprintf('Pressure vs Time with 95%% Confidence Interval - File %s', ...
    fileNumber), 'FontSize', 16, 'FontWeight', 'Bold');

% Improve plot appearance
grid on;
hold off;
improvePlot();

% Set legend
legend('Mean Pressure', '95% Confidence Interval', 'Ideal Trajectory', 'FontSize', 20);

%% Helper Function
function [data, fileName, Kp, Ki] = getDataFile()
    % Prompt the user to select a file
    [fileName, pathName] = uigetfile('*.csv', 'Select the test data file');
    
    if isequal(fileName, 0)
        data = [];
        Kp = [];
        Ki = [];
        return; % Exit if no file is selected
    end

    % Full path to the file
    fullPath = fullfile(pathName, fileName);
    
    % Open the file and read its contents
    fid = fopen(fullPath, 'r');
    if fid == -1
        error('Could not open the file.');
    end
    
    % Initialize variables to store KP, KI, and other settings
    Kp = [];
    Ki = [];
    
    % Look for the KP and KI settings in the first few lines of the file
    while ~feof(fid)
        line = fgetl(fid);  % Read one line at a time
        if contains(line, 'KP,')
            % Extract KP value from the line
            Kp = sscanf(line, 'KP,%f');
        elseif contains(line, 'KI,')
            % Extract KI value from the line
            Ki = sscanf(line, 'KI,%f');
        elseif contains(line, 'time,pressure,error,integral,cycle_start')
            % Break the loop once we reach the data section
            break;
        end
    end
    
    % Ensure both KP and KI are extracted
    if isempty(Kp) || isempty(Ki)
        fclose(fid);
        error('KP or KI values not found in the file.');
    end
    
    % Read the actual data starting after the header
    data = [];
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            dataLine = sscanf(line, '%f,%f,%f,%f,%d'); % Read the data line
            if ~isempty(dataLine)
                data = [data; dataLine']; % Append the data to the matrix
            end
        end
    end
    
    fclose(fid); % Close the file
end
