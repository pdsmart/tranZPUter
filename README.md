## Foreword

The tranZPUter is actively being developed and will be reflected in this document.



## Overview

The Sharp MZ80A is based on the Z80 CPU running at 2MHz. It is vintage and under powered compared with modern computers (or a Raspberry Pi). Besides being part of history, it has a software base that is useful from time to time and still has followers. A software Emulator could be written to prolong the usage of the software but there is something special about using original hardware and this is an alternative to keep the machine original yet provide an upgrade that can power the machine with multiple different CPU's (in FPGA, ie. ZPU, 68000 etc) and also power it with a Z80 running upto 128MHz. This is done by bus mastering where the original CPU is tri-stated and the FPGA takes control of the bus.

Besides providing more powerful and alternative CPU's and memory, the FPGA can also act as a Floppy Drive, Hard Drive etc using the connected SD Card and provide a menu system by overlaying the video memory when invoked.

This design is still a work in progress, I stopped development when I needed to advance the ZPU Evo SDRAM controller which I had been putting off for a while. The SDRAM is critical as the Cyclone 10LP on the CYC1000 has limited BRAM, only enough for the cache and IOCP Bootloader. Many features have been tested and the schematic/pcb made, it is just a matter of furthering the VHDL now that the SDRAM controller works and to develop the C/C++ code to provide the menu/SD services (already done in the ZPU code base).

I chose the CYC1000 as the FPGA solution as I am not competent soldering BGA devices, also at US$30 it is quite a cost effective choice. For software minded people, it is not that difficult to use a Pi Zero W or similar in place of the CYC1000 just a reworking of the PCB and interface logic, but that is a project for another time.

As the design replaces a Z80 in-situ it is not limited to the MZ80A but can be used in any Z80 based computer with the right software.



## tranZPUter

The tranZPUter gets its name from: A TRANsformable ZPU compuTER as the base CPU in the FPGA will be the ZPU Evo. The ZPU Evo will provide the Menu, SD, Video Overlay services to the Sharp MZ80A by tri-stating the original Z80 and accessing the MZ80A memory and peripherals as though they were ZPU devices.

To provide different CPU's it is just a matter of mapping in VHDL the softcore CPU signals to the MZ80A bus via this designs interface. The program memory could either be that on the MZ80A or the faster SDRAM. ie. There is no real need to use the MZ80A memory when using a softcore CPU. In my SharpMZ Emulator I run a Z80 at 112MHz using FPGA BRAM but tests show at least 128MHz is sustainable, thus a softcore Z80 CPU running at 128MHz with 48K BRAM slowing down only for MZ80A peripheral access would see a 64x boost in program run, which for say CP/M or database use is very desirable.

In the gallery are pictures of the current design and files uploaded onto github are relatively stable, WIP files wont be uploaded as they are in constant flux.


### Hardware

![Sheet 1](../images/tranZPUter_v1_1.png)

The basics of this design lie in Z80 bus mastering, ie. the ability to switch the Z80 out of circuit and control the computer as required. Bus mastering was typically used by devices such as DMA for fast transfer of data from an I/O device to memory, or memory to memory 
for applications such as video/graphics. The device taking control of the Z80 bus could transfer data much faster than the Z80 running a program, hence the benefit.

In this design, the bus mastering is used in a similar vein, taking control of the Z80 bus to transfer data between main memory and an SD Card or between the I/O processor and the Video display buffer for presentation of menu's. It is also used where a soft processor
completely idle's the hard Z80 and acts as the main computer CPU. ie. using a soft T-80 ZPU CPU, it can process applications at 128MHz in local memory and slow down to access I/O and the Video buffer on the host machine.

The design centres around lifting the original Z80 onto a daughter card and rerouting several of its signals such that they can be controlled as needed. The core of the design is an FPGA, the Altera Cyclone 10LP on a mini development board made by Trenz Electronics.
This could quite easily be a Raspberry Pi or Teensy 3.6 but the aim of this project is to design electronic hardware in an FPGA using VHDL and making use of the ZPU Processor I have been working on in a seperate project.

The choice of the Trenz Electronic development board put a number of restrictions on the design in so much as it only provides limited I/O facilities. There were not so many other choices of pre-built FPGA development boards with the same size and features to choose from
and designing an FPGA directly into the design from project onset was considered too much a risk because my experience with BGA (Ball Grid Array) packaging and soldering of them was almost zero (I have reballed existing chips but those were working designs!).

As there were limited I/O facilities, I had to make use of two 16bit tri-state buffer latches in an addressed mode rather than a 1:1 mode. ie. The Z80 Data, Address and Control lines eminating out of the FPGA have to be 'set' one word at a time, ie. write data to latch, write address
to latch, write control signals to latch etc. This slows down the speed at which the FPGA can control the Z80 host (to be honest, a 100MHz FPGA can run 50 operations and still match the 2MHz original bus speed) and complicates the logic by requirement of FSM's in VHDL.

It is further complicated by the fact that the signals controlling the latches have themselves to be written in an addressed mode rather than direct, again due to lack of I/O facilities on the FPGA board. Thus in the schematic above you can see IC U6 & U8 being written to via
the common 16bit data bus (shared with the latches) and clocked by a single output signal from the FPGA. A delay line is used such that a write to the latch is performed by signal CYC_CTL/RST going high, this reaches the latch ~8ns after the same signal connected to the Master Reset goes high, thus clocking in the
data. The latches are reset when CYC_CTL/RST goes low and this is enough to control the 16 bit latches U5 & U9. ie. to write a 16bit word into U5 the procedure would be:
```
CYC_CTL/RST low
Set CYC_D0:7 to 0x02 (ADDR_LE active, low)
Set CYC_CTL/RST high, data on CYC_D0:7 is latched into U6/U8 and ADDR_LE goes active enabling transfer of data on CYC_D0:15 into U5 registers (latches on the rising edge of ADDR_LE).
Set required data on CYC_D0:15 that will be passed across to the Z80 BUS.
Set CYC_CTL/RST low, ADDR_LE goes inactive (high) and the data on CYC_D0:15 is latched into U5
```

Once the FPGA FSM is fine tuned, the actual write and read to/from the Z80 bus will be transparent but it is overly complicated as mentioned due to lack of I/O on the Trenz development board. 


### To Do
1. Write the ZPU C/C++ code to take control of the MZ80A, save/update/restore the Video Memory (for Menu system), convert the Main/sharpmz.? Menu/control code, and additional glue to use the SD card.<br/>
2. Convert the T80 CPU to act as a Z80 upgrade for the MZ80A.


## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice. All 3rd party software, to my knowledge and research, is open source and freely useable, if there is found to be any component with licensing restrictions, it will be removed from this repository and a suitable link/config provided.


## Licenses

This design, hardware and software, is licensed under the GNU Public Licence v3.

### The Gnu Public License v3
 The source and binary files in this project marked as GPL v3 are free software: you can redistribute it and-or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

 The source files are distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/.
