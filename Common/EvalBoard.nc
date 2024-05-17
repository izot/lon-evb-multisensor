//////////////////////////////////////////////////////////////////////////////
// EvalBoard.nc
//
// FT 5000 and FT 6050 Evaluation Board utility functions.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef EVALBOARD_NC
#define	EVALBOARD_NC

#include "EvalBoard.h"
#include <string.h>

#ifdef EVALBOARD_USE_SWITCHES_JOYSTICK
unsigned GetIO5SerialInput(void)
{
    unsigned debounce, buttons;
    buttons = 0xFF;
    for (debounce = 0; debounce < MG_BUTTONS_DEBOUNCE; debounce ++) {
        // Capture parallel lines
        io_out(ioSwitchLoad, 0);
        // Deactivate capture--the 74HC165 requires no more than 100ns for
        // capture
        io_out(ioSwitchLoad, 1);
        // Take a sample and debounce
        buttons &= (unsigned)io_in(ioSwitch2JoyStick);
    }
    return ~buttons;
}
#endif // EVALBOARD_USE_SWITCHES_JOYSTICK

void EvalBoardReset(void)
{
	#ifdef EVALBOARD_USE_LCD
		EvalBoardLCDSendCommand(LcdDisplayOn);
		delay(10);
		EvalBoardLCDSendCommandWithParam(LcdSetBrightness, 8);
		EvalBoardLCDClearScreen();
		EvalBoardLCDResetPattern();
		EvalBoardLCDClearScreen();
	#endif // EVALBOARD_USE_LCD

	#ifdef EVALBOARD_USE_LIGHTSENSOR
		EvalBoardLightSensorPower(TRUE);
	#endif // EVALBOARD_USE_LIGHTSENSOR
}

#ifdef EVALBOARD_USE_LEDS
void EvalBoardSetLed(Leds whichLed, boolean bOn)
{
	switch (whichLed) {
	case Led1:
		io_out(ioLed1, !bOn);
		break;
	case Led2:
		io_out(ioLed2, !bOn);
		break;
	default:
		break;
	}
}
#endif // EVALBOARD_USE_LEDS

#ifdef EVALBOARD_USE_SWITCHES
boolean EvalBoardGetSwitch(Switches whichSwitch)
{
	boolean retValue;
	unsigned value;

	switch (whichSwitch) {
	case Switch1:
		retValue = !io_in(ioSwitch1);
		break;
	case Switch2:
		value = GetIO5SerialInput();
		retValue = value & MaskSwitch2;
		break;
	default:
		break;
	}
    return retValue;
}
#endif // EVALBOARD_USE_SWITCHES

#ifdef EVALBOARD_USE_TEMPSENSOR
unsigned long EvalBoardGetTemperature(void)
{
    union {
        unsigned long 	value;
        unsigned    	bytes[2];
    } CurrentTemperature;
    CurrentTemperature.value = 32767l;

    if (touch_reset(ioTemperatureSensor)) {
        (void) touch_byte(ioTemperatureSensor, DS18S20_SKIP_ROM);
        (void) touch_byte(ioTemperatureSensor, DS18S20_READ);

        CurrentTemperature.bytes[1] = touch_byte(ioTemperatureSensor, 0xFFu); // low
        CurrentTemperature.bytes[0] = touch_byte(ioTemperatureSensor, 0xFFu); // high

        if (touch_reset(ioTemperatureSensor)) {
            //  The value currently held in TemperatureDataBuffer is the raw DS18S20
            //  data, in Celsius, at a resolution of 0.5 degrees. SNVT_temp_p, however,
            //  provides a resolution of 0.01 in a fixed-point implementation.
            //  We must correct the raw reading by factor 50 thus:
            CurrentTemperature.value *= 50l;
            CurrentTemperature.value += random() % 100UL;       
            // start the next conversion cycle:
            (void) touch_byte(ioTemperatureSensor, DS18S20_SKIP_ROM);
            (void) touch_byte(ioTemperatureSensor, DS18S20_CONVERT);
        }
        else {
            CurrentTemperature.value = 32767l;
        }
    }
    return CurrentTemperature.value;
}

#endif // EVALBOARD_USE_TEMPSENSOR

#ifdef EVALBOARD_USE_LIGHTSENSOR
#include "lux.nc"
void EvalBoardLightSensorPower(boolean bOn)
{
	char data[2];
	data[0] = LIGHTSENSOR_COMMAND_CONTROL;
	data[1] = bOn ? LIGHTSENSOR_POWER_ON : LIGHTSENSOR_POWER_OFF;
	(void)io_out(ioLightSensorLCD, data, I2C_ADDRESS_LIGHTSENSOR, 2);
}

