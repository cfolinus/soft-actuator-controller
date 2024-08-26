function plotCycles(cycles, trajTimes, trajPressures, fileNumber, isFirst)
    hold on;
    % Get a different colormap for each file
    colors = lines(length(cycles)); % Change 'lines' to a different colormap if desired
    for i = 1:length(cycles)
        plot(cycles{i}.time, cycles{i}.pressure, '-', 'Color', colors(i, :));
    end
    p = plot(trajTimes, trajPressures, 'k--', 'LineWidth', 3); % Plot the ideal trajectory on each tile

    if isFirst
        ylabel('Pressure (PSI)', 'FontSize', 14, 'FontWeight', 'Bold');
        legend(p, 'Ideal Trajectory', 'FontSize', 12, 'Location', 'best');
    end

    title(sprintf('Cycle Test %s', fileNumber), 'FontSize', 18, 'FontWeight', 'Bold');
    grid on;
end
