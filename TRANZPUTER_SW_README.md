## Foreword

The tranZPUter and tranZPUter SW are actively being developed and changes are reflected in the documentation on a regular basis.

The tranZPUter SW is an offshoot from the tranZPUter project and utilises a Freescale K64F processor as the IO Control processor as opposed to the ZPU in the original tranZPUter project.

During testing of the tranZPUter v1.0 and with the advent of the RFS v2.0 upgrade with CP/M it was noticed that the tranZPUter should be updated so that the Z80 had additional memory
and was able to run at higher clock frequencies. It should also run independent of the controlling IO processor, ie. the ZPU Evo on FPGA fabric.

V1.0 of the tranZPUter had design restrictions which in all honesty make the project much harder to complete, for example, because of my lack of experience soldering BGA (Ball Grid Array)
IC's, I chose the next best thing, a pre-fab FPGA board, the CYC1000 with the FPGA already soldered. This device and all other possibilities for the given size and FPGA ALM requirements had
too few general I/O pins. This meant that multiplexing had to be used with tri-state register latches. KISS comes back to mind, Keep It Simple Stupid! So in order to further the concept
and design I took a step back, looked at what was needed at the Z80 side to realise the CP/M requirements and looked at what was needed for the controlling IO Processor. As I am still not
happy about soldering a 30+ pound IC where only an X-Ray machine can validate that it was soldered correctly, I opted for a powerful mini-development board, the Teensy 3.5 which has more
than enough general I/O pins and is 5V tolerant, hence this interim design (which is actually better for anyone who is a software programmer and is not happy with electronics or VHDL yet 
wants to enhance a Z80 machine). Everything will be written in C/C++ and once working, I can take the bold step into speccing a tranZPUter v2.0 with a BGA knowing that the ZPU will run all
the software just written.



## Overview

The Sharp MZ80A is based on the Z80 CPU running at 2MHz. It is vintage and under powered compared with modern computers (or a Raspberry Pi). Besides being part of history, it has a software
base that is useful from time to time and still has followers. A software Emulator could be written to prolong the usage of the software but there is something special about using original
hardware and this is an alternative to keep the machine original yet provide an upgrade that can power the machine with additional processing capabilities, storage and with multiple different
CPU's based in software like the PiCoPro on the BBC Micro. This is all made possible with bus mastering where the original CPU is tri-stated and the K64F takes control of the bus and the
underlying original mainboard peripherals, when needed.

The upgrade also extends the Z80 hardware capabilities by providing additional RAM to allow for a 64K version of CP/M and to increase the speed of the processor whilst maintaining the
original speed when accessing the Sharp MZ80A motherboard peripherals.

This design is a work in progress, working in tandem with the tranZPUter. The C/C++ control software written for the tranZPUter SW will also work on the tranZPUter under the ZPU.

As the design replaces a Z80 in-situ it is not limited to the MZ80A but can be used in any Z80 based computer with the right software adaptations.



## tranZPUter SW

The tranZPUter gets its name from: A TRANsformable ZPU compuTER as the base CPU in the original tranZPUter is the ZPU Evo. The ZPU Evo provides the Menu, SD, Video Overlay services to the
Sharp MZ80A by tri-stating the original Z80 and accessing the MZ80A memory and peripherals as though they were ZPU devices.

The tranZPUter SW makes an improvement on the Z80 hardware and uses a Freescale K64F ARM Cortex-M4 in place of the ZPU Evo. As the K64F is a software solution rather than the ZPU Evo which
is based on VHDL in an FPGA, the project adds the suffix SW for *S*oft*W*are.

To provide different CPU's it is just a matter of taking existing CPU emulators, for example those used in the PiCoPro and adapting them to use the CPU signals on the MZ80A bus via this
designs interface. The program memory could either be that on the MZ80A or the faster K64F memory. ie. There is no real need to use the MZ80A memory when using a soft CPU. The benefits
of using a soft CPU is potentially better performance albeit this is yet to be determined as the K64F only runs at 120MHz. The design of the tranZPUter SW upgrades the Z80 hardware and can
clock the processor, detached from the Sharp MZ80A motherboard, at much higher clock rates, potentially to 20MHz using the Z8400 20MHz CPU. Higher CPU performance will be a benefit to
programs such as CP/M or databases such as DBase II.

In the gallery are pictures of the current design and files uploaded onto github are relatively stable, WIP files wont be uploaded as they are in constant flux.


### Hardware

![Sheet 1](../images/tranZPUterSW_v1_0-2.png)

The basics of this design lie in Z80 bus mastering, ie. the ability to switch the Z80 out of circuit and control the computer as required. Bus mastering was typically used by devices such as
DMA for fast transfer of data from an I/O device to memory, or memory to memory for applications such as video/graphics. The device taking control of the Z80 bus could transfer data much
faster than the Z80 running a program, hence the benefit.

