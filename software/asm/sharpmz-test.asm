;--------------------------------------------------------------------------------------------------------
;-
;- Name:            sharpmz-test.asm
;- Created:         October 2018
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series tester utility.
;-                  This assembly language program is a quick coding to aid in testing components
;-                  of the SharpMZ Series FPGA emulation and more recently the tranZPUter
;-                  and video module offshoots. It is a rough and ready program just to aid
;-                  exercising of hardware changes to verify they work and are reliable.
;-
;-                  Currently it aids in testing:
;-                      1. Tape Read
;-                      2. Tape Write
;-                      3. Memory Test
;-                      4. Graphics RAM Test
;-
;- Credits:         
;- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         October 2018   - Merged 2 utilities to create this compilation.
;-                  September 2020 - Updated to enable testing of the Video Module v2.0
;-
;--------------------------------------------------------------------------------------------------------
;- This source file is free software: you can redistribute it and-or modify
;- it under the terms of the GNU General Public License as published
;- by the Free Software Foundation, either version 3 of the License, or
;- (at your option) any later version.
;-
;- This source file is distributed in the hope that it will be useful,
;- but WITHOUT ANY WARRANTY; without even the implied warranty of
;- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;- GNU General Public License for more details.
;-
;- You should have received a copy of the GNU General Public License
;- along with this program.  If not, see <http://www.gnu.org/licenses/>.
;--------------------------------------------------------------------------------------------------------

GETL:                   EQU     00003h
LETNL:                  EQU     00006h
NL:                     EQU     00009h
PRNTS:                  EQU     0000Ch
PRNT:                   EQU     00012h
MSG:                    EQU     00015h
MSGX:                   EQU     00018h
MROMINIT:               EQU     00000h
MONIT:                  EQU     00086h
ST1:                    EQU     00095h
PRTHL:                  EQU     003BAh
PRTHX:                  EQU     003C3h
DPCT:                   EQU     00DDCh
?BRK:                   EQU     00D11h
?RSTR1:                 EQU     00EE6h
TPSTART:                EQU     010F0h
MEMSTART:               EQU     01200h
GRAMSTART:              EQU     0C000h
GRAMEND:                EQU     0FFFFh
MSTART:                 EQU     0B800h
MEMCHKEND:              EQU     0B8H

;-----------------------------------------------
; IO ports in hardware and values.
;-----------------------------------------------
MMCFG                   EQU     060H                                     ; Memory management configuration latch.
SETXMHZ                 EQU     062H                                     ; Select the alternate clock frequency.
SET2MHZ                 EQU     064H                                     ; Select the system 2MHz clock frequency.
CLKSELRD                EQU     066H                                     ; Read clock selected setting, 0 = 2MHz, 1 = XMHz
SVCREQ                  EQU     068H                                     ; I/O Processor service request.
CPLDCFG                 EQU     06EH                                     ; Version 2.1 CPLD configuration register.
CPLDSTATUS              EQU     06EH                                     ; Version 2.1 CPLD status register.
CPLDINFO                EQU     06FH                                     ; Version 2.1 CPLD version information register.
PALSLCTOFF              EQU     0D3H                                     ; set the palette slot Off position to be adjusted.
PALSLCTON               EQU     0D4H                                     ; set the palette slot On position to be adjusted.
PALSETRED               EQU     0D5H                                     ; set the red palette value according to the PALETTE_PARAM_SEL address.
PALSETGREEN             EQU     0D6H                                     ; set the green palette value according to the PALETTE_PARAM_SEL address.
PALSETBLUE              EQU     0D7H                                     ; set the blue palette value according to the PALETTE_PARAM_SEL address.
VMBORDER                EQU     0F3H                                     ; Select VGA Border colour attributes. Bit 2 = Red, 1 = Green, 0 = Blue.
GRAMMODE                EQU     0F4H                                     ; MZ80B Graphics mode.  Bit 0 = 0, Write to Graphics RAM I, Bit 0 = 1, Write to Graphics RAM II. Bit 1 = 1, blend Graphics RAM I output on display, Bit 2 = 1, blend Graphics RAM II output on display.
VMPALETTE               EQU     0F5H                                     ; Select Palette:
                                                                         ;    0xF5 sets the palette. The Video Module supports 4 bit per colour output but there is only enough RAM for 1 bit per colour so the pallette is used to change the colours output.
                                                                         ;      Bits [7:0] defines the pallete number. This indexes a lookup table which contains the required 4bit output per 1bit input.
                                                                         ; GPU:
GPUPARAM                EQU     0F6H                                     ;    0xF6 set parameters. Store parameters in a long word to be used by the graphics command processor.
                                                                         ;      The parameter word is 128 bit and each write to the parameter word shifts left by 8 bits and adds the new byte at bits 7:0.
GPUCMD                  EQU     0F7H                                     ;    0xF7 set the graphics processor unit commands.
GPUSTATUS               EQU     0F7H                                     ;         [7;1] - FSM state, [0] - 1 = busy, 0 = idle
                                                                         ;      Bits [5:0] - 0 = Reset parameters.
                                                                         ;                   1 = Clear to val. Start Location (16 bit), End Location (16 bit), Red Filter, Green Filter, Blue Filter
                                                                         ; 
VMCTRL                  EQU     0F8H                                     ; Video Module control register. [2:0] - 000 (default) = MZ80A, 001 = MZ-700, 010 = MZ800, 011 = MZ80B, 100 = MZ80K, 101 = MZ80C, 110 = MZ1200, 111 = MZ2000. [3] = 0 - 40 col, 1 - 80 col.
VMGRMODE                EQU     0F9H                                     ; Video Module graphics mode. 7/6 = Operator (00=OR,01=AND,10=NAND,11=XOR), 5=GRAM Output Enable, 4 = VRAM Output Enable, 3/2 = Write mode (00=Page 1:Red, 01=Page 2:Green, 10=Page 3:Blue, 11=Indirect), 1/0=Read mode (00=Page 1:Red, 01=Page2:Green, 10=Page 3:Blue, 11=Not used).
VMREDMASK               EQU     0FAH                                     ; Video Module Red bit mask (1 bit = 1 pixel, 8 pixels per byte).
VMGREENMASK             EQU     0FBH                                     ; Video Module Green bit mask (1 bit = 1 pixel, 8 pixels per byte).
VMBLUEMASK              EQU     0FCH                                     ; Video Module Blue bit mask (1 bit = 1 pixel, 8 pixels per byte).
VMPAGE                  EQU     0FDH                                     ; Video Module memory page register. [0] switches in 16Kb page (1 of 3 pages) of graphics ram to C000 - FFFF. Bits [0] = page, 0 = Off, 1 = GRAM page, as specified by VM Graphics mode register is paged in. This overrides all MZ700/MZ80B page switching functions. [7] 0 - normal, 1 - switches in CGROM for upload at D000:DFFF.

;-----------------------------------------------
; GPU commands.
;-----------------------------------------------
GPUCLEARVRAM            EQU     001H                                     ; Clear the VRAM without updating attributes.
GPUCLEARVRAMCA          EQU     002H                                     ; Clear the VRAM/ARAM with given attribute byte,
GPUCLEARVRAMP           EQU     003H                                     ; Clear the VRAM/ARAM with parameters.
GPUCLEARGRAM            EQU     081H                                     ; Clear the entire Framebuffer.
GPUCLEARGRAMP           EQU     082H                                     ; Clear the Framebuffer according to parameters.
GPURESET                EQU     0FFH                                     ; Reset the GPU, return to idle state.

;-----------------------------------------------
; Memory mapped ports in hardware.
;-----------------------------------------------
SCRN:                   EQU     0D000H
ARAM:                   EQU     0D800H
DSPCTL:                 EQU     0DFFFH                                   ; Screen 40/80 select register (bit 7)
KEYPA:                  EQU     0E000h
KEYPB:                  EQU     0E001h
KEYPC:                  EQU     0E002h
KEYPF:                  EQU     0E003h
CSTR:                   EQU     0E002h
CSTPT:                  EQU     0E003h
CONT0:                  EQU     0E004h
CONT1:                  EQU     0E005h
CONT2:                  EQU     0E006h
CONTF:                  EQU     0E007h
SUNDG:                  EQU     0E008h
TEMP:                   EQU     0E008h
MEMSW:                  EQU     0E00CH
MEMSWR:                 EQU     0E010H
INVDSP:                 EQU     0E014H
NRMDSP:                 EQU     0E015H
SCLDSP:                 EQU     0E200H
SCLBASE:                EQU     0E2H

;-----------------------------------------------
; CPLD Configuration constants.
;-----------------------------------------------
MODE_MZ80K              EQU     0                                        ; Set to MZ-80K mode.
MODE_MZ80C              EQU     1                                        ; Set to MZ-80C mode.
MODE_MZ1200             EQU     2                                        ; Set to MZ-1200 mode.
MODE_MZ80A              EQU     3                                        ; Set to MZ-80A mode (base mode on MZ-80A hardware).
MODE_MZ700              EQU     4                                        ; Set to MZ-700 mode (base mode on MZ-700 hardware).
MODE_MZ800              EQU     5                                        ; Set to MZ-800 mode.
MODE_MZ80B              EQU     6                                        ; Set to MZ-80B mode.
MODE_MZ2000             EQU     7                                        ; Set to MZ-2000 mode.
MODE_VIDEO_FPGA         EQU     8                                        ; Bit flag (bit 3) to switch CPLD into using the new FPGA video hardware.

;-----------------------------------------------
; Video Module control bits.
;-----------------------------------------------
MODE_80CHAR             EQU     008H                                     ; Enable 80 character display.
MODE_COLOUR             EQU     010H                                     ; Enable colour display.
SYSMODE_MZ80A           EQU     000H                                     ; System board mode MZ80A, 2MHz CPU/Bus.
SYSMODE_MZ80B           EQU     001H                                     ; System board mode MZ80B, 4MHz CPU/Bus.
SYSMODE_MZ700           EQU     002H                                     ; System board mode MZ700, 3.54MHz CPU/Bus.
VMMODE_MZ80K            EQU     000H                                     ; Video mode = MZ80K
VMMODE_MZ80C            EQU     001H                                     ; Video mode = MZ80C
VMMODE_MZ1200           EQU     002H                                     ; Video mode = MZ1200
VMMODE_MZ80A            EQU     003H                                     ; Video mode = MZ80A
VMMODE_MZ700            EQU     004H                                     ; Video mode = MZ700
VMMODE_MZ800            EQU     005H                                     ; Video mode = MZ800
VMMODE_MZ80B            EQU     006H                                     ; Video mode = MZ80B
VMMODE_MZ2000           EQU     007H                                     ; Video mode = MZ2000
VMMODE_PCGRAM           EQU     020H                                     ; Enable PCG RAM.
VMMODE_VGA_OFF          EQU     000H                                     ; Set VGA mode off, external monitor is driven by standard internal signals.
VMMODE_VGA_640x480      EQU     040H                                     ; Set external monitor to VGA 640x480 @ 60Hz mode.
VMMODE_VGA_1024x768     EQU     080H                                     ; Set external monitor to VGA 1024x768 @ 60Hz mode.
VMMODE_VGA_800x600      EQU     0C0H                                     ; Set external monitor to VGA 800x600 @ 60Hz mode.

