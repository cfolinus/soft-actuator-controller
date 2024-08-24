#ifndef ANALOG_PRESSURE_SENSOR_H
#define ANALOG_PRESSURE_SENSOR_H

// extern const int SENSOR_PIN;
extern double SensorPressure;

void getSensorPressure(bool USE_KPA);
void displayPressure();
void UpdateFilteredSensorPressure(bool USE_KPA);

#endif
