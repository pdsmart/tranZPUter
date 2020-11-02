;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbiosII.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This assembly language program is written to utilise the paged RAM memory modes of 
;-                  the tranZPUter hardware running on the Sharp MZ80A computer. The purpose is to 
;-                  provide more TPA to CP/M by hiding the support logic in a RAM bank outside of the
;-                  64K address space of CPM. The basics have to exist within the 64K for CP/M to 
;-                  function correctly, ie. disk buffers, stack and jump tables but the remainder
;-                  are placed in a different bank which has 48K available RAM just for CBIOS.
;-
;- Credits:         
;- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Jan 2020 - Seperated Bank from RFS for dedicated use with CPM CBIOS.
;                   May 2020 - Advent of the new RFS PCB v2.0, quite a few changes to accommodate the
;                              additional and different hardware. The SPI is now onboard the PCB and
;                              not using the printer interface card.
;                   May 2020 - Cut taken from the MZ80A RFS version of CPM CBIOS to create a version of
;                              CPM suitable to run on the tranZPUter. The memory models are different
;                              providing more memory at different locations for use by CPM.
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

            ;======================================
            ;
            ; RAM BANK - CPM CBIOS II
            ;
            ;======================================
            ORG     00000H

            ; In order to preserve the interrupt vectors when CPM mode 7 is enabled (ie. this
            ; bank is paged in), the area from 0x0000:0x003F maps to the memory block in mode 6
            ; so this is unuseable space in this bank. In addition, CPM uses 0x0000:0x0100
            ; for many vectors and buffers so this memory is also mapped to the memory block in 
            ; mode 6.
            ;------------ 0x0000 -----------------------------------------------------------
            PAD     00040H
            ;------------ 0x0040 -----------------------------------------------------------            
            PAD     00100H
            ;------------ 0x0100 -----------------------------------------------------------            

LVARSTART   EQU     $                                                    ; Start of local page variables.
SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:       DS      1                                                    ; ATTRIBUTE
NAME:       DS      17                                                   ; FILE NAME
SIZE:       DS      2                                                    ; BYTESIZE
DTADR:      DS      2                                                    ; DATA ADDRESS
EXADR:      DS      2                                                    ; EXECUTION ADDRESS
COMNT:      DS      92                                                   ; Comment / code area of CMT header.
SWPW:       DS      10                                                   ; SWEEP WORK
KDATW:      DS      2                                                    ; KEY WORK
KANAF:      DS      1                                                    ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:      DS      2                                                    ; DISPLAY COORDINATES
MANG:       DS      6                                                    ; COLUMN MANAGEMENT
MANGE:      DS      1                                                    ; COLUMN MANAGEMENT END
PBIAS:      DS      1                                                    ; PAGE BIAS
ROLTOP:     DS      1                                                    ; ROLL TOP BIAS
MGPNT:      DS      1                                                    ; COLUMN MANAG. POINTER
PAGETP:     DS      2                                                    ; PAGE TOP
ROLEND:     DS      1                                                    ; ROLL END
            DS      14                                                   ; BIAS
FLASH:      DS      1                                                    ; FLASHING DATA
SFTLK:      DS      1                                                    ; SHIFT LOCK
REVFLG:     DS      1                                                    ; REVERSE FLAG
FLSDT:      DS      1                                                    ; CURSOR DATA
STRGF:      DS      1                                                    ; STRING FLAG
DPRNT:      DS      1                                                    ; TAB COUNTER
SWRK:       DS      1                                                    ; KEY SOUND FLAG
TEMPW:      DS      1                                                    ; TEMPO WORK
ONTYO:      DS      1                                                    ; ONTYO WORK
OCTV:       DS      1                                                    ; OCTAVE WORK
RATIO:      DS      2                                                    ; ONPU RATIO
DSPXYADDR:  DS      2                                                    ; Address of last known position.

DRVAVAIL    DS      1                                                    ; Flag to indicate which drive controllers are available. Bit 2 = SD, Bit 1 = ROM, Bit 0 = FDC
MOTON       DS      1                                                    ; MOTOR ON = 1, OFF = 0
TMPADR      DS      2                                                    ; TEMPORARY ADDRESS STORAGE
TMPSIZE     DS      2                                                    ; TEMPORARY SIZE
TMPCNT      DS      2                                                    ; TEMPORARY COUNTER
;
FLASHCTL:   DS      1                                                    ; CURSOR FLASH CONTROL. BIT 0 = Cursor On/Off, BIT 1 = Cursor displayed.
TIMESEC:    DS      6                                                    ; RTC 48bit TIME IN MILLISECONDS
NDISKS:     DS      1                                                    ; Dynamically calculated number of disks on boot.
DISKTYPE:   DS      1                                                    ; Disk type of current selection.
MTROFFTIMER:DS      1                                                    ; Second down counter for FDC motor off.
;
SEKDSK:     DS      1                                                    ; Seek disk number
SEKTRK:     DS      2                                                    ; Seek disk track
SEKSEC:     DS      1                                                    ; Seek sector number
SEKHST:     DS      1                                                    ; Seek sector host
;
HSTACT:     DS      1                                                    ; 
;
UNACNT:     DS      1                                                    ; Unalloc rec cnt
UNADSK:     DS      1                                                    ; Last unalloc disk
UNATRK:     DS      2                                                    ; Last unalloc track
UNASEC:     DS      1                                                    ; Last unalloc sector
;
READOP:     DS      1                                                    ; If read operation then 1, else 0 for write.
RSFLAG:     DS      1                                                    ; Read sector flag.
WRTYPE:     DS      1                                                    ; Write operation type.
DMAADDR:    DS      2                                                    ; Last DMA address

FDCCMD      DS      1                                                    ; LAST FDC COMMAND SENT TO CONTROLLER.
INVFDCDATA: DS      1                                                    ; INVERT DATA COMING FROM FDC, 1 = INVERT, 0 = AS IS
TRK0FD1     DS      1                                                    ; FD 1 IS AT TRACK 0 = BIT 0 set 
TRK0FD2     DS      1                                                    ; FD 2 IS AT TRACK 0 = BIT 0 set
TRK0FD3     DS      1                                                    ; FD 3 IS AT TRACK 0 = BIT 0 set
TRK0FD4     DS      1                                                    ; FD 4 IS AT TRACK 0 = BIT 0 set
RETRIES     DS      2                                                    ; DATA READ RETRIES
DISKMAP:    DS      MAXDISKS                                             ; Disk map of CPM logical to physical controller disk.
FDCDISK:    DS      1                                                    ; Physical disk number.
SECPERTRK:  DS      1                                                    ; Sectors per track for 1 head.
SECPERHEAD: DS      1                                                    ; Sectors per head.
SECTORCNT:  DS      1                                                    ; Sector size as a count of how many sectors make 512 bytes.
HSTDSK:     DS      1                                                    ; Host disk number
HSTTRK:     DS      2                                                    ; Host track number
HSTSEC:     DS      1                                                    ; Host sector number
HSTWRT:     DS      1                                                    ; Host write flag
ERFLAG:     DS      1                                                    ; Error number, 0 = no error.
TRACKNO:    DS      2                                                    ; Host controller track number
SECTORNO:   DS      1                                                    ; Host controller sector number

CURSORPSAV  DS      2                                                    ; Cursor save position;default 0,0
HAVELOADED  DS      1                                                    ; To show that a value has been put in for Ansi emualtor.
ANSIFIRST   DS      1                                                    ; Holds first character of Ansi sequence
NUMBERBUF   DS      20                                                   ; Buffer for numbers in Ansi
NUMBERPOS   DS      2                                                    ; Address within buffer
CHARACTERNO DS      1                                                    ; Byte within Ansi sequence. 0=first,255=other
CURSORCOUNT DS      1                                                    ; 1/50ths of a second since last change
FONTSET     DS      1                                                    ; Ansi font setup.
JSW_FF      DS      1                                                    ; Byte value to turn on/off FF routine
JSW_LF      DS      1                                                    ; Byte value to turn on/off LF routine
CHARACTER   DS      1                                                    ; To buffer character to be printed.    
CURSORPOS   DS      2                                                    ; Cursor position, default 0,0.
BOLDMODE    DS      1
HIBRITEMODE DS      1                                                    ; 0 means on, &C9 means off
UNDERSCMODE DS      1
ITALICMODE  DS      1
INVMODE     DS      1
CHGCURSMODE DS      1
ANSIMODE    DS      1                                                    ; 1 = on, 0 = off
COLOUR      EQU     0

LVAREND     EQU     $                                                    ; End of local page variables

            IF $ > 0300H
                ERROR "Keybuf var not aligned, addr=%s, required=%s"; % $, 0300H
            ENDIF
            ALIGN_NOPS 0300H
KEYBUF:     DS      KEYBUFSIZE, 0DH                                      ; Interrupt driven keyboard buffer.
KEYCOUNT:   DS      1, 000H
KEYWRITE:   DS      2, 000H                                              ; Pointer into the buffer where the next character should be placed.
KEYREAD:    DS      2, 000H                                              ; Pointer into the buffer where the next character can be read.
KEYLAST:    DS      1, 000H                                              ; KEY LAST VALUE
KEYRPT:     DS      1, 000H                                              ; KEY REPEAT COUNTER

            DS      64, 0FFH                                             ; Stack space for cold and warm boot.
BOOTSTACK   EQU     $
            ;

            ; Start of CPM entry points.
            ;
            IF $ > 0400H
                ERROR "Stack var not aligned, addr=%s, required=%s"; % $, 0400H
            ENDIF
            ALIGN_NOPS 0400H

            ;-------------------------------------------------------------------------------
            ;  BOOT                                                                        
            ;                                                                              
            ;  The BOOT entry point gets control from the cold start loader and is         
            ;  responsible for basic system initialization, including sending a sign-on    
            ;  message, which can be omitted in the first version.                         
            ;  If the IOBYTE function is implemented, it must be set at this point.        
            ;  The various system parameters that are set by the WBOOT entry point must be 
            ;  initialized, and control is transferred to the CCP at 3400 + b for further  
            ;  processing. Note that register C must be set to zero to select drive A.     
            ;
            ; NB. This code is executed by the MZF loader. The following code is assembled
            ; in the header at $1108 to ensure correct startup.
            ; BOOTSTG1:   LD      A,TZMM_CPM2   ; Switch to CPM memory mode 2
            ;             OUT     (MMCFG), A
            ;             JP      QBOOT_        ; Execute cold boot.
            ; REBOOT:     LD      A,TZMM_TZFS   ; Switch to TZFS memory mode.
            ;             OUT     (MMCFG),A
            ;             JP      MROMADDR      ; Now restart in the SA1510 monitor.
            ;-------------------------------------------------------------------------------
QBOOT_:     DI                                                           ; Disable Interrupts and sat mode. NB. Interrupts are physically disabled by 8255 Port C2 set to low.
            IM      1
            ;
            LD      SP,BOOTSTACK                                         ; Setup to use local stack until CPM takes over.
            ;
            LD      HL,0066H                                             ; Set NMI so it doesnt bother us.
            LD      (HL), 0EDH                                           ; Set to RETN instruction.
            INC     HL
            LD      (HL), 045H
            ;
            LD      HL,GVARSTART                                         ; Start of global variable area
            LD      BC,GVAREND-GVARSTART                                 ; Size of global variable area.
            XOR     A
            LD      D,A
INIT1:      LD      (HL),D                                               ; Clear variable memory including stack space.
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,INIT1
            ;
            LD      HL,LVARSTART                                         ; Start of local page variable area
            LD      BC,LVAREND-LVARSTART                                 ; Size of local page variable area.
            XOR     A
            LD      D,A
INIT2:      LD      (HL),D                                               ; Clear variable memory.
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,INIT2
            ;
            CALL    MODE                                                 ; Configure 8255 port C, set Motor Off, VGATE to 1 (off) and INTMSK to 0 (interrupts disabled).
            LD      A,004H
            LD      (TEMPW),A                                            ; Setup the tempo for sound output.

INIT3:      ; Setup keyboard buffer control.
            LD      A,0
            LD      (KEYCOUNT),A                                         ; Set keyboard buffer to empty.
            LD      HL,KEYBUF
            LD      (KEYWRITE),HL                                        ; Set write pointer to beginning of keyboard buffer.
            LD      (KEYREAD),HL                                         ; Set read pointer to beginning of keyboard buffer.

            ; Setup keyboard rate control and set to CAPSLOCK mode.
            ; (0 = Off, 1 = CAPSLOCK, 2 = SHIFTLOCK).
            LD      A,000H                                               ; Initialise key repeater.
            LD      (KEYRPT),A
            LD      A,001H
            LD      (SFTLK),A                                            ; Setup shift lock, default = off.

            ; Setup the initial cursor, for CAPSLOCK this is a double underscore.
            LD      A,03EH
            LD      (FLSDT),A
            LD      A,080H                                               ; Cursor on (Bit D7=1).
            LD      (FLASHCTL),A

INIT80CHAR: IF BUILD_VIDEOMODULE = 1
            IN      A, (CPLDINFO)                                        ; Get hardware information.
            BIT     3,A
            JR      Z, INIT40CHAR                                        ; If no video module present then need to use 40 char mode.
            AND     007H
            LD      D, A
            OR      MODE_VIDEO_FPGA                                      ; Ensure the video hardware is enabled.
            OUT     (CPLDCFG),A
            LD      A, D
            OR      MODE_80CHAR                                          ; Enable 80 char display.
            LD      C, A
            IN      A, (VMCTRL)                                          ; Get current graphics mode and vga mode.
            AND     0C0H                                                 ; Mask out all but VGA mode.
            OR      C                                                    ; Add in new hardware/80char mode.
            OUT     (VMCTRL),A                                           ; Activate.
            LD      A, D
            CP      MODE_MZ80A                                           ; Check to see if this is the MZ80A, if so, change BUS speed.
            JR      NZ, INIT80END
          ; LD      A, SYSMODE_MZ80B                                     ; Set bus and default CPU speed to 4MHz
          ; OUT     (SYSCTRL),A                                          ; Activate.            
            JR      INIT80END
INIT40CHAR:                                                              ; Currently nothing to do!
            ELSE
            ; Change to 80 character mode on the 40/80 Char Colour board v1.0.
            LD      A, 128                                               ; 80 char mode.
            LD      (DSPCTL), A
            ENDIF
            ;
INIT80END:  LD      A,016H
            CALL    PRNT
            LD      A,071H                                               ; Blue background, white characters in colour mode. Bit 7 is set as a write to bit 7 @ DFFFH selects 80Char mode.
            LD      HL,ARAM
            CALL    CLR8
            CALL    MLDSP
            CALL    NL
            LD      DE,CBIOSSIGNON                                       ; Start of sign on message, as devices are detected they are added to the sign on.
            CALL    MONPRTSTR
            CALL    BEL                                                  ; Beep to indicate startup - for cases where screen is slow to startup.
            LD      A,0FFH
            LD      (SWRK),A

            LD      HL,NUMBERBUF
            LD      (NUMBERPOS),HL
            ;
            XOR     A
            LD      (IOBYT),A
            LD      (CDISK),A            

            ;
            ; Initialise the disk subsystem.
            ;
            LD      A,0                                                  ; No drives yet detected so zero available mask.
            SET     2,A                                                  ; The SD Card is always present on the I/O processor, we cant run without it..
            ;
            PUSH    AF                                                   ; Output indicator that SDC drives are available.
            LD      DE,SDAVAIL
            CALL    MONPRTSTR
            POP     AF
            SET     7,A
            LD      (DRVAVAIL),A
            ;
            CALL    DSKINIT                                              ; Initialise the floppy disk subsystem.
            JR      NZ,STRT5
            LD      A,(DRVAVAIL)
            SET     0,A                                                  ; Indicate Floppy drives are available.

            PUSH    AF                                                   ; Output indicator that FDC drives are available.
            BIT     7,A
            JR      Z,STRT4 
            LD      A,','
            CALL    PRNT
STRT4:      LD      DE,FDCAVAIL
            CALL    MONPRTSTR
            POP     AF
            SET     7,A
            LD      (DRVAVAIL),A
            ;
STRT5:      LD      DE,CBIOSIGNEND                                       ; Terminate the signon message which now includes list of drives detected.
            CALL    MONPRTSTR
            CALL    NL
            ;
            ; Setup the disk parameter blocks according
            ; to connected drives and available memory.
            ;
            LD      DE,DPBASE                                            ; Base of parameter block.
            LD      A,0                                                  ; Using scratch area, setup the disk count, pointer to ALV memory and pointer to CSV memory.
            LD      (CDIRBUF),A
            LD      HL,CSVALVMEM
            LD      (CDIRBUF+1),HL
            ;
            ; 16MB SD Card Drives.
            ;
            LD      BC,0                                                 ; Setup CSV/ALV parameters for a 16MB SD Card drive.
            LD      (CDIRBUF+3),BC
            LD      BC,257    ; 2048/8 + 1
            LD      (CDIRBUF+5),BC
            LD      BC,DPB4
            LD      (CDIRBUF+7),BC                                       ; Address of Disk Parameters
