#ifndef _SpdifReceive_h_
#define _SpdifReceive_h_
#include <xs1.h>

#define FRAME_X 9       // Left
#define FRAME_Y 5       // Right     
#define FRAME_Z 3       // Left (start of frame)


/** SPDIF receiver. 
 *
 * This function needs 1 thread and no memory other
 * than ~2800 bytes of program code. It can do 11025, 12000, 22050, 24000,
 * 44100, 48000, 88200, 96000, and 192000 Khz
 *
 * For a 100Mhz reference clock, use a divider
 * of 1 for 192000, 2 for 96000/88200, 4 for 48000/44100 on clock b. 
 * When the decoder
 * encounters a long series of zeros it will lower the divider; when it
 * encounters a short series of 0-1 transitions it will increase the divider.
 *
 * Output: whole word with bits 0-3 set to preamble.
 *
 * \param p S/PDIF output port
 * \param c channel to output samples to
 * \param initial_divider initial divide for initial estimate of sample rate
 * \param b clock block set to 100Mhz
 **/
void SpdifReceive(in buffered port:4 p, streaming chanend c, int initial_divider, clock b);

#endif // _SpdifReceive_h_
