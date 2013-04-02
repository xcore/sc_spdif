S/PDIF Transmit
'''''''''''''''

This module is a single thread that receives samples over a channel and that
outputs data on the port.

There are two modules that can produce an S/PDIF signal. The simplest
module is a single thread that receives samples over a channel and that
outputs data on the port, and the other module has a thread that receives
samples over a channel and it produces the output on a channel. The latter
is useful if the S/PDIF output port is on a different core.

The S/PDIF transmit module require a one-bit buffered output port
(with transfer width of 32), a clock block, and a master clock
coming in on an unbuffered one-bit port. Externally, a flip-flop
should resynchronise the edges of the signal for any signal above 48 KHz.
In order to set-up the ports, the master clock should be delayed in order
for the external signal and the internal update to not coincide. The
function ``SpdifTransmitPortConfig`` is provided for this purpose.


API
===

Call SpdifTransmitPortConfig to set up the clock then SpdifTransmit to output data.

.. doxygenfunction:: SpdifTransmitPortConfig

.. doxygenfunction:: SpdifTransmit

Example
=======

This example generates a triangle sound wave on the SPDIF interface from a USB Audio 2.0 multichannel interface board. On this board the master clock input is from a PLL. The program is shown below (excluding code to set up the PLL on the board). 

An output port, a master-clock input port and a clock block must be declared:

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::declaration
  :end-before: //::

In this example transmitSpdif sets up the clock and starts the transmit function to receive on a chanend.

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::spdif thread
  :end-before: //::

The generate function sends configuration settings over a channel then a triangle wave.

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::data generation
  :end-before: //::

The example starts by setting up the PLL on the board. Then it creates 3 threads:
   * S/PDIF transmit
   * the data generator
   * clock generator for the PLL
An XC channel connects the generator and the transmit thread.

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::main program
  :end-before: //::

