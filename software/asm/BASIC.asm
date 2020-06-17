;-----------------------------------------------------------------------------------------------
; NASCOM ROM BASIC Ver 4.7, (C) 1978 Microsoft
; Scanned from source published in 80-BUS NEWS from Vol 2, Issue 3
; (May-June 1983) to Vol 3, Issue 3 (May-June 1984)
; Adapted for the freeware Zilog Macro Assembler 2.10 to produce
; the original ROM code (checksum A934H). PA
;
; This BASIC has been created from the original NASCOM v4.7b source and also
; may have elements of Grant Searle's changes as both were used in creating this
; version.
;
; It has undergone extensive modification:
; 1. Restore the CLOAD/CSAVE commands. These commands load/save tokenised cassette
;    images. The cassette images are from the NASCOM but converted with the
;    'nasconv' C program which removes the tape formatting, updates the token values
;    and address pointers.
; 2. Add LOAD/SAVE commands. These commands load/save BASIC in text format.
; 3. Restored the SCREEN command so it works with the Sharp MZ80A 40/80 column screen.
; 4. Increased the command word table to allow additional commands which I expect to add.
; I've added additional comments as things have been figured out to aid future understanding.
;
; Thus (C)opyright notices:
; Original source is: (C) 1978 Microsoft
; Updates (some reversed out): Grant Searle, http://searle.hostei.com/grant/index.html
;                                            eMail: home.micros01@btinternet.com
; All other updates (C) Philip Smart, 2020. http://www.eaw.app philip.smart\@net2net.org
;-----------------------------------------------------------------------------------------------


            ; Bring in additional resources.
            INCLUDE "BASIC_Definitions.asm"
            INCLUDE "Macros.asm"

            ; Sharp MZ-80A Tape Format Header - used by all software including RFS/TZFS 
            ; in processing/loading of this file.
            ;
            ORG     10F0h

            DB      01h                                                                                     ; Code Type, 01 = Machine Code.
            DB      "MZ80A BASIC V1.0", 0Dh                                                                 ; Title/Name (17 bytes).
HEADER1:    IF BUILD_MZ80A = 1
            DW      CODEEND - CODESTART                                                                     ; Size of program.
            DW      CODESTART                                                                               ; Load address of program.
            DW      CODESTART                                                                               ; Exec address of program.
            ENDIF
HEADER2:    IF BUILD_TZFS = 1
            DW      (CODEEND - CODESTART) + (RELOCEND - RELOC)                                              ; Size of program.
            DW      01200H                                                                                  ; Load address of program.
            DW      RELOC                                                                                   ; Exec address of program.
            ENDIF
            DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h          ; Comment (104 bytes).
            DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
            DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
            DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
            DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
            DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
            DB      00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

            ; Load address of this program when first loaded.
            ;
BUILD1:     IF BUILD_MZ80A = 1
            ORG     1200H
            ENDIF

BUILD2:     IF BUILD_TZFS = 1
            ORG     0000H
            ENDIF

CODESTART:

COLD:       JP      STARTB               ; Jump for cold start
WARM:       JP      WARMST               ; Jump for warm start
STARTB:     
            LD      IX,0                 ; Flag cold start
            JP      CSTART               ; Jump to initialise

            DW      DEINT                ; Get integer -32768 to 32767
            DW      ABPASS               ; Return integer in AB


VECTORS:    IF BUILD_TZFS = 1
            ALIGN   0038H
            ORG     0038H
INTVEC:     DS      3                    ; Space for the Interrupt vector.

            ALIGN   0066H
            ORG     0066H
NMIVEC:     DS      3                    ; Space for the NMI vector.
            ENDIF

CSTART:     DI                           ; Disable Interrupts and sat mode. NB. Interrupts are physically disabled by 8255 Port C2 set to low.
            IM      1
            LD      SP,STACK             ; Start of workspace RAM

MEMSW0:     IF BUILD_TZFS = 1
            LD      A,TZMM_MZ700_0       ; Ensure the top part of RAM is set to use the mainboard as we need to configure hardware.
            OUT     (MMCFG),A
            ENDIF

INITST:     LD      A,0                  ; Clear break flag
            LD      (BRKFLG),A

            LD      HL,GVARSTART         ; Start of global variable area
            LD      BC,GVAREND-GVARSTART ; Size of global variable area.
            XOR     A
            LD      D,A
INIT1:      LD      (HL),D               ; Clear variable memory including stack space.
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,INIT1
            ;
            CALL    MODE                 ; Configure 8255 port C, set Motor Off, VGATE to 1 (off) and INTMSK to 0 (interrupts disabled).
            LD      A,000H               ; Clear the screen buffer.
            LD      HL,SCRN
            CALL    CLR8
            LD      A,017H               ; Blue background, white characters in colour mode. Bit 7 is set as a write to bit 7 @ DFFFH selects 80Char mode.
            LD      HL,ARAM
            CALL    CLR8
            LD      A,004H
            LD      (TEMPW),A            ; Setup the tempo for sound output.

INIT3:      ; Setup keyboard buffer control.
            LD      A,0
            LD      (KEYCOUNT),A         ; Set keyboard buffer to empty.
            LD      HL,KEYBUF
            LD      (KEYWRITE),HL        ; Set write pointer to beginning of keyboard buffer.
            LD      (KEYREAD),HL         ; Set read pointer to beginning of keyboard buffer.

            ; Setup keyboard rate control and set to CAPSLOCK mode.
            ; (0 = Off, 1 = CAPSLOCK, 2 = SHIFTLOCK).
            LD      A,000H               ; Initialise key repeater.
            LD      (KEYRPT),A
            LD      A,001H
            LD      (SFTLK),A            ; Setup shift lock, default = off.

            ; Setup the initial cursor, for CAPSLOCK this is a double underscore.
            LD      A,03EH
            LD      (FLSDT),A
            LD      A,080H               ; Cursor on (Bit D7=1).
            LD      (FLASHCTL),A

            ; Change to 80 character mode.
            LD      A, 128               ; 80 char mode.
            LD      (DSPCTL), A
            CALL    MLDSP
            CALL    BEL                  ; Beep to indicate startup - for cases where screen is slow to startup.
            LD      A,0FFH
            LD      (SWRK),A

            ; Setup timer interrupts
            LD      IX,TIMIN             ; Pass the interrupt service handler vector.
            LD      BC,00000H            ; Time starts at 00:00:00 01/01/1980 on initialisation.
            LD      DE,00000H
            LD      HL,00000H
            CALL    TIMESET
            ;
            LD      A,05H                ; Enable interrupts at hardware level, this must be done before switching memory mode.
            LD      (KEYPF),A
            ;
MEMSW1:     IF BUILD_TZFS = 1
            LD      A,TZMM_MZ700_2       ; Enable the full 64K memory range before starting BASIC initialisation.
            OUT     (MMCFG),A
            ENDIF

            ; Clear memory
            LD      HL,WRKSPC
MEMSZ1:     IF BUILD_MZ80A = 1
            LD      BC,MAXMEM - WRKSPC   ; Clear to top of physical RAM.
            ENDIF
MEMSZ2:     IF BUILD_TZFS = 1
            LD      BC,10000H - WRKSPC   ; Clear to top of physical RAM.
            ENDIF
            LD      E,00H
INIT4:      LD      (HL),E
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,INIT4
            ;
            EI
            ;
INIT:       LD      DE,INITAB            ; Initialise workspace
            LD      B,INITBE-INITAB+3    ; Bytes to copy
            LD      HL,WRKSPC            ; Into workspace RAM
COPY:       LD      A,(DE)               ; Get source
            LD      (HL),A               ; To destination
            INC     HL                   ; Next destination
            INC     DE                   ; Next source
            DEC     B                    ; Count bytes
            JP      NZ,COPY              ; More to move
       ;    LD      SP,HL                ; Temporary stack
            CALL    CLREG                ; Clear registers and stack
            CALL    PRNTCRLF             ; Output CRLF
            LD      (BUFFER+72+1),A      ; Mark end of buffer
            LD      (PROGST),A           ; Initialise program area

            LD      HL,MAXMEM
            LD      DE,0-50              ; 50 Bytes string space
            LD      (LSTRAM),HL          ; Save last available RAM
            ADD     HL,DE                ; Allocate string space
            LD      (STRSPC),HL          ; Save string space
            CALL    CLRPTR               ; Clear program area
            LD      HL,(STRSPC)          ; Get end of memory
            LD      DE,0-17              ; Offset for free bytes
            ADD     HL,DE                ; Adjust HL
            LD      DE,PROGST            ; Start of program text
            LD      A,L                  ; Get LSB
            SUB     E                    ; Adjust it
            LD      L,A                  ; Re-save
            LD      A,H                  ; Get MSB
            SBC     A,D                  ; Adjust it
            LD      H,A                  ; Re-save
            PUSH    HL                   ; Save bytes free
            LD      HL,SIGNON            ; Sign-on message
            CALL    PRS                  ; Output string
            POP     HL                   ; Get bytes free back
            CALL    PRNTHL               ; Output amount of free memory
            LD      HL,BFREE             ; " Bytes free" message
            CALL    PRS                  ; Output string

WARMST:     LD      SP,STACK             ; Temporary stack
BRKRET:     CALL    CLREG                ; Clear registers and stack
            JP      PRNTOK               ; Go to get command line

            ; FUNCTION ADDRESS TABLE

FNCTAB:     DW      SGN
            DW      INT
            DW      ABS
            DW      USR
            DW      FRE
            DW      INP
            DW      POS
            DW      SQR
            DW      RND
            DW      LOG
            DW      EXP
            DW      COS
            DW      SIN
            DW      TAN
            DW      ATN
            DW      PEEK
            DW      DEEK
            DW      POINT
            DW      LEN
            DW      STR
            DW      VAL
            DW      ASC
            DW      CHR
            DW      HEX
            DW      BIN
            DW      LEFT
            DW      RIGHT
            DW      MID

            ; RESERVED WORD LIST

WORDS:      DB      'E'+80H,"ND"         ; 0x80
            DB      'F'+80H,"OR"         ; 0x81
            DB      'N'+80H,"EXT"        ; 0x82
            DB      'D'+80H,"ATA"        ; 0x83
            DB      'I'+80H,"NPUT"       ; 0x84
            DB      'D'+80H,"IM"         ; 0x85
            DB      'R'+80H,"EAD"        ; 0x86
            DB      'L'+80H,"ET"         ; 0x87
            DB      'G'+80H,"OTO"        ; 0x88
            DB      'R'+80H,"UN"         ; 0x89
            DB      'I'+80H,"F"          ; 0x8a
            DB      'R'+80H,"ESTORE"     ; 0x8b
            DB      'G'+80H,"OSUB"       ; 0x8c
            DB      'R'+80H,"ETURN"      ; 0x8d
            DB      'R'+80H,"EM"         ; 0x8e
            DB      'S'+80H,"TOP"        ; 0x8f
            DB      'O'+80H,"UT"         ; 0x90
            DB      'O'+80H,"N"          ; 0x91
            DB      'N'+80H,"ULL"        ; 0x92
            DB      'W'+80H,"AIT"        ; 0x93
            DB      'D'+80H,"EF"         ; 0x94
            DB      'P'+80H,"OKE"        ; 0x95
            DB      'D'+80H,"OKE"        ; 0x96
            DB      'S'+80H,"CREEN"      ; 0x97
            DB      'L'+80H,"INES"       ; 0x98
            DB      'C'+80H,"LS"         ; 0x99
            DB      'W'+80H,"IDTH"       ; 0x9a
            DB      'M'+80H,"ONITOR"     ; 0x9b
            DB      'S'+80H,"ET"         ; 0x9c
            DB      'R'+80H,"ESET"       ; 0x9d
            DB      'P'+80H,"RINT"       ; 0x9e
            DB      'C'+80H,"ONT"        ; 0x9f
            DB      'L'+80H,"IST"        ; 0xa0
            DB      'C'+80H,"LEAR"       ; 0xa1
            DB      'C'+80H,"LOAD"       ; 0xa2
            DB      'C'+80H,"SAVE"       ; 0xa3
            DB      'L'+80H,"OAD"        ; 0xa4
            DB      'S'+80H,"AVE"        ; 0xa5 
            DB      'F'+80H,"REQ"        ; 0xa6
            DB      'N'+80H,"EW"         ; 0xa7    <- Command list terminator word, move to lowest command. Update the ZNEW variable below as well.
                                         ;         <- Reserved space for new commands.
            DB      'R'+80H,"EM"         ; 0xa8
            DB      'R'+80H,"EM"         ; 0xa9  
            DB      'R'+80H,"EM"         ; 0xaa  
            DB      'R'+80H,"EM"         ; 0xab 
            DB      'R'+80H,"EM"         ; 0xac  
            DB      'R'+80H,"EM"         ; 0xad  
            DB      'R'+80H,"EM"         ; 0xae  
            DB      'R'+80H,"EM"         ; 0xaf  
            DB      'R'+80H,"EM"         ; 0xb0  
            DB      'R'+80H,"EM"         ; 0xb1  
            DB      'R'+80H,"EM"         ; 0xb2  
            DB      'R'+80H,"EM"         ; 0xb3  
            DB      'R'+80H,"EM"         ; 0xb4  
            DB      'R'+80H,"EM"         ; 0xb5  
            DB      'R'+80H,"EM"         ; 0xb6  
            DB      'R'+80H,"EM"         ; 0xb7  
            DB      'R'+80H,"EM"         ; 0xb8  
            DB      'R'+80H,"EM"         ; 0xb9  
            DB      'R'+80H,"EM"         ; 0xba  
            DB      'R'+80H,"EM"         ; 0xbb  
            DB      'R'+80H,"EM"         ; 0xbc  
            DB      'R'+80H,"EM"         ; 0xbd  
            DB      'R'+80H,"EM"         ; 0xbe  
            DB      'R'+80H,"EM"         ; 0xbf  

            DB      'T'+80H,"AB("        ; 0xc0  <- 0xa5
            DB      'T'+80H,"O"          ; 0xc1  <- 0xa6
            DB      'F'+80H,"N"          ; 0xc2  <- 0xa7
            DB      'S'+80H,"PC("        ; 0xc3  <- 0xa8
            DB      'T'+80H,"HEN"        ; 0xc4  <- 0xa9
            DB      'N'+80H,"OT"         ; 0xc5  <- 0xaa
            DB      'S'+80H,"TEP"        ; 0xc6  <- 0xab

            DB      '+'+80H              ; 0xc7  <- 0xac
            DB      '-'+80H              ; 0xc8  <- 0xad
            DB      '*'+80H              ; 0xc9  <- 0xae
            DB      '/'+80H              ; 0xca  <- 0xaf
            DB      '^'+80H              ; 0xcb  <- 0xb0
            DB      'A'+80H,"ND"         ; 0xcc  <- 0xb1
            DB      'O'+80H,"R"          ; 0xcd  <- 0xb2
            DB      '>'+80H              ; 0xce  <- 0xb3
            DB      '='+80H              ; 0xcf  <- 0xb4
            DB      '<'+80H              ; 0xd0  <- 0xb5

            DB      'S'+80H,"GN"         ; 0xd1  <- 0xb6
            DB      'I'+80H,"NT"         ; 0xd2  <- 0xb7
            DB      'A'+80H,"BS"         ; 0xd3  <- 0xb8
            DB      'U'+80H,"SR"         ; 0xd4  <- 0xb9
            DB      'F'+80H,"RE"         ; 0xd5  <- 0xba
            DB      'I'+80H,"NP"         ; 0xd6  <- 0xbb
            DB      'P'+80H,"OS"         ; 0xd7  <- 0xbc
            DB      'S'+80H,"QR"         ; 0xd8  <- 0xbd
            DB      'R'+80H,"ND"         ; 0xd9  <- 0xbe
            DB      'L'+80H,"OG"         ; 0xda  <- 0xbf
            DB      'E'+80H,"XP"         ; 0xdb  <- 0xc0
            DB      'C'+80H,"OS"         ; 0xdc  <- 0xc1
            DB      'S'+80H,"IN"         ; 0xdd  <- 0xc2
            DB      'T'+80H,"AN"         ; 0xde  <- 0xc3
            DB      'A'+80H,"TN"         ; 0xdf  <- 0xc4
            DB      'P'+80H,"EEK"        ; 0xe0  <- 0xc5
            DB      'D'+80H,"EEK"        ; 0xe1  <- 0xc6
            DB      'P'+80H,"OINT"       ; 0xe2  <- 0xc7
            DB      'L'+80H,"EN"         ; 0xe3  <- 0xc8
            DB      'S'+80H,"TR$"        ; 0xe4  <- 0xc9
            DB      'V'+80H,"AL"         ; 0xe5  <- 0xca
            DB      'A'+80H,"SC"         ; 0xe6  <- 0xcb
            DB      'C'+80H,"HR$"        ; 0xe7  <- 0xcc
            DB      'H'+80H,"EX$"        ; 0xe8  <- 0xcd
            DB      'B'+80H,"IN$"        ; 0xe9  <- 0xce
            DB      'L'+80H,"EFT$"       ; 0xea  <- 0xcf
            DB      'R'+80H,"IGHT$"      ; 0xeb  <- 0xd0
            DB      'M'+80H,"ID$"        ; 0xec  <- 0xd1
            DB      80H                  ; End of list marker

            ; KEYWORD ADDRESS TABLE

WORDTB:     DW      PEND
            DW      FOR
            DW      NEXT
            DW      DATA
            DW      INPUT
            DW      DIM
            DW      READ
            DW      LET
            DW      GOTO
            DW      RUN
            DW      IF
            DW      RESTOR
            DW      GOSUB
            DW      RETURN
            DW      REM
            DW      STOP
            DW      POUT
            DW      ON
            DW      NULL
            DW      WAIT
            DW      DEF
            DW      POKE
            DW      DOKE
            DW      SCREEN
            DW      LINES
            DW      CLS
            DW      WIDTH
            DW      MONITR
            DW      PSET
            DW      RESET
            DW      PRINT
            DW      CONT
            DW      LIST
            DW      CLEAR
            DW      CLOAD               ; Load tokenised BASIC program.
            DW      CSAVE               ; Save tokenised BASIC program.
            DW      LOAD                ; Load ASCII text BASIC program.
            DW      SAVE                ; Save BASIC as ASCII text.
            DW      SETFREQ             ; Set the CPU Frequency.    
            DW      NEW

            ; RESERVED WORD TOKEN VALUES

ZEND        EQU    080H                 ; END    - ZEND marks the start of the table.
ZFOR        EQU    081H                 ; FOR
ZDATA       EQU    083H                 ; DATA
ZGOTO       EQU    088H                 ; GOTO
ZGOSUB      EQU    08CH                 ; GOSUB
ZREM        EQU    08EH                 ; REM
ZPRINT      EQU    09EH                 ; PRINT
ZNEW        EQU    0A7H                 ; NEW    - ZNEW marks the end of the table
                                        ; A8..BF are reserved for future commands.

            ; Space for expansion, a block of tokens for commands has been created from 0xA5 to 0xBF.

FUNCSTRT    EQU    0C0H                 ; Function start.
ZTAB        EQU    FUNCSTRT + 00H       ; 0A5H            ; TAB
ZTO         EQU    FUNCSTRT + 01H       ; 0A6H            ; TO
ZFN         EQU    FUNCSTRT + 02H       ; 0A7H            ; FN
ZSPC        EQU    FUNCSTRT + 03H       ; 0A8H            ; SPC
ZTHEN       EQU    FUNCSTRT + 04H       ; 0A9H            ; THEN
ZNOT        EQU    FUNCSTRT + 05H       ; 0AAH            ; NOT
ZSTEP       EQU    FUNCSTRT + 06H       ; 0ABH            ; STEP

ZPLUS       EQU    FUNCSTRT + 07H       ; 0ACH            ; +
ZMINUS      EQU    FUNCSTRT + 08H       ; 0ADH            ; -
ZTIMES      EQU    FUNCSTRT + 09H       ; 0AEH            ; *
ZDIV        EQU    FUNCSTRT + 0AH       ; 0AFH            ; /
                                        ; 0B0H
                                        ; 0B1H
ZOR         EQU    FUNCSTRT + 0dH       ; 0B2H            ; OR
ZGTR        EQU    FUNCSTRT + 0eH       ; 0B3H            ; >
ZEQUAL      EQU    FUNCSTRT + 0fH       ; 0B4H            ; M
ZLTH        EQU    FUNCSTRT + 10H       ; 0B5H            ; <
ZSGN        EQU    FUNCSTRT + 11H       ; 0B6H            ; SGN
                                        ; 0B7H
                                        ; 0B8H
                                        ; 0B9H
                                        ; 0BAH
                                        ; 0BBH
                                        ; 0BCH
                                        ; 0BDH
                                        ; 0BEH
                                        ; 0BFH
                                        ; 0C0H
                                        ; 0C1H
                                        ; 0C2H
                                        ; 0C3H
                                        ; 0C4H
                                        ; 0C5H
                                        ; 0C6H
ZPOINT      EQU    FUNCSTRT + 22H       ; 0C7H            ; POINT
                                        ; 0C8H
                                        ; 0C9H
                                        ; 0CAH
                                        ; 0CBH
                                        ; 0CCH
ZLEFT       EQU    FUNCSTRT + 2aH       ; 0CFH            ; LEFT$

            ; Space for expansion, reserve a block of tokens for functions.


            ; ARITHMETIC PRECEDENCE TABLE

PRITAB:     DB      79H                  ; Precedence value
            DW      PADD                 ; FPREG = <last> + FPREG

            DB      79H                  ; Precedence value
            DW      PSUB                 ; FPREG = <last> - FPREG

            DB      7CH                  ; Precedence value
            DW      MULT                 ; PPREG = <last> * FPREG

            DB      7CH                  ; Precedence value
            DW      DIV                  ; FPREG = <last> / FPREG

            DB      7FH                  ; Precedence value
            DW      POWER                ; FPREG = <last> ^ FPREG

            DB      50H                  ; Precedence value
            DW      PAND                 ; FPREG = <last> AND FPREG

            DB      46H                  ; Precedence value
            DW      POR                  ; FPREG = <last> OR FPREG

            ; BASIC ERROR CODE LIST

ERRORS:     DB      "NF"                 ; NEXT without FOR
            DB      "SN"                 ; Syntax error
            DB      "RG"                 ; RETURN without GOSUB
            DB      "OD"                 ; Out of DATA
            DB      "FC"                 ; Illegal function call
            DB      "OV"                 ; Overflow error
            DB      "OM"                 ; Out of memory
            DB      "UL"                 ; Undefined line
            DB      "BS"                 ; Bad subscript
            DB      "DD"                 ; Re-DIMensioned array
            DB      "/0"                 ; Division by zero
            DB      "ID"                 ; Illegal direct
            DB      "TM"                 ; Type mis-match
            DB      "OS"                 ; Out of string space
            DB      "LS"                 ; String too long
            DB      "ST"                 ; String formula too complex
            DB      "CN"                 ; Can't CONTinue
            DB      "UF"                 ; Undefined FN function
            DB      "MO"                 ; Missing operand
            DB      "HX"                 ; HEX error
            DB      "BN"                 ; BIN error

            ; INITIALISATION TABLE -------------------------------------------------------

INITAB:     JP      WARMST               ; Warm start jump
            JP      FCERR                ; "USR (X)" jump (Set to Error)

            OUT     (0),A                ; "OUT p,n" skeleton
            RET

            SUB     0                    ; Division support routine
            LD      L,A
            LD      A,H
            SBC     A,0
            LD      H,A
            LD      A,B
            SBC     A,0
            LD      B,A
            LD      A,0
            RET

            DB      0,0,0                ; Random number seed
                                         ; Table used by RND
            DB      035H,04AH,0CAH,099H  ;-2.65145E+07
            DB      039H,01CH,076H,098H  ; 1.61291E+07
            DB      022H,095H,0B3H,098H  ;-1.17691E+07
            DB      00AH,0DDH,047H,098H  ; 1.30983E+07
            DB      053H,0D1H,099H,099H  ;-2-01612E+07
            DB      00AH,01AH,09FH,098H  ;-1.04269E+07
            DB      065H,0BCH,0CDH,098H  ;-1.34831E+07
            DB      0D6H,077H,03EH,098H  ; 1.24825E+07
            DB      052H,0C7H,04FH,080H  ; Last random number

            IN      A,(0)                ; INP (x) skeleton
            RET

            DB      1                    ; POS (x) number (1)
            DB      80                   ; Terminal width (47)
            DB      28                   ; Width for commas (3 columns)
            DB      0                    ; No nulls after input bytes
            DB      0                    ; Output enabled (^O off)

            DW      20                   ; Initial lines counter
            DW      20                   ; Initial lines number
            DW      0                    ; Array load/save check sum

            DB      0                    ; Break not by NMI
            DB      0                    ; Break flag

            JP      TTYLIN               ; Input reflection (set to TTY)
            JP      0000H                ; POINT reflection unused
            JP      0000H                ; SET reflection
            JP      0000H                ; RESET reflection
           ;JP      POINTB               ; POINT reflection unused
           ;JP      SETB                 ; SET reflection
           ;JP      RESETB               ; RESET reflection

            DW      STLOOK               ; Temp string space
            DW      -2                   ; Current line number (cold)
            DW      PROGST+1             ; Start of program text
INITBE:                              ; END OF INITIALISATION TABLE

            ; END OF INITIALISATION TABLE ---------------------------------------------------

ERRMSG:     DB      " Error",0
INMSG:      DB      " in ",0
ZERBYT      EQU     $-1                  ; A zero byte
OKMSG:      DB      "Ok",CR,LF,0,0
BRKMSG:     DB      "Break",0

BAKSTK:     LD      HL,4                 ; Look for "FOR" block with
            ADD     HL,SP                ; same index as specified
LOKFOR:     LD      A,(HL)               ; Get block ID
            INC     HL                   ; Point to index address
            CP      ZFOR                 ; Is it a "FOR" token
            RET     NZ                   ; No - exit
            LD      C,(HL)               ; BC = Address of "FOR" index
            INC     HL
            LD      B,(HL)
            INC     HL                   ; Point to sign of STEP
            PUSH    HL                   ; Save pointer to sign
            LD      L,C                  ; HL = address of "FOR" index
            LD      H,B
            LD      A,D                  ; See if an index was specified
            OR      E                    ; DE = 0 if no index specified
            EX      DE,HL                ; Specified index into HL
            JP      Z,INDFND             ; Skip if no index given
            EX      DE,HL                ; Index back into DE
            CALL    CPDEHL               ; Compare index with one given
INDFND:     LD      BC,16-3              ; Offset to next block
            POP     HL                   ; Restore pointer to sign
            RET     Z                    ; Return if block found
            ADD     HL,BC                ; Point to next block
            JP      LOKFOR               ; Keep on looking

MOVUP:      CALL    ENFMEM               ; See if enough memory
MOVSTR:     PUSH    BC                   ; Save end of source
            EX      (SP),HL              ; Swap source and dest" end
            POP     BC                   ; Get end of destination
MOVLP:      CALL    CPDEHL               ; See if list moved
            LD      A,(HL)               ; Get byte
            LD      (BC),A               ; Move it
            RET     Z                    ; Exit if all done
            DEC     BC                   ; Next byte to move to
            DEC     HL                   ; Next byte to move
            JP      MOVLP                ; Loop until all bytes moved

CHKSTK:     PUSH    HL                   ; Save code string address
            LD      HL,(ARREND)          ; Lowest free memory
            LD      B,0                  ; BC = Number of levels to test
            ADD     HL,BC                ; 2 Bytes for each level
            ADD     HL,BC
            DB      3EH                  ; Skip "PUSH HL"
ENFMEM:     PUSH    HL                   ; Save code string address
            LD      A,0D0H ;LOW -48      ; 48 Bytes minimum RAM
            SUB     L
            LD      L,A
            LD      A,0FFH               ; HIGH (-48) ; 48 Bytes minimum RAM
            SBC     A,H
            JP      C,OMERR              ; Not enough - ?OM Error
            LD      H,A
            ADD     HL,SP                ; Test if stack is overflowed
            POP     HL                   ; Restore code string address
            RET     C                    ; Return if enough mmory
OMERR:      LD      E,OM                 ; ?OM Error
            JP      BERROR

DATSNR:     LD      HL,(DATLIN)          ; Get line of current DATA item
            LD      (LINEAT),HL          ; Save as current line
SNERR:      LD      E,SN                 ; ?SN Error
            DB      01H                  ; Skip "LD E,DZ"
DZERR:      LD      E,DZ                 ; ?/0 Error
            DB      01H                  ; Skip "LD E,NF"
NFERR:      LD      E,NF                 ; ?NF Error
            DB      01H                  ; Skip "LD E,DD"
DDERR:      LD      E,DDA                ; ?DD Error
            DB      01H                  ; Skip "LD E,UF"
UFERR:      LD      E,UF                 ; ?UF Error
            DB      01H                  ; Skip "LD E,OV
OVERR:      LD      E,OV                 ; ?OV Error
            DB      01H                  ; Skip "LD E,TM"
TMERR:      LD      E,TM                 ; ?TM Error

BERROR:     CALL    CLREG                ; Clear registers and stack
            LD      (CTLOFG),A           ; Enable output (A is 0)
            CALL    STTLIN               ; Start new line
            LD      HL,ERRORS            ; Point to error codes
            LD      D,A                  ; D = 0 (A is 0)
            LD      A,'?'
            CALL    OUTC                 ; Output '?'
            ADD     HL,DE                ; Offset to correct error code
            LD      A,(HL)               ; First character
            CALL    OUTC                 ; Output it
            CALL    GETCHR               ; Get next character
            CALL    OUTC                 ; Output it
            LD      HL,ERRMSG            ; "Error" message
ERRIN:      CALL    PRS                  ; Output message
            LD      HL,(LINEAT)          ; Get line of error
            LD      DE,-2                ; Cold start error if -2
            CALL    CPDEHL               ; See if cold start error
            JP      Z,CSTART             ; Cold start error - Restart
            LD      A,H                  ; Was it a direct error?
            AND     L                    ; Line = -1 if direct error
            INC     A
            CALL    NZ,LINEIN            ; No - output line of error
            DB      3EH                  ; Skip "POP BC"
POPNOK:     POP     BC                   ; Drop address in input buffer

PRNTOK:     XOR     A                    ; Output "Ok" and get command
            LD      (CTLOFG),A           ; Enable output
            CALL    STTLIN               ; Start new line
            LD      HL,OKMSG             ; "Ok" message
            CALL    PRS                  ; Output "Ok"
GETCMD:     LD      HL,-1                ; Flag direct mode
            LD      (LINEAT),HL          ; Save as current line
            CALL    GETLIN               ; Get an input line
            JP      C,GETCMD             ; Get line again if break
            CALL    GETCHR               ; Get first character
            INC     A                    ; Test if end of line
            DEC     A                    ; Without affecting Carry
            JP      Z,GETCMD             ; Nothing entered - Get another
            PUSH    AF                   ; Save Carry status
            CALL    ATOH                 ; Get line number into DE
            PUSH    DE                   ; Save line number
            CALL    CRUNCH               ; Tokenise rest of line
            LD      B,A                  ; Length of tokenised line -> length is in C, B is zeroed.
            POP     DE                   ; Restore line number
            POP     AF                   ; Restore Carry
            JP      NC,EXCUTE            ; No line number - Direct mode
            PUSH    DE                   ; Save line number
            PUSH    BC                   ; Save length of tokenised line
            XOR     A
            LD      (LSTBIN),A           ; Clear last byte input
            CALL    GETCHR               ; Get next character
            OR      A                    ; Set flags
            PUSH    AF                   ; And save them
            CALL    SRCHLN               ; Search for line number in DE
            JP      C,LINFND             ; Jump if line found
            POP     AF                   ; Get status
            PUSH    AF                   ; And re-save
            JP      Z,ULERR              ; Nothing after number - Error
            OR      A                    ; Clear Carry
LINFND:     PUSH    BC                   ; Save address of line in prog
            JP      NC,INEWLN            ; Line not found - Insert new
            EX      DE,HL                ; Next line address in DE
            LD      HL,(PROGND)          ; End of program
