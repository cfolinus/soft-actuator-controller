clear; close all;
% Adjust as necessary
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

% Compute the control signal using PID formula with provided integral error
control_signal = Kp * error + Ki * integral_error;

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
improvePlot();
