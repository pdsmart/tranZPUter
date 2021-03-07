              ORG   0                                                  
              ;
              ;
              ; SHARPMZ - 8 2 1
              ; (ROM contents, lower monitor 0000-0FFF)
              ;
              ;
              ; Input / Output address
              ;
              ; Printer interface                                              
PCPR:         EQU   0FCH                            ; Z80 / PIO
PLPT:         EQU   PCPR+3                          ; printer data output
PLPTS:        EQU   PCPR+2                          ; printer strobe
PLPTI:        EQU   PCPR+1                          ; printer data port inic
PLPTSI:       EQU   PCPR+0                          ; printer strobe port inic
              ; Program sound generator                                        
PPSG:         EQU   0F2H                            ; Prog. Sound Gen.
              ; Joystick registers                                             
PJ1:          EQU   0F1H                            ; joystick-2 input port
PJ0:          EQU   0F0H                            ; joystick-1 input port
              ; Pallet write                                                   
PPAL:         EQU   0F0H                            ; pallet write
              ; Memory managerment ports  OUT                                  
PMMC6:        EQU   0E6H                            ; condition from hill protection
PMMC5:        EQU   0E5H                            ; protect the hill
PMMC4:        EQU   0E4H                            ; maximum neRAM as far as possible
PMMC3:        EQU   0E3H                            ; ROM up
PMMC2:        EQU   0E2H                            ; ROM down
              ; Memory managerment ports  OUT / IN                             
PMMC1:        EQU   0E1H                            ; DRAM up / VRAM pryc
PMMC0:        EQU   0E0H                            ; DRAM up / VRAM
              ; Floppy disk                                                    
PFD:          EQU   0D8H                                               
PFDSIZ:       EQU   PFD+5                           ; floppy side settings
PFDMOT:       EQU   PFD+4                           ; drive on / off
PFDDAT:       EQU   PFD+3                           ; register that
PFDSEC:       EQU   PFD+2                           ; sector register
PFDTRK:       EQU   PFD+1                           ; track register
PFDCTR:       EQU   PFD+0                           ; driving word
              ; 8253 I/O. mapped. - interupt, clock, etc.                      
P8253:        EQU   0D4H                            ; 8253 I / O. Mapped 
PCTCC:        EQU   P8253+3                         ; control word 8253
PCTC2:        EQU   P8253+2                         ; counter 2
PCTC1:        EQU   P8253+1                         ; counter 1
PCTC0:        EQU   P8253+0                         ; counter 0
              ; 8255 I/O mapped - klavesnice, joystick, CMT                    
P8255:        EQU   0D0H                                               
PCWR55:       EQU   P8255+3                         ; control word 8255
PPORTC:       EQU   P8255+2                         ; port C - CMT and control
PKBDIN:       EQU   P8255+1                         ; keyboard input
PKBOUT:       EQU   P8255+0                         ; keyboard strobe
              ; GDG I/O ports                                                  
PCRTC:        EQU   0CFH                            ; CRTC register
PDMD:         EQU   0CEH                            ; display mod register
PRF:          EQU   0CDH                            ; read format register
PWF:          EQU   0CCH                            ; write format register
              ;                                                                
              ;  Memory mapping                                                
              ;                                                                
MGATE0:       EQU   0E008H                          ; enable / disable music
              ; 8253 mem. mapped - Interupt, clock                             
M8253:        EQU   0E004H                          ; 8253 Mem. Mapped 
MCTCC:        EQU   M8253+3                         ; control word 8253
MCTC2:        EQU   M8253+2                         ; counter 2
MCTC1:        EQU   M8253+1                         ; counter 1
MCTC0:        EQU   M8253+0                         ; counter 0
              ; 8255 mem. mapped - klavesnice, joystick, CMT                   
M8255:        EQU   0E000H                                             
MCWR55:       EQU   M8255+3                         ; control word 8255
MPORTC:       EQU   M8255+2                         ; port C - CMT and control
MKBDIN:       EQU   M8255+1                         ; keyboard input
MKBOUT:       EQU   M8255+0                         ; keyboard strobe
              ;                                                                
              ; definice ASCII konstant                                        
CR:         EQU   0DH                             ; novy line
SPACE:        EQU   20H                             ; gap
ESC:        EQU   1BH                             ; escape
CLS:        EQU   16H                             ; clear the screen
CRD:        EQU   0CDH                            ; CR in display code
NOKEY:         EQU   0F0H                            ; code NO KEY
              ; definice adres displaye                                         
ADRCRT:       EQU   0D000H                          ; address MZ-700 VRAM
ADRATB:       EQU   0D800H                          ; the address of the CRS attribute
IMPATB:       EQU   71H                             ; default display attribute
              ; priznaky pro podprogramy CMT                                   
CHEAD:        EQU   0CCH                            ; indication of CMT work with header
CDATA:        EQU   053H                            ; ---- "---- with data
CWRITE:       EQU   0D7H                            ; CMT indication write data
CREAD:        EQU   0D2H                            ; --- "--- read"
              ;                                                                
HBLNK:        EQU   50*312+11                       ; frequency of line decomposition
              ;
INTSRQ:       EQU   1038H                           ; PjpM
INTADR:       EQU   1039H                           ; 038Dh ... bounce from INT (38h)
HEAD:         EQU   10F0H                           ; file control block:
NEWSP:        EQU   HEAD                            ; processor tray
FNAME:        EQU   10F1H                           ; filename
FSIZE:        EQU   1102H                           ; length
BEGIN:        EQU   1104H                           ; storage address
ENTRY:        EQU   1106H                           ; start address
OLDSP:        EQU   1148H                           ; used to postpone SP
CONMOD:       EQU   1170H                           ; 0b = alpha / graph, 1b = display
CURSOR:       EQU   1171H                           ; cursor position (row / column)
QATBLN:       EQU   1173H                           ; line join attribute table
AKCHAR:       EQU   118EH                           ; the character under the cursor when the cursor is blinking
CURCH:        EQU   1192H                           ; graphical cursor character
CSRH:         EQU   1194H                           ; position on the line
TMLONG:       EQU   1195H                           ; current length TAPE MARK
MGCRC:        EQU   1197H                           ; checksum for CMT
MGCRCV:       EQU   1199H                           ; checksum verify CMT
AMPM:         EQU   119BH                           ; morning / afternoon flag
EIFLG:        EQU   119CH                           ; EI / DI flag
BPFLG:        EQU   119DH                           ; BEEP ON / OFF flag
TEMPO:        EQU   119EH                           ; tempo for music 0-7
NOTLEN:       EQU   119FH                           ; length of current sheet music
OKTNUM:       EQU   11A0H                           ; octave number 1,2,3
FREQ:         EQU   11A1H                           ; frequency of the current tone
IOBUF:        EQU   11A3H                           ; input buffer for GETL
MGBASE:       EQU   1200H                           ; boot address
COLD:         EQU   0E800H                          ; cold start system
RBASE:        EQU   0FFF0H                          ; run the program in RAM
              ;                                                                
              ;
              ; MZ-700 monitor services vector
              ;
@COLD:        JP    COLD                            ; cold start
@GETL:        JP    GETL                            ; read a line from KBD
@LETNL:       JP    LETNL                           ; CRLF and CRT
@IFNL?:       JP    IFNL?                           ; conditional CRLF
@PRNTS:       JP    PRNTS                           ; space on CRT
@TAB:         JP    TAB                             ; tabulation on CRT
@PRNTC:       JP    PRNTC                           ; character on CRT
@MSG:         JP    MSG                             ; CRT string
@RST18:       JP    RST18                           ; reported to CRT
@GETKY:       JP    GETKY                           ; character from KBD
@BRKEY:       JP    BRKEY                           ; test on BREAK
@WHEAD:       JP    WHEAD                           ; write headers to CMT
@WDATA:       JP    WDATA                           ; write the program to CMT
@RHEAD:       JP    RHEAD                           ; read headers from CMT
@RDATA:       JP    RDATA                           ; read the program from CMT
@VERIF:       JP    VERIF                           ; program comparison
@MELDY:       JP    MELDY                           ; melody
@TIMST:       JP    TIMST                           ; time setting
              DB   0,0                              ; called for RST 38H
@RST38:       JP    INTSRQ                          ; interrupt service
@TIMRD:       JP    TIMRD                           ; read time
@BEEP:        JP    BEEP                            ; acoustic signal
@XTEMP:       JP    XTEMP                           ; tempo for melodies
@MSTA:        JP    MSTA                            ; sound start
@MSTP:        JP    MSTP                            ; stopped sound
              ;
              ; COLD - leftover from the MZ-700 computer
              ;
              LD    SP,NEWSP                                           
              IM    1                                                      
              CALL  @INI55                                              
              CALL  BRKEY                                              
              JR    NC,J0070                        ; CTRL or SHIFT
              CP    20H                                                
              JR    NZ,J0070                        ; SHIFT, that's uninteresting
GORAM:                                              ; jump to RAM from address 0
              OUT   (PMMC1),A                       ; mapping - end = DRAM
              LD    DE,RBASE                        ; where
              LD    HL,QRUNT                        ; what
              LD    BC,5                            ; pin
              LDIR                                  ; MOVE
              JP    RBASE                           ; ... jump
              ;                                                                
QRUNT:        OUT   (PMMC0),A                       ; ... for copying
              JP    0                               ; jump to RAM
              ;                                                                
J0070:                                                                 
              LD    B,255                           ; zero
              LD    HL,FNAME                        ; memory info
              CALL  @F0B                            ; cartridge block
              LD    A,CLS                                            
              CALL  @PRNTC                          ; clear display
              LD    A,IMPATB                        ; default attribute 71H
              LD    HL,ADRATB                       ; attribute address in VRAM
              CALL  @FILLA                          ; CRT attribute settings
              LD    HL,@CLOCK                       ; initialization interrupted
              LD    A,0C3H                          ; C3 = JP
              LD    (INTSRQ),A                                         
              LD    (INTADR),HL                     ; the address of the basic interrupt routine
              LD    A,4                                                
              LD    (TEMPO),A                       ; music tempo initialization
              CALL  MSTP                            ; stop music
              CALL  @IFNL?                                             
              LD    DE,SMON7                        ; introductory message of the monitor
              RST   18H                                                
              CALL  BEEP                                               
              LD    A,1                                                
J00A4:                                                                  
              LD    (BPFLG),A                       ; turn off BEEP
              LD    HL,0E800H                       ; if it is on the E800h ROM
              LD    (HL),A                          ; so there is a sale
              JR    J0102                                              
              ;
              ; Input and display decryption
              ; DE .... address of the chain
              ; B ..... its length
              ;
FPRMPT:                                                                
              CALL  @IFNL?                                             
              LD    A,'*'                           ; Reporting sign
              CALL  @PRNTC                                             
              LD    DE,IOBUF                        ; Input buffer address
              CALL  @GETL                           ; Honor the display
PRMLOP:       LD    A,(DE)                                             
              INC   DE                                                 
              CP    CR                                               
              JR    Z,FPRMPT                        ; sell monitor control
              CP    'J'                                                
              JR    Z,FJUMP                         ; sell control of the program
              CP    'L'                                                
              JR    Z,FLOAD                         ; upload and run the program
              CP    'F'                                                
              JR    Z,FF????                        ; jump up when ROM
              CP    'B'                                                
              JR    Z,FBEEPX                        ; beep on / off after the character
              CP    '#'                                                
              JR    Z,GORAM                         ; jump to RAM from 0
              CP    'P'                                                
              JR    Z,FPRINT                        ; printer operator
              CP    'M'                                                
              JP    Z,FMODIF                        ; memory modification
              CP    'S'                                                
              JP    Z,FSAVE                         ; save the program to CMT
              CP    'V'                                                
              JP    Z,FVERIF                        ; program comparison on CMT
              CP    'D'                                                
              JP    Z,FDUMP                         ; listing of memory contents
              NOP                                                      
              NOP                                                      
              NOP                                                      
              NOP                                                      
              JR    PRMLOP                          ; the first character is not a display, perhaps another
              ;                                                                
FJUMP:                                                                 
              CALL  FHLHEX                          ; decode the jump address
              JP    (HL)                            ; and sell control
              ;                                                                
FBEEPX:                                             ; controlled whistling after each character
              LD    A,(BPFLG)                                          
              RRA                                                      
              CCF                                                      
              RLA                                                      
              JR    J00A4                                              
              ;                                                                
FF????:                                             ; look up
              LD    HL,0F000H                       ; if there is something a lot
J0102:                                              ; zajimaveho
              LD    A,(HL)                          ; when there is zero,
              OR    A                               ; so he won't jump there
              JR    NZ,FPRMPT                       ; and when there will be zero
              JP    (HL)                            ; so jump right there
                                                                     ;                                                                
FCMTER:                                             ; recognizes and responds
              CP    2                               ; type of error you
              JR    Z,FPRMPT                        ; return routines for
              LD    DE,SCHECK                       ; works with CMT:
              RST   18H                                                
FPRMP1:                                             ; relative jumps are
              JR    FPRMPT                          ; sometimes too short
              ;                                                                
FLOAD:                                                                 
              CALL  RHEAD                           ; read the program header
              JR    C,FCMTER                                           
              CALL  @IFNL?                                             
              LD    DE,SLOAD                        ; lists LOADING
              RST   18H                                                
              LD    DE,FNAME                        ; and the name of the program
              RST   18H                                                
              CALL  RDATA                           ; read the program
              JR    C,FCMTER                                           
              LD    HL,(ENTRY)                                         
              LD    A,H                             ; if the start address is
              CP    MGBASE/256                      ; less than 1200H so
              JR    C,FPRMP1                        ; return to the monitor and v
              JP    (HL)                            ; otherwise the sale
                                                    ; control of the recorded program