SFTPRG:     LD      A,(DE)               ; Shift rest of program down
            LD      (BC),A
            INC     BC                   ; Next destination
            INC     DE                   ; Next source
            CALL    CPDEHL               ; All done?
            JP      NZ,SFTPRG            ; More to do
            LD      H,B                  ; HL - New end of program
            LD      L,C
            LD      (PROGND),HL          ; Update end of program

INEWLN:     POP     DE                   ; Get address of line,
            POP     AF                   ; Get status
            JP      Z,SETPTR             ; No text - Set up pointers
            LD      HL,(PROGND)          ; Get end of program
            EX      (SP),HL              ; Get length of input line
            POP     BC                   ; End of program to BC
            ADD     HL,BC                ; Find new end
            PUSH    HL                   ; Save new end
            CALL    MOVUP                ; Make space for line
            POP     HL                   ; Restore new end
            LD      (PROGND),HL          ; Update end of program pointer
            EX      DE,HL                ; Get line to move up in HL
            LD      (HL),H               ; Save MSB
            POP     DE                   ; Get new line number
            INC     HL                   ; Skip pointer
            INC     HL
            LD      (HL),E               ; Save LSB of line number
            INC     HL
            LD      (HL),D               ; Save MSB of line number
            INC     HL                   ; To first byte in line
            LD      DE,BUFFER            ; Copy buffer to program
MOVBUF:     LD      A,(DE)               ; Get source
            LD      (HL),A               ; Save destinations
            INC     HL                   ; Next source
            INC     DE                   ; Next destination
            OR      A                    ; Done?
            JP      NZ,MOVBUF            ; No - Repeat
SETPTR:     CALL    RUNFST               ; Set line pointers
            INC     HL                   ; To LSB of pointer
            EX      DE,HL                ; Address to DE
PTRLP:      LD      H,D                  ; Address to HL
            LD      L,E
            LD      A,(HL)               ; Get LSB of pointer
            INC     HL                   ; To MSB of pointer
            OR      (HL)                 ; Compare with MSB pointer
            JP      Z,GETCMD             ; Get command line if end
            INC     HL                   ; To LSB of line number
            INC     HL                   ; Skip line number
            INC     HL                   ; Point to first byte in line
            XOR     A                    ; Looking for 00 byte
FNDEND:     CP      (HL)                 ; Found end of line?
            INC     HL                   ; Move to next byte
            JP      NZ,FNDEND            ; No - Keep looking
            EX      DE,HL                ; Next line address to HL
            LD      (HL),E               ; Save LSB of pointer
            INC     HL
            LD      (HL),D               ; Save MSB of pointer
            JP      PTRLP                ; Do next line

SRCHLN:     LD      HL,(BASTXT)          ; Start of program text
SRCHLP:     LD      B,H                  ; BC = Address to look at
            LD      C,L
            LD      A,(HL)               ; Get address of next line
            INC     HL
            OR      (HL)                 ; End of program found?
            DEC     HL
            RET     Z                    ; Yes - Line not found
            INC     HL
            INC     HL
            LD      A,(HL)               ; Get LSB of line number
            INC     HL
            LD      H,(HL)               ; Get MSB of line number
            LD      L,A
            CALL    CPDEHL               ; Compare with line in DE
            LD      H,B                  ; HL = Start of this line
            LD      L,C
            LD      A,(HL)               ; Get LSB of next line address
            INC     HL
            LD      H,(HL)               ; Get MSB of next line address
            LD      L,A                  ; Next line to HL
            CCF
            RET     Z                    ; Lines found - Exit
            CCF
            RET     NC                   ; Line not found,at line after
            JP      SRCHLP               ; Keep looking

NEW:        RET     NZ                   ; Return if any more on line
CLRPTR:     LD      HL,(BASTXT)          ; Point to start of program
            XOR     A                    ; Set program area to empty
            LD      (HL),A               ; Save LSB = 00
            INC     HL
            LD      (HL),A               ; Save MSB = 00
            INC     HL
            LD      (PROGND),HL          ; Set program end

RUNFST:     LD      HL,(BASTXT)          ; Clear all variables
            DEC     HL

INTVAR:     LD      (BRKLIN),HL          ; Initialise RUN variables
            LD      HL,(LSTRAM)          ; Get end of RAM
            LD      (STRBOT),HL          ; Clear string space
            XOR     A
            CALL    RESTOR               ; Reset DATA pointers
            LD      HL,(PROGND)          ; Get end of program
            LD      (VAREND),HL          ; Clear variables
            LD      (ARREND),HL          ; Clear arrays

CLREG:      POP     BC                   ; Save return address
            LD      HL,(STRSPC)          ; Get end of working RAN
            LD      SP,HL                ; Set stack
            LD      HL,TMSTPL            ; Temporary string pool
            LD      (TMSTPT),HL          ; Reset temporary string ptr
            XOR     A                    ; A = 00
            LD      L,A                  ; HL = 0000
            LD      H,A
            LD      (CONTAD),HL          ; No CONTinue
            LD      (FORFLG),A           ; Clear FOR flag
            LD      (FNRGNM),HL          ; Clear FN argument
            PUSH    HL                   ; HL = 0000
            PUSH    BC                   ; Put back return
DOAGN:      LD      HL,(BRKLIN)          ; Get address of code to RUN
            RET                          ; Return to execution driver

PROMPT:     LD      A,'?'                ; '?'
            CALL    OUTC                 ; Output character
            LD      A,' '                ; Space
            CALL    OUTC                 ; Output character
            JP      RINPUT               ; Get input line

CRUNCH:     XOR     A                    ; Tokenise line @ HL to BUFFER
            LD      (DATFLG),A           ; Reset literal flag
            LD      C,2+3                ; 2 byte number and 3 nulls
            LD      DE,BUFFER            ; Start of input buffer
CRNCLP:     LD      A,(HL)               ; Get byte
            CP      ' '                  ; Is it a space?
            JP      Z,MOVDIR             ; Yes - Copy direct
            LD      B,A                  ; Save character
            CP      '"'                  ; Is it a quote?
            JP      Z,CPYLIT             ; Yes - Copy literal string
            OR      A                    ; Is it end of buffer?
            JP      Z,ENDBUF             ; Yes - End buffer
            LD      A,(DATFLG)           ; Get data type
            OR      A                    ; Literal?
            LD      A,(HL)               ; Get byte to copy
            JP      NZ,MOVDIR            ; Literal - Copy direct
            CP      '?'                  ; Is it '?' short for PRINT
            LD      A,ZPRINT             ; "PRINT" token
            JP      Z,MOVDIR             ; Yes - replace it
            LD      A,(HL)               ; Get byte again
            CP      '0'                  ; Is it less than '0'
            JP      C,FNDWRD             ; Yes - Look for reserved words
            CP      60; ";"+1            ; Is it "0123456789:;" ?
            JP      C,MOVDIR             ; Yes - copy it direct
FNDWRD:     PUSH    DE                   ; Look for reserved words
            LD      DE,WORDS-1           ; Point to table
            PUSH    BC                   ; Save count
            LD      BC,RETNAD            ; Where to return to
            PUSH    BC                   ; Save return address
            LD      B,ZEND-1             ; First token value -1
            LD      A,(HL)               ; Get byte
            CP      'a'                  ; Less than 'a' ?
            JP      C,SEARCH             ; Yes - search for words
            CP      'z'+1                ; Greater than 'z' ?
            JP      NC,SEARCH            ; Yes - search for words
            AND     01011111B            ; Force upper case
            LD      (HL),A               ; Replace byte
SEARCH:     LD      C,(HL)               ; Search for a word
            EX      DE,HL
GETNXT:     INC     HL                   ; Get next reserved word
            OR      (HL)                 ; Start of word?
            JP      P,GETNXT             ; No - move on
            INC     B                    ; Increment token value
            LD      A, (HL)              ; Get byte from table
            AND     01111111B            ; Strip bit 7
            RET     Z                    ; Return if end of list
            CP      C                    ; Same character as in buffer?
            JP      NZ,GETNXT            ; No - get next word
            EX      DE,HL
            PUSH    HL                   ; Save start of word

NXTBYT:     INC     DE                   ; Look through rest of word
            LD      A,(DE)               ; Get byte from table
            OR      A                    ; End of word ?
            JP      M,MATCH              ; Yes - Match found
            LD      C,A                  ; Save it
            LD      A,B                  ; Get token value
            CP      ZGOTO                ; Is it "GOTO" token ?
            JP      NZ,NOSPC             ; No - Don't allow spaces
            CALL    GETCHR               ; Get next character
            DEC     HL                   ; Cancel increment from GETCHR
NOSPC:      INC     HL                   ; Next byte
            LD      A,(HL)               ; Get byte
            CP      'a'                  ; Less than 'a' ?
            JP      C,NOCHNG             ; Yes - don't change
            AND     01011111B            ; Make upper case
NOCHNG:     CP      C                    ; Same as in buffer ?
            JP      Z,NXTBYT             ; Yes - keep testing
            POP     HL                   ; Get back start of word
            JP      SEARCH               ; Look at next word

MATCH:      LD      C,B                  ; Word found - Save token value
            POP     AF                   ; Throw away return
            EX      DE,HL
            RET                          ; Return to "RETNAD"
RETNAD:     EX      DE,HL                ; Get address in string
            LD      A,C                  ; Get token value
            POP     BC                   ; Restore buffer length
            POP     DE                   ; Get destination address
MOVDIR:     INC     HL                   ; Next source in buffer
            LD      (DE),A               ; Put byte in buffer
            INC     DE                   ; Move up buffer
            INC     C                    ; Increment length of buffer
            SUB     ':'                  ; End of statement?
            JP      Z,SETLIT             ; Jump if multi-statement line
            CP      ZDATA-3AH            ; Is it DATA statement ?
            JP      NZ,TSTREM            ; No - see if REM
SETLIT:     LD      (DATFLG),A           ; Set literal flag
TSTREM:     SUB     ZREM-3AH             ; Is it REM?
            JP      NZ,CRNCLP            ; No - Leave flag
            LD      B,A                  ; Copy rest of buffer
NXTCHR:     LD      A,(HL)               ; Get byte
            OR      A                    ; End of line ?
            JP      Z,ENDBUF             ; Yes - Terminate buffer
            CP      B                    ; End of statement ?
            JP      Z,MOVDIR             ; Yes - Get next one
CPYLIT:     INC     HL                   ; Move up source string
            LD      (DE),A               ; Save in destination
            INC     C                    ; Increment length
            INC     DE                   ; Move up destination
            JP      NXTCHR               ; Repeat

ENDBUF:     LD      HL,BUFFER-1          ; Point to start of buffer
            LD      (DE),A               ; Mark end of buffer (A = 00)
            INC     DE
            LD      (DE),A               ; A = 00
            INC     DE
            LD      (DE),A               ; A = 00
            RET

DODEL:      LD      A,(NULFLG)           ; Get null flag status
            OR      A                    ; Is it zero?
            LD      A,0                  ; Zero A - Leave flags
            LD      (NULFLG),A           ; Zero null flag
            JP      NZ,ECHDEL            ; Set - Echo it
            DEC     B                    ; Decrement length
            JP      Z,GETLIN             ; Get line again if empty
            CALL    OUTC                 ; Output null character
            DB      3EH                  ; Skip "DEC B"
ECHDEL:     DEC     B                    ; Count bytes in buffer
            DEC     HL                   ; Back space buffer
            JP      Z,OTKLN              ; No buffer - Try again
            LD      A,(HL)               ; Get deleted byte
            CALL    OUTC                 ; Echo it
            JP      MORINP               ; Get more input

DELCHR:     DEC     B                    ; Count bytes in buffer
            DEC     HL                   ; Back space buffer
            CALL    OUTC                 ; Output character in A
            JP      NZ,MORINP            ; Not end - Get more
OTKLN:      CALL    OUTC                 ; Output character in A
KILIN:      CALL    PRNTCRLF             ; Output CRLF
            JP      TTYLIN               ; Get line again

GETLIN:
TTYLIN:     LD      HL,BUFFER            ; Get a line by character
            LD      B,1                  ; Set buffer as empty
            XOR     A
            LD      (NULFLG),A           ; Clear null flag
MORINP:     CALL    CLOTST               ; Get character and test ^O
            LD      C,A                  ; Save character in C
            CP      DELETE               ; Delete character?
            JP      Z,DODEL              ; Yes - Process it
            LD      A,(NULFLG)           ; Get null flag
            OR      A                    ; Test null flag status
            JP      Z,PROCES             ; Reset - Process character
            LD      A,0                  ; Set a null
            CALL    OUTC                 ; Output null
            XOR     A                    ; Clear A
            LD      (NULFLG),A           ; Reset null flag
PROCES:     LD      A,C                  ; Get character
            CP      CTRL_G               ; Bell?
            JP      Z,PUTCTL             ; Yes - Save it
            CP      CTRL_C               ; Is it control "C"?
            CALL    Z,PRNTCRLF           ; Yes - Output CRLF
            SCF                          ; Flag break
            RET     Z                    ; Return if control "C"
            CP      CR                   ; Is it enter?
            JP      Z,ENDINP             ; Yes - Terminate input
            CP      CTRL_U               ; Is it control "U"?
            JP      Z,KILIN              ; Yes - Get another line
            CP      '@'                  ; Is it "kill line"?
            JP      Z,OTKLN              ; Yes - Kill line
            CP      DELETE               ; Is it delete?
            JP      Z,DELCHR             ; Yes - Delete character
            CP      BACKS                ; Is it backspace?
            JP      Z,DELCHR             ; Yes - Delete character
            CP      CTRL_R               ; Is it control "R"?
            JP      NZ,PUTBUF            ; No - Put in buffer
            PUSH    BC                   ; Save buffer length
            PUSH    DE                   ; Save DE
            PUSH    HL                   ; Save buffer address
            LD      (HL),0               ; Mark end of buffer
            CALL    OUTNCR               ; Output and do CRLF
            LD      HL,BUFFER            ; Point to buffer start
            CALL    PRS                  ; Output buffer
            POP     HL                   ; Restore buffer address
            POP     DE                   ; Restore DE
            POP     BC                   ; Restore buffer length
            JP      MORINP               ; Get another character

PUTBUF:     CP      ' '                  ; Is it a control code?
            JP      C,MORINP             ; Yes - Ignore
PUTCTL:     LD      A,B                  ; Get number of bytes in buffer
            CP      72+1                 ; Test for line overflow
            LD      A,CTRL_G             ; Set a bell
            JP      NC,OUTNBS            ; Ring bell if buffer full
            LD      A,C                  ; Get character
            LD      (HL),C               ; Save in buffer
            LD      (LSTBIN),A           ; Save last input byte
            INC     HL                   ; Move up buffer
            INC     B                    ; Increment length
OUTIT:      CALL    OUTC                 ; Output the character entered
            JP      MORINP               ; Get another character

OUTNBS:     CALL    OUTC                 ; Output bell and back over it
            LD      A,BACKS              ; Set back space
            JP      OUTIT                ; Output it and get more

CPDEHL:     LD      A,H                  ; Get H
            SUB     D                    ; Compare with D
            RET     NZ                   ; Different - Exit
            LD      A,L                  ; Get L
            SUB     E                    ; Compare with E
            RET                          ; Return status

CHKSYN:     LD      A,(HL)               ; Check syntax of character
            EX      (SP),HL              ; Address of test byte
            CP      (HL)                 ; Same as in code string?
            INC     HL                   ; Return address
            EX      (SP),HL              ; Put it back
            JP      Z,GETCHR             ; Yes - Get next character
            JP      SNERR                ; Different - ?SN Error

OUTC:       PUSH    AF                   ; Save character
            LD      A,(CTLOFG)           ; Get control "O" flag
            OR      A                    ; Is it set?
            JP      NZ,POPAF             ; Yes - don't output
            POP     AF                   ; Restore character
            PUSH    BC                   ; Save buffer length
            PUSH    AF                   ; Save character
            CP      ' '                  ; Is it a control code?
            JP      C,DINPOS             ; Yes - Don't INC POS(X)
            LD      A,(LWIDTH)           ; Get line width
            LD      B,A                  ; To B
            LD      A,(CURPOS)           ; Get cursor position
            INC     B                    ; Width 255?
            JP      Z,INCLEN             ; Yes - No width limit
            DEC     B                    ; Restore width
            CP      B                    ; At end of line?
            CALL    Z,PRNTCRLF           ; Yes - output CRLF
INCLEN:     INC     A                    ; Move on one character
            LD      (CURPOS),A           ; Save new position
DINPOS:     POP     AF                   ; Restore character
            POP     BC                   ; Restore buffer length
ANSIINC:    IF INCLUDE_ANSITERM = 1
            CALL    ANSITERM             ; Send it via the Ansi processor.
            ELSE
            CALL    PRNT                 ; Send it .
            ENDIF
            RET

CLOTST:     CALL    GETKY                ; Get input character
            AND     01111111B            ; Strip bit 7
            CP      CTRL_O               ; Is it control "O"?
            RET     NZ                   ; No don't flip flag
            LD      A,(CTLOFG)           ; Get flag
            CPL                          ; Flip it
            LD      (CTLOFG),A           ; Put it back
            XOR     A                    ; Null character
            RET

LIST:       CALL    ATOH                 ; ASCII number to DE
            RET     NZ                   ; Return if anything extra
            POP     BC                   ; Rubbish - Not needed
            CALL    SRCHLN               ; Search for line number in DE
            PUSH    BC                   ; Save address of line
            CALL    SETLIN               ; Set up lines counter
LISTLP:     POP     HL                   ; Restore address of line
            LD      C,(HL)               ; Get LSB of next line
            INC     HL
            LD      B,(HL)               ; Get MSB of next line
            INC     HL
            LD      A,B                  ; BC = 0 (End of program)?
            OR      C
            JP      Z,PRNTOK             ; Yes - Go to command mode
            CALL    COUNT                ; Count lines
            CALL    TSTBRK               ; Test for break key
            PUSH    BC                   ; Save address of next line
            CALL    PRNTCRLF             ; Output CRLF
            LD      E,(HL)               ; Get LSB of line number
            INC     HL
            LD      D,(HL)               ; Get MSB of line number
            INC     HL
            PUSH    HL                   ; Save address of line start
            EX      DE,HL                ; Line number to HL
            CALL    PRNTHL               ; Output line number in decimal
            LD      A,' '                ; Space after line number
            POP     HL                   ; Restore start of line address
LSTLP2:     CALL    OUTC                 ; Output character in A
LSTLP3:     LD      A,(HL)               ; Get next byte in line
            OR      A                    ; End of line?
            INC     HL                   ; To next byte in line
            JP      Z,LISTLP             ; Yes - get next line
            JP      P,LSTLP2             ; No token - output it
            SUB     ZEND-1               ; Find and output word
            LD      C,A                  ; Token offset+1 to C
            LD      DE,WORDS             ; Reserved word list
FNDTOK:     LD      A,(DE)               ; Get character in list
            INC     DE                   ; Move on to next
            OR      A                    ; Is it start of word?
            JP      P,FNDTOK             ; No - Keep looking for word
            DEC     C                    ; Count words
            JP      NZ,FNDTOK            ; Not there - keep looking
OUTWRD:     AND     01111111B            ; Strip bit 7
            CALL    OUTC                 ; Output first character
            LD      A,(DE)               ; Get next character
            INC     DE                   ; Move on to next
            OR      A                    ; Is it end of word?
            JP      P,OUTWRD             ; No - output the rest
            JP      LSTLP3               ; Next byte in line

SETLIN:     PUSH    HL                   ; Set up LINES counter
            LD      HL,(LINESN)          ; Get LINES number
            LD      (LINESC),HL          ; Save in LINES counter
            POP     HL
            RET

COUNT:      PUSH    HL                   ; Save code string address
            PUSH    DE
            LD      HL,(LINESC)          ; Get LINES counter
            LD      DE,-1
            ADC     HL,DE                ; Decrement
            LD      (LINESC),HL          ; Put it back
            POP     DE
            POP     HL                   ; Restore code string address
            RET     P                    ; Return if more lines to go
            PUSH    HL                   ; Save code string address
            LD      HL,(LINESN)          ; Get LINES number
            LD      (LINESC),HL          ; Reset LINES counter
            CALL    GETKY                ; Get input character
            CP      CTRL_C               ; Is it control "C"?
            JP      Z,RSLNBK             ; Yes - Reset LINES and break
            POP     HL                   ; Restore code string address
            JP      COUNT                ; Keep on counting

RSLNBK:     LD      HL,(LINESN)          ; Get LINES number
            LD      (LINESC),HL          ; Reset LINES counter
            JP      BRKRET               ; Go and output "Break"

FOR:        LD      A,64H                ; Flag "FOR" assignment
            LD      (FORFLG),A           ; Save "FOR" flag
            CALL    LET                  ; Set up initial index
            POP     BC                   ; Drop RETurn address
            PUSH    HL                   ; Save code string address
            CALL    DATA                 ; Get next statement address
            LD      (LOOPST),HL          ; Save it for start of loop
            LD      HL,2                 ; Offset for "FOR" block
            ADD     HL,SP                ; Point to it
FORSLP:     CALL    LOKFOR               ; Look for existing "FOR" block
            POP     DE                   ; Get code string address
            JP      NZ,FORFND            ; No nesting found
            ADD     HL,BC                ; Move into "FOR" block
            PUSH    DE                   ; Save code string address
            DEC     HL
            LD      D,(HL)               ; Get MSB of loop statement
            DEC     HL
            LD      E,(HL)               ; Get LSB of loop statement
            INC     HL
            INC     HL
            PUSH    HL                   ; Save block address
            LD      HL,(LOOPST)          ; Get address of loop statement
            CALL    CPDEHL               ; Compare the FOR loops
            POP     HL                   ; Restore block address
            JP      NZ,FORSLP            ; Different FORs - Find another
            POP     DE                   ; Restore code string address
            LD      SP,HL                ; Remove all nested loops

FORFND:     EX      DE,HL                ; Code string address to HL
            LD      C,8
            CALL    CHKSTK               ; Check for 8 levels of stack
            PUSH    HL                   ; Save code string address
            LD      HL,(LOOPST)          ; Get first statement of loop
            EX      (SP),HL              ; Save and restore code string
            PUSH    HL                   ; Re-save code string address
            LD      HL,(LINEAT)          ; Get current line number
            EX      (SP),HL              ; Save and restore code string
            CALL    TSTNUM               ; Make sure it's a number
            CALL    CHKSYN               ; Make sure "TO" is next
            DB      ZTO                  ; "TO" token
            CALL    GETNUM               ; Get "TO" expression value
            PUSH    HL                   ; Save code string address
            CALL    BCDEFP               ; Move "TO" value to BCDE
            POP     HL                   ; Restore code string address
            PUSH    BC                   ; Save "TO" value in block
            PUSH    DE
            LD      BC,8100H             ; BCDE - 1 (default STEP)
            LD      D,C                  ; C=0
            LD      E,D                  ; D=0
            LD      A,(HL)               ; Get next byte in code string
            CP      ZSTEP                ; See if "STEP" is stated
            LD      A,1                  ; Sign of step = 1
            JP      NZ,SAVSTP            ; No STEP given - Default to 1
            CALL    GETCHR               ; Jump over "STEP" token
            CALL    GETNUM               ; Get step value
            PUSH    HL                   ; Save code string address
            CALL    BCDEFP               ; Move STEP to BCDE
            CALL    TSTSGN               ; Test sign of FPREG
            POP     HL                   ; Restore code string address
SAVSTP:     PUSH    BC                   ; Save the STEP value in block
            PUSH    DE
            PUSH    AF                   ; Save sign of STEP
            INC     SP                   ; Don't save flags
            PUSH    HL                   ; Save code string address
            LD      HL,(BRKLIN)          ; Get address of index variable
            EX      (SP),HL              ; Save and restore code string
PUTFID:     LD      B,ZFOR               ; "FOR" block marker
            PUSH    BC                   ; Save it
            INC     SP                   ; Don't save C

RUNCNT:     CALL    TSTBRK               ; Execution driver - Test break
            LD      (BRKLIN),HL          ; Save code address for break
            LD      A,(HL)               ; Get next byte in code string
            CP      ':'                  ; Multi statement line?
            JP      Z,EXCUTE             ; Yes - Execute it
            OR      A                    ; End of line?
            JP      NZ,SNERR             ; No - Syntax error
            INC     HL                   ; Point to address of next line
            LD      A,(HL)               ; Get LSB of line pointer
            INC     HL
            OR      (HL)                 ; Is it zero (End of prog)?
            JP      Z,ENDPRG             ; Yes - Terminate execution
            INC     HL                   ; Point to line number
            LD      E,(HL)               ; Get LSB of line number
            INC     HL
            LD      D,(HL)               ; Get MSB of line number
            EX      DE,HL                ; Line number to HL
            LD      (LINEAT),HL          ; Save as current line number
            EX      DE,HL                ; Line number back to DE
EXCUTE:     CALL    GETCHR               ; Get key word
            LD      DE,RUNCNT            ; Where to RETurn to
            PUSH    DE                   ; Save for RETurn
IFJMP:      RET     Z                    ; Go to RUNCNT if end of STMT
ONJMP:      SUB     ZEND                 ; Is it a token?
            JP      C,LET                ; No - try to assign it
            CP      ZNEW+1-ZEND          ; END to NEW ?
            JP      NC,SNERR             ; Not a key word - ?SN Error
            RLCA                         ; Double it
            LD      C,A                  ; BC = Offset into table
            LD      B,0
            EX      DE,HL                ; Save code string address
            LD      HL,WORDTB            ; Keyword address table
            ADD     HL,BC                ; Point to routine address
            LD      C,(HL)               ; Get LSB of routine address
            INC     HL
            LD      B,(HL)               ; Get MSB of routine address
            PUSH    BC                   ; Save routine address
            EX      DE,HL                ; Restore code string address

GETCHR:     INC     HL                   ; Point to next character
            LD      A,(HL)               ; Get next code string byte
            CP      ':'                  ; Z if ':'
            RET     NC                   ; NC if > "9"
            CP      ' '
            JP      Z,GETCHR             ; Skip over spaces
            CP      '0'
            CCF                          ; NC if < '0'
            INC     A                    ; Test for zero - Leave carry
            DEC     A                    ; Z if Null
            RET

RESTOR:     EX      DE,HL                ; Save code string address
            LD      HL,(BASTXT)          ; Point to start of program
            JP      Z,RESTNL             ; Just RESTORE - reset pointer
            EX      DE,HL                ; Restore code string address
            CALL    ATOH                 ; Get line number to DE
            PUSH    HL                   ; Save code string address
            CALL    SRCHLN               ; Search for line number in DE
            LD      H,B                  ; HL = Address of line
            LD      L,C
            POP     DE                   ; Restore code string address
            JP      NC,ULERR             ; ?UL Error if not found
RESTNL:     DEC     HL                   ; Byte before DATA statement
UPDATA:     LD      (NXTDAT),HL          ; Update DATA pointer
            EX      DE,HL                ; Restore code string address
            RET

TSTBRK:     CALL    CHKKY                ; Check input status
            OR      A
            RET     Z                    ; No key, go back
            CALL    GETKY                ; Get the key into A
            CP      ESC                  ; Escape key?
            JR      Z,BRK                ; Yes, break
            CP      CTRL_C               ; <Ctrl-C>
            JR      Z,BRK                ; Yes, break
            CP      CTRL_S               ; Stop scrolling?
            RET     NZ                   ; Other key, ignore


STALL:      CALL    GETKY                ; Wait for key
            CP      CTRL_Q               ; Resume scrolling?
            RET      Z                   ; Release the chokehold
            CP      CTRL_C               ; Second break?
            JR      Z,STOP               ; Break during hold exits prog
            JR      STALL                ; Loop until <Ctrl-Q> or <brk>

BRK         LD      A,0FFH               ; Set BRKFLG
            LD      (BRKFLG),A           ; Store it


STOP:       RET     NZ                   ; Exit if anything else
            DB      0F6H                 ; Flag "STOP"
PEND:       RET     NZ                   ; Exit if anything else
            LD      (BRKLIN),HL          ; Save point of break
            DB      21H                  ; Skip "OR 11111111B"
INPBRK:     OR      11111111B            ; Flag "Break" wanted
            POP     BC                   ; Return not needed and more
ENDPRG:     LD      HL,(LINEAT)          ; Get current line number
            PUSH    AF                   ; Save STOP / END status
            LD      A,L                  ; Is it direct break?
            AND     H
            INC     A                    ; Line is -1 if direct break
            JP      Z,NOLIN              ; Yes - No line number
            LD      (ERRLIN),HL          ; Save line of break
            LD      HL,(BRKLIN)          ; Get point of break
            LD      (CONTAD),HL          ; Save point to CONTinue
NOLIN:      XOR     A
            LD      (CTLOFG),A           ; Enable output
            CALL    STTLIN               ; Start a new line
            POP     AF                   ; Restore STOP / END status
            LD      HL,BRKMSG            ; "Break" message
            JP      NZ,ERRIN             ; "in line" wanted?
            JP      PRNTOK               ; Go to command mode

CONT:       LD      HL,(CONTAD)          ; Get CONTinue address
            LD      A,H                  ; Is it zero?
            OR      L
            LD      E,CN                 ; ?CN Error
            JP      Z,BERROR             ; Yes - output "?CN Error"
            EX      DE,HL                ; Save code string address
            LD      HL,(ERRLIN)          ; Get line of last break
            LD      (LINEAT),HL          ; Set up current line number
            EX      DE,HL                ; Restore code string address
            RET                          ; CONTinue where left off

NULL:       CALL    GETINT               ; Get integer 0-255
            RET     NZ                   ; Return if bad value
            LD      (NULLS),A            ; Set nulls number
            RET


ACCSUM:     PUSH    HL                   ; Save address in array
            LD      HL,(CHKSUM)          ; Get check sum
            LD      B,0                  ; BC - Value of byte
            LD      C,A
            ADD     HL,BC                ; Add byte to check sum
            LD      (CHKSUM),HL          ; Re-save check sum
            POP     HL                   ; Restore address in array
            RET

CHKLTR:     LD      A,(HL)               ; Get byte
            CP      'A'                  ; < 'a' ?
            RET     C                    ; Carry set if not letter
            CP      'Z'+1                ; > 'z' ?
            CCF
            RET                          ; Carry set if not letter

FPSINT:     CALL    GETCHR               ; Get next character
POSINT:     CALL    GETNUM               ; Get integer 0 to 32767
DEPINT:     CALL    TSTSGN               ; Test sign of FPREG
            JP      M,FCERR              ; Negative - ?FC Error
DEINT:      LD      A,(FPEXP)            ; Get integer value to DE
            CP      80H+16               ; Exponent in range (16 bits)?
            JP      C,FPINT              ; Yes - convert it
            LD      BC,9080H             ; BCDE = -32768
            LD      DE,0000
            PUSH    HL                   ; Save code string address
            CALL    CMPNUM               ; Compare FPREG with BCDE
            POP     HL                   ; Restore code string address
            LD      D,C                  ; MSB to D
            RET     Z                    ; Return if in range
FCERR:      LD      E,FC                 ; ?FC Error
            JP      BERROR               ; Output error-

ATOH:       DEC     HL                   ; ASCII number to DE binary
GETLN:      LD      DE,0                 ; Get number to DE
GTLNLP:     CALL    GETCHR               ; Get next character
            RET     NC                   ; Exit if not a digit
            PUSH    HL                   ; Save code string address
            PUSH    AF                   ; Save digit
            LD      HL,65529/10          ; Largest number 65529
            CALL    CPDEHL               ; Number in range?
            JP      C,SNERR              ; No - ?SN Error
            LD      H,D                  ; HL = Number
            LD      L,E
            ADD     HL,DE                ; Times 2
            ADD     HL,HL                ; Times 4
            ADD     HL,DE                ; Times 5
            ADD     HL,HL                ; Times 10
            POP     AF                   ; Restore digit
            SUB     '0'                  ; Make it 0 to 9
            LD      E,A                  ; DE = Value of digit
            LD      D,0
            ADD     HL,DE                ; Add to number
            EX      DE,HL                ; Number to DE
            POP     HL                   ; Restore code string address
            JP      GTLNLP               ; Go to next character

