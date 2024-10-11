clear; close all;
%Adjust as necessary
addpath(genpath('helper functions'));

% Define PID controller gains assocaited with to-be-examined test file
Kp = 0.4;
Ki = 0.00115;

% Call the helper function to get data and file number
[data, fileNumber] = getDataFile();

if isempty(data)
    return; % Exit if no file was selected
end

% Assumes time in column 1, pressure in column 2, error in column 3,
% and integral error in column 4
time = data(2:end, 1) / 1000; % Convert to seconds for readibility
pressure = data(2:end, 2);
error = data(2:end, 3);
integral_error = data(2:end, 4); 

% Select trajectory [period and magnitude adjustablein function def]
% 1 for step
% 2 for triangle
% 3 for sawtooth
% 4 for reverse sawtooth
% 5 for sine wave
% 6 for burst ramp
trajSelect = 1;
[trajTimes, trajPressures] = getTrajectory(trajSelect);

% Calculate length of the trajectory
trajLength = length(trajTimes);

% Compute the control signal using PID formula with provided integral error
control_signal = Kp * error + Ki * integral_error;

% Create a vertical figure with tiledlayout
figure;
t = tiledlayout("vertical", 'TileSpacing', 'tight', 'Padding', 'compact');
xlabel(t, 'Time (s)', 'FontSize', 20, 'FontWeight', 'Bold')
title(t, sprintf('Cycle Test %s', fileNumber), "FontSize", 26, ...
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
%xlim([0, trajTimes(end)]);

% Second subplot for control signal
nexttile;
plot(time, control_signal, 'r-', 'DisplayName', 'Control Signal');
grid on;
legend show;
%xlim([0, trajTimes(end)]);

% Third subblot for error vs. time
nexttile;
plot(time, error, 'b-', 'DisplayName', 'Error');
grid on;
legend show;
%xlim([0, trajTimes(end)]);

% Fourth subplot for integral vs. time
nexttile;
plot(time, integral_error, 'g-', 'DisplayName', 'Integral');
grid on;
legend show;
%xlim([0, trajTimes(end)]);

% Fifth subplot for Kp*error and Ki*integral vs. time
nexttile;
hold on;
plot(time, Kp * error, 'm-', 'DisplayName', 'Kp * Error');
plot(time, Ki * integral_error, 'c-', 'DisplayName', 'K_i * Integral');
grid on;
legend show;
%xlim([0, trajTimes(end)]);

% Improve plot appearance
improvePlot();
