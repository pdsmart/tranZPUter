; Digital Research ASM assembler
; disassembled by Larry A. Greene
; got any comments or suggestions?
; send to greenela@clear.lakes.com

; using command ASM TEST.ABC will assemble TEST.ASM with drive designations
; following period. A=ASM file drive, B=HEX file drive, C=SYM file drive

    ORG    0100H

H0000   EQU     0000H           ;cold re-entry to system
H0005   EQU     0005H           ;BDOS
H005C   EQU     005CH           ;FCB
H0080   EQU     0080H           ;DMA

        LD      SP,H0200        ;set stack
    LD    HL,(H0005+1)
        LD      (H01CD),HL      ;set end of memory = BDOS base
    JP    H0200
H010C:  DB      ' '     ;120 byte line buffer for PRN output
H010D:  DB      'C'     ;if H010C is non-space then contains error code:
                        ;B = unknown
                        ;C = comma missing
                        ;D = not an 8 bit value for DB label expression
                        ;E = bad register syntax
                        ;L = bad mnemonic
                        ;N = function not supported
                        ;O = unknown (some form of syntax error)
                        ;P = duplicate label or phase error
                        ;R = wrong register
                        ;S = syntax error
                        ;U = unclained label
                        ;V = bad value
H010E:    DB      "OPY"
H0111:    DB      'R'
H0112:    DB      "IGHT(C) 1978, DIGITAL RESEARCH "
    DS      53H
H0184:  DS      01H     ;index into H010C PRN buffer
H0185:  DS      01H     ;char type. 4=EOL 3=literal 2=digit 1=alpha
H0186:  DS      02H     ;holds value of numeric expression from H1106 call
H0188:  DS      01H     ;index into H0189 ASM buffer
H0189:  DS      01H     ;64 byte ASM line buffer
H018A:    DS      01H
H018B:    DS      3EH
H01C9:    DS      02H
H01CB:  DW      H20F0   ;contains end of symbol table
H01CD:  DS      02H     ;contains BDOS base (end of memory space)
H01CF:  DS      01H     ;assembly pass count 0=build symbol table 1=table done
H01D0:  DS      02H     ;address counter (for HEX file also)
H01D2:  DS      02H     ;address printed at start of line in PRN file
H01D4:  DW      H20F0   ;start of symbol table (fixed)
H01D6:  DS      2AH     ;stack space below H0200
H0200:  JP      H0CE0   ;cold start
H0203:  JP      H0DA1   ;open ASM file
H0206:  JP      H0DCA   ;get char from H029D ASM file buffer.
                        ;reads disk as needed.
        JP      H0E34   ;write byte in ACC reg to PRN file. all regs preserved
        JP      H0EAA   ;write ACC reg to HEX file (direct - after processed)
        JP      H0EDE   ;write ACC reg to console
H0212:  JP      H0CBC   ;print string at (HL). terminates with cr
H0215:  JP      H0F00   ;print H010C line buffer to PRN file w/echo to console
H0218:  JP      H0F2F   ;put error code from ACC reg into H010C flag
H021B:  JP      H104C   ;write byte in ACC reg to HEX file in ASCII form
H021E:  JP      H0F39   ;close files and exit
H0221:  DS      02H     ;HEX file pointer (base address of line)
H0223:  DS      01H     ;index into line of H0224
H0224:  DS      10H     ;obj code line buffer for PRN and HEX use
H0234:  DS      01H     ;current disk
H0235:  DS      01H     ;ASM file drive designation
H0236:  DS      01H     ;PRN file drive designation
H0237:  DS      01H     ;HEX file drive designation
H0238:  DS      9       ;ASM filename
    DB      "ASM"
H0244:    DS      14H
H0258:  DS      01H     ;PRN filename
H0259:    DS      9
    DB      "PRN"
    DS      15H
H027A:  DS      9       ;HEX filename
    DB      "HEX"
    DS      15H
H029B:  DS      02H     ;index into H029D buffer
H029D:  DS      400H    ;buffer for ASM file read
H069D:  DS      02H     ;index into H069F buffer
H069F:  DS      300H    ;buffer for PRN file write
H099F:  DS      02H     ;index into H09A1 buffer
H09A1:  DS      300H    ;buffer for HEX file write
H0CA1:  LD      HL,H0234 ;select drive in ACC reg and make it the current drive
    CP    (HL)
    RET    Z
    LD    (HL),A
    LD    E,A
    LD    C,0EH
    CALL    H0005
    RET
H0CAE:    INC    HL
    LD    A,(HL)
    CP    20H
    JP    Z,H0CB8
    SBC    A,41H
    RET
H0CB8:    LD    A,(H0234)
    RET
H0CBC:  LD      A,(HL)  ;print string at (HL). terminate w/cr
    CALL    H0EDE
    LD    A,(HL)
    INC    HL
    CP    0DH
    JP    NZ,H0CBC
    LD    A,0AH
    CALL    H0EDE
    RET
H0CCD:  LD      DE,H005C        ;move 9 bytes from FCB to (HL)
        LD      B,09H           ;error exit if '?' found
H0CD2:    LD    A,(DE)
    CP    3FH
    JP    Z,H0DBB
    LD    (HL),A
    INC    HL
    INC    DE
    DEC    B
    JP    NZ,H0CD2
    RET
H0CE0:  LD      HL,H0FA0        ;cold start
        CALL    H0CBC           ;print title
    JP    H0D3F
H0CE9:  LD      C,0FH           ;open file
    CALL    H0005
    CP    0FFH
    RET    NZ
    LD    HL,H0FB9
    CALL    H0CBC
    JP    H0000
H0CFA:  LD      C,10H           ;close file
    CALL    H0005
    CP    0FFH
    RET    NZ
    LD    HL,H1029
    CALL    H0CBC
    JP    H0000
H0D0B:  LD      C,13H           ;delete file. (DE) = FCB
    JP    H0005
H0D10:  LD      C,16H           ;make file. (DE) = FCB
        CALL    H0005           ;error exit if disk full
        CP      0FFH
    RET    NZ
    LD    HL,H0FD0
    CALL    H0CBC
    JP    H0000
H0D21:  LD      A,(H0235)       ;select ASM file drive
    CALL    H0CA1
    RET
H0D28:    LD    A,(H0236)
    CP    19H
    RET    Z
    CP    17H
    RET
H0D31:  LD      A,(H0236)       ;select PRN file drive
    CALL    H0CA1
    RET
H0D38:  LD      A,(H0237)       ;select HEX file drive
    CALL    H0CA1
    RET
H0D3F:  LD      A,(H005C)       ;drive designation
    CP    20H
        JP      Z,H0DBB         ;error exit
    LD    C,19H
        CALL    H0005           ;get current disk
    LD    (H0234),A
        LD      HL,0064H        ;get optional drive designations following '.'
        CALL    H0CAE           ;after filename else use current drive
    LD    (H0235),A
    CALL    H0CAE
    LD    (H0237),A
    CALL    H0CAE
    LD    (H0236),A
        LD      HL,H0238        ;ASM filename
        CALL    H0CCD           ;move filename
    CALL    H0D28
    JP    Z,H0D83
    LD    HL,H0259
    PUSH    HL
    PUSH    HL
    CALL    H0CCD
        CALL    H0D31           ;select PRN file drive
    POP    DE
        CALL    H0D0B           ;delete old PRN file
    POP    DE
        CALL    H0D10           ;make new PRN file
H0D83:    LD    A,(H0237)
    CP    19H
    JP    Z,H0D9E
    LD    HL,H027A
    PUSH    HL
    PUSH    HL
    CALL    H0CCD
        CALL    H0D38           ;select HEX file drive
    POP    DE
        CALL    H0D0B           ;delete old HEX file
    POP    DE
        CALL    H0D10           ;make new HEX file
H0D9E:  JP      H1100           ;enter assembler with HEX and PRN files open
H0DA1:  LD      HL,0400H        ;open ASM file. force reading of first byte
        LD      (H029B),HL      ;of ASM file by setting index to EOF
    XOR    A
    LD    (H0244),A
    LD    (H0258),A
    LD    (H0223),A
    CALL    H0D21
    LD    DE,H0238
    CALL    H0CE9
    RET
H0DBB:  LD      HL,H0FE3        ; 'source filename error' exit
    CALL    H0CBC
    JP    H0000
H0DC4:    LD    A,D
    CP    H
    RET    NZ
    LD    A,E
    CP    L
    RET
H0DCA:  PUSH    BC              ;get char from ASM file
    PUSH    DE
    PUSH    HL
    LD    HL,(H029B)
    LD    DE,0400H
    CALL    H0DC4
    JP    NZ,H0E19
    CALL    H0D21
    LD    HL,0000H
    LD    (H029B),HL
    LD    B,08H
    LD    HL,H029D
H0DE7:    PUSH    BC
    PUSH    HL
    LD    C,14H
    LD    DE,H0238
    CALL    H0005
    POP    HL
    POP    BC
    OR    A
    LD    C,80H
    JP    NZ,H0E0D
    LD    DE,H0080
        LD      C,80H           ;extra code not needed (see 3 lines previous)
H0DFE:    LD    A,(DE)
    LD    (HL),A
    INC    DE
    INC    HL
    DEC    C
    JP    NZ,H0DFE
    DEC    B
    JP    NZ,H0DE7
    JP    H0E19