;-----------------------------------------------
; tranZPUter SW Memory Management modes
;-----------------------------------------------
TZMM_ENIOWAIT           EQU     020H                                     ; Memory management IO Wait State enable - insert a wait state when an IO operation to E0-FF is executed.
TZMM_ORIG               EQU     000H                                     ; Original Sharp MZ80A mode, no tranZPUter features are selected except the I/O control registers (default: 0x60-063).
TZMM_BOOT               EQU     001H                                     ; Original mode but E800-EFFF is mapped to tranZPUter RAM so TZFS can be booted.
TZMM_TZFS               EQU     002H ; TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-FFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected.
TZMM_TZFS2              EQU     003H ; TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 1.
TZMM_TZFS3              EQU     004H ; TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 2.
TZMM_TZFS4              EQU     005H ; TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 3.
TZMM_CPM                EQU     006H ; TZMM_ENIOWAIT                     ; CPM main memory configuration, all memory on the tranZPUter board, 64K block 4 selected. Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_CPM2               EQU     007H ; TZMM_ENIOWAIT                     ; CPM main memory configuration, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
                                                                         ; Special case for 0000:003F (interrupt vectors) which resides in block 4, F3FE:F3FF & F7FE:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_COMPAT             EQU     008H ; TZMM_ENIOWAIT                     ; Original mode but with main DRAM in Bank 0 to allow bootstrapping of programs from other machines such as the MZ700.
TZMM_MZ700_0            EQU     00AH ; TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
TZMM_MZ700_1            EQU     00BH ; TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_2            EQU     00CH ; TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_3            EQU     00DH ; TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_MZ700_4            EQU     00EH ; TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_TZPU0              EQU     018H ; TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 0 is selected.
TZMM_TZPU1              EQU     019H ; TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 1 is selected.
TZMM_TZPU2              EQU     01AH ; TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 2 is selected.
TZMM_TZPU3              EQU     01BH ; TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 3 is selected.
TZMM_TZPU4              EQU     01CH ; TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 4 is selected.
TZMM_TZPU5              EQU     01DH ; TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 5 is selected.
TZMM_TZPU6              EQU     01EH ; TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 6 is selected.
TZMM_TZPU7              EQU     01FH ; TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 7 is selected.

;-----------------------------------------------
;    BIOS WORK AREA (MZ80A)
;-----------------------------------------------
TZVARMEM:               EQU     0F4A0H
TZSVCMEM:               EQU     0F560H                                   ; Start of a memory structure used to communicate with the K64F I/O processor for services such as disk access.
TZSVCSIZE:              EQU     00280H                                   ;
TZSVCDIRSZ:             EQU     20                                       ; Size of the directory/file name.
TZSVCFILESZ:            EQU     17                                       ; Size of a Sharp filename.
TZSVCLONGFILESZ:        EQU     31                                       ; Size of a standard filename.
TZSVCLONGFMTSZ:         EQU     20                                       ; Size of a formatted standard filename for use in directory listings.
TZSVCWILDSZ:            EQU     20                                       ; Size of the wildcard.
TZSVCSECSIZE:           EQU     512
TZSVCDIR_ENTSZ:         EQU     32                                       ; Size of a directory entry.
TZSVCWAITIORETRIES:     EQU     500                                      ; Wait retries for IO response.
TZSVCWAITCOUNT:         EQU     65535                                    ; Wait retries for IO request response.
TZSVC_FTYPE_MZF:        EQU     0                                        ; File type being handled is an MZF
TZSVC_FTYPE_CAS:        EQU     1                                        ; File type being handled is an CASsette BASIC script.
TZSVC_FTYPE_BAS:        EQU     2                                        ; File type being handled is an BASic script
TZSVC_FTYPE_ALL:        EQU     10                                       ; Handle any filetype.
TZSVC_FTYPE_ALLFMT:     EQU     11                                       ; Special case for directory listings, all files but truncated and formatted.

TZSVC_CMD_READDIR       EQU     01H                                      ; Service command to open a directory and return the first block of entries.
TZSVC_CMD_NEXTDIR       EQU     02H                                      ; Service command to return the next block of an open directory.
TZSVC_CMD_READFILE      EQU     03H                                      ; Service command to open a file and return the first block.
TZSVC_CMD_NEXTREADFILE  EQU     04H                                      ; Service command to return the next block of an open file.
TZSVC_CMD_WRITEFILE     EQU     05H                                      ; Service command to create a file and save the first block.
TZSVC_CMD_NEXTWRITEFILE EQU     06H                                      ; Service command to write the next block to the open file.
TZSVC_CMD_CLOSE         EQU     07H                                      ; Service command to close any open file or directory.
TZSVC_CMD_LOADFILE      EQU     08H                                      ; Service command to load a file directly into tranZPUter memory.
TZSVC_CMD_SAVEFILE      EQU     09H                                      ; Service command to save a file directly from tranZPUter memory. 
TZSVC_CMD_ERASEFILE     EQU     0aH                                      ; Service command to erase a file on the SD card.
TZSVC_CMD_CHANGEDIR     EQU     0bH                                      ; Service command to change the active directory on the SD card.
TZSVC_CMD_LOAD40BIOS    EQU     20H                                      ; Service command requesting that the 40 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOAD80BIOS    EQU     21H                                      ; Service command requesting that the 80 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOAD700BIOS40 EQU     22H                                      ; Service command requesting that the MZ700 1Z-013A 40 column BIOS is loaded.
TZSVC_CMD_LOAD700BIOS80 EQU     23H                                      ; Service command requesting that the MZ700 1Z-013A 80 column patched BIOS is loaded.
TZSVC_CMD_LOAD80BIPL    EQU     24H                                      ; Service command requesting the MZ-80B IPL is loaded.
TZSVC_CMD_LOADBDOS      EQU     30H                                      ; Service command to reload CPM BDOS+CCP.
TZSVC_CMD_ADDSDDRIVE    EQU     31H                                      ; Service command to attach a CPM disk to a drive number.
TZSVC_CMD_READSDDRIVE   EQU     32H                                      ; Service command to read an attached SD file as a CPM disk drive.
TZSVC_CMD_WRITESDDRIVE  EQU     33H                                      ; Service command to write to a CPM disk drive which is an attached SD file.
TZSVC_CMD_CPU_BASEFREQ  EQU     40H                                      ; Service command to switch to the mainboard frequency.
TZSVC_CMD_CPU_ALTFREQ   EQU     41H                                      ; Service command to switch to the alternate frequency provided by the K64F.
TZSVC_CMD_CPU_CHGFREQ   EQU     42H                                      ; Service command to set the alternate frequency in hertz.
TZSVC_CMD_EXIT          EQU     07FH                                     ; Service command to terminate TZFS and restart the machine in original mode.
TZSVC_STATUS_OK         EQU     000H                                     ; Flag to indicate the K64F processing completed successfully.
TZSVC_STATUS_REQUEST    EQU     0FEH                                     ; Flag to indicate the Z80 has made a request to the K64F.
TZSVC_STATUS_PROCESSING EQU     0FFH                                     ; Flag to indicate the K64F is processing a command.

           ORG      TPSTART

SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
;ATRB:                   DS      virtual 1                               ; ATTRIBUTE
ATRB:                   DB      01h                                      ; Code Type, 01 = Machine Code.
;NAME:                   DS      virtual 17                              ; FILE NAME
NAME:                   DB      "SHARPMZ TEST V1", 0Dh, 00h              ; Title/Name (17 bytes).
;SIZE:                   DS      virtual 2                               ; BYTESIZE
SIZE:                   DW      MEND - MSTART                            ; Size of program.
;DTADR:                  DS      virtual 2                               ; DATA ADDRESS
DTADR:                  DW      MSTART                                   ; Load address of program.
;EXADR:                  DS      virtual 2                               ; EXECUTION ADDRESS
EXADR:                  DW      MSTART                                   ; Exec address of program.
COMNT:                  DS      104                                      ; COMMENT
KANAF:                  DS      virtual 1                                ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:                  DS      virtual 2                                ; DISPLAY COORDINATES
MANG:                   DS      virtual 27                               ; COLUMN MANAGEMENT
FLASH:                  DS      virtual 1                                ; FLASHING DATA
FLPST:                  DS      virtual 2                                ; FLASHING POSITION
FLSST:                  DS      virtual 1                                ; FLASHING STATUS
FLSDT:                  DS      virtual 1                                ; CURSOR DATA
STRGF:                  DS      virtual 1                                ; STRING FLAG
DPRNT:                  DS      virtual 1                                ; TAB COUNTER
TMCNT:                  DS      virtual 2                                ; TAPE MARK COUNTER
SUMDT:                  DS      virtual 2                                ; CHECK SUM DATA
CSMDT:                  DS      virtual 2                                ; FOR COMPARE SUM DATA
AMPM:                   DS      virtual 1                                ; AMPM DATA
TIMFG:                  DS      virtual 1                                ; TIME FLAG
SWRK:                   DS      virtual 1                                ; KEY SOUND FLAG
TEMPW:                  DS      virtual 1                                ; TEMPO WORK
ONTYO:                  DS      virtual 1                                ; ONTYO WORK
OCTV:                   DS      virtual 1                                ; OCTAVE WORK
RATIO:                  DS      virtual 2                                ; ONPU RATIO
BUFER:                  DS      virtual 81                               ; GET LINE BUFFER



           ORG      MSTART
           JP       START

           ; Graphics Initialisation. Needs to be in memory before C000-FFFF
           ;
           ; 0x6E CPLD Configuration register.
           ;
           ; The mode can be changed by a Z80 transaction write into the register and it is acted upon if the mode switches between differing values. The Z80 write is typically used
           ; by host software such as RFS.
           ;
           ; [2:0] - Mode/emulated machine.
           ;         000 = MZ-80K
           ;         001 = MZ-80C
           ;         010 = MZ-1200
           ;         011 = MZ-80A
           ;         100 = MZ-700
           ;         101 = MZ-800
           ;         110 = MZ-80B
           ;         111 = MZ-2000
           ; [3]   - Mainboard Video - 1 = Enable, 0 = Disable - This flag allows Z-80 transactions in the range D000:DFFF to be directed to the mainboard. When disabled all transactions
           ;                                                     can only be seen by the FPGA video logic. The FPGA uses this flag to enable/disable it's functionality.
           ; [6:4] = Mainboard/CPU clock.
           ;         000 = Sharp MZ80A 2MHz System Clock.
           ;         001 = Sharp MZ80B 4MHz System Clock.
           ;         010 = Sharp MZ700 3.54MHz System Clock.
           ;         011 -111 = Reserved, defaults to 2MHz System Clock.
           ;
           ;
           ; 0xF8 set the video mode. 
           ;                       Bits [2:0] define the Video Module machine compatibility. 000 = MZ80K, 001 = MZ80C, 010 = MZ1200, 011 = MZ80A, 100 = MZ-700, 101 = MZ-800, 110 = MZ-80B, 111 = MZ2000,
           ;                       Bit    [3] defines the 40/80 column mode, 0 = 40 col, 1 = 80 col.
           ;                       Bit    [4] defines the colour mode, 0 = mono, 1 = colour - ignored on certain modes.
           ;                       Bit    [5] defines wether PCGRAM is enabled, 0 = disabled, 1 = enabled.
           ;                       Bits [7:6] define the VGA mode.
           ; 0xF9 set the graphics mode. 7/6 = Operator (00=OR,01=AND,10=NAND,11=XOR),
           ;                               5 = GRAM Output Enable (=0), 4 = VRAM Output Enable (=0),
           ;                             3/2 = Write mode (00=Page 1:Red, 01=Page 2:Green, 10=Page 3:Blue, 11=Indirect),
           ;                             1/0 = Read mode (00=Page 1:Red, 01=Page2:Green, 10=Page 3:Blue, 11=Not used).
           ; 0xFA set the Red bit mask (1 bit = 1 pixel, 8 pixels per byte).
           ; 0xFB set the Green bit mask (1 bit = 1 pixel, 8 pixels per byte).
           ; 0xFC set the Blue bit mask (1 bit = 1 pixel, 8 pixels per byte).
           ; 0xFD set the Video memory page in block C000:FFFF 
           ;                            [1:0] switches in 1 16Kb page (3 pages) of graphics ram to C000 - FFFF. 00 = disabled, standard VRAM, 01 = Red page, 10 = Blue page, 11 = Green page.
           ;                            [7] 0 - normal, 1 - switches in CGROM for upload at D000:DFFF.

