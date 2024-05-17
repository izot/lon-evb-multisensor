//////////////////////////////////////////////////////////////////////////////
// Joystick.nc
//
// FT 5000 and FT 6050 EVB Evaluation Board Joystick block.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _Joystick_NC_
#define _Joystick_NC_

#define INDEX_SNVT_SWITCH       95
#define INDEX_SNVT_ANGLE_DEG	104

#define ANGLE_MULTIPLIER        90
#define ANGLE_SCALE             50

#include <snvt_nvt.h>

// <CP Declarations>

network input cp cp_info(device_specific) SCPTnvType cpStickNvType;
network input cp SCPTdefOutput cpStickDefault;

// <Output NV Declarations>

network output changeable_type SNVT_angle_deg nvoJoystick = -50
nv_properties {
    cpStickNvType = {{0, 0, 0, 0, 0, 0, 0, 0}, 0, INDEX_SNVT_ANGLE_DEG, NVT_CAT_INITIAL, 2, 2, -2, 0},
    cpStickDefault = -50
};

// Disable inherited profile warning

#pragma disable_warning 486

// <Block Declaration>

fblock UFPTopenLoopSensor {
	nvoJoystick implements nvoValue;
} Joystick
#ifdef USE_EXTERNAL_NAME
external_name("Joystick")
#endif
;

// Function declarations

void StoreRawValueInSwitch(void);
void StoreRawValueInAngle(void);
void ProcessJoystick(void);
void ProcessTypeChange(void);

// Shared local variables

static JoystickDirection oldDirection = JoystickInvalid;
static SCPTnvType cpStickNvTypeLastKnownGoodValue = {{0, 0, 0, 0, 0, 0, 0, 0}, 0, INDEX_SNVT_ANGLE_DEG, NVT_CAT_INITIAL, 2, 2, -2, 0};

// Process a change to the nvoJoystick NV type CP

when (nv_update_occurs(cpStickNvType))
{
	// If functional block isn't disabled, process type change
	if (IsEnabled(Joystick::global_index)) {
		oldDirection = JoystickInvalid;
		ProcessTypeChange();
		ProcessJoystick();
	}
}

// Process a change to the nvoJoystick default output CP

when (nv_update_occurs(cpStickDefault))
{
	// If functional block isn't disabled, process the default output change
	if (IsEnabled(Joystick::global_index)) {
		oldDirection = JoystickInvalid;
		ProcessJoystick();
	}
}

// Read and process the current joystick position

void ProcessJoystick(void)
{
    char string[20];
    JoystickDirection direction;
    
    direction = EvalBoardGetJoystick();
    if (direction != oldDirection) {
        (void)strcpy(string, "Joystick updated\r\n");
        EvalBoardPrintDebug(string);
		oldDirection = direction;
    	if (nvoJoystick::cpStickNvType.type_index == INDEX_SNVT_SWITCH)
    		StoreRawValueInSwitch();
    	else
    		StoreRawValueInAngle();

		switch (direction) {
		case JoystickCenter:
			(void)strcpy(string, "Joystick center\r\n");
			break;

		case JoystickUp:
			(void)strcpy(string, "Joystick up\r\n");
			break;

		case JoystickLeft:
			(void)strcpy(string, "Joystick left\r\n");
			break;

		case JoystickDown:
			(void)strcpy(string, "Joystick down\r\n");
			break;

		case JoystickRight:
			(void)strcpy(string, "Joystick right\r\n");
			break;
			
		case JoystickNone:
			(void)strcpy(string, "Joystick off\r\n");
			break;
			
		default:
			(void)strcpy(string, "Joystick invalid\r\n");
		}
		EvalBoardPrintDebug(string);
		DriveLCD(direction);
	}
}

// Update the nvoJoystick output NV with the current joystick position in degrees.

void StoreRawValueInAngle(void)
{
    char string[25];
    s32_type defaultValue, directionValue, joystickValue;

	JoystickDirection direction;
	direction = EvalBoardGetJoystick();
	nvoJoystick = (direction == JoystickNone)
		? nvoJoystick::cpStickDefault & 0xFFFF
		: ((signed long) direction) * ANGLE_MULTIPLIER * ANGLE_SCALE;

    (void)strcpy(string, "Updated joystick angle\r\n");
    EvalBoardPrintDebug(string);
    
    (void)strcpy(string, "Direction: ");
    s32_from_slong(direction, &directionValue);
    s32_to_ascii(&directionValue, string + strlen(string));
    (void) strcat(string, "\r\n");
    EvalBoardPrintDebug(string);

	if (direction == JoystickNone) {
        (void)strcpy(string, "Default CP: ");
        s32_from_slong(nvoJoystick::cpStickDefault, &defaultValue);
        s32_to_ascii(&defaultValue, string + strlen(string));
        (void) strcat(string, "\r\n");
        EvalBoardPrintDebug(string);
    }

    (void)strcpy(string, "Angle: ");
    s32_from_slong(nvoJoystick, &joystickValue);
    s32_to_ascii(&joystickValue, string + strlen(string));
    (void) strcat(string, "\r\n");
    EvalBoardPrintDebug(string);
}

// Update the nvoJoystick output NV with the current joystick position as a scaled raw value.