H0E0D:    CP    03H
    JP    NC,H0E2B
H0E12:    LD    (HL),1AH
    INC    HL
    DEC    C
    JP    NZ,H0E12
H0E19:    LD    DE,H029D
    LD    HL,(H029B)
    PUSH    HL
    INC    HL
    LD    (H029B),HL
    POP    HL
    ADD    HL,DE
    LD    A,(HL)
    POP    HL
    POP    DE
    POP    BC
    RET
H0E2B:  LD      HL,H0FFA        ; 'source file read error' exit
    CALL    H0CBC
    JP    H0000
H0E34:  PUSH    BC              ;output char in ACC reg to PRN designation:
        LD      B,A             ;Z = null, X = console, else to H069F buffer
        LD      A,(H0236)       ;and write to disk as needed
        CP      19H             ; 'Z'
    JP    Z,H0E51
        CP      17H             ; 'X'
    LD    A,B
    JP    NZ,H0E4A
        CALL    H0EDE           ;write to console
    JP    H0E51
H0E4A:    PUSH    DE
    PUSH    HL
    CALL    H0E53
    POP    HL
    POP    DE
H0E51:    POP    BC
    RET
H0E53:  LD      HL,(H069D)      ;write byte to PRN file
    EX    DE,HL
    LD    HL,H069F
    ADD    HL,DE
    LD    (HL),A
    EX    DE,HL
    INC    HL
    LD    (H069D),HL
    EX    DE,HL
    LD    HL,0300H
    CALL    H0DC4
    RET    NZ
    CALL    H0D31
    LD    HL,0000H
    LD    (H069D),HL
    LD    HL,H069F
    LD    DE,H0259
        LD      B,06H           ;6 times 80H = 300H
H0E7A:  LD      A,(HL)          ;write HEX file comes here
    CP    1AH
    RET    Z
    PUSH    BC
    PUSH    DE
    LD    C,80H
    LD    DE,H0080
H0E85:    LD    A,(HL)
    LD    (DE),A
    INC    HL
    INC    DE
    DEC    C
    JP    NZ,H0E85
    POP    DE
    PUSH    DE
    PUSH    HL
        LD      C,15H           ;write sequential
    CALL    H0005
    POP    HL
    POP    DE
    POP    BC
    OR    A
    JP    NZ,H0EA1
    DEC    B
    RET    Z
    JP    H0E7A
H0EA1:    LD    HL,H1011
    CALL    H0CBC
    JP    H0F77
H0EAA:  PUSH    BC              ;write ACC to HEX file with disk buffering
    PUSH    DE
    PUSH    HL
    CALL    H0EB4
    POP    HL
    POP    DE
    POP    BC
    RET
H0EB4:    LD    HL,(H099F)
    EX    DE,HL
    LD    HL,H09A1
    ADD    HL,DE
    LD    (HL),A
    EX    DE,HL
    INC    HL
    LD    (H099F),HL
    EX    DE,HL
    LD    HL,0300H
        CALL    H0DC4           ;compare DE and HL - buffer full?
        RET     NZ              ;no
        CALL    H0D38           ;select HEX file drive
    LD    HL,0000H
    LD    (H099F),HL
    LD    HL,H09A1
    LD    DE,H027A
    LD    B,06H
    JP    H0E7A
H0EDE:  PUSH    BC              ;write ACC reg to console
    PUSH    DE
    PUSH    HL
    LD    C,02H
    LD    E,A
    CALL    H0005
    POP    HL
    POP    DE
    POP    BC
    RET
H0EEB:  LD      C,A             ;write ACC reg to PRN designation. echo error
        CALL    H0E34           ;to console if H010C is non-space
    LD    A,(H010C)
    CP    20H
    RET    Z
    LD    A,(H0236)
    CP    17H
    RET    Z
    LD    A,C
        CALL    H0EDE           ;echo to console
    RET
H0F00:  LD      A,(H0184)       ;print H010C line buffer to PRN file with
        LD      HL,H010C        ;echo to console. H0184 = # of chars in line
H0F06:    OR    A
    JP    Z,H0F15
    LD    B,A
    LD    A,(HL)
        CALL    H0EEB           ;write byte w/echo
    INC    HL
    LD    A,B
    DEC    A
    JP    H0F06
H0F15:  LD      (H0184),A       ;write CR to PRN file then clear line buffer
    LD    A,0DH
    CALL    H0EEB
    LD    A,0AH
    CALL    H0EEB
    LD    HL,H010C
    LD    A,78H
H0F27:    LD    (HL),20H
    INC    HL
    DEC    A
    JP    NZ,H0F27
    RET
H0F2F:    LD    B,A
    LD    HL,H010C
    LD    A,(HL)
    CP    20H
    RET    NZ
    LD    (HL),B
    RET
H0F39:  CALL    H0D28           ;close files and exit
        JP      Z,H0F4F         ;taken if no PRN file designated
H0F3F:    LD    HL,(H069D)
    LD    A,L
    OR    H
    JP    Z,H0F4F
        LD      A,1AH           ;fill to end of buffer with ctrl-Z
    CALL    H0E34
    JP    H0F3F
H0F4F:    LD    A,(H0237)
    CP    19H
        JP      Z,H0F77         ;taken if no HEX file designated
        LD      A,(H0223)       ;index
    OR    A
        CALL    NZ,H10B8        ;write final line to HEX file
    LD    HL,(H01D0)
    LD    (H0221),HL
        CALL    H10B8           ;write EOF address as data
H0F67:    LD    HL,(H099F)
    LD    A,L
    OR    H
    JP    Z,H0F77
    LD    A,1AH
    CALL    H0EAA
    JP    H0F67
H0F77:  CALL    H0D28           ;error in writing PRN or HEX file comes here
        JP      Z,H0F86         ;taken if no PRN file designation
        CALL    H0D31           ;select PRN file drive
    LD    DE,H0259
        CALL    H0CFA           ;close PRN file
H0F86:  LD      A,(H0237)       ;check HEX designation
    CP    19H
        JP      Z,H0F97         ;taken if no HEX file designation
        CALL    H0D38           ;select HEX file drive
    LD    DE,H027A
        CALL    H0CFA           ;close HEX file
H0F97:    LD    HL,H103C
    CALL    H0CBC
    JP    H0000
H0FA0:    DB      "CP/M ASSEMBLER - VER 2.0"
    DB      0DH
H0FB9:    DB      "NO SOURCE FILE PRESENT"
    DB      0DH
H0FD0:    DB      "NO DIRECTORY SPACE"
    DB      0DH
H0FE3:    DB      "SOURCE FILE NAME ERROR"
    DB      0DH
H0FFA:    DB      "SOURCE FILE READ ERROR"
    DB      0DH
H1011:    DB      "OUTPUT FILE WRITE ERROR"
    DB      0DH
H1029:    DB      "CANNOT CLOSE FILES"
    DB      0DH
H103C:    DB      "END OF ASSEMBLY"
    DB      0DH
H104C:  PUSH    BC              ;write ACC reg to HEX file
    LD    B,A
    LD    A,(H0237)
    CP    19H
    LD    A,B
    JP    Z,H1098
    PUSH    DE
    PUSH    AF
    LD    HL,H0223
    LD    A,(HL)
    OR    A
    JP    Z,H1084
    CP    10H
    JP    C,H106C
        CALL    H10B8           ;write complete line to HEX file. H0221 = addr
    JP    H1084
H106C:    LD    HL,(H01D0)
    EX    DE,HL
        LD      HL,(H0221)      ;if (H0221) + ACC = (H01D0) then jump to H108A
        LD      C,A             ;else H1081
    LD    B,00H
    ADD    HL,BC
    LD    A,E
    CP    L
    JP    NZ,H1081
    LD    A,D
    CP    H
    JP    Z,H108A
H1081:  CALL    H10B8           ;write complete line to HEX file
H1084:    LD    HL,(H01D0)
    LD    (H0221),HL
H108A:  LD      HL,H0223        ;write ACC reg to H0224 obj buffer and
        LD      E,(HL)          ;increment H0223 index
    INC    (HL)
    LD    D,00H
    LD    HL,H0224
    ADD    HL,DE
    POP    AF
    LD    (HL),A
    POP    DE
H1098:    POP    BC
    RET
H109A:  PUSH    AF              ;write ACC reg to HEX file in HEX ASCII form
    RRCA
    RRCA
    RRCA
    RRCA
    AND    0FH
    CALL    H10AF
    POP    AF
    PUSH    AF
    AND    0FH
    CALL    H10AF
    POP    AF
    ADD    A,D
        LD      D,A             ;keep running checksum for Intel HEX form
    RET
H10AF:    ADD    A,90H
    DAA
    ADC    A,40H
    DAA
    JP    H0EAA
H10B8:  LD      A,3AH           ;write complete line to HEX file
        CALL    H0EAA           ;write ACC reg to HEX file
    LD    HL,H0223
        LD      E,(HL)          ;# of bytes to write
    XOR    A
    LD    D,A
        LD      (HL),A          ;reset index to 0
        LD      HL,(H0221)      ;address of line in HEX file
    LD    A,E
    CALL    H109A
        LD      A,H             ;write line address
    CALL    H109A
    LD    A,L
    CALL    H109A
    XOR    A
    CALL    H109A
    LD    A,E
    OR    A
    JP    Z,H10E8
    LD    HL,H0224
