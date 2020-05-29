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
HW_SPI_ENA  EQU     1                                                    ; Set to 1 if hardware SPI is present on the RFS PCB v2 board.
SW_SPI_ENA  EQU     0                                                    ; Set to 1 if software SPI is present on the RFS PCB v2 board.
PP_SPI_ENA  EQU     0                                                    ; Set to 1 if using the SPI interface via the Parallel Port, ie. for RFS PCB v1 which doesnt have SPI onboard.

;-----------------------------------------------
; Entry/compilation start points.
;-----------------------------------------------
CBIOSSTART  EQU     0C000h
CBIOSDATA   EQU     CBIOSSTART - 0400H
UROMADDR    EQU     0E800H                                               ; Start of User ROM Address space.
FDCROMADDR  EQU     0F000H
CBASE       EQU     0A000H
CPMCCP      EQU     CBASE                                                ; CP/M System entry
CPMBDOS     EQU     CPMCCP + 0806H                                       ; BDOS entry
CPMBIOS     EQU     CPMCCP + 01600H                                      ; Original CPM22 BIOS entry
BOOT        EQU     CBIOSSTART + 0
WBOOT       EQU     CBIOSSTART + 3
WBOOTE      EQU     CBIOSSTART + 3
CONST       EQU     CBIOSSTART + 6
CONIN       EQU     CBIOSSTART + 9
CONOUT      EQU     CBIOSSTART + 12
LIST        EQU     CBIOSSTART + 15
PUNCH       EQU     CBIOSSTART + 18
READER      EQU     CBIOSSTART + 21
HOME        EQU     CBIOSSTART + 24
SELDSK      EQU     CBIOSSTART + 27
SETTRK      EQU     CBIOSSTART + 30
SETSEC      EQU     CBIOSSTART + 33
SETDMA      EQU     CBIOSSTART + 36
READ        EQU     CBIOSSTART + 39
WRITE       EQU     CBIOSSTART + 42
FRSTAT      EQU     CBIOSSTART + 45
SECTRN      EQU     CBIOSSTART + 48
UNUSED      EQU     CBIOSSTART + 51
BANKTOBANK  EQU     CBIOSSTART + 54
CCP         EQU     CBASE
CCPCLRBUF   EQU     CBASE + 3
DPBASE      EQU     CPMBIOS
CDIRBUF     EQU     CPMBIOS + (MAXDISKS * 16)
CSVALVMEM   EQU     CDIRBUF + 128 
CSVALVEND   EQU     CSVALVMEM + 1253
IOBYT       EQU     00003H                                               ; IOBYTE address
CDISK       EQU     00004H                                               ; Address of Current drive name and user number
CPMUSERDMA  EQU     00080h                                               ; Default CPM User DMA address.
DPSIZE      EQU     16                                                   ; Size of a Disk Parameter Block
DPBLOCK0    EQU     SCRN - (8 * DPSIZE)                                  ; Location of the 1st DPB in the CBIOS Rom.
DPBLOCK1    EQU     DPBLOCK0 + DPSIZE
DPBLOCK2    EQU     DPBLOCK1 + DPSIZE
DPBLOCK3    EQU     DPBLOCK2 + DPSIZE
DPBLOCK4    EQU     DPBLOCK3 + DPSIZE
DPBLOCK5    EQU     DPBLOCK4 + DPSIZE
DPBLOCK6    EQU     DPBLOCK5 + DPSIZE
DPBLOCK7    EQU     DPBLOCK6 + DPSIZE


