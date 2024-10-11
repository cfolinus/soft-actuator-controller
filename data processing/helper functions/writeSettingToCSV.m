function writeSettingToCSV(dataLine, filename)
    % Helper function to parse and write settings to CSV
    settingPairs = {
        'KP', 'KI', 'KD', 'Controller Output Threshold', ...
        'Filter alpha', 'Sensor offset', 'Pressure Read Delay', ...
        'Interpolation Calculation Delay', 'Controller Delay', 'Traj times', 'Traj pressures'
    };

    for i = 1:length(settingPairs)
        if contains(dataLine, [settingPairs{i}, ','])
            value = extractAfter(dataLine, ',');
            writecell({settingPairs{i}, value, ''}, filename, 'WriteMode', 'append');
            break;
        end
    end
end