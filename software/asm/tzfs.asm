;--------------------------------------------------------------------------------------------------------
;-
;- Name:            tzfs.asm
;- Created:         July 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series tzfs (tranZPUter Filing System).
;-                  This assembly language program is a branch from the original RFS written for the
;-                  MZ80A_RFS upgrade board. It is adapted to work within the similar yet different 
;-                  environment of the tranZPUter SW which has a large RAM capacity (512K) and an
;-                  I/O processor in the K64F/ZPU.
;-
;- Credits:         
;- Copyright:       (c) 2018-2020 Philip Smart <philip.smart@net2net.org>
;-
;- History:         May 2020  - Branch taken from RFS v2.0 and adapted for the tranZPUter SW.
;-                  July 2020 - Not many changes but updated version to v1.1 to coincide with the
;-                              hardware v1.1 version, thus differentiating between v1.0 board and v1.1.
;-                  July 2020 - Updates to accomodate the v2.1 hardware. Additional commands and fixed a 
;-                              few bugs like the load from card by name!
;-                  Dec 2020  - Updates to accommodate v1.3 of the tranZPUter SW-700 board where soft
;-                              CPU's now become possible.
;-                  Jan 2021  - Additional changes to accommodate soft CPU's.
;-                  Mar 2021  - Bug fixes - MZ-700/MZ-80A address differences.
;-                            - Added optional machine model code on load command to enable 700/800
;-                              programs to be loaded without changing the MZ800 mode switch.
;-                  Apr 2021  - Added 40/80 Colour Card control. Reorganised to free up space.
;-                  Apr 2021  - Updated to add ?RDI/?RDD/?WRI/?WRD/DIR/CD methods to ease conversion of
;-                              programs from cassette storage to SD storage, first conversion being
;-                              BASIC SA-5510.
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

            ; Bring in additional resources.
            INCLUDE "TZFS_Definitions.asm"


            ;============================================================
            ;
            ; USER ROM BANK - Main TZFS Entry point and common functions.
            ; TZFS BANK 1   -
            ;
            ;============================================================
            ORG     UROMADDR


            ;--------------------------------
            ; Startup code
            ;--------------------------------
TZFS:       NOP                                                          ; Nop is needed for monitor autostart.
            LD      A,(WARMSTART)                                        ; Is this the second time we are called? First time sets the memory map to TZMM_TZFS and enables the RAM based monitor.
            OR      A
            JP      NZ,TZFS_1                                            ; Already called so jump to the monitor component of TZFS.
            ;
            LD      A,TZMM_TZFS                
            LD      (MMCFGVAL),A                                         ; Store the value in a memory variable as we cant read the latch once programmed.
            OUT     (MMCFG),A                                            ; Switch to the TZFS memory mode, SA1510/monitor is now in RAM at 0000H
            ;
            LD      A,1                                                  ; TZMM_BOOT doesnt allow writes to User ROM space, so need to be in mode TZMM_TZFS first.
            LD      (WARMSTART),A                                        ; Set warm start flag so next invocation goes to monitor.
            JP      MROMADDR                                             ; Cold start the RAM based SA1510/monitor which in turn will recall us to warm start.
            

            ALIGN_NOPS UROMBSTBL

            ;------------------------------------------------------------------------------------------
            ; Bank switching code, allows a call to code in another bank.
            ; For TZFS, the area E800-EFFF is locked and the area F000-FFFF is paged as needed.
            ;------------------------------------------------------------------------------------------

            ; Methods to access public functions in paged area F000-FFFF. The memory mode is switched
            ; which means any access to F000-FFFF will be directed to a different portion of the 512K
            ; static RAM - this is coded into the FlashRAM decoder. Once the memory mode is switched a
            ; call is made to the required function and upon return the memory mode is returned to the
            ; previous value. The memory mode is stored on the stack and all registers are preserved for
            ; full re-entrant functionality.
BANKTOBANK_:JMPTOBNK

            ALIGN   TZFSJMPTABLE
            ORG     TZFSJMPTABLE


            ;------------------------------------------------------------------------------------------
            ; External function Jump table.
            ; This table is used by external (to TZFS) programs to invoke functionality as required.
            ; The entry point is fixed, starting at TZFSJMPTABLE incrementing by 3 for each call.
            ;------------------------------------------------------------------------------------------
CMT_RDINF:  JP       _CMT_RDINF                                          ; UROMADDR+80H - Tape/SD intercept handler - Read Header
CMT_RDDATA: JP       _CMT_RDDATA                                         ; UROMADDR+83H - Tape/SD intercept handler - Read Data
CMT_WRINF:  JP       _CMT_WRINF                                          ; UROMADDR+86H - Tape/SD intercept handler - Write Header
CMT_WRDATA: JP       _CMT_WRDATA                                         ; UROMADDR+89H - Tape/SD intercept handler - Write Data
CMT_VERIFY: JP       _CMT_VERIFY                                         ; UROMADDR+8CH - Tape/SD intercept handler - Verify Data
CMT_DIR:    JP       _CMT_DIR                                            ; UROMADDR+8FH - SD card directory listing command.
CMT_CD:     JP       _CMT_CD                                             ; UROMADDR+92H - SD change directory command.
SET_FREQ:   JP       ?SETFREQ                                            ; UROMADDR+95H - Set Frequency command.

            ;------------------------------------------------------------------------------------------
            ; Enhanced function Jump table.
            ; This table is generally used by a banked page to call a function within another banked
            ; page. The name is the same as the original function but prefixed by a ?.
            ; All registers are preserved going to the called function and returning from it.
            ;------------------------------------------------------------------------------------------
?PRINTMSG:  CALLBNK PRINTMSG,    TZMM_TZFS2
?PRINTASCII:CALLBNK PRINTASCII,  TZMM_TZFS2
?PRTFN:     CALLBNK PRTFN,       TZMM_TZFS2
?PRTSTR:    CALLBNK PRTSTR,      TZMM_TZFS2
?HELP:      CALLBNK HELP,        TZMM_TZFS2
?MCORX:     CALLBNK MCORX,       TZMM_TZFS3
?DUMPBC:    CALLBNK DUMPBC,      TZMM_TZFS3
?DUMPX:     CALLBNK DUMPX,       TZMM_TZFS3
?DUMP:      CALLBNK DUMP,        TZMM_TZFS3
?INITMEMX:  CALLBNK INITMEMX,    TZMM_TZFS3
?SETVMODE:  CALLBNK SETVMODE,    TZMM_TZFS4
?SETVGAMODE:CALLBNK SETVGAMODE,  TZMM_TZFS4
?SETVBORDER:CALLBNK SETVBORDER,  TZMM_TZFS4
?SETFREQ:   CALLBNK SETFREQ,     TZMM_TZFS4
?SETT80:    CALLBNK SETT80,      TZMM_TZFS4
?SETZ80:    CALLBNK SETZ80,      TZMM_TZFS4
?SETZPUEVO: CALLBNK SETZPUEVO,   TZMM_TZFS4
?TIMERTST:  CALLBNK TIMERTST,    TZMM_TZFS3
?PTESTX:    CALLBNK PTESTX,      TZMM_TZFS3
?GETMODEL:  CALLBNK GETMODEL,    TZMM_TZFS3
?PLTST:     CALLBNK PLTST,       TZMM_TZFS3
CNV_ATOS:   CALLBNK CNVSTR_AS,   TZMM_TZFS2                              ; 
            ;-----------------------------------------


            ;-----------------------------------------
            ; Initialisation and startup.
            ;-----------------------------------------
            ;
            ;
TZFS_1:     LD      SP,TZSTACK                                           ; Setup our stack.
            XOR     A                                                    ; Clear the variable and stack space.
            LD      B, TZSTACK - HLSAVE                                  ; Clear all the variable space except for the startup variables as a restart shouldnt clear them.
            LD      HL, HLSAVE
TZFS_2:     LD      (HL),A
            INC     HL
            DJNZ    TZFS_2              

            ;-------------------------------------------------------------------------------
            ; START OF RFS INITIALISATION AND COMMAND ENTRY PROCESSOR FUNCTIONALITY.
            ;-------------------------------------------------------------------------------
            ;
            ; Replacement command processor in place of the ROM MONITOR command processor.
            ;
MONITOR:    LD      A, (SCRNMODE)
            LD      C, A
            BIT     1, A                                                 ; FPGA video enabled?
            JR      Z, MONITOR1
            ;
            IN      A,(CPLDCFG)
            OR      MODE_VIDEO_FPGA                                      ; Set the tranZPUter CPLD hardware to enable FPGA video.
            OUT     (CPLDCFG),A                                 
            ;
MONITOR1:   LD      HL,DSPCTL                                            ; Control register address for the 40/80 Colour Card.
            LD      A, C                                                 ; Recall screen mode.
            BIT     0, A
            JR      NZ, SET80CHAR
            ;
SET40CHAR:  IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            JR      Z,SET40_1
            ;
            AND     007H                                                 ; Get the base machine mode, use as the starting mode for the video.
            LD      D, A
            LD      A, C                                                 ; Get the VGA mode and add.
            BIT     2, A
            JR      Z, SET40_0
            RRC     A                                                    ; Get the override mode into lower 3 bits.
            RRC     A
            RRC     A
            AND     007H
            LD      D, A
            LD      A, C
            ;
SET40_0:    AND     0C0H
            OR      D
            OUT     (VMCTRL),A                                           ; Activate.
            JR      SET40_2
            ;
SET40_1:    XOR     A                                                    ; 40 char mode.
            LD      E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
            LD      (HL), A
            ;
SET40_2:    XOR     A
            LD      (SPAGE), A                                           ; Allow MZ80A scrolling
            JR      SIGNON
            ;
SET80CHAR:  IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            JR      Z,SET80_1                                            ; No FPGA hardware so try and set set 80 char mode on the assumption the 40/80 Colour Card is installed.
            ;
            AND     007H
            OR      MODE_80CHAR                                          ; Set 80 char flag.
            LD      D, A
            ;
            LD      A, C                                                 ; Check to see if a mode override has been set.
            BIT     2, A
            JR      Z, SET80_0
            RRC     A                                                    ; Get the override mode into lower 3 bits.
            RRC     A
            RRC     A
            AND     007H
            OR      MODE_80CHAR                                          ; Set 80 char flag.
            LD      D, A
            LD      A, C
            ;
SET80_0:    AND     0C0H                                                 ; Get the VGA mode and add.
            OR      D
            OUT     (VMCTRL),A                                           ; Activate.
            LD      A, C                                                 ; Indicate we are using the FPGA video hardware.
            SET     1, A
            LD      (SCRNMODE), A
            JR      SET80_2
            ;
SET80_1:    LD      A, 128                                               ; 80 char mode.
            LD      E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
            LD      (HL), A
            ;
SET80_2:    LD      A, 0FFH
            LD      (SPAGE), A                                           ; MZ80K Scrolling in 80 column mode for time being.
            ;
SIGNON:     LD      A,0C4h                                               ; Move cursor left to overwrite part of SA-1510/monitor banner.
            LD      E,004h                                               ; 4 times.
SIGNON1:    CALL    DPCT
            DEC     E
            JR      NZ,SIGNON1
            LD      DE,MSGSON                                            ; Sign on message,
            CALL    ?PRINTMSG
            IN      A,(CPUINFO)                                          ; Check to see if soft CPU's are available.
            AND     CPUMODE_IS_SOFT_MASK
            CP      CPUMODE_IS_SOFT_AVAIL
            JR      NZ,SIGNON2
            IN      A,(CPUSTATUS)                                        ; Check to see if the T80 is running.
            AND     CPUMODE_IS_T80                                       ; T80 running?
            JR      Z,SIGNON2
            LD      DE,MSGSONT80
            CALL    ?PRINTMSG
SIGNON2:    LD      DE,MSGSONEND
            CALL    ?PRINTMSG

            ; Command processor, table based.
            ; A line is input then a comparison made with entries in the table. If a match is found then the bank and function
            ; address are extracted and a call to the function @ given bank made. The commands can be of variable length
            ; but important to not that longer commands using the same letters as shorter commands must appear first in the table.
            ;
ST1X:       CALL    NL                                                   ; Command line monitor extension.
            LD      A,'*'
            CALL    PRNT
            LD      DE,BUFER
            CALL    GETL
            ;
CMDCMP:     LD      HL,CMDTABLE
CMDCMP0:    LD      DE,BUFER+1                                           ; First command byte after the * prompt.
            LD      A,(HL)
            CP      000H
            JR      Z,ST1X                                               ; Skip processing on lines where just CR pressed.
            BIT     7,A                                                  ; Bit 7 set on command properties indicates table end, exit if needed.
            JR      NZ,CMDNOCMP
            LD      C,A                                                  ; Command properties into C
            SET     6,C                                                  ; Assume command match.
            AND     007H                                                 ; Mask out bytes in command mask.
            LD      B,A                                                  ; Number of bytes in command.
            INC     HL
CMDCMP1:    LD      A,(DE)                                               ; Compare all bytes and reset match bit if we find a difference.
            CP      (HL)
            JR      Z, CMDCMP2
            RES     6,C                                                  ; No command match.
