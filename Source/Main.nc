//////////////////////////////////////////////////////////////////////////////
// Main.nc
//
// FT 5000 and FT 6050 EVB MultiSensor main Neuron C source file.  Contains
// system tasks such as the when(reset) task, file directory declaration, 
// and Neuron C file references.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _Main_NC_
#define _Main_NC_

// Using LonMark Guidelines version 3.4

#pragma set_guidelines_version "3.4"

// Configuration properties (CP) storage.  Specify the CP_STORAGE and 
// CP_CONST_STORAGE macros to support CP storage in files.  The CP template file is
// always considered 'const' and will be linked into the CP_CONST_STORAGE segment.

#define CP_STORAGE far offchip eeprom
#define CP_CONST_STORAGE far offchip eeprom

// <CP Access>

#define _USE_DIRECT_CPARAMS_ACCESS

// <External Name>

#define USE_EXTERNAL_NAME

// <Block Counts>

#define NodeObject_FBLOCK_COUNT 	1
#define Lamp_FBLOCK_COUNT 			2
#define Switch_FBLOCK_COUNT 		2
#define LightSensor_FBLOCK_COUNT 	1
#define TempSensor_FBLOCK_COUNT 	1
#define Joystick_FBLOCK_COUNT 		1

// <Total Block Count>

#define TOTAL_FBLOCK_COUNT 	NodeObject_FBLOCK_COUNT +\
							Lamp_FBLOCK_COUNT +\
							Switch_FBLOCK_COUNT +\
							LightSensor_FBLOCK_COUNT +\
							TempSensor_FBLOCK_COUNT +\
							Joystick_FBLOCK_COUNT

// The file directory has the template file, the value file, and the constant 
// value file by default.  If you add user-defined files, adjust NUM_FILES
// and the file directory (see filesys.nct). Refer to filesys.* and 
// filexfer.* files for more details about user-defined files.

#define NUM_FILES 3

// Enable the NV length override system extension callback function for
// changeable NV type support.

#pragma system_image_extensions nv_length_override

// Enable the same code to be built for targets that do support the callback 
// technique (requires Neuron firmware version 14 or better), as well as for 
// those that don't support that technique. 

#pragma unknown_system_image_extension_isa_warning

#pragma run_unconfigured

#define EVALBOARD_USE_SWITCHES
#define EVALBOARD_USE_LEDS
#define EVALBOARD_USE_LCD
#define EVALBOARD_USE_JOYSTICK
#define EVALBOARD_USE_TEMPSENSOR
#define EVALBOARD_USE_LIGHTSENSOR
#define EVALBOARD_USE_SERIALDEBUG

// Header files

#include "fileSys.h"
#include "EvalBoard.h"
#include <isi.h>
#include "LCD.h"

// Function declarations

void CheckForAlarms(void);

// Global variables

far char VersionString[20];

// FileDirectory declaration. See filexfer.h and filesys.h for more details about
// the implementation of the file system and the LON file transfer protocol.

#ifndef _USE_NO_CPARAMS_ACCESS
	DIRECTORY_STORAGE TFileDirectory FileDirectory = {
    	FILE_DIRECTORY_VERSION,   // major and minor version number (one byte)
	    NUM_FILES, {
	#ifdef _USE_DIRECT_CPARAMS_ACCESS
			{ cp_template_file_len,         TEMPLATE_TYPE,	cp_template_file },
			{ cp_modifiable_value_file_len, VALUE_TYPE,		cp_modifiable_value_file },
			{ cp_readonly_value_file_len,   VALUE_TYPE,		cp_readonly_value_file   }
	#else	// def. _USE_FTP_CPARAMS_ACCESS
			{ NULL_INFO, { 0ul, cp_template_file_len	},		TEMPLATE_TYPE, 	cp_template_file },
			{ NULL_INFO, { 0ul, cp_modifiable_value_file_len },	VALUE_TYPE, 	cp_modifiable_value_file },
			{ NULL_INFO, { 0ul, cp_readonly_value_file_len },	VALUE_TYPE,		cp_readonly_value_file }
	#endif	// def. _USE_DIRECT_CPARAMS_ACCESS
		}
	};
#endif // def. _USE_NO_CPARAMS_ACCESS

// Source Files

#include "NodeObject.nc"
#include "Lamp.nc"
#include "Switch.nc"
#include "LightSensor.nc"
#include "TempSensor.nc"
#include "Joystick.nc"
#include "EvalBoard.nc"
#include "IsiImplementation.nc"
#include "LCD.nc"