H10DF:    LD    A,(HL)
    INC    HL
    CALL    H109A
    DEC    E
    JP    NZ,H10DF
H10E8:    XOR    A
        SUB     D               ;checksum
        CALL    H109A           ;write checksum to HEX file
    LD    A,0DH
    CALL    H0EAA
    LD    A,0AH
    CALL    H0EAA
    RET
    DB      0,0,0,0,0,0,0,0
H1100:  JP      H1340           ;enter assembler with PRN and HEX files open
H1103:  JP      H1132           ;output cr/lf to PRN file (clears line buffer)
H1106:  JP      H11C0           ;parse line up to non-alphanumeric char (EOL)
                                ;reading from ASM file as necessary. if char is
                                ;numeric then return value in H0186. if LF (0Ah)
                                ;found, will print line to PRN file with echo
                                ;to console on 2nd pass.
H1109:  NOP                     ;previous char from H110A
H110A:  NOP                     ;last char read from ASM file
H110B:  NOP                     ;base 2,8,10 or 16 for numeric value
H110C:  CALL    H0206           ;get char from ASM file and store in
        PUSH    AF              ;H010C PRN line buffer
    CP    0DH
    JP    Z,H1130
    CP    0AH
    JP    Z,H1130
    LD    A,(H0184)
    CP    78H
    JP    NC,H1130
    LD    E,A
    LD    D,00H
    INC    A
    LD    (H0184),A
    LD    HL,H010C
    ADD    HL,DE
        POP     AF              ;restore char
        LD      (HL),A          ;store in PRN line buffer
    RET
H1130:  POP     AF              ;restore char
    RET
H1132:  CALL    H1149           ;print CR/LF to PRN file
    LD    (H110A),A
    LD    (H0184),A
    LD    A,0AH
    LD    (H1109),A
        CALL    H0215           ;print PRN line buffer
    LD    A,10H
        LD      (H0184),A       ;index to label field
    RET
H1149:    XOR    A
    LD    (H0188),A
    LD    (H110B),A
    RET
H1151:  LD      HL,H0188        ;store char in H0189 buffer
    LD    A,(HL)
    CP    40H
    JP    C,H115F
    LD    (HL),00H
    CALL    H131E
H115F:    LD    E,(HL)
    LD    D,00H
    INC    (HL)
    INC    HL
    ADD    HL,DE
    LD    A,(H110A)
    LD    (HL),A
    RET
H116A:  LD      A,(HL)          ;null out '$' at (HL)
    CP    24H
    RET    NZ
    XOR    A
    LD    (HL),A
    RET
H1171:  LD      A,(H110A)       ;return z clear if '0-9' digit
    SUB    30H
    CP    0AH
    RLA
    AND    01H
    RET
H117C:  CALL    H1171           ;return z clear if '0-9' or 'A-F' hex digit
    RET    NZ
    LD    A,(H110A)
    SUB    41H
        CP      06H             ;A-F = 0-5. carry set if A-F
        RLA                     ;carry to bit 0
        AND     01H             ; =1 if A-F
    RET
H118B:  LD      A,(H110A)       ;return z clear if 'A-Z' alpha
    SUB    41H
    CP    1AH
    RLA
    AND    01H
    RET
H1196:  CALL    H118B           ;return z clear if 'A-Z' or '0-9' alphanumeric
    RET    NZ
    CALL    H1171
    RET
H119E:    LD    A,(H110A)
    CP    61H
    RET    C
    CP    7BH
    RET    NC
    AND    5FH
    LD    (H110A),A
    RET
H11AD:  CALL    H110C           ;get char and store in PRN line buffer
        LD      (H110A),A       ;save in last char
        JP      H132D           ;go convert lower/upper conditionally
        RET                     ;bogus
H11B7:    CP    0DH
    RET    Z
    CP    1AH
    RET    Z
    CP    21H
    RET
H11C0:  XOR     A               ;parse line
        LD      (H0185),A       ;clear char mode
    CALL    H1149
H11C7:  LD      A,(H110A)       ;each char loops here
    CP    09H
    JP    Z,H11F4
    CP    3BH
    JP    Z,H11E1
    CP    2AH
    JP    NZ,H11ED
    LD    A,(H1109)
    CP    0AH
    JP    NZ,H11ED
H11E1:  CALL    H11AD           ;search ahead to EOL
    CALL    H11B7
    JP    Z,H11FA
    JP    H11E1
H11ED:    OR    20H
    CP    20H
    JP    NZ,H11FA
H11F4:  CALL    H11AD           ;get next char
        JP      H11C7           ;loop for next char
H11FA:    CALL    H118B
        JP      Z,H1205         ;if not alpha
    LD    A,01H
    JP    H1239
H1205:    CALL    H1171
        JP      Z,H1210         ;if not digit
    LD    A,02H
    JP    H1239
H1210:    LD    A,(H110A)
        CP      27H             ;single quote
    JP    NZ,H1221
    XOR    A
    LD    (H110A),A
    LD    A,03H
    JP    H1239
H1221:  CP      0AH
    JP    NZ,H1237
        LD      A,(H01CF)       ;assembly pass count
    OR    A
        CALL    NZ,H0215        ;on 2nd pass print line to PRN file
    LD    HL,H010C
        LD      (HL),20H        ;clear error char
    LD    A,10H
        LD      (H0184),A       ;index to label field for PRN file
H1237:    LD    A,04H
H1239:    LD    (H0185),A
H123C:  LD      A,(H110A)       ;last char
        LD      (H1109),A       ;previous char
    OR    A
        CALL    NZ,H1151        ;store char in ASM buffer
        CALL    H11AD           ;get char and store in PRN line buffer
        LD      A,(H0185)       ;char mode
        CP      04H             ;EOL ?
    RET    Z
        CP      03H             ;literal?
        CALL    NZ,H119E        ;convert lower to upper case if not in quotes
    LD    HL,H110A
        LD      A,(H0185)       ;char mode
        CP      01H             ;alpha?
    JP    NZ,H126C
        CALL    H116A           ;null out '$' from last char
        JP      Z,H123C         ;taken if last char was '$'
    CALL    H1196
        RET     Z               ;taken if not alphanumeric
    JP    H123C
H126C:    CP    02H
    JP    NZ,H1302
    CALL    H116A
        JP      Z,H123C         ;taken if '$'
    CALL    H117C
        JP      NZ,H123C        ;taken if hex digit
    LD    A,(H110A)
        CP      4FH             ; 'O' octal
    JP    Z,H128A
        CP      51H             ; 'Q' octal
    JP    NZ,H128F
H128A:  LD      A,08H           ;base 8 for octal
    JP    H1296
H128F:  CP      48H             ; 'H'
    JP    NZ,H12A0
        LD      A,10H           ;base 16 hex for 'H'
H1296:    LD    (H110B),A
    XOR    A
    LD    (H110A),A
    JP    H12BB
H12A0:    LD    A,(H1109)
        CP      42H             ; 'B' binary
    JP    NZ,H12AD
        LD      A,02H           ;base 2 for binary
    JP    H12B4
H12AD:  CP      44H             ; 'D' decimal
        LD      A,0AH           ; base 10 decimal (default)
    JP    NZ,H12B8
H12B4:  LD      HL,H0188        ;index
        DEC     (HL)            ;ignore trailing char
H12B8:  LD      (H110B),A       ;set base
H12BB:    LD    HL,0000H
    LD    (H0186),HL
    LD    HL,H0188
    LD    C,(HL)
    INC    HL
H12C6:    LD    A,(HL)
    INC    HL
    CP    41H
    JP    NC,H12D2
    SUB    30H
    JP    H12D4
H12D2:    SUB    37H
H12D4:    PUSH    HL
    PUSH    BC
    LD    C,A
    LD    HL,H110B
    CP    (HL)
    CALL    NC,H1318
    LD    B,00H
    LD    A,(HL)
    LD    HL,(H0186)
    EX    DE,HL
    LD    HL,0000H
H12E8:    OR    A
    JP    Z,H12F7
    RRA
    JP    NC,H12F1
    ADD    HL,DE
H12F1:    EX    DE,HL
    ADD    HL,HL
    EX    DE,HL
    JP    H12E8
H12F7:    ADD    HL,BC
    LD    (H0186),HL
    POP    BC
    POP    HL
    DEC    C
    JP    NZ,H12C6
    RET
H1302:    LD    A,(H110A)
    CP    0DH
    JP    Z,H131E
    CP    27H
    JP    NZ,H123C
    CALL    H11AD
    CP    27H
    RET    NZ
    JP    H123C
H1318:  PUSH    AF              ; 'V' bad value error. all regs preserved
    LD    A,56H
    JP    H1324
H131E:  PUSH    AF              ; 'O' error. all regs preserved
    LD    A,4FH
    JP    H1324
H1324:    PUSH    BC
    PUSH    HL
    CALL    H0218
    POP    HL
    POP    BC
    POP    AF
    RET