CMDCMP2:    INC     DE
            INC     HL
            DJNZ    CMDCMP1
            BIT     6,C                                                  ; Bit 7 is still set then we have a command match.
            JR      NZ,CMDCMP3
            INC     HL
            INC     HL                                                   ; Skip over function address
            JR      CMDCMP0                                              ; Try match next command.
CMDCMP3:    LD      A,(HL)                                               ; Command function address into HL
            INC     HL
            LD      H,(HL)
            LD      L,A
            PUSH    HL
            LD      (TMPADR),DE                                          ; Store the key buffer location where arguments start.
            LD      HL,CMDCMPEND                                         ; Location to return to after function is called.
            EX      (SP),HL                                              ; Swap the return location with the location to call.
            PUSH    HL                                                   ; Put location to call at top of stack.
            RET                                                          ; Pop into PC and run.
            ;
CMDNOCMP:   LD      DE,MSGBADCMD
            CALL    ?PRINTMSG
CMDCMPEND:  JP      ST1X


            ;-------------------------------------------------------------------------------
            ; END OF TZFS INITIALISATION AND COMMAND ENTRY PROCESSOR FUNCTIONALITY.
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; SERVICE COMMAND METHODS
            ;-------------------------------------------------------------------------------

            ; Method to send a command to the I/O processor and verify it is being acted upon.
            ; THe method, after sending the command, polls the service structure result to see if the I/O processor has updated it. If it doesnt update the result
            ; then after a period of time the command is resent. After a number of retries the command aborts with error. This is needed in case of the I/O processor crashing
            ; we dont want the host to lock up.
            ;
            ; Inputs:
            ;      A = Command.
            ; Outputs:
            ;      A = 0 - Success, command being processed.
            ;      A = 1 - Failure, no contact with I/O processor.
            ;      A = 2 - Failure, no result from I/O processor, it could have crashed or SD card removed!
SVC_CMD:    PUSH    BC
            LD      (TZSVCCMD), A                                        ; Load up the command into the service record.
            LD      A,TZSVC_STATUS_REQUEST
            LD      (TZSVCRESULT),A                                      ; Set the service structure result to REQUEST, if this changes then the K64 is processing.

            LD      BC, TZSVCWAITIORETRIES                               ; Safety in case the IO request wasnt seen by the I/O processor, if we havent seen a response in the service

SVC_CMD1:   PUSH    BC
            LD      A,(TZSVCCMD)
            OUT     (SVCREQ),A                                           ; Make the service request via the service request port.

            LD      BC,0
SVC_CMD2:   LD      A,(TZSVCRESULT)
            CP      TZSVC_STATUS_REQUEST                                 ; I/O processor when it recognises the request sets the status to PROCESSING or gives a result, if this hasnt occurred the the K64F hasnt begun processing.
            JR      NZ, SVC_CMD3
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ, SVC_CMD2
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SVC_CMD1                                          ; Retry sending the I/O command.
            ;
            PUSH    DE
            LD      DE,SVCIOERR
            CALL    ?PRINTMSG
            POP     DE
            POP     BC
            LD      A,1                                                  ; No response, error.
            RET
SVC_CMD3:   POP     BC
            ;
            LD      BC,TZSVCWAITCOUNT                                    ; Number of loops to wait for a response before setting error.
SVC_CMD4:   PUSH    BC
            LD      BC,0
SVC_CMD5:   LD      A,(TZSVCRESULT)
            CP      TZSVC_STATUS_PROCESSING                              ; Wait until the I/O processor sets the result, again timeout in case it locks up.
            JR      NZ, SVC_CMD6
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SVC_CMD5
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SVC_CMD4                                          ; Retry polling for result.
            ;
            PUSH    DE
            LD      DE,SVCRESPERR
            CALL    ?PRINTMSG
            POP     DE
            POP     BC
            LD      A,2
            RET
SVC_CMD6:   XOR     A                                                    ; Success.
            POP     BC
            POP     BC
            RET

            ;-------------------------------------------------------------------------------
            ; END OF SERVICE COMMAND METHODS
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; UTILITIES
            ;-------------------------------------------------------------------------------

            ; Method to read 4 bytes from a buffer pointed to by DE and attempt to convert to a 16bit number. If it fails, print out an error
            ; message and return with C set.
            ;
            ; Input:  DE = Address of digits to conver.
            ; Output: HL = 16 bit number.

READ4HEX:   CALL    HLHEX
            JR      C,READ4HEXERR
            INC     DE
            INC     DE
            INC     DE
            INC     DE
            OR      A                                                    ; Clear carry flag.
            RET
READ4HEXERR:LD      DE,MSGREAD4HEX                                       ; Load up error message, print and exit.
            CALL    ?PRINTMSG
            SCF
            RET

            ;    SPACE PRINT AND DISP ACC
            ;    INPUT:HL=DISP. ADR.
SPHEX:      CALL    PRNTS                                                ; SPACE PRINT
            LD      A,(HL)
            CALL    PRTHX                                                ; DSP OF ACC (ASCII)
            LD      A,(HL)
            RET

            ;    NEW LINE AND PRINT HL REG (ASCII)
NLPHL:      CALL    NL
            CALL    PRTHL
            RET  

HEXIYX:     EX      (SP),IY
            POP     AF
            CALL    HLHEX
            JR      C,HEXIYX2
            JP      (IY)
HEXIYX2:    POP     AF                                                   ; Waste the intermediate caller address
            RET    

            ; Bring in additional resources.
            USE_CMPSTRING:    EQU   1
            USE_SUBSTRING:    EQU   0
            USE_INDEX:        EQU   0
            USE_STRINSERT:    EQU   0
            USE_STRDELETE:    EQU   0
            USE_CONCAT:       EQU   0
            USE_CNVUPPER:     EQU   1
            USE_CNVCHRTONUM:  EQU   1
            USE_ISNUMERIC:    EQU   1
            USE_CNVSTRTONUM:  EQU   1
            ;
            INCLUDE "Macros.asm"
            INCLUDE "TZFS_Utilities.asm"

            ;-------------------------------------------------------------------------------
            ; END OF UTILITIES
            ;-------------------------------------------------------------------------------



;-------------------------------------------------------------------------------------------
; RAM STORAGE AREA
;-------------------------------------------------------------------------------------------
            ;-------------------------------------------------------------------------------
            ; VARIABLES AND STACK SPACE
            ;-------------------------------------------------------------------------------
            ALIGN      TZVARMEM
            ALIGN_NOPS TZVARMEM + TZVARSIZE
            ;-------------------------------------------------------------------------------
            ; END OF VARIABLES AND STACK SPACE
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; TZ SERVICE STRUCTURE AND VARIABLES
            ;-------------------------------------------------------------------------------
            ALIGN      TZSVCMEM
            ALIGN_NOPS TZSVCMEM + TZSVCSIZE
            ;-------------------------------------------------------------------------------
            ; END OF TZ SERVICE STRUCTURE AND VARIABLES
            ;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
; END OF RAM STORAGE AREA
;-------------------------------------------------------------------------------------------


            ORG     BANKRAMADDR

            ;-------------------------------------------------------------------------------
            ; START OF MEMORY CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Method to branch execution to a user given address.
            ;
GOTOX:      CALL    HEXIYX
            JP      (HL)


            ;====================================
            ;
            ; Screen Width and Mode Commands
            ;
            ;====================================

            ; Commands to start the machine in its original mode loading either a 40 or 80 column BIOS as directed.
SETMODE40:  IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            AND     07H                                                  ; Get model info.
            CP      MODE_MZ80A
            JR      Z, SETMODE40A                                        ; MZ80A hardware so setup MZ80A 40 char mode.
            CP      MODE_MZ700
            JP      Z, SETMODE700                                        ; MZ700 hardware so setup MZ700 40 char mode.
            LD      DE, MSGUNKNHW                                        ; Indicate detected hardware not yet handled.
            CALL    ?PRINTMSG
            RET                                                          ; Return status to caller, 0 = success.

SETMODE80:  IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            AND     07H                                                  ; Get model info.
            CP      MODE_MZ80A
            JR      Z, SETMODE80A                                        ; MZ80A hardware so setup MZ80A 80 char mode.
            CP      MODE_MZ700
            JP      Z, SETMODE7008                                       ; MZ700 hardware so setup MZ700 80 char mode.
            LD      DE, MSGUNKNHW                                        ; Indicate detected hardware not yet handled.
            CALL    ?PRINTMSG
            RET                                                          ; Return status to caller, 0 = success.

            ; Start the machine as an MZ-80A in 40 char mode.
SETMODE40A: IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            LD      A,MODE_MZ80A                                         ; Set the tranZPUter CPLD hardware translation to MZ80A mode.
            JR      Z,SETMODE40_1
            LD      A,VMMODE_MZ80A                                       ; Setup the display to 40 char MZ80A mode.
            OUT     (VMCTRL),A                                           ; Activate.
            LD      A, MODE_MZ80A + MODE_VIDEO_FPGA                      ; Set the tranZPUter CPLD hardware translation to MZ80A mode with FPGA video enabled.
SETMODE40_1:OUT     (CPLDCFG),A                                          ;
            XOR     A
            LD      (SPAGE), A                                           ; Allow MZ80A scrolling
            LD      A,(SCRNMODE)
            RES     0, A
            LD      (SCRNMODE),A                                         ; Bit 0 = 0 = 40char mode on reset.
            ;
            IN      A,(CPLDINFO)                                         ; Check to see if this is an MZ700, if it is not, setup the correct frequency.
            AND     007H
            CP      MODE_MZ80A
            JR      Z,SETMODE40_2
            LD      A,SYSMODE_MZ80A                                      ; Setup the board to run at 2MHz
            OUT     (SYSCTRL),A                                          ; Activate

SETMODE40_2:LD      A,TZSVC_CMD_LOAD40ABIOS                              ; Request the I/O processor loads the SA1510 40column BIOS into memory.
SETBIOS:    CALL    SVC_CMD                                              ; And make communications wit the I/O processor, returning with the result of load operation.
            OR      A
            JP      Z,MROMADDR
            LD      DE,MSGFAILBIOS
            CALL    ?PRINTMSG
            RET                                                          ; Return status to caller, 0 = success.

            ; Start the machine as an MZ-80A in 80 char mode.
SETMODE80A: IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            LD      A, MODE_MZ80A                                        ; Set the tranZPUter CPLD hardware translation to MZ80A mode.
            JR      Z,SETMODE40_1                                        ; No hardware so cannot do 80 char mode.
            ;
            LD      A,VMMODE_MZ80A + MODE_80CHAR                         ; Setup the display to 80 char MZ80A mode.
            OUT     (VMCTRL),A                                           ; Activate.
            LD      A, MODE_MZ80A + MODE_VIDEO_FPGA                      ; Set the tranZPUter CPLD hardware translation to MZ80A mode with FPGA video enabled.
SETMODE80_1:OUT     (CPLDCFG),A                                          ;
            LD      A, 0FFH
            LD      (SPAGE), A                                           ; MZ80K Scrolling in 80 column mode for time being.
            LD      A,(SCRNMODE)
            SET     0, A                                                 ; Indicate 80 column mode for startup.
            LD      (SCRNMODE),A

            IN      A,(CPLDINFO)                                         ; Check to see if this is an MZ700, if it is not, setup the correct frequency.
            AND     007H
            CP      MODE_MZ80A
            JR      Z,SETMODE80_2
            LD      A,SYSMODE_MZ80A                                      ; Setup the board to run at 2MHz
            OUT     (SYSCTRL),A                                          ; Activate

SETMODE80_2:LD      A,TZSVC_CMD_LOAD80ABIOS                              ; Request the I/O processor loads the SA1510 80column BIOS into memory.
            JR      SETBIOS


            ; Commands to switch into MZ-700 compatible mode. This involves switching the CPLD mode which makes hardware keyboard mapping
            ; and changing the frequency, and also enabling of additional traps to detect and change memory mode which are catered for in 
            ; hardware on v2+ boards.
SETMODE700: IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            LD      A, MODE_MZ700                                        ; Set the tranZPUter CPLD hardware translation to MZ700 mode.
            JR      Z,SETMODE7_1
            LD      A,VMMODE_MZ700                                       ; Setup the display to 40 char MZ700 mode.
            OUT     (VMCTRL),A                                           ; Activate.
            LD      A, MODE_MZ700 + MODE_VIDEO_FPGA                      ; Set the tranZPUter CPLD hardware translation to MZ700 mode with FPGA video enabled.
SETMODE7_1: OUT     (CPLDCFG),A                                          ;
            XOR     A
            LD      (SPAGE), A                                           ; Allow MZ80A scrolling
            LD      A,(SCRNMODE)
            RES     0, A
            LD      (SCRNMODE),A                                         ; 0 = 40char mode on reset.

            IN      A,(CPLDINFO)                                         ; Check to see if this is an MZ700, if it is not, setup the correct frequency.
            AND     007H
            CP      MODE_MZ700
            JR      Z,SETMODE7_2
            LD      A,SYSMODE_MZ700                                      ; Setup the board to run at 3.54MHz
            OUT     (SYSCTRL),A                                          ; Activate