FGETL:                                              ; read the row from the keyboard
              EX    (SP),HL                                            
              POP   BC                                                 
              LD    DE,IOBUF                        ; works with standard
              CALL  @GETL                           ; I / O buffer
              LD    A,(DE)                                             
              CP    ESC                           ; break?
              JR    Z,FPRMP1                        ; yes, return to monitor
              JP    (HL)                            ; no, return
              ;                                                                 
FHLHEX:                                             ; decodes the address in the display
              EX    (SP),IY                         ; returned to IY
              POP   AF                              ; and out of the cellar
              CALL  @HLHEX                          ; try to decode
              JR    C,FPRMP1                        ; not possible, so to the monitor
              JP    (IY)                            ; return
              ;                                                                
SCHECK:       DB    "CHECK SUM ER."                                    
              DB    CR                                               
FPRINT:                                             ; dump the rest of the display
              LD    A,(DE)                          ; on the printer
              CP    '&'                             ; & is a special feature flag
              JR    NZ,FP                           ; & was not, list everything
J015A:        INC   DE                              ; testing character for &
              LD    A,(DE)                                             
              CP    'L'                                                
              JR    Z,FPL                           ; 60 characters per line
              CP    'S'                                                
              JR    Z,FPS                           ; 80 characters per line
              CP    'C'                                                
              JR    Z,FPC                           ; exchange per
              CP    'G'                                                
              JR    Z,FPG                           ; graphically mod
              CP    'T'                                                
              JR    Z,FPT                           ; test
FP:                                                                   
              CALL  FPTEXT                                             
              JP    FPRMPT                                             
              ;                                                                
FPL:                                                                   
              LD    DE,QPRN2                        ; 60 characters per line
              JR    FP
              ;                                                                
FPS:                                                                   
              LD    DE,QPRN1                        ; 80 characters per line
              JR    FP
              ;                                                                
FPT:                                                                   
              LD    A,4                             ; test
              JR    J0186                                              
              ;                                                                
FPG:                                                                   
              LD    A,2                             ; graphically mod
J0186:        CALL  FPCHAR                                             
              JR    J015A                                              
              ;                                                                
FPC:                                                                   
              LD    A,1DH                           ; exchange per
              JR    J0186                                              
              ;                                                                
FPCHAR:                                             ; print character to LPT
              LD    C,0                                                
              LD    B,A                                                
              CALL  FPTEST                          ; check for LPT
              LD    A,B                                                
              OUT   (PLPT),A                        ; after sign
              LD    A,10000000B                                        
              OUT   (PLPTS),A                       ; and confirm it
              LD    C,1                             ; waiting for LPT to be taken over
              CALL  FPTEST                                             
              XOR   A                                                  
              OUT   (PLPTS),A                       ; and match confirmed
              RET                                                      
              ;                                                                
FPTEXT:                                             ; print text to a printer
              PUSH  DE                              ; in DE is the address
              PUSH  BC                              ; the text must end CR
              PUSH  AF                              ; and it also prints
PTELOP:       LD    A,(DE)                          ; character from the buffer
              CALL  FPCHAR                          ; and LPT
              LD    A,(DE)                          ; again this character
              INC   DE                              ; point to the next
              CP    CR                            ; CR was sent
              JR    NZ,PTELOP                       ; No, let's go
              POP   AF                              ; CR sent, end of
              POP   BC                                                 
              POP   DE                                                 
              RET                                                      
              ;                                                                
FPTEST:                                             ; printer readiness test
              IN    A,(PLPTS)                                          
              AND   00001101B                                          
              CP    C                                                  
              RET   Z                               ; hura, READY printer
              CALL  @BRKEY                                             
              JR    NZ,FPTEST                       ; when the printer is silent
              LD    SP,NEWSP                        ; and BREAK is pressed
              JP    FPRMPT                          ; jump to the monitor
              ;
              ; Plays music stored on DE, terminated by CR,
              ; it is there ASCII in the MZ-700 Basic conventions
              ;
              ; input: DE - string address
              ; output: AF
              ;
MELDY:                                                                 
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                 
              LD    A,2                             ; standard octave number
              LD    (OKTNUM),A                                         
              LD    B,1                                                
MELOOP:                                                                
              LD    A,(DE)                                             
              CP    CR                            ; the end?
              JR    Z,J0211                         ; Yes
              CP    0C8H                            ; or, such an end?
              JR    Z,J0211                         ; Yes
              CP    0CFH                                               
              JR    Z,J0205                         ; o oktavu niz
              CP    '-'                                                
              JR    Z,J0205                         ; o oktavu niz
              CP    '+'                                                
              JR    Z,J020D                         ; o oktavu vys
              CP    0D7H                                               
              JR    Z,J020D                         ; o oktavu vys
              CP    '#'                                                
              LD    HL,MTBL                                            
              JR    NZ,J01F5                        ; normal tons
              LD    HL,MTBLS                                           
              INC   DE                              ; pultony
J01F5:        CALL  @MELTB                          ; look for the note
              JR    C,MELOOP                        ; not found
              CALL  @MELW                           ; wait for the end last time
              JR    C,J0214                         ; BREAK
              CALL  MSTA                            ; turn on food
              LD    B,C                                                
              JR    MELOOP                                             
J0205:        LD    A,3                             ; o oktavu vys
J0207:        LD    (OKTNUM),A                                         
              INC   DE                                                 
              JR    MELOOP                                             
J020D:        LD    A,1                             ; o oktavu niz
              JR    J0207                                              
J0211:        CALL  @MELW                           ; we play
J0214:        PUSH  AF                                                 
              CALL  MSTP                            ; and it will no longer be played
              POP   AF                                                 
              JP    POPX2                           ; POP and RET
              ;
              ; Finds the actual frequency and length in the melody table
              ; according to the ASCII chain
              ;
              ; input: HL - table address
              ;        DE - address to the music buffer
              ;        (DE) - ASCII note sought
              ;
              ; exit:
              ;
              ; note found: DE = address of next item
              ;       (FREQ) = frequency 2 bytes
              ;       C = length of the note
              ;       A = 0
              ;       HL = undefined
              ;
              ; If the 1st character is not a note number, it returns CY = 1 and adjusts only DE
              ; If the 2nd character is not a length, the drive binds the specified length
              ;
@MELTB:                                                                
              PUSH  BC                                                 
              LD    B,8                                                
              LD    A,(DE)                                             
J0220:        CP    (HL)                            ; look in the sheet music
              JR    Z,J022C                                             
              INC   HL                                                 
              INC   HL                                                 
              INC   HL                                                 
              DJNZ  J0220                                              
              SCF                                   ; bad note
              INC   DE                                                 
              POP   BC                                                 
              RET                                                      
J022C:                                              ; we found a note
              INC   HL                                                 
              PUSH  DE                                                 
              LD    E,(HL)                          ; frequency to DE
              INC   HL                                                 
              LD    D,(HL)                                             
              EX    DE,HL                                              
              LD    A,H                                                
              OR    A                               ; is small ?
              JR    Z,J023F                         ; yes, ignore octaves
              LD    A,(OKTNUM)                      ; octave number
J0239:        DEC   A                                                  
              JR    Z,J023F                         ; finally donated
              ADD   HL,HL                           ; multiple of frequency
              JR    J0239                                              
J023F:        LD    (FREQ),HL                                          
              LD    HL,OKTNUM                                          
              LD    (HL),2                          ; middle octave
              DEC   HL                              ; points to the length of the note
              POP   DE                                                  
              INC   DE                                                 
              LD    A,(DE)                          ; length of the buffer
              LD    B,A                                                
              AND   NOKEY                                               
              CP    '0'                                                
              JR    Z,J0255                         ; it can be a number
              LD    A,(HL)                          ; it's nonsense
              JR    J025A                           ; so we go from the last length
J0255:        INC   DE                                                 
              LD    A,B                                                
              AND   0FH                                                
              LD    (HL),A                          ; save note length (0-9)
J025A:        LD    HL,QMELEN                       ; indexing of the TEMPO table
              ADD   A,L                                                
              LD    L,A                                                
              LD    C,(HL)                          ; actual length
              LD    A,(TEMPO)                                          
              LD    B,A                                                
              XOR   A                                                  
J0265:        ADD   A,C                             ; multiply with pace
              DJNZ  J0265                                              
              POP   BC                                                 
              LD    C,A                                                
              XOR   A                                                  
              RET                                                      
              ;
              ; melody table for normal notes
              ;
MTBL:         DB    'C'                                                
              DW    2118                                               
              DB    'D'                                                
              DW    1887                                               
              DB    'E'                                                
              DW    1681                                               
              DB    'F'                                                
              DW    1587                                               
              DB    'G'                                                
              DW    1414                                               
              DB    'A'                                                
              DW    1260                                               
              DB    'B'                                                
              DW    1124                                               
              DB    'R'                                                
              DW    0                                                  
              ;
              ; Frequency table for # notes
              ;
MTBLS:        DB    'C'                                                
              DW    1999                                               
              DB    'D'                                                
              DW    1781                                               
              DB    'E'                                                 
              DW    1587                                               
              DB    'F'                                                
              DW    1498                                               
              DB    'G'                                                
              DW    1335                                               
              DB    'A'                                                
              DW    1189                                               
              DB    'B'                                                
              DW    1059                                               
              DB    'R'                                                
              DW    0                                                  
              ;
              ; Table of length notes
              ;
QMELEN:       DB    1,2,3,4,6,8,12,16,24,32                            
              ;
              ; DE = DE + 4 (if it were a macro assembler)
              ;
@IC4DE:       INC   DE                                                 
              INC   DE                                                 
              INC   DE                                                 
              INC   DE                                                 
              RET                                                      
              ;
              ; Turns on music at (FREQ),
              ; writes it to 8253 and executes LD (M GATE0), 1
              ; this will start it
              ;
MSTA:                                                                  
              LD    HL,(FREQ)                       ; frequency here
              LD    A,H                                                
              OR    A                                                  
              JR    Z,MSTP                          ; if it is 0 then stop
              PUSH  DE                                                 
              EX    DE,HL                                              
              LD    HL,MCTC0                                           
              LD    (HL),E                          ; set frequency
              LD    (HL),D                                             
              LD    A,1                             ; turn on the music
              POP   DE                                                 
              JR    J02C4                                              
              ;
              ; Stop the music
              ;
MSTP:                                                                  
              LD    A,36H                           ; will not be quoted anymore
              LD    (MCTCC),A                                          
              XOR   A                               ; ban music
J02C4:        LD    (MGATE0),A                      ; and it goes to GATE 8253
              RET                                                      
              ;
              ; Wait for the melody to finish
              ;
              ; input: B = length of waiting
              ; output: HL = E000
              ; A = 0
              ; CY = 1 ... break
              ; 0 ... waited
              ;
@MELW:                                                                 
              LD    HL,MKBOUT                       ; key strobe
              LD    (HL),0F8H                                           
              INC   HL                                                 
              LD    A,(HL)                          ; key input
              AND   81H                                                
              JR    NZ,J02D5                        ; no one is squeezing anything
              SCF                                   ; it was a break
              RET                                                      
J02D5:        LD    A,(MGATE0)                                         
              RRCA                                                     
              JR    C,J02D5                         ; wait for one
J02DB:        LD    A,(MGATE0)                                         
              RRCA                                                     
              JR    NC,J02DB                        ; wait for zero
              DJNZ  J02D5                           ; and more expectations
              XOR   A                                                  
              RET                                                      
              ;
              ; Set melody tempo 0-7
              ; 8-A -M TIME
              ;
XTEMP:                                                                 
              PUSH  AF                                                 
              PUSH  BC                                                 
              AND   0FH                             ; only the lower 4 bits
              LD    B,A                             ; we read from eight
              LD    A,8                                                
              SUB   B                                                  
              LD    (TEMPO),A                       ; and store where it belongs
              POP   BC                                                 
              POP   AF                                                 
              RET                                                       
              ;
              ; Returns the display attributes
              ;
              ; output: HL = cursor position
              ; DE = address in the next row table
              ; A bit 0 = attribute of the current line
              ; A bit 7 = CY = next line attribute
              ;
@ATBLN:                                                                
              LD    HL,QATBLN                                          
              LD    A,(CURSOR+1)                    ; row number
              ADD   A,L                             ; index table
              LD    L,A                                                
              LD    A,(HL)                          ; attribute of our line
              INC   HL                                                 
              RL    (HL)                                               
              OR    (HL)                            ; and complete the attribute
              RR    (HL)                            ; dalsiho radku
              RRCA                                  ; to the tech bits where it belongs
              EX    DE,HL                                              
              LD    HL,(CURSOR)                     ; current position
              RET                                   ; cursor
              ;
              ; Time setting
              ;
              ; A = 0 ... in the morning
              ; 1 ... in the afternoon
              ;
              ; DE = number of seconds since the beginning of the field
              ;
              ; CT1 ... period 1 second (mod 2)
              ; CT2 ... period 43200 period CT1 = 12 hours (mod 0)
              ;