CLEAR:      JP      Z,INTVAR             ; Just "CLEAR" Keep parameters
            CALL    POSINT               ; Get integer 0 to 32767 to DE
            DEC     HL                   ; Cancel increment
            CALL    GETCHR               ; Get next character
            PUSH    HL                   ; Save code string address
            LD      HL,(LSTRAM)          ; Get end of RAM
            JP      Z,STORED             ; No value given - Use stored
            POP     HL                   ; Restore code string address
            CALL    CHKSYN               ; Check for comma
            DB         ','
            PUSH    DE                   ; Save number
            CALL    POSINT               ; Get integer 0 to 32767
            DEC     HL                   ; Cancel increment
            CALL    GETCHR               ; Get next character
            JP      NZ,SNERR             ; ?SN Error if more on line
            EX      (SP),HL              ; Save code string address
            EX      DE,HL                ; Number to DE
STORED:     LD      A,L                  ; Get LSB of new RAM top
            SUB     E                    ; Subtract LSB of string space
            LD      E,A                  ; Save LSB
            LD      A,H                  ; Get MSB of new RAM top
            SBC     A,D                  ; Subtract MSB of string space
            LD      D,A                  ; Save MSB
            JP      C,OMERR              ; ?OM Error if not enough mem
            PUSH    HL                   ; Save RAM top
            LD      HL,(PROGND)          ; Get program end
            LD      BC,40                ; 40 Bytes minimum working RAM
            ADD     HL,BC                ; Get lowest address
            CALL    CPDEHL               ; Enough memory?
            JP      NC,OMERR             ; No - ?OM Error
            EX      DE,HL                ; RAM top to HL
            LD      (STRSPC),HL          ; Set new string space
            POP     HL                   ; End of memory to use
            LD      (LSTRAM),HL          ; Set new top of RAM
            POP     HL                   ; Restore code string address
            JP      INTVAR               ; Initialise variables

RUN:        JP      Z,RUNFST             ; RUN from start if just RUN
            CALL    INTVAR               ; Initialise variables
            LD      BC,RUNCNT            ; Execution driver loop
            JP      RUNLIN               ; RUN from line number

GOSUB:      LD      C,3                  ; 3 Levels of stack needed
            CALL    CHKSTK               ; Check for 3 levels of stack
            POP     BC                   ; Get return address
            PUSH    HL                   ; Save code string for RETURN
            PUSH    HL                   ; And for GOSUB routine
            LD      HL,(LINEAT)          ; Get current line
            EX      (SP),HL              ; Into stack - Code string out
            LD      A,ZGOSUB             ; "GOSUB" token
            PUSH    AF                   ; Save token
            INC     SP                   ; Don't save flags

RUNLIN:     PUSH    BC                   ; Save return address
GOTO:       CALL    ATOH                 ; ASCII number to DE binary
            CALL    REM                  ; Get end of line
            PUSH    HL                   ; Save end of line
            LD      HL,(LINEAT)          ; Get current line
            CALL    CPDEHL               ; Line after current?
            POP     HL                   ; Restore end of line
            INC     HL                   ; Start of next line
            CALL    C,SRCHLP             ; Line is after current line
            CALL    NC,SRCHLN            ; Line is before current line
            LD      H,B                  ; Set up code string address
            LD      L,C
            DEC     HL                   ; Incremented after
            RET     C                    ; Line found
ULERR:      LD      E,UL                 ; ?UL Error
            JP      BERROR               ; Output error message

RETURN:     RET     NZ                   ; Return if not just RETURN
            LD      D,-1                 ; Flag "GOSUB" search
            CALL    BAKSTK               ; Look "GOSUB" block
            LD      SP,HL                ; Kill all FORs in subroutine
            CP      ZGOSUB               ; Test for "GOSUB" token
            LD      E,RG                 ; ?RG Error
            JP      NZ,BERROR            ; Error if no "GOSUB" found
            POP     HL                   ; Get RETURN line number
            LD      (LINEAT),HL          ; Save as current
            INC     HL                   ; Was it from direct statement?
            LD      A,H
            OR      L                    ; Return to line
            JP      NZ,RETLIN            ; No - Return to line
            LD      A,(LSTBIN)           ; Any INPUT in subroutine?
            OR      A                    ; If so buffer is corrupted
            JP      NZ,POPNOK            ; Yes - Go to command mode
RETLIN:     LD      HL,RUNCNT            ; Execution driver loop
            EX      (SP),HL              ; Into stack - Code string out
            DB         3EH                  ; Skip "POP HL"
NXTDTA:     POP     HL                   ; Restore code string address

DATA:       DB      01H,3AH              ; ':' End of statement
REM:        LD      C,0                  ; 00  End of statement
            LD      B,0
NXTSTL:     LD      A,C                  ; Statement and byte
            LD      C,B
            LD      B,A                  ; Statement end byte
NXTSTT:     LD      A,(HL)               ; Get byte
            OR      A                    ; End of line?
            RET     Z                    ; Yes - Exit
            CP      B                    ; End of statement?
            RET     Z                    ; Yes - Exit
            INC     HL                   ; Next byte
            CP      '"'                  ; Literal string?
            JP      Z,NXTSTL             ; Yes - Look for another '"'
            JP      NXTSTT               ; Keep looking

LET:        CALL    GETVAR               ; Get variable name
            CALL    CHKSYN               ; Make sure "=" follows
            DB         ZEQUAL               ; "=" token
            PUSH    DE                   ; Save address of variable
            LD      A,(TYPE)             ; Get data type
            PUSH    AF                   ; Save type
            CALL    EVAL                 ; Evaluate expression
            POP     AF                   ; Restore type
            EX      (SP),HL              ; Save code - Get var addr
            LD      (BRKLIN),HL          ; Save address of variable
            RRA                          ; Adjust type
            CALL    CHKTYP               ; Check types are the same
            JP      Z,LETNUM             ; Numeric - Move value
LETSTR:     PUSH    HL                   ; Save address of string var
            LD      HL,(FPREG)           ; Pointer to string entry
            PUSH    HL                   ; Save it on stack
            INC     HL                   ; Skip over length
            INC     HL
            LD      E,(HL)               ; LSB of string address
            INC     HL
            LD      D,(HL)               ; MSB of string address
            LD      HL,(BASTXT)          ; Point to start of program
            CALL    CPDEHL               ; Is string before program?
            JP      NC,CRESTR            ; Yes - Create string entry
            LD      HL,(STRSPC)          ; Point to string space
            CALL    CPDEHL               ; Is string literal in program?
            POP     DE                   ; Restore address of string
            JP      NC,MVSTPT            ; Yes - Set up pointer
            LD      HL,TMPSTR            ; Temporary string pool
            CALL    CPDEHL               ; Is string in temporary pool?
            JP      NC,MVSTPT            ; No - Set up pointer
            DB      3EH                  ; Skip "POP DE"
CRESTR:     POP     DE                   ; Restore address of string
            CALL    BAKTMP               ; Back to last tmp-str entry
            EX      DE,HL                ; Address of string entry
            CALL    SAVSTR               ; Save string in string area
MVSTPT:     CALL    BAKTMP               ; Back to last tmp-str entry
            POP     HL                   ; Get string pointer
            CALL    DETHL4               ; Move string pointer to var
            POP     HL                   ; Restore code string address
            RET

LETNUM:     PUSH    HL                   ; Save address of variable
            CALL    FPTHL                ; Move value to variable
            POP     DE                   ; Restore address of variable
            POP     HL                   ; Restore code string address
            RET

ON:         CALL    GETINT               ; Get integer 0-255
            LD      A,(HL)               ; Get "GOTO" or "GOSUB" token
            LD      B,A                  ; Save in B
            CP      ZGOSUB               ; "GOSUB" token?
            JP      Z,ONGO               ; Yes - Find line number
            CALL    CHKSYN               ; Make sure it's "GOTO"
            DB      ZGOTO                ; "GOTO" token
            DEC     HL                   ; Cancel increment
ONGO:       LD      C,E                  ; Integer of branch value
ONGOLP:     DEC     C                    ; Count branches
            LD      A,B                  ; Get "GOTO" or "GOSUB" token
            JP      Z,ONJMP              ; Go to that line if right one
            CALL    GETLN                ; Get line number to DE
            CP      ','                  ; Another line number?
            RET     NZ                   ; No - Drop through
            JP      ONGOLP               ; Yes - loop

IF:         CALL    EVAL                 ; Evaluate expression
            LD      A,(HL)               ; Get token
            CP      ZGOTO                ; "GOTO" token?
            JP      Z,IFGO               ; Yes - Get line
            CALL    CHKSYN               ; Make sure it's "THEN"
            DB         ZTHEN                ; "THEN" token
            DEC     HL                   ; Cancel increment
IFGO:       CALL    TSTNUM               ; Make sure it's numeric
            CALL    TSTSGN               ; Test state of expression
            JP      Z,REM                ; False - Drop through
            CALL    GETCHR               ; Get next character
            JP      C,GOTO               ; Number - GOTO that line
            JP      IFJMP                ; Otherwise do statement

MRPRNT:     DEC     HL                   ; DEC 'cos GETCHR INCs
            CALL    GETCHR               ; Get next character
PRINT:      JP      Z,PRNTCRLF           ; CRLF if just PRINT
PRNTLP:     RET     Z                    ; End of list - Exit
            CP      ZTAB                 ; "TAB(" token?
            JP      Z,DOTAB              ; Yes - Do TAB routine
            CP      ZSPC                 ; "SPC(" token?
            JP      Z,DOTAB              ; Yes - Do SPC routine
            PUSH    HL                   ; Save code string address
            CP      ','                  ; Comma?
            JP      Z,DOCOM              ; Yes - Move to next zone
            CP      59 ;";"              ; Semi-colon?
            JP      Z,NEXITM             ; Do semi-colon routine
            POP     BC                   ; Code string address to BC
            CALL    EVAL                 ; Evaluate expression
            PUSH    HL                   ; Save code string address
            LD      A,(TYPE)             ; Get variable type
            OR      A                    ; Is it a string variable?
            JP      NZ,PRNTST            ; Yes - Output string contents
            CALL    NUMASC               ; Convert number to text
            CALL    CRTST                ; Create temporary string
            LD      (HL),' '             ; Followed by a space
            LD      HL,(FPREG)           ; Get length of output
            INC     (HL)                 ; Plus 1 for the space
            LD      HL,(FPREG)           ; < Not needed >
            LD      A,(LWIDTH)           ; Get width of line
            LD      B,A                  ; To B
            INC     B                    ; Width 255 (No limit)?
            JP      Z,PRNTNB             ; Yes - Output number string
            INC     B                    ; Adjust it
            LD      A,(CURPOS)           ; Get cursor position
            ADD     A,(HL)               ; Add length of string
            DEC     A                    ; Adjust it
            CP      B                    ; Will output fit on this line?
            CALL    NC,PRNTCRLF          ; No - CRLF first
PRNTNB:     CALL    PRS1                 ; Output string at (HL)
            XOR     A                    ; Skip CALL by setting 'z' flag
PRNTST:     CALL    NZ,PRS1              ; Output string at (HL)
            POP     HL                   ; Restore code string address
            JP      MRPRNT               ; See if more to PRINT

STTLIN:     LD      A,(CURPOS)           ; Make sure on new line
            OR      A                    ; Already at start?
            RET     Z                    ; Yes - Do nothing
            JP      PRNTCRLF             ; Start a new line

ENDINP:     LD      (HL),0               ; Mark end of buffer
            LD      HL,BUFFER-1          ; Point to buffer
PRNTCRLF:   LD     A,CR                 ; Load a CR
            CALL    OUTC                 ; Output character
            LD      A,LF                 ; Load a LF
            CALL    OUTC                 ; Output character
DONULL:     XOR     A                    ; Set to position 0
            LD      (CURPOS),A           ; Store it
            LD      A,(NULLS)            ; Get number of nulls
NULLP:      DEC     A                    ; Count them
            RET     Z                    ; Return if done
            PUSH    AF                   ; Save count
            XOR     A                    ; Load a null
            CALL    OUTC                 ; Output it
            POP     AF                   ; Restore count
            JP      NULLP                ; Keep counting

DOCOM:      LD      A,(COMMAN)           ; Get comma width
            LD      B,A                  ; Save in B
            LD      A,(CURPOS)           ; Get current position
            CP      B                    ; Within the limit?
            CALL    NC,PRNTCRLF          ; No - output CRLF
            JP      NC,NEXITM            ; Get next item
ZONELP:     SUB     14                   ; Next zone of 14 characters
            JP      NC,ZONELP            ; Repeat if more zones
            CPL                          ; Number of spaces to output
            JP      ASPCS                ; Output them

DOTAB:      PUSH    AF                   ; Save token
            CALL    FNDNUM               ; Evaluate expression
            CALL    CHKSYN               ; Make sure ")" follows
            DB      ")"
            DEC     HL                   ; Back space on to ")"
            POP     AF                   ; Restore token
            SUB     ZSPC                 ; Was it "SPC(" ?
            PUSH    HL                   ; Save code string address
            JP      Z,DOSPC              ; Yes - Do 'E' spaces
            LD      A,(CURPOS)           ; Get current position
DOSPC:      CPL                          ; Number of spaces to print to
            ADD     A,E                  ; Total number to print
            JP      NC,NEXITM            ; TAB < Current POS(X)
ASPCS:      INC     A                    ; Output A spaces
            LD      B,A                  ; Save number to print
            LD      A,' '                ; Space
SPCLP:      CALL    OUTC                 ; Output character in A
            DEC     B                    ; Count them
            JP      NZ,SPCLP             ; Repeat if more
NEXITM:     POP     HL                   ; Restore code string address
            CALL    GETCHR               ; Get next character
            JP      PRNTLP               ; More to print

REDO:       DB      "?Redo from start",CR,LF,0

BADINP:     LD      A,(READFG)           ; READ or INPUT?
            OR      A
            JP      NZ,DATSNR            ; READ - ?SN Error
            POP     BC                   ; Throw away code string addr
            LD      HL,REDO              ; "Redo from start" message
            CALL    PRS                  ; Output string
            JP      DOAGN                ; Do last INPUT again

INPUT:      CALL    IDTEST               ; Test for illegal direct
            LD      A,(HL)               ; Get character after "INPUT"
            CP      '"'                  ; Is there a prompt string?
            LD      A,0                  ; Clear A and leave flags
            LD      (CTLOFG),A           ; Enable output
            JP      NZ,NOPMPT            ; No prompt - get input
            CALL    QTSTR                ; Get string terminated by '"'
            CALL    CHKSYN               ; Check for ';' after prompt
            DB      ';'
            PUSH    HL                   ; Save code string address
            CALL    PRS1                 ; Output prompt string
            DB      3EH                  ; Skip "PUSH HL"
NOPMPT:     PUSH    HL                   ; Save code string address
            CALL    PROMPT               ; Get input with "? " prompt
            POP     BC                   ; Restore code string address
            JP      C,INPBRK             ; Break pressed - Exit
            INC     HL                   ; Next byte
            LD      A,(HL)               ; Get it
            OR      A                    ; End of line?
            DEC     HL                   ; Back again
            PUSH    BC                   ; Re-save code string address
            JP      Z,NXTDTA             ; Yes - Find next DATA stmt
            LD      (HL),','             ; Store comma as separator
            JP      NXTITM               ; Get next item

READ:       PUSH    HL                   ; Save code string address
            LD      HL,(NXTDAT)          ; Next DATA statement
            DB      0F6H                 ; Flag "READ"
NXTITM:     XOR     A                    ; Flag "INPUT"
            LD      (READFG),A           ; Save "READ"/"INPUT" flag
            EX      (SP),HL              ; Get code str' , Save pointer
            JP      GTVLUS               ; Get values

NEDMOR:     CALL    CHKSYN               ; Check for comma between items
            DB         ','
GTVLUS:     CALL    GETVAR               ; Get variable name
            EX      (SP),HL              ; Save code str" , Get pointer
            PUSH    DE                   ; Save variable address
            LD      A,(HL)               ; Get next "INPUT"/"DATA" byte
            CP      ','                  ; Comma?
            JP      Z,ANTVLU             ; Yes - Get another value
            LD      A,(READFG)           ; Is it READ?
            OR      A
            JP      NZ,FDTLP             ; Yes - Find next DATA stmt
            LD      A,'?'                ; More INPUT needed
            CALL    OUTC                 ; Output character
            CALL    PROMPT               ; Get INPUT with prompt
            POP     DE                   ; Variable address
            POP     BC                   ; Code string address
            JP      C,INPBRK             ; Break pressed
            INC     HL                   ; Point to next DATA byte
            LD      A,(HL)               ; Get byte
            OR      A                    ; Is it zero (No input) ?
            DEC     HL                   ; Back space INPUT pointer
            PUSH    BC                   ; Save code string address
            JP      Z,NXTDTA             ; Find end of buffer
            PUSH    DE                   ; Save variable address
ANTVLU:     LD      A,(TYPE)             ; Check data type
            OR      A                    ; Is it numeric?
            JP      Z,INPBIN             ; Yes - Convert to binary
            CALL    GETCHR               ; Get next character
            LD      D,A                  ; Save input character
            LD      B,A                  ; Again
            CP      '"'                  ; Start of literal sting?
            JP      Z,STRENT             ; Yes - Create string entry
            LD      A,(READFG)           ; "READ" or "INPUT" ?
            OR      A
            LD      D,A                  ; Save 00 if "INPUT"
            JP      Z,ITMSEP             ; "INPUT" - End with 00
            LD      D,':'                ; "DATA" - End with 00 or ':'
ITMSEP:     LD      B,','                ; Item separator
            DEC     HL                   ; Back space for DTSTR
STRENT:     CALL    DTSTR                ; Get string terminated by D
            EX      DE,HL                ; String address to DE
            LD      HL,LTSTND            ; Where to go after LETSTR
            EX      (SP),HL              ; Save HL , get input pointer
            PUSH    DE                   ; Save address of string
            JP      LETSTR               ; Assign string to variable

INPBIN:     CALL    GETCHR               ; Get next character
            CALL    ASCTFP               ; Convert ASCII to FP number
            EX      (SP),HL              ; Save input ptr, Get var addr
            CALL    FPTHL                ; Move FPREG to variable
            POP     HL                   ; Restore input pointer
LTSTND:     DEC     HL                   ; DEC 'cos GETCHR INCs
            CALL    GETCHR               ; Get next character
            JP      Z,MORDT              ; End of line - More needed?
            CP      ','                  ; Another value?
            JP      NZ,BADINP            ; No - Bad input
MORDT:      EX      (SP),HL              ; Get code string address
            DEC     HL                   ; DEC 'cos GETCHR INCs
            CALL    GETCHR               ; Get next character
            JP      NZ,NEDMOR            ; More needed - Get it
            POP     DE                   ; Restore DATA pointer
            LD      A,(READFG)           ; "READ" or "INPUT" ?
            OR      A
            EX      DE,HL                ; DATA pointer to HL
            JP      NZ,UPDATA            ; Update DATA pointer if "READ"
            PUSH    DE                   ; Save code string address
            OR      (HL)                 ; More input given?
            LD      HL,EXTIG             ; "?Extra ignored" message
            CALL    NZ,PRS               ; Output string if extra given
            POP     HL                   ; Restore code string address
            RET

EXTIG:      DB      "?Extra ignored",CR,LF,0

FDTLP:      CALL    DATA                 ; Get next statement
            OR      A                    ; End of line?
            JP      NZ,FANDT             ; No - See if DATA statement
            INC     HL
            LD      A,(HL)               ; End of program?
            INC     HL
            OR      (HL)                 ; 00 00 Ends program
            LD      E,OD                 ; ?OD Error
            JP      Z,BERROR             ; Yes - Out of DATA
            INC     HL
            LD      E,(HL)               ; LSB of line number
            INC     HL
            LD      D,(HL)               ; MSB of line number
            EX      DE,HL
            LD      (DATLIN),HL          ; Set line of current DATA item
            EX      DE,HL
FANDT:      CALL    GETCHR               ; Get next character
            CP      ZDATA                ; "DATA" token
            JP      NZ,FDTLP             ; No "DATA" - Keep looking
            JP      ANTVLU               ; Found - Convert input

NEXT:       LD      DE,0                 ; In case no index given
NEXT1:      CALL    NZ,GETVAR            ; Get index address
            LD      (BRKLIN),HL          ; Save code string address
            CALL    BAKSTK               ; Look for "FOR" block
            JP      NZ,NFERR             ; No "FOR" - ?NF Error
            LD      SP,HL                ; Clear nested loops
            PUSH    DE                   ; Save index address
            LD      A,(HL)               ; Get sign of STEP
            INC     HL
            PUSH    AF                   ; Save sign of STEP
            PUSH    DE                   ; Save index address
            CALL    PHLTFP               ; Move index value to FPREG
            EX      (SP),HL              ; Save address of TO value
            PUSH    HL                   ; Save address of index
            CALL    ADDPHL               ; Add STEP to index value
            POP     HL                   ; Restore address of index
            CALL    FPTHL                ; Move value to index variable
            POP     HL                   ; Restore address of TO value
            CALL    LOADFP               ; Move TO value to BCDE
            PUSH    HL                   ; Save address of line of FOR
            CALL    CMPNUM               ; Compare index with TO value
            POP     HL                   ; Restore address of line num
            POP     BC                   ; Address of sign of STEP
            SUB     B                    ; Compare with expected sign
            CALL    LOADFP               ; BC = Loop stmt,DE = Line num
            JP      Z,KILFOR             ; Loop finished - Terminate it
            EX      DE,HL                ; Loop statement line number
            LD      (LINEAT),HL          ; Set loop line number
            LD      L,C                  ; Set code string to loop
            LD      H,B
            JP      PUTFID               ; Put back "FOR" and continue

KILFOR:     LD      SP,HL                ; Remove "FOR" block
            LD      HL,(BRKLIN)          ; Code string after "NEXT"
            LD      A,(HL)               ; Get next byte in code string
            CP      ','                  ; More NEXTs ?
            JP      NZ,RUNCNT            ; No - Do next statement
            CALL    GETCHR               ; Position to index name
            CALL    NEXT1                ; Re-enter NEXT routine
        ; < will not RETurn to here , Exit to RUNCNT or Loop >

GETNUM:     CALL    EVAL                 ; Get a numeric expression
TSTNUM:     DB      0F6H                 ; Clear carry (numeric)
TSTSTR:     SCF                          ; Set carry (string)
CHKTYP:     LD      A,(TYPE)             ; Check types match
            ADC     A,A                  ; Expected + actual
            OR      A                    ; Clear carry , set parity
            RET     PE                   ; Even parity - Types match
            JP      TMERR                ; Different types - Error

OPNPAR:     CALL    CHKSYN               ; Make sure "(" follows
            DB      "("
EVAL:       DEC     HL                   ; Evaluate expression & save
            LD      D,0                  ; Precedence value
EVAL1:      PUSH    DE                   ; Save precedence
            LD      C,1
            CALL    CHKSTK               ; Check for 1 level of stack
            CALL    OPRND                ; Get next expression value
EVAL2:      LD      (NXTOPR),HL          ; Save address of next operator
EVAL3:      LD      HL,(NXTOPR)          ; Restore address of next opr
            POP     BC                   ; Precedence value and operator
            LD      A,B                  ; Get precedence value
            CP      78H                  ; "AND" or "OR" ?
            CALL    NC,TSTNUM            ; No - Make sure it's a number
            LD      A,(HL)               ; Get next operator / function
            LD      D,0                  ; Clear Last relation
RLTLP:      SUB     ZGTR                 ; ">" Token
            JP      C,FOPRND             ; + - * / ^ AND OR - Test it
            CP      ZLTH+1-ZGTR          ; < = >
            JP      NC,FOPRND            ; Function - Call it
            CP      ZEQUAL-ZGTR          ; "="
            RLA                          ; <- Test for legal
            XOR     D                    ; <- combinations of < = >
            CP      D                    ; <- by combining last token
            LD      D,A                  ; <- with current one
            JP      C,SNERR              ; Error if "<<' '==" or ">>"
            LD      (CUROPR),HL          ; Save address of current token
            CALL    GETCHR               ; Get next character
            JP      RLTLP                ; Treat the two as one

FOPRND:     LD      A,D                  ; < = > found ?
            OR      A
            JP      NZ,TSTRED            ; Yes - Test for reduction
            LD      A,(HL)               ; Get operator token
            LD      (CUROPR),HL          ; Save operator address
            SUB     ZPLUS                ; Operator or function?
            RET     C                    ; Neither - Exit
            CP      ZOR+1-ZPLUS          ; Is it + - * / ^ AND OR ?
            RET     NC                   ; No - Exit
            LD      E,A                  ; Coded operator
            LD      A,(TYPE)             ; Get data type
            DEC     A                    ; FF = numeric , 00 = string
            OR      E                    ; Combine with coded operator
            LD      A,E                  ; Get coded operator
            JP      Z,CONCAT             ; String concatenation
            RLCA                         ; Times 2
            ADD     A,E                  ; Times 3
            LD      E,A                  ; To DE (D is 0)
            LD      HL,PRITAB            ; Precedence table
            ADD     HL,DE                ; To the operator concerned
            LD      A,B                  ; Last operator precedence
            LD      D,(HL)               ; Get evaluation precedence
            CP      D                    ; Compare with eval precedence
            RET     NC                   ; Exit if higher precedence
            INC     HL                   ; Point to routine address
            CALL    TSTNUM               ; Make sure it's a number

STKTHS:     PUSH    BC                   ; Save last precedence & token
            LD      BC,EVAL3             ; Where to go on prec' break
            PUSH    BC                   ; Save on stack for return
            LD      B,E                  ; Save operator
            LD      C,D                  ; Save precedence
            CALL    STAKFP               ; Move value to stack
            LD      E,B                  ; Restore operator
            LD      D,C                  ; Restore precedence
            LD      C,(HL)               ; Get LSB of routine address
            INC     HL
            LD      B,(HL)               ; Get MSB of routine address
            INC     HL
            PUSH    BC                   ; Save routine address
            LD      HL,(CUROPR)          ; Address of current operator
            JP      EVAL1                ; Loop until prec' break

OPRND:      XOR     A                    ; Get operand routine
            LD      (TYPE),A             ; Set numeric expected
            CALL    GETCHR               ; Get next character
            LD      E,MO                 ; ?MO Error
            JP      Z,BERROR             ; No operand - Error
            JP      C,ASCTFP             ; Number - Get value
            CALL    CHKLTR               ; See if a letter
            JP      NC,CONVAR            ; Letter - Find variable
            CP      '&'                  ; &H = HEX, &B = BINARY [G. Searle]
            JR      NZ, NOTAMP
            CALL    GETCHR               ; Get next character
            CP      'H'                  ; Hex number indicated? [function added]
            JP      Z,HEXTFP             ; Convert Hex to FPREG
            CP      'B'                  ; Binary number indicated? [function added]
            JP      Z,BINTFP             ; Convert Bin to FPREG
            LD      E,SN                 ; If neither then a ?SN Error
            JP      Z,BERROR             ; 
NOTAMP:     CP      ZPLUS                ; '+' Token ?
            JP      Z,OPRND              ; Yes - Look for operand
            CP      '.'                  ; '.' ?
            JP      Z,ASCTFP             ; Yes - Create FP number
            CP      ZMINUS               ; '-' Token ?
            JP      Z,MINUS              ; Yes - Do minus
            CP      '"'                  ; Literal string ?
            JP      Z,QTSTR              ; Get string terminated by '"'
            CP      ZNOT                 ; "NOT" Token ?
            JP      Z,EVNOT              ; Yes - Eval NOT expression
            CP      ZFN                  ; "FN" Token ?
            JP      Z,DOFN               ; Yes - Do FN routine
            SUB     ZSGN                 ; Is it a function?
            JP      NC,FNOFST            ; Yes - Evaluate function
EVLPAR:     CALL    OPNPAR               ; Evaluate expression in "()"
            CALL    CHKSYN               ; Make sure ")" follows
            DB      ")"
            RET

MINUS:      LD      D,7DH                ; '-' precedence
            CALL    EVAL1                ; Evaluate until prec' break
            LD      HL,(NXTOPR)          ; Get next operator address
            PUSH    HL                   ; Save next operator address
            CALL    INVSGN               ; Negate value
RETNUM:     CALL    TSTNUM               ; Make sure it's a number
            POP     HL                   ; Restore next operator address
            RET

CONVAR:     CALL    GETVAR               ; Get variable address to DE
FRMEVL:     PUSH    HL                   ; Save code string address
            EX      DE,HL                ; Variable address to HL
            LD      (FPREG),HL           ; Save address of variable
            LD      A,(TYPE)             ; Get type
            OR      A                    ; Numeric?
            CALL    Z,PHLTFP             ; Yes - Move contents to FPREG
            POP     HL                   ; Restore code string address
            RET