unsigned long EvalBoardGetLightLevel(void)
{
	unsigned long data0, data1;
	char buffer[2];
	char command;

	command = LIGHTSENSOR_COMMAND_READ_DATA0;
	(void)io_out(ioLightSensorLCD, &command, I2C_ADDRESS_LIGHTSENSOR, 1);
	(void)io_in(ioLightSensorLCD, &buffer, I2C_ADDRESS_LIGHTSENSOR, 2);
	data0 = buffer[1] * 256;
	data0 += buffer[0];

	command = LIGHTSENSOR_COMMAND_READ_DATA1;
	(void)io_out(ioLightSensorLCD, &command, I2C_ADDRESS_LIGHTSENSOR, 1);
	(void)io_in(ioLightSensorLCD, &buffer, I2C_ADDRESS_LIGHTSENSOR, 2);
	data1 = buffer[1] * 256;
	data1 += buffer[0];

	return CalculateLux(0, 2, data0, data1);
}
#endif // EVALBOARD_USE_LIGHTSENSOR

#ifdef EVALBOARD_USE_JOYSTICK
JoystickDirection EvalBoardGetJoystick(void)
{
    JoystickDirection dir;
    unsigned value;

    value = GetIO5SerialInput();
    switch (value & MaskJoystick) {
    case MaskJoystickCenter:
        dir = JoystickCenter;
        break;

    case MaskJoystickRight:
        dir = JoystickRight;
        break;

    case MaskJoystickUp:
        dir = JoystickUp;
        break;

    case MaskJoystickLeft:
        dir = JoystickLeft;
        break;

    case MaskJoystickDown:
        dir = JoystickDown;
        break;

    default:
    	dir = JoystickNone;
        break;
    }
    return dir;
}
#endif // EVALBOARD_USE_JOYSTICK

#ifdef EVALBOARD_USE_LCD
#include <control.h> // For watchdog_update()
void    EvalBoardLCDSendCommand(LcdCommands command)
{
	char data[2];

    data[0] = LCD_COMMAND_PREFIX;
    data[1] = command;
    (void)io_out(ioLightSensorLCD, data, I2C_ADDRESS_LCD, 2);
}

void EvalBoardLCDClearScreen(void)
{
	EvalBoardLCDSendCommand(LcdClearScreen);
	msec_delay(5);		// LCD spec states at least 1.5ms to execute.
}

void EvalBoardLCDSendCommandWithParam(LcdCommands command, char param)
{
	char data[3];

    data[0] = LCD_COMMAND_PREFIX;
    data[1] = command;
    data[2] = param;
    (void)io_out(ioLightSensorLCD, data, I2C_ADDRESS_LCD, 3);
}

void EvalBoardLCDSetCursor(unsigned row, unsigned column)
{
    // Verify row and column are valid
    if (row < LCD_NUM_ROWS  &&  column < LCD_NUM_COLUMNS)
        EvalBoardLCDSendCommandWithParam(LcdSetCursor, LCDRowFirstChar[row] + column);
}

void EvalBoardLCDDisplayChar(char value)
{
	(void)io_out(ioLightSensorLCD, &value, I2C_ADDRESS_LCD, 1);
}

void EvalBoardLCDDisplayString(unsigned row, unsigned column, char *string)
{
	unsigned i;

	// This function does not support multi-line strings
	// Verify there is enough space on the current row for the string to be displayed
	if (column + strlen(string) <= LCD_NUM_COLUMNS) {
		EvalBoardLCDSetCursor(row, column);
	    for (i = 0; i < strlen(string); i++)
	        EvalBoardLCDDisplayChar(string[i]);
	}
}

void EvalBoardLCDResetPattern(void)
{
	unsigned long i;

	for (i = 0; i < LCD_NUM_COLUMNS; i++) {
		EvalBoardLCDDisplayChar(0xFF);
		EvalBoardLCDDisplayChar(' ');
	}
	for (i = 0; i < LCD_NUM_COLUMNS; i++) {
		EvalBoardLCDDisplayChar(' ');
		EvalBoardLCDDisplayChar(0xFF);
	}

	msec_delay(250);
	watchdog_update();
	msec_delay(250);
	watchdog_update();

	for (i = 0; i < LCD_NUM_COLUMNS; i++) {
		EvalBoardLCDDisplayChar(' ');
		EvalBoardLCDDisplayChar(0xFF);
	}
	for (i = 0; i < LCD_NUM_COLUMNS; i++) {
		EvalBoardLCDDisplayChar(0xFF);
		EvalBoardLCDDisplayChar(' ');
	}

	msec_delay(250);
	watchdog_update();
	msec_delay(250);
	watchdog_update();
}

#endif // EVALBOARD_USE_LCD

#ifdef EVALBOARD_USE_SERIALDEBUG

void EvalBoardPrintDebug(char *string)
{
	io_out_request(ioSerialDebug, string, (unsigned int) strlen(string));
	while (!io_out_ready(ioSerialDebug));
}

#endif // EVALBOARD_USE_SERIALDEBUG

#endif // EVALBOARD_NC
