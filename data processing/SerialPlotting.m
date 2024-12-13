% Initialize serial communication and clear workspace
close all; clear; clc;

% Adjust if necessary
addpath(genpath('helper functions'));

% Initialize Serial Communication
% Change to match the serial port on your comptuer
s = initializeSerial("/dev/cu.usbserial-A10LT2ZA", 115200);

% Call the function to read settings, create the CSV file, and get PID values
[csvFileName, kpValue, kiValue, kdValue, useKPA] = readAndWriteSettings(s);

% Initialize plot for real-time data
[pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot,...
     kiIntegralPlot] = initializePlots(useKPA);

% Start receiving and plotting real-time data
receiveAndPlotData(s, csvFileName, pressurePlot, controlSignalPlot, ...
    errorPlot, integralPlot, kpErrorPlot, kiIntegralPlot, ...
    kpValue, kiValue, kdValue, useKPA);