STRT7:      LD      A,(CDIRBUF)
            CP      MAXDISKS - 2                                         ; Make sure we have parameter table entries available to add further drives, ensuring slots for the FDC.
            JR      Z,STRT8
            ;
            LD      (TZSVC_FILE_NO),A                                    ; Indicate the drive number the file will be attached to.
            LD      A,TZSVC_CMD_ADDSDDRIVE                               ; I/O processor command to attach a CPM drive to the file number given.
            CALL    SVC_CMD
            OR      A
            JP      NZ, STRT8                                            ; No drive available, skip.
            ;
            CALL    COPYDPB                                              ; Copy parameters for this disk.
            ;
            ; Now add as many additional SD drives as we have RAM
            ; and config tables available within the CBIOS.
            ;
            LD      BC,(CDIRBUF+1)
            LD      HL,CSVALVEND - 2048/8 + 1                            ; Subtract the size of the ALV (CSV has no size for a fixed SD drive)
            OR      A
            SBC     HL,BC
            JR      C,STRT8                                              ; If there is no more space, exit.
            JR      STRT7                                                ; Add another, keep on adding until there is no more ALV Memory free.
            ;
            ; Setup the 1.44MB Floppy Disk Drives.
            ;
STRT8:      LD      A,(DRVAVAIL)
            BIT     0,A
            JR      Z,STRT10                                              ; No Floppy drives available then skip.
            ;
            LD      BC,128/4                                             ; Setup CSV/ALV parameters for a 1.4MB Floppy drive.
            LD      (CDIRBUF+3),BC
            LD      BC,91   ; 720/8 + 1
            LD      (CDIRBUF+5),BC
            LD      BC,DPB3
            LD      (CDIRBUF+7),BC                                       ; Address of Disk Parameters
STRT9:      LD      A,(CDIRBUF)
            CP      MAXDISKS                                             ; Use the disk count to ensure we only add upto 2 FDC drives.
            JR      Z,STRT10
            ;
            LD      BC,(CDIRBUF+1)                                       ; Make sure there is memory available for the FDC drives.
            LD      HL,CSVALVEND - 720/8 + 1
            OR      A
            SBC     HL,BC
            JR      C,STRT10                                             ; If there is no more space, exit.
            ;
            CALL    COPYDPB                                              ; Setup the FDC.
            JR      STRT9
            ;
STRT10:     LD      A,(CDIRBUF)
            LD      (NDISKS),A                                           ; Setup max number of system disks found on this boot up.
         
            ; Setup timer interrupts
            LD      IX,TIMIN                                             ; Pass the interrupt service handler vector.
            LD      BC,00000H                                            ; Time starts at 00:00:00 01/01/1980 on initialisation.
            LD      DE,00000H
            LD      HL,00000H
            CALL    TIMESET

            ; Signon message after all the hardware has been initialised.
            LD      DE,CPMSIGNON
            CALL    MONPRTSTR
            ;
            ; CP/M init
CPMINIT:    LD      A,(DRVAVAIL)
            BIT     0,A
            JR      Z,CPMINIT1
            ;
            CALL    DSKINIT                                              ; Re-initialise the disk subsystem if available.
            XOR     A                                                    ; 0 to accumulator
            LD      (HSTACT),A                                           ; Host buffer inactive
            LD      (UNACNT),A                                           ; Clear unalloc count
            ;
CPMINIT1:   LD      A, 0C3H                                              ; C3 IS A JMP INSTRUCTION
            LD      (00000H), A                                          ; FOR JMP TO WBOOT
            LD      HL, WBOOTE                                           ; WBOOT ENTRY POINT
            LD      (00001H), HL                                         ; SET ADDRESS FIELD FOR JMP AT 0
            LD      (00005H), A                                          ; FOR JMP TO BDOS
            LD      HL, CPMBDOS                                          ; BDOS ENTRY POINT
            LD      (00006H), HL                                         ; ADDRESS FIELD OF JUMP AT 5 TO BDOS
            LD      HL,TIMIN                                             ; Re-install interrupt vector for RTC incase it was overwritten.
            LD      (00038H),A
            LD      (00039H),HL
            LD      BC,CPMUSERDMA
            CALL    QSETDMA_
            ;
            ; check if current disk is valid
            LD      A,(NDISKS)                                           ; Get the dynamic disk count.
            LD      L,A
            LD      A, (CDISK)                                           ; GET CURRENT USER/DISK NUMBER (UUUUDDDD)
            AND     00FH                                                 ; Isolate the disk number.
            CP      L                                                    ; Drive number ok?
            JR      C, CPMINIT2                                          ; Yes, jump (Carry set if A < NDISKS)
            LD      A, (CDISK)                                           ; No, set disk 0 (previous user)
            AND     0F0H
            LD      (CDISK), A                                           ; Save User/Disk    
CPMINIT2:   CALL    SETDRVMAP                                            ; Refresh the map of physical floppies to CPM drive number.
            CALL    SETDRVCFG
         ;  LD      A,(DISKTYPE)
         ;  OR      A
         ;  CALL    Z,SELDRIVE                                           ; Select and start disk drive motor if floppy disk.
            ;
            LD      A, (CDISK)
            LD      C, A                                                 ; C = current User/Disk for CCP jump (UUUUDDDD)
            JP      BOOT_                                                ; Cold boot CPM now that most initialisation is complete. This is a direct jump to the fixed bios area 0xF000


            ;-------------------------------------------------------------------------------
            ;  WBOOT                                                                       
            ;                                                                               
            ;  The WBOOT entry point gets control when a warm start occurs.                
            ;  A warm start is performed whenever a user program branches to location      
            ;  0000H, or when the CPU is reset from the front panel. The CP/M system must  
            ;  be loaded from the first two tracks of drive A up to, but not including,    
            ;  the BIOS, or CBIOS, if the user has completed the patch. System parameters  
            ;  must be initialized as follows:                                             
            ;                                                                              
            ;  location 0,1,2                                                              
            ;      Set to JMP WBOOT for warm starts (000H: JMP 4A03H + b)                  
            ;                                                                              
            ;  location 3                                                                  
            ;      Set initial value of IOBYTE, if implemented in the CBIOS                
            ;                                                                              
            ;  location 4                                                                  
            ;      High nibble = current user number, low nibble = current drive           
            ;                                                                              
            ;  location 5,6,7                                                              
            ;      Set to JMP BDOS, which is the primary entry point to CP/M for transient 
            ;      programs. (0005H: JMP 3C06H + b)                                        
            ;                                                                              
            ;  Refer to Section 6.9 for complete details of page zero use. Upon completion 
            ;  of the initialization, the WBOOT program must branch to the CCP at 3400H+b  
            ;  to restart the system.                                                      
            ;  Upon entry to the CCP, register C is set to the drive to select after system
            ;  initialization. The WBOOT routine should read location 4 in memory, verify  
            ;  that is a legal drive, and pass it to the CCP in register C.                
            ;-------------------------------------------------------------------------------
QWBOOT_:    DI
            ;
            LD      SP,BOOTSTACK

            ; Reload the CCP and BDOS from SD.
            LD      A,TZSVC_CMD_LOADBDOS                                 ; I/O processor command to load the CCP+BDOS
            LD      HL,CBASE
            LD      (TZSVC_LOADADDR),HL                                  ; Address where to load the CCP+BDOS
            LD      HL,CPMBIOS-CBASE
            LD      (TZSVC_LOADSIZE),HL                                  ; Size of the CCP+BDOS area.
            CALL    SVC_CMD
            OR      A
            JP      Z, CPMINIT                                           ; Initialise CPM and run.
            LD      DE,NOBDOS
            CALL    MONPRTSTR
WBOOT2:     JR      WBOOT2                                               ; Cannot continue, no BDOS/CCP.


            ;-------------------------------------------------------------------------------
            ;  CONOUT                                                                      
            ;                                                                              
            ;  The character is sent from register C to the console output device.         
            ;  The character is in ASCII, with high-order parity bit set to zero. You      
            ;  might want to include a time-out on a line-feed or carriage return, if the  
            ;  console device requires some time interval at the end of the line (such as  
            ;  a TI Silent 700 terminal). You can filter out control characters that cause 
            ;  the console device to react in a strange way (CTRL_Z causes the Lear-       
            ;  Siegler terminal to clear the screen, for example).                         
            ;-------------------------------------------------------------------------------
QCONOUT_:   LD      A,C
            CALL    ANSITERM
            RET

            ;-------------------------------------------------------------------------------
            ;  CONIN                                                                       
            ;                                                                              
            ;  The next console character is read into register A, and the parity bit is   
            ;  set, high-order bit, to zero. If no console character is ready, wait until  
            ;  a character is typed before returning.                                      
            ;-------------------------------------------------------------------------------
QCONIN_:    CALL    GETKY
            RET

            ;-------------------------------------------------------------------------------
            ;  CONST                                                                       
            ;                                                                              
            ;  You should sample the status of the currently assigned console device and   
            ;  return 0FFH in register A if a character is ready to read and 00H in        
            ;  register A if no console characters are ready.                              
            ;-------------------------------------------------------------------------------
QCONST_:    CALL    CHKKY
            RET

            ;-------------------------------------------------------------------------------
            ;  READER                                                                      
            ;                                                                              
            ;  The next character is read from the currently assigned reader device into   
            ;  register A with zero parity (high-order bit must be zero); an end-of-file   
            ;  condition is reported by returning an ASCII CTRL_Z(1AH).                    
            ;-------------------------------------------------------------------------------
QREADER_:   LD      A, 01AH                                              ; Reader not implemented.
            RET

            ;-------------------------------------------------------------------------------
            ;  PUNCH                                                                       
            ;                                                                              
            ;  The character is sent from register C to the currently assigned punch       
            ;  device. The character is in ASCII with zero parity.                         
            ;-------------------------------------------------------------------------------
QPUNCH_:    RET             ; Punch not implemented

            ;-------------------------------------------------------------------------------
            ;  LIST                                                                        
            ;                                                                              
            ;  The character is sent from register C to the currently assigned listing     
            ;  device. The character is in ASCII with zero parity bit.                     
            ;-------------------------------------------------------------------------------
QLIST_:     RET

            ;-------------------------------------------------------------------------------
            ;  LISTST                                                                      
            ;                                                                              
            ;  You return the ready status of the list device used by the DESPOOL program  
            ;  to improve console response during its operation. The value 00 is returned  
            ;  in A if the list device is not ready to accept a character and 0FFH if a    
            ;  character can be sent to the printer. A 00 value should be returned if LIST 
            ;  status is not implemented.                                                  
            ;-------------------------------------------------------------------------------
QLISTST_:   XOR      A    ; Not implemented.
            RET

            ;-------------------------------------------------------------------------------
            ;  HOME                                                                        
            ;                                                                              
            ;  The disk head of the currently selected disk (initially disk A) is moved to 
            ;  the track 00 position. If the controller allows access to the track 0 flag  
            ;  from the drive, the head is stepped until the track 0 flag is detected. If  
            ;  the controller does not support this feature, the HOME call is translated   
            ;  into a call to SETTRK with a parameter of 0.                                
            ;-------------------------------------------------------------------------------
QHOME_:     LD      BC,00000H

            ;-------------------------------------------------------------------------------
            ;  SETTRK                                                                      
            ;                                                                              
            ;  Register BC contains the track number for subsequent disk accesses on the   
            ;  currently selected drive. The sector number in BC is the same as the number 
            ;  returned from the SECTRN entry point. You can choose to seek the selected   
            ;  track at this time or delay the seek until the next read or write actually  
            ;  occurs. Register BC can take on values in the range 0-76 corresponding to   
            ;  valid track numbers for standard floppy disk drives and 0-65535 for         
            ;  nonstandard disk subsystems.                                                
            ;-------------------------------------------------------------------------------
QSETTRK_:   LD      (SEKTRK),BC ; Set track passed from BDOS in register BC.
            RET     

            ;-------------------------------------------------------------------------------
            ;  SETSEC                                                                      
            ;                                                                              
            ;  Register BC contains the sector number, 1 through 26, for subsequent disk   
            ;  accesses on the currently selected drive. The sector number in BC is the    
            ;  same as the number returned from the SECTRAN entry point. You can choose to 
            ;  send this information to the controller at this point or delay sector       
            ;  selection until a read or write operation occurs.                           
            ;-------------------------------------------------------------------------------
QSETSEC_:   LD      A,C   ; Set sector passed from BDOS in register BC.
            LD      (SEKSEC), A
            RET     

            ;-------------------------------------------------------------------------------
            ;  SETDMA                                                                      
            ;                                                                              
            ;  Register BC contains the DMA (Disk Memory Access) address for subsequent    
            ;  read or write operations. For example, if B = 00H and C = 80H when SETDMA   
            ;  is called, all subsequent read operations read their data into 80H through  
            ;  0FFH and all subsequent write operations get their data from 80H through    
            ;  0FFH, until the next call to SETDMA occurs. The initial DMA address is      
            ;  assumed to be 80H. The controller need not actually support Direct Memory   
            ;  Access. If, for example, all data transfers are through I/O ports, the      
            ;  CBIOS that is constructed uses the 128 byte area starting at the selected   
            ;  DMA address for the memory buffer during the subsequent read or write       
            ;  operations.                                                                 
            ;-------------------------------------------------------------------------------
QSETDMA_:   LD      (DMAADDR),BC
            RET     

            ;-------------------------------------------------------------------------------
            ;  SELDSK                                                                      
            ;                                                                              
            ;  The disk drive given by register C is selected for further operations,      
            ;  where register C contains 0 for drive A, 1 for drive B, and so on up to 15  
            ;  for drive P (the standard CP/M distribution version supports four drives).  
            ;  On each disk select, SELDSK must return in HL the base address of a 16-byte 
            ;  area, called the Disk Parameter Header, described in Section 6.10.          
            ;  For standard floppy disk drives, the contents of the header and associated  
            ;  tables do not change; thus, the program segment included in the sample      
            ;  CBIOS performs this operation automatically.                                
            ;                                                                              
            ;  If there is an attempt to select a nonexistent drive, SELDSK returns        
            ;  HL = 0000H as an error indicator. Although SELDSK must return the header    
            ;  address on each call, it is advisable to postpone the physical disk select  
            ;  operation until an I/O function (seek, read, or write) is actually          
            ;  performed, because disk selects often occur without ultimately performing   
            ;  any disk I/O, and many controllers unload the head of the current disk      
            ;  before selecting the new drive. This causes an excessive amount of noise    
            ;  and disk wear. The least significant bit of register E is zero if this is   
            ;  the first occurrence of the drive select since the last cold or warm start. 
            ;-------------------------------------------------------------------------------
QSELDSK_:   LD      HL, 00000H                                           ; HL = error code
            LD      A,(NDISKS)
            LD      B,A
            LD      A,C
            CP      B
            JR      NC,SELDSK1                                           ; Ensure we dont select a non existant disk.
            LD      (CDISK),A                                            ; Setup drive.
SELDSK0:    CALL    SETDRVCFG                                
            LD      A,(DISKTYPE)
            CP      DSKTYP_SDC
            JR      Z,SELSDCDSK                                          ; Select SD Card.
            ; If it is not an SD drive then it must be a floppy disk.
            LD      A,C
            JR      CALCHL
SELDSK1:    RET

            ; For SD Cards, check that the SD Card is present, otherwise illegal disk.
SELSDCDSK:  LD      A,(DRVAVAIL)
            BIT     2,A
            JR      Z,SELDSK1                                            ; No SD Card drives available then skip.
            LD      A,C

            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
CALCHL:     LD      (SEKDSK),A
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,DPBASE
            LD      B,0
            LD      C,A 
            ADD     HL,BC
            JR      SELDSK1


            ;-------------------------------------------------------------------------------
            ;  SECTRAN                                                                     
            ;                                                                              
            ;  Logical-to-physical sector translation is performed to improve the overall  
            ;  response of CP/M. Standard CP/M systems are shipped with a skew factor of   
            ;  6, where six physical sectors are skipped between each logical read         
            ;  operation. This skew factor allows enough time between sectors for most     
            ;  programs to load their buffers without missing the next sector. In          
            ;  particular computer systems that use fast processors, memory, and disk      
            ;  subsystems, the skew factor might be changed to improve overall response.   
            ;  However, the user should maintain a single-density IBM-compatible version   
            ;  of CP/M for information transfer into and out of the computer system, using 
            ;  a skew factor of 6.                                                         
            ;                                                                              
            ;  In general, SECTRAN receives a logical sector number relative to zero in BC 
            ;  and a translate table address in DE. The sector number is used as an index  
            ;  into the translate table, with the resulting physical sector number in HL.  
            ;  For standard systems, the table and indexing code is provided in the CBIOS  
            ;  and need not be changed.                                                    
            ;-------------------------------------------------------------------------------
