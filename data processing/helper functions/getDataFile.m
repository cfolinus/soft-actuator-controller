function [data, fileNumber] = getDataFile()
    % Prompt the user to select a file
    [fileName, pathName] = uigetfile('*.csv', 'Select the test data file');
    
    if isequal(fileName, 0)
        data = [];
        fileNumber = [];
        return; % Exit if no file is selected
    end
    
    % Extract file number from the file name
    fileNumber = regexp(fileName, '\d+', 'match'); 
    fileNumber = fileNumber{1}; % Extract first number in the file name

    % Full path to the file
    fullPath = fullfile(pathName, fileName);
    
    % Read the CSV file
    fid = fopen(fullPath, 'r');
    
    % Read lines until you find the header for the data: 
    % 'time,pressure,error,integral,cycle_start'
    line = fgetl(fid);
    dataStartFound = false;
    while ischar(line)
        if contains(line, 'time,pressure,error,integral,cycle_start')
            dataStartFound = true;
            break;
        end
        line = fgetl(fid); % Read the next line
    end
    
    if ~dataStartFound
        error('Data header not found in the file.');
    end
    
    % Read the actual data starting after the header
    data = [];
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            dataLine = sscanf(line, '%f,%f,%f,%f,%d'); % Read the data line
            data = [data; dataLine']; % Append the data to the matrix
        end
    end
    
    fclose(fid); % Close the file
end