;-----------------------------------------------
; Configurable settings.
;-----------------------------------------------
MAXRDRETRY  EQU     002h 
MAXWRRETRY  EQU     002h
BLKSIZ      EQU     4096                                                 ; CP/M allocation size
HSTSIZ      EQU     512                                                  ; host disk sector size
HSTSPT      EQU     32                                                   ; host disk sectors/trk
HSTBLK      EQU     HSTSIZ/128                                           ; CP/M sects/host buff
CPMSPT      EQU     HSTBLK * HSTSPT                                      ; CP/M sectors/track
SECMSK      EQU     HSTBLK-1                                             ; sector mask
WRALL       EQU     0                                                    ; write to allocated
WRDIR       EQU     1                                                    ; write to directory
WRUAL       EQU     2                                                    ; write to unallocated
TMRTICKINTV EQU     5                                                    ; Number of 0.010mSec ticks per interrupt, ie. resolution of RTC.
MTROFFMSECS EQU     100                                                  ; Time from last access to motor being switched off in seconds in TMRTICKINTV ticks.
COLW:       EQU     80                                                   ; Width of the display screen (ie. columns).
ROW:        EQU     25                                                   ; Number of rows on display screen.
SCRNSZ:     EQU     COLW * ROW                                           ; Total size, in bytes, of the screen display area.
SCRLW:      EQU     COLW / 8                                             ; Number of 8 byte regions in a line for hardware scroll.
MODE80C:    EQU     1
ROMDRVSIZE: EQU     320                                                  ; Size in K of the Rom RFS Drive, currently 240 or 320 are coded. Please set value in make_cpmdisks.sh when changing this parameter.

; BIOS equates
MAXDISKS    EQU     7                                                    ; Max number of Drives supported
KEYBUFSIZE  EQU     16                                                   ; Ensure this is a power of 2, max size 256.

; Debugging
ENADEBUG    EQU     0                                                    ; Enable debugging logic, 1 = enable, 0 = disable

;-------------------------------------------------------
; Function entry points in the CBIOS ROMS
;-------------------------------------------------------
UROMJMPTBL  EQU     UROMADDR + 00020H                                    ; Position at beginning of each bank of an API jump table of public methods in the bank

; Public functions in CBIOS User ROM Bank 1 - utility functions, ie. Audio.
QREBOOT     EQU      0 + UROMJMPTBL
QMELDY      EQU      3 + UROMJMPTBL
QTEMP       EQU      6 + UROMJMPTBL
QMSTA       EQU      9 + UROMJMPTBL
QMSTP       EQU     12 + UROMJMPTBL
QBEL        EQU     15 + UROMJMPTBL
QMODE       EQU     18 + UROMJMPTBL
QTIMESET    EQU     21 + UROMJMPTBL
QTIMEREAD   EQU     24 + UROMJMPTBL
QCHKKY      EQU     27 + UROMJMPTBL
QGETKY      EQU     30 + UROMJMPTBL

; Public functions in CBIOS User ROM Bank 2 - Screen / ANSI terminal functions.
QPRNT       EQU      0 + UROMJMPTBL
QPRTHX      EQU      3 + UROMJMPTBL
QPRTHL      EQU      6 + UROMJMPTBL
QANSITERM   EQU      9 + UROMJMPTBL

; Public functions in CBIOS User ROM Bank 3 - SD Card functions.
SD_INIT      EQU     0 + UROMJMPTBL
SD_READ      EQU     3 + UROMJMPTBL
SD_WRITE     EQU     6 + UROMJMPTBL
SD_GETLBA    EQU     9 + UROMJMPTBL
SDC_READ     EQU    12 + UROMJMPTBL
SDC_WRITE    EQU    15 + UROMJMPTBL

; Public functions in CBIOS User ROM Bank 4 - Floppy Disk Controller functions.
QDSKINIT     EQU     0 + UROMJMPTBL
QSETDRVCFG   EQU     3 + UROMJMPTBL
QSETDRVMAP   EQU     6 + UROMJMPTBL
QSELDRIVE    EQU     9 + UROMJMPTBL
QGETMAPDSK   EQU    12 + UROMJMPTBL
QDSKREAD     EQU    15 + UROMJMPTBL
QDSKWRITE    EQU    18 + UROMJMPTBL


