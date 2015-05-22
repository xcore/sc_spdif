sc_spdif Change Log
===================

1.3.4
-----
    - Changes to RX codebase to allow running on xCORE-200

1.3.3
-----


  * Changes to dependencies:

    - sc_i2c: 2.4.1rc1 -> 3.0.0alpha1

      + Read support added to module_i2c_single_port (xCORE 200 only)
      + Retry on NACK added to module_i2c_single_port (matches module_i2c_simple)
      + module_i2c_single_port functions now takes struct for port resources (matches module_i2c_simple)
      + module_i2c_simple removed from module_i2c_shared dependancies. Allows use with other i2c modules.
        It is now the applications responsibilty to include the desired i2c module as a depenancy.
      + Data arrays passed to write_reg functions now marked const

1.3.2
-----

  * Changes to dependencies:

    - sc_i2c: 2.4.0beta0 -> 2.4.1rc1

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
