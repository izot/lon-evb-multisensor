//////////////////////////////////////////////////////////////////////////////
//
// File: blonsys.h
//
// ECHELON MAKES NO REPRESENTATION, WARRANTY, OR CONDITION OF
// ANY KIND, EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE OR IN
// ANY COMMUNICATION WITH YOU, INCLUDING, BUT NOT LIMITED TO,
// ANY IMPLIED WARRANTIES OF MERCHANTABILITY, SATISFACTORY
// QUALITY, FITNESS FOR ANY PARTICULAR PURPOSE,
// NONINFRINGEMENT, AND THEIR EQUIVALENTS.
//
// Written By:
//
// Description:
//
//   This file is supplied as part of the BAClon (BACnet over LonWorks) Toolkit
//   It contains declarations that have to be shared between the BAClon toolkit
//   and the BACnet library
//
//////////////////////////////////////////////////////////////////////////////

#pragma once

#include <float.h>
#include <io_types.h>
#include "bacunits.h"
#include "nctypes.h"

typedef enum
    {
        BI_OK=0,
        BI_MSTP_QUEUE_SIZE,
        BI_MEM_SIZE,
        BI_RINGBUF_INIT_PARAMETER,
        BI_RINGBUF_ELEMENTS,                // Attempt to initialize a ringbuffer with too many elements - 32 max
        BI_RINGBUF_SIZE,                    // Attempt to initialize a ringbuffer with too many elements - 32 bytes max
        BI_EMM_FAIL,                        // Failed to allocate EMM memory
    } BACNET_INIT_RETURN_CODE ;

#define BVLL_TYPE_BACNET_IP                 0x81
#define BVLC_ORIGINAL_UNICAST_NPDU_CODE     10
#define BVLC_ORIGINAL_BROADCAST_NPDU_CODE   11


typedef enum {
    MIN_BINARY_PV = 0,  /* for validating incoming values */
    BINARY_INACTIVE = 0,
    BINARY_ACTIVE = 1,
    MAX_BINARY_PV = 1,  /* for validating incoming values */
    BINARY_NULL = 127   /* our homemade way of storing this info */
} BACNET_BINARY_PV;

typedef enum {
    RELIABILITY_NO_FAULT_DETECTED = 0,
    RELIABILITY_NO_SENSOR = 1,
    RELIABILITY_OVER_RANGE = 2,
    RELIABILITY_UNDER_RANGE = 3,
    RELIABILITY_OPEN_LOOP = 4,
    RELIABILITY_SHORTED_LOOP = 5,
    RELIABILITY_NO_OUTPUT = 6,
    RELIABILITY_UNRELIABLE_OTHER = 7,
    RELIABILITY_PROCESS_ERROR = 8,
    RELIABILITY_MULTI_STATE_FAULT = 9,
    RELIABILITY_CONFIGURATION_ERROR = 10,
    RELIABILITY_MEMBER_FAULT = 11,
    RELIABILITY_COMMUNICATION_FAILURE = 12,
    RELIABILITY_TRIPPED = 13
    /* Enumerated values 0-63 are reserved for definition by ASHRAE.  */
    /* Enumerated values 64-65535 may be used by others subject to  */
    /* the procedures and constraints described in Clause 23. */
} BACNET_RELIABILITY;

/*Network Layer Message Type */
/*If Bit 7 of the control octet described in 6.2.2 is 1, */
/* a message type octet shall be present as shown in Figure 6-1. */
/* The following message types are indicated: */
typedef enum {
    NETWORK_MESSAGE_WHO_IS_ROUTER_TO_NETWORK = 0,
    NETWORK_MESSAGE_I_AM_ROUTER_TO_NETWORK = 1,
    NETWORK_MESSAGE_I_COULD_BE_ROUTER_TO_NETWORK = 2,
    NETWORK_MESSAGE_REJECT_MESSAGE_TO_NETWORK = 3,
    NETWORK_MESSAGE_ROUTER_BUSY_TO_NETWORK = 4,
    NETWORK_MESSAGE_ROUTER_AVAILABLE_TO_NETWORK = 5,
    NETWORK_MESSAGE_INIT_RT_TABLE = 6,
    NETWORK_MESSAGE_INIT_RT_TABLE_ACK = 7,
    NETWORK_MESSAGE_ESTABLISH_CONNECTION_TO_NETWORK = 8,
    NETWORK_MESSAGE_DISCONNECT_CONNECTION_TO_NETWORK = 9,
    NETWORK_MESSAGE_WHAT_IS_NETWORK_NUMBER = 0x12,
    NETWORK_MESSAGE_NETWORK_NUMBER_IS = 0x13,

    /* X'0A' to X'7F': Reserved for use by ASHRAE, */
    /* X'80' to X'FF': Available for vendor proprietary messages */
    // we cannot use 0x100 for 8-bitters, and the use of INVALID was optional... so deleting.
    NETWORK_MESSAGE_LAST_RESERVED = 0x7f    // and messages after this are vendor types. Using 0x7f so we can use 8-bit int enums.
} BACNET_NETWORK_MESSAGE_TYPE;