FNOFST:     LD      B,0                  ; Get address of function
            RLCA                         ; Double function offset
            LD      C,A                  ; BC = Offset in function table
            PUSH    BC                   ; Save adjusted token value
            CALL    GETCHR               ; Get next character
            LD      A,C                  ; Get adjusted token value
            CP      2*(ZLEFT-ZSGN)-1     ; Adj' LEFT$,RIGHT$ or MID$ ?
            JP      C,FNVAL              ; No - Do function
            CALL    OPNPAR               ; Evaluate expression  (X,...
            CALL    CHKSYN               ; Make sure ',' follows
            DB         ','
            CALL    TSTSTR               ; Make sure it's a string
            EX      DE,HL                ; Save code string address
            LD      HL,(FPREG)           ; Get address of string
            EX      (SP),HL              ; Save address of string
            PUSH    HL                   ; Save adjusted token value
            EX      DE,HL                ; Restore code string address
            CALL    GETINT               ; Get integer 0-255
            EX      DE,HL                ; Save code string address
            EX      (SP),HL              ; Save integer,HL = adj' token
            JP      GOFUNC               ; Jump to string function

FNVAL:      CALL    EVLPAR               ; Evaluate expression
            EX      (SP),HL              ; HL = Adjusted token value
            LD      DE,RETNUM            ; Return number from function
            PUSH    DE                   ; Save on stack
GOFUNC:     LD      BC,FNCTAB            ; Function routine addresses
            ADD     HL,BC                ; Point to right address
            LD      C,(HL)               ; Get LSB of address
            INC     HL                   ;
            LD      H,(HL)               ; Get MSB of address
            LD      L,C                  ; Address to HL
            JP      (HL)                 ; Jump to function

SGNEXP:     DEC     D                    ; Dee to flag negative exponent
            CP      ZMINUS               ; '-' token ?
            RET     Z                    ; Yes - Return
            CP      '-'                  ; '-' ASCII ?
            RET     Z                    ; Yes - Return
            INC     D                    ; Inc to flag positive exponent
            CP      '+'                  ; '+' ASCII ?
            RET     Z                    ; Yes - Return
            CP      ZPLUS                ; '+' token ?
            RET     Z                    ; Yes - Return
            DEC     HL                   ; DEC 'cos GETCHR INCs
            RET                          ; Return "NZ"

POR:        DB      0F6H                 ; Flag "OR"
PAND:       XOR     A                    ; Flag "AND"
            PUSH    AF                   ; Save "AND" / "OR" flag
            CALL    TSTNUM               ; Make sure it's a number
            CALL    DEINT                ; Get integer -32768 to 32767
            POP     AF                   ; Restore "AND" / "OR" flag
            EX      DE,HL                ; <- Get last
            POP     BC                   ; <-  value
            EX      (SP),HL              ; <-  from
            EX      DE,HL                ; <-  stack
            CALL    FPBCDE               ; Move last value to FPREG
            PUSH    AF                   ; Save "AND" / "OR" flag
            CALL    DEINT                ; Get integer -32768 to 32767
            POP     AF                   ; Restore "AND" / "OR" flag
            POP     BC                   ; Get value
            LD      A,C                  ; Get LSB
            LD      HL,ACPASS            ; Address of save AC as current
            JP      NZ,POR1              ; Jump if OR
            AND     E                    ; "AND" LSBs
            LD      C,A                  ; Save LSB
            LD      A,B                  ; Get MBS
            AND     D                    ; "AND" MSBs
            JP      (HL)                 ; Save AC as current (ACPASS)

POR1:       OR      E                    ; "OR" LSBs
            LD      C,A                  ; Save LSB
            LD      A,B                  ; Get MSB
            OR      D                    ; "OR" MSBs
            JP      (HL)                 ; Save AC as current (ACPASS)

TSTRED:     LD      HL,CMPLOG            ; Logical compare routine
            LD      A,(TYPE)             ; Get data type
            RRA                          ; Carry set = string
            LD      A,D                  ; Get last precedence value
            RLA                          ; Times 2 plus carry
            LD      E,A                  ; To E
            LD      D,64H                ; Relational precedence
            LD      A,B                  ; Get current precedence
            CP      D                    ; Compare with last
            RET     NC                   ; Eval if last was rel' or log'
            JP      STKTHS               ; Stack this one and get next

CMPLOG:     DW      CMPLG1               ; Compare two values / strings
CMPLG1:     LD      A,C                  ; Get data type
            OR      A
            RRA
            POP     BC                   ; Get last expression to BCDE
            POP     DE
            PUSH    AF                   ; Save status
            CALL    CHKTYP               ; Check that types match
            LD      HL,CMPRES            ; Result to comparison
            PUSH    HL                   ; Save for RETurn
            JP      Z,CMPNUM             ; Compare values if numeric
            XOR     A                    ; Compare two strings
            LD      (TYPE),A             ; Set type to numeric
            PUSH    DE                   ; Save string name
            CALL    GSTRCU               ; Get current string
            LD      A,(HL)               ; Get length of string
            INC     HL
            INC     HL
            LD      C,(HL)               ; Get LSB of address
            INC     HL
            LD      B,(HL)               ; Get MSB of address
            POP     DE                   ; Restore string name
            PUSH    BC                   ; Save address of string
            PUSH    AF                   ; Save length of string
            CALL    GSTRDE               ; Get second string
            CALL    LOADFP               ; Get address of second string
            POP     AF                   ; Restore length of string 1
            LD      D,A                  ; Length to D
            POP     HL                   ; Restore address of string 1
CMPSTR:     LD      A,E                  ; Bytes of string 2 to do
            OR      D                    ; Bytes of string 1 to do
            RET     Z                    ; Exit if all bytes compared
            LD      A,D                  ; Get bytes of string 1 to do
            SUB     1
            RET     C                    ; Exit if end of string 1
            XOR     A
            CP      E                    ; Bytes of string 2 to do
            INC     A
            RET     NC                   ; Exit if end of string 2
            DEC     D                    ; Count bytes in string 1
            DEC     E                    ; Count bytes in string 2
            LD      A,(BC)               ; Byte in string 2
            CP      (HL)                 ; Compare to byte in string 1
            INC     HL                   ; Move up string 1
            INC     BC                   ; Move up string 2
            JP      Z,CMPSTR             ; Same - Try next bytes
            CCF                          ; Flag difference (">" or "<")
            JP      FLGDIF               ; "<" gives -1 , ">" gives +1

CMPRES:     INC     A                    ; Increment current value
            ADC     A,A                  ; Double plus carry
            POP     BC                   ; Get other value
            AND     B                    ; Combine them
            ADD     A,-1                 ; Carry set if different
            SBC     A,A                  ; 00 - Equal , FF - Different
            JP      FLGREL               ; Set current value & continue

EVNOT:      LD      D,5AH                ; Precedence value for "NOT"
            CALL    EVAL1                ; Eval until precedence break
            CALL    TSTNUM               ; Make sure it's a number
            CALL    DEINT                ; Get integer -32768 - 32767
            LD      A,E                  ; Get LSB
            CPL                          ; Invert LSB
            LD      C,A                  ; Save "NOT" of LSB
            LD      A,D                  ; Get MSB
            CPL                          ; Invert MSB
            CALL    ACPASS               ; Save AC as current
            POP     BC                   ; Clean up stack
            JP      EVAL3                ; Continue evaluation

DIMRET:     DEC     HL                   ; DEC 'cos GETCHR INCs
            CALL    GETCHR               ; Get next character
            RET     Z                    ; End of DIM statement
            CALL    CHKSYN               ; Make sure ',' follows
            DB         ','
DIM:        LD      BC,DIMRET            ; Return to "DIMRET"
            PUSH    BC                   ; Save on stack
            DB      0F6H                 ; Flag "Create" variable
GETVAR:     XOR     A                    ; Find variable address,to DE
            LD      (LCRFLG),A           ; Set locate / create flag
            LD      B,(HL)               ; Get First byte of name
GTFNAM:     CALL    CHKLTR               ; See if a letter
            JP      C,SNERR              ; ?SN Error if not a letter
            XOR     A
            LD      C,A                  ; Clear second byte of name
            LD      (TYPE),A             ; Set type to numeric
            CALL    GETCHR               ; Get next character
            JP      C,SVNAM2             ; Numeric - Save in name
            CALL    CHKLTR               ; See if a letter
            JP      C,CHARTY             ; Not a letter - Check type
SVNAM2:     LD      C,A                  ; Save second byte of name
ENDNAM:     CALL    GETCHR               ; Get next character
            JP      C,ENDNAM             ; Numeric - Get another
            CALL    CHKLTR               ; See if a letter
            JP      NC,ENDNAM            ; Letter - Get another
CHARTY:     SUB     '$'                  ; String variable?
            JP      NZ,NOTSTR            ; No - Numeric variable
            INC     A                    ; A = 1 (string type)
            LD      (TYPE),A             ; Set type to string
            RRCA                         ; A = 80H , Flag for string
            ADD     A,C                  ; 2nd byte of name has bit 7 on
            LD      C,A                  ; Resave second byte on name
            CALL    GETCHR               ; Get next character
NOTSTR:     LD      A,(FORFLG)           ; Array name needed ?
            DEC     A
            JP      Z,ARLDSV             ; Yes - Get array name
            JP      P,NSCFOR             ; No array with "FOR" or "FN"
            LD      A,(HL)               ; Get byte again
            SUB     '('                  ; Subscripted variable?
            JP      Z,SBSCPT             ; Yes - Sort out subscript

NSCFOR:     XOR     A                    ; Simple variable
            LD      (FORFLG),A           ; Clear "FOR" flag
            PUSH    HL                   ; Save code string address
            LD      D,B                  ; DE = Variable name to find
            LD      E,C
            LD      HL,(FNRGNM)          ; FN argument name
            CALL    CPDEHL               ; Is it the FN argument?
            LD      DE,FNARG             ; Point to argument value
            JP      Z,POPHRT             ; Yes - Return FN argument value
            LD      HL,(VAREND)          ; End of variables
            EX      DE,HL                ; Address of end of search
            LD      HL,(PROGND)          ; Start of variables address
FNDVAR:     CALL    CPDEHL               ; End of variable list table?
            JP      Z,CFEVAL             ; Yes - Called from EVAL?
            LD      A,C                  ; Get second byte of name
            SUB     (HL)                 ; Compare with name in list
            INC     HL                   ; Move on to first byte
            JP      NZ,FNTHR             ; Different - Find another
            LD      A,B                  ; Get first byte of name
            SUB     (HL)                 ; Compare with name in list
FNTHR:      INC     HL                   ; Move on to LSB of value
            JP      Z,RETADR             ; Found - Return address
            INC     HL                   ; <- Skip
            INC     HL                   ; <- over
            INC     HL                   ; <- F.P.
            INC     HL                   ; <- value
            JP      FNDVAR               ; Keep looking

CFEVAL:     POP     HL                   ; Restore code string address
            EX      (SP),HL              ; Get return address
            PUSH    DE                   ; Save address of variable
            LD      DE,FRMEVL            ; Return address in EVAL
            CALL    CPDEHL               ; Called from EVAL ?
            POP     DE                   ; Restore address of variable
            JP      Z,RETNUL             ; Yes - Return null variable
            EX      (SP),HL              ; Put back return
            PUSH    HL                   ; Save code string address
            PUSH    BC                   ; Save variable name
            LD      BC,6                 ; 2 byte name plus 4 byte data
            LD      HL,(ARREND)          ; End of arrays
            PUSH    HL                   ; Save end of arrays
            ADD     HL,BC                ; Move up 6 bytes
            POP     BC                   ; Source address in BC
            PUSH    HL                   ; Save new end address
            CALL    MOVUP                ; Move arrays up
            POP     HL                   ; Restore new end address
            LD      (ARREND),HL          ; Set new end address
            LD      H,B                  ; End of variables to HL
            LD      L,C
            LD      (VAREND),HL          ; Set new end address

ZEROLP:     DEC     HL                   ; Back through to zero variable
            LD      (HL),0               ; Zero byte in variable
            CALL    CPDEHL               ; Done them all?
            JP      NZ,ZEROLP            ; No - Keep on going
            POP     DE                   ; Get variable name
            LD      (HL),E               ; Store second character
            INC     HL
            LD      (HL),D               ; Store first character
            INC     HL
RETADR:     EX      DE,HL                ; Address of variable in DE
            POP     HL                   ; Restore code string address
            RET

RETNUL:     LD      (FPEXP),A            ; Set result to zero
            LD      HL,ZERBYT            ; Also set a null string
            LD      (FPREG),HL           ; Save for EVAL
            POP     HL                   ; Restore code string address
            RET

SBSCPT:     PUSH    HL                   ; Save code string address
            LD      HL,(LCRFLG)          ; Locate/Create and Type
            EX      (SP),HL              ; Save and get code string
            LD      D,A                  ; Zero number of dimensions
SCPTLP:     PUSH    DE                   ; Save number of dimensions
            PUSH    BC                   ; Save array name
            CALL    FPSINT               ; Get subscript (0-32767)
            POP     BC                   ; Restore array name
            POP     AF                   ; Get number of dimensions
            EX      DE,HL
            EX      (SP),HL              ; Save subscript value
            PUSH    HL                   ; Save LCRFLG and TYPE
            EX      DE,HL
            INC     A                    ; Count dimensions
            LD      D,A                  ; Save in D
            LD      A,(HL)               ; Get next byte in code string
            CP      ','                  ; Comma (more to come)?
            JP      Z,SCPTLP             ; Yes - More subscripts
            CALL    CHKSYN               ; Make sure ")" follows
            DB         ")"
            LD      (NXTOPR),HL          ; Save code string address
            POP     HL                   ; Get LCRFLG and TYPE
            LD      (LCRFLG),HL          ; Restore Locate/create & type
            LD      E,0                  ; Flag not CSAVE* or CLOAD*
            PUSH    DE                   ; Save number of dimensions (D)
            DB         11H                  ; Skip "PUSH HL" and "PUSH AF'

ARLDSV:     PUSH    HL                   ; Save code string address
            PUSH    AF                   ; A = 00 , Flags set = Z,N
            LD      HL,(VAREND)          ; Start of arrays
            DB         3EH                  ; Skip "ADD HL,DE"
FNDARY:     ADD     HL,DE                ; Move to next array start
            EX      DE,HL
            LD      HL,(ARREND)          ; End of arrays
            EX      DE,HL                ; Current array pointer
            CALL    CPDEHL               ; End of arrays found?
            JP      Z,CREARY             ; Yes - Create array
            LD      A,(HL)               ; Get second byte of name
            CP      C                    ; Compare with name given
            INC     HL                   ; Move on
            JP      NZ,NXTARY            ; Different - Find next array
            LD      A,(HL)               ; Get first byte of name
            CP      B                    ; Compare with name given
NXTARY:     INC     HL                   ; Move on
            LD      E,(HL)               ; Get LSB of next array address
            INC     HL
            LD      D,(HL)               ; Get MSB of next array address
            INC     HL
            JP      NZ,FNDARY            ; Not found - Keep looking
            LD      A,(LCRFLG)           ; Found Locate or Create it?
            OR      A
            JP      NZ,DDERR             ; Create - ?DD Error
            POP     AF                   ; Locate - Get number of dim'ns
            LD      B,H                  ; BC Points to array dim'ns
            LD      C,L
            JP      Z,POPHRT             ; Jump if array load/save
            SUB     (HL)                 ; Same number of dimensions?
            JP      Z,FINDEL             ; Yes - Find element
BSERR:      LD      E,BS                 ; ?BS Error
            JP      BERROR               ; Output error

CREARY:     LD      DE,4                 ; 4 Bytes per entry
            POP     AF                   ; Array to save or 0 dim'ns?
            JP      Z,FCERR              ; Yes - ?FC Error
            LD      (HL),C               ; Save second byte of name
            INC     HL
            LD      (HL),B               ; Save first byte of name
            INC     HL
            LD      C,A                  ; Number of dimensions to C
            CALL    CHKSTK               ; Check if enough memory
            INC     HL                   ; Point to number of dimensions
            INC     HL
            LD      (CUROPR),HL          ; Save address of pointer
            LD      (HL),C               ; Set number of dimensions
            INC     HL
            LD      A,(LCRFLG)           ; Locate of Create?
            RLA                          ; Carry set = Create
            LD      A,C                  ; Get number of dimensions
CRARLP:     LD      BC,10+1              ; Default dimension size 10
            JP      NC,DEFSIZ            ; Locate - Set default size
            POP     BC                   ; Get specified dimension size
            INC     BC                   ; Include zero element
DEFSIZ:     LD      (HL),C               ; Save LSB of dimension size
            INC     HL
            LD      (HL),B               ; Save MSB of dimension size
            INC     HL
            PUSH    AF                   ; Save num' of dim'ns an status
            PUSH    HL                   ; Save address of dim'n size
            CALL    MLDEBC               ; Multiply DE by BC to find
            EX      DE,HL                ; amount of mem needed (to DE)
            POP     HL                   ; Restore address of dimension
            POP     AF                   ; Restore number of dimensions
            DEC     A                    ; Count them
            JP      NZ,CRARLP            ; Do next dimension if more
            PUSH    AF                   ; Save locate/create flag
            LD      B,D                  ; MSB of memory needed
            LD      C,E                  ; LSB of memory needed
            EX      DE,HL
            ADD     HL,DE                ; Add bytes to array start
            JP      C,OMERR              ; Too big - Error
            CALL    ENFMEM               ; See if enough memory
            LD      (ARREND),HL          ; Save new end of array

ZERARY:     DEC     HL                   ; Back through array data
            LD      (HL),0               ; Set array element to zero
            CALL    CPDEHL               ; All elements zeroed?
            JP      NZ,ZERARY            ; No - Keep on going
            INC     BC                   ; Number of bytes + 1
            LD      D,A                  ; A=0
            LD      HL,(CUROPR)          ; Get address of array
            LD      E,(HL)               ; Number of dimensions
            EX      DE,HL                ; To HL
            ADD     HL,HL                ; Two bytes per dimension size
            ADD     HL,BC                ; Add number of bytes
            EX      DE,HL                ; Bytes needed to DE
            DEC     HL
            DEC     HL
            LD      (HL),E               ; Save LSB of bytes needed
            INC     HL
            LD      (HL),D               ; Save MSB of bytes needed
            INC     HL
            POP     AF                   ; Locate / Create?
            JP      C,ENDDIM             ; A is 0 , End if create
FINDEL:     LD      B,A                  ; Find array element
            LD      C,A
            LD      A,(HL)               ; Number of dimensions
            INC     HL
            DB         16H                  ; Skip "POP HL"
FNDELP:     POP     HL                   ; Address of next dim' size
            LD      E,(HL)               ; Get LSB of dim'n size
            INC     HL
            LD      D,(HL)               ; Get MSB of dim'n size
            INC     HL
            EX      (SP),HL              ; Save address - Get index
            PUSH    AF                   ; Save number of dim'ns
            CALL    CPDEHL               ; Dimension too large?
            JP      NC,BSERR             ; Yes - ?BS Error
            PUSH    HL                   ; Save index
            CALL    MLDEBC               ; Multiply previous by size
            POP     DE                   ; Index supplied to DE
            ADD     HL,DE                ; Add index to pointer
            POP     AF                   ; Number of dimensions
            DEC     A                    ; Count them
            LD      B,H                  ; MSB of pointer
            LD      C,L                  ; LSB of pointer
            JP      NZ,FNDELP            ; More - Keep going
            ADD     HL,HL                ; 4 Bytes per element
            ADD     HL,HL
            POP     BC                   ; Start of array
            ADD     HL,BC                ; Point to element
            EX      DE,HL                ; Address of element to DE
ENDDIM:     LD      HL,(NXTOPR)          ; Got code string address
            RET

FRE:        LD      HL,(ARREND)          ; Start of free memory
            EX      DE,HL                ; To DE
            LD      HL,0                 ; End of free memory
            ADD     HL,SP                ; Current stack value
            LD      A,(TYPE)             ; Dummy argument type
            OR      A
            JP      Z,FRENUM             ; Numeric - Free variable space
            CALL    GSTRCU               ; Current string to pool
            CALL    GARBGE               ; Garbage collection
            LD      HL,(STRSPC)          ; Bottom of string space in use
            EX      DE,HL                ; To DE
            LD      HL,(STRBOT)          ; Bottom of string space
FRENUM:     LD      A,L                  ; Get LSB of end
            SUB     E                    ; Subtract LSB of beginning
            LD      C,A                  ; Save difference if C
            LD      A,H                  ; Get MSB of end
            SBC     A,D                  ; Subtract MSB of beginning
ACPASS:     LD      B,C                  ; Return integer AC
ABPASS:     LD      D,B                  ; Return integer AB
            LD      E,0
            LD      HL,TYPE              ; Point to type
            LD      (HL),E               ; Set type to numeric
            LD      B,80H+16             ; 16 bit integer
            JP      RETINT               ; Return the integr

POS:        LD      A,(CURPOS)           ; Get cursor position
PASSA:      LD      B,A                  ; Put A into AB
            XOR     A                    ; Zero A
            JP      ABPASS               ; Return integer AB

DEF:        CALL    CHEKFN               ; Get "FN" and name
            CALL    IDTEST               ; Test for illegal direct
            LD      BC,DATA              ; To get next statement
            PUSH    BC                   ; Save address for RETurn
            PUSH    DE                   ; Save address of function ptr
            CALL    CHKSYN               ; Make sure "(" follows
            DB         "("
            CALL    GETVAR               ; Get argument variable name
            PUSH    HL                   ; Save code string address
            EX      DE,HL                ; Argument address to HL
            DEC     HL
            LD      D,(HL)               ; Get first byte of arg name
            DEC     HL
            LD      E,(HL)               ; Get second byte of arg name
            POP     HL                   ; Restore code string address
            CALL    TSTNUM               ; Make sure numeric argument
            CALL    CHKSYN               ; Make sure ")" follows
            DB         ")"
            CALL    CHKSYN               ; Make sure "=" follows
            DB         ZEQUAL               ; "=" token
            LD      B,H                  ; Code string address to BC
            LD      C,L
            EX      (SP),HL              ; Save code str , Get FN ptr
            LD      (HL),C               ; Save LSB of FN code string
            INC     HL
            LD      (HL),B               ; Save MSB of FN code string
            JP      SVSTAD               ; Save address and do function

DOFN:       CALL    CHEKFN               ; Make sure FN follows
            PUSH    DE                   ; Save function pointer address
            CALL    EVLPAR               ; Evaluate expression in "()"
            CALL    TSTNUM               ; Make sure numeric result
            EX      (SP),HL              ; Save code str , Get FN ptr
            LD      E,(HL)               ; Get LSB of FN code string
            INC     HL
            LD      D,(HL)               ; Get MSB of FN code string
            INC     HL
            LD      A,D                  ; And function DEFined?
            OR      E
            JP      Z,UFERR              ; No - ?UF Error
            LD      A,(HL)               ; Get LSB of argument address
            INC     HL
            LD      H,(HL)               ; Get MSB of argument address
            LD      L,A                  ; HL = Arg variable address
            PUSH    HL                   ; Save it
            LD      HL,(FNRGNM)          ; Get old argument name
            EX      (SP),HL ;            ; Save old , Get new
            LD      (FNRGNM),HL          ; Set new argument name
            LD      HL,(FNARG+2)         ; Get LSB,NLSB of old arg value
            PUSH    HL                   ; Save it
            LD      HL,(FNARG)           ; Get MSB,EXP of old arg value
            PUSH    HL                   ; Save it
            LD      HL,FNARG             ; HL = Value of argument
            PUSH    DE                   ; Save FN code string address
            CALL    FPTHL                ; Move FPREG to argument
            POP     HL                   ; Get FN code string address
            CALL    GETNUM               ; Get value from function
            DEC     HL                   ; DEC 'cos GETCHR INCs
            CALL    GETCHR               ; Get next character
            JP      NZ,SNERR             ; Bad character in FN - Error
            POP     HL                   ; Get MSB,EXP of old arg
            LD      (FNARG),HL           ; Restore it
            POP     HL                   ; Get LSB,NLSB of old arg
            LD      (FNARG+2),HL         ; Restore it
            POP     HL                   ; Get name of old arg
            LD      (FNRGNM),HL          ; Restore it
            POP     HL                   ; Restore code string address
            RET

IDTEST:     PUSH    HL                   ; Save code string address
            LD      HL,(LINEAT)          ; Get current line number
            INC     HL                   ; -1 means direct statement
            LD      A,H
            OR      L
            POP     HL                   ; Restore code string address
            RET     NZ                   ; Return if in program
            LD      E,ID                 ; ?ID Error
            JP      BERROR

CHEKFN:     CALL    CHKSYN               ; Make sure FN follows
            DB         ZFN                  ; "FN" token
            LD      A,80H
            LD      (FORFLG),A           ; Flag FN name to find
            OR      (HL)                 ; FN name has bit 7 set
            LD      B,A                  ; in first byte of name
            CALL    GTFNAM               ; Get FN name
            JP      TSTNUM               ; Make sure numeric function

STR:        CALL    TSTNUM               ; Make sure it's a number
            CALL    NUMASC               ; Turn number into text
STR1:       CALL    CRTST                ; Create string entry for it
            CALL    GSTRCU               ; Current string to pool
            LD      BC,TOPOOL            ; Save in string pool
            PUSH    BC                   ; Save address on stack

SAVSTR:     LD      A,(HL)               ; Get string length
            INC     HL
            INC     HL
            PUSH    HL                   ; Save pointer to string
            CALL    TESTR                ; See if enough string space
            POP     HL                   ; Restore pointer to string
            LD      C,(HL)               ; Get LSB of address
            INC     HL
            LD      B,(HL)               ; Get MSB of address
            CALL    CRTMST               ; Create string entry
            PUSH    HL                   ; Save pointer to MSB of addr
            LD      L,A                  ; Length of string
            CALL    TOSTRA               ; Move to string area
            POP     DE                   ; Restore pointer to MSB
            RET

MKTMST:     CALL    TESTR                ; See if enough string space
CRTMST:     LD      HL,TMPSTR            ; Temporary string
            PUSH    HL                   ; Save it
            LD      (HL),A               ; Save length of string
            INC     HL
SVSTAD:     INC     HL
            LD      (HL),E               ; Save LSB of address
            INC     HL
            LD      (HL),D               ; Save MSB of address
            POP     HL                   ; Restore pointer
            RET

CRTST:      DEC     HL                   ; DEC - INCed after
QTSTR:      LD      B,'"'                ; Terminating quote
            LD      D,B                  ; Quote to D
DTSTR:      PUSH    HL                   ; Save start
            LD      C,-1                 ; Set counter to -1
QTSTLP:     INC     HL                   ; Move on
            LD      A,(HL)               ; Get byte
            INC     C                    ; Count bytes
            OR      A                    ; End of line?
            JP      Z,CRTSTE             ; Yes - Create string entry
            CP      D                    ; Terminator D found?
            JP      Z,CRTSTE             ; Yes - Create string entry
            CP      B                    ; Terminator B found?
            JP      NZ,QTSTLP            ; No - Keep looking
CRTSTE:     CP      '"'                  ; End with '"'?
            CALL    Z,GETCHR             ; Yes - Get next character
            EX      (SP),HL              ; Starting quote
            INC     HL                   ; First byte of string
            EX      DE,HL                ; To DE
            LD      A,C                  ; Get length
            CALL    CRTMST               ; Create string entry
TSTOPL:     LD      DE,TMPSTR            ; Temporary string
            LD      HL,(TMSTPT)          ; Temporary string pool pointer
            LD      (FPREG),HL           ; Save address of string ptr
            LD      A,1
            LD      (TYPE),A             ; Set type to string
            CALL    DETHL4               ; Move string to pool
            CALL    CPDEHL               ; Out of string pool?
            LD      (TMSTPT),HL          ; Save new pointer
            POP     HL                   ; Restore code string address
            LD      A,(HL)               ; Get next code byte
            RET     NZ                   ; Return if pool OK
            LD      E,ST                 ; ?ST Error
            JP      BERROR               ; String pool overflow

PRNUMS:     INC     HL                   ; Skip leading space
PRS:        CALL    CRTST                ; Create string entry for it
PRS1:       CALL    GSTRCU               ; Current string to pool
            CALL    LOADFP               ; Move string block to BCDE
            INC     E                    ; Length + 1
PRSLP:      DEC     E                    ; Count characters
            RET     Z                    ; End of string
            LD      A,(BC)               ; Get byte to output
            CALL    OUTC                 ; Output character in A
            CP      CR                   ; Return?
            CALL    Z,DONULL             ; Yes - Do nulls
            INC     BC                   ; Next byte in string
            JP      PRSLP                ; More characters to output

TESTR:      OR      A                    ; Test if enough room
            DB         0EH                  ; No garbage collection done
GRBDON:     POP     AF                   ; Garbage collection done
            PUSH    AF                   ; Save status
            LD      HL,(STRSPC)          ; Bottom of string space in use
            EX      DE,HL                ; To DE
            LD      HL,(STRBOT)          ; Bottom of string area
            CPL                          ; Negate length (Top down)
            LD      C,A                  ; -Length to BC
            LD      B,-1                 ; BC = -ve length of string
            ADD     HL,BC                ; Add to bottom of space in use
            INC     HL                   ; Plus one for 2's complement
            CALL    CPDEHL               ; Below string RAM area?
            JP      C,TESTOS             ; Tidy up if not done else err
            LD      (STRBOT),HL          ; Save new bottom of area
            INC     HL                   ; Point to first byte of string
            EX      DE,HL                ; Address to DE
POPAF:      POP     AF                   ; Throw away status push
            RET

TESTOS:     POP     AF                   ; Garbage collect been done?
            LD      E,OS                 ; ?OS Error
            JP      Z,BERROR             ; Yes - Not enough string apace
            CP      A                    ; Flag garbage collect done
            PUSH    AF                   ; Save status
            LD      BC,GRBDON            ; Garbage collection done
            PUSH    BC                   ; Save for RETurn
GARBGE:     LD      HL,(LSTRAM)          ; Get end of RAM pointer
GARBLP:     LD      (STRBOT),HL          ; Reset string pointer
            LD      HL,0
            PUSH    HL                   ; Flag no string found
            LD      HL,(STRSPC)          ; Get bottom of string space
            PUSH    HL                   ; Save bottom of string space
            LD      HL,TMSTPL            ; Temporary string pool
GRBLP:      EX      DE,HL
            LD      HL,(TMSTPT)          ; Temporary string pool pointer
            EX      DE,HL
            CALL    CPDEHL               ; Temporary string pool done?
            LD      BC,GRBLP             ; Loop until string pool done
            JP      NZ,STPOOL            ; No - See if in string area
            LD      HL,(PROGND)          ; Start of simple variables
SMPVAR:     EX      DE,HL
            LD      HL,(VAREND)          ; End of simple variables
            EX      DE,HL
            CALL    CPDEHL               ; All simple strings done?
            JP      Z,ARRLP              ; Yes - Do string arrays
            LD      A,(HL)               ; Get type of variable
            INC     HL
            INC     HL
            OR      A                    ; "S" flag set if string
            CALL    STRADD               ; See if string in string area
            JP      SMPVAR               ; Loop until simple ones done

GNXARY:     POP     BC                   ; Scrap address of this array
ARRLP:      EX      DE,HL
            LD      HL,(ARREND)          ; End of string arrays
            EX      DE,HL
            CALL    CPDEHL               ; All string arrays done?
            JP      Z,SCNEND             ; Yes - Move string if found
            CALL    LOADFP               ; Get array name to BCDE
            LD      A,E                  ; Get type of array     
            PUSH    HL                   ; Save address of num of dim'ns
            ADD     HL,BC                ; Start of next array
            OR      A                    ; Test type of array
            JP      P,GNXARY             ; Numeric array - Ignore it
            LD      (CUROPR),HL          ; Save address of next array
            POP     HL                   ; Get address of num of dim'ns
            LD      C,(HL)               ; BC = Number of dimensions
            LD      B,0
            ADD     HL,BC                ; Two bytes per dimension size
            ADD     HL,BC
            INC     HL                   ; Plus one for number of dim'ns
GRBARY:     EX      DE,HL
            LD      HL,(CUROPR)          ; Get address of next array
            EX      DE,HL
            CALL    CPDEHL               ; Is this array finished?
            JP      Z,ARRLP              ; Yes - Get next one
            LD      BC,GRBARY            ; Loop until array all done
STPOOL:     PUSH    BC                   ; Save return address
            OR      80H                  ; Flag string type
STRADD:     LD      A,(HL)               ; Get string length
            INC     HL
            INC     HL
            LD      E,(HL)               ; Get LSB of string address
            INC     HL
            LD      D,(HL)               ; Get MSB of string address
            INC     HL
            RET     P                    ; Not a string - Return
            OR      A                    ; Set flags on string length
            RET     Z                    ; Null string - Return
            LD      B,H                  ; Save variable pointer
            LD      C,L
            LD      HL,(STRBOT)          ; Bottom of new area
            CALL    CPDEHL               ; String been done?
            LD      H,B                  ; Restore variable pointer
            LD      L,C
            RET     C                    ; String done - Ignore
            POP     HL                   ; Return address
            EX      (SP),HL              ; Lowest available string area
            CALL    CPDEHL               ; String within string area?
            EX      (SP),HL              ; Lowest available string area
            PUSH    HL                   ; Re-save return address
            LD      H,B                  ; Restore variable pointer
            LD      L,C
            RET     NC                   ; Outside string area - Ignore
            POP     BC                   ; Get return , Throw 2 away
            POP     AF                   ; 
            POP     AF                   ; 
            PUSH    HL                   ; Save variable pointer
            PUSH    DE                   ; Save address of current
            PUSH    BC                   ; Put back return address
            RET                          ; Go to it

SCNEND:     POP     DE                   ; Addresses of strings
            POP     HL                   ; 
            LD      A,L                  ; HL = 0 if no more to do
            OR      H
            RET     Z                    ; No more to do - Return
            DEC     HL
            LD      B,(HL)               ; MSB of address of string
            DEC     HL
            LD      C,(HL)               ; LSB of address of string
            PUSH    HL                   ; Save variable address
            DEC     HL
            DEC     HL
            LD      L,(HL)               ; HL = Length of string
            LD      H,0
            ADD     HL,BC                ; Address of end of string+1
            LD      D,B                  ; String address to DE
            LD      E,C
            DEC     HL                   ; Last byte in string
            LD      B,H                  ; Address to BC
            LD      C,L
            LD      HL,(STRBOT)          ; Current bottom of string area
            CALL    MOVSTR               ; Move string to new address
            POP     HL                   ; Restore variable address
            LD      (HL),C               ; Save new LSB of address
            INC     HL
            LD      (HL),B               ; Save new MSB of address
            LD      L,C                  ; Next string area+1 to HL
            LD      H,B
            DEC     HL                   ; Next string area address
            JP      GARBLP               ; Look for more strings

CONCAT:     PUSH    BC                   ; Save prec' opr & code string
            PUSH    HL                   ; 
            LD      HL,(FPREG)           ; Get first string
            EX      (SP),HL              ; Save first string
            CALL    OPRND                ; Get second string
            EX      (SP),HL              ; Restore first string
            CALL    TSTSTR               ; Make sure it's a string
            LD      A,(HL)               ; Get length of second string
            PUSH    HL                   ; Save first string
            LD      HL,(FPREG)           ; Get second string
            PUSH    HL                   ; Save second string
            ADD     A,(HL)               ; Add length of second string
            LD      E,LS                 ; ?LS Error
            JP      C,BERROR             ; String too long - Error
            CALL    MKTMST               ; Make temporary string
            POP     DE                   ; Get second string to DE
            CALL    GSTRDE               ; Move to string pool if needed
            EX      (SP),HL              ; Get first string
            CALL    GSTRHL               ; Move to string pool if needed
            PUSH    HL                   ; Save first string
            LD      HL,(TMPSTR+2)        ; Temporary string address
            EX      DE,HL                ; To DE
            CALL    SSTSA                ; First string to string area
            CALL    SSTSA                ; Second string to string area
            LD      HL,EVAL2             ; Return to evaluation loop
            EX      (SP),HL              ; Save return,get code string
            PUSH    HL                   ; Save code string address
            JP      TSTOPL               ; To temporary string to pool

SSTSA:      POP     HL                   ; Return address
            EX      (SP),HL              ; Get string block,save return
            LD      A,(HL)               ; Get length of string
            INC     HL
            INC     HL
            LD      C,(HL)               ; Get LSB of string address
            INC     HL
            LD      B,(HL)               ; Get MSB of string address
            LD      L,A                  ; Length to L
TOSTRA:     INC     L                    ; INC - DECed after
TSALP:      DEC     L                    ; Count bytes moved
            RET     Z                    ; End of string - Return
            LD      A,(BC)               ; Get source
            LD      (DE),A               ; Save destination
            INC     BC                   ; Next source
            INC     DE                   ; Next destination
            JP      TSALP                ; Loop until string moved

GETSTR:     CALL    TSTSTR               ; Make sure it's a string
GSTRCU:     LD      HL,(FPREG)           ; Get current string
GSTRHL:     EX      DE,HL                ; Save DE
GSTRDE:     CALL    BAKTMP               ; Was it last tmp-str?
            EX      DE,HL                ; Restore DE
            RET     NZ                   ; No - Return
            PUSH    DE                   ; Save string
            LD      D,B                  ; String block address to DE
            LD      E,C
            DEC     DE                   ; Point to length
            LD      C,(HL)               ; Get string length
            LD      HL,(STRBOT)          ; Current bottom of string area
            CALL    CPDEHL               ; Last one in string area?
            JP      NZ,POPHL             ; No - Return
            LD      B,A                  ; Clear B (A=0)
            ADD     HL,BC                ; Remove string from str' area
            LD      (STRBOT),HL          ; Save new bottom of str' area
POPHL:      POP     HL                   ; Restore string
            RET

BAKTMP:     LD      HL,(TMSTPT)          ; Get temporary string pool top
            DEC     HL                   ; Back
            LD      B,(HL)               ; Get MSB of address
            DEC     HL                   ; Back
            LD      C,(HL)               ; Get LSB of address
            DEC     HL                   ; Back
            DEC     HL                   ; Back
            CALL    CPDEHL               ; String last in string pool?
            RET     NZ                   ; Yes - Leave it
            LD      (TMSTPT),HL          ; Save new string pool top
            RET

LEN:        LD      BC,PASSA             ; To return integer A
            PUSH    BC                   ; Save address
GETLEN:     CALL    GETSTR               ; Get string and its length
            XOR     A
            LD      D,A                  ; Clear D
            LD      (TYPE),A             ; Set type to numeric
            LD      A,(HL)               ; Get length of string
            OR      A                    ; Set status flags
            RET

ASC:        LD      BC,PASSA             ; To return integer A
            PUSH    BC                   ; Save address
GTFLNM:     CALL    GETLEN               ; Get length of string
            JP      Z,FCERR              ; Null string - Error
            INC     HL
            INC     HL
            LD      E,(HL)               ; Get LSB of address
            INC     HL
            LD      D,(HL)               ; Get MSB of address
            LD      A,(DE)               ; Get first byte of string
            RET

CHR:        LD      A,1                  ; One character string
            CALL    MKTMST               ; Make a temporary string
            CALL    MAKINT               ; Make it integer A
            LD      HL,(TMPSTR+2)        ; Get address of string
            LD      (HL),E               ; Save character
TOPOOL:     POP     BC                   ; Clean up stack
            JP      TSTOPL               ; Temporary string to pool

LEFT:       CALL    LFRGNM               ; Get number and ending ")"
            XOR     A                    ; Start at first byte in string
RIGHT1:     EX      (SP),HL              ; Save code string,Get string
            LD      C,A                  ; Starting position in string
MID1:       PUSH    HL                   ; Save string block address
            LD      A,(HL)               ; Get length of string
            CP      B                    ; Compare with number given
            JP      C,ALLFOL             ; All following bytes required
            LD      A,B                  ; Get new length
            DB         11H                  ; Skip "LD C,0"
ALLFOL:     LD      C,0                  ; First byte of string
            PUSH    BC                   ; Save position in string
            CALL    TESTR                ; See if enough string space
            POP     BC                   ; Get position in string
            POP     HL                   ; Restore string block address
            PUSH    HL                   ; And re-save it
            INC     HL
            INC     HL
            LD      B,(HL)               ; Get LSB of address
            INC     HL
            LD      H,(HL)               ; Get MSB of address
            LD      L,B                  ; HL = address of string
            LD      B,0                  ; BC = starting address
            ADD     HL,BC                ; Point to that byte
            LD      B,H                  ; BC = source string
            LD      C,L
            CALL    CRTMST               ; Create a string entry
            LD      L,A                  ; Length of new string
            CALL    TOSTRA               ; Move string to string area
            POP     DE                   ; Clear stack
            CALL    GSTRDE               ; Move to string pool if needed
            JP      TSTOPL               ; Temporary string to pool

RIGHT:      CALL    LFRGNM               ; Get number and ending ")"
            POP     DE                   ; Get string length
            PUSH    DE                   ; And re-save
            LD      A,(DE)               ; Get length
            SUB     B                    ; Move back N bytes
            JP      RIGHT1               ; Go and get sub-string

MID:        EX      DE,HL                ; Get code string address
            LD      A,(HL)               ; Get next byte ',' or ")"
            CALL    MIDNUM               ; Get number supplied
            INC     B                    ; Is it character zero?
            DEC     B
            JP      Z,FCERR              ; Yes - Error
            PUSH    BC                   ; Save starting position
            LD      E,255                ; All of string
            CP      ')'                  ; Any length given?
            JP      Z,RSTSTR             ; No - Rest of string
            CALL    CHKSYN               ; Make sure ',' follows
            DB         ','
            CALL    GETINT               ; Get integer 0-255
RSTSTR:     CALL    CHKSYN               ; Make sure ")" follows
            DB         ")"
            POP     AF                   ; Restore starting position
            EX      (SP),HL              ; Get string,8ave code string
            LD      BC,MID1              ; Continuation of MID$ routine
            PUSH    BC                   ; Save for return
            DEC     A                    ; Starting position-1
            CP      (HL)                 ; Compare with length
            LD      B,0                  ; Zero bytes length
            RET     NC                   ; Null string if start past end
            LD      C,A                  ; Save starting position-1
            LD      A,(HL)               ; Get length of string
            SUB     C                    ; Subtract start
            CP      E                    ; Enough string for it?
            LD      B,A                  ; Save maximum length available
            RET     C                    ; Truncate string if needed
            LD      B,E                  ; Set specified length
            RET                          ; Go and create string

VAL:        CALL    GETLEN               ; Get length of string
            JP      Z,RESZER             ; Result zero
            LD      E,A                  ; Save length
            INC     HL
            INC     HL
            LD      A,(HL)               ; Get LSB of address
            INC     HL
            LD      H,(HL)               ; Get MSB of address
            LD      L,A                  ; HL = String address
            PUSH    HL                   ; Save string address
            ADD     HL,DE
            LD      B,(HL)               ; Get end of string+1 byte
            LD      (HL),D               ; Zero it to terminate
            EX      (SP),HL              ; Save string end,get start
            PUSH    BC                   ; Save end+1 byte
            LD      A,(HL)               ; Get starting byte
            CP      '$'                  ; Hex number indicated? [function added G. Searle]
            JP      NZ,VAL1
            CALL    HEXTFP               ; Convert Hex to FPREG
            JR      VAL3
VAL1:       CP      '%'                  ; Binary number indicated? [function added]
            JP      NZ,VAL2
            CALL    BINTFP               ; Convert Bin to FPREG
            JR      VAL3
VAL2:       CALL    ASCTFP               ; Convert ASCII string to FP
VAL3:       POP     BC                   ; Restore end+1 byte
            POP     HL                   ; Restore end+1 address
            LD      (HL),B               ; Put back original byte
            RET

LFRGNM:     EX      DE,HL                ; Code string address to HL
            CALL    CHKSYN               ; Make sure ")" follows
            DB      ")"
MIDNUM:     POP     BC                   ; Get return address
            POP     DE                   ; Get number supplied
            PUSH    BC                   ; Re-save return address
            LD      B,E                  ; Number to B
            RET

INP:        CALL    MAKINT               ; Make it integer A
            LD      (INPORT),A           ; Set input port
            CALL    INPSUB               ; Get input from port
            JP      PASSA                ; Return integer A

POUT:       CALL    SETIO                ; Set up port number
            JP      OUTSUB               ; Output data and return

WAIT:       CALL    SETIO                ; Set up port number
            PUSH    AF                   ; Save AND mask
            LD      E,0                  ; Assume zero if none given
            DEC     HL                   ; DEC 'cos GETCHR INCs
            CALL    GETCHR               ; Get next character
            JP      Z,NOXOR              ; No XOR byte given
            CALL    CHKSYN               ; Make sure ',' follows
            DB      ','
            CALL    GETINT               ; Get integer 0-255 to XOR with
NOXOR:      POP     BC                   ; Restore AND mask
WAITLP:     CALL    INPSUB               ; Get input
            XOR     E                    ; Flip selected bits
            AND     B                    ; Result non-zero?
            JP      Z,WAITLP             ; No = keep waiting
            RET

SETIO:      CALL    GETINT               ; Get integer 0-255
            LD      (INPORT),A           ; Set input port
            LD      (OTPORT),A           ; Set output port
            CALL    CHKSYN               ; Make sure ',' follows
            DB      ','
            JP      GETINT               ; Get integer 0-255 and return

FNDNUM:     CALL    GETCHR               ; Get next character
GETINT:     CALL    GETNUM               ; Get a number from 0 to 255
MAKINT:     CALL    DEPINT               ; Make sure value 0 - 255
            LD      A,D                  ; Get MSB of number
            OR      A                    ; Zero?
            JP      NZ,FCERR             ; No - Error
            DEC     HL                   ; DEC 'cos GETCHR INCs
            CALL    GETCHR               ; Get next character
            LD      A,E                  ; Get number to A
            RET

PEEK:       CALL    DEINT                ; Get memory address
            LD      A,(DE)               ; Get byte in memory
            JP      PASSA                ; Return integer A

POKE:       CALL    GETNUM               ; Get memory address
            CALL    DEINT                ; Get integer -32768 to 3276
            PUSH    DE                   ; Save memory address
            CALL    CHKSYN               ; Make sure ',' follows
            DB      ','
            CALL    GETINT               ; Get integer 0-255
            POP     DE                   ; Restore memory address
            LD      (DE),A               ; Load it into memory
            RET

ROUND:      LD      HL,HALF              ; Add 0.5 to FPREG
ADDPHL:     CALL    LOADFP               ; Load FP at (HL) to BCDE
            JP      FPADD                ; Add BCDE to FPREG

SUBPHL:     CALL    LOADFP               ; FPREG = -FPREG + number at HL
            DB         21H                  ; Skip "POP BC" and "POP DE"
PSUB:       POP     BC                   ; Get FP number from stack
            POP     DE
SUBCDE:     CALL    INVSGN               ; Negate FPREG
FPADD:      LD      A,B                  ; Get FP exponent
            OR      A                    ; Is number zero?
            RET     Z                    ; Yes - Nothing to add
            LD      A,(FPEXP)            ; Get FPREG exponent
            OR      A                    ; Is this number zero?
            JP      Z,FPBCDE             ; Yes - Move BCDE to FPREG
            SUB     B                    ; BCDE number larger?
            JP      NC,NOSWAP            ; No - Don't swap them
            CPL                          ; Two's complement
            INC     A                    ;  FP exponent
            EX      DE,HL
            CALL    STAKFP               ; Put FPREG on stack
            EX      DE,HL
            CALL    FPBCDE               ; Move BCDE to FPREG
            POP     BC                   ; Restore number from stack
            POP     DE
NOSWAP:     CP      24+1                 ; Second number insignificant?
            RET     NC                   ; Yes - First number is result
            PUSH    AF                   ; Save number of bits to scale
            CALL    SIGNS                ; Set MSBs & sign of result
            LD      H,A                  ; Save sign of result
            POP     AF                   ; Restore scaling factor
            CALL    SCALE                ; Scale BCDE to same exponent
            OR      H                    ; Result to be positive?
            LD      HL,FPREG             ; Point to FPREG
            JP      P,MINCDE             ; No - Subtract FPREG from CDE
            CALL    PLUCDE               ; Add FPREG to CDE
            JP      NC,RONDUP            ; No overflow - Round it up
            INC     HL                   ; Point to exponent
            INC     (HL)                 ; Increment it
            JP      Z,OVERR              ; Number overflowed - Error
            LD      L,1                  ; 1 bit to shift right
            CALL    SHRT1                ; Shift result right
            JP      RONDUP               ; Round it up

MINCDE:     XOR     A                    ; Clear A and carry
            SUB     B                    ; Negate exponent
            LD      B,A                  ; Re-save exponent
            LD      A,(HL)               ; Get LSB of FPREG
            SBC     A, E                 ; Subtract LSB of BCDE
            LD      E,A                  ; Save LSB of BCDE
            INC     HL
            LD      A,(HL)               ; Get NMSB of FPREG
            SBC     A,D                  ; Subtract NMSB of BCDE
            LD      D,A                  ; Save NMSB of BCDE
            INC     HL
            LD      A,(HL)               ; Get MSB of FPREG
            SBC     A,C                  ; Subtract MSB of BCDE
            LD      C,A                  ; Save MSB of BCDE
CONPOS:     CALL    C,COMPL              ; Overflow - Make it positive

BNORM:      LD      L,B                  ; L = Exponent
            LD      H,E                  ; H = LSB
            XOR     A
BNRMLP:     LD      B,A                  ; Save bit count
            LD      A,C                  ; Get MSB
            OR      A                    ; Is it zero?
            JP      NZ,PNORM             ; No - Do it bit at a time
            LD      C,D                  ; MSB = NMSB
            LD      D,H                  ; NMSB= LSB
            LD      H,L                  ; LSB = VLSB
            LD      L,A                  ; VLSB= 0
            LD      A,B                  ; Get exponent
            SUB     8                    ; Count 8 bits
            CP      -24-8                ; Was number zero?
            JP      NZ,BNRMLP            ; No - Keep normalising
RESZER:     XOR     A                    ; Result is zero
SAVEXP:     LD      (FPEXP),A            ; Save result as zero
            RET

NORMAL:     DEC     B                    ; Count bits
            ADD     HL,HL                ; Shift HL left
            LD      A,D                  ; Get NMSB
            RLA                          ; Shift left with last bit
            LD      D,A                  ; Save NMSB
            LD      A,C                  ; Get MSB
            ADC     A,A                  ; Shift left with last bit
            LD      C,A                  ; Save MSB
PNORM:      JP      P,NORMAL             ; Not done - Keep going
            LD      A,B                  ; Number of bits shifted
            LD      E,H                  ; Save HL in EB
            LD      B,L
            OR      A                    ; Any shifting done?
            JP      Z,RONDUP             ; No - Round it up
            LD      HL,FPEXP             ; Point to exponent
            ADD     A,(HL)               ; Add shifted bits
            LD      (HL),A               ; Re-save exponent
            JP      NC,RESZER            ; Underflow - Result is zero
            RET     Z                    ; Result is zero
RONDUP:     LD      A,B                  ; Get VLSB of number
RONDB:      LD      HL,FPEXP             ; Point to exponent
            OR      A                    ; Any rounding?
            CALL    M,FPROND             ; Yes - Round number up
            LD      B,(HL)               ; B = Exponent
            INC     HL
            LD      A,(HL)               ; Get sign of result
            AND     10000000B            ; Only bit 7 needed
            XOR     C                    ; Set correct sign
            LD      C,A                  ; Save correct sign in number
            JP      FPBCDE               ; Move BCDE to FPREG

FPROND:     INC     E                    ; Round LSB
            RET     NZ                   ; Return if ok
            INC     D                    ; Round NMSB
            RET     NZ                   ; Return if ok
            INC     C                    ; Round MSB
            RET     NZ                   ; Return if ok
            LD      C,80H                ; Set normal value
            INC     (HL)                 ; Increment exponent
            RET     NZ                   ; Return if ok
            JP      OVERR                ; Overflow error

PLUCDE:     LD      A,(HL)               ; Get LSB of FPREG
            ADD     A,E                  ; Add LSB of BCDE
            LD      E,A                  ; Save LSB of BCDE
            INC     HL
            LD      A,(HL)               ; Get NMSB of FPREG
            ADC     A,D                  ; Add NMSB of BCDE
            LD      D,A                  ; Save NMSB of BCDE
            INC     HL
            LD      A,(HL)               ; Get MSB of FPREG
            ADC     A,C                  ; Add MSB of BCDE
            LD      C,A                  ; Save MSB of BCDE
            RET

COMPL:      LD      HL,SGNRES            ; Sign of result
            LD      A,(HL)               ; Get sign of result
            CPL                          ; Negate it
            LD      (HL),A               ; Put it back
            XOR     A
            LD      L,A                  ; Set L to zero
            SUB     B                    ; Negate exponent,set carry
            LD      B,A                  ; Re-save exponent
            LD      A,L                  ; Load zero
            SBC     A,E                  ; Negate LSB
            LD      E,A                  ; Re-save LSB
            LD      A,L                  ; Load zero
            SBC     A,D                  ; Negate NMSB
            LD      D,A                  ; Re-save NMSB
            LD      A,L                  ; Load zero
            SBC     A,C                  ; Negate MSB
            LD      C,A                  ; Re-save MSB
            RET

SCALE:      LD      B,0                  ; Clear underflow
SCALLP:     SUB     8                    ; 8 bits (a whole byte)?
            JP      C,SHRITE             ; No - Shift right A bits
            LD      B,E                  ; <- Shift
            LD      E,D                  ; <- right
            LD      D,C                  ; <- eight
            LD      C,0                  ; <- bits
            JP      SCALLP               ; More bits to shift

SHRITE:     ADD     A,8+1                ; Adjust count
            LD      L,A                  ; Save bits to shift
SHRLP:      XOR     A                    ; Flag for all done
            DEC     L                    ; All shifting done?
            RET     Z                    ; Yes - Return
            LD      A,C                  ; Get MSB
SHRT1:      RRA                          ; Shift it right
            LD      C,A                  ; Re-save
            LD      A,D                  ; Get NMSB
            RRA                          ; Shift right with last bit
            LD      D,A                  ; Re-save it
            LD      A,E                  ; Get LSB
            RRA                          ; Shift right with last bit
            LD      E,A                  ; Re-save it
            LD      A,B                  ; Get underflow
            RRA                          ; Shift right with last bit
            LD      B,A                  ; Re-save underflow
            JP      SHRLP                ; More bits to do

UNITY:      DB      000H,000H,000H,081H  ; 1.00000

LOGTAB:     DB      3                    ; Table used by LOG
            DB      0AAH,056H,019H,080H  ; 0.59898
            DB      0F1H,022H,076H,080H  ; 0.96147
            DB      045H,0AAH,038H,082H  ; 2.88539

LOG:        CALL    TSTSGN               ; Test sign of value
            OR      A
            JP      PE,FCERR             ; ?FC Error if <= zero
            LD      HL,FPEXP             ; Point to exponent
            LD      A,(HL)               ; Get exponent
            LD      BC,8035H             ; BCDE = SQR(1/2)
            LD      DE,04F3H
            SUB     B                    ; Scale value to be < 1
            PUSH    AF                   ; Save scale factor
            LD      (HL),B               ; Save new exponent
            PUSH    DE                   ; Save SQR(1/2)
            PUSH    BC
            CALL    FPADD                ; Add SQR(1/2) to value
            POP     BC                   ; Restore SQR(1/2)
            POP     DE
            INC     B                    ; Make it SQR(2)
            CALL    DVBCDE               ; Divide by SQR(2)
            LD      HL,UNITY             ; Point to 1.
            CALL    SUBPHL               ; Subtract FPREG from 1
            LD      HL,LOGTAB            ; Coefficient table
            CALL    SUMSER               ; Evaluate sum of series
            LD      BC,8080H             ; BCDE = -0.5
            LD      DE,0000H
            CALL    FPADD                ; Subtract 0.5 from FPREG
            POP     AF                   ; Restore scale factor
            CALL    RSCALE               ; Re-scale number
MULLN2:     LD      BC,8031H             ; BCDE = Ln(2)
            LD      DE,7218H
            DB         21H                  ; Skip "POP BC" and "POP DE"

MULT:       POP     BC                   ; Get number from stack
            POP     DE
FPMULT:     CALL    TSTSGN               ; Test sign of FPREG
            RET     Z                    ; Return zero if zero
            LD      L,0                  ; Flag add exponents
            CALL    ADDEXP               ; Add exponents
            LD      A,C                  ; Get MSB of multiplier
            LD      (MULVAL),A           ; Save MSB of multiplier
            EX      DE,HL
            LD      (MULVAL+1),HL        ; Save rest of multiplier
            LD      BC,0                 ; Partial product (BCDE) = zero
            LD      D,B
            LD      E,B
            LD      HL,BNORM             ; Address of normalise
            PUSH    HL                   ; Save for return
            LD      HL,MULT8             ; Address of 8 bit multiply
            PUSH    HL                   ; Save for NMSB,MSB
            PUSH    HL                   ; 
            LD      HL,FPREG             ; Point to number
MULT8:      LD      A,(HL)               ; Get LSB of number
            INC     HL                   ; Point to NMSB
            OR      A                    ; Test LSB
            JP      Z,BYTSFT             ; Zero - shift to next byte
            PUSH    HL                   ; Save address of number
            LD      L,8                  ; 8 bits to multiply by
MUL8LP:     RRA                          ; Shift LSB right
            LD      H,A                  ; Save LSB
            LD      A,C                  ; Get MSB
            JP      NC,NOMADD            ; Bit was zero - Don't add
            PUSH    HL                   ; Save LSB and count
            LD      HL,(MULVAL+1)        ; Get LSB and NMSB
            ADD     HL,DE                ; Add NMSB and LSB
            EX      DE,HL                ; Leave sum in DE
            POP     HL                   ; Restore MSB and count
            LD      A,(MULVAL)           ; Get MSB of multiplier
            ADC     A,C                  ; Add MSB
NOMADD:     RRA                          ; Shift MSB right
            LD      C,A                  ; Re-save MSB
            LD      A,D                  ; Get NMSB
            RRA                          ; Shift NMSB right
            LD      D,A                  ; Re-save NMSB
            LD      A,E                  ; Get LSB
            RRA                          ; Shift LSB right
            LD      E,A                  ; Re-save LSB
            LD      A,B                  ; Get VLSB
            RRA                          ; Shift VLSB right
            LD      B,A                  ; Re-save VLSB
            DEC     L                    ; Count bits multiplied
            LD      A,H                  ; Get LSB of multiplier
            JP      NZ,MUL8LP            ; More - Do it
POPHRT:     POP     HL                   ; Restore address of number
            RET

BYTSFT:     LD      B,E                  ; Shift partial product left
            LD      E,D
            LD      D,C
            LD      C,A
            RET

DIV10:      CALL    STAKFP               ; Save FPREG on stack
            LD      BC,8420H             ; BCDE = 10.
            LD      DE,0000H
            CALL    FPBCDE               ; Move 10 to FPREG

DIV:        POP     BC                   ; Get number from stack
            POP     DE
DVBCDE:     CALL    TSTSGN               ; Test sign of FPREG
            JP      Z,DZERR              ; Error if division by zero
            LD      L,-1                 ; Flag subtract exponents
            CALL    ADDEXP               ; Subtract exponents
            INC     (HL)                 ; Add 2 to exponent to adjust
            INC     (HL)
            DEC     HL                   ; Point to MSB
            LD      A,(HL)               ; Get MSB of dividend
            LD      (DIV3),A             ; Save for subtraction
            DEC     HL
            LD      A,(HL)               ; Get NMSB of dividend
            LD      (DIV2),A             ; Save for subtraction
            DEC     HL
            LD      A,(HL)               ; Get MSB of dividend
            LD      (DIV1),A             ; Save for subtraction
            LD      B,C                  ; Get MSB
            EX      DE,HL                ; NMSB,LSB to HL
            XOR     A
            LD      C,A                  ; Clear MSB of quotient
            LD      D,A                  ; Clear NMSB of quotient
            LD      E,A                  ; Clear LSB of quotient
            LD      (DIV4),A             ; Clear overflow count
DIVLP:      PUSH    HL                   ; Save divisor
            PUSH    BC
            LD      A,L                  ; Get LSB of number
            CALL    DIVSUP               ; Subt' divisor from dividend
            SBC     A,0                  ; Count for overflows
            CCF
            JP      NC,RESDIV            ; Restore divisor if borrow
            LD      (DIV4),A             ; Re-save overflow count
            POP     AF                   ; Scrap divisor
            POP     AF
            SCF                          ; Set carry to
            DB         0D2H                 ; Skip "POP BC" and "POP HL"

RESDIV:     POP     BC                   ; Restore divisor
            POP     HL
            LD      A,C                  ; Get MSB of quotient
            INC     A
            DEC     A
            RRA                          ; Bit 0 to bit 7
            JP      M,RONDB              ; Done - Normalise result
            RLA                          ; Restore carry
            LD      A,E                  ; Get LSB of quotient
            RLA                          ; Double it
            LD      E,A                  ; Put it back
            LD      A,D                  ; Get NMSB of quotient
            RLA                          ; Double it
            LD      D,A                  ; Put it back
            LD      A,C                  ; Get MSB of quotient
            RLA                          ; Double it
            LD      C,A                  ; Put it back
            ADD     HL,HL                ; Double NMSB,LSB of divisor
            LD      A,B                  ; Get MSB of divisor
            RLA                          ; Double it
            LD      B,A                  ; Put it back
            LD      A,(DIV4)             ; Get VLSB of quotient
            RLA                          ; Double it
            LD      (DIV4),A             ; Put it back
            LD      A,C                  ; Get MSB of quotient
            OR      D                    ; Merge NMSB
            OR      E                    ; Merge LSB
            JP      NZ,DIVLP             ; Not done - Keep dividing
            PUSH    HL                   ; Save divisor
            LD      HL,FPEXP             ; Point to exponent
            DEC     (HL)                 ; Divide by 2
            POP     HL                   ; Restore divisor
            JP      NZ,DIVLP             ; Ok - Keep going
            JP      OVERR                ; Overflow error

ADDEXP:     LD      A,B                  ; Get exponent of dividend
            OR      A                    ; Test it
            JP      Z,OVTST3             ; Zero - Result zero
            LD      A,L                  ; Get add/subtract flag
            LD      HL,FPEXP             ; Point to exponent
            XOR     (HL)                 ; Add or subtract it
            ADD     A,B                  ; Add the other exponent
            LD      B,A                  ; Save new exponent
            RRA                          ; Test exponent for overflow
            XOR     B
            LD      A,B                  ; Get exponent
            JP      P,OVTST2             ; Positive - Test for overflow
            ADD     A,80H                ; Add excess 128
            LD      (HL),A               ; Save new exponent
            JP      Z,POPHRT             ; Zero - Result zero
            CALL    SIGNS                ; Set MSBs and sign of result
            LD      (HL),A               ; Save new exponent
            DEC     HL                   ; Point to MSB
            RET

OVTST1:     CALL    TSTSGN               ; Test sign of FPREG
            CPL                          ; Invert sign
            POP     HL                   ; Clean up stack
OVTST2:     OR      A                    ; Test if new exponent zero
OVTST3:     POP     HL                   ; Clear off return address
            JP      P,RESZER             ; Result zero
            JP      OVERR                ; Overflow error

MLSP10:     CALL    BCDEFP               ; Move FPREG to BCDE
            LD      A,B                  ; Get exponent
            OR      A                    ; Is it zero?
            RET     Z                    ; Yes - Result is zero
            ADD     A,2                  ; Multiply by 4
            JP      C,OVERR              ; Overflow - ?OV Error
            LD      B,A                  ; Re-save exponent
            CALL    FPADD                ; Add BCDE to FPREG (Times 5)
            LD      HL,FPEXP             ; Point to exponent
            INC     (HL)                 ; Double number (Times 10)
            RET     NZ                   ; Ok - Return
            JP      OVERR                ; Overflow error

TSTSGN:     LD      A,(FPEXP)            ; Get sign of FPREG
            OR      A
            RET     Z                    ; RETurn if number is zero
            LD      A,(FPREG+2)          ; Get MSB of FPREG
            DB         0FEH                 ; Test sign
RETREL:     CPL                          ; Invert sign
            RLA                          ; Sign bit to carry
FLGDIF:     SBC     A,A                  ; Carry to all bits of A
            RET     NZ                   ; Return -1 if negative
            INC     A                    ; Bump to +1
            RET                          ; Positive - Return +1

SGN:        CALL    TSTSGN               ; Test sign of FPREG
FLGREL:     LD      B,80H+8              ; 8 bit integer in exponent
            LD      DE,0                 ; Zero NMSB and LSB
RETINT:     LD      HL,FPEXP             ; Point to exponent
            LD      C,A                  ; CDE = MSB,NMSB and LSB
            LD      (HL),B               ; Save exponent
            LD      B,0                  ; CDE = integer to normalise
            INC     HL                   ; Point to sign of result
            LD      (HL),80H             ; Set sign of result
            RLA                          ; Carry = sign of integer
            JP      CONPOS               ; Set sign of result

ABS:        CALL    TSTSGN               ; Test sign of FPREG
            RET     P                    ; Return if positive
INVSGN:     LD      HL,FPREG+2           ; Point to MSB
            LD      A,(HL)               ; Get sign of mantissa
            XOR     80H                  ; Invert sign of mantissa
            LD      (HL),A               ; Re-save sign of mantissa
            RET

STAKFP:     EX      DE,HL                ; Save code string address
            LD      HL,(FPREG)           ; LSB,NLSB of FPREG
            EX      (SP),HL              ; Stack them,get return
            PUSH    HL                   ; Re-save return
            LD      HL,(FPREG+2)         ; MSB and exponent of FPREG
            EX      (SP),HL              ; Stack them,get return
            PUSH    HL                   ; Re-save return
            EX      DE,HL                ; Restore code string address
            RET

PHLTFP:     CALL    LOADFP               ; Number at HL to BCDE
FPBCDE:     EX      DE,HL                ; Save code string address
            LD      (FPREG),HL           ; Save LSB,NLSB of number
            LD      H,B                  ; Exponent of number
            LD      L,C                  ; MSB of number
            LD      (FPREG+2),HL         ; Save MSB and exponent
            EX      DE,HL                ; Restore code string address
            RET

BCDEFP:     LD      HL,FPREG             ; Point to FPREG
LOADFP:     LD      E,(HL)               ; Get LSB of number
            INC     HL
            LD      D,(HL)               ; Get NMSB of number
            INC     HL
            LD      C,(HL)               ; Get MSB of number
            INC     HL
            LD      B,(HL)               ; Get exponent of number
INCHL:      INC     HL                   ; Used for conditional "INC HL"
            RET

FPTHL:      LD      DE,FPREG             ; Point to FPREG
DETHL4:     LD      B,4                  ; 4 bytes to move
DETHLB:     LD      A,(DE)               ; Get source
            LD      (HL),A               ; Save destination
            INC     DE                   ; Next source
            INC     HL                   ; Next destination
            DEC     B                    ; Count bytes
            JP      NZ,DETHLB            ; Loop if more
            RET

SIGNS:      LD      HL,FPREG+2           ; Point to MSB of FPREG
            LD      A,(HL)               ; Get MSB
            RLCA                         ; Old sign to carry
            SCF                          ; Set MSBit
            RRA                          ; Set MSBit of MSB
            LD      (HL),A               ; Save new MSB
            CCF                          ; Complement sign
            RRA                          ; Old sign to carry
            INC     HL
            INC     HL
            LD      (HL),A               ; Set sign of result
            LD      A,C                  ; Get MSB
            RLCA                         ; Old sign to carry
            SCF                          ; Set MSBit
            RRA                          ; Set MSBit of MSB
            LD      C,A                  ; Save MSB
            RRA
            XOR     (HL)                 ; New sign of result
            RET

CMPNUM:     LD      A,B                  ; Get exponent of number
            OR      A
            JP      Z,TSTSGN             ; Zero - Test sign of FPREG
            LD      HL,RETREL            ; Return relation routine
            PUSH    HL                   ; Save for return
            CALL    TSTSGN               ; Test sign of FPREG
            LD      A,C                  ; Get MSB of number
            RET     Z                    ; FPREG zero - Number's MSB
            LD      HL,FPREG+2           ; MSB of FPREG
            XOR     (HL)                 ; Combine signs
            LD      A,C                  ; Get MSB of number
            RET     M                    ; Exit if signs different
            CALL    CMPFP                ; Compare FP numbers
            RRA                          ; Get carry to sign
            XOR     C                    ; Combine with MSB of number
            RET

CMPFP:      INC     HL                   ; Point to exponent
            LD      A,B                  ; Get exponent
            CP      (HL)                 ; Compare exponents
            RET     NZ                   ; Different
            DEC     HL                   ; Point to MBS
            LD      A,C                  ; Get MSB
            CP      (HL)                 ; Compare MSBs
            RET     NZ                   ; Different
            DEC     HL                   ; Point to NMSB
            LD      A,D                  ; Get NMSB
            CP      (HL)                 ; Compare NMSBs
            RET     NZ                   ; Different
            DEC     HL                   ; Point to LSB
            LD      A,E                  ; Get LSB
            SUB     (HL)                 ; Compare LSBs
            RET     NZ                   ; Different
            POP     HL                   ; Drop RETurn
            POP     HL                   ; Drop another RETurn
            RET

FPINT:      LD      B,A                  ; <- Move
            LD      C,A                  ; <- exponent
            LD      D,A                  ; <- to all
            LD      E,A                  ; <- bits
            OR      A                    ; Test exponent
            RET     Z                    ; Zero - Return zero
            PUSH    HL                   ; Save pointer to number
            CALL    BCDEFP               ; Move FPREG to BCDE
            CALL    SIGNS                ; Set MSBs & sign of result
            XOR     (HL)                 ; Combine with sign of FPREG
            LD      H,A                  ; Save combined signs
            CALL    M,DCBCDE             ; Negative - Decrement BCDE
            LD      A,80H+24             ; 24 bits
            SUB     B                    ; Bits to shift
            CALL    SCALE                ; Shift BCDE
            LD      A,H                  ; Get combined sign
            RLA                          ; Sign to carry
            CALL    C,FPROND             ; Negative - Round number up
            LD      B,0                  ; Zero exponent
            CALL    C,COMPL              ; If negative make positive
            POP     HL                   ; Restore pointer to number
            RET

DCBCDE:     DEC     DE                   ; Decrement BCDE
            LD      A,D                  ; Test LSBs
            AND     E
            INC     A
            RET     NZ                   ; Exit if LSBs not FFFF
            DEC     BC                   ; Decrement MSBs
            RET

INT:        LD      HL,FPEXP             ; Point to exponent
            LD      A,(HL)               ; Get exponent
            CP      80H+24               ; Integer accuracy only?
            LD      A,(FPREG)            ; Get LSB
            RET     NC                   ; Yes - Already integer
            LD      A,(HL)               ; Get exponent
            CALL    FPINT                ; F.P to integer
            LD      (HL),80H+24          ; Save 24 bit integer
            LD      A,E                  ; Get LSB of number
            PUSH    AF                   ; Save LSB
            LD      A,C                  ; Get MSB of number
            RLA                          ; Sign to carry
            CALL    CONPOS               ; Set sign of result
            POP     AF                   ; Restore LSB of number
            RET

MLDEBC:     LD      HL,0                 ; Clear partial product
            LD      A,B                  ; Test multiplier
            OR      C
            RET     Z                    ; Return zero if zero
            LD      A,16                 ; 16 bits
MLDBLP:     ADD     HL,HL                ; Shift P.P left
            JP      C,BSERR              ; ?BS Error if overflow
            EX      DE,HL
            ADD     HL,HL                ; Shift multiplier left
            EX      DE,HL
            JP      NC,NOMLAD            ; Bit was zero - No add
            ADD     HL,BC                ; Add multiplicand
            JP      C,BSERR              ; ?BS Error if overflow
NOMLAD:     DEC     A                    ; Count bits
            JP      NZ,MLDBLP            ; More
            RET

ASCTFP:     CP      '-'                  ; Negative?
            PUSH    AF                   ; Save it and flags
            JP      Z,CNVNUM             ; Yes - Convert number
            CP      '+'                  ; Positive?
            JP      Z,CNVNUM             ; Yes - Convert number
            DEC     HL                   ; DEC 'cos GETCHR INCs
CNVNUM:     CALL    RESZER               ; Set result to zero
            LD      B,A                  ; Digits after point counter
            LD      D,A                  ; Sign of exponent
            LD      E,A                  ; Exponent of ten
            CPL
            LD      C,A                  ; Before or after point flag
MANLP:      CALL    GETCHR               ; Get next character
            JP      C,ADDIG              ; Digit - Add to number
            CP      '.'
            JP      Z,DPOINT             ; '.' - Flag point
            CP      'E'
            JP      NZ,CONEXP            ; Not 'E' - Scale number
            CALL    GETCHR               ; Get next character
            CALL    SGNEXP               ; Get sign of exponent
EXPLP:      CALL    GETCHR               ; Get next character
            JP      C,EDIGIT             ; Digit - Add to exponent
            INC     D                    ; Is sign negative?
            JP      NZ,CONEXP            ; No - Scale number
            XOR     A
            SUB     E                    ; Negate exponent
            LD      E,A                  ; And re-save it
            INC     C                    ; Flag end of number
DPOINT:     INC     C                    ; Flag point passed
            JP      Z,MANLP              ; Zero - Get another digit
CONEXP:     PUSH    HL                   ; Save code string address
            LD      A,E                  ; Get exponent
            SUB     B                    ; Subtract digits after point
SCALMI:     CALL    P,SCALPL             ; Positive - Multiply number
            JP      P,ENDCON             ; Positive - All done
            PUSH    AF                   ; Save number of times to /10
            CALL    DIV10                ; Divide by 10
            POP     AF                   ; Restore count
            INC     A                    ; Count divides

ENDCON:     JP      NZ,SCALMI            ; More to do
            POP     DE                   ; Restore code string address
            POP     AF                   ; Restore sign of number
            CALL    Z,INVSGN             ; Negative - Negate number
            EX      DE,HL                ; Code string address to HL
            RET

SCALPL:     RET     Z                    ; Exit if no scaling needed
MULTEN:     PUSH    AF                   ; Save count
            CALL    MLSP10               ; Multiply number by 10
            POP     AF                   ; Restore count
            DEC     A                    ; Count multiplies
            RET

ADDIG:      PUSH    DE                   ; Save sign of exponent
            LD      D,A                  ; Save digit
            LD      A,B                  ; Get digits after point
            ADC     A,C                  ; Add one if after point
            LD      B,A                  ; Re-save counter
            PUSH    BC                   ; Save point flags
            PUSH    HL                   ; Save code string address
            PUSH    DE                   ; Save digit
            CALL    MLSP10               ; Multiply number by 10
            POP     AF                   ; Restore digit
            SUB     '0'                  ; Make it absolute
            CALL    RSCALE               ; Re-scale number
            POP     HL                   ; Restore code string address
            POP     BC                   ; Restore point flags
            POP     DE                   ; Restore sign of exponent
            JP      MANLP                ; Get another digit

RSCALE:     CALL    STAKFP               ; Put number on stack
            CALL    FLGREL               ; Digit to add to FPREG
PADD:       POP     BC                   ; Restore number
            POP     DE
            JP      FPADD                ; Add BCDE to FPREG and return

EDIGIT:     LD      A,E                  ; Get digit
            RLCA                         ; Times 2
            RLCA                         ; Times 4
            ADD     A,E                  ; Times 5
            RLCA                         ; Times 10
            ADD     A,(HL)               ; Add next digit
            SUB     '0'                  ; Make it absolute
            LD      E,A                  ; Save new digit
            JP      EXPLP                ; Look for another digit

LINEIN:     PUSH    HL                   ; Save code string address
            LD      HL,INMSG             ; Output " in "
            CALL    PRS                  ; Output string at HL
            POP     HL                   ; Restore code string address
PRNTHL:     EX      DE,HL                ; Code string address to DE
            XOR     A
            LD      B,80H+24             ; 24 bits
            CALL    RETINT               ; Return the integer
            LD      HL,PRNUMS            ; Print number string
            PUSH    HL                   ; Save for return
NUMASC:     LD      HL,PBUFF             ; Convert number to ASCII
            PUSH    HL                   ; Save for return
            CALL    TSTSGN               ; Test sign of FPREG
            LD      (HL),' '             ; Space at start
            JP      P,SPCFST             ; Positive - Space to start
            LD      (HL),'-'             ; '-' sign at start
SPCFST:     INC     HL                   ; First byte of number
            LD      (HL),'0'             ; '0' if zero
            JP      Z,JSTZER             ; Return '0' if zero
            PUSH    HL                   ; Save buffer address
            CALL    M,INVSGN             ; Negate FPREG if negative
            XOR     A                    ; Zero A
            PUSH    AF                   ; Save it
            CALL    RNGTST               ; Test number is in range
SIXDIG:     LD      BC,9143H             ; BCDE - 99999.9
            LD      DE,4FF8H
            CALL    CMPNUM               ; Compare numbers
            OR      A
            JP      PO,INRNG             ; > 99999.9 - Sort it out
            POP     AF                   ; Restore count
            CALL    MULTEN               ; Multiply by ten
            PUSH    AF                   ; Re-save count
            JP      SIXDIG               ; Test it again

GTSIXD:     CALL    DIV10                ; Divide by 10
            POP     AF                   ; Get count
            INC     A                    ; Count divides
            PUSH    AF                   ; Re-save count
            CALL    RNGTST               ; Test number is in range
INRNG:      CALL    ROUND                ; Add 0.5 to FPREG
            INC     A
            CALL    FPINT                ; F.P to integer
            CALL    FPBCDE               ; Move BCDE to FPREG
            LD      BC,0306H             ; 1E+06 to 1E-03 range
            POP     AF                   ; Restore count
            ADD     A,C                  ; 6 digits before point
            INC     A                    ; Add one
            JP      M,MAKNUM             ; Do it in 'E' form if < 1E-02
            CP      6+1+1                ; More than 999999 ?
            JP      NC,MAKNUM            ; Yes - Do it in 'E' form
            INC     A                    ; Adjust for exponent
            LD      B,A                  ; Exponent of number
            LD      A,2                  ; Make it zero after

MAKNUM:     DEC     A                    ; Adjust for digits to do
            DEC     A
            POP     HL                   ; Restore buffer address
            PUSH    AF                   ; Save count
            LD      DE,POWERS            ; Powers of ten
            DEC     B                    ; Count digits before point
            JP      NZ,DIGTXT            ; Not zero - Do number
            LD      (HL),'.'             ; Save point
            INC     HL                   ; Move on
            LD      (HL),'0'             ; Save zero
            INC     HL                   ; Move on
DIGTXT:     DEC     B                    ; Count digits before point
            LD      (HL),'.'             ; Save point in case
            CALL    Z,INCHL              ; Last digit - move on
            PUSH    BC                   ; Save digits before point
            PUSH    HL                   ; Save buffer address
            PUSH    DE                   ; Save powers of ten
            CALL    BCDEFP               ; Move FPREG to BCDE
            POP     HL                   ; Powers of ten table
            LD      B, '0'-1             ; ASCII '0' - 1
TRYAGN:     INC     B                    ; Count subtractions
            LD      A,E                  ; Get LSB
            SUB     (HL)                 ; Subtract LSB
            LD      E,A                  ; Save LSB
            INC     HL
            LD      A,D                  ; Get NMSB
            SBC     A,(HL)               ; Subtract NMSB
            LD      D,A                  ; Save NMSB
            INC     HL
            LD      A,C                  ; Get MSB
            SBC     A,(HL)               ; Subtract MSB
            LD      C,A                  ; Save MSB
            DEC     HL                   ; Point back to start
            DEC     HL
            JP      NC,TRYAGN            ; No overflow - Try again
            CALL    PLUCDE               ; Restore number
            INC     HL                   ; Start of next number
            CALL    FPBCDE               ; Move BCDE to FPREG
            EX      DE,HL                ; Save point in table
            POP     HL                   ; Restore buffer address
            LD      (HL),B               ; Save digit in buffer
            INC     HL                   ; And move on
            POP     BC                   ; Restore digit count
            DEC     C                    ; Count digits
            JP      NZ,DIGTXT            ; More - Do them
            DEC     B                    ; Any decimal part?
            JP      Z,DOEBIT             ; No - Do 'E' bit
SUPTLZ:     DEC     HL                   ; Move back through buffer
            LD      A,(HL)               ; Get character
            CP      '0'                  ; '0' character?
            JP      Z,SUPTLZ             ; Yes - Look back for more
            CP      '.'                  ; A decimal point?
            CALL    NZ,INCHL             ; Move back over digit

DOEBIT:     POP     AF                   ; Get 'E' flag
            JP      Z,NOENED             ; No 'E' needed - End buffer
            LD      (HL),'E'             ; Put 'E' in buffer
            INC     HL                   ; And move on
            LD      (HL),'+'             ; Put '+' in buffer
            JP      P,OUTEXP             ; Positive - Output exponent
            LD      (HL),'-'             ; Put '-' in buffer
            CPL                          ; Negate exponent
            INC     A
OUTEXP:     LD      B,'0'-1              ; ASCII '0' - 1
EXPTEN:     INC     B                    ; Count subtractions
            SUB     10                   ; Tens digit
            JP      NC,EXPTEN            ; More to do
            ADD     A,'0'+10             ; Restore and make ASCII
            INC     HL                   ; Move on
            LD      (HL),B               ; Save MSB of exponent
JSTZER:     INC     HL                   ;
            LD      (HL),A               ; Save LSB of exponent
            INC     HL
NOENED:     LD      (HL),C               ; Mark end of buffer
            POP     HL                   ; Restore code string address
            RET

RNGTST:     LD      BC,9474H             ; BCDE = 999999.
            LD      DE,23F7H
            CALL    CMPNUM               ; Compare numbers
            OR      A
            POP     HL                   ; Return address to HL
            JP      PO,GTSIXD            ; Too big - Divide by ten
            JP      (HL)                 ; Otherwise return to caller

HALF:       DB         00H,00H,00H,80H   ; 0.5

POWERS:     DB         0A0H,086H,001H    ; 100000
            DB         010H,027H,000H    ;  10000
            DB         0E8H,003H,000H    ;   1000
            DB         064H,000H,000H    ;    100
            DB         00AH,000H,000H    ;     10
            DB         001H,000H,000H    ;      1

NEGAFT:     LD  HL,INVSGN                ; Negate result
            EX      (SP),HL              ; To be done after caller
            JP      (HL)                 ; Return to caller

SQR:        CALL    STAKFP               ; Put value on stack
            LD      HL,HALF              ; Set power to 1/2
            CALL    PHLTFP               ; Move 1/2 to FPREG

POWER:      POP     BC                   ; Get base
            POP     DE
            CALL    TSTSGN               ; Test sign of power
            LD      A,B                  ; Get exponent of base
            JP      Z,EXP                ; Make result 1 if zero
            JP      P,POWER1             ; Positive base - Ok
            OR      A                    ; Zero to negative power?
            JP      Z,DZERR              ; Yes - ?/0 Error
POWER1:     OR      A                    ; Base zero?
            JP      Z,SAVEXP             ; Yes - Return zero
            PUSH    DE                   ; Save base
            PUSH    BC
            LD      A,C                  ; Get MSB of base
            OR      01111111B            ; Get sign status
            CALL    BCDEFP               ; Move power to BCDE
            JP      P,POWER2             ; Positive base - Ok
            PUSH    DE                   ; Save power
            PUSH    BC
            CALL    INT                  ; Get integer of power
            POP     BC                   ; Restore power
            POP     DE
            PUSH    AF                   ; MSB of base
            CALL    CMPNUM               ; Power an integer?
            POP     HL                   ; Restore MSB of base
            LD      A,H                  ; but don't affect flags
            RRA                          ; Exponent odd or even?
POWER2:     POP     HL                   ; Restore MSB and exponent
            LD      (FPREG+2),HL         ; Save base in FPREG
            POP     HL                   ; LSBs of base
            LD      (FPREG),HL           ; Save in FPREG
            CALL    C,NEGAFT             ; Odd power - Negate result
            CALL    Z,INVSGN             ; Negative base - Negate it
            PUSH    DE                   ; Save power
            PUSH    BC
            CALL    LOG                  ; Get LOG of base
            POP     BC                   ; Restore power
            POP     DE
            CALL    FPMULT               ; Multiply LOG by power

EXP:        CALL    STAKFP               ; Put value on stack
            LD      BC,08138H            ; BCDE = 1/Ln(2)
            LD      DE,0AA3BH
            CALL    FPMULT               ; Multiply value by 1/LN(2)
            LD      A,(FPEXP)            ; Get exponent
            CP      80H+8                ; Is it in range?
            JP      NC,OVTST1            ; No - Test for overflow
            CALL    INT                  ; Get INT of FPREG
            ADD     A,80H                ; For excess 128
            ADD     A,2                  ; Exponent > 126?
            JP      C,OVTST1             ; Yes - Test for overflow
            PUSH    AF                   ; Save scaling factor
            LD      HL,UNITY             ; Point to 1.
            CALL    ADDPHL               ; Add 1 to FPREG
            CALL    MULLN2               ; Multiply by LN(2)
            POP     AF                   ; Restore scaling factor
            POP     BC                   ; Restore exponent
            POP     DE
            PUSH    AF                   ; Save scaling factor
            CALL    SUBCDE               ; Subtract exponent from FPREG
            CALL    INVSGN               ; Negate result
            LD      HL,EXPTAB            ; Coefficient table
            CALL    SMSER1               ; Sum the series
            LD      DE,0                 ; Zero LSBs
            POP     BC                   ; Scaling factor
            LD      C,D                  ; Zero MSB
            JP      FPMULT               ; Scale result to correct value

EXPTAB:     DB      8                    ; Table used by EXP
            DB      040H,02EH,094H,074H  ; -1/7! (-1/5040)
            DB      070H,04FH,02EH,077H  ;  1/6! ( 1/720)
            DB      06EH,002H,088H,07AH  ; -1/5! (-1/120)
            DB      0E6H,0A0H,02AH,07CH  ;  1/4! ( 1/24)
            DB      050H,0AAH,0AAH,07EH  ; -1/3! (-1/6)
            DB      0FFH,0FFH,07FH,07FH  ;  1/2! ( 1/2)
            DB      000H,000H,080H,081H  ; -1/1! (-1/1)
            DB      000H,000H,000H,081H  ;  1/0! ( 1/1)

SUMSER:     CALL    STAKFP               ; Put FPREG on stack
            LD      DE,MULT              ; Multiply by "X"
            PUSH    DE                   ; To be done after
            PUSH    HL                   ; Save address of table
            CALL    BCDEFP               ; Move FPREG to BCDE
            CALL    FPMULT               ; Square the value
            POP     HL                   ; Restore address of table
SMSER1:     CALL    STAKFP               ; Put value on stack
            LD      A,(HL)               ; Get number of coefficients
            INC     HL                   ; Point to start of table
            CALL    PHLTFP               ; Move coefficient to FPREG
            DB         06H                  ; Skip "POP AF"
SUMLP:      POP     AF                   ; Restore count
            POP     BC                   ; Restore number
            POP     DE
            DEC     A                    ; Cont coefficients
            RET     Z                    ; All done
            PUSH    DE                   ; Save number
            PUSH    BC
            PUSH    AF                   ; Save count
            PUSH    HL                   ; Save address in table
            CALL    FPMULT               ; Multiply FPREG by BCDE
            POP     HL                   ; Restore address in table
            CALL    LOADFP               ; Number at HL to BCDE
            PUSH    HL                   ; Save address in table
            CALL    FPADD                ; Add coefficient to FPREG
            POP     HL                   ; Restore address in table
            JP      SUMLP                ; More coefficients

RND:        CALL    TSTSGN               ; Test sign of FPREG
            LD      HL,SEED+2            ; Random number seed
            JP      M,RESEED             ; Negative - Re-seed
            LD      HL,LSTRND            ; Last random number
            CALL    PHLTFP               ; Move last RND to FPREG
            LD      HL,SEED+2            ; Random number seed
            RET     Z                    ; Return if RND(0)
            ADD     A,(HL)               ; Add (SEED)+2)
            AND     00000111B            ; 0 to 7
            LD      B,0
            LD      (HL),A               ; Re-save seed
            INC     HL                   ; Move to coefficient table
            ADD     A,A                  ; 4 bytes
            ADD     A,A                  ; per entry
            LD      C,A                  ; BC = Offset into table
            ADD     HL,BC                ; Point to coefficient
            CALL    LOADFP               ; Coefficient to BCDE
            CALL    FPMULT  ;            ; Multiply FPREG by coefficient
            LD      A,(SEED+1)           ; Get (SEED+1)
            INC     A                    ; Add 1
            AND     00000011B            ; 0 to 3
            LD      B,0
            CP      1                    ; Is it zero?
            ADC     A,B                  ; Yes - Make it 1
            LD      (SEED+1),A           ; Re-save seed
            LD      HL,RNDTAB-4          ; Addition table
            ADD     A,A                  ; 4 bytes
            ADD     A,A                  ; per entry
            LD      C,A                  ; BC = Offset into table
            ADD     HL,BC                ; Point to value
            CALL    ADDPHL               ; Add value to FPREG
