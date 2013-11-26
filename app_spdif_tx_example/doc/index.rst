S/PDIF Transmit Demo quickstart guide
=====================================

This application uses the S/PDIF transmit component to demonstrate S/PDIF transmission on an xCORE controller.It is designed to run on the XMOS L16 sliceKIT Core Board (XP-SKC-L16) in conjuction with an Audio sliceCARD (XA-SK-AUDIO).

The functionality of the program is as follows:

* Setup the audio hardware on the board as required. This includes Master clock selection and S/PDIF output enable.
* Generate a triangular wave and transmit it through the S/PDIF port of the audio sliceCARD.


Hardware Setup
++++++++++++++

The following hardware components are required:

   * xTAG-2 (xTAG Connector Board)
   * XA-SK-XTAG2 (sliceKIT xTAG Adaptor)
   * XP-SKC-L16 (sliceKIT L16 Core Board)
   * XA-SK-AUDIO (Audio SliceCARD)

XP-SKC-L16 sliceKIT Core board has four slots with edge connectors: SQUARE, CIRCLE, TRIANGLE and STAR, and one chain connector marked with a CROSS.

To setup the hardware:

#. Connect the XA-SK-AUDIO slice card to the XP-SKC-L16 Slicekit core board using the connector marked with the ``CIRCLE``. 
#. Connect the XTAG-2 USB debug adaptor to the XP-SKC-L16 Slicekit core board (via the supplied adaptor board)
#. Connect the XTAG-2 to host PC (an USB extension cable can be used if desired)
#. Connect the power supply to the XP-SKC-L16 Slicekit Core board
#. Connect a S/PDIF speaker or receiver to the S/PDIF port of the Audio Slice Card with a coaxial cable.

.. figure:: images/hw_setup.*
   :align: center

   Hardware Setup for S/PDIF transmit demo

|newpage|

Import and Build the Application
++++++++++++++++++++++++++++++++

#. Open xTimeComposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
#. Locate the ``S/PDIF Transmit Demo`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTimeComposer. 
#. Click on the ``app_spdif_tx_example`` item in the Explorer pane.
#. This will also cause the modules on which this application depends to be imported as well.
#. This application depends on ``module_spdif_tx`` only.
#. Click on the ``app_spdif_tx_example`` item in the Explorer pane then click on the build icon (hammer) in xTIMEcomposer.
#. Check the console window to verify that the application has built successfully.


For help in using xTIMEcomposer, try the xTIMEcomposer tutorial, which you can find by selecting :menuitem:`Help, Tutorials` from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select a module in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quickstart guide within the Developer Column.
   
Run the application
-------------------

Now that the application has been compiled, the next step is to run it on the sliceKIT Core Board using the tools to load the application over JTAG (via the xTAG-2 and xTAG Adaptor card) into the xCORE multicore microcontroller.

#. Select the file ``main.xc`` in the src folder in the ``app_example_tx`` project from the Project Explorer.
#. Click on the ``Run`` icon (the white arrow in the green circle).
#. At the ``Select Device`` dialog select ``XMOS xTAG-2 connect to L1[0..1]`` and click ``OK``.

Now if you connect the S/PDIF output of the audio slice to a speaker you could hear the sound.

Next steps
----------

#. Examine the application code. In xTIMEcomposer Studio navigate to the ``src`` directory under ``app_spdif_tx_example`` and double click on the ``main.xc`` file within it. The file will open in the central editor window.
#. Try changing the ``SAMPLE_FREQUENCY_HZ`` define on line 12 of ``spdif_conf.h`` to 48000, 88200, 96000, 176400 or 192000 to generate s/pdif signal at those frequencies.
