//////////////////////////////////////////////////////////////////////////////
// TempSensor.nc
//
// FT 5000 and FT 6050 EVB MultiSensor Temperature Sensor block.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _TempSensor_NC_
#define _TempSensor_NC_

// <CP Family Declarations>

SCPTmaxSendTime cp_family nciMaxSendTime;
SCPTminSendTime cp_family nciMinSendTime;
SCPTminDeltaTemp cp_family nciMinDelta;

network input cp SCPThighLimTemp nciHighTempAlarm;

// <Output NV Declaration>

network output SNVT_temp_p nvoTemperature = 0
nv_properties {
	nciMinDelta = 50
};

// Disable inherited profile warning

#pragma disable_warning 486

// <Block Declaration>

fblock UFPThvacTempSensor {
	nvoTemperature 	implements nvoHVACTemp;
} TempSensor
#ifdef USE_EXTERNAL_NAME
external_name("TempSensor")
#endif
fb_properties {
	nciMaxSendTime = 600,
	nciMinSendTime = 10,
	nciHighTempAlarm = 3500
};

//  Process heartbeats and throttles

far SCPTmaxSendTime heartbeat;
void ProcessHeartbeats()
{
    if (TempSensor::nciMaxSendTime) {
        // HB ticking
        if (--heartbeat == 0) {
            // Timer expired. propagate NV(s) and reload timer
            propagate(TempSensor::nvoHVACTemp);
            heartbeat = TempSensor::nciMaxSendTime;
        }
    }
}

// Read and process the temperature sensor. The temperature sensor employs three CPs
// that control NV updates issued by this block: the heartbeat, the throttle, and the minimum 
// delta configuration properties.
//
// The heartbeat interval determines a minimum update frequency.  If the reading has not
// changed since the last heartbeat, the most recent value will be re-propagated at an 
// interval determined by the heartbeat timer.
//
// The throttle period indicates a minimum time between two updates. In the event of rapidly 
// changing readings, this slows down NV updates to a sustainable rate.
//
// The minimum delta describes the minimum absolute difference between the most recent and the
// current reading that is considered significant. New readings that vary less than the minimum
// delta are not be propagated on the network.

void ProcessTemperatureSensor(void)
{
    SNVT_temp_p lTemperature;
    lTemperature = EvalBoardGetTemperature();

    if (abs(lTemperature - nvoTemperature) > nvoTemperature::nciMinDelta) {
        // Process a new value that varies enough from the most recent value to be considered.
        // Update the output NVs via pointers so that the new values are stored, but the NV
        // update will not be propagated automatically. 
		#pragma relaxed_casting_on
		#pragma warnings_off
        *((SNVT_temp_p*) &nvoTemperature) = lTemperature;
		#pragma relaxed_casting_off
		#pragma warnings_on

        // Decide whether the updates can be propagated now, or schedule a future
        // propagation and reset the heartbeat timer.  Evaluate if the update must 
        // be throttled. If we send now, reset the heartbeat. If not, let the heartbeat 
        // expire without resetting.
        if (TempSensor::nciMaxSendTime - heartbeat > TempSensor::nciMinSendTime) {
            // Throttle has expired
            propagate(nvoTemperature);
            heartbeat = TempSensor::nciMaxSendTime;
        }
    }
    // Display the data on the LCD
    DisplayData(DataTempLocal);

    // Check for an alarm condition
    CheckForAlarms();
}

#endif //  _TempSensor_NC_