H132D:  PUSH    AF              ;convert lower to upper case if not in quotes
        LD      A,(H0185)       ;char mode
        CP      03H             ;literal?
        CALL    NZ,H119E        ;convert if not literal
    POP    AF
    RET
    DB      0,0,0,0,0,0,0,0
H1340:  JP      H15A0           ;enter assembler with PRN and HEX files open
H1343:  JP      H145C           ;clear H135B buffer
H1346:  JP      H149E           ;using label in H0188 buffer, search for
                                ;duplicate label. return H01D6=0 if no duplicate
                                ;else H01D6 holds address of link field of dup.
H1349:  JP      H1498           ;ret dup label addr in HL. z-set if no dup
H134C:  JP      H14EB           ;add symbol. see H14EB for more description
H134F:  JP      H1560           ;set nibble in symbol table at (H01D6) from
;ACC reg low nibble. when nibble designated by X is set then symbol has been
;assigned value. (H01D6): 00 00 X3 BDOS DW 0005
H1352:  JP      H1572           ;get nibble from symbol table
H1355:  JP      H158D           ;set value field of symbol at (H01D6) from HL
H1358:  JP      H1596           ;get value of symbol at (H01D6) into HL
H135B:  DS      100H            ;buffer table holds 16 bit values. offset into
                                ;table based on checksum of chars in label
H145B:    DS      01H
H145C:    LD    HL,H135B
    LD    B,80H
    XOR    A
H1462:    LD    (HL),A
    INC    HL
    LD    (HL),A
    INC    HL
    DEC    B
    JP    NZ,H1462
    LD    HL,0000H
    LD    (H01D6),HL
    RET
H1471:  LD      HL,H0188        ;add all chars of label then mask bit 7
    LD    B,(HL)
    XOR    A
H1476:    INC    HL
    ADD    A,(HL)
    DEC    B
    JP    NZ,H1476
    AND    7FH
    LD    (H145B),A
    RET
        LD      B,A             ;bogus code until H148E. image from addr 1566h
    LD    HL,(H01D6)
    INC    HL
    INC    HL
    LD    A,(HL)
    AND    0F0H
    OR    B
    LD    (HL),A
    RET
H148E:  LD      HL,(H01D6)      ;get length of symbol table
    INC    HL
    INC    HL
    LD    A,(HL)
    AND    0FH
    INC    A
    RET
H1498:    LD    HL,(H01D6)
    LD    A,L
    OR    H
    RET
H149E:  CALL    H1471           ;search for duplicate label. return H01D6=0 if
        LD      HL,H0188        ;no duplicate or pointing to link field before
        LD      A,(HL)          ;duplicate
    CP    11H
    JP    C,H14AC
        LD      (HL),10H        ;16 chars max length of label
H14AC:    LD    HL,H145B
    LD    E,(HL)
    LD    D,00H
    LD    HL,H135B
    ADD    HL,DE
    ADD    HL,DE
    LD    E,(HL)
    INC    HL
    LD    H,(HL)
    LD    L,E
H14BB:    LD    (H01D6),HL
    CALL    H1498
    RET    Z
    CALL    H148E
    LD    HL,H0188
    CP    (HL)
    JP    NZ,H14E1
    LD    B,A
    INC    HL
    EX    DE,HL
    LD    HL,(H01D6)
    INC    HL
    INC    HL
    INC    HL
H14D5:    LD    A,(DE)
    CP    (HL)
    JP    NZ,H14E1
    INC    DE
    INC    HL
    DEC    B
    JP    NZ,H14D5
    RET
H14E1:    LD    HL,(H01D6)
    LD    E,(HL)
    INC    HL
    LD    D,(HL)
    EX    DE,HL
    JP    H14BB
H14EB:  LD      HL,H0188        ;add symbol from H0188 buffer to end of symbol
        LD      E,(HL)          ;table at (H01CB) and zero value field
    LD    D,00H
    LD    HL,(H01CB)
    LD    (H01D6),HL
    ADD    HL,DE
    LD    DE,0005H
    ADD    HL,DE
    EX    DE,HL
    LD    HL,(H01CD)
    LD    A,E
    SUB    L
    LD    A,D
    SBC    A,H
    EX    DE,HL
        JP      NC,H1541        ;taken if end of symbol space
    LD    (H01CB),HL
    LD    HL,(H01D6)
    EX    DE,HL
    LD    HL,H145B
    LD    C,(HL)
    LD    B,00H
    LD    HL,H135B
    ADD    HL,BC
    ADD    HL,BC
    LD    C,(HL)
    INC    HL
    LD    B,(HL)
    LD    (HL),D
    DEC    HL
    LD    (HL),E
    EX    DE,HL
    LD    (HL),C
    INC    HL
    LD    (HL),B
    LD    DE,H0188
    LD    A,(DE)
    CP    11H
    JP    C,H152F
        LD      A,10H           ;max length of label = 16 chars
H152F:    LD    B,A
    DEC    A
    INC    HL
        LD      (HL),A          ;store length-1
H1533:  INC     HL              ;store label name
    INC    DE
    LD    A,(DE)
    LD    (HL),A
    DEC    B
    JP    NZ,H1533
        XOR     A               ;zero value field
    INC    HL
    LD    (HL),A
    INC    HL
    LD    (HL),A
    RET
H1541:    LD    HL,H154A
    CALL    H0212
    JP    H021E
H154A:    DB      "SYMBOL TABLE OVERFLOW"
    DB      0DH
H1560:    RLA
    RLA
    RLA
    RLA
    AND    0F0H
    LD    B,A
    LD    HL,(H01D6)
    INC    HL
    INC    HL
    LD    A,(HL)
    AND    0FH
    OR    B
    LD    (HL),A
    RET
H1572:    LD    HL,(H01D6)
    INC    HL
    INC    HL
    LD    A,(HL)
    RRA
    RRA
    RRA
    RRA
    AND    0FH
    RET
H157F:  CALL    H148E           ;return HL pointing to value field of
        LD      HL,(H01D6)      ;symbol at (H01D6)
    LD    E,A
    LD    D,00H
    ADD    HL,DE
    INC    HL
    INC    HL
    INC    HL
    RET
H158D:    PUSH    HL
    CALL    H157F
    POP    DE
    LD    (HL),E
    INC    HL
    LD    (HL),D
    RET
H1596:    CALL    H157F
    LD    E,(HL)
    INC    HL
    LD    D,(HL)
    EX    DE,HL
    RET
    DB      0,0
H15A0:  JP      H1860           ;enter assembler with PRN and HEX files open
    JP    H1783
H15A6:  JP      H1810           ;check word for match. return z-set for match
                                ;and regs ACC=parm1, B=parm2
H15A9:  DW      H15C4           ;mnem length = 1 (as in reg designation char)
        DW      H15D4           ;mnem length = 2
        DW      H15E6           ;mnem length = 3
        DW      H1682           ;mnem length = 4
        DW      H16AE           ;mnem length = 5
        DW      H16BD           ;bogus?
H15B5:  DB      10H             ;# of 1 char words in H15C4 table
        DB      09H             ;# of 2 char words in H15D4 table
        DB      34H             ;# of 3 char words in H15E6 table
        DB      0BH             ;# of 4 char words in H1682 table
        DB      03H             ;# of 5 char words in H16AE table
H15BA:  DW      H16BD           ;length = 1
        DW      H16DD           ;length = 2
        DW      H16EF           ;length = 3
        DW      H1757           ;length = 4
        DW      H176D           ;length = 5
H15C4:    DB      0DH

; the following tables must have at least two words in table and words must be
; in alphabetical order

    DB      "()*+,-/ABCDEHLM"
H15D4:    DB      "DBDIDSDWEIIFINORSP"
H15E6:    DB      "ACIADCADDADIANAANDANICMACMCCMPCPIDAADADDCRDCXENDEQUHLTINRINXJMPL"
    DB      "DALXIMODMOVMVINOPNOTORAORGORIOUTPOPPSWRALRARRETRLCRRCRSTSBBSBISE"
    DB      "TSHLSHRSTASTCSUBSUIXORXRAXRI"
H1682:    DB      "CALLENDMLDAXLHLDPCHLPUSHSHLDSPHLSTAXXCHGXTHL"
H16AE:    DB      "ENDIFMACROTITLE"

; the following are 2 byte parameters corresponding to each word.
; they are referenced in source comments as parm1 and parm2.
; for first pair at H16BD: parm1 = 0FH, parm2 = 0AH
; if parm1 = 10H then parm2 represents a register as follows:
; B=0 C=1 D=2 E=3 H=4 L=5 M,SP,PSW=6

H16BD:  DB      0FH,0AH
        DB      0CH,14H,0DH,1EH,00H,50H
    DB      05H,46H,0EH,0AH,06H,46H,01H,50H
    DB      10H,07H,10H,00H,10H,01H,10H,02H
    DB      10H,03H,10H,04H,10H,05H,10H,06H
H16DD:    DB      11H,01H,13H,0F3H,11H,02H,11H,03H
    DB      13H,0FBH,11H,08H,21H,0DBH,0AH,28H
    DB      10H,06H
