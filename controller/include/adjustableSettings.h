#ifndef SETTINGS_H
#define SETTINGS_H

// Pin definitions
extern const int START_BUTTON_PIN; 
extern const int STOP_BUTTON_PIN;
extern const int SENSOR_PIN;
extern const int PRESSURE_PIN;
extern const int VENT_PIN;

// Tuning variables
extern const bool TUNE_PRESSURE;
extern const bool TUNE_VENT;

// Pnuematic valve analog write values
extern const int ANALOG_PRESSURE_MIN;
extern const int ANALOG_PRESSURE_MAX;
extern const int ANALOG_VENT_MIN;
extern const int ANALOG_VENT_MAX;

// Pressure sensor variables
extern const bool USE_KPA;
extern const double FILTER_ALPHA;
extern const int OVERPRESSURE_LIMIT;

// Frequency variables
extern const double PRESSURE_READ_DELAY;
extern const int INTERP_CALC_DELAY;
extern const int CONTROLLER_DELAY; 

// PID Controller variables
extern const double THRESHOLD;
extern const int OUTPUT_MIN;
extern const int OUTPUT_MAX;
extern const double KP;
extern const double KI;
extern const double KD;

// Trajectory variables
extern const float TIMES[]; //milliseconds
extern const double PRESSURES[]; // PSI
extern const int TRAJ_SIZE;

#endif