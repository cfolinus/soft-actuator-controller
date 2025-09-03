#include <Arduino.h>
#include "adjustableSettings.h"

// ========== Pin Definitions ==========
/* Pins pins used to connect various components to the microcontroller.
   Adjust to your specific hardware set-up. Ensure PRESSURE_PIN and VENT_PIN are connected
   to PWM-capable pinouts on your microcontroller*/

const int START_BUTTON_PIN = A3; 
const int STOP_BUTTON_PIN = A2;
const int SENSOR_PIN = A7;
const int PRESSURE_PIN = 6;
const int VENT_PIN = 5;

// ========== Pneumatic Valve Settings ==========
/* Control the pressure applied by the pneumatic valves.
   Adjust the min and max analog PWM write values to calibrate the pressure range. */

const int ANALOG_PRESSURE_MIN = 146;
const int ANALOG_PRESSURE_MAX = 170;
const int ANALOG_VENT_MIN = 156;
const int ANALOG_VENT_MAX = 180;

// ========== Filename Settings ==========
/* String for name of file series. Controller will automatically generate csv
   file with lowest available integer appended to the end, so as to not overwrite 
   existing data files on the SD card */

const char fileName[] = "250828_setup";

// ========== Tuning Modes ==========
/* Toggles for the initial tuning processes for the pressure and vent solenoid valves,
   and the default operation of the controller. Set 'TUNE_PRESSURE' to 'true' to enable tuning mode 
   for the pressure valve, and 'TUNE_VENT' to 'true' to enable tuning mode for the vent valve. 
   Set both to 'false' for normal PID controller operation. */

const bool TUNE_PRESSURE = false;
const bool TUNE_VENT = false;

// ========== Pressure Sensor Settings ==========
/* Settings related to pressure sensor calibration and data logging.
   Adjust the filter alpha value and maximum pressure according to your sensor's specifications.
   Toggle where you want to use kPa (true) or PSI (false) depending on your application/preference */

const bool USE_SD_CARD = false;
const bool USE_KPA = false; 
const double FILTER_ALPHA = 0.0;
const int OVERPRESSURE_LIMIT = 25; // units depend on value of USE_KPA
const double SENSOR_OFFSET = 0.11; // Offset used to calibrate a specific sensor

// ========== Frequency Settings ==========
/* Specifiy delay between different tasks are executed. Adjusting these 
values lets you control the time delay, in milliseconds, between each occurrence 
of the corresponding action in the system. */

const double PRESSURE_READ_DELAY = 30; // milliseconds
const int INTERP_CALC_DELAY = 30;      // milliseconds
const int CONTROLLER_DELAY = 30;       // milliseconds 

// ========== PID Controller Settings ==========
/* These settings configure the PID controller that regulates pressure.
   Fine-tune the proportional (KP), integral (KI), and derivative (KD) 
   constants for optimal performance. */

const double THRESHOLD = 3;
const int OUTPUT_MIN = -1.0; // DO NOT CHANGE
const int OUTPUT_MAX = 1.0; // DO NOT CHANGE
const double KP = 0.1;	  // Start with Kp = 0.1, Ki = 0.0, Kd = 0.0 for Zeigler-Nichols tuning
const double KI = 0.000001;
const double KD = 0.0;

// ========== Trajectory Settings ==========
/* Definition for the pressure trajectory over time.
   Choose one trajectory type and ensure the first and last pressures match for smooth cycling.
   Ensure that the size of the TIMES and PRESSURES arrays match.
   
   Example Trajectories:
   - Step function
   - Triangle
   - Sawtooth
   - Reverse Sawtooth
   - Sinusoidal
   - Burst Ramp
   - Linear Ramp
*/

// Step Function Trajectory
const float TIMES[] = {0, 100, 2000, 2100, 4000}; // milliseconds
const double PRESSURES[] = {0, 20, 20, 0, 0};    // PSI or Kpa

// Uncomment to use a different trajectory:

// Triangle Trajectory
// const float TIMES[] = {0, 1500, 1600, 3000, 3500}; // milliseconds
// const double PRESSURES[] = {0, 20, 20, 0, 0}; // PSI or Kpa

//Sawtooth Trajectory
// const float TIMES[] = {0, 3000, 3100, 3200, 3500}; // milliseconds
// const double PRESSURES[] = {0, 20, 20, 0, 0};    // PSI or Kpa

// Reverse Sawtooth Trajectory
// const float TIMES[] = {0, 100, 200, 3100, 3500}; // milliseconds
// const double PRESSURES[] = {0, 20, 20, 0, 0};   // PSI or Kpa

// Sinusoidal Trajectory
// const int amp = 20; // adjust amplitude of sinusoidal wave
// const float TIMES[] = {0, 1111, 2222, 3333, 4444, 5555, 6666, 7777, 8888, 10000, 10500}; // milliseconds
// const double PRESSURES[] = {
//     0, 
//     amp * sin(M_PI / 9 * 1), 
//     amp * sin(M_PI / 9 * 2), 
//     amp * sin(M_PI / 9 * 3), 
//     amp * sin(M_PI / 9 * 4), 
//     amp * sin(M_PI / 9 * 5), 
//     amp * sin(M_PI / 9 * 6), 
//     amp * sin(M_PI / 9 * 7), 
//     amp * sin(M_PI / 9 * 8), 
//     0,
//     0
// }; // PSI or Kpa

// Burst Ramp Trajectory
// const float TIMES[] = {0, 5000, 10000, 15000, 20000, 
//                         25000, 30000, 35000, 40000, 45000, 
//                         50000, 55000, 60000, 65000, 70000, 
//                         75000, 80000, 80100, 80500}; // milliseconds
// const double PRESSURES[] = {0, 5, 5, 10, 10, 
//                             15, 15, 20, 20, 25, 
//                             25, 30, 30, 35, 35, 
//                             40, 40, 0, 0}; // PSI or Kpa

// Linear Ramp Trajectory
// const float TIMES[] = {0, 180000, 180100}; // milliseconds
// const double PRESSURES[] = {0, 20, 0};     // PSI or Kpa


// ========== Unadjustable Variables ==========
/* DO NOT CHANGE
   These variables are based upon the adjustable settings above, and are
   set automatically so as to make the front-end user expierence simpler */
const int TRAJ_SIZE = sizeof(TIMES) / sizeof(TIMES[0]);