TIMST:                                                                 
              DI                                                       
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                  
              LD    (AMPM),A                                           
              LD    A,NOKEY                                             
              LD    (EIFLG),A                       ; enable disruption
              LD    HL,43200                                           
              XOR   A                                                  
              SBC   HL,DE                           ; how much is left until 12
              PUSH  HL                              ; so much to hide
              NOP                                                      
              EX    DE,HL                                              
              LD    HL,MCTCC                                           
              LD    (HL),01110100B                    ; CT1 mod 2
              LD    (HL),10110000B                    ; CT2 mod 0
              DEC   HL                                                 
              LD    (HL),E                          ; set CT2
              LD    (HL),D                                             
              DEC   HL                                                 
              LD    (HL),10                         ; then 10 to CT1
              LD    (HL),0                                             
              INC   HL                                                 
              INC   HL                                                 
              LD    (HL),10000000B                    ; CT2 mod 0 latch
              DEC   HL                                                 
J0331:        LD    C,(HL)                          ; wait for CT2
              LD    A,(HL)                          ; docita, so far
              CP    D                               ; goes fast
              JR    NZ,J0331                                           
              LD    A,C                                                
              CP    E                                                  
              JR    NZ,J0331                                            
              DEC   HL                                                 
              NOP                                                      
              NOP                                                      
              NOP                                                      
              LD    (HL),HBLNK % 256                ; to CT1 is saved
              LD    (HL),HBLNK/256                  ; what belongs there
              INC   HL                                                 
              POP   DE                                                 
J0344:        LD    C,(HL)                          ; and we'll wait for CT2
              LD    A,(HL)                          ; either not expected at all or
              CP    D                               ; 12 hours
              JR    NZ,J0344                                           
              LD    A,C                                                
              CP    E                                                  
              JR    NZ,J0344                                           
              POP   HL                                                 
              POP   DE                                                 
              POP   BC                                                 
              EI                                                       
              RET                                                      
              ;
              ; sheet music for BEEP
              ;
QBEEP:        DB    0D7H,'A','0',CR                                  
N01U02:       DB    0,0                                                
              ;
              ; read time in the same format as TIMST
              ;
TIMRD:                                                                 
              PUSH  HL                                                 
              LD    HL,MCTCC                                           
              LD    (HL),10000000B                    ; CT2 mod 0 latch
              DEC   HL                                                 
              DI                                                       
              LD    E,(HL)                                             
              LD    D,(HL)                                             
              EI                                                       
              LD    A,E                                                
              OR    D                                                  
              JR    Z,J0375                         ; 0 hours is 12 hours
              XOR   A                                                  
              LD    HL,43200                        ; we really have so much
              SBC   HL,DE                                              
              JR    C,J037F                         ; it can't even happen
              EX    DE,HL                           ; if only someone
              LD    A,(AMPM)                        ; played with a quote
              POP   HL                                                 
              RET                                                      
J0375:        LD    DE,43200                                           
J0378:        LD    A,(AMPM)                                           
              XOR   1                                                  
              POP   HL                                                 
              RET                                                      
J037F:        DI                                    ; someone played with him,
              LD    HL,MCTC2                        ; that must be explained
              LD    A,(HL)                          ; the time is complemented
              CPL                                                      
              LD    E,A                                                
              LD    A,(HL)                                             
              CPL                                                      
              LD    D,A                                                
              EI                                                       
              INC   DE                                                 
              JR    J0378                                              
              ;
              ; Standard interrupt handler routine
              ; activates once every 12 hours
              ; and switches the AMPM to the second state
              ;
              ; sets mod 0 to CT2
              ; CT2 = CT2 + 43200 - 2
              ;
@CLOCK:       PUSH  AF                                                 
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                 
              LD    HL,AMPM                                            
              LD    A,(HL)                                             
              XOR   1                               ; from morning to afternoon
              LD    (HL),A                          ; and from afternoon to morning
              LD    HL,MCTCC                                           
              LD    (HL),10000000B                    ; CT2 mod 0 latch
              DEC   HL                                                 
              PUSH  HL                                                 
              LD    E,(HL)                          ; pull time
              LD    D,(HL)                                             
              LD    HL,43200                                           
              ADD   HL,DE                           ; + 12 hours
              DEC   HL                              ; there is some correction
              DEC   HL                                                 
              EX    DE,HL                           ; to DE
              POP   HL                                                 
              LD    (HL),E                          ; and stuff back
              LD    (HL),D                                             
              POP   HL                                                 
              POP   DE                                                 
              POP   BC                                                 
              POP   AF                                                 
              EI                                                       
              RET                                                      
              ;
              ; List of contents (HL) in the nun system, before the byte
              ; there will be a gap
              ;
              ; input: HL = address to memory
              ; output: A = (HL)
              ;
@MHEX:                                                                 
              CALL  PRNTS                                              
              LD    A,(HL)                                             
              CALL  @BTHEX                                             
              LD    A,(HL)                                             
              RET                                                       
              ;
              ; Listing HL in the nun system
              ;
              ; input: HL = number we want to list
              ; output: AF
              ;
@HEXHL:                                                                
              LD    A,H                                                
              CALL  @BTHEX                                             
              LD    A,L                                                
              JR    @BTHEX                                             
              ;                                                                
              DB    0,0                                                
              ;
              ; Output of content A in the colon system
              ;
              ; input: A = number we want to list
              ; output: AF
              ;
@BTHEX:                                                                
              PUSH  AF                                                 
              RRCA                                                     
              RRCA                                                     
              RRCA                                                     
              RRCA                                                     
              CALL  @ASC                                               
              CALL  @PRNTC                                             
              POP   AF                                                 
              CALL  @ASC                                                
              JP    @PRNTC                                             
              ;
              ; Table setting of 60 characters per line
              ;
QPRN1:        DB    1,9,9,9,CR                                       
              ;
              ; Convert the lower four bits of the A register
              ; to the hexadecimal digit
              ;
              ; input: A = lower four bits
              ; output: A = corresponding hexadecimal digit
              ; (in ASCII)
              ;
@ASC:                                                                  
              AND   0FH                                                
              CP    10                                                 
              JR    C,J03E2                                            
              ADD   A,'A'-'0'-10                                       
J03E2:        ADD   A,'0'                                              
              RET                                                      
              ;
              ; Converts a hexadecimal digit to
              ; four-bit value
              ;
              ; input: A = digits in ASCII
              ; output: CY = 0 and A = corresponding value
              ; CY = 1 cannot convert
              ; (in A the value is undefined)
              ;
HEX:                                                                   
              SUB   '0'                                                
              RET   C                                                  
              CP    10                                                 
              CCF                                                       
              RET   NC                                                 
              SUB   'A'-'0'-10                                         
              CP    16                                                 
              CCF                                                      
              RET   C                                                  
              CP    10                                                 
              RET                                                      
              ;                                                                
N02U04:       DB    0,0,0,0                                            
              ;                                                                
@HEX:                                                                  
              JR    HEX                                                
              ;                                                                
SPLAY:        DB    7FH                                                
              DB    " PLAY"                                            
              DB    CR                                               
SREC:         DB    7FH                                                
              DB    " RECORD."                                        
              DB    CR                                               
              ;                                                                
N03U04:       DB    0,0,0,0                                            
              ;                                                                
              ;
              ; It stores the value written in the noun in HL
              ; system as ASCII characters
              ;
              ; input: DE = string address
              ; output: CY = 0 and HL = corresponding value
              ; CY = 1 conversion cannot be performed
              ; (HL contains undefined state)
              ;
@HLHEX:                                                                
              PUSH  DE                                                 
              CALL  @2HEX                                              
              JR    C,J041D                                            
              LD    H,A                                                
              CALL  @2HEX                                              
              JR    C,J041D                                            
              LD    L,A                                                
J041D:        POP   DE                                                 
              RET                                                      
              ;                                                                
              ;
              ; Converts 2 ASCII characters from a string
              ; to A as a number in the hexadecimal system
              ;
              ; input: DE = string address
              ; output: CY = 1 error, DE and A contains nedef. state
              ; CY = 0 and DE = DE + 1, A = number
              ;
@2HEX:                                                                 
              PUSH  BC                                                 
              LD    A,(DE)                                              
              INC   DE                                                 
              CALL  @HEX                                               
              JR    C,J0434                                            
              RRCA                                                     
              RRCA                                                     
              RRCA                                                     
              RRCA                                                     
              LD    C,A                                                
              LD    A,(DE)                                             
              INC   DE                                                 
              CALL  @HEX                                               
              JR    C,J0434                                            
              OR    C                                                  
J0434:        POP   BC                                                 
              RET                                                      
              ;                                                                
              ;  Oblast podprogramu pro praci s CMT                            
              ;                                                                
              ;
              ; Write the file header to CMT
              ;
              ; Output: CY = 1 an error has occurred
              ;
WHEAD:                                                                 
              DI                                                        
              PUSH  DE                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              LD    D,CWRITE                        ; sign of the record
              LD    E,CHEAD                         ; header flag
              LD    HL,HEAD                         ; header storage address
              LD    BC,128                          ; head length
J0444:        CALL  @CHECK                                             
              CALL  @MGON                                              
              JR    C,J0464                         ; BREAK while waiting for CMT
              LD    A,E                                                
              CP    CHEAD                           ; if a header is written
              JR    NZ,J045E                        ; listing WRITING filename
              CALL  @IFNL?                                             
              PUSH  DE                                                 
              LD    DE,SWRITE                                          
              RST   18H                                                
              LD    DE,FNAME                                           
              RST   18H                                                
              POP   DE                                                 
J045E:                                                                 
              CALL  @WTMRK                                             
              CALL  @WBLOK                                             
J0464:                                                                 
              JP    CMTEND                                             
              ;                                                                 
SWRITE:       DB    "WRITING ", CR                                         
QPRN2:        DB    1,9,9,11,CR                                      
              ;
              ; Write the program on CMT
              ;
              ; CY = 1 an error has occurred
              ;
WDATA:                                                                 
              DI                                                       
              PUSH  DE                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              LD    D,CWRITE                        ; sign of the record
              LD    E,CDATA                         ; program flag
              LD    BC,(FSIZE)                      ; program length
              LD    HL,(BEGIN)                      ; the beginning of the program
              LD    A,B                             ; this information is taken
              OR    C                               ; from the file header
              JR    Z,POPX1                         ; length = 0 =M POP and RET
              JR    J0444                            ;
              ;
              ; Write a block of data to the CMT
              ; It assumes the tape recorder is turned on and saved
              ; TAPE MARK and the existence of a checksum
              ; at the standard MGCRC address
              ;
              ; input: HL = data block storage address
              ; BC = its length
              ; output: CY = 1 an error has occurred
              ;
@WBLOK:                                                                
              PUSH  DE                                                 
              PUSH  BC                                                 
              PUSH  HL                              ; all data is saved
              LD    D,2                             ; on CMT twice
              LD    A,11111000B                     ; Key strobe for advice with BREAK
              LD    (MKBOUT),A                                         
WBLOOP:       LD    A,(HL)                                              
              CALL  @WBYTE                                             
              LD    A,(MKBDIN)                      ; octeni keyboard
              AND   10000001B                       ; test on BREAK
              JP    NZ,J04A5                                           
              LD    A,2                             ; if BREAK was detected
              SCF                                   ; set A = 2, CY = 1
              JR    POPX1                           ; and POP and RET are performed
J04A5:        INC   HL                                                 
              DEC   BC                                                 
              LD    A,B                             ; and is stored until
              OR    C                               ; neni BC = 0
              JP    NZ,WBLOOP                                          
              LD    HL,(MGCRC)                      ; read the control
              LD    A,H                             ; respect and its imposition
              CALL  @WBYTE                          ; and CMT
              LD    A,L                                                
              CALL  @WBYTE                                             
              CALL  @MG1                            ; write last bit = 1
              DEC   D                               ; should I save one more time?
              JP    NZ,J04C2                        ; Yes
              OR    A                               ; resets CY
              JP    POPX1                           ; POP and RET
              ;                                                                
J04C2:        LD    B,0                             ; will be saved again
J04C4:        CALL  @MG0                            ; will send to CMT
              DEC   B                               ; 256 times zero
              JP    NZ,J04C4                                           
              POP   HL                              ; the contents of the registry are restored
              POP   BC                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              JP    WBLOOP                          ; and we're going for it again
              ;                                                                
POPX1:        POP   HL                                                 
              POP   BC                                                 
              POP   DE                                                 
              RET                                                      
              ;                                                                
              DB    0EH,0                           ; someone forgot this here
              ;
              ; Read headers from CMT
              ;
              ; Output: CY = 1 an error has occurred
              ; A = 1 checksum error
              ; A = 2 detected BREAK
              ; CY = 0 OK
              ; (content A is undefined)
              ;
RHEAD:                                                                 
              DI                                                       
              PUSH  DE                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              LD    D,CREAD                         ; reading flag
              LD    E,CHEAD                         ; header flag
              LD    BC,128                          ; head length
              LD    HL,HEAD                         ; header storage address
J04E6:        CALL  @MGON                                              
              JP    C,CMTBRK                        ; error
              CALL  @RTMRK                                             
              JP    C,CMTBRK                        ; error
              CALL  @RBLOK                                             
              JP    CMTEND                                             
              ;
              ; Read the program from the CMT according to the information
              ; stored in the header
              ;
              ; output: CY with the meaning as for RHEAD
              ;
RDATA:                                                                 
              DI                                                       
              PUSH  DE                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              LD    D,CREAD                         ; reading flag
              LD    E,CDATA                         ; program flag
              LD    BC,(FSIZE)                      ; program length
              LD    HL,(BEGIN)                      ; boot address
              LD    A,B                             ; if it is a length
              OR    C                               ; zero, so be it
              JP    Z,CMTEND                        ; does not record anything
              JR    J04E6                                              
              ;
              ; Read a block of data from the CMT
              ;
              ; input: BC = data block length
              ; HL = storage address
              ; output: CY with the meaning as for RHEAD
              ;
