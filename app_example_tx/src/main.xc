// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <assert.h>
//::declaration
#include <xs1.h>
#include <platform.h>
#include "SpdifTransmit.h"

#define SAMPLE_FREQUENCY_HZ 44100
#define MASTER_CLOCK_FREQUENCY_HZ 22579200
#define SPDIF_ENABLE 0x1

on stdcore[1] : buffered out port:32 oneBitPort = XS1_PORT_1M;
on stdcore[1] : in port masterClockPort = XS1_PORT_1E;
on stdcore[1] : clock clockblock = XS1_CLKBLK_1;
on stdcore[1] : out port p_gpio = XS1_PORT_4E;
//::



//::spdif thread
void transmitSpdif(chanend c) {
    SpdifTransmitPortConfig(oneBitPort, clockblock, masterClockPort);
    SpdifTransmit(oneBitPort, c);
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
   p_gpio <: SPDIF_ENABLE;
   par {
      transmitSpdif(c);
      generate(c);
   }
}

int main(void) {
   par {
      on stdcore[1]: example();
   }
   return 0;
}
//::
