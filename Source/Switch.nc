//////////////////////////////////////////////////////////////////////////////
// Switch.nc
//
// FT 5000 and FT 6050 EVB MultiSensor Switch blocks.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _Switch_NC_
#define _Switch_NC_

// <Input NV Declaration>

network input SNVT_switch nviSwitchFb[Switch_FBLOCK_COUNT];

// <Output NV Declaration>

network output SNVT_switch nvoSwitch[Switch_FBLOCK_COUNT];

// <Block Declaration>
fblock SFPTclosedLoopSensor {
	nviSwitchFb[0] 	implements nviValueFb;
	nvoSwitch[0] 	implements nvoValue;
} Switch[Switch_FBLOCK_COUNT]
#ifdef USE_EXTERNAL_NAME
external_name("Switch")
#endif
;

// Function declarations

void ProcessIsiSwitch1(void);
void ProcessIsiSwitch2(boolean bSwitchPressed);

// Process an update to the Switch block nviSwitchFb feedback input.

when(nv_update_occurs(nviSwitchFb))
{
	if (IsEnabled(Switch[nv_array_index]::global_index))  {
		// Follow-up with local light (if application-level coupling is needed):
		if (NodeObject::nciNetConfig == CFG_LOCAL) {
        	EvalBoardSetLed(nv_array_index, nviSwitchFb[nv_array_index].state ? TRUE : FALSE);
            nviLamp[nv_array_index] = nviSwitchFb[nv_array_index];
            // Update the light output NV without propagating an NV update as described for nvoSwitch.
			#pragma disable_warning * 
			#pragma relaxed_casting_on
            memcpy((void*)&nvoLampFb[nv_array_index], &nviSwitchFb[nv_array_index], sizeof(SNVT_switch));
			#pragma relaxed_casting_off
	        #pragma enable_warning *
        }
        
        // Update the output NV, but do not propagate the new NV update. When a Neuron C application
        // assigns a value to an output network variable, this variable gets automatically flagged for
        // propagation to the network at the end of the when task (using the most recently assigned
        // value, unless the network variable is declared with 'sync' modifier). The NV is not
        // automatically scheduled for propagation when the assignment is made through a pointer
        // This code ensures the output network variable has the correct and current value without 
        // re-propagating the NV update.  This implementation assumes a star-shaped feedback layout, 
        // as opposed to a daisy chain.
		#pragma warnings_off
		#pragma relaxed_casting_on
        memcpy((void*)&nvoSwitch[nv_array_index], &nviSwitchFb[nv_array_index], sizeof(SNVT_switch));
		#pragma relaxed_casting_off
		#pragma warnings_on
	}
}

// Check the switch 1 input and handle a change to the input.

static boolean bOldSwitch1 = FALSE;
void ProcessSwitch1(void)
{
	boolean bOn;
	char string[20];

    bOn = EvalBoardGetSwitch(Switch1);
    if (bOn != bOldSwitch1) {
    	bOldSwitch1 = bOn;
    	// Act only on switch press, ignore switch release
    	if (bOn) {
    		// Toggle the state of the switch
    		nvoSwitch[0].state ^= 1;
    		nvoSwitch[0].value = nvoSwitch[0].state ? 200u : 0;

    		// Copy to feedback NV
    		nviSwitchFb[0] = nvoSwitch[0];
  		    (void)strcpy(string, "Switch 1 pressed\r\n");
			EvalBoardPrintDebug(string);
    	}
    	else {
    		(void)strcpy(string, "Switch 1 released\r\n");
			EvalBoardPrintDebug(string);
    	}

    	// Do ISI specific processing
    	ProcessIsiSwitch1();
    }
}

// Check the switch 2 input and handle a change to the input.

static boolean bOldSwitch2 = FALSE;
void ProcessSwitch2(void)
{
	boolean bOn;
	char string[20];

    bOn = EvalBoardGetSwitch(Switch2);
    if (bOn != bOldSwitch2) {
    	bOldSwitch2 = bOn;
    	// Act only on switch press, ignore switch release
    	if (bOn) {
    		// Toggle the state of the switch
    		nvoSwitch[1].state ^= 1;
    		nvoSwitch[1].value = nvoSwitch[1].state ? 200u : 0;

    		// Copy to feedback NV
    		nviSwitchFb[1] = nvoSwitch[1];
    		(void)strcpy(string, "Switch 2 pressed\r\n");
			EvalBoardPrintDebug(string);
    	}
    	else {
    		(void)strcpy(string, "Switch 2 released\r\n");
			EvalBoardPrintDebug(string);
    	}

    	// Do ISI specific processing
    	ProcessIsiSwitch2(bOn);
    }
}

#endif //  _Switch_NC_
