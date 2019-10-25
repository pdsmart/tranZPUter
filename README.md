## Foreword

This document is a work in progress.



## Overview

The Sharp MZ80A is based on the Z80 CPU running at 2MHz. It is vintage and under powered compared with modern computers (or Raspberry Pi). Besides being part of history, it has a software base that is useful from time to time and still has followers. A software Emulator could be written but this is an alternative, provide an upgrade than can power the machine with multiple different CPU's (in FPGA, ie. ZPU, 68000 etc) and also power it with a Z80 running upto 128MHz. This can be done by bus mastering where the original CPU is put into tri-state and the FPGA takes control of the bus.

Besides providing more powerful and alternative CPU's and memory, the FPGA can act as a Floppy Drive, Hard Drive etc using the connected SD Card and provide a menu system by overlaying the video memory when invoked.

This design is still in its infancy, many features have been tested and the schematic/pcb made, it is just a matter of the VHDL and software to be further developed.



## tranZPUter v1.0


##### 

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9630.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9631.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9636.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9637.jpg)

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9681.jpg)





## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice.



## Licenses

This design, hardware and software, is licensed under th GNU Public Licence v3.


