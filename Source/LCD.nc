//////////////////////////////////////////////////////////////////////////////
// LCD.nc
//
// FT 5000 and FT 6050 EVB MultiSensor user interface functions.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//
// Display Pages
//
// 1. A Welcome page shown briefly on startup displaying the version number
//    and management mode.
//
// 2. A Status page that displays the status of the local light-level and
//    temperature sensors.  When connected to a remote sensor, the Status
//    page also displays the status of the remote sensor.
//
// 3. A Configuration page for setting the local light-level and temperature 
//    alarm thresholds, and for manually enabling or disabling ISI.
//
// Joystick Inputs
//
// 1. Center Pushbutton -- toggles between the Status page and Configuration
//    page.
//
// 2. Up/Down -- Moves between lines on the Configuration page, and changes
//    between the Status and Configuration pages.
//
// 3. Left/Right -- Toggle Fahrenheit and Celsius temperature display on the 
//    Status page and increments or decrements the current setting on the
//    Configuration page.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef _LCD_NC_
#define _LCD_NC_

#include "LCD.h"

static far char blanks[LCD_NUM_COLUMNS + 1];
static far char buf[32] = {0};
SCPTnwrkCnfg isiConfig;
static unsigned long lightConfig;
static far char strValue[LCD_NUM_COLUMNS + 1];
static unsigned long tempConfig;

#define LCD_REFRESH_RATE	60 // in seconds
stimer tRefresh;

// Convert an integer value to text in a specified base.

char* itoa(unsigned long val, unsigned int base)
{
	unsigned int i;
	
	if (val == 0) {
		buf[30] = '0';
		i = 29;
	} else {
		for (i = 30; val && i ; --i, val /= base) {
			buf[i] = "0123456789abcdef"[val % base];
		}
	}
	buf[31] = '\0';
	return &buf[i+1];
}

// Append blanks to a text string to make it a specified width.

static void AddBlanks(char *field, unsigned long width) 
{
	unsigned long strLength;

	strLength = strlen(field);
	if (strLength < width) {
		(void)strcat(field, &blanks[sizeof(blanks) - (width - strLength) - 1]);
	}
}

// Fill the blanks array with blanks and nul terminator.

static void FillBlanks(void)
{
	unsigned long i;
	
	for (i = 0; i < sizeof(blanks) - 1; i++) {
		blanks[i] = ' ';
	}
	blanks[i] = '\0';
}

// Return true if a remote sensor is connected.

boolean RemoteConnected(void)
{
	return(is_bound(nviLightRemote) || is_bound(nviTempRemote));
}

// Go to the light-level alarm setting for the Configuration page.

void GotoLight(void)
{
	currentConfigState = ConfigLight;
	EvalBoardLCDSetCursor(1, 19);
	EvalBoardLCDDisplayChar(0x7F);
	EvalBoardLCDSetCursor(2, 19);
	EvalBoardLCDDisplayChar(' ');
	EvalBoardLCDSetCursor(3, 19);
	EvalBoardLCDDisplayChar(' ');
	EvalBoardLCDSendCommand(LcdUnderlineCursorOff);
	DisplayData(DataLightConfig);
}

// Go to the temperature alarm setting for the Configuration page.

void GotoTemp(void)
{
	currentConfigState = ConfigTemp;
	EvalBoardLCDSetCursor(1, 19);
	EvalBoardLCDDisplayChar(' ');
	EvalBoardLCDSetCursor(2, 19);
	EvalBoardLCDDisplayChar(0x7F);
	EvalBoardLCDSetCursor(3, 19);
	EvalBoardLCDDisplayChar(' ');
	EvalBoardLCDSendCommand(LcdUnderlineCursorOff);
	DisplayData(DataTempConfig);
}

// Go to the ISI setting for the Configuration page.

void GotoIsi(void)
{
	currentConfigState = ConfigIsi;
	EvalBoardLCDSetCursor(1, 19);
	EvalBoardLCDDisplayChar(' ');
	EvalBoardLCDSetCursor(2, 19);
	EvalBoardLCDDisplayChar(' ');
	EvalBoardLCDSetCursor(3, 19);
	EvalBoardLCDDisplayChar(0x7F);
	EvalBoardLCDSendCommand(LcdUnderlineCursorOff);
	DisplayData(DataIsiConfig);
}

