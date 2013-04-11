S/PDIF receiver internal structure
==================================

The S/PDIF receiver is written as a state machine that receives bits and
processes those bits, progressively building up a word of received data
that is then sent out on a streaming chanend to the next layer in the
protocol.

The state machine is heavily optimised to run at 192K: a bit rate of 12.288
Mbits/second, requiring a sampling rate of 49.152 MHz. As such, it may look
cumbersome at first.

The state machine is written in assembly code; the assembly code comprises
fragments that are concatenated by a generator. Three sections discuss the
general principle of the receiver, the assembly code (SpdifReceive.S) and
the generator.

We assume that the reader is familiar with the S/PDIF standard.

Operating principle
-------------------

The receiver has an input port clocked of a clock block that is set to
sample the input stream at four times the bit rate. That means, that a zero
bit in S/PDIF encoding will appear as four low sampling points or four high
sampling points, and a one-bit will appear as two high followed by two low
sampling points or vice versa. As the port is sampling data, these will
arrive as sampling points 0, 0, 0, 0 (a zero-bit); 1, 1, 1, 1 (also a zero
bit); 0, 0, 1, 1 (a one-bit); or 1, 1, 0, 0 (a one bit).

These above are ideal sampling sequences; however, as the signal is clocked
asynchronously, the sequence 0, 0, 1, 1 may appear as 0, 1, 1, 1 or 0, 0,
0, 1. As the receiver software is not aware of the precise sampling clock,
it always runs the sampling clock slightly too fast: 50 MHz for a 192K and
12.5 Mhz for a 48K signal. This means that the sequence 0, 0, 1, 1 may also
appear as 0, 0, 1, 1, 1 or 0, 0, 0, 1, 1. Finally, if the signal is
received through an optical cable, the duty cycle is hardly ever 50%, also
causing a sequence 0, 0, 1, 1 to appear as 0, 0, 0, 1.

These values are sampled in a 4-bit buffered port. That is, the port will
collect four of those sampling bits, store them and pass them on for
processing. That means that on a 192 KHz signal that is sampled at 50 Mhz
we have 20 ns x 4 = 80 ns time to dispatch those 4 bits. As the port is
buffered, there is some leeway, in that the only strict requirement is
every second input from the port is processed in 160 ns. On a 62.5 MIPS
thread that leaves us with 5 instructions per input. (!).

Each time that a complete bit has been recovered, this bit is shifted into
the output-register, and the next bits are processed. The receiver
maintains a state of which bits are unprocessed: there are 72 states in the
code, and each state is labelled ``Lxy`` where ``x`` is a string of ones
and zeros, and ``y`` maybe one of ``_S``, ``_T``, or ``_U``. Ignoring the
last bit, the state ``Lx`` means that the receiver has processed all data
up to a point in the stream, and is left with a bit string ``x`` that is
yet to be processed. This string should be read left to right, with the
left being the oldest bit received, and right the most recent bit received.

For example, the state 'L0000' means that there is a sequence of four
unprocessed low samples. This may indicate a zero-bit in the SPDIF stream,
or, it maybe the start of a violation which will nominally comprise six low sample
points. It may also be a stream of eight zero bits, which indicates that we
are probably oversampling a slower SPDIF stream. The latter is the final
part of the system, which is the choice of the sampling clock. Whenever the
receiver observes a long string of low or a long string of high sampling
points, it will try and half the sampling clock. If it observes a string of
alternating high and low samples, then it will try and double the sampling
clock as it is probably a faster stream.

As 44,100 and 48,000 are only 10% apart in speed, both of those streams can
be dealt with by the same sampling clock; 12.5 MHz. 25 Mhz samples both
88,200 and 96,000 and a 50 MHz clock is used for 176,400 and 192,000
sampling rates. 

