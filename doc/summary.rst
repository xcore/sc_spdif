SPDIF software
==============

S/PDIF, or Sony/Philips Digital Interface is a protocol to transmit audio
data over either coaxial or optical cables. The data transmission rate is
determined by the transmitter, and the receiver has to recover the sample
rate.

Important characteristics of S/PDIF software are the following:

* The number of audio channels. Typical values are 2 (stereo), or 6 (5.1
  surround). 

* The sample rate(s) supported. Typical values are 44.1, 48, 96, and 192
  Khz. Some systems require only a single frequency to be supported, others
  need to support all frequencies and need to auto-detect the frequency.

* Transmit and Receive support. Some systems require only S/PDIF output, or
  only S/PDIF input. Others require both.


module_spdif_tx
---------------

This module can transmit S/PDIF signals at the following rates
(assuming XXX threads on a 400 MHz part):

+---------------------------+-----------------------+------------------------+
| Functionality provided    | Resources required    | Status                 | 
+----------+----------------+------------+----------+                        |
| Channels | Sample Rate    | 1-bit port | Memory   |                        |
+----------+----------------+------------+----------+------------------------+
| 2        | up to 192 KHz  | 1-2        | TBC      | Implemented and tested |
+----------+----------------+------------+----------+------------------------+
| 4        | up to 96 KHz   | 1-2        | TBC      | Implemented and tested |
+----------+----------------+------------+----------+------------------------+
| 8        | up to 48 KHz   | 1-2        | TBC      | Implemented and tested |
+----------+----------------+------------+----------+------------------------+

It requires a single thread to run the transmit code. The number of 1-bit
ports depends on whether the master clock is already available on a one-bit
port. If available, then only a single 1-bit port is required to output
S/PDIF. If not, then two ports are required, one for the signal output, and
one for the master-clock input.

An external flip-flop is required to resynchronise the data signal to the
master-clock if more than 2 channels are used, or if the sample rate is
higher than 48 KHz. 

The precise transmission frequencies supported depend on the availability
of an external clock (eg, a PLL or a crystal oscillator) that runs at a
frequency of::

  channels * sampleRate * 64

or a power-of-2 multiple. For example, for 2 channels at 192 Khz the
external clock has to run at a frequency of 24.576 MHz. This same frequency
also supports 2 channels at 48 KHz (which requires a minimum frequency of
6.144 MHz). If both 44,1 and 48 Khz frequencies are to be supported, both a
24.587 MHz and a 22.579 MHz master clock is required. This is normally not
an issue since the same clocks can be used to drive the audio codecs.

Typical applications for this module include iPod docks, digital microphones,
digital mixing desks, USB audio, and AVB.

module_spdif_rx
---------------


This module can receive S/PDIF signals at three different rates. It
automatically adjusts to the incoming rate, but for high rates a fast
thread is required. The thread will fail silently if it does not have
enough MIPS to parse the input stream.

+---------------------------+------------------------------------+------------------------+
| Functionality provided    | Resources required                 | Status                 | 
+----------+----------------+------------+--------+--------------+                        |
| Channels | Sample Rate    | 1-bit port | Memory | Thread rate  |                        |
+----------+----------------+------------+--------+--------------+------------------------+
| 2        | up to 192 KHz  | 1          | 3 KB   | 80 MIPS      | Implemented and tested |
+----------+----------------+------------+--------+--------------+------------------------+
| 4        | up to 96 KHz   | 1          | 3 KB   | 40 MIPS      | Implemented and tested |
+----------+----------------+------------+--------+--------------+------------------------+
| 8        | up to 48 KHz   | 1          | 3 KB   | 20 MIPS      | Implemented and tested |
+----------+----------------+------------+--------+--------------+------------------------+

The receiver does not require any external clock, but can only recover
44.1, 48, 88.2, 96, and 192 KHz sample rates.

Typical applications for this module include digital speakers,
digital mixing desks, USB audio, and AVB.
