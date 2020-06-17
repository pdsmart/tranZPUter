;--------------------------------------------------------------------------------------------------------
;-
;- Name:            BASIC_Definitions.asm
;- Created:         June 2020
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
;                   Jun 2020 - Copied and strpped from TZFS for BASIC.
;
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

;-----------------------------------------------
; Configurable settings.
;-----------------------------------------------
TMRTICKINTV             EQU     5                                        ; Number of 0.010mSec ticks per interrupt, ie. resolution of RTC.
COLW:                   EQU     80                                       ; Width of the display screen (ie. columns).
ROW:                    EQU     25                                       ; Number of rows on display screen.
SCRNSZ:                 EQU     COLW * ROW                               ; Total size, in bytes, of the screen display area.
SCRLW:                  EQU     COLW / 8                                 ; Number of 8 byte regions in a line for hardware scroll.
MODE80C:                EQU     1

; BIOS equates
KEYBUFSIZE              EQU     64                                       ; Ensure this is a power of 2, max size 256.
MAXMEM                  EQU     10000H - TZSVCSIZE                       ; Top of RAM on the tranZPUter/
;MAXMEM                  EQU     0CFFFH                                   ; Top of RAM on a standard Sharp MZ80A.

; Tape load/save modes. Used as a flag to enable common code.
TAPELOAD                EQU     1
CTAPELOAD               EQU     2
TAPESAVE                EQU     3
CTAPESAVE               EQU     4

; Build options. Set just one to '1' the rest to '0'.
BUILD_MZ80A             EQU     1                                        ; Build for the standard Sharp MZ80A, no lower memory. Manually change MAXMEM above.
BUILD_TZFS              EQU     0                                        ; Build for TZFS where extended memory is available.
INCLUDE_ANSITERM        EQU     1                                        ; Include the Ansi terminal emulation processor in the build.

; Debugging
ENADEBUG                EQU     0                                        ; Enable debugging logic, 1 = enable, 0 = disable

;-----------------------------------------------
; BASIC ERROR CODE VALUES
;-----------------------------------------------
NF                      EQU    00H                                       ; NEXT without FOR
SN                      EQU    02H                                       ; Syntax error
RG                      EQU    04H                                       ; RETURN without GOSUB
OD                      EQU    06H                                       ; Out of DATA
FC                      EQU    08H                                       ; Function call error
OV                      EQU    0AH                                       ; Overflow
OM                      EQU    0CH                                       ; Out of memory
UL                      EQU    0EH                                       ; Undefined line number
BS                      EQU    10H                                       ; Bad subscript
DDA                     EQU    12H                                       ; Re-DIMensioned array
DZ                      EQU    14H                                       ; Division by zero (/0)
ID                      EQU    16H                                       ; Illegal direct
TM                      EQU    18H                                       ; Type miss-match
OS                      EQU    1AH                                       ; Out of string space
LS                      EQU    1CH                                       ; String too long
ST                      EQU    1EH                                       ; String formula too complex
CN                      EQU    20H                                       ; Can't CONTinue
UF                      EQU    22H                                       ; UnDEFined FN function
MO                      EQU    24H                                       ; Missing operand
HX                      EQU    26H                                       ; HEX error
BN                      EQU    28H                                       ; BIN error

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
CS                      EQU     0CH                                      ; Clear screen
DELETE                  EQU     07FH
BACKS                   EQU     008H
SOH                     EQU     1                                        ; For XModem etc.
EOT                     EQU     4
ACK                     EQU     6
NAK                     EQU     015H
NUL                     EQU     000H
;NULL                    EQU     000H
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
TZMM_MZ700_0            EQU     00AH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
TZMM_MZ700_1            EQU     00BH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_2            EQU     00CH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_3            EQU     00DH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_MZ700_4            EQU     00EH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
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
                        ; Variables and control structure used by the I/O processor for service calls and requests.
                        ORG     TZSVCMEM