The ``_S`` states are used to indicate that a violation has been spotted,
``_T`` states indicate that the first transition after the violation has
been processed, and ``_U`` states that the second transition has also been
processed. At the time of the ``_T`` state transition the state machine
will have sufficient knowledge to know whether the next SPDIF word will be
an ``X``, ``Y``, or ``Z`` frame. It therefore outputs the word, and
initialises it with a value indicating what sort of frame is coming next.

Assembly code
-------------

The assembly code uses the following registers:

  * r0: the input port resource
  * r1: output chanend resource
  * r2: initial divider
  * r3: the clock block resource
  * r4: temporary value
  * r5: collected S/PDIF word
  * r6: overflow from S/PDIF word
  * r7: the value 1
  * r8: the value 0x1A
  * r9: the value 2
  * r10: the value 4
  * r11: the value 0

Each state comprises a block of code that follows the following pattern
that implements the state machine::

  L0111:
      IN   r4, r0
      BRU  r4
      BLRF_u10 L0000_1
      BLRB_u10 BERROR
      BLRB_u10 BERROR
      BLRB_u10 BERROR
      BLRB_u10 BERROR
      BLRB_u10 BERROR
      BLRB_u10 BERROR
      BLRB_u10 BERROR
      BLRF_u10 L0001_1
      BLRB_u10 BERROR
      BLRB_u10 BFASTER
      BLRB_u10 BERROR
      BLRF_u10 L0011_1
      BLRB_u10 BERROR
      BLRB_u10 L0111_1
      BLRB_u10 BERROR
    
The ``IN r4, r0`` instruction inputs the next four bits from the
port into r4, the ``BRU r4`` instruction performs a relative branch based on the
bit pattern just received, and the following 16 instructions then jump to
the next state. Note that all these instructions are architectural to stop
the assembler from allocating long encodings - it must all fit in short
encodings, any long encoding is a compile-time error.

The ``IN`` instruction inputs 4 bits with the least significant bit being the
oldest bit, and the most significant bit (bit 3) being the most recent bit.
This is reverse from the convention used for the label names, which is
slightly confusing. But at least the label names are written down as we
expect it from left to right...

So, inspecting the table, the first line says:

* Given that we had bits 0111 unprocessed, and we now receive bits 0000, we
  have received 01110000 which is a one-bit in the SPDIF stream (0111), and
  then 4 unprocessed bits (0000). Therefor we branch to label ``L0000_1``
  meaning state ``L0000`` and we need to record a ``1`` in the SPDIF input
  word.

The second line says:

* Given that we had bits 0111 unprocessed, and we now receive bits 1000
  (value 0001 reversed), we
  have received 01111000 which cannot be a valid part of the SPDIF stream.
  We therefore jump to an ERROR label to resynchronise.

And so on. note that there are BERROR and FERROR labels; BERROR jumps
backward, and FERROR jumps forward in order to make all labels fit in 10
bits. Similarly, there are FSLOWER and BSLOWER labels, etc.

As we have seen, some states need to have labels ``_0`` and
``_1`` to record that a zero-bit or one-bit has been received, and these
labels are typically implemented as follows::


  L0111_0:
      LMUL r6, r5, r11, r11, r5, r5
      BRFU L0111
  .align 4
  L0111_1:
      LMUL r6,r5,r5,r7,r5,r7
  L0111:
      ...

The LMUL instruction is a work of marvel that multiplies two numbers (the
third and fourth operands) and adds two more numbers (the fifth and sixth
operands) into a 64 bit number stored in the first two operands. So, the
first LMUL computes r11 x r11 + r5 + r5 = 0 x 0 + r5 + r5 = 2 x r5. This
shifts r5 left one bit, shifting any overflow into r6.
The second LMUL computes r5 x r7 + r5 + r7 = r5 x 1 + r5 + 1 = 2 x r5 + 1.
This shifts r5 left a bit and ors a one bit in the end, shifting any
overflow into r6. Other tricks that the receiver occasionally requires
shift two bits into r5 simultaneously (multiply by r10) etc.


