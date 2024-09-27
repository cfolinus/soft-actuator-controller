#include <Arduino.h>
#include "adjustableSettings.h"

// ========== Pin Definitions ==========
/* These settings define the pins used to connect various components the microcontroller.
   Adjust to your specific hardware set-up. Ensure PRESSURE_PIN and VENT_PIN are connected
   to PWM-capable pinouts on your microcontroller*/

const int START_BUTTON_PIN = A3; 
const int STOP_BUTTON_PIN = A4;
const int SENSOR_PIN = A7;
const int PRESSURE_PIN = 6;
const int VENT_PIN = 5;

// ========== LCD Pin Definitions ==========
/* These settings define the pins used to send data to the I2C LCD display.
   Adjust the values to your specific hardware set-up.*/

const int LCD_RS = 10;   // Register Select
const int LCD_E = 9;    // Enable
const int LCD_D4 = 8;    // Data Pin 4
const int LCD_D5 = 7;    // Data Pin 5
const int LCD_D6 = 3;    // Data Pin 6
const int LCD_D7 = 2;    // Data Pin 7

// ========== Pneumatic Valve Settings ==========
/* These settings control the pressure applied by the pneumatic valves.
   Adjust the min and max analog write values to calibrate the pressure range. */

const int ANALOG_PRESSURE_MIN = 146;
const int ANALOG_PRESSURE_MAX = 170;
const int ANALOG_VENT_MIN = 156;
const int ANALOG_VENT_MAX = 180;

// ========== Tuning Mode ==========
/* These settings toggle between the initial tuning process for the pressure and vent solenoid valves,
   and the default operation of the controller. Set 'TUNE_PRESSURE' to 'true' to enable tuning mode 
   for the pressure valve, and 'TUNE_VENT' to 'true' to enable tuning mode for the vent valve. 
   Set both to 'false' for normal operation. */

const bool TUNE_PRESSURE = false;
const bool TUNE_VENT = false;

// ========== Pressure Sensor Settings ==========
/* These settings are related to the pressure sensor.
   Adjust the filter alpha value and maximum pressure according to your sensor's specifications.
   Toggle where you want to use kPa (true) or PSI (false) depending on your application/preference */

const bool USE_KPA = false; 
const double FILTER_ALPHA = 0.0;
const int OVERPRESSURE_LIMIT = 35;
const double SENSOR_OFFSET = 0.08; // Offset to calibrate sensor

// ========== Frequency Settings ==========
/* These settings determine the frequency at which various tasks are performed.
   You can adjust the delay values to control the frequency in milliseconds. */

const double PRESSURE_READ_DELAY = 10; // milliseconds (100Hz)
const int INTERP_CALC_DELAY = 50;      // milliseconds (20Hz)
const int CONTROLLER_DELAY = 50;       // milliseconds (20Hz)

// ========== PID Controller Settings ==========
/* These settings configure the PID controller that regulates pressure.
   Fine-tune the proportional (KP), integral (KI), and derivative (KD) 
   constants for optimal performance. */

const double THRESHOLD = 10;
const int OUTPUT_MIN = -1.0; // DO NOT CHANGE
const int OUTPUT_MAX = 1.0; // DO NOT CHANGE
const double KP = 0.4;    // Start with Kp = 0.1, Ki = 0.0, Kd = 0.0 for Zeigler-Nichols tuning
const double KI = 0.00115;
const double KD = 0.0;

// ========== Trajectory Settings ==========
/* These settings define the pressure trajectory over time.
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
const float TIMES[] = {0, 100, 2000, 2100, 3000}; // milliseconds
const double PRESSURES[] = {0, 15, 15, 0, 0};    // PSI or Kpa

// Uncomment to use a different trajectory:

// Triangle Trajectory
// const float TIMES[] = {0, 1500, 3000}; // milliseconds
// const double PRESSURES[] = {0, 20, 0}; // PSI or Kpa

//Sawtooth Trajectory
// const float TIMES[] = {0, 3000, 3100, 3500}; // milliseconds
// const double PRESSURES[] = {0, 15, 0, 0};    // PSI or Kpa

// Reverse Sawtooth Trajectory
// const float TIMES[] = {0, 100, 3100, 3500}; // milliseconds
// const double PRESSURES[] = {0, 15, 0, 0};   // PSI or Kpa

// Sinusoidal Trajectory
// const float TIMES[] = {0, 1111, 2222, 3333, 4444, 5555, 6666, 7777, 8888, 10000}; // milliseconds
// const double PRESSURES[] = {
//     0, 
//     20 * sin(M_PI / 9 * 1), 
//     20 * sin(M_PI / 9 * 2), 
//     20 * sin(M_PI / 9 * 3), 
//     20 * sin(M_PI / 9 * 4), 
//     20 * sin(M_PI / 9 * 5), 
//     20 * sin(M_PI / 9 * 6), 
//     20 * sin(M_PI / 9 * 7), 
//     20 * sin(M_PI / 9 * 8), 
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



