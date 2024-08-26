function cycles = parseCycles(time, pressure, cycle_complete)
    % Identify end indices of each cycle based on the cycle_complete column
    end_indices = find(cycle_complete == 1);

    % Initialize cell array to store cycles data
    cycles = {};

    % Extract and store each cycle's data
    start_index = 1;
    for i = 1:length(end_indices)
        end_index = end_indices(i);
        cycle_indices = start_index:end_index;
        cycles{i}.time = time(cycle_indices) - time(cycle_indices(1)); % Normalize to start at zero
        cycles{i}.pressure = pressure(cycle_indices);
        start_index = end_index + 1; % Next cycle starts after the current one ends
    end
end
