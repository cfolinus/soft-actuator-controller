function [currentTime, currentPressure, currentError, currentIntegralError, currentCycleStart, currentControlSignal] = processData(data, kpValue, kiValue, kdValue, prevError)
    currentTime = data(1) / 1000;  % Convert time to seconds
    currentPressure = data(2);
    currentError = data(3);
    currentIntegralError = data(4);
    currentCycleStart = data(5);  % Read cycle_start from the serial input
    
    % Calculate derivative error (change in error over time)
    % Assuming equal time steps for simplicity
    derivativeError = (currentError - prevError);  

    % Calculate control signal using PID formula
    currentControlSignal = kpValue * currentError + kiValue * currentIntegralError + kdValue * derivativeError;
end
