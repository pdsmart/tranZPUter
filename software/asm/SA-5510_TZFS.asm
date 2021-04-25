; Disassembly of the file "SA-5510.bin"
; 
; CPU Type: Z80
; 
; Created with dZ80 2.1
; 
; on Wednesday, 31 of March 2021 at 11:11 PM
; 

BUILD_ORIG  EQU     0                   ; Build BASIC SA-5510 with original configuration, identical to version loaded from tape.
BUILD_TZFS  EQU     1                   ; Build BASIC SA-5510 for use under TZFS with SD Card access via tranZPUter.

PRTC        EQU     0FEH
PRTD        EQU     0FFH
GETL        EQU     00003H
LETNL       EQU     00006H
NL          EQU     00009H
PRNTS       EQU     0000CH
PRNTT       EQU     0000FH
PRNT        EQU     00012H
MSG         EQU     00015H
MSGX        EQU     00018H
GETKY       EQU     0001BH
BRKEY       EQU     0001EH
?WRI        EQU     00021H
?WRD        EQU     00024H
?RDI        EQU     00027H
?RDD        EQU     0002AH
?VRFY       EQU     0002DH
MELDY       EQU     00030H
?TMST       EQU     00033H
TIMRD       EQU     0003BH
BELL        EQU     0003EH
XTEMP       EQU     00041H
MSTA        EQU     00044H
MSTP        EQU     00047H
MONIT       EQU     00000H
SS          EQU     00089H
ST1         EQU     00095H
HLHEX       EQU     00410H
_2HEX       EQU     0041FH
?MODE       EQU     0074DH
?KEY        EQU     008CAH
PRNT3       EQU     0096CH
?ADCN       EQU     00BB9H
?DACN       EQU     00BCEH
?DSP        EQU     00DB5H
?BLNK       EQU     00DA6H
?DPCT       EQU     00DDCH
PRTHL       EQU     003BAH
PRTHX       EQU     003C3H
ASC         EQU     003DAH
HEX         EQU     003F9H
DPCT        EQU     00DDCH
DLY12       EQU     00DA7H
DLY12A      EQU     00DAAH
?RSTR1      EQU     00EE6H
MOTOR       EQU     006A3H
CKSUM       EQU     0071AH
GAP         EQU     0077AH
WTAPE       EQU     00485H
MSTOP       EQU     00700H
LINEBUFR    EQU     0490DH
ATRB        EQU     010F0H
NAME        EQU     010F1H
SIZE        EQU     01102H
DTADR       EQU     01104H
EXADR       EQU     01106H
COMNT       EQU     01108H
SWPW        EQU     01164H
KDATW       EQU     0116EH
KANAF       EQU     01170H
DSPXY       EQU     01171H
MANG        EQU     01173H
MANGE       EQU     01179H
PBIAS       EQU     0117AH
ROLTOP      EQU     0117BH
MGPNT       EQU     0117CH
PAGETP      EQU     0117DH
ROLEND      EQU     0117FH
FLASH       EQU     0118EH
SFTLK       EQU     0118FH
REVFLG      EQU     01190H
SPAGE       EQU     01191H
FLSDT       EQU     01192H
STRGF       EQU     01193H
DPRNT       EQU     01194H
TMCNT       EQU     01195H
SUMDT       EQU     01197H
CSMDT       EQU     01199H
AMPM        EQU     0119BH
TIMFG       EQU     0119CH
SWRK        EQU     0119DH
TEMPW       EQU     0119EH
ONTYO       EQU     0119FH
OCTV        EQU     011A0H
RATIO       EQU     011A1H
BUFER       EQU     011A3H
CMT_RDINF   EQU     0E880H                                               ; UROMADDR+86H - Tape/SD intercept handler - Read Header
CMT_RDDATA  EQU     0E883H                                               ; UROMADDR+89H - Tape/SD intercept handler - Read Data
CMT_WRINF   EQU     0E886H                                               ; UROMADDR+80H - Tape/SD intercept handler - Write Header
CMT_WRDATA  EQU     0E889H                                               ; UROMADDR+8FH - Tape/SD intercept handler - Write Data
CMT_VERIFY  EQU     0E88CH                                               ; UROMADDR+92H - Tape/SD intercept handler - Verify Data
CMT_DIR     EQU     0E88FH                                               ; UROMADDR+95H - SD directory command.
CMT_CD      EQU     0E892H                                               ; UROMADDR+98H - SD command to change directory.
SET_FREQ    EQU     0E895H                                               ; UROMADDR+98H - Set CPU Frequency command
PRGSTART    EQU     011FDH                                               ; Build includes the tape copy code under original build.

            ; Original build set the tape handlers to original.
            IF BUILD_ORIG = 1
QRDI          EQU   ?RDI    
QRDD          EQU   ?RDD
QWRI          EQU   ?WRI
QWRD          EQU   ?WRD
            ENDIF
            IF BUILD_TZFS = 1
QRDI          EQU   TZFSRDI
QRDD          EQU   CMT_RDDATA
QWRI          EQU   CMT_WRINF
QWRD          EQU   CMT_WRDATA
            ENDIF

            ; Create an MZF Tape header.
            ORG     ATRB

            ; Declare the MZF header to bootstrap BASIC from tape/SD.
BOOTATRB:   DB      01h                                                  ; Code Type, 01 = Machine Code.
BOOTNAME:   IF BUILD_ORIG = 1
              DB    "BASIC SA-5510   ", 0Dh                              ; Title/Name (17 bytes).
            ENDIF
            IF BUILD_TZFS = 1
              DB    "BASIC SA-5510-TZ", 0Dh                              ; Title/Name (17 bytes).
            ENDIF
BOOTSIZE:   DW      BASICEND - TAPECOPY                                  ; Size of program.
BOOTDTADR:  DW      TAPECOPY                                             ; Load address of program.
BOOTEXADR:  DW      COLDSTRT                                             ; Exec address of program.
BOOTCOMNT:  DS      104                                                  ; COMMENT

            ORG     PRGSTART

TAPECOPY:   IF BUILD_ORIG = 1
              JP    TAPECOPYPRG
            ENDIF
            IF BUILD_TZFS = 1                                            ; Under TZFS build the tape copy code isnt needed so place NOP's where the call resides.
              NOP
              NOP
              NOP
            ENDIF

COLDSTRT:   LD      HL,048FFH           ; Scan for memory top.
            LD      D,0D0H              ; Full memory for original/TZFS build
L1205:      INC     HL
            LD      A,H
            CP      D
            JR      Z,L1214             ; (+00aH)
            LD      A,0FFH              ; Set location to 255, reread and subtract, should be 0 if real memory.
            LD      (HL),A
            SUB     (HL)
            JR      NZ,L1214            ; (+004H)
            LD      (HL),A
            CP      (HL)
            JR      Z,L1205             ; (-00fH)
L1214:      LD      (04908H),HL
            LD      (0490AH),HL
            LD      SP,HL
            CALL    BELL
            XOR     A
            LD      D,A
            LD      E,A
            CALL    ?TMST
            CALL    L132C
            CALL    L1313
            LD      DE,TITLEMSG
            CALL    L1329
            LD      DE,COPYRMSG
            CALL    L1329
            CALL    L131E
            CALL    L1944
            LD      BC,0000AH
            CALL    L184D
            CALL    L1841
            CALL    MSGNL
            LD      DE,BYTESMSG
            CALL    MSGX
            ;
            ; Warm start, entry point after command error or completion.
            ;
WARMSTRT:   NOP     
            NOP     
WARMSTRTMON:NOP                         ; Sharp defined BASIC restart location from Monitor.
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            LD      SP,(0490AH)
            LD      DE,READYMSG
            CALL    MSGNL
L1262:      LD      HL,L12B8
            PUSH    HL
L1266:      LD      HL,0504DH
            CALL    L19BA
            CALL    L19BA
            CALL    NL
            LD      DE,LINEBUFR
            LD      A,(L2A83)
            OR      A
            JR      Z,L1299             ; (+01eH)
            LD      HL,(L2A84)
            PUSH    HL
            LD      BC,(02A86H)
            ADD     HL,BC
            JR      C,L12A6             ; (+020H)
            LD      (L2A84),HL
            POP     HL
            PUSH    DE
            CALL    STRTONUM
            EX      DE,HL
            LD      (HL),020H
            INC     HL
            LD      (HL),00DH
            EX      DE,HL
            POP     DE
            CALL    MSGX
L1299:      CALL    L1338
            LD      A,(DE)
            CP      01BH
            RET     NZ
            XOR     A
            LD      (L2A83),A
            JR      L1299               ; (-00dH)

L12A6:      XOR     A
            LD      (L2A83),A
            JP      SYNTAXERR

            CALL    L1266
            LD      A,(DE)
            CP      00DH
            RET     Z
            LD      HL,(0490AH)
            LD      SP,HL
L12B8:      CALL    L146A
            CALL    L14F8
            LD      HL,(04A10H)
            LD      A,L
            OR      H
            JR      NZ,L12D4            ; (+00fH)
            LD      HL,04A12H
            LD      (05051H),HL
            CALL    EXECNOTCHR
            DB      00DH
            DW      L1B5F
            JP      L1262

L12D4:      CALL    L12DA
            JP      L1262

L12DA:      CALL    L145E
            CALL    L1459
            CALL    L18B0
            RET     PE
            LD      (DE),A
            CALL    Z,L1302
            LD      A,(04A12H)
            CP      00DH
            RET     Z
            CALL    L18B3
            DI      
            LD      (DE),A
            LD      (04A0EH),HL
            EX      DE,HL
            LD      HL,04A0EH
            CALL    L18F2
            CALL    L18A2
            JR      L130C               ; (+00aH)

L1302:      CALL    L18F2
            EX      DE,HL
            CALL    L1873
            CALL    L1762
L130C:      CALL    L19C3
            EX      DE,HL
            JP      L18EA

L1313:      LD      B,021H
L1315:      LD      A,0CFH
            CALL    PRNT
            DJNZ    L1315               ; (-007H)
            JR      L132C               ; (+00eH)

L131E:      LD      B,021H
L1320:      LD      A,0D7H
            CALL    PRNT
            DJNZ    L1320               ; (-007H)
            JR      L132C               ; (+003H)

L1329:      CALL    MSGX
L132C:      CALL    LETNL
            JP      LETNL

MSGNL:      CALL    NL
            JP      MSGX

L1338:      CALL    GETL
            LD      A,0C9H
            CALL    ?DPCT
            LD      A,000H
            LD      HL,SFTLK
            LD      (HL),A
            RET     

TITLEMSG:   DB      "  BASIC ",0A6H,0B0H,096H,092H,09DH,09EH,09DH,092H,096H,092H,09DH,"  SA-5510"
            DB      00DH
COPYRMSG:   DB      "  C",0B7H,09EH,0BDH,09DH,0A6H,097H,098H,096H," 1981 ",09AH,0BDH," SHARP C",0B7H,09DH,09EH,"."
            DB      00DH
READYMSG:   DB      "R",092H,0A1H,09CH,0BDH
            DB      00DH
ERRORMSG:   DB      "*E",09DH,09DH,0B7H,09DH
            DB      00DH
INMSG:      DB      " ",0A6H,0B0H
            DB      00DH
BREAKMSG:   DB      "*B",09DH,092H,0A1H,0A9H
            DB      00DH
BYTESMSG:   DB      " B",0BDH,096H,092H,0A4H
            DB      00DH
ERRCODE:    DB      012H                ; Storage of error code
            DB      000H
L13A5:      DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H

            ; Error table. A is loaded with code and the 01 is LD BC, so a 3E 01 would be LD A,01 and the next entry would be skipped as it would see 01 3E 02 or LB BC,023E.
            ; Designed to save code, the error code is loaded into A then it falls all the way to the bottom of this table before returning.
SYNTAXERR:  LD      A,1                 ; Syntax error
            DB      001H
OVFLERR:    LD      A,2                 ; Operation result overflow
            DB      001H
ILDATERR:   LD      A,3                 ; Illegal data
            DB      001H
DATMISERR:  LD      A,4                 ; Data type mismatch
            DB      001H
STRLENERR:  LD      A,5                 ; String length exceeded 255 characters
            DB      001H
MEMERR:     LD      A,6                 ; Insufficient memory capacity.
            DB      001H
            LD      A,7                 ; Size of array larger than previous definition.
            DB      001H
LINELENERR: LD      A,8                 ; Length of text line too long.
            DB      001H
GOSUBERR:   LD      A,10                ; GOSUB nest exceeds 16 deep.
            DB      001H
FORNEXTERR: LD      A,11                ; FOR-NEXT nest exceeds 16 deep.
            DB      001H
FUNCERR:    LD      A,12                ; FUNC levels exceed depth of 6.
            DB      001H
NEXTFORERR: LD      A,13                ; NEXT without FOR
            DB      001H
RETGOSBERR: LD      A,14                ; RETURN without GOSUB
            DB      001H
UNDEFFNERR: LD      A,15                ; Undefined function
            DB      001H
LINEERR:    LD      A,16                ; Unused reference line number
            DB      001H
CONTERR:    LD      A,17                ; CONT cannot be executed
            DB      001H
BADWRERR:   LD      A,18                ; Write statement to BASIC error
            DB      001H
CMDSTMTERR: LD      A,19                ; Direct mode and statements are mixed
            DB      001H
READDATAERR:LD      A,24                ; READ without DATA
            DB      001H
OPENERR:    LD      A,43                ; OPEN issued on already open file.
            DB      001H
UNKNWNERR:  LD      A,60                ; 
            DB      001H
OUTFILEERR: LD      A,63                ; Out of file
            DB      001H
PRTNRDYERR: LD      A,65                ; Printer not ready
            DB      001H
PRTHWERR:   LD      A,66                ; Printer hardware error
            DB      001H
PRTPAPERERR:LD      A,67                ; Out of paper
            DB      001H
CHKSUMERR:  LD      A,70                ; Check sum error
            JR      L1403               ; (+009H)

L13FA:      LD      IY,L1400
            RET     

            NOP     
L1400:      LD      A,(013FFH)
L1403:      LD      (ERRCODE),A
            CALL    L1ABF
            CALL    L1AB8
            JR      Z,L142A             ; (+01cH)
            LD      HL,05056H
            LD      A,(HL)
            CP      001H
            JR      NZ,L1421            ; (+00bH)
            INC     (HL)
            LD      HL,(0490AH)
            LD      SP,HL
            LD      HL,(05057H)
            JP      L1EAA

L1421:      CALL    L1991
            CALL    L1978
            CALL    L199E
L142A:      LD      DE,ERRORMSG
            CALL    MSGNL
            LD      HL,(ERRCODE)
            CALL    L1453
            JR      L143E               ; (+006H)

L1438:      LD      DE,BREAKMSG
            CALL    MSGNL
L143E:      LD      BC,WARMSTRT
            PUSH    BC
            XOR     A
            LD      (L2A83),A
            CALL    BELL
            CALL    L1AB8
            RET     Z
            LD      DE,INMSG
            CALL    MSGX
L1453:      CALL    L1841
            JP      MSGX

L1459:      XOR     A
            LD      (L1463),A
            RET     

L145E:      XOR     A
            LD      (05059H),A
            RET     

L1463:      NOP     
L1464:      SBC     A,C
            LD      H,D
            RET     Z
            RRCA    
            SUB     B
            LD      H,D
L146A:      LD      HL,LINEBUFR
            CALL    L17F6
            LD      (04A10H),DE
            LD      DE,04A12H
            LD      C,000H
L1479:      CALL    L1561
            RET     Z
            OR      A
            JP      M,SYNTAXERR
            DEC     DE
            PUSH    HL
            LD      HL,L1479
            EX      (SP),HL
            CP      03FH
            LD      B,088H
            JR      Z,L1498             ; (+00bH)
            DEC     HL
            PUSH    DE
            LD      DE,CMDWORDTBL
            CALL    L14C7
            JR      NZ,L14A8            ; (+011H)
            POP     DE
L1498:      LD      A,080H
            CALL    L14B3
            CP      084H
            RET     NC
L14A0:      CALL    L1595
            CP      ':'
            RET     Z
            POP     AF
            RET     

L14A8:      LD      DE,UNUSEDTBL1
            CALL    L14C7
            JR      NZ,L14B9            ; (+009H)
            POP     DE
            LD      A,081H
L14B3:      LD      (DE),A
            INC     DE
L14B5:      LD      A,B
            LD      (DE),A
            INC     DE
            RET     

L14B9:      LD      DE,OPERATORTBL
            LD      B,083H
            CALL    L14C9
            POP     DE
            JR      Z,L14B5             ; (-00fH)
            INC     HL
            INC     DE
            RET     

L14C7:      LD      B,080H
L14C9:      PUSH    HL
L14CA:      CALL    SKIPSPACE
            OR      A
            JP      M,L14F1
            EX      DE,HL
            CALL    SKIPSPACE
            EX      DE,HL
            SUB     (HL)
            INC     HL
            INC     DE
            JR      Z,L14CA             ; (-011H)
            ADD     A,080H
            JR      NZ,L14E2            ; (+003H)
            INC     SP
            INC     SP
            RET     

L14E2:      POP     HL
            DEC     DE
L14E4:      LD      A,(DE)
            INC     DE
            OR      A
            JR      Z,L14EF             ; (+006H)
            JP      P,L14E4
            INC     B
            JR      L14C9               ; (-026H)

L14EF:      DEC     A
            RET     

L14F1:      POP     HL
            CALL    SKIPSPACE
            DEC     A
            LD      A,(HL)
            RET     

L14F8:      LD      HL,(04A10H)
            LD      DE,LINEBUFR
            LD      C,0B2H
            CALL    L17FE
            LD      A,020H
            LD      (DE),A
            INC     DE
            LD      HL,04A12H
L150A:      CALL    L1561
            RET     Z
            SUB     080H
            JR      C,L150A             ; (-008H)
            DEC     DE
            DEC     C
            CP      003H
            JR      C,L1525             ; (+00dH)
            SUB     002H
            LD      B,A
            PUSH    HL
            LD      HL,OPERATORTBL
L151F:      CALL    L1554
            POP     HL
            JR      L150A               ; (-01bH)

L1525:      EX      AF,AF'
            LD      A,(HL)
            INC     HL
            SUB     07FH
            LD      B,A
            PUSH    HL
            EX      AF,AF'
            OR      A
            JR      Z,L153D             ; (+00dH)
            LD      HL,L151F
            PUSH    HL
            LD      HL,UNUSEDTBL1
            DEC     A
            RET     Z
            LD      HL,UNUSEDTBL2
            RET     

L153D:      PUSH    BC
            LD      HL,CMDWORDTBL
            CALL    L1554
            POP     AF
            LD      HL,L150A
            EX      (SP),HL
            CP      004H
            RET     NC
            JP      L14A0

L154F:      BIT     7,(HL)
            INC     HL
            JR      Z,L154F             ; (-005H)
L1554:      DJNZ    L154F               ; (-007H)
L1556:      CALL    L158A
            ADD     A,080H
            JR      NC,L1556            ; (-007H)
            DEC     DE
            LD      (DE),A
            INC     DE
            RET     

L1561:      CALL    L158A
            RET     Z
            CALL    L1575
            JR      Z,L1561             ; (-009H)
            CP      022H
            RET     NZ
            CALL    L1581
            CP      00DH
            JR      NZ,L1561            ; (-013H)
            RET     

L1575:      CP      020H
            RET     Z
            CP      PRTD
            RET     Z
            CP      028H
            RET     Z
            CP      029H
            RET     

L1581:      CALL    L158A
            RET     Z
            CP      022H
            JR      NZ,L1581            ; (-008H)
            RET     

L158A:      LD      A,(HL)
            LD      (DE),A
            INC     HL
            INC     DE
            INC     C
            JP      Z,LINELENERR
            CP      00DH
            RET     

L1595:      CALL    L158A
            RET     Z
            CP      ':'
            RET     Z
            CP      022H
            JR      NZ,L1595            ; (-00bH)
            CALL    L1581
            CP      00DH
            JR      NZ,L1595            ; (-012H)
            RET     

            ; Reserved word table.
CMDWORDTBL: DB      "RE",         "M" | 080H
            DB      "DAT",        "A" | 080H
            DB      0FFH              | 080H
            DB      0FFH              | 080H
            DB      "REA",        "D" | 080H
            DB      "LIS",        "T" | 080H
            DB      "RU",         "N" | 080H
            DB      "NE",         "W" | 080H
            DB      "PRIN",       "T" | 080H
            DB      "LE",         "T" | 080H
            DB      "FO",         "R" | 080H
            DB      "I",          "F" | 080H
            DB      "THE",        "N" | 080H
            DB      "GOT",        "O" | 080H
            DB      "GOSU",       "B" | 080H
            DB      "RETUR",      "N" | 080H
            DB      "NEX",        "T" | 080H
            DB      "STO",        "P" | 080H
            DB      "EN",         "D" | 080H
            DB      0FFH              | 080H
            DB      "O",          "N" | 080H
            DB      "LOA",        "D" | 080H
            DB      "SAV",        "E" | 080H
            DB      "VERIF",      "Y" | 080H
            DB      "POK",        "E" | 080H
            DB      "DI",         "M" | 080H
            DB      "DEF F",      "N" | 080H
            DB      "INPU",       "T" | 080H
            DB      "RESTOR",     "E" | 080H
            DB      "CL",         "R" | 080H
            DB      "MUSI",       "C" | 080H
            DB      "TEMP",       "O" | 080H
            DB      "USR",        "(" | 080H
            DB      "WOPE",       "N" | 080H
            DB      "ROPE",       "N" | 080H
            DB      "CLOS",       "E" | 080H
            DB      "MO",         "N" | 080H
            DB      "LIMI",       "T" | 080H
            DB      "CON",        "T" | 080H
            DB      "GE",         "T" | 080H
            DB      "INP",        "@" | 080H
            DB      "OUT",        "@" | 080H
            DB      "CURSO",      "R" | 080H
            DB      "SE",         "T" | 080H
            DB      "RESE",       "T" | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      "AUT",        "O" | 080H
            DB      0FFH              | 080H
            DB      0FFH              | 080H
            DB      "COPY/",      "P" | 080H
            DB      "PAGE/",      "P" | 080H
            IF BUILD_ORIG = 1
              DB    07FH              | 080H
              DB    07FH              | 080H
              DB    07FH              | 080H
              DB    07FH              | 080H
              DB    07FH              | 080H
              DB    07FH              | 080H
              DB    07FH              | 080H
              DB    07FH              | 080H
              DB    07FH              | 080H
            ENDIF
            IF BUILD_TZFS = 1
              DB    "DI",         "R" | 080H    ; New DIR command to list the SD card directory.
              DB    "C",          "D" | 080H    ; New CD command to change directory or to CMT/SD
              DB    "FRE",        "Q" | 080H    ; New FREQ command to change CPU speed.
            ENDIF
            DB      000H
UNUSEDTBL1: DB      07FH              | 080H
            DB      000H
UNUSEDTBL2: DB      07FH              | 080H
            DB      000H
