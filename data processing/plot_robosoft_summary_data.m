% Author: C Folinus, MIT, 10/2025
% -----------------------------------------------------------------------
% Revised:
% Changes:
%   - 
% ----------------------------------------------------------------------
%
% This script creates the bar charts for cycle testing data used for our 2026
% RoboSoft submission.
% 
%
% ----------------------------------------------------------------------

clear; close all;
addpath(genpath('helper_functions'));



%% MANUALLY ENTER DATA FROM CYCLE TESTING
% Each entry in combined_data.(actuator_type) is an individual actuator
combined_data.bare = [222, 520, 175, 129, 118];
combined_data.laced = [2657, 3095, 4566, 5618, 4335];
combined_data.tacked = [1137, 151, 592, 674, 518];
combined_data.pinched = [491, 877, 803, 527, 351];

% Define labels for actuator types
actuator_types = {'Bare', 'Laced','Tacked','Pinched'};



%% DEFINE SETTINGS FOR RUNNING THIS SCRIPT
% Significance level for computing confidence intervals
alpha_confidence = 0.05;

% Should figures be saved after running this script?
enable_save_figs = false;

% Relative path for saving generated figures
fig_directory = fullfile('figures');

% Define colorblind-friendly color palette
colors.green = [0, 158, 115] / 255;
colors.blue = [0, 114, 178] / 255;
colors.red = [204, 121, 167] / 255;
colors.black = [0, 0, 0] / 255;



%% ASSEMBLE AND PROCESS DATA
% Assemble data and compute overall metrics
data_array = [combined_data.bare; ...
                combined_data.laced; ...
                combined_data.tacked; ...
                combined_data.pinched]';

data_mean = [mean(combined_data.bare), ...
        mean(combined_data.laced), ...
        mean(combined_data.tacked), ...
        mean(combined_data.pinched)]';

[mean_value, standard_deviation, uncertainty] = ...
    calcMeanUncert (data_array, alpha_confidence);

% Generate categorical array for data
data_categorical = categorical(actuator_types, actuator_types);



%% GENERATE AND SAVE PLOT
figure('Name', 'Overview data'); hold on

% Plot bars with category means
bar(data_categorical, mean_value)

% Plot error bars with uncertainty values
er = errorbar(data_categorical, mean_value, uncertainty, uncertainty);
er.Color = colors.black;
er.LineStyle = 'none';

% Plot raw data points
plot(1 * ones(1, numel(combined_data.bare)), ...
    combined_data.bare, ...
    '.', ...
    'MarkerSize', 25, ...
    'Color', colors.black);
plot(2 * ones(1, numel(combined_data.laced)), ...
    combined_data.laced, ...
    '.', ...
    'MarkerSize', 25, ...
    'Color', colors.black);
plot(3 * ones(1, numel(combined_data.tacked)), ...
    combined_data.tacked, ...
    '.', ...
    'MarkerSize', 25, ...
    'Color', colors.black);
plot(4 * ones(1, numel(combined_data.pinched)), ...
    combined_data.pinched, ...
    '.', ...
    'MarkerSize', 25, ...
    'Color', colors.black);

% Format graph
% May need to comment/uncomment various items to modify style/axes
ylim([0, 10e3]);
yscale log

ylabel("Cycles at constant pressure [-]");

% ax = gca;
% ax.YAxis.Exponent = 3;
% ytickformat('%.e');

improveCatFig();


if enable_save_figs
    saveOpenFigs(fig_directory);
end