;-----------------------------------------------
; Memory mapped ports in hardware.
;-----------------------------------------------
SCRN:       EQU     0D000H
ARAM:       EQU     0D800H
DSPCTL:     EQU     0DFFFH                                               ; Screen 40/80 select register (bit 7)
KEYPA:      EQU     0E000h
KEYPB:      EQU     0E001h
KEYPC:      EQU     0E002h
KEYPF:      EQU     0E003h
CSTR:       EQU     0E002h
CSTPT:      EQU     0E003h
CONT0:      EQU     0E004h
CONT1:      EQU     0E005h
CONT2:      EQU     0E006h
CONTF:      EQU     0E007h
SUNDG:      EQU     0E008h
TEMP:       EQU     0E008h
MEMSW:      EQU     0E00CH
MEMSWR:     EQU     0E010H
INVDSP:     EQU     0E014H
NRMDSP:     EQU     0E015H
SCLDSP:     EQU     0E200H
SCLBASE:    EQU     0E2H
BNKCTRLRST: EQU     0EFF8H                                               ; Bank control reset, returns all registers to power up default.
BNKCTRLDIS: EQU     0EFF9H                                               ; Disable bank control registers by resetting the coded latch.
HWSPIDATA:  EQU     0EFFBH                                               ; Hardware SPI Data register (read/write).
HWSPISTART: EQU     0EFFCH                                               ; Start an SPI transfer.
BNKSELMROM: EQU     0EFFDh                                               ; Select RFS Bank1 (MROM) 
BNKSELUSER: EQU     0EFFEh                                               ; Select RFS Bank2 (User ROM)
BNKCTRL:    EQU     0EFFFH                                               ; Bank Control register (read/write).

;
; RFS v2 Control Register constants.
;
BBCLK       EQU     1                                                    ; BitBang SPI Clock.
SDCS        EQU     2                                                    ; SD Card Chip Select, active low.
BBMOSI      EQU     4                                                    ; BitBang MOSI (Master Out Serial In).
CDLTCH1     EQU     8                                                    ; Coded latch up count bit 1
CDLTCH2     EQU     16                                                   ; Coded latch up count bit 2
CDLTCH3     EQU     32                                                   ; Coded latch up count bit 3
BK2A19      EQU     64                                                   ; User ROM Device Select Bit 0 (or Address bit 19).
BK2A20      EQU     128                                                  ; User ROM Device Select Bit 1 (or Address bit 20).
                                                                         ; BK2A20 : BK2A19
                                                                         ;    0        0   = Flash RAM 0 (default).
                                                                         ;    0        1   = Flash RAM 1.
                                                                         ;    1        0   = Flasm RAM 2 or Static RAM 0.
                                                                         ;    1        1   = Reserved.

BNKCTRLDEF  EQU     BBMOSI+SDCS+BBCLK                                    ; Default on startup for the Bank Control register.

;-----------------------------------------------
; IO ports in hardware and values.
;-----------------------------------------------
SPI_OUT     EQU     0FFH
SPI_IN      EQU     0FEH
;
DOUT_LOW    EQU     000H
DOUT_HIGH   EQU     004H
DOUT_MASK   EQU     004H
DIN_LOW     EQU     000H
DIN_HIGH    EQU     001H
CLOCK_LOW   EQU     000H
CLOCK_HIGH  EQU     002H
CLOCK_MASK  EQU     0FDH
CS_LOW      EQU     000H
CS_HIGH     EQU     001H

