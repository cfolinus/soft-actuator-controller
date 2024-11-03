function [csvFileName, kpValue, kiValue, kdValue, useKPA] = readAndWriteSettings(s)
    % Initialize empty settings
    settings = struct();
    fileName = '';

    disp('Reading settings data...');

    % Loop to read settings from the serial
    while true
        dataLine = readline(s);  % Read line from serial
        dataLine = strtrim(dataLine);  % Remove any whitespace

        % Check if settings section is over
        if strcmp(dataLine, 'Data:')
            disp('Settings data received');
            break;  % Exit the loop to start receiving real-time data
        end

        % Extract and store settings information
        if contains(dataLine, 'filename,')
            fileName = extractAfter(dataLine, 'filename,');
            fileName = strtrim(fileName);
        elseif contains(dataLine, 'Use KPA?,')
            settings.USE_KPA = logical(str2double(extractAfter(dataLine, ',')));  % Convert to boolean
        elseif contains(dataLine, 'KP,')
            settings.KP = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'KI,')
            settings.KI = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'KD,')
            settings.KD = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'Traj Follow Error Threshold,')
            settings.THRESHOLD = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'Filter alpha,')
            settings.FILTER_ALPHA = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'Sensor offset,')
            settings.SENSOR_OFFSET = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'Pressure Read Delay,')
            settings.PRESSURE_READ_DELAY = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'Interpolation Calculation Delay,')
            settings.INTERP_CALC_DELAY = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'Controller Delay,')
            settings.CONTROLLER_DELAY = str2double(extractAfter(dataLine, ','));
        elseif contains(dataLine, 'Traj times,')
            trajTimesStr = extractAfter(dataLine, ',');
            settings.TrajTimes = str2double(strsplit(trajTimesStr, ','));
        elseif contains(dataLine, 'Traj pressures,')
            trajPressuresStr = extractAfter(dataLine, ',');
            settings.TrajPressures = str2double(strsplit(trajPressuresStr, ','));
        end
    end

    % Ensure we received a valid fileName
    if isempty(fileName)
        error('File name not received from microcontroller.');
    end

    % Assign Kp, Ki, Kd, and Use KPA values to return variables
    kpValue = settings.KP;
    kiValue = settings.KI;
    kdValue = settings.KD;
    useKPA = settings.USE_KPA;

    % Create the CSV filename with the lowest available integer value
    csvFileName = createUniqueFileName(fileName);

    % Write settings data to the CSV
    disp(['Creating CSV file: ', csvFileName]);
    writecell({'Settings:', '', ''}, csvFileName, 'WriteMode', 'overwrite');
    writecell({'Use KPA', settings.USE_KPA, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'KP', settings.KP, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'KI', settings.KI, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'KD', settings.KD, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'Traj Follow Error Threshold', settings.THRESHOLD, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'Filter alpha', settings.FILTER_ALPHA, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'Sensor offset', settings.SENSOR_OFFSET, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'Pressure Read Delay', settings.PRESSURE_READ_DELAY, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'Interpolation Calculation Delay', settings.INTERP_CALC_DELAY, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'Controller Delay', settings.CONTROLLER_DELAY, ''}, csvFileName, 'WriteMode', 'append');
    writecell({'Traj times', sprintf('%.2f, ', settings.TrajTimes), ''}, csvFileName, 'WriteMode', 'append');
    writecell({'Traj pressures', sprintf('%.2f, ', settings.TrajPressures), ''}, csvFileName, 'WriteMode', 'append');
    writecell({'time', 'pressure', 'error', 'integral', 'cycle_start'}, csvFileName, 'WriteMode', 'append');
end

% Helper function to create a unique CSV filename
function csvFileName = createUniqueFileName(baseFileName)
    % Initialize counter
    fileNumber = 1;
    
    % Check if files with the naming pattern exist
    while true
        csvFileName = sprintf('%s_MATLAB_%d.csv', baseFileName, fileNumber);
        
        if ~isfile(csvFileName)  % If file doesn't exist, use this name
            break;
        end
        
        % Increment the counter to try the next number
        fileNumber = fileNumber + 1;
    end
end
