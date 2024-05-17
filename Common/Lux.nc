//////////////////////////////////////////////////////////////////////////////
// Lux.nc
//
// Support for TSL2560, TSL2561 light level-to-digital converters.
// TAOS059D - DECEMBER 2005 www.taosinc.com,  Code modified by
// to port to Neuron C.
//
// Original Source Copyright © 2004-2005 TAOS, Inc.
// Neuron C Source Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#include <s32.h>

#define LUX_SCALE 14 // scale by 2^14
#define RATIO_SCALE 9 // scale ratio by 2^9
//---------------------------------------------------
// Integration time scaling factors
//---------------------------------------------------
#define CH_SCALE 10 // scale channel values by 2^10
#define CHSCALE_TINT0 0x7517 // 322/11 * 2^CH_SCALE
#define CHSCALE_TINT1 0x0fe7 // 322/81 * 2^CH_SCALE
//---------------------------------------------------
// T Package coefficients
//---------------------------------------------------
// For Ch1/Ch0=0.00 to 0.50
// Lux/Ch0=0.0304-0.062*((Ch1/Ch0)^1.4)
// piecewise approximation
// For Ch1/Ch0=0.00 to 0.125:
// Lux/Ch0=0.0304-0.0272*(Ch1/Ch0)
//
// For Ch1/Ch0=0.125 to 0.250:
// Lux/Ch0=0.0325-0.0440*(Ch1/Ch0)
//
// For Ch1/Ch0=0.250 to 0.375:
// Lux/Ch0=0.0351-0.0544*(Ch1/Ch0)
//
// For Ch1/Ch0=0.375 to 0.50:
// Lux/Ch0=0.0381-0.0624*(Ch1/Ch0)
//
// For Ch1/Ch0=0.50 to 0.61:
// Lux/Ch0=0.0224-0.031*(Ch1/Ch0)
//
// For Ch1/Ch0=0.61 to 0.80:
// Lux/Ch0=0.0128-0.0153*(Ch1/Ch0)
//
// For Ch1/Ch0=0.80 to 1.30:
// Lux/Ch0=0.00146-0.00112*(Ch1/Ch0)
//
// For Ch1/Ch0>1.3:
// Lux/Ch0=0
//---------------------------------------------------
#define K1T 0x0040 // 0.125 * 2^RATIO_SCALE
	#define B1T 0x01f2 // 0.0304 * 2^LUX_SCALE
	#define M1T 0x01be // 0.0272 * 2^LUX_SCALE
#define K2T 0x0080 // 0.250 * 2^RATIO_SCALE
	#define B2T 0x0214 // 0.0325 * 2^LUX_SCALE
	#define M2T 0x02d1 // 0.0440 * 2^LUX_SCALE
#define K3T 0x00c0 // 0.375 * 2^RATIO_SCALE
	#define B3T 0x023f // 0.0351 * 2^LUX_SCALE
	#define M3T 0x037b // 0.0544 * 2^LUX_SCALE
#define K4T 0x0100 // 0.50 * 2^RATIO_SCALE
	#define B4T 0x0270 // 0.0381 * 2^LUX_SCALE
	#define M4T 0x03fe // 0.0624 * 2^LUX_SCALE
#define K5T 0x0138 // 0.61 * 2^RATIO_SCALE
	#define B5T 0x016f // 0.0224 * 2^LUX_SCALE
	#define M5T 0x01fc // 0.0310 * 2^LUX_SCALE
#define K6T 0x019a // 0.80 * 2^RATIO_SCALE
	#define B6T 0x00d2 // 0.0128 * 2^LUX_SCALE
	#define M6T 0x00fb // 0.0153 * 2^LUX_SCALE
#define K7T 0x029a // 1.3 * 2^RATIO_SCALE
	#define B7T 0x0018 // 0.00146 * 2^LUX_SCALE
	#define M7T 0x0012 // 0.00112 * 2^LUX_SCALE
#define K8T 0x029a // 1.3 * 2^RATIO_SCALE
	#define B8T 0x0000 // 0.000 * 2^LUX_SCALE
	#define M8T 0x0000 // 0.000 * 2^LUX_SCALE

void s32_leftshift(s32_type* a, unsigned int n)
{
	unsigned int i;
	for (i = 0; i < n; i ++) {
		s32_mul2(a);
	}
}

