//////////////////////////////////////////////////////////////////////////////
//
// File: Mapping.nc
//
// ECHELON MAKES NO REPRESENTATION, WARRANTY, OR CONDITION OF
// ANY KIND, EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE OR IN
// ANY COMMUNICATION WITH YOU, INCLUDING, BUT NOT LIMITED TO,
// ANY IMPLIED WARRANTIES OF MERCHANTABILITY, SATISFACTORY
// QUALITY, FITNESS FOR ANY PARTICULAR PURPOSE,
// NONINFRINGEMENT, AND THEIR EQUIVALENTS.
//
//
// Written By:
//
// Description:
//
//   This file is supplied as part of the BAClon (BACnet over LonWorks) Toolkit
//
//////////////////////////////////////////////////////////////////////////////

#include <stddef.h>
#include "mapping.h"
#include "sys\bacunits.h"

// OEM to change the following parameters to suit their needs....

// Change to suit OEM model name.

const far char *Model_Name = "FT 6050 EVB MultiSensor" ;


// This is the version of the Neuron Application, the BACnet stack version is elsewhere
// BACNET_VERSION_TEXT is not under OEM control. (It is the version of the BACnet Stack
// and it is included here just for quick reference.
// In production, the OEM should change this to reflect the version of _their_ _application_
// The stack version, and this application version, are both shown in the BACnet Device Object Properties.

const far char *Application_Software_Version = "1.0.0";


// Change this Vendor Name to match your registered Vendor Name
const far char *Vendor_Name = "Dialog Semiconductor";

// Apply for your own Vendor ID at http://goo.gl/GQKgOH
const far uint16_t Vendor_Identifier = 908;

// The following are handles for 'user defined data types', extend this list as new datatypes are required

#define LDT_SNVT_amp_ac_mil         100
#define LDT_SNVT_volt_ac            101
#define LDT_SNVT_power              102
#define LDT_SNVT_pwr_fact           103
#define LDT_SNVT_time_hour_p        104
#define LDT_SNVT_elec_kwh_l         105
#define LDT_float_to_F              106
// MRB additions
#define LDT_SNVT_angle_deg			107
#define LDT_SNVT_time_sec			108

void Create_Lon_Datatypes(void);

//---------------------------------------------------------------------------------------------------------------------------
// Global handles for Application API calls, create one for each BACnet Object you wish to use the appAPI with. (See APIdemo.nc)
// The Application API allows user programs to manipulate BACnet Objects, along with their mapped Lon Variables, whether these
// Lon Variables are Network Variables (NVs) or Ordinary Variables (OVs)
// Lon Varables can be 'simple' e.g. 'float' or 'structured' with multiple fields e.g SNVT_switch, or now, bit fields too.
// BACnet Objects are 'simple' only, and as such many of them may be mapped to a single structured Lon Variable.
// Regardless of the Lon Variable, to manipulate the BACnet value via the Application API needs one handle per BACnet Object

int8_t aoAppApiDemoHandle;
#pragma ignore_notused aoAppApiDemoHandle
int8_t boAppApiDemoHandle;
#pragma ignore_notused boAppApiDemoHandle

// StringTable.asm is used to define Object Names and Descriptions
#pragma include_assembly_file "StringTable.asm"

