// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

//::declaration
#include <xs1.h>
#include <platform.h>
#include "spdif_transmit.h"
#include "spdif_conf.h"
#include <print.h>

#define MASTER_CLOCK_FREQUENCY_44_1KHZ 22579200
#define MASTER_CLOCK_FREQUENCY_48KHZ 24576000

#define MCLK_FSEL_441 0b00
#define MCLK_FSEL_48  0b10
#define SPDIF_ENABLE  0b01


on tile[1] : out port p_gpio = XS1_PORT_4E;

//::declaration
on tile[1] : buffered out port:32 oneBitPort = XS1_PORT_1M;
on tile[1] : in port masterClockPort = XS1_PORT_1E;
on tile[1] : clock clockblock = XS1_CLKBLK_1;
//::

unsigned int mclk_freq;

//::spdif core
void transmitSpdif(chanend c) {
    spdif_transmit_port_config(oneBitPort, clockblock, masterClockPort);
    spdif_transmit(oneBitPort, c);
}
//::

//::data generation
#define WAVE_LEN 512
void generate(chanend c) {
    int i = 0;
    outuint(c, SAMPLE_FREQUENCY_HZ);
    outuint(c, mclk_freq);
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
}
//::

//::main program
void example(void) {
    chan c;

    //Initialise clock
    if ((SAMPLE_FREQUENCY_HZ%22050) == 0){
        mclk_freq = MASTER_CLOCK_FREQUENCY_44_1KHZ;
        p_gpio <: SPDIF_ENABLE|MCLK_FSEL_441;
    }
    else if ((SAMPLE_FREQUENCY_HZ%24000) == 0){
    	mclk_freq = MASTER_CLOCK_FREQUENCY_48KHZ;
    	p_gpio <: SPDIF_ENABLE|MCLK_FSEL_48;
    }

    par {
        transmitSpdif(c);
        generate(c);
    }
}
//::

int main(void) {
    par {
        on stdcore[1]: example();
    }
    return 0;
}

