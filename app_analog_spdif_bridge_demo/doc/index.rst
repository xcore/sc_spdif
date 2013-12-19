Analog to S/PDIF Bridge Demo quickstart guide
=============================================

This application is a demonstration for analog audio to S/PDIF converstion using xCORE multicore microcontrollers. The appication receives the audio signal through the i2s bus from the audio codec and transmits it through the S/PDIF out.


Hardware Setup
++++++++++++++

The following hardware components are required:

   * xTAG-2 (xTAG Connector Board)
   * XA-SK-XTAG2 (sliceKIT xTAG Adaptor)
   * XP-SKC-L16 (sliceKIT L16 Core Board)
   * XA-SK-AUDIO (Audio SliceCARD)

XP-SKC-L16 sliceKIT Core board has four slots with edge connectors: SQUARE, CIRCLE, TRIANGLE and STAR, and one chain connector marked with a CROSS.

To setup the hardware:

#. Connect the XA-SK-AUDIO slice card to the XP-SKC-L16 sliceKIT core board using the connector marked with the ``CIRCLE``. 
#. Connect the XTAG-2 USB debug adaptor to the XP-SKC-L16 sliceKIT core board (via the supplied adaptor board)
#. Connect the XTAG-2 to host PC (an USB extension cable can be used if desired)
#. Connect the power supply to the XP-SKC-L16 sliceKIT Core board
#. Connect a S/PDIF speaker or receiver to the S/PDIF port of the Audio Slice Card with a coaxial cable.
#. Connect an audio source such as an iPod or laptop audio out to the analog in 1 (``In 1-2``).


.. figure:: images/hw_setup.*
   :align: center

   Hardware Setup for S/PDIF transmit demo

|newpage|

Import and Build the Application
++++++++++++++++++++++++++++++++

#. Open xTIMEcomposer and open the edit perspective (Window->Open Perspective->XMOS Edit).
#. Locate the ``Analog to S/PDIF Bridge Demo`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. 
#. This will also cause the modules on which this application depends to be imported as well.
#. Click on the ``app_analog_spdif_bridge_demo`` item in the Explorer pane and then click on the build icon (hammer) in xTIMEcomposer.
#. Check the console window to verify that the application has built successfully.


For help in using xTIMEcomposer, try the xTIMEcomposer tutorial, which you can find by selecting :menuitem:`Help, Tutorials` from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select a module in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quickstart guide within the Developer Column.
   
Run the application
-------------------

Now that the application has been compiled, the next step is to run it on the sliceKIT Core Board using the tools to load the application over JTAG (via the xTAG-2 and xTAG Adaptor card) into the xCORE multicore microcontroller.

#. Select the file ``main.xc`` in the src folder in the ``app_analog_spdif_bridge`` project from the Project Explorer.
#. Click on the ``Run`` icon (the white arrow in the green circle).
#. At the ``Select Device`` dialog select ``XMOS xTAG-2 connect to L1[0..1]`` and click ``OK``.

Now the analog audio input could be received digitally from the S/PDIF output of the audio slice.

Next steps
----------

#. Examine the application code. In xTIMEcomposer Studio navigate to the ``src`` directory under ``app_analog_spdif_bridge_demo`` and double click on the ``main.xc`` file within it. The file will open in the central editor window.
#. Try changing the ``SAMPLE_FREQUENCY_HZ`` define in ``i2s_spdif_conf.h`` to 48000, 88200, 96000, 176400 or 192000 to generate S/PDIF signal at those frequencies.
