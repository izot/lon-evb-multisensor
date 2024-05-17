//////////////////////////////////////////////////////////////////////////////
//
// File: blonsys.nc
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
#include <access.h>
#include <msg_addr.h>

#include "nctypes.h"
#include "udp_app_msg.h"
#include "blonsys.h"

msg_tag bind_info(nonbind) explictMsgTag;

extern far uint8_t *txBufferRef;

far uint8_t mySubnet0, mySubnet1;

// These are the very minimum sizes required for BAClon stack
// Elsewhere, developers may specifiy their own minimums to override these, so do not change these
// Allowable (bacnet compatible) values: 50,66,82,114,146,210,255

#pragma app_buf_out_size 82,minimum
#pragma app_buf_in_size 82,minimum
#pragma net_buf_out_size 82,minimum
#pragma net_buf_in_size 82,minimum


void lon_physical_transmit(Lon_packet_CB *outpkt)
    {
    const domain_struct *aDomain = access_domain(0);

    msg_out.tag = explictMsgTag;
    msg_out.code = UDP_APP_MSG_CODE;
    msg_out.service = UNACKD;
    msg_out.dest_addr.snode.type = SUBNET_NODE;
    msg_out.dest_addr.snode.domain = 0;
    msg_out.dest_addr.snode.rpt_timer = 0;
    msg_out.dest_addr.snode.retry = 0;
    msg_out.dest_addr.snode.tx_timer = 0;

    if (outpkt->phyDest.len == 0)
        {
        msg_out.data[offsetof(UdpAppMsgHdr, dest)] = mySubnet0 ;
        msg_out.data[offsetof(UdpAppMsgHdr, dest) + 1] = mySubnet1;
        msg_out.data[offsetof(UdpAppMsgHdr, dest) + 2] = aDomain->subnet;
        msg_out.data[offsetof(UdpAppMsgHdr, dest) + 3] = 1;
        msg_out.data[offsetof(UdpAppMsgHdr, dest) + 4] = portHi;
        msg_out.data[offsetof(UdpAppMsgHdr, dest) + 5] = portLo;
        }
    else
        {
        memcpy(&msg_out.data[offsetof(UdpAppMsgHdr, dest)], &outpkt->phyDest.adr, sizeof(UdpAppAddr));
        }

    // set up the 'from' ipaddr.
    msg_out.data[offsetof(UdpAppMsgHdr, source) + 0] = mySubnet0;
    msg_out.data[offsetof(UdpAppMsgHdr, source) + 1] = mySubnet1;
    msg_out.data[offsetof(UdpAppMsgHdr, source) + 2] = aDomain->subnet;
    msg_out.data[offsetof(UdpAppMsgHdr, source) + 3] = aDomain->node;
    msg_out.data[offsetof(UdpAppMsgHdr, source) + 4] = portHi;
    msg_out.data[offsetof(UdpAppMsgHdr, source) + 5] = portLo;

    msg_out.data[sizeof(UdpAppMsgHdr)] = BVLL_TYPE_BACNET_IP;

    if (outpkt->phyDest.len)
        {
        msg_out.data[sizeof(UdpAppMsgHdr) + 1] = BVLC_ORIGINAL_UNICAST_NPDU_CODE;
        }
    else
        {
        msg_out.data[sizeof(UdpAppMsgHdr) + 1] = BVLC_ORIGINAL_BROADCAST_NPDU_CODE;
        }

    msg_out.data[sizeof(UdpAppMsgHdr) + 2] = 0;
    msg_out.data[sizeof(UdpAppMsgHdr) + 3] = (uint8_t)(outpkt->safeBuf->used + 4);
    memcpy(&msg_out.data[sizeof(UdpAppMsgHdr) + 4], outpkt->safeBuf->buffer, outpkt->safeBuf->used);

    sb_free(outpkt->safeBuf);

    msg_send();

    }