GRAMINIT:  OUT      (VMGRMODE),A                           ; Set provided graphics mode.
           LD       A,1                                    ; Switch graphics page into C000:FFFF memory bank 
           OUT      (VMPAGE),A
GRAM0:     LD       HL,GRAMSTART                           ; Start of graphics page.
           LD       BC,GRAMEND - GRAMSTART                 ; Size of graphics page (16KB).
GRAM1:     LD       A,000h                                 ; Clear memory.
           LD       (HL),A
           INC      HL
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GRAM1
           LD       A,0                                    ; Revert to normal memory.
           OUT      (VMPAGE),A
           RET

           ; Graphics Test. Needs to be in memory before C000-FFFF
           ;
GRAMTEST:  OUT      (VMGRMODE),A
           LD       A,1                                    ; Switch graphics page into C000:FFFF memory bank 
           OUT      (VMPAGE),A
           LD       D, 1                                   ; Number of iterations.
           LD       E,080h
GRAMTST0:  LD       HL,GRAMSTART
           LD       BC,GRAMEND - GRAMSTART
GRAMTST1:  LD       A,E
           LD       (HL),A
           INC      HL
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GRAMTST1
           RR       E
           JR       NZ,GRAMTST0
          ;JR       C,GRAMTST0
           DEC      D
           JR       NZ,GRAMTST0
           LD       A,0                                    ; Revert to normal memory.
           OUT      (VMPAGE),A
           RET
           ;
GRAMTEST2: OUT      (VMGRMODE),A
           LD       A,1                                    ; Switch graphics page into C000:FFFF memory bank 
           OUT      (VMPAGE),A
           LD       E,0FFH
GRAMTST4:  LD       HL,GRAMSTART
           LD       BC,GRAMEND - GRAMSTART
GRAMTST5:  LD       A,E
           LD       (HL),A
           INC      HL
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GRAMTST5
           LD       A,0                                    ; Revert to normal memory.
           OUT      (VMPAGE),A
           RET

           ; Graphics Test routine.
           ;
           ;   Graphics mode:- 7/6 = Operator (00=OR,01=AND,10=NAND,11=XOR),
           ;                     5 = GRAM Output Enable  0 = active.
           ;                     4 = VRAM Output Enable, 0 = active.
           ;                   3/2 = Write mode (00=Page 1:Red, 01=Page 2:Green, 10=Page 3:Blue, 11=Indirect),
           ;                   1/0 = Read mode  (00=Page 1:Red, 01=Page2:Green, 10=Page 3:Blue, 11=Not used).
           ;
GRAPHICS1: LD       B, 128
GRAPH0:    PUSH     BC
           LD       A,010h                 ; Red page read/write.
           CALL     GRAMTEST
           LD       A,015h                 ; Green page read/write.
           CALL     GRAMTEST
           LD       A,01Ah                 ; Blue page.
           CALL     GRAMTEST
           POP      BC
           DJNZ     GRAPH0
           JP       GETL1


GRAPHICS2: LD       A, 0FFH                ; Run through the filter mask.
           OUT      (VMREDMASK),A
           OUT      (VMGREENMASK),A
           OUT      (VMBLUEMASK),A
GRAPH1:    LD       A, 01Ch                ; Set graphics mode to Indirect Page write.
           CALL     GRAMTEST2
           IN       A,(VMREDMASK)
           DEC      A
           OUT      (VMREDMASK),A
           JR       NZ, GRAPH1
           IN       A,(VMGREENMASK)
           DEC      A
           OUT      (VMGREENMASK),A
           JR       NZ, GRAPH1
           IN       A,(VMBLUEMASK)
           DEC      A
           OUT      (VMBLUEMASK),A
           JR       NZ, GRAPH1
           JP       GETL1

           ; Graphics progress bar indicator. Needs to be in memory before C000-FFFF
           ;
GRPHIND:   LD       HL,(GRPHPOS)            ; Get position of graphics progress line.
           LD       A,001H
           OUT      (VMPAGE),A              ; Enable graphics memory.
           LD       A,0FFh
           LD       (HL),A
           LD       A,0
           OUT      (VMPAGE),A              ; Disable graphics memory.
           INC      HL
           LD       (GRPHPOS),HL
           LD       A,08CH
           OUT      (VMGRMODE),A
           RET
           

           ;
           ; Start of main program.
           ;
START:     
           LD       HL,0066H                                             ; Set NMI so it doesnt bother us.
           LD       (HL), 0EDH                                           ; Set to RETN instruction.
           INC      HL
           LD       (HL), 045H

           IN       A, (CPLDINFO)                                        ; Get hardware information.
           AND      07H                                                  ; Remove version.
           LD       D, A
           OR       MODE_VIDEO_FPGA                                      ; Ensure the video hardware is enabled.
           OUT      (CPLDCFG),A
           LD       A,D
           CP       MODE_MZ80A
           JR       NZ,START2
           LD       A,192 + VMMODE_MZ700                                 ; Switch to MZ700 video mode for colour testing.
           JR       START3
          ;IN       A,(VMCTRL)
          ;AND      0C0H                                                 ; Mask out all but VGA mode.
START2:    LD       A, 192                                               ; VGA mode 800x600
           OR       D                                                    ; Bring in mode.
START3:    OUT      (VMCTRL),A                                           ; Activate.
           ;
SIGNON:    LD       A,016H
           CALL     PRNT
           LD       A,071H                                               ; Blue background, white characters in colour mode. Bit 7 is set as a write to bit 7 @ DFFFH selects 80Char mode.
           LD       HL,ARAM
           CALL     CLR8
           CALL     NL
           LD       DE,TITLE
           CALL     MSG
           CALL     LETNL
           CALL     LETNL

           ; 0x6E CPLD Configuration register.
           ;
           ; The mode can be changed by a Z80 transaction write into the register and it is acted upon if the mode switches between differing values. The Z80 write is typically used
           ; by host software such as RFS.
           ;
           ; [2:0] - Mode/emulated machine.
           ;         000 = MZ-80K
           ;         001 = MZ-80C
           ;         010 = MZ-1200
           ;         011 = MZ-80A
           ;         100 = MZ-700
           ;         101 = MZ-800
           ;         110 = MZ-80B
           ;         111 = MZ-2000
           ; [3]   - Mainboard Video - 1 = Enable, 0 = Disable - This flag allows Z-80 transactions in the range D000:DFFF to be directed to the mainboard. When disabled all transactions
           ;                                                     can only be seen by the FPGA video logic. The FPGA uses this flag to enable/disable it's functionality.
           ; [6:4] = Mainboard/CPU clock.
           ;         000 = Sharp MZ80A 2MHz System Clock.
           ;         001 = Sharp MZ80B 4MHz System Clock.
           ;         010 = Sharp MZ700 3.54MHz System Clock.
           ;         011 -111 = Reserved, defaults to 2MHz System Clock.
           ;
           ;
           ; 0xF8 set the video mode. 
           ;                       Bits [2:0] define the Video Module machine compatibility. 000 = MZ80K, 001 = MZ80C, 010 = MZ1200, 011 = MZ80A, 100 = MZ-700, 101 = MZ-800, 110 = MZ-80B, 111 = MZ2000,
           ;                       Bit    [3] defines the 40/80 column mode, 0 = 40 col, 1 = 80 col.
           ;                       Bit    [4] defines the colour mode, 0 = mono, 1 = colour - ignored on certain modes.
           ;                       Bit    [5] defines wether PCGRAM is enabled, 0 = disabled, 1 = enabled.
           ;                       Bits [7:6] define the VGA mode.
           ; 0xF9 set the graphics mode. 7/6 = Operator (00=OR,01=AND,10=NAND,11=XOR),
           ;                               5 = GRAM Output Enable (=0), 4 = VRAM Output Enable (=0),
           ;                             3/2 = Write mode (00=Page 1:Red, 01=Page 2:Green, 10=Page 3:Blue, 11=Indirect),
           ;                             1/0 = Read mode (00=Page 1:Red, 01=Page2:Green, 10=Page 3:Blue, 11=Not used).
           ; 0xFA set the Red bit mask (1 bit = 1 pixel, 8 pixels per byte).
           ; 0xFB set the Green bit mask (1 bit = 1 pixel, 8 pixels per byte).
           ; 0xFC set the Blue bit mask (1 bit = 1 pixel, 8 pixels per byte).
           ; 0xFD set the Video memory page in block C000:FFFF bit 0, set the CGROM upload access in bit 7.

INITGRPH:  LD       DE,MSG_INITGR
           CALL     MSG
           CALL     LETNL
           LD       A,0FFh                 ; Set Red filter.
           OUT      (VMREDMASK),A
           LD       A,0FFh                 ; Set Green filter.
           OUT      (VMGREENMASK),A
           LD       A,0FFh                 ; Set Blue filter.
           OUT      (VMBLUEMASK),A
           LD       A,010h                 ; Enable graphics output and character display output. Initialise Red page.
           CALL     GRAMINIT
           LD       A,015h                 ; Initialise Green page.
           CALL     GRAMINIT
           LD       A,01Ah                 ; Initialise Blue page.
           CALL     GRAMINIT
           LD       A, 0ECh                ; Set graphics mode to Indirect Page write, disable graphics output.
           OUT      (VMGRMODE),A
           LD       HL,0DE00h
           LD       (GRPHPOS),HL
           ;
INITMEM:   LD       DE,MSG_INITM
           CALL     MSG
           CALL     LETNL
           LD       HL,1200h
           LD       BC,MSTART - 1200h
CLEAR1:    LD       A,00h
           LD       (HL),A
           INC      HL
           DEC      BC
           LD       A,B
           OR       C
           JP       NZ,CLEAR1
           JP       HELP                   ; Output known commands at startup.

GETL1:     LD       A, 0ECh                ; Set graphics mode to VRAM enable, GRAM disable.
           OUT      (VMGRMODE),A
           CALL     NL
GETL1A:    LD       A,03EH
           CALL     PRNT
           LD       DE,BUFER
           CALL     GETL

CMDCMP:    LD       HL,CMDTABLE
CMDCMP0:   LD       DE,BUFER+1                                           ; First command byte after the * prompt.
           LD       A,(HL)
           CP       000H
           JR       Z,GETL1A                                             ; Skip processing on lines where just CR pressed.
           BIT      7,A                                                  ; Bit 7 set on command properties indicates table end, exit if needed.
           JR       NZ,CMDNOCMP
           LD       C,A                                                  ; Command properties into C
           SET      6,C                                                  ; Assume command match.
           AND      007H                                                 ; Mask out bytes in command mask.
           LD       B,A                                                  ; Number of bytes in command.
           INC      HL
CMDCMP1:   LD       A,(DE)                                               ; Compare all bytes and reset match bit if we find a difference.
           CP       (HL)
           JR       Z, CMDCMP2
           RES      6,C                                                  ; No command match.
CMDCMP2:   INC      DE
           INC      HL
           DJNZ     CMDCMP1
           BIT      6,C                                                  ; Bit 7 is still set then we have a command match.
           JR       NZ,CMDCMP3
           INC      HL
           INC      HL                                                   ; Skip over function address
           JR       CMDCMP0                                              ; Try match next command.
