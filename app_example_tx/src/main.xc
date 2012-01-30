// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

//::declaration
#include <xs1.h>
#include "SpdifTransmit.h"

#define SAMPLE_FREQUENCY_HZ 48000
#define MASTER_CLOCK_FREQUENCY_HZ 24576000

buffered out port:32 oneBitPort = XS1_PORT_1F;
in port masterClockPort = XS1_PORT_1E;
clock clockblock = XS1_CLKBLK_1;
//::

//::data handling
void transmitSpdif(chanend c)  {
    SpdifTransmitPortConfig(oneBitPort, clockblock, masterClockPort);
    SpdifTransmit(oneBitPort, c);
}

void generate(chanend c) {
    outuint(c, SAMPLE_FREQUENCY_HZ);
    outuint(c, MASTER_CLOCK_FREQUENCY_HZ);
    for(int i = 0; i < 10; i++) {
        outuint(c, i);
    }
    outct(c, XS1_CT_END);
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
