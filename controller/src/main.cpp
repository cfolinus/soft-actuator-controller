// Library Inclusions
#include <Arduino.h>
#include <Wire.h>
#include <AutoPID.h>

// Custom Inclusions
#include "adjustableSettings.h"
#include "sdCardOperations.h"
#include "analogPressureSensor.h"
#include "valveControl.h"
#include "lcdDisplay.h"
#include "trajectory.h"
#include "valveTuning.h"

// Declare dynamic variables
float lastPressureUpdate; // milliseconds
float lastInterpUpdate; // milliseconds
float cycleStartTime; // milliseconds
float trajStartTime; // milliseconds
int totalCycles = 0;
unsigned long deltaT;
bool cycleComplete = false;
double desiredPressure; // PSI
double output;

// Initialize controller and trajectory objects
AutoPID valvePID(&SensorPressure, &desiredPressure, &output, OUTPUT_MIN, OUTPUT_MAX, KP, KI, KD);
Trajectory traj(TRAJ_SIZE);

// helper function to display test end condition, # of cycles and exit
void endTest(String reason, int cycles){
  closePressureValve();
  vent();
  valvePID.stop();
  closeSD();
  setLCD(reason, "Cycles: " + String(totalCycles));
  exit(0);
}

void setup() {
  // Initialize Serial w/ Baud Rate 115200
  Serial.begin(115200);
  // Initialize LCD
  lcd.begin(16, 2);
  lcd.clear();
  // Initialize valves and pressure sensor
  pinMode(PRESSURE_PIN, OUTPUT);
  pinMode(VENT_PIN, OUTPUT);
  pinMode(SENSOR_PIN, INPUT);
  analogReference(DEFAULT);
  pinMode(START_BUTTON_PIN, INPUT_PULLUP);
  pinMode(STOP_BUTTON_PIN, INPUT_PULLUP);

  // vent any air in the system
  closeValves();
  delay(20); // 20 millisecond delay between signal and mechanical valve response
  openVentValve();
  setLCD(F("Venting..."), F("Please wait"));
  delay(5000); // hold for 5 seconds to fully vent
  closeValves(); 

  if(TUNE_PRESSURE || TUNE_VENT){ // Solenoind Valve Tuning Mode    
    // Ensure only one valve is set for tuning
    if (TUNE_PRESSURE && TUNE_VENT) {
      setLCD(F("Error"), F("Only 1 Valve"));
      exit(0);
    }
    setLCD(F("Tuning Mode"), F("Press Start"));
    while(digitalRead(START_BUTTON_PIN) == HIGH){
      // wait for start button press
    }
    delay(2000);
    // begin tuning process
    setLCD(F("Starting Tuning..."), F("Please wait"));
  }
  else{ // Normal operation
    // Initialize SD card
    if (!initializeSDCard()) {
      while (1);
    }
    delay(100);

    // Initialize trajectory
    if(!InitializeTrajectory(&traj, TIMES, PRESSURES, TRAJ_SIZE)){
      setLCD(F("Traj Error"), F("Check Serial"));
      while(1);
    }

    // Set PID Controller settings
    valvePID.setTimeStep(CONTROLLER_DELAY); //milliseconds.
    // Tells AutoPID to NOT use bang-bang control
    valvePID.setBangBang(0, 0);

    // hold until start button pressed.
    setLCD(F("Press Start"), F("to Begin Test"));
    while(digitalRead(START_BUTTON_PIN) == HIGH){
      // wait for start button press
    }
    delay(2000);
    // begin cycle test
    setLCD(String(fileName), "Cycles: " + String(totalCycles));
    testStartTime = millis();
    trajStartTime = millis();
    traj.reset();
  }
}

void loop() {
  // Get current time
  unsigned long currentMillis = millis();
  // Stop operations if stop button is pressed
  if (digitalRead(STOP_BUTTON_PIN) == LOW){
    endTest(F("Stop Pressed"), totalCycles);
  }

  // Pressure valve tuning
  if (TUNE_PRESSURE) { 
    tuneValve(PRESSURE_PIN);
    setLCD(F("Pressure Valve"), F("Tuning Complete"));
    exit(0);
  }
  // Vent valve tuning
  else if (TUNE_VENT) { 
    tuneValve(VENT_PIN);
    setLCD(F("Pressure Valve"), F("Tuning Complete"));
    exit(0);
  }
  // Normal operation
  else { 
    // Check that pressure does not exceed maximum
    if (SensorPressure > OVERPRESSURE_LIMIT) {
      vent();
      endTest(F("Overpressure"), totalCycles);
    }
    // Check that controller isn't failing to follow the trajectory
    if (traj.failingToFollow(SensorPressure, deltaT, THRESHOLD)) {
      endTest(F("Traj Follow Fail"), totalCycles);
    }
    // Check if cycle is complete
    if (cycleComplete) {
      totalCycles++;
      setLCD(String(fileName), "Cycles: " + String(totalCycles));
      valvePID.reset();  // anti-windup call
      traj.reset();
      logData(SensorPressure, valvePID.getPreviousError(), valvePID.getIntegral(), cycleComplete, currentMillis);
      trajStartTime = millis();
      syncData();
      cycleComplete = false;
    }
    // Log data at (1/PRESSURE_READ_DELAY) Hz
    if ((currentMillis - lastPressureUpdate) > PRESSURE_READ_DELAY) {
      UpdateFilteredSensorPressure(USE_KPA);
      logData(SensorPressure, valvePID.getPreviousError(), valvePID.getIntegral(), cycleComplete, currentMillis);
      lastPressureUpdate = currentMillis;  // Reset pressure update timer
    }
    // Interpolate setpoint at (1/INTERP_CALC_DELAY) Hz
    if ((currentMillis - lastInterpUpdate) > INTERP_CALC_DELAY) {
      // Calculate time since start of trajectory cycle
      deltaT = currentMillis - trajStartTime; // COULD FUCK UP THE ENTIRE PROGRAM
      // Check if trajectory is finished
      if (traj.isFinished(deltaT)) {
        desiredPressure = PRESSURES[TRAJ_SIZE - 1];
        cycleComplete = true;
      } else {
        // If not, interpolate current setpoint
        desiredPressure = traj.interp(deltaT);
      }
      // Reset interpolation timer
      lastInterpUpdate = currentMillis;
    }
    // Run the PID control action
    valvePID.run();
    sendSignalToValves(output);
  }
}




