//////////////////////////////////////////////////////////////////////////////
// LightSensor.nc
//
// FT 5000 and FT 6050 EVB Light Sensor block.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _LightSensor_NC_
#define _LightSensor_NC_

// <CP Declarations>

network input cp SCPTluxSetpoint nciLowLightAlarm;

// <Output NV Declarations>

network output SNVT_lux nvoLightLevel = 0;

// Disable inherited profile warning

#pragma disable_warning 486

// <Block Declaration>

fblock UFPTlightSensor {
	nvoLightLevel implements nvoLuxLevel;
} LightSensor
#ifdef USE_EXTERNAL_NAME
external_name("LightSensor")
#endif
fb_properties {
	nciLowLightAlarm = 40
};

// Read the light sensor and publish the value to the Light Sensor block output.

void ProcessLightSensor(void)
{
    SNVT_lux lightLevel;
    lightLevel = EvalBoardGetLightLevel();

    nvoLightLevel = lightLevel;
    DisplayData(DataLightLocal);

    // Check for an alarm condition
    CheckForAlarms();
}

#endif //  _LightSensor_NC_