CMDCMP3:   LD       A,(HL)                                               ; Command function address into HL
           INC      HL
           LD       H,(HL)
           LD       L,A
           PUSH     HL
           LD       (TMPADR),DE                                          ; Store the key buffer location where arguments start.
           LD       HL,CMDCMPEND                                         ; Location to return to after function is called.
           EX       (SP),HL                                              ; Swap the return location with the location to call.
           PUSH     HL                                                   ; Put location to call at top of stack.
           RET                                                           ; Pop into PC and run.
           ;
CMDNOCMP:  LD      DE,MSGBADCMD
           CALL    MSG
           CALL    NL
CMDCMPEND: JP      GETL1A


            ; Monitor command table. This table contains the list of recognised commands along with the 
            ; handler function and bank in which it is located.
            ;
            ;         7     6     5:3    2:0
            ;        END  MATCH  UNUSED  SIZE 
CMDTABLE:  
           DB       000H | 000H | 000H | 004H
           DB       "HELP"                    
           DW       HELP
           DB       000H | 000H | 000H | 005H
           DB       "GRPH1"                    
           DW       GRAPHICS1
           DB       000H | 000H | 000H | 005H
           DB       "GRPH2"                    
           DW       GRAPHICS2
           DB       000H | 000H | 000H | 004H
           DB       "GPU1"                    
           DW       GPU1
           DB       000H | 000H | 000H | 004H
           DB       "GPU2"                    
           DW       GPU2
           DB       000H | 000H | 000H | 003H
           DB       "PAL"                    
           DW       PALETTE
           DB       000H | 000H | 000H | 007H
           DB       "MEMTEST"                    
           DW       MEMTEST
           DB       000H | 000H | 000H | 004H
           DB       "LOAD"                    
           DW       LOAD
           DB       000H | 000H | 000H | 005H
           DB       "TIMER"                    
           DW       TIMERTST
           DB       000H | 000H | 000H | 004H
           DB       "SAVE"                    
           DW       SAVE
           DB       000H | 000H | 000H | 004H
           DB       "QUIT"                    
           DW       MROMINIT
           DB       000H | 000H | 000H | 004H
           DB       "VGA0"                                               ; Set VGA mode.
           DW       VGA0
           DB       000H | 000H | 000H | 004H
           DB       "VGA1"                                               ; Set VGA mode.
           DW       VGA1
           DB       000H | 000H | 000H | 004H
           DB       "VGA2"                                               ; Set VGA mode.
           DW       VGA2
           DB       000H | 000H | 000H | 004H
           DB       "VGA3"                                               ; Set VGA mode.
           DW       VGA3
           DB       000H | 000H | 000H | 001H

VGA0:      IN       A,(VMCTRL)
           AND      03FH
           OUT      (VMCTRL),A
           JP       GETL1
VGA1:      IN       A,(VMCTRL)
           AND      03FH
           OR       040H
           OUT      (VMCTRL),A
           JP       GETL1
VGA2:      IN       A,(VMCTRL)
           AND      03FH
           OR       080H
           OUT      (VMCTRL),A
           JP       GETL1
VGA3:      IN       A,(VMCTRL)
           AND      03FH
           OR       0C0H
           OUT      (VMCTRL),A
           JP       GETL1

           ; Simple commands to exercise the GPU functions.
           ;
           ; First up, character clear with parameters. Create descending cleared areas with incremental
           ; character and colour. This puts a lot of pressure on the GPU/Video memory, not so pretty to watch
           ; but does test it out.
GPU1:      XOR      A
           LD       (GPUCHAR),A
           LD       (GPUATTR),A
           LD       (GPUSTARTX),A

GPUNEXT0:  XOR      A
           LD       (GPUSTARTY),A

GPUNEXT1:  LD       A,(GPUSTARTX)
           LD       (GPUENDX),A

GPUNEXT2:  LD       A,(GPUSTARTY)
           LD       (GPUENDY),A

           ; Wait for the GPU to become ready.
GPUWAIT1:  IN       A,(GPUSTATUS)
           BIT      0,A
           JR       NZ,GPUWAIT1

           ; Setup the GPU parameters to fill area.
GPUNEXT3:  LD       A,(GPUSTARTX)
           OUT      (GPUPARAM),A
           LD       A,(GPUSTARTY)
           OUT      (GPUPARAM),A
           LD       A,(GPUENDX)
           OUT      (GPUPARAM),A
           LD       A,(GPUENDY)
           OUT      (GPUPARAM),A
           LD       A,(GPUCHAR)
           OUT      (GPUPARAM),A
           LD       A,(GPUATTR)
           OUT      (GPUPARAM),A
           ; Issue the GPU command.
           LD       A,GPUCLEARVRAMP
           OUT      (GPUCMD),A

           ; Next End Y loop.
           LD       A,(GPUENDY)
           INC      A
           LD       (GPUENDY),A
           CP       25
           JP       C, GPUWAIT1

           ; Change the character.
           LD       A,(GPUCHAR)
           INC      A
           LD       (GPUCHAR),A

           ; Next End X loop.
           LD       A,(GPUENDX)
           INC      A
           LD       (GPUENDX),A
           CP       40
           JP       C, GPUNEXT2

           ; Wait for the GPU to become ready.
GPUWAIT2:  IN       A,(GPUSTATUS)
           BIT      0,A
           JR       NZ,GPUWAIT2

           ; Setup the GPU parameters to clear area.
           LD       A,(GPUSTARTX)
           OUT      (GPUPARAM),A
           LD       A,(GPUSTARTY)
           OUT      (GPUPARAM),A
           LD       A,(GPUENDX)
           OUT      (GPUPARAM),A
           LD       A,(GPUENDY)
           OUT      (GPUPARAM),A
           LD       A,000H                            ; Space
           OUT      (GPUPARAM),A
           LD       A,071H                            ; Default white on blue.
           OUT      (GPUPARAM),A
           ; Issue the GPU command.
           LD       A,GPUCLEARVRAMP
           OUT      (GPUCMD),A

           ; Adjust back colour.
           LD       A,(GPUATTR)
           LD       C,A
           AND      0F8H
           LD       D,A
           LD       A,C
           INC      A
           AND      007H
           OR       D
           LD       (GPUATTR),A

           ; Next Start Y loop.
           LD       A,(GPUSTARTY)
           INC      A
           LD       (GPUSTARTY),A
           CP       25
           JP       C, GPUNEXT1

           ; Adjust front colour.
           LD       A,(GPUATTR)
           LD       C,A
           AND      08FH
           LD       D,A
           LD       A,C
           SRL      A
           SRL      A
           SRL      A
           SRL      A
           INC      A
           AND      007H
           SLA      A
           SLA      A
           SLA      A
           SLA      A
           AND      070H
           OR       D
           LD       (GPUATTR),A

           ; Next Start X loop.
           LD       A,(GPUSTARTX)
           INC      A
           LD       (GPUSTARTX),A
           CP       40
           JP       C, GPUNEXT0
           JP       GETL1

           ; Second up, same as above but end co-ordinates are fixed.
GPU2:      XOR      A
           LD       (GPUCHAR),A
           LD       (GPUATTR),A
           LD       (GPUSTARTX),A

GPUNEXT5:  XOR      A
           LD       (GPUSTARTY),A

           ; Setup the GPU parameters to fill area.
GPUNEXT6:  LD       A,(GPUSTARTX)
           OUT      (GPUPARAM),A
           LD       A,(GPUSTARTY)
           OUT      (GPUPARAM),A
           LD       A,39
           OUT      (GPUPARAM),A
           LD       A,24
           OUT      (GPUPARAM),A
           LD       A,(GPUCHAR)
           OUT      (GPUPARAM),A
           LD       A,(GPUATTR)
           OUT      (GPUPARAM),A
           ; Issue the GPU command.
           LD       A,GPUCLEARVRAMP
           OUT      (GPUCMD),A
           ; Wait for the command to complete.
GPUWAIT3:  IN       A,(GPUSTATUS)
           BIT      0,A
           JR       NZ,GPUWAIT3

           LD       BC,0
GPUWAIT5:  DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GPUWAIT5

           ; Setup the GPU parameters to clear area.
           LD       A,(GPUSTARTX)
           OUT      (GPUPARAM),A
           LD       A,(GPUSTARTY)
           OUT      (GPUPARAM),A
           LD       A,(GPUENDX)
           OUT      (GPUPARAM),A
           LD       A,(GPUENDY)
           OUT      (GPUPARAM),A
           LD       A,000H                            ; Space
           OUT      (GPUPARAM),A
           LD       A,071H                            ; Default white on blue.
           OUT      (GPUPARAM),A
           ; Issue the GPU command.
           LD       A,GPUCLEARVRAMP
           OUT      (GPUCMD),A
           ; Wait for the command to complete.
GPUWAIT4:  IN       A,(GPUSTATUS)
           BIT      0,A
           JR       NZ,GPUWAIT4

           ; Adjust back colour.
           LD       A,(GPUATTR)
           LD       C,A
           AND      0F8H
           LD       D,A
           LD       A,C
           INC      A
           AND      007H
           OR       D
           LD       (GPUATTR),A

           ; Next Start Y loop.
           LD       A,(GPUSTARTY)
           INC      A
           LD       (GPUSTARTY),A
           CP       25
           JP       C, GPUNEXT6

           ; Change the character.
           LD       A,(GPUCHAR)
           INC      A
           LD       (GPUCHAR),A

           ; Adjust front colour.
           LD       A,(GPUATTR)
           LD       C,A
           AND      08FH
           LD       D,A
           LD       A,C
           SRL      A
           SRL      A
           SRL      A
           SRL      A
           INC      A
           AND      007H
           SLA      A
           SLA      A
           SLA      A
           SLA      A
           AND      070H
           OR       D
           LD       (GPUATTR),A

           ; Next Start X loop.
           LD       A,(GPUSTARTX)
           INC      A
           LD       (GPUSTARTX),A
           CP       40
           JP       C, GPUNEXT5
           JP       GETL1

           ; Draw bars in descending colours prior to palette test.
PALETTE:   LD       A,GPUCLEARVRAM
           OUT      (GPUCMD),A
           ; Wait for the command to complete.
PALWAIT1:  IN       A,(GPUSTATUS)
           BIT      0,A
           JR       NZ,PALWAIT1

           XOR      A
           LD       (GPUCHAR),A
           LD       (GPUSTARTX),A
           LD       (GPUSTARTY),A
           LD       A,030H
           LD       (GPUATTR),A

           ; Setup the GPU parameters to fill area.
PALNEXT1:  LD       A,(GPUSTARTX)
           OUT      (GPUPARAM),A
           LD       A,(GPUSTARTY)
           OUT      (GPUPARAM),A
           LD       A,39
           OUT      (GPUPARAM),A
           LD       A,24
           OUT      (GPUPARAM),A
           LD       A,(GPUCHAR)
           OUT      (GPUPARAM),A
           LD       A,(GPUATTR)
           OUT      (GPUPARAM),A
           ; Issue the GPU command.
           LD       A,GPUCLEARVRAMP
           OUT      (GPUCMD),A
           ; Wait for the command to complete.
PALWAIT2:  IN       A,(GPUSTATUS)
           BIT      0,A
           JR       NZ,PALWAIT2

           ; Change the character.
           LD       A,(GPUCHAR)
           INC      A
           LD       (GPUCHAR),A

           ; Adjust back colour.
           LD       A,(GPUATTR)
           LD       C,A
           AND      0F8H
           LD       D,A
           LD       A,C
           INC      A
           AND      007H
           LD       E,A
           OR       D
           LD       (GPUATTR),A

           ; Adjust front colour.
           LD       A,(GPUATTR)
           LD       C,A
           AND      08FH
           LD       D,A
           LD       A,C
           SRL      A
           SRL      A
           SRL      A
           SRL      A
           INC      A
           AND      007H
           SLA      A
           SLA      A
           SLA      A
           SLA      A
           AND      070H
           OR       D
           LD       (GPUATTR),A

           ; Next Start Y loop.
