S/PDIF Transmit
'''''''''''''''

*This section is to be completed*

There are two modules that can produce an S/PDIF signal. The simplest
module is a single thread that receives samples over a channel and that
outputs data on the port, and the other module has a thread that receives
samples over a channel and it produces the output on a channel. The latter
is useful if the S/PDIF output port is on a different core.

The S/PDIF transmit modules require a one-bit output port, a clock block,
and a master clock coming in on a one-bit port.


API
===

.. doxygenfunction:: SpdifTransmitPortConfig

.. doxygenfunction:: SpdifTransmit



Example
=======


An example program is shown below::

  TBC.