typedef enum {
    MESSAGE_PRIORITY_NORMAL = 0,
    MESSAGE_PRIORITY_URGENT = 1,
    MESSAGE_PRIORITY_CRITICAL_EQUIPMENT = 2,
    MESSAGE_PRIORITY_LIFE_SAFETY = 3
} BACNET_MESSAGE_PRIORITY;

#define BACNET_MAX_PRIORITY         16u

typedef enum
{
    CBO_AI,             // Do not change the order of these, the order is used elsewhere
    CBO_BI,
    CBO_AO,
    CBO_BO,
    CBO_MSI,
    CBO_MSO,
    CBO_Device          // leave the Device last, it is used as a marker elsewhere
} COMPACT_BAC_TYPE;

typedef enum
{
    mapFuncAnalogToSLong = 1,
    mapFuncAnalogToSLongF,
    mapFuncAnalogToULong,
    mapFuncAnalogToSShort,
    mapFuncAnalogToUShort,
    mapFuncAnalogToSQuad,
    mapFuncAnalogToUQuad,
    mapFuncAnalogToFloat,
    mapFuncMStoUShort,
    mapFuncAnalogToEnum,
    mapFuncMStoEnum,
    mapFuncBinaryToSShort,
    mapFuncBinaryToULong,
    mapFuncBinaryToSLong,
    mapFuncBinaryToUShort,
    mapFuncBinaryToEnum,
    mapFuncBinaryToSNVT_switch,
    mapFuncBinaryToSNVT_switch_state,
    mapFuncAnalogToSNVT_switch,
    mapFuncBit,
    mapFuncNone

} mapFuncs;

typedef uint8_t UserScaleFactor;
typedef uint8_t UserEngLimits;


#define MAX_MAC_LEN 7

typedef struct
{
    uint8_t len;                // If this is ever set to zero -> implies broadcast
    uint8_t adr[MAX_MAC_LEN];   // If this is IP MAC, it is in network order
} BACNET_MAC_ADDRESS;

typedef struct
{
    uint16_t            net;
    BACNET_MAC_ADDRESS  mac;
} BACNET_ADDRESS;

typedef struct {
    uint8_t protocol_version;
    /* parts of the control octet: */
    pBool data_expecting_reply;
    pBool network_layer_message; /* false if APDU */
    BACNET_MESSAGE_PRIORITY bac_priority;
    /* optional network message info */
    BACNET_NETWORK_MESSAGE_TYPE network_message_type;   /* optional */
    uint16_t vendor_id; /* optional, if net message type is > 0x80 */
    uint8_t hop_count;
} BACNET_NPCI_DATA;

struct ring_buffer_t {
    uint8_t *buffer;            /* block of memory or array of data */
    uint8_t element_size;       /* how many bytes for each chunk */
    uint8_t mx_elements;        // max number of items for the ringbuf
    uint8_t ux_elements;        // how many items are in the ringbuf
    uint8_t head;               /* where the writes go */
    uint8_t tail;               /* where the reads come from */
};

typedef struct ring_buffer_t RING_BUFFER;

#define MX_SB_HEAD  2

typedef struct
{
    uint8_t signature;
    uint8_t allocated;             // allocated space of the buffer
    uint8_t used;                  // typically on incoming messages, how many bytes were received, and encoding, how many bytes built
    pBool   overflow;
    uint8_t buffer[MX_SB_HEAD];    // the array will actually extend far beyond 2 elements in practice (don't place any fields after this).
} SAFE_BUFFER;

typedef struct
{
    BACNET_MAC_ADDRESS  phyDest;
    SAFE_BUFFER *safeBuf;

} Lon_packet_CB;

typedef struct _dll_cb {

    void (*SendPdu)(struct _baclon_port *baclonPort, BACNET_MAC_ADDRESS *mac, BACNET_NPCI_DATA *npci);     // will pick up buffer from txBuildBuf
    uint8_t mx_outgoing_buffer;
    uint8_t mx_apdu;

} DLL_CB;