/////////////////////////////////////////////////////////////////////////////
// BACnet FT Additions 1
/////////////////////////////////////////////////////////////////////////////

// Set up buffers
#pragma app_buf_out_count          1
#pragma app_buf_out_priority_count 0
#pragma app_buf_in_count           3
#pragma net_buf_out_priority_count 0
#pragma net_buf_in_count           3
#pragma net_buf_out_count          1
#pragma app_buf_out_size           255
#pragma app_buf_in_size            255
#pragma net_buf_out_size           255
#pragma net_buf_in_size            255

// Includes
#include "baclon.h"
#include <status.h>
#define BACNET_IP

// BACnet initialization
//
// The BACnet FT library uses two types of heap memory. These private heaps reside inside a large static array called 
// bacnetStaticMemory which must be sized according to the user application. 5000 bytes is a good start.
// Within that static array, a second heap is defined for dynamic use (message buffers, working data structures etc.).
// The Neuron stack is only 256 bytes so we had to offload temp variables/structures elsewhere.  The dynamic heap size 
// has to be a power of 2 due to the implementation that ensures it never fragments (Buddy Memory System, Knuth).

// Dynamic heap size factors

#define EMM_DYN_HEAP_1K       8
#define EMM_DYN_HEAP_2K       9
#define EMM_DYN_HEAP_4K       10
#define EMM_DYN_HEAP_8K       11

// Static heap size (which needs to be large enough to contain the dynamic heap, plus spare)
// If this is too small, the Neuron will immediately reset with an "Applicaton Error: 101" in the "Last error logged" 
// variable.
far uint8_t     bacnetStaticMemory[5000];

// There is a global, public variable 'bacnetUsedMemory' that can be located in the map file, and observed using
// Nodeutil, that indicates how much memory we end up using so that the static memory size can be adjusted if necessary.

BACNET_INIT_RETURN_CODE init_BACnet_transient(void)
{
    // BACnet Initialization function called from when(reset) to offload as much as possible to transient code space

    BACNET_INIT_RETURN_CODE rc;
    // status_struct status;

    (void) emm_init(
        EMM_DYN_HEAP_2K,
        bacnetStaticMemory,
        sizeof bacnetStaticMemory
        );

    // Initialize the rest of BACnet, with incoming queue size (for both protocols), outgoing queue size

    rc = init_BACnet(
                    4,  // Max incoming BACnet packet queue, both Lon packets, and MS/TP (if enabled)
                    2   // Max outgoing BACnet packet queue
                    );

    if (rc != BI_OK)
        {
        // OEM to place code here if desired....
        return rc;
        }
    // This function has been moved here so that the user can create
    // a set of optional Object Lists to be called to e.g. change a 
    // Device's profile during runtime
    Initialize_BACnet_Objects();

    return rc;
}
/////////////////////////////////////////////////////////////////////////////
// End of BACnet FT Additions 1
/////////////////////////////////////////////////////////////////////////////

// Process reset

when (reset)
{
	char string[5];
	char *pStr;
	int i;

	(void)strcpy(VersionString, "Device Reset\r\n");
	EvalBoardPrintDebug(VersionString);
	(void)strcpy(VersionString, "Version ");

	pStr = itoa(NodeObject::nciDevMajVer, 10);
	(void)strcat(VersionString, pStr);
	(void)strcat(VersionString, ".");
	pStr = itoa(NodeObject::nciDevMinVer, 10);
	(void)strcat(VersionString, pStr);
	(void)strcat(VersionString, ".");
	pStr = itoa(BUILD_NUM, 10);
	(void)strcat(VersionString, pStr);
	EvalBoardPrintDebug(VersionString);
	(void)strcpy(string, "\r\n");
	EvalBoardPrintDebug(string);

	IsiResetProcessing();
	EvalBoardReset();
	ProcessJoystick();
	InitializeLamp(Led1);
	InitializeLamp(Led2);
	MoveToWelcomeMode();
	
	// Show welcome message for 3 seconds
	for (i = 0; i < 30; i++) {
		msec_delay(100);
		watchdog_update();
	}
	
	MoveToStatusMode();
	heartbeat = TempSensor::nciMaxSendTime;
	
    /////////////////////////////////////////////////////////////////////////////
    // BACnet FT Additions 2
    /////////////////////////////////////////////////////////////////////////////
    // Initialize BACnet
    if (init_BACnet_transient() != BI_OK){
        // If init_BACnet() fails, an internal flag will be set and no further 
        // BACnet processing will occur.  init_BACnet() returns 0 if all OK, or 
        // an error code if there is a failure.  Place code here to handle the 
        // failed startup condition if desired
    }
    /////////////////////////////////////////////////////////////////////////////
    // End of BACnet FT Additions 2
    /////////////////////////////////////////////////////////////////////////////
 }
 