void Initialize_BACnet_Objects(void)
    {
    Create_Lon_Datatypes();

    // Note to users: Do not 'interleave' object definitions - group them by type.
    
    //---------------------------------------------------------------------------------------------------------------------------
    // Create Analog Input Objects
    //---------------------------------------------------------------------------------------------------------------------------   
    // Note: First parameter to Create_Analog_Input etc. is the index of the required string in StringTable.asm
    // Temp Sensor
    (void) Create_Analog_Input(0, &nvoTemperature, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_temp_p));    
    // Light Sensor
    (void) Create_Analog_Input(1, &nvoLightLevel, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_lux));    
    // Switch Blocks
    (void) Create_Analog_Input(2, &nvoSwitch[0].value, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_switch__value));
    (void) Create_Analog_Input(3, &nvoSwitch[1].value, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_switch__value));     
    // Lamp Blocks FBs
    (void) Create_Analog_Input(4, &nvoLampFb[0].value, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_switch__value)); 
    (void) Create_Analog_Input(5, &nvoLampFb[1].value, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_switch__value));
    // Joystick 
    (void) Create_Analog_Input(6, &nvoJoystick, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_angle_deg));
    
    //---------------------------------------------------------------------------------------------------------------------------
    // Create Analog Output Objects
    //---------------------------------------------------------------------------------------------------------------------------
	// Light Sensor CP
    (void) Create_Analog_Output(7, &nciLowLightAlarm, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_lux));  
    // Temp Sensor CPs  
    (void) Create_Analog_Output(8, &nciHighTempAlarm, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_temp_p));
    (void) Create_Analog_Output(9, &TempSensor::nciMaxSendTime, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_time_sec));
    // Switch Blocks FBs
    (void) Create_Analog_Output(10, &nviSwitchFb[0].value, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_switch__value));
    (void) Create_Analog_Output(11, &nviSwitchFb[1].value, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_switch__value));    
    // Lamp Blocks
    (void) Create_Analog_Output(12, &nviLamp[0].value, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_switch__value));
    (void) Create_Analog_Output(13, &nviLamp[1].value, Get_Analog_Lon_Datatype_Handle(LDT_SNVT_switch__value));

    //---------------------------------------------------------------------------------------------------------------------------
    // Create Binary Input Objects
    //---------------------------------------------------------------------------------------------------------------------------
      // Switch Blocks
    (void) Create_Binary_Input(14, &nvoSwitch[0].state, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch__state));
    (void) Create_Binary_Input(15, &nvoSwitch[1].state, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch__state)); 
    
    // Lamp Blocks FBs
    (void) Create_Binary_Input(16, &nvoLampFb[0].state, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch__state)); 
    (void) Create_Binary_Input(17, &nvoLampFb[1].state, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch__state));
    
    //---------------------------------------------------------------------------------------------------------------------------
    // Create Binary Output Objects
    //---------------------------------------------------------------------------------------------------------------------------   
    // Switch Blocks FBs
    (void) Create_Binary_Output(18, &nviSwitchFb[0].state, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch__state));
    (void) Create_Binary_Output(19, &nviSwitchFb[1].state, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch__state));  

    // Lamp Blocks
    (void) Create_Binary_Output(20, &nviLamp[0].state, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch__state));
    (void) Create_Binary_Output(21, &nviLamp[1].state, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch__state));
    
    //---------------------------------------------------------------------------------------------------------------------------
    // The following example if for a Binary Output where the user wants to manipulate the output from the Neuron Application
    // via the BacAppAPI. The handle must be saved uniquely for reference for by the API

#if ( RUN_DEMO_APP == 1 )
    boAppApiDemoHandle = Create_Binary_Output(105, &contrSNVT_sw, Get_Binary_Lon_Datatype_Handle(LDT_SNVT_switch));
    if (boAppApiDemoHandle < 0)
        {
        // this operation failed.
        }
#endif
    }


void Create_Lon_Datatype(Lon_Datatype lon_Datatype_Tag, Data_Format df, int8_t scaleFactorM, int8_t scaleFactorE, int16_t scalefactorO, ENGINEERING_UNITS units)
    {
    UserScaleFactor userScaleFactor = DefineScaleFactor(scaleFactorM, scaleFactorE, scalefactorO);
    (void) DefineAnalogSystemMappingType(lon_Datatype_Tag, df, userScaleFactor, units);
    }


// Because datatypes use up precious RAM, enable only those that you require

#define INCL_SNVT_environment       1
#define INCL_SNVT_deg_fahrenheit    1


void Create_Lon_Datatypes(void)
    {
    Create_Lon_Datatype(LDT_SNVT_amp_ac_mil, DF_ULong, 1, 0, 0, UNITS_MILLIAMPERES);
    Create_Lon_Datatype(LDT_SNVT_volt_ac, DF_ULong, 1, 0, 0, UNITS_VOLTS);
    Create_Lon_Datatype(LDT_SNVT_power, DF_ULong, 1, -1, 0, UNITS_WATTS);
    Create_Lon_Datatype(LDT_SNVT_pwr_fact, DF_SLong, 5, -5, 0, UNITS_NO_UNITS);
    Create_Lon_Datatype(LDT_SNVT_time_hour_p, DF_UQuad, 1, 0, 0, UNITS_HOURS);
    Create_Lon_Datatype(LDT_SNVT_elec_kwh_l, DF_SQuad, 1, -1, 0, UNITS_KILOWATT_HOURS);
    Create_Lon_Datatype(LDT_float_to_F, DF_Float, 1, 0, 0, UNITS_DEGREES_FAHRENHEIT);
    Create_Lon_Datatype(LDT_SNVT_angle_deg, DF_SLong, 2, -2, 0, UNITS_DEGREES_ANGULAR);
    Create_Lon_Datatype(LDT_SNVT_time_sec, DF_ULong, 1, -1, 0, UNITS_SECONDS);
    }

