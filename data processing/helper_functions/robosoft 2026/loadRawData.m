function [controller_params, raw_data] = loadRawData(csv_filepath, units)
    % Open the file and read its contents
    file_id = fopen(csv_filepath, 'r');
    if file_id == -1
        error('Could not open the file.');
    end
        
    % Parse header lines to extract settings
    controller_params = struct;
    while not(feof(file_id))
    
        % Read current line
        temp_line = fgetl(file_id);
        temp_line = strsplit(temp_line, ',');
    
        % Separate setting name from declared value
        temp_setting_name = temp_line{1};
        try
            temp_setting_value = temp_line{2};
        catch
            temp_setting_value = nan;
        end
    
        % Assign declared setting value to corresponding variable
        switch temp_setting_name
            case 'filename'
                controller_params.filename = temp_setting_value;
            case 'Use KPA?'
                controller_params.use_kPa = str2double(temp_setting_value);
            case 'KP'
                controller_params.gain_proportional = str2double(temp_setting_value);
            case 'KI'
                controller_params.gain_integral = str2double(temp_setting_value);
            case 'KD'
                controller_params.gain_derivative = str2double(temp_setting_value);
            case 'Traj Follow Error Threshold'
                controller_params.threshold_presure_traj_follow_error = ...
                    str2double(temp_setting_value);
            case 'Filter alpha'
                controller_params.filter_alpha = str2double(temp_setting_value);
            case 'Sensor offset'
                controller_params.sensor_offset = str2double(temp_setting_value);
            case 'Pressure Read Delay'
                controller_params.delay_pressure_ms = str2double(temp_setting_value);
            case 'Interpolation Calculation Delay'
                controller_params.delay_interpolation_ms = str2double(temp_setting_value);
            case 'Controller Delay'
                controller_params.delay_controller_ms = str2double(temp_setting_value);
            case 'Traj times'
                controller_params.trajectory_time_ms = 1e-3 * str2double(temp_line(2:end));
            case 'Traj pressures'
                controller_params.trajectory_pressure = str2double(temp_line(2:end));
            case 'Settings:'
            case 'Data:'
                break
            otherwise
                warning('Invalid setting name: %s', temp_setting_name);
        end
    end
    
    fclose(file_id);
    clear temp_line temp_setting_name temp_setting_value
    
    if controller_params.use_kPa
        controller_params.trajectory_pressure_kPa = controller_params.trajectory_pressure;
    else
        controller_params.trajectory_pressure_kPa = controller_params.trajectory_pressure * units.psi_to_kPa;
    end



    %% Import raw data
    % Read actual data starting after the header
    opts = detectImportOptions(csv_filepath);
    raw_data = readtable(csv_filepath, opts);
    
end
