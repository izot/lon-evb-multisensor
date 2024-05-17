//////////////////////////////////////////////////////////////////////////////
// IsiImplementation.nc
//
// Implementation for all ISI related code required for an application.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// BACnet Additions 
/////////////////////////////////////////////////////////////////////////////

#define BACNET_IP
boolean check_BACnet_msg(void);

/////////////////////////////////////////////////////////////////////////////
// End of BACnet Additions
/////////////////////////////////////////////////////////////////////////////
 
    
#ifndef _Isi_NC_
#define _Isi_NC_

#include <isi.h>
#include <control.h>

#ifdef NEURON_6K_SUPPORT
// #warning "Neuron 6K target"
#	pragma library "$STD$\Isi6000.lib"
#else
// #warning "Neuron 5K target"
#   pragma library "$STD$\IsiFull.lib"
#endif

// isiState tracks the state of the ISI engine for each assembly,
// thus allowing to decide which functions to invoke in any given context.
far IsiEvent isiState;

//  isiLedState helps maintain the state of the ISI-related LEDs
far unsigned isiLedState;

static const IsiCsmoData csmoData = {
    // Define the assembly (the switch/light pair) offered by this device.
    //
    // Specify a manufacturer-specific enrollment (isiScopeManufacturer),
    // with a 9F.FF.FF manufacturer ID and a 05.01 device class, but
    // leaving the usage field blank (00) to support enrollment with
    // devices with different usage, but otherwise identical configuration.
    //
    ISI_DEFAULT_GROUP,   // group
    isiDirectionVarious, // direction
    2,                   // width
    0xFFFFul,            // profile
    95u,                 // nv type
    128u,                // variant
    {                    // extended:
        0,              // acknowledged?
        0,              // poll?
        isiScopeManufacturer,   // scope
        {               // program Id
            0x9F, 0xFF, 0xFF, 0x05, 0x01, 0x00
        },
        1               // member
    }
};

//
// Reset Processing
//
// The when(reset) task executes when the device is configured and completes a
// reset. To control the ISI engine start-up, or to prevent the ISI engine from
// starting-up, reset processing contains the following logic:
// a)	If this is the first reset with a new application image, the reset code
//		sets nciNetConfig to CFG_LOCAL. This allows the ISI engine to start on a
//		brand new device. The initial value of CFG_NUL of the local, persistent,
//		oldNwrkCnfg variable is used to detect the first start
// b) 	If nciNetConfig is set to CFG_LOCAL but the previous value is CFG_EXTERNAL
//		(determined by the tracking variable oldNwrkCnfg), the device returns itself
//		to factory defaults
// c)	If nciNetConfig is set to CFG_LOCAL, the ISI engine starts
far offchip eeprom SCPTnwrkCnfg oldNwrkCnfg = CFG_NUL;
void IsiResetProcessing(void)
{
	SCPTnwrkCnfg cpNwrkConfig;
	cpNwrkConfig = oldNwrkCnfg;
  return;  // RTG short cicuit this processing.
#ifndef DISABLE_ISI
    if (cpNwrkConfig == CFG_NUL) {
        // for the first application start, set nciNetConfig to CFG_LOCAL, thus
        // allow the ISI engine to run by default:
        NodeObject::nciNetConfig = CFG_LOCAL;
    }
#endif

    oldNwrkCnfg = NodeObject::nciNetConfig;

    if (NodeObject::nciNetConfig == CFG_LOCAL) {
        //	we are in self-installed mode:
        if (cpNwrkConfig == CFG_EXTERNAL) {
            //	The application has just returned into the self-installed environment.
            //  Make sure to re-initialize the entire ISI engine:
            // This call doesn't return and resets the device
            IsiReturnToFactoryDefaults();
        }
        //  We are in a self-installed network
        //  Start the ISI engine:
        IsiStartS(isiFlagExtended);
    }
}

void _RESIDENT IsiUpdateUserInterface(IsiEvent event, unsigned parameter)
{
    if (parameter == ISI_NO_ASSEMBLY && (event == isiNormal || event == isiCancelled)) {
        isiState = 0;
        isiLedState = 0;
    }
    else if (parameter < (unsigned)sizeof(isiState)) {
        isiState = event;
    }
}