OPERATORTBL:DB      ">",          "<" | 080H
            DB      "<",          ">" | 080H
            DB      "=",          "<" | 080H
            DB      "<",          "=" | 080H
            DB      "=",          ">" | 080H
            DB      ">",          "=" | 080H
            DB      07FH              | 080H
            DB      ">"               | 080H
            DB      "<"               | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      "T",          "O" | 080H
            DB      "STE",        "P" | 080H
            DB      "LEFT$",      "(" | 080H
            DB      "RIGHT$",     "(" | 080H
            DB      "MID$",       "(" | 080H
            DB      "LEN",        "(" | 080H
            DB      "CHR$",       "(" | 080H
            DB      "STR$",       "(" | 080H
            DB      "ASC",        "(" | 080H
            DB      "VAL",        "(" | 080H
            DB      "PEEK",       "(" | 080H
            DB      "TAB",        "(" | 080H
            DB      "SPACE$",     "(" | 080H
            DB      "SIZ",        "E" | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      "STRING$",    "(" | 080H
            DB      07FH              | 080H
            DB      "CHARACTER$", "(" | 080H
            DB      "CS",         "R" | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      07FH              | 080H
            DB      "RND",        "(" | 080H
            DB      "SIN",        "(" | 080H
            DB      "COS",        "(" | 080H
            DB      "TAN",        "(" | 080H
            DB      "ATN",        "(" | 080H
            DB      "EXP",        "(" | 080H
            DB      "INT",        "(" | 080H
            DB      "LOG",        "(" | 080H
            DB      "LN",         "(" | 080H
            DB      "ABS",        "(" | 080H
            DB      "SGN",        "(" | 080H
            DB      "SQR",        "(" | 080H
            DB      07FH              | 080H
            DB      000H
L173A:      LD      HL,(05051H)
            DEC     HL
INCSKIPSPCE:INC     HL
SKIPSPACE:  LD      A,(HL)
            CP      020H
            RET     NZ
            JR      INCSKIPSPCE         ; (-007H)

L1745:      PUSH    AF
            LD      A,00DH
L1748:      CP      (HL)
            INC     HL
            JR      NZ,L1748            ; (-004H)
            POP     AF
            RET     

L174E:      INC     HL
L174F:      CALL    L193B
            RET     Z
            CP      022H
            JR      NZ,L174E            ; (-009H)
L1757:      INC     HL
            LD      A,(HL)
            CP      00DH
            RET     Z
            CP      022H
            JR      NZ,L1757            ; (-009H)
            JR      L174E               ; (-014H)

L1762:      LD      A,C
            CPL     
            LD      C,A
            LD      A,B
            CPL     
            LD      B,A
            INC     BC
            RET     

L176A:      CALL    SKIPSPACE
            SUB     030H
            CP      00AH
            LD      A,(HL)
            RET     

L1773:      LD      A,H
            SUB     D
            RET     NZ
            LD      A,L
            SUB     E
            RET     

L1779:      POP     HL                  ; Get address after call and jump to it via a RET command.
L177A:      EX      (SP),HL
EXECHL:     PUSH    AF
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            POP     AF
            EX      (SP),HL
            RET     

L1783:      POP     HL
L1784:      EX      (SP),HL
            INC     HL
            INC     HL
            EX      (SP),HL
            RET     

L1789:      LD      HL,(04E94H)
            INC     HL
            INC     HL
            INC     HL
            INC     HL
            INC     HL
            RET     

L1792:      LD      HL,(05051H)
EXECNOTCHR: CALL    SKIPSPACE           ; Scan for character after command
            EX      (SP),HL
            CP      (HL)
            INC     HL
            JR      NZ,EXECHL           ; (-022H)
            INC     HL
            JR      L17AB               ; Move the return address pointer over the test character and function address.

L17A0:      LD      HL,(05051H)
MATCHCHR:   CALL    SKIPSPACE
            EX      (SP),HL
            CP      (HL)
            JP      NZ,SYNTAXERR
L17AB:      INC     HL
            EX      (SP),HL
            JR      INCSKIPSPCE         ; (-071H)

L17AF:      XOR     A
            CP      H
            JR      Z,L17B7             ; (+004H)
            EX      DE,HL
            CP      H
            JR      NZ,L177A            ; (-03dH)
L17B7:      LD      A,L
            LD      L,H
L17B9:      OR      A
            JR      Z,L17CC             ; (+010H)
            RRA     
            JR      NC,L17C2            ; (+003H)
            ADD     HL,DE
            JR      C,L177A             ; (-048H)
L17C2:      OR      A
            JR      Z,L17CC             ; (+007H)
            EX      DE,HL
            ADD     HL,HL
            EX      DE,HL
            JR      NC,L17B9            ; (-011H)
            JR      L177A               ; (-052H)

L17CC:      EX      DE,HL
            JR      L1784               ; (-04bH)

L17CF:      CALL    L17AF
            OR      C
            INC     DE
            RET     

L17D5:      LD      DE,MONIT
            LD      B,D
L17D9:      CALL    L176A
            JR      NC,L1784            ; (-05aH)
            AND     00FH
            LD      C,A
            XOR     A
            PUSH    HL
            LD      L,E
            LD      H,D
            ADD     HL,HL
            RRA     
            ADD     HL,HL
            RRA     
            ADD     HL,DE
            RRA     
            ADD     HL,HL
            RRA     
            ADD     HL,BC
            EX      DE,HL
            POP     HL
            INC     HL
            ADC     A,A
            JR      NC,L17D9            ; (-01bH)
            JR      L177A               ; (-07cH)

L17F6:      CALL    L17D5
            XOR     E
            INC     DE
            RET     

            ; Method to convert a number in HL to a string.
STRTONUM:   LD      C,000H
L17FE:      LD      A,020H
            LD      (DE),A
            INC     DE
            PUSH    DE
            LD      B,000H
            LD      DE,L2710
            CALL    L1827
            LD      DE,003E8H
            CALL    L1827
            LD      DE,00064H
            CALL    L1827
            LD      DE,0000AH
            CALL    L1827
            LD      A,L
            POP     HL
            OR      030H
            LD      (HL),A
            INC     HL
            LD      (HL),00DH
            EX      DE,HL
            RET     

L1827:      LD      A,0FFH
L1829:      INC     A
            OR      A
            SBC     HL,DE
            JR      NC,L1829            ; (-006H)
            ADD     HL,DE
            OR      A
            JR      NZ,L1836            ; (+003H)
            OR      B
            RET     Z
            XOR     A
L1836:      INC     B
            OR      030H
            POP     DE
            EX      (SP),HL
            LD      (HL),A
            INC     HL
            EX      (SP),HL
            PUSH    DE
            INC     C
            RET     

            ; Convert a string into a numeric and store.
L1841:      LD      DE,04AB3H           ; Conversion to be stored in location.
            PUSH    DE
            CALL    STRTONUM
            POP     DE
            RET     

L184A:      LD      BC,MONIT
L184D:      LD      HL,(04E94H)
            ADD     HL,BC
            JR      C,L185C             ; (+009H)
            EX      DE,HL
            LD      HL,0FF9CH
            ADD     HL,SP
            XOR     A
            SBC     HL,DE
            RET     NC
L185C:      JP      MEMERR

L185F:      PUSH    HL
            PUSH    DE
            CALL    L184D
            POP     DE
            POP     HL
            RET     

L1867:      LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            EX      DE,HL
            LD      A,L
            OR      H
            RET     

L1873:      PUSH    BC
            PUSH    HL
            PUSH    DE
            EX      DE,HL
            ADD     HL,BC
            EX      DE,HL
            CALL    L1789
            LD      A,L
            SUB     E
            LD      C,A
            LD      A,H
            SBC     A,D
            LD      B,A
            INC     BC
            POP     HL
            PUSH    HL
            EX      DE,HL
            JR      L18A8               ; (+020H)

L1888:      CALL    L185F
            PUSH    BC
            PUSH    HL
            PUSH    DE
            CALL    L1789
            PUSH    HL
            ADD     HL,BC
            EX      (SP),HL
            LD      A,L
            SUB     E
            LD      C,A
            LD      A,H
            SBC     A,D
            LD      B,A
            INC     BC
            POP     DE
            LDDR    
L189E:      POP     DE
            POP     HL
            POP     BC
            RET     

L18A2:      CALL    L1888
L18A5:      PUSH    BC
            PUSH    HL
            PUSH    DE
L18A8:      LD      A,C
            OR      B
            JR      Z,L189E             ; (-00eH)
            LDIR    
            JR      L189E               ; (-012H)

L18B0:      LD      (L18BF),HL
L18B3:      LD      HL,0505CH
L18B6:      PUSH    HL
            CALL    L1867
            JP      Z,L1779
            PUSH    HL
            DB      021H
L18BF:      DB      0AAH
            DB      00FH
            CALL    L1773
            POP     HL
            JP      Z,L1783
            JP      C,L1783
            POP     AF
            JR      L18B6               ; (-018H)

L18CE:      PUSH    HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            LD      A,E
            OR      D
            JP      Z,L1779
            DB      021H
L18D8:      DB      042H
            DB      04CH
            CALL    L1773
            POP     HL
            INC     HL
            INC     HL
            JP      L1784

L18E3:      ADD     HL,BC
            EX      DE,HL
            POP     HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            EX      DE,HL
L18EA:      PUSH    HL
            CALL    L1867
            JR      NZ,L18E3            ; (-00dH)
            POP     HL
            RET     

L18F2:      PUSH    HL
            LD      BC,00004H
            ADD     HL,BC
            CALL    L1900
            INC     BC
            POP     HL
            RET     

L18FD:      LD      BC,MONIT
L1900:      PUSH    HL
            LD      A,00DH
L1903:      CP      (HL)
            INC     HL
            INC     BC
            JR      NZ,L1903            ; (-005H)
            DEC     BC
            POP     HL
            RET     

L190B:      CALL    L1921
L190E:      LD      A,E
            EX      DE,HL
            LD      BC,MONIT
            LD      HL,(04E92H)
            DEC     HL
L1917:      INC     HL
            ADD     HL,BC
            CP      (HL)
            INC     HL
            LD      C,(HL)
            INC     HL
            JR      NZ,L1917            ; (-008H)
            EX      DE,HL
            RET     

L1921:      LD      A,D
            OR      A
            RET     NZ
            JR      L1929               ; (+003H)

L1926:      LD      A,D
            OR      A
            RET     Z
L1929:      JP      DATMISERR

L192C:      LD      HL,(04E94H)
            EX      DE,HL
L1930:      LD      BC,00005H
            LDIR    
            RET     

L1936:      LD      HL,(04E94H)
            JR      L1930               ; (-00bH)

L193B:      CALL    SKIPSPACE
            CP      00DH
            RET     Z
            CP      ':'
            RET     

L1944:      LD      HL,MONIT
            LD      (04E4CH),HL
            CALL    L1957
            CALL    L199E
            CALL    L1978
            CALL    L1459
            RET     

L1957:      LD      HL,0505CH
            CALL    L19BA
            LD      DE,04E4EH
L1960:      PUSH    HL
            LD      HL,04E96H
            XOR     A
            SBC     HL,DE
            LD      B,L
            SRL     B
            POP     HL
            EX      DE,HL
L196C:      XOR     A
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            LD      (DE),A
            INC     DE
            LD      (DE),A
            INC     DE
            DJNZ    L196C               ; (-00bH)
            RET     

L1978:      LD      HL,05040H
            LD      (04E9AH),HL
            LD      HL,04FD7H
            LD      (04E98H),HL
            LD      HL,04EBAH
            LD      (04E96H),HL
            LD      HL,05053H
            CALL    L19BA
            LD      (HL),A
L1991:      XOR     A
            LD      (05056H),A
            RET     

L1996:      LD      HL,(04E84H)
            LD      DE,04E84H
            JR      L1960               ; (-03eH)

L199E:      LD      HL,04DF2H
            LD      B,05AH
L19A3:      LD      (HL),000H
            INC     HL
            DJNZ    L19A3               ; (-005H)
            LD      B,01AH
            LD      HL,04E50H
L19AD:      LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            PUSH    HL
            EX      DE,HL
            CALL    L2E09
            POP     HL
            DJNZ    L19AD               ; (-00cH)
            RET     

L19BA:      XOR     A
L19BB:      LD      (HL),A
            INC     HL
            LD      (HL),A
            INC     HL
            RET     

L19C0:      CALL    L1888
L19C3:      PUSH    HL
            LD      A,E
            EX      AF,AF'
            LD      A,D
            LD      HL,04E94H
L19CA:      LD      E,(HL)
            INC     HL
            LD      D,(HL)
            CP      D
            JR      C,L19D7             ; (+007H)
            JR      NZ,L19E2            ; (+010H)
            EX      AF,AF'
            CP      E
            JR      NC,L19E1            ; (+00bH)
            EX      AF,AF'
L19D7:      EX      DE,HL
            ADD     HL,BC
            EX      DE,HL
            LD      (HL),D
            DEC     HL
            LD      (HL),E
            DEC     HL
            DEC     HL
            JR      L19CA               ; (-017H)

L19E1:      EX      AF,AF'
L19E2:      LD      D,A
            EX      AF,AF'
            LD      E,A
            POP     HL
            RET     

L19E7:      CALL    L1873
            PUSH    BC
            CALL    L1762
            CALL    L19C3
            POP     BC
            RET     

L19F3:      CALL    SKIPSPACE
            LD      DE,00D2CH
            LD      BC,MONIT
            CP      022H
            JR      NZ,L1A02            ; (+002H)
            LD      E,A
            INC     HL
L1A02:      PUSH    HL
L1A03:      LD      A,(HL)
            CP      D
            JR      Z,L1A0F             ; (+008H)
            CP      E
            INC     HL
            JR      Z,L1A0F             ; (+004H)
            INC     BC
            JR      L1A03               ; (-00bH)

L1A0E:      PUSH    HL
L1A0F:      EX      (SP),HL
            PUSH    HL
            CALL    L1A1E
            EX      DE,HL
            EX      (SP),HL
            CALL    L18A5
            POP     DE
            POP     HL
            JP      SKIPSPACE

L1A1E:      PUSH    BC
            XOR     A
            LD      E,A
            LD      HL,(04E92H)
            JR      L1A2B               ; (+005H)

L1A26:      INC     HL
            LD      C,(HL)
            INC     HL
            INC     HL
            ADD     HL,BC
L1A2B:      INC     E
            CP      (HL)
            JR      NZ,L1A26            ; (-009H)
            POP     BC
            PUSH    BC
            INC     BC
            INC     BC
            INC     BC
            EX      DE,HL
            CALL    L1888
            EX      DE,HL
            PUSH    HL
            ADD     HL,BC
            DEC     HL
            LD      (HL),00DH
            LD      HL,(04E94H)
            ADD     HL,BC
            LD      (04E94H),HL
            POP     HL
            POP     BC
            LD      (HL),E
            INC     HL
            LD      (HL),C
            INC     HL
            LD      D,001H
            RET     

L1A4E:      PUSH    HL
            LD      HL,(04E94H)
            LD      DE,MONIT
            LD      A,(HL)
            OR      A
            JP      P,L1779
            CP      0C1H
            JR      C,L1A72             ; (+014H)
            SUB     0D1H
            JP      NC,L1779
            LD      E,003H
            ADD     HL,DE
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            JR      L1A6F               ; (+004H)

L1A6B:      SRL     D
            RR      E
L1A6F:      INC     A
            JR      NZ,L1A6B            ; (-007H)
L1A72:      JP      L1783

L1A75:      CALL    EXECNOTCHR
            DB      00DH
            DW      L1A7E
            JP      L177A

L1A7E:      PUSH    HL
            DEC     HL
L1A80:      CALL    L1A91
            JR      Z,L1A80             ; (-005H)
            CP      00DH
            JP      NZ,L1779
            POP     HL
            CALL    L2333
            JP      L1784

L1A91:      CALL    INCSKIPSPCE
            CP      045H
            RET     Z
L1A97:      CALL    L176A
            JR      NC,L1A9E            ; (+002H)
            CP      (HL)
            RET     

L1A9E:      CP      02EH
            RET     Z
            CP      '+'
            RET     Z
            CP      '-'
            RET     

L1AA7:      PUSH    HL
            CALL    L1AB8
            POP     HL
            RET     Z
            JR      L1AB5               ; Command statement error.

L1AAF:      PUSH    HL
            CALL    L1AB8
            POP     HL
            RET     NZ
L1AB5:      JP      CMDSTMTERR

L1AB8:      LD      HL,(0504FH)
            LD      A,H
            OR      L
            RET     

L1ABE:      NOP     
L1ABF:      LD      HL,L1ABE
            XOR     A
            CP      (HL)
            LD      (HL),A
            JR      NZ,L1AEE            ; (+027H)
L1AC7:      LD      HL,0505CH
L1ACA:      LD      E,(HL)
            INC     HL
            LD      D,(HL)
            DEC     HL
            LD      A,E
            OR      D
            RET     Z
            CALL    L1773
            RET     C
            EX      DE,HL
            ADD     HL,DE
            EX      DE,HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            EX      DE,HL
            JR      L1ACA               ; (-014H)

L1ADE:      LD      HL,(04E4EH)
            LD      DE,0505CH
            DEC     HL
            DEC     HL
            XOR     A
            SBC     HL,DE
            LD      B,H
            LD      C,L
            JP      L19E7

L1AEE:      CALL    L1ADE
L1AF1:      CALL    L1996
            CALL    L199E
            CALL    L1978
            RET     

            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            PUSH    BC
            CALL    L1AEE
            POP     BC
            LD      A,B
            OR      A
            JR      NZ,L1B10            ; (+004H)
            LD      A,C
            CP      003H
            RET     C
L1B10:      PUSH    BC
            DEC     BC
            DEC     BC
            LD      DE,0505CH
            CALL    L19C0
            POP     BC
            RET     

L1B1B:      LD      HL,0505CH
L1B1E:      LD      E,(HL)
            INC     HL
            LD      D,(HL)
            DEC     HL
            LD      A,D
            OR      E
            RET     Z
            CALL    L1773
            RET     NC
            PUSH    DE
            EX      DE,HL
            XOR     A
            SBC     HL,DE
            EX      DE,HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            POP     HL
            JR      L1B1E               ; (-017H)

L1B35:      LD      HL,(05051H)
L1B38:      CALL    SKIPSPACE
L1B3B:      CP      00DH
            JR      Z,L1B45             ; (+006H)
            CALL    MATCHCHR
            DB      ':'
            JR      L1B5C               ; (+017H)

L1B45:      LD      HL,(0504DH)
            LD      A,H
            OR      L
            JP      Z,WARMSTRT
L1B4D:      LD      A,(HL)
            INC     HL
            OR      (HL)
            DEC     HL
            JP      Z,L1D17
            LD      DE,0504DH
            LD      BC,00004H
            LDIR    
L1B5C:      LD      (05051H),HL
L1B5F:      LD      A,(05056H)
            DEC     A
            CALL    Z,L1B9F
            CALL    BRKEY
            JR      NZ,L1B73            ; (+008H)
            LD      A,002H
            CALL    L29EB
            JP      L1438

L1B73:      LD      HL,(04E92H)
            CALL    L19BA
            LD      (04E94H),HL
            CALL    L173A
L1B7F:      SUB     080H
            JP      C,CMDLET
            INC     HL
            LD      C,(HL)
            INC     HL
            PUSH    HL
            LD      HL,CMDJMPTBL
            JP      NZ,SYNTAXERR
            LD      A,C
            ADD     A,080H
            JP      NC,SYNTAXERR
            LD      C,A
L1B95:      LD      B,000H
            ADD     HL,BC
            ADD     HL,BC
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            EX      (SP),HL
            RET     

L1B9F:      CALL    L1AB8
            RET     Z
            LD      DE,L13A5
            LD      HL,0504DH
            JR      NZ,L1BAC            ; (+001H)
            EX      DE,HL
L1BAC:      LD      BC,LETNL
            LDIR    
            RET     

CMDJMPTBL:  DW      CMDREMDATA
            DW      CMDREMDATA
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      CMDREAD
            DW      CMDLIST
            DW      CMDRUN
            DW      CMDNEW
            DW      CMDPRINT
            DW      CMDLET
            DW      CMDFOR
            DW      CMDIF
            DW      SYNTAXERR
            DW      CMDGOTO
            DW      CMDGOSUB
            DW      CMDRETURN
            DW      CMDNEXT
            DW      CMDSTOP
            DW      CMDEND
            DW      SYNTAXERR
            DW      CMDON
            DW      CMDLOAD
            DW      CMDSAVE
            DW      CMDVERIFY
            DW      CMDPOKE
            DW      CMDDIM
            DW      CMDDEFFN
            DW      CMDINPUT
            DW      CMDRESTORE
            DW      CMDCLS
            DW      CMDMUSIC
            DW      CMDTEMPO
            DW      CMDUSRN
            DW      CMDWOPEN
            DW      CMDROPEN
            DW      CMDCLOSE
            DW      CMDMON
            DW      CMDLIMIT
            DW      CMDCONT
            DW      CMDGET
            DW      CMDINP
            DW      CMDOUT
            DW      CMDCURSOR
            DW      CMDSET
            DW      CMDRESET
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      CMDAUTO
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      CMDCOPY
            DW      CMDPAGE
            IF BUILD_ORIG = 1
              DW    SYNTAXERR
              DW    SYNTAXERR
              DW    SYNTAXERR
            ENDIF
            IF BUILD_TZFS = 1
              DW    CMDDIR
              DW    CHGDIR
              DW    SETFREQ
            ENDIF
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
L1C32:      CALL    L193B
            JP      NZ,SYNTAXERR
            LD      (05051H),HL
            RET     

CMDREMDATA: CALL    L174F
            JP      L1B38

CMDNEW:     XOR     A
            LD      (L1463),A
            CALL    L1944
L1C49:      JP      WARMSTRT

L1C4C:      DB      006H
CMDLIST:    XOR     A
            LD      (L1CAB),A
            CALL    EXECNOTCHR
            DB      '/'
            DW      L1C60
            CALL    MATCHCHR
            DB      050H
            LD      A,001H
            LD      (L1CAB),A
L1C60:      CALL    L1AA7
            DB      03EH
            LD      A,(BC)
            LD      (L1C4C),A
            PUSH    HL
            LD      HL,04AB3H
            CALL    L19BA
            DEC     A
            CALL    L19BB
            POP     HL
            CALL    L193B
            CALL    NZ,L1CF3
            LD      (05051H),HL
            LD      HL,0505CH
L1C80:      PUSH    HL
            CALL    L1867
            POP     HL
L1C85:      JR      Z,L1C49             ; (-03eH)
            CALL    L18F2
            LD      DE,04A0EH
            LDIR    
            LD      HL,(04AB3H)
            EX      DE,HL
            LD      HL,(04A10H)
            CALL    L1773
            JR      C,L1CDF             ; (+044H)
            EX      DE,HL
            LD      HL,(04AB5H)
            CALL    L1773
            JR      C,L1CDF             ; (+03bH)
            CALL    L14F8
            LD      DE,LINEBUFR
            DB      03EH
L1CAB:      DB      000H
            OR      A
            JR      Z,L1CBA             ; (+00bH)
            CALL    L31A2
            CALL    L3246
            CALL    L31A7
            JR      L1CC7               ; (+00dH)

L1CBA:      CALL    MSGNL
            LD      A,(L1C4C)
            DEC     A
            LD      (L1C4C),A
            CALL    Z,L1CE4