SETMODE7_2: LD      A,TZSVC_CMD_LOAD700BIOS40                            ; Request the I/O processor loads the MZ700 1Z-013A 40column BIOS into memory.
            JR      SETBIOS

SETMODE7008:IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            JR      Z,SETMODE7_1                                         ; No hardware so cannot select 80 char mode.
            LD      A,VMMODE_MZ700 + MODE_80CHAR                         ; Setup the display to 80char MZ700 mode.
            OUT     (VMCTRL),A                                           ; Activate.
            LD      A, MODE_MZ700 + MODE_VIDEO_FPGA                      ; Set the tranZPUter CPLD hardware translation to MZ700 mode with FPGA video enabled.
SETMODE78_1:OUT     (CPLDCFG),A                                          ;
            LD      A, 0FFH
            LD      (SPAGE), A                                           ; MZ80K Scrolling in 80 column mode for time being.
            LD      A,(SCRNMODE)
            SET     0, A                                                 ; Indicate 80 column mode for startup.
            LD      (SCRNMODE),A

            IN      A,(CPLDINFO)                                         ; Check to see if this is an MZ700, if it is not, setup the correct frequency.
            AND     007H
            CP      MODE_MZ700
            JR      Z,SETMODE78_2
            LD      A,SYSMODE_MZ700                                      ; Setup the board to run at 3.54MHz
            OUT     (SYSCTRL),A                                          ; Activate

SETMODE78_2:LD      A,TZSVC_CMD_LOAD700BIOS80                            ; Request the I/O processor loads the SA1510 80column BIOS into memory.
            JP      SETBIOS


            ; Command to switch into the Sharp MZ-80B compatible mode. This involves loading the IPL, switching
            ; the frequency to 4MHz and enabling of additional traps to detect and change memory mode.
SETMODE80B: IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            JP      Z,SETMODE40_1                                        ; Without the video hardware cannot select 80B mode.
            LD      A,VMMODE_MZ80B + MODE_80CHAR                         ; Setup the display to 80char MZ80B mode.
            OUT     (VMCTRL),A                                           ; Activate.
            LD      A, MODE_MZ80B + MODE_VIDEO_FPGA                      ; Set the tranZPUter CPLD hardware translation to MZ80B mode with FPGA video enabled.
SETMODE8B_1:OUT     (CPLDCFG),A                                          ;
            LD      A, 0FFH
            LD      (SPAGE), A                                           ; MZ80K Scrolling in 80 column mode for time being.
            LD      A,(SCRNMODE)
            SET     0,A                                                  ; Indicate 80 column mode for startup.
            LD      (SCRNMODE),A

            IN      A,(CPLDINFO)                                         ; Check to see if this is an MZ700, if it is not, setup the correct frequency.
            AND     007H
            CP      MODE_MZ700
            JR      Z,SETMODE8B_2
            LD      A,SYSMODE_MZ700                                      ; Setup the board to run at 3.54MHz
            OUT     (SYSCTRL),A                                          ; Activate

SETMODE8B_2:LD      A,TZSVC_CMD_LOAD80BIPL                               ; Request the I/O processor loads the IPL and switches frequency.
            JP      SETBIOS

            ; Exit out of TZFS - This entails clearing the DRAM as it wont have been refreshed, switching memory mode and then branching to the monitor start entry point.
            ; This is all done by the I/O processor as we need to be in memory mode 0 where all tranZPUter memory is paged out.
            ;
EXITTZFS:   LD      A,TZSVC_CMD_EXIT                                     ; Request the I/O processor restarts the host in original mode.
            CALL    SVC_CMD                                              
            OR      A
            JP      Z,MROMADDR
            LD      DE,MSGFAILEXIT                                       ; Print message if the I/O processor cant process the command.
            CALL    ?PRINTMSG
            RET                                                          ; Return status to caller, 0 = success.


            ; Method to get the CMT parameters from the command line.
            ; The parameters which should be given are:
            ; XXXXYYYYZZZZ - where XXXX = Start Address, YYYY = End Address, ZZZZ = Execution Address.
            ; If the start, end and execution address parameters are correct, prompt for a filename which will be written into the CMT header.
            ; Output:  Reg C = 0 - Success
            ;                = 1 - Error.
GETCMTPARM: CALL    READ4HEX                                             ; Start address
            JR      C,GETCMT1
            LD      (DTADR),HL                                           ; data adress buffer
            LD      B,H
            LD      C,L
            CALL    READ4HEX                                             ; End address
            JR      C,GETCMT1
            SBC     HL,BC
            LD      (SIZE),HL                                            ; byte size buffer
            CALL    READ4HEX                                             ; Execution address
            JR      C,GETCMT1
            LD      (EXADR),HL                                           ; buffer
            CALL    NL
            LD      DE,MSGSAVE                                           ; 'FILENAME? '
            CALL    ?PRINTMSG                                             ; Print out the filename.
            LD      DE,BUFER
            CALL    GETL
            LD      HL,BUFER+10
            LD      DE,NAME                                              ; name buffer
            LD      BC,FNSIZE
            LDIR                                                         ; C = 0 means success.
            RET 
GETCMT1:    LD      C,1                                                  ; C = 1 means an error occured.
            RET 

    
            ;-------------------------------------------------------------------------------
            ; END OF MEMORY CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF CMT CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; CMT Utility to Load a program from tape.
            ;
            ; Three entry points:
            ; LOADTAPE = Load the first program shifting to lo memory if required and execute.
            ; LOADTAPENX = Load the first program and return without executing.
            ; LOADTAPECP = Load the first program to address 0x1200 and return.
            ;
LOADTAPECP: LD      A,0FFH
            LD      (CMTAUTOEXEC),A
            JR      LOADTAPE2
LOADTAPENX: LD      A,0FFH
            JR      LOADTAPE1
LOADTAPE:   LD      A,000H
LOADTAPE1:  LD      (CMTAUTOEXEC),A
            XOR     A
LOADTAPE2:  LD      (CMTCOPY),A                                          ; Set cmt copy mode, 0xFF if we are copying.
            LD      A,0FFH                                               ; If called interbank, set a result code in memory to detect success.
            LD      (RESULT),A
            CALL    ?RDI
            JP      C,?ERX2
            LD      DE,MSGLOAD                                           ; 'LOADING '
            LD      BC,NAME
            CALL    ?PRINTMSG
            XOR     A
            LD      (CMTLOLOAD),A

            LD      HL,(DTADR)                                           ; Common code, store load address in case we shift or manipulate loading.
            LD      (DTADRSTORE),HL

            LD      A,(CMTCOPY)                                          ; If were copying we always load at 0x1200 if the load address is below 0x1000.
            OR      A
            JR      Z,LOADTAPE3
            LD      A,H
            CP      001H
            JR      NC,LOADTAPE2A
            LD      HL,01200H
LOADTAPE2A: LD      (DTADR),HL

LOADTAPE3:  LD      HL,(DTADR)                                           ; If were loading and the load address is below 0x1200, shift it to 0x1200 to load then move into correct location.
            LD      A,H
            OR      L
            JR      NZ,LOADTAPE4
            LD      A,0FFh
            LD      (CMTLOLOAD),A
            LD      HL,01200h
            LD      (DTADR),HL
LOADTAPE4:  CALL    ?RDD
            JP      C,?ERX2
            LD      HL,(DTADRSTORE)                                      ; Restore the original load address into the CMT header.
            LD      (DTADR),HL
            LD      A,(CMTCOPY)
            OR      A
            JR      NZ,LOADTAPE6
LOADTAPE5:  LD      A,(CMTAUTOEXEC)                                      ; Get back the auto execute flag.
            OR      A
            JR      NZ,LOADTAPE6                                         ; Dont execute..
            LD      A,(CMTLOLOAD)
            CP      0FFh
            JR      Z,LOADTAPELM                                         ; Execute at low memory?
            LD      BC,00100h
            LD      HL,(EXADR)
            JP      (HL)
LOADTAPELM: LD      A,(MEMSW)                                            ; Perform memory switch, mapping out ROM from $0000 to $C000
            LD      HL,01200h                                            ; Shift the program down to RAM at $0000
            LD      DE,00000h
            LD      BC,(SIZE)
            LDIR
            LD      BC,00100h
            LD      HL,(EXADR)                                           ; Fetch exec address and run.
            JP      (HL)
LOADTAPE6:  LD      DE,MSGCMTDATA
            PUSH    HL                                                   ; Load address as parameter 2.
            LD      HL,(EXADR)
            PUSH    HL                                                   ; Execution address as parameter 1.
            LD      BC,(SIZE)                                            ; Size as BC parameter.
            CALL    ?PRINTMSG
            POP     BC
            POP     BC                                                   ; Waste parameters.
            XOR     A                                                    ; Success.
            LD      (RESULT),A
            RET


            ; SA1510 Routine to write a tape header. Copied into the TZFS and modified to merge better
            ; with the TZFS interface.
            ;
CMTWRI:     DI      
            PUSH    DE
            PUSH    BC
            PUSH    HL
            LD      D,0D7H
            LD      E,0CCH
            LD      HL,IBUFE
            LD      BC,00080H
            CALL    CKSUM
            CALL    MOTOR
            JR      C,CMTWRI2                 
            LD      A,E
            CP      0CCH
            JR      NZ,CMTWRI1                
            ;
            PUSH    HL
            PUSH    DE
            PUSH    BC
            LD      DE,MSGCMTWRITE
            LD      BC,NAME
            CALL    ?PRINTMSG
            POP     BC
            POP     DE
            POP     HL
            ;
CMTWRI1:    CALL    GAP
            CALL    WTAPE
CMTWRI2:    POP     HL
            POP     BC
            POP     DE
            CALL    MSTOP
            PUSH    AF
            LD      A,(TIMFG)
            CP      0F0H
            JR      NZ,CMTWRI3                
            EI      
CMTWRI3:    POP     AF
            RET     


            ; Method to save an application stored in memory to a cassette in the CMT. The start, size and execution address are either given in BUFER via the 
            ; command line and the a filename is prompted for and read, or alternatively all the data is passed into the function already set in the CMT header.
            ; The tape is then opened and the header + data are written out.
            ;
SAVECMT:    LD      A,0FFH                                               ; Set SDCOPY to indicate this is a copy command and not a command line save.
            JR      SAVEX1
            ;
            ; Normal entry point, the cmdline contains XXXXYYYYZZZZ where XXXX=start, YYYY=size, ZZZZ=exec addr. A filenname is prompted for and read.
            ; The data is stored in the CMT header prior to writing out the header and data..
            ;
SAVEX:      CALL    GETCMTPARM                                           ; Get the CMT parameters.
            LD      A,C
            OR      A
            RET     NZ                                                   ; Exit if an error occurred.

            XOR     A
SAVEX1:     LD      (SDCOPY),A
            LD      A,0FFH
            LD      (RESULT),A                                           ; For interbank calls, pass result via a memory variable. Assume failure unless updated.
            LD      A,OBJCD                                              ; Set attribute: OBJ
            LD      (ATRB),A
            CALL    CMTWRI                                               ; Commence header write. Header doesnt need updating for header write.
?ERX1:      JP      C,?ERX2

            LD      A,(SDCOPY)
            OR      A
            JR      Z,SAVEX2
            LD      DE,(DTADR)
            LD      A,D                                                  ; If copying and address is below 1000H, then data is held at 1200H so update header for write.
            CP      001H
            JR      NC,SAVEX2
            LD      DE,01200H
            LD      (DTADR),DE
SAVEX2:     CALL    ?WRD                                                 ; data
            JR      C,?ERX1
            LD      DE,MSGSAVEOK                                         ; 'OK!'
            CALL    ?PRINTMSG
            LD      A,0                                                  ; Success.
            LD      (RESULT),A
            RET
?ERX2:      CP      002h
            JR      NZ,?ERX3
            LD      (RESULT),A                                           ; Set break key pressed code.
            RET     Z
?ERX3:      LD      DE,MSGE1                                             ; 'CHECK SUM ER.'
            CALL    ?PRINTMSG
            RET


            ; Method to verify that a tape write occurred free of error. After a write, the tape is read and compared with the memory that created it.
            ;
VRFYX:      CALL    ?VRFY
            JP      C,?ERX2
            LD      DE,MSGOK                                             ; 'OK!'
            CALL    ?PRINTMSG
            RET

            ; Method to toggle the audible key press sound, ie a beep when a key is pressed.
            ;
SGX:        LD      A,(SWRK)
            RRA
            CCF
            RLA
            LD      (SWRK),A
            RET

            ;-------------------------------------------------------------------------------
            ; END OF CMT CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; The FDC controller uses it's busy/wait signal as a ROM address line input, this
            ; causes a jump in the code dependent on the signal status. It gets around the 2MHz
            ; Z80 not being quick enough to process the signal by polling.
            ;------------ 0xF3CE -----------------------------------------------------------
            ALIGN_NOPS FDCJMP1
            ORG        FDCJMP1