// Increment the light-level alarm setting.

void IncrementLightConfig(void)
{
	lightConfig += 5;
	DisplayData(DataLightConfig);
}

// Decrement the light-level alarm setting.

void DecrementLightConfig(void)
{
	lightConfig -= 5;
	DisplayData(DataLightConfig);
}

// Increment the temperature alarm setting.

void IncrementTempConfig(void)
{
	tempConfig += 50;
	DisplayData(DataTempConfig);
}

// Decrement the temperature alarm setting.

void DecrementTempConfig(void)
{
	tempConfig -= 50;
	DisplayData(DataTempConfig);
}

// Discard configuration setting changes.

void DiscardChanges(void)
{
	lightConfig = nciLowLightAlarm;
    tempConfig = nciHighTempAlarm;
    isiConfig = NodeObject::nciNetConfig;
}
#pragma ignore_notused DiscardChanges

// Save configuration setting changes.

void SaveChanges(void)
{
	nciLowLightAlarm = lightConfig;
    nciHighTempAlarm = tempConfig;
    if (isiConfig != NodeObject::nciNetConfig) {
    	NodeObject::nciNetConfig = isiConfig;
    	ProcessIsiCpUpdate();
    	if (isiConfig == CFG_EXTERNAL) {
    		go_unconfigured();
    	}
    }
}

// Toggle Celcius and Farhrenheit configuration setting.

void ToggleTempType(void)
{
	currentTempType = (currentTempType == TempCelcius) ? TempFahrenheit : TempCelcius;
	if (currentDisplayMode == ModeStatus) {
		DisplayData(DataTempLocal);
		DisplayData(DataTempRemote);
	}
}

// Toggle the ISI configuration setting.

void ToggleIsiConfig(void)
{
    isiConfig = (isiConfig == CFG_LOCAL) ? CFG_EXTERNAL : CFG_LOCAL;
    DisplayData(DataIsiConfig);
}

// Process a joystick input based on the current display mode.

void DriveLCD(JoystickDirection direction)
{
	switch (currentDisplayMode) {
	case ModeWelcome:
		switch (direction) {
		case JoystickUp:
		case JoystickLeft:
		case JoystickCenter:
		case JoystickRight:
		case JoystickDown:
			MoveToStatusMode();
			break;

		default:
			break;
		}
		break;

	case ModeStatus:
		switch (direction) {
		case JoystickLeft:
		case JoystickRight:
			ToggleTempType();
			break;

		case JoystickDown:
		case JoystickCenter:
		case JoystickUp:
			MoveToConfigMode();
			break;

		default:
			break;
		}
		break;

	case ModeConfig:
		switch (currentConfigState) {
		case ConfigLight:
			switch (direction) {
			case JoystickUp:
			case JoystickCenter:
                SaveChanges();
                MoveToStatusMode();
				break;

			case JoystickDown:
				GotoTemp();
				break;

			case JoystickLeft:
				DecrementLightConfig();
				break;

			case JoystickRight:
				IncrementLightConfig();
				break;

			default:
				break;
			}
			break;

		case ConfigTemp:
			switch (direction) {
			case JoystickUp:
				GotoLight();
				break;

			case JoystickDown:
				GotoIsi();
				break;

			case JoystickLeft:
				DecrementTempConfig();
				break;

			case JoystickRight:
				IncrementTempConfig();
				break;

			case JoystickCenter:
                SaveChanges();
                MoveToStatusMode();
				break;

			default:
				break;
			}
			break;

		case ConfigIsi:
			switch (direction) {
			case JoystickUp:
				GotoTemp();
				break;

			case JoystickLeft:
			case JoystickRight:
				ToggleIsiConfig();
				break;

			case JoystickCenter:
			case JoystickDown:
                SaveChanges();
                MoveToStatusMode();
				break;

			default:
				break;
			}
			break;

		default:
			break;
		}
	}
}

// Display the Welcome page.