L1CC7:      CALL    BRKEY
            JR      Z,L1C85             ; (-047H)
L1CCC:      CALL    GETKY
            CP      020H
            JR      Z,L1CCC             ; (-007H)
            CP      03FH
            JR      NZ,L1CDF            ; (+008H)
            LD      BC,L2000
L1CDA:      DEC     BC
            LD      A,B
            OR      C
            JR      NZ,L1CDA            ; (-005H)
L1CDF:      LD      HL,(04A0EH)
            JR      L1C80               ; (-064H)

L1CE4:      INC     A
            LD      (L1C4C),A
            PUSH    BC
            LD      BC,00001H
L1CEC:      DEC     BC
            LD      A,B
            OR      C
            JR      NZ,L1CEC            ; (-005H)
            POP     BC
            RET     

L1CF3:      CALL    L17F6
            LD      (04AB3H),DE
            CALL    L193B
            JR      Z,L1D0A             ; (+00bH)
            CALL    MATCHCHR
            DB      '-'
            CALL    L193B
            RET     Z
            CALL    L17F6
L1D0A:      LD      (04AB5H),DE
            CALL    L193B
            RET     Z
            JP      SYNTAXERR

CMDEND:     DB      0AFH
            DB      001H
L1D17:      LD      A,001H
            EX      AF,AF'
            CALL    L1AAF
            EX      AF,AF'
            OR      A
            CALL    Z,L1D24
            JR      L1D41               ; (+01dH)

L1D24:      CALL    L1C32
            LD      A,001H
            JP      L29EB

CMDSTOP:    CALL    L1AAF
            CALL    L1D24
            LD      HL,(0504FH)
            LD      DE,L1D44
            CALL    MSGX
            CALL    L1841
            CALL    MSGX
L1D41:      JP      WARMSTRT

L1D44:      DB      "*S",096H,0B7H,09EH," ",0A6H,0B0H,00DH
CMDRESTORE: CALL    L17F6
            CALL    L1C32
            LD      BC,L1B35
            PUSH    BC
            LD      A,D
            OR      E
            JP      Z,L145E
            LD      BC,L2D46
            PUSH    BC
L1D60:      EX      DE,HL
L1D61:      CALL    L18B0
            PUSH    DE
            INC     DE
            RET     Z
            JP      LINEERR

CMDLET:     PUSH    HL
L1D6B:      CALL    L193B
            JP      Z,SYNTAXERR
            CP      03DH
            INC     HL
            JR      NZ,L1D6B            ; (-00bH)
            CALL    L2293
            LD      (05051H),HL
            CALL    L1D95
            POP     HL
            CALL    L267F
            CALL    L24B2
            CALL    MATCHCHR
            DB      03DH
            CALL    L1D9A
            CALL    L1DA5
            DW      DATMISERR
            JP      L1B35

L1D95:      LD      HL,04900H
            JR      L1D9D               ; (+003H)

L1D9A:      LD      HL,04904H
L1D9D:      LD      (HL),C
            INC     HL
            LD      (HL),B
            INC     HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            RET     

L1DA5:      LD      HL,04903H
            LD      B,(HL)
            INC     HL
            LD      C,(HL)
            INC     HL
            LD      A,(HL)
            LD      DE,(04906H)
            OR      A
            JR      NZ,L1DBD            ; (+009H)
            OR      B
            JP      NZ,L177A
            CALL    L1936
            JR      L1DF2               ; (+035H)

L1DBD:      XOR     A
            OR      B
            JP      Z,L177A
            LD      HL,L1DF5
            XOR     A
            LD      B,A
            SBC     HL,DE
            JR      Z,L1DFE             ; (+033H)
            LD      HL,(04900H)
            XOR     A
            SBC     HL,BC
            LD      B,H
            LD      C,L
            JR      C,L1DDA             ; (+005H)
            CALL    L1888
            JR      L1DE2               ; (+008H)

L1DDA:      PUSH    BC
            CALL    L1762
            CALL    L1873
            POP     BC
L1DE2:      CALL    L19C3
            LD      HL,(04902H)
            EX      DE,HL
            CALL    L190E
            EX      DE,HL
            DEC     DE
            DEC     HL
            INC     BC
            LDIR    
L1DF2:      JP      L1784

L1DF5:      JR      NC,L1E27            ; (+030H)
            DEC     C
            JR      NC,L1E2A            ; (+030H)
            DEC     C
            JR      NC,L1E2D            ; (+030H)
            DEC     C
L1DFE:      LD      HL,(04902H)
            EX      DE,HL
            CALL    L190B
            EX      DE,HL
            LD      DE,L1DF5
            PUSH    DE
            LD      B,003H
L1E0C:      LD      C,002H
L1E0E:      CALL    L176A
            JR      NC,L1E5D            ; (+04aH)
            LD      (DE),A
            INC     DE
            INC     HL
            DEC     C
            JR      NZ,L1E0E            ; (-00bH)
            LD      A,00DH
            LD      (DE),A
            INC     DE
            DEC     B
            JR      NZ,L1E0C            ; (-014H)
            CALL    EXECNOTCHR
            DB      00DH
            DW      ILDATERR
            POP     HL
L1E27:      CALL    L1E69
L1E2A:      LD      B,000H
            LD      A,E
L1E2D:      CP      018H
            JR      NC,L1E5D            ; (+02cH)
            SUB     00CH
            JR      C,L1E37             ; (+002H)
            LD      E,A
            INC     B
L1E37:      LD      A,B
            PUSH    AF
            PUSH    HL
            LD      HL,00E10H
            CALL    L17CF
            POP     HL
            PUSH    DE
            INC     HL
            CALL    L1E69
            LD      A,E
            CP      03CH
            JR      NC,L1E5D            ; (+012H)
            PUSH    HL
            LD      HL,0003CH
            CALL    L17CF
            POP     HL
            EX      (SP),HL
            ADD     HL,DE
            EX      (SP),HL
            INC     HL
            CALL    L1E69
            LD      A,E
            CP      03CH
L1E5D:      JR      NC,L1E8E            ; (+02fH)
            POP     HL
            ADD     HL,DE
            EX      DE,HL
            POP     AF
            CALL    ?TMST
            JP      L1784

L1E69:      EXX     
            LD      BC,00005H
            CALL    L1E7F
            CALL    L2333
            CALL    L1926
            CALL    L1A4E
            OR      C
            INC     DE
            EXX     
            LD      BC,0FFFBH
L1E7F:      LD      HL,(04E94H)
            ADD     HL,BC
            LD      (04E94H),HL
            EXX     
            RET     

GETNUM:     CALL    L1E69
            LD      A,D
            OR      A
            RET     Z
L1E8E:      JP      ILDATERR

CMDRUN:     XOR     A
            LD      (L2A83),A
            LD      (L30E2),A
            CALL    L2E94
            CALL    L145E
            CALL    L1459
            CALL    L176A
            JR      NC,L1EAF            ; (+009H)
CMDGOTO:    CALL    L17F6
L1EA9:      EX      DE,HL
L1EAA:      CALL    L1D61
            JR      L1EC4               ; (+015H)

L1EAF:      CALL    L193B
            JP      NZ,SYNTAXERR
            CALL    L1991
            CALL    L1978
            CALL    L1996
            CALL    L199E
            LD      HL,0505CH
L1EC4:      JP      L1B4D

CMDGOSUB:   CALL    L1AAF
            CALL    L17F6
L1ECD:      CALL    L1C32
            CALL    L1D60
            EXX     
            LD      HL,05055H
            LD      A,(HL)
            CP      00FH
            JP      Z,GOSUBERR
            INC     (HL)
            DEC     HL
            DEC     HL
            LD      DE,(04E9AH)
            DEC     DE
            LD      BC,00007H
            LDDR    
            INC     DE
            LD      (04E9AH),DE
            LD      C,007H
            ADD     HL,BC
            LD      (HL),000H
            EXX     
            JP      L1B4D

CMDRETURN:  CALL    L1AAF
            LD      HL,05055H
            XOR     A
            CP      (HL)
            JP      Z,RETGOSBERR
            DEC     (HL)
L1F04:      LD      HL,05053H
            LD      A,(HL)
            OR      A
            JR      Z,L1F1A             ; (+00fH)
            DEC     (HL)
            INC     HL
            DEC     (HL)
            LD      HL,(04E98H)
            LD      BC,00013H
            ADD     HL,BC
            LD      (04E98H),HL
            JR      L1F04               ; (-016H)

L1F1A:      LD      HL,(04E9AH)
            LD      DE,0504DH
            LD      BC,00007H
            LDIR    
            LD      (04E9AH),HL
            JP      L1B35

CMDFOR:     CALL    L267F
            CALL    MATCHCHR
            DB      03DH                ; =
            PUSH    DE
            CALL    L1FB7
            POP     HL
            LD      (05040H),HL
            EX      DE,HL
            CALL    L24BD
            CALL    L1936
            CALL    L17A0
            SBC     A,(HL)
            CALL    L1FB7
            LD      DE,05048H
            CALL    L1936
            CALL    L1792
            SBC     A,A
            LD      E,H
            RRA     
            CALL    L1FB7
            LD      HL,(04E94H)
            JR      L1F5F               ; (+003H)

            LD      HL,L2A88
L1F5F:      LD      DE,05042H
            LD      A,(HL)
            LD      (05047H),A
            LD      BC,00005H
            LDIR    
            LD      HL,(04E98H)
            LD      DE,(05040H)
            LD      A,(05053H)
            INC     A
L1F76:      DEC     A
            JR      Z,L1F98             ; (+01fH)
            EX      AF,AF'
            LD      A,(HL)
            SUB     E
            LD      B,A
            INC     HL
            LD      A,(HL)
            SUB     D
            OR      B
            LD      BC,PRNT
            ADD     HL,BC
            JR      Z,L1F8A             ; (+003H)
            EX      AF,AF'
            JR      L1F76               ; (-014H)

L1F8A:      LD      (04E98H),HL
            EX      AF,AF'
            DEC     A
            LD      HL,05053H
            LD      B,(HL)
            LD      (HL),A
            SUB     B
            INC     HL
            ADD     A,(HL)
            LD      (HL),A
L1F98:      LD      HL,05054H
            LD      A,(HL)
            CP      00FH
            JP      Z,FORNEXTERR
            INC     (HL)
            DEC     HL
            INC     (HL)
            DEC     HL
            LD      DE,(04E98H)
            LD      BC,00013H
            DEC     DE
            LDDR    
            INC     DE
            EX      DE,HL
            LD      (04E98H),HL
            JP      L1B35

L1FB7:      CALL    L2333
            LD      (05051H),HL
            JP      L1926

CMDNEXT:    LD      A,(05053H)
            OR      A
L1FC4:      JP      Z,NEXTFORERR
            CALL    L2640
            LD      (05051H),HL
            LD      HL,(04E98H)
            CALL    NC,L2039
L1FD3:      LD      A,E
            SUB     (HL)
            INC     HL
            LD      B,A
            LD      A,D
            SUB     (HL)
            OR      B
            JR      Z,L1FF1             ; (+015H)
            EXX     
            LD      HL,05053H
            LD      A,(HL)
            DEC     A
            JR      Z,L1FC4             ; (-020H)
            LD      (HL),A
            INC     HL
            DEC     (HL)
            EXX     
            LD      BC,PRNT
            ADD     HL,BC
            LD      (04E98H),HL
            JR      L1FD3               ; (-01eH)

L1FF1:      INC     HL
            CALL    L24BD
            PUSH    DE
            PUSH    HL
            CALL    L3405
            POP     HL
            POP     DE
            LD      BC,00005H
            ADD     HL,BC
L2000:      LD      A,(HL)
            INC     HL
            PUSH    HL
            OR      A
            JP      P,L201B
            EX      DE,HL
            CALL    L3A66
            POP     HL
            LD      BC,00005H
            JR      C,L2025             ; (+014H)
L2011:      ADD     HL,BC
            LD      DE,0504DH
            INC     C
            LDIR    
            JP      L1B35

L201B:      CALL    L3A66
            POP     HL
            LD      BC,00005H
            CCF     
            JR      C,L2011             ; (-014H)
L2025:      LD      C,00BH
            ADD     HL,BC
            LD      (04E98H),HL
            LD      HL,05053H
            DEC     (HL)
            INC     HL
            DEC     (HL)
            CALL    L1792
            INC     L
            DEC     (HL)
            DEC     DE
            JR      CMDNEXT             ; (-079H)

L2039:      LD      E,(HL)
            INC     HL
            LD      D,(HL)
            DEC     HL
            RET     

CMDON:      CALL    L1AAF
            CALL    L2333
            CALL    L1926
            CALL    L1A4E
            DB      04CH
            DB      020H
            CALL    MATCHCHR
            DB      080H
            SUB     08DH
            CP      002H
            JP      NC,SYNTAXERR
            EX      AF,AF'
            INC     HL
            LD      A,E
            OR      A
            JR      Z,L2061             ; (+004H)
            LD      A,D
            OR      A
            JR      Z,L206F             ; (+00eH)
L2061:      JP      CMDREMDATA

L2064:      CALL    L193B
            JP      Z,L1B3B
            CP      ','
            INC     HL
            JR      NZ,L2064            ; (-00bH)
L206F:      DEC     E
            JR      NZ,L2064            ; (-00eH)
            CALL    L17F6
            CALL    L174F
            EX      AF,AF'
            OR      A
            JP      NZ,L1ECD
            JP      L1EA9

CMDDIM:     CALL    L267F
            LD      BC,MONIT
            CP      024H
            JR      NZ,L208C            ; (+002H)
            INC     HL
            INC     B
L208C:      CALL    MATCHCHR
            DB      028H
            CALL    L2107
            JR      NZ,L20E5            ; (+050H)
            PUSH    HL
            LD      HL,(L2105)
            LD      E,H
            LD      D,A
            LD      H,A
            INC     HL
            INC     DE
            CALL    L17AF
            CP      D
            INC     DE
            LD      A,(L2104)
            OR      A
            POP     HL
            PUSH    DE
            PUSH    HL
            LD      HL,00002H
            JR      NZ,L20B1            ; (+002H)
            LD      L,005H
L20B1:      CALL    L17AF
            CP      D
            INC     DE
            LD      HL,00004H
            ADD     HL,DE
            JP      C,MEMERR
            LD      B,H
            LD      C,L
            POP     DE
            CALL    L19C0
            LD      HL,(L18D8)
            EX      DE,HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            LD      DE,(02105H)
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            POP     BC
            LD      A,(L2104)
            OR      A
            JR      Z,L20F0             ; (+016H)
L20DA:      LD      (HL),000H
            INC     HL
            LD      (HL),00DH
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,L20DA            ; (-00bH)
L20E5:      LD      HL,(L2102)
            CALL    EXECNOTCHR
            DB      ','
            DW      L1B38
            JR      CMDDIM              ; (-070H)

L20F0:      EX      DE,HL
L20F1:      PUSH    BC
            LD      HL,L2A8D
            LD      BC,00005H
            LDIR    
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,L20F1            ; (-00fH)
            JR      L20E5               ; (-01dH)

L2102:      XOR     (HL)
            LD      H,C
L2104:      DB      001H
L2105:      DB      00BH
            DB      001H
L2107:      PUSH    DE
            PUSH    BC
            CALL    GETNUM
            POP     BC
            LD      A,(HL)
            CP      ','
            CALL    Z,L2185
            CALL    MATCHCHR
            DB      029H
            LD      (L2102),HL
            POP     HL
            LD      (L18D8),HL
            EX      DE,HL
            LD      (L2105),HL
            LD      A,B
            LD      (L2104),A
            LD      HL,04E86H
            LD      DE,LETNL
            OR      A
            JR      Z,L2130             ; (+001H)
            ADD     HL,DE
L2130:      LD      A,C
            LD      E,002H
            OR      A
            JR      NZ,L2137            ; (+001H)
            ADD     HL,DE
L2137:      LD      E,(HL)
            INC     HL
            LD      D,(HL)
            EX      DE,HL
L213B:      CALL    L18CE
            LD      L,(HL)
            LD      HL,L2E28
            LD      E,(HL)
            INC     HL
            PUSH    HL
            LD      L,(HL)
            LD      D,000H
            LD      H,D
            INC     HL
            INC     DE
            CALL    L17CF
            LD      A,(L2104)
            OR      A
            JR      NZ,L215F            ; (+00bH)
            LD      HL,00005H
            CALL    L17CF
            POP     HL
            ADD     HL,DE
            INC     HL
            JR      L213B               ; (-024H)

L215F:      POP     HL
            INC     HL
            LD      B,000H
L2163:      LD      C,(HL)
            INC     HL
            INC     HL
            ADD     HL,BC
            DEC     DE
            LD      A,D
            OR      E
            JR      NZ,L2163            ; (-009H)
            JR      L213B               ; (-033H)

            XOR     A
            RET     

            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            INC     HL
            LD      DE,(02105H)
            LD      A,B
            CP      D
            JR      C,L217E             ; (+002H)
            LD      A,C
            CP      E
L217E:      JP      C,ILDATERR
            LD      A,001H
            OR      A
            RET     

L2185:      INC     C
            PUSH    BC
            PUSH    DE
            INC     HL
            CALL    GETNUM
            LD      A,E
            POP     DE
            LD      D,A
            POP     BC
            RET     

CMDPOKE:    CALL    L299F
            CALL    L2E94
            PUSH    DE
            CALL    L299F
            LD      A,D
            OR      A
            JP      NZ,ILDATERR
            EX      (SP),HL
            LD      (HL),E
            POP     HL
L21A3:      JP      L1B38

CMDCLS:     PUSH    HL
            CALL    L1AF1
            POP     HL
            JR      L21A3               ; (-00aH)

CMDIF:      CALL    L1AAF
            CALL    EXECNOTCHR
            DB      0AEH
            DW      L21D3
            CALL    L2DBA
            JP      Z,SYNTAXERR
            LD      B,A
            CALL    L2712
            PUSH    HL
            LD      A,B
            CALL    L2DC1
            RST     038H
            RST     038H
            LD      BC,00008H
            ADD     HL,BC
            LD      A,(HL)
            POP     HL
            OR      A
            JR      NZ,L21E3            ; (+013H)
L21D0:      JP      L1B45

L21D3:      CALL    L2293
            CALL    L1926
            LD      IX,(04E94H)
            BIT     7,(IX+004H)
            JR      Z,L21D0             ; (-013H)
L21E3:      CALL    MATCHCHR
            ADD     A,B
            SUB     08CH
            INC     HL
            CP      002H
            JP      Z,CMDGOSUB
L21EF:      JP      NC,SYNTAXERR
            OR      A
            CALL    Z,L21F9
            JP      CMDGOTO

L21F9:      CALL    L176A
            RET     C
            POP     BC
            JP      L1B7F

CMDDEFFN:   CALL    SKIPSPACE
            SUB     041H
            CP      01AH
            JR      NC,L21EF            ; (-01bH)
            LD      E,(HL)
            INC     HL
            CALL    MATCHCHR
            DB      028H
            SUB     041H
            CP      01AH
            JR      NC,L21EF            ; (-027H)
            LD      D,(HL)
            INC     HL
            CALL    MATCHCHR
            DB      029H
            CALL    MATCHCHR
            DB      03DH
            PUSH    HL
            CALL    L174F
            POP     BC
            PUSH    HL
            XOR     A
            SBC     HL,BC
            PUSH    BC
            PUSH    HL
            LD      HL,(04E84H)
L222E:      LD      A,(HL)
            CP      E
            JR      Z,L224D             ; (+01bH)
            OR      A
            JR      Z,L223C             ; (+007H)
            INC     HL
            INC     HL
            CALL    L1745
            JR      L222E               ; (-00eH)

L223C:      EX      DE,HL
            LD      BC,GETL
            CALL    L19C0
            EX      DE,HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            LD      (HL),00DH
            EX      DE,HL
            JR      L225D               ; (+010H)

L224D:      INC     HL
            LD      (HL),D
            INC     HL
            PUSH    HL
            CALL    L174F
            POP     DE
            XOR     A
            SBC     HL,DE
            LD      B,H
            LD      C,L
            CALL    L19E7
L225D:      POP     BC
            POP     HL
            CALL    L18A2
            CALL    L19C3
            POP     HL
L2266:      JP      L1B38

CMDMUSIC:   CALL    L193B
            JR      Z,L2266             ; (-008H)
            CALL    L2333
            CALL    L193B
            JR      Z,L2277             ; (+001H)
            INC     HL
L2277:      CALL    L190B
            CALL    MELDY
            JP      C,L1438
            JR      CMDMUSIC            ; (-019H)

CMDTEMPO:   CALL    GETNUM
            LD      A,E
            DEC     A
            CP      007H
            JP      NC,ILDATERR
            INC     A
            CALL    XTEMP
            JR      L2266               ; (-02cH)

L2292:      INC     HL
L2293:      CALL    L2333
L2296:      CP      03DH
            JR      NZ,L229C            ; (+002H)
            LD      A,089H
L229C:      CP      083H
            RET     C
            CP      090H
            RET     NC
            SUB     083H
            EX      AF,AF'
            LD      A,D
            OR      A
            JR      NZ,L22B4            ; (+00bH)
            EX      AF,AF'
            EXX     
            LD      BC,L2296
            LD      DE,L2332
            JP      L23BB

L22B4:      EX      AF,AF'
            PUSH    DE
            PUSH    AF
            CALL    L2332
            POP     AF
            EX      AF,AF'
            EX      (SP),HL
            CALL    L190B
            LD      A,C
            PUSH    AF
            EX      DE,HL
            CALL    L190B
            POP     AF
            LD      B,A
            CALL    L2305
            LD      HL,L22F3
            PUSH    HL
            LD      HL,L22E1
            EX      AF,AF'
            LD      C,A
            LD      B,000H
            ADD     HL,BC
            ADD     HL,BC
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            EX      AF,AF'
            OR      A
            LD      A,001H
            JP      (HL)

L22E1:      DW      L231B
            DW      L231B
            DW      L231E
            DW      L231E
            DW      L2322
            DW      L2322
            DW      L2325
            DW      L2328
            DW      L232F
L22F3:      LD      DE,L2A92
            OR      A
            JR      NZ,L22FC            ; (+003H)
            LD      DE,L2A8D
L22FC:      CALL    L192C
            POP     HL
            CALL    L23FA
            JR      L2296               ; (-06fH)

L2305:      LD      A,B
            OR      C
            RET     Z
            LD      A,C
            CP      B
            JR      NZ,L2315            ; (+009H)
L230C:      LD      A,(DE)
            SUB     (HL)
            JR      NZ,L2315            ; (+005H)
            INC     HL
            INC     DE
            DJNZ    L230C               ; (-008H)
            RET     

L2315:      LD      A,001H
            DB      0D0H
            LD      A,080H
            RET     

L231B:      RET     NZ
            XOR     A
            RET     

L231E:      RET     Z
            RET     M
            XOR     A
            RET     

L2322:      RET     P
            XOR     A
            RET     

L2325:      RET     Z
            XOR     A
            RET     

L2328:      LD      A,000H
            RET     Z
            RET     M
            LD      A,001H
            RET     

L232F:      RET     M
            XOR     A
            RET     