FDCJMPL:    JP       (IX)    
            ;------------ 0xF400 -----------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF MEMORY TEST FUNCTIONALITY
            ;-------------------------------------------------------------------------------

MEMTEST:    LD      B,240       ; Number of loops
LOOP:       LD      HL,MEMSTART ; Start of checked memory,
            LD      D,0CFh      ; End memory check CF00
LOOP1:      LD      A,000h
            CP      L
            JR      NZ,LOOP1b
            CALL    PRTHL       ; Print HL as 4digit hex.
            LD      A,0C4h      ; Move cursor left.
            LD      E,004h      ; 4 times.
LOOP1a:     CALL    DPCT
            DEC     E
            JR      NZ,LOOP1a
LOOP1b:     INC     HL
            LD      A,H
            CP      D           ; Have we reached end of memory.
            JR      Z,LOOP3     ; Yes, exit.
            LD      A,(HL)      ; Read memory location under test, ie. 0.
            CPL                 ; Subtract, ie. FF - A, ie FF - 0 = FF.
            LD      (HL),A      ; Write it back, ie. FF.
            SUB     (HL)        ; Subtract written memory value from A, ie. should be 0.
            JR      NZ,LOOP2    ; Not zero, we have an error.
            LD      A,(HL)      ; Reread memory location, ie. FF
            CPL                 ; Subtract FF - FF
            LD      (HL),A      ; Write 0
            SUB     (HL)        ; Subtract 0
            JR      Z,LOOP1     ; Loop if the same, ie. 0
LOOP2:      LD      A,16h
            CALL    PRNT        ; Print A
            CALL    PRTHX       ; Print HL as 4 digit hex.
            CALL    PRNTS       ; Print space.
            XOR     A
            LD      (HL),A
            LD      A,(HL)      ; Get into A the failing bits.
            CALL    PRTHX       ; Print A as 2 digit hex.
            CALL    PRNTS       ; Print space.
            LD      A,0FFh      ; Repeat but first load FF into memory
            LD      (HL),A
            LD      A,(HL)
            CALL    PRTHX       ; Print A as 2 digit hex.
            NOP
            JR      LOOP4

LOOP3:      CALL    PRTHL
            LD      DE,OKCHECK
            CALL    MSG          ; Print check message in DE
            LD      A,B          ; Print loop count.
            CALL    PRTHX
            LD      DE,OKMSG
            CALL    MSG          ; Print ok message in DE
            CALL    NL
            DEC     B
            JR      NZ,LOOP
            LD      DE,DONEMSG
            CALL    MSG          ; Print check message in DE
            JP      ST1X

LOOP4:      LD      B,09h
            CALL    PRNTS        ; Print space.
            XOR     A            ; Zero A
            SCF                  ; Set Carry
LOOP5:      PUSH    AF           ; Store A and Flags
            LD      (HL),A       ; Store 0 to bad location.
            LD      A,(HL)       ; Read back
            CALL    PRTHX        ; Print A as 2 digit hex.
            CALL    PRNTS        ; Print space
            POP     AF           ; Get back A (ie. 0 + C)
            RLA                  ; Rotate left A. Bit LSB becomes Carry (ie. 1 first instance), Carry becomes MSB
            DJNZ    LOOP5        ; Loop if not zero, ie. print out all bit locations written and read to memory to locate bad bit.
            XOR     A            ; Zero A, clears flags.
            LD      A,80h
            LD      B,08h
LOOP6:      PUSH    AF           ; Repeat above but AND memory location with original A (ie. 80) 
            LD      C,A          ; Basically walk through all the bits to find which one is stuck.
            LD      (HL),A
            LD      A,(HL)
            AND     C
            NOP
            JR      Z,LOOP8      ; If zero then print out the bit number
            NOP
            NOP
            LD      A,C
            CPL
            LD      (HL),A
            LD      A,(HL)
            AND     C
            JR      NZ,LOOP8     ; As above, if the compliment doesnt yield zero, print out the bit number.
LOOP7:      POP     AF
            RRCA
            NOP
            DJNZ    LOOP6
            JP      ST1X

LOOP8:      CALL    LETNL        ; New line.
            LD      DE,BITMSG    ; BIT message
            CALL    MSG          ; Print message in DE
            LD      A,B
            DEC     A
            CALL    PRTHX        ; Print A as 2 digit hex, ie. BIT number.
            CALL    LETNL        ; New line
            LD      DE,BANKMSG   ; BANK message
            CALL    MSG          ; Print message in DE
            LD      A,H
            CP      50h          ; 'P'
            JR      NC,LOOP9     ; Work out bank number, 1, 2 or 3.
            LD      A,01h
            JR      LOOP11

LOOP9:      CP      90h
            JR      NC,LOOP10
            LD      A,02h
            JR      LOOP11

LOOP10:     LD      A,03h
LOOP11:     CALL    PRTHX        ; Print A as 2 digit hex, ie. BANK number.
            JR      LOOP7

DLY1S:      PUSH    AF
            PUSH    BC
            LD      C,10
L0324:      CALL    DLY12
            DEC     C
            JR      NZ,L0324
            POP     BC
            POP     AF
            RET
            
            ;-------------------------------------------------------------------------------
            ; END OF MEMORY TEST FUNCTIONALITY
            ;-------------------------------------------------------------------------------



            ; Method to print out an SDC directory entry name along with an incremental file number. The file number can be
            ; used as a quick reference to a file rather than the filename.
            ;
            ; Input: HL = Address of filename.
            ;         D = File number.
            ;         A = File type.
            ;
PRTDIR:     PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      C,A                                                  ; Preserve the file type.
            ;
            LD      A,(SCRNMODE)
            BIT     0, A
            LD      H,47
            JR      Z,PRTDIR0
            LD      H,93
PRTDIR0:    LD      A,(TMPLINECNT)                                       ; Pause if we fill the screen.
            LD      E,A
            INC     E
            CP      H
            JR      NZ,PRTNOWAIT
            LD      E, 0
PRTDIRWAIT: CALL    GETKY
            CP      ' '
            JR      Z,PRTNOWAIT
            CP      'X'                                                  ; Exit from listing.
            LD      A,001H
            JR      Z,PRTDIR4
            JR      PRTDIRWAIT
PRTNOWAIT:  LD      A,E
            LD      (TMPLINECNT),A
            ;
            LD      A, D                                                 ; Print out file number and increment.
            CALL    PRTHX
            LD      A,C
            CP      OBJCD
            LD      A, '.'                                               ; File type is MACHINE CODE program.
            JR      Z,PRTDIR0A
            LD      A,C
            CP      BTX1CD
            LD      A,'-'                                                ; File type is BASIC.
            JR      Z,PRTDIR0A
            LD      A,C
            CP      BTX2CD
            LD      A,'_'                                                ; File type is BASIC.
            JR      Z,PRTDIR0A
            LD      A,'+'
PRTDIR0A:   CALL    PRNT
            POP     DE
            PUSH    DE                                                   ; Get pointer to the file name and print.

            CALL    ?PRTFN                                               ; Print out the filename.
            ;
            LD      HL, (DSPXY)
            ;
            LD      A,L
            CP      20
            LD      A,20
            JR      C, PRTDIR2
            ;
            LD      A,(SCRNMODE)                                         ; 40 Char mode? 2 columns of filenames displayed so NL.
            BIT     0,A
            JR      Z,PRTDIR1
            ;
            LD      A,L                                                  ; 80 Char mode we print 4 columns of filenames.
            CP      40
            LD      A,40
            JR      C, PRTDIR2
            ;
            LD      A,L
            CP      60
            LD      A,60
            JR      C, PRTDIR2
            ;
PRTDIR1:    CALL    NL
            JR      PRTDIR3
PRTDIR2:    LD      L,A
            LD      (DSPXY),HL
PRTDIR3:    XOR     A
PRTDIR4:    OR      A
            POP     HL
            POP     DE
            POP     BC
            RET



            ; Method to request a sector full of directory entries from the I/O processor.
            ;
            ; Inputs:
            ;      A = Director Sector number to request (set of directory entries in 512byte blocks).
            ; Outputs:
            ;      A = 0   - success, directory sector filled.
            ;      A = 255 - I/O Error.
            ;      A > 1   - Result from I/O processor, which is normally the error code.
            ;
SVC_GETDIR: LD      (TZSVCDIRSEC),A                                      ; Save the sector number into the service structure.
            ;
            OR      A                                                    ; Sector is 0 then setup for initial read.
            LD      A, TZSVC_CMD_READDIR                                 ; Readdir command opens the directory. The default directory and wildcard have either been placed in the
            JR      Z,SVC_GETD1                                          ; buffer by earlier commands or will be defaulted by the I/O processor.
            LD      A, TZSVC_CMD_NEXTDIR                                 ; Request the next directory sector. The I/O processor either gets the next block or uses the TZSVCDIRSEC value.
SVC_GETD1:  LD      (TZSVCCMD), A                                        ; Load up the command into the service record.
            CALL    SVC_CMD                                              ; And make communications wit the I/O processor, returning with the required record.
            OR      A
            LD      A,255                                                ; Report I/O error as 255.
            RET     NZ
            ;
            LD      A,(TZSVCRESULT)
            RET                                                          ; Return status to caller, 0 = success.

            ; Method to get an SD Directory entry.
            ; The I/O processor communications structure uses a 512 byte sector to pass SD data. A sector is cached and each call evaluates if the required request is in cache, if it is not,
            ; a new sector is read.
            ;
            ; Input:  D  = Directory entry number to retrieve.
            ; Output: HL = Address of directory entry.
            ;         A  = 0, no errors, A > 1 error.
GETSDDIRENT:PUSH    BC
            PUSH    DE;
            ;
            LD      A,D
            SRL     A
            SRL     A
            SRL     A
            SRL     A                                                    ; Divide by 16 to get sector number.
            LD      C,A
            LD      A,(TZSVCDIRSEC)                                      ; Do we have this sector in the buffer? If we do, use it.
            CP      C
            JR      Z,GETDIRSD0
            LD      A,TZSVC_FTYPE_MZF                                    ; Setup to filter on MZF type files.
            LD      (TZSVC_FILE_TYPE),A 
            LD      A,C
            LD      (TZSVCDIRSEC), A                                     ; Store the directory sector we need.
            ;
            CALL    SVC_GETDIR                                           ; Read a sector full of directory entries..
            ;
            OR      A
            JR      NZ,DIRSDERR
            ;
GETDIRSD0:  POP     DE
            PUSH    DE
            LD      A,D                                                  ; Retrieve the directory entry number required.
            AND     00FH
            LD      HL,TZSVCSECTOR
            JR      Z,GETDIRSD2
            LD      B,A
            LD      DE,TZSVCDIR_ENTSZ                                    ; Directory entry size
GETDIRSD1:  ADD     HL,DE                                                ; Directory entry address into HL.
            DJNZ    GETDIRSD1
GETDIRSD2:  POP     DE
            POP     BC
            LD      A,0
GETDIRSD3:  OR      A
            RET
            ;
DIRSDERR:   EX      DE,HL                                                ; Print error message, show HL as it contains sector number where error occurred.
            PUSH    HL
            POP     BC                                                   ; HL to BC as the call requires the value to be displayed in BC.
            LD      DE,MSGSDRERR
            CALL    ?PRINTMSG                                            ; Print out the filename.
            POP     DE
            POP     BC
            LD      A,1
            JR      GETDIRSD3

       ;PUSH HL
       ;POP BC
       ;LD DE, TESTMSG
       ;CALL ?PRINTMSG
       ;PUSH DE
       ;POP BC
       ;LD DE, TESTMSG2
       ;CALL ?PRINTMSG

            ; Method to set the file search wildcard prior to requesting a directory listing. The I/O processor applies this filter only returning directories
            ; which match the wildcard, ie. A* returns directories starting A...
            ;
            ; Inputs:
            ;     DE = Pointer to BUFER start of wildcard.
            ;
            ; HL and B are not preserved.

SETWILDCARD:LD      HL, TZSVCWILDC                                       ; Location of directory name in the service record.
            LD      B, TZSVCWILDSZ-1
            CALL    GETSTRING                                            ; Copy the string into the service record.
            RET

            ; Method to list the directory of the SD Card.
            ;
            ; This method creates a unique sequenced number starting at 0 and attaches to each successive valid directory entry
            ; The file number and file name are then printed out in tabular format. The file number can be used in Load/Save commands
            ; instead of the filename.
            ;
            ; Inputs:
            ;     DE = Pointer to BUFER start of wildcard if present.
            ;
DIRSDCARD:  CALL    SETWILDCARD
            LD      A,1                                                  ; Setup screen for printing, account for the title line. TMPLINECNT is used for page pause.
            LD      (TMPLINECNT),A
            LD      A,0FFH
            LD      (TZSVCDIRSEC),A                                      ; Reset the sector buffer in memory indicator, using 0xFF will force a reread..
            ;
DIRSD0:     LD      D,0                                                  ; Directory entry number
            LD      B,0