;-----------------------------------------------
; Rom File System Header (MZF)
;-----------------------------------------------
RFS_ATRB:   EQU     00000h                                               ; Code Type, 01 = Machine Code.
RFS_NAME:   EQU     00001h                                               ; Title/Name (17 bytes).
RFS_SIZE:   EQU     00012h                                               ; Size of program.
RFS_DTADR:  EQU     00014h                                               ; Load address of program.
RFS_EXADR:  EQU     00016h                                               ; Exec address of program.
RFS_COMNT:  EQU     00018h                                               ; COMMENT
MZFHDRSZ    EQU     128                                                  ; Full MZF Header size
MZFHDRNCSZ  EQU     24                                                   ; Only the primary MZF data, no comment field.
RFSSECTSZ   EQU     256
MROMSIZE    EQU     4096
UROMSIZE    EQU     2048
BANKSPERTRACK EQU (ROMSECTORSIZE * ROMSECTORS) / UROMSIZE                ; (8) We currently only use the UROM for disk images.
SECTORSPERBANK EQU UROMSIZE / ROMSECTORSIZE                              ; (16)
SECTORSPERBLOCK EQU RFSSECTSZ/ROMSECTORSIZE                              ; (2)
ROMSECTORSIZE EQU   128
ROMSECTORS    EQU   128
;ROMBK1:     EQU      01016H                                               ; CURRENT MROM BANK 
;ROMBK2:     EQU      01017H                                               ; CURRENT USERROM BANK 
;WRKROMBK1:  EQU      01018H                                               ; WORKING MROM BANK 
;WRKROMBK2:  EQU      01019H                                               ; WORKING USERROM BANK

;-----------------------------------------------
; ROM Banks, 0-7 are reserved for alternative
;            Monitor versions, CPM and RFS
;            code in MROM bank,
;            0-7 are reserved for RFS code in
;            the User ROM bank.
;            8-15 are reserved for CPM code in
;            the User ROM bank.
;-----------------------------------------------
MROMPAGES   EQU     8
USRROMPAGES EQU     12                                                   ; Monitor ROM         :  User ROM
ROMBANK0    EQU     0                                                    ; MROM SA1510 40 Char :  RFS Bank 0 - Main RFS Entry point and functions.
ROMBANK1    EQU     1                                                    ; MROM SA1510 80 Char :  RFS Bank 1 - Floppy disk controller and utilities.
ROMBANK2    EQU     2                                                    ; CPM 2.2 CBIOS       :  RFS Bank 2 - SD Card controller and utilities.
ROMBANK3    EQU     3                                                    ; RFS Utilities       :  RFS Bank 3 - Cmdline tools (Memory, Printer, Help)
ROMBANK4    EQU     4                                                    ; Free                :  RFS Bank 4 - CMT Utilities.
ROMBANK5    EQU     5                                                    ; Free                :  RFS Bank 5
ROMBANK6    EQU     6                                                    ; Free                :  RFS Bank 6
ROMBANK7    EQU     7                                                    ; Free                :  RFS Bank 7 - Memory and timer test utilities.
ROMBANK8    EQU     8                                                    ;                     :  CBIOS Bank 1 - Utilities
ROMBANK9    EQU     9                                                    ;                     :  CBIOS Bank 2 - Screen / ANSI Terminal
ROMBANK10   EQU     10                                                   ;                     :  CBIOS Bank 3 - SD Card
ROMBANK11   EQU     11                                                   ;                     :  CBIOS Bank 4 - Floppy disk controller.



OBJCD       EQU     001h

;-----------------------------------------------
; IO Registers
;-----------------------------------------------
FDC         EQU     0D8h                                                 ; MB8866 IO Region 0D8h - 0DBh
FDC_CR      EQU     000h + FDC                                           ; Command Register
FDC_STR     EQU     000h + FDC                                           ; Status Register
FDC_TR      EQU     001h + FDC                                           ; Track Register
FDC_SCR     EQU     002h + FDC                                           ; Sector Register
FDC_DR      EQU     003h + FDC                                           ; Data Register
FDC_MOTOR   EQU     004h + FDC                                           ; DS[0-3] and Motor control. 4 drives  DS= BIT 0 -> Bit 2 = Drive number, 2=1,1=0,0=0 DS0, 2=1,1=0,0=1 DS1 etc
                                                                         ;  bit 7 = 1 MOTOR ON LOW (Active)
FDC_SIDE    EQU     005h + FDC                                           ; Side select, Bit 0 when set = SIDE SELECT LOW

