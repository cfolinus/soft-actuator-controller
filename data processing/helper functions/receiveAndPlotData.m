function receiveAndPlotData(s, csvFileName, pressurePlot, ...
    controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, ...
    kiIntegralPlot, kpValue, kiValue, kdValue, useKPA)
    disp('Receiving real-time data...');
    idx = 1;
    prevError = 0;  % Store the previous error for derivative calculation

    % Set the pressure unit based on the USE_KPA flag
    pressureUnit = 'PSI';  % Default is PSI
    if useKPA
        pressureUnit = 'kPa';
    end

    while true
        dataLine = readline(s);
        data = str2double(strsplit(dataLine, ','));

        % Ensure the data has the expected number of fields (5)
        if numel(data) == 5
            [currentTime, currentPressure, currentError, currentIntegralError, currentCycleStart, currentControlSignal] = processData(data, kpValue, kiValue, kdValue, prevError);

            % Append data to arrays and increment index
            time(idx) = currentTime;
            pressure(idx) = currentPressure;
            error(idx) = currentError;
            integral_error(idx) = currentIntegralError;
            control_signal(idx) = currentControlSignal;
            cycle_start(idx) = currentCycleStart;
            idx = idx + 1;

            % Update plots
            updateLivePlots(pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, kiIntegralPlot, time, pressure, control_signal, error, integral_error, kpValue, kiValue);

            % Update ylabel of pressure plot dynamically
            ylabel(pressurePlot.Parent, ['Pressure (' pressureUnit ')'], 'FontSize', 16);

            % Write real-time data to the CSV file without the control signal
            dataRow = {currentTime, currentPressure, currentError, currentIntegralError, currentCycleStart};
            writecell(dataRow, csvFileName, 'WriteMode', 'append');
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
    disp(['Data saved to CSV file: ', csvFileName]);
end

% Example processData function
function [currentTime, currentPressure, currentError, currentIntegralError, currentCycleStart, currentControlSignal] = processData(data, kpValue, kiValue, kdValue, prevError)
    currentTime = data(1) / 1000;  % Convert time to seconds
    currentPressure = data(2);
    currentError = data(3);
    currentIntegralError = data(4);
    currentCycleStart = data(5);  % Read cycle_start from the serial input
    
    % Calculate derivative error (change in error over time)
    derivativeError = (currentError - prevError) / currentTime;
    
    % Calculate control signal based on PID formula
    currentControlSignal = kpValue * currentError + kiValue * currentIntegralError + kdValue * derivativeError;
end
