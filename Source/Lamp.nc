//////////////////////////////////////////////////////////////////////////////
// Lamp.nc
//
// FT 5000 and FT 6050 EVB MultiSensor Lamp blocks.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _Lamp_NC_
#define _Lamp_NC_

#include <control.h>
#include <mem.h>
#include <snvt_nvt.h>

#define INDEX_SNVT_SWITCH 95

// <CP Declarations>

network input cp SCPTdefOutput cpLampDefault[Lamp_FBLOCK_COUNT];

// <Input NV Declarations>

network input SNVT_switch nviLamp[Lamp_FBLOCK_COUNT];

// <Output NV Declarations>

network output SNVT_switch bind_info(unackd) nvoLampFb[Lamp_FBLOCK_COUNT];

// <Block Declaration>

fblock SFPTclosedLoopActuator {
	nviLamp[0]   implements nviValue;
	nvoLampFb[0] implements nvoValueFb;
} Lamp[Lamp_FBLOCK_COUNT]
#ifdef USE_EXTERNAL_NAME
external_name("Lamp")
#endif
	fb_properties {
		cpLampDefault[0] = {0, 0}
	};

// Function declarations

void InitializeLamp(unsigned int lamp);
void ProcessIsiLamp(unsigned nvArrayIndex); // There is no Lamp block specific ISI processing.
void UpdateLamp(unsigned int lamp);

// Process an update to the Lamp block input.

when(nv_update_occurs(nviLamp))
{
	char string[24];
	
   	(void)strcpy(string, "Received lamp update\r\n");
	EvalBoardPrintDebug(string);
	
	if (IsEnabled(Lamp[nv_array_index]::global_index)) {
		if(memcmp(&nviLamp[nv_array_index], &nvoLampFb[nv_array_index], sizeof(SNVT_switch)))  {
			UpdateLamp(nv_array_index);
        }
	}
}

// Process an NV type change for the Lamp block.

when(nv_update_occurs(cpLampDefault))
{
	char string[24];
	
   	(void)strcpy(string, "Received lamp default\r\n");
	EvalBoardPrintDebug(string);
	
	InitializeLamp(nv_array_index);
}

// Blink the LEDs to help the user identify a particular EvbMultiSensor board.

when (wink) {
	int i;
	for (i = 0; i < 20; i++) {
		EvalBoardSetLed(Led1, (boolean)(i % 2));
		EvalBoardSetLed(Led2, !(boolean)(i % 2));
		msec_delay(250U);
		watchdog_update();
	}	
	EvalBoardSetLed(Led1, nviLamp[0].state && nviLamp[0].value ? TRUE : FALSE);
	EvalBoardSetLed(Led2, nviLamp[1].state && nviLamp[1].value ? TRUE : FALSE);
}

// Set the Lamp block input and the LED for a specified lamp to the configured default value.

void InitializeLamp(unsigned int lamp) 
{
	nviLamp[lamp].state = Lamp[lamp]::cpLampDefault.state;
	nviLamp[lamp].value = Lamp[lamp]::cpLampDefault.value;
	UpdateLamp(lamp);
//	EvalBoardSetLed(lamp, nviLamp[lamp].state && nviLamp[lamp].value ? TRUE : FALSE);
}

// Update lamp state and feedback output based on the lamp input NV

void UpdateLamp(unsigned int lamp)
{
	char string[24];
	
    // Set the LED according to the state of the NV
    EvalBoardSetLed(lamp, nviLamp[lamp].state && nviLamp[lamp].value ? TRUE : FALSE);

    // Copy to feedback NV
    nvoLampFb[lamp] = nviLamp[lamp];

    // Do ISI specific processing
    ProcessIsiLamp(lamp);

    // Print debug information
    (void)strcpy(string, "Lamp ");
    lamp ? (void) strcat(string, "2 ") : (void) strcat(string, "1 ");
    nviLamp[lamp].state && nviLamp[lamp].value ? (void) strcat(string, "On\r\n") : (void) strcat(string, "Off\r\n");
    EvalBoardPrintDebug(string);
}

#endif //  _Lamp_NC_
