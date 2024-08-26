function [trajTimes, trajPressures] = getTrajectory(trajSelect)
    % Define trajectories
    stepTimes = [0, 100, 2000, 2100, 3000] / 1000; % Convert from millisec to sec
    stepPressures = [0, 15, 15, 0, 0];

    triTimes = [0, 1500, 3000] / 1000;
    triPressures = [0, 20, 0]; 

    sawTimes = [0, 3000, 3100] / 1000;
    sawPressures = [0, 15, 0];

    revSawTimes = [0, 100, 3100] / 1000;
    revSawPressures = [0, 15, 0];

    sinTimes = [0, 1.111, 2.222, 3.333, 4.444, 5.555, 6.666, 7.777, 8.888, 10];
    sinPressures = 15 * [0, sin(pi/9), sin(pi/9*2), sin(pi/9*3), sin(pi/9*4), sin(pi/9*5), sin(pi/9*6), sin(pi/9*7), sin(pi/9*8), sin(pi)];

    burstTimes = [0, 5000, 10000, 15000, 20000, 25000, 30000, 35000,...
        40000, 45000, 50000, 55000, 60000, 65000, ...
        70000, 75000, 80000, 80100, 80500] / 1000; % Convert from millisec to sec
    burstPressures = [0, 5, 5, 10, 10, 15, 15, 20, 20,...
        25, 25, 30, 30, 35, 35, 40, 40, 0, 0]; % PSI

    % Select trajectory
    switch trajSelect
        case 1 % for step
            trajTimes = stepTimes;
            trajPressures = stepPressures;
        case 2 % for triangle
            trajTimes = triTimes;
            trajPressures = triPressures;
        case 3 % for sawtooth
            trajTimes = sawTimes;
            trajPressures = sawPressures;
        case 4 % for rev. sawtooth
            trajTimes = revSawTimes;
            trajPressures = revSawPressures;
        case 5 % for sin
            trajTimes = sinTimes;
            trajPressures = sinPressures;
        case 6 % for burst
            trajTimes = burstTimes;
            trajPressures = burstPressures;
        otherwise
            error('Invalid trajectory selection');
    end
end
