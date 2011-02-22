S/PDIF Rx and Tx
================

The two modules in this library are used to transmit and receive
S/PDIF streams

S/PDIF transmit
---------------

Requires a clock-block and two ports: a one bit buffered output port (transfer width of 32)
and a one bit unbuffered input port with the master clock. On the outside
you will need a flip-flop to resynchronise the signal with the master
clock.

Call the configuration function to set up the clock.

SpdifTransmitPortConfig(onebitPort, clockblock, masterClockPort)

Then call one of four functions to output data:

  void SpdifTransmit_1(oneBitPort, dataChannel, ctrl_left[2], ctrl_right[2])
  void SpdifTransmit_2(oneBitPort, dataChannel, ctrl_left[2], ctrl_right[2])
  void SpdifTransmit_4(oneBitPort, dataChannel, ctrl_left[2], ctrl_right[2])

Depending on whether the master clock is 1, 2, or 4 times the bit rate.
The transmit function will in a loop read a word of dataChannel, and
transmit it over the oneBitPort. To stop the function send an END control
token over the data channel. The four integers supplied are the control
words that are to be transmitted with the S/PDIF stream.

S/PDIF receive
--------------

The S/PDIF receiver is generated from a state machine description. The
generated code requires a one bit buffered input port (transfer width of
4), and a clock block to work. Call:

SpdifReceive(oneBitPort, dataChannel, initialDivider, clockBlock)

Set the initial divider to 1, 2, or 4 depending on whether you expect
192000, 96000/88290, or 48000/44100 sample rates. The reference clock must
be 100 MHz

The function will in a loop output samples to the dataChannel; bits 4..27
represent the data value, and bits 0..3 are set to one of FRAME_X, FRAME_Y
or FRAME_Z to indicate Left, Right, or Start of frame data. 