QSECTRN_:   LD      H,B
            LD      L,C
            RET     

            ;-------------------------------------------------------------------------------
            ;  READ                                                                        
            ;                                                                              
            ;  Assuming the drive has been selected, the track has been set, and the DMA   
            ;  address has been specified, the READ subroutine attempts to read one sector 
            ;  based upon these parameters and returns the following error codes in        
            ;  register A:                                                                 
            ;                                                                              
            ;      0 - no errors occurred                                                  
            ;      1 - non recoverable error condition occurred                            
            ;                                                                              
            ;  Currently, CP/M responds only to a zero or nonzero value as the return      
            ;  code. That is, if the value in register A is 0, CP/M assumes that the disk  
            ;  operation was completed properly. If an error occurs the CBIOS should       
            ;  attempt at least 10 retries to see if the error is recoverable. When an     
            ;  error is reported the BDOS prints the message BDOS ERR ON x: BAD SECTOR.    
            ;  The operator then has the option of pressing a carriage return to ignore    
            ;  the error, or CTRL_C to abort.                                              
            ;-------------------------------------------------------------------------------
            ;
            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
            ;
QREAD_:     XOR     A
            LD      (UNACNT), A
            LD      A, 1
            LD      (READOP), A                                          ; read operation
            LD      (RSFLAG), A                                          ; must read data
            LD      A, WRUAL
            LD      (WRTYPE), A                                          ; treat as unalloc
            CALL    RWOPER                                               ; to perform the read, returns with A=0 no errors or A > 0 errors.
            RET


            ;-------------------------------------------------------------------------------
            ;  WRITE                                                                       
            ;                                                                              
            ;  Data is written from the currently selected DMA address to the currently    
            ;  selected drive, track, and sector. For floppy disks, the data should be     
            ;  marked as nondeleted data to maintain compatibility with other CP/M         
            ;  systems. The error codes given in the READ command are returned in register 
            ;  A, with error recovery attempts as described above.                         
            ;-------------------------------------------------------------------------------
            ;
            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
            ;
QWRITE_:    XOR     A                                                    ; 0 to accumulator
            LD      (READOP), A                                          ; not a read operation
            LD      A, C                                                 ; write type in c
            LD      (WRTYPE), A
            CP      WRUAL                                                ; write unallocated?
            JR      NZ, CHKUNA                                           ; check for unalloc
            ; write to unallocated, set parameters
            LD      A, BLKSIZ/128                                        ; next unalloc recs
            LD      (UNACNT), A
            LD      A, (SEKDSK)                                          ; disk to seek
            LD      (UNADSK), A                                          ; unadsk = sekdsk
            LD      HL, (SEKTRK)
            LD      (UNATRK), HL                                         ; unatrk = sectrk
            LD      A, (SEKSEC)
            LD      (UNASEC), A                                          ; unasec = seksec
            ; check for write to unallocated sector
CHKUNA:     LD      A,(UNACNT)                                           ; any unalloc remain?
            OR      A   
            JR      Z, ALLOC                                             ; skip if not
            ; more unallocated records remain
            DEC     A                                                    ; unacnt = unacnt-1
            LD      (UNACNT), A
            LD      A, (SEKDSK)                                          ; same disk?
            LD      HL, UNADSK
            CP      (HL)                                                 ; sekdsk = unadsk?
            JP      NZ, ALLOC                                            ; skip if not
            ; disks are the same
            LD      HL, UNATRK
            CALL    SEKTRKCMP                                            ; sektrk = unatrk?
            JP      NZ, ALLOC                                            ; skip if not
            ;   tracks are the same
            LD      A, (SEKSEC)                                          ; same sector?
            LD      HL, UNASEC
            CP      (HL)                                                 ; seksec = unasec?
            JP      NZ, ALLOC                                            ; skip if not
            ; match, move to next sector for future ref
            INC     (HL)                                                 ; unasec = unasec+1
            LD      A, (HL)                                              ; end of track?
            CP      CPMSPT                                               ; count CP/M sectors
            JR      C, NOOVF                                             ; skip if no overflow
            ; overflow to next track
            LD      (HL), 0                                              ; unasec = 0
            LD      HL, (UNATRK)
            INC     HL
            LD      (UNATRK), HL                                         ; unatrk = unatrk+1
            ; match found, mark as unnecessary read
NOOVF:      XOR     A                                                    ; 0 to accumulator
            LD      (RSFLAG), A                                          ; rsflag = 0
            JR      ALLOC2                                               ; to perform the write
            ; not an unallocated record, requires pre-read
ALLOC:      XOR     A                                                    ; 0 to accum
            LD      (UNACNT), A                                          ; unacnt = 0
            INC     A                                                    ; 1 to accum
ALLOC2:     LD      (RSFLAG), A                                          ; rsflag = 1
            CALL    RWOPER
            RET


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
            CALL    MONPRTSTR
            POP     DE
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
            CALL    MONPRTSTR
            POP     DE
            LD      A,2
            RET
SVC_CMD6:   XOR     A                                                    ; Success.
            POP     BC
            POP     BC
            RET

            ;-------------------------------------------------------------------------------
            ; END OF SERVICE COMMAND METHODS
            ;-------------------------------------------------------------------------------


            ; Method to clear memory either to 0 or a given pattern.
            ;
CLR8Z:      XOR     A
CLR8:       LD      BC,00800H
CLRMEM:     PUSH    DE
            LD      D,A
L09E8:      LD      (HL),D
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,L09E8                
            POP     DE
            RET     


            ;-------------------------------------------------------------------------------
            ; START OF SD CARD DRIVE FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Method to read a sector from the SD Card.
            ; All reads occur in a 512byte sector.
            ;
            ; CPM Provides us with a track and sector, take these and pass them to the I/O
            ; processor which will map the params into the file associated with the drive.
            ;
            ; Inputs: (HSTTRK) - 16bit track number.
            ;         (HSTSEC) - 8bit sector number.
            ;         (CDISK)  - Disk drive number.
SDCREAD:    LD      HL,(HSTTRK)                                 ; 16bit track.
            LD      (TZSVC_TRACK_NO),HL
            LD      H,0                                         ; Only use 8 bit sector numbers at the moment.
            LD      A,(HSTSEC)
            LD      L,A
            LD      (TZSVC_SECTOR_NO),HL
            LD      A,(CDISK)                                   ; Disk drive no.
            LD      (TZSVC_FILE_NO),A 
            ;
            LD      A,TZSVC_CMD_READSDDRIVE
            CALL    SVC_CMD
            OR      A
            JP      READHST3

            ; Method to write a sector for CPM using its track/sector addressing.
            ; All writes occur in a 512byte sector.
            ;
            ; Inputs: (HSTTRK) - 16bit track number.
            ;         (HSTSEC) - 8bit sector number.
            ;         (CDISK)  - Disk drive number.
            ; Outputs: A = 1 - Error.
            ;          A = 0 - Success.
SDCWRITE:   LD      HL,(HSTTRK)                                 ; 16bit track.
            LD      (TZSVC_TRACK_NO),HL
            LD      H,0                                         ; Only use 8 bit sector numbers at the moment.
            LD      A,(HSTSEC)
            LD      L,A
            LD      (TZSVC_SECTOR_NO),HL
            LD      A,(CDISK)                                   ; Disk drive no.
            LD      (TZSVC_FILE_NO),A 
            ;
            LD      A,TZSVC_CMD_WRITESDDRIVE
            CALL    SVC_CMD
            OR      A
            JP      WRITEHST3

            ;-------------------------------------------------------------------------------
            ; END OF SD CARD DRIVE FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF CPM DEBLOCKING ALGORITHM
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; RWOPER                                                                      
            ;                                                                              
            ; The common blocking/deblocking algorithm provided by DR to accommodate devices
            ; which have sector sizes bigger than the CPM 128byte standard sector.
            ; In this implementation a sector size of 512 has been chosen regardless of
            ; what the underlying hardware uses (ie. FDC is 256 byte for a standard MZ800
            ; format disk).
            ;-------------------------------------------------------------------------------
RWOPER:     XOR     A                                                    ; zero to accum
            LD      (ERFLAG), A                                          ; no errors (yet)
            LD      A, (SEKSEC)                                          ; compute host sector
            OR      A                                                    ; carry = 0
            RRA                                                          ; shift right
            OR      A                                                    ; carry = 0
            RRA                                                          ; shift right
            LD      (SEKHST), A                                          ; host sector to seek
            ; active host sector?
            LD      HL, HSTACT                                           ; host active flag
            LD      A, (HL)
            LD      (HL), 1                                              ; always becomes 1
            OR      A                                                    ; was it already?
            JR      Z, FILHST                                            ; fill host if not
            ; host buffer active, same as seek buffer?
            LD      A, (SEKDSK)
            LD      HL, HSTDSK                                           ; same disk?
            CP      (HL)                                                 ; sekdsk = hstdsk?
            JR      NZ, NOMATCH
            ; same disk, same track?
            LD      HL, HSTTRK
            CALL    SEKTRKCMP                                            ; sektrk = hsttrk?
            JR      NZ, NOMATCH
            ; same disk, same track, same buffer?
            LD      A, (SEKHST)
            LD      HL, HSTSEC                                           ; sekhst = hstsec?
            CP      (HL)
            JR      Z, MATCH                                             ; skip if match
            ; proper disk, but not correct sector
NOMATCH:    LD      A, (HSTWRT)                                          ; host written?
            OR      A
            CALL    NZ, WRITEHST                                         ; clear host buff
            ; may have to fill the host buffer
FILHST:     LD      A, (SEKDSK)
            LD      (HSTDSK), A
            LD      HL, (SEKTRK)
            LD      (HSTTRK), HL
            LD      A, (SEKHST)
            LD      (HSTSEC), A
            LD      A, (RSFLAG)                                          ; need to read?
            OR      A
            CALL    NZ, READHST                                          ; yes, if 1
            OR      A
            JR      NZ,RWEXIT                                            ; If A > 0 then read error occurred.
            XOR     A                                                    ; 0 to accum
            LD      (HSTWRT), A                                          ; no pending write
            ; copy data to or from buffer
MATCH:      LD      A,  (SEKSEC)                                         ; mask buffer number
            AND     SECMSK                                               ; least signif bits
            LD      L,  A                                                ; ready to shift
            LD      H,  0                                                ; double count
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ; hl has relative host buffer address
            LD      DE, HSTBUF
            ADD     HL, DE                                               ; hl = host address
            EX      DE, HL                                               ; now in DE
            LD      HL, (DMAADDR)                                        ; get/put CP/M data
            LD      C, 128                                               ; length of move
            LD      A, (READOP)                                          ; which way?
            OR      A
            JR      NZ, RWMOVE                                           ; skip if read
            ; write operation, mark and switch direction
            LD      A, 1
            LD      (HSTWRT), A                                          ; hstwrt = 1
            EX      DE, HL                                               ; source/dest swap
            ; c initially 128, DE is source, HL is dest
RWMOVE:     LD      A,(INVFDCDATA)                                       ; Check to see if FDC data needs to be inverted. MB8866 controller works on negative logic.
            RRCA
            JR      NC,RWMOVE3
RWMOVE2:    CALL    MEMCPYINV
            JR      RWMOVE4
RWMOVE3:    CALL    MEMCPY
            ; data has been moved to/from host buffer
RWMOVE4:    LD      A, (WRTYPE)                                          ; write type
            CP      WRDIR                                                ; to directory?
            LD      A, (ERFLAG)                                          ; in case of errors
            RET     NZ                                                   ; no further processing
            ; clear host buffer for directory write
            OR      A                                                    ; errors?
            RET     NZ                                                   ; skip if so
            XOR     A                                                    ; 0 to accum
            LD      (HSTWRT), A                                          ; buffer written
            CALL    WRITEHST
RWEXIT:     LD      A, (ERFLAG)
            RET
        
            ; utility subroutine for 16-bit compare
            ; HL = .unatrk or .hsttrk, compare with sektrk
SEKTRKCMP:  EX      DE, HL
            LD      HL, SEKTRK
            LD      A, (DE)                                              ; low byte compare
            CP      (HL)                                                 ; same?
            RET     NZ                                                   ; return if not
            ; low bytes equal, test high 1s
            INC     DE
            INC     HL
            LD      A, (DE)
            CP      (HL)                                                 ; sets flags
            RET

            ;------------------------------------------------------------------------------------------------
            ; Read physical sector from host
            ;
            ; Read data from the floppy disk or SD. A = 1 if an error occurred.
            ;------------------------------------------------------------------------------------------------
READHST:    PUSH    BC
            PUSH    HL
            LD      A,(DISKTYPE)
            CP      DSKTYP_SDC                                           ; Is the drive an SD Card?
            JP      Z,SDCREAD
READHST2:   CALL    DSKREAD                                              ; Floppy card, use the FDC Controller.
READHST3:   POP     HL
            POP     BC
            RET
        
            ;------------------------------------------------------------------------------------------------
            ; Write physical sector to host
            ;
            ; Write data to the floppy disk or SD. A = 1 if an error occurred.
            ;------------------------------------------------------------------------------------------------
WRITEHST:   PUSH    BC
            PUSH    HL
            LD      A,(DISKTYPE)
            CP      DSKTYP_SDC                                           ; Is the drive an SD Card?
            JP      Z,SDCWRITE
            CALL    DSKWRITE
WRITEHST3:  POP     HL
            POP     BC
            RET
WRITEHST4:  LD      A,1                                                  ; Error, cannot write.
            JR      WRITEHST3

            ;-------------------------------------------------------------------------------
            ; END OF CPM DEBLOCKING ALGORITHM
            ;-------------------------------------------------------------------------------

            
            ;-------------------------------------------------------------------------------
            ; START OF AUDIO CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Melody function.
MLDY:       PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      A,002H
            LD      (OCTV),A
            LD      B,001H
MLD1:       LD      A,(DE)
            CP      00DH
            JR      Z,MLD4                 
            CP      0C8H
            JR      Z,MLD4                 
            CP      0CFH
            JR      Z,MLD2                 
            CP      02DH
            JR      Z,MLD2                 
            CP      02BH
            JR      Z,MLD3                 
            CP      0D7H
            JR      Z,MLD3                 
            CP      023H
            LD      HL,MTBL
            JR      NZ,MLD1A                
            LD      HL,M?TBL
            INC     DE
MLD1A:      CALL    ONPU
            JR      C,MLD1                 
            CALL    RYTHM
            JR      C,MLD5                 
            CALL    MLDST
            LD      B,C
            JR      MLD1                   
MLD2:       LD      A,003H
MLD2A:      LD      (OCTV),A
            INC     DE
            JR      MLD1                   
MLD3:       LD      A,001H
            JR      MLD2A                   
MLD4:       CALL    RYTHM
MLD5:       PUSH    AF
            CALL    MLDSP
            POP     AF
            POP     HL
            POP     DE
            POP     BC
            RET     

ONPU:       PUSH    BC
            LD      B,008H
            LD      A,(DE)
ONP1A:      CP      (HL)
            JR      Z,ONP2                 
            INC     HL
            INC     HL
            INC     HL
            DJNZ    ONP1A                   
            SCF     
            INC     DE
            POP     BC
            RET     

ONP2:       INC     HL
            PUSH    DE
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            EX      DE,HL
            LD      A,H
            OR      A
            JR      Z,ONP2B                 
            LD      A,(OCTV)
ONP2A:      DEC     A
            JR      Z,ONP2B                 
            ADD     HL,HL
            JR      ONP2A                   
ONP2B:      LD      (RATIO),HL
            LD      HL,OCTV
            LD      (HL),002H
            DEC     HL
            POP     DE
            INC     DE
            LD      A,(DE)
            LD      B,A
            AND     0F0H
            CP      030H
            JR      Z,ONP2C                 
            LD      A,(HL)
            JR      ONP2D                   
ONP2C:      INC     DE
            LD      A,B
            AND     00FH
            LD      (HL),A
ONP2D:      LD      HL,OPTBL
            ADD     A,L
            LD      L,A
            LD      C,(HL)
            LD      A,(TEMPW)
            LD      B,A
            XOR     A
            JP      MLDDLY

RYTHM:      LD      HL,KEYPA
            LD      (HL),0F0H
            INC     HL
            LD      A,(HL)
            AND     081H
            JR      NZ,L02D5                
            SCF     
            RET     