typedef struct _baclon_port
{
    DLL_CB              *dllCB;
    struct _baclon_port *next;          // pointer to next baclon port in link-list
    uint16_t        bacPort;            // Network byte order
    int16_t         socket;
} BACLON_PORT;


typedef struct pkt_cb
{
    BACLON_PORT         *baclonPort;        // parameters for each Datalink layer BUT THIS MUST BE FIRST!!!

    BACNET_MAC_ADDRESS  *srcMac;            // In most cases this is the source address, but eventually gets used as the destination address for a response, so avoid calling it the src or dest.
                                            // Source address details captured partially by Datalink layer, partially by npdu_decode() (aka npci_decode() )
    SAFE_BUFFER         *safeBuf;
} PKT_CB;


typedef struct { int8_t mult; int8_t exp; int16_t offset; } LR_Scale_Factor;
typedef struct { float_type mult; int8_t exp; float_type offset; } HR_Scale_Factor;
typedef enum { EL_SInt, EL_UInt, EL_Float } Eng_Limit_Type;
typedef enum { DF_ULong, DF_SLong, DF_UShort, DF_SShort, DF_Float, DF_UQuad, DF_SQuad, DF_Enum } Data_Format;

#define LDT_SNVT_amp                                        1
#define LDT_SNVT_amp_ac                                     2
#define LDT_SNVT_amp_f                                      3
#define LDT_SNVT_hvac_overid__state                         4
#define LDT_SNVT_hvac_overid__percent                       5
#define LDT_SNVT_hvac_overid__flow                          6
#define LDT_SNVT_hvac_status__cool_output                   7
#define LDT_SNVT_hvac_status__econ_output                   8
#define LDT_SNVT_hvac_status__in_alarm                      9
#define LDT_SNVT_hvac_status__fan_output                    10
#define LDT_SNVT_hvac_status__heat_output_primary           11
#define LDT_SNVT_hvac_status__heat_output_secondary         12
#define LDT_SNVT_hvac_status__mode                          13
#define LDT_SNVT_switch                                     14
#define LDT_SNVT_switch__state                              15
#define LDT_SNVT_switch__value                              16
#define LDT_SNVT_switch_2__scene_number                     17
#define LDT_SNVT_switch_2__setting_angle                    18
#define LDT_SNVT_switch_2__setting_button_number            19
#define LDT_SNVT_switch_2__setting_change                   20
#define LDT_SNVT_switch_2__setting_delay                    21
#define LDT_SNVT_switch_2__setting_fan_level                22
#define LDT_SNVT_switch_2__setting_group_number             23
#define LDT_SNVT_switch_2__setting_multiplier               24
#define LDT_SNVT_switch_2__setting_value                    25
#define LDT_SNVT_temp_p                                     26
#define LDT_SNVT_temp                                       27
#define LDT_SNVT_temp_f                                     28
#define LDT_SNVT_lux                                        29
#define LDT_SNVT_lev_cont_f                                 30
#define LDT_SNVT_count_32                                   31
#define LDT_SShort                                          32                  // 8-bit
#define LDT_UShort                                          33
#define LDT_SLong                                           34                  // 16-bit
#define LDT_ULong                                           35
#define LDT_Float                                           36
#define LDT_SQuad                                           37
#define LDT_UQuad                                           38
#define LDT_Enum                                            LDT_SShort
#define LDT_SNVT_temp_p_US                                  39
#define LDT_SNVT_temp_US                                    40

typedef int8_t Lon_Datatype;


typedef struct {
    Lon_Datatype            systemMappingType;
    Data_Format             dataFormat;
    UserScaleFactor         userScaleFactor;
    ENGINEERING_UNITS       units;
} Analog_Mapping_Type;

typedef struct {
    Lon_Datatype            systemMappingType;
    Data_Format             dataFormat;
    uint8_t                 bitOffset;
} Binary_Mapping_Type;


extern const far char *Vendor_Name;
#pragma ignore_notused Vendor_Name
extern const far uint16_t Vendor_Identifier;
#pragma ignore_notused Vendor_Identifier
extern far const char *Model_Name;
#pragma ignore_notused Model_Name
extern far const char *Application_Software_Version;
#pragma ignore_notused Application_Software_Version
extern far int8_t initFail;

extern far RING_BUFFER lon_outgoing_queue;
extern far RING_BUFFER bacIncomingQueueCB;
extern far BACLON_PORT lonPort;

