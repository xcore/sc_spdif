S/PDIF Transmit Demo
====================

.. toctree::

app_spdif_tx_example Quick Start Guide
--------------------------------------

This application uses the s/pdif tx module to demonstrate s/pdif transmission on an XCore processor.It is designed to run on the XMOS L16 Slicekit Core Board (XP-SKC-L16) in conjuction with an Audio Slice Card (XA-SK-AUDIO).

The functionality of the program is a follows:

    * Setup the audio hardware on the board as required, this includes Master clock selection and SPDIF output enable.
    * Generate a triangular wave and transmit it thru the s/pdif port of the audio Slice Card.


Hardware Setup
++++++++++++++

To setup the hardware:

    #. Connect the XA-SK-AUDIO slice card to the XP-SKC-L16 Slicekit core board using the connector marked with the ``CIRCLE``. 
    #. Connect the XTAG-2 USB debug adaptor to the XP-SKC-L16 Slicekit core board (via the supplied adaptor board)
    #. Connect the XTAG-2 to host PC (as USB extension cable can be used if desired)
    #. Connect the power supply to the XP-SKC-L16 Slicekit Core board
    #. Connect a s/pdif speaker or receiver to the s/pdif port of the Audio Slice Card with a co axial cable.

.. figure:: images/hw_setup.png
   :width: 300px
   :align: center

   Hardware Setup for S/PDIF transmit demo

Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTimeComposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``S/PDIF Transmit Demo`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTimeComposer. 
   #. Click on the ``app_spdif_tx_example`` item in the Explorer pane then click on the build icon (hammer) in xTimeComposer. Check the console window to verify that the application has built successfully.
