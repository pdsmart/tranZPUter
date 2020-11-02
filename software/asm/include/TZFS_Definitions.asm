;--------------------------------------------------------------------------------------------------------
;-
;- Name:            TZFS_Definitions.asm
;- Created:         September 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series tzfs (tranZPUter Filing System).
;-                  This assembly language program is a branch from the original RFS written for the
;-                  MZ80A_RFS upgrade board. It is adapted to work within the similar yet different 
;-                  environment of the tranZPUter SW which has a large RAM capacity (512K) and an
;-                  I/O processor in the K64F/ZPU.
;-
;- Credits:         
;- Copyright:       (c) 2019-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         May 2020  - Branch taken from RFS v2.0 and adapted for the tranZPUter SW.
;-                  July 2020 - Updates to accommodate v2.1 of the tranZPUter board.
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

;-----------------------------------------------
; Features.
;-----------------------------------------------

;-----------------------------------------------
; Entry/compilation start points.
;-----------------------------------------------
MROMADDR                EQU     00000H                                   ; Start of SA1510 Monitor ROM.
UROMADDR                EQU     0E800H                                   ; Start of User ROM Address space.
UROMBSTBL               EQU     UROMADDR + 020H                          ; Entry point to the bank switching table.
TZFSJMPTABLE            EQU     UROMADDR + 00080H                        ; Start of jump table.
BANKRAMADDR             EQU     0F000H                                   ; Start address of the banked RAM used for TZFS functionality.
FDCROMADDR              EQU     0F000H
FDCJMP1BLK              EQU     0F3C0H                                   ; The memory mapping FlashRAM only has 64byte granularity so we need to block 64 bytes per FDC vector.
FDCJMP1                 EQU     0F3FEH                                   ; ROM paged vector 1.
FDCJMP2BLK              EQU     0F7C0H                                   ; The memory mapping FlashRAM only has 64byte granularity so we need to block 64 bytes per FDC vector.
FDCJMP2                 EQU     0F7FEH                                   ; ROM paged vector 2.

;-----------------------------------------------
; Common character definitions.
;-----------------------------------------------
SCROLL                  EQU     001H                                     ;Set scroll direction UP.
BELL                    EQU     007H
SPACE                   EQU     020H
TAB                     EQU     009H                                     ;TAB ACROSS (8 SPACES FOR SD-BOARD)
CR                      EQU     00DH
LF                      EQU     00AH
FF                      EQU     00CH
DELETE                  EQU     07FH
BACKS                   EQU     008H
SOH                     EQU     1                                        ; For XModem etc.
EOT                     EQU     4
ACK                     EQU     6
NAK                     EQU     015H
NUL                     EQU     000H
NULL                    EQU     000H
CTRL_A                  EQU     001H
CTRL_B                  EQU     002H
CTRL_C                  EQU     003H
CTRL_D                  EQU     004H
CTRL_E                  EQU     005H
CTRL_F                  EQU     006H
CTRL_G                  EQU     007H
CTRL_H                  EQU     008H
CTRL_I                  EQU     009H
CTRL_J                  EQU     00AH
CTRL_K                  EQU     00BH
CTRL_L                  EQU     00CH
CTRL_M                  EQU     00DH
CTRL_N                  EQU     00EH
CTRL_O                  EQU     00FH
CTRL_P                  EQU     010H
CTRL_Q                  EQU     011H
CTRL_R                  EQU     012H
CTRL_S                  EQU     013H
CTRL_T                  EQU     014H
CTRL_U                  EQU     015H
CTRL_V                  EQU     016H
CTRL_W                  EQU     017H
CTRL_X                  EQU     018H
CTRL_Y                  EQU     019H
CTRL_Z                  EQU     01AH
ESC                     EQU     01BH
CTRL_SLASH              EQU     01CH
CTRL_RB                 EQU     01DH
CTRL_CAPPA              EQU     01EH
CTRL_UNDSCR             EQU     01FH
CTRL_AT                 EQU     000H
NOKEY                   EQU     0F0H
CURSRIGHT               EQU     0F1H
CURSLEFT                EQU     0F2H
CURSUP                  EQU     0F3H
CURSDOWN                EQU     0F4H
DBLZERO                 EQU     0F5H
INSERT                  EQU     0F6H
CLRKEY                  EQU     0F7H
HOMEKEY                 EQU     0F8H
BREAKKEY                EQU     0FBH


