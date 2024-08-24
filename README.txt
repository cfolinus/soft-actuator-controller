The Trajectory Cycle program serves as a means of running a cyclic actuator inflation test. 
This program is designed for the arduino nano platform and is intended to be used with a
2/2 NC solenoid valves arranged in a fill/bleed circuit. The program is designed to be used with any soft pneumatic actuator, and requires tuning of PID gain values for different actuators. Zeigler-Nichols method is a recommended starting point.

The codebase will not be able to properly upload to the controller unless it is correctly formatted for your computer. Be sure to follow the PlatformIO and codebase installation instructions found in the "Install, Tune, & Run the Controller" How-to guide.

In the codebase, the main control loop can be found in main.cpp, but all variables relevant to the adjustment of the controller can be found in adjustableSettings.cpp. For details on how the controller works, what purpose it serves, what all relevant variables do, and how to tune the controller, please refer to the Powerpoint presentation and word documents included in this directory.

--Evan Comiskey, 2024/08, MIT Fabrication-Integrated Design Lab, comiskey@mit.edu