L02D5:      LD      A,(SUNDG)
            RRCA    
            JR      C,L02D5                 
L02DB:      LD      A,(SUNDG)
            RRCA    
            JR      NC,L02DB                
            DJNZ    L02D5                   
            XOR     A
            RET

MLDST:      LD      HL,(RATIO)
            LD      A,H
            OR      A
            JR      Z,MLDSP                 
            PUSH    DE
            EX      DE,HL
            LD      HL,CONT0
            LD      (HL),E
            LD      (HL),D
            LD      A,001H
            POP     DE
            JR      L02C4                   
MLDSP:      LD      A,034H
            LD      (CONTF),A
            XOR     A
L02C4:      LD      (SUNDG),A
            RET   

MLDDLY:     ADD     A,C
            DJNZ    MLDDLY                   
            POP     BC
            LD      C,A
            XOR     A
            RET   


TEMPO:      PUSH    AF
            PUSH    BC
            AND     00FH
            LD      B,A
            LD      A,008H
            SUB     B
            LD      (TEMPW),A
            POP     BC
            POP     AF
            RET  

            ;
            ; Method to sound the bell, basically play a constant tone.
            ; 
BEL:        PUSH    DE
            LD      DE,00DB1H
            CALL    MLDY
            POP     DE
            RET

            ;
            ; Melody (note) lookup table.
            ;
MTBL:       DB      043H
            DB      077H
            DB      007H
            DB      044H
            DB      0A7H
            DB      006H
            DB      045H
            DB      0EDH
            DB      005H
            DB      046H
            DB      098H
            DB      005H
            DB      047H
            DB      0FCH
            DB      004H
            DB      041H
            DB      071H
            DB      004H
            DB      042H
            DB      0F5H
            DB      003H
            DB      052H
            DB      000H
            DB      000H
M?TBL:      DB      043H
            DB      00CH
            DB      007H
            DB      044H
            DB      047H
            DB      006H
            DB      045H
            DB      098H
            DB      005H
            DB      046H
            DB      048H
            DB      005H
            DB      047H
            DB      0B4H
            DB      004H
            DB      041H
            DB      031H
            DB      004H
            DB      042H
            DB      0BBH
            DB      003H
            DB      052H
            DB      000H
            DB      000H

OPTBL:      DB      001H
            DB      002H
            DB      003H
            DB      004H
            DB      006H
            DB      008H
            DB      00CH
            DB      010H
            DB      018H
            DB      020H
            ;-------------------------------------------------------------------------------
            ; END OF AUDIO CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF RTC FUNCTIONALITY (INTR HANDLER IN MAIN CBIOS)
            ;-------------------------------------------------------------------------------
            ; 
            ; BC:DE:HL contains the time in milliseconds (100msec resolution) since 01/01/1980. In IX is held the interrupt service handler routine address for the RTC.
            ; HL contains lower 16 bits, DE contains middle 16 bits, BC contains upper 16bits, allows for a time from 00:00:00 to 23:59:59, for > 500000 days!
            ; NB. Caller must disable interrupts before calling this method.
TIMESET:    LD      (TIMESEC),HL                                         ; Load lower 16 bits.
            EX      DE,HL
            LD      (TIMESEC+2),HL                                       ; Load middle 16 bits.
            PUSH    BC
            POP     HL
            LD      (TIMESEC+4),HL                                       ; Load upper 16 bits.
            ;
            LD      HL,CONTF
            LD      (HL),074H                                            ; Set Counter 1, read/load lsb first then msb, mode 2 rate generator, binary
            LD      (HL),0B0H                                            ; Set Counter 2, read/load lsb first then msb, mode 0 interrupt on terminal count, binary
            DEC     HL
            LD      DE,TMRTICKINTV                                       ; 100Hz coming into Timer 2 from Timer 1, set divisor to set interrupts per second.
            LD      (HL),E                                               ; Place current time in Counter 2
            LD      (HL),D
            DEC     HL
            IF      BUILD_MZ80A = 1
              LD    (HL),03BH                                            ; Place divisor in Counter 1, = 315, thus 31500/315 = 100
              LD    (HL),001H
            ENDIF
            IF      BUILD_MZ700 = 1
              LD    (HL),09CH                                            ; Place divisor in Counter 1, = 156, thus 15611/156 = 100
              LD    (HL),000H
            ENDIF
            NOP     
            NOP     
            NOP     
            ;
            LD      A, 0C3H                                              ; Install the interrupt vector for when interrupts are enabled.
            LD      (00038H),A
            LD      (00039H),IX
            RET    

            ; Time Read;
            ; Returns BC:DE:HL where HL is lower 16bits, DE is middle 16bits and BC is upper 16bits of milliseconds since 01/01/1980.
TIMEREAD:   LD      HL,(TIMESEC+4)
            PUSH    HL
            POP     BC
            LD      HL,(TIMESEC+2)
            EX      DE,HL
            LD      HL,(TIMESEC)
            RET
            ;-------------------------------------------------------------------------------
            ; END OF RTC FUNCTIONALITY
            ;-------------------------------------------------------------------------------




            ;-------------------------------------------------------------------------------
            ; START OF FDC CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;------------------------------------------------------------------------------------------------
            ; Initialise drive and reset flags, Set motor off
            ;------------------------------------------------------------------------------------------------
DSKINIT:    XOR     A                                                        
            OUT     (FDC_MOTOR),A                                        ; Motor off
            LD      (TRK0FD1),A                                          ; Track 0 flag drive 1
            LD      (TRK0FD2),A                                          ; Track 0 flag drive 2
            LD      (TRK0FD3),A                                          ; Track 0 flag drive 3
            LD      (TRK0FD4),A                                          ; Track 0 flag drive 4
            LD      (MOTON),A                                            ; Motor on flag
            LD      (MTROFFTIMER),A                                      ; Clear the down counter for motor off.
            LD      A,(FDCJMP1)                                          ; Check to see if the FDC AFI ROM is installed, use this as
            AND     0DFH                                                 ; Byte can be either DD or FD dependent on the FDC wait line,
            CP      0DDH                                                 ; so check both to determine if the FDC is present.
            RET

            ; Function to create a mapping table between a CPM disk and a physical disk.
SETDRVMAP:  PUSH    HL
            PUSH    DE
            PUSH    BC
            ; Zero out the map.
            LD      B,MAXDISKS
            LD      HL,DISKMAP
            LD      A,0FFH
SETDRVMAP1: LD      (HL),A
            INC     HL
            DJNZ    SETDRVMAP1
            LD      HL,DISKMAP                                           ; Place in the Map for next drive.
            ; Now go through each disk from the Disk Parameter Base list.
            LD      B,0                                                  ; Disk number count = CDISK.
            LD      DE,0                                                 ; Physical disk number, D = FDC, E = SDC.
SETDRVMAP2: LD      A,B
            CP      MAXDISKS
            JR      Z,SETDRVMAP6
            INC     B
            PUSH    HL
            PUSH    DE
            PUSH    BC
            ; For the Disk in A, find the parameter table.
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,DPBASE                                            ; Base of disk description block.
            LD      B,0
            LD      C,A 
            ADD     HL,BC                                                ; HL contains address of actual selected disk block.
            LD      C,10
            ADD     HL,BC                                                ; HL contains address of pointer to disk parameter block.
            LD      E,(HL)
            INC     HL
            LD      D,(HL)                                               ; DE contains address of disk parameter block.
            EX      DE,HL
            LD      A,(HL)
            LD      E,A
            LD      BC,15
            ADD     HL,BC                                                ; Move to configuuration byte which identifies the disk type.
            ;
            POP     BC
            POP     DE
            LD      A,(HL)
            POP     HL

            BIT     4,A                                                  ; Disk type = FDC
            JR      Z,SETDRVMAP4                                         ; Is this an FDC controlled disk, if so store the mapping number in the map unchanged.
            ;
            BIT     3,A                                                  ; Is this an SD Card disk, if so, add 080H to the mapping number and store.
            JR      Z,SETDRVMAP5
            LD      A,E
            OR      080H
            INC     E
            JR      SETDRVMAP5
            ;
SETDRVMAP4: LD      A,D
            INC     D
SETDRVMAP5: LD      (HL),A
            INC     HL
            JR      SETDRVMAP2
            ;
SETDRVMAP6: POP     BC
            POP     DE
            POP     HL
            RET

            ; Function to setup the drive parameters according to the CFG byte in the disk parameter block.
SETDRVCFG:  PUSH    HL
            PUSH    DE
            PUSH    BC
            LD      A,(CDISK)
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,DPBASE                                            ; Base of disk description block.
            LD      B,0
            LD      C,A 
            ADD     HL,BC                                                ; HL contains address of actual selected disk block.
            LD      C,10
            ADD     HL,BC                                                ; HL contains address of pointer to disk parameter block.
            LD      E,(HL)
            INC     HL
            LD      D,(HL)                                               ; DE contains address of disk parameter block.
            EX      DE,HL
            LD      A,(HL)
            LD      E,A

            LD      BC,15
            ADD     HL,BC                                                ; Move to configuration byte.
            XOR     A
            BIT     2,(HL)
            JR      Z,SETDRV0
            INC     A
SETDRV0:    LD      (INVFDCDATA),A                                       ; Data inversion is set according to drive parameter.
            LD      A,4
            BIT     1,(HL)
            JR      Z,SETDRV1
            LD      A,2
            BIT     0,(HL)
            JR      Z,SETDRV1
            LD      A,1
SETDRV1:    LD      (SECTORCNT),A                                        ; Set the disk sector size.
            LD      D,A
            CP      4
            LD      A,E
            JR      Z,SETDRV1A
            OR      A
            RR      A
            LD      E,A
            LD      A,D
            CP      2
            LD      A,E
            JR      Z,SETDRV1A
            OR      A
            RR      A                                                    ; Convert sectors per track from 128 bytes to 256 byte sectors.
SETDRV1A:   INC     A                                                    ; Add 1 to ease comparisons.
            LD      (SECPERTRK),A                                        ; Only cater for 8bit, ie. 256 sectors.
            DEC     A
            OR      A
            RR      A
            INC     A                                                    ; Add 1 to ease comparisons.
            LD      (SECPERHEAD),A                                       ; Convert sectors per track to sectors per head.
            ;
            XOR     A                                                    ; Disk type = FDC
            BIT     4,(HL)
            JR      Z,SETDRV2
            LD      A,DSKTYP_SDC                                         ; Disk type = SD Card
SETDRV2:    LD      (DISKTYPE),A
            POP     BC
            POP     DE
            POP     HL
            RET

            ; Method to get the current disk drive mapped to the correct controller.
            ; The CPM CDISK is mapped via MAPDISK[CDISK] and the result:
            ; Bit 7 = 1 - SD Card drive.
            ; BIT 7:6 = 00 - Floppy drive.
GETMAPDSK:  PUSH    HL
            PUSH    BC
            LD      A,(CDISK)
            LD      HL,DISKMAP
            LD      C,A
            LD      B,0
            ADD     HL,BC
            LD      A,(HL)                                               ; Get the physical number after mapping from the CDISK.
            POP     BC
            POP     HL
            RET

            ; Select FDC drive (make active) based on value in DISKMAP[CDISK].
SELDRIVE:   CALL    GETMAPDSK
            CP      040H                                                 ; Anything with bit 6 or 7 set is not an FDC drive.
            RET     NC                                                   ; This isnt a physical floppy disk, no need to perform any actions, exit.
            ;
            LD      (FDCDISK),A
            CALL    DSKMTRON                                             ; yes, set motor on and wait
            LD      A,(FDCDISK)                                          ; select drive no
            OR      084H                                                     
            OUT     (FDC_MOTOR),A                                        ; Motor on for drive 0-3
            XOR     A                                                        
            LD      (FDCCMD),A                                           ; clr latest FDC command byte
            LD      HL,00000H                                                
SELDRV2:    DEC     HL                                                       
            LD      A,H                                                      
            OR      L                                                        
            JP      Z,SELDRVERR                                          ; Reset and print message that this is not a valid disk.
            IN      A,(FDC_STR)                                          ; Status register.
            CPL                                                              
            RLCA                                                             
            JR      C,SELDRV2                                            ; Wait on Drive Ready Bit (bit 7)
            LD      A,(FDCDISK)                                          ; Drive number
            LD      C,A
            LD      HL,TRK0FD1                                           ; 1 track 0 flag for each drive
            LD      B,000H                                                   
            ADD     HL,BC                                                ; Compute related flag 1002/1003/1004/1005
            BIT     0,(HL)                                                   
            JR      NZ,SELDRV3                                           ; If the drive hasnt been intialised to track 0, intialise and set flag.
            CALL    DSKSEEKTK0                                           ; Seek track 0.
            SET     0,(HL)                                               ; Set bit 0 of trk 0 flag
SELDRV3:    CALL    SETDRVCFG
            RET

            ; Turn disk motor on if not already running.
DSKMTRON:   LD      A,255                                                ; Ensure motor is kept running whilst we read/write.
            LD      (MTROFFTIMER),A
            LD      A,(MOTON)                                            ; Test to see if motor is on, if it isnt, switch it on.
            RRCA
            JR      NC, DSKMOTORON
            RET
DSKMOTORON: PUSH    BC
            LD      A,080H
            OUT     (FDC_MOTOR),A                                        ; Motor on
            LD      B,010H                                               ; 
DSKMTR2:    CALL    MTRDELAY                                             ; 
            DJNZ    DSKMTR2                                              ; Wait until becomes ready.
            LD      A,001H                                               ; Set motor on flag.
            LD      (MOTON),A                                            ; 
            POP     BC
            RET      

FDCDLY1:    PUSH    DE
            LD      DE,00007H
            JP      MTRDEL2

MTRDELAY:   PUSH    DE
            LD      DE,01013H
MTRDEL2:    DEC     DE
            LD      A,E
            OR      D
            JR      NZ,MTRDEL2                                           
            POP     DE
            RET    

DSKWRITE:   LD      A,MAXWRRETRY
            LD      (RETRIES),A
            LD      A,(SECTORCNT)
            LD      B,A
            LD      A,(HSTSEC)
DSKWRITE0A: DJNZ    DSKWRITE0B
            JR      DSKWRITE1
DSKWRITE0B: OR      A
            RL      A
            JR      DSKWRITE0A
DSKWRITE1:  INC     A
            LD      (SECTORNO), A                                        ; Convert from Host 512 byte sector into local sector according to paraameter block.
            LD      HL,(HSTTRK)
            LD      (TRACKNO),HL

DSKWRITE2:  CALL    SETTRKSEC                                            ; Set current track & sector, get load address to HL
DSKWRITE3:  CALL    SETHEAD                                              ; Set side reg
            CALL    SEEK                                                 ; Command 1b output (seek)
            JP      NZ,SEEKRETRY                                         ; 
            CALL    OUTTKSEC                                             ; Set track & sector reg

            LD      IX, 0F3FEH                                           ; As below. L03FE
            LD      IY,WRITEDATA                                         ; Write sector from memory.
            DI     
            ;
            LD      A,0B4H                                               ; Write Sector multipe with Side Compare for side 1.
            CALL    DISKCMDWAIT
            LD      D,2                                                  ; Regardless of 4x128, 2x256 or 1x512, we always read 512bytes by the 2x INI instruction with B=256.
STRTDATWR:  LD      B,0                                                  ; 256 bytes to load.
            JP      (IX)

WRITEDATA:  OUTI    
            JP      NZ, 0F3FEH                                           ; This is crucial, as the Z80 is running at 2MHz it is not fast enough so needs
                                                                         ; hardware acceleration in the form of a banked ROM, if disk not ready jumps to IX, if
                                                                         ; data ready, jumps to IY.
            DEC     D
            JP      NZ,0F3FEH                                            ; If we havent read all sectors to form a 512 byte block, go for next sector.
            JR      DATASTOP      

            ; Read disk starting at the first logical sector in param block 1009/100A
            ; Continue reading for the given size 100B/100C and store in the location 
            ; Pointed to by the address stored in the parameter block. 100D/100E
DSKREAD:    LD      A,MAXRDRETRY
            LD      (RETRIES),A
            LD      A,(SECTORCNT)
            LD      B,A
            LD      A,(HSTSEC)
DSKREAD0A:  DJNZ    DSKREAD0B
            JR      DSKREAD1
DSKREAD0B:  OR      A
            RL      A
            JR      DSKREAD0A
DSKREAD1:   INC     A
            LD      (SECTORNO), A                                        ; Convert from Host 512 byte sector into local sector according to paraameter block.
            LD      HL,(HSTTRK)
            LD      (TRACKNO),HL
