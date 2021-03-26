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
            ; TZFS BANK 3 - Utilities and additional commands.
            ;
            ;============================================================
            ORG     BANKRAMADDR

            ;-------------------------------------------------------------------------------
            ; START OF UTILITY METHODS
            ;-------------------------------------------------------------------------------

            ; Method to skip white space whilst locating a comma. Once found, advance to the next first non-white space character.
            ; Outputs:
            ;     Z  = No comma - either comma found but no following characters or no comma found.
            ;     NZ = comma found, DE points to next non-white character.
SKIPCOMMA:  LD      A,(DE)                                               ; Scan the parameter buffer for a comma.
            INC     DE
            CP      ' '
            JR      Z,SKIPCOMMA     
            CP      000H
            RET     Z                                                    ; End of string, no comma found.
            CP      ','
            JR      NZ,SKIPCOMMA
SKIPCOM2:   LD      A,(DE)                                               ; Comma found no advance to first non-white char.
            CP      000H                                                 ; End of string?
            RET     Z
            CP      ' '                                                  ; Non comma found, return success.
            RET     NZ
            INC     DE                                                   ; Whitespace so advance to next char.
            JR      SKIPCOM2

            ; Method to validate a model code, the single character should be one of:
            ; K = MZ-80K
            ; C = MZ-80C
            ; 1 = MZ-1200
            ; A = MZ-80A
            ; B = MZ-80B
            ; 7 = MZ-700
            ; 8 = MZ-800
            ; 2 = MZ-2000
            ; O = Original memory load, original machine configuration, ie. MZ-800 as an MZ-800..
            ; o = Original memory load, alternative mode, ie. MZ-700 on MZ-800 host..
            ; Outputs:
            ;    C = Binary model number 0..7
            ;    Z = Model code valid.
            ;   NZ = Invalid code.
CHECKMODEL: LD      C,MODE_MZ80K
            CP      'K'                                                   ; MZ-80K
            RET     Z                                                     ; 0
            INC     C
            CP      'C'                                                   ; MZ-80C
            RET     Z                                                     ; 1
            INC     C
            CP      '1'                                                   ; MZ-1200
            RET     Z                                                     ; 2
            INC     C
            CP      'A'                                                   ; MZ-80A
            RET     Z                                                     ; 3
            INC     C
            CP      '7'                                                   ; MZ-700
            RET     Z                                                     ; 4
            INC     C
            CP      '8'                                                   ; MZ-800
            RET     Z                                                     ; 5
            INC     C
            CP      'B'                                                   ; MZ-80B
            RET     Z                                                     ; 6
            INC     C
            CP      '2'                                                   ; MZ-2000
            RET     Z                                                     ; 7
            INC     C
            CP      'O'                                                   ; Original host, ie. MZ-800 as an MZ-800
            RET     Z                                                     ; 8
            INC     C
            CP      'S'                                                   ; Original host, alternative mode, ie. MZ-700 mode on MZ-800 host.
            RET                                                           ; 9?

            ; Get optional machine model code. Format is: CMD<param>[,][machine model code]
            ; Outputs:
            ;     A = Model number.
GETMODEL:   CALL    SKIPCOMMA
            JR      Z,READMODEL                                          ; No comma found so no parameter, read default model from CPLD.
            LD      A,(DE)                                               ; Get code
            CALL    CHECKMODEL
            LD      A,C
            JR      NZ,READMODEL
            RET
READMODEL:  IN      A,(CPLDINFO)                                         ; Get the model number from the underlying hardware.
            AND     007H                                                 ; Mask in the relevant bits, A = Model number.
            RET

            ;
            ; Pallet Reg. & Border Reg. set
            ;      PLT0~3  Black
            ;      Border  Black
            ;
            ; output: BC = 6CFH, A = 0
            ;
