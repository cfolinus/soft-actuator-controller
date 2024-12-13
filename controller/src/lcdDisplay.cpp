#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include "adjustableSettings.h"

// Initialize the I2C LCD object
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Write two lines to the LCD display
void setLCD(String text1, String text2) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(text1);
  lcd.setCursor(0, 1);
  lcd.print(text2);
}