boolean check_BACnet_msg(void)
    {
    // msg_in_addr const *mia = &msg_in.addr;
    PKT_CB *pkt;
    BACNET_MAC_ADDRESS *src;
    SAFE_BUFFER *sb;
//  uint8_t i;

    if (msg_in.code != UDP_APP_MSG_CODE)
        {
        // message is not a UDP packet, ignore
        return FALSE;
        }

    if (msg_in.data[4] != portHi || msg_in.data[5] != portLo )
        {
        // this message is also not for us...
        return FALSE;
        }

    // record UDP subnet information.
    mySubnet0 = msg_in.data[6];
    mySubnet1 = msg_in.data[7];

    if (initFail) return FALSE;

    // right here is where we have to decide if this message if over Lon or over LIFT
    if (msg_in.data[sizeof(UdpAppMsgHdr)] == BVLL_TYPE_BACNET_IP)
        {
        if (msg_in.data[sizeof(UdpAppMsgHdr) + 1] == BVLC_ORIGINAL_UNICAST_NPDU_CODE || msg_in.data[sizeof(UdpAppMsgHdr) + 1] == BVLC_ORIGINAL_BROADCAST_NPDU_CODE)
            {
            uint8_t len = (uint8_t)(msg_in.len - sizeof(UdpAppMsgHdr) - 4);

            pkt = (PKT_CB *)Ringbuf_Pre_Alloc(&bacIncomingQueueCB);
            if (pkt != NULL)
                {
                // try alloc the larger block first
                sb = sb_alloc(len);
                if (sb == NULL)
                    {
                    return TRUE;
                    }

                src = (BACNET_MAC_ADDRESS *)emm_malloc(sizeof(BACNET_MAC_ADDRESS));
                if (src == NULL)
                    {
                    sb_free(sb);
                    return TRUE;
                    }

                memcpy(sb->buffer, &msg_in.data[sizeof(UdpAppMsgHdr) + 4], len);
                sb->used = len;

                // make a copy of source IP address for response
                memcpy(&src->adr[0], &msg_in.data[offsetof(UdpAppMsgHdr, source)], sizeof(UdpAppAddr));
                src->len = 6;

                pkt->baclonPort = &lonPort;
                pkt->safeBuf = sb;
                pkt->srcMac = src;
                Ringbuf_Post_Alloc(&bacIncomingQueueCB);
                }
            }
        }
    return TRUE;
    }


#if defined ( BACNET_MSTP )

// Note: IO_9 is defined as an input AND output. Sequence of definition matters!
IO_9 input bit ioPin9in;
IO_9 output bit ioPin9 ;

#pragma specify_io_clock "10 MHz"
IO_8 sci baud(SCI_38400) ioSerialMSTP;

// Optional functionality to e.g. Illuminate LED for MSTP Rx Frames
#ifdef IOforRx
IOforRx output bit ioRx;

__resident void MSTPreceiveStart(void)
    {
        io_out ( ioRx, IOforRxActive ) ;
    }
__resident void MSTPreceiveEnd(void)
    {
        io_out ( ioRx, ! IOforRxActive ) ;
    }
#else
__resident void MSTPreceiveStart(void)
    {
    }
__resident void MSTPreceiveEnd(void)
    {
    }
#endif


__resident pBool get_mstp_progress(void)
    {
        return io_in ( ioPin9in ) ;
    }

__resident void send_mstp_packet(void)
    {
    io_out(ioPin9, 1);  // Assert TxEnable (the SCI library will switch it off for us)
    io_out_request(ioSerialMSTP, OutputBuffer, OutputPointer);
    }


interrupt(repeating, "2500")
    {
    incrementTimers();

    TransmitterStateMachine();

    process_serial_mstp();
    }

#endif

static pBool spinlock;

__resident void spinlock_lock(void)
    {
    __lock
        {
        while (spinlock);
        spinlock = TRUE;
        }
    }

__resident void spinlock_unlock(void)
    {
    spinlock = FALSE;
    }


__resident unsigned long my_crc16_ccitt(unsigned long crc_in, const unsigned *sp, unsigned len)
    {
    return crc16_ccitt(crc_in, sp, len);
    }


void Process_Outgoing_BACnet(void)
    {
    Lon_packet_CB *outPkt;

    if (initFail) return;

    // A note on race conditions: There is no other consumer of this queue, so it is safe to peek, and a while later
    // pop. We only pop if we manage to successfully malloc an outgoing buffer

    outPkt = (Lon_packet_CB *)Ringbuf_Peek(&lon_outgoing_queue);
    if (outPkt)
        {
        // would we be able to send if we wanted to?
        if (msg_alloc_priority())
            {
            lon_physical_transmit(outPkt);
            Ringbuf_Pop(&lon_outgoing_queue);
            }
        else if (msg_alloc())
            {
            lon_physical_transmit(outPkt);
            Ringbuf_Pop(&lon_outgoing_queue);
            }
        }
    }


// If for some reason, application wants to totally restart BACnet.. here it is..
void Reset_BACnet ( void )
{
    Sys_Reset_BACnet() ;

#if defined ( BACNET_COV ) && defined ( BACNET_Persist_COV_Increment )
    ResetPersist();
#endif

}