DIRSD1:     CALL    GETSDDIRENT                                          ; Get SD Directory entry details for directory entry number stored in D.
            RET     NZ
DIRSD2:     LD      A,(HL)
            INC     HL
            OR      A
            RET     Z
            CALL    PRTDIR                                               ; Valid entry so print directory number and name pointed to by HL.
            JR      NZ,DIRSD4
DIRSD3:     INC     D                                                    ; Onto next directory entry number.
            DJNZ    DIRSD1
DIRSD4:     RET
            ;

            ; Quick method to load the basic interpreter. So long as the filename doesnt change this method will load and boot Basic.
LOADBASIC:  LD      DE,BASICFILENM
            JR      LOADSDCARD

            ; Quick method to load CPM. So long as the filename doesnt change this method will load and boot CPM.
LOADCPM:    LD      DE,CPMFILENAME
            JR      LOADSDCARD

            ; Entry point when copying the SD file. Setup flags to indicate copying to effect any special processing.
            ; The idea is to load the file into memory, dont execute and pass back the parameters within the CMT header.
            ;
LOADSDCP:   LD      A,0FFH
            LD      (SDAUTOEXEC),A
            JR      LOADSD2

            ; Method/entry point to load a file header only. This method is for compatibility with the Sharp ?RDI/?RDD methods.
            ;
LOADSDINF:  LD      A,TZSVC_FTYPE_MZFHDR
            JR      LOADSD2C

            ; Method/entry point to load a file with header already preset. This method is for compatibility with the Sharp ?RDI/?RDD methods.
            ;
LOADSDDATA: LD      A,0FEH                                               ; Mark dont execute and dont print details.
            LD      (SDAUTOEXEC),A
            XOR     A
            LD      (SDCOPY),A   
            LD      A,TZSVC_FTYPE_MZF                                    ; Full file load.
            LD      (TZSVC_FILE_TYPE),A
            LD      HL,(DTADR)                                           ; Load address comes from the header as caller may have changed it, ie. BASIC.
            LD      (TZSVC_LOADADDR),HL
            LD      A,0FFH                                               ; Reset result code ready for new result.
            LD      (RESULT),A
            JR      LOADSD3A                                             ; Load program defined in CMT header.

            ; Load a program from the SD Card into RAM and/or execute it.
            ;
            ; DE points to a number or filename to load.
LOADSDCARDX:LD      A,0FFH
            JR      LOADSD1

LOADSDCARD: XOR     A
LOADSD1:    LD      (SDAUTOEXEC),A
            XOR     A                                                    ; Clear copying flag.
LOADSD2:    LD      (SDCOPY),A   
            LD      A,TZSVC_FTYPE_MZF                                    ; Default to full file load.
            ;
            LD      HL,0FFFFH                                            ; Setup the load address to 0xFFFF = load address definded in file MZF header.
            LD      (TZSVC_LOADADDR),HL
            ;
LOADSD2C:   LD      (TZSVC_FILE_TYPE),A
            ;
            PUSH    DE
            LD      A,0FFH                                               ; For interbank calls, save result in a memory variable.
            LD      (RESULT),A
            LD      (TZSVC_FILE_NO), A 
            CALL    _2HEX
            JR      C, LOADSD2A                                          ; 
            LD      (TZSVC_FILE_NO),A                                    ; A file number was found so store it in the service structure.
LOADSD2A:   CALL    ?GETMODEL                                            ; Get machine model option.
            LD      (TMPCNT),A
            CP      008H                                                 ; Original mainboard memory is target?
            LD      A,000H                                               ; tranZPUter.
            JR      C,LOADSD2B                                           ; MZ-80K .. MZ-2000 modes on tranZPUter.
            INC     A                                                    ; Mainboard mode.
LOADSD2B:   LD      (TZSVC_MEM_TARGET), A
            POP     HL
            LD      A,(TZSVC_FILE_NO)                                    ; Test to see if a file number was found, if none then a filename was given, so copy.
            CP      0FFH
            JR      NZ,LOADSD3A
LOADSD3:    LD      DE,TZSVC_FILENAME
            LD      BC,TZSVCFILESZ
            LDIR                                                         ; Copy in the MZF filename.
            ;
LOADSD3A:   LD      A,TZSVC_CMD_LOADFILE
            LD      (TZSVCCMD), A                                        ; Load up the command into the service record.
            CALL    SVC_CMD                                              ; And make communications with the I/O processor, returning with the required record.
            OR      A
            JR      Z, LOADSD4
            LD      A,255                                                ; Report I/O error as 255.
            JP      LOADSDX2

LOADSD4:    LD      A,(TZSVCRESULT)
            OR      A
            JR      NZ, LOADSD4A
            LD      A,(TZSVC_FILE_TYPE)                                  ; Check to see if we are making a full file load, if header only then return.
            CP      TZSVC_FTYPE_MZF
            JR      Z, LOADSD14
            JR      LOADSDX

LOADSD4A:   LD      DE,MSGNOTFND
            CALL    ?PRINTMSG                                            ; Print message that file wasnt found.
            LD      A,1
            JR      LOADSDX2

            ; The file has been found and loaded into memory by the I/O processor.
            LD      DE,MSGLOAD+1                                         ; Skip initial CR.
            LD      BC,NAME
            CALL    ?PRINTMSG                                            ; Print out the filename.

LOADSD14:   LD      A,(SDAUTOEXEC)                                       ; Autoexecute turned off?
            CP      0FFh
            JP      Z,LOADSD15                                           ; Go back to monitor if it has been turned off, else execute.
            CP      0FEH                                                 ; Extension for ?RDD - if set to 0FEH then dont print information just return.
            JR      Z,LOADSDX       
            ;
            LD      A,(TZSVCSECTOR+TZFS_ATRB)                            ; Fetch the CMT data from the service sector.
            LD      HL,(TZSVCSECTOR+TZFS_EXADR)                          ; Save the execution address as it may not be in scope later on.
            LD      DE,(TZSVCSECTOR+TZFS_DTADR)                          ; Save the data address, used to check if it was a low memory load.
            ;
            CP      OBJCD                                                ; Standard binary file?
            JR      Z,LOADSD14A
            CP      TZOBJCD0                                             ; TZFS binary file for a particular bank?
            JR      C,LOADSD17

LOADSD14A:  LD      A,(TZSVC_MEM_TARGET)                                 ; Are we loading/executing in original host memory?
            OR      A
            JR      NZ,ORIPRGBOOT                                        ; Yes, then need special bootstrap.      
            ;
            IN      A,(CPLDINFO)                                         ; Check hardware, if not MZ700/MZ800 skip memory reconfig.
            AND     07H
            CP      MODE_MZ700
            JR      Z, LOADSD14B                                         ; 700 mode we just check if the lower bank needs paging in.
            CP      MODE_MZ800
            JR      NZ, LOADSD14C
            ;
            ; DE = Load Address
LOADSD14B:  LD      A,010H                                               ; Load address below 1000H? If so, page out monitor ROM.
            CP      D
            JR      C,LOADSD14C
            JR      NZ,LOADSD14C
            OUT     (MMIO0), A                                           ; Program loaded below 1000H so page in memory.
            ;
LOADSD14C:  LD      A,(TMPCNT)                                           ; Get hardware model the loaded program should execute under.
            CP      MODE_MZ800                                           ; Only interested in the MZ-800 at the moment, K to 700 models dont need special settings.
            JR      Z,LOADSD14D
            JR      LOADSD14E
            ;
LOADSD14D:  XOR     A                                            
            OUT     (GDCMD),A                                            ; Set MZ 800 mode
            CALL    ?PLTST                                               ; Set the palette.
            ;
            ; HL = Execution address.
LOADSD14E:  XOR     A
            JP      (HL)                                                 ; Execution address.

LOADSD15:   LD      DE,MSGCMTDATA                                        ; Indicate where the program was loaded and the execution address.
            LD      HL,(TZSVCSECTOR+TZFS_DTADR)
            PUSH    HL
            LD      HL,(TZSVCSECTOR+TZFS_EXADR)
            PUSH    HL
            LD      BC,(TZSVCSECTOR+TZFS_SIZE)
LOADSD16:   CALL    ?PRINTMSG                                            ; Print out the filename.
            POP     BC
            POP     BC                                                   ; Remove parameters off stack.
LOADSDX:    LD      A,0                                                  ; Non error exit.
            ;
LOADSDX2:   LD      (RESULT),A
            RET
            ;
LOADSD17:   LD      DE,MSGNOTBIN
            CALL    ?PRINTMSG                                            ; Print out the filename.
            LD      A,1
            JR      LOADSDX2

            ; Code to bootstrap a program residing in the host memory.
            ; It is assumed, running in TZFS, that the memory map is of TZFS and actions taken accordingly.
ORIPRGBOOT: LD      A,(TMPCNT)                                           ; Get requested mode before it goes out of scope and store.
            LD      C,A
            ;
            LD      A,TZMM_HOSTACCESS                                    ; Page in host memory so we can read the execution address and run the program.
            OUT     (MMCFG),A
            EXX                                                          ; Execution and load address are stored in HL/DE from the tape header.
            LD      DE,PRGBOOTJMP                                        ; Move the relocatable code into the safe area, in this case the upper attribute RAM.
            LD      HL,ORIBOOTREL
            LD      BC,ORIBOOTRELEND - ORIBOOTREL
            LDIR
            EXX
            JP      PRGBOOTJMP

            ; Relocatable code which operates in a safe area within original host memory. This code then switches memory mode
            ; and executes the stored code.
ORIBOOTREL: LD      SP,PRGBOOTJMP + (ORIBOOTRELEND - ORIBOOTREL)         ; Relative as this code block is moved.
            ;
            LD      A,TZMM_ORIG                                          ; Switch to original host mode.
            OUT     (MMCFG),A
            OUT     (MMIO4),A

            ; Determine if this program is loaded below 1200h? We cant initialise monitor variables for this case ; as it may corrupt the program.
            LD      A,D
            CP      011H
            JR      C,ORIBOOT1                                           ; Some programs load data in the tape header or scratch area so need to work on 1000H or below.
            ;
            PUSH    HL                                                   ; The loaded program may call or reference monitor api procedures and the monitor scratch area
            LD      HL,SWPW                                              ; state will be unknown, we therefore need to zero it to ensure correct loaded program execution.
            LD      B,BUFER - SWPW
            XOR     A
ORIBOOT0:   LD      (HL), A
            INC     HL
            DJNZ    ORIBOOT0
            LD      A,004H
            LD      (TEMPW),A                                            ; Set the sound tempo to default.
            ;
            LD      A,24                                                 ; Set the display coordinates to end of screen to not corrupt existing data.
            LD      (DSPXY+1),A
            POP     HL
            ;
ORIBOOT1:   IN      A,(CPLDINFO)                                         ; Check hardware, if not MZ700/MZ800 skip memory reconfig.
            AND     07H
            CP      MODE_MZ700
            JR      Z, ORIBOOT3                                          ; 700 mode we just check if the lower bank needs paging in.
            CP      MODE_MZ800
            JR      NZ, ORIBOOT4
            ;
ORIBOOT2:   LD      A,C                                                  ; Check user requested mode, original or alternative (ie. MZ-700 mode on an MZ-800).
            CP      09H
            JR      Z,ORIBOOT3
            ;
            XOR     A                                                    ; Set the graphics display gatearray command register to enable 800 mode.
            OUT     (GDCMD),A 
           ;OUT     (MMIO4),A

            ; Set the MZ-800 palette.
            PUSH    HL                                           
            LD      BC,05F0H                                             ; C=port (Pallet Write), B=count
            LD      HL,PRGBOOTJMP + (ORIPLTDT - ORIBOOTREL)              ; Data
            OTIR                                                                          
            XOR     A                                                                     
            LD      BC,06CFH                                             ; Border Black
            OUT     (C),A                                                ; Send to port.
            POP     HL                                           
            ;
ORIBOOT3:   LD      A,D                                                  ; Load address below 1000H? If so, page out monitor ROM.
            CP      011H
            JR      NC, ORIBOOT4
            OUT     (MMIO0), A                                           ; Page in lower DRAM as the program executes from below 0x1000.
            ;
ORIBOOT4:   JP      (HL)                                                 ; Execute program.

            ; Initialization table for Palette
            ;
ORIPLTDT:   DB      0,10H,20H,30H,40H    
            ; Temporary stack.
            DS      32
ORISTACK    EQU     $
            ;
ORIBOOTRELEND:

            ; The FDC controller uses it's busy/wait signal as a ROM address line input, this
            ; causes a jump in the code dependent on the signal status. It gets around the 2MHz
            ; Z80 not being quick enough to process the signal by polling.
            ;------------ 0xF7C0 -----------------------------------------------------------
            ALIGN_NOPS FDCJMP2
            ORG        FDCJMP2
FDCJMPH:    JP       (IY)    
            ;------------ 0xF800 -----------------------------------------------------------


            ; Method to erase a file on the SD. Details of the file are passed to the I/O processor and if the file is found
            ; it is deleted from the SD.
            ; Input:  DE = String containing filenumber or filename to erase.
            ; Output:  A = 0 Success, 1 = Fail.
