S/PDIF transmit
---------------

Requires a clock-block and two ports: a one bit buffered output port (transfer width of 32)
and a one bit unbuffered input port with the master clock. On the outside
you will need a flip-flop to resynchronise the signal with the master
clock.

Call the configuration function to set up the clock.

* ``SpdifTransmitPortConfig(onebitPort, clockblock, masterClockPort)``

Then call the function that outputs data:

* ``SpdifTransmit(oneBitPort, dataChannel)``

The transmit function will in a loop expect on the channel
* The sample frequency (in Hz as an int)
* The master clock frequency (in Hz as an int)
* Left and right sample values (each 32 bits, left aligned)
* An END control token if either of the frequencies needs changing. 

S/PDIF receive
--------------

The S/PDIF receiver is generated from a state machine description. The
generated code requires a one bit buffered input port (transfer width of
4), and a clock block to work. Call:

* ``SpdifReceive(oneBitPort, dataChannel, initialDivider, clockBlock)``

Set the initial divider to 1, 2, or 4 depending on whether you expect
192000, 96000/88290, or 48000/44100 sample rates. The reference clock must
be 100 MHz

The function will in a loop output samples to the dataChannel; bits 4..27
represent the data value, and bits 0..3 are set to one of FRAME_X, FRAME_Y
or FRAME_Z to indicate Left, Right, or Start of frame data. The function
does not return unless compiled in DEBUG mode in which case it returns any
time that it loses synchronisation.

image:: test.svg
