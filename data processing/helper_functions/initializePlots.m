function [pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot, kiIntegralPlot] = initializePlots(useKPA)
    pressureUnit = 'PSI';  % Default is PSI
    if useKPA
        pressureUnit = 'kPa';
    end

    % Initialize the plotting figure
    figure('Position', [100, 100, 1200, 800]); % Larger figure
    t = tiledlayout("vertical", 'TileSpacing', 'tight', 'Padding', 'compact');
    title(t, 'Real-Time PID Control Plot', "FontSize", 26, 'FontWeight', 'Bold');
    xlabel(t, 'Time (s)', 'FontSize', 20, 'FontWeight', 'Bold');

    % Create subplots and return their handles
    ax1 = nexttile; hold(ax1, 'on');
    pressurePlot = plot(ax1, NaN, NaN, '-o', 'LineWidth', 2, 'DisplayName', 'Measured Pressure');
    ylabel(ax1, ['Pressure (' pressureUnit ')'], 'FontSize', 16);
    grid(ax1, 'on'); legend(ax1, 'show', 'Location', 'best');

    ax2 = nexttile; controlSignalPlot = plot(ax2, NaN, NaN, 'r-', 'LineWidth', 2, 'DisplayName', 'Control Signal');
    ylabel(ax2, 'Control Signal', 'FontSize', 16);
    grid(ax2, 'on'); legend(ax2, 'show', 'Location', 'best');

    ax3 = nexttile; errorPlot = plot(ax3, NaN, NaN, 'b-', 'LineWidth', 2, 'DisplayName', 'Error');
    ylabel(ax3, 'Error', 'FontSize', 16);
    grid(ax3, 'on'); legend(ax3, 'show', 'Location', 'best');

    ax4 = nexttile; integralPlot = plot(ax4, NaN, NaN, 'g-', 'LineWidth', 2, 'DisplayName', 'Integral Error');
    ylabel(ax4, 'Integral Error', 'FontSize', 16);
    grid(ax4, 'on'); legend(ax4, 'show', 'Location', 'best');

    ax5 = nexttile; hold(ax5, 'on');
    kpErrorPlot = plot(ax5, NaN, NaN, 'm-', 'LineWidth', 2, 'DisplayName', 'Kp * Error');
    kiIntegralPlot = plot(ax5, NaN, NaN, 'c-', 'LineWidth', 2, 'DisplayName', 'Ki * Integral');
    ylabel(ax5, 'PID Components', 'FontSize', 16);
    grid(ax5, 'on'); legend(ax5, 'show', 'Location', 'best');
end
