//////////////////////////////////////////////////////////////////////////////
//
// File: AppAPI.h
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

#ifndef APPAPI_H_
#define APPAPI_H_

#include "nctypes.h"

/*
    To use this API:

    In mappings.nc, be sure to save the handle for each BACnet Object created.
    Use this handle in the function calls below.

    Do not write directly to the nvo from your application, it will be overwritten by the BACnet PV.

    Write to the Relinquish Default instead. In the absence of any Priority Array overrides, this value will
    flow through to the PV, and thereafter to the NV.

    In the presence of any Priority Array entries, either via this API, or a BACnet write over the BACnet network,
    the Priority Array value will take precedince over the Relinquish Default.

    BACnet messages are prevented from writing to the Relinquish Default, per this design.

    Be sure to choose appropriate writes for appropriate BACnet Object types. i.e. Don't try write a float to
    a Binary Object

    */


// Set to 1 to enable a demo state machine that emulates the 'smart outputs'
#define RUN_DEMO_APP 0


// Return codes (for all functions)

typedef enum
{
    BAPI_ERR_NO_ERROR = 0,
    BAPI_ERR_INVALID_HANDLE = -1,   // Handle must be value returned when BACnet Object created in mappings.nc
    BAPI_ERR_INVALID_PRIO = -2,     // Priority not valid(1 - 5, 7 - 16)
    BAPI_ERR_INVALID_TYPE = -3,     // This operation only valid on BACnet object types AO, BO
    BAPI_ERR_NOT_NV = -4,           // Cannot attempt this operation on an "Ordinary Variable" (i.e. not a Network Variable).
    BAPI_ERR_DATA_ACCESS = -5,      // Could not access the BACnet data for some reason. Please report.
    BAPI_ERR_INVALID_SIZE = -6,     // Invalid size for a Lon variable
    BAPI_ERR_OUT_OF_MEMORY = -7,
    BAPI_ERR_PRI_ARR_NULL = -8,
    BAPI_ERR_WRITE_FAILED = -9,
} BAPI_ERR;


// Write a PV, at given priority, into the Priority Array.
BAPI_ERR BACapiWritePVsnvt(const int8_t handle, const uint8_t bac_priority, const void *snvtPtr);
BAPI_ERR BACapiWritePVfloat(const int8_t handle, const uint8_t bac_priority, float_type *tfloat);
BAPI_ERR BACapiWritePVbool(const int8_t handle, const uint8_t bac_priority, const pBool tbool);

// Write to the Relinquish Default.
BAPI_ERR BACapiWriteRDsnvt(const int8_t handle, const void *snvtPtr);
BAPI_ERR BACapiWriteRDfloat(const int8_t handle, float_type *tfloat);
BAPI_ERR BACapiWriteRDbool(const int8_t handle, const pBool tbool);


// Write a NULL to PV, at given priority.
BAPI_ERR BACapiRelinquish(const int8_t handle, const uint8_t bac_priority);


// These functions for reference/debugging only. You should not have to use them... the data
// in question (PV) should be in your Lon Variable already.

BAPI_ERR BACapiReadPVfloat(const int8_t handle, float_type *tfloat);
BAPI_ERR BACapiReadPVbool(const int8_t handle, pBool *tbool);
BAPI_ERR BACapiReadPVsnvt(const int8_t handle, void *tsnvt);
BAPI_ERR BACapiReadPAfloat(const int8_t handle, const uint8_t bac_pri, float_type *tfloat);
BAPI_ERR BACapiReadPAbool(const int8_t handle, const uint8_t bac_pri, pBool *tbool);
BAPI_ERR BACapiReadPAsnvt(const int8_t handle, const uint8_t bac_pri, void *tsnvt);
BAPI_ERR BACapiReadRDfloat(const int8_t handle, float_type *tfloat);
BAPI_ERR BACapiReadRDbool(const int8_t handle, pBool *tbool);

// This function initializes Ordinary (as opposed Network) Variables

BAPI_ERR BACapiInitOrdinaryVariable(  const void *ordinaryVariable, const uint8_t sizeofOrdinaryVariable );

void BACapiRegisterCallback(void (*callbackFunc) (const int8_t objectHandle) );

void ScaleLonToBACnet(const UserScaleFactor userScaleFactor, float_type *value);
void ScaleBACnetToLon(const UserScaleFactor scaleFactorHandle, float_type *value);

BAPI_ERR BACapiWriteCOVincrementFloat(const int8_t handle, float_type *tfloat);
BAPI_ERR BACapiWriteDeviceName(const char *newName);

#endif // APPAPI_H_