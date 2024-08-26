function [data, fileNumber] = getDataFile()
    % Prompt user to select a file
    [filename, pathname] = uigetfile('*.csv', 'Select a CSV file');

    if isequal(filename, 0)
        disp('User selected Cancel');
        data = [];
        fileNumber = [];
        return;
    else
        % Construct full filename
        fullFilename = fullfile(pathname, filename);
        disp(['User selected ', fullFilename]);
    end

    % Read file
    data = readmatrix(fullFilename);

    % Extract the number from the filename as a string
    pattern = 'cycle_test_(\d+)\.csv';
    tokens = regexp(filename, pattern, 'tokens');
    fileNumber = tokens{1}{1};
end
