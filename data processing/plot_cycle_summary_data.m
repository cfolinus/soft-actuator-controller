clear; close all;
addpath(genpath('helper_functions'));

% Define colors
plot_spec.colors.teal_light = [82, 196, 204] / 255;
plot_spec.colors.blue_soft = [82, 108, 204] / 255;
plot_spec.colors.pink = [251, 81, 115] / 255;
plot_spec.colors.orange = [255, 149, 0] / 255;

plot_spec.color_names.fff = 'teal_light';
plot_spec.color_names.fff_handcast = 'blue_soft';
plot_spec.color_names.sla = 'pink';
plot_spec.color_names.pj = 'orange';
plot_spec.labels = {'fff', 'fff_handcast', 'sla', 'pj'};
plot_spec.display_labels = {'FFF', 'FFF, hand cast', 'SLA', 'PJ'};

plot_spec.marker_size = 20;
plot_spec.scatter_marker_size = 40;

% Define plot specifications
plot_spec.plot_width_px = 2 * 400;
plot_spec.plot_height_px = 2 * 300;
improveFig = @(plot_width_px, plot_height_px) ...
    improveJournalFig (plot_width_px, plot_height_px);

alpha_confidence = 0.05;

%% MANUALLY ENTER DATA FROM CYCLE TESTING
% Each entry in combined_data.(actuator_type) is an individual actuator
% TODO: REPLACE WITH REAL DATA
% TODO: LOAD FROM SPREADSHEET
combined_data.fff = [222, 520, 175, 129, 118];
combined_data.fff_handcast = [2657, 3095, 4566, 5618, 4335];
combined_data.sla = [1137, 151, 592, 674, 518];
combined_data.pj = [491, 877, 803, 527, 351];







%% PLOT PRESSURE PROFILES - TOGETHER
% TODO: CHECK UNITS OF TIME
% TODO: update with actual trajectory
% TODO: create combined version with all strategies
figure ('Name', 'Pressure profiles - all'); hold on;
num_cycles_to_plot = 5;

input_files = {fullfile('data', 'cycles', 'Green', 'cycle_combined_specimen36.mat'), ...
                fullfile('data', 'cycles', 'Green', 'cycle_combined_specimen37.mat'), ...
                fullfile('data', 'cycles', 'Green', 'cycle_combined_specimen45.mat'), ...
                fullfile('data', 'cycles', 'Green', 'cycle_combined_specimen46.mat')};

% Load data
for strategy_index = 1:4

    strategy_name = plot_spec.labels{strategy_index};


    input_filepath = input_files{strategy_index};
    controller_params = load(input_filepath).controller_params;
    raw_cycle_data = load(input_filepath).raw_cycle_data;
    
    % Plot to-be-followed trajectory
    if strategy_index == 1
        pressure_trajectory.time_ms = controller_params.trajectory_time_ms;
        pressure_trajectory.pressure_kPa = controller_params.trajectory_pressure_kPa;
        
        x_data = repmat(pressure_trajectory.time_ms, [num_cycles_to_plot, 1])' ...
            + (max(pressure_trajectory.time_ms) * (0:(num_cycles_to_plot - 1)));
        x_data = x_data(:);
        y_data = repmat(pressure_trajectory.pressure_kPa, [num_cycles_to_plot, 1])';
        y_data = y_data(:);
        plot (x_data, y_data, ...
            '-', ...
            'Color', [0, 0, 0], ...
            'LineWidth', 1);
    end
        
    
    
    % Plot followed trajectory
    for cycle_index = 1 + 0:num_cycles_to_plot
    
        cycle_data.time_ms = raw_cycle_data{cycle_index, 1}.time_ms;
        cycle_data.pressure_kPa = raw_cycle_data{cycle_index, 1}.pressure_kPa;
        
        x_data = max(pressure_trajectory.time_ms) * (cycle_index - 1) + cycle_data.time_ms;
        y_data = cycle_data.pressure_kPa;
        color_data = plot_spec.colors.(plot_spec.color_names.(strategy_name));
    
        plot (x_data, y_data, ...
            '-', ...
            'Color', color_data, ...
            'LineWidth', 3);
    
    end
    

end
axis([0, 15, 0, inf])
xticks (0:3:15)
xlabel ('Time [s]');
ylabel ('Pressure [kPa]');

