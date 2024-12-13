#include <Arduino.h>
#include <SdFat.h>
#include <SPI.h>
#include <AutoPID.h>
#include "sdCardOperations.h"
#include "lcdDisplay.h"
#include "analogPressureSensor.h"
#include "adjustableSettings.h"

// SD card variables
SdFat SD;
SdFile dataFile;
const int SD_CS_PIN = 10;
unsigned long testStartTime;
char specificFileName[50];

// Function to initialize the SD card
bool initializeSDCard() {
  setLCD(F("SD init..."), F("Please wait"));

  // Initialize SD card pins
  pinMode(12, INPUT); // MISO
  pinMode(11, OUTPUT); // MOSI
  pinMode(13, OUTPUT); // SCK
  pinMode(SD_CS_PIN, OUTPUT); // CS

  if (!SD.begin(SD_CS_PIN, SD_SCK_MHZ(8))) {
    setLCD(F("SD Init"), F("Failed"));
    return false;
  }
  setLCD(F("SD Initialized"), F("Prepping File..."));

  // Create a new file for each new cycle test
  int fileIndex = getNextFileIndex();
  snprintf(specificFileName, sizeof(specificFileName), "%s_%d.csv", fileName, fileIndex);  // Store specific file name
  Serial.print(F("Creating file: "));
  Serial.println(specificFileName);

  if (!createFile(specificFileName)) {
    setLCD(F("File create fail"), F("Check SD Card"));
    return false;
  }

  if (!openFile(specificFileName)) {
    setLCD(F("File open fail"), F("Check SD Card"));
    return false;
  }

  Serial.println(F("SD card setup complete."));
  delay(2000);  // delay for readability
  return true;
}


// helper function to get the next file index
int getNextFileIndex() {
  int index = 0;

  size_t bufferSize = strlen(fileName) + 10; 
  char tempFileName[bufferSize]; 
  
  while (true) {
    snprintf(tempFileName, bufferSize, "%s_%d.csv", fileName, index);  
    if (!SD.exists(tempFileName)) {
      return index;
    }
    index++;
  }
}

// Function for writing data to files if USE_SD_CARD is true
bool createFile(const char* fileName) {
  if (dataFile.open(fileName, O_RDWR | O_CREAT | O_AT_END)) {
    dataFile.println(F("Settings:"));
    dataFile.print(F("filename,")); dataFile.println(fileName);  // Log the full filename
    dataFile.print(F("Use KPA?,")); dataFile.println(USE_KPA);
    dataFile.print(F("KP,")); dataFile.println(KP, 5);
    dataFile.print(F("KI,")); dataFile.println(KI, 5);
    dataFile.print(F("KD,")); dataFile.println(KD, 5);
    dataFile.print(F("Traj Follow Error Threshold,")); dataFile.println(THRESHOLD);
    dataFile.print(F("Filter alpha,")); dataFile.println(FILTER_ALPHA, 5);
    dataFile.print(F("Sensor offset,")); dataFile.println(SENSOR_OFFSET, 5);
    dataFile.print(F("Pressure Read Delay,")); dataFile.println(PRESSURE_READ_DELAY);
    dataFile.print(F("Interpolation Calculation Delay,")); dataFile.println(INTERP_CALC_DELAY);
    dataFile.print(F("Controller Delay,")); dataFile.println(CONTROLLER_DELAY);
    dataFile.print(F("Traj times,"));
    for (int i = 0; i < TRAJ_SIZE; i++) dataFile.print(TIMES[i]), dataFile.print(i < TRAJ_SIZE - 1 ? ',' : '\n');
    dataFile.print(F("Traj pressures,"));
    for (int i = 0; i < TRAJ_SIZE; i++) dataFile.print(PRESSURES[i]), dataFile.print(i < TRAJ_SIZE - 1 ? ',' : '\n');
    dataFile.println(F("Data:"));

    // Write header information for the data
    dataFile.println(F("time,pressure,error,integral,cycle_start"));
    dataFile.close();
    return true;
  } else {
    setLCD(F("File create fail"), F("Check SD Card"));
    return false;
  }
}

// helper function to open an existing file
bool openFile(const char* fileName) {
  if (dataFile.open(fileName, O_RDWR | O_AT_END)) {
    return true;
  } else {
    setLCD(F("File open fail"), F("Check SD Card"));
    return false;
  }
}

// helper function to close the file
void closeSD() {
  if (dataFile) {
    dataFile.close();
  }
}

// write time, pressure, and error data to the SD card or Serial
void logData(double pressure, double error, double integral, bool cycleComplete, unsigned long currentTime) {
  if(USE_SD_CARD){ //write to SD card
    dataFile.print(currentTime - testStartTime);
    dataFile.print(',');
    dataFile.print(pressure, 2);
    dataFile.print(',');
    dataFile.print(error, 2);
    dataFile.print(',');
    dataFile.print(integral, 2);
    dataFile.print(',');
    dataFile.println(cycleComplete ? "1" : "0");
  }
  else{ // Otherwise, print to Serial
    Serial.print(currentTime - testStartTime);
    Serial.print(",");
    Serial.print(pressure);
    Serial.print(",");
    Serial.print(error);
    Serial.print(",");
    Serial.print(integral);
    Serial.print(",");
    Serial.println(cycleComplete ? "1" : "0");
  }
}

void syncData() {
  dataFile.sync();
}