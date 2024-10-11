% Initialize serial communication and clear workspace
close all; clear; clc;

% Adjust if necessary
addpath(genpath('helper functions'));

% Initialize Serial Communication
s = initializeSerial("/dev/tty.usbserial-AQ01KRCM", 115200);

% Prompt user for filename
filename = initializeFile();

% Read and write settings data to CSV, return Kp, Ki, Kd
[kpValue, kiValue, kdValue] = readAndWriteSettings(s, filename);

% Initialize plot for real-time data
[pressurePlot, controlSignalPlot, errorPlot, integralPlot, kpErrorPlot,...
     kiIntegralPlot] = initializePlots();

% Start receiving and plotting real-time data
receiveAndPlotData(s, filename, pressurePlot, controlSignalPlot, ...
    errorPlot,integralPlot, kpErrorPlot, kiIntegralPlot, ...
    kpValue, kiValue, kdValue);