DSKREAD2:   CALL    SETTRKSEC                                            ; Set current track & sector, get load address to HL
DSKREAD3:   CALL    SETHEAD                                              ; Set side reg
            CALL    SEEK                                                 ; Command 1b output (seek)
            JP      NZ,SEEKRETRY                                         ; 
            CALL    OUTTKSEC                                             ; Set track & sector reg
            LD      IX, 0F3FEH                                           ; As below. L03FE
            LD      IY,READDATA                                          ; Read sector into memory.
            DI     
            ;
            LD      A,094H                                               ; Read Sector multiple with Side Compare for side 1.
            CALL    DISKCMDWAIT
            LD      D,2                                                  ; Regardless of 4x128, 2x256 or 1x512, we always read 512bytes by the 2x INI instruction with B=256.
STRTDATRD:  LD      B,0                                                  ; 256 bytes to load.
            JP      (IX)

            ; Get data from disk sector to staging area.
READDATA:   INI     
            JP      NZ,0F3FEH                                            ; This is crucial, as the Z80 is running at 2MHz it is not fast enough so needs
                                                                         ; hardware acceleration in the form of a banked ROM, if disk not ready jumps to IX, if
                                                                         ; data ready, jumps to IY.
            DEC     D
            JP      NZ,0F3FEH                                            ; If we havent read all sectors to form a 512 byte block, go for next sector.
            ;
            ;
DATASTOP:   LD      A,0D8H                                               ; Force interrupt command, Immediate interrupt (I3 bit 3=1) of multiple sector read.
            CPL    
            OUT     (FDC_CR),A
            CALL    WAITRDY                                              ; Wait for controller to become ready, acknowledging interrupt.
            IN      A,(FDC_STR)                                          ; Check for errors.
            CPL     
            AND     0FFH
            JR      NZ,SEEKRETRY   
UPDSECTOR:  PUSH    HL
            LD      A,(SECTORCNT)
            LD      HL,SECTORNO
            ADD     A,(HL)                                               ; Update sector to account for sectors read. NB. All reads will start at such a position
            LD      (HL), A                                              ; that a read will not span a track or head. Ensure that disk formats meet an even 512byte format.
            POP     HL
MOTOROFF:   LD      A,MTROFFMSECS                                         ; Schedule motor to be turned off.
            LD      (MTROFFTIMER),A
            XOR     A                                                    ; Successful read, return 0
            EI
            RET    

SEEKRETRY:  LD      B,A                                                  ; Preserve the FDC Error byte.
            LD      A,(RETRIES)
            DEC     A
            LD      (RETRIES),A
            LD      A,B
            JP      Z,RETRIESERR
            CALL    DSKSEEKTK0
            LD      A, (READOP) 
            OR      A
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            JP      Z, DSKWRITE2                                         ; Try write again.
            JP      DSKREAD2                                             ; Try the read again.

DISKCMDWAIT:LD      (FDCCMD),A
            CPL    
            OUT     (FDC_CR),A
            CALL    WAITBUSY
            RET     

            ; Send a command to the disk controller.
DSKCMD:     LD      (FDCCMD),A                                           ; Store latest FDC command.
            CPL                                                          ; Compliment it (FDC bit value is reversed).
            OUT     (FDC_CR),A                                           ; Send command to FDC.
            CALL    WAITRDY                                              ; Wait to become ready.
            IN      A,(FDC_STR)                                          ; Get status register.
            CPL                                                          ; Inverse (FDC is reverse bit logic).
            RET   

            ; Seek to programmed track.
SEEK:       LD      A,01BH                                               ; Seek command, load head, verify stepping 6ms.
            CALL    DSKCMD
            AND     099H
            RET

            ; Set current track & sector, get load address to HL
SETTRKSEC:  CALL    SELDRIVE
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            LD      HL, HSTBUF
            RET     

            ; Compute side/head.
SETHEAD:    CPL                                                          ; 
            OUT     (FDC_DR),A                                           ; Output track no for SEEK command.
            PUSH    HL
            LD      HL,SECPERHEAD
            LD      A,(SECTORNO)                                         ; Check sector, if greater than sector per track, change head.
            CP      (HL)
            POP     HL
            JR      NC,SETHD2                                            ; Yes, even, set side/head 1
            LD      A,001H                                               ; No, odd, set side/head 0
            JR      SETHD3                   

            ; Set side/head register.
SETHD2:     XOR     A                                                    ; Side 0
SETHD3:     CPL                                                          ; Side 1
            OUT     (FDC_SIDE),A                                         ; Side/head register.
            RET     

            ; Set track and sector register.
OUTTKSEC:   PUSH    HL
            LD      HL,SECPERHEAD
            ;
            LD      C,FDC_DR                                             ; Port for data retrieval in the INI instruction in main block.                 
            LD      A,(TRACKNO)                                          ; Current track number, NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            CPL                             
            OUT     (FDC_TR),A                                           ; Track reg
            ;
            LD      A,(SECTORNO)                                         ; Current sector number
            CP      (HL)
            JR      C,OUTTKSEC2
            SUB     (HL)
            INC     A                                                    ; Account for the +1 added to ease comparisons.
OUTTKSEC2:  CPL                             
            OUT     (FDC_SCR),A                                          ; Sector reg
            POP     HL
            RET                       

            ; Seek to track 0.
DSKSEEKTK0: CALL    DSKMTRON                                             ; Make sure disk is spinning.
            LD      A,00BH                                               ; Restore command, seek track 0.
            CALL    DSKCMD                                               ; Send command to FDC.
            AND     085H                                                 ; Process result.
            XOR     004H   
            RET     Z      
            JP      DSKSEEKERR

            ; Wait for the drive to become ready.
WAITRDY:    PUSH    DE
            PUSH    HL
            CALL    FDCDLY1
            LD      E,007H
WAITRDY2:   LD      HL,00000H
WAITRDY3:   DEC     HL
            LD      A,H
            OR      L
            JR      Z,WAITRDY4                                           
            IN      A,(FDC_STR)
            CPL     
            RRCA    
            JR      C,WAITRDY3                                          
            POP     HL
            POP     DE
            RET     

WAITRDY4:   DEC     E
            JR      NZ,WAITRDY2                                        
            POP     HL
            POP     DE
            JP      WAITRDYERR

WAITBUSY:   PUSH    DE
            PUSH    HL
            CALL    FDCDLY1
            LD      E,007H                                               ; 7 Chances of a 16bit down count delay waiting for DRQ.
WAITBUSY2:  LD      HL,00000H
WAITBUSY3:  DEC     HL
            LD      A,H
            OR      L
            JR      Z,WAITBUSY4                                          ; Down counter expired, decrement retries, error on 0.
            IN      A,(FDC_STR)                                          ; Get the FDC Status
            CPL                                                          ; Switch to positive logic.
            RRCA                                                         ; Shift Busy flag into Carry.
            JR      NC,WAITBUSY3                                         ; Busy not set, decrement counter and retry.
            POP     HL
            POP     DE
            RET     

WAITBUSY4:  DEC     E
            JR      NZ,WAITBUSY2                                         
            POP     HL
            POP     DE
            JP      DSKERR


            ; Error processing. Consists of printing a message followed by debug data (if enabled) and returning with carry set
            ; to indicate error.
DSKERR:     LD      DE,LOADERR                                           ; Loading error message
            JR      HDLERROR                                             

SELDRVERR:  LD      DE,SELDRVMSG                                         ; Select drive error message.
            JR      HDLERROR                                              
            
WAITRDYERR: LD      DE,WAITRDYMSG                                        ; Waiting for ready timeout error message.
            JR      HDLERROR                                               
 
DSKSEEKERR: LD      DE,DSKSEEKMSG                                        ; Disk seek to track error message.
            JR      HDLERROR                                                

RETRIESERR: BIT     2,A                                                  ; Data overrun error if 1.
            LD      DE,DATAOVRMSG
            JR      NZ, RETRIESERR2
            BIT     3,A                                                  ; CRC error if 1.
            LD      DE,CRCERRMSG
            JR      NZ,RETRIESERR2
            LD      DE,RETRIESMSG                                        ; Data sector read error message.
RETRIESERR2:

            ; Process error, dump debug data and return fail code.
HDLERROR:   SCF
            CALL    DEBUG
HOLPRTSTR:  LD      A,(DE)
            OR      A
            JR      Z,HDLPRTSTR3
            INC     DE
HOLPRTSTR2: CALL    PRNT
            JR      HOLPRTSTR
HDLPRTSTR3: XOR     A
            CALL    DSKINIT
            CALL    DSKMTRON
            LD      A,001H                                               ; Indicate error by setting 1 in A register.
            EI
            RET

            ;-------------------------------------------------------------------------------
            ; END OF FDC CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; UTILITIES
            ;-------------------------------------------------------------------------------

            ; Function to print a string with control character interpretation.
MONPRTSTR:  LD      A,(DE)
            OR      A
            RET     Z
            INC     DE
MONPRTSTR2: CALL    PRNT
            JR      MONPRTSTR

            ; Helper method to set up a Disk Parameter Block.
            ; Input: Drive Count = (CDIRBUF)
            ;        CSV/ALV Memory Pointer (CDIRBUF+1)
            ;        CSV Size (CDIRBUF+3)
            ;        ALV Size (CDIRBUF+5)
            ;        Disk parameters address CDIRBUF+7)
            ; Output: Updated CSV/ALV Pointer (CDIRBUF+1)
            ;         Updated disk count (CDIRBUF)
COPYDPB:    LD      HL,DPBTMPL                                           ; Base of parameter template.
            LD      BC,10
            LDIR                                                         ; Copy the lower part of the DPB as it is static.
            LD      HL,CDIRBUF+7                                         ; Get the address of the disk parameters.
            LDI
            LDI
            LD      BC,(CDIRBUF+3)                                       ; Add the CSV size for this entry to the pointer and store.
            LD      A,B                                                  ; Fixed drives dont have a CSV, so if 0, copy 0 and not allocate memory.
            OR      C
            LD      HL,CDIRBUF+1                                         ; Now get the free CSV/ALV pointer.
            JR      NZ,COPYDPB1
            LD      HL,CDIRBUF+3
COPYDPB1:   LDI
            LDI
            LD      HL,(CDIRBUF+1)
            LD      BC,(CDIRBUF+3)                                       ; Add the CSV size for this entry to the pointer and store.
            ADD     HL,BC
            LD      (CDIRBUF+1),HL
            LD      HL,CDIRBUF+1
            LDI
            LDI
            LD      HL,(CDIRBUF+1)
            LD      BC,(CDIRBUF+5)                                       ; Now add the size of the ALV for this drive to the pointer for the next drive.
            ADD     HL,BC
            LD      (CDIRBUF+1),HL                                       ; Store.
            LD      A,(CDIRBUF)
            INC     A
            LD      (CDIRBUF),A                                          ; Update drive count.
            RET


            ; A function from the z88dk stdlib, a delay loop with T state accuracy.
            ; 
            ; enter : hl = tstates >= 141
            ; uses  : af, bc, hl
T_DELAY:    LD      BC,-141
            ADD     HL,BC
            LD      BC,-23
TDELAYLOOP: ADD     HL,BC
            JR      C, TDELAYLOOP
            LD      A,L
            ADD     A,15
            JR      NC, TDELAYG0
            CP      8
            JR      C, TDELAYG1
            OR      0
TDELAYG0:   INC     HL
TDELAYG1:   RRA
            JR      C, TDELAYB0
            NOP
TDELAYB0:   RRA
            JR      NC, TDELAYB1
            OR      0
TDELAYB1:   RRA
            RET     NC
            RET

            ; Method to multiply a 16bit number by another 16 bit number to arrive at a 32bit result.
            ; Input: DE = Factor 1
            ;        BC = Factor 2
            ; Output:DEHL = 32bit Product
            ;
MULT16X16:  LD      HL,0
            LD      A,16
MULT16X1:   ADD     HL,HL
            RL      E 
            RL      D
            JR      NC,$+6
            ADD     HL,BC
            JR      NC,$+3
            INC     DE
            DEC     A
            JR      NZ,MULT16X1
            RET

            ; Method to add a 16bit number to a 32bit number to obtain a 32bit product.
            ; Input: DEHL = 32bit Addend
            ;        BC   = 16bit Addend
            ; Output:DEHL = 32bit sum.
            ;
ADD3216:    ADD     HL,BC
            EX      DE,HL
            LD      BC,0
            ADC     HL,BC
            EX      DE,HL
            RET

            ;-------------------------------------------------------------------------------
            ; END OF UTILITIES
            ;-------------------------------------------------------------------------------

            ; CPM Boot code.
            ;
            ; When CPM is loaded by TZFS it will execute startup code at this vector in 64K block 0. Once the memory mode
            ; switch executed then this block is paged in, so the follow on instructions must be in place otherwise the CPU
            ; will go into the wilderness!
            ;
            IF $ > 01108H
                ERROR "CMT comment area not aligned, needed for CPM bootstrap. Addr=%s, required=%s"; % $, 01108H
            ENDIF            
            ALIGN_NOPS 01108H
BOOTSTG1:   LD      A,TZMM_CPM2
            OUT     (MMCFG), A
            JP      QBOOT_
            ; Method to reboot the machine back into TZFS. This code exists both in memory mode 2 and 7 at the same location so when a switch is made from
            ; mode 7 to mode 2, the code continues.
REBOOT:     LD      A,TZMM_TZFS
            OUT     (MMCFG),A

            ; Switch machine back to default state.
            IF BUILD_VIDEOMODULE = 1
            IN      A,(VMCTRL)                                           ; Get current display mode.
            AND     ~MODE_80CHAR                                         ; Disable 80 char display.
            OUT     (VMCTRL),A                                           ; Activate.
         ;  LD      A, SYSMODE_MZ80A                                     ; Set bus and default CPU speed to 2MHz
         ;  OUT     (SYSCTRL),A                                          ; Activate.
            ELSE
            ; Change to 40 character mode on the 40/80 Char Colour board v1.0.
            LD      A, 0                                                 ; 40 char mode.
            LD      (DSPCTL), A
            ENDIF
            ;
            JP      MROMADDR                                             ; Now restart in the SA1510 monitor.


            ALIGN_NOPS 01200H

            ;-------------------------------------------------------------------------------
            ; START OF KEYBOARD FUNCTIONALITY (INTR HANDLER SEPERATE IN CBIOS)
            ;-------------------------------------------------------------------------------

MODE:       LD      HL,KEYPF
            LD      (HL),08AH
            LD      (HL),007H                                            ; Set Motor to Off.
            LD      (HL),004H                                            ; Disable interrupts by setting INTMSK to 0.
            LD      (HL),001H                                            ; Set VGATE to 1.
            RET     

            ; Method to check if a key has been pressed and stored in buffer.. 
CHKKY:      LD      A, (KEYCOUNT)
            OR      A
            JR      Z,CHKKY2
            LD      A,0FFH
            RET
CHKKY2:     XOR     A
            RET

GETKY:      PUSH    HL
            LD      A,(KEYCOUNT)
            OR      A
            JR      Z,GETKY2
GETKY1:     DI                                                           ; Disable interrupts, we dont want a race state occurring.
            LD      A,(KEYCOUNT)
            DEC     A                                                    ; Take 1 off the total count as we are reading a character out of the buffer.
            LD      (KEYCOUNT),A
            LD      HL,(KEYREAD)                                         ; Get the position in the buffer where the next available character resides.
            LD      A,(HL)                                               ; Read the character and save.
            PUSH    AF
            INC     L                                                    ; Update the read pointer and save.
            LD      A,L
            AND     KEYBUFSIZE-1
            LD      L,A
            LD      (KEYREAD),HL
            POP     AF
            EI                                                           ; Interrupts back on so keys and RTC are actioned.
            JR      PRCKEY                                               ; Process the key, action any non ASCII keys.
            ;
GETKY2:     LD      A,(KEYCOUNT)                                         ; No key available so loop until one is.
            OR      A
            JR      Z,GETKY2                 
            JR      GETKY1
            ;
PRCKEY:     CP      CR                                                   ; CR
            JR      NZ,PRCKY3
            JR      PRCKYE
PRCKY3:     CP      HOMEKEY                                              ; HOME
            JR      NZ,PRCKY4
            JR      GETKY2
PRCKY4:     CP      CLRKEY                                               ; CLR
            JR      NZ,PRCKY5
            JR      GETKY2
PRCKY5:     CP      INSERT                                               ; INSERT
            JR      NZ,PRCKY6
            JR      GETKY2
PRCKY6:     CP      DBLZERO                                              ; 00
            JR      NZ,PRCKY7
            LD      A,'0'
            LD      (KEYBUF),A                                           ; Place a character into the keybuffer so we double up on 0
            JR      PRCKYX
