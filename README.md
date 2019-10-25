## Foreword

This document is a work in progress.



## Overview

The Sharp MZ80A is based on the Z80 CPU running at 2MHz. It is vintage and under powered compared with modern computers (or a Raspberry Pi). Besides being part of history, it has a software base that is useful from time to time and still has followers. A software Emulator could be written to prolong the usage of the software but there is something special about using original hardware and this is an alternative to keep the machine original yet provide an upgrade that can power the machine with multiple different CPU's (in FPGA, ie. ZPU, 68000 etc) and also power it with a Z80 running upto 128MHz. This is done by bus mastering where the original CPU is tri-stated and the FPGA takes control of the bus.

Besides providing more powerful and alternative CPU's and memory, the FPGA can also act as a Floppy Drive, Hard Drive etc using the connected SD Card and provide a menu system by overlaying the video memory when invoked.

This design is still in its infancy, many features have been tested and the schematic/pcb made, it is just a matter of the VHDL and software being further developed.

As the design replaces a Z80 in-situ it is not limited to the MZ80A but can be used in any Z80 based computer with the right software.



## tranZPUter v1.0


##### 

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9630.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9631.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9636.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9637.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9681.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9640.jpg)





## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice.



## Licenses

This design, hardware and software, is licensed under th GNU Public Licence v3.


