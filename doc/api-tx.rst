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


An example program is shown below. An output port, a master-clock input port and a clock block must be
declared:

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::declaration
  :end-before: //::

  TBC.

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::data handling
  :end-before: //::

The main program in this example simply starts the S/PDIF transmit thread,
and the data generator thread in parallel:

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::main program
  :end-before: //::