PALNEXT2:  LD       A,(GPUSTARTY)
           INC      A
           LD       (GPUSTARTY),A
           CP       25
           JP       C, PALNEXT1


           LD       A,0FFH               ; Choose palette 255 for tests.
           OUT      (VMPALETTE),A
           OUT      (PALSLCTON),A        ; Enable writes to the ON values of palette 255
           ;
           LD       E,0                  ; Red
           LD       D,0                  ; Green
           LD       L,0                  ; Blue
PALNEXT5:  LD       A,E
           OUT      (PALSETRED),A
           LD       A,D
           OUT      (PALSETGREEN),A
           LD       A,L
           OUT      (PALSETBLUE),A

           LD       BC,32768
PALWAIT4:  DEC      BC
           LD       A,B
           OR       C
           JR       NZ,PALWAIT4

           INC      L
           LD       A,L
           CP       020H
           JR       C, PALNEXT5
           LD       L,0
           INC      D
           LD       A,D
           CP       020H
           JR       NZ, PALNEXT5
           LD       D,0
           INC      E
           LD       A,E
           CP       020H
           JR       NZ, PALNEXT5

           XOR      A
PALNEXT3:  OUT      (VMPALETTE),A

           LD       BC,0
PALWAIT3:  DEC      BC
           LD       A,B
           OR       C
           JR       NZ,PALWAIT3

           IN       A, (VMPALETTE)
           INC      A
           OR       A
           JR       NZ, PALNEXT3
           JP       GETL1
         

MEMTEST:   LD       B,240       ; Number of loops
LOOP:      LD       HL,MEMSTART ; Start of checked memory,
           LD       D,MEMCHKEND ; End memory check
LOOP1:     LD       A,000h
           CP       L
           JR       NZ,LOOP1b
           CALL     PRTHL       ; Print HL as 4digit hex.
           LD       A,0C4h      ; Move cursor left.
           LD       E,004h      ; 4 times.
LOOP1a:    CALL     DPCT
           DEC      E
           JR       NZ,LOOP1a
LOOP1b:    INC      HL
           LD       A,H
           CP       D           ; Have we reached end of memory.
           JR       Z,LOOP3     ; Yes, exit.
           LD       A,(HL)      ; Read memory location under test, ie. 0.
           CPL                  ; Subtract, ie. FF - A, ie FF - 0 = FF.
           LD       (HL),A      ; Write it back, ie. FF.
           SUB      (HL)        ; Subtract written memory value from A, ie. should be 0.
           JR       NZ,LOOP2    ; Not zero, we have an error.
           LD       A,(HL)      ; Reread memory location, ie. FF
           CPL                  ; Subtract FF - FF
           LD       (HL),A      ; Write 0
           SUB      (HL)        ; Subtract 0
           JR       Z,LOOP1     ; Loop if the same, ie. 0
LOOP2:     LD       A,16h
           CALL     PRNT        ; Print A
           CALL     PRTHX       ; Print HL as 4 digit hex.
           CALL     PRNTS       ; Print space.
           XOR      A
           LD       (HL),A
           LD       A,(HL)      ; Get into A the failing bits.
           CALL     PRTHX       ; Print A as 2 digit hex.
           CALL     PRNTS       ; Print space.
           LD       A,0FFh      ; Repeat but first load FF into memory
           LD       (HL),A
           LD       A,(HL)
           CALL     PRTHX       ; Print A as 2 digit hex.
           NOP
           JR       LOOP4

LOOP3:     CALL     PRTHL
           LD       DE,OKCHECK
           CALL     MSG          ; Print check message in DE
           LD       A,B          ; Print loop count.
           CALL     PRTHX
           LD       DE,OKMSG
           CALL     MSG          ; Print ok message in DE
           CALL     NL
           CALL     GRPHIND
           DEC      B
           JR       NZ,LOOP
           LD       DE,DONEMSG
           CALL     MSG          ; Print check message in DE
           JP       GETL1

LOOP4:     LD       B,09h
           CALL     PRNTS        ; Print space.
           XOR      A            ; Zero A
           SCF                   ; Set Carry
LOOP5:     PUSH     AF           ; Store A and Flags
           LD       (HL),A       ; Store 0 to bad location.
           LD       A,(HL)       ; Read back
           CALL     PRTHX        ; Print A as 2 digit hex.
           CALL     PRNTS        ; Print space
           POP      AF           ; Get back A (ie. 0 + C)
           RLA                   ; Rotate left A. Bit LSB becomes Carry (ie. 1 first instance), Carry becomes MSB
           DJNZ     LOOP5        ; Loop if not zero, ie. print out all bit locations written and read to memory to locate bad bit.
           XOR      A            ; Zero A, clears flags.
           LD       A,80h
           LD       B,08h
LOOP6:     PUSH     AF           ; Repeat above but AND memory location with original A (ie. 80) 
           LD       C,A          ; Basically walk through all the bits to find which one is stuck.
           LD       (HL),A
           LD       A,(HL)
           AND      C
           NOP
           JR       Z,LOOP8      ; If zero then print out the bit number
           NOP
           NOP
           LD       A,C
           CPL
           LD       (HL),A
           LD       A,(HL)
           AND      C
           JR       NZ,LOOP8     ; As above, if the compliment doesnt yield zero, print out the bit number.
LOOP7:     POP      AF
           RRCA
           NOP
           DJNZ     LOOP6
           JP       GETL1

LOOP8:     CALL     LETNL        ; New line.
           LD       DE,BITMSG    ; BIT message
           CALL     MSG          ; Print message in DE
           LD       A,B
           DEC      A
           CALL     PRTHX        ; Print A as 2 digit hex, ie. BIT number.
           CALL     LETNL        ; New line
           LD       DE,BANKMSG   ; BANK message
           CALL     MSG          ; Print message in DE
           LD       A,H
           CP       50h          ; 'P'
           JR       NC,LOOP9     ; Work out bank number, 1, 2 or 3.
           LD       A,01h
           JR       LOOP11

LOOP9:     CP       90h
           JR       NC,LOOP10
           LD       A,02h
           JR       LOOP11

LOOP10:    LD       A,03h
LOOP11:    CALL     PRTHX        ; Print A as 2 digit hex, ie. BANK number.
           JR       LOOP7


           ;
           ; LOAD COMMAND
           ;
LOAD:      CALL     ?RDI
           JP       C,?ER
LOA0:      CALL     NL
           LD       DE,MSG_LOADFROM
           CALL     MSG
           LD       HL,(DTADR)
           CALL     PRTHL
           CALL     NL
           LD       DE,MSG_LOADEXEC
           CALL     MSG
           LD       HL,(EXADR)
           CALL     PRTHL
           CALL     NL
           LD       DE,MSG_LOADSIZE
           CALL     MSG
           LD       HL,(SIZE)
           CALL     PRTHL
           CALL     NL
           LD       DE,MSG_LOADFILE
           CALL     MSGX
           LD       DE,NAME
           CALL     MSGX
           CALL     NL
           CALL     ?RDD
           JP       C,?ER
           LD       HL,(EXADR)
           LD       A,H
           CP       12h
           JP       C,GETL1
           JP       (HL)


           ; SAVE COMMAND

SAVE:      LD       HL,TESTBUF
           LD       DE,IBUFE
           LD       BC,128
           LDIR
           LD       DE,TITLE_SAVE
           CALL     MSG
           CALL     LETNL
           CALL     LETNL
           LD       DE,MSG_SAVEFROM
           CALL     MSG
           LD       HL,(DTADR)
           CALL     PRTHL
           CALL     NL
           LD       DE,MSG_SAVEEXEC
           CALL     MSG
           LD       HL,(EXADR)
           CALL     PRTHL
           CALL     NL
           LD       DE,MSG_SAVESIZE
           CALL     MSG
           LD       HL,(SIZE)
           CALL     PRTHL
           CALL     NL
           LD       DE,MSG_SAVEFILE
           CALL     MSGX
           LD       DE,NAME
           CALL     MSGX
           CALL     NL
           LD       A,01H                                                    ; ATTRIBUTE: OBJECT CODE
           LD       (ATRB),A
           ;
           LD       DE,MSG_WHDR
           CALL     MSGX
           CALL     NL
           CALL     QWRI
           JP       C,QER                                                    ; WRITE ERROR
           ;
           LD       DE,MSG_WDATA
           CALL     MSGX
           CALL     NL
           ;
           CALL     QWRD                                                     ; DATA
           JP       C,QER
           CALL     NL
           LD       DE,MSGOK                                                 ; OK MESSAGE
           CALL     MSGX                                                     ; CALL MSGX
           JP       GETL1           

           ;
           ; ERROR (LOADING)
           ;
QER:       CP       02h
           JP       Z,GETL1
           LD       DE,MSG_ERRWRITE
           CALL     MSG
           JP       GETL1
           ;
           ; ERROR (LOADING)
           ;
?ER:       CP       02h
           JP       Z,GETL1
           LD       DE,MSG_ERRCHKSUM
           CALL     MSG
           JP       GETL1
           ;
           ; READ INFORMATION
           ;
           ; EXIT ACC = 0 : OK CF=0
           ;          = 1 : ER CF=1
           ;          = 2 : BREAK CF=1
           ;
?RDI:      DI
           PUSH     DE
           PUSH     BC
           PUSH     HL
           LD       D,0D2h
           LD       E,0CCh
           LD       BC,80h
           LD       HL,IBUFE
RD1:       CALL     MOTOR
           JP       C,RTP6
           CALL     TMARK
           JP       C,RTP6
;   CALL     PRTHL
           CALL     RTAPE
           POP      HL
           POP      BC
           POP      DE
           ;CALL     MSTOP
           PUSH     AF
           LD       A,(TIMFG)
           CP       0F0h
           JR       NZ,RD2
           EI
RD2:       POP      AF
           RET

           ;
           ; READ DATA
           ;
?RDD:      DI
           PUSH     DE
           PUSH     BC
           PUSH     HL
           LD       D,0D2h
           LD       E,53h
           LD       BC,(SIZE)
           LD       HL,(DTADR)
           LD       A,B
           OR       C
           JP       Z,RDD1
           JR       RD1
RDD1:      POP      HL
           POP      BC
           POP      DE
           ;CALL     MSTOP
           PUSH     AF
           LD       A,(TIMFG)
           CP       0F0h
           JR       NZ,RDD2
           EI
RDD2:      POP      AF
           RET

           ;
           ; READ TAPE
           ;
RTAPE:     ;PUSH     BC
           ;PUSH     DE
           ;LD       DE,MSG_READTAPE
           ;CALL     MSG
           ;CALL     NL
           ;POP      DE
           ;POP      BC
           PUSH     DE
           PUSH     BC
           PUSH     HL
           LD       H,2
RTP1:      LD       BC,KEYPB
           LD       DE,CSTR
RTP2:      CALL     EDGE
           JP       C,RTP6
           CALL     DLY3
           LD       A,(DE)
           AND      20h
           JP       Z,RTP2
           LD       D,H
           LD       HL,0
           LD       (SUMDT),HL
           POP      HL
           POP      BC
           PUSH     BC
           PUSH     HL