;-----------------------------------------------
; Common character definitions.
;-----------------------------------------------
SCROLL      EQU     001H            ;Set scroll direction UP.
BELL        EQU     007H
SPACE       EQU     020H
TAB         EQU     009H            ;TAB ACROSS (8 SPACES FOR SD-BOARD)
CR          EQU     00DH
LF          EQU     00AH
FF          EQU     00CH
DELETE      EQU     07FH
BACKS       EQU     008H
SOH         EQU     1            ; For XModem etc.
EOT         EQU     4
ACK         EQU     6
NAK         EQU     015H
NUL         EQU     000H
NULL        EQU     000H
CTRL_A      EQU     001H
CTRL_B      EQU     002H
CTRL_C      EQU     003H
CTRL_D      EQU     004H
CTRL_E      EQU     005H
CTRL_F      EQU     006H
CTRL_G      EQU     007H
CTRL_H      EQU     008H
CTRL_I      EQU     009H
CTRL_J      EQU     00AH
CTRL_K      EQU     00BH
CTRL_L      EQU     00CH
CTRL_M      EQU     00DH
CTRL_N      EQU     00EH
CTRL_O      EQU     00FH
CTRL_P      EQU     010H
CTRL_Q      EQU     011H
CTRL_R      EQU     012H
CTRL_S      EQU     013H
CTRL_T      EQU     014H
CTRL_U      EQU     015H
CTRL_V      EQU     016H
CTRL_W      EQU     017H
CTRL_X      EQU     018H
CTRL_Y      EQU     019H
CTRL_Z      EQU     01AH
ESC         EQU     01BH
CTRL_SLASH  EQU     01CH
CTRL_RB     EQU     01DH
CTRL_CAPPA  EQU     01EH
CTRL_UNDSCR EQU     01FH
CTRL_AT     EQU     000H
NOKEY       EQU     0F0H
CURSRIGHT   EQU     0F1H
CURSLEFT    EQU     0F2H
CURSUP      EQU     0F3H
CURSDOWN    EQU     0F4H
DBLZERO     EQU     0F5H
INSERT      EQU     0F6H
CLRKEY      EQU     0F7H
HOMEKEY     EQU     0F8H
BREAKKEY    EQU     0FBH


; MMC/SD command (SPI mode)
CMD0        EQU     64 + 0                                               ; GO_IDLE_STATE 
CMD1        EQU     64 + 1                                               ; SEND_OP_COND 
ACMD41      EQU     0x40+41                                              ; SEND_OP_COND (SDC) 
CMD8        EQU     64 + 8                                               ; SEND_IF_COND 
CMD9        EQU     64 + 9                                               ; SEND_CSD 
CMD10       EQU     64 + 10                                              ; SEND_CID 
CMD12       EQU     64 + 12                                              ; STOP_TRANSMISSION 
CMD13       EQU     64 + 13                                              ; SEND_STATUS 
ACMD13      EQU     0x40+13                                              ; SD_STATUS (SDC) 
CMD16       EQU     64 + 16                                              ; SET_BLOCKLEN 
CMD17       EQU     64 + 17                                              ; READ_SINGLE_BLOCK 
CMD18       EQU     64 + 18                                              ; READ_MULTIPLE_BLOCK 
CMD23       EQU     64 + 23                                              ; SET_BLOCK_COUNT 
ACMD23      EQU     0x40+23                                              ; SET_WR_BLK_ERASE_COUNT (SDC)
CMD24       EQU     64 + 24                                              ; WRITE_BLOCK 
CMD25       EQU     64 + 25                                              ; WRITE_MULTIPLE_BLOCK 
CMD32       EQU     64 + 32                                              ; ERASE_ER_BLK_START 
CMD33       EQU     64 + 33                                              ; ERASE_ER_BLK_END 
CMD38       EQU     64 + 38                                              ; ERASE 
CMD55       EQU     64 + 55                                              ; APP_CMD 
CMD58       EQU     64 + 58                                              ; READ_OCR 

; Card type flags (CardType)
CT_MMC      EQU     001H                                                 ; MMC ver 3 
CT_SD1      EQU     002H                                                 ; SD ver 1 
CT_SD2      EQU     004H                                                 ; SD ver 2 
CT_SDC      EQU     CT_SD1|CT_SD2                                        ; SD 
CT_BLOCK    EQU     008H                                                 ; Block addressing

