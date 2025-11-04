function overall_cycle_data = computeOverallMetrics (resampled_cycle_data, alpha_confidence)

    if isempty(resampled_cycle_data)

        overall_cycle_data = struct;

    else

        resampled_time_ms = resampled_cycle_data(1).time_ms;
        overall_cycle_data.time_ms = resampled_time_ms;
        
        temp_pressure_kPa = [resampled_cycle_data(:).pressure_kPa];
        
        overall_cycle_data.mean_pressure_kPa = mean(temp_pressure_kPa, 2);
        overall_cycle_data.std_pressure_kPa = std(temp_pressure_kPa, [], 2);
        
        temp_num_cycles = numel(resampled_cycle_data);
        t_critical = tinv(1 - 0.5 * alpha_confidence, temp_num_cycles - 1);
        overall_cycle_data.conf_interval_pressure_kPa = ...
            t_critical * (overall_cycle_data.std_pressure_kPa / sqrt(temp_num_cycles));
    
        overall_cycle_data.num_cycles = temp_num_cycles;

    end

end