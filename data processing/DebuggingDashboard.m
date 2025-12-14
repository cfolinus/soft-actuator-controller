clear; close all;
% Adjust as necessary
addpath(genpath('helper_functions'));

% Call the helper function to get data, file name, and Kp/Ki values
[data, fileName, Kp, Ki] = getDataFile();

if isempty(data)
    return; % Exit if no file was selected
end

% Assumes time in column 1, pressure in column 2, error in column 3,
% and integral error in column 4
time = data(2:end, 1); % Convert to seconds for readability
pressure = data(2:end, 2);
error = data(2:end, 3);
integral_error = data(2:end, 4); 

% Compute the control signal using PID formula with provided integral error
control_signal = Kp * error + Ki * integral_error;

% Compute the valve signal
function x_out = mapFloat (x, in_min, in_max, out_min, out_max)
    x_out = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
end

ANALOG_PRESSURE_MIN = 145;
ANALOG_PRESSURE_MAX = 173;
ANALOG_VENT_MIN = 143;
ANALOG_VENT_MAX = 175;

pressure_valve_signal = (control_signal > 1) ...
    .* mapFloat(control_signal, 0, 1, 0, ANALOG_PRESSURE_MAX - ANALOG_PRESSURE_MIN) ...
    + ANALOG_PRESSURE_MIN;
vent_valve_signal = (control_signal < 1) ...
    .* mapFloat(abs(control_signal), 0, 1, 0, ANALOG_VENT_MAX - ANALOG_VENT_MIN) ...
    + ANALOG_VENT_MIN;

pressure_valve_signal = min (pressure_valve_signal, ANALOG_PRESSURE_MAX);
vent_valve_signal = min (vent_valve_signal, ANALOG_VENT_MAX);

figure; hold on;
plot (time, pressure_valve_signal);
plot (time, vent_valve_signal);

yline (ANALOG_PRESSURE_MIN, '--', 'Alpha', 1, 'Color', 0 * [1,1,1]);
yline (ANALOG_PRESSURE_MAX, '--', 'Alpha', 1, 'Color', 0 * [1,1,1]);
yline (ANALOG_VENT_MIN, '--', 'Alpha', 1, 'Color', 0.5 * [1,1,1]);
yline (ANALOG_VENT_MAX, '--', 'Alpha', 1, 'Color', 0.5 * [1,1,1]);

% Replace underscores in the file name for plot title
plotTitle = strrep(fileName, '_', ' ');

% Create a vertical figure with tiledlayout
figure;
t = tiledlayout("vertical", 'TileSpacing', 'tight', 'Padding', 'compact');
xlabel(t, 'Time (s)', 'FontSize', 30, 'FontWeight', 'Bold')
%title(t, plotTitle, "FontSize", 26, 'FontWeight', 'Bold');

% Initialize a container for all legends
legendEntries = [];
legendLabels = {};

% First subplot for pressure
nexttile;
hold on;
p1 = plot(time, pressure, '-o', 'DisplayName', 'Measured Pressure');
ylabel('psi', 'FontSize', 26);
grid on;

% Store legend information
legendEntries(end+1) = p1;
legendLabels{end+1} = 'Measured Pressure';

% Second subplot for control signal
nexttile;
p2 = plot(time, control_signal, 'r-', 'DisplayName', 'Control Signal');
grid on;

% Store legend information
legendEntries(end+1) = p2;
legendLabels{end+1} = 'Control Signal';

% Third subplot for error vs. time
nexttile;
p3 = plot(time, error, 'b-', 'DisplayName', 'Error');
grid on;

% Store legend information
legendEntries(end+1) = p3;
legendLabels{end+1} = 'Error';

% Fourth subplot for integral vs. time
nexttile;
p4 = plot(time, integral_error, 'g-', 'DisplayName', 'Integral');
grid on;

% Store legend information
legendEntries(end+1) = p4;
legendLabels{end+1} = 'Integral';

% Fifth subplot for Kp*error and Ki*integral vs. time
nexttile;
hold on;
p5 = plot(time, Kp * error, 'm-', 'DisplayName', 'Kp * Error');
p6 = plot(time, Ki * integral_error, 'c-', 'DisplayName', 'Ki * Integral');
grid on;

% Store legend information
legendEntries(end+1) = p5;
legendLabels{end+1} = 'Kp * Error';
legendEntries(end+1) = p6;
legendLabels{end+1} = 'Ki * Integral';

% Add a legend below the tiled layout
lgd = legend(legendEntries, legendLabels, ...
    'Orientation', 'horizontal', ... % Arrange legend entries horizontally
    'FontSize', 20, ...              % Increase font size for readability
    'Box', 'on');                    % Add a border around the legend

% Adjust the legend position below the tiled layout
lgd.Layout.Tile = 'south';

% Improve plot appearance
improveHangerFig(4*150, 2* 3*150);