The S, T, and U states work in a very similar manner, except that there are
entry points into those states to record whether the next SPDIF word will
be an X, Y, or Z frame. An example below is the L000_T state, which is the
state where three low samples are unprocessed, we have seen the second
transition on the violation, and there are entry points for whether this
transition signalled an X, Y, or Z frame::

  .align 4
  L000_TY:
      BITREV r5, r5
      OUT  r1,r5
      LADD r5,r6,r8,r11,r11
      BRFU L000_T
  .align 4
  L000_TZ:
      BITREV r5, r5
      OUT  r1,r5
      LADD r5,r6,r8,r9,r11
      BRFU L000_T
  .align 4
  L000_TX:
      BITREV r5, r5
      OUT  r1,r5
      LSUB r5,r6,r8,r7,r11
  L000_T:
      IN   r4, r0
      BRU  r4
      ...

In any case, the word is bit-reversed and output. The bit reverse is needed
as bits are transmitted least significant bit first over SPDIF, but we are
shifting them in to the left. After the output, r5 and r6 are initialised
using an LADD or LSUB instruction. LADD and LSUB perform an addition
(subtraction) with carry (borrow) into two registers: the answer and the
carry (borrow). A Y-initialisation adds r8 + r11 + r11 = 0x1A + 0 + 0 =
0x1A into r5 and r6. That is r5 will become 0x1A, and r6 will be 0. A
Z-initialisation adds r8 + r9 + r11 = 0x1A + 2 + 0 = 0x1C into r5, and 0
into r6, and finally an X-initialisation computes 0x1A - 1 - 0 = 0x19 into
r5 and 0 into r6.

Note that the initial value of r5 always has bit 4 set (0x19, 0x1A, 0x1C)
and r6 is initially always 0. When 28 bits have been shifted into r5, r5
will be one of 0x9sssssss, 0xAsssssss, or 0xCsssssss and r6 will be 1. This
indicates that we have received a full word of data, and is used in some
states to jump out of the state machine. On reversing the final value for
r5, we will end up with the 28 bits of the SPDIF sample in bits 4..31 and a
value of 0x9, 0x5 or 0x3 in the lowest nibble for an X, Y, or Z frame.

There are a few cases that are ambiguous; in particular whether a violation
has been received or a zero-bit. These are resolved using r6 in labels
Lx_CHOICE.

The generator
-------------

The generator glues together all states. It does so by finding a
permutation of the states that enables all jumps to be encoded in 10 bit
short operands. This takes a few iterations of a piece of java code.

The java code could also find states that overlap, and compile them into a
single state. This is not implemented at present.

All states are listed in the file ``states.csv`` in this directory. Each
state is listed in a row, with the 16 columns listing the 16 next states.
These states are listed in order of our left-to-right convention; the
actual value input from the port is listed in row 1. This table is
generated from the states directory in the generator. You will note that
this directory only contains state starting with a '1', as SPDIF is
completely symmetrical, the generator will from that create all identical
states starting with '0'.

Notes
-----

#. Normally, on an ERROR a sample of 4 bits is thrown away, and the next 4
   bits are used to dispatch to the first state. If compiled with -DTEST it
   will return on an error, this is useful when debugging the state
   machine.

#. The FASTER function is limited to a clock divider of 1 - it will never
   go to a 100 MHz clock.

#. The SLOWER function is limited to a clock divider of 8. Attempting to go
   slower than that will set the divider back to 1, this is to avoid
   aliasing causing a signal to appear slower than it really is.

#. The initial value of r5 has bit 5 set, this will cause it to
   still lock, even though the ERROR might have been thrown around the
   first bit.

#. The state machine can be interrupted by sending a control token over the
   channel. The control token will be read and the function will return.
   This goes through an event enable on the input stream, and the event
   vector being set up for address ``parseSpDifTerminate``.