;-------------------------------------------------------
; Function entry points in the standard SA-1510 Monitor.
;-------------------------------------------------------
GETL:                   EQU     00003h
LETNL:                  EQU     00006h
NL:                     EQU     00009h
PRNTS:                  EQU     0000Ch
PRNT:                   EQU     00012h
MSG:                    EQU     00015h
MSGX:                   EQU     00018h
GETKY                   EQU     0001Bh
BRKEY                   EQU     0001Eh
?WRI                    EQU     00021h
?WRD                    EQU     00024h
?RDI                    EQU     00027h
?RDD                    EQU     0002Ah
?VRFY                   EQU     0002Dh
MELDY                   EQU     00030h
?TMST                   EQU     00033h
MONIT:                  EQU     00000h
SS:                     EQU     00089h
ST1:                    EQU     00095h
HLHEX                   EQU     00410h
_2HEX                   EQU     0041Fh
?MODE:                  EQU     0074DH
?KEY                    EQU     008CAh
PRNT3                   EQU     0096Ch
?ADCN                   EQU     00BB9h
?DACN                   EQU     00BCEh
?DSP:                   EQU     00DB5H
?BLNK                   EQU     00DA6h
?DPCT                   EQU     00DDCh
PRTHL:                  EQU     003BAh
PRTHX:                  EQU     003C3h
HEX:                    EQU     003F9h
DPCT:                   EQU     00DDCh
DLY12:                  EQU     00DA7h
DLY12A:                 EQU     00DAAh
?RSTR1:                 EQU     00EE6h
MOTOR:                  EQU     006A3H
CKSUM:                  EQU     0071AH
GAP:                    EQU     0077AH
WTAPE:                  EQU     00485H
MSTOP:                  EQU     00700H

; Debugging
ENADEBUG                EQU     0                                        ; Enable debugging logic, 1 = enable, 0 = disable

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
SYSCTRL                 EQU     0F0H                                     ; System board control register. [2:0] - 000 MZ80A Mode, 2MHz CPU/Bus, 001 MZ80B Mode, 4MHz CPU/Bus, 010 MZ700 Mode, 3.54MHz CPU/Bus.
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
VMPAGE                  EQU     0FDH                                     ; Video Module memory page register. [1:0] switches in 1 16Kb page (3 pages) of graphics ram to C000 - FFFF. Bits [1:0] = page, 00 = off, 01 = Red, 10 = Green, 11 = Blue. This overrides all MZ700/MZ80B page switching functions. [7] 0 - normal, 1 - switches in CGROM for upload at D000:DFFF.

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
; GPU commands.
;-----------------------------------------------
GPUCLEARVRAM            EQU     001H                                     ; Clear the VRAM without updating attributes.
GPUCLEARVRAMCA          EQU     002H                                     ; Clear the VRAM/ARAM with given attribute byte,
GPUCLEARVRAMP           EQU     003H                                     ; Clear the VRAM/ARAM with parameters.
GPUCLEARGRAM            EQU     081H                                     ; Clear the entire Framebuffer.
GPUCLEARGRAMP           EQU     082H                                     ; Clear the Framebuffer according to parameters.
GPURESET                EQU     0FFH                                     ; Reset the GPU, return to idle state.