ERASESD:    PUSH    DE
            LD      A,0FFh                                               ; Tag the filenumber as invalid.
            LD      (TZSVC_FILE_NO), A 
            CALL    _2HEX
            JR      C, ERASESD1                                          ; 
            LD      (TZSVC_FILE_NO),A                                    ; A file number was found so store it in the service structure.
ERASESD1:   POP     HL
            LD      A,(TZSVC_FILE_NO)                                    ; Test to see if a file number was found, if one wasnt then a filename was given, so copy.
            CP      0FFH
            JR      NZ,ERASESD2
            LD      DE,TZSVC_FILENAME
            LD      BC,TZSVCFILESZ
            LDIR                                                         ; Copy in the MZF filename.
ERASESD2:   LD      A,TZSVC_FTYPE_MZF                                    ; Set to MZF type files.
            LD      (TZSVC_FILE_TYPE),A
            LD      A,TZSVC_CMD_ERASEFILE
            LD      (TZSVCCMD), A                                        ; Load up the command into the service record.
            CALL    SVC_CMD                                              ; And make communications wit the I/O processor, returning with the required record.
            OR      A
            JR      Z, ERASESD3
            LD      A,255                                                ; Report I/O error as 255.
            RET
ERASESD3:   LD      A,(TZSVC_FILE_NO)                                    ; Get the file number for the message output.
            LD      C,A
            LD      B,0
            LD      A,(TZSVCRESULT)
            OR      A
            JR      Z, ERASESD4
            ;
            LD      DE,MSGERAFAIL                                        ; Fail, print out message.
            CALL    ?PRINTMSG                                             ; Print out the filename.
            LD      A,1
            RET
ERASESD4:   LD      DE,MSGERASEDIR
            CALL    ?PRINTMSG                                             ; Print out the filename.
            LD      A,0                                                  ; Success.
            RET


            ; Setup for saving an application to SD Card but using the CMT header. Also set the copy flag because the values in the header
            ; may not reflect where the image is stored (ie. CTM LOAD=0x0000 -> data is at 0x1200).
            ;
SAVESDCARDX:LD      A,0FFH    
            JR      SAVESD1

            ; Method to save a block of memory to the SD card as a program.
            ; The parameters which should be given are:
            ; XXXXYYYYZZZZ - where XXXX = Start Address, YYYY = End Address, ZZZZ = Execution Address.
            ; Prompt for a filename which will be written into the CMT header.
            ; All the values are stored in the CMT header and copied as needed into the SD file.
            ;
SAVESDCARD: CALL    GETCMTPARM                                           ; Get the CMT parameters.
            LD      A,C
            OR      A
            RET     NZ                                                   ; Exit if an error occurred.
            ;
            LD      A,OBJCD                                              ; Set attribute: OBJ
            LD      (ATRB),A
            ;
SAVESDDATA: XOR     A                                                    ; Disable the copy flag.
SAVESD1:    LD      (SDCOPY),A
            LD      A,0FFH                                               ; Interbank calls, pass result via a memory variable. Assume failure unless updated.
            LD      (RESULT),A

            ; Save the file by making a service call to the I/O processor, it will allocate a filename on the SD, read the tranZPUter memory directly based on the values in the
            ; service record.
SAVESD2:    LD      A,TZSVC_FTYPE_MZF                                    ; Set to MZF type files.
            LD      (TZSVC_FILE_TYPE),A
            LD      A,TZSVC_CMD_SAVEFILE
            LD      (TZSVCCMD), A                                        ; Load up the command into the service record.
            CALL    SVC_CMD                                              ; And make communications wit the I/O processor, returning with the required record.
            OR      A
            JR      Z, SAVESD3
            LD      A,255                                                ; Report I/O error as 255.
            RET
SAVESD3:    LD      A,(TZSVC_FILE_NO)                                    ; Get the file number for the message output.
            LD      C,A
            LD      B,0
            LD      A,(TZSVCRESULT)
            OR      A
            JR      Z, SAVESD4
            ;
            LD      DE,MSGSVFAIL                                         ; Fail, print out message.
            CALL    ?PRINTMSG                                             ; Print out the filename.
            LD      A,1
            JR      SAVESD5
SAVESD4:    LD      A,0                                                  ; Success.
SAVESD5:    LD      (RESULT),A
            RET

            ; Method to change the directory on the SD card where files are loaded and saved into. This involves getting a name
            ; and storing it in the service command structure for the I/O processor to use when searching for a file to read or saving a file.
            ; If the cache is in operation it is flushed and reloaded, any errors are reported and the user has to correct the error before issuing further
            ; SD commands.
            ;
            ; Inputs:
            ;     DE = Pointer into BUFER where the string commences. Skip whitespace and copy upto the end marker 0x0D.
            ;
CHGSDDIR:   LD      HL, TZSVC_DIRNAME                                    ; Location of directory name in the service record.
            LD      B,TZSVCDIRSZ-1                                       ; Ensure we dont overflow the buffer.
            CALL    GETSTRING
            ;
            LD      A,TZSVC_FTYPE_MZF                                    ; Setup to filter on MZF type files.
            LD      (TZSVC_FILE_TYPE),A 
            LD      A,TZSVC_CMD_CHANGEDIR                                ; Inform I/O processor that a directory change has taken place, allows it to cache the new dir.
            LD      (TZSVCCMD), A                                        ; Load up the command into the service record.
            CALL    SVC_CMD                                              ; And make communications wit the I/O processor, returning with the required record.
            OR      A
            JR      Z, CHGDIR1
            LD      A,255                                                ; Report I/O error as 255.
            RET
CHGDIR1:    LD      A,(TZSVCRESULT)
            OR      A
            JR      Z, CHGDIR2                                           ; No errors.
            ;
            LD      DE,MSGCDFAIL                                         ; Fail, print out message.
            CALL    ?PRINTMSG                                            ; Print out the filename.
            LD      A,1
            JR      CHGDIR3
CHGDIR2:    LD      A,0                                                  ; Success.
CHGDIR3:    LD      (RESULT),A
            OR      A
            RET

            ;-------------------------------------------------------------------------------
            ; START OF TAPE/SD CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Method to copy an application on a tape to an SD stored application. The tape drive is read and the first
            ; encountered program is loaded into memory at 0x1200. The CMT header is populated with the correct details (even if
            ; the load address isnt 0x1200, the CMT Header contains the correct value).
            ; A call is then made to write the application to the SD card.
            ; If the bulk method is called, we continue in a never ending loop, converting tape after tape.
            ;
TAPE2SDBULK:LD      A, 1                                                 ; Flag to indicate this is a bulk conversion.
            JR      TAPE2SD1
TAPE2SD:    XOR     A                                                    ; Flag to indicate this is a single conversion.
TAPE2SD1:   PUSH    AF                                                   ; Load from tape into memory, filling the tape CMT header and loading data into location 0x1200.
            CALL    LOADTAPECP                                           ; Call the Loadtape command, non execute version to get the tape contents into memory.
            LD      A,(RESULT)
            OR      A
            JR      NZ,TAPE2SDERR
            ; Save to SD Card.
            CALL    SAVESDCARDX
            LD      A,(RESULT)
            OR      A
            JR      NZ,TAPE2SDERR
            LD      DE,MSGT2SDOK
            CALL    ?PRINTMSG
            POP     AF
            OR      A
            JR      Z, TAPE2SDERR2
            JR      TAPE2SD1
TAPE2SDERR: LD      DE,MSGT2SDERR
            POP     AF
            CALL    ?PRINTMSG
TAPE2SDERR2:RET

            ; Method to copy an SD stored application to a Cassette tape in the CMT.
            ; The directory entry number or filename is passed to the command and the entry is located within the SD
            ; directory structure. The file is then loaded into memory and the CMT header populated. A call is then made
            ; to write out the data to tape.
            ;
SD2TAPE:    ; Load from SD, fill the CMT header then call CMT save.
            CALL    LOADSDCP
            LD      A,(RESULT)
            OR      A
            JR      NZ,SD2TAPEERR
            CALL    SAVECMT
            LD      A,(RESULT)
            OR      A
            JR      NZ,SD2TAPEERR
            RET
SD2TAPEERR: LD      DE,MSGSD2TERR
            JR      TAPE2SDERR2
            RET

            ;-------------------------------------------------------------------------------
            ; END OF TAPE/SD CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF FLOPPY DISK CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Method to check if the floppy interface ROM is present and if it is, jump to its entry point.
            ;
FDCK:       CALL    FDCKROM                                              ; Check to see if the Floppy ROM is present, exit if it isnt.
            CALL    Z,FDCROMADDR
            RET                               ; JP       CMDCMPEND
FDCKROM:    LD      A,(FDCROMADDR)
            OR      A
            RET

FLOPPY:     PUSH    DE                                                   ; Preserve pointer to input buffer.
            LD      DE,BPARA                                             ; Copy disk parameter block into RAM work area. (From)
            LD      HL,PRMBLK                                            ; (To)
            LD      BC,0000BH                                            ; 11 bytes of config data.
            LDIR                                                         ; BC=0, HL=F0E8, DE=1013
            POP     DE                                                   ; init 1001-1005, port $DC mit $00
            LD      A,(DE)                                               ; If not at the end of the line, then process as the boot disk number.
            CP      00Dh                                                 ; 
            JR      NZ,GETBOOTDSK                                        ; 
            CALL    DSKINIT                                              ; Initialise disk and flags.
L000F:      LD      DE,MSGBOOTDRV                                        ; 
            CALL    ?PRINTMSG
            LD      DE,BUFER                                             ; 
            CALL    GETL                                                 ; 
            LD      A,(DE)                                               ; 
            CP      01BH                                                 ; Check input value is in range 1-4.
            RET     Z                                                    ; 
            LD      HL,MSGLOADERR - MSGBOOTDRV - 2                       ; Address of input location after printing out prompt.
            ADD     HL,DE                                                ; 
            LD      A,(HL)                                               ; 
            CP      00DH                                                 ; 
            JR      Z,L003A                                              ; 
GETBOOTDSK: CALL    HEX                                                  ; Convert number to binary
            JR      C,L000F                                              ; If illegal, loop back and re-prompt.
            DEC     A                                                    ; 
            CP      004H                                                 ; Check in range, if not loop back.
            JR      NC,L000F                                             ; 
            LD      (BPARA),A                                            ; Store in parameter block.
L003A:      LD      IX,BPARA                                             ; Point to drive number.,
            CALL    DSKREAD                                              ; Read sector 1 of trk 0
            LD      HL,0CE00H                                            ; Now compare the first 7 bytes of what was read to see if this is a bootable disk.
            LD      DE,DSKID                                             ; 
            LD      B,007H                                               ; 
L0049:      LD      C,(HL)                                               ; 
            LD      A,(DE)                                               ; 
            CP      C                                                    ; 
            JP      NZ,L008C                                             ; If NZ then this is not a master disk, ie not bootable, so error exit with message.
            INC     HL                                                   ; 
            INC     DE                                                   ; 
            DJNZ    L0049                                                ; 
            LD      DE,MSGIPLLOAD                                        ; 
            CALL    ?PRINTMSG
            LD      DE,0CE07H                                            ; Program name stored at 8th byte in boot sector.
            CALL    ?PRTFN
            LD      HL,(0CE16H)                                          ; Get the load address
            LD      (IX+005H),L                                          ; And store in parameter block at 100D/100E
            LD      (IX+006H),H                                          ; 
            INC     HL
            DEC     HL
            JR      NZ, NOTCPM                                           ; If load address is 0 then where loading CPM.
    ;        LD      A,(MEMSW)                                            ; Page out ROM.
NOTCPM:     LD      HL,(0CE14H)                                          ; Get the size
            LD      (IX+003H),L                                          ; And store in parameter block at 100B/100C
            LD      (IX+004H),H                                          ; 
            LD      HL,(0CE1EH)                                          ; Get logical sector number
            LD      (IX+001H),L                                          ; And store in parameter block at 1009/100A
            LD      (IX+002H),H                                          ; 
            CALL    DSKREAD                                              ; Read the required data and store in memory.
            CALL    DSKINIT                                              ; Reset the disk ready for next operation.
            LD      HL,(0CE18H)                                          ; Get the execution address
            JP      (HL)                                                 ; And execute.

DSKLOADERR: LD      DE,MSGLOADERR                                        ; Loading error message
            JR      L008F                                                ; (+003h)

L008C:      LD      DE,MSGDSKNOTMST                                      ; This is not a boot/master disk message.
L008F:      CALL    ?PRINTMSG
            LD      DE,ERRTONE                                           ; Play error tone.
            CALL    MELDY
            JP      ST1X                                                 ; Stack may be a mess due to the way the original AFI was written.

L0104:      LD      A,(MOTON)                                            ; motor on flag
            RRCA                                                         ; motor off?
            CALL    NC,DSKMOTORON                                        ; yes, set motor on and wait
            LD      A,(IX+000H)                                          ;drive no
            OR      084H                                                 ;
            OUT     (0DCH),A                                             ; Motor on for drive 0-3
            XOR     A                                                    ;
            LD      (FDCCMD),A                                           ; clr latest FDC command byte
            LD      HL,00000H                                            ;
