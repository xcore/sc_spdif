sc_spdif Change Log
===================

1.3.2
-----

  * Changes to dependencies:

    - sc_i2c: 2.4.0beta0 -> 2.4.1rc0

      + module_i2c_simple header-file comments updated to correctly reflect API

1.3.1
-----
    - Added .type and .size directives to SpdifReceive. This is required for the function to show up in xTIMEcomposer binary viewer

  * Changes to dependencies:

    - sc_i2c: 2.2.1rc0 -> 2.4.0beta0

      + i2c_shared functions now take i2cPorts structure as param (rather than externed). This allows for
      + module_i2c_simple fixed to ACK correctly during multi-byte reads (all but the final byte will be now be ACKd)
      + module_i2c_simple can now be built with support to send repeated starts and retry reads and writes NACKd by slave
      + module_i2c_shared added to allow multiple logical cores to safely share a single I2C bus
      + Removed readreg() function from single_port module since it was not safe

1.3.0
-----
    - Added this file
    - Removed xcommon dep