// Modify these variables if you wish to alter BACnet MS/TP parameters programatically. Address can be modified by BACnet Clients via Device Object, Description Property too.
extern eeprom uint8_t This_Station;
extern eeprom TSciRates baudRate;
extern eeprom uint8_t portHi, portLo;

extern far pBool lon_dll_init;

BACNET_INIT_RETURN_CODE emm_init(uint8_t dynMemSizeOrder, uint8_t *staticMem, uint16_t staticMemSize);

BACNET_INIT_RETURN_CODE init_BACnet(
    uint8_t incomingQueueSize,
    uint8_t outgoingLonQueueSize );

void Reset_BACnet(void);
#pragma ignore_notused Reset_BACnet
void Sys_Reset_BACnet(void);

BACNET_INIT_RETURN_CODE dllon_init(uint8_t outgoingLonQueueSize);
#pragma ignore_notused dllon_init
void    bacnet_emulation_main(void);
#pragma ignore_notused bacnet_emulation_main
pBool   check_BACnet_msg(void);

uint8_t txUsed(void);
#pragma ignore_notused txUsed

void dumpMappingTable(void);
#pragma ignore_notused dumpMappingTable

void Process_Incoming_BACnet(void);
void Process_Outgoing_BACnet(void);

char *myitoa(int16_t i);
#pragma ignore_notused myitoa

void loadTString2(unsigned idx, char *dp);
#pragma ignore_notused loadTString2

void copy_bacnet_mac(BACNET_MAC_ADDRESS *dest, BACNET_MAC_ADDRESS *src);
#pragma ignore_notused copy_bacnet_mac
void set_global_broadcast(BACNET_ADDRESS *destAddr);
#pragma ignore_notused set_global_broadcast
void set_local_broadcast(BACNET_ADDRESS *destAddr);
#pragma ignore_notused set_local_broadcast

__resident SAFE_BUFFER *sb_alloc( uint8_t length);
__resident void sb_free(SAFE_BUFFER *ptr);

__resident void *emm_malloc(uint16_t size);
__resident void emm_free(void *ptr);
#pragma ignore_notused emm_free
void *emm_calloc_static(uint16_t size);                 // allocates in static heap - never allowed to free.
#pragma ignore_notused emm_calloc_static

__resident void *Ringbuf_Peek(RING_BUFFER const *b);
__resident void Ringbuf_Pop(RING_BUFFER *b);
__resident void *Ringbuf_Pre_Alloc(RING_BUFFER * b);
__resident void Ringbuf_Post_Alloc(RING_BUFFER * b);

void handler_cov_timer_second(void);
void handler_cov_task(void);
void tsm_timer_second(void);

extern __resident void spinlock_lock(void);
#pragma ignore_notused spinlock_lock
extern __resident void spinlock_unlock(void);
#pragma ignore_notused spinlock_unlock

extern __resident uint16_t my_crc16_ccitt(uint16_t crc_in, const uint8_t *sp, uint8_t len);
#pragma ignore_notused my_crc16_ccitt
const char* ResolveName(void);
#pragma ignore_notused ResolveName


#ifdef BACNET_MSTP

extern __resident void MSTPreceiveStart(void);
extern __resident void MSTPreceiveEnd(void);
extern system far _RESIDENT void _scimstp_init(void);
extern system unsigned short _SciRxRingBuf[256];
extern system unsigned short _SciRxHead;
extern system unsigned short _SciRxTail;


extern uint8_t ReceiveError;
extern uint8_t DataAvailable;
extern uint16_t tickCounterTimer;

extern s32_type nsCounter;
extern s32_type sCounter;

#define MX_OUTPUT_BUFFER    255

extern far uint8_t OutputBuffer[MX_OUTPUT_BUFFER];
extern uint8_t OutputPointer;

__resident void incrementTimers(void);
__resident void SilenceTimerReset(void);
BACNET_INIT_RETURN_CODE init_BACnet_MSTP(uint8_t mx_outgoing_buffers );
BACNET_INIT_RETURN_CODE dlmstp_init(uint8_t mxOutboundQueue);
__resident void dlmstp_process_Master(void);
__resident void process_serial_mstp(void);
__resident void MSTP_Receive_Frame_FSM(uint8_t DataRegister);
__resident pBool MSTP_Master_Node_FSM(void);
__resident void TransmitterStateMachine(void);
void RS485_Set_Baud_Rate(void);
void RS485_Set_Next_Baud_Rate(void);
__resident void send_mstp_packet(void);
__resident pBool get_mstp_progress(void);

extern system far __resident void _scimstp_set_baud(unsigned long baud_control);

#endif



