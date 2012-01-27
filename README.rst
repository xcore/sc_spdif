S/PDIF 
...........

:Stable release:   unreleased

:Status:  Feature complete

:Description: Transmit and Receive S/PDIF streams.

:Maintainer:  https://github.com/henkmuller


The two modules in this library are used to transmit and receive
S/PDIF streams, http://en.wikipedia.org/wiki/Spdif. The rx_generator directory contains the programs that are used
to generate the state machine used
by the receiver.

Key Features
============

* RX and TX in separate threads
* Rates of 44,100 up to 192,000 Samples/sec

Firmware Overview
=================

RX and TX are defined as functions which each run forever.

Documentation
=============

Full documentation can be found at: http://xcore.github.com/sc_spdif/

Known Issues
============

none

Required Repositories
================

* xcommon git\@github.com:xmos/xcommon.git

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the maintainer for this line.