L2332:      INC     HL
L2333:      LD      A,(HL)
            CP      020H
            JR      Z,L2332             ; (-006H)
            CP      '+'
            JR      Z,L2348             ; (+00cH)
            CP      '-'
            JR      NZ,L2349            ; (+009H)
            CALL    L2392
            CALL    L2410
            JR      L234C               ; (+004H)

L2348:      INC     HL
L2349:      CALL    L2393
L234C:      CP      '+'
            JR      Z,L2356             ; (+006H)
            CP      '-'
            RET     NZ
            LD      A,00DH
            DB      001H                ; Create a dummy LD BC,<val> to preserve A
L2356:      LD      A,00CH
            EX      AF,AF'
            LD      A,D
            OR      A
            JR      NZ,L2367            ; (+00aH)
            EX      AF,AF'
            EXX     
            LD      BC,L234C
            LD      DE,L2392
            JR      L23BB               ; (+054H)

L2367:      EX      AF,AF'
            CP      00CH
            JP      NZ,SYNTAXERR
            PUSH    DE
            CALL    L2392
            EX      (SP),HL
            PUSH    DE
            CALL    L190B
            LD      A,C
            PUSH    AF
            EX      DE,HL
            CALL    L190B
            POP     AF
            ADD     A,C
            JP      C,STRLENERR
            PUSH    AF
            EX      DE,HL
            CALL    L18A2
            CALL    L19C3
            POP     AF
            LD      C,A
            DEC     DE
            LD      (DE),A
            POP     DE
            POP     HL
            LD      A,(HL)
            JR      L234C               ; (-046H)

L2392:      INC     HL
L2393:      CALL    L23AC
L2396:      CP      '/'
            JR      Z,L23A0             ; (+006H)
            CP      02AH
            RET     NZ
            LD      A,00EH
            DB      001H
L23A0:      LD      A,00FH
            EXX     
            LD      BC,L2396
            LD      DE,L23AB
            JR      L23BB               ; (+010H)

L23AB:      INC     HL
L23AC:      CALL    L2402
L23AF:      CP      05EH
            RET     NZ
            LD      A,010H
            EXX     
            LD      BC,L23AF
            LD      DE,L2401
L23BB:      PUSH    BC
            LD      HL,(04E94H)
            LD      BC,00005H
            ADD     HL,BC
            LD      (04E94H),HL
            LD      HL,L2691
            LD      C,A
            ADD     HL,BC
            ADD     HL,BC
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            PUSH    BC
            LD      HL,L23DC
            PUSH    HL
            PUSH    DE
            EXX     
            LD      A,D
            OR      A
            RET     Z
L23D9:      JP      DATMISERR

L23DC:      LD      A,D
            OR      A
            JR      NZ,L23D9            ; (-007H)
            POP     IY
            PUSH    HL
            LD      HL,(04E94H)
            LD      BC,0FFFBH
            LD      E,L
            LD      D,H
            ADD     HL,BC
            LD      (04E94H),HL
            EX      DE,HL
            LD      BC,L23F9
            PUSH    BC
            JP      (IY)

L23F6:      CALL    L192C
L23F9:      POP     HL
L23FA:      LD      BC,00005H
            LD      D,B
            LD      E,B
            LD      A,(HL)
            RET     

L2401:      INC     HL
L2402:      CALL    SKIPSPACE
            CP      '+'
            JR      Z,L2425             ; (+01cH)
            CP      '-'
            JR      NZ,L2426            ; (+019H)
            CALL    L2425
L2410:      EXX     
            LD      HL,(04E94H)
            PUSH    HL
            LD      BC,00004H
            ADD     HL,BC
            LD      A,(HL)
            POP     HL
            OR      A
            JR      Z,L2422             ; (+004H)
            LD      A,(HL)
            ADD     A,080H
            LD      (HL),A
L2422:      EXX     
            LD      A,(HL)
            RET     

L2425:      INC     HL
L2426:      CALL    L2640
            JR      NC,L2447            ; (+01cH)
            LD      A,046H
            CP      E
            JR      NZ,L2436            ; (+006H)
            LD      A,04EH
            CP      D
            JP      Z,L24F0
L2436:      CALL    L24B2
            PUSH    HL
            LD      A,B
            OR      A
            JR      Z,L23F6             ; (-048H)
            EX      DE,HL
            LD      B,000H
            CALL    L1A0E
            POP     HL
            LD      A,(HL)
            RET     

L2447:      CP      080H
            JR      C,L2481             ; (+036H)
            CP      0FFH
            JR      Z,L24A8             ; (+059H)
            CP      0C0H
            JR      C,L2472             ; (+01fH)
            SUB     0C0H
            PUSH    AF
            CALL    L2332
            CALL    L1926
            CALL    MATCHCHR
            DB      029H
            POP     AF
            PUSH    HL
            LD      HL,L23F9
            PUSH    HL
            LD      HL,(04E94H)
            EX      DE,HL
            LD      HL,L26DB
            PUSH    HL
            LD      C,A
            JP      L1B95

L2472:      SUB     0A0H
            JR      C,L248F             ; (+019H)
            LD      C,A
            CALL    INCSKIPSPCE
            PUSH    HL
            LD      HL,L26B3
            JP      L1B95

L2481:      CP      028H
            JR      Z,L2492             ; (+00dH)
            CP      022H
            JP      Z,L19F3
            CALL    L1A97
            JR      Z,L249E             ; (+00fH)
L248F:      JP      SYNTAXERR

L2492:      LD      BC,MONIT
            CALL    L185F
            CALL    L2292
            JP      L2712

L249E:      LD      DE,(04E94H)
            CALL    L3670
            JP      L23FA

L24A8:      CALL    INCSKIPSPCE
            PUSH    HL
            LD      DE,L2A97
            JP      L23F6

L24B2:      LD      A,(HL)
            CP      024H
            JP      Z,L256F
            CP      028H
            JP      Z,L25FE
L24BD:      PUSH    HL
            LD      HL,(04E8AH)
            LD      BC,00005H
L24C4:      LD      A,(HL)
            CP      E
            INC     HL
            JR      NZ,L24CD            ; (+004H)
            LD      A,(HL)
            CP      D
            JR      Z,L24EB             ; (+01eH)
L24CD:      OR      A
            JR      Z,L24D4             ; (+004H)
            INC     HL
            ADD     HL,BC
            JR      L24C4               ; (-010H)

L24D4:      LD      C,007H
            DEC     HL
            PUSH    DE
            EX      DE,HL
            LD      HL,L2A8D
            DEC     HL
            DEC     HL
            CALL    L18A2
            CALL    L19C3
            EX      DE,HL
            POP     DE
            LD      (HL),E
            INC     HL
            LD      (HL),D
            LD      C,005H
L24EB:      INC     HL
            EX      DE,HL
            POP     HL
            LD      A,(HL)
            RET     

L24F0:      LD      A,(HL)
            SUB     041H
            CP      01AH
            JP      NC,SYNTAXERR
            LD      E,(HL)
            INC     HL
            CALL    MATCHCHR
            DB      028H
            PUSH    DE
            CALL    L2333
            CALL    L1926
            CALL    L2712
            POP     DE
            PUSH    HL
            LD      HL,(04E84H)
L250D:      LD      A,(HL)
            OR      A
            JP      Z,UNDEFFNERR
            CP      E
            JR      Z,L251C             ; (+007H)
            INC     HL
            INC     HL
            CALL    L1745
            JR      L250D               ; (-00fH)

L251C:      INC     HL
            LD      E,(HL)
            INC     HL
            PUSH    HL
            PUSH    DE
            LD      D,020H
            CALL    L24BD
            POP     HL
            PUSH    DE
            PUSH    HL
            LD      HL,(04E96H)
            LD      DE,04E9CH
            CALL    L1773
            JP      Z,FUNCERR
            LD      BC,0FFFAH
            ADD     HL,BC
            LD      (04E96H),HL
            POP     DE
            LD      (HL),E
            INC     HL
            POP     DE
            LD      BC,00005H
            EX      DE,HL
            CALL    L18A5
            EX      DE,HL
            LD      HL,(04E94H)
            CALL    L18A5
            POP     HL
            CALL    L2333
            CALL    L1926
            CALL    L193B
            JP      NZ,SYNTAXERR
            LD      HL,(04E96H)
            LD      E,(HL)
            INC     HL
            LD      D,020H
            CALL    L24BD
            CALL    L18A5
            ADD     HL,BC
            LD      (04E96H),HL
            JP      L23F9

L256F:      CALL    INCSKIPSPCE
            CP      028H
            JP      Z,L25F9
            PUSH    HL
            LD      HL,04954H
            XOR     A
            SBC     HL,DE
            JR      Z,L25B2             ; (+032H)
            EX      DE,HL
            LD      (L18D8),HL
            LD      HL,(04E90H)
L2587:      CALL    L18CE
            SUB     (HL)
            DEC     H
            JR      Z,L25AA             ; (+01cH)
            LD      B,000H
            LD      C,(HL)
            ADD     HL,BC
            INC     HL
            INC     HL
            JR      L2587               ; (-00fH)

            LD      BC,00004H
            EX      DE,HL
            LD      HL,L18D8
            CALL    L18A2
            CALL    L19C3
            EX      DE,HL
            ADD     HL,BC
            DEC     HL
            LD      (HL),00DH
            DEC     HL
            LD      (HL),B
L25AA:      LD      C,(HL)
            INC     HL
            LD      B,001H
            EX      DE,HL
            POP     HL
            LD      A,(HL)
            RET     

L25B2:      CALL    TIMRD
            EX      DE,HL
            OR      A
            JR      Z,L25BB             ; (+002H)
            LD      A,00CH
L25BB:      EXX     
            LD      HL,L1DF5
            PUSH    HL
            EXX     
            LD      DE,0F1F0H
            CALL    L25D9
            LD      DE,0FFC4H
            CALL    L25D8
            LD      A,L
            CALL    L25E2
            POP     DE
            LD      BC,00106H
            POP     HL
            LD      A,(HL)
            RET     

L25D8:      XOR     A
L25D9:      ADD     HL,DE
            JR      NC,L25DF            ; (+003H)
            INC     A
            JR      L25D9               ; (-006H)

L25DF:      OR      A
            SBC     HL,DE
L25E2:      LD      BC,L30F6
L25E5:      ADD     A,C
            JR      NC,L25EB            ; (+003H)
            INC     B
            JR      L25E5               ; (-006H)

L25EB:      ADD     A,03AH
            EX      AF,AF'
            LD      A,B
            EXX     
            LD      (HL),A
            INC     HL
            EX      AF,AF'
            LD      (HL),A
            INC     HL
            LD      (HL),00DH
            EXX     
            RET     

L25F9:      LD      BC,00100H
            JR      L2601               ; (+003H)

L25FE:      LD      BC,MONIT
L2601:      INC     HL
            CALL    L2107
            JP      Z,ILDATERR
            PUSH    HL
            LD      L,C
            LD      H,000H
            LD      C,E
            LD      E,D
            LD      B,H
            LD      D,H
            PUSH    BC
            INC     HL
            CALL    L17CF
            POP     HL
            ADD     HL,DE
            EX      DE,HL
            LD      A,(L2104)
            OR      A
            JR      NZ,L262B            ; (+00dH)
            LD      HL,00005H
            CALL    L17CF
            POP     HL
            ADD     HL,DE
            LD      BC,00005H
            JR      L263A               ; (+00fH)

L262B:      POP     HL
            LD      B,000H
L262E:      LD      C,(HL)
            INC     HL
            LD      A,D
            OR      E
            JR      Z,L2639             ; (+005H)
            ADD     HL,BC
            INC     HL
            DEC     DE
            JR      L262E               ; (-00bH)

L2639:      INC     B
L263A:      EX      DE,HL
            LD      HL,(L2102)
            LD      A,(HL)
            RET     

L2640:      CALL    SKIPSPACE
            LD      BC,L411A
            SUB     B
            CP      C
            LD      A,(HL)
            RET     NC
            LD      E,A
            LD      D,020H
L264D:      INC     HL
            LD      A,(HL)
            CP      D
            JR      Z,L264D             ; (-005H)
            SUB     B
            CP      C
            JR      C,L265A             ; (+004H)
            SUB     0EFH
            CP      00AH
L265A:      LD      A,(HL)
            CCF     
            RET     C
            LD      D,A
            CP      04EH
            JR      NZ,L2667            ; (+005H)
            LD      A,046H
            CP      E
            JR      Z,L267A             ; (+013H)
L2667:      INC     HL
            LD      A,(HL)
            CP      020H
            JR      Z,L2667             ; (-006H)
            SUB     B
            CP      C
            JR      C,L2667             ; (-00aH)
            SUB     0EFH
            CP      00AH
            JR      C,L2667             ; (-010H)
L2677:      LD      A,(HL)
            SCF     
            RET     

L267A:      CALL    INCSKIPSPCE
            SCF     
            RET     

L267F:      CALL    L2640
            JR      NC,L268E            ; (+00aH)
            LD      A,046H
            CP      E
            JR      NZ,L268C            ; (+003H)
            LD      A,04EH
            CP      D
L268C:      JR      NZ,L2677            ; (-017H)
L268E:      JP      SYNTAXERR

L2691:      DW      L3B62
            DW      L3B62
            DW      L3B87
            DW      L3B87
            DW      L3B8B
            DW      L3B8B
            DW      L3B7F
            DW      L3B73
            DW      L3B77
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      L3405
            DW      L3403
            DW      L3500
            DW      L35D0
            DW      L4159
L26B3:      DW      L26F3
            DW      L270F
            DW      L273E
            DW      L2765
            DW      L2772
            DW      L277F
            DW      L27B4
            DW      L279A
            DW      L27F9
            DW      L2801
            DW      L2804
            DW      L2895
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      SYNTAXERR
            DW      L2824
            DW      SYNTAXERR
            DW      L2841
            DW      L287C
            DW      SYNTAXERR
L26DB:      DW      L3B98
            DW      L3C16
            DW      L3D05
            DW      L3D14
            DW      L4076
            DW      L3E03
            DW      L3A86
            DW      L4064
            DW      L3F35
            DW      L289D
            DW      L28A2
            DW      L3D3F
L26F3:      DB      0CDH
            DB      033H
            DB      023H
            DB      0CDH
            DB      094H
            DB      02EH
L26F9:      PUSH    DE
            CALL    GETNUM
            CALL    L2712
            EX      (SP),HL
            PUSH    HL
            EX      DE,HL
            CALL    L190B
            LD      A,C
            SUB     L
            JR      C,L273A             ; (+030H)
            PUSH    HL
            LD      C,A
            ADD     HL,DE
            JR      L2732               ; (+023H)

L270F:      DB      0CDH
L2710:      DB      017H
            DB      027H
L2712:      CALL    MATCHCHR
            DB      029H
            RET     

            CALL    L2333
            CALL    L2E94
            PUSH    DE
            CALL    GETNUM
            JR      L2724               ; (+001H)

L2723:      PUSH    BC
L2724:      EX      (SP),HL
            PUSH    HL
            EX      DE,HL
            CALL    L190B
            LD      A,C
            SUB     L
            JR      C,L273A             ; (+00cH)
            PUSH    HL
            LD      C,A
            LD      L,E
            LD      H,D
L2732:      EX      DE,HL
            CALL    L19E7
            POP     BC
            DEC     HL
            LD      (HL),C
            INC     HL
L273A:      POP     DE
            POP     HL
            LD      A,(HL)
            RET     

L273E:      CALL    L2333
            CALL    L2E94
            PUSH    DE
            PUSH    BC
            CALL    GETNUM
            POP     BC
            LD      A,E
            OR      A
            JP      Z,ILDATERR
            LD      A,C
            SUB     E
            JR      NC,L2755            ; (+002H)
            LD      A,PRTD
L2755:      INC     A
            LD      E,A
            POP     BC
            CALL    L2723
            CALL    L2E94
            CP      '-'
            JR      NZ,L26F9            ; (-069H)
            INC     HL
            JR      L2712               ; (-053H)

L2765:      CALL    L2333
            CALL    L190B
            CALL    L2712
            PUSH    HL
            LD      A,C
            JR      L27C4               ; (+052H)

L2772:      CALL    L299F
            CALL    L2712
            LD      A,E
            LD      BC,00001H
            JP      L280F

L277F:      CALL    L2333
            CALL    L1926
            CALL    L2712
            PUSH    HL
            LD      HL,(04E94H)
            LD      DE,04AB3H
            PUSH    DE
            CALL    L38BB
            POP     HL
            CALL    L19F3
            POP     HL
            LD      A,(HL)
            RET     

L279A:      CALL    L2333
            CALL    L190B
            CALL    L2712
            PUSH    HL
            EX      DE,HL
            JR      L27AA               ; (+003H)

            LD      HL,L27B2
L27AA:      CALL    L1A75
            AND     A
            DAA     
            POP     HL
            LD      A,(HL)
            RET     

L27B2:      DB      030H
            DB      00DH
L27B4:      CALL    L2333
            CALL    L190B
            CALL    L2712
            LD      A,C
            OR      A
            JP      Z,ILDATERR
L27C2:      LD      A,(DE)
            PUSH    HL
L27C4:      LD      E,A
            LD      D,000H
L27C7:      CALL    L27CD
            POP     HL
            LD      A,(HL)
            RET     

L27CD:      LD      B,080H
            LD      A,D
            OR      E
            JR      Z,L27E7             ; (+014H)
            LD      B,0D0H
            LD      A,D
            OR      A
            JR      NZ,L27DE            ; (+005H)
            LD      B,0C8H
            LD      D,E
            LD      E,000H
L27DE:      EX      DE,HL
L27DF:      BIT     7,H
            JR      NZ,L27E6            ; (+003H)
            ADD     HL,HL
            DJNZ    L27DF               ; (-007H)
L27E6:      EX      DE,HL
L27E7:      LD      HL,(04E94H)
            LD      (HL),B
            INC     HL
            CALL    L19BA
            LD      (HL),E
            INC     HL
            LD      (HL),D
            LD      BC,00005H
            LD      DE,MONIT
            RET     

L27F9:      CALL    L299F
            CALL    L2712
            JR      L27C2               ; (-03fH)

L2801:      JP      SYNTAXERR

L2804:      CALL    GETNUM
            CALL    L2712
            LD      A,020H
            LD      C,E
            LD      B,000H
L280F:      PUSH    HL
            PUSH    AF
            CALL    L1A1E
            POP     AF
            PUSH    DE
            PUSH    BC
            LD      B,C
            INC     B
            JR      L281D               ; (+002H)

L281B:      LD      (HL),A
            INC     HL
L281D:      DJNZ    L281B               ; (-004H)
            POP     BC
            POP     DE
            POP     HL
            LD      A,(HL)
            RET     

L2824:      CALL    L2333
            CALL    L2E94
            PUSH    DE
            CALL    GETNUM
            CALL    L2712
            EX      (SP),HL
            PUSH    DE
            EX      DE,HL
            CALL    L190B
            LD      A,C
            OR      A
            JP      Z,ILDATERR
            LD      A,(DE)
            POP     BC
            POP     HL
            JR      L280F               ; (-032H)

L2841:      CALL    L1E69
            LD      A,E
            CP      028H
L2847:      JP      NC,ILDATERR
            PUSH    AF
            CALL    MATCHCHR
            DB      ','
            CALL    GETNUM
            CALL    MATCHCHR
            DB      029H
            LD      A,E
            CP      019H
            JR      NC,L2847            ; (-014H)
            POP     AF
            LD      C,A
            LD      B,E
            INC     B
            PUSH    HL
            LD      HL,(PAGETP)
            LD      D,000H
            LD      E,028H
            XOR     A
            SBC     HL,DE
L286A:      ADD     HL,DE
            DJNZ    L286A               ; (-003H)
            ADD     HL,BC
            CALL    L2878
            POP     HL
            LD      BC,00001H
            JP      L280F

L2878:      LD      A,(HL)
            JP      ?DACN

L287C:      CALL    EXECNOTCHR
            DB      056H
            DW      L288C
            LD      A,(01172H)
L2885:      LD      D,000H
            LD      E,A
            PUSH    HL
            JP      L27C7

L288C:      CALL    MATCHCHR
            DB      048H
            LD      A,(DSPXY)
            JR      L2885               ; (-010H)

L2895:      PUSH    HL
            CALL    L184A
            EX      DE,HL
            JP      L27C7

L289D:      LD      A,(DE)
            OR      080H
            LD      (DE),A
            RET     

L28A2:      LD      A,(DE)
            LD      DE,L192C
            PUSH    DE
            LD      DE,L2A92
            OR      A
            RET     P
            LD      DE,L2A88
            CP      080H
            RET     NZ
            LD      DE,L2A8D
            RET     

CMDMON:     JP      MONIT

CMDCURSOR:  CALL    GETNUM
            LD      A,E
            CP      028H
L28BF:      JP      NC,ILDATERR
            PUSH    AF
            CALL    MATCHCHR
            DB      ','
            CALL    GETNUM
            LD      A,E
            CP      019H
            JR      NC,L28BF            ; (-010H)
            PUSH    HL
            LD      HL,(DSPXY)
            LD      A,E
            SUB     H
            LD      H,A
            LD      A,(MGPNT)
            JP      M,L28F8
            ADD     A,H
            SUB     032H
            JR      NC,L28E3            ; (+002H)
            ADD     A,032H
L28E3:      LD      (MGPNT),A
            EX      DE,HL
            LD      H,L
            POP     DE
            POP     AF
            LD      L,A
            LD      (DSPXY),HL
            NOP     
            NOP     
            NOP     
            LD      (DPRNT),A
            EX      DE,HL
            JP      L1B38

L28F8:      ADD     A,H
            JP      P,L28E3
            ADD     A,032H
            JR      L28E3               ; (-01dH)

            NOP     
            NOP     
CMDGET:     CALL    L267F
            CALL    L24B2
            LD      (05051H),HL
            CALL    L1D9A
            CALL    GETKY
            PUSH    AF
            LD      A,(04905H)
            OR      A
            JR      Z,L292D             ; (+015H)
            POP     AF
            LD      BC,MONIT
            OR      A
            JR      Z,L2920             ; (+001H)
            INC     BC
L2920:      CALL    L280F
L2923:      CALL    L1D95
            CALL    L1DA5
            DW      DATMISERR
            JR      L2998               ; (+06bH)

L292D:      POP     AF
            LD      DE,MONIT
            CALL    L2939
L2934:      CALL    L27CD
            JR      L2923               ; (-016H)

L2939:      OR      A
            RET     Z
            SUB     030H
            CP      00AH
            RET     NC
            LD      E,A
            RET     

CMDUSRN:    CALL    L299F
            PUSH    DE
            CALL    EXECNOTCHR
            DB      ','
            DW      L2959
            CALL    L267F
            CALL    L24B2
            LD      A,B
            OR      A
            JP      Z,DATMISERR
            LD      B,000H
L2959:      CALL    L2712
            LD      (05051H),HL
            CALL    L13FA
            LD      HL,L1B35
            EX      (SP),HL
            JP      (HL)

CMDLIMIT:   LD      DE,L299B
            CALL    L14C7
            JR      NZ,L2977            ; (+008H)
            LD      (05051H),HL
            LD      HL,(04908H)
            JR      L2994               ; (+01dH)

