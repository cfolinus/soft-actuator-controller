clear; close all;
addpath(genpath('helper_functions'));



%% DEFINE SETTINGS FOR RUNNING THIS SCRIPT
% Relative path to directory containing data
directory_name = fullfile('data', 'cycles');

% Relative path to directory for exporting figures
fig_base_directory = fullfile('figures');

% Should figures be saved after running this script?
enable_save_figs = false;

% Name of actuator type, corresponding to subdirectory within directory_name
actuator_type = 'Bare';

% Name of specific trial (.mat file) to be loaded
trial_name = 'cycle_specimen16_trial1';

% Relative threshold for determining actuator failure, based on assuming a
% programmed rectangular wave. Tests fail when any of the following conditions
% are met: 
%   - Peak pressure for the cycle is
%       below (1 - alpha) * trajectory peak pressure
%   - Average pressure for the inflation period is
%       below (1 - alpha) * trajectory peak pressure
%   - Average pressure for the deflation period exceeds 
%       alpha * trajectory peak pressure
alpha_pressure_threshold = 0.3;

% Define plotting specifications
plot_width_px = 4 * 200;
plot_height_px = 3 * 200;
colors.red = [204, 24, 0] / 255;

% Define handle for figure formatting
improveFig = @(plot_width_px, plot_height_px) improveHangerFig(plot_width_px, plot_height_px);

% Define units for conversions
units.psi_to_kPa = 6.89476;
units.kPa_to_psi = 1 / 6.89476;



%% LOAD AND PROCESS DATA
% Assemble filepaths and directories
mat_filepath = fullfile('data', 'cycles', ...
                        actuator_type, [trial_name, '.mat']);
fig_directory = fullfile(fig_base_directory, actuator_type, trial_name);

% Load data
data = load(mat_filepath);

% Extract trajectory information from controller_params
trajectory_time_ms = data.controller_params.trajectory_time_ms;
trajectory_pressure_kPa = data.controller_params.trajectory_pressure_kPa;
max_trajectory_pressure_kPa = max(trajectory_pressure_kPa);

% Compute pressure-related metrics for each cycle
num_raw_cycles = height(data.all_raw_cycle_data);
max_overall_pressure_kPa = nan(num_raw_cycles, 1);
mean_high_pressure_kPa = nan(num_raw_cycles, 1);
mean_low_pressure_kPa = nan(num_raw_cycles, 1);
for cycle_index = 1:num_raw_cycles

    % Extract current cycle data
    temp_cycle_data = data.all_raw_cycle_data{cycle_index};

    % Determine overall peak pressure during cycle
    max_overall_pressure_kPa(cycle_index) = max(temp_cycle_data.pressure_kPa);

    % Determine mean pressure during inflation period
    temp_event_indices = and(temp_cycle_data.time_ms >= 0.5, ...
                            temp_cycle_data.time_ms <= 1.5);
    mean_high_pressure_kPa(cycle_index) = ...
                            mean(temp_cycle_data.pressure_kPa(temp_event_indices));

    % Determine mean pressure during deflation period
    temp_event_indices = and(temp_cycle_data.time_ms >= 2, ...
                            temp_cycle_data.time_ms <= 3);
    mean_low_pressure_kPa(cycle_index) = ...
                            mean(temp_cycle_data.pressure_kPa(temp_event_indices));

end

% Determine first cycle of screen runout
temp_cycle_length = nan(num_raw_cycles, 1);
for cycle_index = 1:num_raw_cycles

    temp_cycle_length(cycle_index) = height(data.all_raw_cycle_data{cycle_index, 1});

end


% Determine first cycle to trigger true failure criteria
upper_pressure_threshold_kPa = (1 - alpha_pressure_threshold) * max_trajectory_pressure_kPa;
lower_pressure_threshold_kPa = alpha_pressure_threshold * max_trajectory_pressure_kPa;
is_failed_cycle = any( ...
    [max_overall_pressure_kPa <= upper_pressure_threshold_kPa, ...
    mean_high_pressure_kPa <= upper_pressure_threshold_kPa, ...
    mean_low_pressure_kPa >= lower_pressure_threshold_kPa], 2);