PRCKY7:     CP      BREAKKEY                                             ; Break key processing.
            JR      NZ,PRCKY8

PRCKY8:
PRCKYX:    
PRCKYE:    
            POP     HL
            RET

            ;-------------------------------------------------------------------------------
            ; END OF KEYBOARD FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF SCREEN FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; CR PAGE MODE1
.CR:        CALL    .MANG
            RRCA    
            JP      NC,CURS2
            LD      L,000H
            INC     H
            CP      ROW - 1                                              ; End of line?
            JR      Z,.CP1                 
            INC     H
            JP      CURS1

.CP1:       LD      (DSPXY),HL

            ; SCROLLER
.SCROL:     LD      BC,SCRNSZ - COLW                                     ; Scroll COLW -1 lines
            LD      DE,SCRN                                              ; Start of the screen.
            LD      HL,SCRN + COLW                                       ; Start of screen + 1 line.
            PUSH    BC                                                   ; 1000 STORE
            LDIR    
            POP     BC
            PUSH    DE
            LD      DE,SCRN + 800H                                       ; COLOR RAM SCROLL
            LD      HL,SCRN + 800H + COLW                                ; SCROLL TOP + 1 LINE
            LDIR    
            LD      B,COLW                                               ; ONE LINE
            EX      DE,HL
            IF      MODE80C = 0
              LD    A,071H                                               ; Black background, white characters. Bit 7 is clear as a write to bit 7 @ DFFFH selects 40Char mode.
            ELSE
              LD    A,071H                                               ; Blue background, white characters in colour mode. Bit 7 is set as a write to bit 7 @ DFFFH selects 80Char mode.
            ENDIF
           ;LD      A,71H                                                ; COLOR RAM INITIAL DATA
            CALL    DINT
            POP     HL
            LD      B,COLW
            CALL    CLER                                                 ; LAST LINE CLEAR
            LD      BC,ROW + 1                                           ; ROW NUMBER+1
            LD      DE,MANG                                              ; LOGICAL MANAGEMENT
            LD      HL,MANG+1
            LDIR    
            LD      (HL),0
            LD      A,(MANG)
            OR      A
            JP      Z,RSTR
            LD      HL,DSPXY+1
            DEC     (HL)
            JR      .SCROL

DPCT:       PUSH    AF                                                   ; Display control, character is mapped to a function call.
            PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      B,A
            AND     0F0H
            CP      0C0H
            JP      NZ,RSTR
            XOR     B
            RLCA    
            LD      C,A
            LD      B,000H
            LD      HL,.CTBL
DPCT1:      ADD     HL,BC
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            EX      DE,HL
            JP      (HL)


PRT:        LD      A,C
            CALL    ADCN
            LD      C,A
            AND     0F0H
            CP      0F0H
            RET     Z

            CP      0C0H
            LD      A,C
            JR      NZ,PRNT3                
PRNT5:      CALL    DPCT
            CP      0C3H
            JR      Z,PRNT4                 
            CP      0C5H
            JR      Z,PRNT2                 
            CP      0CDH                   ; CR
            JR      Z,PRNT2                 
            CP      0C6H
            RET     NZ

PRNT2:      XOR     A
PRNT2A:     LD      (DPRNT),A
            RET     

PRNT3:      CALL    DSP
PRNT4:      LD      A,(DPRNT)
            INC     A
            CP      COLW*2                 ; 050H
            JR      C,PRNT4A                 
            SUB     COLW*2                 ; 050H
PRNT4A:     JR      PRNT2A                   

NL:         LD      A,(DPRNT)
            OR      A
            RET     Z

LTNL:       LD      A,0CDH
            JR      PRNT5                   
PRTT:       CALL    PRTS
            LD      A,(DPRNT)
            OR      A
            RET     Z

L098C:      SUB     00AH
            JR      C,PRTT                 
            JR      NZ,L098C                
            RET     

            ; Function to disable the cursor display.
            ;
CURSOROFF:  DI
            CALL    CURSRSTR                                             ; Restore character under the cursor.
            LD      HL,FLASHCTL                                          ; Indicate cursor is now off.
            RES     7,(HL)
            EI
            RET

            ;
            ; Function to enable the cursor display.
            ;
CURSORON:   DI
            CALL    DSPXYTOADDR                                          ; Update the screen address for where the cursor should appear.
            LD      HL,FLASHCTL                                          ; Indicate cursor is now on.
            SET     7,(HL)
            EI
            RET

            ;
            ; Function to restore the character beneath the cursor iff the cursor is being dislayed.
            ;
CURSRSTR:   PUSH    HL
            PUSH    AF
            LD      HL,FLASHCTL                                          ; Check to see if there is a cursor at the current screen location.
            BIT     6,(HL)
            JR      Z,CURSRSTR1
            RES     6,(HL)
            LD      HL,(DSPXYADDR)                                       ; There is so we must restore the original character before further processing.
            LD      A,(FLASH)
            LD      (HL),A
CURSRSTR1:  POP     AF
            POP     HL
            RET

            ;
            ; Function to convert XY co-ordinates to a physical screen location and save.
            ;
DSPXYTOADDR:PUSH    HL
            PUSH    DE
            PUSH    BC
            LD      BC,(DSPXY)                                           ; Calculate the new cursor position based on the XY coordinates.
            LD      DE,COLW
            LD      HL,SCRN - COLW
DSPXYTOA1:  ADD     HL,DE
            DEC     B
            JP      P,DSPXYTOA1
            LD      B,000H
            ADD     HL,BC
            RES     3,H
            LD      (DSPXYADDR),HL                                       ; Store the new address.
            LD      A,(HL)                                               ; Store the new character.
            LD      (FLASH),A
DSPXYTOA2:  POP     BC
            POP     DE
            POP     HL
            RET

            ;
            ; Function to print a space.
            ;
PRTS:       LD      A,020H

            ; Function to print a character to the screen. If the character is a control code it is processed as necessary
            ; otherwise the character is converted from ASCII display and displayed.
            ;
PRNT:       DI
            CALL    CURSRSTR                                             ; Restore char under cursor.
            CP      00DH
            JR      Z,NEWLINE                 
            CP      00AH
            JR      Z,NEWLINE                 
            CP      07FH
            JR      Z,DELCHR
            CP      BACKS
            JR      Z,DELCHR
            PUSH    BC
            LD      C,A
            LD      B,A
            CALL    PRT
            LD      A,B
            POP     BC
PRNT1:      CALL    DSPXYTOADDR
            EI
            RET     

            ; Delete a character on screen.
DELCHR:     LD      A,0C7H
            CALL    DPCT
            JR      PRNT1

NEWLINE:    CALL    NL
            JR      PRNT1

            ;

            ;
            ; Function to print out the contents of HL as 4 digit Hexadecimal.
            ;
PRTHL:      LD      A,H
            CALL    PRTHX
            LD      A,L
            JR      PRTHX                   
            RET

            ;
            ; Function to print out the contents of A as 2 digit Hexadecimal
            ;
PRTHX:      PUSH    AF
            RRCA    
            RRCA    
            RRCA    
            RRCA    
            CALL    ASC
            CALL    PRNT
            POP     AF
            CALL    ASC
            JP      PRNT

ASC:        AND     00FH
            CP      00AH
            JR      C,NOADD                 
            ADD     A,007H
NOADD:      ADD     A,030H
            RET     

;CLR8Z:      XOR     A
;            LD      BC,00800H
;            PUSH    DE
;            LD      D,A
;L09E8:      LD      (HL),D
;            INC     HL
;            DEC     BC
;            LD      A,B
;            OR      C
;            JR      NZ,L09E8                
;            POP     DE
;            RET   

REV:        LD      HL,REVFLG
            LD      A,(HL)
            OR      A
            CPL     
            LD      (HL),A
            JR      Z,REV1                 
            LD      A,(INVDSP)
            JR      REV2                   
REV1:       LD      A,(NRMDSP)
REV2:       JP      RSTR

.MANG:      LD      HL,MANG
.MANG2:     LD      A,(DSPXY + 1)
            ADD     A,L
            LD      L,A
            LD      A,(HL)
            INC     HL
            RL      (HL)
            OR      (HL)
            RR      (HL)
            RRCA    
            EX      DE,HL
            LD      HL,(DSPXY)
            RET     

L09C7:      PUSH    DE
            PUSH    HL
            LD      HL,PBIAS
            XOR     A
            RLD     
            LD      D,A
            LD      E,(HL)
            RRD     
            XOR     A
            RR      D
            RR      E
            LD      HL,SCRN
            ADD     HL,DE
            LD      (PAGETP),HL
            POP     HL
            POP     DE
            RET

DSP:        PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      B,A
            CALL    PONT
            LD      (HL),B
            LD      HL,(DSPXY)
            LD      A,L
DSP01:      CP      COLW - 1                ; End of line.
            JP      NZ,CURSR                
            CALL    .MANG
            JR      C,CURSR                 
.DSP03:     EX      DE,HL
            LD      (HL),001H
            INC     HL
            LD      (HL),000H
            JP      CURSR

CURSD:      LD      HL,(DSPXY)
            LD      A,H
            CP      ROW - 1
            JR      Z,CURS4                 
            INC     H
CURS1:                                ;CALL    MGP.I
CURS3:      LD      (DSPXY),HL
            JR      RSTR                   

CURSU:      LD      HL,(DSPXY)
            LD      A,H
            OR      A
            JR      Z,CURS5                 
            DEC     H
CURSU1:     JR      CURS3                   

CURSR:      LD      HL,(DSPXY)
            LD      A,L
            CP      COLW - 1                ; End of line
            JR      NC,CURS2                
            INC     L
            JR      CURS3                   
CURS2:      LD      L,000H
            INC     H
            LD      A,H
            CP      ROW 
            JR      C,CURS1                 
            LD      H,ROW - 1
            LD      (DSPXY),HL
CURS4:      JP      .SCROL

CURSL:      LD      HL,(DSPXY)
            LD      A,L
            OR      A
            JR      Z,CURS5A                 
            DEC     L
            JR      CURS3                   
CURS5A:     LD      L,COLW - 1              ; End of line
            DEC     H
            JP      P,CURSU1
            LD      H,000H
            LD      (DSPXY),HL
CURS5:      JR      RSTR

CLRS:       LD      HL,MANG
            LD      B,01BH
            CALL    CLER
            LD      HL,SCRN
            PUSH    HL
            CALL    CLR8Z
            IF      MODE80C = 0
              LD    A,071H                                                   ; Black background, white characters. Bit 7 is clear as a write to bit 7 @ DFFFH selects 40Char mode.
            ELSE
              LD    A,071H                                                   ; Blue background, white characters in colour mode. Bit 7 is set as a write to bit 7 @ DFFFH selects 80Char mode.
            ENDIF
           ;LD      A,71H                                                    ; COLOR DATA
            CALL    CLR8                                                     ; D800H-DFFFH CLEAR            
            POP     HL
CLRS1:      LD      A,(SCLDSP)
HOM0:       LD      HL,00000H
            JP      CURS3

RSTR:       POP     HL
RSTR1:      POP     DE
            POP     BC
            POP     AF
            RET     

DEL:        LD      HL,(DSPXY)
            LD      A,H
            OR      L
            JR      Z,RSTR                 
            LD      A,L
            OR      A
            JR      NZ,DEL1                
            CALL    .MANG
            JR      C,DEL1                 
            CALL    PONT
            DEC     HL
            LD      (HL),000H
            JR      CURSL                   
DEL1:       CALL    .MANG
            RRCA    
            LD      A,COLW
            JR      NC,L0F13                
            RLCA    
L0F13:      SUB     L
            LD      B,A
            CALL    PONT
            PUSH    HL
            POP     DE
            DEC     DE
            SET     4,D
DEL2:       RES     3,H
            RES     3,D
            LD      A,(HL)
            LD      (DE),A
            INC     HL
            INC     DE
            DJNZ    DEL2                   
            DEC     HL
            LD      (HL),000H
            JP      CURSL

INST:       CALL    .MANG
            RRCA    
            LD      L,COLW - 1              ; End of line
            LD      A,L
            JR      NC,INST1A                
            INC     H
INST1A:     CALL    PNT1
            PUSH    HL
            LD      HL,(DSPXY)
            JR      NC,INST2                
            LD      A,(COLW*2)-1            ; 04FH
INST2:      SUB     L
            LD      B,A
            POP     DE
            LD      A,(DE)
            OR      A
            JR      NZ,RSTR                
            CALL    PONT
            LD      A,(HL)
            LD      (HL),000H
INST1:      INC     HL
            RES     3,H
            LD      E,(HL)
            LD      (HL),A
            LD      A,E
            DJNZ    INST1                   
            JR      RSTR                   

PONT:       LD      HL,(DSPXY)
PNT1:       PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            POP     BC
            LD      DE,COLW
            LD      HL,SCRN - COLW
PNT2:       ADD     HL,DE
            DEC     B
            JP      P,PNT2
            LD      B,000H
            ADD     HL,BC
            RES     3,H
            POP     DE
            POP     BC
            POP     AF
            RET     

CLER:       XOR     A
            JR      DINT                   
CLRFF:      LD      A,0FFH
DINT:       LD      (HL),A
            INC     HL
            DJNZ    DINT                   
            RET     

ADCN:       PUSH    BC
            PUSH    HL
            LD      HL,ATBL      ;00AB5H
            LD      C,A
            LD      B,000H
            ADD     HL,BC
            LD      A,(HL)
            JR      DACN3                   

DACN:       PUSH    BC
            PUSH    HL
            PUSH    DE
            LD      HL,ATBL
            LD      D,H
            LD      E,L
            LD      BC,00100H
            CPIR    
            JR      Z,DACN1                 
            LD      A,0F0H
DACN2:      POP     DE
DACN3:      POP     HL
            POP     BC
            RET     

DACN1:      OR      A
            DEC     HL
            SBC     HL,DE
            LD      A,L
            JR      DACN2     

            ; CTBL PAGE MODE1
.CTBL:      DW      .SCROL
            DW      CURSD
            DW      CURSU
            DW      CURSR
            DW      CURSL
            DW      HOM0
            DW      CLRS
            DW      DEL
            DW      INST
            DW      RSTR
            DW      RSTR
            DW      RSTR
            DW      REV
            DW      .CR
            DW      RSTR
            DW      RSTR

