function receiveAndPlotData(s, csvFileName, pressurePlot, ...
    controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, ...
    kiIntegralPlot, kpValue, kiValue, kdValue, useKPA)
    
    disp('Ready to recieve real-time data. Press Start...');
    idx = 1;
    prevError = 0; % Store the previous error for derivative calculation

    % Set the pressure unit based on the USE_KPA flag
    pressureUnit = 'psi';
    if useKPA
        pressureUnit = 'kPa';
    end

    % Initialize timers for tracking data inactivity
    lastDataTime = tic;
    
    % Initialize data arrays
    time = [];
    pressure = [];
    error = [];
    integral_error = [];
    control_signal = [];
    cycle_start = [];

    while true
        % Read data from the serial port
        if s.BytesAvailable > 0
            dataLine = readline(s);
            data = str2double(strsplit(dataLine, ','));

            % Ensure the data has the expected number of fields (5)
            if numel(data) == 5
                % Process the data
                [currentTime, currentPressure, currentError, currentIntegralError, currentCycleStart, currentControlSignal] = processData(data, kpValue, kiValue, kdValue, prevError);

                % Append data to arrays and increment index
                time(idx) = currentTime;
                pressure(idx) = currentPressure;
                error(idx) = currentError;
                integral_error(idx) = currentIntegralError;
                control_signal(idx) = currentControlSignal;
                cycle_start(idx) = currentCycleStart;
                idx = idx + 1;

                % Reset inactivity timer
                lastDataTime = tic;
            end
        end

        % Check for data inactivity (no new data for > 2 seconds)
        if toc(lastDataTime) > 2 && ~isempty(time)
            disp('Writing buffered data to CSV and updating plots...');
            
            % Combine data into a cell array for writing
            combinedData = [time', pressure', error', integral_error', cycle_start'];
            
            % Write data to CSV
            writecell(num2cell(combinedData), csvFileName, 'WriteMode', 'append');

            % Plot all the collected data
            updateLivePlots(pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, kiIntegralPlot, ...
                time, pressure, control_signal, error, integral_error, kpValue, kiValue);

            % Update ylabel of pressure plot dynamically
            ylabel(pressurePlot.Parent, ['Pressure (' pressureUnit ')'], 'FontSize', 16);

            % Clear arrays after writing and plotting
            time = [];
            pressure = [];
            error = [];
            integral_error = [];
            control_signal = [];
            cycle_start = [];
            idx = 1;

            disp(['Data saved to CSV file: ', csvFileName]);

            % Reset inactivity timer
            lastDataTime = tic;
        end

        % Check if the figure window has been closed
        if ~isvalid(pressurePlot.Parent)
            disp('Figure closed. Stopping data acquisition.');
            break;
        end

        % Optional stop condition based on elapsed time
        if ~isempty(time) && time(end) > 600 % Example: Stop after 10 minutes
            disp('Test completed.');
            break;
        end
    end

    % Ensure all remaining data is saved and plotted before exiting
    if ~isempty(time)
        disp('Writing remaining buffered data to CSV and updating plots...');
        combinedData = [time', pressure', error', integral_error', cycle_start'];
        writecell(num2cell(combinedData), csvFileName, 'WriteMode', 'append');
        
        % Plot remaining data
        updateLivePlots(pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, kiIntegralPlot, ...
            time, pressure, control_signal, error, integral_error, kpValue, kiValue);
        
        ylabel(pressurePlot.Parent, ['Pressure (' pressureUnit ')'], 'FontSize', 16);
        disp(['Data saved to CSV file: ', csvFileName]);
    end
end

function [currentTime, currentPressure, currentError, currentIntegralError, currentCycleStart, currentControlSignal] = processData(data, kpValue, kiValue, kdValue, prevError)
    currentTime = data(1) / 1000; % Convert time to seconds
    currentPressure = data(2);
    currentError = data(3);
    currentIntegralError = data(4);
    currentCycleStart = data(5); % Read cycle_start from the serial input

    % Calculate derivative error (change in error over time)
    derivativeError = (currentError - prevError) / currentTime;

    % Calculate control signal based on PID formula
    currentControlSignal = kpValue * currentError + kiValue * currentIntegralError + kdValue * derivativeError;
end
