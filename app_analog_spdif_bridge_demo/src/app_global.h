
#ifndef _APP_GLOBAL_H_
#define _APP_GLOBAL_H_

#include <xs1.h>
#include <platform.h>

/* Core that Audio Slice is connected to */
#define AUDIO_IO_CORE 		            1


/**************/
/* Audio clocking defines */
/* Master clock defines (Hz) */
#define MCLK_FREQ_441                   (512*44100)   /* 44.1, 88.2 etc */
#define MCLK_FREQ_48                    (512*48000)   /* 48, 96 etc */

#if (SAMPLE_FREQUENCY_HZ%22050==0)
#define MCLK_FREQ                       MCLK_FREQ_441
#elif (SAMPLE_FREQUENCY_HZ%24000==0)
#define MCLK_FREQ                       MCLK_FREQ_48
#else
#error Unsupported sample frequency
#endif



#endif /* ifndef _GLOBAL_H_ */

