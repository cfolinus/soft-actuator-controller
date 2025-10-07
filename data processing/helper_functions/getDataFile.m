function [data, fileName, Kp, Ki] = getDataFile()
    % Prompt the user to select a file
    [fileName, pathName] = uigetfile('*.csv', 'Select the test data file');
    
    if isequal(fileName, 0)
        data = [];
        Kp = [];
        Ki = [];
        return; % Exit if no file is selected
    end

    % Full path to the file
    fullPath = fullfile(pathName, fileName);
    
    % Open the file and read its contents
    fid = fopen(fullPath, 'r');
    if fid == -1
        error('Could not open the file.');
    end
    
    % Initialize variables to store KP, KI, and other settings
    Kp = [];
    Ki = [];
    
    % Look for the KP and KI settings in the first few lines of the file
    while ~feof(fid)
        line = fgetl(fid);  % Read one line at a time
        if contains(line, 'KP,')
            % Extract KP value from the line
            Kp = sscanf(line, 'KP,%f');
        elseif contains(line, 'KI,')
            % Extract KI value from the line
            Ki = sscanf(line, 'KI,%f');
        elseif contains(line, 'time,pressure,error,integral,cycle_start')
            % Break the loop once we reach the data section
            break;
        end
    end
    
    % Ensure both KP and KI are extracted
    if isempty(Kp) || isempty(Ki)
        fclose(fid);
        error('KP or KI values not found in the file.');
    end
    
    % Read the actual data starting after the header
    data = [];
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            dataLine = sscanf(line, '%f,%f,%f,%f,%d'); % Read the data line
            if ~isempty(dataLine)
                data = [data; dataLine']; % Append the data to the matrix
            end
        end
    end
    
    fclose(fid); % Close the file
end
