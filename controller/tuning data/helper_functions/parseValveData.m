function parsed_valve_data = parseValveData (input_filepath, pressure_thresholds)

    % Read the file as text
    input_text_data = fileread(input_filepath);
    
    % Split into lines
    input_lines = regexp(input_text_data, '\r?\n', 'split');
    
    % Initialize arrays
    data = nan([256, 2]);
    
    % Loop through lines and extract data
    for line_index = 2:length(input_lines)
    
        % Extract current line
        temp_line = strtrim(input_lines{line_index});
    
        % Match lines like: "PWM Value: 0"
        pwm_line = regexp(temp_line, '^PWM Value:\s*(\d+)', 'tokens');
    
        % Match lines like: "Pressure: 18.02 PSI"
        pressure_line = regexp(temp_line, '^Pressure:\s*([-+]?\d*\.?\d+)\s*PSI', 'tokens');
    
        if ~isempty(pwm_line)
            temp_pwm_value = str2double(pwm_line{1}{1});
        end
    
        if ~isempty(pressure_line)
            temp_pressure_value = str2double(pressure_line{1}{1});
    
            % Store row [PWM, Pressure]
            row_index = floor(line_index / 2);
            data(row_index, :) = [temp_pwm_value, temp_pressure_value];
        end
    end
    
    % Remove initial row of PWM = 0
    data = data(2:end, :);
    
    pressure_start_psi = mean(data(1:50, 2), 'omitnan');
    pressure_end_psi = mean(data(end-50:end, 2), 'omitnan');
    pressure_change_psi = abs(pressure_start_psi - pressure_end_psi);
    
    pressure_scaled = (data(:, 2) - min([pressure_start_psi, pressure_end_psi])) ...
                        ./ pressure_change_psi;
    
    
    valid_indices = find(all([ ...
                        pressure_scaled >= pressure_thresholds(1), ...
                        pressure_scaled <= pressure_thresholds(2), ...
                        data(:, 1) >= 100], 2));
    
    pwm_limits = [data(valid_indices(1) - 1, 1), ...
                    data(valid_indices(end) + 1, 1)];

    pwm_scaled = (data(:, 1) - min(pwm_limits)) ...
                ./ (range(pwm_limits));


    % Store parsed outputs
    parsed_valve_data.data = data;
    parsed_valve_data.pwm_limits = pwm_limits;
    parsed_valve_data.pwm_scaled = pwm_scaled;
    parsed_valve_data.pressure_scaled = pressure_scaled;
    parsed_valve_data.pressure_start_psi = pressure_start_psi;
    parsed_valve_data.pressure_end_psi = pressure_end_psi;
    parsed_valve_data.pressure_thresholds = pressure_thresholds;

end