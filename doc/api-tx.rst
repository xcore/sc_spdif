S/PDIF Transmit
'''''''''''''''

This module is a single thread that receives samples over a channel and that
outputs data on the port.

The S/PDIF transmit module require a one-bit buffered output port (with transfer width of 32), a clock block,
and a master clock coming in on an unbuffered one-bit port.


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

