function filteredPressure = applyFilter(pressure, filterOrder, cutoffFrequency)
    % Apply digital low-pass filter to the pressure data
    [b, a] = butter(filterOrder, cutoffFrequency, 'low');
    filteredPressure = filtfilt(b, a, pressure);
end
