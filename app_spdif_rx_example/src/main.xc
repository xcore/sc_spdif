// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

//::declaration
#include <xs1.h>
#include <platform.h>
#include "SpdifReceive.h"
#include "i2s_master.h"
#include "xa_sk_audio_1v1.h"
#include "i2c_conf.h"
#include <print.h>

#define MCLK_FREQ_441                   (512*44100)   /* 44.1, 88.2 etc */
#define MCLK_FREQ_48                    (512*48000)   /* 48, 96 etc */

#define SAMP_FREQ       44100


on tile[1] : port p_i2c = PORT_I2C;
on tile[1] : out port p_gpio = PORT_GPIO;

/* HW resource needed for i2s bus*/
on tile[1] : r_i2s i2s_resources = {
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,
    PORT_MCLK_IN,             // Master Clock
    PORT_I2S_BCLK,            // Bit Clock
    PORT_I2S_LRCLK,           // LR Clock
    {PORT_I2S_ADC0},
    {PORT_I2S_DAC0},

};

on tile[0] : buffered in port:4 oneBitPort = XS1_PORT_1A;
on tile[0] : clock clockblock = XS1_CLKBLK_3;
//::

//::data handling
void handle_samples(streaming chanend c, streaming chanend c_i2s) {
    int tmp = 0,tmp1, left, right;
    while(1) {

        c :> tmp;
        if((tmp & 0xF) == FRAME_Y) {
            right = (tmp & ~0xf) << 4;
            // operate on left and right
        }
        else {
            left = (tmp & ~0xf) << 4;
        }
        c_i2s :> tmp;
        c_i2s :> tmp;

        c_i2s <: left;
        c_i2s <: right;
    }
}
//::


void audio_hw_init();
void audio_hw_config(unsigned samFreq);

//::main program
int main(void) {
    streaming chan c_spdif_rx;
    streaming chan c_i2s;

    par {
        on tile[0]: {
            par {
                    {
                        SpdifReceive(oneBitPort, c_spdif_rx, 1, clockblock);
                    }
                    {
                        set_core_fast_mode_on();
                        while(1);
                    }
                    {
                        set_core_fast_mode_on();
                        while(1);
                    }
                    {
                        set_core_fast_mode_on();
                        while(1);
                    }
                    {
                        set_core_fast_mode_on();
                        while(1);
                    }
                }

        }
        on tile[1]: handle_samples(c_spdif_rx, c_i2s);
        on tile[1]: {
            unsigned mclk_div = MCLK_FREQ_441 / ( SAMP_FREQ * 64 );
            audio_hw_init();
            audio_hw_config(SAMP_FREQ);
            i2s_master(i2s_resources,c_i2s,mclk_div);
        }
    }
    return 0;
}
//::