H16EF:    DB      1AH,0CEH,1DH,88H,1DH,80H,1AH,0C6H
    DB      1DH,0A0H,09H,32H,1AH,0E6H,13H,2FH
    DB      13H,3FH,1DH,0B8H,1AH,0FEH,13H,27H
    DB      15H,09H,1EH,05H,1FH,0BH,11H,04H
    DB      11H,07H,13H,76H,1EH,04H,1FH,03H
    DB      17H,0C3H,1CH,3AH,14H,01H,02H,50H
    DB      18H,40H,19H,06H,13H,00H,08H,3CH
    DB      1DH,0B0H,11H,0AH,1AH,0F6H,21H,0D3H
    DB      16H,0C1H,10H,06H,13H,17H,13H,1FH
    DB      13H,0C9H,13H,07H,13H,0FH,20H,0C7H
    DB      1DH,98H,1AH,0DEH,11H,0BH,03H,50H
    DB      04H,50H,1CH,32H,13H,37H,1DH,90H
    DB      1AH,0D6H,0BH,28H,1DH,0A8H,1AH,0EEH
H1757:    DB      17H,0CDH,11H,06H,1BH,0AH,1CH,2AH
    DB      13H,0E9H,16H,0C5H,1CH,22H,13H,0F9H
    DB      1BH,02H,13H,0EBH,13H,0E3H
H176D:    DB      11H,05H,11H,09H,11H,0CH
H1773:    DB      "NZZ NCC POPEP M "
H1783:    LD    E,0FFH
    INC    B
    LD    C,00H
H1788:    XOR    A
    LD    A,B
    ADD    A,C
    RRA
    CP    E
    JP    Z,H17C4
    LD    E,A
    PUSH    HL
    PUSH    DE
    PUSH    BC
    PUSH    HL
    LD    B,D
    LD    C,B
    LD    D,00H
    LD    HL,0000H
H179C:    ADD    HL,DE
    DEC    B
    JP    NZ,H179C
    POP    DE
    ADD    HL,DE
    LD    DE,H0189
H17A6:    LD    A,(DE)
    CP    (HL)
    INC    DE
    INC    HL
    JP    NZ,H17B6
    DEC    C
    JP    NZ,H17A6
    POP    BC
    POP    DE
    POP    HL
    LD    A,E
    RET
H17B6:    POP    BC
    POP    DE
    POP    HL
    JP    C,H17C0
    LD    C,E
    JP    H1788
H17C0:    LD    B,E
    JP    H1788
H17C4:    XOR    A
    INC    A
    RET
H17C7:    LD    A,(H0189)
    LD    BC,0C217H
    CP    4AH
    RET    Z
    LD    B,0C4H
    CP    43H
    RET    Z
    LD    BC,0C013H
    CP    52H
    RET
H17DB:    LD    A,(H0188)
    CP    04H
    JP    NC,H180D
    CP    03H
    JP    Z,H17F2
    CP    02H
    JP    NZ,H180D
    LD    HL,H018B
    LD    (HL),20H
H17F2:    LD    BC,0008H
    LD    DE,H1773
H17F8:    LD    HL,H018A
    LD    A,(DE)
    CP    (HL)
    INC    DE
    JP    NZ,H1805
    LD    A,(DE)
    INC    HL
    CP    (HL)
    RET    Z
H1805:    INC    DE
    INC    B
    DEC    C
    JP    NZ,H17F8
    INC    C
    RET
H180D:    XOR    A
    INC    A
    RET
H1810:    LD    A,(H0188)
    LD    C,A
    DEC    A
    LD    E,A
    LD    D,00H
    PUSH    DE
        CP      05H             ;max length of mnem
    JP    NC,H185A
    LD    HL,H15B5
    ADD    HL,DE
    LD    B,(HL)
    LD    HL,H15A9
    ADD    HL,DE
    ADD    HL,DE
    LD    D,(HL)
    INC    HL
    LD    H,(HL)
    LD    L,D
    LD    D,C
    CALL    H1783
        JP      NZ,H1845        ;ACC now = nth pair of whichever 2 byte table
    POP    DE
    LD    HL,H15BA
    ADD    HL,DE
    ADD    HL,DE
    LD    E,(HL)
    INC    HL
    LD    D,(HL)
    LD    L,A
    LD    H,00H
    ADD    HL,HL
    ADD    HL,DE
    LD    A,(HL)
    INC    HL
    LD    B,(HL)
    RET
H1845:    POP    DE
    CALL    H17C7
    RET    NZ
    PUSH    BC
    CALL    H17DB
    LD    A,B
    POP    BC
    RET    NZ
    OR    A
    RLA
    RLA
    RLA
    OR    B
    LD    B,A
    LD    A,C
    CP    A
    RET
H185A:    POP    DE
    XOR    A
    INC    A
    RET
    DB      0,0
H1860:  JP      H1BA0           ;enter assembler with PRN and HEX files open
H1863:  JP      H1A19           ;return addr of symbol in H01C9 and (HL) reg
    JP    H196E
H1869:  JP      H1938           ;return 'USE FACTOR' value in DE reg
H186C:  DS      01H             ;flag 0 or FFh
H186D:  DS      0AH             ;buffer for parm1 values
H1877:  DS      0AH             ;buffer for parm2 values
H1881:    DS      10H
H1891:  DS      01H             ;index into H186D or H1877 buffers
H1892:  DS      01H             ;index into H1881 buffer
H1893:  EX      DE,HL           ;store HL reg pair in H1881 buffer and increment
        LD      HL,H1892        ;H1892 index by 2
    LD    A,(HL)
    CP    10H
    JP    C,H18A2
    CALL    H1B85
    LD    (HL),00H
H18A2:    LD    A,(HL)
    INC    (HL)
    INC    (HL)
    LD    C,A
    LD    B,00H
    LD    HL,H1881
    ADD    HL,BC
    LD    (HL),E
    INC    HL
    LD    (HL),D
    RET
H18B0:  PUSH    AF              ;store parm1,parm2 in H186D and H1877 buffers
        LD      HL,H1891        ;and increment H1891 index
    LD    A,(HL)
    CP    0AH
    JP    C,H18BF
    LD    (HL),00H
        CALL    H1B85           ; 'E' error
H18BF:    LD    E,(HL)
    LD    D,00H
    INC    (HL)
    POP    AF
    LD    HL,H186D
    ADD    HL,DE
    LD    (HL),A
    LD    HL,H1877
    ADD    HL,DE
    LD    (HL),B
    RET
H18CF:  LD      HL,H1892        ;get previous pair to HL reg from H1881 buffer
    LD    A,(HL)
    OR    A
    JP    NZ,H18DE
    CALL    H1B85
    LD    HL,0000H
    RET
H18DE:    DEC    (HL)
    DEC    (HL)
    LD    C,(HL)
    LD    B,00H
    LD    HL,H1881
    ADD    HL,BC
    LD    C,(HL)
    INC    HL
    LD    H,(HL)
    LD    L,C
    RET
H18EC:  CALL    H18CF           ;get 2 pairs from H1881 buffer to HL and DE regs
    EX    DE,HL
    CALL    H18CF
    RET
H18F4:  LD      L,A             ;call subroutine from H1901 table based on
        LD      H,00H           ;parm1 value from H186D table
    ADD    HL,HL
    LD    DE,H1901
    ADD    HL,DE
    LD    E,(HL)
    INC    HL
    LD    H,(HL)
    LD    L,E
    JP    (HL)
H1901:    DW      H1989
    DW      H1992
    DW      H1999
    DW      H199F
    DW      H19AB
    DW      H19BF
    DW      H19C6
    DW      H19D0
    DW      H19D9
    DW      H19E0
    DW      H19EC
    DW      H19F8
    DW      H1B85
H191B:    CALL    H18EC
    LD    A,D
    OR    A
    JP    NZ,H1927
    LD    A,E
    CP    11H
    RET    C
H1927:  CALL    H1B85           ;call 'E' error
    LD    A,10H
    RET
H192D:    XOR    A
    SUB    L
    LD    L,A
    LD    A,00H
    SBC    A,H
    LD    H,A
    RET
H1935:    CALL    H18EC
H1938:    EX    DE,HL
    LD    (H196B),HL
    LD    HL,H196D
    LD    (HL),11H
    LD    BC,0000H
    PUSH    BC
    XOR    A
H1946:    LD    A,E
    RLA
    LD    E,A
    LD    A,D
    RLA
    LD    D,A
    DEC    (HL)
    POP    HL
    RET    Z
    LD    A,00H
    ADC    A,00H
    ADD    HL,HL
    LD    B,H
    ADD    A,L
    LD    HL,(H196B)
    SUB    L
    LD    C,A
    LD    A,B
    SBC    A,H
    LD    B,A
    PUSH    BC
    JP    NC,H1964
    ADD    HL,BC
    EX    (SP),HL
H1964:    LD    HL,H196D
    CCF
    JP    H1946
H196B:    NOP
    NOP
H196D:    NOP
H196E:    LD    B,H
    LD    C,L
    LD    HL,0000H
H1973:    XOR    A
    LD    A,B
    RRA
    LD    B,A
    LD    A,C
    RRA
    LD    C,A
    JP    C,H1982
    OR    B
    RET    Z
    JP    H1983
H1982:    ADD    HL,DE
H1983:    EX    DE,HL
    ADD    HL,HL
    EX    DE,HL
    JP    H1973
H1989:    CALL    H18EC
    CALL    H196E
    JP    H1A01