L0119:      DEC     HL                                                   ;
            LD      A,H                                                  ;
            OR      L                                                    ;
            JP      Z,DSKERR                                             ; Reset and print message that this is not a bootable disk.
            IN      A,(0D8H)                                             ; Status register.
            CPL                                                          ;
            RLCA                                                         ;
            JR      C,L0119                                              ; Wait on motor off (bit 7)
            LD      C,(IX+000H)                                          ; Drive number
            LD      HL,TRK0FD1                                           ; 1 track 0 flag for each drive
            LD      B,000H                                               ;
            ADD     HL,BC                                                ; Compute related flag 1002/1003/1004/1005
            BIT     0,(HL)                                               ;
            JR      NZ,L0137                                             ; 
            CALL    DSKSEEKTK0                                           ; Seek track 0.
            SET     0,(HL)                                               ; Set bit 0 of trk 0 flag
L0137:      RET     

            ; Turn disk motor on.
DSKMOTORON: LD      A,080H
            OUT     (0DCH),A                                             ; Motor on
            LD      B,010H                                               ; 
L013E:      CALL    L02C7                                                ; 
            DJNZ    L013E                                                ; Wait until becomes ready.
            LD      A,001H                                               ; Set motor on flag.
            LD      (MOTON),A                                            ; 
            RET     

L0149:      LD      A,01BH
            CALL    DSKCMD
            AND     099H
            RET     

            ; Initialise drive and reset flags, Set motor off
DSKINIT:    XOR     A                                                    
            OUT     (0DCH),A                                             ; Motor on/off
            LD      (TRK0FD1),A                                          ; Track 0 flag drive 1
            LD      (TRK0FD2),A                                          ; Track 0 flag drive 2
            LD      (TRK0FD3),A                                          ; Track 0 flag drive 3
            LD      (TRK0FD4),A                                          ; Track 0 flag drive 4
            LD      (MOTON),A                                            ; Motor on flag
            RET     

DSKSEEKTK0: LD      A,00BH                                               ; Restore command, seek track 0.
            CALL    DSKCMD                                               ; Send command to FDC.
            AND     085H                                                 ; Process result.
            XOR     004H   
            RET     Z      
            JP      DSKERR

DSKCMD:     LD      (FDCCMD),A                                           ; Store latest FDC command.
            CPL                                                          ; Compliment it (FDC bit value is reversed).
            OUT     (0D8H),A                                             ; Send command to FDC.
            CALL    L017E                                                ; Wait to become ready.
            IN      A,(0D8H)                                             ; Get status register.
            CPL                                                          ; Inverse (FDC is reverse bit logic).
            RET     

L017E:      PUSH    DE
            PUSH    HL
            CALL    L02C0
            LD      E,007H
L0185:      LD      HL,00000H
L0188:      DEC     HL
            LD      A,H
            OR      L
            JR      Z,L0196                                              ; (+009h)
            IN      A,(0D8H)
            CPL     
            RRCA    
            JR      C,L0188                                              ; (-00bh)
            POP     HL
            POP     DE
            RET     

L0196:      DEC     E
            JR      NZ,L0185                                             ; (-014h)
            JP      DSKERR

L019C:      PUSH    DE
            PUSH    HL
            CALL    L02C0
            LD      E,007H
L01A3:      LD      HL,00000H
L01A6:      DEC     HL
            LD      A,H
            OR      L
            JR      Z,L01B4                                              ; (+009h)
            IN      A,(0D8H)
            CPL     
            RRCA    
            JR      NC,L01A6                                             ; (-00bh)
            POP     HL
            POP     DE
            RET     

L01B4:      DEC     E
            JR      NZ,L01A3                                             ; (-014h)
            JP      DSKERR

            ; Read disk starting at the first logical sector in param block 1009/100A
            ; Continue reading for the given size 100B/100C and store in the location 
            ; Pointed to by the address stored in the parameter block. 100D/100E
DSKREAD:    CALL    L0220                                                ; Compute logical sector-no to track-no & sector-no, retries=10
L01BD:      CALL    L0229                                                ; Set current track & sector, get load address to HL
L01C0:      CALL    L0249                                                ; Set side reg
            CALL    L0149                                                ; Command 1b output (seek)
            JR      NZ,L0216                                             ; 
            CALL    L0259                                                ; Set track & sector reg
            PUSH    IX                                                   ; Save 1008H
            LD      IX, FDCJMPL                                          ; As below. L03FE
            LD      IY,L01DF                                             ; Read sector into memory.
            DI      
            LD      A,094H                                               ; Latest FDC command byte
            CALL    L028A
L01DB:      LD      B,000H
            JP      (IX)

            ; Get data from disk sector to staging area (CE00).
L01DF:      INI     
            LD      A,(DE)                                               ; If not at the end of the line, then process as the boot disk number.
            JP      NZ, FDCJMPL                                          ; This is crucial, as the Z80 is running at 2MHz it is not fast enough so needs
                                                                         ; hardware acceleration in the form of a banked ROM, if disk not ready jumps to IX, if
                                                                         ; data ready, jumps to IY. L03FE
            POP     IX
            INC     (IX+008H)                                            ; Increment current sector number
            LD      A,(IX+008H)                                          ; Load current sector number
            PUSH    IX                                                   ; Save 1008H
            LD      IX, FDCJMPL                                          ; As above. L03FE
            CP      011H                                                 ; Sector 17? Need to loop to next track.
            JR      Z,L01FB                 
            DEC     D
            JR      NZ,L01DB                
            JR      L01FC                                                ; (+001h)

L01FB:      DEC     D
L01FC:      CALL    L0294
            CALL    L02D2
            POP     IX
            IN      A,(0D8H)
            CPL     
            AND     0FFH
            JR      NZ,L0216                                             ; (+00bh)
            CALL    L0278
            JP      Z,L021B
            LD      A,(IX+007H)
            JR      L01C0                                                ; (-056h)

L0216:      CALL    L026A
            JR      L01BD                                                ; (-05eh)

L021B:      LD      A,080H
            OUT     (0DCH),A                                             ; Motor on
            RET     

L0220:      CALL    L02A3                                                ; compute logical sector no to track no & sector no
            LD      A,00AH                                               ; 10 retries
            LD      (RETRIES),A
            RET     

            ; Set current track & sector, get load address to HL
L0229:      CALL    L0104
            LD      D,(IX+004H)                                          ; Number of sectors to read
            LD      A,(IX+003H)                                          ; Bytes to read
            OR      A                                                    ; 0?
            JR      Z,L0236                                              ; Yes
            INC     D                                                    ; Number of sectors to read + 1
L0236:      LD      A,(IX+00AH)                                          ; Start sector number
            LD      (IX+008H),A                                          ; To current sector number
            LD      A,(IX+009H)                                          ; Start track number
            LD      (IX+007H),A                                          ; To current track number
            LD      L,(IX+005H)                                          ; Load address low byte
            LD      H,(IX+006H)                                          ; Load address high byte
            RET     

            ; Compute side/head.
L0249:      SRL     A                                                    ; Track number even?
            CPL                                                          ; 
            OUT     (0DBH),A                                             ; Output track no.
            JR      NC,L0254                                             ; Yes, even, set side/head 1
            LD      A,001H                                               ; No, odd, set side/head 0
            JR      L0255                   

            ; Set side/head register.
L0254:      XOR     A                                                    ; Side 0
L0255:      CPL                                                          ; Side 1
            OUT     (0DDH),A                                             ; Side/head register.
            RET     

            ; Set track and sector register.
L0259:      LD      C,0DBH                  
            LD      A,(IX+007H)                                          ; Current track number
            SRL     A                       
            CPL                             
            OUT     (0D9H),A                                             ; Track reg
            LD      A,(IX+008H)                                          ; Current sector number
            CPL                            
            OUT     (0DAH),A                                             ; Sector reg
            RET                      

L026A:      LD      A,(RETRIES)
            DEC     A
            LD      (RETRIES),A
            JP      Z,DSKERR
            CALL    DSKSEEKTK0
            RET     

L0278:      LD      A,(IX+008H)
            CP      011H
            JR      NZ,L0287                                             ; (+008h)
            LD      A,001H
            LD      (IX+008H),A
            INC     (IX+007H)
L0287:      LD      A,D
            OR      A
            RET     

L028A:      LD      (FDCCMD),A
            CPL     
            OUT     (0D8H),A
            CALL    L019C
            RET     

L0294:      LD      A,0D8H
            CPL     
            OUT     (0D8H),A
            CALL    L017E
            RET     

DSKERR:     CALL    DSKINIT
            JP      DSKLOADERR

            ; Logical sector number to physical track and sector.
L02A3:      LD      B,000H
            LD      DE,00010H                                            ; No of sectors per trk (16)
            LD      L,(IX+001H)                                          ; Logical sector number
            LD      H,(IX+002H)                                          ; 2 bytes in length
            XOR     A
L02AF:      SBC     HL,DE                                                ; Subtract 16 sectors/trk 
            JR      C,L02B6                                              ; Yes, negative value
            INC     B                                                    ; Count track
            JR      L02AF                                                ; Loop
L02B6:      ADD     HL,DE                                                ; Reset HL to the previous
            LD      H,B                                                  ; Track
            INC     L                                                    ; Correction +1
            LD      (IX+009H),H                                          ; Start track no
            LD      (IX+00AH),L                                          ; Start sector no
            RET     

L02C0:      PUSH    DE
            LD      DE,00007H
            JP      L02CB

L02C7:      PUSH    DE
            LD      DE,01013H
L02CB:      DEC     DE
            LD      A,E
            OR      D
            JR      NZ,L02CB                                             ; (-005h)
            POP     DE
            RET     

L02D2:      PUSH    AF
            LD      A,(0119CH)
            CP      0F0H
            JR      NZ,L02DB                                             ; (+001h)
            EI      
L02DB:      POP     AF
            RET     

;wait on bit 0 and bit 1 = 0 of state reg
L0300:      IN      A,(0D8H)	                                 	     ; State reg
            RRCA    
            JR      C,L0300	                                             ; Wait on not busy
            RRCA    
            JR      C,L0300	                                             ; Wait on data reg ready
            JP      (IY)	                                             ; to f1df

            ;-------------------------------------------------------------------------------
            ; END OF FLOPPY DISK CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF UTILITIES
            ;-------------------------------------------------------------------------------

            ; Method to get a string parameter and copy it into the provided buffer.
            ;
            ; Inputs:
            ;     DE = Pointer to BUFER where user entered data has been placed.
            ;     HL = Pointer to Destination buffer.
            ;     B  = Max number of characters to read.
            ; Outputs:
            ;     DE and HL point to end of bufer and buffer resepectively.
            ;     B  = Characters copied (ie. B - input B = no characters).
            ;
GETSTRING:  LD      A,(DE)                                               ; Skip white space before copy.
            CP      ' '
            JR      NC, GETSTR1
            CP      00DH
            JR      GETSTR2                                              ; No directory means use the I/O set default.
            INC     DE
            JR      GETSTRING
GETSTR1:    LD      (HL),A                                               ; Copy the name entered by user. Validation is done on the I/O processor, bad directory name will result in error next read/write.
            INC     DE
            INC     HL
            LD      A,(DE)                                               ; Get next char and check it isnt CR, end of input line character.
            CP      00DH
            JR      Z,GETSTR2                                            ; Finished if we encounter CR.
            DJNZ    GETSTR1                                              ; Loop until buffer is full, ignore characters beyond buffer limit.
GETSTR2:    XOR     A                                                    ; Place end of buffer terminator as I/O processor uses C strings.
            LD      (HL),A
            RET

            ;-------------------------------------------------------------------------------
            ; END OF UTILITIES
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; API METHODS - Intercept handlers to provide enhanced services to 
            ;               existing MA-700 BIOS API functions.
            ;-------------------------------------------------------------------------------

            ; Method to check if the active drive is the CMT.
CHECKCMT:   LD      A,(CMTINACTIVE)                                      ; Test the flag to see if the default is to use the CMT for the CMT/SD intercept handlers.
            OR      A                                                    ; Flag set to > 0 if the CMT is not active.
            RET

            ; Convert the lower 4 bits of A into a Hex character.
TOHEXDIGIT: AND     00FH                                                 ; Simple logic, add 30H to get 0..9, add additional 7 if value >= 10 to get digits A..F.
            CP      00AH
            JR      C,NOADD                 
            ADD     A,007H
NOADD:      ADD     A,030H
            RET    

            ; Convert a number into Hex string and store in buffer pointed to by DE.
            ;