L2977:      CALL    L299F
            LD      (05051H),HL
            LD      HL,(04908H)
            CALL    L1773
            JP      C,ILDATERR
            LD      HL,(04E94H)
            LD      BC,000C8H
            ADD     HL,BC
            CALL    L1773
            JP      NC,BADWRERR
            EX      DE,HL
L2994:      LD      (0490AH),HL
            LD      SP,HL
L2998:      JP      L1B35

L299B:      LD      C,L
            LD      B,C
            RET     C
            NOP     
L299F:      CALL    EXECNOTCHR
            DB      024H
            DW      L29CB
            LD      DE,MONIT
L29A8:      CALL    L176A
            JR      NC,L29C2            ; (+015H)
L29AD:      AND     00FH
            LD      C,A
            LD      B,000H
            LD      A,D
            AND     0F0H
            JP      NZ,ILDATERR
            EX      DE,HL
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,BC
            EX      DE,HL
            INC     HL
            JR      L29A8               ; (-01aH)

L29C2:      SUB     041H
            CP      006H
            RET     NC
            ADD     A,00AH
            JR      L29AD               ; (-01eH)

L29CB:      JP      L1E69

CMDCONT:    CALL    L1AA7
            LD      A,(L1463)
            OR      A
            JP      Z,CONTERR
            PUSH    AF
            XOR     A
            CALL    L29EB
            POP     AF
            LD      HL,(05051H)
            OR      A
            JP      M,L2C56
            DEC     A
            JR      Z,L2998             ; (-050H)
            JP      L1B5F

L29EB:      LD      (L1463),A
            LD      DE,L1464
            LD      BC,LETNL
            LD      HL,0504DH
            OR      A
            JR      NZ,L29FB            ; (+001H)
            EX      DE,HL
L29FB:      LDIR    
            RET     

CMDINP:     CALL    GETNUM
            CALL    L2E94
            LD      A,E
            LD      (L2A15),A
            CALL    L267F
            CALL    L24B2
            LD      (05051H),HL
            CALL    L1D9A
            DB      0DBH
L2A15:      DB      0FFH
            LD      E,A
            LD      D,000H
            JP      L2934

CMDOUT:     CALL    GETNUM
            CALL    L2E94
            LD      A,E
            LD      (L2A2B),A
            CALL    GETNUM
            LD      A,E
            DB      0D3H
L2A2B:      DB      0FFH
L2A2C:      JP      L1B38

CMDAUTO:    CALL    L1AA7
            CALL    L193B
            JR      Z,L2A5F             ; (+028H)
            CALL    EXECNOTCHR
            DB      ','
            DW      L2A3F
            JR      L2A71               ; (+032H)

L2A3F:      CALL    L2A7A
            LD      (02A84H),DE
            CALL    L193B
            JR      Z,L2A6C             ; (+021H)
            CALL    EXECNOTCHR
            DB      ','
            DW      SYNTAXERR
L2A51:      CALL    L2A7A
            LD      (02A86H),DE
L2A58:      LD      A,001H
            LD      (L2A83),A
            JR      L2A2C               ; (-033H)

L2A5F:      LD      DE,0000AH
            LD      (02A84H),DE
L2A66:      LD      (02A86H),DE
            JR      L2A58               ; (-014H)

L2A6C:      LD      DE,0000AH
            JR      L2A66               ; (-00bH)

L2A71:      LD      DE,0000AH
            LD      (02A84H),DE
            JR      L2A51               ; (-029H)

L2A7A:      CALL    L1E69
            LD      A,D
            OR      E
            RET     NZ
            JP      SYNTAXERR

L2A83:      DB      000H
L2A84:      DB      00AH
            DB      000H
            DB      00AH
            DB      000H
L2A88:      DB      0C1H
            DB      000H
            DB      000H
            DB      000H
            DB      080H
L2A8D:      DB      080H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
L2A92:      DB      041H
            DB      000H
            DB      000H
            DB      000H
            DB      080H
L2A97:      DB      0C2H
            DB      0A1H
            DB      0DAH
            DB      00FH
            DB      0C9H
            AND     00FH
            ADD     A,030H
            CP      ':'
            RET     C
            ADD     A,007H
            RET     

CMDSET:     LD      A,001H
            JR      L2AAB               ; (+001H)

CMDRESET:   XOR     A
L2AAB:      PUSH    AF
            CALL    GETNUM
            PUSH    DE
            CALL    MATCHCHR
            DB      ','
            CALL    GETNUM
            LD      (05051H),HL
            LD      A,E
L2ABB:      SUB     032H
            JR      NC,L2ABB            ; (-004H)
            ADD     A,032H
            LD      E,A
            POP     BC
            LD      A,C
L2AC4:      SUB     050H
            JR      NC,L2AC4            ; (-004H)
            ADD     A,050H
            LD      C,A
            XOR     A
            SRL     C
            JR      NC,L2ADE            ; (+00eH)
            SRL     E
            JR      NC,L2AD8            ; (+004H)
            ADD     A,004H
L2AD6:      ADD     A,002H
L2AD8:      ADD     A,001H
L2ADA:      ADD     A,001H
            JR      L2AE4               ; (+006H)

L2ADE:      SRL     E
            JR      NC,L2ADA            ; (-008H)
            JR      L2AD6               ; (-00eH)

L2AE4:      PUSH    AF
            LD      HL,(PAGETP)
            LD      A,028H
L2AEA:      ADD     HL,DE
            DEC     A
            JR      NZ,L2AEA            ; (-004H)
            ADD     HL,BC
            RES     3,H
            LD      A,(HL)
            CP      0F0H
            JR      NC,L2AF8            ; (+002H)
            LD      A,0F0H
L2AF8:      POP     BC
            LD      C,A
            POP     AF
            OR      A
            LD      A,B
            JR      Z,L2B02             ; (+003H)
            OR      C
            JR      L2B04               ; (+002H)

L2B02:      CPL     
            AND     C
L2B04:      CP      0F0H
            JR      NZ,L2B09            ; (+001H)
            XOR     A
L2B09:      LD      (HL),A
            JP      L1B35

CMDPRINT:   CALL    EXECNOTCHR          ; Check to see if a stream, ie. /T = Tape is given. The 02FH below is / and the function after is called if it doesnt match /.
            DB      '/'                ; Execute below function IFF first non-space character after PRINT command is not a /
            DW      L2B18
            CALL    L2E9B
            JR      L2B1E               ; (+006H)

L2B18:      CALL    L2DBA
            CALL    L2E94
L2B1E:      CALL    L193B
            JR      NZ,L2B2F            ; (+00cH)
            LD      (05051H),HL
L2B26:      LD      HL,L2BEF
            CALL    L2BE3
            JP      L1B35

L2B2F:      CALL    EXECNOTCHR
            DB      03BH
            DW      L2B35
L2B35:      LD      BC,L2B4D
            PUSH    BC
            CP      ','
            RET     NZ
            INC     HL
            LD      A,(04DD4H)
            OR      A
            RET     P
            AND     07FH
            JP      Z,PRNTT
            CP      002H
            RET     NZ
            JP      L326E

L2B4D:      CALL    L193B
            LD      (05051H),HL
            JP      NZ,L2B60
            LD      A,(04DD4H)
            OR      A
            JP      M,L1B35
            JP      L2B26

L2B60:      CP      03BH
            JR      Z,L2B66             ; (+002H)
            CP      ','
L2B66:      JP      Z,L2B2F
            CALL    EXECNOTCHR
            DB      0A9H
            DW      L2B9A
            CALL    GETNUM
            CALL    MATCHCHR
            DB      029H
            LD      D,013H
            LD      A,(DPRNT)
            LD      B,A
            LD      A,(04DD4H)
            CP      080H
            JR      Z,L2B8D             ; (+00aH)
            LD      D,020H
            CP      082H
            JR      NZ,L2BBD            ; (+034H)
            LD      A,(L32D3)
            LD      B,A
L2B8D:      LD      A,E
            SUB     B
            JR      C,L2B2F             ; (-062H)
            LD      C,A
            LD      B,000H
            LD      A,D
            CALL    L280F
            JR      L2B9D               ; (+003H)

L2B9A:      CALL    L2293
L2B9D:      PUSH    HL
            LD      HL,LINEBUFR
            LD      A,D
            OR      A
            CALL    Z,L2BC0
            CALL    NZ,L2BD0
            LD      HL,L2BF7
            CALL    L2BE3
            LD      HL,L2B1E
            EX      (SP),HL
            CALL    L193B
            RET     Z
            CP      03BH
            RET     Z
            CP      ','
            RET     Z
L2BBD:      JP      SYNTAXERR

L2BC0:      PUSH    AF
            PUSH    HL
            EX      DE,HL
            LD      HL,(04E94H)
            CALL    L38BB
            POP     HL
            CALL    L18FD
            JP      L2BD9

L2BD0:      PUSH    AF
            CALL    L190B
            EX      DE,HL
            CALL    L18A5
            EX      DE,HL
L2BD9:      DEC     HL
            LD      (HL),C
            INC     HL
            PUSH    HL
            ADD     HL,BC
            LD      (HL),00DH
            POP     DE
            POP     AF
L2BE2:      RET     

L2BE3:      LD      A,(04DD4H)
            ADD     A,080H
            CALL    L13FA
            CALL    L2E12
            JP      (HL)

L2BEF:      LD      B,000H
            XOR     E
            INC     DE
            AND     A
            LD      SP,L2BE2
L2BF7:      DEC     D
            NOP     
            XOR     E
            INC     DE
            OR      H
            LD      SP,L3064
CMDINPUT:   CALL    L1AAF
            CALL    EXECNOTCHR
            DB      '/'
            DW      L2C0E
            CALL    L2E9B
            JP      L2C62

L2C0E:      CALL    L2DBA
            CALL    SKIPSPACE
            CP      022H
            LD      DE,L2C5F
            JR      NZ,L2C25            ; (+00aH)
            CALL    L2333
            CALL    MATCHCHR
            DB      03BH
            CALL    L190B
L2C25:      LD      (05051H),HL
L2C28:      CALL    MSG
            LD      A,(DPRNT)
            LD      B,A
            LD      L,A
            LD      H,000H
            LD      DE,LINEBUFR
            ADD     HL,DE
            LD      (L2C8C),HL
            CALL    GETL
            EX      DE,HL
            LD      A,(HL)
            CP      01BH
            JR      NZ,L2C4A            ; (+008H)
            LD      A,080H
            CALL    L29EB
            JP      L1438

L2C4A:      INC     B
            LD      A,00DH
L2C4D:      CP      (HL)
            JR      Z,L2C56             ; (+006H)
            INC     HL
            DJNZ    L2C4D               ; (-006H)
            JP      L2C8E

L2C56:      CALL    NL
            LD      DE,L2C5F
            JP      L2C28

L2C5F:      CCF     
            JR      NZ,L2C6F            ; (+00dH)
L2C62:      CALL    L2E94
            LD      (05051H),HL
L2C68:      LD      DE,LINEBUFR
            PUSH    DE
            LD      HL,L2C84
L2C6F:      CALL    L2BE3
            POP     HL
            DEC     HL
            LD      (HL),C
            INC     HL
            LD      A,B
            OR      A
            JP      NZ,STRLENERR
            CALL    L1A0E
            LD      HL,L2C68
            JP      L2CC8

L2C84:      XOR     E
            INC     DE
            XOR     E
            INC     DE
            XOR     E
            INC     DE
            ADC     A,A
            DB      030H
L2C8C:      DB      00FH
            DB      049H
L2C8E:      LD      A,(04DD4H)
            CP      081H
            JP      Z,L2D1D
            LD      HL,(L2C8C)
            CALL    L18FD
            LD      DE,LINEBUFR
            PUSH    DE
            INC     BC
            LDIR    
            POP     HL
            LD      (L2C8C),HL
            CALL    SKIPSPACE
            CP      00DH
            JP      Z,L2C56
            CALL    EXECNOTCHR
            DB      ','
            DW      L2CBF
            PUSH    HL
            LD      DE,L2D11
            CALL    L19F3
            POP     HL
            JR      L2CC2               ; (+003H)

L2CBF:      CALL    L19F3
L2CC2:      LD      (L2C8C),HL
            LD      HL,L2C8E
L2CC8:      PUSH    HL
            CALL    L1D95
            LD      HL,(05051H)
            CALL    L267F
            CALL    L24B2
            LD      (05051H),HL
            CALL    L1D9A
L2CDB:      CALL    L1DA5
            DW      L2CF4
            LD      HL,(05051H)
            CALL    L193B
            JR      NZ,L2CEC            ; (+004H)
            POP     AF
            JP      L1B35

L2CEC:      CALL    MATCHCHR
            DB      ','
            LD      (05051H),HL
            RET     

L2CF4:      LD      DE,(04902H)
            CALL    L190B
            EX      DE,HL
            CALL    EXECNOTCHR
            DB      00DH
            DW      L2D05
            LD      HL,L2D10
L2D05:      CALL    L1A75
            OR      H
            INC     DE
            CALL    L1D95
            JP      L2CDB

L2D10:      DB      030H
L2D11:      DB      00DH
CMDREAD:    LD      (05051H),HL
            LD      A,081H
            LD      (04DD4H),A
            CALL    L1AAF
L2D1D:      LD      A,(05059H)
            OR      A
            CALL    Z,L2D43
            LD      HL,(0505AH)
            CALL    L193B
            JR      NZ,L2D32            ; (+006H)
            CALL    L2D6B
            JP      L2D1D

L2D32:      CALL    L19F3
            CALL    L2E94
            LD      (0505AH),HL
            LD      HL,LINEBUFR
            LD      (HL),00DH
            JP      L2CC2

L2D43:      LD      HL,0505CH
L2D46:      XOR     A
            LD      (05059H),A
L2D4A:      LD      A,(HL)
            INC     HL
            OR      (HL)
            INC     HL
            JP      Z,READDATAERR
            INC     HL
            INC     HL
L2D53:      CALL    EXECNOTCHR
            DB      080H
            DW      L2D68
            CALL    EXECNOTCHR
            DB      081H
            DW      L2D68
            LD      (0505AH),HL
            LD      A,001H
            LD      (05059H),A
            RET     

L2D68:      CALL    L174F
L2D6B:      INC     HL
            CP      ':'
            JP      Z,L2D53
            JP      L2D4A

L2D74:      DB      001H
CMDLOAD:    CALL    EXECNOTCHR
            DB      '/'
            DW      L2EDA
            CALL    MATCHCHR
            DB      'T'
            JP      L2EDA

CMDSAVE:    CALL    L1AA7
            CALL    EXECNOTCHR
            DB      '/'
            DW      L2FE0
            CALL    MATCHCHR
            DB      'T'
            JP      L2FE0

CMDROPEN:   CALL    EXECNOTCHR
            DB      '/'
            DW      L311E
            CALL    MATCHCHR
            DB      'T'
            JP      L311E

CMDWOPEN:   CALL    EXECNOTCHR
            DB      '/'
            DW      L30E5
            CALL    MATCHCHR
            DB      'T'
            JP      L30E5

            NOP     
CMDCLOSE:   CALL    EXECNOTCHR
            DB      '/'
            DW      L3171
            CALL    MATCHCHR
            DB      'T'
            JP      L3171

L2DBA:      LD      A,080H
            LD      (04DD4H),A
            OR      A
            RET     

L2DC1:      LD      HL,04DF2H
            LD      DE,NL
            LD      B,00AH
L2DC9:      CP      (HL)
            JR      Z,L2DD2             ; (+006H)
            ADD     HL,DE
            DJNZ    L2DC9               ; (-006H)
            JP      L177A

L2DD2:      LD      A,00AH
            SUB     B
            JP      L1784

L2DD8:      LD      A,B
            OR      C
            JR      Z,L2DDE             ; (+002H)
            INC     BC
            INC     BC
L2DDE:      LD      E,(HL)
            INC     HL
            LD      D,(HL)
            DEC     HL
            PUSH    HL
            LD      H,B
            LD      L,C
            CALL    L1773
            POP     HL
            JR      Z,L2DF7             ; (+00cH)
            EX      DE,HL
            PUSH    BC
            LD      C,L
            LD      B,H
            CALL    L19E7
            POP     BC
            CALL    L19C0
            EX      DE,HL
L2DF7:      LD      D,H
            LD      E,L
            LD      A,C
            OR      B
            RET     Z
            LD      (HL),C
            INC     HL
            LD      (HL),B
            DEC     HL
            DEC     BC
            DEC     BC
            RET     

            CALL    L2DD8
            INC     HL
            INC     HL
            RET     

L2E09:      PUSH    BC
            LD      BC,MONIT
            CALL    L2DD8
            POP     BC
            RET     

L2E12:      ADD     A,A
            ADD     A,L
            LD      L,A
            JR      NC,L2E18            ; (+001H)
            INC     H
L2E18:      LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            RET     

L2E1D:      LD      DE,CMTFNAME         ; Compare loaded filename against name given by user.
            PUSH    HL
            INC     HL
            LD      B,010H
L2E24:      LD      A,(DE)
            CP      (HL)
            JR      NZ,L2E31            ; (+009H)
L2E28:      INC     HL
            INC     DE
            CP      00DH
            JR      Z,L2E31             ; (+003H)
            DEC     B
            JR      NZ,L2E24            ; (-00dH)
L2E31:      POP     HL
            RET     

CMTBUF:     DB      002H
CMTFNAME:   DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            PUSH    HL
            LD      HL,GETL
            LD      (04DD6H),HL
            LD      HL,04DD8H
            LD      B,005H
L2E5F:      LD      (HL),000H
            INC     HL
            DJNZ    L2E5F               ; (-005H)
            LD      HL,CMTFNAME
            LD      B,011H
L2E69:      LD      (HL),00DH
            INC     HL
            DJNZ    L2E69               ; (-005H)
            LD      B,00EH
L2E70:      LD      (HL),000H
            INC     HL
            DJNZ    L2E70               ; (-005H)
            POP     HL
            CALL    L2E94
            CALL    L2333
            LD      A,D
            OR      A
            JP      Z,UNKNWNERR
            LD      A,C
            DEC     A
            CP      010H
            JP      NC,UNKNWNERR
            PUSH    HL
            CALL    L190B
            LD      HL,CMTFNAME
            EX      DE,HL
            LDIR    
            POP     HL
            RET     

L2E94:      CALL    EXECNOTCHR
            DB      ','
            DW      L2E9A
L2E9A:      RET     

L2E9B:      LD      B,000H
            LD      DE,L2EB0
            CALL    L14C9
            JP      NZ,SYNTAXERR
            CALL    L2E94
            LD      A,B
            ADD     A,082H
            LD      (04DD4H),A
            RET     

L2EB0:      DB      0D0H
            DB      0D4H
            DB      000H
CMDVERIFY:  CALL    L1AA7
            XOR     A
            JR      L2EDC               ; (+023H)

L2EB9:      LD      A,(ATRB)
            CP      002H
            JR      NZ,L2EE6            ; (+026H)
            CALL    L2F62
            CALL    L1B1B
            CALL    ?VRFY
            PUSH    AF
            CALL    L1AC7
            POP     AF
            JP      C,L30B3
            LD      DE,L2FDD
            CALL    MSGNL
            JP      L1B35

L2EDA:      LD      A,001H
L2EDC:      LD      (L2D74),A
            LD      BC,L2EE6
            PUSH    BC
            JP      L2FE4

L2EE6:      CALL    QRDI                ; Original ?RDI call
            JP      C,L30B3
            CALL    L2F67
            LD      HL,ATRB
            LD      A,(HL)
            OR      A
            JR      Z,L2EE6             ; (-010H)
            CP      004H
            JR      NC,L2EE6            ; (-014H)
            LD      DE,CMTFNAME
            LD      A,(DE)
            CP      00DH
            JR      Z,L2F07             ; (+005H)
            CALL    L2E1D
            JR      NZ,L2EE6            ; (-021H)
L2F07:      LD      A,(L2D74)
            OR      A
            JR      Z,L2EB9             ; (-054H)
            LD      A,(ATRB)
            CP      001H
            JP      Z,L2F8E
            CP      002H
            JR      NZ,L2EE6            ; (-033H)
            CALL    L1944
            LD      HL,(SIZE)
            DEC     HL
            DEC     HL
            LD      C,L
            LD      B,H
            LD      DE,0505CH
            CALL    L1888
            CALL    L19C3
            LD      (DTADR),DE
            CALL    L2F6C
            CALL    QRDD                ; Original ?RDD call
            JR      C,L2F3E             ; (+006H)
            CALL    L1ABF
            JP      L1B35

L2F3E:      PUSH    AF
            CALL    L2F4B
            POP     AF
            PUSH    AF
            CALL    L1944
            POP     AF
            JP      L30B3

L2F4B:      LD      DE,0505EH
            LD      HL,04E4EH
            XOR     A
            SBC     HL,DE
            RET     Z
            LD      C,L
            LD      B,H
            DEC     DE
            DEC     DE
            CALL    L1873
            CALL    L1762
            JP      L19C3

L2F62:      LD      DE,L2FD2
            JR      L2F6F               ; (+008H)

L2F67:      LD      DE,L2FC2
            JR      L2F6F               ; (+003H)

L2F6C:      LD      DE,L2FC9
L2F6F:      CALL    MSGNL
            LD      DE,NAME
            LD      A,(DE)
            CP      00DH
            RET     Z
            PUSH    DE
            CALL    L2F86
            POP     DE
            LD      A,00DH
            LD      (01101H),A
            CALL    MSGX
L2F86:      LD      DE,L2F8C
            JP      MSGX

L2F8C:      DB      022H
            DB      00DH
L2F8E:      LD      HL,(DTADR)
            EX      DE,HL
            LD      HL,(0490AH)
            DEC     HL
            CALL    L1773
            JR      NC,L2FB6            ; (+01bH)
            LD      HL,(SIZE)
            ADD     HL,DE
            JR      C,L2FBC             ; (+01bH)
            EX      DE,HL
            LD      HL,(04908H)
            CALL    L1773
            JR      C,L2FBC             ; (+012H)
            CALL    L2F6C
            CALL    QRDD                ; Original ?RDD call
            JP      C,L30B3
            JP      L1B35

L2FB6:      CALL    MSTOP
            JP      BADWRERR

L2FBC:      CALL    MSTOP
            JP      MEMERR

L2FC2:      DB      "F",0B7H,0A5H,0B0H,09CH," "
            DB      00DH
L2FC9:      DB      "L",0B7H,0A1H,09CH,0A6H,0B0H,097H," "
            DB      00DH
L2FD2:      DB      "V",092H,09DH,0A6H,0AAH,0BDH,0A6H,0B0H,097H," "
            DB      00DH
L2FDD:      DB      "OK"
            DB      00DH
L2FE0:      LD      BC,L3038
            PUSH    BC
L2FE4:      CALL    EXECNOTCHR
            DB      ','
            DW      L2FEA
L2FEA:      PUSH    HL
            LD      HL,CMTBUF
            LD      (HL),002H
L2FF0:      LD      B,011H
L2FF2:      INC     HL
            LD      (HL),00DH
            DJNZ    L2FF2               ; (-005H)
            CALL    L1459
            POP     HL
            CALL    L193B               ; Skip space to CR, ':' or char.
            LD      (05051H),HL
            RET     Z                   ; CR or ':' return.
            CALL    L2333
            CALL    L193B               ; Skip space to CR, ':' or char.
            JP      NZ,SYNTAXERR
            LD      (05051H),HL
            LD      A,D
            OR      A
            JP      Z,UNKNWNERR
            CALL    L190B
            LD      A,C
            OR      A
            RET     Z
            CP      011H
            JP      NC,UNKNWNERR
            EX      DE,HL
            LD      DE,CMTFNAME
            LDIR    
            RET     