void _RESIDENT IsiCreateCsmo(unsigned assembly, IsiCsmoData *pCsmoData)
{
    if (assembly == 0)
        memcpy(pCsmoData, &csmoData, sizeof(IsiCsmoData));
}

unsigned _RESIDENT IsiGetAssembly(const IsiCsmoData *pIn, boolean bAuto)
{
    // This application does not accept connections requiring acknowledged service or polling:
    if (!pIn->Extended.Acknowledged && !pIn->Extended.Poll) {
        if (!bAuto) {
			if (isiState == isiPendingHost || isiState == isiApprovedHost) {
                return ISI_NO_ASSEMBLY;
            }

            // Test for the different acceptable connections:
            if (memcmp(pIn, &csmoData, sizeof(IsiCsmoData)) == 0) {
                // this matches the connection advertised for a switch/light pair:
                return 0;
            }

            if (pIn->Extended.Scope == isiScopeStandard && pIn->Extended.Member == 1
                && pIn->Width == 2 && pIn->NvType == 95u) {
                if (pIn->Profile == 5  && pIn->Variant == 128u) {
                    // This is an offer made from MgLight:
                    return 0;
                }
                if (pIn->Profile == 3 && pIn->Variant == 0) {
                    // This is an offer made from MgSwitch, or any other standard SFPTclosedLoopSensor implementing SNVT_switch
                    return 0;
                }
            }
        }
    }
    return ISI_NO_ASSEMBLY;
}

unsigned _RESIDENT IsiGetNextAssembly(const IsiCsmoData *pIn, boolean bAuto, unsigned assembly)
{
    return ISI_NO_ASSEMBLY;
#pragma ignore_notused   pIn
#pragma ignore_notused   bAuto
#pragma ignore_notused   assembly
}

unsigned _RESIDENT IsiGetNvIndex(unsigned assembly, unsigned offset)
{
    if (assembly == 0) {
        return offset ? nvoSwitch[0]::global_index : nvoLampFb[0]::global_index;
    }

    return ISI_NO_INDEX;
}

unsigned _RESIDENT IsiGetNextNvIndex(unsigned assembly, unsigned offset, unsigned previousIndex)
{
    if (assembly == 0) {
        if (previousIndex == nvoSwitch[0]::global_index) {
            return nviLamp[0]::global_index;
        }
        else if (previousIndex == nvoLampFb[0]::global_index) {
            return nviSwitchFb[0]::global_index;
        }
    }
    return ISI_NO_INDEX;
#pragma ignore_notused  offset
}

void ProcessIsiCpUpdate(void)
{
	if (nciNetConfig == CFG_EXTERNAL  &&  oldNwrkCnfg != CFG_EXTERNAL) {
        // Some network tool is now managing this device.
        // It's not an ISI device anymore.
        oldNwrkCnfg = nciNetConfig;
        IsiStop();
        application_restart();
    }
    else if (nciNetConfig == CFG_LOCAL  &&  oldNwrkCnfg != CFG_LOCAL) {
        // The external tool has stopped managing the device.  Go back to the ISI mode.
        oldNwrkCnfg = nciNetConfig;
        // This call doesn't return and resets the device
        IsiReturnToFactoryDefaults();
    }
}


//  Keep the ISI engine running
mtimer repeating isiTicker = 1000ul / ISI_TICKS_PER_SECOND;

//  The device will return to factory defaults if the user activates the service pin continuously for 10 seconds
#define SERVICE_PIN_ACTIVATION  (10u*ISI_TICKS_PER_SECOND)
unsigned    servicePinActivation = 0;

// Process isiTicker timer expiration