void s32_rightshift(s32_type* a, unsigned int n)
{
	unsigned int i;
	for (i = 0; i < n; i ++) {
		s32_div2(a);
	}
}

//////////////////////////////////////////////////////////////////////////////
//
// Calculate the approximate illuminance (lux) given the raw channel values
// of the TSL2560. The equation is implemented as a piece-wise linear 
// approximation without floating point calculations.
//
// Arguments: unsigned int iGain - gain, where 0:1X, 1:16X
// unsigned int tInt - integration time, where 0:13.7mS, 1:100mS, 2:402mS,
// 3:Manual
// unsigned int ch0 - raw channel value from channel 0 of TSL2560
// unsigned int ch1 - raw channel value from channel 1 of TSL2560
// unsigned int iType - package type (T or CS)
//
// Return: unsigned int - the approximate illuminance (lux)
//
//////////////////////////////////////////////////////////////////////////////

unsigned long CalculateLux(unsigned int iGain, unsigned int tInt, unsigned long ch0,
unsigned long ch1)
{
	unsigned long chScale;
	s32_type channel1;
	s32_type channel0;
	unsigned long ratio1, ratio;
	unsigned long b, m;
	s32_type temp, temp1, temp2, temp3;
	unsigned long lux;

	// Scale the channel values depending on the gain and integration time
	// 16X, 402mS is nominal.  Scale if integration time is NOT 402 msec.
	switch (tInt) {
	case 0: // 13.7 msec
		chScale = CHSCALE_TINT0;
		break;
	case 1: // 101 msec
		chScale = CHSCALE_TINT1;
		break;
	default: // assume no scaling
		chScale = ((unsigned long) 1 << CH_SCALE);
		break;
	}
	
	// Scale if gain is NOT 16X
	if (!iGain) chScale = chScale << 4; // scale 1X to 16X
	
	// Scale the channel values
	
	//channel0 = (ch0 * chScale) >> CH_SCALE;
	//channel1 = (ch1 * chScale) >> CH_SCALE;
	
	s32_from_ulong(ch0, &temp1);
	s32_from_ulong(chScale, &temp2);
	s32_mul(&temp1, &temp2, &channel0);
	s32_rightshift(&channel0, CH_SCALE);
	
	s32_from_ulong(ch1, &temp1);
	s32_from_ulong(chScale, &temp2);
	s32_mul(&temp1, &temp2, &channel1);
	s32_rightshift(&channel1, CH_SCALE);
	
	// Find the ratio of the channel values (Channel1/Channel0).
	// Prevent divide by zero.
	ratio1 = 0;
	temp1 = s32_zero;
	if (s32_ne(&channel0, &temp1)) {
		//ratio1 = (channel1 << (RATIO_SCALE+1)) / channel0;
		temp1 = channel1;
		s32_leftshift(&temp1, (RATIO_SCALE+1));
		s32_div(&temp1, &channel0, &temp2);
		ratio1 = s32_to_ulong(&temp2);
	}
	// Round the ratio value
	ratio = (ratio1 + 1) >> 1;
	
	// Test if ratio <= eachBreak
	if (ratio <= K1T)
		{b=B1T; m=M1T;}
	else if (ratio <= K2T)
		{b=B2T; m=M2T;}
	else if (ratio <= K3T)
		{b=B3T; m=M3T;}
	else if (ratio <= K4T)
		{b=B4T; m=M4T;}
	else if (ratio <= K5T)
		{b=B5T; m=M5T;}
	else if (ratio <= K6T)
		{b=B6T; m=M6T;}
	else if (ratio <= K7T)
		{b=B7T; m=M7T;}
	else if (ratio > K8T)
		{b=B8T; m=M8T;}

	s32_from_ulong(b, &temp1);
	s32_mul(&channel0, &temp1, &temp2);
	
	s32_from_ulong(m, &temp1);
	s32_mul(&channel1, &temp1, &temp3);
	
	s32_sub(&temp2, &temp3, &temp);
	
	// Round LSB (2^(LUX_SCALE-1))
	s32_from_ulong(((unsigned long)1 << (LUX_SCALE-1)), &temp1);
	temp2 = temp;
	s32_add(&temp2, &temp1, &temp);
	
	// Strip off fractional portion
	s32_rightshift(&temp, LUX_SCALE);
	lux = s32_to_ulong(&temp);
	
	return(lux);
}
