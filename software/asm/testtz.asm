i;--------------------------------------------------------------------------------------------------------
;-
;- Name:            testtz.asm
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

            INCLUDE "TESTTZ_Definitions.asm"
            INCLUDE "Macros.asm"



           ORG     10F0h

           ; Tape header (MZF) - this program is a loadable executable.
           DB      01h                                                                                     ; Code Type, 01 = Machine Code.
           DB      "TZTESTER V1.0", 0Dh, 00h, 00h, 00h                                                     ; Title/Name (17 bytes).
           DW      PGMEND - START                                                                          ; Size of program.
           DW      START                                                                                   ; Load address of program.
           DW      START                                                                                   ; Exec address of program.
           DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h          ; Comment (104 bytes).
           DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
           DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

           ORG     01200h

START:      DI                                                           ; Disable Interrupts and sat mode. NB. Interrupts are physically disabled by 8255 Port C2 set to low.
            IM      1
            ;
INIT1:      LD      SP,BOOTSTACK                                         ; Setup to use local stack until CPM takes over.
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
            LD      A,016H
            CALL    PRNT
            LD      A,017H                                               ; Blue background, white characters in colour mode. Bit 7 is set as a write to bit 7 @ DFFFH selects 80Char mode.
            LD      HL,ARAM
            CALL    CLR8
            LD      A,004H
            LD      (TEMPW),A                                            ; Setup the tempo for sound output.

INIT3:      ; Setup the initial cursor, for CAPSLOCK this is a double underscore.
            LD      A,080H                                               ; Cursor on (Bit D7=1).
            LD      (FLASHCTL),A

            ; Change to 80 character mode.
            LD      A, 128                                               ; 80 char mode.
            LD      (DSPCTL), A
            CALL    MLDSP
            CALL    NL
INIT4:      LD      DE,TESTTZSIGNON
            CALL    MONPRTSTR
            CALL    BEL                                                  ; Beep to indicate startup - for cases where screen is slow to startup.
            LD      A,0FFH
            LD      (SWRK),A

           ;
           ; Switch out the monitor and write to address 0000
           ;
TEST1:     LD      DE,MSGTEST1
           CALL    MONPRTSTR
           ;
           LD      HL,00000H
           LD      D,(HL)
           INC     HL
           LD      E,(HL)
           LD      (MONSTORE),DE
           ;
           LD      BC,0
TEST1A:    PUSH    BC
           OUT     (0E0H),A
           LD      HL,00000H
           LD      (HL),C
           INC     HL
           LD      (HL),B
           DEC     HL
           LD      E,(HL)
           INC     HL
           LD      D,(HL)
          ;JR      TEST1

           ; Page in the monitor and check print out the value from the RAM just paged out and the value in the monitor RAM to verify the bank switched.
           OUT     (0E4H),A
           LD      HL,00000H
           LD      A,(HL)
           LD      B,A
           INC     HL
           LD      A,(HL)
           LD      H,A
           LD      L,B
          ;JR      TEST1

           LD      A,H
           CP      D
           JR      Z,TEST1B1
           JR      TEST1B2
TEST1B1:   LD      A,L
           CP      E
           JR      NZ,TEST1B2
           ;
           LD      BC,(MONSTORE)                 ; Check that the byte isnt the last contents of the monitor rom.
           LD      A,B
           CP      H
           JR      NZ,TEST1E
           LD      A,C
           CP      L
           JR      NZ,TEST1E
           ;
TEST1B2:   PUSH    DE
           CALL    PRTHL
           CALL    PRTS        ; Print space.
           POP     DE
           EX      DE,HL
           CALL    PRTHL
           ;
           LD      A,0C4h      ; Move cursor left.
           LD      E,9         ; 9 times.
TEST1B:    CALL    DPCT
           DEC     E
           JR      NZ,TEST1B           
           ;
TEST1C:    POP     BC
           DEC     BC
           LD      A,B
           OR      C
           JR      NZ,TEST1A
           JP      DONE
           ;
