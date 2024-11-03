clear; close all;
% Adjust as necessary
addpath(genpath('helper functions'));

% Toggle for applying the digital low-pass filter for visibility
applyFilter = true; % Set to true to apply the filter, false to skip it

% Filter parameters (adjust as necessary)
filterOrder = 1;
cutoffFrequency = 0.2;

% Call the helper function to get data and file number
[data, fileNumber] = getDataFile();

if isempty(data)
    return; % Exit if no file was selected
end

% Assumes time in column 1, pressure in column 2, error in column 3,
% integral error in column 4, and cycle completion in column 5
time = data(2:end, 1)/1000; % Convert from milliseconds to seconds
pressure = data(2:end, 2);
% New column indicating the completion of a cycle
cycle_complete = data(2:end, 5);

% Apply digital low-pass filter if toggle is on
if applyFilter
    [b, a] = butter(filterOrder, cutoffFrequency, 'low');
    pressure = filtfilt(b, a, pressure);
end

% Select trajectory [period and magnitude adjustablein function def]
% 1 for step
% 2 for triangle
% 3 for sawtooth
% 4 for reverse sawtooth
% 5 for sine wave
% 6 for burst ramp
trajSelect = 1;
[trajTimes, trajPressures] = getTrajectory(trajSelect);

% Identify end indices of each cycle based on the cycle_complete column
end_indices = find(cycle_complete == 1);

% Initialize cell arrays to store cycles data
cycles = {};

% Extract and store each cycle's data
start_index = 1;
for i = 1:length(end_indices)
    end_index = end_indices(i);
    cycle_indices = start_index:end_index;
    % Normalize to start at zero
    cycles{i}.time = time(cycle_indices) - time(cycle_indices(1)); 
    cycles{i}.pressure = pressure(cycle_indices);
    % Next cycle starts after the current one ends
    start_index = end_index + 1; 
end

% Get a colormap
colors = viridis(length(cycles));

% Create a figure
figure;
hold on;

% Plot each cycle's pressure with different colors
for i = 1:length(cycles)
    plot(cycles{i}.time, cycles{i}.pressure, '-o', 'Color', colors(i, :)...
        , 'DisplayName', sprintf('Cycle %d', i));
end

% Plot the ideal trajectory
plot(trajTimes, trajPressures, 'k--', 'LineWidth', 3,...
    'DisplayName', 'Ideal Trajectory');

% Add labels and title
xlabel('Time (s)', 'FontSize', 20, 'FontWeight', 'Bold');
ylabel('Pressure (PSI)', 'FontSize', 20, 'FontWeight', 'Bold');
title(sprintf('Cycle Test %s', fileNumber), 'FontSize', 26,...
    'FontWeight', 'Bold');
%title('15 PSI step funciton', 'FontSize', 26, 'FontWeight', 'Bold');

% Improve plot appearance
grid on;
improvePlot();

% Set legend size
lgd = legend('FontSize', 20);
