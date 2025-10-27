clear; close all;
addpath(genpath('helper_functions'));

csv_filepath = fullfile('data', 'cycles', '251023_cycle_1.csv');



%% Extract controller settings
% Open the file and read its contents
file_id = fopen(csv_filepath, 'r');
if file_id == -1
    error('Could not open the file.');
end
    
% Parse header lines to extract settings
controller_params = struct;
while not(feof(file_id))

    % Read current line
    temp_line = fgetl(file_id);
    temp_line = strsplit(temp_line, ',');

    % Separate setting name from declared value
    temp_setting_name = temp_line{1};
    try
        temp_setting_value = temp_line{2};
    catch
        temp_setting_value = nan;
    end

    % Assign declared setting value to corresponding variable
    switch temp_setting_name
        case 'filename'
            controller_params.filename = temp_setting_value;
        case 'Use KPA?'
            controller_params.use_kPa = temp_setting_value;
        case 'KP'
            controller_params.gain_proportional = temp_setting_value;
        case 'KI'
            controller_params.gain_integral = temp_setting_value;
        case 'KD'
            controller_params.gain_derivative = temp_setting_value;
        case 'Traj Follow Error Threshold'
            controller_params.threshold_presure_traj_follow_error = ...
                temp_setting_value;
        case 'Filter alpha'
            controller_params.filter_alpha = temp_setting_value;
        case 'Sensor offset'
            controller_params.sensor_offset = temp_setting_value;
        case 'Pressure Read Delay'
            controller_params.delay_pressure_ms = temp_setting_value;
        case 'Interpolation Calculation Delay'
            controller_params.delay_interpolation_ms = temp_setting_value;
        case 'Controller Delay'
            controller_params.delay_controller_ms = temp_setting_value;
        case 'Traj times'
            controller_params.trajectory_time_ms = 1e-3 * str2double(temp_line(2:end));
        case 'Traj pressures'
            controller_params.trajectory_pressure = str2double(temp_line(2:end));
        case 'Data:'
            break
        otherwise
            warning('Invalid setting name: %s', temp_setting_name);
    end
end

fclose(file_id);
clear temp_line temp_setting_name temp_setting_value



%% Import raw data
% Read actual data starting after the header
opts = detectImportOptions(csv_filepath);
raw_data = readtable(csv_filepath, opts);

clear opts



%% Split data into cycles and resample
num_time_points = 100;

end_indices = find(raw_data.cycle_start);
num_raw_cycles = numel(end_indices);

% Initialize cell arrays to store cycles data
raw_cycle_data = cell([num_raw_cycles, 1]);

% Extract and store each cycle's data
for cycle_index = 1:num_raw_cycles

    % Determine beginning and ending indices of this cycle
    if cycle_index == 1
        temp_start_index = 1;
    else
        temp_start_index = end_indices(cycle_index - 1);
    end

    temp_end_index = end_indices(cycle_index) - 1;
    temp_cycle_indices = temp_start_index:temp_end_index;

    % Extract data for this cycle
    raw_cycle_data{cycle_index} = raw_data(temp_start_index:temp_end_index, :);

    % Shift time to start at zero
    raw_cycle_data{cycle_index}.time = ...
        raw_cycle_data{cycle_index}.time - raw_cycle_data{cycle_index}.time(1);

    % Convert time in ms to seconds
    raw_cycle_data{cycle_index}.time_ms = 1e-3 * raw_cycle_data{cycle_index}.time;
    raw_cycle_data{cycle_index} = removevars(raw_cycle_data{cycle_index}, 'time');


    % Resample cycle data to have consistent number of points
    
end





%% Pre-process data
% Assumes time in column 1, pressure in column 2, cycle completion in column 5
time = cycle_data.time / 1000; % Convert from milliseconds to seconds
pressure = cycle_data.pressure;
pressure = pressure * 6.89476; % convert fromn psi to KPA
cycle_complete = cycle_data.cycle_start; % New column indicating the completion of a cycle

% % Apply digital low-pass filter if toggle is on
% if applyFilter
%     [b, a] = butter(filterOrder, cutoffFrequency, 'low');
%     pressure = filtfilt(b, a, pressure);
% end

% Identify end indices of each cycle based on the cycle_complete column
end_indices = find(cycle_complete == 1);

% Initialize cell arrays to store cycles data
cycles = {};

% Extract and store each cycle's data
temp_start_index = 1;
for cycle_index = 1:length(end_indices)
    temp_end_index = end_indices(cycle_index);
    cycle_indices = temp_start_index:temp_end_index;

    % Normalize time to start at zero
    cycles{cycle_index}.time = time(cycle_indices) - time(cycle_indices(1)); 
    cycles{cycle_index}.pressure = pressure(cycle_indices);
    temp_start_index = temp_end_index + 1; 
end

%% Manually check for end conditions
pressure_threshold = 25;

for cycle_index = 1:length(cycles)
    max_cycle_pressure(cycle_index) = max(cycles{cycle_index}.pressure);
end

temp_flagged_cycles = find(max_cycle_pressure < pressure_threshold, 1);

% Trim cycles
cycles = cycles(1:temp_flagged_cycles);


%% Resample pressure data
% Find the maximum cycle duration to establish a common time vector
max_cycle_time = max(cellfun(@(x) max(x.time), cycles));
normalized_time = linspace(0, max_cycle_time, 100); % Interpolating with 1000 points

% Interpolate pressure data for each cycle to match the normalized time axis
interpolated_pressures = zeros(length(cycles), length(normalized_time));

for cycle_index = 1:length(cycles)
    interpolated_pressures(cycle_index, :) = interp1(cycles{cycle_index}.time, ...
                                                cycles{cycle_index}.pressure, ...
                                                normalized_time, ...
                                                'linear', ...
                                                'extrap');
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



%% Plot data
figure; hold on;
plot (cycle_data.time, cycle_data.pressure);

num_cycle_starts = nnz(cycle_data.cycle_start);



%% Plot the mean pressure with the 95% confidence interval as a shaded area
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
magnitude = 50; % unitless for purposes of graphing
[trajTimes, trajPressures] = getTrajectory(trajSelect, magnitude);

darkGreen = [0, 0.8, 0];

% Plot the mean pressure line
plot(normalized_time, mean_pressure, 'Color', 'r', 'LineWidth', 6);
%plot(normalized_time, mean_pressure, 'b', 'LineWidth', 6);

% Plot the shaded area for the confidence interval
fill([normalized_time, fliplr(normalized_time)], ...
    [mean_pressure - conf_interval, fliplr(mean_pressure + conf_interval)], ...
    'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

plot(trajTimes, trajPressures, 'k--', 'LineWidth', 3);

% Remove padding around the plot
axis tight; % Ensures axes are tightly fitted to the data
set(gca, 'LooseInset', max(get(gca, 'TightInset'), 0.02)); % Removes extra padding

% Improve plot appearance
ylim([0,inf])
xlim([0,inf])
grid on;
hold off;
improvePlot();

% Set the font size for tick marks
set(gca, 'FontSize', 24); 

% Add labels and title
xlabel('Time (s)', 'FontSize', 32, 'FontWeight', 'Bold');
ylabel('Pressure (kPa)', 'FontSize', 32, 'FontWeight', 'Bold');

% Set legend
legend('Mean Pressure', '95% Confidence Interval', 'Ideal Trajectory', ...
    'FontSize', 28);
