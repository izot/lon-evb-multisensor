//////////////////////////////////////////////////////////////////////////////
//
// File: udp_app_msg.h
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

#define UDP_APP_MSG_CODE           0x4f
#define UDP_APP_IP_ADDR_SIZE          4

typedef struct
{
    unsigned int  address[UDP_APP_IP_ADDR_SIZE];
    unsigned long port;    // The UDP port
} UdpAppAddr ;

typedef struct UdpAppMsgHdr
{
    UdpAppAddr  source ;
    UdpAppAddr  dest ;
} UdpAppMsgHdr;