TZSVCMEM:               EQU     0FD80H                                   ; Start of a memory structure used to communicate with the K64F I/O processor for services such as disk access.
TZSVCSIZE:              EQU     00280H                                   ;
TZSVCDIRSZ:             EQU     20                                       ; Size of the directory/file name.
TZSVCFILESZ:            EQU     17                                       ; Size of a Sharp filename.
TZSVCWILDSZ:            EQU     20                                       ; Size of the wildcard.
TZSVCSECSIZE:           EQU     512
TZSVCDIR_ENTSZ:         EQU     32                                       ; Size of a directory entry.
TZSVCWAITIORETRIES:     EQU     500                                      ; Wait retries for IO response.
TZSVCWAITCOUNT:         EQU     65535                                    ; Wait retries for IO request response.
TZSVC_FTYPE_MZF:        EQU     0                                        ; File type being handled is an MZF
TZSVC_FTYPE_CAS:        EQU     1                                        ; File type being handled is an CASsette BASIC script.
TZSVC_FTYPE_BAS:        EQU     2                                        ; File type being handled is an BASic script
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

TZSVC_CMD_READDIR:      EQU     01H                                      ; Service command to open a directory and return the first block of entries.
TZSVC_CMD_NEXTDIR:      EQU     02H                                      ; Service command to return the next block of an open directory.
TZSVC_CMD_READFILE:     EQU     03H                                      ; Service command to open a file and return the first block.
TZSVC_CMD_NEXTREADFILE: EQU     04H                                      ; Service command to return the next block of an open file.
TZSVC_CMD_WRITEFILE:    EQU     05H                                      ; Service command to create a file and save the first block.
TZSVC_CMD_NEXTWRITEFILE:EQU     06H                                      ; Service command to write the next block to the open file.
TZSVC_CMD_CLOSE:        EQU     07H                                      ; Service command to close any open file or directory.
TZSVC_CMD_LOADFILE:     EQU     08H                                      ; Service command to load a file directly into tranZPUter memory.
TZSVC_CMD_SAVEFILE:     EQU     09H                                      ; Service command to save a file directly from tranZPUter memory. 
TZSVC_CMD_ERASEFILE:    EQU     0aH                                      ; Service command to erase a file on the SD card.
TZSVC_CMD_CHANGEDIR:    EQU     0bH                                      ; Service command to change the active directory on the SD card.
TZSVC_CMD_LOAD40BIOS:   EQU     20H                                      ; Service command requesting that the 40 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOAD80BIOS:   EQU     21H                                      ; Service command requesting that the 80 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOAD700BIOS40:EQU     22H                                      ; Service command requesting that the MZ700 1Z-013A 40 column BIOS is loaded.
TZSVC_CMD_LOAD700BIOS80:EQU     23H                                      ; Service command requesting that the MZ700 1Z-013A 80 column patched BIOS is loaded.
TZSVC_CMD_LOAD80BIPL:   EQU     24H                                      ; Service command requesting the MZ-80B IPL is loaded.
TZSVC_CMD_LOADBDOS:     EQU     30H                                      ; Service command to reload CPM BDOS+CCP.
TZSVC_CMD_ADDSDDRIVE:   EQU     31H                                      ; Service command to attach a CPM disk to a drive number.
TZSVC_CMD_READSDDRIVE:  EQU     32H                                      ; Service command to read an attached SD file as a CPM disk drive.
TZSVC_CMD_WRITESDDRIVE: EQU     33H                                      ; Service command to write to a CPM disk drive which is an attached SD file.
TZSVC_CMD_CPU_BASEFREQ  EQU     40H                                      ; Service command to switch to the mainboard frequency.
TZSVC_CMD_CPU_ALTFREQ   EQU     41H                                      ; Service command to switch to the alternate frequency provided by the K64F.
TZSVC_CMD_CPU_CHGFREQ   EQU     42H                                      ; Service command to set the alternate frequency in hertz.
TZSVC_STATUS_OK:        EQU     000H                                     ; Flag to indicate the K64F processing completed successfully.
TZSVC_STATUS_REQUEST:   EQU     0FEH                                     ; Flag to indicate the Z80 has made a request to the K64F.
TZSVC_STATUS_PROCESSING:EQU     0FFH                                     ; Flag to indicate the K64F is processing a command.