RTP3:      CALL     RBYTE
           JP       C,RTP6
           LD       (HL),A
           INC      HL
           DEC      BC
           LD       A,B
           OR       C
           JP       NZ,RTP3
           LD       HL,(SUMDT)
           CALL     RBYTE                 ; Checksum MSB
           JP       C,RTP6
           LD       D,A
           CALL     RBYTE                 ; Checksum LSB
           JP       C,RTP6
           LD       E,A
           CP       L
           JP       NZ,RTP5
           LD       A,D
           CP       H
           JP       NZ,RTP5
RTP0:      XOR      A
           ;
           PUSH     HL
           PUSH     DE
           PUSH     DE
           LD       DE,MSG_CHKSUM_MZ1
           CALL     MSGX
           CALL     PRTHL
           CALL     NL
           LD       DE,MSG_CHKSUM_TP1
           CALL     MSGX
           POP      DE
           EX       DE,HL
           CALL     PRTHL
           CALL     NL
           POP      DE
           POP      HL
           ;
RTP4:      
RET2:      POP      HL
           POP      BC
           POP      DE
           CALL     MSTOP
           PUSH     AF
           LD       A,(TIMFG)
           CP       0F0h
           JR       NZ,RTP8
           EI
RTP8:      POP      AF
           RET

RTP5:      PUSH     HL
           PUSH     DE
           PUSH     DE
           LD       DE,MSG_CHKSUM_MZ2
           CALL     MSGX
           CALL     PRTHL
           CALL     NL
           LD       DE,MSG_CHKSUM_TP2
           CALL     MSGX
           POP      DE
           EX       DE,HL
           CALL     PRTHL
           CALL     NL
           POP      DE
           POP      HL
           ;
           LD       D,1
           DEC      D
           JR       Z,RTP7
           LD       H,D
           CALL     GAPCK
           JP       RTP1
RTP7:      LD       A,1
           JR       RTP9
RTP6:      LD       A,2
RTP9:      SCF
           JR       RTP4


           ;
           ; EDGE
           ;  BC = KEYPB
           ;  DE = CSTR
           ; EXIT CF = 0 : EDGE
           ;         = 1 : BREAK
           ;
EDGE:      LD       A,0F0h
           LD       (KEYPA),A
           NOP
EDG1:      LD       A,(BC)
           AND      81h             ; SHIFT & BREAK
           JP       NZ,EDG0
           SCF
           RET
EDG0:      LD       A,(DE)
           AND      20h
           JP       NZ,EDG1
EDG2:      LD       A,(BC)
           AND      81h
           JP       NZ,EDG3
           SCF
           RET
EDG3:      LD       A,(DE)
           AND      20h
           JP       Z,EDG2
           RET


           ;
           ; 1 BYTE READ
           ;
           ; EXIT  SUMDT=STORE
           ; CF = 1 : BREAK
           ;    = 0 : DATA=ACC
           ;
RBYTE:     PUSH     BC
           PUSH     DE
           PUSH     HL
           LD       HL,0800h
           LD       BC,KEYPB
           LD       DE,CSTR
RBY1:      CALL     EDGE
           JP       C,RBY3
           CALL     DLY3
           LD       A,(DE)
           AND      20h
           JP       Z,RBY2
           PUSH     HL
           LD       HL,(SUMDT)
           INC      HL
           LD       (SUMDT),HL
           POP      HL
           SCF
RBY2:      LD       A,L
           RLA
           LD       L,A
           DEC      H
           JP       NZ,RBY1
           CALL     EDGE
           LD       A,L
RBY3:      POP      HL
           POP      DE
           POP      BC
           RET

           ;
           ; TAPE MARK DETECT
           ;
           ;    E=@L@     : INFORMATION
           ;     =@S@     : DATA
           ; EXIT CF = 0  : OK
           ;         = 1  : BREAK
           ;
TMARK:     CALL     GAPCK
           PUSH     BC
           PUSH     DE
           PUSH     HL
           PUSH     BC
           PUSH     DE
           LD       DE,MSG_TAPEMARK
           CALL     MSG
           CALL     NL
           POP      DE
           POP      BC
           LD       HL,2828h
           LD       A,E
           CP       0CCh
           JP       Z,TM0
           LD       HL,1414h
TM0:       LD       (TMCNT),HL
           LD       BC,KEYPB
           LD       DE,CSTR
TM1:       LD       HL,(TMCNT)
TM2:       CALL     EDGE
           JP       C,TM4
           CALL     DLY3
           LD       A,(DE)
           AND      20h
           JP       Z,TM1
           DEC      H
           JP       NZ,TM2
;  CALL     PRTHL
TM3:       CALL     EDGE
           JP       C,TM4
           CALL     DLY3
           LD       A,(DE)
           AND      20h
           JP       NZ,TM1
           DEC      L
           JP       NZ,TM3
           CALL     EDGE
RET3:
TM4:       POP      HL
           POP      DE
           POP      BC
           RET

TM4A:      CALL     NL
           CALL     PRTHL       ; Print HL as 4digit hex.
           LD       A,0C4h      ; Move cursor left.
TM4B:      CALL     DPCT
           CALL     DPCT
           CALL     DPCT
           CALL     DPCT
           CALL     NL
           JP       GETL1

           ;
           ; MOTOR ON
           ;
           ;    D=@W@   : WRITE
           ;     =@R@   : READ
           ; EXIT CF=0  : OK
           ;        =1  : BREAK
MOTOR:     PUSH     BC
           PUSH     DE
           PUSH     HL
           PUSH     BC
           PUSH     DE
           LD       DE,MSG_MOTORTG
           CALL     MSG
           CALL     NL
           POP      DE
           POP      BC
           LD       B,10
MOT1:      LD       A,(CSTR)
           AND      10h
           JR       Z,MOT4
MOT2:      LD       B,0A6h
MOT3:      CALL     DLY12
           DJNZ     MOT3
           XOR      A
MOT7:      JR       RET3
MOT4:      LD       A,06h
           LD       HL,CSTPT
           LD       (HL),A
           INC      A
           LD       (HL),A
           DJNZ     MOT1
           CALL     NL
           LD       A,D
           CP       0D7h
           JR       Z,MOT8
           LD       DE,MSG1
           JR       MOT9
MOT8:      LD       DE,MSG3
           CALL     MSGX
           LD       DE,MSG2
MOT9:      CALL     MSGX
MOT5:      LD       A,(CSTR)
           AND      10h
           JR       NZ,MOT2
           CALL     ?BRK
           JR       NZ,MOT5
           SCF
           JR       MOT7

           ;
           ; MOTOR STOP
           ;
MSTOP:     PUSH     AF
           PUSH     BC
           PUSH     DE
           PUSH     BC
           PUSH     DE
           LD       DE,MSG_MOTORSTP
           CALL     MSG
           CALL     NL
           POP      DE
           POP      BC
           LD       B,10
MST1:      LD       A,(CSTR)
           AND      10H
           JR       Z,MST3
MST2:      LD       A,06h
           LD       (CSTPT),A
           INC      A
           LD       (CSTPT),A
           DJNZ     MST1
MST3:      JP       ?RSTR1

           ;
           ; CHECK SUM
           ;
           ;   BC = SIZE
           ;   HL = DATA ADR
           ; EXIT SUMDT=STORE
           ;      CSMDT=STORE
           ;
CKSUM:     PUSH     BC
           PUSH     DE
           PUSH     HL
           LD       DE,0
CKS1:      LD       A,B
           OR       C
           JR       NZ,CKS2
           EX       DE,HL
           LD       (SUMDT),HL
           LD       (CSMDT),HL
           POP      HL
           POP      DE
           POP      BC
           RET
CKS2:      LD       A,(HL)
           PUSH     BC
           LD       B,+8
CKS3:      RLCA
           JR       NC,CKS4
           INC      DE
CKS4:       DJNZ     CKS3
           POP      BC
           INC      HL
           DEC      BC
           JR       CKS1


           ;
           ; 107 uS DELAY
           ;
DLY1:      LD       A,14
DLY1A:     DEC      A
           JP       NZ,DLY1A
           RET

           ;
           ; 240 uS DELAY
           ;
DLY2:      LD       A,13
DLY2A:     DEC      A
           JP       NZ,DLY2A
           RET

           ;
           ; 240 uS x 3 DELAY
           ;
DLY3:      NEG
           NEG
           LD       A,42
           JP       DLY2A

           ;
           ; 12mS DELAY
DLY12:     PUSH     BC
           LD       B,35
DLY12A:    CALL     DLY3
           DJNZ     DLY12A
           POP      BC
           RET


           ;
           ; GAP * TAPEMARK
           ;
           ;  E = @L@   : LONG GAP
           ;    = @S@   : SHORT GAP
           ;
GAP:       PUSH     BC
           PUSH     DE
           PUSH     HL
           LD       A,E
           LD       BC,55F0h           ;Number of pulses for the Long Gap.
           LD       DE,2828h           ;40 + 40 LTM
           CP       0CCh
           JP       Z,GAP0
           LD       BC,2AF8h           ;Number of pulses for a Short Gap.
           LD       DE,1414h           ;20 + 20 LTM
GAP0:      PUSH     DE
           LD       DE,MSG_WGAPS
           CALL     MSG
           ;
GAP1:      CALL     SHORT              ;22000 short GAP pulses.
           LD       H,B
           LD       L,C
           LD       A,000h
           CP       L
           JR       NZ,GAP1D
           CALL     PRTHL              ; Print HL as 4digit hex.
           LD       A,0C4h             ; Move cursor left.
           LD       E,004h             ; 4 times.
GAP1B:     CALL     DPCT
           DEC      E
           JR       NZ,GAP1B
GAP1D:     DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GAP1
           LD       H,B
           LD       L,C
           CALL     PRTHL              ; Print HL as 4digit hex.
           LD       DE,MSG_SPC
           CALL     MSG
           CALL     LETNL
           POP      DE
           ;
           LD       BC,20000            ; 2 Second delay
GAP1C:     CALL     DLY1
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GAP1C
           ;
           PUSH     DE
GAP1A:     LD       DE,MSG_WGAPL
           CALL     MSGX
           POP      DE
GAP2:      PUSH     DE
           CALL     LONG               ;40 or 20 Long Pulses (LTM or STM)
           LD       H,00h
           LD       L,D
           CALL     PRTHL              ; Print HL as 4digit hex.
           LD       A,0C4h             ; Move cursor left.
           LD       E,004h             ; 4 times.
GAP2B:     CALL     DPCT
           DEC      E
           JR       NZ,GAP2B
           LD       BC,1000           ; .1 Second delay
GAP2D:     CALL     DLY1
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GAP2D
           POP      DE
           DEC      D
           JR       NZ,GAP2
           LD       H,000h
           LD       L,D
           CALL     PRTHL              ; Print HL as 4digit hex.
           PUSH     DE
           LD       DE,MSG_SPC
           CALL     MSG
           CALL     LETNL
           POP      DE
           ;
           LD       BC,20000           ; 2 Second delay
GAP2C:     CALL     DLY1
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GAP2C
           ;
GAP2A:     PUSH     DE
           LD       DE,MSG_WGAPS2
           CALL     MSGX
           POP      DE
GAP3:      PUSH     DE
           CALL     SHORT              ;40 or 20 Short Pulses (LTM or STM)
           LD       H,00h
           LD       L,E
           CALL     PRTHL              ; Print HL as 4digit hex.
           LD       A,0C4h             ; Move cursor left.
           LD       E,004h             ; 4 times.
GAP3B:     CALL     DPCT
           DEC      E
           JR       NZ,GAP3B
           LD       BC,1000            ; .1 Second delay
GAP3D:     CALL     DLY1
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GAP3D
           POP      DE
           DEC      E
           JR       NZ,GAP3
           LD       H,000h
           LD       L,E
           CALL     PRTHL              ; Print HL as 4digit hex.
           PUSH     DE
           LD       DE,MSG_SPC
           CALL     MSGX
           CALL     LETNL
           POP      DE
           ;
           LD       BC,20000           ; 2 Second delay