@RBLOK:                                                                
              PUSH  DE                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              LD    H,2                             ; try to clean 2 blocks
J0513:        LD    BC,MKBDIN                                          
              LD    DE,MPORTC                                          
J0519:        CALL  W0TO1                           ; wait for the edge
              JR    C,CMTBRK                        ; did not reach
              CALL  @D331                           ; pocka and READ POINT
              LD    A,(DE)                          ; she made a sample
              AND   00100000B                       ; is it zero?
              JP    Z,J0519                         ; Yes
              LD    D,H                                                
              LD    HL,0                                                
              LD    (MGCRC),HL                      ; resets the CRC
              POP   HL                              ; restore registries
              POP   BC                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
J0532:        CALL  @RBYTE                                             
              JR    C,CMTBRK                        ; error
              LD    (HL),A                                             
              INC   HL                                                 
              DEC   BC                                                 
              LD    A,B                             ; until BC = 0
              OR    C                               ; so read
              JR    NZ,J0532                                           
              LD    HL,(MGCRC)                                         
              CALL  @RBYTE                          ; read the CRC
              JR    C,CMTBRK                        ; error
              LD    E,A                                                
              CALL  @RBYTE                                             
              JR    C,CMTBRK                        ; error
              CP    L                                                  
              JR    NZ,J0565                        ; if the CRC does not agree
              LD    A,E                             ; so he jumps off
              CP    H                                                  
              JR    NZ,J0565                                           
J0553:        XOR   A                               ; A = 0, CY = 0
              ;
              ; Here I jump all routines for CMT operation
              ; CMT is turned off here, enable interrupt if it is
              ; Enable interrupt enabled and perform nqvrat
              ;
CMTEND:       POP   HL                                                 
              POP   BC                                                 
              POP   DE                                                 
              CALL  @MGOFF                          ; turn off CMT
              PUSH  AF                                                 
              LD    A,(EIFLG)                                          
              CP    NOKEY                            ; when music is on
              JR    NZ,J0563                        ; so you are allowed to interrupt
              EI                                                       
J0563:        POP   AF                                                 
              RET                                                      
              ;                                                                
J0565:        DEC   D                               ; can i try to clean?
              JR    Z,J056E                         ; no -M
              LD    H,D                             ; Yes
              CALL  @RINTR                          ; skip the zero area
              JR    J0513                           ; and I'm going for it again
              ;                                                                
J056E:        LD    A,1                             ; checksum error
              JR    J0574                                              
              ;                                                                
CMTBRK:       LD    A,2                             ; detected BREAK
J0574:        SCF                                                      
              JR    CMTEND                                             
              ;
              ; Acoustic signal
              ;
              ; Nici: AF
              ;
BEEP:                                                                  
              PUSH  DE                                                 
              LD    DE,QBEEP                                           
              RST   30H                             ; P=M CALL MELDY
              POP   DE                                                 
              RET                                                      
              ;
              ; Click the cursor and test the KBD in the display code,
              ;
              ; output: A = read character
              ; Z = 1 ... key not pressed
              ;
@?KBDC:                                                                
              CALL  BLIKC                                              
              CALL  @GETKD                                             
              CP    NOKEY                                               
              RET                                                      
              DB    0                                                  
              ;
              ; Just a trap program with facts in mind
              ;
              ; output: CY = 1 an error has occurred
              ; A = 1 checksum error
              ; A = 2 detected BREAK
              ; CY = 0 OK
              ; (content A is undefined)
              ;
VERIF:                                                                 
              DI                                                       
              PUSH  DE                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              LD    BC,(FSIZE)                      ; program length
              LD    HL,(BEGIN)                      ; address of the beginning of the program
              LD    D,CREAD                         ; reading flag
              LD    E,CDATA                         ; program flag
              LD    A,B                                                
              OR    C                               ; when the length is zero
              JR    Z,CMTEND                        ; so nothing happens
              CALL  @CHECK                                             
              CALL  @MGON                                              
              JR    C,CMTBRK                        ; error
              CALL  @RTMRK                                             
              JR    C,CMTBRK                        ; error
              CALL  @VBLOK                                             
              JR    CMTEND                                             
              ;
              ; Verifies a block of data from the CMT
              ;
              ; Input: HL = data block address
              ; BC = length of the data
              ; Output: CY with the meaning of VERIF
              ;
@VBLOK:                                                                
              PUSH  DE                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              LD    H,2                                                
J05B2:        LD    BC,MKBDIN                                          
              LD    DE,MPORTC                                          
J05B8:        CALL  W0TO1                           ; wait for the edge
              JP    C,CMTBRK                        ; did not reach
              CALL  @D331                                              
              LD    A,(DE)                                             
              AND   00100000B                                          
              JP    Z,J05B8                         ; it is not a LONG bit
              LD    D,H                                                
              POP   HL                              ; restore the registry
              POP   BC                                                  
              PUSH  BC                                                 
              PUSH  HL                                                 
J05CC:        CALL  @RBYTE                          ; read until BC = 0
              JR    C,CMTBRK                        ; error
              CP    (HL)                                               
              JR    NZ,J056E                        ; error
              INC   HL                                                 
              DEC   BC                                                 
              LD    A,B                                                
              OR    C                                                  
              JR    NZ,J05CC                                           
              LD    HL,(MGCRCV)                                        
              CALL  @RBYTE                          ; read checksum
              CP    H                                                  
              JR    NZ,J056E                        ; error
              CALL  @RBYTE                                             
              CP    L                                                  
              JR    NZ,J056E                        ; error
              DEC   D                               ; I still have to check
              JP    Z,J0553                         ; one block?
              LD    H,D                             ; Yes
              JR    J05B2                           ; I'm on it
              ;
              ; Turns off the cursor
              ; character (AKCHAR) da at the cursor position, it was there
              ; hidden by the @CURON subroutine
              ;
              ; output: HL = cursor address
              ;
@CUROF:                                                                
              PUSH  AF                                                 
              LD    A,(AKCHAR)                                          
              CALL  @?POINT                                            
              LD    (HL),A                                             
              POP   AF                                                 
              RET                                                      
              ;
              ; Prints the HL address on a new CRT line
              ;
              ; input: HL = displayed word
              ; output: AF
              ;
@?NLHL:                                                                
              CALL  @IFNL?                                             
              CALL  @HEXHL                                             
              RET                                                      
              ;
              ; Waiting for the leading edge of the signal from the CMT
              ;
              ; input: BC =M KBDIN
              ; DE =M PORTC
              ; output: CY = 0 reached
              ; CY = 1 was BREAK
              ; output: AF
              ;
W0TO1:                                                                 
              LD    A,11111000B                     ; strobe keyboard
              LD    (MKBOUT),A                                         
              NOP                                   ; they forgot something here again
J0607:        LD    A,(BC)                                             
              AND   10000001B                       ; is a break?
              JR    NZ,J060E                        ; No
              SCF                                   ; Yes
              RET                                                      
              ;                                                                
J060E:        LD    A,(DE)                          ; we are waiting for zero from CMT
              AND   00100000B                                          
              JR    NZ,J0607                                           
J0613:        LD    A,(BC)                          ; when we got there
              AND   10000001B                       ; so we will test BREAK
              JR    NZ,J061A                        ; and let's go
              SCF                                   ; was BREAK
              RET                                                      
              ;                                                                
J061A:        LD    A,(DE)                          ; we are waiting for one
              AND   00100000B                                          
              JR    Z,J0613                         ; and we test it
              RET                                   ; BREAK
              ;                                                                
              DB    0,0,0,0                                            
              ;
              ; Read the apartment from CMT
              ;
              ; Output: CY = 0 and A contains the read byte
              ; CY = 1 was detected by BREAK
              ; (content A is not defined)
              ;
@RBYTE:                                                                
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                 
              LD    HL,8*256+0                      ; in H is the number of bits in the byte
              LD    BC,MKBDIN                       ; preparation of values
              LD    DE,MPORTC                       ; for W0TO1
J0630:        CALL  W0TO1                                              
              JP    C,J0654                         ; error, POP and RET
              CALL  @D331                           ; waiting for READ POINT
              LD    A,(DE)                                             
              AND   00100000B                       ; sampled
              JP    Z,J0649                         ; for zero it is skipped
              PUSH  HL                              ; checksum
              LD    HL,(MGCRC)                                         
              INC   HL                                                  
              LD    (MGCRC),HL                                         
              POP   HL                                                 
              SCF                                                      
J0649:        LD    A,L                             ; stores the value in L
              RLA                                   ; read bit
              LD    L,A                                                
              DEC   H                               ; has it been 8 bits?
              JP    NZ,J0630                        ; No
              CALL  W0TO1                           ; if so, wait
              LD    A,L                             ; to the leading edge of another
J0654:        POP   HL                              ; signal, save the read
              POP   DE                              ; value to the A register
              POP   BC                              ; and end up
              RET                                                      
              ;                                                                
              DB    0,0,0                                              
              ;
              ; Skip loading tons
              ; and pocka on TAPE MARK
              ;
              ; Input: E = 0CCH as header flag
              ; or E = anything other than
              ; program flag
              ;
              ; Output: CY = 1 detected BREAK
              ; CY = 0 OK
              ; Nici: AF
              ;
@RTMRK:                                                                
              CALL  @RINTR                          ; skip bootloader
              PUSH  BC                              ; tone
              PUSH  DE                                                 
              PUSH  HL                                                 
              LD    HL,40*256+40                                       
              LD    A,E                             ; produce to H and L
              CP    CHEAD                           ; lengths LONG and SHORT
              JR    Z,J066C                         ; areas in TAPE MARK
              LD    HL,20*256+20                    ; according to the symptom of E
J066C:        LD    (TMLONG),HL                     ; and hide them
              LD    BC,MKBDIN                       ; initializes values
              LD    DE,MPORTC                       ; for W0TO1
J0675:        LD    HL,(TMLONG)                     ; restores the length of TAPE MARK
J0678:        CALL  W0TO1                                              
              JR    C,POPX2                         ; error
              CALL  @D331                           ; pocka to READ POINT
              LD    A,(DE)                                             
              AND   00100000B                       ; is sampled
              JR    Z,J0675                         ; it's zero and now it's waiting
              DEC   H                               ; to ones =M again
              JR    NZ,J0678                        ; can continue
J0688:        CALL  W0TO1                           ; and now he will wait
              JR    C,POPX2                         ; to block zero
              CALL  @D331                                              
              LD    A,(DE)                                             
              AND   00100000B                                          
              JR    NZ,J0675                        ; the one read
              DEC   L                                                  
              JR    NZ,J0688                                           
              CALL  W0TO1                           ; wait for the leading edge
POPX2:        POP   HL                              ; the following signal
              POP   DE                                                 
              POP   BC                                                 
              RET                                                      
              ;
              ; Turn on the tape recorder
              ;
              ; input: D = D2 as read flag
              ; or anything else
              ; as a sign of writing
              ; output: CY = 1 BREAK detected
              ; CY = 0 OK
              ;
@MGON:                                                                 
              PUSH  BC                                                 
              PUSH  DE                                                  
              PUSH  HL                                                 
              LD    B,10                            ; number of power-up attempts
J06A4:        LD    A,(MPORTC)                                         
              AND   00010000B                       ; is it going
              JR    Z,J06B9                         ; No
J06AB:        LD    B,255                           ; if so then take a moment
J06AD:        CALL  @D7000                          ; pocka na motor
              JR    J06B4                           ; about 1.8 secondsQ
              ;                                                                
              JR    @MGON                           ; they forgot something here, IT'S NOWQ
              ;                                                                
J06B4:        DJNZ  J06AD                                              
              XOR   A                                                  
J06B7:        JR    POPX2                           ; and we're leaving
                                                                     ;                                                                
J06B9:        LD    A,00000110B                     ; this sequence instruction
              LD    HL,MCWR55                       ; after the signal
              LD    (HL),A                          ; ENGINE edge that would
              INC   A                               ; she should have run it if
              LD    (HL),A                          ; the drive is on
              DJNZ  J06A4                                              
              CALL  @IFNL?                          ; it failed at ten
              LD    A,D                             ; experiment and so it is written
              CP    CWRITE                          ; prompt 'RECORD.PLAY'
              JR    Z,J06D0                         ; respectively 'PLAY'
              LD    DE,SPLAY                                           
              JR    J06D7                                              
J06D0:        LD    DE,SREC                                            
              RST   18H                                                
              LD    DE,3FDH                                            
J06D7:        RST   18H                                                
J06D8:        LD    A,(MPORTC)                      ; and will wait for
              AND   10H                             ; until the CMT user turns on
              JR    NZ,J06AB                        ; he succeeded
              CALL  BRKEY                           ; BREAK?
              JR    NZ,J06D8                        ; no, wait
              SCF                                   ; Yes
              JR    J06B7                           ; balime to
              ;                                                                
SMON7:        DB    "**  MONITOR 1Z-013B  **"                          
              DB    CR                                               
              ;                                                                
              DB    0                                                  
              ;
              ; Turns off CMT
              ;
              ; Protects all registries
              ;
@MGOFF:                                                                
              PUSH  AF                                                 
              PUSH  BC                                                 
              PUSH  DE                                                 
              LD    B,10                            ; number of attempts
J0705:        LD    A,(MPORTC)                                         
              AND   00010000B                       ; has he stopped yet?
              JR    Z,J0717                         ; yes, we are
              LD    A,00000110B                     ; No, we're sending him
              LD    (MCWR55),A                      ; food
              INC   A                                                  
              LD    (MCWR55),A                      ; and when it doesn't work either
              DJNZ  J0705                           ; tenth attempt, so
