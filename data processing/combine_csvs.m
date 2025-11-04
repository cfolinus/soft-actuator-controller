% Author: C Folinus, MIT, 10/2025
% -----------------------------------------------------------------------
% Revised:
% Changes:
%   - 
% ----------------------------------------------------------------------
%
% This script processes cycle testing pressure-time data from test results in a
% specified folder (directory_name). For each .csv that exists in the
% contents of the specified folder, the script can import and process
% raw .csv data and save .mat files corresponding to each .csv. The script can
% also combine data from .mat files for specimens with the same ID number
% (corresponding to interrupted dest data).
%
% The script considers a test to have `failed` or `concluded` using pressure
% conditions defined as relative fractions (alpha_confidence) of the programmed
% pressure trajectory. The programmed pressure trajectory and other controller
% settings are stored at the beginning of the .csv, imported, and saved in the
% output .mat files.
%
% ----------------------------------------------------------------------

clear; close all;
addpath(genpath('helper_functions'));



%% DEFINE SETTINGS FOR RUNNING THIS SCRIPT
% Relative path to directory containing .csv data
directory_name = fullfile('data', 'cycles', 'Laced');

% Should raw .csvs be opened and converted to .mat?
enable_reprocess_data = true;

% Should .mat files for individual trials be combined?
enable_combine_trials = true;

% Number of time interpolation points for resampling time-pressure data
num_time_points = 100;

% Significance level for computing confidence intervals
alpha_confidence = 0.05;

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

% Define units for conversions
units.psi_to_kPa = 6.89476;
units.kPa_to_psi = 1 / 6.89476;



%% LOAD, PROCESS, AND EXPORT .CSV DATA
if enable_reprocess_data

    fprintf('Processing individual files...\n');

    % Identify contents of specified directory
    directory_contents = dir(fullfile(directory_name, '*.csv'));

    % Load, process, and export raw data from specified directory into .mat
    for file_index = 1:numel(directory_contents)
    
        fprintf('\tFile %i of %i...', file_index, numel(directory_contents));
    
        % Assemble input .csv filepath
        temp_csv_filename = directory_contents(file_index).name;
        temp_csv_filepath = fullfile(directory_name, temp_csv_filename);
    
        % Construct filepath for output .mat file
        [~, temp_base_filename, ~] = fileparts(temp_csv_filepath);
        temp_mat_filepath = fullfile(directory_name, [temp_base_filename, '.mat']);
       
        % Load data
        [controller_params, raw_data] = loadRawData(temp_csv_filepath, units);
        controller_params.alpha_pressure_threshold = alpha_pressure_threshold;
    
        % Process data for thie file
        [raw_cycle_data, resampled_cycle_data, all_raw_cycle_data] = ...
                                            splitAndResampleData (...
                                                    raw_data, ...
                                                    controller_params, ...
                                                    num_time_points, ...
                                                    alpha_pressure_threshold, ...
                                                    units);
        overall_cycle_data = computeOverallMetrics (resampled_cycle_data, ...
                                                    alpha_confidence);
        % Save data to .mat
        fprintf(' saving...');
        save (temp_mat_filepath, ...
            'controller_params', ...
            'raw_cycle_data', ...
            'resampled_cycle_data', ...
            'overall_cycle_data', ...
            'all_raw_cycle_data');
        fprintf(' saved.\n');
        
    end

    clear controller_params raw_cycle_data resampled_cycle_data overall_cycle_data
end



%% COMBINE .MAT DATA FOR FILES WITH THE SAME SPECIMEN ID
if enable_combine_trials

    fprintf('Combining individual files...\n')

    directory_contents = dir(fullfile(directory_name, 'cycle_specimen*_trial*.mat'));
    parts = split({directory_contents.name}, '_');

    % Check for empty or invalid directory
    if isempty(parts)
        error('Error: specified directory %s does not contain valid file names', directory_name)
    end

    % Determine ID numbers for the specimens in this directory
    specimen_ids = {parts{:, :, 2}};
    unique_specimen_ids = unique(specimen_ids);

    % For each unique specimen ID, identify all files and combine
    for unique_specimen_index = 1:numel(unique_specimen_ids)
    
        % Identify all files for this specimen
        file_indices = strcmp(specimen_ids, unique_specimen_ids{unique_specimen_index});
        temp_filenames = {directory_contents(file_indices).name};
    
        % Loop over each filename
        for file_index = 1:numel(temp_filenames)
            
            % Load data for this file
            temp_data = load(fullfile(directory_name, temp_filenames{file_index}));

            % Check that the file is not empty
            is_empty_cycles = isempty(temp_data.raw_cycle_data);
    
            % For valid (non-empty files), append data
            if not(is_empty_cycles)
                if not(exist('controller_params'))
                    controller_params = temp_data.controller_params;
                    raw_cycle_data = temp_data.raw_cycle_data;
                    resampled_cycle_data = temp_data.resampled_cycle_data;
    
                    aggregated_cycle_data = temp_data.overall_cycle_data;
    
                else
                    % TODO: check that controller params haven't changed!
        
                    raw_cycle_data = [raw_cycle_data; temp_data.raw_cycle_data];
                    resampled_cycle_data = [resampled_cycle_data, temp_data.resampled_cycle_data];
                    aggregated_cycle_data = [aggregated_cycle_data, temp_data.overall_cycle_data];
        
                end
            end
        end

        % Compute overall metrics for combined data
        overall_cycle_data = computeOverallMetrics (resampled_cycle_data, alpha_confidence);

        % Save combined file
        combined_mat_filename = sprintf('cycle_combined_%s.mat', ...
                                    unique_specimen_ids{unique_specimen_index});
        combined_mat_filepath = fullfile(directory_name, combined_mat_filename);
        save(combined_mat_filepath, ...
            'controller_params', ...
            'raw_cycle_data', ...
            'resampled_cycle_data', ...
            'overall_cycle_data', ...
            'aggregated_cycle_data');

        clear('controller_params', ...
            'raw_cycle_data', ...
            'resampled_cycle_data', ...
            'overall_cycle_data', ...
            'aggregated_cycle_data');
    
    end
end