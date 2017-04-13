#include <xs1.h>
#include <xclib.h>
#include <print.h>

#define VALIDITY        0x00000000      /* Validity bit (x<<28) */

void SpdifTransmitPortConfig_4bitPort(out buffered port:32 p, clock clk, in port p_mclk)
{
    /* Clock clock block from master-clock */
    configure_clock_src(clk, p_mclk);

    /* Clock S/PDIF tx port from MClk */
    configure_out_port_no_ready(p, clk, 0);

    /* Set delay to align SPDIF output to the clock at the external flop */
    set_clock_fall_delay(clk, 7);

    /* Start the clockblock ticking */
    start_clock(clk);
}



/* Returns parity for a given word */
static int inline parity32(unsigned x)
{
    crc32(x, 0, 1);
    return (x & 1);
}

extern unsigned dataWords_1_Nibble[16];

extern unsigned dataWords_1[256];
extern unsigned preableWords_1[3];


extern unsigned dataWords_2[16];
extern unsigned preableWords_2[3];

extern unsigned dataWords_4[32];
extern unsigned preambleWords_4[6];


/* void my_partout(out buffered port:32 p, unsigned n, unsigned val)
 *
 * This function converts 8/16 data bits to 32-bit value and outputs it to the 32-bit port buffer.
 *
 * Parameters:
 * port p : 4-bit XCORE port, must be declared as 'out buffered port:32'
 * unsigned n: data length 8 or 16
 * unsigned val: value to send
*/
void my_partout(out buffered port:32 p, unsigned n, unsigned val)
{
    if (n == 16)
        // send 16 bits to port in 2 steps: insert zeroes in each 8-bit part and send 32 bit to port, repeat
    {
       unsigned long long res = 0;      // 64-bit value
       unsigned int data = val & 0xFF;  // get low 8-bit = [x x x x ... b7 b6 ... b0]
       res = zip(0, data, 0);   // convert to [0 x 0 x ... b7 0 b6 0 ... 0 b0]
       res &= 0xFFFFFFFF;       // get low 32-bit part

       data = zip(0, res, 0);   // convert again to [0 0 0 x 0 0 0 x ... b7 0 0 0 b6 ... 0 0 0 b0]
       p <: data; // send low 32 bits to port [0 0 0 b7 0 0 0 b6 ... 0 0 0 b0]


       data = (val >> 8) & 0xFF; //get bits from 15 to 8 = [x x x x ... b15 b14 ... b8]
       res = zip(0, data, 0);    // convert to [0 x 0 x ... b15 0 b14 0 ... 0 b8]
       res &= 0xFFFFFFFF;        // get low 32-bit part

       data = zip(0, res, 0);   // convert again to [0 0 0 x 0 0 0 x ... b15 0 0 0 b14 ... 0 0 0 b8]
       p <: data; // send low 32 bits to port [0 0 0 b15 0 0 0 b14 ... 0 0 0 b8]

    }
    else if (n == 8)
        // send 8 bits to port in 1 steps: insert zeroes and send 32 bit to port
    {
        unsigned long long res = 0;
        unsigned int data = val & 0xFF;
        res = zip(0, data, 0); // convert to [0 x 0 x ... b7 0 b6 0 ... 0 b0]

        res &= 0xFFFFFFFF;

        data = zip(0, res, 0); // convert again to [0 0 0 x 0 0 0 x ... b7 0 0 0 b6 ... 0 0 0 b0]
        p <: data; // send low 32 bits to port [0 0 0 b7 0 0 0 b6 ... 0 0 0 b0]
    }
}