RND1:       CALL    BCDEFP               ; Move FPREG to BCDE
            LD      A,E                  ; Get LSB
            LD      E,C                  ; LSB = MSB
            XOR     01001111B            ; Fiddle around
            LD      C,A                  ; New MSB
            LD      (HL),80H             ; Set exponent
            DEC     HL                   ; Point to MSB
            LD      B,(HL)               ; Get MSB
            LD      (HL),80H             ; Make value -0.5
            LD      HL,SEED              ; Random number seed
            INC     (HL)                 ; Count seed
            LD      A,(HL)               ; Get seed
            SUB     171                  ; Do it modulo 171
            JP      NZ,RND2              ; Non-zero - Ok
            LD      (HL),A               ; Zero seed
            INC     C                    ; Fillde about
            DEC     D                    ; with the
            INC     E                    ; number
RND2:       CALL    BNORM                ; Normalise number
            LD      HL,LSTRND            ; Save random number
            JP      FPTHL                ; Move FPREG to last and return

RESEED:     LD      (HL),A               ; Re-seed random numbers
            DEC     HL
            LD      (HL),A
            DEC     HL
            LD      (HL),A
            JP      RND1                 ; Return RND seed

RNDTAB:     DB      068H,0B1H,046H,068H  ; Table used by RND
            DB      099H,0E9H,092H,069H
            DB      010H,0D1H,075H,068H