TOHEX:      PUSH    DE
            PUSH    AF                                                   ; Save AF to retrieve lower 4 bits.
            RRCA                                                         ; Shift upper 4 bits to lower to convert to hex.
            RRCA    
            RRCA    
            RRCA    
            CALL    TOHEXDIGIT
            LD      (DE),A                                               ; Store and convert lower 4 bits.
            INC     DE
            POP     AF
            CALL    TOHEXDIGIT
            LD      (DE),A
            INC     DE
            LD      A,CR                                                 ; Terminate with a CR.
            LD      (DE),A
            POP     DE                                                   ; DE back to start of string.
            RET

            ; Handler to intercept the CMT Read Header Information call.
            ; DE contains a pointer to memory containing the file to load. If (DE) = NULL then
            ; load the next sequential file from the SD card directory.
            ; DE = Filename.
            ;
            ; No registers or flags should be affected as we dont know the caller state.
_CMT_RDINF: CALL    CHECKCMT                                             ; If drive is set to the CMT Unit exit with Z set so that the original CMT handlers are called.
            JP      Z,?RDI
            LD      A,(DE)                                               ; Check to see if empty string given, if so expand the default Next file number into the buffer.
            CP      CR
            JR      NZ,_CMT_RDINF1
            LD      A,(CMTFILENO)                                        ; Get next sequential number and convert to hex.
            PUSH    AF
            CALL    TOHEX                         
            POP     AF
            INC     A                                                    ; Increment number so next call retrieves the next sequential file.
            LD      (CMTFILENO),A
            ;
_CMT_RDINF1:PUSH    DE
            CALL    LOADSDINF                                            ; DE already points to the filename, call LOADSDINF to locate it on the SD card and setup the header.
            POP     DE
            OR      A
            SCF
            RET     NZ                                                   ; > 0 = fail, return with carry set.

            ; Copy the filename into the Buffer provided allowing for file number to name expansion.
            LD      HL,NAME
            LD      BC,TZSVCFILESZ
            LDIR
            ;
            OR      A
            RET                                                          ; 0 = success, return with carry clear.

            ; Handler to intercept the CMT Read Data call and insert selectable SD Card
            ; Drive functionality. 
            ;
            ; No registers or flags should be affected as we dont know the caller state.
_CMT_RDDATA:CALL    LOADSDDATA
            OR      A
            JR      NZ,_CMT_RDERR
            RET
_CMT_RDERR: SCF
            RET

            ; Handler to intercept the CMT Write Header Information call and insert selectable
            ; SD Card RFS Drive functionality. 
            ;
            ; No registers or flags should be affected as we dont know the caller state.
            ;
            ; At the moment, the WRINF call only creates a filename if none specified. The actual write to file occurs in WRDATA. Once I have more understanding of
            ; how the sequential data mode works I can adapt it to be compatible.
_CMT_WRINF: LD      DE,NAME                                              ; Caller has already setup the CMT header so we use this for processing.
            ;
            CALL    CHECKCMT
            JP      Z,?WRI
            ;
            LD      A,(DE)                                               ; Check to see if empty string given, if so create a default name.
            CP      CR
            JR      NZ,_CMT_WRINF1
            ;
            LD      HL,DEFAULTFN
            LD      BC,DEFAULTFNE - DEFAULTFN
            LDIR
            LD      A,(CMTFILENO)                                        ; Get next sequential number and convert to hex.
            PUSH    AF
            CALL    TOHEX                         
            POP     AF
            INC     A                                                    ; Increment number so next call retrieves the next sequential file.
            LD      (CMTFILENO),A
            ;
_CMT_WRINF1:LD      A,0                                                  ; Always success as nothing is written.
            OR      A
            RET

            ; Handler to intercept the CMT Write Data call and insert selectable SD Card RFS
            ; Drive functionality. 
            ;
            ; No registers or flags should be affected as we dont know the caller state.
_CMT_WRDATA:CALL    SAVESDDATA
            LD      A,(RESULT)
            OR      A
            JR      NZ,_CMT_RDERR
            RET

            ; Handler to intercept the CMT Verify Data call and insert selectable SD Card
            ; Drive functionality. 
            ;
            ; No registers or flags should be affected as we dont know the caller state.
_CMT_VERIFY:CALL    CHECKCMT
            JR      Z,_VERIFY
            LD      DE,MSGNOVERIFY
            JR      SD_ERRMSG

_VERIFY:    JP      ?VRFY

SD_NOTFND:  LD      DE,MSGNOTFND
SD_ERRMSG:  CALL    ?PRINTMSG
            LD      A,1
            OR      A
            RET

            ; Method list the active directory contents.
_CMT_DIR:   CALL    CHECKCMT                                             ; Cannot DIR tape drive so give error.
            JP      Z,_CMT_NODIR
            CALL    DIRSDCARD                                            ; List the directory contents with optional directory/wildcard filter.
            RET
_CMT_NODIR: LD      DE,MSGNOCMTDIR
            JR      SD_ERRMSG

            ; Method to set the active directory or CMT unit/SD card. ie. \BAS to change to directory \BAS on the SD card, C to switch to CMT unit.
_CMT_CD:    LD      A,(DE)
            CP      'C'                                                  ; Check to see if we are enabling the CMT unit.
            JR      NZ,_CMT_CD2
            XOR     A                                                    ; CMT is now active so clear the inactive flag.
_CMT_CD1:   LD      (CMTINACTIVE),A
            RET
_CMT_CD2:   CALL    CHGSDDIR                                             ; Change directory, if not valid do not update the CMTINACTIVE flag.
            RET     NZ
            LD      A,1
            JR      _CMT_CD1

            ;-------------------------------------------------------------------------------
            ; END OF API METHODS
            ;-------------------------------------------------------------------------------

            ; A method used when testing hardware, scope and code will change but one of its purposes is to generate a scope signal pattern.
            ;
LOCALTEST:  LD      A,0
            LD      C,SVCREQ
            OUT     (C),A
            RET

            ; Quick load program names.
CPMFILENAME:DB      "CPM223 MZ-700-80", 000H
BASICFILENM:DB      "S-BASIC", 000H
DEFAULTFN:  DB      "DEFAULT"
DEFAULTFNE: EQU     $

            ; Error tone.
ERRTONE:    DB      "A0", 0D7H, "ARA", 0D7H, "AR", 00DH

            ; Identifier to indicate this is a valid boot disk
DSKID:      DB      002H, "IPLPRO"

            ; Parameter block to indicate configuration and load area.
PRMBLK:     DB      000H, 000H, 000H, 000H, 001H, 000H, 0CEH, 000H, 000H, 000H, 000H

            ; Monitor command table. This table contains the list of recognised commands along with the 
            ; handler function and bank in which it is located.
            ;
            ;         7     6     5:3    2:0
            ;        END  MATCH  UNUSED  SIZE 
CMDTABLE:   DB      000H | 000H | 000H | 003H
            DB      "40A"                                                ; Switch to the 40char Sharp MZ-80A compatbile mode.
            DW      SETMODE40A
            DB      000H | 000H | 000H | 003H
            DB      "80A"                                                ; Switch to the 80char Sharp MZ-80A compatbile mode.
            DW      SETMODE80A
            DB      000H | 000H | 000H | 003H
            DB      "80B"                                                ; Switch to the Sharp MZ-80B compatbile mode.
            DW      SETMODE80B
            DB      000H | 000H | 000H | 001H                            ; Bit 2:0 = Command Size, 5:3 = Bank, 6 = Command match, 7 = Command table end.
            DB      '4'                                                  ; 40 Char screen mode.
            DW      SETMODE40
            DB      000H | 000H | 000H | 001H
            DB      '8'                                                  ; 80 Char screen mode.
            DW      SETMODE80
            DB      000H | 000H | 000H | 004H
            DB      "7008"                                               ; Switch to 80 column MZ700 mode.
            DW      SETMODE7008
            DB      000H | 000H | 000H | 003H
            DB      "700"                                                ; Switch to 40 column MZ700 mode.
            DW      SETMODE700
            DB      000H | 000H | 000H | 005H
            DB      "BASIC"                                              ; Load and run BASIC SA-5510.
            DW      LOADBASIC
            DB      000H | 000H | 000H | 001H
            DB      'B'                                                  ; Bell.
            DW      SGX
            DB      000H | 000H | 000H | 003H
            DB      "CPM"                                                ; Load and run CPM.
            DW      LOADCPM
            DB      000H | 000H | 000H | 002H
            DB      "CD"                                                 ; SD Card Directory change command.
            DW      CHGSDDIR
            DB      000H | 000H | 000H | 001H
            DB      'C'                                                  ; Clear Memory.
            DW      ?INITMEMX
            DB      000H | 000H | 000H | 003H
            DB      "DIR"                                                ; List SD Card directory.
            DW      DIRSDCARD
            DB      000H | 000H | 000H | 001H
            DB      'D'                                                  ; Dump Memory.
            DW      ?DUMPX
            DB      000H | 000H | 000H | 002H
            DB      "EC"                                                 ; Erase file.
            DW      ERASESD
            DB      000H | 000H | 000H | 002H
            DB      "EX"                                                 ; Exit out of TZFS to original Monitor.
            DW      EXITTZFS 
            DB      000H | 000H | 000H | 004H
            DB      "FREQ"                                               ; Set or change the CPU frequency.
            DW      ?SETFREQ
            DB      000H | 000H | 000H | 001H
            DB      'F'                                                  ; RFS Floppy boot code.
            DW      FLOPPY
            DB      000H | 000H | 000H | 001H
            DB      'H'                                                  ; Help screen.
            DW      ?HELP
            DB      000H | 000H | 000H | 001H
            DB      'J'                                                  ; Jump to address.
            DW      GOTOX
            DB      000H | 000H | 000H | 004H
            DB      "LTNX"                                               ; Load from CMT without auto execution.
            DW      LOADTAPENX
            DB      000H | 000H | 000H | 002H
            DB      "LT"                                                 ; Load from CMT
            DW      LOADTAPE
            DB      000H | 000H | 000H | 004H
            DB      "LCNX"                                               ; Load from SDCARD without auto execution.
            DW      LOADSDCARDX
            DB      000H | 000H | 000H | 002H
            DB      "LC"                                                 ; Load from SD CARD
            DW      LOADSDCARD
            DB      000H | 000H | 000H | 001H
            DB      "L"                                                  ; Original Load from CMT
            DW      LOADTAPE
            DB      000H | 000H | 000H | 001H
            DB      'M'                                                  ; Edit Memory.
            DW      ?MCORX
            DB      000H | 000H | 000H | 001H
            DB      'P'                                                  ; Printer test.
            DW      ?PTESTX
            DB      000H | 000H | 000H | 001H
            DB      'R'                                                  ; Memory test.
            DW      MEMTEST
            DB      000H | 000H | 000H | 004H
            DB      "SD2T"                                               ; Copy SD Card to Tape.
            DW      SD2TAPE
            DB      000H | 000H | 000H | 002H
            DB      "SC"                                                 ; Save to SD CARD
            DW      SAVESDCARD
            DB      000H | 000H | 000H | 002H
            DB      "ST"                                                 ; Save to CMT
            DW      SAVEX
            DB      000H | 000H | 000H | 001H
            DB      'S'                                                  ; Save to CMT
            DW      SAVEX
            DB      000H | 000H | 000H | 004H
            DB      "TEST"                                               ; A test function used in debugging.
            DW      LOCALTEST
            DB      000H | 000H | 000H | 005H
            DB      "T2SDB"                                              ; Copy Tape to SD Card in bulk mode.
            DW      TAPE2SDBULK
            DB      000H | 000H | 000H | 004H
            DB      "T2SD"                                               ; Copy Tape to SD Card.
            DW      TAPE2SD
            DB      000H | 000H | 000H | 003H
            DB      "T80"                                                ; Switch to soft T80 CPU.
            DW      ?SETT80
            DB      000H | 000H | 000H | 001H
            DB      'T'                                                  ; Timer test.
            DW      ?TIMERTST
            DB      000H | 000H | 000H | 007H
            DB      "VBORDER"                                            ; Set VGA border colour.
            DW      ?SETVBORDER
            DB      000H | 000H | 000H | 005H
            DB      "VMODE"                                              ; Set VGA mode.
            DW      ?SETVMODE
            DB      000H | 000H | 000H | 003H
            DB      "VGA"                                                ; Set VGA mode.
            DW      ?SETVGAMODE
            DB      000H | 000H | 000H | 001H
            DB      'V'                                                  ; Verify CMT Save.
            DW      VRFYX
            DB      000H | 000H | 000H | 003H
            DB      "Z80"                                                ; Switch to soft Z80 CPU.
            DW      ?SETZ80
            DB      000H | 000H | 000H | 003H
            DB      "ZPU"                                                ; Switch to soft ZPU Evolution CPU.
            DW      ?SETZPUEVO
            DB      000H | 000H | 000H | 001H



            ;-------------------------------------------------------------------------------
            ; END OF TZFS COMMAND FUNCTIONS.
            ;-------------------------------------------------------------------------------

            ;
            ; Ensure we fill the entire 6K by padding with FF's.
            ;
            ALIGN_NOPS      10000H
MEND: 

            ;
            ; Include all other banks which make up the TZFS system.
            ;
            INCLUDE  "tzfs_bank2.asm"
            INCLUDE  "tzfs_bank3.asm"
            INCLUDE  "tzfs_bank4.asm"