/* E.g. 24MHz -> 192kHz */
void SpdifTransmit_4bitPort_1(out buffered port:32 p, chanend c_tx0, const int ctrl_left[2], const int ctrl_right[2])
{
    unsigned word;
    unsigned xor = 0;
    unsigned encoded_preamble, encoded_word;

    unsigned sample, sample2, control, preamble, parity;

    /* Check for new frequency */
    if (testct(c_tx0))
    {
        chkct(c_tx0, XS1_CT_END);
        return;
    }

    /* Get L/R samples */
    sample = inuint(c_tx0) >> 4 & 0x0FFFFFF0 ;
    sample2 = inuint(c_tx0);

#pragma unsafe arrays
    while (1)
    {
        int controlLeft  = ctrl_left[0];
        int controlRight = ctrl_right[0];
        int newblock = 2;

        for (int i = 0 ; i < 192; i++)
        {

            /* Left sample */
            control = (controlLeft & 1) << 30;
            preamble = newblock ;
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;

            /* Preamble */
            encoded_preamble = preableWords_1[word & 0xF];
            encoded_preamble ^= xor;
            my_partout(p, 8, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 8) >> 8;     /* xor = 0xFFFFFFFF * ((encoded_preamble & 0x8000) == 0x8000); */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 4;

            /* Lookup remaining 28 bits, 8/4 bits at a time */
            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            my_partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 8;

            newblock = 0;
            controlLeft >>=1;

            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            my_partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 8;

            encoded_word = dataWords_1_Nibble[word & 0xF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            my_partout(p, 8, encoded_word);
            xor = __builtin_sext(encoded_word, 8) >> 8;         /* xor = 0xFFFFFFFF * ((encoded_word & 0x8000) != 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 4;

            sample = sample2 >> 4 & 0x0FFFFFF0 ;

            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            my_partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */

            /* Right sample */

            control = (controlRight & 1)<<30;
            preamble = (1);
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;


            /* Preamble */
            encoded_preamble = preableWords_1[word & 0xF];
            encoded_preamble ^= xor;
            my_partout(p, 8, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 8) >> 8;     /* xor = 0xFFFFFFFF * ((encoded_preamble & 0x8000) == 0x8000);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 4;

            /* Lookup remaining 28 bits, 8/4 bits at a time */
            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            my_partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 8;

            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            my_partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0); */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 8;

            controlRight >>=1;

            encoded_word = dataWords_1_Nibble[word & 0xF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            my_partout(p, 8, encoded_word);
            xor = __builtin_sext(encoded_word, 8) >> 8;         /* xor = 0xFFFFFFFF * ((encoded_word & 0x8000) != 0); */
                                                                /* Replace with sext(encoded_word,1) */
            word = word >> 4;

            /* Test for new frequency */
            if (testct(c_tx0))
            {
                chkct(c_tx0, XS1_CT_END);
                return;
            }

            /* Get new samples... */
            sample = inuint(c_tx0) >> 4 & 0x0FFFFFF0 ;
            sample2 = inuint(c_tx0);

            encoded_word = dataWords_1[word & 0xFF];
            encoded_word ^= xor;                                /* Xor to invert data if lsab of last data was a 1 */
            my_partout(p, 16, encoded_word);
            xor = __builtin_sext(encoded_word, 16) >> 16;       /* xor = 0xFFFFFFFF * (encoded_word < 0);  */
                                                                /* Replace with sext(encoded_word,1) */
            if (i == 31) {
                controlLeft = ctrl_left[1];
                controlRight = ctrl_right[1];
            }
        }
    }
}

/* Divide by 2, e.g 24 -> 96khz */
void SpdifTransmit_4bitPort_2(out buffered port:32 p, chanend c_tx0, const int ctrl_left[2], const int ctrl_right[2])
{
    unsigned word;
    unsigned xor = 0;
    unsigned encoded_preamble, encoded_byte;

    unsigned sample, sample2, control, preamble, parity;

    clearbuf(p);

#pragma unsafe arrays
    while (1)
    {
        int controlLeft  = ctrl_left[0];
        int controlRight = ctrl_right[0];
        int newblock = 2;

        for (int i = 0; i < 192; i++)
        {
            /* Check for new frequency */
            if (testct(c_tx0))
            {
                chkct(c_tx0, XS1_CT_END);
                return;
            }

            /* Input samples */
            sample = inuint(c_tx0) >> 4 & 0x0FFFFFF0 ;
            sample2 = inuint(c_tx0);

            control = (controlLeft & 1)<<30;
            preamble = newblock ;
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;

            /* Output left sample */

            /* Preamble */
            encoded_preamble = preableWords_2[word & 0xF];
            encoded_preamble ^= xor;
            my_partout(p, 16, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 16) >> 16;
            word = word >> 4;

            newblock = 0;
            controlLeft >>=1;

            /* Lookup remaining 28 bits, 4 bits at a time */
#pragma unsafe arrays
#pragma loop unroll(7)
            for (int i = 0; i < 7; i++)
            {
                encoded_byte = dataWords_2[word & 0xF];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                my_partout(p, 16, encoded_byte);
                xor = __builtin_sext(encoded_byte, 16) >> 16;
                word = word >> 4;
            }

            sample = sample2 >> 4 & 0x0FFFFFF0 ;

            control = (controlRight & 1)<<30;
            preamble = (1);
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;

            /* Output right sample */

            /* Preamble */
            encoded_preamble = preableWords_2[word & 0xF];
            encoded_preamble ^= xor;
            my_partout(p, 16, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 16) >> 16;
            word = word >> 4;

            controlRight >>=1;

            /* Lookup remaining 28 bits, 4 bits at a time */
#pragma unsafe arrays
#pragma loop unroll(7)
            for (int i = 0; i < 7; i++)
            {
                encoded_byte = dataWords_2[word & 0xF];
                encoded_byte ^= xor;  // Xor to invert data if lsab of last data was a 1
                my_partout(p, 16, encoded_byte);
                xor = __builtin_sext(encoded_byte, 16) >> 16;
                word = word >> 4;
            }

            if (i == 31) {
                controlLeft = ctrl_left[1];
                controlRight = ctrl_right[1];
            }
        }
    }
}



/* Divide by 4, e.g 24 -> 48khz */
void SpdifTransmit_4bitPort_4(buffered out port:32 p, chanend c_tx0, const int ctrl_left[2], const int ctrl_right[2])
{
    unsigned word;
    unsigned xor = 0;
    unsigned encoded_preamble, encoded_byte;

    unsigned sample, control, preamble, parity, sample2;

    clearbuf(p);

#pragma unsafe arrays
    while (1)
    {
        int controlLeft  = ctrl_left[0];
        int controlRight = ctrl_right[0];
        int newblock = 2;

        for (int i = 0 ; i<192; i++)
        {
            /* Check for new sample frequency */
            if (testct(c_tx0))
            {
                /* Swallow control token and return */
                chkct(c_tx0, XS1_CT_END);
                return;
            }

            /* Input left and right samples */
            sample = inuint(c_tx0) >> 4 & 0x0FFFFFF0 ;
            sample2 = inuint(c_tx0);

            /* Create status bit */
            control = (controlLeft & 1) << 30;
            preamble = newblock ;

            /* Generate parity bit */
            parity = parity32(sample | control | VALIDITY) << 31;

            /* Generate complete 32bit word */
            word = preamble | sample | control | parity | VALIDITY;

            /* Output left sample */

            /* Look up preamble and output */
            encoded_preamble = preambleWords_4[(word & 0xF)*2+1];
            encoded_preamble ^= xor;
            my_partout(p, 16, encoded_preamble);

            encoded_preamble = preambleWords_4[(word & 0xF)*2];
            encoded_preamble ^= xor;
            my_partout(p, 16, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 16) >> 16;
            word = word >> 4;

            newblock = 0;
            controlLeft >>=1;

            /* Lookup remaining 28 bits, 4 bits at a time */
#pragma unsafe arrays
#pragma loop unroll(7)
            for (int i = 0; i < 7; i++)
            {
                encoded_byte = dataWords_4[(word & 0xF)*2+1];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                my_partout(p, 16, encoded_byte);
                encoded_byte = dataWords_4[(word & 0xF) * 2];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                my_partout(p, 16, encoded_byte);
                xor = __builtin_sext(encoded_byte, 16) >> 16;
                word = word >> 4;
            }

            sample = sample2 >> 4 & 0x0FFFFFF0 ;

            /*  Output right sample */

            control = (controlRight & 1)<<30;
            preamble = (1);
            parity = parity32(sample | control | VALIDITY) << 31;
            word = preamble | sample | control | parity | VALIDITY;

            /* Look up and output pre-amble, 2 bytes at a time */
            encoded_preamble = preambleWords_4[(word & 0xF)*2+1];
            encoded_preamble ^= xor;
            my_partout(p, 16, encoded_preamble);

            encoded_preamble = preambleWords_4[(word & 0xF)*2];
            encoded_preamble ^= xor;
            my_partout(p, 16, encoded_preamble);
            xor = __builtin_sext(encoded_preamble, 16) >> 16;
            word = word >> 4;

            controlRight >>=1;


            /* Lookup remaining 28 bits, 4 bits at a time */
#pragma unsafe arrays
#pragma loop unroll(7)
            for (int i = 0; i < 7; i++)
            {
                encoded_byte = dataWords_4[(word & 0xF)*2+1];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                my_partout(p, 16, encoded_byte);
                encoded_byte = dataWords_4[(word & 0xF) * 2];
                encoded_byte ^= xor;  /* Xor to invert data if lsab of last data was a 1 */
                xor = __builtin_sext(encoded_byte, 16) >> 16;
                word = word >> 4;
                my_partout(p, 16, encoded_byte);
            }

            if (i == 31) {
                controlLeft = ctrl_left[1];
                controlRight = ctrl_right[1];
            }
        }
    }
}


void SpdifTransmitError_4bitPort(chanend c_in)
{

#if 0
    printstr("Sample Frequency and Master Clock Frequency combination not supported\n");
#endif

    while(1)
    {
        /* Keep swallowing samples until we get a sample frequency change */
        if (testct(c_in))
        {
            chkct(c_in, XS1_CT_END);
            return;
        }

        inuint(c_in);
        inuint(c_in);
    }
}

/* Defines for building channel status words */
#define CHAN_STAT_L        0x00107A04
#define CHAN_STAT_R        0x00207A04

#define CHAN_STAT_44100    0x00000000
#define CHAN_STAT_48000    0x02000000
#define CHAN_STAT_88200    0x08000000
#define CHAN_STAT_96000    0x0A000000
#define CHAN_STAT_176400   0x0C000000
#define CHAN_STAT_192000   0x0E000000

#define CHAN_STAT_WORD_2   0x0000000B


/* S/PDIF transmit thread */
void SpdifTransmit_4bitPort(buffered out port:32 p, chanend c_in)
{
    int chanStat_L[2], chanStat_R[2];
    unsigned divide;

    /* Receive sample frequency over channel (in Hz) */
    unsigned  samFreq = inuint(c_in);

    /* Receive master clock frequency over channel (in Hz) */
    unsigned  mclkFreq = inuint(c_in);

    /* Create channel status words based on sample freq */
    switch(samFreq)
    {
        case 44100:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_44100;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_44100;
            break;

        case 48000:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_48000;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_48000;
            break;

        case 88200:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_88200;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_88200;
            break;

        case 96000:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_96000;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_96000;
            break;

        case 176400:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_176400;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_176400;
            break;

        case 192000:
            chanStat_L[0] = CHAN_STAT_L | CHAN_STAT_192000;
            chanStat_R[0] = CHAN_STAT_R | CHAN_STAT_192000;
            break;

        default:
            /* Sample frequency not recognised.. carry on for now... */
            chanStat_L[0] = CHAN_STAT_L;
            chanStat_R[0] = CHAN_STAT_R;
            break;

    }
    chanStat_L[1] = CHAN_STAT_WORD_2;
    chanStat_R[1] = CHAN_STAT_WORD_2;

    /* Calculate required divide */
    divide = mclkFreq / (samFreq * 2 * 32 * 2);

    switch(divide)
    {
        case 1:
            /* Highest sample freq supported by mclk freq, eg: 24 -> 192 */
            SpdifTransmit_4bitPort_1(p,  c_in, chanStat_L, chanStat_R);
            break;

        case 2:
            /* E.g. 24 -> 96 */
           SpdifTransmit_4bitPort_2(p, c_in, chanStat_L, chanStat_R);
           break;

        case 4:
            /* E.g. 24MHz -> 48kHz */
            SpdifTransmit_4bitPort_4(p, c_in, chanStat_L, chanStat_R);
            break;

        default:
            /* Mclk does not support required sample freq */
            SpdifTransmitError_4bitPort(c_in);
            break;
    }
}


