#include <Arduino.h>
#include "analogPressureSensor.h"
#include "adjustableSettings.h"

// Define the sensor pin
double SensorPressure;
double previousPressure;

void getSensorPressure(bool USE_KPA) {
  int SensorReading = analogRead(SENSOR_PIN);
  // Conversion equation between pressure sensor's output range in analog values
  // to volts (min 0.5V, max 4.5V, range of 4.0V), and then from volts to PSI.
  // P = ((5V * SensorReading) / (MaxAnalogSignalValue) - 0.5V) * 150PSI/4V
  SensorPressure = (5.0 * SensorReading / 1023.0 - 0.5) * 37.5; // Analog to PSI
  if (USE_KPA) { // Convert to KPA if needed
    SensorPressure *= 6.89476; // PSI to KPA
  }
}

void UpdateFilteredSensorPressure(bool USE_KPA) {
  // simple estimated moving average filter to reduce signal noise
  previousPressure = SensorPressure;
  getSensorPressure(USE_KPA);
  SensorPressure = (1.0 - FILTER_ALPHA) * SensorPressure + FILTER_ALPHA  * previousPressure;
}

void displayPressure() {
  // You can replace this with any LCD or other display code if needed
}