GAP3C:     CALL     DLY1
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,GAP3C
           ;
GAP3A:     PUSH     DE
           LD       DE,MSG_WGAPL2
           CALL     MSGX
           CALL     LETNL
           POP      DE
           CALL     LONG               ;1 Long Pulse
           POP      HL
           POP      DE
           POP      BC
           RET

           ;GAP Test - fixed 80 x short, 80 x long to see if hardware is receiving and counting correctly.
           ;
;GAP:       PUSH     BC
;           PUSH     DE
;GAP0:      LD       BC,050h          ;Number of pulses for the Long Gap.
;GAP1:      CALL     SHORT              
;GAP1A:     DEC      BC
;           LD       A,B
;           OR       C
;           JR       NZ,GAP1
;           LD       BC,0050h          ;Number of pulses for the Long Gap.
;GAP2:      CALL     LONG              
;GAP2A:     DEC      BC
;           LD       A,B
;           OR       C
;           JR       NZ,GAP2
;GAP3A:     JR       GAP3A
;GAP3:      POP      DE
;           POP      BC
;           RET


           ;
           ; GAP CHECK
           ;
GAPCK:     PUSH     BC
           PUSH     DE
           PUSH     HL
           LD       DE,MSG_GAPCK
           CALL     MSG
           CALL     NL
           LD       BC,KEYPB
           LD       DE,CSTR
GAPCK1:    LD       H,100
GAPCK2:    CALL     EDGE
           JR       C,GAPCK3
           CALL     DLY3
           LD       A,(DE)
           AND      20h
           JR       NZ,GAPCK1
           DEC      H
           JR       NZ,GAPCK2
GAPCK3:    JP       RET3

           ;
           ; 1 bit write
           ; Short Pulse
           ;
SHORT:     PUSH     AF
           LD       A,03h
           LD       (CSTPT),A
           CALL     DLY1
           CALL     DLY1
           LD       A,02h
           LD       (CSTPT),A
           CALL     DLY1
           CALL     DLY1
           POP      AF
           RET

           ;
           ; 1 bit write
           ; Long Pulse
           ;
LONG:      PUSH     AF
           LD       A,03h
           LD       (CSTPT),A
           CALL     DLY1
           CALL     DLY1
           CALL     DLY1
           CALL     DLY1
           LD       A,02h
           LD       (CSTPT),A
           CALL     DLY1
           CALL     DLY1
           CALL     DLY1
           CALL     DLY2
           POP      AF
           RET


           ;    WRITE INFORMATION

QWRI:      DI      
           PUSH     DE
           PUSH     BC
           PUSH     HL
           LD       D,0D7H                                                   ; "W"
           LD       E,0CCH                                                   ; "L"
           LD       HL,IBUFE                                                 ; 10F0H
           LD       BC,80H                                                   ; WRITE BYTE SIZE
WRI1:      CALL     CKSUM                                                    ; CHECK SUM
           CALL     MOTOR                                                    ; MOTOR ON
           JR       C,WRI3
           LD       A,E
           CP       0CCH                                                     ; "L" - Long Gap/Tape Mark?
           JR       NZ,WRI2
           CALL     NL
           PUSH     DE
           LD       DE,MSGN7                                                 ; WRITING
           RST      18H                                                      ; CALL MSGX
           LD       DE,NAME                                                  ; FILE NAME
           RST      18H                                                      ; CALL MSGX
           CALL     NL
           POP      DE
WRI2:      CALL     GAP
           CALL     WTAPE
WRI3:      JP       RET2


           ;    WRITE DATA
           ;    EXIT CF=0 : OK
           ;           =1 : BREAK

QWRD:      DI      
           PUSH     DE
           PUSH     BC
           PUSH     HL
           LD       D,0D7H                                                   ; "W"
           LD       E,53H                                                    ; "S"
L047D:     LD       BC,(SIZE)                                                ; WRITE DATA BYTE SIZE
           LD       HL,(DTADR)                                               ; WRITE DATA ADDRESS
           LD       A,B
           OR       C
           JP       Z,RET1
           JR       WRI1

           ;    TAPE WRITE
           ;    BC=BYTE SIZE
           ;    HL=DATA LOW ADDRESS
           ;    EXIT CF=0 : OK
           ;           =1 : BREAK

WTAPE:     PUSH     DE
           PUSH     BC
           PUSH     HL
           LD       D,02H
           LD       A,0F0H                                                   ; 88H WOULD BE BETTER!!
           LD       (KEYPA),A                                                ; E000H
WTAP1:     LD       A,(HL)
           CALL     WBYTE                                                    ; 1 BYTE WRITE
           LD       A,(KEYPB)                                                ; E001H
           AND      81H                                                      ; SHIFT & BREAK
           JP       NZ,WTAP2
           LD       A,02H                                                    ; BREAK IN CODE
           SCF     
           JR       WTAP3

WTAP2:     INC      HL
           DEC      BC
           LD       A,B
           OR       C
           JP       NZ,WTAP1
           LD       HL,(SUMDT)                                               ; SUM DATA SET
           LD       A,H
           CALL     WBYTE                                                    ; Send Checksum
           LD       A,L
           CALL     WBYTE
WTAP3A:    PUSH     DE
           LD       DE,MSG_WGAPL2
           CALL     MSGX
           CALL     LETNL
           POP      DE
           CALL     LONG
           DEC      D
           JP       NZ,L04C2                                                 ; Another copy to be sent?
           OR       A
           JP       WTAP3

L04C2:     PUSH     DE
           LD       DE,MSG_SPCS
           CALL     MSGX
           POP      DE
           LD       B,0                                                      ; Send 256 short pulses.

L04C4:     CALL     SHORT
           LD       H,00h
           LD       L,B
           CALL     PRTHL              ; Print HL as 4digit hex.
           LD       A,0C4h             ; Move cursor left.
           LD       E,004h             ; 4 times.
SPCS2:     CALL     DPCT
           DEC      E
           JR       NZ,SPCS2
           DEC      B
           JP       NZ,L04C4
           LD       H,00h
           LD       L,B
           CALL     PRTHL              ; Print HL as 4digit hex.
           LD       BC,2500            ; .25 Second delay
SPCS3:     CALL     DLY1
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,SPCS3
           CALL     LETNL
           POP      HL                                                       ; Retrieve saved location and size
           POP      BC
           PUSH     BC
           PUSH     HL
           JP       WTAP1                                                    ; Repeat send.

WTAP3:
RET1:      POP      HL
           POP      BC
           POP      DE
           RET     

           DB       2FH
           DB       4EH

           ;    VERIFY (FROM $CMT)
           ;    EXIT ACC=0 : OK CF=0
           ;            =1 : ER CF=1
           ;            =2 : BREAK CF=1

QVRFY:     DI      
           PUSH     DE
           PUSH     BC
           PUSH     HL
           LD       BC,(SIZE)
           LD       HL,(DTADR)
           LD       D,0D2H                                                   ; "R"
           LD       E,53H                                                    ; "S"
           LD       A,B
           OR       C
           JP       Z,RTP4                                                   ; END
           CALL     CKSUM
           CALL     MOTOR
           JP       C,RTP6                                                   ; BRK
           CALL     TMARK                                                    ; TAPE MARK DETECT
           JP       C,RTP6                                                   ; BRK
           CALL     TVRFY
           JP       RTP4

           ;    DATA VERIFY
           ;    BC=SIZE
           ;    HL=DATA LOW ADDRESS
           ;    CSMDT=CHECK SUM
           ;    EXIT ACC=0 : OK  CF=0
           ;            =1 : ER    =1
           ;            =2 : BREAK =1

TVRFY:     PUSH     DE
           PUSH     BC
           PUSH     HL
           LD       H,02H                                                    ; COMPARE TWICE
TVF1:      LD       BC,KEYPB
           LD       DE,CSTR
TVF2:      CALL     EDGE
           JP       C,RTP6                                                   ; BRK
           CALL     DLY3                                                     ; CALL DLY2*3
           LD       A,(DE)
           AND      20H
           JP       Z,TVF2
           LD       D,H
           POP      HL
           POP      BC
           PUSH     BC
           PUSH     HL
           ;    COMPARE TAPE DATA AND STORAGE
TVF3:      CALL     RBYTE
           JP       C,RTP6                                                   ; BRK
           CP       (HL)
           JP       NZ,RTP7                                                  ; ERROR, NOT EQUAL
           INC      HL                                                       ; STORAGE ADDRESS + 1
           DEC      BC                                                       ; SIZE - 1
           LD       A,B
           OR       C
           JR       NZ,TVF3
           ;    COMPARE CHECK SUM (1199H/CSMDT) AND TAPE
           LD       HL,(CSMDT)
           CALL     RBYTE
           CP       H
           JP       NZ,RTP7                                                  ; ERROR, NOT EQUAL
           CALL     RBYTE
           CP       L
           JP       NZ,RTP7                                                  ; ERROR, NOT EQUAL
           DEC      D                                                        ; NUMBER OF COMPARES (2) - 1
           JP       Z,RTP8                                                   ; OK, 2 COMPARES
           LD       H,D                                                      ; (-->05C7H), SAVE NUMBER OF COMPARES
           JR       TVF1                                                     ; NEXT COMPARE

           ;    1 BYTE WRITE

WBYTE:     PUSH     BC
           LD       B,8
           CALL     LONG
WBY1:      RLCA    
           CALL     C,LONG
           CALL     NC,SHORT
           DEC      B
           JP       NZ,WBY1
           POP      BC
           RET     

ARARA:     POP      HL
           JP       ABCD

DLY1S:     PUSH     AF
           PUSH     BC
           LD       C,10
L0324:     CALL     DLY12
           DEC      C
           JR       NZ,L0324
           POP      BC
           POP      AF
           RET

           ; Test the 8253 Timer, configure it as per the monitor and display the read back values.
TIMERTST:  CALL     NL
           LD       DE,MSG_TIMERTST
           CALL     MSG
           CALL     NL
           LD       DE,MSG_TIMERVAL
           CALL     MSG
           LD       A,01h
           LD       DE,8000h
           CALL     ?TMST
NDE:       JP       NDE
           JP       GETL1
?TMST:     DI      
           PUSH     BC
           PUSH     DE
           PUSH     HL
           LD       (AMPM),A
           LD       A,0F0H
           LD       (TIMFG),A
ABCD:      LD       HL,0A8C0H
           XOR      A
           SBC      HL,DE
           PUSH     HL
           INC      HL
           EX       DE,HL

           LD       HL,CONTF    ; Control Register
           LD       (HL),0B0H   ; 10110000 Control Counter 2 10, Write 2 bytes 11, 000 Interrupt on Terminal Count, 0 16 bit binary
           LD       (HL),074H   ; 01110100 Control Counter 1 01, Write 2 bytes 11, 010 Rate Generator, 0 16 bit binary
           LD       (HL),030H   ; 00110100 Control Counter 1 01, Write 2 bytes 11, 010 interrupt on Terminal Count, 0 16 bit binary

           LD       HL,CONT2    ; Counter 2
           LD       (HL),E
           LD       (HL),D

           LD       HL,CONT1    ; Counter 1
           LD       (HL),00AH
           LD       (HL),000H

           LD       HL,CONT0    ; Counter 0
           LD       (HL),00CH
           LD       (HL),0C0H

;           LD       HL,CONT2    ; Counter 2
;           LD       C,(HL)
;           LD       A,(HL)
;           CP       D
;           JP       NZ,L0323                
;           LD       A,C
;           CP       E
;           JP       Z,CDEF                
           ;

