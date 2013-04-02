S/PDIF Transmit
'''''''''''''''

*This section is to be completed*

There are two modules that can produce an S/PDIF signal. The simplest
module is a single thread that receives samples over a channel and that
outputs data on the port, and the other module has a thread that receives
samples over a channel and it produces the output on a channel. The latter
is useful if the S/PDIF output port is on a different core.

The S/PDIF transmit modules require a one-bit output port, a clock block,
and a master clock coming in on a one-bit port. Externally, a flip-flop
should resynchronise the edges of the signal for any signal above 48 KHz.
In order to set-up the ports, the master clock should be delayed in order
for the external signal and the internal update to not coincide. The
function ``SpdifTransmitPortConfig`` is provided for this purpose.


API
===

.. doxygenfunction:: SpdifTransmitPortConfig

.. doxygenfunction:: SpdifTransmit

Example
=======


An example program is shown below::

  TBC.