L3025:      LD      DE,ATRB
            LD      HL,CMTBUF
            LD      BC,PRNT
            LDIR    
            LD      B,06EH
L3032:      XOR     A
            LD      (DE),A
            INC     DE
            DJNZ    L3032               ; (-005H)
            RET     

L3038:      CALL    L3025
            LD      HL,0505CH
            LD      (DTADR),HL
            LD      DE,0505CH
            LD      HL,(04E4EH)
            XOR     A
            SBC     HL,DE
            LD      (SIZE),HL
            CALL    QWRI                ; Original ?WRI call
            JP      C,L30B8
            CALL    L1B1B
            CALL    QWRD                ; Original ?WRD call
            PUSH    AF
            CALL    L1ABF
            POP     AF
            JP      C,L30B8
            JP      WARMSTRT

L3064:      CALL    L1459
            LD      A,(L30E2)
            CP      001H
            JR      NZ,L309A            ; (+02cH)
            LD      HL,(L30E3)
L3071:      PUSH    DE
            LD      DE,04DD3H
            CALL    L1773
            JR      C,L3082             ; (+008H)
            CALL    QWRD                ; Original ?WRD call
            JR      C,L30B8             ; (+039H)
            LD      HL,04CD3H
L3082:      POP     DE
            LD      A,(DE)
            LD      (HL),A
            INC     HL
            INC     DE
            CP      00DH
            JR      NZ,L3071            ; (-01aH)
            LD      (L30E3),HL
            RET     

            CALL    L1459
            LD      A,(L30E2)
            PUSH    DE
            LD      C,000H
            CP      002H
L309A:      JP      NZ,OUTFILEERR
            LD      (L2D74),A
            LD      HL,(L30E3)
L30A3:      PUSH    DE
            LD      DE,04DD3H
            CALL    L1773
            JR      C,L30BE             ; (+012H)
            PUSH    BC
            CALL    QRDD                ; Original ?RDD call
            POP     BC
            JR      NC,L30BB            ; (+008H)
L30B3:      CP      002H
            JP      NZ,CHKSUMERR
L30B8:      JP      L1438

L30BB:      LD      HL,04CD3H
L30BE:      LD      A,(HL)
            LD      B,A
            CP      0FFH
            JR      NZ,L30CC            ; (+008H)
            LD      A,(L2D74)
            CP      002H
            JP      Z,OUTFILEERR
L30CC:      XOR     A
            LD      (L2D74),A
            LD      A,B
            POP     DE
            LD      (DE),A
            INC     HL
            INC     DE
            INC     C
            CP      00DH
            JR      NZ,L30A3            ; (-037H)
            DEC     C
            POP     DE
            LD      (L30E3),HL
            LD      B,000H
            RET     

L30E2:      NOP     
L30E3:      NOP     
            NOP     
L30E5:      CALL    L1AAF
            LD      A,(L30E2)
            OR      A
            JP      NZ,OPENERR
            LD      BC,L30FC
            PUSH    BC
            PUSH    HL
            DB      021H
            DB      033H
L30F6:      DB      02EH
            LD      (HL),003H
            JP      L2FF0

L30FC:      CALL    L3025
            LD      HL,00100H
            LD      (SIZE),HL
            LD      HL,04CD3H
            LD      (L30E3),HL
            LD      (DTADR),HL
            CALL    QWRI                ; Original ?WRI call
L3111:      JR      C,L30B8             ; (-05bH)
            CALL    MSTOP
            LD      A,001H
            LD      (L30E2),A
L311B:      JP      L1B35

L311E:      CALL    L1AAF
            LD      A,(L30E2)
            OR      A
            JP      NZ,OPENERR
            LD      BC,L313A
            PUSH    BC
            LD      A,002H
            LD      (L2D74),A
            PUSH    HL
            LD      HL,CMTBUF
            LD      (HL),004H
            JP      L2FF0

L313A:      CALL    QRDI                ; Original ?RDI call.
            JP      C,L30B3
            LD      HL,ATRB
            LD      A,(HL)
            CP      003H
            JR      NZ,L313A            ; (-00eH)
            LD      DE,CMTFNAME
            LD      A,(DE)
            CP      00DH
            JR      Z,L3155             ; (+005H)
            CALL    L2E1D               ; Compare filename.
            JR      NZ,L313A            ; NZ - filename doesnt match, read next header.
L3155:      LD      A,002H
            LD      (L30E2),A
            CALL    MSTOP
            LD      HL,04CD3H
            LD      (DTADR),HL
            LD      HL,00100H
            LD      (SIZE),HL
            LD      HL,04DD3H
            LD      (L30E3),HL
            JR      L311B               ; (-056H)

L3171:      CALL    L1459
            LD      A,(L30E2)
            OR      A
            JR      Z,L3195             ; (+01bH)
            PUSH    HL
            DEC     A
            JR      NZ,L3190            ; (+012H)
            LD      HL,(L30E3)
            LD      DE,04DD3H
            CALL    L1773
            JR      NC,L3198            ; (+00fH)
L3189:      LD      (HL),0FFH
            CALL    QWRD                ; Original ?WRD call
L318E:      JR      C,L3111             ; (-07fH)
L3190:      XOR     A
            LD      (L30E2),A
            POP     HL
L3195:      JP      CMDREMDATA

L3198:      CALL    QWRD                ; Original ?WRD call
            JR      C,L318E             ; (-00fH)
            LD      HL,04CD3H
            JR      L3189               ; (-019H)

L31A2:      LD      A,(L32D3)
            OR      A
            RET     Z
L31A7:      CALL    L32C2
            LD      A,00DH
            CALL    L3291
            XOR     A
            LD      (L32D3),A
            RET     

            PUSH    BC
            PUSH    DE
            LD      A,(L32D3)
            LD      B,A
L31BA:      LD      A,(DE)
            CP      00DH
            JP      Z,L3258
            CP      020H
            CALL    C,L31CC
            CALL    L3291
            INC     B
            INC     DE
            JR      L31BA               ; (-012H)

L31CC:      CP      005H
            JR      Z,L31F0             ; (+020H)
            CP      006H
            JR      Z,L3200             ; (+02cH)
            CP      010H
            JR      Z,L3221             ; (+049H)
            CP      011H
            JR      Z,L31F9             ; (+01dH)
            CP      012H
            JR      Z,L31F5             ; (+015H)
            CP      013H
            JR      Z,L3226             ; (+042H)
            CP      014H
            JR      Z,L322A             ; (+042H)
            CP      015H
            JR      Z,L3238             ; (+04cH)
            POP     AF
            INC     DE
            JR      L31BA               ; (-036H)

L31F0:      LD      A,00FH
L31F2:      LD      B,PRTD
            RET     

L31F5:      LD      A,00BH
            JR      L31F2               ; (-007H)

L31F9:      LD      A,009H
            LD      (L326D),A
            JR      L31F2               ; (-00eH)

L3200:      LD      A,00CH
            CALL    L3291
            LD      A,009H
            CALL    L3291
            LD      A,009H
            CALL    L3291
            LD      A,00BH
            CALL    L3291
            LD      A,00AH
            CALL    L3291
            CALL    L3267
            CALL    L3291
            JR      L31F0               ; (-031H)

L3221:      CALL    L3267
            JR      L31F2               ; (-034H)

L3226:      LD      A,00CH
            JR      L31F2               ; (-038H)

L322A:      LD      A,009H
            CALL    L3291
            LD      A,009H
            CALL    L3291
            LD      A,009H
            JR      L31F2               ; (-046H)

L3238:      LD      A,009H
            CALL    L3291
            LD      A,009H
            CALL    L3291
            LD      A,00BH
            JR      L31F2               ; (-054H)

L3246:      PUSH    BC
            PUSH    DE
            LD      A,(L32D3)
            LD      B,A
L324C:      LD      A,(DE)
            CP      00DH
            JR      Z,L3258             ; (+007H)
            CALL    L3291
            INC     DE
            INC     B
            JR      L324C               ; (-00cH)

L3258:      LD      A,B
            CP      0A0H
            JR      C,L325F             ; (+002H)
            SUB     0A0H
L325F:      LD      (L32D3),A
            POP     DE
            POP     BC
            JP      L32C2

L3267:      LD      A,00AH
            LD      (L326D),A
            RET     

L326D:      LD      A,(BC)
L326E:      PUSH    BC
            PUSH    DE
            LD      A,(L32D3)
            LD      B,A
L3274:      LD      A,020H
            CALL    L3291
            INC     B
            LD      A,B
L327B:      SUB     00AH
            JR      C,L3274             ; (-00bH)
            JR      NZ,L327B            ; (-006H)
            JP      L3258

L3284:      CALL    L3291
            CALL    L32A5
            IN      A,(PRTC)
            RRCA    
            RRCA    
            RET     

L328F:      LD      A,01BH
L3291:      PUSH    AF
            CALL    L32A5
            POP     AF
            OUT     (PRTD),A
            LD      A,080H
            OUT     (PRTC),A
            LD      A,001H
            CALL    L32A6
            XOR     A
            OUT     (PRTC),A
            RET     

L32A5:      XOR     A
L32A6:      PUSH    BC
            PUSH    DE
            LD      C,A
            LD      B,00FH
            LD      DE,MONIT
L32AE:      IN      A,(PRTC)
            AND     00DH
            CP      C
            JR      Z,L32BF             ; (+00aH)
            DEC     DE
            LD      A,D
            OR      E
            JR      NZ,L32AE            ; (-00cH)
            DJNZ    L32AE               ; (-00eH)
            JP      PRTNRDYERR

L32BF:      POP     DE
            POP     BC
            RET     

L32C2:      LD      A,007H
            CALL    L3284
            JP      NC,PRTPAPERERR
            LD      A,008H
            CALL    L3284
            RET     C
            JP      PRTHWERR

L32D3:      NOP     
CMDPAGE:    CALL    GETNUM
            LD      A,E
            OR      A
            JP      Z,ILDATERR
            LD      A,009H
            CALL    L3291
            LD      A,009H
            CALL    L3291
            LD      A,E
            PUSH    AF
            RRCA    
            RRCA    
            RRCA    
            RRCA    
            CALL    ASC
            CALL    L3291
            POP     AF
            CALL    ASC
            CALL    L3291
            JP      L1B38

L32FC:      CALL    L31A7
            JP      L1B35

            CALL    L193B
            LD      (05051H),HL
            JR      Z,L32FC             ; (-00eH)
            PUSH    HL
            CALL    L338A
            LD      BC,00500H
            CALL    L2DD8
            POP     HL
L3315:      CALL    L193B
            LD      (05051H),HL
            JR      Z,L3373             ; (+056H)
            CALL    L2E94
            CALL    EXECNOTCHR
            DB      03BH
            DW      L3326
L3326:      CALL    L2293
            PUSH    HL
            LD      HL,(04E80H)
            PUSH    BC
            LD      BC,003F0H
            ADD     HL,BC
            POP     BC
            LD      A,D
            OR      A
            CALL    Z,L2BC0
            CALL    NZ,L2BD0
            LD      A,B
            OR      C
            JR      Z,L3362             ; (+023H)
            PUSH    DE
            LD      HL,(04E80H)
            INC     HL
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            DEC     HL
            PUSH    DE
            PUSH    HL
            EX      DE,HL
            ADD     HL,BC
            XOR     A
            EX      DE,HL
            LD      HL,003E8H
            SBC     HL,DE
            JP      C,ILDATERR
            POP     HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            POP     DE
            ADD     HL,DE
            POP     DE
            EX      DE,HL
            LDIR    
L3362:      LD      HL,L3315
            EX      (SP),HL
            CALL    L193B
            RET     Z
            CP      03BH
            RET     Z
            CP      ','
            RET     Z
            JP      SYNTAXERR

L3373:      LD      HL,(04E80H)
            INC     HL
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            LD      A,D
            OR      E
            JR      Z,L3387             ; (+008H)
            INC     HL
            EX      DE,HL
            CALL    L3390
            CALL    L338A
L3387:      JP      L1B35

L338A:      LD      HL,(04E80H)
            JP      L2E09

L3390:      CALL    L328F
            LD      A,018H
            CALL    L3291
            LD      A,L
            CALL    L3291
            LD      A,H
            CALL    L3291
L33A0:      LD      A,(DE)
            CALL    L3291
            INC     DE
            DEC     HL
            LD      A,H
            OR      L
            JR      NZ,L33A0            ; (-00aH)
            RET     

CMDCOPY:    CALL    L193B
            JP      Z,SYNTAXERR
            INC     HL
            LD      (05051H),HL
            SUB     034H
            JP      Z,SYNTAXERR
            INC     A
            JP      Z,SYNTAXERR
            INC     A
            JP      Z,SYNTAXERR
            INC     A
            JP      NZ,SYNTAXERR
            LD      HL,(PAGETP)
            LD      C,019H
L33CB:      CALL    L31A7
            LD      A,028H
            LD      B,A
L33D1:      CALL    L2878
            OR      A
            JR      Z,L33DB             ; (+004H)
            CP      00DH
            JR      NZ,L33DD            ; (+002H)
L33DB:      LD      A,020H
L33DD:      CALL    L3291
            CALL    BRKEY
            JR      Z,L33FD             ; (+018H)
            INC     HL
            DJNZ    L33D1               ; (-017H)
            DEC     C
            JR      NZ,L33CB            ; (-020H)
            CALL    L31A7
            JP      L1B35

L33F1:      CALL    L328F
            LD      A,(L326D)
            JP      L3291

            CALL    L33F1
L33FD:      JP      L1438

L3400:      DB      000H
L3401:      DB      080H
L3402:      DB      086H
L3403:      XOR     A
            DB      001H
L3405:      LD      A,080H
            PUSH    DE
            XOR     (HL)
            CPL     
            LD      C,A
            LD      A,(DE)
            AND     080H
            LD      B,A
            XOR     C
            CPL     
            AND     080H
            LD      C,A
L3414:      PUSH    BC
            LD      B,(HL)
            RES     7,B
            LD      A,(DE)
            AND     07FH
            CP      B
            JR      NC,L3428            ; (+00aH)
            POP     BC
            EX      DE,HL
            LD      A,B
            XOR     C
            CPL     
            AND     080H
            LD      B,A
            JR      L3414               ; (-014H)

L3428:      LD      C,A
            ADD     A,040H
            LD      (L3402),A
            LD      A,C
            SUB     B
            POP     BC
            LD      (03400H),BC
            PUSH    DE
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            POP     HL
            INC     HL
            JR      Z,L345C             ; (+01aH)
L3442:      CP      008H
            JR      NC,L3453            ; (+00dH)
L3446:      SRL     B
            RR      C
            RR      D
            RR      E
            DEC     A
            JR      NZ,L3446            ; (-00bH)
            JR      L345C               ; (+009H)

L3453:      LD      E,D
            LD      D,C
            LD      C,B
            LD      B,000H
            SUB     008H
            JR      NZ,L3442            ; (-01aH)
L345C:      LD      A,(L3400)
            OR      A
            JR      Z,L349C             ; (+03aH)
            LD      A,(HL)
            INC     HL
            ADD     A,E
            LD      E,A
            LD      A,(HL)
            INC     HL
            ADC     A,D
            LD      D,A
            LD      A,(HL)
            INC     HL
            ADC     A,C
            LD      C,A
            LD      A,(HL)
            ADC     A,B
            LD      B,A
            JR      NC,L347F            ; (+00cH)
            RR      B
            RR      C
            RR      D
            RR      E
            LD      HL,L3402
            INC     (HL)
L347F:      LD      HL,L3402
            LD      A,(HL)
            SUB     040H
            JR      C,L348E             ; (+007H)
            JP      M,OVFLERR
            DEC     HL
            OR      (HL)
            JR      L3491               ; (+003H)

L348E:      CALL    L3CDE
L3491:      POP     HL
L3492:      LD      (HL),A
            INC     HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            LD      (HL),C
            INC     HL
            LD      (HL),B
            RET     

L349C:      LD      A,(HL)
            INC     HL
            SUB     E
            LD      E,A
            LD      A,(HL)
            INC     HL
            SBC     A,D
            LD      D,A
            LD      A,(HL)
            INC     HL
            SBC     A,C
            LD      C,A
            LD      A,(HL)
            SBC     A,B
            LD      B,A
            CALL    C,L34E4
            OR      C
            OR      D
            JR      NZ,L34B7            ; (+005H)
            LD      A,E
            CP      03FH
            JR      C,L348E             ; (-029H)
L34B7:      LD      HL,L3402
L34BA:      LD      A,B
            OR      A
            JP      M,L347F
            JR      NZ,L34D4            ; (+013H)
            LD      A,(HL)
            SUB     008H
            JR      C,L348E             ; (-038H)
            LD      (HL),A
            LD      A,C
            OR      D
            OR      E
            JR      Z,L348E             ; (-03eH)
            LD      B,C
            LD      C,D
            LD      D,E
            LD      E,000H
            JP      L34BA

L34D4:      DEC     (HL)
            JR      C,L348E             ; (-049H)
            SLA     E
            RL      D
            RL      C
            RL      B
            JP      P,L34D4
            JR      L347F               ; (-065H)

L34E4:      LD      HL,L3401
            LD      A,(HL)
            ADD     A,080H
            LD      (HL),A
            LD      A,E
            CPL     
            ADD     A,001H
            LD      E,A
            LD      A,D
            CPL     
            ADC     A,000H
            LD      D,A
            LD      A,C
            CPL     
            ADC     A,000H
            LD      C,A
            LD      A,B
            CPL     
            ADC     A,000H
            LD      B,A
            RET     

L3500:      PUSH    DE
            LD      A,(DE)
            XOR     (HL)
            CPL     
            AND     080H
            LD      (L3401),A
            LD      B,(HL)
            RES     7,B
            LD      A,(DE)
            AND     07FH
            ADD     A,B
            JP      Z,L348E
            DEC     A
L3514:      CP      030H
            JP      C,L348E
            CP      0E0H
            JP      NC,OVFLERR
            LD      (L3402),A
            XOR     A
            LD      (L3400),A
            LD      BC,00004H
            ADD     HL,BC
            LD      A,(HL)
            OR      A
            JP      P,L348E
            PUSH    HL
            POP     IY
            LD      C,B
            EX      DE,HL
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            PUSH    HL
            LD      H,B
            LD      L,B
            EXX     
            POP     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            LD      HL,MONIT
            LD      A,D
            OR      A
            JP      P,L348E
            LD      C,004H
L354A:      LD      A,(IY+000H)
            LD      B,008H
            OR      A
            JR      Z,L35C5             ; (+073H)
L3552:      RLA     
            JR      NC,L3569            ; (+014H)
            EX      AF,AF'
            EXX     
            LD      A,B
            ADD     A,C
            LD      C,A
            ADC     HL,DE
            EXX     
            ADC     HL,DE
            JR      NC,L3568            ; (+007H)
            LD      A,(L3400)
            INC     A
            LD      (L3400),A
L3568:      EX      AF,AF'
L3569:      SRL     D
            RR      E
            EXX     
            RR      D
            RR      E
            RR      B
            EXX     
            DJNZ    L3552               ; (-025H)
L3577:      DEC     IY
            DEC     C
            JR      NZ,L354A            ; (-032H)
            LD      A,(L3400)
            OR      A
            JR      Z,L3599             ; (+017H)
            LD      B,A
            LD      A,(L3402)
            ADD     A,B
            LD      (L3402),A
L358A:      SCF     
            RR      H
            RR      L
            EXX     
            RR      H
            RR      L
            RR      C
            EXX     
            DJNZ    L358A               ; (-00fH)
L3599:      EXX     
            LD      A,C
            OR      A
            JP      P,L35BD
            LD      DE,00001H
            ADD     HL,DE
            EXX     
            LD      DE,MONIT
            ADC     HL,DE
            JR      NC,L35BC            ; (+011H)
            RR      H
            RR      L
            EXX     
            RR      H
            RR      L
            EXX     
            LD      A,(L3402)
            INC     A
            LD      (L3402),A
L35BC:      EXX     
L35BD:      PUSH    HL
            EXX     
            LD      B,H
            LD      C,L
            POP     DE
            JP      L34B7

L35C5:      LD      A,E
            LD      E,D
            LD      D,000H
            EXX     
            LD      B,E
            LD      E,D
            LD      D,A
            EXX     
            JR      L3577               ; (-059H)

L35D0:      PUSH    DE
            LD      A,(DE)
            XOR     (HL)
            CPL     
            AND     080H
            LD      (L3401),A
            LD      B,(HL)
            RES     7,B
            LD      A,(DE)
            AND     07FH
            SUB     B
            ADD     A,081H
L35E2:      CP      030H
            JP      C,L348E
            CP      0E0H
            JP      NC,OVFLERR
            LD      (L3402),A
            INC     HL
            INC     DE
            EX      DE,HL
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            INC     HL
            PUSH    HL
            EX      DE,HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            LD      A,L
            EX      AF,AF'
            LD      A,H
            LD      H,B
            LD      L,C
            EXX     
            POP     HL
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            LD      H,A
            EX      AF,AF'
            LD      L,A
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            LD      H,B
            LD      L,C
            LD      A,D
            OR      A
            JP      P,OVFLERR
            LD      C,004H
L3615:      LD      B,008H
L3617:      BIT     7,H
            JR      NZ,L3633            ; (+018H)
            OR      A
L361C:      RLA     
            EXX     
            ADD     HL,HL
            EXX     
            ADC     HL,HL
            DJNZ    L3617               ; (-00dH)
            PUSH    AF
            DEC     C
            JR      NZ,L3615            ; (-013H)
L3628:      POP     AF
            LD      E,A
            POP     AF
            LD      D,A
            POP     AF
            LD      C,A
            POP     AF
            LD      B,A
            JP      L34B7

L3633:      EXX     
            OR      A
            SBC     HL,DE
            EXX     
            SBC     HL,DE
            CCF     
            JR      C,L361C             ; (-021H)
            EXX     
            ADD     HL,DE
            EXX     
            ADC     HL,DE
            OR      A
            RLA     
            EXX     
            ADD     HL,HL
            EXX     
            ADC     HL,HL
            DEC     B
            JR      NZ,L3652            ; (+006H)
            PUSH    AF
            LD      B,008H
            DEC     C
            JR      Z,L3628             ; (-02aH)
L3652:      EXX     
            OR      A
            SBC     HL,DE
            EXX     
            SBC     HL,DE
            SCF     
            RLA     
            DEC     B
            JR      NZ,L3664            ; (+006H)
            PUSH    AF
            LD      B,008H
            DEC     C
            JR      Z,L3628             ; (-03cH)
L3664:      EXX     
            ADD     HL,HL
            EXX     
            ADC     HL,HL
            JR      NC,L3617            ; (-054H)
            JR      L3652               ; (-01bH)

L366D:      DEC     E
L366E:      XOR     C
            LD      D,B