COS:        LD      HL,HALFPI            ; Point to PI/2
            CALL    ADDPHL               ; Add it to PPREG
SIN:        CALL    STAKFP               ; Put angle on stack
            LD      BC,8349H             ; BCDE = 2 PI
            LD      DE,0FDBH
            CALL    FPBCDE               ; Move 2 PI to FPREG
            POP     BC                   ; Restore angle
            POP     DE
            CALL    DVBCDE               ; Divide angle by 2 PI
            CALL    STAKFP               ; Put it on stack
            CALL    INT                  ; Get INT of result
            POP     BC                   ; Restore number
            POP     DE
            CALL    SUBCDE               ; Make it 0 <= value < 1
            LD      HL,QUARTR            ; Point to 0.25
            CALL    SUBPHL               ; Subtract value from 0.25
            CALL    TSTSGN               ; Test sign of value
            SCF                          ; Flag positive
            JP      P,SIN1               ; Positive - Ok
            CALL    ROUND                ; Add 0.5 to value
            CALL    TSTSGN               ; Test sign of value
            OR      A                    ; Flag negative
SIN1:       PUSH    AF                   ; Save sign
            CALL    P,INVSGN             ; Negate value if positive
            LD      HL,QUARTR            ; Point to 0.25
            CALL    ADDPHL               ; Add 0.25 to value
            POP     AF                   ; Restore sign
            CALL    NC,INVSGN            ; Negative - Make positive
            LD      HL,SINTAB            ; Coefficient table
            JP      SUMSER               ; Evaluate sum of series

HALFPI:     DB      0DBH,00FH,049H,081H  ; 1.5708 (PI/2)

QUARTR:     DB      000H,000H,000H,07FH  ; 0.25

SINTAB:     DB      5                    ; Table used by SIN
            DB      0BAH,0D7H,01EH,086H  ; 39.711
            DB      064H,026H,099H,087H  ;-76.575
            DB      058H,034H,023H,087H  ; 81.602
            DB      0E0H,05DH,0A5H,086H  ;-41.342
            DB      0DAH,00FH,049H,083H  ;  6.2832

TAN:        CALL    STAKFP               ; Put angle on stack
            CALL    SIN                  ; Get SIN of angle
            POP     BC                   ; Restore angle
            POP     HL
            CALL    STAKFP               ; Save SIN of angle
            EX      DE,HL                ; BCDE = Angle
            CALL    FPBCDE               ; Angle to FPREG
            CALL    COS                  ; Get COS of angle
            JP      DIV                  ; TAN = SIN / COS

ATN:        CALL    TSTSGN               ; Test sign of value
            CALL    M,NEGAFT             ; Negate result after if -ve
            CALL    M,INVSGN             ; Negate value if -ve
            LD      A,(FPEXP)            ; Get exponent
            CP      81H                  ; Number less than 1?
            JP      C,ATN1               ; Yes - Get arc tangnt
            LD      BC,8100H             ; BCDE = 1
            LD      D,C
            LD      E,C
            CALL    DVBCDE               ; Get reciprocal of number
            LD      HL,SUBPHL            ; Sub angle from PI/2
            PUSH    HL                   ; Save for angle > 1
ATN1:       LD      HL,ATNTAB            ; Coefficient table
            CALL    SUMSER               ; Evaluate sum of series
            LD      HL,HALFPI            ; PI/2 - angle in case > 1
            RET                          ; Number > 1 - Sub from PI/2

ATNTAB:     DB      9                    ; Table used by ATN
            DB      04AH,0D7H,03BH,078H  ; 1/17
            DB      002H,06EH,084H,07BH  ;-1/15
            DB      0FEH,0C1H,02FH,07CH  ; 1/13
            DB      074H,031H,09AH,07DH  ;-1/11
            DB      084H,03DH,05AH,07DH  ; 1/9
            DB      0C8H,07FH,091H,07EH  ;-1/7
            DB      0E4H,0BBH,04CH,07EH  ; 1/5
            DB      06CH,0AAH,0AAH,07FH  ;-1/3
            DB      000H,000H,000H,081H  ; 1/1


ARET:       RET                          ; A RETurn instruction

CLS:        LD      A,016H               ; ASCII Clear screen
            JP      PRNT                 ; Output character

WIDTH:      CALL    GETINT               ; Get integer 0-255
            LD      A,E                  ; Width to A
            LD      (LWIDTH),A           ; Set width
            RET

LINES:      CALL    GETNUM               ; Get a number
            CALL    DEINT                ; Get integer -32768 to 32767
            LD      (LINESC),DE          ; Set lines counter
            LD      (LINESN),DE          ; Set lines number
            RET

DEEK:       CALL    DEINT                ; Get integer -32768 to 32767
            PUSH    DE                   ; Save number
            POP     HL                   ; Number to HL
            LD      B,(HL)               ; Get LSB of contents
            INC     HL
            LD      A,(HL)               ; Get MSB of contents
            JP      ABPASS               ; Return integer AB

DOKE:       CALL    GETNUM               ; Get a number
            CALL    DEINT                ; Get integer -32768 to 32767
            PUSH    DE                   ; Save address
            CALL    CHKSYN               ; Make sure ',' follows
            DB         ','
            CALL    GETNUM               ; Get a number
            CALL    DEINT                ; Get integer -32768 to 32767
            EX      (SP),HL              ; Save value,get address
            LD      (HL),E               ; Save LSB of value
            INC     HL
            LD      (HL),D               ; Save MSB of value
            POP     HL                   ; Restore code string address
            RET


            ; HEX$(nn) Convert 16 bit number to Hexadecimal string

HEX: 	    CALL	TSTNUM               ; Verify it's a number
            CALL	DEINT                ; Get integer -32768 to 32767
            PUSH	BC                   ; Save contents of BC
            LD	    HL,PBUFF
            LD	    A,D                  ; Get high order into A
            CP      000H
		    JR      Z,HEX2               ; Skip output if both high digits are zero
            CALL    BYT2ASC              ; Convert D to ASCII
		    LD      A,B
		    CP      '0'
		    JR      Z,HEX1               ; Don't store high digit if zero
            LD	    (HL),B               ; Store it to PBUFF
            INC	    HL                   ; Next location
HEX1:       LD	    (HL),C               ; Store C to PBUFF+1
            INC     HL                   ; Next location
HEX2:       LD	    A,E                  ; Get lower byte
            CALL    BYT2ASC              ; Convert E to ASCII
		    LD      A,D
            CP      000H
		    JR      NZ,HEX3              ; If upper byte was not zero then always print lower byte
		    LD      A,B
		    CP      '0'                  ; If high digit of lower byte is zero then don't print
		    JR      Z,HEX4
HEX3:       LD      (HL),B               ; to PBUFF+2
            INC     HL                   ; Next location
HEX4:       LD      (HL),C               ; to PBUFF+3
            INC     HL                   ; PBUFF+4 to zero
            XOR     A                    ; Terminating character
            LD      (HL),A               ; Store zero to terminate
            INC     HL                   ; Make sure PBUFF is terminated
            LD      (HL),A               ; Store the double zero there
            POP     BC                   ; Get BC back
            LD      HL,PBUFF             ; Reset to start of PBUFF
            JP      STR1                 ; Convert the PBUFF to a string and return it

BYT2ASC	    LD      B,A                  ; Save original value
            AND     00FH                 ; Strip off upper nybble
            CP      00AH                 ; 0-9?
            JR      C,ADD30              ; If A-F, add 7 more
            ADD     A,007H               ; Bring value up to ASCII A-F
ADD30	    ADD     A,030H               ; And make ASCII
            LD      C,A                  ; Save converted char to C
            LD      A,B                  ; Retrieve original value
            RRCA                         ; and Rotate it right
            RRCA
            RRCA
            RRCA
            AND     00FH                 ; Mask off upper nybble
            CP      00AH                 ; 0-9? < A hex?
            JR      C,ADD301             ; Skip Add 7
            ADD     A,007H               ; Bring it up to ASCII A-F
