function s = initializeSerial(port, baudRate)
    s = serialport(port, baudRate);
    configureTerminator(s, "LF");
end