In this design, the bus mastering is used in a similar vein, taking control of the Z80 bus to transfer data between main memory and an SD Card or between the I/O processor and the Video display
buffer for presentation of menu's. It is also used where a soft processor completely idle's the hard Z80 and acts as the main computer CPU. ie. using a soft CPU emulator, it can process
applications in local memory and slow down to access I/O and the Video buffer on the host machine as needed presenting a completely different computing experience. Imagine, a 6809 or a 68000
based Sharp MZ80A!

The design centres around lifting the original Z80 onto a daughter card and rerouting several of its signals such that they can be controlled as needed. In order to be able to run programs
for other Sharp models (ie.MZ-700) or 64K CP/M the design adds a 512KB Static RAM device with necessary paging logic. As the design needs to be flexible at this stage on memory remapping
(ie. mapping blocks of the underlying Sharp MZ80A address space out and mapping in blocks of the 512Kbyte static RAM), a programmable decoder in the form of a Flash RAM is used. This allows
maximum flexibility during development to settle on a final set of memory maps for required functionality and a v2.0 of this project can use hardwired logic in a PAL/GAL rather than the Flash RAM
to save cost and board space.

The above schematic has been designed such that no IO processor is needed, just plug this board into the Z80 socket on the Sharp MZ80A, update the RFS software and you have an enhanced machine. Add the
IO Control processor (a Teensy 3.5) and suddenly a whole new range of options becomes available. Using this design it will be easier to use an FPGA in place of the Teensy 3.5 for the final 
tranZPUter project.

![Sheet 2](../images/tranZPUterSW_v1_0-3.png)

The second schematic is the Teensy 3.5 development board which comes in a 48pin DIL package (outline, has more pins underneath), ideal to place onto a project board. It contains the Freescale K64F processor, an SD card and USB logic
to upload programs into its memory. Very little supporting hardware is needed to enable the Teensy3.5 to control the Z80 in this project.

### PCB

As per previous schematics and PCB boards, this project has been designed with KiCad Schematic Capture and PCB Layout. Below are the finished boards awaiting components and assembly.

![PCB TopSide](../images/tranZPUterSW_v1_PCB_TopSide.jpg)

![PCB UnderSide](../images/tranZPUterSW_v1_PCB_UnderSide.jpg)


### Software

The existing ZPU software, ZPUTA and zOS have been ported to the K64F platform in anticipation of forwarding this design with rapid application development. Please see the [zSoft](/zsoft/) section for details
on current OS status.

Tools for the Teensy are stored in the \<z-tools> directory to aid in development and keeping consistent tested versions within the repository.

    
### Paths