; Disk types.
DSKTYP_FDC  EQU     0                                                    ; Type of disk is a Floppy disk and handled by the FDC controller.
DSKTYP_ROM  EQU     1                                                    ; Type of disk is a ROM and handled by the ROM methods.
DSKTYP_SDC  EQU     2                                                    ; Type of disk is an SD Card and handled by the SD Card methods.

;
; Rom Filing System constants.
;
RFS_DIRENT  EQU     256                                                  ; Directory entries in the RFS directory.
RFS_DIRENTSZ EQU    32                                                   ; Size of a directory entry.
RFS_DIRSIZE EQU     RFS_DIRENT * RFS_DIRENTSZ                            ; Total size of the directory.
RFS_BLOCKSZ EQU     65536                                                ; Size of a file block per directory entry.
RFS_IMGSZ   EQU     RFS_DIRSIZE + (RFS_DIRENT * RFS_BLOCKSZ)             ; Total size of the RFS image.

;
; CPM constants
;
CPM_SD_SEC   EQU    32
CPM_SD_TRK   EQU    1024
CPM_SD_IMGSZ EQU    CPM_SD_TRK * CPM_SD_SEC * SD_SECSIZE

;
; SD Card constants.
;
SD_SECSIZE  EQU     512                                                  ; Default size of an SD Sector 
SD_SECPTRK  EQU     CPM_SD_SEC                                           ; Sectors of SD_SECSIZE per virtual track.
SD_TRACKS   EQU     CPM_SD_TRK                                           ; Number of virtual tracks per disk image.


;-----------------------------------------------
;    BIOS WORK AREA (MZ80A)
;-----------------------------------------------
            ORG     CBIOSDATA

            ; Keyboard processing, ensure starts where LSB = 0.
VARSTART    EQU     $                                                    ; Start of variables.
KEYBUF:     DS      virtual KEYBUFSIZE                                   ; Interrupt driven keyboard buffer.
KEYCOUNT:   DS      virtual 1
KEYWRITE:   DS      virtual 2                                            ; Pointer into the buffer where the next character should be placed.
KEYREAD:    DS      virtual 2                                            ; Pointer into the buffer where the next character can be read.
KEYLAST:    DS      virtual 1                                            ; KEY LAST VALUE
KEYRPT:     DS      virtual 1                                            ; KEY REPEAT COUNTER
USRBANKSAV: DS      virtual 1                                            ; Save user bank number when calling another user bank.
HLSAVE:     DS      virtual 2                                            ; Space to save HL register when manipulating stack.
ROMCTL      DS      virtual 1                                            ; Rom Paging control register contents.
;
SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:       DS      virtual 1                                            ; ATTRIBUTE
NAME:       DS      virtual 17                                           ; FILE NAME
SIZE:       DS      virtual 2                                            ; BYTESIZE
DTADR:      DS      virtual 2                                            ; DATA ADDRESS
EXADR:      DS      virtual 2                                            ; EXECUTION ADDRESS
SWPW:       DS      virtual 10                                           ; SWEEP WORK
KDATW:      DS      virtual 2                                            ; KEY WORK
;KANAF:      DS      virtual 1                                            ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:      DS      virtual 2                                            ; DISPLAY COORDINATES
;DSPXYLST:   DS      virtual 2                                            ; Last known cursor position, to compare with DSPXY to detect changes.
FLASHCTL:   DS      virtual 1                                            ; CURSOR FLASH CONTROL. BIT 0 = Cursor On/Off, BIT 1 = Cursor displayed.
DSPXYADDR:  DS      virtual 2                                            ; Address of last known position.
MANG:       DS      virtual 6                                            ; COLUMN MANAGEMENT
MANGE:      DS      virtual 1                                            ; COLUMN MANAGEMENT END
PBIAS:      DS      virtual 1                                            ; PAGE BIAS
ROLTOP:     DS      virtual 1                                            ; ROLL TOP BIAS
MGPNT:      DS      virtual 1                                            ; COLUMN MANAG. POINTER
PAGETP:     DS      virtual 2                                            ; PAGE TOP
ROLEND:     DS      virtual 1                                            ; ROLL END
            DS      virtual 14                                           ; BIAS