PLTST:      PUSH    HL                                           
            LD      BC,05F0H                                             ; C=port (Pallet Write), B=count
            LD      HL,PLTDT                                             ; Data
            OTIR                                                                          
            XOR     A                                                                     
            LD      BC,06CFH                                             ; Border Black
            OUT     (C),A                                                ; Send to port.
            POP     HL                                           
            RET  

            ; Initialization table for Palette
            ;
PLTDT:      DB      0,10H,20H,30H,40H    

            ;-------------------------------------------------------------------------------
            ; END OF UTILITY METHODS
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF ADDITIONAL TZFS COMMAND METHODS
            ;-------------------------------------------------------------------------------

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

            ;-------------------------------------------------------------------------------
            ; END OF ADDITIONAL TZFS COMMAND METHODS
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF TIMER TEST FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Test the 8253 Timer, configure it as per the monitor and display the read back values.
TIMERTST:   CALL    NL
            LD      DE,MSG_TIMERTST
            CALL    MSG
            CALL    NL
            LD      DE,MSG_TIMERVAL
            CALL    MSG
            LD      A,01h
            LD      DE,8000h
            CALL    TIMERTST1
NDE:        JP      NDE
            JP      ST1X
TIMERTST1:  DI      
            PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      (AMPM),A
            LD      A,0F0H
            LD      (TIMFG),A
ABCD:       LD      HL,0A8C0H
            XOR     A
            SBC     HL,DE
            PUSH    HL
            INC     HL
            EX      DE,HL

            LD      HL,CONTF    ; Control Register
            LD      (HL),0B0H   ; 10110000 Control Counter 2 10, Write 2 bytes 11, 000 Interrupt on Terminal Count, 0 16 bit binary
            LD      (HL),074H   ; 01110100 Control Counter 1 01, Write 2 bytes 11, 010 Rate Generator, 0 16 bit binary
            LD      (HL),030H   ; 00110100 Control Counter 1 01, Write 2 bytes 11, 010 interrupt on Terminal Count, 0 16 bit binary

            LD      HL,CONT2    ; Counter 2
            LD      (HL),E
            LD      (HL),D

            LD      HL,CONT1    ; Counter 1
            LD      (HL),00AH
            LD      (HL),000H

            LD      HL,CONT0    ; Counter 0
            LD      (HL),00CH
            LD      (HL),0C0H

;            LD      HL,CONT2    ; Counter 2
;            LD      C,(HL)
;            LD      A,(HL)
;            CP      D
;            JP      NZ,L0323H                
;            LD      A,C
;            CP      E
;            JP      Z,CDEF                
            ;

L0323H:     PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),080H
            LD      HL,CONT2    ; Counter 2
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    PRNTS
            ;CALL    DLY1S
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),040H
            LD      HL,CONT1    ; Counter 1
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    PRNTS
            ;CALL    DLY1S
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),000H
            LD      HL,CONT0    ; Counter 0
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            ;CALL    DLY1S
            ;
            LD      A,0C4h      ; Move cursor left.
            LD      E,0Eh      ; 4 times.
L0330:      CALL    DPCT
            DEC     E
            JR      NZ,L0330
            ;
;            LD      C,20
;L0324:      CALL    DLY12
;            DEC     C
;            JR      NZ,L0324
            ;
            POP     HL
            POP     DE
            POP     BC
            POP     AF
            ;
            LD      HL,CONT2    ; Counter 2
            LD      C,(HL)
            LD      A,(HL)
            CP      D
            JP      NZ,L0323H                
            LD      A,C
            CP      E
            JP      NZ,L0323H                
            ;
            ;
            PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            CALL    NL
            CALL    NL
            CALL    NL
            LD      DE,MSG_TIMERVAL2
            CALL    MSG
            POP     HL
            POP     DE
            POP     BC
            POP     AF

            ;
CDEF:       POP     DE
            LD      HL,CONT1
            LD      (HL),00CH
            LD      (HL),07BH
            INC     HL

