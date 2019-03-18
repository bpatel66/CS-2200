The BOB-2200a Assembler
===============

To aid in testing your processor, we have provided an *assembler* for
the BOB-2200a architecture. The assembler supports converting text `.s`
files into either binary (for the simulator) or hexadecimal (for
pasting into Logisim) formats.

Requirements
-----------

The assembler runs on any version of Python 2.6+. An instruction set
architecture definition file is required along with the assembler. The
GT-2200a assembler definition is included.

Included Files
-----------

* `assembler.py`: the main assembler program
* `bob2200a.py`: the BOB-2200a assembler definition

Using the Assembler
-----------

### Assemble for Brandonsim

To output assembled code in hexadecimal (for use with *Brandonsim*):

    python assembler.py -i bob2200a --hex test.s

You can then open the resulting `test.hex` file in your favorite text
editor.  In Brandonsim, right-click on your RAM, select **Edit
Contents...**, and then copy-and-paste the contents of the hex file
into the window.

Do not use the Open or Save buttons in Brandonsim, as it will not
recognize the format.

Assembler Pseudo-ops
-----------

In addition to the syntax described in the BOB-2200a ISA reference,
the assembler supports the following *pseudo-instructions*:

* `.fill`: fills a word of memory with the literal value provided

For example, `mynumber: .fill 0x500` places `0x500` at the memory
location labeled by `mynumber`.

* `.word`: an alias for `.fill`