H1992:    CALL    H1935
    EX    DE,HL
    JP    H1A01
H1999:    CALL    H1935
    JP    H1A01
H199F:    CALL    H191B
H19A2:    OR    A
    JP    Z,H1A01
    ADD    HL,HL
    DEC    A
    JP    H19A2
H19AB:    CALL    H191B
H19AE:    OR    A
    JP    Z,H1A01
    PUSH    AF
    XOR    A
    LD    A,H
    RRA
    LD    H,A
    LD    A,L
    RRA
    LD    L,A
    POP    AF
    DEC    A
    JP    H19AE
H19BF:    CALL    H18EC
H19C2:    ADD    HL,DE
    JP    H1A01
H19C6:    CALL    H18EC
    EX    DE,HL
    CALL    H192D
    JP    H19C2
H19D0:    CALL    H18CF
H19D3:    CALL    H192D
    JP    H1A01
H19D9:    CALL    H18CF
    INC    HL
    JP    H19D3
H19E0:    CALL    H18EC
    LD    A,D
    AND    H
    LD    H,A
    LD    A,E
    AND    L
    LD    L,A
    JP    H1A01
H19EC:    CALL    H18EC
    LD    A,D
    OR    H
    LD    H,A
    LD    A,E
    OR    L
    LD    L,A
    JP    H1A01
H19F8:    CALL    H18EC
    LD    A,D
    XOR    H
    LD    H,A
    LD    A,E
    XOR    L
    LD    L,A
H1A01:    JP    H1893
H1A04:    LD    A,(H0185)
    CP    04H
    RET    NZ
    LD    A,(H0189)
    CP    0DH
    RET    Z
    CP    3BH
    RET    Z
    CP    2CH
    RET    Z
    CP    21H
    RET
H1A19:    XOR    A
    LD    (H1891),A
    LD    (H1892),A
    DEC    A
    LD    (H186C),A
    LD    HL,0000H
    LD    (H01C9),HL
H1A2A:    CALL    H1A04
    JP    NZ,H1A5D
H1A30:    LD    HL,H1891
    LD    A,(HL)
    OR    A
    JP    Z,H1A48
    DEC    (HL)
    LD    E,A
    DEC    E
    LD    D,00H
    LD    HL,H186D
    ADD    HL,DE
    LD    A,(HL)
        CALL    H18F4           ;call subroutine from table
    JP    H1A30
H1A48:    LD    A,(H1892)
    CP    02H
        CALL    NZ,H1B85        ;call 'E' error
    LD    A,(H010C)
    CP    20H
    RET    NZ
    LD    HL,(H1881)
    LD    (H01C9),HL
    RET
H1A5D:    LD    A,(H010C)
    CP    20H
    JP    NZ,H1B7F
        LD      A,(H0185)       ;char type
    CP    03H
    JP    NZ,H1A89
    LD    A,(H0188)
    OR    A
    CALL    Z,H1B85
    CP    03H
    CALL    NC,H1B85
    LD    D,00H
    LD    HL,H0189
    LD    E,(HL)
    INC    HL
    DEC    A
    JP    Z,H1A85
    LD    D,(HL)
H1A85:    EX    DE,HL
    JP    H1B71
H1A89:  CP      02H             ;char type = numeric
    JP    NZ,H1A94
        LD      HL,(H0186)      ;numeric value
    JP    H1B71

; non-alphanumeric chars encountered in label being evaluated come here to
; evaluate possible expression (math)

H1A94:  CALL    H15A6           ;scan for match. if match then ACC=parm1 B=parm2
        JP      NZ,H1B31        ;taken if no match
    CP    10H
    JP    NC,H1B26
    CP    0CH
    LD    C,A
    LD    A,(H186C)
    JP    NZ,H1AB5
    OR    A
        CALL    Z,H1B85         ; 'E' error
    LD    A,0FFH
    LD    (H186C),A
    LD    A,C
    JP    H1B03
H1AB5:    OR    A
    JP    NZ,H1B0E
H1AB9:    PUSH    BC
    LD    A,(H1891)
    OR    A
    JP    Z,H1ADE
    LD    E,A
    DEC    E
    LD    D,00H
    LD    HL,H1877
    ADD    HL,DE
    LD    A,(HL)
    CP    B
    JP    C,H1ADE
    LD    HL,H1891
    LD    (HL),E
    LD    HL,H186D
    ADD    HL,DE
    LD    A,(HL)
        CALL    H18F4           ;call subroutine from table
    POP    BC
    JP    H1AB9
H1ADE:    POP    BC
    LD    A,C
    CP    0DH
    JP    NZ,H1B03
    LD    HL,H1891
    LD    A,(HL)
    OR    A
    JP    Z,H1AFC
    DEC    A
    LD    (HL),A
    LD    E,A
    LD    D,00H
    LD    HL,H186D
    ADD    HL,DE
    LD    A,(HL)
    CP    0CH
    JP    Z,H1AFF
H1AFC:    CALL    H1B85
H1AFF:    XOR    A
    JP    H1B08
H1B03:    CALL    H18B0
    LD    A,0FFH
H1B08:    LD    (H186C),A
    JP    H1B7F
H1B0E:  LD      A,C             ;parm1
    CP    05H
    JP    Z,H1B7F
    CP    06H
    JP    NZ,H1B1E
        INC     A               ;f(-)
    LD    C,A
    JP    H1AB9
H1B1E:  CP      08H             ;f(NOT) = 8
    CALL    NZ,H1B85
    JP    H1AB9
H1B26:    CP    11H
    CALL    Z,H1B85
    LD    L,B
    LD    H,00H
    JP    H1B71
H1B31:    LD    A,(H0185)
    CP    04H
    JP    NZ,H1B50
    LD    A,(H0189)
        CP      24H             ; '$'
    JP    Z,H1B4A
    CALL    H1B85
    LD    HL,0000H
    JP    H1B71
H1B4A:    LD    HL,(H01D2)
    JP    H1B71
H1B50:  CALL    H1346           ;check for duplicate label
        CALL    H1349           ;test results
        JP      NZ,H1B64        ;taken if no duplicate
        LD      A,50H           ; 'P'
        CALL    H0218           ;error
        CALL    H134C           ;add symbol
    JP    H1B6E
H1B64:  CALL    H1352           ;test nibble
    AND    07H
        LD      A,55H           ; 'U'
        CALL    Z,H0218         ;error
H1B6E:  CALL    H1358           ;get symbol value into HL
H1B71:    LD    A,(H186C)
    OR    A
    CALL    Z,H1B85
    XOR    A
    LD    (H186C),A
    CALL    H1893
H1B7F:  CALL    H1106           ;f(+)
    JP    H1A2A
H1B85:  PUSH    HL              ; 'E' error
    LD    A,45H
    CALL    H0218
    POP    HL
    RET
H1B8D:    CALL    H1352
    OR    A
    JP    Z,H1DB5
    RET
    DB      0,0,0,0,0,0,0,0,0,0,0
H1BA0:  XOR     A               ;entry to assembler with PRN and HEX files open
        LD      (H01CF),A       ;reset pass count to 0
        CALL    H1343           ;clear buffer

; 2nd pass loops here

H1BA7:  CALL    H1103           ;new line (send CR/LF to PRN file)
        CALL    H0203           ;open ASM file
    LD    HL,0000H
    LD    (H20EB),HL
    LD    (H01D0),HL
    LD    (H01D2),HL
    LD    (H20ED),HL
H1BBC:  CALL    H1106           ;parse word into H0189 and H010C buffers and
H1BBF:  LD      A,(H0185)       ;set char type in H0185
    CP    02H
        JP      Z,H1BBC         ;handle digit
    CP    04H
    JP    NZ,H1BDD
    LD    A,(H0189)
        CP      2AH             ; '*'
    JP    NZ,H1F31
    CALL    H2000
        JP      NZ,H1F7C        ; 'S' error
    JP    H1F52
H1BDD:    CP    01H
        JP      NZ,H1F7C        ;not alpha
        CALL    H15A6           ;check word for match
    JP    Z,H1C30
        CALL    H1346           ;check for duplicate label
        CALL    H1349           ;test results
        JP      NZ,H1BFE        ;if no duplicate
        CALL    H134C           ;add symbol to table
        LD      A,(H01CF)       ;assembler pass#
    OR    A
        CALL    NZ,H20D7        ; 'P' error if duplicate symbol on 1st pass
    JP    H1C0C
H1BFE:  CALL    H1352           ;get symbol assignment nibble
    CP    06H
        JP      NZ,H1C0C        ;if label assigned value
        CALL    H20E3           ; 'N' error
    JP    H1F52
H1C0C:    LD    HL,(H20EB)
    LD    A,L
    OR    H
        CALL    NZ,H20DD        ; 'L' error
    LD    HL,(H01D6)
    LD    (H20EB),HL
    CALL    H1106
    LD    A,(H0185)
    CP    04H
    JP    NZ,H1BBF
    LD    A,(H0189)
    CP    3AH
    JP    NZ,H1BBF
    JP    H1BBC
H1C30:    CP    11H
    JP    NZ,H1DD7
    LD    E,B
    LD    D,00H
    DEC    DE
    LD    HL,H1C43
    ADD    HL,DE
    ADD    HL,DE
    LD    E,(HL)
    INC    HL
    LD    H,(HL)
    LD    L,E
    JP    (HL)

