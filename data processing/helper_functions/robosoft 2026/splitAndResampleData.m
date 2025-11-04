function [raw_cycle_data, resampled_cycle_data, all_raw_cycle_data] = splitAndResampleData (...
    raw_data, controller_params, num_time_points, alpha_pressure_threshold, units)
    
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
    
    end


    all_raw_cycle_data = raw_cycle_data;


    % Manually check for end conditions
    upper_threshold_kPa = (1 - alpha_pressure_threshold) ...
        * max(controller_params.trajectory_pressure_kPa);
    lower_threshold_kPa = alpha_pressure_threshold ...
        * max(controller_params.trajectory_pressure_kPa);
    is_failed_cycle = nan(1, 2);
    temp_flagged_cycle = nan;

    
    for cycle_index = 1:num_raw_cycles
        if not(any(is_failed_cycle))

            temp_cycle_data = raw_cycle_data{cycle_index};
    
            % Check for pressure during upper hold period
            temp_event_indices = [temp_cycle_data.time_ms > controller_params.trajectory_time_ms(2), ...
                temp_cycle_data.time_ms < controller_params.trajectory_time_ms(3), ...
                temp_cycle_data.time_ms < controller_params.trajectory_time_ms(4)];
    
            temp_time_indices = and(temp_event_indices(:, 1), temp_event_indices(:, 2));
            if nnz(temp_time_indices) > 0
                max_upper_hold_pressure_kPa = max(temp_cycle_data.pressure_kPa(temp_time_indices));
                is_failed_cycle(1) = max_upper_hold_pressure_kPa < upper_threshold_kPa;
            else
                is_failed_cycle(1) = 1;
            end
      
    
            % Check for pressure during lower hold period
            temp_time_indices = and(temp_event_indices(:, 2), temp_event_indices(:, 3));
            if nnz(temp_time_indices) > 0
                min_lower_hold_pressure_kPa = min(temp_cycle_data.pressure_kPa(temp_time_indices));
                is_failed_cycle(2) = min_lower_hold_pressure_kPa > lower_threshold_kPa;
            else
                is_failed_cycle(2) = 1;
            end

            if any(is_failed_cycle)
                temp_flagged_cycle = cycle_index;
            end
        end
    end

    % temp_flagged_cycle = find(any(is_failed_cycle, 2), 1);

    
    if not(isnan(temp_flagged_cycle))
        temp_final_cycle = temp_flagged_cycle - 1;
    else
        temp_final_cycle = num_raw_cycles;
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
        
    % Convert resampled data to struct
    resampled_cycle_data = [resampled_cycle_data{:}];
    
end