/////////////////////////////////////////////////////////////////////////////
// BACnet FT Additions 3
/////////////////////////////////////////////////////////////////////////////

// Set up background processing

#define MS_TICK 5
mtimer repeating msTimer = MS_TICK;
uint16_t msTimerCounter;
uint8_t startUpStateMachine;
#pragma ignore_notused startUpStateMachine

when(timer_expires(msTimer))    
{
    msTimerCounter++;
    Process_Incoming_BACnet();
    Process_Outgoing_BACnet();
    // COV handling
    if (!(msTimerCounter % (1000 / MS_TICK)))
        {
        // every second...
        handler_cov_timer_second();
        tsm_timer_second();
        }
    handler_cov_task();
}

/////////////////////////////////////////////////////////////////////////////
// End of BACnet FT Additions 3
/////////////////////////////////////////////////////////////////////////////

// Get the NV length override value.

unsigned _RESIDENT get_nv_length_override(unsigned nvIndex)
{
#ifdef _SUPPORT_LARGE_NV
	unsigned uResult = get_declared_nv_length(nvIndex);
#else
	unsigned uResult = 0xFF;
#endif

	switch (nvIndex) {
	case nvoJoystick::global_index:
    	uResult = nvoJoystick::cpStickNvType.type_length;
        break;
    default:
    	break;
	}

	return uResult;
}

//  Periodic sampling of all inputs.

#define TICKS_PER_SECOND 50u
mtimer repeating tTick = 1000ul / TICKS_PER_SECOND;
far unsigned OneSec = TICKS_PER_SECOND;

when(timer_expires(tTick))
{
	char string[24];
	static int count = 0;
	static boolean startup = TRUE;
	
	// Print debug progress dots on startup to confirm timer operation
   	if (startup) {
   	    (void)strcpy(string, ".");
   	    EvalBoardPrintDebug(string);
	
        if (count++ > 50) {
            (void)strcpy(string, "\r\n");
            EvalBoardPrintDebug(string);
            startup = FALSE;
        }
   	}

    // Process Switches and joystick every millisecond
    ProcessSwitch1();
    ProcessSwitch2();
    ProcessJoystick();

    // Process heartbeats, temperature sensor and light level sensor every second
    if (--OneSec == 0) {
        OneSec = TICKS_PER_SECOND;
        ProcessHeartbeats();
        ProcessTemperatureSensor();
        ProcessLightSensor();
    }
}

// Check for light level and temperature alarms.

void CheckForAlarms(void)
{
	int alarmType;
	char description[20];

	alarmType = 0;
	if ((nvoLightLevel <= nciLowLightAlarm) || (is_bound(nviLightRemote) && (nviLightRemote <= nciLowLightAlarm))) {
		alarmType = 1;
	}
	if ((nvoTemperature >= nciHighTempAlarm) || (is_bound(nviTempRemote) && (nviTempRemote >= nciHighTempAlarm))) {
		alarmType += 2;
	}
	
	switch (alarmType) {
	case 1:
		(void)strcpy(description, "Light");
		break;
	case 2:
		(void)strcpy(description, "Temp");
		break;
	case 3:
		(void)strcpy(description, "Light & Temp");
		break;
	case 0:
	default:
		(void)strcpy(description, "None");
		break;
	}

	if (alarmType) {
		nvoAlarm.alarm_type = AL_ALM_CONDITION;
		nvoAlarm.priority_level = PR_LEVEL_1;
	} else {
		nvoAlarm.alarm_type = AL_NO_CONDITION;
		nvoAlarm.priority_level = PR_NUL;
	}

	#pragma warnings_off
	#pragma relaxed_casting_on
	(void)strcpy((char*)nvoAlarm.description, description);
	#pragma relaxed_casting_off
	#pragma warnings_on
	DisplayData(DataAlarm);
}


#endif // _Main_NC_