void MoveToWelcomeMode(void)
{
	currentDisplayMode = ModeWelcome;
	FillBlanks();
    EvalBoardLCDClearScreen();
	#pragma relaxed_casting_on
	#pragma disable_warning 464
    EvalBoardLCDDisplayString(0, 0, "Dialog Semiconductor");
    EvalBoardLCDDisplayString(1, 1, "FT EVB MultiSensor");
    EvalBoardLCDDisplayString(2, 4, VersionString);
    EvalBoardLCDDisplayString(3, 3, IsiIsRunning() ? "  (ISI Mode)" : "(Managed Mode)");
	EvalBoardPrintDebug("Welcome mode\r\n");
	#pragma enable_warning 464
	#pragma relaxed_casting_off
}

// Display the Status page.

void MoveToStatusMode(void)
{
	currentDisplayMode = ModeStatus;
	FillBlanks();
    EvalBoardLCDClearScreen();
	#pragma relaxed_casting_on
	#pragma disable_warning 464
	EvalBoardLCDDisplayString(0, 0, RemoteConnected() ? "Status-Local Remote" : "       Status");
    EvalBoardLCDDisplayString(1, 0, "Light:");
    EvalBoardLCDDisplayString(2, 0, "Temp :");
    EvalBoardLCDDisplayString(3, 0, "Alarm:");

    DisplayData(DataLightLocal);
    DisplayData(DataTempLocal);
    DisplayData(DataLightRemote);
    DisplayData(DataTempRemote);
    DisplayData(DataAlarm);

	EvalBoardPrintDebug("Status mode\r\n");
	#pragma enable_warning 464
	#pragma relaxed_casting_off

	// Start refresh timer
	tRefresh = LCD_REFRESH_RATE;
}

// Display the Configuration page.

void MoveToConfigMode(void)
{
	currentDisplayMode = ModeConfig;
	FillBlanks();
    EvalBoardLCDClearScreen();
	#pragma relaxed_casting_on
	#pragma disable_warning 464
    EvalBoardLCDDisplayString(0, 3, "Configuration");
    EvalBoardLCDDisplayString(1, 0, "Light Alarm:");
    EvalBoardLCDDisplayString(2, 0, "Temp Alarm :");
    EvalBoardLCDDisplayString(3, 0, "ISI Enabled:");

    lightConfig = nciLowLightAlarm;
    tempConfig = nciHighTempAlarm;
	isiConfig = NodeObject::nciNetConfig;
    DisplayData(DataLightConfig);
    DisplayData(DataTempConfig);
	DisplayData(DataIsiConfig);
    GotoLight();

	EvalBoardPrintDebug("Config mode\r\n");
	#pragma enable_warning 464
	#pragma relaxed_casting_off
}

// Display a specified data value on the Status or Configuration page.
// Keep resident to simplify debugging.

