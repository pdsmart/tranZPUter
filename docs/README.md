## Foreword

This document is a work in progress.



## Overview

The Sharp MZ80A is based on the Z80 CPU running at 2MHz. It is vintage and under powered compared with modern computers (or a Raspberry Pi). Besides being part of history, it has a software base that is useful from time to time and still has followers. A software Emulator could be written to prolong the usage of the software but there is something special about using original hardware and this is an alternative to keep the machine original yet provide an upgrade that can power the machine with multiple different CPU's (in FPGA, ie. ZPU, 68000 etc) and also power it with a Z80 running upto 128MHz. This is done by bus mastering where the original CPU is tri-stated and the FPGA takes control of the bus.

Besides providing more powerful and alternative CPU's and memory, the FPGA can also act as a Floppy Drive, Hard Drive etc using the connected SD Card and provide a menu system by overlaying the video memory when invoked.

This design is still a work in progress, I stopped development when I needed to advance the ZPU Evo SDRAM controller which I had been putting off for a while. The SDRAM is critical as the Cyclone 10LP on the CYC1000 has limited BRAM, only enough for the cache and IOCP Bootloader. Many features have been tested and the schematic/pcb made, it is just a matter of furthering the VHDL now that the SDRAM controller works and to develop the C/C++ code to provide the menu/SD services (already done in the ZPU code base).

I chose the CYC1000 as the FPGA solution as I am not competent soldering BGA devices, also at US$30 it is quite a cost effective choice. For software minded people, it is not that difficult to use a Pi Zero W or similar in place of the CYC1000 just a reworking of the PCB and interface logic, but that is a project for another time.

As the design replaces a Z80 in-situ it is not limited to the MZ80A but can be used in any Z80 based computer with the right software.



## tranZPUter v1.0

The tranZPUter gets its name from: A TRANsformable ZPU compuTER as the base CPU in the FPGA will be the ZPU Evo. The ZPU Evo will provide the Menu, SD, Video Overlay services to the Sharp MZ80A by tri-stating the original Z80 and accessing the MZ80A memory and peripherals as though they were ZPU devices.

To provide different CPU's it is just a matter of mapping in VHDL the softcore CPU signals to the MZ80A bus via this designs interface. The program memory could either be that on the MZ80A or the faster SDRAM. ie. There is no real need to use the MZ80A memory when using a softcore CPU. In my SharpMZ Emulator I run a Z80 at 112MHz using FPGA BRAM but tests show at least 128MHz is sustainable, thus a softcore Z80 CPU running at 128MHz with 48K BRAM slowing down only for MZ80A peripheral access would see a 64x boost in program run, which for say CP/M or database use is very desirable.

Below are pictures of the current design and files uploaded onto github are relatively stable, WIP files wont be uploaded.

#### To Do
a) Write the ZPU C/C++ code to take control of the MZ80A, save/update/restore the Video Memory (for Menu system), convert the Main/sharpmz.? Menu/control code, and additional glue to use the SD card.<br/>
b) Convert the T80 CPU to act as a Z80 upgrade for the MZ80A.

### Images of the tranZPUter daughter board
##### 

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9630.jpg)
Underside of the daughter board showing a 40pin standoff connector. The original Z80 CPU is removed, located onto the daughter board which is then connected by the 40pin standoff to the main board.

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9631.jpg)
Topside of the daughter board without the Z80 or CYC1000 devices.

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9637.jpg)
Topside of the daughter board with the Z80 and CYC1000 in place.

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9681.jpg)
The original motherboard, the tranZPUter daughter board is located top right and the 40/80 column and RFS daughter boards can also be seen in place.

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9636.jpg)
A test to verify that the board sits correctly within the MZ80A computer.

![alt text](https://github.com/pdsmart/tranZPUter/blob/master/docs/IMG_9640.jpg)
A power on test and verification.


## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice.



## Licenses

This design, hardware and software, is licensed under th GNU Public Licence v3.