failed_cycle_index = find(is_failed_cycle, 1);

% Determine number of successful cycles
% If cycle n triggered failure, set cycle n-1 to be last successful cycle
if not(isempty(failed_cycle_index))
    num_cycles = failed_cycle_index - 1;

% If no cycles triggered, set last recorded cycle to be last successful cycle
else
    num_cycles = num_raw_cycles;
end



%% RUNOUT DETECTION
% Check for screen runout condition: we start recording zero cycles
cycle_start_screen_runout = find(isnan(mean_high_pressure_kPa), 1);

% Look at raw data
temp_runout_data = data.all_raw_cycle_data(cycle_start_screen_runout + (-1:5));
temp_runout_data = cell2mat(temp_runout_data);

pre_runout_data = data.all_raw_cycle_data(1:cycle_start_screen_runout);
pre_runout_data = cell2mat(pre_runout_data);



%% VISUALIZE RESULTS
if num_cycles > 0

    % Plot metrics
    figure('Name', 'Pressure metrics over test duration');
    tiledlayout(1,3);
    
    nexttile; hold on;
    plot(max_overall_pressure_kPa, ...
        '.-', ...
        'LineWidth', 2, ...
        'MarkerSize', 10, ...
        'Color', 0 * ones(1,3));
    yline(max(trajectory_pressure_kPa), ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 1, ...
        'Color', 0 * ones(1,3));
    yline(0.7 * max(trajectory_pressure_kPa), ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 0.7, ...
        'Color', colors.red);
    plot(num_cycles, max_overall_pressure_kPa(num_cycles), ...
        '.', ...
        'MarkerSize', 20, ...
        'Color', colors.red);
    xline(num_cycles, ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 1, ...
        'Color', colors.red);
    xlabel ('Cycle index [-]');
    ylabel ('Max overall pressure [kPa]');
    
    nexttile; hold on;
    plot(mean_high_pressure_kPa, ...
        '.-', ...
        'LineWidth', 2, ...
        'MarkerSize', 10, ...
        'Color', 0 * ones(1,3));
    yline(max(trajectory_pressure_kPa), ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 1, ...
        'Color', 0 * ones(1,3));
    yline((1 - alpha_pressure_threshold) * max(trajectory_pressure_kPa), ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 0.7, ...
        'Color', colors.red);
    plot(num_cycles, mean_high_pressure_kPa(num_cycles), ...
        '.', ...
        'MarkerSize', 20, ...
        'Color', colors.red);
    xline(num_cycles, ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 1, ...
        'Color', colors.red);
    xlabel ('Cycle index [-]');
    ylabel ('Mean inflation pressure [kPa]');
    
    nexttile; hold on;
    plot(mean_low_pressure_kPa, ...
        '.-', ...
        'LineWidth', 2, ...
        'MarkerSize', 10, ...
        'Color', 0 * ones(1, 3));
    yline(max(trajectory_pressure_kPa), ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 1, ...
        'Color', 0 * ones (1,3));
    yline(alpha_pressure_threshold * max(trajectory_pressure_kPa), ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 0.3, ...
        'Color', colors.red);
    plot(num_cycles, mean_low_pressure_kPa(num_cycles), ...
        '.', ...
        'MarkerSize', 20, ...
        'Color', colors.red);
    xline(num_cycles, ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 1, ...
        'Color', colors.red);
    xlabel ('Cycle index [-]');
    ylabel ('Mean deflation pressure [kPa]');
    
    improveHangerFig(2 * plot_width_px, plot_height_px)
    
    
    
    % Plot initial 5 cycles and final cycles
    figure ('Name', 'Pressure cycles');
    hold on;
    
    % Plot initial five cycles
    if num_cycles < num_raw_cycles
        cycles_to_plot = [1:5, fliplr(num_cycles - (-1:4))];
        color_data = linspace(0, 0.8, numel(cycles_to_plot))' * ones(1,3);
    
        temp_final_plot_index = numel(cycles_to_plot) - 1;
    elseif num_cycles <= 4
        cycles_to_plot = 1:num_cycles;
        color_data = linspace(0, 0.8, numel(cycles_to_plot))' * ones(1,3);
    
        temp_final_plot_index = num_cycles;

    else
        cycles_to_plot = [1:5, fliplr(num_cycles - (0:4))];
        color_data = linspace(0, 0.8, numel(cycles_to_plot) + 1)' * ones(1,3);
    
        temp_final_plot_index = numel(cycles_to_plot);
    end
    
    % If last sample does not exist in resampled data, resample it
    if not(numel(data.resampled_cycle_data) >= cycles_to_plot(end))
        temp_x_data = data.resampled_cycle_data(1).time_ms/ max(trajectory_time_ms);
        
        % Extract data for this cycle
        temp_cycle_data = data.all_raw_cycle_data{cycles_to_plot(end)};
        
        % Resample cycle data to have consistent number of points
        is_valid_cycle = numel(unique(temp_cycle_data.time_ms)) == numel(temp_cycle_data.time_ms);
        if is_valid_cycle
            temp_resampled_pressure_kPa = interp1(temp_cycle_data.time_ms, ...
                                                        temp_cycle_data.pressure_kPa, ...
                                                        temp_x_data, ...
                                                        'linear', ...
                                                        'extrap');
            temp_y_data = temp_resampled_pressure_kPa';
        
            x_data = [[data.resampled_cycle_data(cycles_to_plot(1:end-1)).time_ms]' / max(trajectory_time_ms); ...
                temp_x_data'];
            y_data = [[data.resampled_cycle_data(cycles_to_plot(1:end-1)).pressure_kPa]'; ...
                temp_y_data];   
    
        else
            x_data = [data.resampled_cycle_data(cycles_to_plot(1:end-1)).time_ms]' / max(trajectory_time_ms);
            y_data = [data.resampled_cycle_data(cycles_to_plot(1:end-1)).pressure_kPa]';
    
            cycles_to_plot = cycles_to_plot(1:end - 1);
        end
    
    else
        x_data = [data.resampled_cycle_data(cycles_to_plot).time_ms]' / max(trajectory_time_ms);
        y_data = [data.resampled_cycle_data(cycles_to_plot).pressure_kPa]';
    end
    
    for temp_index = 1:numel(cycles_to_plot)
    
        plot (x_data(temp_index, :) + temp_index, ...
            y_data(temp_index, :), ...
            'Color', color_data(temp_index, :), ...
            'LineWidth', 2);
    
    end
    
    x_data = data.resampled_cycle_data(num_cycles).time_ms / max(trajectory_time_ms);
    y_data = [data.resampled_cycle_data(num_cycles).pressure_kPa]';
    color_data = colors.red;
    
    plot (x_data + temp_final_plot_index, ...
        y_data, ...
        'Color', color_data, ...
        'LineWidth', 2);
    
    yline(max_trajectory_pressure_kPa, ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 1, ...
        'Color', 0 * ones(1, 3));
    yline(upper_pressure_threshold_kPa, ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 0.7, ...
        'Color', colors.red);
    yline(lower_pressure_threshold_kPa, ...
        '--', ...
        'LineWidth', 1, ...
        'Alpha', 0.3, ...
        'Color', colors.red);
    
    xticks(1:numel(cycles_to_plot));
    xticklabels(cycles_to_plot);
    
    % Format graph
    % Improve plot appearance
    ylim([0, 75])
    xlim([0, inf])
    
    % Add labels and title
    xlabel('Cycle index [-]');
    ylabel('Pressure [kPa]');
    
    improveFig(plot_width_px, 0.5 * plot_height_px);
    
    
    % Save open figures
    if enable_save_figs
        saveOpenFigs(fig_directory, 'png');
    end
end