FLASH:      DS      virtual 1                                            ; FLASHING DATA
SFTLK:      DS      virtual 1                                            ; SHIFT LOCK
REVFLG:     DS      virtual 1                                            ; REVERSE FLAG
FLSDT:      DS      virtual 1                                            ; CURSOR DATA
STRGF:      DS      virtual 1                                            ; STRING FLAG
DPRNT:      DS      virtual 1                                            ; TAB COUNTER
;AMPM:       DS      virtual 1                                            ; AMPM DATA
;TIMFG:      DS      virtual 1                                            ; TIME FLAG
SWRK:       DS      virtual 1                                            ; KEY SOUND FLAG
TEMPW:      DS      virtual 1                                            ; TEMPO WORK
ONTYO:      DS      virtual 1                                            ; ONTYO WORK
OCTV:       DS      virtual 1                                            ; OCTAVE WORK
RATIO:      DS      virtual 2                                            ; ONPU RATIO
;BUFER:      DS      virtual 81                                           ; GET LINE BUFFER
;KEYBUF:     DS      virtual 1                                            ; KEY BUFFER
DRVAVAIL    DS      virtual 1                                            ; Flag to indicate which drive controllers are available. Bit 2 = SD, Bit 1 = ROM, Bit 0 = FDC
TIMESEC     DS      virtual 6                                            ; RTC 48bit TIME IN MILLISECONDS
FDCCMD      DS      virtual 1                                            ; LAST FDC COMMAND SENT TO CONTROLLER.
MOTON       DS      virtual 1                                            ; MOTOR ON = 1, OFF = 0
INVFDCDATA: DS      virtual 1                                            ; INVERT DATA COMING FROM FDC, 1 = INVERT, 0 = AS IS
TRK0FD1     DS      virtual 1                                            ; FD 1 IS AT TRACK 0 = BIT 0 set 
TRK0FD2     DS      virtual 1                                            ; FD 2 IS AT TRACK 0 = BIT 0 set
TRK0FD3     DS      virtual 1                                            ; FD 3 IS AT TRACK 0 = BIT 0 set
TRK0FD4     DS      virtual 1                                            ; FD 4 IS AT TRACK 0 = BIT 0 set
RETRIES     DS      virtual 2                                            ; DATA READ RETRIES
TMPADR      DS      virtual 2                                            ; TEMPORARY ADDRESS STORAGE
TMPSIZE     DS      virtual 2                                            ; TEMPORARY SIZE
TMPCNT      DS      virtual 2                                            ; TEMPORARY COUNTER
;
CPMROMLOC:  DS      virtual 2                                            ; Upper Byte = ROM Bank, Lower Byte = Page of CPM Image.
CPMROMDRV0: DS      virtual 2                                            ; Upper Byte = ROM Bank, Lower Byte = Page of CPM Rom Drive Image Disk 0.
CPMROMDRV1: DS      virtual 2                                            ; Upper Byte = ROM Bank, Lower Byte = Page of CPM Rom Drive Image Disk 1.
NDISKS:     DS      virtual 1                                            ; Dynamically calculated number of disks on boot.
DISKMAP:    DS      virtual MAXDISKS                                     ; Disk map of CPM logical to physical controller disk.
FDCDISK:    DS      virtual 1                                            ; Physical disk number.
SECPERTRK:  DS      virtual 1                                            ; Sectors per track for 1 head.
SECPERHEAD: DS      virtual 1                                            ; Sectors per head.
SECTORCNT:  DS      virtual 1                                            ; Sector size as a count of how many sectors make 512 bytes.
DISKTYPE:   DS      virtual 1                                            ; Disk type of current selection.
MTROFFTIMER:DS      virtual 1                                            ; Second down counter for FDC motor off.
;
SEKDSK:     DS      virtual 1                                            ; Seek disk number
SEKTRK:     DS      virtual 2                                            ; Seek disk track
SEKSEC:     DS      virtual 1                                            ; Seek sector number
SEKHST:     DS      virtual 1                                            ; Seek sector host
;
HSTDSK:     DS      virtual 1                                            ; Host disk number
HSTTRK:     DS      virtual 2                                            ; Host track number
HSTSEC:     DS      virtual 1                                            ; Host sector number
HSTWRT:     DS      virtual 1                                            ; Host write flag
HSTACT:     DS      virtual 1                                            ; 
;
UNACNT:     DS      virtual 1                                            ; Unalloc rec cnt
UNADSK:     DS      virtual 1                                            ; Last unalloc disk
UNATRK:     DS      virtual 2                                            ; Last unalloc track
UNASEC:     DS      virtual 1                                            ; Last unalloc sector
;
ERFLAG:     DS      virtual 1                                            ; Error number, 0 = no error.
READOP:     DS      virtual 1                                            ; If read operation then 1, else 0 for write.
RSFLAG:     DS      virtual 1                                            ; Read sector flag.
WRTYPE:     DS      virtual 1                                            ; Write operation type.
TRACKNO:    DS      virtual 2                                            ; Host controller track number
SECTORNO:   DS      virtual 1                                            ; Host controller sector number
DMAADDR:    DS      virtual 2                                            ; Last DMA address
HSTBUF:     DS      virtual 512                                          ; Host buffer for disk sector storage
HSTBUFE:

SDVER:      DS      virtual 1                                            ; SD Card version.
SDCAP:      DS      virtual 1                                            ; SD Card capabilities..
SDSTARTSEC  DS      virtual 4                                            ; Starting sector of data to read/write from/to SD card.
SDBUF:      DS      virtual 11                                           ; SD Card command fram buffer for the command and response storage.

CURSORPSAV  DS      virtual 2                                            ; Cursor save position;default 0,0
HAVELOADED  DS      virtual 1                                            ; To show that a value has been put in for Ansi emualtor.
ANSIFIRST   DS      virtual 1                                            ; Holds first character of Ansi sequence
NUMBERBUF   DS      virtual 20                                           ; Buffer for numbers in Ansi
NUMBERPOS   DS      virtual 2                                            ; Address within buffer
CHARACTERNO DS      virtual 1                                            ; Byte within Ansi sequence. 0=first,255=other
CURSORCOUNT DS      virtual 1                                            ; 1/50ths of a second since last change
FONTSET     DS      virtual 1                                            ; Ansi font setup.
JSW_FF      DS      virtual 1                                            ; Byte value to turn on/off FF routine
JSW_LF      DS      virtual 1                                            ; Byte value to turn on/off LF routine
CHARACTER   DS      virtual 1                                            ; To buffer character to be printed.    
CURSORPOS   DS      virtual 2                                            ; Cursor position, default 0,0.
BOLDMODE    DS      virtual 1
HIBRITEMODE DS      virtual 1                                            ; 0 means on, &C9 means off
UNDERSCMODE DS      virtual 1
ITALICMODE  DS      virtual 1
INVMODE     DS      virtual 1
CHGCURSMODE DS      virtual 1
ANSIMODE    DS      virtual 1                                            ; 1 = on, 0 = off
COLOUR      EQU     0

SPSAVE:     DS      virtual 2                                            ; CPM Stack save.
SPISRSAVE:  DS      virtual 2
            ; Stack space for the CBIOS.
MSGSTRBUF:  DS      virtual 128                                          ; Lower end of the stack space is for interbank message printing, ie.space for a string to print.
BIOSSTACK   EQU     $
            ; Stack space for the Interrupt Service Routine.
            DS      virtual 16                                           ; Max 8 stack pushes.
ISRSTACK    EQU     $

DBGSTACKP:  DS      virtual 2
            DS      virtual 64
DBGSTACK:   EQU     $

VAREND      EQU     $                                                    ; End of variables
