// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>


#include <xs1.h>
#include <platform.h>
#include "spdif_transmit.h"
#include "i2s_master.h"
#include "xa_sk_audio_1v1.h"
#include "i2s_spdif_conf.h"
#include "app_global.h"
#include "i2c_conf.h"





/* HW resources needed for S/PDIF*/
on tile[1] : buffered out port:32 oneBitPort = XS1_PORT_1M;
on tile[1] : clock spdif_clockblock = XS1_CLKBLK_3;

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

/* Port for I2C bus for configuring the audio codec.
   Both SDA and SCL are on lines on same port */
on tile[1] : port p_i2c = PORT_I2C;

/* GPIO port */
on tile[1] : out port p_gpio = PORT_GPIO;

void audio_hw_init();
void audio_hw_config(unsigned samFreq);
void i2s_to_spdif_bridge(streaming chanend c_i2s, chanend c_spdif);

int main(void){

    chan c_spdif;
    streaming chan c_i2s;

    par{
        on tile[1] :{
        unsigned mclk_bclk_div = MCLK_FREQ/(SAMPLE_FREQUENCY_HZ * 64);
        audio_hw_init();
        audio_hw_config(SAMPLE_FREQUENCY_HZ);
        spdif_transmit_port_config(oneBitPort,
                                   spdif_clockblock,
                                   i2s_resources.mck);
        par{
                i2s_master(i2s_resources, c_i2s, mclk_bclk_div);
                i2s_to_spdif_bridge(c_i2s,c_spdif);
                spdif_transmit(oneBitPort,c_spdif);
            }
        }
    }
    return 0;
}

void i2s_to_spdif_bridge(streaming chanend c_i2s, chanend c_spdif){
    unsigned i2s_buffer[2] = {0,0};
    unsigned spdif_buffer[2] = {0,0};

     outuint(c_spdif, SAMPLE_FREQUENCY_HZ);
     outuint(c_spdif, MCLK_FREQ);

     while(1){
             c_i2s :> i2s_buffer[0];
             c_i2s :> i2s_buffer[1];

             c_i2s <: 0;
             c_i2s <: 0;
             /* Moving the data from i2s buffer to spdif buffer.
              * Some processing could be done here.*/
             spdif_buffer[0] = i2s_buffer[0];
             spdif_buffer[1] = i2s_buffer[1];


             outuint(c_spdif, i2s_buffer[0]);
             outuint(c_spdif, i2s_buffer[1]);
     }
 }


