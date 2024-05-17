//////////////////////////////////////////////////////////////////
// NodeObject.nc
//
// FT 5000 and FT 6050 EVB MultiSensor Node Object block.  Route
// external requests that relate to other EVB MultiSensor blocks to
// the relevant director functions.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _NodeObject_NC_
#define _NodeObject_NC_

#include <snvt_rq.h>
#include <snvt_al.h>
#include <snvt_pr.h>
#include <snvt_cfg.h>
#include <string.h>
#include <s32.h>

// The application will report a version number of
// nciDevMajVer.nciDevMinVer.BUILD_NUM

#define BUILD_NUM	0

// <CP Declarations>

const SCPTdevMajVer cp_family nciDevMajVer;
const SCPTdevMinVer cp_family cp_info(device_specific) nciDevMinVer;
network input cp cp_info(device_specific) SCPTnwrkCnfg nciNetConfig;

// <Input NV Declarations>

network input SNVT_obj_request nviRequest;
network input SNVT_lux nviLightRemote = 0;
network input SNVT_temp_p nviTempRemote = 0;

// <Output NV Declarations>

network output sync SNVT_obj_status nvoStatus;
network output SNVT_alarm_2 nvoAlarm = {AL_NO_CONDITION, PR_NUL, {0x00, 0x00, 0x00, 0x00}, 0, 0, {"None"}};
network output SNVT_alarm_2 nvoAlarmRemote = {AL_NO_CONDITION, PR_NUL, {0x00, 0x00, 0x00, 0x00}, 0, 0, {"None"}};
network output polled const SNVT_address nvoFileDirectory = (SNVT_address)&FileDirectory;

// Disable inherited profile warning

#pragma disable_warning 486

// <Block Declaration>

fblock UFPTnodeObject {
   nviRequest       implements nviRequest;
   nvoStatus        implements nvoStatus;
   nviLightRemote   implements nviLightRemote;
   nviTempRemote    implements nviTempRemote;
   nvoAlarm         implements nvoAlarm2;
   nvoAlarmRemote   implements nvoAlarmRemote;
   nvoFileDirectory implements nvoFileDirectory;
} NodeObject
#ifdef USE_EXTERNAL_NAME
external_name("NodeObject")
#endif
fb_properties {
	nciDevMajVer = 6,
	nciDevMinVer = 0,
	nciNetConfig = CFG_EXTERNAL
};

void ProcessIsiCpUpdate(void);

// -----------------------------------------------------------------------
// Node Object Implementation
// -----------------------------------------------------------------------

// The following variable is used for device management duties.
// Make the variable persistent with the eeprom modifier. Initial values 
// for these variables are only set at application download, but persist
// a reset.  Implementing one persistent state variable for all blocks, 
// the N-th bit (starting with N=0 for the LSB) represents the boolean 
// disabled state for block N, where N equals the block's global index.

#define FBLOCK_DISABLED 0x01u

far offchip eeprom unsigned long bitmapDisabled = 0;

boolean IsEnabled(unsigned fbIndex)
{
    return !(boolean)(bitmapDisabled & (FBLOCK_DISABLED << fbIndex));
}

when (nv_update_occurs(nviRequest))
{
    unsigned first, last;
    SNVT_obj_status statusOutput;
    boolean copy;

    // Process requests received via nviRequest.  This NV describes the
    // request in the object_request field, and the selected object in 
    // the object_id field. The object_id can be a specific object other 
    // than the Node Object, or 0 (zero) to address all objects on the 
    // device with a single request.

    memset(&statusOutput, 0, (unsigned)sizeof(statusOutput));
    statusOutput.object_id = nviRequest.object_id;

    if (nviRequest.object_id > TOTAL_FBLOCK_COUNT - 1) {
        statusOutput.invalid_id = 1;
    }
    else {
        if (nviRequest.object_id == 0) {
            first = 1;
            last = TOTAL_FBLOCK_COUNT - 1;
        }
        else {
            first = last = (unsigned)nviRequest.object_id;
        }
        copy = FALSE;

        if (nviRequest.object_request == RQ_NORMAL) {
            // Support for RQ_NORMAL is mandatory
            // Whichever state the object is in, return to normal operation:
            bitmapDisabled  = 0;
            statusOutput.disabled = 0;
            copy = TRUE;
        }
        else if (nviRequest.object_request == RQ_UPDATE_STATUS) {
            // Support for RQ_UPDATE_STATUS is mandatory
            // Report state for the selected object
            if (first == last) {
                statusOutput.disabled = !IsEnabled(first);
            }
            else {
                statusOutput.disabled = 0;
                while (first <= last) {
                    statusOutput.disabled  |= !IsEnabled(first ++);
                }
            }
        }
        else if (nviRequest.object_request == RQ_REPORT_MASK) {
            // Support for RQ_REPORT_MASK is mandatory
            // Report the object's capability:
            statusOutput.disabled = statusOutput.report_mask = 1;
        }
        else if (nviRequest.object_request == RQ_DISABLED) {
            // Supporting RQ_DISABLED is optional
            // Disable the selected object:
            bitmapDisabled |= FBLOCK_DISABLED;
            statusOutput.disabled = 1;
            copy = TRUE;
        }
        else if (nviRequest.object_request == RQ_ENABLE) {
            // Supporting RQ_ENABLE is optional
            // Enable the object:
            bitmapDisabled &= ~FBLOCK_DISABLED;
            statusOutput.disabled = 0;
            copy = TRUE;
        }
        else {
            // Command not supported. Indicate error:
            statusOutput.invalid_request = 1;
        }

        if (copy) {
        	while (first <= last) {
                if (bitmapDisabled & FBLOCK_DISABLED) {
                    bitmapDisabled |= (FBLOCK_DISABLED << first);
                }
                else {
                    bitmapDisabled &= ~(FBLOCK_DISABLED << first);
                }
                ++ first;
            }
        }
    }
    nvoStatus = statusOutput;
}

when (nv_update_occurs(nviTempRemote))
{
	DisplayData(DataTempRemote);
    CheckForAlarms();
}

when (nv_update_occurs(nviLightRemote))
{
	DisplayData(DataLightRemote);
    CheckForAlarms();
}

when (nv_update_occurs(nciNetConfig))
{
	ProcessIsiCpUpdate();
}

#endif //_NodeObject_NC_