void _RESIDENT DisplayData(DataType type)
{
	switch (type) {
	case DataLightLocal:
		if (currentDisplayMode == ModeStatus) {
			unsigned long value;
			boolean kFlag;
			
			value = nvoLightLevel;
			kFlag = (value >= (RemoteConnected() ? 1000 : 10000));
			if (kFlag) {
				value /= 1000;
			}
			(void)strcpy(strValue, itoa(value, 10));
			if (kFlag) {
				(void)strcat(strValue, "K");
			}
			if (!RemoteConnected()) {
				(void)strcat(strValue, " Lux");
			}
			AddBlanks(strValue, RemoteConnected() ? 4 : 8);
			EvalBoardLCDDisplayString(1, 7, strValue);
		}
		break;

	case DataTempLocal:
		if (currentDisplayMode == ModeStatus) {
			unsigned long value1;
			unsigned long value2;
			boolean outOfRangeFlag;
			
			outOfRangeFlag = nvoTemperature < 0;

			if (outOfRangeFlag) {
				(void)strcpy(strValue, "---");
			} else {
				if (currentTempType == TempCelcius) {
					value1 = nvoTemperature / 100;
					value2 = nvoTemperature % 100;
					value2 /= 10;
				} else {
					unsigned long tempF;

					tempF = (9*nvoTemperature)/5 + 3200;
					value1 = tempF / 100;
					value2 = tempF % 100;
					value2 /= 10;
				}
				(void)strcpy(strValue, itoa(value1, 10));
				(void)strcat(strValue, ".");
				(void)strcat(strValue, itoa(value2, 10));

				if (!RemoteConnected()) {
					(void)strcat(strValue, (currentTempType == TempCelcius) ? " C" : " F");
				}
			}

			AddBlanks(strValue, RemoteConnected() ? 5 : 7);
			EvalBoardLCDDisplayString(2, 7, strValue);
		}
		break;

	case DataAlarm:
		if (currentDisplayMode == ModeStatus) {
			#pragma warnings_off
			#pragma relaxed_casting_on
			(void)strcpy(strValue, (char*)nvoAlarm.description);
			#pragma relaxed_casting_off
			#pragma warnings_on
			AddBlanks(strValue, 12);
			EvalBoardLCDDisplayString(3, 7, strValue);
		}
		break;
		
	case DataLightRemote:
		if (currentDisplayMode == ModeStatus) {
			unsigned long value;
			boolean kFlag;

			if (is_bound(nviLightRemote)) {
				value = nviLightRemote;
				kFlag = (value >= 1000);
				if (kFlag) {
					value /= 1000;
				}
				(void)strcpy(strValue, itoa(value, 10));
				if (kFlag) {
					(void)strcat(strValue, "K");
				}
				if (strlen(strValue) < 4) {
					(void)strcat(strValue, " ");
				}
				(void)strcat(strValue, "Lux");
				AddBlanks(strValue, 7);
				EvalBoardLCDDisplayString(1, 13, strValue);
			}
		}
		break;

	case DataTempRemote:
		if (currentDisplayMode == ModeStatus) {
			unsigned long value1;
			unsigned long value2;

			if (is_bound(nviTempRemote)) {
				if (currentTempType == TempCelcius) {
					value1 = nviTempRemote / 100;
					value2 = nviTempRemote % 100;
					value2 /= 10;
				} else {
					unsigned long tempF;

					tempF = (9*nviTempRemote)/5 + 3200;
					value1 = tempF / 100;
					value2 = tempF % 100;
					value2 /= 10;
				}

				(void)strcpy(strValue, itoa(value1, 10));
				(void)strcat(strValue, ".");
				(void)strcat(strValue, itoa(value2, 10));
				(void)strcat(strValue, (currentTempType == TempCelcius) ? " C" : " F");
				AddBlanks(strValue, 7);
				EvalBoardLCDDisplayString(2, 13, strValue);
			}
		}
		break;

	case DataLightConfig:
		if (currentDisplayMode == ModeConfig) {
			unsigned long value;
			boolean kFlag;

			value = lightConfig;
			kFlag = (value >= 10000);
			if (kFlag) {
				value /= 1000;
			}
			(void)strcpy(strValue, itoa(value, 10));
			if (strlen(strValue) < 4) {
				(void)strcat(strValue, " ");
			}
			(void)strcat(strValue, "Lux");
			AddBlanks(strValue, 7);
			EvalBoardLCDDisplayString(1, 12, strValue);
			EvalBoardLCDSendCommand(LcdMoveCursorLeft);
		}
		break;

	case DataTempConfig:
		if (currentDisplayMode == ModeConfig) {
			unsigned long value1;
			unsigned long value2;

			if (currentTempType == TempCelcius) {
				value1 = tempConfig / 100;
				value2 = tempConfig % 100;
				value2 /= 10;
			} else {
				unsigned long tempF;

				tempF = (9*tempConfig)/5 + 3200;
				value1 = tempF / 100;
				value2 = tempF % 100;
				value2 /= 10;
			}

			(void)strcpy(strValue, itoa(value1, 10));
			(void)strcat(strValue, ".");
			(void)strcat(strValue, itoa(value2, 10));
			(void)strcat(strValue, (currentTempType == TempCelcius) ? " C" : " F");

			AddBlanks(strValue, 7);
			EvalBoardLCDDisplayString(2, 12, strValue);
			EvalBoardLCDSendCommand(LcdMoveCursorLeft);
		}
		break;

    case DataIsiConfig:
    	if (currentDisplayMode == ModeConfig) {
        	(void)strcpy(strValue, (isiConfig == CFG_LOCAL) ? "On " : "Off");
        	EvalBoardLCDDisplayString(3, 12, strValue);
        }
 		break;
 		               
	default:
		break;
	}
}

// Refresh the display periodically while displaying the Status page.

when (timer_expires(tRefresh))
{
	if (currentDisplayMode == ModeStatus) {
		MoveToStatusMode();
	}
}

#endif // _LCD_NC_