For ease of reading, the following shortnames refer to the corresponding path in this chapter. Two repositories are used, the primary one for the [tranZPUter](https://github.com/pdsmart/tranZPUter) and [zSoft](https://github.com/pdsmart/zSoft) for the software developments.

*zSoft Repository (software)*


|  Short Name      |                                                                            |
|------------------|----------------------------------------------------------------------------|
| \[\<ABS PATH>\]  | The path where this repository was extracted on your system.               |
| \<z-apps\>       | \[\<ABS PATH>\]/zsoft/apps                                                 |
| \<z-build\>      | \[\<ABS PATH>\]/zsoft/build                                                |
| \<z-common\>     | \[\<ABS PATH>\]/zsoft/common                                               |
| \<z-libraries\>  | \[\<ABS PATH>\]/zsoft/libraries                                            |
| \<z-teensy3\>    | \[\<ABS PATH>\]/zsoft/teensy3                                              |
| \<z-include\>    | \[\<ABS PATH>\]/zsoft/include                                              |
| \<z-startup\>    | \[\<ABS PATH>\]/zsoft/startup                                              |
| \<z-iocp\>       | \[\<ABS PATH>\]/zsoft/iocp                                                 |
| \<z-zOS\>        | \[\<ABS PATH>\]/zsoft/zOS                                                  |
| \<z-zputa\>      | \[\<ABS PATH>\]/zsoft/zputa                                                |
| \<z-rtl\>        | \[\<ABS PATH>\]/zsoft/rtl                                                  |
| \<z-docs\>       | \[\<ABS PATH>\]/zsoft/docs                                                 |
| \<z-tools\>      | \[\<ABS PATH>\]/zsoft/tools                                                |

*tranZPUter Repository*

|  Short Name      |                                                                            |
|------------------|----------------------------------------------------------------------------|
| \<cpu\>          | \[\<ABS PATH>\]/tranZPUter/cpu                                             |
| \<build\>        | \[\<ABS PATH>\]/tranZPUter/build                                           |
| \<devices\>      | \[\<ABS PATH>\]/tranZPUter/devices                                         |
| \<docs\>         | \[\<ABS PATH>\]/tranZPUter/docs                                            |
| \<pcb\>          | \[\<ABS PATH>\]/tranZPUter/pcb                                             |
| \<roms\>         | \[\<ABS PATH>\]/tranZPUter/software/roms                                   |
| \<schematics\>   | \[\<ABS PATH>\]/tranZPUter/schematics                                      |
| \<software\>     | \[\<ABS PATH>\]/tranZPUter/software                                        |
| \<tools\>        | \[\<ABS PATH>\]/tranZPUter/software/tools                                  |



### Tools

All development has been made under Linux, specifically Debian/Ubuntu. Besides the standard Linux buildchain, the following software is needed.

|                                                           |                                                                                                                     |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
[ZPU GCC ToolChain](https://github.com/zylin/zpugcc)        | The GCC toolchain for ZPU development. Install into */opt* or similar common area.                                  |
[Arduino](https://www.arduino.cc/en/main/software)          |  The Arduino development environment, not really needed unless adding features to the K64F version of zOS from the extensive Arduino library. Not really needed, more for reference. |
[Teensyduino](https://www.pjrc.com/teensy/td_download.html) | The Teensy3 Arduino extensions to work with the Teensy3.5 board at the Arduino level. Not really needed, more for reference. |

For the Teensy3.5/K64F the ARM compatible toolchain is stored in the repo within the build tree.

#### Memory Decoder Tool

The tranZPUterSW uses a 512KB Flash RAM as the active decoder. This was chosen intentionally to allow multiple different memory maps so as the development progressed the tranZPUter SW
could run software from the MZ80K/C/B/700/800 machines as they all are very similar just with different memory maps (graphics can differ but the [MZ80A Colour Board](/sharpmz-upgrades-80col/)
does a pretty good job at providing compatible video and it will be upgraded shortly with MZ80B/800 capable pixel graphics.

In order to generate the decoder bit map I have written a tool in C which creates the map based on internal coding. The internal coding uses Z80 sigals so it is relatively straight
forward to say 'Memory map 5, Z80 WR and Addr:0xE800:EFFF has tranZPUter RAM mapped into it'. This tool will be extended as development progresses.

To use it and create a bit map, clone the [repository](https://github.com/pdsmart/tranZPUter.git) and follow the steps below:

```
1. Change to <software>/src/tools/ directory and issue command:
   make
   make install
2. Run the command:
   <tools>/flashmmcfg -o <roms>/tranZPUterDecoderMappingFile.bin
3. Flash the file:<roms>/tranZPUterDecoderMappingFile.bin  to
   a suitable 512KB Flash RAM.
```

```
The tool currently has the following options:o

FLASHMMCFG v1.0

Options:-
  -h | --help              This help test.
  -i | --io-addr <addr>    Base address for the IO Control Registers.
  -o | --output <file>     Output the final binary image to the given file. This file is programmed into the Flash RAM.
  -v | --verbose           Output more messages.

Examples:
  flashmmcfg --output Decode1.bin --io-addr 0x20       Create the mapping binary using 0x20 as the base address for the IO Control Registers.
```

Adding decoding options is a matter of editting the file \<software\>/src/tools/flashmmcfg.c and adding suitable clauses in the setMap() method. I will add more detail how to do it
in this document later.

More software details specific to this board will appear here as development progresses.

### Flash Teensy3.5

All the necessary files and executables to program the Teensy can be found in the \<z-tools> directory within the [zSoft](/zsoft/) repository, 

To program the Teensy after an OS build, follow the steps below:

```
1. Connect the teensy 3.5 board to your PC with the USB cable.
2. Launch the Teensy programming application: 
   \<z-soft>/teensy 
3. In the Teensy application, select File->Open HEX file and navigate to the \<z-zOS> or \z<zputa> directory (depending on which OS your uploading) and select the file 'main.hex'.
4. Press the RESET button on the Teensy 3.5
5. In the Teensy application, select Operation->Program - this programs the onboard Flash RAM.
6. Ensure you have a terminal emulator open configured to the virtual serial device (if unsure, issue the 'dmesg' command from within Linux to see the latest USB attachment and its name). Normally the device is /dev/ttyACM0. There is no need to set the Baud rate or Bits/Parity, this is a virtual serial port and operates at USB speed.
7. In the Teensy application, select Operation->Reboot - this will now reboot the K64F and it will startup running zOS or ZPUTA.
8. Interact with the OS via the terminal emulator. 
```
For further information, see the Teensy [basic usage guid](https://www.pjrc.com/teensy/td_usage.html).

### To Do
1. Write the ZPU C/C++ code to take control of the MZ80A, save/update/restore the Video Memory (for Menu system), convert the MisTer Main/sharpmz application.? Menu/control code, and additional glue to use the SD card.<br/>
2. Look into converting the PiCoPro soft processors to work with the K64F. Both are ARM based so should be possible.


## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice. All 3rd party software, to my knowledge and research, is open source and freely useable, if there is found to be any component with licensing restrictions, it will be removed from this repository and a suitable link/config provided.


## Licenses

This design, hardware and software, is licensed under the GNU Public Licence v3.

### The Gnu Public License v3
 The source and binary files in this project marked as GPL v3 are free software: you can redistribute it and-or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

 The source files are distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/.