J0717:        JP    J0EE6                           ; it will be left flat
              ;
              ; Counts the checksum of the data block
              ; and save it to the default addresses
              ; MGCRC and MGCRCV
              ;
              ; input: HL = data block address
              ; BC = its length
              ;
@CHECK:                                                                
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                 
              LD    DE,0                            ; at the beginning is a control
J0720:        LD    A,B                             ; the sum is equal to zero
              OR    C                               ; are we done yet?
              JR    NZ,J072F                        ; not yet, it's time to work
              EX    DE,HL                                              
              LD    (MGCRC),HL                      ; so let's save it
              LD    (MGCRCV),HL                     ; and we will return
              POP   HL                                                 
              POP   DE                                                 
              POP   BC                                                 
              RET                                                      
J072F:        LD    A,(HL)                          ; this is where the CRC of the apartment took place
              PUSH  BC                                                 
              LD    B,8                             ; number of bits in the apartment
J0733:        RLCA                                                     
              JR    NC,J0737                                           
              INC   DE                              ; added
J0737:        DJNZ  J0733                           ; I'll finish it for the apartment
              POP   BC                                                 
              INC   HL                              ; edit addresses
              DEC   BC                              ; and I'm going for it again
              JR    J0720                                              
              ;
              ; Initialization routine
              ;
              ; sets I8255 to mode 0
              ; And, Cl as an exit
              ; B, Ch as input
              ; sends an edge to the MOTOR signal
              ; so turn it on if
              ; was turned off and vice versa
              ; allows periodic interrupts
              ; from timer I8253
              ;
              ; output: HL
              ;
@INI55:                                                                
              LD    HL,MCWR55                                          
              LD    (HL),10001010B                    ; mode 8255
              LD    (HL),00000111B                    ; switch CMT
              LD    (HL),00000101B                    ; allow interupt
              RET                                                      
              ;                                                                
              DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0                  
              ;
              ; Delay approx. 111 microseconds
              ;
              ; output: AF
              ;
@D111:                                                                 
              LD    A,27                                               
J075B:        DEC   A                                                  
              JP    NZ,J075B                                           
              RET                                                      
              ;
              ; Delay about 103 microseconds
              ;
              ; output: AF
              ;
@D103:                                                                 
              LD    A,25                                               
J0762:        DEC   A                                                  
              JP    NZ,J0762                                           
              RET                                                      
              ;
              ; Writes a byte from the A register to the CMT
              ;
              ; output: AF
              ;
@WBYTE:                                                                
              PUSH  BC                                                 
              LD    B,8                             ; number of bits in the apartment
              CALL  @MG1                            ; start / stop bit
J076D:        RLCA                                                     
              CALL  C,@MG1                                             
              CALL  NC,@MG0                                            
              DEC   B                                                  
              JP    NZ,J076D                                           
              POP   BC                                                 
              RET                                                      
              ;
              ; Writes the boot signal and TAPE MARK
              ;
              ; input: E = 0CCH as header flag, or
              ; any value, as a program flag
              ; output: AF
              ;
@WTMRK:                                                                
              PUSH  BC                                                 
              PUSH  DE                                                 
              LD    A,E                                                
              LD    BC,22000                                           
              LD    DE,40*256+40                                       
              CP    CHEAD                           ; according to the symptom
              JP    Z,J078E                         ; you set up
              LD    BC,11000                        ; parameters
              LD    DE,20*256+20                                       
J078E:        CALL  @MG0                            ; writes BC times zero
              DEC   BC                                                  
              LD    A,B                                                
              OR    C                                                  
              JR    NZ,J078E                                           
J0796:        CALL  @MG1                            ; writes D times to one
              DEC   D                                                  
              JR    NZ,J0796                                           
J079C:        CALL  @MG0                            ; writes E times a unit
              DEC   E                                                  
              JR    NZ,J079C                                           
              CALL  @MG1                                               
              POP   DE                                                 
              POP   BC                                                 
              RET                                                      
              ;
              ; Execute part of the MODIFY display
              ;
FMODIF:                                                                
              CALL  FHLHEX                          ; entered address
FMOD1:                                                                 
              CALL  @?NLHL                          ; write it on a new line
              CALL  @MHEX                           ; and a flat on it with a space
              CALL  PRNTS                                              
              CALL  FGETL                           ; honor string character
              CALL  @HLHEX                          ; and immediately get a HEXA number from it
              JR    C,J07D7                         ; that should be our address
              CALL  @IC4DE                                             
              INC   DE                                                 
              CALL  @2HEX                           ; and this is old content
              JR    C,FMOD1                         ; it was not a hexadecimal number
              CP    (HL)                             ;
              JR    NZ,FMOD1                        ; the old contents do not fit
              INC   DE                                                 
              LD    A,(DE)                                             
              CP    CR                                               
              JR    Z,J07D4                         ; only CR pressed
              CALL  @2HEX                           ; new content
              JR    C,FMOD1                         ; incorrect entry
              LD    (HL),A                          ; modify in memory
J07D4:        INC   HL                              ; next byte
              JR    FMOD1                           ; and again
J07D7:        LD    H,B                                                
              LD    L,C                                                
              JR    FMOD1                                              
              ;                                                                
QT????:       DB    'N','K',CR,';',CR,';',CR,';',' ',' ',' '
              ;                                                                
              ;
              ; Reads the character string from the keyboard.
              ; When reading a character, it stores it in VRAM, it is possible
              ; use all allowable editing commands
              ; (arrows, tab, inst, del, clr, home, etc.)
              ; Enter the string at the end by pressing CR, then read, working
              ; 40 or 80 character line (depending on the line attribute)
              ; to the input buffer, the rest of the line to 40 or 80
              ; is filled with the constant CR.
              ;
              ; AttentionQ The subroutine saves the line from the beginning,
              ; namely the one on which CR was pressed, at the beginning
              ; the cursor position does not matter at allQ
              ;
              ; input: DE = I / O buffer address
              ;
GETL:         PUSH  AF                                                 
              PUSH  BC                                                 
              PUSH  HL                                                 
              PUSH  DE                                                 
GETLOP:       CALL  @??KEY                          ; flash the cursor and honor KBD
              PUSH  AF                                                 
              LD    B,A                                                
              LD    A,(BPFLG)                                          
              RRCA                                                     
              CALL  NC,BEEP                         ; pipni, when you have
              LD    A,B                                                
              LD    HL,CONMOD                       ; NO ONE SETTINGS
              AND   NOKEY                            ; DOES NOT NEED 
              CP    0C0H                            ; driving sign?
              POP   DE                                                 
              LD    A,B                                                
              JR    NZ,J0818                        ; no, send
              CP    0CDH                                               
              JR    Z,J085B                         ; CR came, finally the end
              CP    0CBH                                               
              JP    Z,J0822                         ; BREAK
              CP    0CFH                                               
              JR    Z,J0818                         ; CF is always written (PROC?)
              CP    0C7H                                               
              JR    NC,J081D                        ; larger than C6 is controlled
              RR    E                               ; A NENSI SNAD NE ?Q
              LD    A,B                                                
              JR    NC,J081D                                           
J0818:        CALL  @AVRAM                          ; character to VRAM
              JR    GETLOP                                             
J081D:        CALL  @?DPCT                          ; management
              JR    GETLOP                                             
J0822:        POP   HL                              ; BREAK at GETL
              PUSH  HL                                                  
              LD    (HL),ESC                                         
              INC   HL                                                 
              LD    (HL),CR                                          
              JR    J087E                           ; new line, POP and RET
J082B:        RRCA                                                     
              JR    NC,J0865                        ; the starting point of the line
              JR    J0863                           ; continued to reach the line
              ;
              ; Wait 7 milliseconds and honor the keyboard via KBDIN
              ;
@WGKEY:                                                                
              CALL  @D7000                                             
              CALL  @KBDIN                                             
              RET                                                      
              ;                                                                
              DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0                
              DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0                
              ;                                                                
J085B:                                                                 
              CALL  @ATBLN                                             
              LD    B,40                            ; 40 characters per line
              JR    NC,J082B                        ; the starting point is line
              DEC   H                               ; o line vys
J0863:        LD    B,80                            ; 80 characters per line
J0865:        LD    L,0                                                
              CALL  @?ACUR                          ; decode the address from the position
              POP   DE                              ; address I / O buf
              PUSH  DE                                                 
J086C:        LD    A,(HL)                          ; we transfer characters to the I / O buffer
              CALL  @?DACN                                             
              LD    (DE),A                                             
              INC   HL                                                 
              INC   DE                                                 
              DJNZ  J086C                                              
              EX    DE,HL                                              
J0876:        LD    (HL),CR                       ; the spaces at the end will replace CR
              DEC   HL                                                 
              LD    A,(HL)                                             
              CP    SPACE                                              
              JR    Z,J0876                                            
J087E:        CALL  LETNL                           ; new line and end of GETL
              POP   DE                                                 
              POP   HL                                                 
              POP   BC                                                 
              POP   AF                                                 
              RET                                                      
              ;                                                                
N07U14:       DB    0,0,0,0,0,0,0,0,0,0,0,0,0                          
              ;
              ; Send the character string to the CRT terminated CR
              ; control characters (C0-CF)
              ;
              ; input: DE = string address
              ;
MSG:                                                                   
              PUSH  AF                                                  
              PUSH  BC                                                 
              PUSH  DE                                                 
MSGLOP:                                                                
              LD    A,(DE)                          ; character from the buffer
              CP    CR                            ; is it CR?
              JR    Z,J08A7                         ; it's CR
              CALL  PRNTC                           ; it's not CR
              INC   DE                              ; to the next sign
              JR    MSGLOP                          ; and again
              ;
              ; Send the character string to the CRT, terminated CR
              ; control characters are converted to display code
              ; and save to VRAM
              ;
              ; input: DE = string address
              ;
RST18:                                                                 
              PUSH  AF                                                 
              PUSH  BC                                                 
              PUSH  DE                                                 
J08A4:        LD    A,(DE)                                             
              CP    CR                                               
J08A7:        JP    Z,J0EE6                         ; POP and RET
              CALL  @?ADCN                                             
              CALL  @PRNTA                                             
              INC   DE                                                 
              JR    J08A4                                              
              ;                                                                
J08B3:        LD    DE,QKBDS                        ; close to GETKD
              JR    J08FA                                              
              ;                                                                 
J08B8:        LD    A,0CBH                                             
              OR    A                                                  
              JR    J08D6                                              
              ;
              ; Returns the code of the just pressed key in ASCII code,
              ; if no was pressed, it returns 0
              ; (call GETKD and then? DACN)
              ;
              ; output: key in "ASCII" code
              ;
GETKY:                                                                 
              CALL  @GETKD                                             
              SUB   NOKEY                                               
              RET   Z                                                  
              ADD   A,NOKEY                                             
              JP    @?DACN                                             
              ;                                                                
              DB    0,0                                                
              ;
              ; Returns the currently pressed key in the display code to A reg.
              ; (this routine has a delay of 7 millisecondsQ)
              ;
              ; SHIFT + BREAK = CD
              ; rear key = F0
              ; common key = code from tablesQ KBD ..
              ;
              ; mod SHIFT CTRL table
              ;
              ; ALPHA no no KBD base table
              ; ALPHA yes - KBDS shifted charactersQ
              ; --- no yesQ KBDC control characters
              ; GRAPH no noQ KBDG graphics
              ; GRAPH yes -Q KBDGS shifted graphic characters
              ;
@GETKD:                                                                 
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                 
              CALL  @WGKEY                          ; key pressed
              LD    A,B                             ; "shift" keys
              RLCA                                  ; the key was pressed
              JR    C,J08DA                         ; Yes
              LD    A,NOKEY                          ; no, it returns code
J08D6:        POP   HL                              ; rear keys
              POP   DE                                                 
              POP   BC                                                 
              RET                                                      
                                                    ; something pressed
J08DA:        LD    DE,QKBD                                            
              LD    A,B                                                
              CP    88H                             ; was it a break?
              JR    Z,J08B8                         ; Yes
              LD    H,0                                                
              LD    L,C                                                
              BIT   5,A                                                
              JR    NZ,J08F7                        ; driving sign
              LD    A,(CONMOD)                                         
              RRCA                                                     
              JP    C,J08FE                         ; graphically mod + shift
              LD    A,B                                                
              RLA                                                      
              RLA                                                      
              JR    C,J08B3                         ; shift
              JR    J08FA                           ; ordinary character
J08F7:        LD    DE,QKBDC                                            
J08FA:        ADD   HL,DE                           ; index the table
J08FB:        LD    A,(HL)                          ; sign here
              JR    J08D6                           ; and the end
J08FE:        BIT   6,B                                                
              JR    Z,J0909                                            
              LD    DE,QKBDGS                                          
              ADD   HL,DE                                              
              SCF                                                      
              JR    J08FB                                              
J0909:        LD    DE,QKBDG                                           
              JR    J08FA                                              
              ;
              ; New line on CRT
              ; no AF
              ;
LETNL:                                                                 
              XOR   A                                                  
              LD    (CSRH),A                                           
              LD    A,CRD                                            
              JR    J0959                                              
              ;                                                                
              DB    0,0                                                
              ;
              ; New line on CRT, if CSRH PM 0,
              ; i.e. if the cursor is not on the edge of the line
              ;
IFNL?:                                                                 
              LD    A,(CSRH)                        ; logical cursor position
              OR    A                                                   
              RET   Z                               ; we are at the beginning of the line
              JR    LETNL                           ; business CR
              ;                                                                
              DB    0                                                  
              ;                                                                
              ;
              ; Mezara on display
              ; no AF
              ;