;-----------------------------------------------
; tranZPUter SW Memory Management modes
;-----------------------------------------------
TZMM_ENIOWAIT           EQU     020H                                     ; Memory management IO Wait State enable - insert a wait state when an IO operation to E0-FF is executed.
TZMM_ORIG               EQU     000H                                     ; Original Sharp MZ80A mode, no tranZPUter features are selected except the I/O control registers (default: 0x60-063).
TZMM_BOOT               EQU     001H                                     ; Original mode but E800-EFFF is mapped to tranZPUter RAM so TZFS can be booted.
TZMM_TZFS               EQU     002H + TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-FFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected.
TZMM_TZFS2              EQU     003H + TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 1.
TZMM_TZFS3              EQU     004H + TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 2.
TZMM_TZFS4              EQU     005H + TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 3.
TZMM_CPM                EQU     006H + TZMM_ENIOWAIT                     ; CPM main memory configuration, all memory on the tranZPUter board, 64K block 4 selected. Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_CPM2               EQU     007H + TZMM_ENIOWAIT                     ; CPM main memory configuration, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
                                                                         ; Special case for 0000:003F (interrupt vectors) which resides in block 4, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_COMPAT             EQU     008H + TZMM_ENIOWAIT                     ; Original mode but with main DRAM in Bank 0 to allow bootstrapping of programs from other machines such as the MZ700.
TZMM_MZ700_0            EQU     00AH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
TZMM_MZ700_1            EQU     00BH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_2            EQU     00CH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_3            EQU     00DH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_MZ700_4            EQU     00EH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_TZPU0              EQU     018H + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 0 is selected.
TZMM_TZPU1              EQU     019H + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 1 is selected.
TZMM_TZPU2              EQU     01AH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 2 is selected.
TZMM_TZPU3              EQU     01BH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 3 is selected.
TZMM_TZPU4              EQU     01CH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 4 is selected.
TZMM_TZPU5              EQU     01DH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 5 is selected.
TZMM_TZPU6              EQU     01EH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 6 is selected.
TZMM_TZPU7              EQU     01FH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 7 is selected.

;-----------------------------------------------
; TZ File System Header (MZF)
;-----------------------------------------------
TZFS_ATRB:              EQU     00000h                                   ; Code Type, 01 = Machine Code.
TZFS_NAME:              EQU     00001h                                   ; Title/Name (17 bytes).
TZFS_SIZE:              EQU     00012h                                   ; Size of program.
TZFS_DTADR:             EQU     00014h                                   ; Load address of program.
TZFS_EXADR:             EQU     00016h                                   ; Exec address of program.
TZFS_COMNT:             EQU     00018h                                   ; Comment
TZFS_MZFLEN:            EQU     128                                      ; Length of the MZF header.
TZFS_CMTLEN:            EQU     104                                      ; Length of the comment field

;-----------------------------------------------
; Entry/compilation start points.
;-----------------------------------------------
TPSTART:                EQU     010F0h
MEMSTART:               EQU     01200h
MSTART:                 EQU     0E900h
MZFHDRSZ                EQU     128
TZFSSECTSZ              EQU     256
MROMSIZE                EQU     4096
UROMSIZE                EQU     2048
FNSIZE                  EQU     17

;-----------------------------------------------
; RAM Banks, 0-3 are reserved for TZFS code in
;            the User/Floppy ROM bank area.
;-----------------------------------------------
USRROMPAGES             EQU     3                                        ; User ROM
ROMBANK0                EQU     0                                        ; TZFS Bank 0 - Main RFS Entry point and functions.
ROMBANK1                EQU     1                                        ; TZFS Bank 1 - 
ROMBANK2                EQU     2                                        ; TZFS Bank 2 - 
ROMBANK3                EQU     3                                        ; TZFS Bank 3 - 

OBJCD                   EQU     001h                                     ; MZF contains a binary object.
TZOBJCD0                EQU     0F8H                                     ; MZF contains a TZFS binary object for page 0.
TZOBJCD1                EQU     0F8H
TZOBJCD2                EQU     0F8H
TZOBJCD3                EQU     0F8H
TZOBJCD4                EQU     0F8H
TZOBJCD5                EQU     0F8H
TZOBJCD6                EQU     0F8H
TZOBJCD7                EQU     0F8H                                     ; MZF contains a TZFS binary object for page 7.

