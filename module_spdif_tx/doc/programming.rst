S/PDIF Transmit
'''''''''''''''

This component runs on a single logical core that receives samples over a channel and that outputs data on the port.

The S/PDIF transmit component requires a one-bit buffered output port (with transfer width of 32), a clock block, and a master clock coming in on an unbuffered one-bit port. Externally, a flip-flop should resynchronise the edges of the signal for any signal above 48 KHz. In order to set-up the ports, the master clock should be delayed in order for the external signal and the internal update to not coincide. The function ``SpdifTransmitPortConfig`` is provided for this purpose.


API
===

Call SpdifTransmitPortConfig to set up the clock and then call SpdifTransmit to output data.

.. doxygenfunction:: SpdifTransmitPortConfig

.. doxygenfunction:: SpdifTransmit
