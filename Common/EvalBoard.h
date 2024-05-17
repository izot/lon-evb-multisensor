//////////////////////////////////////////////////////////////////////////////
// EvalBoard.h
// 
// FT 5000 and FT 6050 EVB Evaluation Board I/O header file.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef EVALBOARD_H
#define EVALBOARD_H

#include <stddef.h>

//////////////////////////////////////////////////////////////////////////////
// EVB I/O
//////////////////////////////////////////////////////////////////////////////

#ifdef EVALBOARD_USE_LEDS

// LEDs -- there are two LEDs that are available on IO2 and IO3.
// The EVB uses bit I/O to interface with the LEDs.

typedef enum {
    Led1 = 0,
    Led2
} Leds;

IO_2 output bit ioLed1 = 1; // The LED is off by default
IO_3 output bit ioLed2 = 1; // The LED is off by default

// Illuminates or extinguishes a particular LED

void    EvalBoardSetLed(Leds whichLed, boolean bOnOrOff);

#endif // EVALBOARD_USE_LEDS

#ifdef EVALBOARD_USE_SWITCHES

#define EVALBOARD_USE_SWITCHES_JOYSTICK

// Switches and joystick -- there are two switches and one joystick with five
// directional values (up, left, bottom, down, center). The first switch is 
// available on IO_9 as bit I/O and the second switch along with the 5 joystick 
// values are available through serial bitshift on pins IO4 to IO6.

typedef enum {
    Switch1 = 0,
    Switch2
} Switches;

IO_9 input  bit ioSwitch1;

// Gets the status of a particular switch
boolean EvalBoardGetSwitch(Switches whichSwitch);

#endif // EVALBOARD_USE_SWITCHES

#ifdef EVALBOARD_USE_JOYSTICK

#ifndef EVALBOARD_USE_SWITCHES_JOYSTICK
#define EVALBOARD_USE_SWITCHES_JOYSTICK
#endif // EVALBOARD_USE_SWITCHES_JOYSTICK

typedef enum {
    JoystickInvalid           = -2,   // Not intialized
    JoystickNone              = -1,	  // Not pressed
    JoystickCenter            = 0,    // 0 degrees
    JoystickUp                = 1,    // 90 degrees
    JoystickLeft              = 2,    // 180 degrees
    JoystickDown              = 3,    // 270 degrees
    JoystickRight             = 4     // 360 degrees
}JoystickDirection;

// Gets the status of the joystick
JoystickDirection EvalBoardGetJoystick(void);

#endif // EVALBOARD_USE_JOYSTICK

#ifdef EVALBOARD_USE_SWITCHES_JOYSTICK
typedef enum {
    MaskJoystickUp            = 0x01,
    MaskJoystickLeft          = 0x02,
    MaskJoystickDown          = 0x04,
    MaskJoystickRight         = 0x08,
    MaskJoystickCenter        = 0x10,
    MaskJoystick              = 0x1F,
    MaskSwitch2               = 0x20,
}BitMask;

IO_4 input bitshift numbits(8) clockedge(-) ioSwitch2JoyStick;
IO_6 output bit ioSwitchLoad = 1;
#define MG_BUTTONS_DEBOUNCE   3
#endif // EVALBOARD_USE_SWITCHES_JOYSTICK

#ifdef EVALBOARD_USE_TEMPSENSOR

// Temperature sensor -- the EVB contains a Dallas 1-Wire DS18S20 digital
// temperature sensor. Since the EVB implements only one device on the
// 1-Wire bus, this implementation uses a simplified protocol, skipping the
// ROM search step.  (1-Wire is a registered trademark of Dallas Semiconductor)
// You can find out more about this device on www.maxim-ic.com
// The board uses touch I/O on pin IO7 to interface with the sensor.

IO_7 touch ioTemperatureSensor;
#define DS18S20_SKIP_ROM      0xCCu
#define DS18S20_CONVERT       0x44u
#define DS18S20_READ          0xBEu

// Get the temperature from the temperature sensor in degrees C
// with a resolution of 0.01

unsigned long EvalBoardGetTemperature(void);

#endif // EVALBOARD_USE_TEMPSENSOR

#ifdef EVALBOARD_USE_LCD

#define EVALBOARD_USE_LCD_LIGHTSENSOR

// Light sensor and LCD -- the EVB contains a TSL2560 light level-to-digital 
// converter and an NHD-0420D3Z-FL-GBW LCD module. The board interfaces to these
// devices using I2C on pins IO0 and IO1