;table for parm1 = 11h. parm2 referenced in ()

H1C43:  DW      H1C5B   ;(01h) DB
        DW      H1CA9   ;(02h) DS
        DW      H1CC0   ;(03h) DW
        DW      H1CDE   ;(04h) END
        DW      H1D15   ;(05h) ENDIF
        DW      H1D18   ;(06h) ENDM (function not supported. gives 'N' error)
        DW      H1D1E   ;(07h) EQU
        DW      H1D40   ;(08h) IF
        DW      H1D87   ;(09h) MACRO (function not supported. gives 'N' error)
        DW      H1D8D   ;(0Ah) ORG
        DW      H1DA7   ;(0Bh) SET
        DW      H1DCE   ;(0Ch) TITLE
H1C5B:    CALL    H200A
H1C5E:    CALL    H1106
    LD    A,(H0185)
    CP    03H
    JP    NZ,H1C8C
    LD    A,(H0188)
    DEC    A
    JP    Z,H1C8C
    LD    B,A
    INC    B
    INC    B
    LD    HL,H0189
H1C76:    DEC    B
    JP    Z,H1C86
    PUSH    BC
    LD    B,(HL)
    INC    HL
    PUSH    HL
    CALL    H2048
    POP    HL
    POP    BC
    JP    H1C76
H1C86:    CALL    H1106
    JP    H1C9B
H1C8C:    CALL    H1863
    LD    HL,(H01C9)
    LD    A,H
    OR    A
        CALL    NZ,H20D1        ; 'D' error if DB label not 8-bit value
    LD    B,L
    CALL    H2048
H1C9B:    CALL    H1FF9
    CALL    H1EBA
    CP    2CH
    JP    Z,H1C5E
    JP    H1F31
H1CA9:  CALL    H200A           ;f(DS)
    CALL    H20A6
        CALL    H1ED1           ;get 16 bit value/address into HL
    EX    DE,HL
    LD    HL,(H01D2)
    ADD    HL,DE
    LD    (H01D2),HL
        LD      (H01D0),HL      ;address PC counter
    JP    H1F31
H1CC0:  CALL    H200A           ;f(DW)
H1CC3:    CALL    H1ED1
    PUSH    HL
    LD    B,L
    CALL    H2048
    POP    HL
    LD    B,H
    CALL    H2048
    CALL    H1FF9
    CALL    H1EBA
    CP    2CH
    JP    Z,H1CC3
    JP    H1F31
H1CDE:  CALL    H200A           ;f(END)
        CALL    H20A6           ;print final PRN line addr to buffer
    LD    A,(H010C)
    CP    20H
    JP    NZ,H1F31
        CALL    H1ED1           ;get addr to HL of symbol following END (if any)
        LD      A,(H010C)       ;END w/o symbol gives 'E' error (both passes)
    CP    20H
    JP    NZ,H1CFA
        LD      (H20ED),HL      ;value of symbol after END. possibly EOF addr?
H1CFA:    LD    A,20H
    LD    (H010C),A
    CALL    H1106
    LD    A,(H0185)
    CP    04H
    JP    NZ,H1F7C
    LD    A,(H0189)
    CP    0AH
    JP    NZ,H1F7C
    JP    H1F8B
H1D15:  JP      H1DD1           ;f(ENDIF)
H1D18:  CALL    H20E3           ;f(ENDM) gives 'N' error (not supported)
    JP    H1DD1
H1D1E:  CALL    H2000           ;f(EQU)
    JP    Z,H1F7C
    LD    HL,(H01D2)
    PUSH    HL
    CALL    H1ED1
    LD    (H01D2),HL
    CALL    H200A
    CALL    H20A9
    LD    HL,H0112
    LD    (HL),3DH
    POP    HL
    LD    (H01D2),HL
    JP    H1F31
H1D40:  CALL    H200A           ;f(IF)
    CALL    H1ED1
    LD    A,(H010C)
    CP    20H
    JP    NZ,H1F31
    LD    A,L
    RRA
    JP    C,H1F31
H1D53:    CALL    H1106
    LD    A,(H0185)
    CP    04H
    JP    NZ,H1D6E
    LD    A,(H0189)
    CP    1AH
    LD    A,42H
    CALL    Z,H0218
    JP    Z,H1F8B
    JP    H1D53
H1D6E:    CP    01H
    JP    NZ,H1D53
    CALL    H15A6
    JP    NZ,H1D53
    CP    11H
    JP    NZ,H1D53
    LD    A,B
    CP    05H
    JP    NZ,H1D53
    JP    H1DD1
H1D87:  CALL    H20E3           ;f(MACRO) gives 'N' error (not supported)
    JP    H1F31
H1D8D:  CALL    H1ED1           ;f(ORG)
    LD    A,(H010C)
    CP    20H
    JP    NZ,H1F31
        LD      (H01D2),HL      ;ORG address for PC counters
    LD    (H01D0),HL
    CALL    H200A
    CALL    H20A6
    JP    H1F31
H1DA7:  CALL    H2000           ;f(SET)
    JP    Z,H1F7C
    CALL    H1B8D
    CP    05H
    CALL    NZ,H20DD
H1DB5:    LD    A,05H
    CALL    H134F
    CALL    H1ED1
    PUSH    HL
    CALL    H2000
    POP    HL
    CALL    H1355
    LD    HL,0000H
    LD    (H20EB),HL
    JP    H1F31
H1DCE:    CALL    H20E3
H1DD1:    CALL    H1106
    JP    H1F31
H1DD7:  SUB     13H             ;ACC = parm1 value from H15A6 call
        CP      21H             ;bug here. should have been 0Fh
        JP      NC,H1F7C        ;taken for parm1<13h or >=34h (should be >=22h)
        LD      E,A             ;see table following. range only 13h to 21h
    LD    D,00H
    LD    HL,H1DEB
    ADD    HL,DE
    ADD    HL,DE
    LD    E,(HL)
    INC    HL
    LD    H,(HL)
    LD    L,E
    JP    (HL)

;table for parm1 = 13h to 21h. parm1 value in ()

H1DEB:  DW      H1E09   ;(13h) DI EI CMA CMC DAA HLT NOP RAL RAR RET RLC RRC STC
                        ;      PCHL SPHL XTHL XCHG
        DW      H1E12   ;(14h) LXI
        DW      H1E1E   ;(15h) DAD
        DW      H1E24   ;(16h) POP PUSH
        DW      H1E38   ;(17h) JMP CALL
        DW      H1E41   ;(18h) MOV
        DW      H1E50   ;(19h) MVI
        DW      H1E60   ;(1Ah) ACI ADI ANI CPI ORI XRI SUI SBI
        DW      H1E69   ;(1Bh) LDAX STAX
        DW      H1E78   ;(1Ch) LDA STA LHLD SHLD
        DW      H1E81   ;(1Dh) ADC ADD ANA CMP ORA XRA SUB SBB
        DW      H1E88   ;(1Eh) DCR INR
        DW      H1E8F   ;(1Fh) DCX INX
        DW      H1E9E   ;(20h) RST
        DW      H1EA5   ;(21h) IN OUT
H1E09:    CALL    H2048
    CALL    H1106
    JP    H1EB1
H1E12:  CALL    H1EFC   ;process reg char following LXI instruction
        CALL    H1F17   ;check for comma
    CALL    H1F11
    JP    H1EB1
H1E1E:  CALL    H1EFC   ;process reg char following DAD instruction
    JP    H1EB1
H1E24:    CALL    H1EF2
    CP    38H
    JP    Z,H1E31
    AND    08H
    CALL    NZ,H20BD
H1E31:    LD    A,C
    AND    30H
    OR    B
    JP    H1EAE
H1E38:    CALL    H2048
    CALL    H1F11
    JP    H1EB1
H1E41:  CALL    H1EF2   ;f(MOV)
    OR    B
    LD    B,A
    CALL    H1F17
        CALL    H1EE7   ;parse reg value
    OR    B
    JP    H1EAE
H1E50:  CALL    H1EF2   ;get reg mask following MVI instruction
    OR    B
        CALL    H2047   ;store opcode
        CALL    H1F17   ;check for comma
        CALL    H1F0B   ;parse and store 8 bit label/value after comma
    JP    H1EB1
H1E60:  CALL    H2048   ;store opcode in HEX file
        CALL    H1F0B   ;parse operand
    JP    H1EB1
H1E69:    CALL    H1EF2
    AND    28H
    CALL    NZ,H20BD
    LD    A,C
    AND    10H
    OR    B
    JP    H1EAE
H1E78:    CALL    H2048
    CALL    H1F11
    JP    H1EB1
H1E81:    CALL    H1EE7
    OR    B
    JP    H1EAE
H1E88:    CALL    H1EF2
    OR    B
    JP    H1EAE
H1E8F:    CALL    H1EF2
    AND    08H
    CALL    NZ,H20BD
    LD    A,C
    AND    30H
    OR    B
    JP    H1EAE
H1E9E:    CALL    H1EF2
    OR    B
    JP    H1EAE
H1EA5:    CALL    H2048
    CALL    H1F0B
    JP    H1EB1
