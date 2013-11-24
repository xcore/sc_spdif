Programming guide
-----------------

The S/PDIF transmit component requires a one-bit buffered output port (with transfer width of 32), a clock block, and a master clock coming in on an unbuffered one-bit port. Externally, a flip-flop should resynchronise the edges of the signal for any signal above 48 KHz. In order to set-up the ports, the master clock should be delayed in order for the external signal and the internal update to not coincide. The function ``SpdifTransmitPortConfig`` is provided for this purpose.

This component runs on a single logical core. The logical core takes the following parameters and data through a xCONNECT link.
   #. The S/PDIF transmission frequency in Hz.
   #. The master clock frequency in Hz.

Once the transmission frequency and master clock frequency are sent to the core, the audio data could be sent thru the link.

Usage Example
-------------
The ``S/PDIF TRANSMIT DEMO`` application generates a triangle sound wave on the SPDIF interface on  the audio sliceCARD. On this board the master clock input is from the CS2100-CP programmable PLL chip.
. The program is shown below (excluding code to set up the PLL on the board). 

An output port, a master-clock input port and a clock block must be declared:

.. literalinclude:: app_spdif_tx_example/src/main.xc
  :start-after: //::declaration
  :end-before: //::

In this example ``transmitSpdif`` function sets up the clock and starts the transmit function to receive on a link.

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::spdif core
  :end-before: //::

The generate function sends configuration settings over the link then generates signal triangle wave signal and sends the data.

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::data generation
  :end-before: //::

The example starts by setting up the PLL on the board. Then it starts 2 cores:
   * S/PDIF transmit
   * the data generator
An link connects the generator and the transmit core.

.. literalinclude:: app_example_tx/src/main.xc
  :start-after: //::main program
  :end-before: //::