; ASCII TO DISPLAY CODE TABLE
ATBL:       DB      0CCH   ; NUL '\0' (null character)     
            DB      0E0H   ; SOH (start of heading)     
            DB      0F2H   ; STX (start of text)        
            DB      0F3H   ; ETX (end of text)          
            DB      0CEH   ; EOT (end of transmission)  
            DB      0CFH   ; ENQ (enquiry)              
            DB      0F6H   ; ACK (acknowledge)          
            DB      0F7H   ; BEL '\a' (bell)            
            DB      0F8H   ; BS  '\b' (backspace)       
            DB      0F9H   ; HT  '\t' (horizontal tab)  
            DB      0FAH   ; LF  '\n' (new line)        
            DB      0FBH   ; VT  '\v' (vertical tab)    
            DB      0FCH   ; FF  '\f' (form feed)       
            DB      0FDH   ; CR  '\r' (carriage ret)    
            DB      0FEH   ; SO  (shift out)            
            DB      0FFH   ; SI  (shift in)                
            DB      0E1H   ; DLE (data link escape)        
            DB      0C1H   ; DC1 (device control 1)     
            DB      0C2H   ; DC2 (device control 2)     
            DB      0C3H   ; DC3 (device control 3)     
            DB      0C4H   ; DC4 (device control 4)     
            DB      0C5H   ; NAK (negative ack.)        
            DB      0C6H   ; SYN (synchronous idle)     
            DB      0E2H   ; ETB (end of trans. blk)    
            DB      0E3H   ; CAN (cancel)               
            DB      0E4H   ; EM  (end of medium)        
            DB      0E5H   ; SUB (substitute)           
            DB      0E6H   ; ESC (escape)               
            DB      0EBH   ; FS  (file separator)       
            DB      0EEH   ; GS  (group separator)      
            DB      0EFH   ; RS  (record separator)     
            DB      0F4H   ; US  (unit separator)       
            DB      000H   ; SPACE                         
            DB      061H   ; !                             
            DB      062H   ; "                          
            DB      063H   ; #                          
            DB      064H   ; $                          
            DB      065H   ; %                          
            DB      066H   ; &                          
            DB      067H   ; '                          
            DB      068H   ; (                          
            DB      069H   ; )                          
            DB      06BH   ; *                          
            DB      06AH   ; +                          
            DB      02FH   ; ,                          
            DB      02AH   ; -                          
            DB      02EH   ; .                          
            DB      02DH   ; /                          
            DB      020H   ; 0                          
            DB      021H   ; 1                          
            DB      022H   ; 2                          
            DB      023H   ; 3                          
            DB      024H   ; 4                          
            DB      025H   ; 5                          
            DB      026H   ; 6                          
            DB      027H   ; 7                          
            DB      028H   ; 8                          
            DB      029H   ; 9                          
            DB      04FH   ; :                          
            DB      02CH   ; ;                          
            DB      051H   ; <                          
            DB      02BH   ; =                          
            DB      057H   ; >                          
            DB      049H   ; ?                          
            DB      055H   ; @
            DB      001H   ; A
            DB      002H   ; B
            DB      003H   ; C
            DB      004H   ; D
            DB      005H   ; E
            DB      006H   ; F
            DB      007H   ; G
            DB      008H   ; H
            DB      009H   ; I
            DB      00AH   ; J
            DB      00BH   ; K
            DB      00CH   ; L
            DB      00DH   ; M
            DB      00EH   ; N
            DB      00FH   ; O
            DB      010H   ; P
            DB      011H   ; Q
            DB      012H   ; R
            DB      013H   ; S
            DB      014H   ; T
            DB      015H   ; U
            DB      016H   ; V
            DB      017H   ; W
            DB      018H   ; X
            DB      019H   ; Y
            DB      01AH   ; Z
            DB      052H   ; [
            DB      059H   ; \  '\\'
            DB      054H   ; ]
            DB      0BEH   ; ^
            DB      03CH   ; _
            DB      0C7H   ; `
            DB      081H   ; a
            DB      082H   ; b
            DB      083H   ; c
            DB      084H   ; d
            DB      085H   ; e
            DB      086H   ; f
            DB      087H   ; g
            DB      088H   ; h
            DB      089H   ; i
            DB      08AH   ; j
            DB      08BH   ; k
            DB      08CH   ; l
            DB      08DH   ; m
            DB      08EH   ; n
            DB      08FH   ; o
            DB      090H   ; p
            DB      091H   ; q
            DB      092H   ; r
            DB      093H   ; s
            DB      094H   ; t
            DB      095H   ; u
            DB      096H   ; v
            DB      097H   ; w
            DB      098H   ; x
            DB      099H   ; y
            DB      09AH   ; z
            DB      0BCH   ; {
            DB      080H   ; |
            DB      040H   ; }
            DB      0A5H   ; ~
            DB      0C0H   ; DEL
            DB      040H  
            DB      0BDH
            DB      09DH
            DB      0B1H
            DB      0B5H
            DB      0B9H
            DB      0B4H
            DB      09EH
            DB      0B2H
            DB      0B6H
            DB      0BAH
            DB      0BEH
            DB      09FH
            DB      0B3H
            DB      0B7H
            DB      0BBH
            DB      0BFH
            DB      0A3H
            DB      085H
            DB      0A4H
            DB      0A5H
            DB      0A6H
            DB      094H
            DB      087H
            DB      088H
            DB      09CH
            DB      082H
            DB      098H
            DB      084H
            DB      092H
            DB      090H
            DB      083H
            DB      091H
            DB      081H
            DB      09AH
            DB      097H
            DB      093H
            DB      095H
            DB      089H
            DB      0A1H
            DB      0AFH
            DB      08BH
            DB      086H
            DB      096H
            DB      0A2H
            DB      0ABH
            DB      0AAH
            DB      08AH
            DB      08EH
            DB      0B0H
            DB      0ADH
            DB      08DH
            DB      0A7H
            DB      0A8H
            DB      0A9H
            DB      08FH
            DB      08CH
            DB      0AEH
            DB      0ACH
            DB      09BH
            DB      0A0H
            DB      099H
            DB      0BCH
            DB      0B8H
            DB      080H
            DB      03BH
            DB      03AH
            DB      070H
            DB      03CH
            DB      071H
            DB      05AH
            DB      03DH
            DB      043H
            DB      056H
            DB      03FH
            DB      01EH
            DB      04AH
            DB      01CH
            DB      05DH
            DB      03EH
            DB      05CH
            DB      01FH
            DB      05FH
            DB      05EH
            DB      037H
            DB      07BH
            DB      07FH
            DB      036H
            DB      07AH
            DB      07EH
            DB      033H
            DB      04BH
            DB      04CH
            DB      01DH
            DB      06CH
            DB      05BH
            DB      078H
            DB      041H
            DB      035H
            DB      034H
            DB      074H
            DB      030H
            DB      038H
            DB      075H
            DB      039H
            DB      04DH
            DB      06FH
            DB      06EH
            DB      032H
            DB      077H
            DB      076H
            DB      072H
            DB      073H
            DB      047H
            DB      07CH
            DB      053H
            DB      031H
            DB      04EH
            DB      06DH
            DB      048H
            DB      046H
            DB      07DH
            DB      044H
            DB      01BH
            DB      058H
            DB      079H
            DB      042H
            DB      060H
            DB      0FDH
            DB      0CBH
            DB      000H
            DB      01EH
            ;-------------------------------------------------------------------------------
            ; END OF SCREEN FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;----------------------------------------
            ;
            ;    ANSI EMULATION
            ;
            ;    Emulate the Ansi standard
            ;    N.B. Turned on when Chr
            ;         27 recieved.
            ;    Entry - A = Char
            ;    Exit  - None
            ;    Used  - None
            ;
            ;----------------------------------------
ANSITERM:   PUSH    HL
            PUSH    DE
            PUSH    BC
            PUSH    AF
            LD      C,A                                                  ; Move character into C for safe keeping
            ;
            LD      A,(ANSIMODE)
            OR      A
            JR      NZ,ANSI2
            LD      A,C
            CP      27
            JP      NZ,NOTANSI                                           ; If it is Chr 27 then we haven't just
                                                                         ; been turned on, so don't bother with
                                                                         ; all the checking.
            LD      A,1                                                  ; Turn on.
            LD      (ANSIMODE),A
            JP      AnsiMore

ANSI2:      LD      A,(CHARACTERNO)                                      ; CHARACTER number in sequence
            OR      A                                                    ; Is this the first character?
            JP      Z,AnsiFirst                                          ; Yes, deal with this strange occurance!

            LD      A,C                                                  ; Put character back in C to check

            CP      ";"                                                  ; Is it a semi colon?
            JP      Z,AnsiSemi
    
            CP      "0"                                                  ; Is it a number?
            JR      C,ANSI_NN                                            ; If <0 then no
            CP      "9"+1                                                ; If >9 then no
            JP      C,AnsiNumber

ANSI_NN:    CP      "?"                                                  ; Simple trap for simple problem!
            JP      Z,AnsiMore

            CP      "@"                                                  ; Is it a letter?
            JP      C,ANSIEXIT                                           ; Abandon if not letter; something wrong

ANSIFOUND:  CALL    CURSRSTR                                             ; Restore any character under the cursor.
            LD      HL,(NUMBERPOS)                                       ; Get value of number buffer
            LD      A,(HAVELOADED)                                       ; Did we put anything in this byte?
            OR      A
            JR      NZ,AF1
            LD      (HL),255                                             ; Mark the fact that nothing was put in
AF1:        INC      HL
            LD      A,254
            LD      (HL),A                                               ; Mark end of sequence (for unlimited length sequences)

            ;Disable cursor as unwanted side effects such as screen flicker may occur.
            LD      A,(FLASHCTL)
            BIT     7,A
            CALL    NZ,CURSOROFF

            XOR     A
            LD      (CURSORCOUNT),A                                      ; Restart count
            LD      A,0C9h
            LD      (CHGCURSMODE),A                                      ; Disable flashing temp.

            LD      HL,NUMBERBUF                                         ; For the routine called.
            LD      A,C                                                  ; Restore number
            ;
            ;    Now work out what happens...
            ;
            CP      "A"                                                  ; Check for supported Ansi characters
            JP      Z,CUU                                                ; Upwards
            CP      "B"
            JP      Z,CUD                                                ; Downwards
            CP      "C"
            JP      Z,CUF                                                ; Forward
            CP      "D"
            JP      Z,CUB                                                ; Backward
            CP      "H"
            JP      Z,CUP                                                ; Locate
            CP      "f"
            JP      Z,HVP                                                ; Locate
            CP      "J"
            JP      Z,ED                                                 ; Clear screen
            CP      "m"
            JP      Z,SGR                                                ; Set graphics renditon
            CP      "K"
            JP      Z,EL                                                 ; Clear to end of line
            CP      "s"
            JP      Z,SCP                                                ; Save the cursor position
            CP      "u"
            JP      Z,RCP                                                ; Restore the cursor position

ANSIEXIT:   CALL    CURSORON                                             ; If t
            LD      HL,NUMBERBUF                                         ; Numbers buffer position
            LD      (NUMBERPOS),HL
            XOR     A
            LD      (CHARACTERNO),A                                      ; Next time it runs, it will be the
                                                                         ; first character
            LD      (HAVELOADED),A                                       ; We haven't filled this byte!
            LD      (CHGCURSMODE),A                                      ; Cursor allowed back again!
            XOR     A
            LD      (ANSIMODE),A
            JR      AnsiMore
NOTANSI:    CP      000h                                                 ; Filter unprintable characters.
            JR      Z,AnsiMore
            CALL    PRNT
AnsiMore:   POP     AF
            POP     BC
            POP     DE
            POP     HL
            RET

            ;
            ;    The various routines needed to handle the filtered characters
            ;
AnsiFirst:  LD      A,255
            LD      (CHARACTERNO),A                                      ; Next character is not first!
            LD      A,C                                                  ; Get character back
            LD      (ANSIFIRST),A                                        ; Save first character to check later
            CP      "("                                                  ; ( and [ have characters to follow
            JP      Z,AnsiMore                                           ; and are legal.
            CP      "["
            JP      Z,AnsiMore
            CP      09Bh                                                 ; CSI
            JP      Z,AnsiF1                                             ; Pretend that "[" was first ;-)
            JP      ANSIEXIT                                             ; = and > don't have anything to follow
                                                                         ; them but are legal.  
                                                                         ; Others are illegal, so abandon anyway.
AnsiF1:     LD      A,"["                                                ; Put a "[" for first character
            LD      (ANSIFIRST),A
            JP      ANSIEXIT

AnsiSemi:   LD      HL,(NUMBERPOS)                                       ; Move the number pointer to the
            LD      A,(HAVELOADED)                                       ; Did we put anything in this byte?
            OR      A
            JR      NZ,AS1
            LD      (HL),255                                             ; Mark the fact that nothing was put in
AS1:        INC     HL                                                   ; move to next byte
            LD      (NUMBERPOS),HL
            XOR     A
            LD      (HAVELOADED),A                                       ; New byte => not filled!
            JP      AnsiMore

AnsiNumber: LD      HL,(NUMBERPOS)                                       ; Get address for number
            LD      A,(HAVELOADED)
            OR      A                                                    ; If value is zero
            JR      NZ,AN1
            LD      A,C                                                  ; Get value into A
            SUB     "0"                                                  ; Remove ASCII offset
            LD      (HL),A                                               ; Save and Exit
            LD      A,255
            LD      (HAVELOADED),A                                       ; Yes, we _have_ put something in!
            JP      AnsiMore

AN1:        LD      A,(HL)                                               ; Stored value in A; TBA in C
            ADD     A,A                                                  ; 2 *
            LD      D,A                                                  ; Save the 2* for later
            ADD     A,A                                                  ; 4 *
            ADD     A,A                                                  ; 8 *
            ADD     A,D                                                  ; 10 *
            ADD     A,C                                                  ; 10 * + new num
            SUB     "0"                                                  ; And remove offset from C value!
            LD      (HL),A                                               ; Save and Exit.
            JP      AnsiMore                                             ; Note routine will only work up to 100
                                                                         ; which should be okay for this application.

            ;--------------------------------
            ;    GET NUMBER
            ;
            ;    Gets the next number from
            ;    the list
            ;
            ;    Entry - HL = address to get
            ;            from
            ;    Exit  - HL = next address
            ;        A  = value
            ;        IF a=255 then default value
            ;        If a=254 then end of sequence
            ;    Used  - None
            ;--------------------------------
GetNumber:  LD      A,(HL)                                               ; Get number
            CP      254
            RET     Z                                                    ; Return if end of sequence,ie still point to
                                                                         ; end
            INC     HL                                                   ; Return pointing to next byte
            RET                                                          ; Else next address and return

            ;***    ANSI UP
            ;
CUU:        CALL    GetNumber                                            ; Number into A
            LD      B,A                                                  ; Save value into B
            CP      255
            JR      NZ,CUUlp
            LD      B,1                                                  ; Default value
CUUlp:      LD      A,(DSPXY+1)                                          ; A <- Row
            CP      B                                                    ; Is it too far?
            JR      C,CUU1
            SUB     B                                                    ; No, then go back that far.
            JR      CUU2
CUU1:       LD      A,0                                                  ; Make the choice, top line.
CUU2:       LD      (DSPXY+1),A                                          ; Row <- A
            JP      ANSIEXIT

            ;***    ANSI DOWN
            ;
CUD:        LD      A,(ANSIFIRST)
            CP      "["
            JP      NZ,ANSIEXIT                                          ; Ignore ESC(B
            CALL    GetNumber
            LD      B,A                                                  ; Save value in b
            CP      255
            JR      NZ,CUDlp
            LD      B,1                                                  ; Default
CUDlp:      LD      A,(DSPXY+1)                                          ; A <- Row
            ADD     A,B
            CP      ROW                                                  ; Too far?
            JP      C,CUD1
            LD      A,ROW-1                                              ; Too far then bottom of screen
CUD1:       LD      (DSPXY+1),A                                          ; Row <- A
            JP      ANSIEXIT

            ;***    ANSI RIGHT
            ;
CUF:        CALL    GetNumber                                            ; Number into A
            LD      B,A                                                  ; Value saved in B
            CP      255
            JR      NZ,CUFget
            LD      B,1                                                  ; Default
CUFget:     LD      A,(DSPXY)                                            ; A <- Column
            ADD     A,B                                                  ; Add movement.
            CP      80                                                   ; Too far?
            JR      C,CUF2
            LD      A,79                                                 ; Yes, right edge
CUF2:       LD      (DSPXY),A                                            ; Column <- A
            JP      ANSIEXIT

            ;***    ANSI LEFT
            ;
CUB:        CALL    GetNumber                                            ; Number into A
            LD      B,A                                                  ; Save value in B
            CP      255
            JR      NZ,CUBget
            LD      B,1                                                  ; Default
CUBget:     LD      A,(DSPXY)                                            ; A <- Column
            CP      B                                                    ; Too far?
            JR      C,CUB1a
            SUB     B
            JR      CUB1b
CUB1a:      LD      A,0
CUB1b:      LD      (DSPXY),A                                            ; Column <-A
            JP      ANSIEXIT

            ;***    ANSI LOCATE
            ;
HVP:
CUP:        CALL    GetNumber
            CP      255
            CALL    Z,DefaultLine                                        ; Default = 1
            CP      254                                                  ; Sequence End -> 1
            CALL    Z,DefaultLine
            CP      ROW+1                                                ; Out of range then don't move
            JP      NC,ANSIEXIT
            OR      A
            CALL    Z,DefaultLine                                        ; 0 means default, some strange reason
            LD      D,A
            CALL    GetNumber
            CP      255                                                  ; Default = 1
            CALL    Z,DefaultColumn
            CP      254                                                  ; Sequence End -> 1
            CALL    Z,DefaultColumn
            CP      81                                                   ; Out of range, then don't move
            JP      NC,ANSIEXIT
            OR      A
            CALL    Z,DefaultColumn                                      ; 0 means go with default
            LD      E,A
            EX      DE,HL
            DEC     H                                                    ; Translate from Ansi co-ordinates to hardware
            DEC     L                                                    ; co-ordinates
            LD      (DSPXY),HL                                           ; Set the cursor position.
            JP      ANSIEXIT

DefaultColumn:
DefaultLine:LD      A,1
            RET

            ;***    ANSI CLEAR SCREEN
            ;
ED:         CALL    GetNumber
            OR      A
            JP      Z,ED1                                                ; Zero means first option
            CP      254                                                  ; Also default
            JP      Z,ED1
            CP      255
            JP      Z,ED1
            CP      1
            JP      Z,ED2
            CP      2
            JP      NZ,ANSIEXIT

            ;***    Option 2
            ;
ED3:        LD      HL,0
            LD      (DSPXY),HL                                           ; Home the cursor
            LD      A,(JSW_FF)
            OR      A
            JP      NZ,ED_Set_LF
            CALL    CALCSCADDR
            CALL    CLRSCRN
            JP      ANSIEXIT

ED_Set_LF:  XOR     A                                                    ; Note simply so that
            LD      (JSW_LF),A                                           ; ESC[2J works the same as CTRL-L
            JP      ANSIEXIT

            ;***    Option 0
            ;
ED1:        LD      HL,(DSPXY)                                           ; Get and save cursor position
            LD      A,H
            OR      L
            JP      Z,ED3                                                ; If we are at the top of the
                                                                         ; screen and clearing to the bottom
                                                                         ; then we are clearing all the screen!
            PUSH    HL
            LD      A,ROW-1
            SUB     H                                                    ; ROW - Row
            LD      HL,0                                                 ; Zero start
            OR      A                                                    ; Do we have any lines to add?
            JR      Z,ED1_2                                              ; If no bypass that addition!
            LD      B,A                                                  ; Number of lines to count
            LD      DE,80
ED1_1:      ADD     HL,DE
            DJNZ    ED1_1
ED1_2:      EX      DE,HL                                                ; Value into DE
            POP     HL
            LD      A,80
            SUB     L                                                    ; 80 - Columns
            LD      L,A                                                  ; Add to value before
            LD      H,0
            ADD     HL,DE
            PUSH    HL                                                   ; Value saved for later
            LD      HL,(DSPXY)                                           ; _that_ value again!
            POP     BC                                                   ; Number to blank
            CALL    CALCSCADDR
            CALL    CLRSCRN                                              ; Now do it!
            JP      ANSIEXIT                                             ; Then exit properly

            ;***    Option 1 - clear from cursor to beginning of screen
            ;
ED2:        LD      HL,(DSPXY)                                           ; Get and save cursor position
            PUSH    HL
            LD      A,H
            LD      HL,0                                                 ; Zero start
            OR      A                                                    ; Do we have any lines to add?
            JR      Z,ED2_2                                              ; If no bypass that addition!
            LD      B,A                                                  ; Number of lines
            LD      DE,80
ED2_1:      ADD     HL,DE
            DJNZ    ED2_1
ED2_2:      EX      DE,HL                                                ; Value into DE
            POP     HL
            LD      H,0
            ADD     HL,DE
            PUSH    HL                                                   ; Value saved for later
            LD      HL,0                                                 ; Find the begining!
            POP     BC                                                   ; Number to blank
            CALL    CLRSCRN                                              ; Now do it!
            JP      ANSIEXIT                                             ; Then exit properly

            ; ***    ANSI CLEAR LINE
            ;
EL:         CALL    GetNumber                                            ; Get value
            CP      0
            JP      Z,EL1                                                ; Zero & Default are the same
            CP      255
            JP      Z,EL1
            CP      254
            JP      Z,EL1
            CP      1
            JP      Z,EL2
            CP      2
            JP      NZ,ANSIEXIT                                          ; Otherwise don't do a thing

            ;***    Option 2 - clear entire line.
            ;
            LD      HL,(DSPXY)
            LD      L,0
            LD      (DSPXY),HL
            CALL    CALCSCADDR
            LD      BC,80                                                ; 80 bytes to clear (whole line)
            CALL    CLRSCRN
            JP      ANSIEXIT

            ;***    Option 0 - Clear from Cursor to end of line.
            ;
EL1:        LD      HL,(DSPXY)
            LD      A,80                                                 ; Calculate distance to end of line
            SUB     L
            LD      C,A
            LD      B,0
            LD      (DSPXY),HL
            PUSH HL
            POP DE
            CALL    CALCSCADDR
            CALL    CLRSCRN
            JP      ANSIEXIT

            ;***    Option 1 - clear from cursor to beginning of line.
            ;
EL2:        LD      HL,(DSPXY)
            LD      C,L                                                  ; BC = distance from start of line
            LD      B,0
            LD      L,0
            LD      (DSPXY),HL
            CALL    CALCSCADDR
            CALL    CLRSCRN
            JP      ANSIEXIT

            ; In HL = XY Pos
            ; Out   = Screen address.
CALCSCADDR: PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      A,H
            LD      B,H
            LD      C,L
            LD      HL,SCRN
            OR      A
            JR      Z,CALC3
            LD      DE,80
CALC2:      ADD     HL,DE
            DJNZ    CALC2
CALC3:      POP     DE
            ADD     HL,BC
            POP     DE
            POP     BC
            POP     AF
            RET

            ;    HL = address
            ;    BC = length
CLRSCRN:    PUSH    HL                                                   ; 1 for later!
            LD      D,H
            LD      E,L
            INC     DE                                                   ; DE <- HL +1
            PUSH    BC                                                   ; Save the value a little longer!
            XOR     A
            LD      (HL), A                                              ; Blank this area!
            LDIR                                                         ; *** just like magic ***
                                                                         ;     only I forgot it in 22a!
            POP     BC                                                   ; Restore values
            POP     HL
            LD      DE,2048                                              ; Move to attributes block
            ADD     HL,DE
            LD      D,H
            LD      E,L
            INC     DE                                                   ; DE = HL + 1
            LD      A,(FONTSET)                                          ; Save in the current values.
            LD      (HL),A
            LDIR
            RET
        
            ;***    ANSI SET GRAPHICS RENDITION
            ;
SGR:        CALL    GetNumber
            CP      254                                                  ; 254 signifies end of sequence
            JP      Z,ANSIEXIT
            OR      A
            CALL    Z,AllOff
            CP      255                                                  ; Default means all off
            CALL    Z,AllOff
            CP      1
            CALL    Z,BoldOn
            CP      2
            CALL    Z,BoldOff
            CP      4
            CALL    Z,UnderOn
            CP      5
            CALL    Z,ItalicOn
            CP      6
            CALL    Z,ItalicOn
            CP      7
            CALL    Z,InverseOn
            JP      SGR                                                  ; Code is re-entrant
        
            ;--------------------------------
            ;
            ;    RESET GRAPHICS
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
AllOff:     PUSH    AF                                                   ; Save registers
            LD      A,0C9h                                               ; = off
            LD      (BOLDMODE),A                                         ; Turn the flags off
            LD      (ITALICMODE),A
            LD      (UNDERSCMODE),A
            LD      (INVMODE),A
            LD      A,017h                                               ; Black background, white chars.
            LD      (FONTSET),A                                          ; Reset the bit map store
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN BOLD ON
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
BoldOn:     PUSH    AF                                                   ; Save register
            XOR     A                                                    ; 0 means on
            LD      (BOLDMODE),A
BOn1:       LD      A,(FONTSET)
            SET     0,A                                                  ; turn ON indicator flag
            LD      (FONTSET),A
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN BOLD OFF
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
BoldOff:    PUSH    AF                                                   ; Save register
            PUSH    BC
            LD      A,0C9h                                               ; &C9 means off
            LD      (BOLDMODE),A
BO1:        LD      A,(FONTSET)
            RES     0,A                                                  ; turn OFF indicator flag
            LD      (FONTSET),A
            POP     BC
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN ITALICS ON
            ;    (replaces flashing)
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
ItalicOn:   PUSH    AF                                                   ; Save AF
            XOR     A
            LD      (ITALICMODE),A                                       ; 0 means on
            LD      A,(FONTSET)
            SET     1,A                                                  ; turn ON indicator flag
            LD      (FONTSET),A
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN UNDERLINE ON
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
UnderOn:    PUSH    AF                                                   ; Save register
            XOR     A                                                    ; 0 means on
            LD      (UNDERSCMODE),A
            LD      A,(FONTSET)
            SET     2,A                                                  ; turn ON indicator flag
            LD      (FONTSET),A
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN INVERSE ON
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
InverseOn:  PUSH    AF                                                   ; Save register
            XOR     A                                                    ; 0 means on
            LD      (INVMODE),A
            LD      A,(FONTSET)
            SET     3,A                                                  ; turn ON indicator flag
            LD     (FONTSET),A
            POP    AF                                                    ; Restore AF
            RET
        
            ;***    ANSI SAVE CURSOR POSITION
            ;
SCP:        LD      HL,(DSPXY)                                           ; (backup) <- (current)
            LD      (CURSORPSAV),HL
            JP      ANSIEXIT
        
            ;***    ANSI RESTORE CURSOR POSITION
            ;
RCP:        LD      HL,(CURSORPSAV)                                      ; (current) <- (backup)
            LD      (DSPXY),HL
            JP      ANSIEXIT

            ;-------------------------------------------------------------------------------
            ; END OF ANSI TERMINAL FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF STATIC LOOKUP TABLES AND CONSTANTS
            ;-------------------------------------------------------------------------------

            ; Disk Parameter Header template.
DPBTMPL:    DW      0000H, 0000H, 0000H, 0000H, CDIRBUF


            ;--------------------------------------
            ; Test Message table
            ;--------------------------------------

CBIOSSIGNON:DB      "** C-BIOS v1.10, (C) P.D. Smart, 2020. Drives:",                  NUL
CBIOSIGNEND:DB       " **",                                                    CR,     NUL
CPMSIGNON:  DB      "CP/M v2.23 (64K) COPYRIGHT(C) 1979, DIGITAL RESEARCH",    CR, LF, NUL
SDAVAIL:    DB      "SD",                                                              NUL
FDCAVAIL:   DB      "FDC",                                                             NUL
NOBDOS:     DB      "I/O Processor failed to load BDOS, aborting!",            CR, LF, NUL
SVCRESPERR: DB      "I/O Response Error, time out!",                           CR,     NUL
SVCIOERR:   DB      "I/O Error, time out!",                                    CR,     NUL

LOADERR:    DB      "DISK ERROR - LOADING",         CR, NUL
SELDRVMSG:  DB      "DISK ERROR - SELECT",          CR, NUL
WAITRDYMSG: DB      "DISK ERROR - WAIT",            CR, NUL
DSKSEEKMSG: DB      "DISK ERROR - SEEK",            CR, NUL
RETRIESMSG: DB      "DISK ERROR - RETRIES",         CR, NUL
DATAOVRMSG: DB      "DISK ERROR - DATA OVERRUN",    CR, NUL
CRCERRMSG:  DB      "DISK ERROR - CRC ERROR",       CR, NUL

            ;-------------------------------------------------------------------------------
            ; END OF STATIC LOOKUP TABLES AND CONSTANTS
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF DEBUGGING FUNCTIONALITY
            ;-------------------------------------------------------------------------------
            ; Debug routine to print out all registers and dump a section of memory for analysis.
            ;
DEBUG:      IF ENADEBUG = 1
            LD      (DBGSTACKP),SP
            LD      SP,DBGSTACK
            ;
            PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            PUSH    AF
            PUSH    HL
            PUSH    DE
            PUSH    BC
            PUSH    AF
            LD      DE, INFOMSG
            CALL    MONPRTSTR
            POP     BC
            LD      A,B
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            LD      DE, INFOMSG2
            CALL    MONPRTSTR
            POP     BC
            LD      A,B
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            LD      DE, INFOMSG3
            CALL    MONPRTSTR
            POP     DE
            LD      A,D
            CALL    PRTHX
            LD      A,E
            CALL    PRTHX
            LD      DE, INFOMSG4
            CALL    MONPRTSTR
            POP     HL
            LD      A,H
            CALL    PRTHX
            LD      A,L
            CALL    PRTHX
            LD      DE, INFOMSG5
            CALL    MONPRTSTR
            LD      HL,(DBGSTACKP)
            LD      A,H
            CALL    PRTHX
            LD      A,L
            CALL    PRTHX
            CALL    NL

            LD      DE, DRVMSG
            CALL    MONPRTSTR
            LD      A, (CDISK)
            CALL    PRTHX

            LD      DE, FDCDRVMSG
            CALL    MONPRTSTR
            LD      A, (FDCDISK)
            CALL    PRTHX
           
            LD      DE, SEKTRKMSG
            CALL    MONPRTSTR
            LD      BC,(SEKTRK)
            LD      A,B
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            CALL    PRTS 
            LD      A,(SEKSEC)
            CALL    PRTHX
            CALL    PRTS 
            LD      A,(SEKHST)
            CALL    PRTHX
           
            LD      DE, HSTTRKMSG
            CALL    MONPRTSTR
            LD      BC,(HSTTRK)
            LD      A,B
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            CALL    PRTS 
            LD      A,(HSTSEC)
            CALL    PRTHX
           
            LD      DE, UNATRKMSG
            CALL    MONPRTSTR
            LD      BC,(UNATRK)
            LD      A,B
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            CALL    PRTS 
            LD      A,(UNASEC)
            CALL    PRTHX
           
            LD      DE, CTLTRKMSG
            CALL    MONPRTSTR
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            CALL    PRTHX
            CALL    PRTS 
            LD      A,(SECTORNO)
            CALL    PRTHX
           
            LD      DE, DMAMSG
            CALL    MONPRTSTR
            LD      BC,(DMAADDR)
            LD      A,B
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            CALL    NL
            ;
            POP     AF
            JR      C, SKIPDUMP
            ;
            LD      HL,DPBASE                                            ; Dump the startup vectors.
            LD      DE, 1000H
            ADD     HL, DE
            EX      DE,HL
            LD      HL,DPBASE
            CALL    DUMPX

            LD      HL,00000h                                            ; Dump the startup vectors.
            LD      DE, 00A0H
            ADD     HL, DE
            EX      DE,HL
            LD      HL,00000h
            CALL    DUMPX
           
            LD      HL,IBUFE                                             ; Dump the data area.
            LD      DE, 0300H 
            ADD     HL, DE
            EX      DE,HL
            LD      HL,IBUFE
            CALL    DUMPX

            LD      HL,CBASE                                             ; Dump the CCP + BDOS area.
            LD      DE,CPMBIOS - CBASE                                
            ADD     HL, DE
            EX      DE,HL
            LD      HL,CBASE
            CALL    DUMPX

SKIPDUMP:   ;JR SKIPDUMP
            POP     HL
            POP     DE
            POP     BC
            POP     AF
            ;
            LD      SP,(DBGSTACKP)
            RET

            ; HL = Start
            ; DE = End
DUMPX:      LD      A,10
DUM1:       LD      (TMPCNT),A
DUM3:       LD      B,010h
            LD      C,02Fh
            CALL    NLPHL
DUM2:       CALL    SPHEX
            INC     HL
            PUSH    AF
            LD      A,(DSPXY)
            ADD     A,C
            LD      (DSPXY),A
            POP     AF
            CP      020h
            JR      NC,L0D51
            LD      A,02Eh
L0D51:      CALL    PRNT
            LD      A,(DSPXY)
            INC     C
            SUB     C
            LD      (DSPXY),A
            DEC     C
            DEC     C
            DEC     C
            PUSH    HL
            SBC     HL,DE
            POP     HL
            JR      NC,DUM7
L0D78:      DJNZ    DUM2
            LD      A,(TMPCNT)
            DEC     A
            LD      (TMPCNT),A
            JR      NZ,DUM3
DUM4:       CALL    CHKKY
            CP      0FFH
            JR      NZ,DUM4
            CALL    GETKY
            CP      'D'
            JR      NZ,DUM5
            LD      A,8
            JR      DUM1
DUM5:       CP      'U'
            JR      NZ,DUM6
            PUSH    DE
            LD      DE,00100H
            OR      A
            SBC     HL,DE
            POP     DE
            LD      A,8
            JR      DUM1
DUM6:       CP      'X'
            JR      Z,DUM7
            JR      DUMPX
DUM7:       CALL    NL
            RET

NLPHL:      CALL    NL
            CALL    PRTHL
            RET

            ; SPACE PRINT AND DISP ACC
            ; INPUT:HL=DISP. ADR.
SPHEX:      CALL    PRTS                        ; SPACE PRINT
            LD      A,(HL)
            CALL    PRTHX                       ; DSP OF ACC (ASCII)
            LD      A,(HL)
            RET   
           
            ; Debugger messages, bit cryptic but this is due to limited space on the screen.
            ;
DRVMSG:     DB      "DRV=",  000H
FDCDRVMSG:  DB      ",FDC=", 000H
SEKTRKMSG:  DB      ",S=",   000H
HSTTRKMSG:  DB      ",H=",   000H
UNATRKMSG:  DB      ",U=",   000H
CTLTRKMSG:  DB      ",C=",   000H
DMAMSG:     DB      ",DMA=", 000H
INFOMSG:    DB      "AF=",   NUL
INFOMSG2:   DB      ",BC=",  000H
INFOMSG3:   DB      ",DE=",  000H
INFOMSG4:   DB      ",HL=",  000H
INFOMSG5:   DB      ",SP=",  000H

            ; Seperate stack for the debugger so as not to affect anything it is reporting on.
            ;
DBGSTACKP:  DS      2
            DS      128, 0AAH
DBGSTACK:   EQU     $

            ALIGN   00400H
            ENDIF
            ;-------------------------------------------------------------------------------
            ; END OF DEBUGGING FUNCTIONALITY
            ;-------------------------------------------------------------------------------
