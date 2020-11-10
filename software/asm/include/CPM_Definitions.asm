;--------------------------------------------------------------------------------------------------------
;-
;- Name:            CPM_Definitions.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM v2.23
;-                  Definitions for the Sharp MZ80A CPM v2.23 OS used in the RFS
;-
;- Credits:         
;- Copyright:       (c) 2019-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Jan 2020 - Initial version.
;                   May 2020 - Advent of the new RFS PCB v2.0, quite a few changes to accommodate the
;                              additional and different hardware. The SPI is now onboard the PCB and
;                              not using the printer interface card.
;                   May 2020 - Cut from the RFS version of CPM for the tranZPUter SW board.
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
BUILD_VIDEOMODULE       EQU     1                                        ; Build for the Video Module v2 board (=1) otherwise build for the 80Char Colour Board v1.0
BUILD_MZ80A             EQU     1                                        ; Build for the Sharp MZ-80A base hardware.
BUILD_MZ700             EQU     0                                        ; Build for the Sharp MZ-700 base hardware.

;-----------------------------------------------
; Entry/compilation start points.
;-----------------------------------------------
MROMADDR                EQU     00000H                                   ; Start of SA1510 Monitor ROM.
CBASE                   EQU     0DA00H
CPMCCP                  EQU     CBASE                                    ; CP/M System entry
CPMBDOS                 EQU     CPMCCP + 0806H                           ; BDOS entry
CPMBIOS                 EQU     CPMCCP + 01600H                          ; Original CPM22 BIOS entry
CBIOSSTART              EQU     CPMBIOS                                  ; Start of the actual CBIOS code.
BOOT                    EQU     CBIOSSTART + 0
WBOOT                   EQU     CBIOSSTART + 3
WBOOTE                  EQU     CBIOSSTART + 3
CONST                   EQU     CBIOSSTART + 6
CONIN                   EQU     CBIOSSTART + 9
CONOUT                  EQU     CBIOSSTART + 12
LIST                    EQU     CBIOSSTART + 15
PUNCH                   EQU     CBIOSSTART + 18
READER                  EQU     CBIOSSTART + 21
HOME                    EQU     CBIOSSTART + 24
SELDSK                  EQU     CBIOSSTART + 27
SETTRK                  EQU     CBIOSSTART + 30
SETSEC                  EQU     CBIOSSTART + 33
SETDMA                  EQU     CBIOSSTART + 36
READ                    EQU     CBIOSSTART + 39
WRITE                   EQU     CBIOSSTART + 42
FRSTAT                  EQU     CBIOSSTART + 45
SECTRN                  EQU     CBIOSSTART + 48
QDEBUG                  EQU     CBIOSSTART + 51
CCP                     EQU     CBASE
CCPCLRBUF               EQU     CBASE + 3
IOBYT                   EQU     00003H                                   ; IOBYTE address
CDISK                   EQU     00004H                                   ; Address of Current drive name and user number
CPMUSERDMA              EQU     00080h                                   ; Default CPM User DMA address.
DPSIZE                  EQU     16                                       ; Size of a Disk Parameter Block
; Old Flash RAM mapping
;FDCJMP1BLK              EQU     0F3C0H                                   ; The memory mapping FlashRAM only has 64byte granularity so we need to block 64 bytes per FDC vector.
;FDCJMP1                 EQU     0F3FEH                                   ; ROM paged vector 1.
;FDCJMP2BLK              EQU     0F7C0H                                   ; The memory mapping FlashRAM only has 64byte granularity so we need to block 64 bytes per FDC vector.
;FDCJMP2                 EQU     0F7FEH                                   ; ROM paged vector 2.
; New CPLD mapping
FDCJMP1BLK              EQU     0F3FEH                                   ; The memory mapping CPLD has 1byte granularity so we need to block just 2 bytes per FDC vector.
FDCJMP1                 EQU     0F3FEH                                   ; ROM paged vector 1.
FDCJMP2BLK              EQU     0F7FEH                                   ; The memory mapping CPLD has 1byte granularity so we need to block just 2 bytes per FDC vector.
FDCJMP2                 EQU     0F7FEH                                   ; ROM paged vector 2.


;-----------------------------------------------
; Configurable settings.
;-----------------------------------------------
MAXRDRETRY              EQU     002h 
MAXWRRETRY              EQU     002h
BLKSIZ                  EQU     4096                                     ; CP/M allocation size
HSTSIZ                  EQU     512                                      ; host disk sector size
HSTSPT                  EQU     32                                       ; host disk sectors/trk
HSTBLK                  EQU     HSTSIZ/128                               ; CP/M sects/host buff
CPMSPT                  EQU     HSTBLK * HSTSPT                          ; CP/M sectors/track
SECMSK                  EQU     HSTBLK-1                                 ; sector mask
WRALL                   EQU     0                                        ; write to allocated
WRDIR                   EQU     1                                        ; write to directory
WRUAL                   EQU     2                                        ; write to unallocated
TMRTICKINTV             EQU     5                                        ; Number of 0.010mSec ticks per interrupt, ie. resolution of RTC.
MTROFFMSECS             EQU     100                                      ; Time from last access to motor being switched off in seconds in TMRTICKINTV ticks.
COLW:                   EQU     80                                       ; Width of the display screen (ie. columns).
ROW:                    EQU     25                                       ; Number of rows on display screen.
SCRNSZ:                 EQU     COLW * ROW                               ; Total size, in bytes, of the screen display area.
SCRLW:                  EQU     COLW / 8                                 ; Number of 8 byte regions in a line for hardware scroll.
MODE80C:                EQU     1


