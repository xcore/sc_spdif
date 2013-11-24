// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

//::declaration
#include <xs1.h>
#include "SpdifReceive.h"

buffered in port:4 oneBitPort = XS1_PORT_1F;
clock clockblock = XS1_CLKBLK_1;
//::

//::data handling
void handleSamples(streaming chanend c) {
    int v, left, right;
    while(1) {
        c :> v;
        if((v & 0xF) == FRAME_Y) {
            right = (v & ~0xf) << 4;
            // operate on left and right
        } else {
            left = (v & ~0xf) << 4;
        }
    }
}
//::

//::main program
int main(void) {
    streaming chan c;
    par {
        SpdifReceive(oneBitPort, c, 1, clockblock);
        handleSamples(c);
    }
    return 0;
}
//::
