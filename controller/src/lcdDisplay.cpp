#include <Arduino.h>
#include "lcdDisplay.h"
#include "adjustableSettings.h"

// Initialize the LiquidCrystal object with externally defined pin names
LiquidCrystal lcd(LCD_RS, LCD_E, LCD_D4, LCD_D5, LCD_D6, LCD_D7);

void setLCD(String text1, String value) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(text1);
  lcd.setCursor(0, 1);
  lcd.print(value);
}
