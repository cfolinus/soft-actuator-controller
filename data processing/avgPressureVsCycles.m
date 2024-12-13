% Get data file
[data, filename] = getDataFile();
if isempty(data)
    return;
end

% Assumes time in column 1, pressure in column 2, cycle completion in column 5
time = data(:, 1) / 1000; % Convert from milliseconds to seconds
pressure = data(:, 2);
cycle_complete = data(:, 5); % Column indicating the start of a cycle

% Parse cycles
cycles = parseCycles(time, pressure, cycle_complete);

% Initialize array to store average pressures
avg_pressures = zeros(length(cycles), 1);

% Loop through each cycle
for i = 1:length(cycles)
    cycle_time = cycles{i}.time;
    cycle_pressure = cycles{i}.pressure;
    
    % Select the part of the cycle between 100 ms and 3000 ms
    valid_indices = cycle_time >= 0.1 & cycle_time <= 2.0;
    valid_pressures = cycle_pressure(valid_indices);
    
    % Calculate the average pressure for the selected part of the cycle
    avg_pressures(i) = mean(valid_pressures);
end

% Plot the average pressure vs cycle number
figure;
plot(1:length(avg_pressures), avg_pressures, '-o');

grid on;
axis tight; % Ensures axes are tightly fitted to the data
set(gca, 'LooseInset', max(get(gca, 'TightInset'), 0.02)); % Removes extra padding

ylim([0, 16]);
xlim([0,170]);

% Improve the layout of the plot
improvePlot();
xlabel('Cycle Number', 'FontSize', 32, 'FontWeight', 'Bold');
ylabel('Average Pressure (PSI)', 'FontSize', 32, 'FontWeight', 'Bold');