ADD301	    ADD     A,030H               ; And make it full ASCII
            LD      B,A                  ; Store high order byte
            RET	

            ; Convert "&Hnnnn" to FPREG
            ; Gets a character from (HL) checks for Hexadecimal ASCII numbers "&Hnnnn"
            ; Char is in A, NC if char is ;<=>?@ A-z, CY is set if 0-9
HEXTFP      EX      DE,HL                ; Move code string pointer to DE
            LD      HL,00000H            ; Zero out the value
            CALL    GETHEX               ; Check the number for valid hex
            JP      C,HXERR              ; First value wasn't hex, HX error
            JR      HEXLP1               ; Convert first character
HEXLP       CALL    GETHEX               ; Get second and addtional characters
            JR      C,HEXIT              ; Exit if not a hex character
HEXLP1      ADD     HL,HL                ; Rotate 4 bits to the left
            ADD     HL,HL
            ADD     HL,HL
            ADD     HL,HL
            OR      L                    ; Add in D0-D3 into L
            LD      L,A                  ; Save new value
            JR      HEXLP                ; And continue until all hex characters are in

GETHEX      INC     DE                   ; Next location
            LD      A,(DE)               ; Load character at pointer
            CP      ' '
            JP      Z,GETHEX             ; Skip spaces
            SUB     030H                 ; Get absolute value
            RET     C                    ; < "0", error
            CP      00AH
            JR      C,NOSUB7             ; Is already in the range 0-9
            SUB     007H                 ; Reduce to A-F
            CP      00AH                 ; Value should be $0A-$0F at this point
            RET     C                    ; CY set if was :            ; < = > ? @
NOSUB7      CP      010H                 ; > Greater than "F"?
            CCF
            RET                          ; CY set if it wasn't valid hex
    
HEXIT       EX      DE,HL                ; Value into DE, Code string into HL
            LD      A,D                  ; Load DE into AC
            LD      C,E                  ; For prep to 
            PUSH    HL
            CALL    ACPASS               ; ACPASS to set AC as integer into FPREG
            POP     HL
            RET

HXERR:      LD      E,HX                 ; ?HEX Error
            JP      BERROR

            ; BIN$(NN) Convert integer to a 1-16 char binary string
BIN:        CALL    TSTNUM               ; Verify it's a number
            CALL    DEINT                ; Get integer -32768 to 32767
BIN2:       PUSH    BC                   ; Save contents of BC
            LD      HL,PBUFF
            LD      B,17                 ; One higher than max char count
ZEROSUP:                                 ; Suppress leading zeros
            DEC     B                    ; Max 16 chars
            LD      A,B
            CP      001H
            JR      Z,BITOUT             ; Always output at least one character
            RL      E
            RL      D
            JR      NC,ZEROSUP
            JR      BITOUT2
BITOUT:          
            RL      E
            RL      D                    ; Top bit now in carry
BITOUT2:    
            LD      A,'0'                ; Char for '0'
            ADC     A,0                  ; If carry set then '0' --> '1'
            LD      (HL),A
            INC     HL
            DEC     B
            JR      NZ,BITOUT
            XOR     A                    ; Terminating character
            LD      (HL),A               ; Store zero to terminate
            INC     HL                   ; Make sure PBUFF is terminated
            LD      (HL),A               ; Store the double zero there
            POP     BC
            LD      HL,PBUFF
            JP      STR1

            ; Convert "&Bnnnn" to FPREG
            ; Gets a character from (HL) checks for Binary ASCII numbers "&Bnnnn"
BINTFP:     EX      DE,HL                ; Move code string pointer to DE
            LD      HL,00000H            ; Zero out the value
            CALL    CHKBIN               ; Check the number for valid bin
            JP      C,BINERR             ; First value wasn't bin, HX error
BINIT:      SUB     '0'
            ADD     HL,HL                ; Rotate HL left
            OR      L
            LD      L,A
            CALL    CHKBIN               ; Get second and addtional characters
            JR      NC,BINIT             ; Process if a bin character
            EX      DE,HL                ; Value into DE, Code string into HL
            LD      A,D                  ; Load DE into AC
            LD      C,E                  ; For prep to 
            PUSH    HL
            CALL    ACPASS               ; ACPASS to set AC as integer into FPREG
            POP     HL
            RET

        ; Char is in A, NC if char is 0 or 1
CHKBIN:     INC     DE
            LD      A,(DE)
            CP      ' '
            JP      Z,CHKBIN             ; Skip spaces
            CP      '0'                  ; Set C if < '0'
            RET     C
            CP      '2'
            CCF                          ; Set C if > '1'
            RET

BINERR:     LD      E,BN                 ; ?BIN Error
            JP      BERROR

JJUMP1:     LD      IX,-1                ; Flag cold start
            JP      CSTART               ; Go and initialise

            ; Restored SCREEN command updated for the MZ80A.
            ; The MZ80A uses 0,0 -> COLW-1,ROW-1 addressing as opposed to the NASCOM 1,1 -> 48,16
            ;
SCREEN:     CALL    GETINT               ; Get integer 0 to 255
            PUSH    AF                   ; Save column
            CALL    CHKSYN               ; Make sure "," follows
            DB      ","
            CALL    GETINT               ; Get integer 0 to 255
            POP     BC                   ; Column to B
            PUSH    HL                   ; Save code string address
            PUSH    BC                   ; Save column
            CALL    SCRADR               ; Set screen coordinates.
            POP     HL                   ; Rstore code string address
            RET

SCRADR:     LD      B,A                  ; Line and column to BC once checked.
            OR      A                    ; Test it
            JP      Z,FCERR              ; Zero - ?FC Error
            CP      ROW+1                ; Number of lines
            JP      P,FCERR              ; > Number of lines then ?FC Error
            DEC     B                    ; Sharp uses 0,0 addressing so once value verified, decrement.
            POP     DE                   ; RETurn address
            POP     AF                   ; Get column
            PUSH    DE                   ; Re-save RETurn
            LD      C,A                  ; Column to DE
            OR      A                    ; Test it
            JP      Z,FCERR              ; Zero - ?FC Error
            CP      COLW+1               ; Number of characters per line
            JP      P,FCERR              ; > number of characters then ?FC Error
            DEC     C                    ; Sharp uses 0,0 addressing.
            LD      (DSPXY),BC           ; Save coordinates.
            RET

ARETN:      RETN                         ; Return from NMI

TSTBIT:     PUSH    AF                   ; Save bit mask
            AND     B                    ; Get common bits
            POP     BC                   ; Restore bit mask
            CP      B                    ; Same bit set?
            LD      A,0                  ; Return 0 in A
            RET

OUTNCR:     CALL    OUTC                 ; Output character in A
            JP      PRNTCRLF             ; Output CRLF


            ; Method to load BASIC text program.
LOAD:       LD      A,TAPELOAD           ; Set the type of operation into the flag var.
            JR      CLOAD0

            ; Method to load a cassette image (tokenised basic script).
            ;
CLOAD:      LD      A,CTAPELOAD          ; Set the type of operatiom into the flag var.
CLOAD0:     LD      (TPFLAG),A
            LD      A,(HL)               ; Get byte after "CLOAD"
       ;    CP      ZTIMES               ; "*" token? ("CLOAD*")
       ;    JP      Z,ARRLD1             ; Yes - Array load
            SUB     ZPRINT               ; "?" ("PRINT" token) Verify?
            JP      Z,FLGVER             ; Yes - Flag "verify"
            XOR     A                    ; Flag "load"
            DB      01H                  ; Skip "CPL" and "INC HL"
FLGVER:     CPL                          ; Flag "verify"
            INC     HL                   ; Skip over "?"
            PUSH    AF                   ; Save verify flag
            DEC     HL                   ; DEC 'cos GETCHR INCs
            CALL    GETCHR               ; Get next character
            LD      A,0                  ; Any file will do
            JP      Z,SDNONAM            ; No name given - error.
            CALL    EVAL                 ; Evaluate expression
            CALL    GTFLNM               ; Get file name
            POP     AF
            OR      A
            JP      NZ,SDVERF
            ;
            LD      HL,TZSVC_FILENAME    ; Set the filename to be created.
            LD      A,(TMSTPL)                                   
            CP      TZSVCFILESZ          ; Check size of filename, cant be more than an MZF name of 17 chars.
            JP      NC,SDFNTG
            LD      B,A
CLOAD1:     LD      A,(DE)               ; Copy filename into service record.
            LD      (HL),A
            INC     DE
            INC     HL
            DJNZ    CLOAD1
            XOR     A
            LD      (HL),A               ; Terminate filename.
            ;
            CALL    CLRPTR               ; Initialise memory to NEW state ready for program load.
            LD      A,(TPFLAG)           ; What are we processing, cassette image or text?
            CP      CTAPELOAD
            JR      Z,CLOAD2             ; Is this a cassette image load?
            CALL    LDTXT                ; BASIC text load.
            JR      SDLOADE
CLOAD2:     SCF
            CALL    PRCFIL               ; Process file as a load request.
CLOAD3:     PUSH    HL
            LD      HL,(BASTXT)          ; Get start of program memory.
            LD      BC,(TZSVC_LOADSIZE)  ; Get the actual load size.
            ADD     HL,BC                ; Find the end.
            XOR     A
            LD      (HL),A               ; Last two bytes are xeroed as they are for the next line number.
            INC     HL
            LD      (HL),A
            INC     HL
            LD      (PROGND),HL          ; Set it as the end of program memory.
            POP     HL
            JR      SDLOADE              ; Exit and tidy up.

SDVERF:
SDLOADE:    LD      HL,OKMSG             ; "Ok" message
            CALL    PRS                  ; Output string
            JP      SETPTR               ; Set up line pointers

            ; Methods to open, read and close an SD file for retrieval of basic program data. Cassette files are read/written
            ; directly to memory by the K64F but text files, as they are being expanded/compressed, need to be read/written
            ; sector by sector.
LDOPEN:     XOR     A
            LD      (TZSVC_FILE_SEC),A   ; Starting sector number of file to load.
            LD      A,TZSVC_FTYPE_BAS    ; Type of file is CASsette, the K64F will know how to handle it.
            LD      (TZSVC_FILE_TYPE),A
            LD      A,TZSVC_CMD_READFILE
            CALL    SVC_CMD              ; And make communications wit the I/O processor, returning with the required record.
            OR      A                    ; Zero means no physical error occurred.
            JP      NZ, SDOPER           ; Open error, K64F didint respond, cannot read!
            LD      A,(TZSVCRESULT)      ; Check the result from the K64F, non zero is an error.
            OR      A
            JP      NZ, SDOPER           ; Same thing, if K64F processes request and returns an error, open or read problem!
            LD      HL,TZSVCSECTOR       ; Start at beginning of sector.
            LD      (SECTPOS),HL
            RET

LDCLOSE:    LD      A,TZSVC_CMD_CLOSE    ; Close file.
            CALL    SVC_CMD              ; And make communications wit the I/O processor, returning with the required record.
            OR      A                    ; Zero means no physical error occurred.
            JP      NZ, SDCLER           ; Close error, K64F didint respond, cannot close the file.
            LD      A,(TZSVCRESULT)      ; Check the result from the K64F, non zero is an error.
            OR      A
            JP      NZ, SDCLER           ; Same thing, if K64F closes file and returns an error, closing problem (SD removed!)!
            RET

LDBUF:      LD      A,(TZSVC_FILE_SEC)   ; Update the virtual file sector number so the K64F knows what to read.
            INC     A
            LD      (TZSVC_FILE_SEC),A
            LD      A, TZSVC_CMD_NEXTREADFILE
            CALL    SVC_CMD              ; And make communications with the I/O processor, returning with the required record.
            OR      A                    ; Zero means no physical error occurred.
            JP      NZ, SDRDER           ; Write error, K64F didint respond, cannot write so flag as error!
            LD      A,(TZSVCRESULT)      ; Check the result from the K64F, non zero is an error.
            OR      A
            JP      NZ, SDRDER           ; Same thing, if K64F read from file returns an error, read error (SD removed or disk error!)!
            RET

            ; Method to load a NASIC program which is stored as TEXT into memory. This is accomplied sector by sector, line by line,
            ; each line needs to be read, tokenised and stored. 
            ;
LDTXT:      CALL    LDOPEN               ; Open file, read the first sector of data.
            LD      HL,(PROGND)          ; After reset the pointer points to the first line number not the first address
            DEC     HL                   ; Update it to keep the later logic more simple.
            DEC     HL
            LD      (PROGND),HL
            ;
LDTXT0:     LD      HL,(TZSVC_LOADSIZE)  ; Get size of sector loaded.
            LD      BC,TZSVCSECTOR       ; Address of sector
            ADD     HL,BC                ; End of sector address
            PUSH    HL
            POP     BC                   ; BC contains sector end address.
            LD      HL,(SECTPOS)         ; Get position in sector for next line.
            LD      DE,STACKE            ; Copy line into temporary area in case we span sectors.
LDTXT1:     PUSH    HL
            OR      A
            SBC     HL,BC                ; So long as the end sector address is greater than the pointer we will have carry.
            POP     HL
            JR      C,LDTXT2             ; Check that we havent got to the end of the current sector.
            CALL    LDBUF                ; End of current sector so load new.
            LD      HL,(TZSVC_LOADSIZE)
            LD      A,H
            OR      L
            JR      Z,LDTXTE             ; No bytes in sector means end of file,exit.
            LD      HL,TZSVCSECTOR       ; Start at beginning of sector.
LDTXT2:     LD      A,(HL)               ; Copy the string from the sector to the temporary area.
            LD      (DE),A
            INC     HL
            CP      CR
            JR      Z,LDTXT3             ; CR means EOS.
            CP      LF
            JR      Z,LDTXT3             ; LF means EOS.
            INC     DE
            JR      LDTXT1
LDTXT3:     LD      A,(HL)               ; If CR make sure any LF is wasted.
            CP      LF
            JR      NZ,LDTXT4            
            INC     HL
LDTXT4:     LD      (SECTPOS),HL
            LD      HL,STACKE            ; Start of line to insert.
            XOR     A
            LD      (DE),A               ; Terminate string, BASIC uses NULL terminated strings.
            CALL    ATOH                 ; Get line number into DE
            PUSH    DE                   ; Save line number
            CALL    CRUNCH               ; Convert text to tokens. A returns with size of line in BUFFER.
            LD      L,C                  ; Length of string to L.
            LD      H,0
            LD      BC,(PROGND)
            PUSH    BC
            ADD     HL,BC                ; Find new end
            LD      (PROGND),HL          ; Update end of program pointer
            POP     DE                   ; Get back old pointer.
            EX      DE,HL
            LD      (HL),E               ; Set pointer to end of line.
            INC     HL                   
            LD      (HL),D
            INC     HL                   ; Move onto line number.
            POP     DE                   ; Get back line number,
            LD      (HL),E
            INC     HL
            LD      (HL),D               ; Store line number.
            INC     HL                   ; HL now points to first location for tokenised line.
            LD      DE,BUFFER            ; Copy buffer to program
LDMVBUF:    LD      A,(DE)               ; Get source
            LD      (HL),A               ; Save destinations
            INC     HL                   ; Next source
            INC     DE                   ; Next destination
            OR      A                    ; Done?
            JP      NZ,LDMVBUF           ; No - Repeat
            ;
            JP      LDTXT0               ; Get next line.
LDTXTE:     CALL    LDCLOSE              ; Close file for exit.
            RET

            ; Method to save BASIC text to file.
            ;
SAVE:       LD      A,TAPESAVE           ; Set the type of operation into the flag var.
            JR      CSAVE0

            ; Method to save a cassette image (tokenised basic script).
            ;
CSAVE:      LD      A,CTAPESAVE          ; Set the type of operatiom into the flag var.
CSAVE0:     LD      (TPFLAG),A
            ;
            LD      B,1                  ; Flag "CSAVE"
       ;    CP      ZTIMES               ; "*" token? ("CSAVE*")
       ;    JP      Z,ARRSV1             ; Yes - Array save
            CALL    EVAL                 ; Evaluate expression
            PUSH    HL
            CALL    GTFLNM               ; Get file name
            ;
            LD      HL,TZSVC_FILENAME    ; Set the filename to be created.
            LD      A,(TMSTPL)                                   
            CP      TZSVCFILESZ          ; Check size of filename, cant be more than an MZF name of 17 chars.
            JP      NC,SDFNTG
            LD      B,A
CSAVE1:     LD      A,(DE)               ; Copy filename into service record.
            LD      (HL),A
            INC     DE
            INC     HL
            DJNZ    CSAVE1
            XOR     A
            LD      (HL),A               ; Terminate filename.
            ;
            LD      A,(TPFLAG)           ; What are we processing, cassette image or text?
            CP      CTAPESAVE
            JR      Z,CSAVE2             ; Is this a cassette image save?
            ;
            PUSH    DE
            CALL    SVOPEN               ; Open the required file for writing.
            CALL    SVTXT                ; Expand and save text into the file
            CALL    SVCLOSE              ; Finish by closing file so no corruption occurs.
            POP     DE
            JR      CSAVEE
CSAVE2:     SCF
            CCF
            CALL    PRCFIL               ; Process file as a save request.
CSAVEE:     POP     HL
            RET


            ; Methods to open, write and close an SD file for storage of basic program data. Cassette files are read/written
            ; directly to memory by the K64F but text files, as they are being expanded/compressed, need to be read/written
            ; sector by sector.
            ;
SVOPEN:     PUSH    HL
            XOR     A
            LD      (TZSVC_FILE_SEC),A   ; Starting sector number.
            LD      A,TZSVC_FTYPE_BAS    ; Type of file is BASic, the K64F will know how to handle it.
            LD      (TZSVC_FILE_TYPE),A
            LD      HL,0
            LD      (TZSVC_SAVESIZE),HL  ; Initialise the sector size count.
            POP     HL
            LD      A,TZSVC_CMD_WRITEFILE
            CALL    SVC_CMD              ; And make communications wit the I/O processor, returning with the required record.
            OR      A                    ; Zero means no physical error occurred.
            JP      NZ, SDCRER           ; Create error, K64F didint respond, cannot write!
            LD      A,(TZSVCRESULT)      ; Check the result from the K64F, non zero is an error.
            OR      A
            JP      NZ, SDCRER           ; Same thing, if K64F processes request and returns an error, creation problem!
            RET

SVCLOSE:    CALL    SVBUF                ; Flush out any unwritten data.
            LD      A,TZSVC_CMD_CLOSE    ; Close file.
            CALL    SVC_CMD              ; And make communications wit the I/O processor, returning with the required record.
            OR      A                    ; Zero means no physical error occurred.
            JP      NZ, SDCLER           ; Close error, K64F didint respond, cannot write so flag as error!
            LD      A,(TZSVCRESULT)      ; Check the result from the K64F, non zero is an error.
            OR      A
            JP      NZ, SDCLER           ; Same thing, if K64F closes file and returns an error, closing problem (SD removed!)!
            RET

SVBUF:      LD      A, TZSVC_CMD_NEXTWRITEFILE
            CALL    SVC_CMD              ; And make communications with the I/O processor, returning with the required record.
            OR      A                    ; Zero means no physical error occurred.
            JP      NZ, SDWRER           ; Write error, K64F didint respond, cannot write so flag as error!
            LD      A,(TZSVCRESULT)      ; Check the result from the K64F, non zero is an error.
            OR      A
            JP      NZ, SDWRER           ; Same thing, if K64F write to file and returns an error, write error (SD removed or disk full!)!
            LD      A,(TZSVC_FILE_SEC)   ; Update the virtual file sector number
            INC     A
            LD      (TZSVC_FILE_SEC),A
            LD      DE,0
            LD      (TZSVC_SAVESIZE),DE  ; Initialise to empty sector.
            RET
 
            ; Methods to write into the SD sector a BASIC script as it is expanded into text.
            ;
WRLINE:     PUSH    BC                   ; Convert line number in DE into text.
            XOR     A
            LD      B,80H+24             ; 24 bits
            CALL    RETINT               ; Return the integer
            CALL    NUMASC               ; Output line number in decimal
            POP     BC
            LD      HL,PBUFF             ; Text version of line number now in PBUFF
WRLINE1:    LD      A,(HL)               ; Loop and write to service command sector, 0 terminates string.
            OR      A
            RET     Z
            CALL    WRBUF
            INC     HL
            JR      WRLINE1

WRCRLF:     LD      A,CR                 ; Carriage return first.
            CALL    WRBUF
            LD      A,LF                 ; Now line feed.
WRBUF:      PUSH    HL                   ; Save as were using it.
            PUSH    DE
            LD      DE,(TZSVC_SAVESIZE)  ; Get current pointer into sector for next char.
            LD      HL,TZSVCSECTOR       ; Add in the absolute address of the service sector.
            ADD     HL,DE
            LD      (HL),A               ; Save at correct location.
       ;    CALL    PRNT                 ; Print out what is being saved, debug!
            INC     DE
            LD      (TZSVC_SAVESIZE),DE  ; Update the sector location for next byte.
            LD      A,D
            CP      2                    ; Test to see if buffer full. Hard coded 512 byte msb as Glass isnt resolving shift right correctly.
            JR      NZ,WRBUF1
            CALL    SVBUF                ; Save the buffer.
            ; Write out buffer.
WRBUF1:     POP     DE
            POP     HL                   ; Restore and get out.
            RET


            ; Method to save the current program in memory to SD card as text.
            ; This is the most common way of working with basic scripts, the cassette
            ; image type offers speed but in this day and age it is not so much needed.
            ;
SVTXT:      LD      DE,0
            CALL    SRCHLN               ; Search for line number in DE
            PUSH    BC                   ; Save address of line
            CALL    SETLIN               ; Set up lines counter
            JR      SVTXT1               ; Skip CR on first line.
SVTXT0:     CALL    WRCRLF               ; Write CRLF to buffer.
SVTXT1:     POP     HL                   ; Restore address of line
            LD      C,(HL)               ; Get LSB of next line
            INC     HL
            LD      B,(HL)               ; Get MSB of next line
            INC     HL
            LD      A,B                  ; BC = 0 (End of program)?
            OR      C
            RET     Z                    ; Yes - finish save.
            CALL    SVCNT                ; Count lines
            PUSH    BC                   ; Save address of next line
            LD      E,(HL)               ; Get LSB of line number
            INC     HL
            LD      D,(HL)               ; Get MSB of line number
            INC     HL
            PUSH    HL                   ; Save address of line start
            CALL    WRLINE               ; Write out the line number.
            LD      A,' '                ; Space after line number
            POP     HL                   ; Restore start of line address
SVTXT2:     CALL    WRBUF                ; Output character in A
SVTXT3:     LD      A,(HL)               ; Get next byte in line
            OR      A                    ; End of line?
            INC     HL                   ; To next byte in line
            JP      Z,SVTXT0             ; Yes - get next line
            JP      P,SVTXT2             ; No token - output it
            SUB     ZEND-1               ; Find and output word
            LD      C,A                  ; Token offset+1 to C
            LD      DE,WORDS             ; Reserved word list
SVTXT4:     LD      A,(DE)               ; Get character in list
            INC     DE                   ; Move on to next
            OR      A                    ; Is it start of word?
            JP      P,SVTXT4             ; No - Keep looking for word
            DEC     C                    ; Count words
            JP      NZ,SVTXT4            ; Not there - keep looking
SVTXT5:     AND     01111111B            ; Strip bit 7
            CALL    WRBUF                ; Output first character
            LD      A,(DE)               ; Get next character
            INC     DE                   ; Move on to next
            OR      A                    ; Is it end of word?
            JP      P,SVTXT5             ; No - output the rest
            JP      SVTXT3               ; Next byte in line

SVCNT:      PUSH    HL                   ; Save code string address
            PUSH    DE
            LD      HL,(LINESC)          ; Get LINES counter
            LD      DE,-1
            ADC     HL,DE                ; Decrement
            LD      (LINESC),HL          ; Put it back
            POP     DE
            POP     HL                   ; Restore code string address
            RET     P                    ; Return if more lines to go
            PUSH    HL                   ; Save code string address
            LD      HL,(LINESN)          ; Get LINES number
            LD      (LINESC),HL          ; Reset LINES counter
            POP     HL                   ; Restore code string address
            JP      SVCNT                ; Keep on counting

            ; Method to process a cassette based file load/save.
            ; The file is stored in a tokenised format and maintains a degree
            ; of compatibility with NASCOM files. To use NASCOM files please
            ; see the 'nasconv' tool which updates the tokens as this version
            ; of BASIC adds additional commands which meant adjusting token values.
            ;
PRCFIL:     JR      NC,PRCFIL1
            LD      HL,(BASTXT)          ; Get start of program memory.
            LD      (TZSVC_LOADADDR), HL
            LD      DE,(LSTRAM)
            EX      DE,HL
            SBC     HL,DE
            LD      (TZSVC_LOADSIZE),HL  ; Place max size we can load into the service loadsize field.
            LD      A,TZSVC_CMD_LOADFILE
            JR      PRCFIL2
PRCFIL1:    LD      DE,(BASTXT)          ; Get start of program memory.
            LD      (TZSVC_SAVEADDR), DE
            LD      HL,(PROGND)          ; End of program information
            SBC     HL,DE                ; Get size of program.
            LD      (TZSVC_SAVESIZE),HL  ; Store into service record.
            LD      A,TZSVC_CMD_SAVEFILE  
PRCFIL2:    PUSH    AF                   ; Save service command to execute.
            ;
            ; Setup the service record for the file load/save.
            ;
            LD      A,0FFh               ; Tag the filenumber as invalid.
            LD      (TZSVC_FILE_NO), A 
            LD      A,(TMSTPL)                                   
            CP      TZSVCFILESZ          ; Check size of filename, cant be more than an MZF name of 17 chars.
            JR      NC,SDFNTG
            LD      A,TZSVC_FTYPE_CAS    ; Type of file is CASsette, the K64F will know how to handle it.
            LD      (TZSVC_FILE_TYPE),A
            POP     AF
            CALL    SVC_CMD              ; And make communications wit the I/O processor, returning with the required record.
            OR      A                    ; Zero means no physical error occurred.
            JR      Z, PRCFIL3
            JR      SDPHYER
PRCFIL3:     LD      A,(TZSVCRESULT)      ; Check the result from the K64F, non zero is an error.
            OR      A
            RET     Z
            LD      A,(TZSVCCMD)
            CP      TZSVC_CMD_LOADFILE
            JR      Z,SDLDER
            JR      SDSVER

SDNONAM:    LD      HL,BADFN             ; Must give a name for SD card load and save.
SDERR:      CALL    PRS
            POP     AF                   ; Waste return address.
            JP      ERRIN
SDFNTG:     LD      HL,FNTOOG
            JR      SDERR
SDPHYER:    LD      HL,PHYERR
            JR      SDERR
SDLDER:     LD      HL,LOADERR
            JR      SDERR
SDSVER:     LD      HL,SAVEERR
            JR      SDERR
SDCRER:     LD      HL,CREATER
            JR      SDERR
SDCLER:     LD      HL,CLOSEER
            JR      SDERR
SDWRER:     LD      HL,WRITEER
            JR      SDERR
SDOPER:     LD      HL,OPENER
            JR      SDERR
SDRDER:     LD      HL,READER
            JR      SDERR

            ; Command to change the Z80 CPU frequency if running with the tranZPUter upgrade.
SETFREQ:    CALL    POSINT               ; Get frequency in KHz
            PUSH    HL
            ;
            LD      (TZSVC_CPU_FREQ),DE  ; Set the required frequency in the service structure.
            LD      A,D
            CP      E
            JR      NZ,SETFREQ1
            LD      A, TZSVC_CMD_CPU_BASEFREQ ; Switch to the base frequency.
            JR      SETFREQ2
SETFREQ1:   LD      A, TZSVC_CMD_CPU_ALTFREQ  ; Switch to the alternate frequency.
SETFREQ2:   CALL    SVC_CMD
            OR      A
            JR      NZ,SETFREQERR
            LD      A,D
            CP      E
            JR      Z,SETFREQ4           ; If we are disabling the alternate cpu frequency (ie. = 0) indicate success.
            LD      A, TZSVC_CMD_CPU_CHGFREQ  ; Switch to the base frequency.
            CALL    SVC_CMD
            OR      A
            JR      NZ,SETFREQERR
            LD      HL, (TZSVC_CPU_FREQ) ; Get the actual frequency the K64F could create.
            CALL    PRNTHL               ; Output amount of free memory
            LD      HL,FREQSET           ; Output the actual frequency.
SETFREQ3:   CALL    PRS                  ; Output string
            POP     HL
            RET
SETFREQ4:   LD      HL,FREQDEF           ; Set to default.
            JR      SETFREQ3
            ;
SETFREQERR: LD      HL,FREQERR
            JR      SDERR


MONITR:     
MONITR2     IF BUILD_TZFS = 1
            ; Switch memory back to TZFS mode.
            LD      A, TZMM_TZFS 
            OUT     (MMCFG),A 
            ENDIF
            JP      REBOOT               ; Restart (Normally Monitor Start)

            ;-------------------------------------------------------------------------------
            ; TIMER INTERRUPT                                                                      
            ;                                                                              
            ; This is the RTC interrupt, which interrupts every 100msec. RTC is maintained
            ; by keeping an in memory count of seconds past 00:00:00 and an AMPM flag.
            ;-------------------------------------------------------------------------------
TIMIN:      LD      (SPISRSAVE),SP                                       ; Use a seperate stack for the interrupt as the hardware is paged in and RAM paged out.
            LD      SP,ISRSTACK
            ;
            PUSH    AF                                                   ; Save used registers.
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
MEMSW2:     IF BUILD_TZFS = 1
            LD      A,TZMM_MZ700_0                                       ; We meed to be in memory mode 10 to process the interrupts as this allows us access to the hardware.
            OUT     (MMCFG),A
            ENDIF
            ;
            ; Reset the interrupt counter.
            LD      HL,CONTF                                             ; CTC Control register, set to reload the 100ms interrupt time period.
            LD      (HL),080H                                            ; Select Counter 2, latch counter, read lsb first, mode 0 and binary.
            PUSH    HL
            DEC     HL
            LD      E,(HL)
            LD      D,(HL)                                               ; Obtain the overrun count if any (due to disabled interrupts).
            LD      HL, 00001H                                           ; Add full range to count to obtain the period of overrun time.
            SBC     HL,DE
            EX      DE,HL
            POP     HL
            LD      (HL),0B0H                                            ; Select Counter 2, load lsb first, mode 0 interrupt on terminal count, binary
            DEC     HL
            LD      (HL),TMRTICKINTV
            LD      (HL),000H                                            ; Another 100msec delay till next interrupt.
            ;
            ; Update the RTC with the time period.
            LD      HL,(TIMESEC)                                         ; Lower 16bits of counter.
            ADD     HL,DE
            LD      (TIMESEC),HL
            JR      NC,TIMIN1                                            ; On overflow we increment middle 16bits.
            ; 
            LD      HL,(TIMESEC+2)
            INC     HL 
            LD      (TIMESEC+2),HL
            LD      A,H
            OR      L
            JR      NZ,TIMIN1                                            ; On overflow we increment upper 16bits.
            ;
            LD      HL,(TIMESEC+4)
            INC     HL 
            LD      (TIMESEC+4),HL

            ;
            ; Flash a cursor at the current XY location.
            ;
TIMIN1:     LD      HL,FLASHCTL
            BIT     7,(HL)                                               ; Is cursor enabled? If it isnt, skip further processing.
            JR      Z,TIMIN3
            ;
FLSHCTL0:   LD      A,(KEYPC)                                            ; Flashing component, on each timer tick, display the cursor or the original screen character.
            LD      C,A
            XOR     (HL)                                                 ; Detect a cursor change signal.
            RLCA    
            RLCA    
            JR      NC,TIMIN3                                            ; No change, skip.

            RES     6,(HL)
            LD      A,C                                                  ; We know there was a change, so decide what to display and write to screen.
            RLCA
            RLCA
            LD      A,(FLASH)
            JR      NC,FLSHCTL1
            SET     6,(HL)                                               ; We are going to display the cursor, so save the underlying character.
            LD      A,(FLSDT)                                            ; Retrieve the cursor character.