L0336H:     PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),080H
            LD      HL,CONT2    ; Counter 2
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    PRNTS
            CALL    DLY1S
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),040H
            LD      HL,CONT1    ; Counter 1
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    PRNTS
            CALL    DLY1S
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),000H
            LD      HL,CONT0    ; Counter 0
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    DLY1S
            ;
            LD      A,0C4h      ; Move cursor left.
            LD      E,0Eh      ; 4 times.
L0340:      CALL    DPCT
            DEC     E
            JR      NZ,L0340
            ;
            POP     HL
            POP     DE
            POP     BC
            POP     AF

            LD      HL,CONT2    ; Counter 2
            LD      C,(HL)
            LD      A,(HL)
            CP      D
            JR      NZ,L0336H                
            LD      A,C
            CP      E
            JR      NZ,L0336H                
            CALL    NL
            LD      DE,MSG_TIMERVAL3
            CALL    MSG
            POP     HL
            POP     DE
            POP     BC
            EI      
            RET   
            ;-------------------------------------------------------------------------------
            ; END OF TIMER TEST FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF PRINTER CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------
PTESTX:     LD      A,(DE)
            CP      '&'                                                  ; plotter test
            JR      NZ,PTST1X
PTST0X:     INC     DE
            LD      A,(DE)
            CP      'L'                                                  ; 40 in 1 line
            JR      Z,.LPTX
            CP      'S'                                                  ; 80 in 1 line
            JR      Z,..LPTX
            CP      'C'                                                  ; Pen change
            JR      Z,PENX
            CP      'G'                                                  ; Graph mode
            JR      Z,PLOTX
            CP      'T'                                                  ; Test
            JR      Z,PTRNX
;
PTST1X:     CALL    PMSGX
ST1X2:      RET
.LPTX:      LD      DE,LLPT                                              ; 01-09-09-0B-0D
            JR      PTST1X
..LPTX:     LD      DE,SLPT                                              ; 01-09-09-09-0D
            JR      PTST1X
PTRNX:      LD      A,004h                                               ; Test pattern
            JR      LE999
PLOTX:      LD      A,002h                                               ; Graph mode
LE999:      CALL    LPRNTX
            JR      PTST0X
PENX:       LD      A,01Dh                                               ; 1 change code (text mode)
            JR      LE999
;
;
;       1 char print to $LPT
;
;        in: ACC print data
;
;
LPRNTX:     LD      C,000h                                               ; RDAX test
            LD      B,A                                                  ; print data store
            CALL    RDAX
            LD      A,B
            OUT     (0FFh),A                                             ; data out
            LD      A,080h                                               ; RDP high
            OUT     (0FEh),A
            LD      C,001h                                               ; RDA test
            CALL    RDAX
            XOR     A                                                    ; RDP low
            OUT     (0FEh),A
            RET
;
;       $LPT msg.
;       in: DE data low address
;       0D msg. end
;
PMSGX:      PUSH    DE
            PUSH    BC
            PUSH    AF
PMSGX1:     LD      A,(DE)                                               ; ACC = data
            CALL    LPRNTX
            LD      A,(DE)
            INC     DE
            CP      00Dh                                                 ; end ?
            JR      NZ,PMSGX1
            POP     AF
            POP     BC
            POP     DE
            RET

;
;       RDA check
;
;       BRKEY in to monitor return
;       in: C RDA code
;
RDAX:       IN      A,(0FEh)
            AND     00Dh
            CP      C
            RET     Z
            CALL    BRKEY
            JR      NZ,RDAX
            LD      SP,ATRB
            JR      ST1X2

            ;    40 CHA. IN 1 LINE CODE (DATA)
LLPT:       DB      01H                                                  ; TEXT MODE
            DB      09H
            DB      09H
            DB      0BH
            DB      0DH

            ;    80 CHA. 1 LINE CODE (DATA)
SLPT:       DB      01H                                                  ; TEXT MODE
            DB      09H
            DB      09H
            DB      09H
            DB      0DH

            ;-------------------------------------------------------------------------------
            ; END OF PRINTER CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------


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
