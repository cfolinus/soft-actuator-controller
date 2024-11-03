clear; close all;
%Adjust as necessary
addpath(genpath('helper functions'));

% Call the helper function to get data, file name, and Kp/Ki values
[data, fileName, Kp, Ki] = getDataFile();

if isempty(data)
    return; % Exit if no file was selected
end

% Assumes time in column 1, pressure in column 2, error in column 3,
% and integral error in column 4
time = data(2:end, 1)/1000; % Convert to seconds for readability
pressure = data(2:end, 2);
error = data(2:end, 3);
integral_error = data(2:end, 4); 

% Select trajectory [period and magnitude adjustable in function def]
% 1 for step
% 2 for triangle
% 3 for sawtooth
% 4 for reverse sawtooth
% 5 for sine wave
% 6 for burst ramp
trajSelect = 1;
[trajTimes, trajPressures] = getTrajectory(trajSelect);

% Compute the control signal using PID formula with provided integral error
control_signal = Kp * error + Ki * integral_error;

% Replace underscores in the file name for plot title
plotTitle = strrep(fileName, '_', ' ');

% Create a vertical figure with tiledlayout
figure;
t = tiledlayout("vertical", 'TileSpacing', 'tight', 'Padding', 'compact');
xlabel(t, 'Time (s)', 'FontSize', 20, 'FontWeight', 'Bold')
title(t, plotTitle, "FontSize", 26, ...
    'FontWeight', 'Bold');

% First subplot for pressure and setPressures
nexttile;
hold on;
plot(time, pressure, '-o', 'DisplayName', 'Measured Pressure');
plot(trajTimes, trajPressures, 'k--', 'LineWidth', 3, ...
    'DisplayName', 'Ideal Trajectory');
ylabel('PSI');
grid on;
legend show;

% Second subplot for control signal
nexttile;
plot(time, control_signal, 'r-', 'DisplayName', 'Control Signal');
grid on;
legend show;

% Third subblot for error vs. time
nexttile;
plot(time, error, 'b-', 'DisplayName', 'Error');
grid on;
legend show;

% Fourth subplot for integral vs. time
nexttile;
plot(time, integral_error, 'g-', 'DisplayName', 'Integral');
grid on;
legend show;

% Fifth subplot for Kp*error and Ki*integral vs. time
nexttile;
hold on;
plot(time, Kp * error, 'm-', 'DisplayName', 'Kp * Error');
plot(time, Ki * integral_error, 'c-', 'DisplayName', 'Ki * Integral');
grid on;
legend show;

% Improve plot appearance
improvePlot();
