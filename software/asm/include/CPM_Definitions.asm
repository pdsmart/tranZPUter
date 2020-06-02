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
FDCJMP1BLK              EQU     0F3C0H                                   ; The memory mapping FlashRAM only has 64byte granularity so we need to block 64 bytes per FDC vector.
FDCJMP1                 EQU     0F3FEH                                   ; ROM paged vector 1.
FDCJMP2BLK              EQU     0F7C0H                                   ; The memory mapping FlashRAM only has 64byte granularity so we need to block 64 bytes per FDC vector.
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
TZSVCDIRSZ:             EQU     8                                        ; Size of the directory/file name.
TZSVCFILESZ:            EQU     17                                       ; Size of a Sharp filename.
TZSVCWILDSZ:            EQU     8                                        ; Size of the wildcard.
TZSVCSECSIZE:           EQU     512
TZSVCDIR_ENTSZ:         EQU     32                                       ; Size of a directory entry.
TZSVCWAITIORETRIES:     EQU     500                                      ; Wait retries for IO response.
TZSVCWAITCOUNT:         EQU     65535                                    ; Wait retries for IO request response.

TZSVC_CMD_READDIR:      EQU     01H                                      ; Service command to open a directory and return the first block of entries.
TZSVC_CMD_NEXTDIR:      EQU     02H                                      ; Service command to return the next block of an open directory.
TZSVC_CMD_READFILE:     EQU     03H                                      ; Service command to open a file and return the first block.
TZSVC_CMD_MEXTREADFILE: EQU     04H                                      ; Service command to return the next block of an open file.
TZSVC_CMD_CLOSE:        EQU     05H                                      ; Service command to close any open file or directory.
TZSVC_CMD_LOADFILE:     EQU     06H                                      ; Service command to load a file directly into tranZPUter memory.
TZSVC_CMD_SAVEFILE:     EQU     07H                                      ; Service command to save a file directly from tranZPUter memory. 
TZSVC_CMD_ERASEFILE:    EQU     08H                                      ; Service command to erase a file on the SD card.
TZSVC_CMD_CHANGEDIR:    EQU     09H                                      ; Service command to change the active directory on the SD card.
TZSVC_CMD_LOAD40BIOS:   EQU     20H                                      ; Service command requesting that the 40 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOAD80BIOS:   EQU     21H                                      ; Service command requesting that the 80 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOADBDOS:     EQU     30H                                      ; Service command to reload CPM BDOS+CCP.
TZSVC_CMD_ADDSDDRIVE:   EQU     31H                                      ; Service command to attach a CPM disk to a drive number.
TZSVC_CMD_READSDDRIVE:  EQU     32H                                      ; Service command to read an attached SD file as a CPM disk drive.
TZSVC_CMD_WRITESDDRIVE: EQU     33H                                      ; Service command to write to a CPM disk drive which is an attached SD file.
TZSVC_STATUS_OK:        EQU     000H                                     ; Flag to indicate the K64F processing completed successfully.
TZSVC_STATUS_REQUEST:   EQU     0FEH                                     ; Flag to indicate the Z80 has made a request to the K64F.
TZSVC_STATUS_PROCESSING:EQU     0FFH                                     ; Flag to indicate the K64F is processing a command.
