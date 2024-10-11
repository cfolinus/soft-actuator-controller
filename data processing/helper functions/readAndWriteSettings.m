function [kpValue, kiValue, kdValue] = readAndWriteSettings(s, filename)
    kpValue = NaN; kiValue = NaN; kdValue = NaN;  % Initialize PID values
    disp('Reading settings data...');
    
    while true
        dataLine = readline(s);  % Read line from serial
        dataLine = strtrim(dataLine);  % Remove any whitespace

        % Check if settings section is over
        if strcmp(dataLine, 'Data:')
            writecell({'Data:', '', ''}, filename, 'WriteMode', 'append');
            disp('Settings data received');
            break;  % Exit the loop to start receiving real-time data
        end

        % Parse the settings and write to CSV
        if contains(dataLine, 'KP,')
            kpValue = str2double(extractAfter(dataLine, ','));
            writecell({'KP', kpValue, ''}, filename, 'WriteMode', 'append');
        elseif contains(dataLine, 'KI,')
            kiValue = str2double(extractAfter(dataLine, ','));
            writecell({'KI', kiValue, ''}, filename, 'WriteMode', 'append');
        elseif contains(dataLine, 'KD,')
            kdValue = str2double(extractAfter(dataLine, ','));
            writecell({'KD', kdValue, ''}, filename, 'WriteMode', 'append');
        else
            writeSettingToCSV(dataLine, filename);
        end
    end

    % Add column headers for real-time data
    writecell({'time', 'pressure', 'error', 'integral', 'cycle_start'}, filename, 'WriteMode', 'append');
end
