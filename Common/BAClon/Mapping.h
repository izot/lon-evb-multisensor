//////////////////////////////////////////////////////////////////////////////
//
// File: Mapping.h
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

#pragma once

#include "sys\blonsys.h"

#define SF_None 255

typedef int16_t Analog_Mapping_Type_Handle;
typedef int16_t Binary_Mapping_Type_Handle;

void Initialize_BACnet_Objects(void);

int8_t Create_Analog_Input(const uint8_t objectNameStringIndex, const void *networkVariable, const Analog_Mapping_Type_Handle mth);
int8_t Create_Binary_Input(const uint8_t objectNameStringIndex, const void *NetworkVariable, const Binary_Mapping_Type_Handle mth);

int8_t Create_Analog_Output(const uint8_t objectNameStringIndex, const void *networkVariable, const Analog_Mapping_Type_Handle mth);
int8_t Create_Binary_Output(const uint8_t objectNameStringIndex, const void *NetworkVariable, const Binary_Mapping_Type_Handle mth);

UserScaleFactor DefineScaleFactor(int8_t multiplier, int8_t exponent, int16_t offset);
UserScaleFactor DefineHiResScaleFactor(float_type *multiplier, int8_t exponent, float_type *offset);
#pragma ignore_notused DefineHiResScaleFactor

Analog_Mapping_Type_Handle Get_Analog_Lon_Datatype_Handle(Lon_Datatype amt);
Binary_Mapping_Type_Handle Get_Binary_Lon_Datatype_Handle(Lon_Datatype bmt);
Binary_Mapping_Type_Handle Get_Binary_Lon_Datatype_Handle_8bit(uint8_t offset);
#pragma ignore_notused Get_Binary_Lon_Datatype_Handle_8bit
Binary_Mapping_Type_Handle Get_Binary_Lon_Datatype_Handle_16bit(uint8_t offset);
#pragma ignore_notused Get_Binary_Lon_Datatype_Handle_16bit

Analog_Mapping_Type_Handle DefineAnalogSystemMappingType(Lon_Datatype systemMappingType, Data_Format dataFormat, UserScaleFactor userScaleFactor, ENGINEERING_UNITS units);