TEST1E:    PUSH    DE
           CALL    PRTHL
           CALL    PRTS        ; Print space.
           POP     DE
           EX      DE,HL
           CALL    PRTHL
           ;
           LD      DE,MSGFAIL
           CALL    MONPRTSTR
           POP     HL
           PUSH    HL
           CALL    PRTHL
           CALL    NL
           ;
           LD      DE,(MONSTORE)
           LD      HL,00000H
           LD      (HL),E
           INC     HL
           LD      (HL),D
           JR      TEST1C

DONE:      LD      DE,MSGDONE
           CALL    MONPRTSTR
           JP      0E800H


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

TMPADR      DS      2                                                    ; TEMPORARY ADDRESS STORAGE
TMPSIZE     DS      2                                                    ; TEMPORARY SIZE
TMPCNT      DS      2                                                    ; TEMPORARY COUNTER
FLASHCTL:   DS      1                                                    ; CURSOR FLASH CONTROL. BIT 0 = Cursor On/Off, BIT 1 = Cursor displayed.
;
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

MONSTORE    DS      2

            DS      256, 0FFH                                             ; Stack space for cold and warm boot.
BOOTSTACK   EQU     $
            ;
LVAREND     EQU     $                                                    ; End of local page variables

            
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
            ; UTILITIES
            ;-------------------------------------------------------------------------------

            ; Function to print a string with control character interpretation.
MONPRTSTR:  LD      A,(DE)
            OR      A
            RET     Z
            INC     DE
MONPRTSTR2: CALL    PRNT
            JR      MONPRTSTR

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
            ; END OF UTILITIES
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF KEYBOARD FUNCTIONALITY (INTR HANDLER SEPERATE IN CBIOS)
            ;-------------------------------------------------------------------------------

MODE:       LD      HL,KEYPF
            LD      (HL),08AH
            LD      (HL),007H                                            ; Set Motor to Off.
            LD      (HL),004H                                            ; Disable interrupts by setting INTMSK to 0.
            LD      (HL),001H                                            ; Set VGATE to 1.
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
            CP      ROW - 1                 ; End of line?
            JR      Z,.CP1                 
            INC     H
            JP      CURS1

.CP1:       LD      (DSPXY),HL

            ; SCROLLER
.SCROL:     LD      BC,SCRNSZ - COLW        ; Scroll COLW -1 lines
            LD      DE,SCRN                 ; Start of the screen.
            LD      HL,SCRN + COLW          ; Start of screen + 1 line.
            LDIR    
            EX      DE,HL
            LD      B,COLW                  ; Clear last line at bottom of screen.
            CALL    CLER
            LD      BC,0001AH
            LD      DE,MANG
            LD      HL,MANG + 1
            LDIR    
            LD      (HL),000H
            LD      A,(MANG)
            OR      A
            JP      Z,RSTR
            LD      HL,DSPXY + 1
            DEC     (HL)
            JR      .SCROL                   

DPCT:       PUSH    AF                      ; Display control, character is mapped to a function call.
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

            ; Delete a character on screen.
DELCHR:     LD      A,0C7H
            CALL    DPCT
            JR      PRNT1

NEWLINE:    CALL    NL
            JR      PRNT1

            ;
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
            LD      A,007h                                               ; Black background, white chars.
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
DUM4:      ;CALL    CHKKY
            CP      0FFH
            JR      NZ,DUM4
           ;CALL    GETKY
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
DMAMSG:     DB      ",DMA=",   000H
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

            ;-------------------------------------------------------------------------------
            ; START OF STATIC LOOKUP TABLES AND CONSTANTS
            ;-------------------------------------------------------------------------------

            ;--------------------------------------
            ; Test Message table
            ;--------------------------------------

TESTTZSIGNON:DB      "** tranZPUter Tester Program (C) P.D. Smart, 2020 **",   CR, CR,   NUL
MSGTEST1:    DB      "E0/E4 Test, write into RAM and see if it writes onto the Monitor ROM.", CR, "A downcount is the write pattern, first column is ROM contents", CR, NUL
MSGFAIL:     DB      " - Failed at loop count: ", NUL
MSGDONE:     DB      "Tests complete.", CR, NUL

            ;-------------------------------------------------------------------------------
            ; END OF STATIC LOOKUP TABLES AND CONSTANTS
            ;-------------------------------------------------------------------------------

PGMEND:    EQU     $
