//////////////////////////////////////////////////////////////////////////////
// LCD.h
//
// FT 5000 and FT 6050 EVB MultiSensor user interface header file.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _LCD_H_
#define _LCD_H_

// EVB MultiSensor application modes.
typedef enum {
    ModeWelcome,
    ModeStatus,
    ModeConfig
} DisplayMode;
DisplayMode currentDisplayMode;

// EVB MultiSensor application states.
typedef enum {
    ConfigLight,
    ConfigTemp,
    ConfigIsi
} ConfigState;
ConfigState currentConfigState;

// Display modes.
typedef enum {
    DataLightLocal,
    DataLightRemote,
    DataTempLocal,
    DataTempRemote,
    DataAlarm,
    DataLightConfig,
    DataTempConfig,
    DataIsiConfig
} DataType;

// Temperature units.
typedef enum {
    TempCelcius,
    TempFahrenheit
} TempType;
TempType currentTempType = TempCelcius;

// Helper functions
void DriveLCD(JoystickDirection direction);
void MoveToWelcomeMode(void);
void MoveToStatusMode(void);
void MoveToConfigMode(void);
void _RESIDENT DisplayData(DataType type);

#endif // _LCD_H_