improveFig (0.75 * plot_spec.plot_width_px, 0.5 * 0.75 * plot_spec.plot_height_px);



%% PLOT PRESSURE PROFILES - SUBPLOTS
% TODO: CHECK UNITS OF TIME
% TODO: update with actual trajectory
% TODO: create combined version with all strategies
figure ('Name', 'Pressure profiles - subplots');
t = tiledlayout (4, 1);
num_cycles_to_plot = 5;

input_files = {fullfile('data', 'cycles', 'Green', 'cycle_combined_specimen36.mat'), ...
                fullfile('data', 'cycles', 'Green', 'cycle_combined_specimen37.mat'), ...
                fullfile('data', 'cycles', 'Green', 'cycle_combined_specimen45.mat'), ...
                fullfile('data', 'cycles', 'Green', 'cycle_combined_specimen46.mat')};

% Load data
for strategy_index = 1:4

    strategy_name = plot_spec.labels{strategy_index};

    nexttile(t, strategy_index); hold on;

    input_filepath = input_files{strategy_index};
    controller_params = load(input_filepath).controller_params;
    raw_cycle_data = load(input_filepath).raw_cycle_data;
    
    % Plot to-be-followed trajectory
    pressure_trajectory.time_ms = controller_params.trajectory_time_ms;
    pressure_trajectory.pressure_kPa = controller_params.trajectory_pressure_kPa;
    
    x_data = repmat(pressure_trajectory.time_ms, [num_cycles_to_plot, 1])' ...
        + (max(pressure_trajectory.time_ms) * (0:(num_cycles_to_plot - 1)));
    x_data = x_data(:);
    y_data = repmat(pressure_trajectory.pressure_kPa, [num_cycles_to_plot, 1])';
    y_data = y_data(:);
    plot (x_data, y_data, ...
        '-', ...
        'Color', [0, 0, 0], ...
        'LineWidth', 1);
    
    
    
    % Plot followed trajectory
    for cycle_index = 1 + 0:num_cycles_to_plot
    
        cycle_data.time_ms = raw_cycle_data{cycle_index, 1}.time_ms;
        cycle_data.pressure_kPa = raw_cycle_data{cycle_index, 1}.pressure_kPa;
        
        x_data = max(pressure_trajectory.time_ms) * (cycle_index - 1) + cycle_data.time_ms;
        y_data = cycle_data.pressure_kPa;
        color_data = plot_spec.colors.(plot_spec.color_names.(strategy_name));
    
        plot (x_data, y_data, ...
            '-', ...
            'Color', color_data, ...
            'LineWidth', 3);
    
    end
    
    axis([0, 15, 0, inf])
    xticks (0:3:15)
    xlabel ('Time [s]');
    ylabel ('Pressure [kPa]');

end
improveFig (0.75 * plot_spec.plot_width_px, 2 * 0.75 * plot_spec.plot_height_px);




%% PLOT INFLATION PRESSURE




%% PLOT NUMBER OF CYCLES
figure('Name', 'Number of cycles');
hold on;

for strategy_index = 1:4
    strategy_name = plot_spec.labels{strategy_index};

    color_data = plot_spec.colors.(plot_spec.color_names.(strategy_name));
    x_data = strategy_index * ones(size(combined_data.(strategy_name)));
    y_data = combined_data.(strategy_name);

    scatter (x_data, y_data, ...
        plot_spec.scatter_marker_size, ...
        'Marker', 'diamond', ...
        'MarkerFaceColor', color_data, ...
        'MarkerEdgeColor', color_data, ...
        'MarkerFaceAlpha', 0.5, ...
        'MarkerEdgeAlpha', 1.0);

    [y_mean, ~, y_uncert] = calcMeanUncert(y_data, alpha_confidence);
    errorbar (strategy_index, y_mean, y_uncert, y_uncert, ...
        '.', ...
        'Color', color_data, ...
        'MarkerSize', plot_spec.marker_size, ...
        'LineWidth', 1.5, ...
        'CapSize', 10);
end


axis([0, 5, -inf, inf]);
xticks(1:4);
xticklabels(plot_spec.display_labels)
xlabel ('Fabrication strategy [-]');
ylabel ('Cycles to failure [-]')
improveFig (plot_spec.plot_width_px, plot_spec.plot_height_px)