H1EAE:    CALL    H2047
H1EB1:  CALL    H200A   ;each instruction line comes here to close
        CALL    H1FF9   ;update PRN file PC counter (H01D2) for next line
    JP    H1F31
H1EBA:    LD    A,(H0185)
    CP    04H
    CALL    NZ,H20D1
    LD    A,(H0189)
    CP    2CH
    RET    Z
    CP    3BH
    RET    Z
    CP    0DH
    CALL    NZ,H20D1
    RET
H1ED1:  PUSH    BC      ;get 16 bit reg value or label address into HL reg.
        CALL    H1106           ;parse word
        CALL    H1863           ;process word
        LD      HL,(H01C9)      ;holds value (example: C reg value = 0001)
    POP    BC
    RET
H1EDD:  CALL    H1ED1   ;get 8 bit reg value or label address into ACC reg.
    LD    A,H
    OR    A
    CALL    NZ,H20C7
    LD    A,L
    RET
H1EE7:  CALL    H1EDD   ;parse 8 bit reg char value into ACC (0 to 7 = ACC to M)
    CP    08H
        CALL    NC,H20C7        ; 'V' error (bad register designation)
    AND    07H
    RET
H1EF2:  CALL    H1EE7   ;get 8 bit reg char value (0-7) into bits 3,4,5 of ACC
    RLA
    RLA
    RLA
    AND    38H
    LD    C,A
    RET
H1EFC:  CALL    H1EF2   ;store 16 bit regs (even# B,D or H) ORA'd with B(=parm2)
        AND     08H             ;bit 3 set if odd# reg (ACC,C,E or L)
        CALL    NZ,H20BD        ; 'R' error
    LD    A,C
    AND    30H
    OR    B
    JP    H2047
H1F0B:  CALL    H1EDD   ;parse and store 8 bit label/address (operand)
    JP    H2047
H1F11:  CALL    H1ED1   ;parse and store 16 bit label/address (operand)
    JP    H2074
H1F17:  PUSH    AF      ;check for comma
    PUSH    BC
    LD    A,(H0185)
    CP    04H
    JP    NZ,H1F29
    LD    A,(H0189)
    CP    2CH
    JP    Z,H1F2E
H1F29:    LD    A,43H
    CALL    H0218
H1F2E:    POP    BC
    POP    AF
    RET
H1F31:    CALL    H200A
    LD    A,(H0185)
    CP    04H
    JP    NZ,H1F7C
    LD    A,(H0189)
    CP    0DH
    JP    NZ,H1F4A
    CALL    H1106
    JP    H1BBC
H1F4A:  CP      3BH             ; ';'
    JP    NZ,H1F72
    CALL    H200A
H1F52:    CALL    H1106
    LD    A,(H0185)
    CP    04H
    JP    NZ,H1F52
    LD    A,(H0189)
    CP    0AH
    JP    Z,H1BBC
    CP    1AH
    JP    Z,H1F8B
    CP    21H
    JP    Z,H1BBC
    JP    H1F52
H1F72:  CP      21H             ; '!'
    JP    Z,H1BBC
    CP    1AH
    JP    Z,H1F8B
H1F7C:    LD    A,53H
    CALL    H0218
    JP    H1F52
H1F84:  LD      A,E             ;HL=DE-HL
    SUB    L
    LD    L,A
    LD    A,D
    SBC    A,H
    LD    H,A
    RET
H1F8B:  LD      HL,H01CF        ;assembler pass count
    LD    A,(HL)
        INC     (HL)            ;increment 1st to 2nd pass
    OR    A
        JP      Z,H1BA7         ;if 2nd pass
        CALL    H1106           ;here after 2nd pass
    CALL    H20A6
    LD    HL,H0111
    LD    (HL),0DH
    LD    HL,H010D
    CALL    H0212
    LD    HL,(H01CB)
    EX    DE,HL
    LD    HL,(H01D4)
    CALL    H1F84
    PUSH    HL
    LD    HL,(H01CD)
    EX    DE,HL
    LD    HL,(H01D4)
    CALL    H1F84
    LD    E,H
    LD    D,00H
    POP    HL
    CALL    H1869
    EX    DE,HL
        CALL    H20A9           ;put HL in PRN buffer just before 'USE FACTOR'
    LD    HL,H0111
    LD    DE,H1FD6
H1FCB:  LD      A,(DE)          ;put 'USE FACTOR' in PRN buffer
    OR    A
    JP    Z,H1FE4
    LD    (HL),A
    INC    HL
    INC    DE
    JP    H1FCB
H1FD6:    DB      "H USE FACTOR"
    DB      0DH,00H
H1FE4:    LD    HL,H010E
    CALL    H0212
    LD    HL,(H20ED)
    LD    (H01D0),HL
        JP      H021E           ;go close files and exit
H1FF3:    LD    A,D
    CP    H
    RET    NZ
    LD    A,E
    CP    L
    RET
H1FF9:    LD    HL,(H01D0)
    LD    (H01D2),HL
    RET
H2000:  LD      HL,(H20EB)      ;test H20EB for 0. move to H01D6 and ret in HL
    LD    (H01D6),HL
    CALL    H1349
    RET

; on 1st pass if H20EB non-zero then set PC counter to value of symbol operand
; at (H20EB). clear up unevaluated label, if any. on 2nd pass make sure label
; value is set and matches current PC else 'P' phase error

H200A:  CALL    H2000
    RET    Z
    LD    HL,0000H
    LD    (H20EB),HL
        LD      A,(H01CF)       ;pass count
    OR    A
        JP      NZ,H2031        ;if 2nd pass
        CALL    H1352           ;test nibble (see H134F notes)
    PUSH    AF
    AND    07H
        CALL    NZ,H20DD        ; 'L' error
    POP    AF
    OR    01H
        CALL    H134F           ;set nibble flag
    LD    HL,(H01D2)
        CALL    H1355           ;set value of symbol to HL
    RET
H2031:  CALL    H1352           ;test nibble
    AND    07H
        CALL    Z,H20D7         ; 'P' error
        CALL    H1358           ;get symbol value
    EX    DE,HL
    LD    HL,(H01D2)
    CALL    H1FF3
    CALL    NZ,H20D7
    RET

;on 2nd pass store byte from ACC in hex ascii form to H010C PRN line buffer
;and HEX file. also write PC address in hex ascii if at beginning of line.

H2047:  LD      B,A
H2048:  LD      A,(H01CF)       ;store byte in B reg
        OR      A               ;pass count
    LD    A,B
        JP      Z,H206C         ;if 1st pass, only advance PC counter
    PUSH    BC
        CALL    H021B           ;write byte to HEX file
    LD    A,(H010D)
    CP    20H
        LD      HL,(H01D2)      ;PC counter of PRN line
        CALL    Z,H20A9         ;print PC at start of PRN line (if no error)
        LD      A,(H20EF)       ;PRN file line index
        CP      10H             ;10h = start of label field
    POP    BC
    JP    NC,H206C
    LD    A,B
        CALL    H2096           ;print byte in hex to PRN file
H206C:  LD      HL,(H01D0)      ;advance PC counter
    INC    HL
    LD    (H01D0),HL
    RET
H2074:  PUSH    HL              ;write HL to PRN buffer and HEX file
    LD    B,L
    CALL    H2048
    POP    HL
    LD    B,H
    JP    H2048
H207E:    ADD    A,30H
    CP    3AH
    RET    C
    ADD    A,07H
    RET
H2086:    CALL    H207E
    LD    HL,H20EF
    LD    E,(HL)
    LD    D,00H
    INC    (HL)
    LD    HL,H010C
    ADD    HL,DE
    LD    (HL),A
    RET
H2096:  PUSH    AF              ;print byte to PRN buffer
    RRA
    RRA
    RRA
    RRA
    AND    0FH
    CALL    H2086
    POP    AF
    AND    0FH
    JP    H2086
H20A6:  LD      HL,(H01D2)      ;print PC addr in ascii to PRN buffer
H20A9:    EX    DE,HL
    LD    HL,H20EF
    PUSH    HL
    LD    (HL),01H
    LD    A,D
    PUSH    DE
    CALL    H2096
    POP    DE
    LD    A,E
    CALL    H2096
    POP    HL
    INC    (HL)
    RET
H20BD:  PUSH    AF              ; 'R' error
    PUSH    BC
    LD    A,52H
    CALL    H0218
    POP    BC
    POP    AF
    RET
H20C7:  PUSH    AF              ; 'V' error
    PUSH    HL
    LD    A,56H
    CALL    H0218
    POP    HL
    POP    AF
    RET
H20D1:  PUSH    AF              ; 'D' error
    LD    A,44H
    JP    H20E6
H20D7:  PUSH    AF              ; 'P' error
    LD    A,50H
    JP    H20E6
H20DD:  PUSH    AF              ; 'L' error
    LD    A,4CH
    JP    H20E6
H20E3:  PUSH    AF              ; 'N' error
    LD    A,4EH
H20E6:    CALL    H0218
    POP    AF
    RET
H20EB:  DS      02H             ;last H01D6 value from H1346 call
H20ED:  DS      02H             ;EOF addr after 'END' (value of symbol)
H20EF:  DS      1               ;char index into H010C PRN line buffer
H20F0:  DS      1               ;label table begins here
    END