FLSHCTL1:   LD      HL,(DSPXYADDR)                                       ; Load the desired cursor or character onto the screen.
            LD      (HL),A

            ;
            ; Keyboard processing.
            ;
TIMIN3:                                                                  ; Perform keyboard sweep - inline to avoid overhead of a call.
            ; KEYBOARD SWEEP
            ;
            ; EXIT B,D7=0    NO DATA
            ;          =1    DATA
            ;        D6=0    SHIFT OFF
            ;          =1    SHIFT ON
            ;      C   =     ROW & COLUMN
            ;
SWEP:       XOR     A
            LD      (KDATW),A                                            ; Reset key counter
            LD      B,0FAH                                               ; Starting scan line, D3:0 = scan = line 10. D5:4 not used, D7=Cursor flash.
            LD      D,A

            ; BREAK TEST
            ; BREAK ON  : ZERO = 1
            ;       OFF : ZERO = 0
            ; NO KEY    : CY = 0
            ; KEY IN    : CY = 1
            ;     A D6=1: SHIFT ON
            ;         =0: SHIFT OFF
            ;       D5=1: CTRL ON
            ;         =0: CTRL OFF
            ;       D4=1: GRAPH ON
            ;         =0: GRAPH OFF
BREAK:      LD      A,0F0H
            LD      (KEYPA),A                                            ; Port A scan line 0
            NOP     
            LD      A,(KEYPB)                                            ; Read back key data.
            OR      A
            RLA     
            JR      NC,BREAK3                                            ; CTRL/BREAK key pressed?
            RRA     
            RRA                                                          ; Check if SHIFT key pressed/
            JR      NC,BREAK1                                            ; SHIFT BREAK not pressed, jump.
            RRA     
            JR      NC,BREAK2                                            ; Check for GRAPH.
            CCF     
            JR      SWEP6 ;SWEP1     

BREAK1:     LD      A,040H                                               ; A D6=1 SHIFT ON
            SCF     
            JR      SWEP6

BREAK2:     LD      A,001H                                               ; No keys found to be pressed on scanline 0.
            LD      (KDATW),A
            LD      A,010H                                               ; A D4=1 GRAPH
            SCF     
            JR      SWEP6

BREAK3:     AND     006H                                                 ; SHIFT + GRAPH + BREAK?
            JR      Z,SWEP1A
            AND     002H                                                 ; SHIFT ?
            JR      Z,SWEP1                                              ; Z = 1 = SHIFT BREAK pressed/
            LD      A,020H                                               ; A D5=1 CTRL
            SCF     
            JR      SWEP6

SWEP1:      LD      D,088H                                               ; Break ON
            JR      SWEP9                   
SWEP1A:     JP      REBOOT                                               ; Shift + Graph + Break ON = RESET.
            ;
            JR      SWEP9                   
SWEP6:      LD      HL,SWPW
            PUSH    HL
            JR      NC,SWEP11                
            LD      D,A
            AND     060H                                                 ; Shift & Ctrl =no data.
            JR      NZ,SWEP11                
            LD      A,D                                                  ; Graph Check
            XOR     (HL)
            BIT     4,A
            LD      (HL),D
            JR      Z,SWEP0                 
SWEP01:     SET     7,D                                                  ; Data available, set flag.
SWEP0:      DEC     B
            POP     HL                                                   ; SWEP column work
            INC     HL
            LD      A,B
            LD      (KEYPA),A                                            ; Port A (8255) D3:0 = Scan line output.
            CP      0F0H
            JR      NZ,SWEP3                                             ; If we are not at scan line 0 then check for key data.              
            LD      A,(HL)                                               ; SWPW
            CP      003H                                                 ; Have we scanned all lines, if yes then no data?
            JR      C,SWEP9                 
            LD      (HL),000H                                            ;
            RES     7,D                                                  ; Reset data in as no data awailable.
SWEP9:      LD      B,D
            JR      ISRKEY0

SWEP11:     LD      (HL),000H
            JR      SWEP0                   
SWEP3:      LD      A,(KEYPB)                                            ; Port B (8255) D7:0 = Key data in for given scan line.
            LD      E,A
            CPL     
            AND     (HL)
            LD      (HL),E
            PUSH    HL
            LD      HL,KDATW
            PUSH    BC
            LD      B,008H
SWEP8:      RLC     E
            JR      C,SWEP7                 
            INC     (HL)
SWEP7:      DJNZ    SWEP8                   
            POP     BC
            OR      A
            JR      Z,SWEP0                 
            LD      E,A
SWEP2:      LD      H,008H
            LD      A,B
            DEC     A                                                    ; TBL adjust
            AND     00FH
            RLCA    
            RLCA    
            RLCA    
            LD      C,A
            LD      A,E
SWEP12:     DEC     H
            RRCA    
            JR      NC,SWEP12                
            LD      A,H
            ADD     A,C
            LD      C,A
            JP      SWEP01

ISRKEY0:    LD      A,B
            RLCA    
            JP      C,ISRKEY2                                            ; CY=1 then data available.
            LD      HL,KDATW
            LD      A,(HL)                                               ; Is a key being held down?
            OR      A
            JR      NZ, ISRAUTORPT                                       ; It is so process as an auto repeat key.
            XOR     A
            LD      (KEYRPT),A                                           ; No key held then clear the auto repeat initial pause counter.
            LD      A,NOKEY                                              ; No key code.
ISRKEY1:    LD      HL,KDATW
            LD      E,A
            LD      A,(HL)                                               ; Current key scan line position.
            INC     HL
            LD      D,(HL)                                               ; Previous key position.
            LD      (HL),A                                               ; Previous <= current
            SUB     D                                                    ; Are they the same?
            JR      NC,ISRKEY11
            INC     (HL)                                                 ; 
ISRKEY11:   LD      A,E
ISRKEY10:   CP      NOKEY
            JR      Z,ISREXIT
            LD      (KEYLAST),A
ISRKEYRPT:  LD      A,(KEYCOUNT)                                         ; Get current count of bytes in the keyboard buffer.
            CP      KEYBUFSIZE - 1
            JR      NC, ISREXIT                                          ; Keyboard buffer full, so waste character.
            INC     A
            LD      (KEYCOUNT),A
            LD      HL,(KEYWRITE)                                        ; Get the write buffer pointer.
            LD      (HL), E                                              ; Store the character.
            INC     L
            LD      A,L
            AND     KEYBUFSIZE-1                                         ; Circular buffer, keep boundaries.
            LD      L,A
            LD      (KEYWRITE),HL                                        ; Store updated pointer.
            ;
ISREXIT:    
MEMSW3:     IF BUILD_TZFS = 1
            LD      A,TZMM_MZ700_2                                       ; Return to the full 64K memory mode.
            OUT     (MMCFG),A
            ENDIF
            ;
            POP     HL
            POP     DE
            POP     BC
            POP     AF
            ;
            LD      SP,(SPISRSAVE)
            EI      
            RET     

            ;
            ; Helper to determine if a key is being held down and autorepeat should be applied.
            ; The criterion is a timer, if this expires then autorepeat is applied.
            ;
ISRAUTORPT: LD      A,(KEYRPT)                                           ; Increment an initial pause counter.
            INC     A
            CP      10
            JR      C,ISRAUTO1                                           ; Once expired we can auto repeat the last key.
            LD      A,(KEYLAST)
            CP      080H
            JR      NC,ISREXIT                                           ; Dont auto repeat control keys.
            LD      E,A
            JR      ISRKEYRPT 
ISRAUTO1:   LD      (KEYRPT),A
            JR      ISREXIT

            ;
            ; Method to alternate through the 3 shift modes, CAPSLOCK=1, SHIFTLOCK=2, NO LOCK=0
            ;
LOCKTOGGLE: LD      HL,FLSDT
            LD      A,(SFTLK)
            INC     A
            CP      3
            JR      C,LOCK0
            XOR     A
LOCK0:      LD      (SFTLK),A
            OR      A
            LD      (HL),043H                                            ; Thick block cursor when lower case.
            JR      Z,LOCK1
            CP      1
            LD      (HL),03EH                                            ; Thick underscore when CAPS lock.
            JR      Z,LOCK1
            LD      (HL),0EFH                                            ; Block cursor when SHIFT lock.
LOCK1:      JP      ISREXIT


ISRKEY2:    RLCA    
            RLCA    
            RLCA    
            JP      C,LOCKTOGGLE                                         ; GRAPH key which acts as the Shift Lock.
            RLCA    
            JP      C,ISRBRK                                             ; BREAK key.
            LD      H,000H
            LD      L,C
            LD      A,C
            CP      038H                                                 ; TEN KEY check.
            JR      NC,ISRKEY6                                           ; Jump if TENKEY.
            LD      A,B
            RLCA    
            LD      B,A
            LD      A,(SFTLK)
            OR      A
            LD      A,B
            JR      Z,ISRKEY14                 
            RLA     
            CCF     
            RRA     
ISRKEY14:   RLA     
            RLA     
            JR      NC,ISRKEY3                
ISRKEY15:   LD      DE,KTBLC
ISRKEY5:    ADD     HL,DE
            LD      A,(HL)
            JP      ISRKEY1                   

ISRKEY3:    RRA     
            JR      NC,ISRKEY6                
            LD      A,(SFTLK)
            CP      1
            LD      DE,KTBLCL
            JR      Z,ISRKEY5
            LD      DE,KTBLS
            JR      ISRKEY5                   

ISRKEY6:    LD      DE,KTBL
            JR      ISRKEY5                   
ISRKEY4:    RLCA    
            RLCA    
            JR      C,ISRKEY15                 
            LD      DE,KTBL
            JR      ISRKEY5                   

            ; Break key pressed, handled in getkey routine.
ISRBRK:     LD      A,(KEYLAST)
            CP      BREAKKEY
            JP      Z,ISREXIT
            XOR     A                                                    ; Reset the keyboard buffer.
            LD      (KEYCOUNT),A
            LD      HL,KEYBUF
            LD      (KEYWRITE),HL
            LD      (KEYREAD),HL
            LD      A,BREAKKEY
            JP      ISRKEY10


KTBL:       ; Strobe 0           
            DB      '"'
            DB      '!'
            DB      'W'
            DB      'Q'
            DB      'A'
            DB      INSERT
            DB      0
            DB      'Z'
            ; Strobe 1
            DB      '$'
            DB      '#'
            DB      'R'
            DB      'E'
            DB      'D'
            DB      'S'
            DB      'X'
            DB      'C'
            ; Strobe 2
            DB      '&'
            DB      '%'
            DB      'Y'
            DB      'T'
            DB      'G'
            DB      'F'
            DB      'V'
            DB      'B'
            ; Strobe 3
            DB      '('
            DB      '\''
            DB      'I'
            DB      'U'
            DB      'J'
            DB      'H'
            DB      'N'
            DB      SPACE
            ; Strobe 4
            DB      '_'
            DB      ')'
            DB      'P'
            DB      'O'
            DB      'L'
            DB      'K'
            DB      '<'
            DB      'M'
            ; Strobe 5
            DB      '~'
            DB      '='
            DB      '{'
            DB      '`'
            DB      '*'
            DB      '+'
            DB      CURSLEFT
            DB      '>'
            ; Strobe 6
            DB      HOMEKEY
            DB      '|'
            DB      CURSRIGHT
            DB      CURSUP
            DB      CR
            DB      '}'
            DB      0
            DB      CURSUP     
            ; Strobe 7
            DB      '8'
            DB      '7'
            DB      '5'
            DB      '4'
            DB      '2'
            DB      '1'
            DB      DBLZERO
            DB      '0'
            ; Strobe 8
            DB      '*'
            DB      '9'
            DB      '-'
            DB      '6'
            DB      0
            DB      '3'
            DB      0
            DB      ','         

KTBLS:      ; Strobe 0          
            DB      '2'         
            DB      '1'         
            DB      'w'         
            DB      'q'         
            DB      'a'         
            DB      DELETE      
            DB      0        
            DB      'z'         
            ; Strobe 1          
            DB      '4'         
            DB      '3'         
            DB      'r'         
            DB      'e'         
            DB      'd'         
            DB      's'         
            DB      'x'         
            DB      'c'         
            ; Strobe 2          
            DB      '6'         
            DB      '5'         
            DB      'y'         
            DB      't'         
            DB      'g'         
            DB      'f'         
            DB      'v'         
            DB      'b'         
            ; Strobe 3          
            DB      '8'         
            DB      '7'         
            DB      'i'         
            DB      'u'         
            DB      'j'         
            DB      'h'         
            DB      'n'         
            DB      SPACE       
            ; Strobe 4          
            DB      '0'         
            DB      '9'         
            DB      'p'         
            DB      'o'         
            DB      'l'         
            DB      'k'         
            DB      ','         
            DB      'm'         
            ; Strobe 5          
            DB      '^'         
            DB      '-'         
            DB      '['         
            DB      '@'         
            DB      ':'         
            DB      ';'         
            DB      '/'         
            DB      '.'         
            ; Strobe 6          
            DB      CLRKEY      
            DB      '\\'        
            DB      CURSLEFT    
            DB      CURSDOWN    
            DB      CR          
            DB      ']'         
            DB      0        
            DB      '?'         

KTBLCL:     ; Strobe 0          
            DB      '2'         
            DB      '1'         
            DB      'W'         
            DB      'Q'         
            DB      'A'         
            DB      DELETE      
            DB      0        
            DB      'Z'         
            ; Strobe 1          
            DB      '4'         
            DB      '3'         
            DB      'R'         
            DB      'E'         
            DB      'D'         
            DB      'S'         
            DB      'X'         
            DB      'C'         
            ; Strobe 2          
            DB      '6'         
            DB      '5'         
            DB      'Y'         
            DB      'T'         
            DB      'G'         
            DB      'F'         
            DB      'V'         
            DB      'B'         
            ; Strobe 3          
            DB      '8'         
            DB      '7'         
            DB      'I'         
            DB      'U'         
            DB      'J'         
            DB      'H'         
            DB      'N'         
            DB      SPACE       
            ; Strobe 4          
            DB      '0'         
            DB      '9'         
            DB      'P'         
            DB      'O'         
            DB      'L'         
            DB      'K'         
            DB      ','         
            DB      'M'         
            ; Strobe 5          
            DB      '^'         
            DB      '-'         
            DB      '['         
            DB      '@'         
            DB      ':'         
            DB      ';'         
            DB      '/'         
            DB      '.'         
            ; Strobe 6          
            DB      CLRKEY      
            DB      '\\'        
            DB      CURSLEFT    
            DB      CURSDOWN    
            DB      CR          
            DB      ']'         
            DB      0        
            DB      '?'         
                                
KTBLC:      ; CTRL ON
            ; Strobe 0
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_W
            DB      CTRL_Q
            DB      CTRL_A
            DB      NOKEY
            DB      000H
            DB      CTRL_Z
            ; Strobe 1
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_R
            DB      CTRL_E
            DB      CTRL_D
            DB      CTRL_S
            DB      CTRL_X
            DB      CTRL_C
            ; Strobe 2
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_Y
            DB      CTRL_T
            DB      CTRL_G
            DB      CTRL_F
            DB      CTRL_V
            DB      CTRL_B
            ; Strobe 3
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_I
            DB      CTRL_U
            DB      CTRL_J
            DB      CTRL_H
            DB      CTRL_N
            DB      NOKEY
            ; Strobe 4
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_P
            DB      CTRL_O
            DB      CTRL_L
            DB      CTRL_K
            DB      NOKEY
            DB      CTRL_M
            ; Strobe 5
            DB      CTRL_CAPPA
            DB      CTRL_UNDSCR
            DB      ESC
            DB      CTRL_AT
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            ; Strobe 6
            DB      NOKEY
            DB      CTRL_SLASH
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_RB
            DB      NOKEY

            ;-------------------------------------------------------------------------------
            ; END OF TIMER INTERRUPT                                                                      
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
            LD      (HL),03BH                                            ; Place divisor in Counter 1, = 315, thus 31500/315 = 100
            LD      (HL),001H
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
TIMEREAD:  LD      HL,(TIMESEC+4)
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
            ; UTILITIES
            ;-------------------------------------------------------------------------------

            ; Function to print a string with control character interpretation.
MONPRTSTR:  LD      A,(DE)
            OR      A
            RET     Z
            INC     DE
MONPRTSTR2: CALL    PRNT
            JR      MONPRTSTR

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
DELETECHR:  LD      A,0C7H
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
            LD      (SPISRSAVE),SP                                       ; Share the interrupt stack for banked access as the BASIC stack goes out of scope.
            LD      SP,ISRSTACK                                          ; Interrupts are disabled so we can safely use this stack.
            ;
MEMSW4:     IF BUILD_TZFS = 1
            PUSH    AF
            LD      A,TZMM_MZ700_0                                       ; Enable access to the hardware by paging out the upper bank.
            OUT     (MMCFG),A
            POP     AF
            ENDIF
            ;
            CALL    CURSRSTR                                             ; Restore char under cursor.
            CP      00DH
            JR      Z,NEWLINE                 
            CP      00AH
            JR      Z,NEWLINE                 
            CP      07FH
            JR      Z,DELETECHR
            CP      BACKS
            JR      Z,DELETECHR
            PUSH    BC
            LD      C,A
            LD      B,A
            CALL    PRT
            LD      A,B
            POP     BC
PRNT1:      CALL    DSPXYTOADDR
            ;
MEMSW5:     IF BUILD_TZFS = 1
            LD      A,TZMM_MZ700_2                                       ; Enable access to the hardware by paging out the upper bank.
            OUT     (MMCFG),A
            ENDIF
            ;
            LD      SP,(SPISRSAVE)                                       ; Restore the BASIC stack to exit.
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
            CALL    ASCII
            CALL    PRNT
            POP     AF
            CALL    ASCII
            JP      PRNT

ASCII:      AND     00FH
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

            ;-------------------------------------------------------------------------------
            ; ANSI TERMINAL FUNCTIONALITY
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
ANSITERM:   IF INCLUDE_ANSITERM = 1
            PUSH    HL
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
CLRSCRN:    DI
            ;
MEMSW6:     IF BUILD_TZFS = 1
            LD      A,TZMM_MZ700_0                                       ; Enable access to the hardware by paging out the upper bank.
            OUT     (MMCFG),A
            ENDIF

            LD      (HLSAVE),HL                                          ; 1 for later!
            LD      D,H
            LD      E,L
            INC     DE                                                   ; DE <- HL +1
            LD      (BCSAVE),BC                                          ; Save the value a little longer!
            XOR     A
            LD      (HL), A                                              ; Blank this area!
            LDIR                                                         ; *** just like magic ***
                                                                         ;     only I forgot it in 22a!
            LD      BC,(BCSAVE)                                          ; Restore values
            LD      HL,(HLSAVE)
            LD      DE,2048                                              ; Move to attributes block
            ADD     HL,DE
            LD      D,H
            LD      E,L
            INC     DE                                                   ; DE = HL + 1
            LD      A,(FONTSET)                                          ; Save in the current values.
            LD      (HL),A
            LDIR

MEMSW7:     IF BUILD_TZFS = 1
            LD      A,TZMM_MZ700_2                                       ; Enable access to the hardware by paging out the upper bank.
            OUT     (MMCFG),A
            ENDIF
            ;
            EI
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


            ; Control variables for the Ansi Emulator. Inline with the code as this module
            ; is a build time include and the target for execution is RAM.
            ;
CURSORPSAV  DS      2,    0                                              ; Cursor save position;default 0,0
HAVELOADED  DS      1,    0                                              ; To show that a value has been put in for Ansi emualtor.
ANSIFIRST   DS      1,    0                                              ; Holds first character of Ansi sequence
NUMBERBUF   DS      20,   0                                              ; Buffer for numbers in Ansi
NUMBERPOS   DW      1,    NUMBERBUF                                      ; Address within buffer
CHARACTERNO DS      1,    0                                              ; Byte within Ansi sequence. 0=first,255=other
CURSORCOUNT DS      1,    0                                              ; 1/50ths of a second since last change
FONTSET     DS      1,    017H                                           ; Ansi font setup - Blue background White Foreground as default.
JSW_FF      DS      1,    0                                              ; Byte value to turn on/off FF routine
JSW_LF      DS      1,    0                                              ; Byte value to turn on/off LF routine
CHARACTER   DS      1,    0                                              ; To buffer character to be printed.    
CURSORPOS   DS      2,    0                                              ; Cursor position, default 0,0.
BOLDMODE    DS      1,    0
HIBRITEMODE DS      1,    0                                              ; 0 means on, &C9 means off
UNDERSCMODE DS      1,    0
ITALICMODE  DS      1,    0
INVMODE     DS      1,    0
CHGCURSMODE DS      1,    0
ANSIMODE    DS      1,    0                                              ; 1 = on, 0 = off
BCSAVE      DW      1,    0                                              ; Register save for when stack is not paged in.
DESAVE      DW      1,    0
HLSAVE      DW      1,    0
COLOUR      EQU     0

            ENDIF
            ;-------------------------------------------------------------------------------
            ; END OF ANSI TERMINAL FUNCTIONALITY
            ;-------------------------------------------------------------------------------


REBOOT:     DI
            LD      A,TZMM_TZFS
            OUT     (MMCFG),A
            JP      0000H                                                ; Now restart in the SA1510 monitor.

            ;-------------------------------------------------------------------------------
            ; START OF STATIC LOOKUP TABLES AND CONSTANTS
            ;-------------------------------------------------------------------------------

            ;--------------------------------------
            ; Test Message table
            ;--------------------------------------

BFREE:      DB      " Bytes free",CR,LF,0,0

SIGNON:     DB      "Z80 BASIC Ver 4.7b",CR,LF
            DB      "Copyright ",40,"C",41
            DB      " 1978 by Microsoft",CR,LF,0,0

SDAVAIL:    DB      "SD",                                                              NUL
FDCAVAIL:   DB      "FDC",                                                             NUL
NOBDOS:     DB      "I/O Processor failed to load BDOS, aborting!",            CR, LF, NUL
SVCRESPERR: DB      "I/O Response Error, time out!",                           CR,     NUL
SVCIOERR:   DB      "I/O Error, time out!",                                    CR,     NUL
BADFN:      DB      "Filename missing!",                                       CR,     NUL
FNTOOG:     DB      "Filename too long!",                                      CR,     NUL
PHYERR:     DB      "SD/K64F IO error!",                                       CR,     NUL
LOADERR:    DB      "File loading error!",                                     CR,     NUL
SAVEERR:    DB      "File save error!",                                        CR,     NUL
CREATER:    DB      "File create error!",                                      CR,     NUL
CLOSEER:    DB      "File close error!",                                       CR,     NUL
WRITEER:    DB      "File write error!",                                       CR,     NUL
OPENER:     DB      "File open error!",                                        CR,     NUL
READER:     DB      "File read error!",                                        CR,     NUL
FREQERR:    DB      "Failed to change frequency!",                             CR,     NUL
FREQSET:    DB      " KHz set.",                                               CR, LF, NUL
FREQDEF:    DB      "Set to default.",                                         CR, LF, NUL

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

            POP     AF
            JR      C, SKIPDUMP
            ;
            LD      HL,04000H  ; WRKSPC                                            ; Dump the startup vectors.
            LD      DE, 1000H
            ADD     HL, DE
            EX      DE,HL
            LD      HL,WRKSPC
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
INFOMSG:    DB      "AF=",   NUL
INFOMSG2:   DB      ",BC=",  000H
INFOMSG3:   DB      ",DE=",  000H
INFOMSG4:   DB      ",HL=",  000H
INFOMSG5:   DB      ",SP=",  000H

            ; Seperate stack for the debugger so as not to affect anything it is reporting on.
            ;
TMPCNT      DS      virtual 2                                            ; TEMPORARY COUNTER
DBGSTACKP:  DS      2
            DS      128, 000H
DBGSTACK:   EQU     $

            ENDIF
            ;-------------------------------------------------------------------------------
            ; END OF DEBUGGING FUNCTIONALITY
            ;-------------------------------------------------------------------------------
CODEEND:

            ;-------------------------------------------------------------------------------
            ; BASIC RELOCATION
            ;-------------------------------------------------------------------------------

            ; For TZFS builds the image needs to be relocated from 0x1200 to 0x0000 on startup after switching the memory mode.
RELOCSTART: IF BUILD_TZFS = 1
            ORG     $ + 1200H

            ; Swtch memory.
RELOC:      LD      A, TZMM_MZ700_0                                      ; Switch to the MZ700 memory map where the lower 4K 0000:0FFF is in block 6, we therefore preserve the Monitor for exit.
            OUT     (MMCFG),A 

            ; Move the image down and start.
            LD      DE, 0000H
            LD      HL, 01200H
            LD      BC, CODEEND - CODESTART
            LDIR
            JP      0000H
RELOCEND:   ENDIF


            ; Variables start at the end of the code in the running image (not relocatable image).
            ORG     CODEEND
GVARSTART   EQU     $                                                    ; Start of variables.

            ; Pad out so that the keyboard buffer is aligned on a 256 byte block boundary.
            ALIGN   ($ + 0100H) & 0FF00H

KEYBUF:     DS      virtual KEYBUFSIZE                                   ; Interrupt driven keyboard buffer.
KEYCOUNT:   DS      virtual 1
KEYWRITE:   DS      virtual 2                                            ; Pointer into the buffer where the next character should be placed.
KEYREAD:    DS      virtual 2                                            ; Pointer into the buffer where the next character can be read.
KEYLAST:    DS      virtual 1                                            ; Last key value
KEYRPT:     DS      virtual 1                                            ; Key repeat counter


SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:       DS      virtual 1                                            ; ATTRIBUTE
NAME:       DS      virtual 17                                           ; FILE NAME
SIZE:       DS      virtual 2                                            ; BYTESIZE
DTADR:      DS      virtual 2                                            ; DATA ADDRESS
EXADR:      DS      virtual 2                                            ; EXECUTION ADDRESS
COMNT:      DS      virtual 92                                           ; Comment / code area of CMT header.
SWPW:       DS      virtual 10                                           ; SWEEP WORK
KDATW:      DS      virtual 2                                            ; KEY WORK
KANAF:      DS      virtual 1                                            ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:      DS      virtual 2                                            ; DISPLAY COORDINATES
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
SWRK:       DS      virtual 1                                            ; KEY SOUND FLAG
TEMPW:      DS      virtual 1                                            ; TEMPO WORK
ONTYO:      DS      virtual 1                                            ; ONTYO WORK
OCTV:       DS      virtual 1                                            ; OCTAVE WORK
RATIO:      DS      virtual 2                                            ; ONPU RATIO
DSPXYADDR:  DS      virtual 2                                            ; Address of last known position.

FLASHCTL:   DS      virtual 1                                            ; CURSOR FLASH CONTROL. BIT 0 = Cursor On/Off, BIT 1 = Cursor displayed.
TIMESEC:    DS      virtual 6                                            ; RTC 48bit TIME IN MILLISECONDS
;
TPFLAG      DS      virtual 1
SECTPOS     DS      virtual 2

SPISRSAVE:  DS      virtual 2
            ; Stack space for the Interrupt Service Routine.
            DS      virtual 32                                           ; Max 8 stack pushes.
ISRSTACK    EQU     $
STACKE:     EQU     $
            DS      virtual 128
STACK:      EQU     $


WRKSPC      DS      virtual 3                                            ;  0       BASIC Work space
USR         DS      virtual 3                                            ; 3H       "USR (x)" jump
OUTSUB      DS      virtual 1                                            ; 6H       "OUT p,n"
OTPORT      DS      virtual 2                                            ; 7H       Port (p)
DIVSUP      DS      virtual 1                                            ; 9H       Division support routine
DIV1        DS      virtual 4                                            ; 0AH      <- Values
DIV2        DS      virtual 4                                            ; 0EH      <-   to
DIV3        DS      virtual 3                                            ; 12H      <-   be
DIV4        DS      virtual 2                                            ; 15H      <-inserted
SEED        DS      virtual 35                                           ; 17H      Random number seed
LSTRND      DS      virtual 4                                            ; 3AH      Last random number
INPSUB      DS      virtual 1                                            ; 3EH      #INP (x)" Routine
INPORT      DS      virtual 2                                            ; 3FH      PORT (x)
NULLS       DS      virtual 1                                            ; 41H      Number of nulls
LWIDTH      DS      virtual 1                                            ; 42H      Terminal width
COMMAN      DS      virtual 1                                            ; 43H      Width for commas
NULFLG      DS      virtual 1                                            ; 44H      Null after input byte flag
CTLOFG      DS      virtual 1                                            ; 45H      Control "O" flag
LINESC      DS      virtual 2                                            ; 46H      Lines counter
LINESN      DS      virtual 2                                            ; 48H      Lines number
CHKSUM      DS      virtual 2                                            ; 4AH      Array load/save check sum
NMIFLG      DS      virtual 1                                            ; 4CH      Flag for NMI break routine
BRKFLG      DS      virtual 1                                            ; 4DH      Break flag
RINPUT      DS      virtual 3                                            ; 4EH      Input reflection
POINT       DS      virtual 3                                            ; 51H      "POINT" reflection (unused)
PSET        DS      virtual 3                                            ; 54H      "SET"   reflection
RESET       DS      virtual 3                                            ; 57H      "RESET" reflection
STRSPC      DS      virtual 2                                            ; 5AH      Bottom of string space
LINEAT      DS      virtual 2                                            ; 5CH      Current line number
BASTXT      DS      virtual 3                                            ; 5EH      Pointer to start of program
BUFFER      DS      virtual 5                                            ; 61H      Input buffer
STACKI      DS      virtual 69                                           ; 66H      Initial stack
CURPOS      DS      virtual 1                                            ; 0ABH     Character position on line
LCRFLG      DS      virtual 1                                            ; 0ACH     Locate/Create flag
TYPE        DS      virtual 1                                            ; 0ADH     Data type flag
DATFLG      DS      virtual 1                                            ; 0AEH     Literal statement flag
LSTRAM      DS      virtual 2                                            ; 0AFH     Last available RAM
TMSTPT      DS      virtual 2                                            ; 0B1H     Temporary string pointer
TMSTPL      DS      virtual 12                                           ; 0B3H     Temporary string pool
TMPSTR      DS      virtual 4                                            ; 0BFH     Temporary string
STRBOT      DS      virtual 2                                            ; 0C3H     Bottom of string space
CUROPR      DS      virtual 2                                            ; 0C5H     Current operator in EVAL
LOOPST      DS      virtual 2                                            ; 0C7H     First statement of loop
DATLIN      DS      virtual 2                                            ; 0C9H     Line of current DATA item
FORFLG      DS      virtual 1                                            ; 0CBH     "FOR" loop flag
LSTBIN      DS      virtual 1                                            ; 0CCH     Last byte entered
READFG      DS      virtual 1                                            ; 0CDH     Read/Input flag
BRKLIN      DS      virtual 2                                            ; 0CEH     Line of break
NXTOPR      DS      virtual 2                                            ; 0D0H     Next operator in EVAL
ERRLIN      DS      virtual 2                                            ; 0D2H     Line of error
CONTAD      DS      virtual 2                                            ; 0D4H     Where to CONTinue
PROGND      DS      virtual 2                                            ; 0D6H     End of program
VAREND      DS      virtual 2                                            ; 0D8H     End of variables
ARREND      DS      virtual 2                                            ; 0DAH     End of arrays
NXTDAT      DS      virtual 2                                            ; 0DCH     Next data item
FNRGNM      DS      virtual 2                                            ; 0DEH     Name of FN argument
FNARG       DS      virtual 4                                            ; 0E0H     FN argument value
FPREG       DS      virtual 3                                            ; 0E4H     Floating point register
FPEXP       DS      virtual 1                                            ; FPREG+3  Floating point exponent
SGNRES      DS      virtual 1                                            ; 0E8H     Sign of result
PBUFF       DS      virtual 13                                           ; 0E9H     Number print buffer
MULVAL      DS      virtual 3                                            ; 0F6H     Multiplier
PROGST      DS      virtual 100                                          ; 0F9H     Start of program text area
STLOOK      DS      virtual 1                                            ; 15DH     Start of memory test

GVAREND     EQU     $                                                    ; End of variables