PRNTS:                                                                 
              LD    A,SPACE                                            
              JR    PRNTC                                              
              ;
              ; Tab on CRT, then NULL
              ; tabs by 10 characters
              ;
              ; no AF
              ;
TAB:                                                                   
              CALL  @PRNTS                                             
              LD    A,(CSRH)                                           
              OR    A                                                  
              RET   Z                               ; at the beginning of the line
J092C:        SUB   10                              ; module 10 = 0?
              JR    C,TAB                           ; Yes
              JR    NZ,J092C                        ; no, another space
              NOP                                                      
              NOP                                                      
              NOP                                                      
              ;
              ; Character output to CRT
              ; (via PRNTA or? DPCT)
              ;
              ; input: A = output character
              ; output: AF
              ;
PRNTC:                                                                  
              CP    CR                                               
              JR    Z,LETNL                         ; CR is done differently
              PUSH  BC                                                 
              LD    C,A                                                
              LD    B,A                                                
              CALL  FPRNTC                          ; own routine
              LD    A,B                                                
              POP   BC                                                 
              RET                                                      
              ;                                                                
MSGOK:         DB    "OK!"                                              
              DB    CR                                               
              ;
              ; PRNTC without registry hiding
              ;
FPRNTC:       LD    A,C                                                
              CALL  @?ADCN                          ; to display
              LD    C,A                                                
              CP    NOKEY                                               
              RET   Z                               ; it's nothing
              AND   NOKEY                                               
              CP    0C0H                            ; rizeni?
              LD    A,C                                                
              JR    NZ,@PRNTA                       ; No
              CP    0C7H                            ; really driving?
              JR    NC,@PRNTA                       ; No
J0959:        CALL  @?DPCT                          ; it's driving
              CP    0C3H                            ; C right?
              JR    Z,@ICSRH                                           
              CP    0C5H                            ; home?
              JR    Z,J0967                                             
              CP    0C6H                            ; clear?
              RET   NZ                                                 
J0967:        XOR   A                               ; at clear a home
J0968:        LD    (CSRH),A                                           
              RET                                                      
              ;
              ; Character from A in the display code directly to VRAM and
              ; move CSRH
              ;
              ; input: A = character in the display code
              ; output: AF
              ;
@PRNTA:                                                                
              CALL  @AVRAM                                             
@ICSRH:                                                                
              LD    A,(CSRH)                        ; CSRH increment
              INC   A                                                  
              CP    50H                                                
              JR    C,J0968                                            
              SUB   50H                                                
              JR    J0968                                              
              ;                                                                
J097B:        LD    A,(AKCHAR)                      ; piece from BLIKC
              JR    J09EF                                              
              ;                                                                
J0980:        BIT   5,A                             ; it's a piece of BRKEY
              JR    Z,J0986                                            
              OR    A                               ; common characters
              RET                                                      
J0986:        LD    A,20H                           ; CTRL
              OR    A                                                  
              SCF                                                      
              RET                                                      
              ;                                                                
SFNAME:       DB    "FILENAME? "                                       
              DB    CR                                               
              ;
              ; Delay approx. 7 milliseconds
              ;
              ; output: AF
              ;
@D7000:                                                                
              PUSH  BC                                                 
              LD    B,21                                               
J0999:        CALL  @D331                                              
              DJNZ  J0999                                              
              POP   BC                                                 
              RET                                                      
              ;                                                                
SLOAD:        DB    "LOADING "                                         
              DB    CR                                               
              ;
              ; Delay approx. 459 microseconds
              ;
              ; output: AF
              ;
@D459:                                                                 
              LD    A,73H                                              
J09AB:        DEC   A                                                   
              JP    NZ,J09AB                                           
              RET                                                      
              ;                                                                
              DB    0,0,0                                              
              ;                                                                
              ;
              ; Flash with the cursor and wait for the keyboard
              ;
@??KEY:                                                                
              PUSH  HL                                                 
              CALL  @CURON                          ; deploy cursor
J09B7:        CALL  @?KBDC                          ; wait for the keyboard to release
              JR    NZ,J09B7                                           
J09BC:        CALL  @?KBDC                          ; wait for the key to be pressed
              JR    Z,J09BC                                            
              LD    H,A                             ; keys in the display
              CALL  @D7000                                             
              CALL  @GETKD                          ; after 7 ms again
              PUSH  AF                                                 
              CP    H                                                  
              POP   HL                                                 
              JR    NZ,J09BC                        ; it's not the same, the key oscillates
              PUSH  HL                                                 
              POP   AF                                                 
              CALL  @CUROF                          ; remove cursor
              POP   HL                                                 
              RET                                                      
              ;
              ; Fill 2 kB of memory with zero
              ;
@FILL0:                                                                
              XOR   A                                                  
              ;
              ; Fill 2 kB of memory with a constant from A
              ;
              ; input: HL = memory full address
              ; output: HL = HL + 800h
              ; BC = 0
              ; A = 0
              ;
@FILLA:                                                                
              LD    BC,800H                                            
              PUSH  DE                                                 
              LD    D,A                                                
J09DA:        LD    (HL),D                                             
              INC   HL                                                 
              DEC   BC                                                 
              LD    A,B                                                
              OR    C                                                  
              JR    NZ,J09DA                                           
              POP   DE                                                 
              RET                                                      
              ;
              ; Flashes with the cursor according to the 6th bit of C port 8255
              ; (there is a cursor flicker frequency)
              ;
              ; Save to VRAM at the cursor position
              ; (CURCH) if 6.bit C was equal to one
              ; (AKCHAR) ------ "----- zero
              ;
@BLIKC:                                                                 
              PUSH  AF                                                 
              PUSH  HL                                                 
              LD    A,(MPORTC)                      ; cursor bit
              RLCA                                                     
              RLCA                                                     
              JR    C,J097B                         ; save the normal character
              LD    A,(CURCH)                       ; save the cursor character
J09EF:        CALL  @?POINT                                            
              LD    (HL),A                                             
              POP   HL                                                 
              POP   AF                                                 
              RET                                                      
              ;                                                                
              DB    0,0,0,0,0,0,0,0,0                                  
              ;                                                                
BLIKC:                                                                 
              JR    @BLIKC                                             
              ;
              ; Enroll in CMT: record "SHORT",
              ; which represents the value 0
              ;
              ; HIGH ------- ---
              ; Q Q Q
              ; LOW --- --------
              ; ^ ^ ^ ^
              ; 0 240 ^ 278 + 240
              ; ^ (data is in microseconds)
              ; READ POINT: 379
              ;
@MG0:                                                                  
              PUSH  AF                                                  
              LD    A,00000011B                     ; high on CMT
              LD    (MCWR55),A                                         
              CALL  @D111                                              
              CALL  @D111                                              
              LD    A,00000010B                     ; low on CMT
              LD    (MCWR55),A                                         
              CALL  @D111                                              
              CALL  @D111                                              
              POP   AF                                                 
              RET                                                      
              ;
              ; Enroll in CMT: entry "LONG",
              ; which represents the value 1
              ;
              ;
              ; HIGH ------------- ---
              ; Q ^Q Q
              ; LOW --- ^ --------------
              ; ^ ^ ^ ^
              ; 0 ^ 470 494 + 470
              ; ^ (data is in microseconds)
              ; READ POINT: 379
              ;
@MG1:                                                                  
              PUSH  AF                                                 
              LD    A,00000011B                     ; high on CMT
              LD    (MCWR55),A                                         
              CALL  @D459                                              
              LD    A,00000010B                     ; low on CMT
              LD    (MCWR55),A                                         
              CALL  @D459                                              
              POP   AF                                                  
              RET                                                      
              ;                                                                
              DB    0,0,0,0,0                                          
              ;
              ; Tests the state of the SHIFT, CTRL, and BREAK keys
              ;
              ; output: A = see following table
              ; Z = 1 ... SHIFT + BREAK
              ; CY = 1 ... SHIFT or CTRL
              ;
              ;
              ; CTRL SHIFT BREAK CY ZA
              ; yes no - 1 0 20H control characters
              ; no no no 0 0 7FH common characters
              ; no no yes 0 0 3FH ESC
              ; - yes no 1 0 40H shift characters
              ; - yes yes 0 1 0 SHIFT + BREAK
              ;
BRKEY:                                                                 
              LD    A,11111000B                                        
              LD    (MKBOUT),A                      ; key strobe
              NOP                                                      
              LD    A,(MKBDIN)                      ; key input
              OR    A                                                  
              RRA                                   ; shift bit to CY
              JP    C,J0980                         ; there was no shift
              RLA                                                      
              RLA                                   ; break bit to CY
              JR    NC,J0A48                        ; it was a break
              LD    A,40H                           ; return code shift
              SCF                                                      
              RET                                                      
J0A48:        XOR   A                               ; SHIFT + BREAK
              RET                                                      
              ;
              ; Delay approx. 331 milliseconds
              ;
              ; output: AF
              ;
@D331:                                                                 
              LD    A,82                                               
              JP    J0762                                              
              ;                                                                
              DB   0                                                   
              ;
              ; Returns the hardware code of the currently pressed key
              ;
              ; output: B = code of the "shift" keys, see the following
              ; table.
              ; if the key is pressed, it is set
              ; 7 bit B register
              ;
              ; C = key code
              ; LINE * 8 + 7-COLUMN
              ; LINE and COLUMN are determined from the table
              ; physical connection of the keyboard.
              ; The subroutine does not test the last column (F1-F5),
              ; the penultimate column only affects the B register
              ; If the key has not been pressed, it is not
              ; C register changed.
              ;
              ; CTRL SHIFT BREAK BC
              ;
              ; - yes yes 88H unchanged
              ; yes no - 20H key code
              ; - yes no 40H "
              ; no no no 0H "
              ;
              ;
              ; 0 1 2 3 4 5 6 7 8 9
              ; + ------------------------------------------------- - +
              ; Q Q
              ; 7Q blank YQIA 1 \ inst break F1Q
              ; Q Q
              ; 6Q graph ZRJB 2 ^ del ctrl F2Q
              ; Q Q
              ; 5Q pound @ SKC 3 - right F3Q
              ; Q Q
              ; 4Q alpha FTLD 4 sp down F4Q
              ; Q Q
              ; 3Q tab] UME 5 O left F5Q
              ; Q Q
              ; 2Q ; VNF 6 9 upQ
              ; Q Q
              ; 1Q : WOG 7,? Q
              ; Q Q
              ; 0Q cr XPH 8. / shiftQ
              ; Q Q
              ; + ------------------------------------------------- - +
              ;
@KBDIN:                                                                
              PUSH  DE                                                 
              PUSH  HL                                                 
              XOR   A                                                  
              LD    B,11111000B                     ; this will start strobing
              LD    D,A                             ; 0 -M D
              CALL  BRKEY                                              
              JR    NZ,J0A5F                        ; there was no break
              LD    D,88H                           ; code break
              JR    J0A73                           ; POP and RET
J0A5F:        JR    NC,KBDTST                       ; unhifted
              LD    D,A                             ; shifted, hide
              JR    KBDTST                          ; and let's go
J0A64:        SET   7,D                             ; a sign that she was a keyboard
KBDTST:       DEC   B                               ; next column tested
              LD    A,B                                                
              LD    (MKBOUT),A                                         
              CP    0EFH                            ; koncime?
              JR    NZ,J0A77                        ; No
              CP    0F8H                            ; NONSENSE Q THIS CONDITION
              JR    Z,KBDTST                        ; IT WILL NEVER BE FULFILLED 
J0A73:        LD    B,D                                                
              POP   HL                                                 
              POP   DE                                                 
              RET                                                       
J0A77:        LD    A,(MKBDIN)                                         
              CPL                                                      
              OR    A                               ; is there something in that column?
              JR    Z,KBDTST                        ; it does not look like that,
              LD    E,A                             ; we will still need it
              LD    H,8                                                
              LD    A,B                                                
              AND   00001111B                                          
              RLCA                                  ; multiply 8
              RLCA                                                     
              RLCA                                                     
              LD    C,A                                                
              LD    A,E                                                
J0A89:        DEC   H                               ; we are looking for the right bit
              RRCA                                                     
              JR    NC,J0A89                                           
              LD    A,H                                                
              ADD   A,C                                                
              LD    C,A                                                
              JR    J0A64                           ; POP and RET
              ;
              ; "ASCII to display" conversion table
              ;