; BIOS equates
MAXDISKS                EQU     7                                        ; Max number of Drives supported
KEYBUFSIZE              EQU     64                                       ; Ensure this is a power of 2, max size 256.

; Debugging
ENADEBUG                EQU     1                                        ; Enable debugging logic, 1 = enable, 0 = disable

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
; IO Registers
;-----------------------------------------------
FDC                     EQU     0D8h                                     ; MB8866 IO Region 0D8h - 0DBh
FDC_CR                  EQU     FDC + 000h                               ; Command Register
FDC_STR                 EQU     FDC + 000h                               ; Status Register
FDC_TR                  EQU     FDC + 001h                               ; Track Register
FDC_SCR                 EQU     FDC + 002h                               ; Sector Register
FDC_DR                  EQU     FDC + 003h                               ; Data Register
FDC_MOTOR               EQU     FDC + 004h                               ; DS[0-3] and Motor control. 4 drives  DS= BIT 0 -> Bit 2 = Drive number, 2=1,1=0,0=0 DS0, 2=1,1=0,0=1 DS1 etc
                                                                         ;  bit 7 = 1 MOTOR ON LOW (Active)
FDC_SIDE                EQU     FDC + 005h                               ; Side select, Bit 0 when set = SIDE SELECT LOW

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
CTRL_LB                 EQU     01BH
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
GRAPHKEY                EQU     0FCH
ALPHAKEY                EQU     0FDH


; MMC/SD command (SPI mode)
CMD0                    EQU     64 + 0                                   ; GO_IDLE_STATE 
CMD1                    EQU     64 + 1                                   ; SEND_OP_COND 
ACMD41                  EQU     0x40+41                                  ; SEND_OP_COND (SDC) 
CMD8                    EQU     64 + 8                                   ; SEND_IF_COND 
CMD9                    EQU     64 + 9                                   ; SEND_CSD 
CMD10                   EQU     64 + 10                                  ; SEND_CID 
CMD12                   EQU     64 + 12                                  ; STOP_TRANSMISSION 
CMD13                   EQU     64 + 13                                  ; SEND_STATUS 
ACMD13                  EQU     0x40+13                                  ; SD_STATUS (SDC) 
CMD16                   EQU     64 + 16                                  ; SET_BLOCKLEN 
CMD17                   EQU     64 + 17                                  ; READ_SINGLE_BLOCK 
CMD18                   EQU     64 + 18                                  ; READ_MULTIPLE_BLOCK 
CMD23                   EQU     64 + 23                                  ; SET_BLOCK_COUNT 
ACMD23                  EQU     0x40+23                                  ; SET_WR_BLK_ERASE_COUNT (SDC)
CMD24                   EQU     64 + 24                                  ; WRITE_BLOCK 
CMD25                   EQU     64 + 25                                  ; WRITE_MULTIPLE_BLOCK 
CMD32                   EQU     64 + 32                                  ; ERASE_ER_BLK_START 
CMD33                   EQU     64 + 33                                  ; ERASE_ER_BLK_END 
CMD38                   EQU     64 + 38                                  ; ERASE 
CMD55                   EQU     64 + 55                                  ; APP_CMD 
CMD58                   EQU     64 + 58                                  ; READ_OCR 

; Card type flags (CardType)
CT_MMC                  EQU     001H                                     ; MMC ver 3 
CT_SD1                  EQU     002H                                     ; SD ver 1 
CT_SD2                  EQU     004H                                     ; SD ver 2 
CT_SDC                  EQU     CT_SD1|CT_SD2                            ; SD 
CT_BLOCK                EQU     008H                                     ; Block addressing

; Disk types.
DSKTYP_FDC              EQU     0                                        ; Type of disk is a Floppy disk and handled by the FDC controller.
;DSKTYP_ROM              EQU     1                                        ; Type of disk is a ROM and handled by the ROM methods.
DSKTYP_SDC              EQU     2                                        ; Type of disk is an SD Card and handled by the SD Card methods.

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
;SYSCTRL                 EQU     0F0H                                     ; System board control register. [2:0] - 000 MZ80A Mode, 2MHz CPU/Bus, 001 MZ80B Mode, 4MHz CPU/Bus, 010 MZ700 Mode, 3.54MHz CPU/Bus.
;GRAMMODE                EQU     0F4H                                     ; MZ80B Graphics mode.  Bit 0 = 0, Write to Graphics RAM I, Bit 0 = 1, Write to Graphics RAM II. Bit 1 = 1, blend Graphics RAM I output on display, Bit 2 = 1, blend Graphics RAM II output on display.
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

;
; CPM constants
;
CPM_SD_SEC              EQU    32
CPM_SD_TRK              EQU    1024
CPM_SD_IMGSZ            EQU    CPM_SD_TRK * CPM_SD_SEC * SD_SECSIZE

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