#define LCD_COMMAND_PREFIX    0xFE
typedef enum {
    LcdDisplayOn              = 0x41,
    LcdDisplayOff             = 0x42,
    LcdSetCursor              = 0x45, // Takes 1 byte cursor location as parameter.
                                      // Calculate cursor location using the table below:
                                      //          Column1     Column20
                                      //  Line1   0x00        0x13
                                      //  Line2   0x40        0x53
                                      //  Line3   0x14        0x27
                                      //  Line4   0x54        0x67
    LcdCursorHome             = 0x46,
    LcdUnderlineCursorOn      = 0x47,
    LcdUnderlineCursorOff     = 0x48,
    LcdMoveCursorLeft         = 0x49,
    LcdMoveCursorRight        = 0x4A,
    LcdBlinkingCursorOn       = 0x4B,
    LcdBlinkingCursorOff      = 0x4C,
    LcdBackspace              = 0x4E,
    LcdClearScreen            = 0x51,
    LcdSetContrast            = 0x52, // Takes 1 byte value (1-50) as parameter. 50 is highest. Default is 40.
    LcdSetBrightness          = 0x53, // Takes 1 byte value (1-16) as parameter. 16 is highest. Default is 1.
    LcdCustomCharacter        = 0x54, // Takes buffer of 9 bytes as parameter.
                                      // First byte is custom character address from 0x00 to 0x07.
                                      // Remaining 8 bytes define the character in an 8x8 bitmap.
    LcdMoveDisplayLeft        = 0x55,
    LcdMoveDisplayRight       = 0x56,
    LcdChangeBaudRate         = 0x61, // Takes 1 byte value as parameter.
    LcdChangeI2CAddress       = 0x62, // Takes 1 byte value as parameter.
    LcdDisplayFirmwareVersion = 0x70,
    LcdDisplayBaudRate        = 0x71,
    LcdDisplayI2CAddress      = 0x72
}LcdCommands;

// Define the address of the first character on each line
char LCDRowFirstChar[4] =     {0x00, 0x40, 0x14, 0x54};

// Display dimensions
#define LCD_NUM_ROWS          4
#define LCD_NUM_COLUMNS       20

// The datasheet advertizes the address as 0x50, but in reality, the 7-bit
// right-justified address is 0x28 (0x50 >> 1)
#define I2C_ADDRESS_LCD       (0x50 >> 1)

// Send a command to the LCD module
void EvalBoardLCDSendCommand(LcdCommands command);

// Clears the LCD module display
void EvalBoardLCDClearScreen(void);

// Send a command with a 1-byte parameter to the LCD module
void EvalBoardLCDSendCommandWithParam(LcdCommands command, char param);

// Sets the location for cursor on the LCD module
void EvalBoardLCDSetCursor(unsigned row, unsigned column);

// Displays a character at the current location on the LCD module
void EvalBoardLCDDisplayChar(char value);

// Displays a string at a specified location on the LCD module
void EvalBoardLCDDisplayString(unsigned row, unsigned column, char* string);

// Displays a checkered reset pattern on the LCD module
void EvalBoardLCDResetPattern(void);

#endif // EVALBOARD_USE_LCD

#ifdef EVALBOARD_USE_LIGHTSENSOR

#ifndef EVALBOARD_USE_LCD_LIGHTSENSOR
#define EVALBOARD_USE_LCD_LIGHTSENSOR
#endif // EVALBOARD_USE_LCD_LIGHTSENSOR

#define LIGHTSENSOR_COMMAND_CONTROL    0x80
#define LIGHTSENSOR_COMMAND_READ_DATA0 0xAC
#define LIGHTSENSOR_COMMAND_READ_DATA1 0xAE

#define LIGHTSENSOR_POWER_ON           0x03
#define LIGHTSENSOR_POWER_OFF          0x00

#define I2C_ADDRESS_LIGHTSENSOR        0x39

// Turn the light sensor on or off
void EvalBoardLightSensorPower(boolean bOn);

// Get the light level from the light level sensor in Lux
unsigned long EvalBoardGetLightLevel(void);

#endif // EVALBOARD_USE_LIGHTSENSOR

#ifdef EVALBOARD_USE_LCD_LIGHTSENSOR
IO_0 i2c __slow ioLightSensorLCD;
#endif // EVALBOARD_USE_LCD_LIGHTSENSOR

#ifdef EVALBOARD_USE_SERIALDEBUG
#include <io_types.h>
#pragma specify_io_clock "10 MHz"
IO_8 sci baud(SCI_9600) ioSerialDebug;
void EvalBoardPrintDebug(char* string);
#endif // EVALBOARD_USE_SERIALDEBUG

// Reset the EVB
void    EvalBoardReset(void);

#endif  // EVALBOARD_H