QADCN:                                                                 
              DB    NOKEY,NOKEY,NOKEY,0F3H,NOKEY,0F5H,NOKEY,NOKEY            
              DB    NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY            
              DB    NOKEY,0C1H,0C2H,0C3H,0C4H,0C5H,0C6H,NOKEY             
              DB    NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY            
              DB    000H,061H,062H,063H,064H,065H,066H,067H            
              DB    068H,069H,06BH,06AH,02FH,02AH,02EH,02DH            
              DB    020H,021H,022H,023H,024H,025H,026H,027H            
              DB    028H,029H,04FH,02CH,051H,02BH,057H,049H            
              DB    055H,001H,002H,003H,004H,005H,006H,007H            
              DB    008H,009H,00AH,00BH,00CH,00DH,00EH,00FH            
              DB    010H,011H,012H,013H,014H,015H,016H,017H            
              DB    018H,019H,01AH,052H,059H,054H,050H,045H            
              DB    0C7H,0C8H,0C9H,0CAH,0CBH,0CCH,0CDH,0CEH            
              DB    0CFH,0DFH,0E7H,0E8H,0E5H,0E9H,0ECH,0EDH            
              DB    0D0H,0D1H,0D2H,0D3H,0D4H,0D5H,0D6H,0D7H            
              DB    0D8H,0D9H,0DAH,0DBH,0DCH,0DDH,0DEH,0C0H            
              DB    080H,0BDH,09DH,0B1H,0B5H,0B9H,0B4H,09EH            
              DB    0B2H,0B6H,0BAH,0BEH,09FH,0B3H,0B7H,0BBH            
              DB    0BFH,0A3H,085H,0A4H,0A5H,0A6H,094H,087H            
              DB    088H,09CH,082H,098H,084H,092H,090H,083H            
              DB    091H,081H,09AH,097H,093H,095H,089H,0A1H            
              DB    0AFH,08BH,086H,096H,0A2H,0ABH,0AAH,08AH            
              DB    08EH,0B0H,0ADH,08DH,0A7H,0A8H,0A9H,08FH            
              DB    08CH,0AEH,0ACH,09BH,0A0H,099H,0BCH,0B8H             
              DB    040H,03BH,03AH,070H,03CH,071H,05AH,03DH            
              DB    043H,056H,03FH,01EH,04AH,01CH,05DH,03EH            
              DB    05CH,01FH,05FH,05EH,037H,07BH,07FH,036H            
              DB    07AH,07EH,033H,04BH,04CH,01DH,06CH,05BH            
              DB    078H,041H,035H,034H,074H,030H,038H,075H            
              DB    039H,04DH,06FH,06EH,032H,077H,076H,072H            
              DB    073H,047H,07CH,053H,031H,04EH,06DH,048H            
              DB    046H,07DH,044H,01BH,058H,079H,042H,060H            
                                                                       
              ;
              ; Physically place the cursor on the screen. Save the code to
              ; variable CURCH = FE ... graphically cursor
              ; FF ... alphanumeric cursor
              ; The sign that he covered is put to AKCHAR, there you have it
              ; they pick up the BLIKC and CUROF routines
              ;
              ; output: HL = E000H
              ; A = FFH
              ;
@CURON:                                                                
              LD    HL,CURCH                                           
              LD    (HL),0EFH                       ; alphanumeric cursor
              LD    A,(CONMOD)                                         
              RRCA                                                     
              JR    C,J0BA0                         ; graphically mod
              RRCA                                  ; do I display the cursor?
              JR    NC,J0BA2                        ; No
J0BA0:        LD    (HL),0FFH                       ; graphically cursor
J0BA2:        LD    A,(HL)                          ; cursor character here
              PUSH  AF                                                 
              CALL  @?POINT                         ; cursor address
              LD    A,(HL)                          ; what was there
              LD    (AKCHAR),A                      ; is hiding for CUROF
              POP   AF                              ; a nas cursor
              LD    (HL),A                          ; will be stored there
              XOR   A                                                  
              LD    HL,MKBOUT                                          
              LD    (HL),A                                             
              CPL                                                      
              LD    (HL),A                                             
              RET                                                      
              ;                                                                
              DB   36H,43H,18H,0E9H                                    
              ;
              ; Character conversion from "ASCII" code to display code
              ;
              ; input: A - character in "ASCII" code
              ; output: A - character in the display code
              ;
@?ADCN:                                                                
              PUSH  BC                                                 
              PUSH  HL                                                 
              LD    HL,QADCN                        ; asci table -M display
              LD    C,A                                                
              LD    B,0                                                
              ADD   HL,BC                           ; index it
              LD    A,(HL)                          ; pull out the display code
              JR    J0BE0                           ; POP and RET
              ;                                                                
SV10A:        DB    "V1.0A"                                            
              DB    CR                                               
              ;                                                                
              DB    0,0,0                                              
              ;
              ; Convert a character from DISPLAY to an "ASCII" code
              ;
              ; input: A - character in the display code
              ; output: A - character in ASCII code
              ;
@?DACN:                                                                
              PUSH  BC                                                 
              PUSH  HL                                                 
              PUSH  DE                                                 
              LD    HL,QADCN                        ; ASCII table -M display
              LD    D,H                                                
              LD    E,L                             ; and to DE
              LD    BC,256                          ; the length of this table
              CPIR                                  ; looking for the sign outside
              JR    Z,J0BE3                         ; found
              LD    A,NOKEY                          ; not found, returns NOKEY
J0BDF:        POP   DE                                                 
J0BE0:        POP   HL                                                 
              POP   BC                                                 
              RET                                                      
J0BE3:        OR    A                               ; found, reset CY
              DEC   HL                              ; address back
              SBC   HL,DE                            ;
              LD    A,L                             ; calculate the index from the address
              JR    J0BDF                           ; POP and RET
              ;
              ; Keyboard tables
              ;
              ; 5 conversion tables from keyboard hardware code to
              ; display code, all tables are 64 characters long,
              ; only CTRL has only 63 characters for unknown reasons.
              ;
              ;
              ; Normal keys (without SHIFT, CTRL in alphanumeric mode)
              ;
QKBD:         DB    0BFH,0CAH,058H,0C9H,NOKEY,02CH,04FH,0CDH            
              DB    019H,01AH,055H,052H,054H,NOKEY,NOKEY,NOKEY             
              DB    011H,012H,013H,014H,015H,016H,017H,018H            
              DB    009H,00AH,00BH,00CH,00DH,00EH,00FH,010H            
              DB    001H,002H,003H,004H,005H,006H,007H,008H            
              DB    021H,022H,023H,024H,025H,026H,027H,028H            
              DB    059H,050H,02AH,000H,020H,029H,02FH,02EH            
              DB    0C8H,0C7H,0C2H,0C1H,0C3H,0C4H,049H,02DH            
              ;
              ; Shift keys
              ;
QKBDS:        DB    0BFH,0CAH,01BH,0C9H,NOKEY,06AH,06BH,0CDH            
              DB    099H,09AH,0A4H,0BCH,040H,NOKEY,NOKEY,NOKEY            
              DB    091H,092H,093H,094H,095H,096H,097H,098H            
              DB    089H,08AH,08BH,08CH,08DH,08EH,08FH,090H            
              DB    081H,082H,083H,084H,085H,086H,087H,088H            
              DB    061H,062H,063H,064H,065H,066H,067H,068H            
              DB    080H,0A5H,02BH,000H,060H,069H,051H,057H            
              DB    0C6H,0C5H,0C2H,0C1H,0C3H,0C4H,05AH,045H            
              ;
              ; Normal keys in graphics mode
              ;
QKBDG:        DB    0BFH,NOKEY,0E5H,0C9H,NOKEY,042H,0B6H,0CDH            
              DB    075H,076H,0B2H,0D8H,04EH,NOKEY,NOKEY,NOKEY            
              DB    03CH,030H,044H,071H,079H,0DAH,038H,06DH            
              DB    07DH,05CH,05BH,0B4H,01CH,032H,0B0H,0D6H            
              DB    053H,06FH,0DEH,047H,034H,04AH,04BH,072H            
              DB    037H,03EH,07FH,07BH,03AH,05EH,01FH,0BDH            
              DB    0D4H,09EH,0D2H,000H,09CH,0A1H,0CAH,0B8H            
              DB    0C8H,0C7H,0C2H,0C1H,0C3H,0C4H,0BAH,0DBH            
              ;
              ; CTRL characters
              ;
QKBDC:        DB    NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY            
              DB    NOKEY,05AH,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY            
              DB    0C1H,0C2H,0C3H,0C4H,0C5H,0C6H,NOKEY,NOKEY            
              DB    NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY            
              DB    NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY            
              DB    NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY            
              DB    NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY            
              DB    NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY,NOKEY                 
              ;
              ; Shift graphics
              ;
QKBDGS:       DB    0BFH,NOKEY,0CFH,0C9H,NOKEY,0B5H,04DH,0CDH            
              DB    035H,077H,0D7H,0B3H,0B7H,NOKEY,NOKEY,NOKEY            
              DB    07CH,070H,041H,031H,039H,0A6H,078H,0DDH            
              DB    03DH,05DH,06CH,056H,01DH,033H,0D5H,0B1H            
              DB    046H,06EH,0D9H,048H,074H,043H,04CH,073H            
              DB    03FH,036H,07EH,03BH,07AH,01EH,05FH,0A2H            
              DB    0D3H,09FH,0D1H,000H,09DH,0A3H,0D0H,0B9H            
              DB    0C6H,0C5H,0C2H,0C1H,0C3H,0C4H,0BBH,0BEH            
FDUMP:                                                                  
              CALL  FHLHEX                          ; address from
              CALL  @IC4DE                           ;
              PUSH  HL                              ; hide
              CALL  @HLHEX                          ; address kam
              POP   DE                              ; pull the address from where
              JR    C,J0D88                         ; incorrect entry
J0D36:        EX    DE,HL                           ; DE ... end, HL ... beginning
J0D37:        LD    B,8                             ; number of apartments per row
              LD    C,23                            ; shifted HEXA and ASCII text
              CALL  @?NLHL                          ; address from the beginning of the line to the CRT
J0D3E:        CALL  @MHEX                           ; byte below (HL)
              INC   HL                              ; next byte
              PUSH  AF                               ;
              LD    A,(CURSOR)                      ; column
              ADD   A,C                             ; the cursor at points to ASCII
              LD    (CURSOR),A                      ; column
              POP   AF                                                 
              CP    SPACE                           ; gap?
              JR    NC,J0D51                                           
              LD    A,'.'                           ; flats P32 replace with a dot
J0D51:        CALL  @?ADCN                          ; to the display code
              CALL  @PRNTA                          ; and send
              LD    A,(CURSOR)                                         
              INC   C                               ; the cursor returns
              SUB   C                                                  
              LD    (CURSOR),A                      ; and saves
              DEC   C                               ; edit cursor
              DEC   C                                                  
              DEC   C                                                  
              PUSH  HL                                                 
              SBC   HL,DE                           ; the end?
              POP   HL                                                 
              JR    Z,J0D85                         ; yes, jump to the monitor
              LD    A,11111000B                                        
              LD    (MKBOUT),A                                         
              NOP                                                      
              LD    A,(MKBDIN)                                         
              CP    11111110B                       ; suspension request?
              JR    NZ,J0D78                                           
              CALL  @?BLNK                          ; suspend listing
J0D78:        DJNZ  J0D3E                           ; another byte on the line
J0D7A:        CALL  @GETKD                          ; test suspended again
              OR    A                                                  
              JR    Z,J0D7A                                            
              CALL  BRKEY                                              
              JR    NZ,J0D37                        ; there was no break, another line
J0D85:        JP    FPRMPT                                             
J0D88:        LD    HL,160                                             
              ADD   HL,DE                           ; default end address
              JR    J0D36                           ; and I continue
              ;                                                                
              DB   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     
              ;
              ; Wait for the beginning of the frame dimming pulse
              ;
@?BLNK:                                                                
              PUSH  AF                                                 
J0DA7:        LD    A,(MPORTC)                                         
              RLCA                                                     
              JR    NC,J0DA7                        ; wait for high
J0DAD:        LD    A,(MPORTC)                                         
              RLCA                                                     
              JR    C,J0DAD                         ; wait for low
              POP   AF                                                 
              RET                                                      
              ;
              ; Saves the character at the cursor position in the VRAM, and executes
              ; cursor right. When saving a character to the last column,
              ; adjust line end attributes.
              ;
              ; input: A - character in the display code
              ;
@AVRAM:                                                                
              PUSH  AF                                                 
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                 
J0DB9:                                                                 
              CALL  @?POINT                         ; cursor address
              LD    (HL),A                          ; save character
              LD    HL,(CURSOR)                                        
              LD    A,L                                                
              CP    39                                                 
              JR    NZ,J0DD0                        ; we are not at the end of the line
              CALL  @ATBLN                          ; attributes
              JR    C,J0DD0                         ; the current line is already ongoing
              EX    DE,HL                                              
              LD    (HL),1                          ; the next will be continued
              INC   HL                                                 
              LD    (HL),0                          ; and no more
J0DD0:        LD    A,0C3H                          ; cursor right
              JR    J0DE0                           ; • DPCT without saving the registry
              ;
              ; Query the set input mode
              ;
              ; output: A - 0CAH ... graphic mode setting character
              ; Z = 1 ... graphically mod
              ; 0 ... alphanumeric mod
              ;
@?GMOD:                                                                
              LD    A,(CONMOD)                                         
              CP    1                                                  
              LD    A,0CAH                                             
              RET                                                      
              ;
              ; Execution of control characters C0 - CF on CRT
              ; All other codes are ignored
              ; The meaning of the individual codes is described in
              ; tableQ ADISP.
              ;
              ; input: A = control code C0-CF
              ;
@?DPCT:                                                                
              PUSH  AF                                                 
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                 
J0DE0:        LD    B,A                             ; control code i to B
              AND   11110000B                                          
              CP    0C0H                            ; is it really control code?
              JR    NZ,EXIT1                        ; no
              XOR   B                               ; character without upper four bits
              RLCA                                  ; * 2
              LD    C,A                             ; index into the table
              LD    B,0                                                
              LD    HL,QADISP                       ; service address table
              ADD   HL,BC                           ; index table
              LD    E,(HL)                          ; service address to HL
              INC   HL                                                 
              LD    D,(HL)                                             
              LD    HL,(CURSOR)                     ; cursor position to DE
              EX    DE,HL                                              
              JP    (HL)                            ; sell control services
              ;
              ; Cursor o line niz
              ; If it is already on the 24th line, it rolls
              ;
