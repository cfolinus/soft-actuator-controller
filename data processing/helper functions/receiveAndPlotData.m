function receiveAndPlotData(s, filename, pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, kiIntegralPlot, kpValue, kiValue, kdValue)
    disp('Receiving real-time data...');
    idx = 1;
    prevError = 0;  % Store the previous error for derivative calculation

    while true
        dataLine = readline(s);

        % Ensure that dataLine is a valid character vector or string
        if ischar(dataLine) || isstring(dataLine)
            % Check if dataLine is empty or contains no commas
            if isempty(dataLine) || ~contains(dataLine, ',')
                continue;  % Skip if data is invalid
            end

            % Split and convert to numbers
            data = str2double(strsplit(dataLine, ','));

            % Ensure the data has the expected number of fields (5)
            if numel(data) == 5
                % Process data, calculate control signal based on Kp, Ki, Kd
                [currentTime, currentPressure, currentError, currentIntegralError, currentCycleStart, currentControlSignal] = processData(data, kpValue, kiValue, kdValue, prevError);

                % Update previous error for the next iteration
                prevError = currentError;

                % Append data to arrays and increment index
                time(idx) = currentTime;
                pressure(idx) = currentPressure;
                error(idx) = currentError;
                integral_error(idx) = currentIntegralError;
                control_signal(idx) = currentControlSignal;  % Ensure control signal is updated
                cycle_start(idx) = currentCycleStart;  % Read cycle_start from serial
                idx = idx + 1;

                % Update plots (including control signal)
                updateLivePlots(pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, kiIntegralPlot, time, pressure, control_signal, error, integral_error, kpValue, kiValue);

                % Write real-time data to the CSV file without the control signal
                dataRow = {currentTime, currentPressure, currentError, currentIntegralError, currentCycleStart};
                writecell(dataRow, filename, 'WriteMode', 'append');
            end
        end

        % Check if the figure window has been closed
        if ~isvalid(pressurePlot.Parent)
            disp('Figure closed. Stopping data acquisition.');
            break;
        end

        % Stop condition for time (optional)
        if currentTime > 600  % Example: Stop after 10 minutes
            disp('Test completed.');
            break;
        end
    end
    disp('Data saved to CSV file.');
end

