//////////////////////////////////////////////////////////////////////////////
//
// File: nctypes.h
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

#include <s32.h>

typedef unsigned long uint16_t;     /* 2 bytes 0 to 65535   */
typedef unsigned int uint8_t;       /* 1 byte  0 to 255     */
typedef signed char int8_t;         /* 1 byte -127 to 127   */
typedef signed long int16_t;        /* 2 bytes -32767 to 32767 */
typedef s32_type int32_t;           /* 4 bytes -2147483647 to 2147483647, but for Neuron-C this is a structure! */

typedef struct _u32_type
{
    uint8_t bytes[4];
} u32_type;

typedef u32_type    uint32_t ;
typedef boolean pBool ;

#define u32_to_uint16(a)                s32_to_ulong ( (const s32_type *) a )

typedef uint16_t ENGINEERING_UNITS ;



