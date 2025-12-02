clear; close all;
addpath(genpath('helper_functions'));

% Define location of input file
% input_directory = fullfile ('kim possible');
% input_filenames = {'tuning_data_pressure_251126_15psi', ...
%                         'tuning_data_pressure_251126_20psi', ...
%                         'tuning_data_pressure_251126_30psi'};
% output_figure_name = 'kim possible - tuning_data_pressure_251126';
% 
% input_directory = fullfile ('kim possible');
% input_filenames = {'tuning_data_vent_251126_15psi', ...
%                         'tuning_data_vent_251126_20psi', ...
%                         'tuning_data_vent_251126_30psi_trial2'};
% output_figure_name = 'kim possible - tuning_data_vent_251126';

% input_directory = fullfile ('kim possible', 'secondary configuration');
% input_filenames = {'tuning_data_vent_251126_15psi', ...
%                         'tuning_data_vent_251126_20psi', ...
%                         'tuning_data_vent_251126_30psi'};
% output_figure_name = 'kim possible - secondary configuration - tuning_data_vent_251126';



% input_directory = fullfile ('ron stoppable');
% input_filenames = {'tuning_data_pressure_251125_15psi', ...
%                         'tuning_data_pressure_251125_20psi', ...
%                         'tuning_data_pressure_251125_30psi'};
% output_figure_name = 'ron stoppable - tuning_data_pressure_251125';

% input_directory = fullfile ('ron stoppable');
% input_filenames = {'tuning_data_vent_251125_15psi', ...
%                         'tuning_data_vent_251125_20psi', ...
%                         'tuning_data_vent_251125_30psi'};
% output_figure_name = 'ron stoppable - tuning_data_vent_251125';
% 
% input_directory = fullfile ('ron stoppable', 'secondary configuration');
% input_filenames = {'tuning_data_vent_251126_15psi', ...
%                         'tuning_data_vent_251126_20psi', ...
%                         'tuning_data_vent_251126_30psi'};
% output_figure_name = 'ron stoppable - secondary configuration - tuning_data_vent_251126';



% input_directory = fullfile ('ron stoppable', 'valve 02');
% input_filenames = {'tuning_data_pressure_251126_15psi', ...
%                         'tuning_data_pressure_251126_20psi', ...
%                         'tuning_data_pressure_251126_30psi'};
% output_figure_name = 'ron stoppable - valve 02 - tuning_data_pressure_251126';
% 
% input_directory = fullfile ('ron stoppable', 'valve 02');
% input_filenames = {'tuning_data_vent_251126_15psi', ...
%                         'tuning_data_vent_251126_20psi', ...
%                         'tuning_data_vent_251126_30psi'};
% output_figure_name = 'ron stoppable - valve 02 - tuning_data_vent_251126';

% input_directory = fullfile ('ron stoppable', 'valve 02', 'secondary configuration');
% input_filenames = {'tuning_data_vent_251126_15psi', ...
%                         'tuning_data_vent_251126_20psi', ...
%                         'tuning_data_vent_251126_30psi'};
% output_figure_name = 'ron stoppable - valve 02 - secondary configuration - tuning_data_vent_251126';
% 


% input_directory = fullfile ('ron stoppable', 'valve 02', 'upstream 45psi');
% input_filenames = {'tuning_data_pressure_251126_15psi', ...
%                         'tuning_data_pressure_251126_20psi', ...
%                         'tuning_data_pressure_251126_30psi'};
% output_figure_name = 'ron stoppable - valve 02 - upstream 45psi - tuning_data_pressure_251126';
% 
input_directory = fullfile ('ron stoppable', 'valve 02', 'upstream 45psi');
input_filenames = {'tuning_data_vent_251126_15psi', ...
                        'tuning_data_vent_251126_20psi', ...
                        'tuning_data_vent_251126_30psi'};
output_figure_name = 'ron stoppable - valve 02 - upstream 45psi - tuning_data_vent_251126';


% Define thresholds for determining when valve has started to open
% Thresholds defined as % of pressure change
pressure_thresholds = [0.05, 0.95];

% Define location for figure outputs
enable_save_figs = true;
fig_directory = fullfile('figures', ...
                        'combined calibration curves');




% Define colors
plot_spec.colors.blue = [0, 129, 204] / 255;
plot_spec.colors.red = [201, 20, 23] / 255;
plot_spec.colors.navy = [0, 77, 128] / 255;

% Define plot specifications
plot_spec.plot_width_px = 3 * 400;
plot_spec.plot_height_px = 3 * 300;
improveFig = @(plot_width_px, plot_height_px) ...
    improveHangerFig (plot_width_px, plot_height_px);



%% Parse input files
num_files = length(input_filenames);
for file_index = 1:num_files

    % Get current filename and filepath
    temp_filename = input_filenames{file_index};
    temp_input_filepath = fullfile (input_directory, [temp_filename, '.txt']);

    % Parse data
    parsed_valve_data(file_index) = parseValveData (temp_input_filepath, pressure_thresholds);

end


plotValveCalibrationCurves (parsed_valve_data, output_figure_name, plot_spec)
improveFig (plot_spec.plot_width_px, plot_spec.plot_height_px);

if enable_save_figs
    saveOpenFigs(fig_directory);

end