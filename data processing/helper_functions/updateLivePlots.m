function updateLivePlots(pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, kiIntegralPlot, time, pressure, control_signal, error, integral_error, kpValue, kiValue)
    % Update pressure plot
    set(pressurePlot, 'XData', time, 'YData', pressure);

    % Update control signal plot
    set(controlSignalPlot, 'XData', time, 'YData', control_signal);

    % Update error plot
    set(errorPlot, 'XData', time, 'YData', error);

    % Update integral error plot
    set(integralPlot, 'XData', time, 'YData', integral_error);

    % Update Kp*error plot
    set(kpErrorPlot, 'XData', time, 'YData', kpValue * error);

    % Update Ki*integral error plot
    set(kiIntegralPlot, 'XData', time, 'YData', kiValue * integral_error);

    % Refresh the plots
    drawnow;
end