L3670:      LD      A,(HL)
            PUSH    HL
            POP     IX
            EX      DE,HL
            LD      (L366E),HL
            EX      AF,AF'
            XOR     A
            LD      (L366D),A
            LD      H,A
            LD      L,A
            EXX     
            LD      H,A
            LD      L,A
            LD      B,A
            LD      C,A
            EX      AF,AF'
            CP      02EH
            JR      Z,L369D             ; (+014H)
            SUB     030H
L368B:      CALL    L3772
            CALL    L3768
            SUB     030H
            CP      00AH
            JR      C,L368B             ; (-00cH)
            ADD     A,030H
            CP      02EH
            JR      NZ,L36AD            ; (+010H)
L369D:      CALL    L3768
            SUB     030H
            CP      00AH
            JR      NC,L36AB            ; (+005H)
            CALL    L3780
            JR      L369D               ; (-00eH)

L36AB:      ADD     A,030H
L36AD:      CP      045H
            JR      NZ,L36F5            ; (+044H)
            EXX     
            CALL    L3768
            LD      B,001H
            CP      '+'
            JR      Z,L36C1             ; (+006H)
            CP      '-'
            JP      NZ,SYNTAXERR
            DEC     B
L36C1:      LD      A,B
            OR      A
            EX      AF,AF'
            CALL    L3768
            SUB     030H
            NOP     
            NOP     
            CP      00AH
            JR      NC,L36EB            ; (+01cH)
            LD      B,A
            CALL    L3768
            SUB     030H
            CP      00AH
            JR      NC,L36EB            ; (+012H)
            LD      C,A
            CALL    L3768
            SUB     030H
            CP      00AH
            JP      C,OVFLERR
            LD      A,B
            ADD     A,A
            ADD     A,A
            ADD     A,B
            ADD     A,A
            ADD     A,C
            LD      B,A
L36EB:      EX      AF,AF'
            LD      A,B
            JR      NZ,L36F1            ; (+002H)
            CPL     
            INC     A
L36F1:      LD      (L366D),A
            EXX     
L36F5:      PUSH    IX
            LD      A,(L366D)
            ADD     A,01DH
            ADD     A,C
            LD      (L366D),A
            CP      030H
            JR      C,L370B             ; (+007H)
            CP      080H
            JP      C,OVFLERR
            JR      L375D               ; (+052H)

L370B:      LD      A,080H
            LD      (L3401),A
            LD      A,0A0H
            LD      (L3402),A
            PUSH    HL
            EXX     
            POP     BC
            LD      D,H
            LD      E,L
            LD      HL,L3725
            PUSH    HL
            LD      HL,(L366E)
            PUSH    HL
            JP      L34B7

L3725:      LD      A,(L366D)
            LD      L,A
            LD      C,A
            LD      H,000H
            LD      B,H
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,BC
            LD      BC,L37AE
            ADD     HL,BC
            LD      DE,(0366EH)
            LD      A,080H
            LD      (L3401),A
            LD      A,020H
            ADD     A,(HL)
            LD      B,A
            LD      A,(DE)
            AND     07FH
            ADD     A,B
            JP      C,OVFLERR
            SUB     021H
            JR      NC,L374D            ; (+001H)
            XOR     A
L374D:      LD      BC,L3755
            PUSH    BC
            PUSH    DE
            JP      L3514

L3755:      POP     HL
            LD      BC,00005H
            LD      D,B
            LD      E,B
            LD      A,(HL)
            RET     

L375D:      LD      HL,L3755
            PUSH    HL
            LD      HL,(L366E)
            PUSH    HL
            JP      L348E

L3768:      INC     IX
            LD      A,(IX+000H)
            CP      020H
            RET     NZ
            JR      L3768               ; (-00aH)

L3772:      OR      A
            JR      NZ,L3778            ; (+003H)
            OR      B
            RET     Z
            XOR     A
L3778:      EX      AF,AF'
            LD      A,B
            CP      009H
            JR      NZ,L378E            ; (+010H)
            INC     C
            RET     

L3780:      OR      A
            JR      NZ,L3788            ; (+005H)
            DEC     C
            OR      B
            RET     Z
            INC     C
            XOR     A
L3788:      EX      AF,AF'
            LD      A,B
            CP      009H
            RET     Z
            DEC     C
L378E:      INC     B
            LD      D,H
            LD      E,L
            EXX     
            LD      D,H
            LD      E,L
            XOR     A
            ADD     HL,HL
            RLA     
            ADD     HL,HL
            RLA     
            ADD     HL,DE
            LD      D,000H
            ADC     A,D
            ADD     HL,HL
            RLA     
            EX      AF,AF'
            LD      E,A
            EX      AF,AF'
            ADD     HL,DE
            ADC     A,D
            EXX     
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,DE
            ADD     HL,HL
            LD      D,000H
            LD      E,A
            ADD     HL,DE
            RET     

L37AE:      DB      0E0H
            DB      0F5H
            DB      0F7H
            DB      0D2H
            DB      0CAH
            DB      0E3H
            DB      0F3H
            DB      0B5H
            DB      087H
            DB      0FDH
            DB      0E7H
            DB      0B8H
            DB      0D1H
            DB      074H
            DB      09EH
            DB      0EAH
            DB      025H
            DB      006H
            DB      012H
            DB      0C6H
            DB      0EDH
            DB      0AFH
            DB      087H
            DB      096H
            DB      0F7H
            DB      0F1H
            DB      0CDH
            DB      014H
            DB      0BEH
            DB      09AH
            DB      0F4H
            DB      001H
            DB      09AH
            DB      06DH
            DB      0C1H
            DB      0F7H
            DB      081H
            DB      000H
            DB      0C9H
            DB      0F1H
            DB      0FBH
            DB      050H
            DB      0A0H
            DB      01DH
            DB      097H
L37DB:      DB      0FEH
            DB      065H
            DB      008H
            DB      0E5H
            DB      0BCH
            DB      001H
            DB      07EH
            DB      04AH
            DB      01EH
            DB      0ECH
            DB      005H
            DB      08FH
            DB      0EEH
            DB      092H
            DB      093H
            DB      008H
            DB      032H
            DB      0AAH
            DB      077H
            DB      0B8H
            DB      00BH
            DB      0BFH
            DB      094H
            DB      095H
            DB      0E6H
            DB      00FH
            DB      0F7H
            DB      07CH
            DB      01DH
            DB      090H
            DB      012H
            DB      035H
            DB      0DCH
            DB      024H
            DB      0B4H
            DB      015H
            DB      042H
            DB      013H
            DB      02EH
            DB      0E1H
            DB      019H
            DB      009H
            DB      0CCH
            DB      0BCH
            DB      08CH
            DB      01CH
            DB      00CH
            DB      0FFH
            DB      0EBH
            DB      0AFH
            DB      01FH
            DB      0CFH
            DB      0FEH
            DB      0E6H
            DB      0DBH
            DB      023H
            DB      041H
            DB      05FH
            DB      070H
            DB      089H
            DB      026H
            DB      012H
            DB      077H
            DB      0CCH
            DB      0ABH
            DB      029H
            DB      0D6H
            DB      094H
            DB      0BFH
            DB      0D6H
            DB      02DH
            DB      006H
            DB      0BDH
            DB      037H
            DB      086H
            DB      030H
            DB      047H
            DB      0ACH
            DB      0C5H
            DB      0A7H
            DB      033H
            DB      059H
            DB      017H
            DB      0B7H
            DB      0D1H
            DB      037H
            DB      098H
            DB      06EH
            DB      012H
            DB      083H
            DB      03AH
            DB      03DH
            DB      00AH
            DB      0D7H
            DB      0A3H
            DB      03DH
            DB      0CDH
            DB      0CCH
            DB      0CCH
            DB      0CCH
            DB      041H
            DB      000H
            DB      000H
            DB      000H
            DB      080H
            DB      044H
            DB      000H
            DB      000H
            DB      000H
            DB      0A0H
            DB      047H
            DB      000H
            DB      000H
            DB      000H
            DB      0C8H
            DB      04AH
            DB      000H
            DB      000H
            DB      000H
            DB      0FAH
            DB      04EH
            DB      000H
            DB      000H
            DB      040H
            DB      09CH
            DB      051H
            DB      000H
            DB      000H
            DB      050H
            DB      0C3H
            DB      054H
            DB      000H
            DB      000H
            DB      024H
            DB      0F4H
            DB      058H
            DB      000H
            DB      080H
            DB      096H
            DB      098H
            DB      05BH
            DB      000H
            DB      020H
            DB      0BCH
            DB      0BEH
            DB      05EH
            DB      000H
            DB      028H
            DB      06BH
            DB      0EEH
            DB      062H
            DB      000H
            DB      0F9H
            DB      002H
            DB      095H
            DB      065H
            DB      040H
            DB      0B7H
            DB      043H
            DB      0BAH
            DB      068H
            DB      010H
            DB      0A5H
            DB      0D4H
            DB      0E8H
            DB      06CH
            DB      02AH
            DB      0E7H
            DB      084H
            DB      091H
            DB      06FH
            DB      0F5H
            DB      020H
            DB      0E6H
            DB      0B5H
            DB      072H
            DB      032H
            DB      0A9H
            DB      05FH
            DB      0E3H
            DB      076H
            DB      0BFH
            DB      0C9H
            DB      01BH
            DB      08EH
            DB      079H
            DB      02FH
            DB      0BCH
            DB      0A2H
            DB      0B1H
            DB      07CH
            DB      03AH
            DB      06BH
            DB      00BH
            DB      0DEH
            DB      080H
            DB      005H
            DB      023H
            DB      0C7H
            DB      08AH
L38A3:      DB      08DH
            DB      06CH
L38A5:      DB      001H
L38A6:      DB      020H
L38A7:      DB      031H
L38A8:      DB      02EH
            DB      035H
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
            DB      00DH
L38AF:      DB      00DH
L38B0:      DB      00DH
L38B1:      DB      000H
L38B2:      DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
L38BB:      PUSH    DE
            CALL    L3997
            LD      A,(L38A5)
            OR      A
            JP      Z,L3960
            JP      M,L38CF
            CP      009H
            JR      C,L392B             ; (+05eH)
            JR      L38D4               ; (+005H)

L38CF:      CP      PRTD
            JP      NC,L395B
L38D4:      LD      A,02EH
            LD      (L38A7),A
            LD      HL,L38B0
            XOR     A
L38DD:      DEC     HL
            CP      (HL)
            JR      Z,L38DD             ; (-004H)
            LD      A,(HL)
            CP      02EH
            JP      Z,L398A
            INC     HL
            LD      (HL),045H
            INC     HL
            LD      A,(L38A5)
            LD      B,'+'
            OR      A
            JP      P,L38FD
            CP      0EDH
            JP      C,L398A
            LD      B,'-'
            CPL     
            INC     A
L38FD:      LD      (HL),B
            INC     HL
            LD      BC,0FF0AH
L3902:      INC     B
            SUB     C
            JR      NC,L3902            ; (-004H)
            ADD     A,C
            LD      (HL),B
            INC     HL
            LD      (HL),A
            INC     HL
            LD      (HL),00DH
L390D:      LD      HL,L38A6
L3910:      INC     HL
            LD      A,(HL)
            CP      00DH
            JR      Z,L391D             ; (+007H)
            JR      NC,L3910            ; (-008H)
            OR      030H
            LD      (HL),A
            JR      L3910               ; (-00dH)

L391D:      LD      DE,L38A6
            XOR     A
            SBC     HL,DE
            LD      B,H
            LD      C,L
            POP     HL
            EX      DE,HL
            INC     BC
            LDIR    
            RET     

L392B:      LD      HL,L38A8
            LD      DE,L38A7
            LD      B,A
            INC     B
L3933:      DEC     B
            JR      Z,L393C             ; (+006H)
            LD      A,(HL)
            LD      (DE),A
            INC     HL
            INC     DE
            JR      L3933               ; (-009H)

L393C:      LD      A,02EH
            LD      (DE),A
            LD      HL,L38B0
L3942:      LD      (HL),00DH
            DEC     HL
            LD      A,(HL)
            OR      A
            JR      Z,L3942             ; (-007H)
            CP      02EH
            JR      NZ,L394F            ; (+002H)
            LD      (HL),00DH
L394F:      LD      HL,L38A7
            LD      A,(HL)
            CP      00DH
            JR      NZ,L390D            ; (-04aH)
            LD      (HL),000H
            JR      L390D               ; (-04eH)

L395B:      LD      DE,L38B2
            JR      L3963               ; (+003H)

L3960:      LD      DE,L38B1
L3963:      LD      HL,L38AF
            LD      A,00DH
            LD      (DE),A
            PUSH    DE
            DEC     DE
            LD      BC,00008H
            LDDR    
            EX      DE,HL
            LD      A,(L38A5)
            OR      A
            JR      Z,L397A             ; (+003H)
            LD      (HL),000H
            DEC     HL
L397A:      LD      (HL),02EH
            DEC     HL
            LD      (HL),000H
            POP     HL
L3980:      DEC     HL
            LD      A,(HL)
            CP      000H
            JR      NZ,L390D            ; (-079H)
            LD      (HL),00DH
            JR      L3980               ; (-00aH)

L398A:      LD      HL,L3994
            LD      BC,GETL
            POP     DE
            LDIR    
            RET     

L3994:      JR      NZ,L39C6            ; (+030H)
            DEC     C
L3997:      LD      (L38A3),HL
            LD      A,(HL)
            LD      B,020H
            OR      A
            JP      M,L39A3
            LD      B,'-'
L39A3:      AND     07FH
            LD      (HL),A
            LD      A,B
            LD      (L38A6),A
            EX      DE,HL
            LD      HL,L37DB
            LD      A,0ECH
            EX      AF,AF'
L39B1:      EX      AF,AF'
            INC     A
            EX      AF,AF'
            LD      BC,00005H
            ADD     HL,BC
            PUSH    HL
            PUSH    DE
            LD      A,(DE)
            CALL    L3A73
            POP     DE
            POP     HL
            JR      NC,L39B1            ; (-011H)
            EX      AF,AF'
            LD      (L38A5),A
L39C6:      PUSH    DE
            LD      BC,L39D8
            PUSH    BC
            PUSH    DE
            LD      A,080H
            LD      (L3401),A
            LD      A,(DE)
            SUB     (HL)
            ADD     A,081H
            JP      L35E2

L39D8:      LD      HL,L38A7
            LD      (HL),000H
            INC     HL
            EX      (SP),HL
            LD      A,(HL)
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            PUSH    HL
            EX      DE,HL
            EXX     
            POP     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            EX      DE,HL
            SUB     0C0H
            JR      NC,L39FE            ; (+00dH)
L39F1:      SRL     H
            RR      L
            EXX     
            RR      H
            RR      L
            EXX     
            INC     A
            JR      NZ,L39F1            ; (-00dH)
L39FE:      POP     BC
            LD      A,009H
L3A01:      EX      AF,AF'
            XOR     A
            LD      D,H
            LD      E,L
            EXX     
            LD      D,H
            LD      E,L
            ADD     HL,HL
            EXX     
            ADC     HL,HL
            RLA     
            EXX     
            ADD     HL,HL
            EXX     
            ADC     HL,HL
            RLA     
            EXX     
            ADD     HL,DE
            EXX     
            ADC     HL,DE
            LD      D,000H
            ADC     A,D
            EXX     
            ADD     HL,HL
            EXX     
            ADC     HL,HL
            RLA     
            LD      (BC),A
            INC     BC
            EX      AF,AF'
            DEC     A
            JR      NZ,L3A01            ; (-026H)
L3A27:      LD      HL,L38B0
            LD      A,(HL)
            LD      (HL),000H
            CP      005H
            LD      C,000H
            JR      C,L3A34             ; (+001H)
            INC     C
L3A34:      LD      B,00AH
L3A36:      DEC     B
            JR      Z,L3A47             ; (+00eH)
            DEC     HL
            LD      A,(HL)
            ADD     A,C
            LD      (HL),A
            SUB     00AH
            LD      C,000H
            JR      C,L3A36             ; (-00dH)
            INC     C
            LD      (HL),A
            JR      L3A36               ; (-011H)

L3A47:      LD      A,(L38A7)
            OR      A
            RET     Z
            LD      HL,L38AF
            LD      DE,L38B0
            LD      BC,NL
            LDDR    
            EX      DE,HL
            LD      (HL),000H
            LD      A,(L38A5)
            INC     A
            LD      (L38A5),A
            JR      L3A27               ; (-03cH)

L3A63:      LD      BC,00005H
L3A66:      LD      A,(DE)
            OR      A
            JP      M,L3A73
            BIT     7,(HL)
            JR      Z,L3A71             ; (+002H)
            SCF     
            RET     

L3A71:      EX      DE,HL
            LD      A,(DE)
L3A73:      CP      (HL)
            RET     NZ
            DEC     C
            ADD     HL,BC
            EX      DE,HL
            ADD     HL,BC
            EX      DE,HL
            LD      B,003H
L3A7C:      LD      A,(DE)
            CP      (HL)
            RET     NZ
            DEC     HL
            DEC     DE
            DJNZ    L3A7C               ; (-007H)
            LD      A,(DE)
            CP      (HL)
            RET     

L3A86:      EX      DE,HL
            CALL    L3997
            LD      A,(L38A6)
            LD      B,080H
            CP      020H
            JR      Z,L3A95             ; (+002H)
            LD      B,000H
L3A95:      LD      A,B
            LD      (L3401),A
            OR      A
            JR      Z,L3B1A             ; (+07eH)
            LD      A,(L38A5)
            DEC     A
            JP      M,L3B50
            LD      HL,L38B0
            LD      B,00DH
            LD      (HL),B
            SUB     008H
            JR      NC,L3AB3            ; (+006H)
L3AAD:      LD      (HL),B
            DEC     HL
            INC     A
            JR      NZ,L3AAD            ; (-005H)
            DEC     A
L3AB3:      INC     A
            LD      (L366D),A
            LD      IX,L38A7
            XOR     A
            LD      H,A
            LD      L,A
            EXX     
            LD      B,A
            LD      C,A
            LD      H,A
            LD      L,A
L3AC3:      LD      A,(IX+000H)
            CP      00DH
            JR      Z,L3AD1             ; (+007H)
            CALL    L3772
            INC     IX
            JR      L3AC3               ; (-00eH)

L3AD1:      LD      A,(L366D)
            ADD     A,01DH
            ADD     A,C
            LD      (L366D),A
            LD      A,0A0H
            LD      (L3402),A
            PUSH    HL
            EXX     
            POP     BC
            LD      D,H
            LD      E,L
            LD      HL,L3AEF
            PUSH    HL
            LD      HL,(L38A3)
            PUSH    HL
            JP      L34B7

L3AEF:      LD      A,(L366D)
            LD      C,A
            LD      L,A
            LD      H,000H
            LD      B,H
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,BC
            LD      BC,L37AE
            ADD     HL,BC
            LD      DE,(038A3H)
            XOR     A
            LD      (L3400),A
            LD      A,020H
            ADD     A,(HL)
            LD      B,A
            LD      A,(DE)
            AND     07FH
            ADD     A,B
            JP      C,OVFLERR
            SUB     021H
            JR      NC,L3B16            ; (+001H)
            XOR     A
L3B16:      PUSH    DE
            JP      L3514

L3B1A:      LD      A,(L38A5)
            DEC     A
            JP      M,L3B55
            LD      HL,L38B0
            LD      BC,00D00H
            LD      (HL),B
            SUB     008H
            JR      NC,L3B3B            ; (+00fH)
            JR      L3B36               ; (+008H)

L3B2E:      EX      AF,AF'
            LD      A,(HL)
            OR      A
            JR      Z,L3B34             ; (+001H)
            INC     C
L3B34:      LD      (HL),B
            EX      AF,AF'
L3B36:      DEC     HL
            INC     A
            JR      NZ,L3B2E            ; (-00cH)
            DEC     A
L3B3B:      EX      AF,AF'
            LD      A,C
            OR      A
            JR      Z,L3B4C             ; (+00cH)
L3B40:      LD      A,(HL)
            INC     A
            LD      (HL),A
            CP      00AH
            JR      NZ,L3B4C            ; (+005H)
            LD      (HL),000H
            DEC     HL
            JR      L3B40               ; (-00cH)

L3B4C:      EX      AF,AF'
            JP      L3AB3

L3B50:      LD      DE,L2A8D
            JR      L3B58               ; (+003H)

L3B55:      LD      DE,L2A92
L3B58:      LD      HL,(L38A3)
            EX      DE,HL
L3B5C:      LD      BC,00005H
            LDIR    
            RET     

L3B62:      PUSH    DE
            CALL    L3A63
            JR      Z,L3B6D             ; (+005H)
L3B68:      LD      HL,L2A92
            JR      L3B70               ; (+003H)

L3B6D:      LD      HL,L2A8D
L3B70:      POP     DE
            JR      L3B5C               ; (-017H)

L3B73:      PUSH    DE
            EX      DE,HL
            JR      L3B78               ; (+001H)

L3B77:      PUSH    DE
L3B78:      CALL    L3A63
            JR      C,L3B68             ; (-015H)
            JR      L3B6D               ; (-012H)

L3B7F:      PUSH    DE
            CALL    L3A63
            JR      Z,L3B68             ; (-01dH)
            JR      L3B6D               ; (-01aH)

L3B87:      PUSH    DE
            EX      DE,HL
            JR      L3B8C               ; (+001H)

L3B8B:      PUSH    DE
L3B8C:      CALL    L3A63
            JR      C,L3B6D             ; (-024H)
            JR      L3B68               ; (-02bH)

L3B93:      CP      (HL)
            DEC     (HL)
            JR      Z,L3B73             ; (-024H)
            RST     008H
L3B98:      PUSH    DE
            EX      DE,HL
            LD      A,(HL)
            LD      BC,00004H
            ADD     HL,BC
            XOR     (HL)
            JP      M,L3BC4
            LD      DE,L3B93
            PUSH    DE
            LD      HL,L3BE9
            CALL    L3500
            POP     HL
            PUSH    HL
            LD      A,(HL)
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            CP      0C1H
            CALL    NC,L3BD2
            POP     HL
            PUSH    HL
            CALL    L3492
            JR      L3BCE               ; (+00aH)

L3BC4:      LD      DE,L3B93
            LD      HL,L3BE4
            PUSH    DE
            CALL    L3B5C
L3BCE:      POP     HL
            POP     DE
            JR      L3B5C               ; (-076H)

L3BD2:      SUB     0C0H
L3BD4:      SLA     E
            RL      D
            RL      C
            RL      B
            DEC     A
            JR      NZ,L3BD4            ; (-00bH)
            LD      A,0C0H
            JP      L3CC5

L3BE4:      CP      (HL)
            DEC     (HL)
            JR      Z,L3BC4             ; (-024H)
            RST     008H
L3BE9:      DB      0C5H
            DB      000H
            DB      000H
            DB      000H
            DB      0B8H
L3BEE:      DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
L3BF3:      DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
L3BF8:      DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
L3BFD:      DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
L3C02:      LD      DE,L3BEE
            JP      L3405

L3C08:      CALL    L3C02
L3C0B:      LD      HL,L3BF3
L3C0E:      LD      DE,L3BEE
            JP      L3500

