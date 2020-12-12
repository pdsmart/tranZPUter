;--------------------------------------------------------------------------------------------------------
;-
;- Name:            tzfs_bank3.asm
;- Created:         July 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series tzfs (tranZPUter Filing System).
;-                  Bank 3 - F000:FFFF - 
;-
;-                  This assembly language program is a branch from the original RFS written for the
;-                  MZ80A_RFS upgrade board. It is adapted to work within the similar yet different 
;-                  environment of the tranZPUter SW which has a large RAM capacity (512K) and an
;-                  I/O processor in the K64F/ZPU.
;-
;- Credits:         
;- Copyright:       (c) 2018-2020 Philip Smart <philip.smart@net2net.org>
;-
;- History:         May 2020  - Branch taken from RFS v2.0 and adapted for the tranZPUter SW.
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


            ;============================================================
            ;
            ; TZFS BANK 3 - 
            ;
            ;============================================================
            ORG     BANKRAMADDR

            ;
            ;       Memory correction
            ;       command 'M'
            ;
MCORX:      CALL    READ4HEX                                             ; correction address
            RET     C
MCORX1:     CALL    NLPHL                                                ; corr. adr. print
            CALL    SPHEX                                                ; ACC ASCII display
            CALL    PRNTS                                                ; space print
            LD      DE,BUFER                                             ; Input the data.
            CALL    GETL
            LD      A,(DE)
            CP      01Bh                                                 ; If . pressed, exit.
            RET     Z
            PUSH    HL
            POP     BC
            CALL    HLHEX                                                ; If the existing address is no longer hex, reset. HLASCII(DE). If it is hex, take as the address to store data into.
            JR      C,MCRX3                                              ; Line is corrupted as the address is no longer in Hex, reset.
            INC     DE
            INC     DE
            INC     DE
            INC     DE
            INC     DE                                                   ;
            CALL    _2HEX                                                ; Get value entered.
            JR      C,MCORX1                                             ; Not hex, reset.
            CP      (HL)                                                 ; Not same as memory, reset.
            JR      NZ,MCORX1
            INC     DE                                                   ; 
            LD      A,(DE)                                               ; Check if no data just CR, if so, move onto next address.
            CP      00Dh                                                 ; not correction
            JR      Z,MCRX2
            CALL    _2HEX                                                ; Get the new entered data. ACCHL(ASCII)
            JR      C,MCORX1                                             ; New data not hex, reset.
            LD      (HL),A                                               ; data correct so store.
MCRX2:      INC     HL
            JR      MCORX1
MCRX3:      LD      H,B                                                  ; memory address
            LD      L,C
            JR      MCORX1


            ; Dump method when called interbank as HL cannot be passed.
            ;
            ; BC = Start
            ; DE = End
DUMPBC:     PUSH    BC
            POP     HL
            JR      DUMP

            ; Command line utility to dump memory.
            ; Get start and optional end addresses from the command line, ie. XXXX[XXXX]
            ; Paging is implemented, 23 lines at a time, pressing U goes back 100H, pressing D scrolls down 100H
            ;
DUMPX:      CALL    HLHEX                                                ; Get start address if present into HL
            JR      NC,DUMPX1
            LD      DE,(DUMPADDR)                                        ; Setup default start and end.
            JR      DUMPX2
DUMPX1:     INC     DE
            INC     DE
            INC     DE
            INC     DE
            PUSH    HL
            CALL    HLHEX                                                ; Get end address if present into HL
            POP     DE                                                   ; DE = Start address
            JR      NC,DUMPX4                                            ; Both present? Then display.
DUMPX2:     LD      A,(SCRNMODE)
            BIT     0,A
            LD      HL,000A0h                                            ; Make up an end address based on 160 bytes from start for 40 column mode.
            JR      Z,DUMPX3
            LD      HL,00140h                                            ; Make up an end address based on 320 bytes from start for 80 column mode.
DUMPX3:     ADD     HL,DE
DUMPX4:     EX      DE,HL
            ;
            ; HL = Start
            ; DE = End
DUMP:       LD      A,23
DUMP0:      LD      (TMPCNT),A
            LD      A,(SCRNMODE)                                         ; Configure output according to screen mode, 40/80 chars.
            BIT     0,A
            JR      NZ,DUMP1
            LD      B,008H                                               ; 40 Char, output 23 lines of 40 char.
            LD      C,017H
            JR      DUMP2
DUMP1:      LD      B,010h                                               ; 80 Char, output 23 lines of 80 char.
            LD      C,02Fh
DUMP2:      CALL    NLPHL
DUMP3:      CALL    SPHEX
            INC     HL
            PUSH    AF
            LD      A,(DSPXY)
            ADD     A,C
            LD      (DSPXY),A
            POP     AF
            CP      020h
            JR      NC,DUMP4
            LD      A,02Eh
DUMP4:      CALL    ?ADCN
            CALL    PRNT3
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
            JR      NC,DUMP9
DUMP5:      DJNZ    DUMP3
            LD      A,(TMPCNT)
            DEC     A
            JR      NZ,DUMP0
DUMP6:      CALL    GETKY                                                ; Pause, X to quit, D to go down a block, U to go up a block.
            OR      A
            JR      Z,DUMP6
            CP      'D'
            JR      NZ,DUMP7
            LD      A,8
            JR      DUMP0
DUMP7:      CP      'U'
            JR      NZ,DUMP8
            PUSH    DE
            LD      DE,00100H
            OR      A
            SBC     HL,DE
            POP     DE
            LD      A,8
            JR      DUMP0
DUMP8:      CP      'X'
            JR      Z,DUMP9
            JR      DUMP
DUMP9:      LD      (DUMPADDR),HL                                        ; Store last address so we can just press D for next page,
            CALL    NL
            RET


            ; Cmd tool to clear memory.
            ; Read cmd line for an init byte, if one not present, use 00H
            ;
INITMEMX:   CALL    _2HEX
            JR      NC,INITMEMX1
            LD      A,000H
INITMEMX1:  PUSH    AF
            LD      DE,MSGINITM
            CALL    ?PRINTMSG
            LD      HL,1200h
            LD      BC,0D000h - 1200h
            POP     DE
CLEAR1:     LD      A,D
            LD      (HL),A
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JP      NZ,CLEAR1
            RET


            ; The FDC controller uses it's busy/wait signal as a ROM address line input, this
            ; causes a jump in the code dependent on the signal status. It gets around the 2MHz Z80 not being quick
            ; enough to process the signal by polling.
            ALIGN_NOPS FDCJMP1
            ORG      FDCJMP1
FDCJMPL3:   JP       (IX)      


            ; The FDC controller uses it's busy/wait signal as a ROM address line input, this
            ; causes a jump in the code dependent on the signal status. It gets around the 2MHz Z80 not being quick
            ; enough to process the signal by polling.
            ALIGN_NOPS FDCJMP2
            ORG      FDCJMP2               
FDCJMPH3:   JP       (IY)

            ; Ensure we fill the entire 4K by padding with FF's.
            ;
            ALIGN_NOPS      10000H