void StoreRawValueInSwitch(void)
{
    char string[25];
    s32_type defaultValue, directionValue, joystickValue;

	SNVT_switch sw;
	JoystickDirection direction;
	direction = EvalBoardGetJoystick();
   	#pragma relaxed_casting_on
	#pragma warnings_off
	sw.state = (direction == JoystickNone) ? 0 : 1;
   	sw.value = (direction == JoystickNone) ? nvoJoystick::cpStickDefault & 0xFF : direction;
    *((SNVT_switch*) &nvoJoystick) = sw;
	#pragma relaxed_casting_off
	#pragma warnings_on
	propagate(nvoJoystick);
    (void)strcpy(string, "Updated joystick raw\r\n");
    EvalBoardPrintDebug(string);
    
    (void)strcpy(string, "Direction: ");
    s32_from_slong(direction, &directionValue);
    s32_to_ascii(&directionValue, string + strlen(string));
    (void) strcat(string, "\r\n");
    EvalBoardPrintDebug(string);

	if (direction == JoystickNone) {
        (void)strcpy(string, "Default CP: ");
        s32_from_slong(nvoJoystick::cpStickDefault, &defaultValue);
        s32_to_ascii(&defaultValue, string + strlen(string));
        (void) strcat(string, "\r\n");
        EvalBoardPrintDebug(string);
    }

    (void)strcpy(string, "Raw: ");
    s32_from_slong(nvoJoystick, &joystickValue);
    s32_to_ascii(&joystickValue, string + strlen(string));
    (void) strcat(string, "\r\n");
    EvalBoardPrintDebug(string);
}

// Process a change to the nvoJoystick NV type

void ProcessTypeChange(void)
{
    boolean bAcceptChange;
    unsigned long newTypeIndex;
    SCPTnvType cpStickNvTypeLocal;
    SNVT_obj_status statusOutput;
	char string[24];
	
    bAcceptChange = FALSE;
    newTypeIndex = INDEX_SNVT_ANGLE_DEG;

    // Copy the input nv locally as it is volatile
    cpStickNvTypeLocal = cpStickNvType;

    if (memcmp((void *)&cpStickNvTypeLocal, &cpStickNvTypeLastKnownGoodValue, sizeof(cpStickNvType)) != 0) {
        // A change has been requested; verify it is valid
        if (cpStickNvTypeLocal.type_category == NVT_CAT_INITIAL) {
        	// Assign default type
            newTypeIndex = INDEX_SNVT_ANGLE_DEG;
            bAcceptChange = TRUE;
        }
        else if (((cpStickNvTypeLocal.type_category >= NVT_CAT_SIGNED_CHAR  &&
                 cpStickNvTypeLocal.type_category <= NVT_CAT_UNSIGNED_LONG) // All scalar types
                 || cpStickNvTypeLocal.type_category == NVT_CAT_STRUCT) 	// SNVT_switch is struct
                 &&  cpStickNvTypeLocal.type_scope == 0) {					// type_index is a SNVT index
            newTypeIndex = cpStickNvTypeLocal.type_index;
            if (newTypeIndex == INDEX_SNVT_SWITCH || newTypeIndex == INDEX_SNVT_ANGLE_DEG)
                bAcceptChange = TRUE;
        }
    }

	memset(&statusOutput, 0, sizeof(SNVT_obj_status));
    if (bAcceptChange) {
    	// Update the status in the Node Object block
    	statusOutput.object_id = Joystick::global_index;
    	statusOutput.invalid_request = 0;

        // Change the values
        (void)strcpy(string, "Joystick out is ");
        if (cpStickNvTypeLastKnownGoodValue.type_index == INDEX_SNVT_SWITCH && newTypeIndex == INDEX_SNVT_ANGLE_DEG) {
            // Change raw value from INDEX_SNVT_SWITCH to INDEX_SNVT_ANGLE_DEG
            StoreRawValueInAngle();
            (void) strcat(string, "angle\r\n");
            EvalBoardPrintDebug(string);
        }
        else if (cpStickNvTypeLastKnownGoodValue.type_index == INDEX_SNVT_ANGLE_DEG && newTypeIndex == INDEX_SNVT_SWITCH) {
            // Change from INDEX_SNVT_ANGLE_DEG to INDEX_SNVT_SWITCH
        	StoreRawValueInSwitch();
            (void) strcat(string, "raw\r\n");
            EvalBoardPrintDebug(string);
        }

        // Store the new CP information
        cpStickNvTypeLastKnownGoodValue = cpStickNvTypeLocal;
        cpStickNvTypeLastKnownGoodValue.type_index = newTypeIndex;
        cpStickNvType = cpStickNvTypeLastKnownGoodValue;
    }
    else {
    	// Invalid type.  Set the CP back to the last known good value.
        cpStickNvType = cpStickNvTypeLastKnownGoodValue;
        // Reject the unsupported type change
        // update the status in the node object
    	statusOutput.object_id = Joystick::global_index;
    	statusOutput.invalid_request = 1;
    	statusOutput.disabled = 1;
    	bitmapDisabled |= (FBLOCK_DISABLED << Joystick::global_index);
    }
    nvoStatus = statusOutput;
}

#endif //  _Joystick_NC_