when (timer_expires(isiTicker))
{
    // Call the ISI Tick function four times per second
    IsiTickS();

    // Drive the ISI-related LEDs
    if (IsiIsRunning()) {
	    switch(isiState) {
        case isiPending:
        case isiPendingHost:
            isiLedState = ~isiLedState;
            break;

        case isiApproved:
        case isiApprovedHost:
            isiLedState = TRUE;
            break;

        case isiImplemented:
        case isiCancelled:
        case isiDeleted:
        case isiNormal:
            isiState = isiNormal;
            isiLedState = FALSE;
            break;

        default:
            break;
	    }

	    EvalBoardSetLed(Led2, isiLedState);
	}

    // Look after the service button
    if (service_pin_state()) {
        ++servicePinActivation;
        if (servicePinActivation > SERVICE_PIN_ACTIVATION) {
            oldNwrkCnfg = NodeObject::nciNetConfig = CFG_LOCAL;
            IsiReturnToFactoryDefaults();   // never returns!
        }
    }
    else {
        servicePinActivation = 0;
    }
}

// Process incoming application messages.  Handle any ISI and BACnet FT
// messages.  Add code here to handle other application messages.

when (msg_arrives)
{
    if (IsiApproveMsg()) {
        if (IsiProcessMsgS()) {
            //  Process unprocessed ISI messages here (if any)
            ;
        }
    } else {
        // Process other application messages here (if any)
        ;
    }
    
    /////////////////////////////////////////////////////////////////////////////
    // BACnet Additions 
    /////////////////////////////////////////////////////////////////////////////
        
    #ifdef BACNET_IP
    if (check_BACnet_msg()){
        // Check_BACnet_msg() will return true if the message
        // was a BACnet message, and therefore the OEM
        // is not expected to do any more handling of the message
        return;
    }
    #endif
    // If we get here, the message was not a BACnet message, and application
    // specific handling can proceed...
    // Add OEM code here .......
    
    /////////////////////////////////////////////////////////////////////////////
    // End of BACnet Additions
    /////////////////////////////////////////////////////////////////////////////
}

void ProcessIsiLamp(unsigned nvArrayIndex)
{
	if (IsiIsRunning()) {
    	nviSwitchFb[nvArrayIndex] = nviLamp[nvArrayIndex];
		#pragma warnings_off
		#pragma relaxed_casting_on
        memcpy((void*)&nvoSwitch[nvArrayIndex], &nviLamp[nvArrayIndex], sizeof(SNVT_switch));
		#pragma relaxed_casting_off
		#pragma warnings_on
    }
}

void ProcessIsiSwitch1(void)
{
	if (IsiIsRunning()) {
    	nviLamp[0] = nvoSwitch[0];
    	nvoLampFb[0] = nviLamp[0];
        EvalBoardSetLed(Led1, nviLamp[0].state ? TRUE : FALSE);
    }
}

#define CANCEL_ENROLLMENT_TIMEOUT	8

stimer tEnrollment;
void ProcessIsiSwitch2(boolean bSwitchPressed)
{
	boolean bCancelEnrollment;
	if (IsiIsRunning()) {
    	if (bSwitchPressed) {
            // Start the enrollment timer
            tEnrollment = CANCEL_ENROLLMENT_TIMEOUT;
        }
        else {
        	bCancelEnrollment = tEnrollment ? FALSE : TRUE;

        	switch (isiState) {
	        case isiPendingHost:
	            if (bCancelEnrollment)
	                IsiCancelEnrollment();
	            break;

	        case isiPending:
	            IsiCreateEnrollment(0);
	            break;

	        case isiApprovedHost:
	            if (bCancelEnrollment)
	                IsiCancelEnrollment();
	            else
	                IsiCreateEnrollment(0);
	            break;

	        case isiApproved:
	            if (bCancelEnrollment)
	                IsiCancelEnrollment();
	            break;

	        case isiNormal:
	            if (bCancelEnrollment) {
	                /* Delete the connection */
	                IsiLeaveEnrollment(0);
	            }
	            else
	                IsiOpenEnrollment(0);
	            break;

	        default:
	            break;
		    }
        }
    }
}

// The following override allows developing and debugging of this
// application in a managed NodeBuilder development environment.
// See documentation for further, important, considerations related
// to debugging ISI-enabled devices in a managed environment, and
// regarding the IsiSetDomain override in particular.

#if defined(_DEBUG)
	void _RESIDENT IsiSetDomain(domain_struct* pDomain, unsigned Index) {
	    ;
#	pragma  ignore_notused pDomain
#	pragma  ignore_notused Index
	}
#pragma ignore_notused IsiSetDomain
#endif  // _debug

#endif // _Isi_NC_
