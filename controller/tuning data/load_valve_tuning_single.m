clear; close all;
addpath(genpath('helper_functions'));

% Define location of input file
input_directory = fullfile('ron stoppable', ...
                            'valve 02', ...
                            'upstream 45psi');
input_filename = 'tuning_data_pressure_251126_15psi';
input_filepath = fullfile (input_directory, [input_filename, '.txt']);

% Define thresholds for determining when valve has started to open
% Thresholds defined as % of pressure change
pressure_thresholds = [0.05, 0.95];

% Define location for figure outputs
enable_save_figs = true;
fig_directory = fullfile(input_directory, 'figures');




% Define colors
plot_spec.colors.blue = [0, 129, 204] / 255;
plot_spec.colors.red = [201, 20, 23] / 255;
plot_spec.colors.navy = [0, 77, 128] / 255;

% Define plot specifications
plot_spec.plot_width_px = 3 * 400;
plot_spec.plot_height_px = 3 * 300;
improveFig = @(plot_width_px, plot_height_px) ...
    improveHangerFig (plot_width_px, plot_height_px);



%% Parse input file and plot this trial's data
parsed_valve_data = parseValveData (input_filepath, pressure_thresholds);

plotValveTrial (parsed_valve_data, input_filename, plot_spec)

improveFig (plot_spec.plot_width_px, plot_spec.plot_height_px);




%% Save and export figures
if enable_save_figs
    saveOpenFigs(fig_directory);
end