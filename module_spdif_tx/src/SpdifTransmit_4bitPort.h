#ifndef _SPDIF_TRANSMIT_4BIT_PORT_
#define _SPDIF_TRANSMIT_4BIT_PORT_

/**
 * Code limitations:
 * 1. Code is suitable only for XCORE-200 processor because of using UNZIP assembler commands
 * 2. Code assumes S/PDIF signal wire is connected to P4x0 port pin.
 *    For other wire connection edit my_partout() function. 
 *
 * Function expects a buffered single bit port clock from the master clock
 *
 * All channel communication is done via builtins (e.g.
 * outuint, outct etc.)
 *
 * On startup expects two words over the channel:
 *
 * 1) Desired sample frequency (in Hz)
 *
 * 2) Master clock frequency (in Hz)
 *
 * Then sample pairs:
 *
 * 1) Left sample
 *
 * 2) Right sample
 *
 * The data format is 24-bit signed left aligned in a 32-bit word.
 *
 * If a XS1_CT_END token is received, the thread stops and waits for new sample/master freq pair
 *
 * @param   p           S/PDIF tx port
 * @param   c           Channel-end for sample freq and samples
 */
void SpdifTransmit_4bitPort(buffered out port:32 p, chanend c);

/**
 * Configure out port to be clocked by clock block, driven from master clock input.
 *
 * Must be called before SpdifTransmit_4biPort()
 *
 * @param   p           S/PDIF tx port
 * @param   cl          Clock block to be used
 * @param   p_mclk      Master-clock input port
 */
void SpdifTransmitPortConfig_4bitPort(out buffered port:32 p, clock cl, in port p_mclk);

#endif

