// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <assert.h>
//::declaration
#include <xs1.h>
#include <platform.h>
#include "SpdifTransmit.h"
#include "SpdifTransmit_4bitPort.h"

#define SAMPLE_FREQUENCY_HZ 96000
#define MASTER_CLOCK_FREQUENCY_HZ 12288000

on stdcore[1] : buffered out port:32 oneBitPort = XS1_PORT_1K;
on stdcore[1] : buffered out port:32 fourBitsPort = XS1_PORT_4D;
on stdcore[1] : in port masterClockPort = XS1_PORT_1L;
on stdcore[1] : clock clockblock = XS1_CLKBLK_1;
//::

//::clocking
#include "i2c.h"

on stdcore[1] : struct r_i2c i2c_master = {
   XS1_PORT_1D,
   XS1_PORT_1C,
   1000
};

#define DEV_ADR      (0x9C   >> 1)

unsigned char PLL_REGRD(int reg) {
   unsigned char data[10];
   i2c_master_read_reg(DEV_ADR, reg, data, 1, i2c_master);
   return data[0];
}

void PLL_REGWR(int reg, unsigned char val) {
   unsigned char data[10];
   data[0] = val;
   i2c_master_write_reg(DEV_ADR, reg, data, 1, i2c_master);
}

/* Init of CS2300 */
void PllInit() {
    /* Enable init */
    PLL_REGWR(0x03, 0x07);
    PLL_REGWR(0x05, 0x01);
    PLL_REGWR(0x16, 0x10);
    PLL_REGWR(0x17, 0x00); //0x10 for always gen clock even when unlocked

    /* Check */
    assert(PLL_REGRD(0x03) == 0x07);
    assert(PLL_REGRD(0x05) == 0x01);
    assert(PLL_REGRD(0x16) == 0x10);
    assert(PLL_REGRD(0x17) == 0x00);
}

/* Setup PLL multiplier */
void PllMult(unsigned mult) {
    /* Multiplier is translated to 20.12 format by shifting left by 12 */
    PLL_REGWR(0x06, (mult >> 12) & 0xFF);
    PLL_REGWR(0x07, (mult >> 4) & 0xFF);
    PLL_REGWR(0x08, (mult << 4) & 0xFF);
    PLL_REGWR(0x09, 0x00);

    /* Check */
    assert(PLL_REGRD(0x06) == ((mult >> 12) & 0xFF));
    assert(PLL_REGRD(0x07) == ((mult >> 4) & 0xFF));
    assert(PLL_REGRD(0x08) == ((mult << 4) & 0xFF));
    assert(PLL_REGRD(0x09) == 0x00);
}

on stdcore[1] : out port p_pll_clk = XS1_PORT_4E;
on stdcore[1] : out port p_aud_cfg = XS1_PORT_4A;

void setupPll(void) {
    i2c_master_init(i2c_master);
    PllInit();
    PllMult(MASTER_CLOCK_FREQUENCY_HZ/300);
}

// Generate 300Hz clock for PLL
#define LOCAL_CLOCK_INCREMENT 166667

void clockGen() {
   unsigned pinVal = 0;
   timer t;
   unsigned time;
   t :> time;
   p_aud_cfg <: 0;
   p_pll_clk <: pinVal;

   while(1) {
      t when timerafter(time) :> void;
      pinVal = !pinVal;
      p_pll_clk <: pinVal;
      time += LOCAL_CLOCK_INCREMENT;
   }
}
//::

//::spdif thread
void transmitSpdif(chanend c) {
    SpdifTransmitPortConfig(oneBitPort, clockblock, masterClockPort);
    SpdifTransmit(oneBitPort, c);
}
//::

//::spdif thread 2
void transmitSpdif_4bitPort(chanend c) {
    SpdifTransmitPortConfig_4bitPort(fourBitsPort, clockblock, masterClockPort);
    SpdifTransmit_4bitPort(fourBitsPort, c);
}
//::

//::data generation
#define WAVE_LEN 512
void generate(chanend c) {
    int i = 0;
    outuint(c, SAMPLE_FREQUENCY_HZ);
    outuint(c, MASTER_CLOCK_FREQUENCY_HZ);
    while(1) {
       // Generate a triangle wave
       int sample = i;
       if (i > (WAVE_LEN / 4)) {
          // After the first quarter of the cycle
          sample = (WAVE_LEN / 2) - i;
       }
       if (i > (3 * WAVE_LEN / 4)) {
          // In the last quarter of the cycle
          sample = i - WAVE_LEN;
       }
       sample <<= 23; // Shift to highest but 1 bits
       outuint(c, sample); // Left channel
       outuint(c, sample); // Right channel

       i++;
       i %= WAVE_LEN;
    }
    //outct(c, XS1_CT_END); // to stop SpdifTransmit thread
}
//::

//::main program
void example(void) {
   chan c;
   setupPll();
   par {
      //------- Use one of these functions -------
	  transmitSpdif(c);
	  //transmitSpdif_4bitPort(c);
	  //------------------------------------------
      generate(c);
      clockGen();
   }
}

int main(void) {
   par {
      on stdcore[1]: example();
   }
   return 0;
}
//::