L0323:     PUSH     AF
           PUSH     BC
           PUSH     DE
           PUSH     HL
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),080H
           LD       HL,CONT2    ; Counter 2
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     PRNTS
           ;CALL     DLY1S
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),040H
           LD       HL,CONT1    ; Counter 1
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     PRNTS
           ;CALL     DLY1S
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),000H
           LD       HL,CONT0    ; Counter 0
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           ;CALL     DLY1S
           ;
           LD       A,0C4h      ; Move cursor left.
           LD       E,0Eh      ; 4 times.
L0330:     CALL     DPCT
           DEC      E
           JR       NZ,L0330
           ;
;           LD       C,20
;L0324:     CALL     DLY12
;           DEC      C
;           JR       NZ,L0324
           ;
           POP      HL
           POP      DE
           POP      BC
           POP      AF
           ;
           LD       HL,CONT2    ; Counter 2
           LD       C,(HL)
           LD       A,(HL)
           CP       D
           JP       NZ,L0323                
           LD       A,C
           CP       E
           JP       NZ,L0323                
           ;
           ;
           PUSH     AF
           PUSH     BC
           PUSH     DE
           PUSH     HL
           CALL     NL
           CALL     NL
           CALL     NL
           LD       DE,MSG_TIMERVAL2
           CALL     MSG
           POP      HL
           POP      DE
           POP      BC
           POP      AF

           ;
CDEF:      POP      DE
           LD       HL,CONT1
           LD       (HL),00CH
           LD       (HL),07BH
           INC      HL

L0336:     PUSH     AF
           PUSH     BC
           PUSH     DE
           PUSH     HL
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),080H
           LD       HL,CONT2    ; Counter 2
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     PRNTS
           CALL     DLY1S
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),040H
           LD       HL,CONT1    ; Counter 1
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     PRNTS
           CALL     DLY1S
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),000H
           LD       HL,CONT0    ; Counter 0
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     DLY1S
           ;
           LD       A,0C4h      ; Move cursor left.
           LD       E,0Eh      ; 4 times.
L0340:     CALL     DPCT
           DEC      E
           JR       NZ,L0340
           ;
           POP      HL
           POP      DE
           POP      BC
           POP      AF

           LD       HL,CONT2    ; Counter 2
           LD       C,(HL)
           LD       A,(HL)
           CP       D
           JR       NZ,L0336                
           LD       A,C
           CP       E
           JR       NZ,L0336                
           CALL     NL
           LD       DE,MSG_TIMERVAL3
           CALL     MSG
           POP      HL
           POP      DE
           POP      BC
           EI      
           RET     

?TMRD:     PUSH     HL
           LD       HL,CONTF
           LD       (HL),080H
           DEC      HL
           DI      
           LD       E,(HL)
           LD       D,(HL)
           EI      
           LD       A,E
           OR       D
           JR       Z,?TMR1                 
           XOR      A
           LD       HL,0A8C0H
           SBC      HL,DE
           JR       C,?TMR2                 
           EX       DE,HL
           LD       A,(AMPM)
           POP      HL
           RET     

?TMR1:     LD       DE,0A8C0H
?TMR1A:    LD       A,(AMPM)
           XOR      001H
           POP      HL
           RET     

?TMR2:     DI      
           LD       HL,CONT2
           LD       A,(HL)
           CPL      
           LD       E,A
           LD       A,(HL)
           CPL      
           LD       D,A
           EI      
           INC      DE
           JR       ?TMR1A     

TIMIN:     PUSH     AF
           PUSH     BC
           PUSH     DE
           PUSH     HL
           LD       HL,AMPM
           LD       A,(HL)
           XOR      001H
           LD       (HL),A
           LD       HL,CONTF
           LD       (HL),080H
           DEC      HL
           PUSH     HL
           LD       E,(HL)
           LD       D,(HL)
           LD       HL,0A8C0H
           ADD      HL,DE
           DEC      HL
           DEC      HL
           EX       DE,HL
           POP      HL
           LD       (HL),E
           LD       (HL),D
           POP      HL
           POP      DE
           POP      BC
           POP      AF
           EI      
           RET

           ; Method to clear memory either to 0 or a given pattern.
           ;
CLR8Z:     XOR      A
CLR8:      LD       BC,00800H
CLRMEM:    PUSH     DE
           LD       D,A
L09E8:     LD       (HL),D
           INC      HL
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,L09E8                
           POP      DE
           RET     

           ; Help/Synoposis of commands available.
           ;
HELP:      CALL     LETNL
           LD       DE,MSG_HELP1
           CALL     MSG
           CALL     LETNL
           LD       DE,MSG_HELP2
           CALL     MSG
           CALL     LETNL
           LD       DE,MSG_HELP3
           CALL     MSG
           CALL     LETNL
           LD       DE,MSG_HELP4
           CALL     MSG
           CALL     LETNL
           LD       DE,MSG_HELP5
           CALL     MSG
           CALL     LETNL
           LD       DE,MSG_HELP6
           CALL     MSG
           CALL     LETNL
           LD       DE,MSG_HELP7
           CALL     MSG
           CALL     LETNL
           LD       DE,MSG_HELP8
           CALL     MSG
           CALL     LETNL
           LD       DE,MSG_HELP9
           CALL     MSG
           CALL     LETNL
           CALL     LETNL
           JP       GETL1

TMPADR:    DW       00000H
GPUCHAR:   DW       00000H
GPUATTR:   DW       00000H
GPUSTARTX: DW       00000H
GPUSTARTY: DW       00000H
GPUENDX:   DW       00000H
GPUENDY:   DW       00000H


MSG_HELP1: DB       "GRPH[1-2]= TEST GRAPHICS",   0Dh, 00h
MSG_HELP2: DB       "GPU[1-2] = TEST GPU",        0Dh, 00h
MSG_HELP3: DB       "PAL      = TEST PALETTE",    0Dh, 00h
MSG_HELP4: DB       "MEMTEST  = TEST MEMORY",     0Dh, 00h
MSG_HELP5: DB       "LOAD     = LOAD TAPE",       0Dh, 00h
MSG_HELP6: DB       "TIMER    = TIMER TEST",      0Dh, 00h
MSG_HELP7: DB       "SAVE     = WRITE TEST TAPE", 0Dh, 00h
MSG_HELP8: DB       "VGA[0-3] = SET VGA MODE",    0Dh, 00h
MSG_HELP9: DB       "QUIT     = QUIT TO MONITOR", 0Dh, 00h

TITLE:     DB       "SHARPMZ TESTER (C) P.SMART 2018-20", 0Dh, 00h
MSG_INITGR:DB       "INIT GRAPHICS", 0Dh
MSG_INITM: DB       "INIT MEMORY", 0Dh
TITLE_SAVE:DB       "WRITE TEST TAPE", 0Dh
            
MSGBADCMD: DB       "???", 0DH, 00H
MSG1:      DW       207Fh
MSG2:      DB       "PLAY", 0Dh, 00h
MSG3:      DW       207Fh                     ; PRESS RECORD
           DB       "RECORD.", 0Dh, 00h
MSGN7:     DB       "WRITING ", 0Dh, 00h
MSGOK:     DB       "OK", 0Dh, 00h
MSG_ERRCHKSUM:
           DB       "CHECKSUM ERROR", 0Dh
MSG_ERRWRITE:
           DB       "WRITE ERROR", 0Dh

MSG_READTAPE:
           DB       "READ TAPE", 0Dh, 00h
MSG_TAPEMARK:
           DB       "TAPEMARK", 0Dh, 00h
MSG_MOTORTG:
           DB       "MOTOR TOGGLE", 0Dh, 00h
MSG_MOTORSTP:
           DB       "MOTOR STOP", 0Dh, 00h
MSG_TPMARK:
           DB       "TAPE MARK START", 0Dh, 00h
MSG_GAPCK:
           DB       "GAP CHECK", 0Dh, 00h
MSG_LOADFILE:
           DB       "LOAD FILE          = ",0Dh, 00h
MSG_LOADFROM:
           DB       "LOAD ADDRESS       = ", 0Dh, 00h
MSG_LOADEXEC:
           DB       "EXEC ADDRESS       = ", 0Dh, 00h
MSG_LOADSIZE:
           DB       "LOAD SIZE          = ", 0Dh, 00h
MSG_SAVEFILE:
           DB       "SAVE FILE          = ",0Dh, 00h
MSG_SAVEFROM:
           DB       "SAVE ADDRESS       = ", 0Dh, 00h
MSG_SAVEEXEC:
           DB       "SAVE EXEC ADDRESS  = ", 0Dh, 00h
MSG_SAVESIZE:
           DB       "SAVE SIZE          = ", 0Dh, 00h
MSG_CHKSUM_MZ1:
           DB       "  MZ CHECKSUM (OK) = ", 0Dh, 00h
MSG_CHKSUM_TP1:
           DB       "TAPE CHECKSUM (OK) = ", 0Dh, 00h
MSG_CHKSUM_MZ2:
           DB       "  MZ CHECKSUM (ER) = ", 0Dh, 00h
MSG_CHKSUM_TP2:
           DB       "TAPE CHECKSUM (ER) = ", 0Dh, 00h
MSG_WHDR:  DB       "WRITE HEADER...", 0Dh
MSG_WDATA: DB       "WRITE DATA...", 0Dh
MSGGAP:    DB       "GAP WRITTEN", 0Dh, 00h
MSG_WGAPS: DB       "WRITE GAP: ", 0Dh, 00h
MSG_WGAPS2:DB       "WRITE TM SHORT: ", 0Dh, 00h
MSG_WGAPL: DB       "WRITE TM LONG: ", 0Dh, 00h
MSG_WGAPL2:DB       "WRITE 1 LONG BIT", 0Dh, 00h
MSG_SPCS:  DB       "WRITE 256 SHORT: ", 0Dh, 00h
MSG_SPC:   DB       ", WAIT.", 0Dh, 00h
MSGTAPE    DB       "HEADER WRITTEN", 0Dh, 00h
MSG_TIMERTST:
           DB      "8253 TIMER TEST", 0Dh, 00h
MSG_TIMERVAL:
           DB      "READ VALUE 1: ", 0Dh, 00h
MSG_TIMERVAL2:
           DB      "READ VALUE 2: ", 0Dh, 00h
MSG_TIMERVAL3:
           DB      "READ DONE.", 0Dh, 00h

OKCHECK:   DB      ", CHECK: ", 0Dh
OKMSG:     DB      " OK.", 0Dh
DONEMSG:   DB      11h
           DB      "RAM TEST COMPLETE.", 0Dh

BITMSG:    DB      " BIT:  ", 0Dh
BANKMSG:   DB      " BANK: ", 0Dh

GRPHPOS:   DB      00h, 00h

           ; Test tape image to save.
TESTBUF:                                                                 ; TAPE BUFFER (128 BYTES)
TATRB:     DB       02h                                                  ; Code Type, 01 = Machine Code.
TNAME:     DB       "TEST TAPE SAVE", 0Dh, 00h, 00h                      ; Title/Name (17 bytes).
TSIZE:     DW       TESTEND - TESTSTART                                  ; Size of program.
TDTADR:    DW       TESTSTART                                            ; Load address of program.
TEXADR:    DW       TESTSTART                                            ; Exec address of program.
TCOMNT:    DB       "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

TESTSTART: DB       01h
           DB       0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
           DB       16,17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
           DB       32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
           DB       48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
           DB       64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
           DB       80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
           DB       96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111
           DB       112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127
           DB       128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143
           DB       144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159
           DB       160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175
           DB       176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191
           DB       192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207
           DB       208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223
           DB       224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239
           DB       240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255 
TESTEND:

MEND:
