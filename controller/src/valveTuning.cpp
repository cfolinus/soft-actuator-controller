#include <Arduino.h>
#include "valveTuning.h"
#include "adjustableSettings.h"
#include "analogPressureSensor.h"
#include "valveControl.h"

void tuneValve(int pin) {
  // if we are tuning the vent valve, pressurise the system
  // so that users can observe the vent valve's behavior
  // during deflation process
  if (pin == VENT_PIN) {
    closeVentValve();
    openPressureValve();
    delay(100);
  }
  for (int pwmValue = 0; pwmValue <= 255; pwmValue++) {
    // end test early if stop button is pressed
    if (digitalRead(STOP_BUTTON_PIN) == LOW){
      break;
    }
    // open the valve to the current pwm value
    analogWrite(pin, pwmValue);
    Serial.print("PWM Value: ");
    Serial.println(pwmValue);
    // read the corresponding pressure sensor value
    getSensorPressure(USE_KPA);
    Serial.print("Pressure: ");
    Serial.print(SensorPressure);
    Serial.println(" PSI");
    // hold for one second to observe the valve behavior
    delay(1000); 
  }
  analogWrite(pin, 0); // Close the valve after testing
}