;-----------------------------------------------
;    SA-1510 MONITOR WORK AREA (MZ80A)
;-----------------------------------------------
STACK:                  EQU     010F0H
;
                        ORG     STACK
;
SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:                   DS      virtual 1                                ; ATTRIBUTE
NAME:                   DS      virtual FNSIZE                           ; FILE NAME
SIZE:                   DS      virtual 2                                ; BYTESIZE
DTADR:                  DS      virtual 2                                ; DATA ADDRESS
EXADR:                  DS      virtual 2                                ; EXECUTION ADDRESS
COMNT:                  DS      virtual 92                               ; COMMENT
SWPW:                   DS      virtual 10                               ; SWEEP WORK
KDATW:                  DS      virtual 2                                ; KEY WORK
KANAF:                  DS      virtual 1                                ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:                  DS      virtual 2                                ; DISPLAY COORDINATES
MANG:                   DS      virtual 6                                ; COLUMN MANAGEMENT
MANGE:                  DS      virtual 1                                ; COLUMN MANAGEMENT END
PBIAS:                  DS      virtual 1                                ; PAGE BIAS
ROLTOP:                 DS      virtual 1                                ; ROLL TOP BIAS
MGPNT:                  DS      virtual 1                                ; COLUMN MANAG. POINTER
PAGETP:                 DS      virtual 2                                ; PAGE TOP
ROLEND:                 DS      virtual 1                                ; ROLL END
                        DS      virtual 14                               ; BIAS
FLASH:                  DS      virtual 1                                ; FLASHING DATA
SFTLK:                  DS      virtual 1                                ; SHIFT LOCK
REVFLG:                 DS      virtual 1                                ; REVERSE FLAG
SPAGE:                  DS      virtual 1                                ; PAGE CHANGE
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



                        ; Starting EC80H - variables used by the filing system.
                        ORG     TZVARMEM

TZVARMEM:               EQU     0EC80H
TZVARSIZE:              EQU     00100H
WARMSTART:              DS      virtual 1                                ; Warm start mode, 0 = cold start, 1 = warm start.
SCRNMODE:               DS      virtual 1                                ; Mode of screen, [0] = 0 - 40 char, 1 - 80 char, [1] = 0 - Mainboard video, 1 - FPGA Video, [4:2] Video mode, [7:6] - VGA mode.
MMCFGVAL:               DS      virtual 1                                ; Current memory model value.
HLSAVE:                 DS      virtual 2                                ; Storage for HL during bank switch manipulation.
AFSAVE:                 DS      virtual 2                                ; Storage for AF during bank switch manipulation.
FNADDR:                 DS      virtual 2                                ; Function to be called address.
TMPADR:                 DS      virtual 2                                ; TEMPORARY ADDRESS STORAGE
TMPSIZE:                DS      virtual 2                                ; TEMPORARY SIZE
TMPCNT:                 DS      virtual 2                                ; TEMPORARY COUNTER
TMPLINECNT:             DS      virtual 2                                ; Temporary counter for displayed lines.
TMPSTACKP:              DS      virtual 2                                ; Temporary stack pointer save.
DUMPADDR:               DS      virtual 2                                ; Address used by the D(ump) command so that calls without parameters go onto the next block.
CMTLOLOAD:              DS      virtual 1                                ; Flag to indicate that a tape program is loaded into hi memory then shifted to low memory after ROM pageout.
CMTCOPY:                DS      virtual 1                                ; Flag to indicate that a CMT copy operation is taking place.
CMTAUTOEXEC:            DS      virtual 1                                ; Auto execution flag, run CMT program when loaded if flag clear.
DTADRSTORE:             DS      virtual 2                                ; Backup for load address if actual load shifts to lo memory or to 0x1200 for copy.
SDCOPY:                 DS      virtual 1                                ; Flag to indicate an SD copy is taking place, either CMT->SD or SD->CMT.
RESULT:                 DS      virtual 1                                ; Result variable needed for interbank calls when a result is needed.
SDAUTOEXEC:             DS      virtual 1                                ; Flag to indicate if a loaded file should be automatically executed.
FDCCMD:                 DS      virtual 1                                ; Floppy disk command storage. 
MOTON:                  DS      virtual 1                                ; Motor on flag.
TRK0FD1:                DS      virtual 1                                ; Floppy Disk 1 track 0 indicator.
TRK0FD2:                DS      virtual 1                                ; Floppy Disk 2 track 0 indicator.
TRK0FD3:                DS      virtual 1                                ; Floppy Disk 3 track 0 indicator.
TRK0FD4:                DS      virtual 1                                ; Floppy Disk 4 track 0 indicator.
RETRIES:                DS      virtual 1                                ; Retries count for a command.
BPARA:                  DS      virtual 1   
                        DS      virtual (TZVARMEM + TZVARSIZE) - $       ; Top of variable area downwards is used as the working stack, SA1510 space isnt used.
TZSTACK:                EQU     TZVARMEM + TZVARSIZE


                        ; Variables and control structure used by the I/O processor for service calls and requests.
                        ORG     TZSVCMEM

TZSVCMEM:               EQU     0ED80H                                   ; Start of a memory structure used to communicate with the K64F I/O processor for services such as disk access.
TZSVCSIZE:              EQU     00280H                                   ;
TZSVCDIRSZ:             EQU     20                                       ; Size of the directory/file name.
TZSVCFILESZ:            EQU     17                                       ; Size of a Sharp filename.
TZSVCLONGFILESZ:        EQU     31                                       ; Size of a standard filename.
TZSVCLONGFMTSZ:         EQU     20                                       ; Size of a formatted standard filename for use in directory listings.
TZSVCWILDSZ:            EQU     20                                       ; Size of the wildcard.
TZSVCSECSIZE:           EQU     512
TZSVCDIR_ENTSZ:         EQU     32                                       ; Size of a directory entry.
TZSVCWAITIORETRIES:     EQU     5                                        ; Wait retries for IO response.
TZSVCWAITCOUNT:         EQU     65535                                    ; Wait retries for IO request response.
TZSVC_FTYPE_MZF:        EQU     0                                        ; File type being handled is an MZF
TZSVC_FTYPE_CAS:        EQU     1                                        ; File type being handled is an CASsette BASIC script.
TZSVC_FTYPE_BAS:        EQU     2                                        ; File type being handled is an BASic script
TZSVC_FTYPE_ALL:        EQU     10                                       ; Handle any filetype.
TZSVC_FTYPE_ALLFMT:     EQU     11                                       ; Special case for directory listings, all files but truncated and formatted.
TZSVCCMD:               DS      virtual 1                                ; Service command.
TZSVCRESULT:            DS      virtual 1                                ; Service command result.
TZSVCDIRSEC:            DS      virtual 1                                ; Storage for the directory sector number.
TZSVC_FILE_SEC:         EQU     TZSVCDIRSEC                              ; Union of the file and directory sector as only one can be used at a time.
TZSVC_TRACK_NO:         DS      virtual 2                                ; Storage for the virtual drive track number.
TZSVC_SECTOR_NO:        DS      virtual 2                                ; Storage for the virtual drive sector number.
TZSVC_FILE_NO:          DS      virtual 1                                ; File number to be opened in a file service command.
TZSVC_FILE_TYPE:        DS      virtual 1                                ; Type of file being accessed to differentiate between Sharp MZF files and other handled files.
TZSVC_LOADADDR:         DS      virtual 2                                ; Dynamic load address for rom/images.
TZSVC_SAVEADDR:         EQU     TZSVC_LOADADDR                           ; Union of the load address and the cpu frequency change value, the address  of data to be saved.
TZSVC_CPU_FREQ:         EQU     TZSVC_LOADADDR                           ; Union of the load address and the save address value, only one can be used at a time.
TZSVC_LOADSIZE:         DS      virtual 2                                ; Size of image to load.
TZSVC_SAVESIZE:         EQU     TZSVC_LOADSIZE                           ; Size of image to be saved.
TZSVC_DIRNAME:          DS      virtual TZSVCDIRSZ                       ; Service directory/file name.
TZSVC_FILENAME:         DS      virtual TZSVCFILESZ                      ; Filename to be opened/created.
TZSVCWILDC:             DS      virtual TZSVCWILDSZ                      ; Directory wildcard for file pattern matching.
TZSVCSECTOR:            DS      virtual TZSVCSECSIZE                     ; Service command sector - to store directory entries, file sector read or writes.

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
TZSVC_CMD_LOAD40ABIOS   EQU     20H                                      ; Service command requesting that the 40 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOAD80ABIOS   EQU     21H                                      ; Service command requesting that the 80 column version of the SA1510 BIOS is loaded.
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


; Quickdisk work area
;QDPA                   EQU     01130h                                   ; QD code 1
;QDPB                   EQU     01131h                                   ; QD code 2
;QDPC                   EQU     01132h                                   ; QD header startaddress
;QDPE                   EQU     01134h                                   ; QD header length
;QDCPA                  EQU     0113Bh                                   ; QD error flag
;HDPT                   EQU     0113Ch                                   ; QD new headpoint possition
;HDPT0                  EQU     0113Dh                                   ; QD actual headpoint possition
;FNUPS                  EQU     0113Eh
;FNUPF                  EQU     01140h
;FNA                    EQU     01141h                                   ; File Number A (actual file number)
;FNB                    EQU     01142h                                   ; File Number B (next file number)
;MTF                    EQU     01143h                                   ; QD motor flag
;RTYF                   EQU     01144h
;SYNCF                  EQU     01146h                                   ; SyncFlags
;RETSP                  EQU     01147h
;BUFER                  EQU     011A3h
;QDIRBF                 EQU     0CD90h



;SPV:
;IBUFE:                                                                  ; TAPE BUFFER (128 BYTES)
;ATRB:                  DS      virtual 1                                ; Code Type, 01 = Machine Code.
;NAME:                  DS      virtual 17                               ; Title/Name (17 bytes).
;SIZE:                  DS      virtual 2                                ; Size of program.
;DTADR:                 DS      virtual 2                                ; Load address of program.
;EXADR:                 DS      virtual 2                                ; Exec address of program.
;COMNT:                 DS      virtual 104                              ; COMMENT
;KANAF:                 DS      virtual 1                                ; KANA FLAG (01=GRAPHIC MODE)
;DSPXY:                 DS      virtual 2                                ; DISPLAY COORDINATES
;MANG:                  DS      virtual 27                               ; COLUMN MANAGEMENT
;FLASH:                 DS      virtual 1                                ; FLASHING DATA
;FLPST:                 DS      virtual 2                                ; FLASHING POSITION
;FLSST:                 DS      virtual 1                                ; FLASHING STATUS
;FLSDT:                 DS      virtual 1                                ; CURSOR DATA
;STRGF:                 DS      virtual 1                                ; STRING FLAG
;DPRNT:                 DS      virtual 1                                ; TAB COUNTER
;TMCNT:                 DS      virtual 2                                ; TAPE MARK COUNTER
;SUMDT:                 DS      virtual 2                                ; CHECK SUM DATA
;CSMDT:                 DS      virtual 2                                ; FOR COMPARE SUM DATA
;AMPM:                  DS      virtual 1                                ; AMPM DATA
;TIMFG:                 DS      virtual 1                                ; TIME FLAG
;SWRK:                  DS      virtual 1                                ; KEY SOUND FLAG
;TEMPW:                 DS      virtual 1                                ; TEMPO WORK
;ONTYO:                 DS      virtual 1                                ; ONTYO WORK
;OCTV:                  DS      virtual 1                                ; OCTAVE WORK
;RATIO:                 DS      virtual 2                                ; ONPU RATIO
