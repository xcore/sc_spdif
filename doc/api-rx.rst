S/PDIF Receive
''''''''''''''

The S/PDIF receive module comprises a single thread that parses data as it
arrives on a one-bit port and that outputs words of data onto a streaming
channel end. Each word of data carries 24 bits of data and 4 bits of
channel information.

This module requires the reference clock to be exactly 100 MHz.


Symbolic constants
==================

.. doxygendefine:: FRAME_X

.. doxygendefine:: FRAME_Y

.. doxygendefine:: FRAME_Z

API
===

.. doxygenfunction:: SpdifReceive


Example
=======


An example program is shown below. An input port and a clock block must be
declared. Neither should be configured:

.. literalinclude:: app_example_rx/src/main.xc
  :start-after: //::declaration
  :end-before: //::

All data samples are being received on a streaming channel, after being
parsed by the receive process. After reading a sample value from the
channel, it must be converted to a signed sample value whilst removing the
tag identifying the channel information. In this example, we perform this
operation by masking off the bottom four bits and shifting the sample-data
into the most significant 24-bits, ready to be used on, for example, I2S:

.. literalinclude:: app_example_rx/src/main.xc
  :start-after: //::data handling
  :end-before: //::

The main program in this example simply starts the S/PDIF receive thread,
and the data handling thread in parallel:

.. literalinclude:: app_example_rx/src/main.xc
  :start-after: //::main program
  :end-before: //::
