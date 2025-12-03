clear; close all;
addpath(genpath('helper_functions'));

% csv_filepath = fullfile('data', 'cycles', '251023_cycle_0.csv');
csv_filepath = fullfile('data', 'tuning_test_1.csv');
units.psi_to_kPa = 6.89476;
units.kPa_to_psi = 1 / 6.89476;

alpha_confidence = 0.05;
colors.blue = [0, 128, 203]/255;

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
            controller_params.use_kPa = str2double(temp_setting_value);
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
        case 'Settings:'
        case 'Data:'
            break
        otherwise
            warning('Invalid setting name: %s', temp_setting_name);
    end
end

fclose(file_id);
clear temp_line temp_setting_name temp_setting_value

if controller_params.use_kPa
    controller_params.trajectory_pressure_kPa = controller_params.trajectory_pressure;
else
    controller_params.trajectory_pressure_kPa = controller_params.trajectory_pressure * units.psi_to_kPa;
end



%% Import raw data
% Read actual data starting after the header
opts = detectImportOptions(csv_filepath);
raw_data = readtable(csv_filepath, opts);

clear opts



%% Split data into cycles and resample
num_time_points = 100;
resampled_time_ms = linspace(0, controller_params.trajectory_time_ms(end), num_time_points);

end_indices = find(raw_data.cycle_start);
num_raw_cycles = numel(end_indices);

% Initialize cell arrays to store cycles data
raw_cycle_data = cell([num_raw_cycles, 1]);
resampled_cycle_data = cell([num_raw_cycles, 1]);

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
    temp_cycle_data = raw_data(temp_start_index:temp_end_index, :);

    % Shift time to start at zero
    temp_cycle_data.time = ...
        temp_cycle_data.time - temp_cycle_data.time(1);



    % Convert time in ms to seconds
    temp_cycle_data.time_ms = 1e-3 * temp_cycle_data.time;
    temp_cycle_data = movevars(temp_cycle_data, 'time_ms', 'Before', 'time');
    temp_cycle_data = removevars(temp_cycle_data, 'time');




    % Convert pressure to kPa
    % If data was collected in kPa, just update variable name
    if controller_params.use_kPa
        temp_cycle_data.pressure_kPa = temp_cycle_data.pressure;
    
    % If data was collected in psi, convert data and update variable name
    else
        temp_cycle_data.pressure_kPa = temp_cycle_data.pressure * units.psi_to_kPa;

        temp_cycle_data.error = temp_cycle_data.error * units.psi_to_kPa;
        temp_cycle_data.integral = temp_cycle_data.integral * units.psi_to_kPa;

    end
    temp_cycle_data = movevars(temp_cycle_data, 'pressure_kPa', 'Before', 'pressure');
    temp_cycle_data = removevars(temp_cycle_data, 'pressure');

    

    % Store raw cycle data
    raw_cycle_data{cycle_index} = temp_cycle_data;



    % % Resample cycle data to have consistent number of points
    % temp_resampled_pressure_kPa = interp1(temp_cycle_data.time_ms, ...
    %                                             temp_cycle_data.pressure_kPa, ...
    %                                             resampled_time_ms, ...
    %                                             'linear', ...
    %                                             'extrap');
    % resampled_cycle_data{cycle_index}.time_ms = resampled_time_ms';
    % resampled_cycle_data{cycle_index}.pressure_kPa = temp_resampled_pressure_kPa';

end




%% Manually check for end conditions
pressure_threshold_kPa = 0.5 * max(controller_params.trajectory_pressure_kPa);


max_cycle_pressure_kPa = nan([num_raw_cycles, 1]);
for cycle_index = 1:num_raw_cycles
    max_cycle_pressure_kPa(cycle_index) = max(raw_cycle_data{cycle_index}.pressure_kPa);
end

temp_flagged_cycle = find(max_cycle_pressure_kPa < pressure_threshold_kPa, 1);

if not(isempty(temp_flagged_cycle))
    temp_final_cycle = temp_flagged_cycle - 1;
else
    temp_final_cycle = height(raw_cycle_data);
end


% Trim cycles
raw_cycle_data = raw_cycle_data(1:temp_final_cycle);

for cycle_index = 1:temp_final_cycle

    temp_cycle_data = raw_cycle_data{cycle_index, 1};

    % Resample cycle data to have consistent number of points
    temp_resampled_pressure_kPa = interp1(temp_cycle_data.time_ms, ...
                                                temp_cycle_data.pressure_kPa, ...
                                                resampled_time_ms, ...
                                                'linear', ...
                                                'extrap');
    resampled_cycle_data{cycle_index}.time_ms = resampled_time_ms';
    resampled_cycle_data{cycle_index}.pressure_kPa = temp_resampled_pressure_kPa';
end

% resampled_cycle_data = resampled_cycle_data(1:temp_final_cycle);

% Convert resampled data to struct
resampled_cycle_data = [resampled_cycle_data{:}];



%% Calculate mean, variance, etc.
overall_cycle_data.time_ms = resampled_time_ms';

temp_pressure_kPa = [resampled_cycle_data(:).pressure_kPa];

overall_cycle_data.mean_pressure_kPa = mean(temp_pressure_kPa, 2);
overall_cycle_data.std_pressure_kPa = std(temp_pressure_kPa, [], 2);

temp_num_cycles = numel(resampled_cycle_data);
t_critical = tinv(1 - 0.5 * alpha_confidence, temp_num_cycles - 1);
overall_cycle_data.conf_interval_pressure_kPa = ...
    t_critical * (overall_cycle_data.std_pressure_kPa / sqrt(temp_num_cycles));




%% Plot data from this file
% plotAverageAndConfidence (overall_cycle_data, controller_params)
% 
% plotOverlaidCycles(resampled_cycle_data, controller_params, plot_frequency);
% plotIndividualCycles(resampled_cycle_data, controller_params, plot_frequency);
plot_frequency = 50;


figure;
t = tiledlayout(2, 2, 'TileSpacing', 'compact');
nexttile();
plotAverageAndConfidence (overall_cycle_data, controller_params)

nexttile();
plotOverlaidCycles(resampled_cycle_data, controller_params, plot_frequency);

nexttile(t, 3, [1, 2]);
plotIndividualCycles(resampled_cycle_data, controller_params, plot_frequency)

% Adjust figure size (double-width)
set(gcf, 'rend', 'painters', 'Units', 'pixels', 'pos', ...
        [100 100 4*300 3*300]);


function plotAverageAndConfidence (overall_cycle_data, controller_params)

    hold on;
    
    x_data = overall_cycle_data.time_ms';
    y_data = overall_cycle_data.mean_pressure_kPa';
    error_data = overall_cycle_data.conf_interval_pressure_kPa';
    
    plot (x_data, y_data, ...
        'Color', 0 * ones(1,3), ...
        'LineWidth', 2);
    
    % Plot the shaded area for the confidence interval
    fill([x_data, fliplr(x_data)], ...
        [y_data - error_data, fliplr(y_data + error_data)], ...
        'r', ...
        'FaceColor', 0 * ones(1,3), ...
        'FaceAlpha', 0.25, ...
        'EdgeColor', 'none');
    
    % Plot programmed trajectory
    plot(controller_params.trajectory_time_ms, ...
        controller_params.trajectory_pressure_kPa, 'k--', 'LineWidth', 2);
    
    
    
    % Format graph
    % Remove padding around the plot
    axis tight; % Ensures axes are tightly fitted to the data
    % set(gca, 'LooseInset', max(get(gca, 'TightInset'), 0.02)); % Removes extra padding
    
    % Improve plot appearance
    ylim([0, inf])
    xlim([0, inf])
    grid on;
    hold off;
    improvePlot();
    
    % Set the font size for tick marks
    % set(gca, 'FontSize', 24); 
    
    % Add labels and title
    xlabel('Time (s)', 'FontWeight', 'Bold');
    ylabel('Pressure (kPa)', 'FontWeight', 'Bold');
    
    % Set legend
    % legend('Mean pressure', '95% confidence interval', 'Programmed trajectory');

end

function plotOverlaidCycles(resampled_cycle_data, controller_params, plot_frequency)

    hold on;
    
    num_total_cycles = numel(resampled_cycle_data);
    cycles_to_plot = unique([1, plot_frequency:plot_frequency:num_total_cycles, num_total_cycles]);
    
    x_data = [resampled_cycle_data(cycles_to_plot).time_ms]';
    y_data = [resampled_cycle_data(cycles_to_plot).pressure_kPa]';
    color_data = linspace(0, 0.8, numel(cycles_to_plot))' * ones(1,3);
    
    for temp_index = 1:numel(cycles_to_plot)
    
        plot (x_data(temp_index, :), ...
            y_data(temp_index, :), ...
            'Color', color_data(temp_index, :), ...
            'LineWidth', 2);
    
    end
    
    % % Plot programmed trajectory
    % plot(controller_params.trajectory_time_ms, ...
    %     controller_params.trajectory_pressure_kPa, 'k--', 'LineWidth', 2);
    
    
    
    % Format graph
    % Remove padding around the plot
    axis tight; % Ensures axes are tightly fitted to the data
    % set(gca, 'LooseInset', max(get(gca, 'TightInset'), 0.02)); % Removes extra padding
    
    % Improve plot appearance
    ylim([0, inf])
    xlim([0, inf])
    grid on;
    hold off;
    improvePlot();
    
    % Set the font size for tick marks
    % set(gca, 'FontSize', 24); 
    
    % Add labels and title
    xlabel('Time (s)', 'FontWeight', 'Bold');
    ylabel('Pressure (kPa)', 'FontWeight', 'Bold');
    
end
function plotIndividualCycles(resampled_cycle_data, controller_params, plot_frequency)

    hold on;
    
    num_total_cycles = numel(resampled_cycle_data);
    cycles_to_plot = unique([1, plot_frequency:plot_frequency:num_total_cycles, num_total_cycles]);
    
    x_data = [resampled_cycle_data(cycles_to_plot).time_ms]' / max(controller_params.trajectory_time_ms);
    y_data = [resampled_cycle_data(cycles_to_plot).pressure_kPa]';
    color_data = linspace(0, 0.8, numel(cycles_to_plot))' * ones(1,3);
    
    for temp_index = 1:numel(cycles_to_plot)
    
        plot (x_data(temp_index, :) + temp_index, ...
            y_data(temp_index, :), ...
            'Color', color_data(temp_index, :), ...
            'LineWidth', 2);
    
    end
    
    xtick_frequency = 5;
    xticks([1, 2:xtick_frequency:numel(cycles_to_plot)])
    xticklabels([1, cycles_to_plot(2:xtick_frequency:numel(cycles_to_plot))]);
    
    
    
    % Format graph
    % Remove padding around the plot
    axis tight; % Ensures axes are tightly fitted to the data
    
    % Improve plot appearance
    ylim([0, 75])
    xlim([0, inf])
    grid on;
    hold off;
    improvePlot();
    
    % Set the font size for tick marks
    % set(gca, 'FontSize', 24); 
    
    % Add labels and title
    xlabel('Cycle (-)', 'FontWeight', 'Bold');
    ylabel('Pressure (kPa)', 'FontWeight', 'Bold');
    % 
    % % Adjust figure size (double-width)
    % set(gcf, 'rend', 'painters', 'Units', 'pixels', 'pos', ...
    %         [100 100 2*4*200 3*200]);
end