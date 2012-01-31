// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

//::declaration
#include <xs1.h>
#include "SpdifTransmit.h"

#define SAMPLE_FREQUENCY_HZ 192000
#define MASTER_CLOCK_FREQUENCY_HZ 24576000

buffered out port:32 oneBitPort = XS1_PORT_1F;
in port masterClockPort = XS1_PORT_1E;
clock clockblock = XS1_CLKBLK_1;
//::

//::spdif thread
void transmitSpdif(chanend c)  {
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
int main(void) {
    chan c;
    par {
        transmitSpdif(c);
        generate(c);
    }
    return 0;
}
//::