CDOWN:                                                                 
              EX    DE,HL                                              
              LD    A,H                                                
              CP    24                              ; the last line ?
              JR    Z,J0E23                         ; yes, scroll
              INC   H                               ; o line dolu
EXITC:                                                                 
              LD    (CURSOR),HL                                        
EXIT1:                                                                 
              JP    EXIT                                               
              ;
              ; Cursor one line up
              ; If it is already on the 0th line, nothing happens
              ;
CUP:                                                                   
              EX    DE,HL                                              
              LD    A,H                                                
              OR    A                                                  
              JR    Z,EXIT1                         ; 0.line
              DEC   H                               ; on the previous line
J0E0B:        JR    EXITC                                              
              ;
              ; Cursor one character to the right
              ;
CRIGHT:                                                                
              EX    DE,HL                                              
              LD    A,L                                                
              CP    39                              ; last column?
              JR    NC,J0E16                        ; Yes
              INC   L                               ; no, raise the column
              JR    EXITC                           ; return
J0E16:        LD    L,0                             ; the column was the last
              INC   H                               ; on another line
              LD    A,H                              ;
              CP    25                              ; on the last line?
              JR    C,EXITC                         ; no, everything is OK
              LD    H,24                            ; yes, he will stay there
              LD    (CURSOR),HL                                        
J0E23:        JR    SCROLL                          ; and rolls off
              ;
              ; Cursor one character to the left
              ;
CLEFT:                                                                 
              EX    DE,HL                                              
              LD    A,L                                                
              OR    A                                                  
              JR    Z,J0E2D                         ; I'm at the beginning of the line
              DEC   L                               ; shrink
              JR    EXITC                           ; return
J0E2D:        LD    L,39                            ; I'll be at the end of the line
              DEC   H                               ; and line vys
              JP    P,J0E0B                         ; return - nothing happened
              LD    H,0                             ; column zero
              LD    (CURSOR),HL                                        
              JR    EXIT1                                              
              ;
              ; Clear the screen
              ;
CLEAR:                                                                 
              LD    HL,QATBLN                                          
              LD    B,27                                               
              CALL  @F0B                            ; delete row attributes
              LD    HL,ADRCRT                       ; reset VRAM data
              CALL  @FILL0                                             
              LD    A,IMPATB                        ; delete VRAM attributes
              CALL  @FILLA                          ; and then a home was made
              ;
              ; Cursor left up
              ;
HOME:                                                                  
              LD    HL,0                                               
              JR    EXITC                                              
              ;                                                                 
              DB    0,0,0,0,0,0,0,0                                    
              ;
              ; New line on CRT
              ;
CRLF:                                                                  
              CALL  @ATBLN                                             
              RRCA                                  ; attribute of the next row?
              JR    NC,J0E16                        ; is a continuation, skip it
              LD    L,0                             ; Column 0
              INC   H                                                  
              CP    24                                                 
              JR    Z,J0E6A                         ; end of screen, scroll
              INC   H                                                  
              JR    EXITC                                              
              ;                                                                
J0E6A:                                                                 
              LD    (CURSOR),HL                                        
              ;
              ; Scrolls the CRT up one logical line
              ;
SCROLL:                                                                
              LD    BC,960                          ; length
              LD    DE,ADRCRT                                          
              LD    HL,ADRCRT+40                                       
              PUSH  BC                                                 
              LDIR                                  ; scrolled VRAM data
              POP   BC                                                 
              PUSH  DE                                                 
              LD    DE,ADRATB                                           
              LD    HL,ADRATB+40                                       
              LDIR                                  ; scrolling VRAM attributes
              LD    B,40                                               
              EX    DE,HL                                              
              LD    A,IMPATB                                           
              CALL  @FAB                            ; deleting the last row of VRAM
              POP   HL                                                 
              LD    B,40                                               
              CALL  @F0B                            ; deleting the last row of VRAM
              LD    BC,26                                              
              LD    DE,QATBLN                                          
              LD    HL,QATBLN+1                                        
              LDIR                                  ; line end attribute scrolling
              LD    (HL),0                                             
              LD    A,(QATBLN)                      ; attribute 0. radku
              OR    A                                                  
              JR    Z,EXIT                          ; not continued
              LD    HL,CURSOR+1                     ; is continued, scrolls again
              DEC   (HL)                            ; cursor one line up
              JR    SCROLL                          ; and again
              ;
              ; CRT Service Address Table (C0-CF)
              ;
QADISP:       DW    SCROLL                          ; C0 = Scroll
              DW    CDOWN                           ; C1 = Cursor down
              DW    CUP                             ; C2 = Cursor up
              DW    CRIGHT                          ; C3 = Cursor right
              DW    CLEFT                           ; C4 = Cursor left
              DW    HOME                            ; C5 = homeM
              DW    CLEAR                           ; C6 = clr
              DW    DELETE                          ; C7 = del
              DW    INSERT                          ; C8 = ins
              DW    ALPHA                           ; C9 = alph
              DW    GRAPH                           ; CA = graph
              DW    EXIT                            ; CB = not used
              DW    EXIT                            ; CC = not used
              DW    CRLF                            ; CD = cr
              DW    EXIT                            ; CE = not used
              DW    EXIT                            ; CF = not used
              ;                                                                
J0ECA:        SET   3,H                             ; it's a piece from INSERT
              LD    A,(HL)                          ; copies characters in VRAM-attributes
              INC   HL                                                 
              LD    (HL),A                                             
              DEC   HL                                                 
              RES   3,H                             ; and in VRAM data
              LDD                                                      
              LD    A,C                                                
              OR    B                                                  
              JR    NZ,J0ECA                        ; loop insert
              EX    DE,HL                                              
              LD    (HL),0                          ; under the cursor delete
              SET   3,H                                                
              LD    (HL),IMPATB                     ; and delete the attribute as well
              JR    EXIT                                               
              ;
              ; Set alphanumeric mod
              ;
ALPHA:                                                                 
              XOR   A                                                  
J0EE2:        LD    (CONMOD),A                                         
              ;                                                                
EXIT:         POP   HL                                                 
J0EE6:        POP   DE                                                 
              POP   BC                                                 
              POP   AF                                                 
              RET                                                      
              ;                                                                
              DB    0,0,0,0                                            
              ;
              ; Graphically sets the character, if it has already been set, the character
              ; save to CRT
              ;
GRAPH:                                                                 
              CALL  @?GMOD                          ; it is set ?
              JP    Z,J0DB9                         ; Yes
              LD    A,1                                                
              JR    J0EE2                           ; jump to AVRAM without storage
              ;
              ; Delete the character to the left of the cursor
              ;
DELETE:                                                                
              EX    DE,HL                                              
              LD    A,H                                                
              OR    L                                                  
              JR    Z,EXIT                          ; We're home
              LD    A,L                                                
              OR    A                                                  
              JR    NZ,J0F0E                        ; the cursor is not at the beginning of the line
              CALL  @ATBLN                          ; the cursor is at the beginning of the line
              JR    C,J0F0E                         ; line is a continuation, normally lubricated
              CALL  @?POINT                                            
              DEC   HL                                                 
              LD    (HL),0                          ; to the end of the previous one
              JR    J0F33                                              
              ;                                                                
J0F0E:        CALL  @ATBLN                                             
              RRCA                                  ; the row attribute to CY
              LD    A,40                            ; simple line
              JR    NC,J0F17                                           
              RLCA                                  ; continuation line
J0F17:        SUB   L                               ; the number of characters until the end of the line
              LD    B,A                             ; as a repeater
              CALL  @?POINT                                            
J0F1C:                                              ; shift B flat to the left
              LD    A,(HL)                          ; and VRAM data
              DEC   HL                                                 
              LD    (HL),A                                             
              INC   HL                                                 
              SET   3,H                             ; and in VRAM attributes
              LD    A,(HL)                                             
              DEC   HL                                                 
              LD    (HL),A                                             
              RES   3,H                                                
              INC   HL                                                 
              INC   HL                                                 
              DJNZ  J0F1C                           ; the last character has not been moved yet
              DEC   HL                                                 
              LD    (HL),0                          ; delete the last character in the VRAM
              SET   3,H                             ; also in VRAM attributes
              LD    HL,IMPATB                       ; HL MA APARTMENT IN BRACES 
J0F33:        LD    A,0C4H                          ; cursor left
              JP    J0DE0                           ; for hiding the registry? DPCT
              ;
              ; Insert a character in place of the cursor
              ;
INSERT:                                                                
              CALL  @ATBLN                                             
              RRCA                                  ; the row attribute to CY
              LD    L,39                            ; simple length
              LD    A,L                                                 
              JR    NC,J0F42                         ;
              INC   H                               ; line is double
J0F42:        CALL  @?ACUR                          ; line end address
              PUSH  HL                                                 
              LD    HL,(CURSOR)                     ; cursor position
              JR    NC,J0F4D                                           
              LD    A,79                            ; double line length
J0F4D:                                                                 
              SUB   L                               ; the character remains until the end of the line
              LD    B,0                                                
              LD    C,A                             ; BC is the number of characters to the end of the line
              POP   DE                              ; reset line end address
              JR    Z,EXIT                          ; we are on the last character
              LD    A,(DE)                          ; last character
              OR    A                                                  
              JR    NZ,EXIT                         ; it is not a space, INSERT cannot
              LD    H,D                                                
              LD    L,E                                                
              DEC   HL                              ; penultimate address to HL
              JP    J0ECA                                              
              ;
              ; SAVE monitor display
              ;
FSAVE:                                                                 
              CALL  FHLHEX                          ; enter the address in the HL
              LD    (BEGIN),HL                      ; this will be the boot address
              LD    B,H                             ; and will also be in BC
              LD    C,L                                                
              CALL  @IC4DE                          ; to another address
              CALL  FHLHEX                          ; I'm with her
              SBC   HL,BC                           ; it is the end address
              INC   HL                                                 
              LD    (FSIZE),HL                      ; to the header
              CALL  @IC4DE                          ; and one more address
              CALL  FHLHEX                                             
              LD    (ENTRY),HL                      ; start address
              CALL  @IFNL?                          ; novy line
              LD    DE,SFNAME                       ; query file name
              RST   18H                                                
              CALL  FGETL                           ; read the file name
              CALL  @IC4DE                          ; DE = DE + 8
              CALL  @IC4DE                                             
              LD    HL,FNAME                        ; address in the file name header
J0F8E:        INC   DE                              ; copy the name to the header
              LD    A,(DE)                                             
              LD    (HL),A                                             
              INC   HL                                                 
              CP    CR                            ; we end when there is CR
              JR    NZ,J0F8E                                           
              LD    A,1                             ; type is always 1 = ORDER NO
              LD    (HEAD),A                                           
              CALL  WHEAD                           ; write the header
              JP    C,FCMTER                        ; error
              CALL  WDATA                           ; record that
              JP    C,FCMTER                        ; error
              CALL  @IFNL?                                             
              LD    DE,MSGOK                         ; Write the message OKQ
              RST   18H                                                
              JP    FPRMPT                          ; to the monitor
              ;
              ; Return the cursor address to the VRAM
              ;
              ; output: HL = cursor address
              ;
@?POINT:                                                               
              LD    HL,(CURSOR)                                        
@?ACUR:                                             ; this input assumes a position in HL
              PUSH  AF                                                 
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                  
              POP   BC                              ; position is in BC
              LD    DE,40                           ; length of work
              LD    HL,ADRCRT-40                    ; before the CRT address
J0FBF:        ADD   HL,DE                           ; * 40
              DEC   B                                                  
              JP    P,J0FBF                                            
              LD    B,0                                                
              ADD   HL,BC                           ; add a column
              POP   DE                                                 
              POP   BC                                                 
              POP   AF                                                 
              RET                                                      
              ;                                                                
FVERIF:                                             ; File verification
              CALL  VERIF                           ; perform verification
              JP    C,FCMTER                        ; error or break
              LD    DE,MSGOK                        ; List OK!
              RST   18H                                                
              JP    FPRMPT                          ; to the monitor
              ;
              ; Zero memory full ( see @ FAB )
              ;
@F0B:         XOR   A                                                  
              JR    @FAB                                               
              ;
              ; Full FF memory ( see @ FAB )
              ;
@FFFB:        LD    A,0FFH                                             
              ;
              ; Full memory constant
              ;
              ; Input: HL - address
              ; A - the value by which it is fulfilled
              ; B - number of apartments
              ;
              ; Output: HL = HL + B
              ; A = constant by which it was filled
              ;
@FAB:         LD    (HL),A                                             
              INC   HL                                                 
              DJNZ  @FAB                                               
              RET                                                      
              ;
              ; Waiting for 100 zeros on CMT (think bit zeros)
              ;
              ; output: CY = 1 ... break
              ; CY = 0 ... zeros found
              ;
@RINTR:                                                                
              PUSH  BC                                                 
              PUSH  DE                                                 
              PUSH  HL                                                 
              LD    BC,MKBDIN                       ; registers for W0TO1
              LD    DE,MPORTC                                          
J0FEB:        LD    H,100                                              
J0FED:        CALL  W0TO1                           ; wait for the leading edge
              JR    C,J0FFD                         ; break
              CALL  @D331                           ; waiting for READ POINT
              LD    A,(DE)                          ; honor 8255 gate C
              AND   00100000B                       ; test read CMT bit
              JR    NZ,J0FEB                        ; the one does not have to be there
              DEC   H                               ; a mame dalsi zero
              JR    NZ,J0FED                        ; there are not 100 of them yet
J0FFD:        JP    POPX2                                              
                                                                     ;                                                                