L3C14:      NOP     
L3C15:      NOP     
L3C16:      PUSH    DE
            LD      HL,L3CE7
            CALL    L35D0
            POP     HL
            PUSH    HL
            LD      A,(HL)
            LD      (L3C15),A
            OR      080H
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            CP      0C3H
            JR      C,L3C43             ; (+012H)
            SUB     0C2H
L3C33:      SLA     E
            RL      D
            RL      C
            RL      B
            DEC     A
            JR      NZ,L3C33            ; (-00bH)
            LD      A,0C2H
            CALL    L3CC5
L3C43:      LD      HL,08000H
            CP      0C2H
            JR      C,L3C50             ; (+006H)
            LD      H,L
            RES     7,B
            CALL    L3CC5
L3C50:      CP      0C1H
            JR      C,L3C5A             ; (+006H)
            INC     L
            RES     7,B
            CALL    L3CC5
L3C5A:      EX      AF,AF'
            LD      A,(L3C15)
            XOR     H
            CPL     
            AND     080H
            LD      H,A
            LD      (L3C14),HL
            EX      AF,AF'
            POP     HL
            PUSH    HL
            CALL    L3492
            LD      A,(L3C14)
            OR      A
            JR      Z,L3C7A             ; (+008H)
            POP     DE
            PUSH    DE
            LD      HL,L2A88
            CALL    L3403
L3C7A:      POP     HL
            PUSH    HL
            LD      A,(HL)
            AND     07FH
            LD      B,A
            LD      A,(L3C15)
            OR      B
            LD      (HL),A
            LD      DE,L3BEE
            CALL    L3B5C
            LD      DE,L3BF3
            LD      HL,L3BEE
            CALL    L3B5C
            CALL    L3C0B
            LD      DE,L3BF3
            LD      HL,L3BEE
            CALL    L3B5C
            LD      HL,L3CEC
            CALL    L3C0E
            LD      HL,L3CF1
            CALL    L3C08
            LD      HL,L3CF6
            CALL    L3C08
            LD      HL,L3CFB
            CALL    L3C08
            LD      HL,L3D00
            CALL    L3C02
            POP     DE
            LD      HL,L3BEE
            JP      L3500

L3CC5:      BIT     7,B
            RET     NZ
            EX      AF,AF'
            LD      A,B
            OR      C
            OR      E
            OR      D
            JR      Z,L3CDE             ; (+00fH)
            EX      AF,AF'
L3CD0:      BIT     7,B
            RET     NZ
            SLA     E
            RL      D
            RL      C
            RL      B
            DEC     A
            JR      NZ,L3CD0            ; (-00eH)
L3CDE:      LD      BC,MONIT
            LD      DE,MONIT
            LD      A,080H
            RET     

L3CE7:      DB      0C1H
            DB      0A1H
            DB      0DAH
            DB      00FH
            DB      0C9H
L3CEC:      DB      0B4H
            DB      0DCH
            DB      00FH
            DB      00AH
            DB      09FH
L3CF1:      DB      039H
            DB      061H
            DB      08FH
            DB      029H
            DB      099H
L3CF6:      DB      0BDH
            DB      0C8H
            DB      077H
            DB      034H
            DB      0A3H
L3CFB:      DB      040H
            DB      085H
            DB      0E1H
            DB      05DH
            DB      0A5H
L3D00:      DB      0C1H
            DB      094H
            DB      0DAH
            DB      00FH
            DB      0C9H
L3D05:      PUSH    DE
            LD      HL,L3CE7
            CALL    L3403
            POP     HL
            CALL    L4193
            EX      DE,HL
            JP      L3C16

L3D14:      PUSH    DE
            EX      DE,HL
            LD      DE,L3BFD
            CALL    L3B5C
            POP     DE
            PUSH    DE
            CALL    L3D05
            POP     HL
            PUSH    HL
            LD      DE,L3BF8
            CALL    L3B5C
            POP     DE
            PUSH    DE
            LD      HL,L3BFD
            CALL    L3B5C
            POP     DE
            PUSH    DE
            CALL    L3C16
            POP     DE
            LD      HL,L3BF8
            JP      L35D0

L3D3D:      NOP     
L3D3E:      NOP     
L3D3F:      LD      A,003H
            LD      (L3D3D),A
            PUSH    DE
            EX      DE,HL
            LD      A,(HL)
            ADD     A,080H
            JP      NC,ILDATERR
            JR      NZ,L3D5B            ; (+00dH)
            EX      AF,AF'
            LD      BC,00004H
            ADD     HL,BC
            LD      A,(HL)
            SBC     HL,BC
            OR      A
            JP      P,L3DBA
            EX      AF,AF'
L3D5B:      BIT     0,A
            JR      NZ,L3DD5            ; (+076H)
            LD      (L3D3E),A
            LD      (HL),0C0H
            LD      DE,L3BEE
            CALL    L3B5C
            LD      HL,L3DED
            CALL    L3C0E
            LD      HL,L3DF2
L3D73:      CALL    L3C02
L3D76:      LD      DE,L3BF3
            POP     HL
            PUSH    HL
            CALL    L3B5C
            LD      DE,L3BF3
            LD      HL,L3BEE
            CALL    L35D0
            LD      HL,L3BF3
            CALL    L3C02
            LD      HL,L3BEE
            LD      A,(HL)
            AND     07FH
            DEC     A
            JR      C,L3DBA             ; (+024H)
            OR      080H
            LD      (HL),A
            LD      A,(L3D3D)
            DEC     A
            LD      (L3D3D),A
            JR      NZ,L3D76            ; (-02cH)
            LD      A,(L3D3E)
            CP      040H
            CALL    NZ,L3DC1
            LD      B,(HL)
            RES     7,B
            ADD     A,B
            SUB     040H
            JR      C,L3DBA             ; (+008H)
            JP      M,OVFLERR
            OR      080H
            LD      (HL),A
            JR      L3DBD               ; (+003H)

L3DBA:      LD      HL,L2A8D
L3DBD:      POP     DE
            JP      L3B5C

L3DC1:      JR      C,L3DCA             ; (+007H)
            SUB     040H
            SRL     A
            ADD     A,040H
            RET     

L3DCA:      LD      B,A
            LD      A,040H
            SUB     B
            SRL     A
            LD      B,A
            LD      A,040H
            SUB     B
            RET     

L3DD5:      INC     A
            LD      (L3D3E),A
            LD      (HL),0BFH
            LD      DE,L3BEE
            CALL    L3B5C
            LD      HL,L3DF7
            CALL    L3C0E
            LD      HL,L3DFC
            JP      L3D73

L3DED:      DB      0C0H
            DB      000H
            DB      000H
            DB      000H
            DB      090H
L3DF2:      DB      0BFH
            DB      000H
            DB      000H
            DB      000H
            DB      0E0H
L3DF7:      DB      0C0H
            DB      000H
            DB      000H
            DB      000H
            DB      0E0H
L3DFC:      DB      0BFH
            DB      000H
            DB      000H
            DB      000H
            DB      090H
L3E01:      NOP     
L3E02:      NOP     
L3E03:      PUSH    DE
            LD      A,(DE)
            AND     080H
            LD      (L3E01),A
            LD      A,(DE)
            OR      080H
            LD      (DE),A
            LD      HL,L3F2D
            CALL    L35D0
            POP     HL
            PUSH    HL
            LD      A,040H
            LD      (L3E02),A
            LD      A,(HL)
            SUB     0C1H
            CALL    NC,L3EBB
            POP     DE
            PUSH    DE
            LD      HL,L3F28
            CALL    L3403
            POP     HL
            PUSH    HL
            LD      DE,L3BEE
            CALL    L3B5C
            LD      HL,L3F05
            CALL    L3C0E
            LD      HL,L3F0A
            CALL    L3C02
            POP     HL
            PUSH    HL
            CALL    L3C0E
            LD      HL,L3F0F
            CALL    L3C02
            POP     HL
            PUSH    HL
            CALL    L3C0E
            LD      HL,L3F14
            CALL    L3C02
            POP     HL
            PUSH    HL
            CALL    L3C0E
            LD      HL,L3F19
            CALL    L3C02
            POP     HL
            PUSH    HL
            CALL    L3C0E
            LD      HL,L3F1E
            CALL    L3C02
            POP     HL
            PUSH    HL
            CALL    L3C0E
            LD      HL,L3F23
            CALL    L3C02
            LD      HL,L3BEE
            LD      B,(HL)
            RES     7,B
            LD      A,(L3E02)
            ADD     A,B
            JP      C,L3EFC
            SUB     03FH
            JR      C,L3EEC             ; (+067H)
            JP      M,L3EFC
            OR      080H
            LD      (HL),A
            LD      A,(L3E01)
            OR      A
            JR      Z,L3E98             ; (+007H)
            LD      HL,L3BEE
            POP     DE
            JP      L3B5C

L3E98:      POP     DE
            PUSH    DE
            LD      HL,L2A88
            CALL    L3B5C
            POP     DE
            PUSH    DE
            LD      A,(DE)
            CP      0FCH
            PUSH    AF
            JR      C,L3EAA             ; (+002H)
            DEC     A
            LD      (DE),A
L3EAA:      LD      HL,L3BEE
            CALL    L35D0
            POP     AF
            POP     HL
            RET     C
            LD      A,(HL)
            DEC     A
            LD      (HL),A
            RET     M
            PUSH    HL
            JP      L348E

L3EBB:      INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            PUSH    HL
            INC     A
            LD      H,A
            XOR     A
L3EC7:      SLA     E
            RL      D
            RL      C
            RL      B
            RLA     
            JR      C,L3EFA             ; (+028H)
            DEC     H
            JR      NZ,L3EC7            ; (-00eH)
            ADD     A,040H
            JR      C,L3EFA             ; (+021H)
            LD      (L3E02),A
            LD      A,0C0H
            CALL    L3CC5
            POP     HL
            LD      (HL),B
            DEC     HL
            LD      (HL),C
            DEC     HL
            LD      (HL),D
            DEC     HL
            LD      (HL),E
            DEC     HL
            LD      (HL),A
            RET     

L3EEC:      LD      A,(L3E01)
            OR      A
            JP      Z,OVFLERR
L3EF3:      LD      HL,L2A8D
            POP     DE
            JP      L3B5C

L3EFA:      POP     AF
            POP     AF
L3EFC:      LD      A,(L3E01)
            OR      A
            JP      NZ,OVFLERR
            JR      L3EF3               ; (-012H)

L3F05:      DB      0B3H
            DB      07CH
            DB      08CH
            DB      090H
            DB      0E3H
L3F0A:      DB      0B6H
            DB      01FH
            DB      0DFH
            DB      062H
            DB      0F8H
L3F0F:      DB      0B9H
            DB      0E2H
            DB      06DH
            DB      0DDH
            DB      0DEH
L3F14:      DB      0BCH
            DB      08BH
            DB      033H
            DB      0C1H
            DB      0A0H
L3F19:      DB      0BEH
            DB      089H
            DB      04AH
            DB      0F1H
            DB      0ADH
L3F1E:      DB      0BFH
            DB      034H
            DB      033H
            DB      0F2H
            DB      0FAH
L3F23:      DB      0C0H
            DB      036H
            DB      0F3H
            DB      004H
            DB      0B5H
L3F28:      DB      0C0H
            DB      000H
            DB      000H
            DB      000H
            DB      080H
L3F2D:      DB      0C0H
            DB      0F8H
            DB      017H
            DB      072H
            DB      0B1H
L3F32:      DB      000H
L3F33:      DB      000H
L3F34:      DB      000H
L3F35:      PUSH    DE
            LD      A,080H
            LD      (L3F33),A
            LD      (L3F32),A
            EX      DE,HL
            LD      A,(HL)
            OR      A
            JP      P,OVFLERR
            CP      08AH
            JR      NC,L3F53            ; (+00bH)
            XOR     A
            LD      (L3F32),A
            EX      DE,HL
            CALL    L3D3F
            POP     HL
            PUSH    HL
            LD      A,(HL)
L3F53:      CP      0C1H
            CALL    C,L4011
            LD      B,000H
            CP      0C1H
            JR      Z,L3F64             ; (+006H)
            SUB     0C1H
            LD      B,A
            LD      A,0C1H
            LD      (HL),A
L3F64:      LD      A,B
            LD      (L3F34),A
            LD      DE,L3BEE
            CALL    L3B5C
            POP     DE
            PUSH    DE
            LD      HL,L4055
            CALL    L3403
            LD      HL,L4055
            CALL    L3C02
            POP     DE
            PUSH    DE
            LD      HL,L3BEE
            CALL    L35D0
            POP     DE
            PUSH    DE
            LD      HL,L405A
            CALL    L3500
            POP     HL
            PUSH    HL
            LD      DE,L3BF3
            CALL    L3B5C
            POP     HL
            PUSH    HL
            LD      DE,L3BF3
            CALL    L3500
            LD      DE,L3BEE
            LD      HL,L3BF3
            CALL    L3B5C
            LD      HL,L4041
            CALL    L3C0E
            LD      HL,L4046
            CALL    L3C08
            LD      HL,L404B
            CALL    L3C08
            LD      HL,L4050
            CALL    L3C02
            POP     HL
            PUSH    HL
            CALL    L3C0E
            LD      DE,L3BF3
            LD      HL,L3BEE
            CALL    L3B5C
            LD      A,(L3F34)
            ADD     A,A
            INC     A
            LD      B,A
            LD      A,008H
L3FD3:      BIT     7,B
            JR      NZ,L3FDC            ; (+005H)
            SLA     B
            DEC     A
            JR      NZ,L3FD3            ; (-009H)
L3FDC:      ADD     A,0C0H
            LD      HL,L3BEE
            LD      (HL),A
            INC     HL
            XOR     A
            LD      (HL),A
            INC     HL
            LD      (HL),A
            INC     HL
            LD      (HL),A
            INC     HL
            LD      (HL),B
            LD      HL,L405F
            CALL    L3C0E
            LD      HL,L3BF3
            CALL    L3C02
            LD      HL,L3BEE
            LD      A,(L3F33)
            CALL    L4191
            POP     DE
            PUSH    DE
            CALL    L3B5C
            POP     DE
            LD      A,(L3F32)
            OR      A
            RET     NZ
            LD      HL,L3BEE
            JP      L3405

L4011:      PUSH    HL
            LD      DE,L3BEE
            CALL    L3B5C
            POP     DE
            PUSH    DE
            LD      HL,L2A88
            CALL    L3B5C
            POP     DE
            PUSH    DE
            LD      HL,L3BEE
            CALL    L35D0
            POP     HL
            LD      A,(HL)
            CP      0C1H
            JR      NC,L4039            ; (+00bH)
            PUSH    HL
            EX      DE,HL
            LD      HL,L2A88
            CALL    L3B5C
            POP     HL
            LD      A,0C1H
L4039:      EX      AF,AF'
            LD      A,000H
            LD      (L3F33),A
            EX      AF,AF'
            RET     

L4041:      DB      0ADH
            DB      0A4H
            DB      062H
            DB      0CCH
            DB      0AFH
L4046:      DB      0B2H
            DB      09FH
            DB      0E9H
            DB      047H
            DB      0F9H
L404B:      DB      0B8H
            DB      0A4H
            DB      082H
            DB      0AAH
            DB      0DCH
L4050:      DB      0BFH
            DB      0BFH
            DB      0CCH
            DB      0B0H
            DB      0AFH
L4055:      DB      0C1H
            DB      033H
            DB      0F3H
            DB      004H
            DB      0B5H
L405A:      DB      0C3H
            DB      099H
            DB      079H
            DB      082H
            DB      0BAH
L405F:      DB      0BFH
            DB      0F8H
            DB      017H
            DB      072H
            DB      0B1H
L4064:      PUSH    DE
            CALL    L3F35
            POP     DE
            LD      HL,L406F
            JP      L3500

L406F:      DB      0BFH
            DB      0A9H
            DB      0D8H
            DB      05BH
            DB      0DEH
L4074:      DB      000H
L4075:      DB      000H
L4076:      PUSH    DE
            EX      DE,HL
            LD      A,(HL)
            AND     080H
            LD      (L4074),A
            SET     7,(HL)
            LD      DE,L2A88
            CALL    L3A63
            LD      A,080H
            JR      NC,L40A3            ; (+019H)
            LD      DE,L3BEE
            POP     HL
            PUSH    HL
            CALL    L3B5C
            POP     DE
            PUSH    DE
            LD      HL,L2A88
            CALL    L3B5C
            POP     DE
            PUSH    DE
            LD      HL,L3BEE
            CALL    L35D0
            XOR     A
L40A3:      LD      (L4075),A
            POP     HL
            PUSH    HL
            LD      DE,L3BEE
            CALL    L3B5C
            POP     HL
            PUSH    HL
            CALL    L3C0E
            LD      HL,L3BEE
            LD      DE,L3BF3
            CALL    L3B5C
            LD      HL,L4121
            CALL    L3C0E
            LD      HL,L4126
            CALL    L3C08
            LD      HL,L412B
            CALL    L3C08
            LD      HL,L4130
            CALL    L3C08
            LD      HL,L4135
            CALL    L3C08
            LD      HL,L413A
            CALL    L3C08
            LD      HL,L413F
            CALL    L3C08
            LD      HL,L4144
            CALL    L3C08
            LD      HL,L4149
            CALL    L3C08
            LD      HL,L2A88
            CALL    L3C02
            POP     HL
            PUSH    HL
            CALL    L3C0E
            POP     DE
            PUSH    DE
            LD      HL,L3BEE
            CALL    L3B5C
            LD      A,(L4075)
            OR      A
            JR      NZ,L411B            ; (+010H)
            POP     DE
            PUSH    DE
            LD      HL,L3CE7
            CALL    L3B5C
            POP     DE
            PUSH    DE
            LD      HL,L3BEE
            DB      0CDH
            DB      003H
L411A:      DB      034H
L411B:      POP     HL
            LD      A,(L4074)
            JR      L4191               ; (+070H)

L4121:      DB      037H
            DB      0CAH
            DB      09AH
            DB      056H
            DB      0DFH
L4126:      DB      0BAH
            DB      012H
            DB      077H
            DB      0CCH
            DB      0ABH
L412B:      DB      03BH
            DB      023H
            DB      0B2H
            DB      05EH
            DB      0F8H
L4130:      DB      0BCH
            DB      020H
            DB      063H
            DB      090H
            DB      0E9H
L4135:      DB      03DH
            DB      0EEH
            DB      03DH
            DB      0E0H
            DB      0AAH
L413A:      DB      0BDH
            DB      04FH
            DB      01AH
            DB      0D5H
            DB      0DFH
L413F:      DB      03EH
            DB      0E3H
            DB      0AFH
            DB      003H
            DB      092H
L4144:      DB      0BEH
            DB      02AH
            DB      07BH
            DB      0C7H
            DB      0CCH
L4149:      DB      03FH
            DB      017H
            DB      096H
            DB      0AAH
            DB      0AAH
L414E:      DB      000H
            DB      000H
            DB      000H
            DB      000H
L4152:      DB      000H
L4153:      DB      000H
L4154:      DB      000H
            DB      000H
            DB      000H
            DB      000H
            DB      000H
L4159:      PUSH    DE
            LD      DE,L4154
            CALL    L3B5C
            POP     HL
            PUSH    HL
            LD      BC,00004H
            ADD     HL,BC
            LD      A,(HL)
            OR      A
            POP     HL
            PUSH    HL
            JP      P,L348E
            LD      A,(HL)
            AND     080H
            LD      (L4153),A
            SET     7,(HL)
            EX      DE,HL
            CALL    L3F35
            LD      A,(L4153)
            OR      A
            CALL    Z,L41A4
            POP     DE
            PUSH    DE
            LD      HL,L4154
            CALL    L3500
            POP     DE
            PUSH    DE
            CALL    L3E03
            POP     HL
            LD      A,(L4153)
L4191:      OR      A
            RET     NZ
L4193:      LD      BC,00004H
            ADD     HL,BC
            BIT     7,(HL)
            PUSH    AF
            XOR     A
            SBC     HL,BC
            POP     AF
            RET     Z
            LD      A,(HL)
            ADD     A,080H
            LD      (HL),A
            RET     

L41A4:      LD      HL,L4154
            LD      DE,L414E
            CALL    L3B5C
            LD      DE,L4154
            CALL    L3A86
            LD      DE,L414E
            LD      HL,L4154
            CALL    L3403
            LD      HL,L4152
            LD      A,(HL)
            OR      A
            JP      M,ILDATERR
            LD      HL,L4154
            LD      A,(HL)
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            AND     07FH
            SUB     041H
            JR      C,L41E6             ; (+010H)
            JR      Z,L41E3             ; (+00bH)
L41D8:      SLA     E
            RL      D
            RL      C
            RL      B
            DEC     A
            JR      NZ,L41D8            ; (-00bH)
L41E3:      RL      B
            RET     C
L41E6:      LD      A,080H
            LD      (L4153),A
            RET     

TAPECOPYPRG:IF BUILD_ORIG = 1
            ; Self duplicate code. This method is used to duplicate BASIC SA-5510 onto a new cassette.
              NOP   
              LD    DE,ATRB
              LD    HL,L4223
              LD    BC,PRNT
              LDIR  
              LD    HL,TAPECOPY
              LD    (DTADR),HL
              LD    DE,TAPECOPYPRG
              EX    DE,HL
              XOR   A
              SBC   HL,DE
              INC   HL
              LD    (SIZE),HL
              LD    HL,COLDSTRT
              LD    (EXADR),HL
              CALL  ?WRI
              RET   C
              LD    HL,TAPECOPYPRG
              LD    A,0C9H
              LD    (HL),A
              CALL  ?WRD
              PUSH  AF
              LD    A,000H
              LD    (HL),A
              POP   AF
              RET   C
              RET   

L4223:        DB    001H,"BASIC SA-5510",00DH
            ENDIF

            ; Define extensions under TZFS. Each is in a seperate block due to Glass Z80 way of not evaluating labels inside IF statements when false.
            ;
TZFSRDI:    IF BUILD_TZFS = 1
              ; TZFS extensions, call the TZFS API to execute extended code.
              LD    DE,CMTFNAME
              JP    CMT_RDINF
            ENDIF
CMDDIR:     IF BUILD_TZFS = 1
              CALL  L193B               ; Skip space to CR, ':' or char.
              LD    (05051H),HL
              JR    Z,CMDDIRNOSTR       ; CR or ':' return.
CMDDIRNOSTR:  EX    DE,HL               ; CMT_DIR expects DE to point to argument string.
              CALL  CMT_DIR
              JP    WARMSTRT
            ENDIF
CHGDIR:     IF BUILD_TZFS = 1
              CALL  L193B               ; Skip space to CR, ':' or char.
              LD    (05051H),HL
              JR    Z,CHGDIRNOSTR       ; CR or ':' return.
CHGDIRNOSTR:  EX    DE,HL               ; CMT_CD expects DE to point to argument string.
              CALL  CMT_CD
              JP    WARMSTRT
            ENDIF
SETFREQ:    IF BUILD_TZFS = 1
              CALL  L193B               ; Skip space to CR, ':' or char.
              LD    (05051H),HL
              JR    Z,SETFREQNOSTR      ; CR or ':' return.
SETFREQNOSTR: EX    DE,HL               ; SET_FREQ expects DE to point to argument string.
              CALL  SET_FREQ
              JP    WARMSTRT
            ENDIF

BASICEND:
