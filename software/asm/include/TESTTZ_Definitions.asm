;--------------------------------------------------------------------------------------------------------
;-
;- Name:            TESTTZ_Definitions.asm
;- Created:         June 2020
;- Author(s):       Philip Smart
;- Description:     tranZPUter tester program
;-                  A small program to exercise parts of the tranZPUter to aid in problem resolution.
;-
;- Credits:         
;- Copyright:       (c) 2019-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Jun 2020 - Initial version.
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
; Configurable settings.
;-----------------------------------------------
COLW:                   EQU     80                                       ; Width of the display screen (ie. columns).
ROW:                    EQU     25                                       ; Number of rows on display screen.
SCRNSZ:                 EQU     COLW * ROW                               ; Total size, in bytes, of the screen display area.
SCRLW:                  EQU     COLW / 8                                 ; Number of 8 byte regions in a line for hardware scroll.
MODE80C:                EQU     1

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


;-----------------------------------------------
; IO ports in hardware and values.
;-----------------------------------------------
MMCFG                   EQU     060H                                     ; Memory management configuration latch.
SETXMHZ                 EQU     062H                                     ; Select the alternate clock frequency.
SET2MHZ                 EQU     064H                                     ; Select the system 2MHz clock frequency.
CLKSELRD                EQU     066H                                     ; Read clock selected setting, 0 = 2MHz, 1 = XMHz
SVCREQ                  EQU     068H                                     ; I/O Processor service request.
CPUCFG                  EQU     06CH                                     ; Version 2.2 CPU configuration register.
CPUSTATUS               EQU     06CH                                     ; Version 2.2 CPU runtime status register.
CPUINFO                 EQU     06DH                                     ; Version 2.2 CPU information register.
CPLDCFG                 EQU     06EH                                     ; Version 2.1 CPLD configuration register.
CPLDSTATUS              EQU     06EH                                     ; Version 2.1 CPLD status register.
CPLDINFO                EQU     06FH                                     ; Version 2.1 CPLD version information register.
PALSLCTOFF              EQU     0D3H                                     ; set the palette slot Off position to be adjusted.
PALSLCTON               EQU     0D4H                                     ; set the palette slot On position to be adjusted.
PALSETRED               EQU     0D5H                                     ; set the red palette value according to the PALETTE_PARAM_SEL address.
PALSETGREEN             EQU     0D6H                                     ; set the green palette value according to the PALETTE_PARAM_SEL address.
PALSETBLUE              EQU     0D7H                                     ; set the blue palette value according to the PALETTE_PARAM_SEL address.
SYSCTRL                 EQU     0F0H                                     ; System board control register. [2:0] - 000 MZ80A Mode, 2MHz CPU/Bus, 001 MZ80B Mode, 4MHz CPU/Bus, 010 MZ700 Mode, 3.54MHz CPU/Bus.
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
VMPAGE                  EQU     0FDH                                     ; Video Module memory page register. [1:0] switches in 1 16Kb page (3 pages) of graphics ram to C000 - FFFF. Bits [1:0] = page, 00 = off, 01 = Red, 10 = Green, 11 = Blue. This overrides all MZ700/MZ80B page switching functions. [7] 0 - normal, 1 - switches in CGROM for upload at D000:DFFF.


;-----------------------------------------------
; tranZPUter SW Memory Management modes
;-----------------------------------------------
TZMM_ORIG               EQU     000H                                     ; Original Sharp MZ80A mode, no tranZPUter features are selected except the I/O control registers (default: 0x60-063).
TZMM_BOOT               EQU     001H                                     ; Original mode but E800-EFFF is mapped to tranZPUter RAM so TZFS can be booted.
TZMM_TZFS               EQU     002H                                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-FFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected.
TZMM_TZFS2              EQU     003H                                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 1.
TZMM_TZFS3              EQU     004H                                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 2.
TZMM_TZFS4              EQU     005H                                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 3.
TZMM_CPM                EQU     006H                                     ; CPM main memory configuration, all memory on the tranZPUter board, 64K block 4 selected. Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_CPM2               EQU     007H                                     ; CPM main memory configuration, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
                                                                         ; Special case for 0000:003F (interrupt vectors) which resides in block 4, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_TZPU0              EQU     018H                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 0 is selected.
TZMM_TZPU1              EQU     019H                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 1 is selected.
TZMM_TZPU2              EQU     01AH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 2 is selected.
TZMM_TZPU3              EQU     01BH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 3 is selected.
TZMM_TZPU4              EQU     01CH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 4 is selected.
TZMM_TZPU5              EQU     01DH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 5 is selected.
TZMM_TZPU6              EQU     01EH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 6 is selected.
TZMM_TZPU7              EQU     01FH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 7 is selected.

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
;    BIOS WORK AREA (MZ80A)
;-----------------------------------------------
