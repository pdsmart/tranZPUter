;*****************************************************************************
;*                     Sharp MZ-800 QD BASIC MZ-5Z009 v1.0B
;*
;* Listing edited by M. A. Hawes (for the Sharp Users Club)   30 January 2004
;*
;* This ASM LISTING originates from 26 TELESYSTEMS.MAC 10D source modules
;* written by T. Miho for Sharp Electronics in Japan.
;*
;* These modules contain alternative sections of code that may be included or
;* excluded at assembly time, by means of 'IF'...'ENDIF' directives, to suit
;* the MZ-700, MZ-800 or MZ-1500. The differences between the 700 and 800 are
;* well known, but the MZ-1500 is a mystery, as it never appeared in Europe.
;*
;* The IF   ENDIF sections of code suggest that MZ-1500 BASIC had 8 extra
;* keywords, 4 RS-232 channels, and a more sophisticated MUSIC system. These
;* sections of code, together with a few 'comments' in graphics characters,
;* have been left in this listing as an archive (the assumption being that,
;* on a Japanese machine, the graphics would appear Japanese characters).
;*
;* When the 26 modules were joined into one composite file and the IF  ENDIF
;* sections were sorted out, it became clear that the listing represented
;* MZ-800 QDBASIC MZ-5Z009 v1.0A. The listing was then edited, to allow it
;* to be re-assembled by Flight Electronics' XASM.EXE on a 486 PC.
;*
;* The syntax of XASM.EXE differs from that of the Televideo Macro-Assembler,
;* and some global changes were therefore required to allow the composite
;* file to be re-assembled under XASM. For example, the pseudo-operation
;* 'ENT' was deleted, 'RST 3' was altered to 'RST 18H', the pseudo-operand
;* 'M' was replaced by '(HL)', and all HEX numbers starting with a letter
;* were prefixed by '0'. In addition, '*' was used in place of ';' to mark
;* the starts of all lines that were not to be assembled, pseudo-instructions
;* such as LD BC,DE were replaced by LD B,E/LD C,E; and all memory-setting
;* instructions such as DEFS 5 were changed to DB   0,0,0,0,0.
;*
;* Also, wherever a 1-byte ASCII code was denoted by a character inside
;* double quotes, these were changed to single quotes  (e.g. LD A,':').
;*
;* Finally, all references to Macros and Links were deleted, comments were
;* added to align this listing with the published German listing of Sharp's
;* equivalent FD Basic MZ-2Z046, and patches were added to convert this file
;* from v1.0A to v1.0B (these patches were not included in the original 26
;* TELESYSTEMS.MAC modules, and they are labelled PATCH1 to PATCH8).
;*
;* The original combined file contained a few duplicate ROUTINES, several
;* JR's and DJNZ's to un-labelled destinations, and many duplicate EQUATES
;* and LABELS. To retain compatibility with versions of 5Z009 already in
;* circulation the duplicate routines were left in; but the offending JR's
;* and DJNZ's were labelled, duplicate EQUATES were commented out; and the
;* problems with duplicate LABELS were resolved by renaming one or both.
;*
;* In addition to these enforced changes, a few glaring spelling errors such
;* as 'scrool', 'tabel', and 'manegement' were corrected, and comments were
;* were added to mark the START and END of each original module. Otherwise,
;* the comments and labels of the original author have been left unchanged.
;*
;* This listing is particularly useful for its detailed comments on the tape-
;* handling routines in the 'CMT:' module, as these are typically 'Sharp' and
;* include precise timings, in both MZ-800 clock cycles and microseconds.
;*
;* The BINARY file produced by cross-assembling this listing under 'XASM'
;* on a 486 PC has been compared byte by byte with the code on an original
;* Sharp Master QD of MZ-5Z009 v1.0B, and it has been found that the two
;* sets of binary code are effectively identical (there are a few very minor
;* differences, but they all occur in transient storage areas).
;*****************************************************************************
;* Updates: TZFS, 2021->
;*
;* I stumbled across this BASIC assembly source after I had given up on the
;* idea of an updated BASIC, other than the NASCOM v4.7 BASIC, for the
;* tranZPUter cards on the Sharp machines. The ability to modify the original
;* source to use tranZPUter SD services instead of QD/FD allows reuse of
;* a large collection of Sharp BASIC programs.
;*
;* I have converted the original LST files to ASM files referred to in the
;* above description and stored them with this source file for reference.
;* In addition, as Im using the Java based GLASS Z80 Assembler, this source
;* needed to be adapted to enable it to assemble.
;*
;* A typical assembly line would be:
;* java -jar glass-0.5.jar 5Z009-1B.ASM 5Z009-1B.obj 5Z009-1B.sym -I include
;*
;* Changes:
;*   o Re-enabled the IF..ENDIF selective assembly statements as this code is
;*     intended to work on the MZ-700, 800 and 1500.
;*   o Comments start with semicolon in Glass.
;*   o EI/DI/END/SET/NEG/SUB etc name clash.
;*   o DEFB/DEFW/DEFM updated to DB,DW,DB
;*   o A lot of syntax errors, Im guessing XASM is more tolerant.
;*   o Had to revert to MONITN definition of -3 along with all the others as
;*     Glass expects an 8 bit signed number not 16bit.
;*****************************************************************************

; Build time variables, set one of these to 1, the others to 0, to build
; BASIC for the named machine.
;
B_MZ700   EQU     1
B_MZ800   EQU     0
B_MZ1500  EQU     0

;*-----------------------------------------
;* Variable RSYS to 1 for MZ-800, 0 for MZ-700, MZ-1500
;* Variable SYS set to 1 for MZ-800 Sound system
;*-----------------------------------------
          IF B_MZ700 = 1
RSYS:     EQU     0           ;0=700,1500, 1=800
SYS:      EQU     0           ;0 = MZ-1500; 1 = PLE
          ENDIF
          IF B_MZ800 = 1
RSYS:     EQU     1           ;0=700,1500, 1=800
SYS:      EQU     1           ;0 = MZ-1500; 1 = PLE
          ENDIF
          IF B_MZ1500 = 1
RSYS:     EQU     0           ;0=700,1500, 1=800
SYS:      EQU     1           ;0 = MZ-1500; 1 = PLE
          ENDIF

          ORG     10F0H
          IF B_MZ700 = 1
          DB      01h                                      ; Code Type, 01 = Machine Code.
          DB      "BASIC 5Z009-700", 0Dh, 00h              ; Title/Name (17 bytes).
          DW      BASICEND - BASICSTART                    ; Size of program.
          DW      BASICSTART                               ; Load address of program.
          DW      BASICSTART                               ; Exec address of program.
          DS      104                                      ; COMMENT          
          ENDIF
          IF B_MZ800 = 1
          DB      01h                                      ; Code Type, 01 = Machine Code.
          DB      "BASIC 5Z009-800", 0Dh, 00h              ; Title/Name (17 bytes).
          DW      BASICEND - BASICSTART                    ; Size of program.
          DW      BASICSTART                               ; Load address of program.
          DW      BASICSTART                               ; Exec address of program.
          DS      104                                      ; COMMENT          
          ENDIF
          IF B_MZ1500 = 1
          DB      01h                                      ; Code Type, 01 = Machine Code.
          DB      "BASIC 5Z009-1500", 00h                  ; Title/Name (17 bytes).
          DW      BASICEND - BASICSTART                    ; Size of program.
          DW      BASICSTART                               ; Load address of program.
          DW      BASICSTART                               ; Exec address of program.
          DS      104                                      ; COMMENT          
          ENDIF


;*===========================================================================
;*       START of original module MON1.ASM
;*----------------------------
;* MZ-800     crt port define
;* FI:CRTEQU  ver 1.0  7.26.84
;*----------------------------

;*------------------
;* custom  lsi ports
;*------------------

LSPAL:    EQU     0F0H        ;pallet
LSFC:     EQU     0FCH        
LSE0:     EQU     0E0H        
LSE1:     EQU     0E1H        
LSE2:     EQU     0E2H        
LSE3:     EQU     0E3H        
LSE4:     EQU     0E4H        
LSE5:     EQU     0E5H        
LSE6:     EQU     0E6H        
LSD0:     EQU     0D0H        
LSD1:     EQU     0D1H        
LSD2:     EQU     0D2H        
LSD3:     EQU     0D3H        
;*
LSWF:     EQU     0CCH        
LSRF:     EQU     0CDH        
LSDMD:    EQU     0CEH        
LSSCR:    EQU     0CFH        

;*-------------
;*  work areas
;*-------------

KEYBF:    EQU     11A4H       ;Keyboard Input Buffer
;*TEXTBF: EQU    2000H          ;defined later
BITBUF:   EQU     8000H       
FONTBF:   EQU     1000H       
ERRTXT:   EQU     0FDA0H      

;*-----------------------------
;* MZ-800      Monitor part 1
;* FI:PL1      ver 1.0  7.30.84
;*-----------------------------

          ORG     0           

BASICSTART:

          JP      STARTP      
          JP      GETL        
          JP      CR1         
          JP      CR2         
          JP      CRT1S       
          JP      PRNTT       
          JP      CRT1C       
          JP      CRTMSG      
.IOSVC:   JP      IOSVC       ;RST3 superviser call entry
          JP      INKEY0      
BRKCHK:   JP      BRKEY       
          JP      SVCMT1      
          JP      SVCMT2      
          JP      LDCMT1      
          JP      LDCMT2      
          JP      CHKTAP      
          JP      .RET        ;RST6
          JP      TIMST       

          DB      0,0         ;was DEFS 2

          JP      .RET        ;RST7 debugger reserve

          JP      TIMRD       
BEEPM:    JP      CTRLG       

ATEMPO:   JP      QTEMP       
          JP      MLDSP       
          JP      MLDSP       
          JP      GETL        

SYSSTA:   DW      BSTART      
ERRORP:   DB      0,0         ;was DEFS 2
          JP      CRTMSG      ;org 51H

          DB      0,0,0,0     ;was DEFS 4
          JP      INKEY$      ;org 58H

;*---------------------------------
;*   crt driver control code table
;*---------------------------------
CONTTB:   DW      .RET        ;@ 00
          DW      .RET        ;A 01
          DW      .RET        ;B 02
          DW      CTR.M       ;C 03
          DW      .RET        ;D 04
          DW      CTR.E       ;E 05 sft lock
          DW      CTR.F       ;F 06 sft normal
          DW      .RET        ;G 07 beep
          DW      .RET        ;H 08
          DW      CTAB        ;I 09
          DW      .RET        ;J 0A
          DW      .RET        ;K 0B
          DW      .RET        ;L 0C
          DW      CTR.M       ;M 0D cr
          DW      SPLSW       ;N 0E spool exec/stop
          DW      .RET        ;O 0F
          DW      DEL         ;P 10 del
          DW      CDOWN       ;Q 11 cursor down
          DW      CUP         ;R 12 cursor up
          DW      CRIGHT      ;S 13 cursor right
          DW      CLEFT       ;T 14 cursor left
          DW      HOME        ;U 15 home
          DW      HCLSW       ;V 16 clr
          DW      CTR.W       ;W 17 graph
          DW      INST        ;X 18 inst
          DW      CTR.Y       ;Y 19 alpha
          DW      .RET        ;Z 1A
          DW      CTR.M       ;[ 1B esc
          DW      .RET        ;\ 1C
          DW      .RET        ;] 1D
          DW      .RET        ;^ 1E
          DW      .RET        ;_ 1F

CTRLJB:   ADD     A,A         
          LD      HL,CONTTB   
          CALL    ADDHLA      
          CALL    INDRCT      
          JP      (HL)        

.NOP:     NOP     
.HL:      JP      (HL)        

DINT:     EI      
          PUSH    AF          
          CALL    MWAIT       
          CALL    SPLOFF      
          POP     AF          
          DI      
.RET:     RET     


EINT:     PUSH    AF          
          CALL    SPLON       
          POP     AF          
          EI      
          RET     

;*--------------------------------
;*   register all push programs
;*
;* PUSHRA : PUSH IX,HL,BC,DE,AF
;* PUSHR  : PUSH IX,HL,BC,DE
;*          Destroy IX
;*----------------------------------
PUSHRA:   EX      (SP),IX     
          PUSH    HL          
          PUSH    BC          
          PUSH    DE          
          PUSH    AF          
          PUSH    HL          
          LD      HL,POPRA    
          EX      (SP),HL     
          JP      (IX)        
PUSHR:    EX      (SP),IX     
          PUSH    HL          
          PUSH    BC          
          PUSH    DE          
          PUSH    HL          
          LD      HL,POPR     
          EX      (SP),HL     
          JP      (IX)        

POPRA:    POP     AF          
POPR:     POP     DE          
          POP     BC          
          POP     HL          
          POP     IX          
          RET     

;*---------------------------------
;*      cold startup routine
;*---------------------------------
          ORG     0DAH        ;ensure routine is where expected

COLDST:   DI      
          LD      SP,0000H    
          IM      2           
          OUT     (LSE1),A    
          LD      HL,(SYSSTA) 
          JP      (HL)        ;system entry jump

;*-------------------------
;*    BREAK, can't continue
;*-------------------------
BREAKX:   XOR     A           
          DB      21H         
;*-----------------------
;*    BREAK, can continue
;*-----------------------
BREAKZ:   LD      A,80H       
          DB      21H         
;*-------------
;*    I/O error
;*-------------
IOERR:    OR      80H         
;*---------------
;*    Error occur
;*---------------
ERRORJ:   PUSH    AF          
          CALL    MLDSP       
          POP     AF          
          LD      HL,(ERRORP) 
          JP      (HL)        ;error jump
;*
;*-----------------------------
;*  B = String bytes (till 00H)
;*-----------------------------
COUNT:    PUSH    DE          
          LD      B,0         
COUNT2:   LD      A,(DE)      
          OR      A           
          JR      Z,COUNT9    
          INC     DE          
          INC     B           
          JR      NZ,COUNT2   
          DEC     B           
COUNT9:   POP     DE          
          RET     

;*--------------------------
;*    IOOUT
;*
;*    Ent. HL=I/O data table
;*         B =counter
;*--------------------------
IOOUT:    LD      A,(HL)      
          INC     HL          
          LD      C,(HL)      
          INC     HL          
          OUT     (C),A       
          DJNZ    IOOUT       
          RET     
;*
DEVASC:   RST     18H         
          DB      .DEASC      
          LD      A,D         
          OR      A           
          JP      NZ,ER03M    
          LD      A,E         
          CP      B           
          RET     C           
          JP      ER03M       
          NOP                 ; make spare byte 00H

;*----------------------
          ORG     011BH       ; ensure start of CKCACC matches MZ-700 BASIC
;*  Syntax of CHECK ACC
;*     CALL CHKACC
;*     DB   N
;*     DB   X1
;*     DB   X2
;*      :   :
;*     DB   XN
;*----------------------
CHKACC:   EX      (SP),HL     
          PUSH    BC          
          LD      B,(HL)      
CHACC1:   INC     HL          
          CP      (HL)        
          JR      Z,CHACC2    
          DJNZ    CHACC1      
          INC     HL          
          JR      CHACC9      

CHACC2:   INC     HL          
          DJNZ    CHACC2      
CHACC9:   POP     BC          
          EX      (SP),HL     
          RET     

;*-------------
;*  LD DE,(HL+)
;*-------------
LDDEMI:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          INC     HL          
          RET     

;*-------------
;*  LD DE,(HL)
;*-------------
LDDEMD:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          DEC     HL          
          RET     

;*--------------------------
;* Clear B bytes, start (HL)
;*--------------------------
QCLRHL:   XOR     A           
;*------------------------
;* Set B bytes, start (HL)
;*------------------------
QSETHL:   LD      (HL),A      
          INC     HL          
          DJNZ    QSETHL      
          RET     

;*--------------------------
;* Clear B bytes, start (DE)
;*--------------------------
QCLRDE:   XOR     A           
;*------------------------
;* Set B bytes, start (DE)
;*------------------------
QSETDE:   LD      (DE),A      
          INC     DE          
          DJNZ    QSETDE      
          RET     

;*-----------------------
;*  LD (DE),(HL)  B bytes
;*-----------------------
LDDEHL:   LD      A,(HL)      
          LD      (DE),A      
          INC     HL          
          INC     DE          
          DJNZ    LDDEHL      
          RET     

;*-----------------------
;*  LD (HL),(DE)  B bytes
;*-----------------------
LDHLDE:   LD      A,(DE)      
          LD      (HL),A      
          INC     HL          
          INC     DE          
          DJNZ    LDHLDE      
          RET     

;*------------
;*  LD HL,(HL)
;*------------
INDRCT:   PUSH    AF          
          LD      A,(HL)      
          INC     HL          
          LD      H,(HL)      
          LD      L,A         
          POP     AF          
          RET     

;*----------
;*  ADD HL,A
;*----------
ADDHLA:   ADD     A,L         
          LD      L,A         
          RET     NC          
          INC     H           
          RET     

;*------------------
;* Fetch subroutines
;*------------------
INCHLF:   INC     HL          
HLFTCH:   LD      A,(HL)      
          CP      20H         
          JR      Z,INCHLF    
          RET     

;*-----------------------
;* TEST1 "x" ;test 1 char
;*-----------------------
TEST1:    CALL    HLFTCH      
          EX      (SP),HL     
          CP      (HL)        
          INC     HL          
          EX      (SP),HL     
          RET     NZ          
          INC     HL          
          RET     

;*--------------------------
;*  TESTX "x"  ;check 1 char
;*--------------------------
TESTX:    CALL    HLFTCH      
          EX      (SP),HL     
          CP      (HL)        
          INC     HL          
          EX      (SP),HL     
          INC     HL          
          RET     Z           ;OK
          LD      A,1         
          JP      ERRORJ      ;Syntax error
;*
;*--------------------
;* SVC (RST 18H) table
;*--------------------
IOSVCT:   
.MONOP:   EQU     00H         
          DW      MONOP       
.CR1:     EQU     01H         
          DW      CR1         
.CR2:     EQU     02H         
          DW      CR2         
.CRT1C:   EQU     03H         
          DW      CRT1C       
.CRT1X:   EQU     04H         
          DW      CRT1CX      
.CRTMS:   EQU     05H         
          DW      CRTSIMU     
.LPTOT:   EQU     06H         
          DW      LPTOUT      
.LPT1C:   EQU     07H         
          DW      LPT1C       
DHCR:     EQU     08H         
          DW      HCR         
DH1C:     EQU     09H         
          DW      H1C         
DH1CX:    EQU     0AH         
          DW      H1CX        
DHMSG:    EQU     0BH         
          DW      HMSG        
.GETL:    EQU     0CH         
          DW      GETL        
.INKEY:   EQU     0DH         
          DW      INKEY$      
.BREAK:   EQU     0EH         
          DW      BRKEY       
.HALT:    EQU     0FH         
          DW      HALTP       
.DI:      EQU     10H         
          DW      DINT          
.EI:      EQU     11H         
          DW      EINT          
.CURMV:   EQU     12H         
          DW      CURMOV      
.DEASC:   EQU     13H         
          DW      DEASC       
.DEHEX:   EQU     14H         
          DW      DEHEX       
.CKHEX:   EQU     15H         
          DW      CKHEX       
.ASCHL:   EQU     16H         
          DW      ASCHL       
.COUNT:   EQU     17H         
          DW      COUNT       
.ADDP0:   EQU     18H         
          DW      ADDP0       
.ADDP1:   EQU     19H         
          DW      ADDP1       
.ADDP2:   EQU     1AH         
          DW      ADDP2       
.ERRX:    EQU     1BH         
          DW      ERRX        
DQDACN:   EQU     1CH         
          DW      QDACN       
DQADCN:   EQU     1DH         
          DW      QADCN       
.STICK:   EQU     1EH         
          DW      STICK       
.STRIG:   EQU     1FH         
          DW      STRIG       
.BELL:    EQU     20H         
          DW      CTRLG       
.PLAY:    EQU     21H         
          DW      PLAY        
.SOUND:   EQU     22H         
          DW      MSOUND      
.MCTRL:   EQU     23H         
          DW      MCTRL       
.IOOUT:   EQU     24H         
          DW      IOOUT       
.TIMRD:   EQU     25H         
          DW      TIMRD       
.TIMST:   EQU     26H         
          DW      TIMST       
.INP1C:   EQU     27H         
          DW      INP1C0      
.CLRIO:   EQU     28H         
          DW      CLRIO       
.SEGAD:   EQU     29H         
          DW      SEGADR      
.OPSEG:   EQU     2AH         
          DW      OPSEG       
.DLSEG:   EQU     2BH         
          DW      DELSEG      
.DEVNM:   EQU     2CH         
          DW      DEV         
.DEVFN:   EQU     2DH         
          DW      DEV.FN      
.LUCHK:   EQU     2EH         
          DW      LUCHK       
.LOPEN:   EQU     2FH         
          DW      LOPEN       
.LOADF:   EQU     30H         
          DW      LOADFL      
.SAVEF:   EQU     31H         
          DW      SAVEFL      
.VRFYF:   EQU     32H         
          DW      VRFYFL      
.RWOPN:   EQU     33H         
          DW      RWOPEN      
.INSTT:   EQU     34H         
          DW      INPSTRT     
.INMSG:   EQU     35H         
          DW      INPMSG      
.INDAT:   EQU     36H         
          DW      INPDT       
.PRSTR:   EQU     37H         
          DW      PRTSTR      
.CLKL:    EQU     38H         
          DW      CLKL        
.DIR:     EQU     39H         
          DW      FDIR        
.SETDF:   EQU     3AH         
          DW      SETDFL      
.LSALL:   EQU     3BH         
          DW      LSALL       
.FINIT:   EQU     3CH         
          DW      FINIT       
.DELET:   EQU     3DH         
          DW      FDELET      
.RENAM:   EQU     3EH         
          DW      FRENAM      
.LOCK:    EQU     3FH         
          DW      FLOCK       
.RECST:   EQU     40H         
          DW      RECST       
.INREC:   EQU     41H         
          DW      INREC       
.PRREC:   EQU     42H         
          DW      PRREC       
.ERCVR:   EQU     43H         
          DW      ERRCVR      
.SWAP:    EQU     44H         
          DW      FSWAP       
.CLS:     EQU     45H         
          DW      HCLS        
.POSCK:   EQU     46H         
          DW      POSCK       
.POSSV:   EQU     47H         
          DW      POSSV       
.PSET:    EQU     48H         
          DW      PSET        
.LINE:    EQU     49H         
          DW      WLINE       
.PATTR:   EQU     4AH         
          DW      CHARW       
.BOX:     EQU     4BH         
          DW      WBOX        
.PAINT:   EQU     4CH         
          DW      WPAINT      
.CIRCL:   EQU     4DH         
          DW      WCIRCL      
.POINT:   EQU     4EH         
          DW      QPOINT      
.HCPY:    EQU     4FH         
          DW      HCPY        
.DSMOD:   EQU     50H         
          DW      DSMODE      
.DPLBK:   EQU     51H         
          DW      DPALBK      
.DPLST:   EQU     52H         
          DW      DPALST      
.DWIND:   EQU     53H         
          DW      DWIND       
.DCOL:    EQU     54H         
          DW      DCOLOR      
.DGCOL:   EQU     55H         
          DW      DGCOL       
.ICRT:    EQU     56H         
          DW      ICRT        
.SYMBL:   EQU     57H         
          DW      SYMBOL      

;*----------------------
;* SVC handler (RST 18H)
;*----------------------
IOSVC:    EX      (SP),HL     
          PUSH    AF          
          LD      A,(HL)      
          INC     HL          
          PUSH    HL          
          LD      HL,IOSVCT   
          ADD     A,A         
          ADD     A,L         
          JR      NC,IOSVC1   
          INC     H           
IOSVC1:   LD      L,A         
          LD      A,(HL)      
          INC     HL          
          LD      H,(HL)      
          LD      L,A         
          LD      (IOSVCX+1),HL 
          POP     HL          
          POP     AF          
          EX      (SP),HL     
IOSVCX:   JP      0           ;xxx

;*------------------------
;*  I/O device call (RST5)
;*------------------------
IOCALL:   PUSH    HL          
          PUSH    DE          
          LD      (IOCALX+1),IX 
          LD      IX,IOERR    
          OR      A           
IOCALX:   CALL    0           ;xxx
          POP     DE          
          POP     HL          
          RET     NC          
          OR      A           
          SCF     
          RET     Z           
          JP      IOERR       

;*---------------------------------
;*  Convert BINARY(HL) to ASCII(DE)
;*---------------------------------
ASCHL:    PUSH    HL          
          PUSH    BC          
          PUSH    DE          
          LD      DE,10000    
          CALL    NEWLAB      
          LD      DE,1000     
          CALL    NEWLAB      
          LD      DE,100      
          CALL    NEWLAB      
          LD      DE,10       
          CALL    NEWLAB      
          LD      A,L         
          POP     DE          
          OR      30H         
          LD      (DE),A      
          INC     DE          
          XOR     A           
          LD      (DE),A      
          POP     BC          
          POP     HL          
          RET     

NEWLAB:   LD      A,0FFH      
ASCHL4:   INC     A           
          OR      A           
          SBC     HL,DE       
          JR      NC,ASCHL4   
          ADD     HL,DE       
          OR      A           
          JR      NZ,ASCHL6   
          OR      B           
          RET     Z           ;Zero sup.
          XOR     A           
ASCHL6:   LD      B,1         
          OR      30H         
          POP     DE          
          EX      (SP),HL     
          LD      (HL),A      
          INC     HL          
          EX      (SP),HL     
          PUSH    DE          
          RET     

;*---------------------------------
;*  Convert ASCII(HL) to BINARY(DE)
;*---------------------------------
DEASC:    CALL    TEST1       
          DB      '$'         
          JR      Z,DEHEX     
          LD      DE,0        
DEASC2:   CALL    HLFTCH      
          SUB     30H         
          CP      10          
          RET     NC          
          INC     HL          
          PUSH    HL          
          LD      H,D         
          LD      L,E         
          ADD     HL,HL       ;2
          JR      C,ER02A     
          ADD     HL,HL       ;4
          JR      C,ER02A     
          ADD     HL,DE       ;5
          JR      C,ER02A     
          ADD     HL,HL       ;10
          JR      C,ER02A     
          LD      E,A         
          LD      D,0         
          ADD     HL,DE       
          JR      C,ER02A     
          EX      DE,HL       
          POP     HL          
          JR      DEASC2      

ER02A:    LD      A,2         
          JP      ERRORJ      

;*------------------------------
;* Convert HEX(HL) to BINARY(DE)
;*------------------------------
DEHEX:    LD      DE,0        
DEHEX2:   LD      A,(HL)      
          CALL    CKHEX       
          RET     C           
          INC     HL          
          EX      DE,HL       
          ADD     HL,HL       ;2
          JR      C,ER02A     
          ADD     HL,HL       ;4
          JR      C,ER02A     
          ADD     HL,HL       ;8
          JR      C,ER02A     
          ADD     HL,HL       ;16
          JR      C,ER02A     
          ADD     A,L         
          LD      L,A         
          EX      DE,HL       
          JR      DEHEX2      

;*----------
;* Check hex
;*----------
CKHEX:    SUB     30H         
          CP      10          
          CCF     
          RET     NC          
          SUB     17          
          CP      6           
          CCF     
          RET     C           
          ADD     A,10        
          RET     

;*------------------------------
;* SVC .HALT   ;Halt if SPACE,
;*             ;and break check
;*------------------------------
HALTP     CALL    HALTSB      
          CP      20H         
          RET     NZ          
HALT1:    CALL    HALTSB      
          OR      A           
          JR      Z,HALT1     
          RET     


HALTSB:   RST     18H         
          DB      .BREAK      
          JR      Z,HALTBR    
          LD      A,0FFH      
          RST     18H         
          DB      .INKEY      
          CP      1BH         
          RET     NZ          
HALTBR:   JP      BREAKZ      
          RET     

;*-------------------------
;* SVC .SETDF  ;set default
;*   ent DE:equipment table
;*       A: channel
;*-------------------------
SETDFL:   LD      (DDEV),DE   
          LD      (DCHAN),A   
          RET     

;*---------------
;* Pointer update
;*---------------
ADDP0:    LD      HL,(POOL)   
          ADD     HL,DE       
          LD      (POOL),HL   
ADDP1:    LD      HL,(VARST)  
          ADD     HL,DE       
          LD      (VARST),HL  
ADDP2:    LD      HL,(STRST)  
          ADD     HL,DE       
          LD      (STRST),HL  
          LD      HL,(VARED)  
          ADD     HL,DE       
          LD      (VARED),HL  
          LD      HL,(TMPEND) 
          ADD     HL,DE       
          LD      (TMPEND),HL 
          RET     

;*--------------------------------
;* SVC .ERRX  ;Print error message
;*--------------------------------
ERRX:     LD      C,A         
          RST     18H         
          DB      .BELL       
          RST     18H         
          DB      .CR2        
          BIT     7,C         
          JR      Z,ERRX1     
          LD      HL,KEYBUF   
          PUSH    HL          
          CALL    SETDNM      
          POP     DE          
          RST     18H         
          DB      .CRTMS      ;device name
ERRX1:    LD      A,C         
          AND     7FH         
          LD      C,A         
          RST     18H         
          DB      .DI         
          OUT     (LSE3),A    ;bank change
          JR      ERRX0       

ERRXU:    LD      C,69        
ERRX0:    LD      DE,ERRTXT   
ERRX2:    DEC     C           
          JR      Z,ERRX4     
ERRX3:    LD      A,(DE)      
          INC     DE          
          OR      A           
          JP      P,ERRX3     
          JR      Z,ERRXU     
          JR      ERRX2       
;*
ERRX4:    LD      A,(DE)      
          CP      80H         
          JR      Z,ERRXU     
          EX      DE,HL       
          LD      DE,KEYBUF   
ERRX6:    LD      A,(HL)      
          OR      A           
          JP      M,ERRX8     
          LDI     
          JR      ERRX6       

ERRX8:    AND     7FH         
          LD      (DE),A      
          OUT     (LSE1),A    ;bank change
          RST     18H         
          DB      .EI         
          INC     DE          
          LD      HL,MESER    
          LD      B,8         
          CALL    LDDEHL      
          LD      DE,KEYBUF   
          RST     18H         
          DB      .CRTMS      
          RET     

SETDNM:   LD      DE,(ZEQT)   
          INC     DE          
          INC     DE          
          RST     18H         
          DB      .COUNT      
          CALL    LDHLDE      
          LD      A,(ZCH)     
          ADD     A,'1'       
          LD      (HL),A      ;ch#
          LD      A,(ZFLAG2)  
          AND     0FH         ;max ch#
          JR      Z,SETDN2    
          INC     HL          
SETDN2:   LD      (HL),':'    
          INC     HL          
          LD      (HL),0      
          RET     

MESER:    DB      " ERROR"   
          DB      0           

;*-----------------------------------
;*    display mode
;*   ent. acc   mode    colors  dmd
;*         1  320*200     4      0
;*         2  320*200    16      2
;*         3  640*200     2      4
;*         4  640*200     4      6
;*-----------------------------------
DSMODE:   CALL    PUSHR       
          LD      B,A         
          LD      A,(MEMOP)   ;option vram exist ?
          OR      A           
          LD      A,B         
          JR      NZ,DSM0     
          CP      2           
          JR      Z,CERR      
          CP      4           
          JR      Z,CERR      
DSM0:     PUSH    AF          
          DEC     A           
          LD      D,0FFH      
          LD      HL,PAL4T    
          LD      BC,0403H    
          JR      Z,DSM00     ;skip if 320*200  4 colors
          DEC     A           
          LD      HL,PAL16T   
          LD      BC,100FH    
          JR      Z,DSM00     ;skip if 320*200 16 colors
          DEC     A           
          LD      HL,PAL2T    
          LD      BC,0201H    
          JR      Z,DSM00     ;skip if 640*200  2 colors
          LD      HL,PAL4T    ; 640 *200  4 colors
          LD      BC,0805H    
          LD      D,0FDH      
DSM00:    LD      (CPLANE),BC ;c cplane
          LD      A,D         
          LD      (PMASK),A   ;plane mask
          LD      (PALAD),HL  
          CALL    PALOFF      
          POP     AF          
          DEC     A           
          RLCA    
          LD      (DMD),A     
          OUT     (LSDMD),A   
          AND     4           ;bit 2 only
          CALL    DWIDTH      ;acc=0 -->40 chr
          CALL    CONPCI      ;(YS,YE)=0,24 palint
          OR      A           
          RET     

CERR:     SCF     
          RET     

;*--------------------------------
;*  console & palette & color init
;*--------------------------------
CONPCI:   LD      HL,1800H    ;(ys,ye)=(0,24)
          CALL    DWIND       
;*
;*       JR PALINT              ;commented out in original module
;*
PALINT:   LD      A,(CPLANE)  
          LD      (CMODE),A   
          XOR     A           
          CALL    DPALBK      ;init palette block reg.
          LD      HL,PALAD    
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          EX      DE,HL       
          LD      DE,PALTBL   ;init palette reg.
          PUSH    DE          
          LD      BC,4        
          LDIR    
          POP     HL          
PALOUT:   LD      B,4         
          LD      C,LSPAL     
          OTIR    
          RET     

;*------------------
;*   Palette all clr
;*------------------
PALOFF:   PUSH    BC          
          XOR     A           
          LD      B,5         
          LD      C,LSPAL     
PALOF1:   OUT     (C),A       
          ADD     A,10H       
          DJNZ    PALOF1      
          POP     BC          
          RET     

;*-------------------------------
;*   pallet  block register set
;*      ent  acc=pal block number
;*-------------------------------
DPALBK:   CALL    PUSHR       
          LD      (PALBK),A   
          LD      E,A         
          LD      A,(DMD)     
          CP      2           
          JR      NZ,PALBK1   ;skip if not 320*200 16 col
          LD      A,E         
          RLCA                ;*2
          RLCA                ;*4
          LD      HL,PALTBL   
          LD      B,4         
          PUSH    HL          
PALBK0:   LD      (HL),A      
          ADD     A,11H       
          INC     HL          
          DJNZ    PALBK0      
          POP     HL          
          CALL    PALOUT      
PALBK1:   LD      A,E         
          OR      40H         
          OUT     (LSPAL),A   
          RET     

;*----------------------------------
;*   pallet  register set
;*      ent  acc=pal register number
;*           b  =pal color code
;*----------------------------------
DPALST:   CALL    PUSHR       
          LD      HL,PALTBL   
          LD      D,0         
          LD      E,A         ;pallet register number
          ADD     HL,DE       
          OR      A           
          RLCA    
          RLCA    
          RLCA    
          RLCA    
          OR      B           ;pallet color code
          LD      (HL),A      
          OUT     (LSPAL),A   
          RET     

;*----------------------------------
;*   display color set
;*           acc=col code
;*----------------------------------
DCOLOR:   PUSH    AF          
          CALL    COLS        
          LD      (CMODE),A   
          POP     AF          
          RET     


DGCOL:    PUSH    AF          
          CALL    COLS        
          LD      (GMODE),A   
          POP     AF          
          RET     

COLS:     PUSH    BC          
          LD      B,A         
          LD      A,(DMD)     
          CP      6           
          LD      A,B         
          JR      NZ,COLS1    ;skip if not 640*200 4
          CP      2           
          JR      C,COLS1     
          ADD     A,2         ;2 or 3 only
COLS1:    POP     BC          
          RET     

;*---------------------
;*  display window set
;*---------------------
DWIND:    CALL    PUSHR       
          LD      (YS),HL     ;save YS,YE
          LD      A,H         
          SUB     L           
          INC     A           
          LD      (YW),A      ;YW=YE-YS+1 :lines
          LD      B,A         
          ADD     A,A         
          ADD     A,A         
          ADD     A,B         
          LD      (SW),A      ;SW=YW*5
          EX      DE,HL       
          LD      H,0         
          LD      L,A         
          ADD     HL,HL       ;*2
          ADD     HL,HL       ;*4
          ADD     HL,HL       ;*8
          LD      (SSW),HL    
          EX      DE,HL       
          INC     H           
          LD      A,H         
          ADD     A,A         
          ADD     A,A         
          ADD     A,H         
          LD      (SEA),A     ;SEA=(YE+1)*5
          LD      A,L         
          ADD     A,A         
          ADD     A,A         
          ADD     A,L         
          LD      (SSA),A     ;SSA=YS*5
          LD      HL,0        
          LD      (SOF),HL    ;SOF=0
          LD      HL,SEA      
          LD      BC,6CFH     ;B counter C scroll reg
          OTDR    
          CALL    HCLS        
          JP      HOME        

;*------------------------------
;*  display chracter size change
;*     if acc=1 then 640 chr
;*     if acc=0 then 320 chr
;*------------------------------
DWIDTH:   CALL    PUSHR       
          OR      A           
          LD      A,40        
          LD      DE,2300H    
          JR      Z,DWID1     
          ADD     A,A         ;80 chr
          LD      DE,0023H    
DWID1:    LD      (CWIDTH),A  
          LD      H,0         
          LD      L,A         
          ADD     HL,HL       ;*2
          ADD     HL,HL       ;*4
          ADD     HL,HL       ;*8
          LD      (CSIZE),HL  
          DEC     A           
          LD      (XE),A      
          LD      A,D         
          LD      (PTW0),A    
          LD      (PTW0+1),A  
          LD      (PTB0),A    
          LD      A,E         
          LD      (PTW1),A    
          LD      (PTW1+1),A  
          LD      (PTB1),A    
          LD      BC,0B07H    ;patch counter
          LD      HL,CHTBL    ;patch table addr
          CALL    PATCH       
          CALL    CHGRPH      ;mon-grph
          JP      HCLS        

;*------------
;*  word patch
;*------------
PATCH:    
PATCHW:   LD      E,(HL)      ;addr read
          INC     HL          
          LD      D,(HL)      
          INC     HL          
PTW0:     INC     HL          ;nop
          INC     HL          ;nop
          LD      A,(HL)      ;data read
          INC     HL          
          LD      (DE),A      
          INC     DE          
          LD      A,(HL)      
          INC     HL          
          LD      (DE),A      
PTW1:     NOP                 ;inc hl
          NOP                 ;inc hl
          DJNZ    PATCHW      
;*--------------
;*    byte patch
;*--------------
          LD      B,C         
PATCHB:   LD      E,(HL)      ;addr read
          INC     HL          
          LD      D,(HL)      
          INC     HL          
PTB0:     INC     HL          ;nop
          LD      A,(HL)      
          INC     HL          
          LD      (DE),A      
PTB1:     NOP                 ;inc hl
          DJNZ    PATCHB      
          RET     

;*--------------------------------
;*    PL-EX crt driver patch table
;*--------------------------------
;*------------
;*  word patch
;*------------
CHTBL:    DW      XPD1+1      ;ld de,xxxxh
          DW      80          
          DW      40          
          DW      XPC1        ;sla c
          DW      21CBH       
          DW      0           ;nop
          DW      XPC2+1      ;ld bc,xxxxh
          DW      400         
          DW      200         
          DW      XPC3+1      ;ld hl,xxxxh
          DW      BITBUF+16000 
          DW      BITBUF+8000 
          DW      XPDE3+1     ;ld de,xxxxh
          DW      80          
          DW      40          
          DW      XPDE4+1     ;ld bc,xxxxh
          DW      560         
          DW      280         
          DW      XPIN2+1     ;ld de,xxxxh
          DW      80          
          DW      40          
          DW      XPIN3+1     ;ld de,xxxxh
          DW      0FFB0H      
          DW      0FFD8H      
          DW      XPIN4+1     ;ld bc,xxxxh
          DW      0FDD0H      
          DW      0FEE8H      
          DW      XPLI2+1     ;ld de,xxxxh
          DW      80          
          DW      40          
          DW      XPSC2+1     ;ld bc,xxxxh
          DW      639         
          DW      319         
;*----------
;*byte patch
;*----------
          DW      XPDE1+1     ;ld l,xxh
          DB      79          
          DB      39          
          DW      XPDE2+1     ;ld c,xxh
          DB      79          
          DB      39          
          DW      XPIN1+1     ;ld c,xxh
          DB      79          
          DB      39          
          DW      XPLI1+1     ;ld a,xxh
          DB      79          
          DB      39          
          DW      XPSC1+1     ;ld c,xxh
          DB      80          
          DB      40          
          DW      XPCU1       ;add hl,hl
          DB      29H         
          DB      0           ;nop
          DW      XPCU2       ;add hl,hl
          DB      29H         
          DB      0           ;nop

;*---------------------------
;*    crt 1 character display
;*       acc=ascii code
;*---------------------------
ACCDI:    CALL    PUSHRA      
          LD      HL,(POSADR) 
          LD      C,A         
          CP      20H         ;convert space
          JR      NZ,ACCDI0   
          XOR     A           
ACCDI0:   LD      (HL),A      
          LD      HL,(BITADR) 
          LD      A,C         
          CALL    BITMAP      
          XOR     A           ;patch cursor
          LD      (CDOWN2+2),A 
          CALL    CRIGHT      
          LD      A,7         
          LD      (CDOWN2+2),A 
          RET     

;*-----------------------
;*    bitmap extension
;*    ent Acc:ascii  code
;*        HL :bitadr
;*-----------------------
BITMAP:   RST     18H         ;ascii->display
          DB      DQADCN      
          DI      
          EXX     
          PUSH    HL          
          LD      H,0         
          LD      L,A         ;display code
          LD      A,(CMODE)   
          OR      80H         ;replace mode
          OUT     (LSWF),A    
          ADD     HL,HL       ;*2
          ADD     HL,HL       ;*4
          ADD     HL,HL       ;*8
          SET     4,H         ;offset fontbuf $1000
          EXX     
          LD      B,8         
XPD1:     LD      DE,40       ;cwidth 80<--80 chr
          IN      A,(LSE0)    ;bank change !!
BITM1:    EXX     
          LD      A,(HL)      ;font pattern read
          INC     HL          ;next pointer
          EXX     
          LD      (HL),A      ;font pattern write
          ADD     HL,DE       ;next laster
          DJNZ    BITM1       
          IN      A,(LSE1)    ;   bank reset !!
          EI      
          EXX     
          POP     HL          
          EXX     
          RET     

;*-------------------------
;*     management   utility
;*     exit D=begin line
;*          E=end line+1
;*-------------------------
LBOUND:   CALL    TBCALC      
LBOUN1:   LD      A,(HL)      
          OR      A           
          JR      Z,LBOUN2    
          DEC     HL          
          DEC     E           
          LD      A,(YS)      
          CP      E           
          JR      C,LBOUN1    
LBOUN2:   LD      D,E         
LBOUN3:   INC     E           
          INC     HL          
          LD      A,(HL)      
          OR      A           
          RET     Z           
          LD      A,(YE)      
          CP      E           
          JR      NC,LBOUN3   
          RET     

TBCALC:   LD      E,H         
          LD      D,0         
          LD      HL,SCRNT0   
          ADD     HL,DE       
          RET     

;*-------------------
;*     clear  window
;*-------------------
HCLSW:    CALL    PUSHR       
          LD      A,(YS)      
          LD      H,A         
          CALL    TBCALC      
          LD      A,(YW)      ;YW=YE-YS+1
          LD      B,A         ;lines
          LD      E,A         ;store YW
          CALL    QCLRHL      ;mangement buf clr
CLSWT:    LD      C,E         ;restore YW
          LD      A,(YE)      

;*       JR     CLSLT           ;commented out in the original module

;*------------------------
;*    clear   line
;*    C=lines Acc=line no.
;*------------------------
CLSLT:    INC     A           
          LD      L,0         
          LD      H,A         
          PUSH    HL          ;start pos x,y
          CALL    PONT        
          LD      B,0         
XPC1:     NOP                 ;40  SLA C<--80
          NOP     
          PUSH    BC          
          CALL    PUSHW       
          POP     HL          ;pop counter
          ADD     HL,HL       ;*2
          ADD     HL,HL       ;*4
          ADD     HL,HL       ;*8
          LD      C,L         
          LD      B,H         
          POP     HL          ;start pos x,y
          CALL    PONTB       
          CALL    PUSHW       
          JR      CLRSCR      

;*------------------
;*    clear   screen
;*------------------
HCLS:     CALL    PUSHRA      
CLST:     LD      HL,TEXTBF+2000 
          LD      BC,50       
          CALL    PUSHW       
          LD      B,25        
          LD      HL,SCRNT0   
          CALL    QCLRHL      ;management buf clr
;*------------
;*  color mode
;*------------
CLSB:     
XPC2:     LD      BC,200      ;or 400
XPC3:     LD      HL,BITBUF+8000 ;or +16000
          CALL    PUSHW       
          JR      CLRSCR      

;*-----------------------
;*   PUSH Write
;*  Ent:HL=cls point addr
;*      BC=counts *40
;*-----------------------
PUSHW:    LD      (PUSHW1+1),SP 
          LD      (PUSHW2+1),HL 
          LD      HL,0        
          LD      A,(CPLANE)  ;display active plane
          OR      80H         ;replace mode
          OUT     (LSWF),A    
PUSHW0:   DI      
PUSHW2:   LD      SP,0        ;xx
          IN      A,(LSE0)    ;bank
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          ;10
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          ;20
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          ;30
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          
          PUSH    HL          ;40
          IN      A,(LSE1)    ;bank
          LD      (PUSHW2+1),SP 
PUSHW1:   LD      SP,0        ;xxx
          EI      
          DEC     BC          
          LD      A,C         
          OR      B           
          JR      NZ,PUSHW0   
          RET     

;*----------------------------
;*    scroll parameter initial
;*----------------------------
CLRSCR:   LD      HL,0        
          LD      (SOF),HL    
          LD      B,2         
          LD      C,LSSCR     ;lsi scroll register
          OUT     (C),H       
          DEC     B           
          OUT     (C),L       
          JP      HOME        

;*---------------------
;*     delete character
;*---------------------
DEL:      EXX     
          PUSH    HL          
          PUSH    DE          
          PUSH    BC          
          EXX     
          CALL    DEL0        
          EXX     
          POP     BC          
          POP     DE          
          POP     HL          
          EXX     
          RET     


DEL0:     LD      HL,(CURXY)  
          DEC     L           
          JP      P,DEL1      
          CALL    TBCALC      
          LD      A,(HL)      
          LD      H,E         
          LD      L,0         
          OR      A           
          JR      Z,DEL1      
          LD      A,(YS)      
          CP      H           
          JR      Z,DEL1      
          DEC     H           
XPDE1:    LD      L,39        ;XE 39 or 79
DEL1:     LD      (CURXY),HL  
          CALL    LINCAL      
;*BC lines HL' counts HL last curxy
          CALL    PONTC       
          PUSH    BC          ;lines store
          LD      D,H         
          LD      E,L         
          INC     HL          
          EXX     
          PUSH    HL          ;HL' counts
          EXX     
          POP     BC          
          LDIR    
          XOR     A           
          LD      (DE),A      ;last addr space
          POP     BC          ;lines pop
          LD      HL,(CURXY)  
          INC     HL          
          CALL    PONTB       ;bitmap addr
DELB11:   EXX     
          LD      D,9         ;laster set
          LD      HL,(MAXCF)  
          DEC     D           
          EXX     
          JR      DELB2       ;line first time only

;*----------------------------------
;*  DELB
;*  ent.
;*  BC  lines
;*  HL  start address
;*----------------------------------
DELB:     
XPDE2:    LD      C,39        ;79 xe
          DEC     B           ;last line ?
          JR      Z,DELB0     ;skip if end of func.
          INC     DE          ;next addr calc
          INC     DE          
          LD      H,D         
          LD      L,E         
          JR      DELB11      

DELB1:    LD      HL,(MAXCF)  ;
          DEC     D           ;last laster ?
          EXX     
          JR      Z,DELB      ;skip if next line
XPDE3:    LD      DE,40       ;cwidth  80
          ADD     HL,DE       
DELB2:    EXX                 ;next plane ?
          RRC     L           
          JR      C,DELB1     
          LD      A,L         
          AND     H           ;pmask
          EXX     
          JR      Z,DELB2     ;skip if warp
          DI      
          PUSH    HL          
          PUSH    BC          
          OUT     (LSRF),A    ;read plane
          OUT     (LSWF),A    ;write plane
          IN      A,(LSE0)    ;bank change
          OUT     (LSE0),A    ;cg off
          LD      D,H         
          LD      E,L         
          DEC     DE          
          LD      A,C         
          OR      A           
          JR      Z,XPDE4     
          LD      A,B         ;line counter
          LD      B,0         
          LDIR    
          DEC     A           
          JR      Z,DELB3     ;skip if last counter
XPDE4:    LD      BC,280      ; 560
          ADD     HL,BC       
          LD      A,(HL)      
          LD      (DE),A      
DELB3:    IN      A,(LSE1)    ;bank off
          EI      
          POP     BC          
          POP     HL          
          JP      DELB2       

DELB0:    EX      DE,HL       
          INC     C           
          LD      E,C         
          LD      D,B         
          LD      B,8         
          DI      
          IN      A,(LSE0)    ;bank change
          OUT     (LSE0),A    ;cg off
          LD      A,(CPLANE)  
          OR      80H         ;replace mode
          OUT     (LSWF),A    
DELB01:   XOR     A           
          LD      (HL),A      ;space fill
          SBC     HL,DE       
          DJNZ    DELB01      
          IN      A,(LSE1)    ;bank off
          EI      
          LD      HL,(CURXY)  
          JP      CURMOV      

;*---------------------
;*     insert character
;*---------------------
INST:     EXX     
          PUSH    HL          
          PUSH    DE          
          PUSH    BC          
          EXX     
          CALL    INST0       
          EXX     
          POP     BC          
          POP     DE          
          POP     HL          
          EXX     
          RET     

INST0:    LD      HL,(CURXY)  
          CALL    LINCAL      
;*BC lines HL' counts HL last curxy
          PUSH    HL          ;store last-next pos x,y
          CALL    PONT        
          DEC     HL          ;last addr
          LD      A,(HL)      
          OR      A           
          JR      NZ,INSTE    ;no insert space
          PUSH    BC          ;lines store
          LD      D,H         
          LD      E,L         
          DEC     HL          
          EXX     
          PUSH    HL          ;HL' counts
          EXX     
          POP     BC          
          LDDR    
          XOR     A           
          LD      (DE),A      ;last addr space
          POP     BC          ;lines pop
          POP     HL          
          CALL    PONTB       ;bitmap addr
          DEC     HL          
          LD      A,C         
          LD      (LASTC+1),A 
          DEC     B           
          JR      Z,INSEF     ;first time ended
          JR      INSB1       

INSTE:    POP     HL          
          RET     

;*----------------------------------
;*       insert operation
;*            <<bitmap>>
;*       ent. B =line counter
;*----------------------------------
INSB:     DEC     B           ;last line ?
          JR      Z,INSEND    ;skip if end of func.
INSB1:    
XPIN1:    LD      C,39        ;79 xe
          CALL    INSLIN      
          JR      INSB        

;*---------------------------------
;*       insert operation
;*             <<bitmap end >>
;*---------------------------------
INSEND:   
LASTC:    LD      C,0         ;patch
INSEF:    CALL    INSLIN      
          CALL    PONTCB      
XPIN2:    LD      DE,40       ;cwidth 80
          LD      B,8         
          DI      
          LD      A,(CPLANE)  
          OR      80H         ;replace mode
          OUT     (LSWF),A    
          IN      A,(LSE0)    ;bank change
          OUT     (LSE0),A    ;cg off
INSB01:   XOR     A           
          LD      (HL),A      ;space fill
          ADD     HL,DE       
          DJNZ    INSB01      
          IN      A,(LSE1)    ;bank off
          EI      
          RET     

;*----------------------------------
;*       insert operation
;*              1 line only
;*   ent.
;*         HL=first destination addr
;*         C =bytes
;*----------------------------------
INSLIN:   EXX     
          LD      D,9         ;laster counter set
INSL1:    LD      HL,(MAXCF)  ;
          DEC     D           ;last laster ?
          EXX     
          RET     Z           
          CALL    INSLAS      
XPIN3:    LD      DE,0FFD8H   ;0FFB0H<--80
          ADD     HL,DE       
          EXX     
          JR      INSL1       

;*---------------------------------
;*       insert operation
;*              1 laster only
;*   ent.  E'=plane data(maxcf)
;*         HL=first destination addr
;*         C=bytes
;*---------------------------------
INSLAS:   EXX                 ;next plane ?
          RRC     L           
          LD      A,L         
          EXX     
          RET     C           ;next laster
          EXX     
          AND     H           ;pmask
          EXX     
          JR      Z,INSLAS    ;skip if warp
          PUSH    HL          
          PUSH    BC          
          DI      
          OUT     (LSRF),A    ;read plane
          OUT     (LSWF),A    ;write plane
          IN      A,(LSE0)    ;bank change
          OUT     (LSE0),A    ;cg off
          LD      D,H         
          LD      E,L         
          DEC     HL          
          LD      A,C         
          OR      A           
          JR      Z,XPIN4     
          LD      A,B         ;line counter
          LD      B,0         
          LDDR    
          OR      A           
          JR      Z,INSLA1    ;skip if last line
XPIN4:    LD      BC,0FEE8H   ;FDD0H <--80
          ADD     HL,BC       
          LD      A,(HL)      
          LD      (DE),A      
INSLA1:   IN      A,(LSE1)    ;bank off
          EI      
          POP     BC          
          POP     HL          
          JP      INSLAS      

;*------------------
;*   line cal
;*------------------

LINCAL:   LD      B,1         
XPLI1:    LD      A,39        ;xe 39 or 79
          SUB     L           
          LD      C,A         
          EXX     
XPLI2:    LD      DE,40       ;cwidth 80
          LD      H,0         
          LD      L,A         
          EXX     
LINC1:    INC     H           ;next line check
          LD      A,(YE)      
          CP      H           
          JR      C,LINC2     ;scroll end check
          CALL    TBCALC      
          LD      A,(HL)      
          OR      A           
          LD      H,E         
          JR      Z,LINC2     ;management check
          INC     B           
          EXX     
          ADD     HL,DE       
          EXX     
          JR      LINC1       

LINC2:    LD      L,0         
          RET     

;*---------------------
;*    scroll main logic
;*--------------------
SCROLL:   CALL    PUSHRA      
;*-----------------------
;*  text buf scroll & clr
;*-----------------------
SCRTX:    LD      A,(YS)      
          LD      H,A         
          LD      L,0         
          CALL    PONT        ;start addr  cal
          LD      D,H         
          LD      E,L         ;DE destination addr
          LD      B,0         
XPSC1:    LD      C,40        ;cwidth 80
          ADD     HL,BC       ;HL source addr
          LD      A,(YW)      ;scroll lines
          DEC     A           
          JR      Z,SCR0      ;skip if 1 line mode
          PUSH    BC          
          PUSH    HL          
          LD      HL,0        
SCR1:     ADD     HL,BC       
          DEC     A           
          JR      NZ,SCR1     
          LD      B,H         ;scroll bytes
          LD      C,L         
          POP     HL          ;pop source addr
          LDIR    
          POP     BC          
SCR0:     LD      B,C         
          CALL    QCLRDE      ;last line clr
;*---------------------------
;*   manager buf scroll & clr
;*---------------------------
          LD      A,(YS)      
          LD      H,A         
          CALL    TBCALC      ;exit HL maneger addr
          LD      A,(YW)      ;scroll lines
          DEC     A           ;1 line mode check
          LD      B,A         
          LD      (HL),0      
          INC     HL          
          LD      D,H         
          LD      E,L         
          INC     DE          
          CALL    NZ,LDHLDE   ;(hl)<--(de)
          LD      (HL),0      ;last line manegement
;*----------------------
;*    calculation xferad
;*----------------------
SCRCAL:   LD      A,(YE)      
          LD      H,A         
          LD      L,0         ;HL=(0,YE)
          CALL    PONTB       
          LD      (XFERAD+1),HL ;xferad data
;*----------------------
;*    scroll offset calc
;*----------------------
SCXFER:   LD      DE,40       
          LD      HL,(SOF)    ;lsi scroll offset
          ADD     HL,DE       
          PUSH    HL          
          LD      DE,(SSW)    ;lsi scroll width
          OR      A           
          SBC     HL,DE       
          POP     HL          
          JR      NZ,SCXF1    ;sof<ssw
          LD      HL,0        
SCXF1:    LD      (SOF),HL    
;*--------------------
;*   scroll offset out
;*--------------------
SCXF2:    IN      A,(LSDMD)   ;lsi status
          AND     40H         ;vblank check
          JR      NZ,SCXF2    
          DI      
          LD      C,LSSCR     ;lsi scroll port
          LD      B,2         
          OUT     (C),H       
          DEC     B           
          OUT     (C),L       
          LD      A,(CMODE)   ;crt mode st
          OUT     (LSRF),A    ;single mode
          OR      80H         ;replace mode
          OUT     (LSWF),A    
;*--------------------------------
;*  xfer   buffer -->> graphic ram
;*--------------------------------
          IN      A,(LSE0)    ; bank change
          OUT     (LSE0),A    ; cg off
XFERAD:   LD      HL,0        ; LD HL,xxxxh
          LD      (HL),0      
          LD      D,H         
          LD      E,L         
          INC     DE          
XPSC2:    LD      BC,319      ;xfer bytes
          LDIR    
          IN      A,(LSE1)    ;  bank reset
          EI      
;*-----------------------------
;*      scroll operation ended
;*        cursor window end pos
;*-----------------------------
BOS:      LD      A,(YE)      
          LD      H,A         
          LD      L,0         
          JP      CURMOV      

;*---------------------
;*     cursor  routines
;*---------------------
CURSM:    CALL    PUSHRA      
;*cursor data pattern
          EXX     
          PUSH    HL          ;push hl'
          LD      HL,CURDT1   
          LD      A,(CURMAK)  
          OR      A           
          JR      Z,CURS0     
          LD      HL,CURDT2   
          DEC     A           
          JR      Z,CURS0     
          LD      HL,CURDT3   
CURS0:    EXX     
          DI      
          LD      A,(CURFLG)  
          XOR     1           
          LD      (CURFLG),A  
          LD      HL,(BITADR) 
          LD      D,0         
          LD      A,(CWIDTH)  
          LD      E,A         
          LD      B,8         ;counter
          LD      A,(CMODE)   
          OR      20H         ;xor mode
          OUT     (LSWF),A    ;wf
          IN      A,(LSE0)    ;bank change
          OUT     (LSE0),A    ;cg off
CURS1:    EXX     
          LD      A,(HL)      
          INC     HL          
          EXX     
          LD      (HL),A      
          ADD     HL,DE       
          DJNZ    CURS1       
          IN      A,(LSE1)    ;bank reset
          EXX     
          POP     HL          ;pop hl'
          EXX     
          EI      
          RET     

HCURON:   CALL    PUSHRA      
          XOR     A           
          OUT     (LSD0),A    ;reset 556
          CPL     
          OUT     (LSD0),A    
          LD      A,(CURFLG)  
          OR      A           
          RET     NZ          
          JR      CURSM       

HCUROF:   CALL    PUSHRA      
          LD      A,(CURFLG)  
          OR      A           
          RET     Z           
          JR      CURSM       

FLASH:    IN      A,(LSD2)    ;bit 6
          RLCA    
          RLCA    
          JR      NC,HCURON   
          JR      HCUROF      

;*--------------------------
;*   cursor   move
;*                ent HL x,y
;*--------------------------
CURMOV:   CALL    PUSHR       
          LD      (CURXY),HL  
          CALL    PONT        ;cursor addr cal
          LD      (POSADR),HL 
          CALL    PONTCB      ;bitmap cursor pos cal
          LD      (BITADR),HL 
          RET     
;*
;*--------------------------
;*   pointer calc
;*          ent hl=curxy
;*              hl=text addr
;*--------------------------
PONTC:    LD      HL,(CURXY)  
PONT:     PUSH    DE          
          PUSH    AF          
          LD      D,20H       ;offset textbuf
          LD      E,L         
          LD      A,H         
          ADD     A,A         ;2
          ADD     A,A         ;4
          ADD     A,H         ;5
          LD      L,A         
          LD      H,0         
          ADD     HL,HL       ;10
          ADD     HL,HL       ;20
          ADD     HL,HL       ;40
XPCU1:    NOP                 ;ADD HL,HL *80
          ADD     HL,DE       
          POP     AF          
          POP     DE          
          RET     

;*---------------------------
;*     pointer cal
;*         ent hl=curxy
;*             hl=bitmap addr
;*---------------------------
PONTCB:   LD      HL,(CURXY)  
PONTB:    PUSH    DE          
          PUSH    AF          
          LD      D,H         
          LD      E,0         ;de=h*256
          LD      A,L         
          LD      L,H         ;l=curx
          LD      H,E         ;h=0
          ADD     HL,HL       ;*2
          ADD     HL,HL       ;*4
          ADD     HL,HL       ;*8
          ADD     HL,HL       ;*16
          ADD     HL,HL       ;*32
          ADD     HL,HL       ;*64
          ADD     HL,DE       ;*320
XPCU2:    NOP                 ;ADD HL,HL *640
          CALL    ADDHLA      
          SET     7,H         ;offset bitmap addr
          POP     AF          
          POP     DE          
          RET     

;*------------------------------
;*    cursor left,right,down,up
;*------------------------------
HOME:     LD      L,0         
          LD      A,(YS)      
          LD      H,A         
          JP      CSET        
;*
CR2:      CALL    PUSHR       
          LD      HL,(CURXY)  
          LD      A,L         
          OR      A           
          JR      NZ,CR1      
          CALL    TBCALC      
          LD      A,(HL)      
          OR      A           
          RET     Z           
CR1:      LD      A,0DH       
          JP      CRT1C       

CTR.M:    XOR     A           
          LD      (CRTSFG+1),A ;sft mode reset
          LD      HL,(CURXY)  
          PUSH    HL          
          INC     H           
          CALL    TBCALC      
          LD      A,(YE)      
          LD      D,A         
CTR.ML:   LD      A,(HL)      
          OR      A           
          JR      Z,CTR.M4    
          INC     HL          
          INC     E           
          LD      A,D         
          CP      E           
          JR      NC,CTR.ML   
CTR.M4:   DEC     E           
          POP     HL          
          LD      H,E         
          JR      CTR.M2      

CDOWN:    LD      HL,(CURXY)  
          JR      CDOWN2      

CRIGHT:   LD      HL,(CURXY)  
          INC     L           
          LD      A,(XE)      
          CP      L           
          JR      NC,CSET     
CTR.M2:   LD      L,0         
CDOWN2:   INC     H           
          JR      CDOWN3      ;patch
          PUSH    HL          
          CALL    TBCALC      
          LD      (HL),1      
          POP     HL          
CDOWN3:   LD      A,(YE)      
          CP      H           
          JR      NC,CSET     
          LD      H,A         
          PUSH    HL          
          CALL    SCROLL      
          POP     HL          
CSET:     JP      CURMOV      

CUP:      LD      HL,(CURXY)  
          JR      CUP2        

CLEFT:    LD      HL,(CURXY)  
          LD      A,L         
          OR      A           
          JR      NZ,CSET2    
          LD      A,(XE)      
          LD      L,A         
CUP2:     LD      A,(YS)      
          CP      H           
          JR      C,CSET3     
          LD      A,(YS)      
          LD      H,A         
          DB      3EH         
CSET2:    DEC     L           
          DB      3EH         
CSET3:    DEC     H           
          JR      CSET        

CTR.F:    
CTR.Y:    XOR     A           ;ALPHA
          DB      21H         
CTR.E:    LD      A,1         ;Shift lock
          DB      21H         
CTR.W:    LD      A,2         ;GRAPH
          LD      (CURMAK),A  
          RET     

;*-----------------
;*     tab function
;*-----------------
CTAB:     LD      B,0         ;tab
          LD      HL,(CURXY)  
          INC     L           
          LD      A,L         
CTAB1:    INC     B           
          SUB     10          
          JR      NC,CTAB1    
          XOR     A           
CTAB2:    ADD     A,10        
          DJNZ    CTAB2       
          LD      L,A         
          LD      A,(XE)      ;border check
          CP      L           
          RET     C           
          PUSH    HL          
          LD      A,(INPFLG)  
          OR      A           
          JR      Z,CTAB4     
          LD      A,(CURX)    
          LD      H,A         
          LD      A,L         
          SUB     H           
          JR      Z,CTAB4     
          LD      B,A         
CTAB3:    PUSH    BC          
          LD      A,20H       ;space
          CALL    PLTOUT      
          POP     BC          
          DJNZ    CTAB3       
CTAB4:    POP     HL          
          JP      CURMOV      

;*-------------------
;* tab print function
;*-------------------
PRNTT:    CALL    CRT1S       
          LD      A,(CURX)    
PRNTT1:   SUB     10          
          JR      NC,PRNTT1   
          ADD     A,10        
          RET     Z           
          JR      PRNTT       

;*------------------------------
;*   GET LINE     V0.1A
;*                  '84.7.11
;*------------------------------
BINPUT:   PUSH    HL          
          LD      HL,(CURXY)  
          PUSH    HL          
          PUSH    DE          
          CALL    TBCALC      
          POP     DE          
          LD      (HL),0      
          POP     HL          
          CALL    GETL        
          JR      C,BINERT    
          LD      A,L         
          OR      A           
          JR      Z,BINERT    
          LD      H,0         
          ADD     HL,DE       
          EX      DE,HL       
          OR      A           
BINERT:   POP     HL          
          RET     

GETL:     PUSH    BC          
          PUSH    HL          
          PUSH    DE          
LINP02:   CALL    INKEY1      
          CP      0DH         ;CR?
          JP      Z,GCRT      
          CP      1BH         ;Break?
          JR      Z,LINP.B    
          PUSH    AF          
          LD      A,(CURMAK)  
          CP      2           ;Graph mode?
          JR      NZ,LINP10   
          POP     AF          
          CP      17H         
          JR      NC,LINP11   
          CP      11H         
          JR      C,LINP11    
          LD      HL,(CTRSFT) 
          BIT     6,L         ;Ctrl?
          JR      Z,LINP11    
LINP32:   RST     18H         
          DB      .CRT1X      
          JR      LINP02      

LINP10:   POP     AF          
LINP11:   RST     18H         
          DB      .CRT1C      
          JR      LINP02      

LINP.B:   SCF                 ;break key on
LINP80:   RST     18H         
          DB      .CR1        
          POP     DE          
          POP     HL          
          POP     BC          
          RET     

GCRT:     LD      HL,(CURXY)  
          CALL    LBOUND      ;begin end search
          LD      A,E         
          SUB     D           
          LD      E,A         ;E:Y.length
          LD      H,D         ;H:line count
          LD      L,0         
          CALL    PONT        ;calc start address
          LD      A,(CWIDTH)  ;X size
          LD      D,A         
          POP     BC          ;store address set
          PUSH    BC          
          EXX     
          PUSH    HL          
          LD      HL,(LINLIM) ;L:line inp limit
          EXX     
GCRT10:   LD      A,(HL)      ;A<--ascii code
GCRT36:   INC     HL          
          LD      (BC),A      ;(BC)<--ascii code
          INC     BC          
          EXX     
          DEC     L           
          JR      Z,GCRT40    ;line limit?
          EXX     
          DEC     D           
          JR      NZ,GCRT10   ;X right end ?
          LD      A,(CWIDTH)  
          LD      D,A         
          DEC     E           
          JR      NZ,GCRT10   ;line count=0 ?
          EXX     
GCRT40:   POP     HL          
          EXX     
          XOR     A           
          LD      (BC),A      ;end address=0
          LD      L,C         
          LD      H,B         
          POP     DE          
          PUSH    DE          
          PUSH    HL          
          OR      A           
          SBC     HL,DE       
          LD      B,L         
          POP     HL          
          LD      A,20H       ;clschr?
          LD      D,A         
          JP      Z,LINP80    
          DEC     HL          
GCRT50:   LD      A,(HL)      
          OR      A           
          JR      Z,GCRT52    
          CP      D           
          JR      NZ,GCRT54   
          LD      (HL),0      
GCRT52:   DEC     HL          
          DJNZ    GCRT50      
          JR      GCRT56      

GCRT54:   LD      A,(HL)      
          OR      A           
          JR      NZ,GCRT55   
          LD      (HL),20H    
GCRT55:   DEC     HL          
          DJNZ    GCRT54      
GCRT56:   OR      A           
          JP      LINP80      

;*-----------------------------------------------------
;* Top of p.69 in German Listing of MZ-2Z046 Disk Basic
;*-----------------------------------------------------
;*-----------------------------
;*     KEY      V0.1A
;*                   '84.7.11
;* INKEY$[(ACC)]
;*   A=FF : INKEY$   =GET
;*   A=0  : INKEY$(0)=KEY DATA
;*   A>0  : INKEY$(1)=FLASH GET
;*-----------------------------
INKEY$:   INC     A           
          JR      Z,INKEYFF   
          DEC     A           
          JP      Z,INKEY0    
INKEY1:   CALL    KBFCHR      
          CALL    PUSHR       
          CALL    HCURON      
          EX      AF,AF'      
          PUSH    AF          
          CALL    KEYSNS      
          LD      A,(REPTF)   
QKEY10:   EX      AF,AF'      
QKEY12:   LD      B,16        ;chattering
QKEY14:   CALL    FLASH       
          CALL    KEYSNS      
          BIT     1,A         
          JR      NZ,QKEY12   ;same key ?
          DJNZ    QKEY14      
          BIT     0,A         
          JR      Z,QKEY20    ;key on ?
          BIT     2,A         
          JR      NZ,QKEY24   ;new key ?
          EX      AF,AF'      
          DEC     A           
          JR      NZ,QKEY10   
          LD      A,6         ;Repeat step time
          JR      QKEY26      
QKEY20:   PUSH    HL          
          PUSH    DE          
          PUSH    BC          
          LD      HL,KYDTB2   
          LD      DE,KYDTB1   
          LD      BC,10       
          LDIR                ;(KYDTB1)<--(KYDTB2)
          POP     BC          
          POP     DE          
          POP     HL          
QKEY24:   LD      A,40H       ;Repeat init time
QKEY26:   LD      (REPTF),A   
QKEY28:   CALL    FLASH       
          CALL    KEYGET      
          OR      A           
          JR      Z,QKEY29    
          LD      (KEYDAT),A  
          LD      C,A         
          CALL    HCUROF      
          POP     AF          
          EX      AF,AF'      
          LD      A,C         
          RET     

QKEY29:   PUSH    HL          
          PUSH    BC          
          LD      B,10        
          LD      HL,KYDTB1   
QKEY30:   LD      (HL),0FFH
          INC     HL          
          DJNZ    QKEY30      
          POP     BC          
          POP     HL          
          JR      QKEY28      

INKEYFF:  CALL    KBFCHR      
          PUSH    HL          
          CALL    KEYGET      
          LD      HL,KEYDAT   
          OR      A           
          JR      Z,INKEY9    
          CP      (HL)        
          JR      NZ,INKEY9   
          POP     HL          
          XOR     A           
          RET     

INKEY9:   LD      (HL),A      
          POP     HL          
          RET     

INKEY0:   CALL    KBFCHR      
          CALL    KEYGET      
          LD      (KEYDAT),A  
          RET     

KBFCHR:   PUSH    HL          ;function key buffer
          LD      HL,(INBUFC) 
          LD      A,L         ;INBUFC
          CP      H           ;INBUFL
          POP     HL          
          RET     Z           
          EX      (SP),HL     
          INC     A           
          LD      (INBUFC),A  
          LD      HL,INBUFL   ;INBUF-1
          CALL    ADDHLA      
          LD      A,(HL)      
          POP     HL          
          RET     

KEYSNS:   CALL    PUSHR       
          LD      DE,KYDTB2   
          LD      HL,KYDTB1   
          LD      BC,0A00H    
          DI      
KEYSN0:   LD      A,B         
          ADD     A,0EFH      
          OUT     (0D0H),A    
          CP      0F8H        ;special strobe
          IN      A,(0D1H)    
          JR      NZ,KEYSN1   
          OR      7FH         
KEYSN1:   CP      0FFH        
          JR      Z,KEYSN2    
          SET     0,C         ;bit 0=key on
KEYSN2:   EX      DE,HL       
          CP      (HL)        
          LD      (HL),A      
          EX      DE,HL       
          JR      Z,KEYSN3    
          SET     1,C         ;bit 1=not same key
KEYSN3:   CPL     
          AND     (HL)        
          JR      Z,KEYSN4    
          SET     2,C         ;bit 2=new key
KEYSN4:   INC     HL          
          INC     DE          
          DJNZ    KEYSN0      
          LD      A,C         
KEYSNE:   EI      
          RET     

KEYGET:   CALL    PUSHR       
          LD      HL,KYDTB1   
          LD      DE,KYDTB2   
          PUSH    HL          
          PUSH    DE          
          LD      BC,10       
          LDIR                ;(KYDTB2)<--(KYDTB1)
          POP     HL          
          POP     DE          
          LD      BC,0AF9H    
          DI      
          LD      A,C         
          OUT     (0D0H),A    
          NOP     
          IN      A,(0D1H)    
          LD      (DE),A      
KEYGL1:   LD      A,C         
          OUT     (0D0H),A    
          CP      0F8H        ;special strobe
          IN      A,(0D1H)    
          LD      (DE),A      
          JR      Z,KEYG13    
          CPL     
          AND     (HL)        ;same--->Acc=0
KEYGL3:   LD      (HL),A      
          INC     DE          
          INC     HL          
          DEC     C           
          DJNZ    KEYGL1      
          EI      
          LD      BC,0A00H    
KYSTCK:   DEC     HL          
          LD      A,(HL)      
          OR      A           
          JR      NZ,KEYGIN   ;not same-->KEYGIN
          INC     C           
          DJNZ    KYSTCK      
          LD      B,10        
KEYGL2:   DEC     DE          
          LD      A,(DE)      
          CP      0FFH        
          JR      NZ,REPKIN   
REPKI3:   DJNZ    KEYGL2      
KEYNUL:   XOR     A           
          JR      KEYSNE      

KEYG13:   XOR     A           
          JR      KEYGL3      

REPKIN:   LD      A,B         
          CP      2           
          JR      NZ,REPKI2   
          LD      A,(DE)      
          AND     81H         
          JR      NZ,REPKI3   
          LD      A,1BH       ;break key
          JR      KEYSNE      

REPKI2:   CP      1           
          JR      Z,KEYNUL    
          LD      A,(REPCD1)  
          CP      B           
          JR      NZ,REPKI3   
          LD      A,(DE)      
          PUSH    DE          
          LD      D,A         
          LD      A,(REPCD2)  
          AND     D           
          POP     DE          
          JR      NZ,REPKI3   
          LD      A,(KEYDAT)  
          JR      KEYSNE      

KEYGIN:   PUSH    AF          
          LD      A,B         
          LD      (REPCD1),A  
          LD      A,(HL)      
          LD      (REPCD2),A  
          POP     AF          
          DEC     B           
          JR      NZ,KEYGI6   
          CALL    ABITB       ;function key
          LD      A,(CTRSFT)  
          BIT     6,A         
          JR      Z,KEYNUL    
          BIT     0,A         
          LD      A,B         
          JR      NZ,KEYG14   
          ADD     A,5         
KEYG14:   CP      10          
          JR      NC,KEYNUL   
          LD      L,A         
          LD      H,0         
          ADD     HL,HL       
          ADD     HL,HL       
          ADD     HL,HL       
          ADD     HL,HL       
          LD      BC,FUNBUF   
          ADD     HL,BC       
          LD      A,(HL)      
          OR      A           
          JR      Z,KEYNUL    
          LD      DE,INBUFC   
          LD      A,1         
          LD      (DE),A      
          INC     DE          
          LD      BC,16       
          LDIR    
          LD      A,(INBUF)   
          JP      KEYSNE      

KEYGI6:   CALL    ABITB       
          LD      A,C         
          ADD     A,A         
          ADD     A,A         
          ADD     A,A         
          ADD     A,B         
          LD      L,A         
          LD      H,0         
          LD      A,(CTRSFT)  
          BIT     6,A         ;ctrl key
          LD      BC,NOMALB   
          JR      Z,CTRLIN    
          PUSH    AF          
          LD      A,(CURMAK)  
          CP      1           ;shift+lock
          JR      NZ,SFTLKL   
          POP     AF          
          XOR     1           
          PUSH    AF          
SFTLKL:   POP     AF          
          BIT     0,A         ;shift key
          JR      NZ,KEYG17   
          LD      BC,SHIFTB   
KEYG17:   LD      A,(CURMAK)  
          CP      2           ;graph
          JR      NZ,CHRSET   
          LD      BC,GRPHB    
          LD      A,(CTRSFT)  
          BIT     0,A         
          JR      Z,CHRSET    
          LD      BC,GRPHS    
CHRSET:   CALL    QKYTBL      
          LD      A,C         
          JP      KEYSNE      

CTRLIN:   CALL    QKYTBL      
          LD      A,C         
          CP      20H         
          JP      C,KEYSNE    
          LD      HL,CTKYTB   
          LD      B,5         
KEYG18:   CP      (HL)        
          JR      Z,CTRLC1    
          INC     HL          
          DJNZ    KEYG18      
          CP      40H         
          JP      C,KEYNUL    
          CP      5BH         
          JP      NC,KEYNUL   
          SUB     40H         
          JP      KEYSNE      

CTRLC1:   LD      A,32        
          SUB     B           
          JP      KEYSNE      

ABITB:    LD      B,8         
KEYG19:   RRCA    
          JR      C,ABITB2    
          DJNZ    KEYG19      
          RET     

ABITB2:   DEC     B           
          RET     

BRKEY:    LD      A,0E8H      
          OUT     (0D0H),A    
          NOP     
          IN      A,(0D1H)    
          AND     81H         
          RET     Z           
          RLCA    
          RET     C           
          JR      BRKEY       

KYDTB1:   DB      0           ;was DEFS 1
CTRSFT:   DB      0,0,0,0,0,0,0,0,0 ;was DEFS 9


KYDTB2:   DB      0,0,0,0,0,0,0,0,0,0 ;was DEFS 10


REPTF:    DB      0           
REPCD1:   DB      0           
REPCD2:   DB      1           

NOMALB:   DW      0BEAH       
          DW      1790H       
          DW      19FCH       
          DW      3B09H       
          DW      0D3AH       
          DW      1018H       
          DW      1112H       
          DW      1413H       
          DW      2F3FH       

SHIFTB:   DW      0C2AH       
          DW      1790H       
          DW      05FBH       
          DW      2B09H       
          DW      0D2AH       
          DW      1516H       
          DW      1112H       
          DW      1413H       
          DW      5FC6H       

GRPHB:    DW      0CE9H       
          DW      1790H       
          DW      0568H       
          DW      8409H       
          DW      0DE9H       
          DW      1516H       
          DW      1112H       
          DW      1413H       
          DW      8B8FH       

GRPHS:    DW      0C6AH       
          DW      1790H       
          DW      196CH       
          DW      0FE09H      
          DW      0D89H       
          DW      1516H       
          DW      1112H       
          DW      1413H       
          DW      7B8AH       

CTKYTB:   DB      5BH         ;  [
          DB      5CH         ;  \
          DB      5DH         ;  ]
          DB      5EH         ;  ^
          DB      2FH         ;  /

;*-----------------------------------
;*  CRT message out
;*   05H,06H simulated
;*      ent. DE=msg top addr
;*           eof is NULL
;*           mode code 05h,06h
;*           CR is reset mode
;*-----------------------------------
CRTSIMU:  CALL    PUSHR 
CRTSI2:   LD      A,(DE)      ;get msg data
          INC     DE          ;next pointer
          OR      A           
          RET     Z           ;eof code is NULL
          LD      C,A         
          CP      05H         ;sft lock in
          JR      Z,CRTSIE    ;CTR.E
          CP      06H         ;normal mode
          JR      Z,CRTSIF    ;CTR.F
          SUB     'A'         
          CP      26          
          JR      NC,CRTSI4   ;skip not if code A-Z
CRTSFG:   LD      A,0         ;xxx
          OR      A           
          JR      Z,CRTSI4    
          LD      HL,SMLTBL-'A' ;sftlock code trans.
          LD      B,0         
          ADD     HL,BC       
          LD      C,(HL)      
CRTSI4:   LD      A,C         
          RST     18H         
          DB      .CRT1C      
          CP      0DH         
          JR      NZ,CRTSI2   
CRTSIF:   XOR     A           
CRTSIE:   LD      (CRTSFG+1),A 
          JR      CRTSI2      

;*----------------------------------------------------
;* Table of 'Sharp ASCII' codes for lower-case letters
;*----------------------------------------------------
SMLTBL:   DB      0A1H        ;a
          DB      09AH        ;b
          DB      09FH        ;c
          DB      09CH        ;d
          DB      092H        ;e
          DB      0AAH        ;f
          DB      097H        ;g
          DB      098H        ;h
          DB      0A6H        ;i
          DB      0AFH        ;j
          DB      0A9H        ;k
          DB      0B8H        ;l
          DB      0B3H        ;m
          DB      0B0H        ;n
          DB      0B7H        ;o
          DB      09EH        ;p
          DB      0A0H        ;q
          DB      09DH        ;r
          DB      0A4H        ;s
          DB      096H        ;t
          DB      0A5H        ;u
          DB      0ABH        ;v
          DB      0A3H        ;w
          DB      09BH        ;x
          DB      0BDH        ;y
          DB      0A2H        ;z

;*-------------------------
;* CRT and KB device tables
;*-------------------------
EQTBL:    
SCRT:     DW      SKB         ;address of next table in chain (SKB)
          DB      "CRT"       ;name of THIS table
          DB      0           
          DB      8AH         ;Stream, O1C, W
          DW      0           
          DW      CRTINI      
          DW      .RET        ;ROPEN
          DW      .RET        ;WOPEN
          DW      .RET        ;CLOSE
          DW      .RET        ;KILL
          DW      CRTIN       
          DW      CRTOUT      
          DW      CRTPOS      

SKB:      DW      SLPT        ;address of next table in chain (SLPT); 
          DB      "KB"        ;name of THIS table
          DW      0           
          DB      81H         ;Stream, R
          DW      0           
          DW      .RET        ;INIT
          DW      .RET        ;ROPEN
          DW      .RET        ;WOPEN
          DW      .RET        ;CLOSE
          DW      .RET        ;KILL
          DW      CRTIN       
          DW      .RET        
          DW      .RET        

CRTIN:    RST     18H         
          DB      .GETL       
          LD      A,80H       ;BREAKZ
          RET     C           
          RST     18H         
          DB      .COUNT      
          RET     

CRTOUT:   EX      AF,AF'      
          LD      HL,CRT1C    
          LD      A,(DISPX)   ;0=msg/1=msgx
          OR      A           
          JR      Z,CRTOU2    
          LD      HL,CRT1CX   
CRTOU2:   EX      AF,AF'      
          JP      (HL)        

CRTPOS:   LD      A,(CURX)    
          RET     

;*----------------------------------
;* CRT(LPT) routine
;*     CRT1C  H1C
;*     CRT1CX H1CX
;*     CRTMSG HMSG
;*            HCR
;*---------------------------------
HCR:      LD      A,0DH       
H1C:      PUSH    AF          
          LD      A,(FILOUT)  ;0=crt/1=lpt
          OR      A           
          JR      NZ,H1CL     
          POP     AF          
          JR      CRT1C       
H1CL:     POP     AF          
          JP      LPT1C       

H1CX:     PUSH    AF          
          LD      A,(FILOUT)  ;0=crt/1=lpt
          OR      A           
          JR      NZ,H1CXL    
          POP     AF          
          JR      CRT1CX      
H1CXL:    POP     AF          
          JP      LPT1CX      

HMSG:     CALL    PUSHR       
          LD      HL,H1C      
          JR      CRTMS2      

CRTMSG:   CALL    PUSHR       
          LD      HL,CRT1C    
CRTMS2:   LD      A,(DE)      
          OR      A           
          RET     Z           
          CALL    .HL         
          INC     DE          
          JR      CRTMS2      

CRT1S:    LD      A,20H       
CRT1C:    CALL    PUSHRA      
CRT1C0:   LD      C,A         
          LD      A,(INPFLG)  ;plot on/off
          OR      A           
          JR      Z,CRT1C9    ;skip if plot off
          LD      A,C         
          CP      20H         
          JR      NC,CRT1C4   ;skip if normal ascii
          LD      DE,(CURXY)  ;control code only
          LD      HL,(XS)     
          CP      14H         
          JR      Z,CRT1C1    ;skip if left code
          CP      12H         
          JR      NZ,CRT1C2   ;
          LD      HL,(YS)     ;skip if up code
          LD      E,D         
CRT1C1:   LD      A,L         
          CP      E           
          JP      NC,BEEPM    ;error range
CRT1C2:   LD      HL,PLTCOD   ;plotter code  trans.
          LD      B,0         
          ADD     HL,BC       
          LD      A,(HL)      
          INC     A           
          JR      Z,CRT1C9    ; no operation when ffh
          DEC     A           
          JP      Z,BEEPM     ;beep when null code
CRT1C4:   CALL    PLTOUT      
CRT1C9:   LD      A,C         
          CP      20H         
          JP      C,CTRLJB    ;control code trans.
          JP      ACCDI       ;1 byte disply ent.=acc

CRT1CX:   CALL    PUSHRA      
          LD      C,A         
          CP      0DH         
          JR      Z,CRT1C0    
          CALL    ACCDI       
          LD      A,(INPFLG)  ;plot on/off
          OR      A           
          RET     Z           
          LD      A,C         

;*       JR     PLTOTX          ;commented out in original module

PLTOTX:   CP      11H         
          JR      C,PLT2E     
          CP      17H         
          JR      C,PLTOK     
          CP      20H         
          JR      C,PLT2E     
PLTOUT:   CP      60H         
          JR      C,PLTOK     
          CP      70H         
          JR      C,PLT2E     
          CP      0C1H        
          JR      C,PLTOK     
          CALL    CHKACC      
          DB      3           
          DW      0CFD7H      
          DB      0FFH        
          JR      Z,PLTOK     
PLT2E:    LD      A,2EH       
PLTOK:    JP      LPTOUT      

PLTCOD:   DB      0           ;00
          DB      0           ;01
          DB      0           ;02
          DB      0           ;03
          DB      0FFH        ;04 CTR.D
          DB      0FFH        ;05 CTR.E
          DB      0FFH        ;06 CTR.F
          DB      1DH         ;07
          DB      0           ;08
          DB      0FFH        ;09 CTAB
          DB      0           ;0A
          DB      0           ;0B
          DB      0           ;0C
          DB      0DH         ;0D
          DB      0           ;0E
          DB      0           ;0F
          DB      0           ;10 DEL
          DB      0AH         ;11 DOWN
          DB      03H         ;12 UP
          DB      20H         ;13 RIGHT
          DB      0EH         ;14 LEFT
          DB      0           ;15 HOME
          DB      0           ;16 CLR
          DB      0FFH        ;17 GRAPH
          DB      0           ;18 INST
          DB      0FFH        ;19 ALPHA
          DB      0FFH        ;1A KANA
          DB      0DH         ;1B
          DB      0FFH        ;1C hirakana
          DB      0           ;1D
          DB      0           ;1E
          DB      0           ;1F

;*-------------------
;*  Monitor hot start
;*-------------------
STARTP:   DI      
          XOR     A           
          OUT     (LSDMD),A   ;mz-800 320*200 4col
          LD      (INPFLG),A  ;plot on/off
          LD      (FILOUT),A  ;0=crt/1=lpt
          LD      SP,0000H    ;stack pointer set
          IM      2           ;interruptt mode 2
          LD      A,4         
          OUT     (LSD3),A    ;8253 int disable
          OUT     (LSE0),A    ;bank dram
          OUT     (LSE1),A    ;bank dram
          CALL    PALOFF      ;palette all off
          LD      A,0FH       ;interrupt vector
          LD      I,A         
          LD      A,0FEH      ;interrupt addrs
          OUT     (0FDH),A    ;PIO int vector set
          LD      A,0FH       
          OUT     (0FDH),A    ;PIO mode 0
          PUSH    BC          
          CALL    CRTPWR      ;CRT power on init
          CALL    PSGPWR      ;PSG power on init
          CALL    EMMPWR      ;EMM power on init
          POP     BC          
STRTP2:   DB      21H         ;dummy byte
          JR      STRTP9      
          XOR     A           
          LD      (STRTP2),A  
          LD      D,A         
          LD      E,A         
          RST     18H         
          DB      .TIMST      
          LD      DE,SCMT     
          LD      A,B         
          OR      A           
          JR      Z,STRTP4    
          DEC     A           
          JR      Z,STRTP4    
          LD      DE,SFD      
          DEC     A           
          JR      Z,STRTP4    
          LD      DE,SQD      
STRTP4:   LD      A,C         
          RST     18H         
          DB      .SETDF      
STRTP9:   JP      COLDST      

;*---------------------
;*  check vram option ?
;*---------------------
CRTPWR:   DI      
          XOR     A           
          OUT     (LSDMD),A   ;320*200 4 color
          LD      A,14H       
          OUT     (LSRF),A    
          LD      A,94H       
          OUT     (LSWF),A    
          IN      A,(LSE0)    
          OUT     (LSE0),A    ;cg off
          LD      HL,9FFFH    
          LD      A,(HL)      ;read
          LD      C,A         
          CPL     
          LD      (HL),A      ;write
          CP      (HL)        ;verify
          LD      (HL),C      ;pop mem
          LD      A,0         
          JR      NZ,CRTPW0   
          INC     A           
CRTPW0:   LD      (MEMOP),A   
          IN      A,(LSE1)    
          EI      
          LD      A,1         ;window (0,24)
          CALL    DSMODE      ;320*200 4 color
;*--------------------
;* data free area init
;*--------------------
          XOR     A           
          LD      (CURFLG),A  ;cursor off
          LD      (CURMAK),A  ;nomal char
          RET     

;*------------------------------
;* MZ-2Z009    USR I/O driver
;* FI:MON-USR  ver 1.0A 03.17.84
;*------------------------------
SUSR:     DW      0           ;last table in chain so no address here 
          DB      "USR"       ;name of THIS table
          DB      0           
          DB      9FH         ;STRM, FNM, W1C, R1C, W, R
          DW      0           
          DW      .RET        ;INIT
          DW      USRRO       ;ROPEN
          DW      USRWO       ;WOPEN
          DW      .RET        ;CLOSE
          DW      .RET        ;KILL
          DW      USRIN       ;INP
          DW      USROUT      ;OUT
          DW      .RET        ;POS

USRRO:    
USRWO:    LD      HL,ELMD1    
          RST     18H         
          DB      .DEASC      
          LD      A,D         
          OR      E           
          JP      Z,ER60M     
          LD      (ZWRK1),DE  
          RET     

USRIN:    
USROUT:   LD      HL,(ZWRK1)  
          JP      (HL)        
          DB      0,0,0,0,0,0,0,0,0,0 ;was DEFS  69
          DB      0,0,0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0,0 

;*       END of original module MON1.ASM
;*===========================================================================        
;*     START of original module MON2.ASM   
;*--------------------------
;* MZ-800 monitor Work area
;* FI:MON2  ver 1.0A 9.05.84
;*--------------------------
;*-------------------
;*  Interrupt vectors
;*-------------------
          ORG     0FF0H       ;kept to ensure match with existing versions
          DB      0,0,0,0,0,0,0,0 ;was DEFS 12
          DB      0,0,0,0     

          ORG     0FFCH       ;kept to ensure match with existing versions
          DW      PSGINT      ;PSG (MUSIC) interrupt
          DW      LPTINT      ;Printer interrupt

;*--------------------------------
;* Directory entry (1000H - 103FH)
;*--------------------------------
          ORG     1000H       ;kept to ensure match with existing versions
ELMD:     DB      0           ;file mode (was DEFS 1)
ELMD1:    DB      0,0,0,0,0,0,0,0 ;file name (was DEFS 17)
          DB      0,0,0,0,0,0,0,0 
          DB      0           
ELMD18:   DB      0,0         ;protection, type (was DEFS 2)
ELMD20:   DB      0,0         ;size (was DEFS 2)
ELMD22:   DB      0,0         ;adrs (was DEFS 2)
ELMD24:   DB      0,0         ;exec (was DEFS 2)
ELMD26:   DB      0,0,0,0     ;(was DEFS 4)
ELMD30:   DB      0,0         ;(was DEFS 2)
ELMD32:   DB      0,0,0,0,0,0,0,0 ;(was DEFS 32)
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 


;*----------------
;*  LU table entry
;*----------------
ZTOP:     DW      2           ;LU block top
ZLOG:     DB      0           ;LU#
ZRWX:     DB      0           ;1:R, 2:W, 3:X
ZEQT:     DW      0           ;Address of EQTBL
ZCH:      DB      0           ;CH#
ZEOF:     DB      0           ;EOF?
ZWRK1:    DB      0           ;Work 1
ZWRK2:    DB      0           ;Work 2

;*----------------
;* EQT table entry
;*----------------
ZNXT:     DW      0           ;STRM  SQR    RND
ZDEVNM:   DB      0,0,0,0     ;device name 
ZFLAG1:   DB      1           ;flag 1
ZFLAG2:   DB      0           ;flag 2
ZDIRMX:   DB      0           ;max DIR
ZINIT:    DW      0           ;initialise

ZRO:      
ZMAPS:    DW      0           ;ROPEN RDINF Map.start

ZWO:      
ZMAPB:    DW      0           ;WOPEN WRFIL Map.bytes

ZCL:      
ZSTRT:    
ZDIRS:    DW      0           ;CLOSE START Dir.start

ZKL:      
ZBLK:     DW      0           ;KILL  - Block/Byte -

ZINP:     DW      0           ;INP   RDDAT BREAD
ZOUT:     DW      0           ;OUT   WRDAT BWRIT

ZPOS:     
ZDELT:    DW      0           ;Posn. DELETE

ZWDIR:    DW      0           ;    WR DIR
ZFREE:    DW      0           ;      - free bytes -

ZBYTES:   EQU     ZFREE+2-ZNXT ;Z-area bytes

          DB      0,0         ;(was DEFS 2)

DCHAN:    DB      0           ;default channel (was DEFS 1)
DDEV:     DB      0,0         ;default device (was DEFS 2)

DSCRT:    DW      SCRT        
DSLPT:    DW      SLPT        

;*------------------------------------
;*  Work area pointers (1070H - 1081H)
;*------------------------------------
TEXTST:   DB      0,0         ;Text start (was DEFS 2)

TEXTED:   
POOL:     DB      0,0         ;I/O work (was DEFS 2)

POOLED:   
VARST:    DB      0,0         ;Variable start (was DEFS 2)

STRST:    DB      0,0         ;String start (was DEFS 2)
VARED:    DB      0,0         ;Var & String end (was DEFS 2)
TMPEND:   DB      0,0         ;Temp end (was DEFS 2)
INTFAC:   DB      0,0         ;Init FAC (was DEFS 2)
MEMLMT:   DB      0,0         ;LIMIT (was DEFS 2)
MEMMAX:   DW      0FF00H      ;highest available MEM

;*-----------------------------------------
;*    cursor / position work (1082H - 108DH
;*-----------------------------------------
CURXY:    
CURX:     DB      0           ;cursor position
CURY:     DB      0           

POSADR:   DW      2000H       ;Textbuff addr.
BITADR:   DW      8000H       ;Bitmap addr.
POINTX:   DB      0,0         ;X co-ord (was DEFS 2)
POINTY:   DB      0,0         ;Y co-ord (was DEFS 2)
CURFLG:   DB      0           ;0=OFF 1=ON
CURMAK:   DB      0           ;0=normal 1=shftlock 2=graph

;*-----------------------------
;* CRT/LPT work (108EH - 1097H)
;*-----------------------------
CMTMSG:   DB      0           ;if =0 disp cmt-msg (was DEFS 1)
INPFLG:   DB      0           ;0=plot off 1=plot on
DISPX:    DB      0           ;0=MSG 1=MSGX (was DEFS 1)
FILOUT:   DB      0           ;0=CRT 1=LPT
PSEL:     DB      1           ;Printer select
PCRLF:    DB      0DH         ;LPT CRLF CODE
LPT.TM:   DB      14          ;LPT wait time
LPOSB:    DB      0           ;LPT posn.
PSMAL:    DB      0           ;LPT sml/cap
PNMODE:   DB      1           ;LPT mode  1..text, 2..graph

;*----------------------------------
;*  crt dispmode work (1098H -109FH)
;*----------------------------------
DMD:      DB      0           ;disp mode 0=320 4  col   4=640 2  col
;*                              ;          2=320 16 col   6=640 4  col
MEMOP:    DB      0           ;option mem exit 0= off 1= on
PWMODE:   DB      0           ;graph mode
CMODE:    DB      3           ;colour mode
CPLANE:   DB      3           ;current active plane
MAXCF:    DB      4           ;max plane data
PMASK:    DB      0FFH        ;mask plane data
GMODE:    DB      3           ;graphic colour mode

;*-----------------------------------
;* Monitor stack area (10A0H - 10EFH)
;*-----------------------------------
          DB      0,0,0,0,0,0,0,0 ;(was DEFS 80)
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 

;*------------------------------
;* CMT work area (10F0H - 116FH)
;*------------------------------

IBUFE:    DB      0,0,0,0,0,0,0,0 ;(was DEFS 128)
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 

;*----------------------------------------
;* MZ-700-compatible flags (1170H - 1191H)
;*----------------------------------------
          DB      0,0,0,0,0,0,0,0 ;(was DEFS 34)
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0         

;*------------------------------------
;* General Basic flags (1192H - 11A3H)
;*------------------------------------
          DB      0EFH        ;FLSDT (current character at cursor)
          DB      0,0         ;STRFG, DPRNT (was DEFS 2)
TMCNT:    DB      0,0         ;was DEFS 2
SUMDT:    DB      0,0         ;SUMDT (was DEFS 2)
CSMDT:    DB      0,0         ;CSMDT (was DEFS 2)
          DB      0,0         ;AMPM, TIMFG (was DEFS 2)
          DB      1           ;SWRK
TEMPW:    DB      4           ;TEMPW
          DB      5           ;ONTYO
          DB      0,0,0       ;OCTV, RATIO (was DEFS 3)
KEYBM1:   DB      0           ;(was DEFS 1)

;*--------------------------------------------------
;* Keyboard Input and General Buffer (11A4H - 12A9H)
;*--------------------------------------------------
KEYBUF:   DB      0,0,0,0,0,0,0,0 ;(was DEFS 262)
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0 

KEY262:   DB      0,0         ;(was DEFS 2)
KEY264:   DB      0,0         ;(was DEFS 2)
KEY266:   DB      0,0,0,0     ;(was DEFS 4)

FUNBUF:   DB      7           
FNB1S:    DB      "RUN   "    
          DB      0DH         
FNB1E:    DB      0,0,0,0,0,0,0,0 ;(was DEFS   8)
          DB      5           
FNB2S:    DB      "LIST "     
FNB2E:    DB      0,0,0,0,0,0,0,0,0,0 ;(was DEFS   10)
          DB      5           
FNB3S:    DB      "AUTO "     
FNB3E:    DB      0,0,0,0,0,0,0,0,0,0 ;(was DEFS   10)
          DB      6           
FNB4S:    DB      "RENUM "    
FNB4E:    DB      0,0,0,0,0,0,0,0,0 ;(was DEFS   9)
          DB      6           ;QD FD ->"DIR"
FNB5S:    DB      "COLOR "    
FNB5E:    DB      0,0,0,0,0,0,0,0,0 ;(was DEFS   9)
          DB      5           
FNB6S:    DB      "CHR$("     
FNB6E:    DB      0,0,0,0,0,0,0,0,0,0 ;(was DEFS   10)
          DB      8           
FNB7S:    DB      "DEF KEY("  
FNB7E:    DB      0,0,0,0,0,0,0 ;(was DEFS   7)
          DB      4           
FNB8S:    DB      "CONT"      
FNB8E:    DB      0,0,0,0,0,0,0,0,0,0,0 ;(was DEFS   11)
          DB      6           
FNB9S:    DB      "SAVE  "    
FNB9E:    DB      0,0,0,0,0,0,0,0,0 ;(was DEFS   9)
          DB      6           
FNB10S:   DB      "LOAD  "    
FNB10E:   DB      0,0,0,0,0,0,0,0,0 ;(was DEFS   9)
INBUFC:   DB      0           ;INBUF counter
INBUFL:   DB      0           ;INBUF length
INBUF:    DB      0,0,0,0,0,0,0,0 ;DEF KEY buffer (was DEFS 16)
          DB      0,0,0,0,0,0,0,0 
LINLIM:   DB      255         ;getline buffer limit
KEYDAT:   DB      0           

;*--------------
;*    timer work
;*---------------
AMPM:     DB      0           
SECD:     DW      0           

;*---------------
;*    scroll work
;*---------------
XS:       DB      0           ;console X start const=0
XE:       DB      39          ;console X end
CWIDTH:   DW      40          ;console width (cwidth=xe+1)
CSIZE:    DW      320         ;csize=cwidth*8
YS:       DB      0           ;console Y start
YE:       DB      24          ;console Y end
YW:       DB      25          ;console Y width (yw=ye-ys+1)

;*----------------------
;*    scroll custom data
;*----------------------
SOF:      DW      0           ;scroll offset
SW:       DB      7DH         ;scroll width (sw  = yw*5)
SSA:      DB      0           ;scroll start (ssa = ys*5)
SEA:      DB      7DH         ;scroll end (sea =(ye+1)*5)
SSW:      DW      3E8H        ;scroll offset lilmit (ssw = sw*8)

;*---------------------
;*     crt work (Basic)
;*---------------------
CRTMD1:   DB      1           ;crt bit data
CRTMD2:   DB      1           ;crt mode no.
SELCOL:   DB      3           ;default colour
PAIWED:   DW      0           ;paint stack end

;*-----------------
;*     palette work
;*-----------------
PALBK:    DB      0           ;palette block no.
PALAD:    DW      PAL4T       ;palette init addr.
PALTBL:   DB      0,0,0,0     ;pallette data table (was DEFS 4)

;*----------------------------
;*     palette init data table
;*----------------------------
PAL2T:    DB      00H         ;PAL 0 black
          DB      1FH         ;PAL 1 white
          DB      2FH         ;PAL 2 white
          DB      3FH         ;PAL 3 white
;*
PAL4T:    DB      00H         ;PAL 0 black
          DB      11H         ;PAL 1 blue
          DB      22H         ;PAL 2 red
          DB      3FH         ;PAL 3 white
;*
PAL16T:   DB      00H         ;PAL 0 black
          DB      11H         ;PAL 1 blue
          DB      22H         ;PAL 2 red
          DB      33H         ;PAL 3 purple

;*----------------------------
;*     cursor  init data table
;*----------------------------
CURDT1:   DB      0FFH        ;0 NORMAL cursor
          DB      0FFH        ;1
          DB      0FFH        ;2
          DB      0FFH        ;3
          DB      0FFH        ;4
          DB      0FFH        ;5
          DB      0FFH        ;6
          DB      0FFH        ;7
;*
CURDT2:   DB      7EH         ;0 SHIFTLOCK cursor
          DB      0FFH        ;1
          DB      0FFH        ;2
          DB      0FFH        ;3
          DB      0FFH        ;4
          DB      0FFH        ;5
          DB      0FFH        ;6
          DB      7EH         ;7
;*
CURDT3:   DB      00H         ;0 GRAPH cursor
          DB      00H         ;1
          DB      00H         ;2
          DB      00H         ;3
          DB      00H         ;4
          DB      00H         ;5
          DB      00H         ;6
          DB      0FFH        ;7

;*---------------------------
;*   screen management buffer
;*---------------------------
SCRNT0:   DB      0,0,0,0,0,0,0,0 ;(was DEFS 25)
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0           
SCRNTE:   DB      0           

;*------------------
;*  emm (E-RAM) work
;*------------------
EMFLG:    DB      0           ;(was DEFS 1)
EMPTR:    DB      0,0         ;(was DEFS 2)
EMWP0:    DB      0,0         ;(was DEFS 2)
EMWP1:    DB      0,0         ;(was DEFS 2)

;*----------
;*  lpt work
;*----------
WPULSE:   DB      0           
WSTROB:   DB      0           
PBCMAW:   DW      3FF0H       
PBCN:     DW      0           ;
PBCIP:    DW      0C000H      ;FIFO inp pointer
PBCOP:    DW      0C000H      ;FIFO out pointer
PBCTOP:   DW      0C000H      ;buffer top
SPLFLG:   DB      0           ;spool on/stop/off
OUTIMF:   DB      0           ;output image flag
HPCOUN:   DB      4           ;printer counter
HERRF:    DB      0           ;ROM error flag

;*--------------------------------
;*  code translation table
;* 'Sharp ASCII' <> Standard ASCII
;*--------------------------------

CTABLE:   DW      CTABL1      ;table address
CTABL1:   DB      39          ;number in table
          DB      023H        ;#
          DB      023H        
          DB      040H        ;@
          DB      040H        
          DB      05BH        ;[
          DB      05BH        
          DB      05CH        ;\
          DB      05CH        
          DB      05DH        ;]
          DB      05DH        
          DB      08BH        ;^
          DB      05EH        
          DB      090H        ;under_
          DB      05FH        
          DB      093H        ;'
          DB      060H        
          DB      0A1H        ;a
          DB      061H        
          DB      09AH        ;b
          DB      062H        
          DB      09FH        ;c
          DB      063H        
          DB      09CH        ;d
          DB      064H        
          DB      092H        ;e
          DB      065H        
          DB      0AAH        ;f
          DB      066H        
          DB      097H        ;g
          DB      067H        
          DB      098H        ;h
          DB      068H        
          DB      0A6H        ;i
          DB      069H        
          DB      0AFH        ;j
          DB      06AH        
          DB      0A9H        ;k
          DB      06BH        
          DB      0B8H        ;l
          DB      6CH         
          DB      0B3H        ;m
          DB      6DH         
          DB      0B0H        ;n
          DB      6EH         
          DB      0B7H        ;o
          DB      6FH         
          DB      09EH        ;p
          DB      70H         
          DB      0A0H        ;q
          DB      71H         
          DB      09DH        ;r
          DB      72H         
          DB      0A4H        ;s
          DB      73H         
          DB      096H        ;t
          DB      74H         
          DB      0A5H        ;u
          DB      75H         
          DB      0ABH        ;v
          DB      76H         
          DB      0A3H        ;w
          DB      77H         
          DB      09BH        ;x
          DB      78H         
          DB      0BDH        ;y
          DB      79H         
          DB      0A2H        ;z
          DB      7AH         
          DB      0BEH        ;{
          DB      7BH         
          DB      0C0H        ;|
          DB      7CH         
          DB      080H        ;}
          DB      7DH         
          DB      094H        ;~
          DB      7EH         
          DB      07FH        ;
          DB      7FH         

;*         END of original module MON2.ASM
;*============================================================================
;*       START of original module MON3.ASM

;*---------------------------------
;*   XMON-ROM   8.30.84
;*   JISX   MZ-800 --> ASC
;*    ent A     :data
;*        IX    :output sub
;*        (HL)  :tab counter
;*        E     :DISPX
;*---------------------------------

JISX:     CP      0DH         
          JR      Z,JISXCR    
          CP      0AH         
          JR      Z,JISXCR    
          CALL    AJISX       ;code change
          CP      20H         
          JR      NC,JPIX     
          BIT     0,E         ;print/p ?
          JR      Z,JPIX      ;no
          LD      A,20H       
JPIX:     JP      (IX)        

JISXCR:   CALL    JPIX        
          LD      (HL),0      
          RET     

AJISX:    PUSH    BC          
          LD      C,0         
          CALL    AJISX1      
          POP     BC          
          RET     

AJISX1:   CALL    PUSHR       
          LD      HL,(CTABLE) 
          LD      B,(HL)      ;code counter set
          INC     HL          ;HL=MZ-800
          LD      D,H         ;DE=JIS
          LD      E,L         
          INC     DE          
          BIT     0,C         ;MZ-800 --> JIS ?
          JR      Z,AJISX2    ;yes
          EX      DE,HL       
AJISX2:   CP      (HL)        
          JR      Z,AJISX3    ;code match
          INC     HL          
          INC     HL          
          INC     DE          
          INC     DE          
          DJNZ    AJISX2      
          RET     

AJISX3:   LD      A,(DE)      
          RET     

;*---------------------------------
;*  JISR   ASC    --> MZ-800
;*    ent (A)   :data
;*        IX    :input  sub
;*---------------------------------
JISR:     CALL    JPIX        ;input sub :A set
          RET     C           
          PUSH    BC          
          LD      C,1         
          CALL    AJISX1      
          POP     BC          
          OR      A           
          RET     

;*-----------------
;* LPT device table
;*-----------------
SLPT:     DW      SCMT        ;address of next table in chain (SCMT)
          DB      "LPT"       ;name of THIS table
          DB      0           
          DB      8AH         ;Stream, O1C, W
          DW      0           
          DW      LPTINI      
          DW      ER59M       ;ROPEN
          DW      .RET        ;WOPEN
          DW      .RET        ;CLOSE
          DW      .RET        ;KILL
          DW      0           ;INP
          DW      LPT1CQ      
          DW      LPTPOS      

;*PIO.AC: EQU    0FCH            ;Port-A control LABEL NOT USED
;*PIO.AD: EQU    0FEH            ;Port-A data        ditto
;*PIO.BC: EQU    0FDH            ;Port-B control     ditto
;*PIO.BD: EQU    0FFH            ;Port-B data        ditto

P.PLT:    EQU     0           ;1P01, 1P09
P.KP5:    EQU     1           ;KP5
P.JIS:    EQU     2           ;JIS code
P.THRU:   EQU     3           ;thrue

LPTPOS:   LD      A,(INPFLG)  
          OR      A           
          LD      A,(LPOSB)   
          RET     Z           
          LD      A,(CURX)    
          RET     

;*---------------------------
;*  PL ROM CALLS (MZ-800 ROM)
;*---------------------------
ROMST:    EQU     03H         ;F403H
ROMST1:   EQU     0F400H      

TIMST:    CALL    ROMJP2      
          DB      ROMST       

TIMRD:    CALL    ROMJP2      
          DB      ROMST+3     

STICK:    CALL    ROMJP2      
          DB      ROMST+6     

STRIG:    CALL    ROMJP2      
          DB      ROMST+9     

HCPY:     CALL    ROMJP       
          DB      ROMST+12    

LPT1CQ:   LD      HL,DISPX    
          BIT     0,(HL)      
          JR      NZ,LPT1CX   

LPT1C:    PUSH    IY          
          EX      AF,AF'      
          LD      A,3+15      ;F003+15
          LD      (APL1CD),A  
          LD      A,.CRT1C    
APL1CF:   LD      (APL1CE),A  
          EX      AF,AF'      
          CALL    APL1C       
          POP     IY          
          PUSH    BC          
          LD      B,A         
          LD      A,(INPFLG)  
          OR      A           
          LD      A,B         
          POP     BC          
          RET     Z           
          RST     18H         
APL1CE:   DB      .CRT1C      
          RET     

APL1C:    LD      IY,JISX     
          CALL    ROMJP       

APL1CD:   DB      ROMST+15    
LPT1CX:   PUSH    IY          
          EX      AF,AF'      
          LD      A,3+18      ;F003+18
          LD      (APL1CD),A  
          LD      A,.CRT1X    ;was LD A, .CRT1CX (a mistake !)
          JR      APL1CF      

LPTINI:   CALL    ROMJP       
          DB      ROMST+21    

LPTOUT:   CALL    ROMJP       
          DB      ROMST+24    

PBCCLR:   CALL    ROMJP       
          DB      ROMST+27    

SPLOFF:   CALL    ROMJP       
          DB      ROMST+30    

SPLON:    CALL    ROMJP       
          DB      ROMST+33    

SPLSW:    CALL    ROMJP       
          DB      ROMST+36    

LPTM02:   CALL    ROMJP       
          DB      ROMST+39    

;*---------------------
;* ROM-calling routines
;*---------------------
ROMJP:    EX      AF,AF'      
          LD      A,(PSEL)    
          BIT     P.KP5,A     
          JR      Z,ROMJP1    

          PUSH    BC          
          LD      B,3         
          RST     18H         
          DB      .MCTRL      
          POP     BC          

ROMJP1:   EX      AF,AF'      
ROMJP2:   EX      AF,AF'      
          XOR     A           
          LD      (KEY266),HL 
          LD      (HERRF),A   
          EX      AF,AF'      
          DI      
          LD      (KEY264),SP 
          EX      (SP),HL     ;HL=call stored address
          LD      SP,HL       ;
          POP     HL          ;HL=call address
          OUT     (LSE3),A    
          LD      SP,KEY262   
          CALL    HLJP        
          OUT     (LSE1),A    
          LD      SP,(KEY264) 
          EX      (SP),HL     
          INC     SP          
          INC     SP          
          EI      
          EX      AF,AF'      
          LD      A,(HERRF)   
          OR      A           
          JR      NZ,ROMERR   
          EX      AF,AF'      
          RET     

HLJP:     LD      H,0F4H      ;HL=F4??H
          JP      (HL)        

ROMERR:   LD      B,A         ;B=0
          EX      AF,AF'      
          DEC     B           ;B=1
          JP      Z,BREAKZ    
          DEC     B           ;B=2
          JP      NZ,ERRORJ   
ROMER1:   LD      HL,(PBCN)   ;INIT M2
          LD      A,H         
          OR      L           
          JR      Z,LPTM02    
          CALL    SPLON       
          RST     18H         
          DB      .BREAK      
          JP      Z,BREAKZ    
          JR      ROMER1      

LPTINT:   DI      
          PUSH    AF          
          PUSH    HL          
          PUSH    BC          
          LD      (WKLINT),SP 
          LD      SP,WKLINT   
          OUT     (LSE3),A    
          CALL    ROMST1      ;F400H
          OUT     (LSE1),A    
          LD      SP,(WKLINT) 
          POP     BC          
          POP     HL          
          POP     AF          
          EI      
          RETI    

          DB      0,0,0,0,0,0,0,0 ;(was DEFS 8)

WKLINT:   DW      0           

;*----------------------------
;* MZ-800     Monitor command
;* FI:MONOP   ver 1.0A 8.04.84
;*----------------------------
MONOP:    PUSH    HL          
          LD      DE,(ERRORP) 
          PUSH    DE          
          LD      DE,MONERR   
          LD      (ERRORP),DE ;error ret adr set
          LD      A,(LINLIM)  
          PUSH    AF          
          LD      A,100       ;getline max set
          LD      (LINLIM),A  
          LD      (MONSP+1),SP ;stack pointer push
          XOR     A           
          LD      (FILOUT),A  ;crt mode
MONCLD:   LD      SP,0000H    ;stack initize
MONHOT:   LD      BC,MONHOT   
          PUSH    BC          ;last return addrs set
          RST     18H         ;linefeed & cr
          DB      .CR2        
          LD      A,'*'       ;prompt disp
          RST     18H         
          DB      .CRT1C      
MONEDQ:   CALL    MONEDT      ;memory correction ?
          JR      NC,MONEDQ   
          LD      A,(DE)      
          CP      '*'         
          RET     NZ          ;prompt check
          INC     DE          
          LD      A,(DE)      ;acc=next interpret data
          INC     DE          ;next interpret data addr
;*---------------------------
;* monitor commands handler
;*---------------------------
          EXX                 ;parameter push
          LD      HL,MNCMTB   
          LD      B,10        ;commands counter
MNCMCP:   CP      (HL)        
          INC     HL          
          JR      Z,MNCMOK    ;skip if just command
          INC     HL          ;next search
          INC     HL          
          DJNZ    MNCMCP      
          EXX     
          RET     

MONERR:   LD      C,A         
          AND     7FH         
          JR      Z,MONCLD    ;Break
          LD      A,C         ;acc=errcode
          RST     18H         ;display error messege
          DB      .ERRX       
          RST     18H         ;error recover fd/qd
          DB      .ERCVR      
          JR      MONCLD      

MNCMOK:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          PUSH    DE          ;command addr set
          EXX                 ;parameter pop
          RET     

;*------------------------------------
;* table of monitor commands/addresses
;*------------------------------------
MNCMTB:   DB      'D'         
          DW      MONDMP      
          DB      'M'         
          DW      MONSET      
          DB      'P'         
          DW      MONPRT      
          DB      'G'         
          DW      MONGOT      
          DB      'F'         
          DW      MONSCH      
          DB      'R'         
          DW      MONSP       
          DB      'S'         
          DW      MONSAV      
          DB      'L'         
          DW      MONLOD      
          DB      'V'         
          DW      MONVRY      
          DB      'T'         
          DW      MONTRN      

;*---------------------------------
;* monitor P(rint) command (toggle)
;*---------------------------------
MONPRT:   LD      A,(FILOUT)  ;lpt/crt
          XOR     1           
          LD      (FILOUT),A  
          RET     

;*-----------------------
;* monitor S(ave) command
;*-----------------------
MONSAV:   CALL    SAVTRN      ;set addrs
          RET     C           
          EXX     
          CALL    FNMST       ;file name set
          EXX     
          LD      (ELMD20),BC ;bytes
          LD      (ELMD22),DE ;data adrs
          LD      (ELMD24),HL ;exec adrs
          RST     18H         ;save file
          DB      .SAVEF      
          RET     

;*-----------------------
;* monitor L(oad) command
;*-----------------------
MONLOD:   CALL    HLSET       ;load addr set
          PUSH    HL          ;hl=load addrs
          PUSH    AF          
          CALL    LOAVRY      ;filename set & open
          POP     AF          
          POP     HL          
          JR      NC,MONLD2   ;user load addr set ??
          LD      HL,(ELMD22) 
MONLD2:   RST     18H         ;load file
          DB      .LOADF      
          RET     

;*--------------------
;* filename set & open
;*--------------------
LOAVRY:   CALL    FNMST       ;file name set
          RST     18H         
          DB      .LOPEN      ;ROPEN
          CP      1           
          RET     Z           
          JP      ER61M       ;File mode error

;*-------------------------
;* monitor V(erify) command
;*-------------------------
MONVRY:   CALL    LOAVRY      ;filename set
          LD      HL,(ELMD22) 
          RST     18H         ;file verify
          DB      .VRFYF      
          RET     

;*-------------------------
;* monitor R(eturn) command
;*        (to BASIC)
;*-------------------------
MONSP:    LD      SP,0000H    
          POP     AF          
          LD      (LINLIM),A  
          POP     HL          
          LD      (ERRORP),HL 
          POP     HL          
          RET     

;*----------------------
;*     monitor operation
;*----------------------
MONEDT:   LD      DE,0FF00H   ;monitor work
          RST     18H         
          DB      .GETL       
          JR      C,MONEDE    
;*------------------
;*    check ':xxxx='
;*------------------
          LD      A,(DE)      
          CP      ':'         ;mem correct ??
          SCF     
          RET     NZ          
          INC     DE          
          CALL    HLSET       ;addrs input ?
          RET     C           
          LD      A,(DE)      
          INC     DE          
          XOR     3DH         ;'='
          RET     NZ          
NEXTAC:   CALL    ACSET       ;data read
          CCF     
          RET     NC          
          LD      (HL),A      ;mem correction !
          INC     HL          ;next pointer
          JR      NEXTAC      

MONEDE:   LD      (DE),A      ;error
          RET     

;*----------------------------------
;*    4 ascii to binary (word)
;*        ent. de=ascii data pointer
;*        ext  hl=xxxxH
;*----------------------------------
HLSET:    PUSH    HL          
          CALL    SPCTAC      ;separater search
          PUSH    DE          
          CALL    ACSETH      ;2 ascii to binary
          JR      C,HLSETE    
          LD      H,A         
          CALL    ACSETH      ;2 ascii to binary
          JR      C,HLSETE    
          LD      L,A         
          POP     AF          
          POP     AF          
          XOR     A           
          RET     

HLSETE:   POP     DE          
          POP     HL          
          SCF     
          RET     

;*----------------
;*    space search
;*----------------
SPCTA2:   INC     DE          
SPCTAC:   LD      A,(DE)      
          CP      20H         
          JR      Z,SPCTA2    
          RET     

;*---------------------------------
;*    1 ascii to binary (nible)
;*
;*        ent. de=ascii data pointer
;*        ext  acc= 0xH
;*---------------------------------
ACSETS:   LD      A,(DE)      
          RST     18H         ;0-9 a-f check
          DB      .CKHEX      
          INC     DE          ;set pointer to next
          RET     

;*---------------------------------
;*    2 ascii to  binary (byte)
;*        ent. de=ascii data pointer
;*        ext  acc= xxH
;*---------------------------------
ACSET:    CALL    SPCTAC      ;skip spaces
          CP      ';'         
          JR      Z,SEMIOK    ;skip if ascii input
ACSETH:   PUSH    BC          
          PUSH    DE          
          CALL    ACSETS      ;1 ascii to binary(nible)
          JR      C,ACSTER    
          LD      C,A         ;high nible
          CALL    ACSETS      ;1 ascii to binary(nible)
          JR      C,ACSTER    
          LD      B,A         ;low nible
          LD      A,C         
          RLCA    
          RLCA    
          RLCA    
          RLCA    
          ADD     A,B         
          LD      C,A         
          LD      A,C         
          POP     BC          
          POP     BC          
          OR      A           
          RET     

ACSTER:   POP     DE          
          POP     BC          
          SCF     
          RET     

;*--------------------------
;*    ascii  code input mode
;*--------------------------
SEMIOK:   INC     DE          
          LD      A,(DE)      
          INC     DE          
          OR      A           ;∆∆JR ACSETO
          RET                 ;∆∆

;*------------------------------------------------------
;* Top of p.123 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
;*-----------------------
;* Monitor G(oto) Command
;*-----------------------
MONGOT:   CALL    HLSET       
          RET     C           
          JP      (HL)        

;*-----------------------
;* Monitor D(ump) command
;*-----------------------
MONDMP:   CALL    HLSET       ;top addrs set
          JR      C,MONDP1    ;skip if 'd' only
          PUSH    HL          
          CALL    HLSET       ;end addrs set
          JR      C,MONDP2    ;skip if top addrs only
          POP     DE          
          EX      DE,HL       
          JR      MONDP3      

MONDP2:   POP     HL          ;
MONDP1:   EX      DE,HL       
          LD      HL,80H      
          ADD     HL,DE       ;last addrs calc
          EX      DE,HL       
MONDP3:   LD      C,8         ;counter set
          CALL    MONDPS      ;dump list disp
          RET     C           
          PUSH    HL          
          SBC     HL,DE       ;dump end calc
          POP     HL          
          RET     NC          
          JR      MONDP3      

MONDPS:   CALL    HLHXPR      ;addrs disp
          LD      B,C         
          PUSH    HL          
MONDP4:   LD      A,(HL)      ;data read
          CALL    ACHXPR      ;1 byte disp
          INC     HL          
          LD      A,20H       ;space disp
          RST     18H         
          DB      DH1C        
          DJNZ    MONDP4      
          POP     HL          
          LD      A,'/'       ;separator disp
          RST     18H         
          DB      DH1C        
          LD      B,C         
MONDP5:   LD      A,(HL)      ;data read
          CP      20H         ;control code ?
          JR      NC,MONDP6   
          LD      A,'.'       ;yes, control code
MONDP6:   RST     18H         
          DB      DH1C        
          INC     HL          ;next pointer
          DJNZ    MONDP5      
          RST     18H         
          DB      DHCR        
          RST     18H         ;break & stop
          DB      .HALT       
          OR      A           
          RET     

;*----------------------
;*    disp addrs
;*         ent. hl=addrs
;*              ':xxxx='
;*----------------------
HLHXPR:   LD      A,':'       
          RST     18H         
          DB      DH1C        
          LD      A,H         
          CALL    ACHXPR      ;acc disp
          LD      A,L         
          CALL    ACHXPR      ;acc disp
          LD      A,'='       
          RST     18H         
          DB      DH1C        
          RET     

;*--------------------------------
;*    acc  disp
;*         ent. acc = disp data
;*--------------------------------
ACHXPR:   PUSH    AF          
          RLCA    
          RLCA    
          RLCA    
          RLCA    
          CALL    AC1HXP      ;nibble disp
          POP     AF          
AC1HXP:   AND     0FH         ;ascii trans
          ADD     A,30H       
          CP      ':'         
          JR      C,AC2HXP    
          ADD     A,7         
AC2HXP:   RST     18H         ;disp acc(nible)
          DB      DH1C        
          RET     

;*------------------------------
;* monitor M(emory edit) command
;*------------------------------
MONSET:   CALL    HLSET       ;
          LD      A,(FILOUT)  ;lpt/crt switch
          PUSH    AF          
          XOR     A           
          LD      (FILOUT),A  ;crt mode
MONSTL:   RST     18H         
          DB      .CR2        
          CALL    HLHXPR      ;addrs disp
          LD      A,(HL)      ;data read
          CALL    ACHXPR      ;data disp
          LD      A,20        ;back space
          RST     18H         
          DB      .CRT1C      
          RST     18H         
          DB      .CRT1C      
          CALL    MONEDT      ;monitor operation
          JR      NC,MONSTL   
          POP     AF          
          LD      (FILOUT),A  
          RET     

;*-------------------------
;* monitor S(earch) command
;*-------------------------
MONSCH:   CALL    HLSET       ;start addrs
          RET     C           
          PUSH    HL          
          CALL    HLSET       ;end addrs
          POP     BC          
          RET     C           
          PUSH    HL          ;hl end addr
          PUSH    BC          ;bc start addr
          LD      HL,0FF00H   ;check data read
          CALL    NEXTAC      ;(hl)<--data
          LD      DE,0FF00H   
          OR      A           
          SBC     HL,DE       ;check data bytes
          LD      C,L         
          POP     HL          
          PUSH    HL          
          EXX     
          POP     HL          ;hl start addr
          POP     DE          ;de end addr
          EXX     
          RET     Z           
MNSHLP:   CALL    HLDECK      ;de=FF00h
          JR      NZ,SKPSCH   ;de check databuf
          CALL    MONDPS      ;data disp
          RET     C           
SKPSCH:   RST     18H         
          DB      .BREAK      
          RET     Z           
          EXX     
          INC     HL          ;next check pointer
          PUSH    HL          
          SCF     
          SBC     HL,DE       ;end check ?
          POP     HL          
          RET     NC          
          PUSH    HL          
          EXX     
          POP     HL          ;next check pointer
          JR      MNSHLP      

;*----------------------------------
;*    3 pointer data interpret
;*        ent de=ascii data top addr
;*        ext de=first data
;*            bc=(second-first) data
;*            hl=last data
;*     used save,xfer command
;*     command : save :  xfer
;*        de   : start:  source
;*        bc   : bytes:  bytes
;*        hl   : end  :  destination
;*----------------------------------
SAVTRN:   CALL    HLSET       ;first
          PUSH    HL          
          CALL    NC,HLSET    ;second
          POP     BC          ;first
          RET     C           
          SBC     HL,BC       ;calc bytes
          INC     HL          
          PUSH    HL          ;bytes
          PUSH    BC          ;first
          CALL    HLSET       ;last
          PUSH    HL          ;last
          EXX     
          POP     HL          ;last
          POP     DE          ;first
          POP     BC          ;bytes
          RET     

;*---------------------------
;* monitor T(ransfer) command
;*---------------------------
MONTRN:   CALL    SAVTRN      
          RET     C           
          EX      DE,HL       
          PUSH    HL          
          SBC     HL,DE       ;direction check
          POP     HL          
          JR      C,LDDRTR    
          LDIR    
          RET     

LDDRTR:   ADD     HL,BC       ;last addrs calc
          DEC     HL          
          EX      DE,HL       
          ADD     HL,BC       
          DEC     HL          
          EX      DE,HL       
          LDDR    
          RET     

;*-----------------
;*  filename set
;*-----------------
FNMST:    LD      A,(DE)      
          OR      A           
          JR      Z,FNMST2    
          INC     DE          
          CP      ':'         ;demiliter seach
          JR      NZ,FNMST    
FNMST2:   RST     18H         ;count string length
          DB      .COUNT      
          RST     18H         ;interpret dev. file name
          DB      .DEVFN      
          LD      A,1         
          LD      (ELMD),A    ;.OBJ atribut
          RET     

;*---------------------------------
;*     check (de) (hl) ?
;*           hl,de check data point
;*             c   counter
;*---------------------------------

;*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
HLDECK:   LD      A,(DE)      ;this routine is duplicated at HLDECH: !!
          CP      (HL)        ;but has been left in for compatibility
          RET     NZ          
          PUSH    BC          
          PUSH    DE          
          PUSH    HL          
          LD      B,C         
HLDEC1:   LD      A,(DE)      
          CP      (HL)        
          JR      NZ,HLDEC2   
          INC     DE          
          INC     HL          
          DJNZ    HLDEC1      
          XOR     A           
HLDEC2:   POP     HL          
          POP     DE          
          POP     BC          
          RET     

;*---------------------------------------------------------------------------

          DB      0,0,0,0,0,0,0,0 ;22 bytes spare at 17EAH -17FFH

          DB      0,0,0,0,0,0,0,0 

          DB      0,0,0,0,0,0 


;*       END of original module MON3.ASM
;*===========================================================================
;*     START of original module MON-IOCS.ASM
;*------------------------------
;* Lx-monitor  IOCS-part
;* FI:MON-IOCS  ver 1.01 5.24.84
;*------------------------------

          ORG     1800H       

SIOCS:    JP      BSTART      ;5800H in this version

;*------------------------------------------------------------
;* NOTE - FLAGS 1, 2  and ZWRX below appear in 'Device Tables'
;*------------------------------------------------------------
;*----------------------
;* FLAG1 bit definitions
;*----------------------
ROPENA:   EQU     0           ;ROPEN enable
WOPENA:   EQU     1           ;WOPEN enable
READ1:    EQU     2           ;Read at 1 char
WRITE1:   EQU     3           ;Write at 1 char
QNAME:    EQU     4           ;File name exist
RAND:     EQU     5           ;FD
SEQU:     EQU     6           ;CMT, QD, RAM
STREM:    EQU     7           ;CRT, KB, LPT, RS, USR

;*----------------------
;* FLAG2 bit definitions
;*----------------------
GNAME:    EQU     7           ;Disp filename
ROPN1:    EQU     6           ;1 file only open
WOPN1:    EQU     5           ;1 file only wopen
DOEOF:    EQU     4           ;select EOF process
;*   bit 3 not used
;*   bit 0,1,2                 ;max channel

;*---------------------
;* ZRWX bit definitions
;*---------------------
ROPNAA:   EQU     0           ;R.opened
WOPNAA:   EQU     1           ;W.opened
XOPNAA:   EQU     2           ;X.opened
LOPNAA:   EQU     3           ;L.opened
EOFAA:    EQU     7           ;End of file

;*-----------
;* DIR offset
;*-----------
SIZEAA:   EQU     20          
PTRAA:    EQU     64          ;BSD block pointer
BLOCAA:   EQU     64+16-2     ;BSD block number
;*
CMTLU:    EQU     80H         
CRTLU:    EQU     88H         
LPTLU:    EQU     89H         

;*---------------------------------------------------------------------------
CRTLUQ:   LD      A,(ZLOG)    ;This routine is duplicatedin a later module
          CP      CRTLU       ;but both are left in, for compatibility.
          RET                 ;The duplicate routine is renamed CRTDUP:
;*---------------------------------------------------------------------------

ZMODE:    DW      0           ;File mode
ZBUFF:    DW      0           ;Buffer adrs
ZBUFE:    DW      0           ;Buffer end

;*------------------------------------
;* SVC .PRSTR  ;print string into file
;*    ent DE:adrs
;*        B: length
;*------------------------------------
PRTSTR:   CALL    IO.RDY      
          CALL    PRTST0      
IO.OK:    XOR     A           
          LD      (QSEG),A    
          RET     

IO.RDY:   LD      A,(ZLOG)    
          LD      (QSEG),A    
          RET     

PRTST0:   CALL    PUSHR       
          LD      A,(ZFLAG1)  
          BIT     STREM,A     
          LD      HL,PRT1C    
          JR      Z,PRTST2    
          BIT     WRITE1,A    ;Output at
          LD      HL,.ZOUT    
          JR      NZ,PRTST2   ; 1 char
.ZOUT:    LD      IX,(ZOUT)   ; 1 line
          CALL    IOCALL      
          RET     

PRTST2:   LD      A,B         ;SEQ/RND
          OR      A           
          RET     Z           
          LD      A,(DE)      
PRTST4:   CALL    .HL         ;PRT1C or .ZOUT
          INC     DE          
          DEC     B           
          JR      PRTST2      

PRT1C:    CALL    PUSHR       
          LD      E,(IY+PTRAA) 
          LD      D,(IY+PTRAA+1) 
          LD      HL,(ZBUFF)  
          ADD     HL,DE       
          LD      (HL),A      
          INC     DE          
          LD      HL,(ZBLK)   
          OR      A           
          SBC     HL,DE       
          CALL    Z,PRT1B     ;Buffer full
          LD      (IY+PTRAA),E 
          LD      (IY+PTRAA+1),D 
          INC     (IY+SIZEAA) 
          RET     NZ          
          INC     (IY+SIZEAA+1) 
          RET     NZ          
          JP      ER55        ;too long file

PRT1B:    PUSH    BC          ;Output 1 block
          LD      B,02H       ;F# not update, blocked
PRT1B0:   CALL    QRND        
          LD      IX,.ZOUT    
          JR      Z,PRT1B1    
          LD      IX,PRX1B    
PRT1B1:   LD      A,B         
          CALL    SEQSET      
          CALL    JPIX        
PRT1B9:   INC     (IY+BLOCAA) 
          LD      DE,0        
          POP     BC          
          RET     

;*---------------------------------------------------------------------------
JIXDUP:   JP      (IX)        ;Duplicate JP (IX) left in for compatibility
;*---------------------------------------------------------------------------

PRT1BX:   LD      A,1AH       ;Output last block
          LD      E,(IY+PTRAA) 
          LD      D,(IY+PTRAA+1) 
PRT1X2:   LD      HL,(ZBUFF)  
          ADD     HL,DE       
          LD      (HL),A      
          INC     DE          
          LD      HL,(ZBLK)   
          XOR     A           
          SBC     HL,DE       
          JR      NZ,PRT1X2   
          PUSH    BC          
          LD      HL,(ZBUFF)  
          DEC     HL          
          LD      (HL),0FFH   ;EOF mark
          DEC     HL          
          LD      (HL),0FFH   
          LD      B,06H       ;F# update, blocked
          JR      PRT1B0      

SEQSET:   LD      BC,(ZBLK)   
          INC     BC          
          INC     BC          
          LD      HL,(ZBUFF)  
          DEC     HL          
          DEC     HL          
          LD      DE,(ZMODE)  
          RET     

.ZEND:    DB      0F6H        
.ZSTRT:   XOR     A           
          LD      IX,(ZSTRT)  
          CALL    IOCALL      
          RET     

;*---------------------------------
;* SVC .INSTT  ;INPUT command start
;*---------------------------------
INPSTRT:  CALL    CRTLUQ       ;input start
          RET     NZ          
          PUSH    DE          
          LD      DE,KEYBUF   
          CALL    BINPUT      
          LD      (INPKB+1),DE 
          POP     DE          
          RET     NC          
          JP      BREAKZ      

;*-----------------------------
;* SVC .INMSG  ;input from file
;*   ent DE:adrs
;*   ext B: length
;*-----------------------------
INPMSG:   PUSH    HL          
          PUSH    DE          
          CALL    IO.RDY      
          LD      HL,(ZTOP)   
          INC     HL          
          BIT     EOFAA,(HL)  
          PUSH    HL          
          LD      B,0         
          SCF     
          CALL    Z,INPMS0    
          POP     HL          
          CALL    C,INEOF     
          POP     DE          
          PUSH    AF          
          CALL    IO.OK       
          LD      L,B         
          LD      H,0         
          ADD     HL,DE       
          LD      (HL),0      
          POP     AF          
          POP     HL          
          RET     

INEOF:    SET     EOFAA,(HL)  
          LD      HL,ZFLAG2   
          BIT     DOEOF,(HL)  
          RET     Z           ;normally
          JP      ER63        ;old method

INPMS0:   CALL    CRTLUQ      ;input 1 record
          JR      Z,INPKB     
          LD      A,(ZFLAG1)  
          BIT     STREM,A     
          LD      HL,INP1C    
          JR      Z,INPMC     
          BIT     READ1,A     
          LD      HL,.ZINP    
          JR      NZ,INPMC    
.ZINP:    LD      IX,(ZINP)   
          CALL    IOCALL      
          RET     

INPKB0:   LD      A,'?'       
          RST     18H         
          DB      .CRT1C      
          LD      A,20H       
          RST     18H         
          DB      .CRT1C      
          RST     18H         
          DB      .INSTT      
INPKB:    LD      HL,0        ;xxx
          CALL    HLFTCH      
          OR      A           
          JR      Z,INPKB0    
          LD      C,0         
          RST     18H         
          DB      .INDAT      ; was .INDATA (a mistake !)
          LD      (INPKB+1),HL 
          RET     

;*----------------------------------------
;* SVC .INDAT ;read 1 item from buffer
;*   ent HL:data pointer
;*       DE:input buffer
;*       C: separator(normally 00H or ":")
;*   ext B: length
;*       HL:data pointer
;*----------------------------------------
INPDT:    LD      B,0         
          CALL    TEST1       
          DB      '"'         
          JR      NZ,INPDT6   
INPDT2:   LD      A,(HL)      
          OR      A           
          RET     Z           
          INC     HL          
          CP      '"'         
          JR      Z,INPDT4    
          LD      (DE),A      
          INC     DE          
          INC     B           
          JR      INPDT2      
INPDT4:   CALL    TEST1       
          DB      ','         
          OR      A           ;Reset CF
          RET     

INPDT6:   LD      A,(HL)      
          OR      A           
          RET     Z           
          CP      C           
          RET     Z           
          INC     HL          
          CP      ','         
          RET     Z           
          LD      (DE),A      
          INC     DE          
          INC     B           
          JR      INPDT6      

INPMC:    LD      (INPMC2+1),HL ;input by chr
          LD      B,0         
INPMC2:   CALL    0           ;INP1C or (ZINP)
          RET     C           
          CP      0DH         
          RET     Z           
          LD      (DE),A      
          INC     DE          
          INC     B           
          JR      NZ,INPMC2   
          JP      ER41        ;I/O error

INP1C0:   LD      A,(ZFLAG1)  
          BIT     STREM,A     
          JP      NZ,ER59M    ;STRM ommit
INP1C:    CALL    PUSHR       
          LD      E,(IY+PTRAA) 
          LD      D,(IY+PTRAA+1) 
          LD      HL,(ZBLK)   
          OR      A           
          SBC     HL,DE       
          CALL    Z,INP1B     
          RET     C           
          LD      L,(IY+BLOCAA) 
          LD      H,(IY+BLOCAA+1) 
          XOR     A           
          SBC     HL,DE       
          SCF     
          RET     Z           ;EOF
          LD      HL,(ZBUFF)  
          ADD     HL,DE       
          LD      A,(HL)      
          INC     DE          
          LD      (IY+PTRAA),E 
          LD      (IY+PTRAA+1),D 
          RET     

INP1B:    CALL    QRND        
          JP      NZ,INX1B    
          DB      0F6H        ;not first block
INP1B0:   XOR     A           ;first block
          CALL    SEQSET      
          CALL    .ZINP       
          RET     C           
          LD      A,(HL)      
          INC     HL          
          AND     (HL)        
          LD      (HL),0FFH   
          INC     A           
          LD      DE,0        
          RET     NZ          ;Nomal block
          PUSH    HL          ;EOF block
          LD      HL,(ZBUFE)  
          LD      BC,(ZBLK)   
INP1B2:   DEC     HL          
          DEC     BC          
          LD      A,(HL)      
          OR      A           
          JR      Z,INP1B2    
          POP     HL          
          LD      (HL),B      ;Block length
          DEC     HL          
          LD      (HL),C      
          RET     

;*-----------------------------------
;* SVC .LUCHK  ;check lu & set Z-area
;*   ent A: lu
;*   ext A: 1:R, 2:W
;*       if CF then not-found
;*-----------------------------------
LUCHK:    CALL    PUSHR       
          LD      HL,CRTTBL   
          CP      CRTLU       
          JR      Z,LUCHK4    
          LD      HL,LPTTBL   
          CP      LPTLU       
          JR      Z,LUCHK4    
          RST     18H         
          DB      .SEGAD      
          RET     C           ;LU# not found
LUCHK4:   LD      (ZTOP),HL   
          LD      DE,ZLOG     
          LD      BC,8        
          LDIR    
          LD      (ZMODE),HL  
          PUSH    HL          
          POP     IY          
          LD      DE,ELMD     
          CALL    LDIR64      
          PUSH    HL          
          LD      HL,(ZEQT)   
          LD      DE,ZNXT     
          LD      BC,ZBYTES   
          LDIR    
          POP     HL          
          LD      BC,16       
          ADD     HL,BC       
          LD      (ZBUFF),HL  
          LD      BC,(ZBLK)   
          ADD     HL,BC       
          LD      (ZBUFE),HL  
          LD      A,(ZRWX)    
          AND     0FH         
          RET     

CRTTBL:   DB      CRTLU       
          DB      3           ;W R
          DW      SCRT        
          DW      0           
          DW      0           

LPTTBL:   DB      LPTLU       
          DB      2           ;W
          DW      SLPT        
          DW      0           
          DW      0           

;*------------------------------
;* SVC .DEVNM  ;Interp. dev name
;*  ent DE:device name pointer
;*  ext DE:equipment table
;*      HL:file name pointer
;*      A: channel
;*------------------------------
DEV:      LD      HL,KEYBUF   
          PUSH    HL          
          LD      A,B         
          OR      A           
          CALL    NZ,LDHLDE   
          LD      (HL),0      
          LD      HL,EQTBL    
          JR      DEV1A       

DEV1:     LD      HL,0        ;xxx
DEV1A:    LD      A,L         
          OR      H           
          JR      Z,DEV8      ;Not found
          LD      (DEV7+1),HL 
          CALL    LDDEMI      
          LD      (DEV1+1),DE 
          LD      DE,KEYBUF   
          EX      DE,HL       
DEV2:     LD      A,(DE)      
          OR      A           
          JR      Z,DEV4      
          CP      (HL)        
          JR      NZ,DEV1     ;Mismatch
          INC     HL          
          INC     DE          
          JR      DEV2        
DEV4:     LD      A,(HL)      
          INC     HL          
          CP      ':'         
          LD      C,0         
          JR      Z,DEV5      ;Match
          SUB     31H         
          CP      9           
          JR      NC,DEV1     ;Mismatch
          LD      C,A         
          LD      A,(HL)      
          INC     HL          
          CP      3AH         
          JR      NZ,DEV1     ;Mismatch
DEV5:     EX      (SP),HL     ;Found
DEV7:     LD      HL,0        ;xxx
          LD      A,C         
          JR      DEV9        

DEV8:     POP     HL          ;Not found
          PUSH    HL          
DEV82:    LD      A,(HL)      
          INC     HL          
          CP      ':'         
          JP      Z,ER58M     ;Dev name err
          OR      A           
          JR      NZ,DEV82    
          LD      HL,(DDEV)   
          LD      A,(DCHAN)   
DEV9:     LD      (ZEQT),HL   
          PUSH    HL          
          LD      (ZCH),A     
          LD      DE,ZNXT     
          LD      BC,ZBYTES   
          LDIR    
          LD      B,A         
          LD      A,(ZFLAG2)  
          AND     07H         ;bit 0,1,2
          CP      B           
          JP      C,ER58M     ;Dev name err (CH#)
          LD      A,B         
          POP     DE          
          POP     HL          
          RET     

;*-----------------------------------
;* SVC .DEVFN  ;Interp. dev&file name
;*   ent DE:pointer
;*       B: length
;*-----------------------------------
DEV.FN:   CALL    PUSHR       
          RST     18H         
          DB      .DEVNM      
          EX      DE,HL       
          LD      HL,ELMD1    
          LD      B,31        
          CALL    QCLRHL      
          LD      HL,ELMD     
          RST     18H         
          DB      .COUNT      
          CALL    SETFNAM     
          LD      HL,ZFLAG1   
          BIT     QNAME,(HL)  
          RET     Z           
          INC     HL          
          BIT     GNAME,(HL)  
          RET     NZ          
          LD      A,(ELMD1)   ;except CMT
          CP      0DH         ;no filename
          JP      Z,ER60M     ;error 60.
          RET     

;*-----------------
;*ROPEN/WOPEN/XOPEN
;*-----------------
RWOPEN:   CALL    PUSHR       
          CALL    OPEN00      
          LD      B,0         
          CALL    TYPECK      
          JP      DUST        

OPEN00:   LD      A,(ZLOG)    
          RST     18H         
          DB      .SEGAD      
          JP      NC,ER43     ;LU already opened
          CALL    QOPEND      ;Check already opened
          LD      HL,8+64+16+5 ;LU, DIR and work
          LD      A,(ZFLAG1)  
          LD      DE,(ZBLK)   
          INC     DE          
          INC     DE          
          BIT     STREM,A     
          JR      NZ,OPEN10   
          ADD     HL,DE       ;SEQ,RND
OPEN10:   LD      A,(ZRWX)    
          BIT     2,A         
          JR      Z,OPEN11    
          ADD     HL,DE       ;XO
OPEN11:   EX      DE,HL       
          LD      A,(ZLOG)    
          RST     18H         ;open segment
          DB      .OPSEG      
          LD      (QSEG),A    
          LD      (ZTOP),HL   
          EX      DE,HL       
          LD      HL,ZLOG     
          LD      BC,8        
          LDIR                ;xfer ZLOG to seg
          LD      (ZMODE),DE  
          PUSH    DE          
          POP     IY          
          LD      HL,ELMD     
          CALL    LDIR64      ;xfer ELMD to seg
          LD      HL,16       
          ADD     HL,DE       
          LD      (ZBUFF),HL  
          LD      DE,(ZBLK)   
          ADD     HL,DE       
          LD      (ZBUFE),HL  
          CALL    QRND        
          JP      NZ,OPX      ;RND
          LD      A,(ZRWX)    ;SEQ/STRM
          BIT     XOPNAA,A    
          JP      NZ,ER59M    
          BIT     WOPNAA,A    
          LD      IX,(ZWO)    
          JR      NZ,OPEN20   
          LD      A,(ZFLAG1)  
          BIT     STREM,A     
          JR      Z,OPEN30    
          LD      IX,(ZRO)    ;STRM RO
OPEN20:   LD      HL,ELMD     ;SEQ/STRM WO
          JP      IOCALL      

OPEN30:   LD      B,(IY+0)    ;SEQ RO
          CALL    SERFLR      
          LD      A,(ELMD)    
          CP      B           
          JP      NZ,ER61M    
          JP      INP1B0      ;First call

;*-----------------------------
;* SVC .LOPEN  ;Search for LOAD
;*-----------------------------
LOPEN:    CALL    PUSHR       
          LD      IY,0100H    ;(ZLOG)=0
          LD      (ZLOG),IY   ;(ZRWX)=1 ;R
          LD      IY,ELMD     
          CALL    QRND        
          LD      HL,LOPX     
          JR      NZ,LOPEN1   
          LD      HL,SERFLR   
LOPEN1:   CALL    .HL         
          LD      B,80H       
          CALL    TYPECK      
          LD      A,(ELMD)    
          RET     

;*------------------------------------
;* type check (chained or contiguous)
;*------------------------------------
TYPECK:   LD      A,(ELMD)    
          CP      5           
          RET     C           
          LD      A,(ELMD18)  
          AND     80H         
          CP      B           
          RET     Z           
          JP      ER61M       

;*-----------------------------------
;* SVC .CLKL   ;CLOSE/KILL
;*   ent A: lu, if A=0 then all-files
;*       B: B=0:KILL, B<>0:CLOSE
;*-----------------------------------
CLKL:     CALL    PUSHR       ;CLOSE/KILL file
          OR      A           
          JR      Z,CLKLA     
          CALL    CL1F        
          JP      DUST        

CL1F:     RST     18H         
          DB      .LUCHK      
          RET     C           ;LU# not found
          CALL    IO.RDY      
          PUSH    AF          
          CALL    QRND        
          JR      NZ,CL1FR    
          BIT     STREM,A     
          LD      A,B         
          JR      Z,CL1FB     
          OR      A           ;Stream I/O
          LD      IX,(ZKL)    
          JR      Z,CL1FA     
          LD      IX,(ZCL)    
CL1FA:    CALL    IOCALL      
          JR      CL1F8       

CL1FB:    OR      A           ;SEQ I/O
          JR      Z,CL1F8     
          LD      A,(ZRWX)    
          BIT     WOPNAA,A    
          CALL    NZ,PRT1BX   
          JR      CL1F8       

CL1FR:    CALL    CLX         ;RND I/O
CL1F8:    POP     AF          
          RST     18H         
          DB      .DLSEG      
          RET     

;*---------------------------
;*  SVC .CLRIO ;clear all i/o
;*---------------------------
CLRIO:    CALL    PUSHR       
          LD      B,0         
CLKLA:    LD      C,8EH       ;all files
CLKLA2:   LD      A,C         
          PUSH    BC          
          RST     18H         
          DB      .SEGAD      
          CALL    NC,CL1F     
          POP     BC          
          DEC     C           
          JR      NZ,CLKLA2   
          JP      ERRCVR      

;*--------------------------
;*  search file (SEQ device)
;*--------------------------
SERFIL:   CALL    PUSHR       ;Search file
          LD      A,(ZFLAG1)  
          BIT     SEQU,A      
          JP      Z,ER59M     ;SEQ only ok
          CALL    .ZSTRT      
          LD      A,(ZDIRMX)  
          LD      B,A         
SERFL2:   LD      HL,KEYBUF   
          PUSH    BC          
          LD      IX,(ZRO)    ;RDINF
          CALL    IOCALL      
          POP     BC          
          SET     0,A         ;A<>0
          RET     C           ;Not found
          PUSH    IY          
          POP     DE          
          CALL    FNMTCH      
          LD      A,(HL)      
          RET     Z           
          DJNZ    SERFL2      
          XOR     A           ;end of dir
          SCF     
          RET     

;*----------------------------
;* search file for WOPEN, SAVE
;*  (SEQ device)
;*----------------------------
SERFLW:   CALL    QOPEND      
          CALL    SERFIL      
          JP      NC,ER42     ;already exist
          OR      A           
          JP      Z,ER51      ;too many files
          RET     

;*----------------------
;* search file for ROPEN
;*  (SEQ device)
;*----------------------
SERFLR:   CALL    QOPEND      
          CALL    SERFIL      
          JP      C,ER40      ;not found
          CALL    PUSHR       
          LD      HL,KEYBUF   
          PUSH    IY          
          POP     DE          
          PUSH    HL          
          CALL    LDIR64      
          POP     HL          
          LD      DE,ELMD     
          LD      A,(HL)      
LDIR64:   LD      BC,64       
          LDIR    
          OR      A           
          RET     

;*-----------------------------------
;* CALL QOPEND ; Check already opened
;*-----------------------------------
QOPEND:   LD      IX,QOPCKX   
QOPEN0:   LD      (QOPEN6+1),IX 
          CALL    PUSHR       
          LD      A,(ZLOG)    
          LD      C,A         
          LD      HL,(POOL)   
          PUSH    HL          
QOPEN2:   POP     HL          
          LD      A,(HL)      
          OR      A           
          RET     Z           
          LD      B,A         
          INC     HL          
          CALL    LDDEMI      
          PUSH    HL          
          ADD     HL,DE       
          EX      (SP),HL     
          CP      8FH         
          JR      NC,QOPEN2   ;non i/o seg.
          CP      C           
          JR      Z,QOPEN2    ;same lu
          INC     HL          ;ZRWX
          LD      A,(HL)      
          EX      AF,AF'      
          INC     HL          
          LD      DE,ZEQT     
          PUSH    BC          
          LD      BC,300H     
QOPEN4:   LD      A,(DE)      
          SUB     (HL)        
          OR      C           
          LD      C,A         
          INC     DE          
          INC     HL          
          DJNZ    QOPEN4      
          POP     BC          
          JR      NZ,QOPEN2   ;Diff. device
          LD      A,B         
QOPEN6:   CALL    0           ;xxx
          JR      QOPEN2      

QOPCKX:   LD      A,(ZFLAG2)  ;Same device
          BIT     ROPN1,A     ;1 file only ?
          JP      NZ,ER43     ;  Yes, already open
          BIT     WOPN1,A     ;1 file only W ?
          RET     Z           ;  No, ok
          EX      AF,AF'      
          LD      B,A         
          LD      A,(ZRWX)    
          AND     B           
          BIT     WOPNAA,A    
          RET     Z           
          JP      ER43        

;*------------------------------------------------------
;* Top of p.152 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
;*-------------------------------
;* SVC .LOADFL
;*   ent HL:loaging adrs
;*   call after .DEVFN and .LOPEN
;*-------------------------------
LOADFL:   CALL    QRND        
          JP      NZ,LDX      
          LD      BC,(ELMD20) 
          PUSH    BC          
          XOR     A           ;first block
          LD      IX,(ZINP)   
          CALL    IOCALL      
          POP     BC          
          RET     

;*----------------------------
;* SVC .VRFYF  ;verify file
;*   ent HL:adrs
;*   call after .DEVFN, .LOPEN
;*----------------------------
VRFYFL:   LD      A,(ZFLAG2)  
          BIT     GNAME,A     
          JP      Z,ER59M     
          LD      BC,(ELMD20) 
          JP      CMTVRF      

;*------------------------
;*  SVC .SAVEF  ;save file
;*   ent DE:adrs
;*   call after .DEVFN
;*------------------------
SAVEFL:   LD      A,(ELMD)    
          CP      5           
          JR      C,SAVEF2    
          LD      A,80H       
          LD      (ELMD18),A  ;contiguas flag
SAVEF2:   CALL    QRND        
          JP      NZ,SVX      
          BIT     STREM,A     
          JP      NZ,ER59M    
          PUSH    DE          
          LD      HL,0200H    
          LD      (ZLOG),HL   
          CALL    QOPEND      
          LD      HL,ELMD     
          PUSH    HL          
          POP     IY          
          LD      IX,(ZWO)    
          CALL    IOCALL      
          LD      BC,(ELMD20) 
          POP     HL          
          LD      A,04H       ;F# update,unblocked
          LD      IX,(ZOUT)   
          CALL    IOCALL      
          RET     

QRND:     LD      A,(ZFLAG1)  
          BIT     RAND,A      
          RET     

;*-------------------------
;* SVC .DIR
;*   ent A=0 ... read dir
;*       A>0 ... output dir
;*-------------------------
FDIR:     CALL    PUSHR       
          OR      A           
          JR      NZ,FDIR3    
          LD      HL,100H     
          LD      (ZLOG),HL   
          CALL    QOPEND      
          LD      HL,ZFLAG1   
          BIT     STREM,(HL)  
          JP      NZ,ER59M    ;Stream i/o omit
          BIT     RAND,(HL)   
          JP      NZ,LD.DIR   ;RND
          INC     HL          ;SEQ
          BIT     GNAME,(HL)  
          JP      NZ,ER59M    ;CMT ommit
          CALL    MWAIT       ;MUSIC WAIT
          LD      HL,DIRARE   
          LD      BC,8        ;clear 0800H bytes
FDIR1:    CALL    QCLRHL      
          DEC     C           
          JR      NZ,FDIR1    
          CALL    .ZSTRT      
          LD      A,(ZDIRMX)  
          LD      B,A         
          LD      HL,DIRARE   
FDIR2:    PUSH    BC          
          LD      IX,(ZRO)    ;read information
          CALL    IOCALL      
          PUSH    AF          
          LD      BC,32       
          ADD     HL,BC       
          LD      (HL),0      
          POP     AF          
          POP     BC          
          JR      C,FDIRX     
          DJNZ    FDIR2       
FDIRX:    JP      .ZEND       

FDIR3:    LD      (FDIROT+1),A 
          XOR     A           
          LD      (DISPX),A   
          LD      HL,KEYBUF   
          PUSH    HL          
          LD      DE,DIRM1    
          LD      B,DIRM2-DIRM1 
          CALL    LDHLDE      
          CALL    SETDNM      ;set device name
          LD      (HL),20H    
          INC     HL          
          LD      (HL),20H    
          INC     HL          
          EX      DE,HL       
          CALL    QRND        
          LD      IX,(ZFREE)  ;SEQ
          JR      Z,FDIR3A    
          LD      IX,FREEX    ;RND
FDIR3A:   CALL    IOCALL      
          JR      C,FDIR4     
          LD      H,B         
          LD      L,C         
          LD      B,0         
          RST     18H         
          DB      .ASCHL      
          LD      HL,DIRM2    
          LD      B,DIRM3-DIRM2 
          CALL    LDDEHL      
FDIR4:    EX      DE,HL       
          LD      (HL),0DH    
          INC     HL          
          LD      (HL),0      
          POP     DE          
          CALL    FDIROT      ;DIR OF (dd: xxx) KB FREE

          LD      B,64        ;max dir
          LD      HL,DIRARE   
FDIR6:    CALL    FDIRS       ;mod  "name"
          LD      DE,32       
          ADD     HL,DE       
          DJNZ    FDIR6       
          JP      DUST        

FDIRS:    CALL    PUSHR       
          LD      A,(HL)      
          OR      A           
          RET     Z           
          RET     M           
          LD      DE,KEYBUF   
          PUSH    DE          
          LD      A,20H       
          LD      B,38        
          CALL    QSETDE      
          LD      A,(HL)      
          CP      MAXMOD+1    
          JR      C,FDIRJ1    
          LD      A,MAXMOD+1  
FDIRJ1:   PUSH    HL          
          POP     IY          
          POP     DE          
          PUSH    DE          
          INC     DE          
          LD      HL,DIRM3-3  
          LD      BC,3        
FDIRJ2:   ADD     HL,BC       
          DEC     A           
          JR      NZ,FDIRJ2   
          LDIR    
          EX      DE,HL       
          BIT     0,(IY+18)   
          JR      Z,FDIRJ3    
          LD      (HL),'*'    
FDIRJ3:   INC     HL          
          INC     HL          
          LD      (HL),'"'    
          INC     HL          
FDIRS2:   LD      A,(IY+1)    
          CP      0DH         
          JR      Z,FDIRS4    
          LD      (HL),A      
          INC     IY          
          INC     HL          
          JR      FDIRS2      
FDIRS4:   LD      (HL),'"'    
          INC     HL          
          LD      (HL),0DH    
          INC     HL          
          LD      (HL),0      
          POP     DE          
FDIROT:   LD      A,0         ;xxx output lu
          RST     18H         
          DB      .LUCHK      
          RST     18H         
          DB      .COUNT      
          RST     18H         
          DB      .PRSTR      
          RST     18H         
          DB      .HALT       
          RET     

DIRM1:    DB      0DH         
          DB      "DIRECTORY OF " 



DIRM2:    DB      " KB FREE." 


DIRM3:    DB      "OBJ"       ;1
          DB      "BTX"       ;2
          DB      "BSD"       ;3
          DB      "BRD"       ;4
          DB      "RB "       ;5
          DB      " ? "       ;6
          DB      "LIB"       ;7
          DB      " ? "       ;8
          DB      " ? "       ;9
          DB      "SYS"       ;10
          DB      "GR "       ;11
          DB      " ? "       ;12
MAXMOD:   EQU     11          

;*--------------------
;*  INIT "dev:command"
;*--------------------
FINIT:    PUSH    HL          
FINIT2:   XOR     A           
          LD      (ZLOG),A    
          LD      IX,QOPCKY   
          LD      (QOPCKY+1),SP 
          CALL    QOPEN0      
          POP     HL          
          LD      IX,(ZINIT)  
          CALL    IOCALL      
          RET     

QOPCKY:   LD      SP,0        
          LD      B,0         
          RST     18H         ;KILL
          DB      .CLKL       
          JR      FINIT2      

;*-----------
;* Ask Y or N
;*-----------
OKYN:     CALL    TEST1       
          DB      'Y'         
          RET     Z           
          LD      DE,OKQMSG   
          RST     18H         
          DB      .CRTMS      
          LD      A,1         
          RST     18H         
          DB      .INKEY      
          CP      'Y'         
          RET     Z           
          JP      BREAKZ      

OKQMSG:   DB      "OK ? [Y/N]" 


          DB      19H         ;alpha
          DB      0           

;*---------------
;* Filename check
;*---------------
CKFIL:    LD      DE,ELMD     
FNMTCH:   CALL    PUSHR       
          INC     HL          
          INC     DE          
          LD      A,(DE)      
          CP      0DH         
          RET     Z           
          LD      B,17        
FNMTLP:   LD      A,(DE)      
          CP      (HL)        
          RET     NZ          
          CP      0DH         
          RET     Z           
          INC     HL          
          INC     DE          
          DJNZ    FNMTLP      
          OR      A           
          RET     

SETFNAM:  INC     HL
          LD      C,16        
SETFN2:   LD      A,B         
          OR      A           
          JR      Z,SETFN4    
          LD      A,(DE)      
          INC     DE          
          DEC     B           
          OR      A           
          JR      Z,SETFN4    
          CP      '"'         
          JR      Z,SETFN2    
          CP      ':'         
          JP      Z,ER60M     ;file name err
          LD      (HL),A      
          INC     HL          
          DEC     C           
          JR      NZ,SETFN2   
SETFN4:   LD      (HL),0DH    
          INC     HL          
SETFN6:   LD      A,C         
          OR      A           
          RET     Z           
          LD      (HL),20H    
          INC     HL          
          DEC     C           
          JR      SETFN6      

;*------------------------------
;* SVC .SEGAD  ;get segment adrs
;*   ent A .... Seg No.
;*   ext HL ... Buffer adrs
;*------------------------------
SEGADR:   LD      HL,(POOL)   
SEGAD2:   INC     (HL)        
          DEC     (HL)        
          SCF     
          RET     Z           ;not found
          CP      (HL)        
          INC     HL          
          JR      Z,SEGAD9    
          PUSH    DE          
          CALL    LDDEMI      
          ADD     HL,DE       
          POP     DE          
          JR      SEGAD2      
SEGAD9:   INC     HL          
          INC     HL          
          RET     

;*---------------------------
;* SVC .DLSEG ;delete segment
;*   ent A .... Seg No.
;*---------------------------
DELSEG:   CALL    PUSHR       
          RST     18H         
          DB      .SEGAD      
          RET     C           ;Not exist
          DEC     HL          
          LD      B,(HL)      
          DEC     HL          
          LD      C,(HL)      ;BC = length
          DEC     HL          ;HL = del start
          LD      D,H         
          LD      E,L         ;DE = del start
          INC     BC          
          INC     BC          
          INC     BC          ;BC = del size
          PUSH    BC          
          ADD     HL,BC       ;HL = del end
          PUSH    HL          
          LD      B,H         
          LD      C,L         
          LD      HL,(TMPEND) 
          OR      A           
          SBC     HL,BC       
          LD      B,H         
          LD      C,L         ;BC = Move bytes
          POP     HL          ;HL = del end
          LDIR    
          POP     DE          ;DE = del size
          LD      HL,0        
          OR      A           
          SBC     HL,DE       
          EX      DE,HL       ;DE= - delete size
          RST     18H         
          DB      .ADDP1      
          OR      A           
          RET     

;*---------------------------
;* SVC .OPSEG ;open segment
;*   ent A .... Seg No.
;*       DE ... Buffer length
;*   ext HL ... Buffer adrs
;*---------------------------
OPSEG:    PUSH    AF          
          PUSH    BC          
          PUSH    DE          
          PUSH    DE          
          INC     DE          
          INC     DE          
          INC     DE          
          LD      HL,(TMPEND) 
          EX      DE,HL       ;
          ADD     HL,DE       ; ADD DE,HL
          EX      DE,HL       ; DE = new TMPEND
          JP      C,ER06M     
          PUSH    HL          
          LD      HL,-512     
          ADD     HL,SP       
          SBC     HL,DE       
          JR      C,ER06M     
          LD      HL,(MEMLMT) 
          DEC     H           
          DEC     H           
          SBC     HL,DE       
          JR      C,ER06M     
          POP     HL          
          PUSH    HL          ;old TMPEND
          LD      BC,(VARST)  ;POOL END
          OR      A           
          SBC     HL,BC       
          LD      B,H         
          LD      C,L         ;BC = move bytes
          POP     HL          ;HL = old TMPEND
          INC     BC          
          LDDR    
          POP     DE          ;Buffer length
          LD      (HL),A      ;Seg No.
          INC     HL          
          LD      (HL),E      ;Size
          INC     HL          
          LD      (HL),D      
          INC     HL          
          PUSH    HL          
          INC     DE          ;LEN+1
          PUSH    DE          
OPSEG2:   LD      (HL),0      
          INC     HL          
          DEC     DE          
          LD      A,D         
          OR      E           
          JR      NZ,OPSEG2   
          POP     DE          ;LEN+1
          INC     DE          
          INC     DE          ;LEN+3
          RST     18H         
          DB      .ADDP1      
          POP     HL          
          POP     DE          
          POP     BC          
          POP     AF          
          RET     

;*-------------------------------------------------------------------------
;*MONITOR ERROR EXITS (THOSE SUFFIXED 'M' ARE DUPLICATED IN A LATER MODULE)
;*-------------------------------------------------------------------------
ER03M:    LD      A,03        
          DB      21H         
ER06M:    LD      A,06        
          DB      21H         
ER28:     LD      A,28+80H    
          DB      21H         
ER40:     LD      A,40+80H    
          DB      21H         
ER41:     LD      A,41+80H    
          DB      21H         
ER42:     LD      A,42+80H    
          DB      21H         
ER43:     LD      A,43+80H    
          DB      21H         
ER46:     LD      A,46+80H    
          DB      21H         
ER50:     LD      A,50+80H    
          DB      21H         
ER51:     LD      A,51+80H    
          DB      21H         
ER52:     LD      A,52+80H    
          DB      21H         
ER53:     LD      A,53+80H    
          DB      21H         
ER54:     LD      A,54+80H    
          DB      21H         
ER55:     LD      A,55+80H    
          DB      21H         
ER58M:    LD      A,58        
          DB      21H         
ER59M:    LD      A,59+80H    
          DB      21H         
ER60M:    LD      A,60+80H    
          DB      21H         
ER61M:    LD      A,61+80H    
          DB      21H         
ER63:     LD      A,63+80H    
          DB      21H         
ER64M:    LD      A,64        ;not used but left in to keep code aligned
          DB      21H         
ER68:     LD      A,68+80H    
          JP      ERRORJ      
;*-----------------------
;*  Error recover routine
;*-----------------------
ERRCVR:   LD      A,(QSEG)    
          OR      A           
          LD      B,0         
          CALL    NZ,CLKL     ;KILL
          CALL    FLOFF       ;FD motor off
          CALL    QDOFF       ;QD motor off
          XOR     A           
          LD      (QSEG),A    
          JP      DUST        ;I/O open check

;*       JP     MLDSP           ;commented out in the original module

          DB      0,0,0       ;(was DEFS 3)
QSEG:     DB      0           
;*---------------------------------------------------------------------------
          DB      0,0,0,0,0,0,0,0 ;38 bytes spare at 1FDAH - 1FFFH

          DB      0,0,0,0,0,0,0,0 

          DB      0,0,0,0,0,0,0,0 

          DB      0,0,0,0,0,0,0,0 

          DB      0,0,0,0,0,0 


;*       END of original module MON-IOCS.ASM
;*===========================================================================
;*     START of original module XWORK.ASM

          ORG     2000H       

TEXTBF:   DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;TXTBUF (was DEFS 2000)




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 





DIRARE:   DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;DIR area (was DEFS 800H)



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




;*       END of original module XWORK.ASM
;*===========================================================================
;*      START of original module H-QD.ASM         

;*--------------------------
;* MZ-800 Monitor  QD driver
;* FI:M-QD  ver 0.2A  9.5.84
;*--------------------------

          ORG     2FD0H       
;*---------------------
;* DEVICE TABLE FOR QD:
;*---------------------
SQD:      DW      SUSR        ;address of next table in chain (SUSR)
          DB      "QD"        ;name of THIS table
          DW      0           
          DB      5FH         ;Seq, W, R
          DB      40H         ;1OPN
          DB      32          ;Max dir
          DW      Q.INI       
          DW      Q.RINF      
          DW      Q.WINF      
          DW      Q.ON        
          DW      1024        
          DW      Q.RDAT      
          DW      Q.WDAT      
          DW      0           ;DELETE
          DW      0           ;WRDIR
          DW      Q.FREE      

Q.FREE:   XOR     A           
          SCF     
          RET     

Q.INI:    RET     C           
          CALL    TEST1       
          DB      'Y'         
          JR      Z,Q.INI2    
          OR      A           
          JP      NZ,ER03M    
          CALL    OKYN        
Q.INI2:   CALL    Q.RDY       
          RET     C           
          RST     18H         
          DB      .DI         
          LD      C,2         
          JR      QDIOX       

;*------------------
;*  Dir search start
;*------------------
Q.ON:     OR      A           
          JR      NZ,QDOFF    
          RST     18H         
          DB      .DI         
          XOR     A           
          LD      (FNUPS),A   ;KILL #
          LD      C,5         
          CALL    QDIOR       
          LD      BC,1        

QDIOR:    LD      (QDPC),HL   
          LD      (QDPE),DE   
          LD      HL,QDPB     
          LD      (HL),B      
          DEC     HL          
          LD      (HL),C      
          JR      QDIO        

QDOFF:    CALL    PUSHR       
          LD      C,6         
          JR      QDIOX       

;*------------------
;*  Read information
;*   ent HL:adrs
;*------------------
Q.RINF:   LD      BC,3        
          LD      DE,64       
          CALL    QDIOR       
          RET     NC          
          CP      40          ;not found
          SCF     
          RET     NZ          
          LD      A,0         
          RET     

;*-----------------------
;* Read data
;*  ent HL:buffer address
;*      BC:byte size
;*-----------------------
Q.RDAT:   RST     18H         
          DB      .DI         
          LD      D,B         
          LD      E,C         
          LD      BC,0103H    
QDIOX:    CALL    QDIOR       
          RST     18H         
          DB      .EI         
          RET     

;*------------------
;* Write information
;*------------------
Q.WINF:   LD      A,37H       ;SCF
          LD      (Q.WD1),A   
Q.RDY:    LD      BC,0101H    
          JR      QDIOR       

;*------------------
;* Write data
;*------------------
Q.WDAT:   PUSH    AF          
          RST     18H         
          DB      .DI         
Q.WD1:    XOR     A           ;XOR A / SCF
          JR      NC,Q.WD2    
          LD      A,0AFH      ;XOR A
          LD      (Q.WD1),A   
          CALL    SERFLW      ;First time only
          LD      (QDPG),HL   
          LD      HL,ELMD     
          LD      DE,64       
          POP     AF          
          JR      Q.WD3       

Q.WD2:    LD      (QDPG),HL   
          POP     AF          
          SET     0,A         
Q.WD3:    LD      (QDPI),BC   
          LD      B,A         
          LD      C,4         
          JR      QDIOX       

;*-------
;*QD WORK
;*-------
QDTBL:    
QDPA:     DB      0           
QDPB:     DB      0           
QDPC:     DW      0           
QDPE:     DW      0           
QDPG:     DW      0           
QDPI:     DW      0           
HDPT:     DB      0           
HDPT0:    DB      0           
FNUPS:    DB      0           
FNUPS1:   DB      0           
FNUPF:    DB      0           
FNA:      DB      0           
FNB:      DB      0           
MTF:      DB      0           
RTYF:     DB      0           
SYNCF:    DB      0           
RETSP:    DW      0           
FMS:      EQU     0EFFFH      
;*
;*-------
;* QD I/O
;*-------
QDIO:     LD      A,5         ;Retry 5
          LD      (RTYF),A    
RTY:      DI      
          CALL    QMEIN       
          EI      
          RET     NC          
          PUSH    AF          
          CP      40          
          JR      Z,RTY4      
          CALL    MTOF        
          LD      A,(QDPA)    
          CP      4           ;Write ?
          JR      NZ,RTY3     
          LD      A,(FNUPF)   
          OR      A           
          JR      Z,RTY5      
          XOR     A           ;FNUPF CLR
          LD      (FNUPF),A   
          LD      A,(FNA)     
          PUSH    HL          ;RETSP <= SP-2
          LD      (RETSP),SP  
          POP     HL          
          DI      
          CALL    QDSVFN      
          EI      
          JR      C,RTY2      
          CALL    MTOF        
RTY3:     CP      3           ;Read ?
          JR      NZ,RTY5     
          LD      HL,HDPT     
          DEC     (HL)        
RTY5:     POP     AF          
          PUSH    AF          
          CP      41          
          JR      NZ,RTY2     
          LD      HL,RTYF     
          DEC     (HL)        
          JR      Z,RTY2      
          POP     AF          
          LD      A,(FNUPS1)  
          LD      (FNUPS),A   
          JR      RTY         

RTY2:     CALL    WRCAN       
          CALL    QDHPC       
RTY4:     POP     AF          
          RET     

QMEIN:    LD      (RETSP),SP  
          LD      A,(QDPA)    
          DEC     A           
          JR      Z,QDRC      ;Ready Check
          DEC     A           
          JR      Z,QDFM      ;Format
          DEC     A           
          JR      Z,QDRD      ;Read
          DEC     A           
          JP      Z,QDWR      ;Write
          DEC     A           
          JR      Z,QDHPC     ;Head Point Clear
          JR      MTOFX       ;Motor Off
;*
;*-----------------
;* Head Point Clear
;*-----------------
QDHPC:    PUSH    AF          
          XOR     A           
          LD      (HDPT),A    
          POP     AF          
          RET     

;*---------------
;* QD Ready Check
;*---------------
QDRC:     LD      A,(QDPB)    
          JP      QREDY       

;*----------
;* QD Format
;*----------

QDFM:     XOR     A           
          CALL    QDSVFN      
          CALL    SYNCS2      
          LD      BC,FMS      
          LD      A,0AAH      
QDFM1:    CPL     
          LD      D,A         
          CALL    TRANS       
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      Z,QDFM2     
          LD      A,D         
          JR      QDFM1       

QDFM2:    CALL    EOM         
          CALL    MTOF        
          CALL    MTON        
          LD      A,(FNB)     
          DEC     A           
          JR      NZ,FMERR    
          CALL    SYNCL2      
          LD      BC,FMS      
          LD      E,55H       
QDFM3:    CP      E           
          JR      NZ,FMERR    
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      Z,QDFM4     
          LD      A,E         
          CPL     
          LD      E,A         
          CALL    RDATA       
          JR      QDFM3       

QDFM4:    CALL    RDCRC       
MTOFX:    JP      MTOF        

FMERR:    LD      A,41        ;Hard Err
          SCF     
          RET     


;*--------
;* QD Read
;*--------

QDRD:     LD      A,(MTF)     
          OR      A           
          CALL    Z,MTON      
          CALL    HPS         
          RET     C           
          CALL    BRKC        
          CALL    RDATA       
          LD      C,A         
          CALL    RDATA       
          LD      B,A         
          OR      C           ;Byte size zero check
          JP      Z,QDWE1     
          LD      HL,(QDPE)   ;Byte size check
          SBC     HL,BC       
          JP      C,QDWE1     
          LD      HL,(QDPC)   
;*---------------
;*Block Data Read
;*---------------
BDR:      CALL    RDATA       
          LD      (HL),A      
          INC     HL          
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,BDR      
          CALL    RDCRC       
          LD      A,(QDPB)    
          BIT     0,A         
          JR      NZ,MTOFX    
          RET     

;*-----------------
;*Head Point Search
;*-----------------
HPS:      LD      HL,FNB      
          DEC     (HL)        
          JR      Z,HPNFE     ;Not Found
          CALL    SYNCL2      
          LD      C,A         ;BLKFLG => C reg
          LD      A,(HDPT)    
          LD      HL,HDPT0    
          CP      (HL)        ;Search ok ?
          JR      NZ,HPS1     
          INC     A           ;HDPT count up
          LD      (HDPT),A    
          LD      (HL),A      ;HDPT0 count up
          LD      A,(QDPB)    
          XOR     C           
          RRA     
          RET     NC          ;=

;*----------
;*Dummy read
;*----------
DMR:      CALL    RDATA       
          LD      C,A         
          CALL    RDATA       
          LD      B,A         
DMR1:     CALL    RDATA       
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,DMR1     
          CALL    RDCRC       
          JR      HPS         ;next
;*
HPS1:     INC     (HL)        
          JR      DMR         
;*
HPNFE:    LD      A,40        ;Not Found
          SCF     
          RET     


;*---------
;* QD Write
;*---------

QDWR:     LD      A,(FNUPS)   
          LD      (FNUPS1),A  
          LD      A,(MTF)     
          OR      A           
          JR      NZ,QDWR1    
          CALL    MTON        
          LD      A,(FNUPS)   
          LD      HL,FNB      
          ADD     A,(HL)      
          LD      (FNB),A     
          INC     A           
          LD      (HDPT),A    
          CALL    HPS         
          JP      NC,QDWE1    ;Hard err
QDWR1:    LD      A,(QDPB)    
          LD      B,A         
          AND     1           
          JR      NZ,QDWR2    
          LD      DE,QDPC     
          LD      A,B         
          RES     2,A         
          CALL    BDW         
          CALL    BRKC        
QDWR2:    LD      DE,QDPG     
          LD      A,(QDPB)    
          SET     0,A         
          CALL    BDW         
          CALL    MTOF        
          CALL    BRKC        
          LD      A,(QDPB)    
          AND     4           
          JR      Z,NFNUP     
          LD      A,(FNA)     
          LD      HL,FNUPS    
          ADD     A,(HL)      
          CALL    QDSVFN      
          LD      A,1         
          LD      (FNUPF),A   
QDWR4:    LD      A,(FNA)     
          LD      HL,FNUPS1   
          ADD     A,(HL)      
          INC     A           
          LD      (FNB),A     
          INC     A           
          LD      (HDPT),A    
          CALL    HPS         
          JR      NC,QDWE1    
          LD      A,(QDPB)    
          AND     1           
          JR      NZ,QDWR3    
          LD      DE,QDPC     
          CALL    BDV         
          RET     C           
QDWR3:    LD      DE,QDPG     
          CALL    BDV         
          RET     C           
          LD      A,(FNUPF)   
          OR      A           
          JR      Z,QDWR5     
WRCAN:    XOR     A           
          LD      (FNUPS),A   
          LD      (FNUPF),A   
QDWR5:    JP      MTOF        

QDWE1:    LD      A,41        
          SCF     
          RET     

NFNUP:    CALL    MTON        
          JR      QDWR4       

;*----------------
;*Block Data Write
;*----------------
BDW:      PUSH    AF          
          LD      HL,FNUPS    
          INC     (HL)        
          CALL    SYNCS2      
          POP     AF          
          CALL    TRANS       
          CALL    RSET        
          LD      A,C         
          CALL    TRANS       
          LD      A,B         
          CALL    TRANS       
BDW1:     LD      A,(HL)      
          CALL    TRANS       
          INC     HL          
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,BDW1     
          JP      EOM         

;*---------
;*HL,BC SET
;*---------
RSET:     EX      DE,HL       
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          INC     HL          
          LD      C,(HL)      
          INC     HL          
          LD      B,(HL)      
          EX      DE,HL       
          RET     

;*-----------------
;*Block Data Verify
;*-----------------
BDV:      CALL    SYNCL2      
          CALL    RSET        
          CALL    RDATA       
          CP      C           
          JR      NZ,QDWE1    
          CALL    RDATA       
          CP      B           
          JR      NZ,QDWE1    
BDV1:     CALL    RDATA       
          CP      (HL)        
          JR      NZ,QDWE1    
          INC     HL          
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,BDV1     
          JP      RDCRC       

;*--------------------------
;* i/o port addresses for QD
;*--------------------------
SIOAD:    EQU     0F4H        ; sio A data
SIOBD:    EQU     0F5H        ; sio B data
SIOAC:    EQU     0F6H        ; sio A control
SIOBC:    EQU     0F7H        ; sio B control

;*-------------------------------
;* Ready & Write protect
;*    Acc = '0' : Ready check
;*    Acc = '1' : & Write Protect
;*-------------------------------
QREDY:    LD      B,A         
          LD      A,02H       ;SIO hard check
          OUT     (SIOBC),A   
          LD      A,81H       
          OUT     (SIOBC),A   
          LD      A,02H       
          OUT     (SIOBC),A   
          IN      A,(SIOBC)   
          AND     81H         
          CP      81H         
          JP      NZ,IOE50    ;Not ready
          LD      A,10H       
          OUT     (SIOAC),A   
          IN      A,(SIOAC)   
          LD      C,A         
          AND     08H         
          JP      Z,IOE50     ;Not ready
          LD      A,B         
          OR      A           
          RET     Z           ;No err
          LD      A,C         
          AND     20H         
          RET     NZ          ;No err
          JP      IOE46       ;Write protect

;*---------
;* Write FN
;*---------
QDSVFN:   PUSH    AF          
          LD      HL,SIOSD    
          LD      B,09H       
          CALL    LSINT       ;save init
SREDY:    LD      A,10H       
          OUT     (SIOAC),A   
          IN      A,(SIOAC)   
          AND     8           
          JP      Z,IOE50     ;Not ready
          LD      A,10H       
          OUT     (SIOBC),A   
          IN      A,(SIOBC)   
          AND     8           
          JR      Z,SREDY     
          LD      BC,00E9H    ;Wait 160ms
          CALL    TIMW        
          CALL    SBRK        ;Send Break
          CALL    SYNCS1      ;FN Only SYNC
          POP     AF          
          CALL    TRANS       ;FN=A
          CALL    EOM         ;CRC FLAG(7EH)
          JR      FNEND       

;*-----------------------------
;* MTON -- QD MOTOR ON
;*         READ FILE NUMBER
;*         READ &CHECK CRC,FLAG
;*-----------------------------
MTON:     LD      HL,SIOLD    
          LD      B,0BH       
          CALL    LSINT       ;load init
LREDY:    LD      A,10H       
          OUT     (SIOAC),A   
          IN      A,(SIOAC)   
          AND     8           
          JP      Z,IOE50     ;Not ready
          CALL    BRKC        
          LD      A,10H       
          OUT     (SIOBC),A   
          IN      A,(SIOBC)   
          AND     8           
          JR      Z,LREDY     
          LD      BC,00E9H    ;Wait 160ms
          CALL    TIMW        
          CALL    SYNCL1      ;LOAD SYNC
          LD      (FNA),A     
          INC     A           
          LD      (FNB),A     
          CALL    RDCRC       
FNEND:    LD      HL,SYNCF    
          SET     3,(HL)      
          XOR     A           
          LD      (HDPT0),A   
          RET     

;*---------------
;*    sio initial
;*---------------
LSINT:    LD      C,SIOAC     
          OTIR    
          LD      A,05H       
          LD      (MTF),A     
          OUT     (SIOBC),A   
          LD      A,80H       
          OUT     (SIOBC),A   
          RET     

;*-------------
;* QD Motor off
;*-------------
MTOF:     PUSH    AF          
          LD      A,05H       
          OUT     (SIOAC),A   
          LD      A,60H       
          OUT     (SIOAC),A   ;WRGT OFF,TRANS DISABLE
          LD      A,05H       
          OUT     (SIOBC),A   
          XOR     A           
          LD      (MTF),A     
          OUT     (SIOBC),A   
          POP     AF          
          RET     

;*----------------------------------
;* SYNCL1 -- LOAD F.N SYNC ONLY
;*                (SEND BREAK 110ms)
;* SYNCL2 -- LOAD FIRST FILE SYNC
;*                (SEND BREAK 110ms)
;* SYNCL3 -- LOAD FILES SYNC
;*                (SEND BREAK 002ms)
;*----------------------------------
SYNCL2:   LD      A,58H       
          LD      B,0BH       
          LD      HL,SIOLD    
          CALL    SYNCA       
          LD      HL,SYNCF    
          BIT     3,(HL)      
          LD      BC,3        ;WAIT 2ms
          JR      Z,TMLPL     
          RES     3,(HL)      
SYNCL1:   LD      BC,00A0H    ;WAIT 110ms
TMLPL:    CALL    TIMW        
          LD      A,05H       
          OUT     (SIOBC),A   
          LD      A,82H       
          OUT     (SIOBC),A   
          LD      A,03H       
          OUT     (SIOAC),A   
          LD      A,0D3H      
          OUT     (SIOAC),A   
          LD      BC,2CC0H    ;loop 220ms
SYNCW0:   LD      A,10H       
          OUT     (SIOAC),A   
          IN      A,(SIOAC)   
          AND     10H         
          JR      Z,SYNCW1    
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,SYNCW0   
          JP      IOE54       ;Un format
;*
SYNCW1:   LD      A,03H       
          OUT     (SIOAC),A   
          LD      A,0C3H      
          OUT     (SIOAC),A   
          LD      B,9FH       ;loop 3ms
SYNCW2:   LD      A,10H       
          OUT     (SIOAC),A   
          IN      A,(SIOAC)   
          AND     01H         
          JR      NZ,SYNCW3   
          DEC     B           
          JR      NZ,SYNCW2   
          JP      IOE54       ;Un format
;*
SYNCW3:   LD      A,03H       
          OUT     (SIOAC),A   
          LD      A,0C9H      
          OUT     (SIOAC),A   
          CALL    RDATA       
          JP      RDATA       
;*
;*----------------------------------
;* SYNCS1 -- SAVE F.N SYNC
;*                (SEND BREAK 220ms)
;* SYNCS2 -- SAVE FIRST FILE SYNC
;*                (SEND BREAK 220ms)
;* SYNCS3 -- SAVE FILES SYNC
;*                (SEND BREAK 020ms)
;*----------------------------------
SYNCS2:   LD      A,98H       
          LD      B,09H       
          LD      HL,SIOSD    
          CALL    SYNCA       
          CALL    SBRK        
          LD      HL,SYNCF    
          BIT     3,(HL)      
          LD      BC,001DH    ;WAIT 20ms
          JR      Z,TMLPS     
          RES     3,(HL)      
SYNCS1:   LD      BC,0140H    ;WAIT 220ms
TMLPS:    CALL    TIMW        
          LD      A,05H       
          OUT     (SIOAC),A   
          LD      A,0EFH      
          OUT     (SIOAC),A   
          LD      BC,1        ;WAIT 0.7ms
          CALL    TIMW        
          LD      A,0A5H      
          CALL    TRANS       
          JP      PATCH1      ; LD A,0C0H; OUT(SIOAC),A; RET

;*-------------------------
;* SBRK -- SEND BREAK (00H)
;*-------------------------
SBRK:     LD      A,05H       
          OUT     (SIOAC),A   
          LD      A,0FFH      
          OUT     (SIOAC),A   
          RET     

SYNCA:    LD      C,SIOAC     
          OUT     (C),A       
          LD      A,5         
          OUT     (SIOBC),A   
          LD      A,80H       
          OUT     (SIOBC),A   
          OTIR    
          RET     

;*---------------------------
;* EOM -- End off message
;*         Save CRC#1,#2,FLAG
;*         File space check
;*---------------------------

EOM:      LD      BC,1        ;WAIT 0.7ms
          CALL    TIMW        
          LD      A,10H       
          OUT     (SIOBC),A   
          IN      A,(SIOBC)   
          AND     8           
          RET     NZ          
          JP      IOE53       ;NO file space

;*--------------------------
;* RDCRC -- READ CRC & CHECK
;*--------------------------
RDCRC:    LD      B,3         
RDCR1:    CALL    RDATA       
          DJNZ    RDCR1       
RDCR2:    IN      A,(SIOAC)   
          RRCA    
          JR      NC,RDCR2    ; Rx Available
          LD      A,01H       
          OUT     (SIOAC),A   
          IN      A,(SIOAC)   
          AND     40H         
          JR      NZ,IOE41    ;Hard err
          OR      A           
          RET     

;*------------------
;* Save 1 chr by Acc
;*     & ready check
;*------------------
TRANS:    PUSH    AF          
TRA1:     IN      A,(SIOAC)   
          AND     4           ;TRANS buf null
          JR      Z,TRA1      
          POP     AF          
          OUT     (SIOAD),A   
NRCK:     LD      A,10H       
          OUT     (SIOAC),A   
          IN      A,(SIOAC)   
          AND     08H         
          JP      Z,IOE50     ;Not ready
          RET     

;*------------------
;* Read data (1 chr)
;*------------------
RDATA:    CALL    NRCK        
          IN      A,(SIOAC)   ;RR0
          RLCA    
          JR      C,IOE41     ;Hard err
          RRCA    
          RRCA    
          JR      NC,RDATA    
          IN      A,(SIOAD)   
          OR      A           
          RET     

;*--------
;* i/o err
;*--------
IOE41:    LD      A,41        ;Hard err
          DB      21H         
IOE46:    LD      A,46        ;Write protect
          DB      21H         
IOE50:    LD      A,50        ;Not ready
          DB      21H         
IOE53:    LD      A,53        ;No file space
          DB      21H         
IOE54:    LD      A,54        ;Un format
          LD      SP,(RETSP)  
          SCF     
          RET     

;*-------------------------------
;*   wait timer  clock 3.54368MHz
;*
;* BC=001H=  0.7ms (  0.698ms)
;*    003H=  2.0ms (  2.072ms)
;*    01DH= 20.0ms ( 19.929ms)
;*    0A0H=110.0ms (109.899ms)
;*    0E9H=160.0ms (160.036ms)
;*    140H=220.0ms (219.787ms)
;*--------------------------------
;*
TIMW:     PUSH    AF          
TIMW1:    LD      A,150       ;MZ-1500=152
TIMW2:    DEC     A           
          JR      NZ,TIMW2    
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,TIMW1    
          POP     AF          
          RET     

;*--------------------------------
;* SIO CH A COMMAND CHAIN
;*
;* SIOLD -- LOAD INIT. DATA
;* SIOSD -- SAVE INIT. DATA
;*--------------------------------
SIOLD:    DB      58H         ;CHANNEL RESET
          DB      04H         ;POINT WR4
          DB      10H         ;X1 CLOCK
          DB      05H         ;POINT WR1
          DB      04H         ;CRC-16
          DB      03H         ;POINT WR3
          DB      0D0H        ;ENTER HUNT PHASE
;*Rx 8bits
          DB      06H         ;POINT WR6
          DB      16H         ;SYNC CHR(1)
          DB      07H         ;POINT WR7
          DB      16H         ;SYNC CHR(2)
;*
SIOSD:    DB      98H         ;CHANNEL RESET
;*Tx CRC Generator reset
          DB      04H         ;POINT WR4
          DB      10H         ;X1 CLOCK
          DB      06H         ;POINT WR6
          DB      16H         ;SYNC CHR(1)
          DB      07H         ;POINT WR7
          DB      16H         ;SYNC CHR(2)
          DB      05H         ;POINT WR5
          DB      6DH         ;Tx CRC ENABLE

;*------------
;* BREAK CHECK
;*------------
BRKC:     LD      A,0E8H      
          OUT     (LSD0),A    
          NOP     
          IN      A,(LSD1)    
          AND     81H         
          RET     NZ          
          CALL    WRCAN       
          JP      BREAKX      ;Can't CONT

;*--------------------------
;* MZ-800  monitor
;*         LDALL
;*         SVALL
;*         ver 0.1A 08.08.84
;*--------------------------
;*---------------
;*   RAM i/o port
;*---------------
RCADR:    EQU     0EBH        ;RAM file ctrl port
RDADR:    EQU     0EAH        ;RAM file data port
;*----------------
;*   RAM equ table
;*----------------
RMLIM:    EQU     0000H       ;RAM file limit
RMADR:    EQU     0002H       ;RAM file usage
RMTOP:    EQU     0010H       ;RAM file top adrs
;*-----------------
;* LDAL,SVAL WORK
;*-----------------
RMFRE:    DW      0           
FAS:      DW      0           
NFT:      DW      0           ;1 File top
NBT:      DW      0           ;1 Block top
;*
FLAGF:    DB      0           
FNUPB:    DB      0           
;*
BLKF:     DB      0           
BLKSL:    DB      0           
BLKSH:    DB      0           

;*------------------------
;*  SVC .LSALL
;*    ent A=0 ... LOAD ALL
;*        A=1 ... SAVE ALL
;*------------------------
LSALL:    CALL    PUSHR       
          LD      HL,LDALM    
          OR      A           
          JR      Z,LSAL1A    
          LD      HL,SVALM    
LSAL1A:   LD      (LSAL1+1),HL 
          RST     18H         
          DB      .CLRIO      
          CALL    QDHPC       
          PUSH    HL          
          LD      (RETSP),SP  
          POP     HL          
          XOR     A           
          CALL    QREDY       
          JR      C,LSAL2     
          LD      A,5         ;max retry
          LD      (RTYF),A    
LSAL3:    RST     18H         
          DB      .DI         
LSAL1:    CALL    0           ;xxx LDALM or SVALM
          CALL    MTOF        
          RST     18H         
          DB      .EI         
          RET     NC          
          CP      41          
          JR      NZ,LSAL2    
          LD      HL,RTYF     
          DEC     (HL)        
          JR      NZ,LSAL3    
          LD      A,41        
LSAL2:    JP      ERRORJ      

;*--------------------
;*  LDALL main roution
;*--------------------
LDALM:    LD      (RETSP),SP  
          LD      HL,RMLIM    
          CALL    EMLD2       
          DEC     DE          ;RMFRE-end point buffer
          DEC     DE          ;end point buffer(2byte)
          LD      (RMFRE),DE  ;RAM buffer MAX adrs
          LD      HL,RMADR    
          CALL    EMLD2       
          LD      HL,RMTOP    
          OR      A           
          SBC     HL,DE       
          JP      NZ,RMER     ;RAM Not init
          LD      (NFT),DE    ;first NFT set(0010H)
          INC     DE          
          INC     DE          
          LD      (NBT),DE    ;first NBT set(0012H)
          LD      HL,FAS      
          LD      (HL),0      ;1 file byte size clear
          INC     HL          
          LD      (HL),0      
          CALL    MTON        
LDALN:    LD      HL,FNB      
          DEC     (HL)        
          JP      Z,LDEND     
          CALL    SYNCL2      
          LD      (BLKF),A    
          CALL    RDATA       
          LD      (BLKSL),A   
          CALL    RDATA       
          LD      (BLKSH),A   
          LD      HL,(BLKSL)  
          LD      DE,(NBT)    
          ADD     HL,DE       ;NBT+Block size
          JR      C,LDALEE    ;over
          LD      BC,2        
          ADD     HL,BC       ;HL+BLKF+BLKS(H,L)
LDALEE:   JP      C,LDALE     ;64K over
          LD      BC,(RMFRE)  
          SBC     HL,BC       ;usedadrs-maxused
          JR      Z,FBUF0     ;free just
          JP      NC,LDALE    ;NTB+lodingsize+3>free
FBUF0:    LD      HL,BLKF     
          LD      BC,3        
          CALL    EMSVD       
          EX      DE,HL       
          LD      DE,(BLKSL)  
          LD      A,D         ;size zero check
          OR      E           
          JP      Z,IOE41     ;size zero error
LEQM:     IN      A,(SIOAC)   
          RLCA    
          JR      C,LEQME     
          RRCA    
          RRCA    
          JR      NC,LEQM     
          IN      A,(SIOAD)   
          LD      C,RCADR     
          LD      B,H         
          OUT     (C),L       
          DEC     C           
          OUT     (C),A       
          INC     HL          
          DEC     DE          
          LD      A,D         
          OR      E           
          JR      NZ,LEQM     
          CALL    RDCRC       
          LD      (NBT),HL    
          LD      HL,(FAS)    ;1 file all size
          LD      DE,(BLKSL)  
          ADD     HL,DE       
          INC     HL          
          INC     HL          
          INC     HL          
          LD      (FAS),HL    
          LD      A,(BLKF)    
          BIT     2,A         
          JR      NZ,LDALO    ;end block ?
LDALP:    CALL    BRKCHK      
          JP      NZ,LDALN    
          JP      BREAKZ      

LDALO:    LD      DE,(NFT)    
          ADD     HL,DE       
          INC     HL          
          INC     HL          
          LD      (NFT),HL    ;next NFT
          PUSH    HL          
          EX      DE,HL       
          LD      DE,(FAS)    
          CALL    EMSV2       
          LD      HL,0        
          LD      (FAS),HL    
          POP     HL          
          INC     HL          
          INC     HL          
          LD      (NBT),HL    
          JR      LDALP       

LDEND:    LD      HL,(NFT)    
          LD      DE,RMADR    
          EX      DE,HL       
          CALL    EMSV2       
          EX      DE,HL       
          NOP     
          LD      DE,0        
          CALL    EMSV2       
          RET     

LDALE:    CALL    LDEND       
          LD      A,53        
LEQME:    SCF     
          RET     

;*--------------------
;*  SVALL main roution
;*--------------------
SVALM:    LD      (RETSP),SP  
          XOR     A           
          LD      (FNUPB),A   
          LD      (FLAGF),A   
          LD      (FNUPS),A   
          LD      HL,RMTOP    
          CALL    EMLD2       
          LD      A,D         
          OR      E           
          RET     Z           ;RAM Not file
          CALL    MTON        
          LD      A,(FNB)     
          DEC     A           
          JP      NZ,QDER     ;QD Not init
          LD      HL,RMTOP    
SVALN:    CALL    EMLD2       
          LD      (FAS),DE    
          LD      A,D         
          OR      E           
          JR      Z,SVALQ     
          INC     HL          
          INC     HL          
SVALO:    PUSH    HL          
          CALL    SYNCS2      
          POP     HL          
          CALL    EMLD1       
          CALL    TRANS       
          INC     HL          
          CALL    EMLD2       
          LD      (BLKSL),DE  
          LD      A,E         
          CALL    TRANS       
          LD      A,D         
          CALL    TRANS       
          INC     HL          
          INC     HL          
SEQM:     LD      C,RCADR     
          LD      B,H         
          OUT     (C),L       
          DEC     C           
          IN      B,(C)       
SEQM1:    IN      A,(SIOAC)   
          AND     4           
          JR      Z,SEQM1     
          LD      A,B         
          OUT     (SIOAD),A   
          INC     HL          
          DEC     DE          
          LD      A,D         
          OR      E           
          JR      NZ,SEQM     
;*-------------
;*   check EOM
;*-------------
          LD      BC,1        
          CALL    TIMW        
          LD      A,10H       
          OUT     (SIOBC),A   
          IN      A,(SIOBC)   
          AND     8           
          JR      NZ,SEQM2    
          LD      A,53        
          LD      (FLAGF),A   
          JP      SVALQ       

SEQM2:    PUSH    HL          
          LD      HL,FNUPS    
          INC     (HL)        
          CALL    BRKCHK      
          JP      Z,BREAKZ    
          LD      HL,(FAS)    
          LD      DE,(BLKSL)  
          LD      BC,3        
          XOR     A           
          SBC     HL,DE       
          SBC     HL,BC       
          JR      Z,SVALP     
          LD      (FAS),HL    
          POP     HL          
          JR      SVALO       
SVALP:    POP     HL          
          LD      A,(FNUPS)   
          LD      (FNUPB),A   
          JP      SVALN       
;*
SVALQ:    LD      A,(FNUPB)   
          LD      (FNUPS),A   
          CALL    MTOF        
          CALL    MTON        
          LD      HL,RMTOP    
SVALT:    CALL    EMLD2       
          LD      (FAS),DE    
          INC     HL          
          INC     HL          
SVALR:    LD      A,(FNUPB)   
          DEC     A           
          JP      Z,SVALU     
          LD      (FNUPB),A   
          PUSH    HL          
          CALL    SYNCL2      
          POP     HL          
          LD      D,A         
          CALL    EMLD1       
          CP      D           
          JR      NZ,QDHER    
          INC     HL          
          CALL    EMLD2       
          LD      (BLKSL),DE  
          CALL    RDATA       
          CP      E           
          JR      NZ,QDHER    
          CALL    RDATA       
          CP      D           
          JR      NZ,QDHER    
          INC     HL          
          INC     HL          
VEQM:     IN      A,(SIOAC)   
          RLCA    
          JR      C,QDHER     
          RRCA    
          RRCA    
          JR      NC,VEQM     
          IN      A,(SIOAD)   
          LD      C,RCADR     
          LD      B,H         
          OUT     (C),L       
          DEC     C           
          IN      B,(C)       
          CP      B           
          JR      NZ,QDHER    
          INC     HL          
          DEC     DE          
          LD      A,D         
          OR      E           
          JR      NZ,VEQM     
          CALL    RDCRC       
          PUSH    HL          
          CALL    BRKCHK      
          JP      Z,BREAKZ    
          LD      HL,(FAS)    
          LD      DE,(BLKSL)  
          LD      BC,3        
          XOR     A           
          SBC     HL,DE       
          SBC     HL,BC       
          JR      Z,SVALS     
          LD      (FAS),HL    
          POP     HL          
          JR      SVALR       
;*
SVALS:    POP     HL          
          JR      SVALT       
;*
SVALU:    CALL    MTOF        
          LD      A,(FNUPS)   
          CALL    QDSVFN      
          XOR     A           
          LD      (FNUPS),A   
          LD      A,(FLAGF)   
          OR      A           
          RET     Z           
          SCF     
          RET     

QDER:     
RMER:     LD      A,54        
          SCF     
          RET     

QDHER:    
          LD      A,41        
          SCF     
          RET     

;*       END of original module H-QD.ASM
;*=============================================================================
;*     START of original module H-CMT.ASM
;*----------------------------
;* PLE-monitor   CMT-driver
;* FI:M-CMT   ver 0.1  6.05.84
;*----------------------------
;*----------------------
;* DEVICE TABLE FOR CMT:
;*----------------------
SCMT:     DW      SRS         ;address of next table in chain (SRS)
          DB      "CMT"       ;name of THIS table
          DB      0           
          DB      5FH         ;Seq, W, R
SCMTF2:   DB      0C0H        ;CMT, 1OPN
          DB      0           
          DW      CTINI       ;INIT
          DW      CTRINF      ;RO
          DW      CTWINF      ;WO
          DW      .RET        ;START
          DW      256         ;Block/byte
          DW      CTRDAT      ;INP
          DW      CTWDAT      ;OUT
          DW      0           ;DELETE
          DW      0           ;WDIR
          DW      ER59M       ;FREE

CTINI:    CALL    TEST1       ; Change EOF process
          DB      'T'         
          LD      HL,SCMTF2   
          SET     DOEOF,(HL)  ; Tape BASIC mode
          RET     Z           
          RES     DOEOF,(HL)  ; Disk BASIC mode
          OR      A           
          RET     

CTWINF:   CALL    PUSHR       
          LD      DE,IBUFE    
          LD      A,(HL)      
          LD      C,5         
          CP      2           ; BTX 2 ==> 5
          JR      Z,CTWF2     
          LD      C,4         
          CP      3           ; BSD 3 ==> 4
          JR      Z,CTWF2     
          LD      C,A         
CTWF2:    LD      A,C         
          LD      (DE),A      
          INC     HL          
          INC     DE          
          LD      BC,17       
          LDIR    
          INC     HL          
          INC     HL          
          LD      BC,6        
          LDIR    
          LD      B,128-24    
          CALL    QCLRDE      
          LD      HL,IBUFE    
          LD      BC,128      
          CALL    SVCMT1      
          JR      CTWD9       

CTWDAT:   CALL    SVCMT2      
CTWD9:    JP      C,BREAKX    ; break!
          RET                 ; ok!

;*--------------
;* read inf
;*   ent HL:adrs
;*--------------
CTRINF:   LD      A,37H       ; SCF
          LD      (CTRDAT),A  
          PUSH    HL          
          LD      HL,IBUFE    
          LD      BC,128      
          CALL    LDCMT1      
          JR      C,CTERR     ; error or break
          LD      DE,FINMES   ; "Found"
          CALL    FNMPRT      ; ? file name
          POP     DE          
          LD      A,(ZLOG)    
          OR      A           ; ROPEN or LOAD?
          LD      A,(HL)      
          JP      NZ,CTRI1    ; R
          LD      C,2         ; L BTX 5 ==> 2
          CP      5           
          JR      Z,CTRI2     
CTRI1:    LD      C,3         ;   BSD 4 ==> 3
          CP      4           
          JR      Z,CTRI2     
          LD      C,A         
          SUB     2           
          CP      2           
          JP      C,ER61M     ; file mode error!
CTRI2:    LD      A,C         
          LD      (DE),A      
          INC     HL          
          INC     DE          
          LD      BC,17       
          LDIR    
          XOR     A           
          LD      B,2         
          CALL    QCLRDE      
          LD      BC,6        
          LDIR    
          LD      B,32-18-2-6 
          JP      QCLRDE      

;*--------------------
;*  read data
;*    ent HL:adrs
;*        BC:byte size
;*--------------------
CTRDAT:   XOR     A           ; XOR A / SCF
          JR      NC,CTRD2    
          LD      A,0AFH      ;XOR A
          LD      (CTRDAT),A  
          PUSH    HL          ; first time only
          LD      HL,ELMD     
          LD      DE,LDNGMS   ; "Loading"
          CALL    FNMPRT      ; ? file name
          POP     HL          
CTRD2:    CALL    LDCMT2      
          RET     NC          ; ok!
CTERR:    CP      2           
          JP      NZ,BREAKX   ; break!
          LD      A,70+80H    
          JP      ERRORJ      ; error!

;*---------
;* CMT SAVE
;*---------
SVCMT1:   LD      A,0CCH      ;Information
          JR      SAVE3       
;*
SVCMT2:   LD      A,53H       ;Data
SAVE3:    LD      (SPSV+1),SP 
          LD      SP,IBUFE    
          PUSH    DE          
          LD      E,A         
          LD      D,0D7H      ; 'W'=Dreg.
          LD      A,B         
          OR      C           
          JR      Z,RET1      
          CALL    CKSUM       ; check sum set
          CALL    MOTOR       ; motor on
          JR      C,WRI3      ; break!
          LD      A,E         
          CP      0CCH        
          JR      NZ,WRI2     ; write Data
          PUSH    DE          
          LD      DE,WRTMES   ; "Writing"
          CALL    FNMPRT      ; ? file name
          POP     DE          
WRI2:     DI      
          CALL    GAP         ; write gap
          CALL    NC,WTAPE    ; write Inf. or Data
WRI3:     DI      
          CALL    TMSTOP      ; motor off
RET1:     POP     DE          
SPSV:     LD      SP,0        ;xxx
          PUSH    AF          
          RST     18H         
          DB      .EI         
          POP     AF          
          RET     

;*---------
;* CMT LOAD
;*---------
LDCMT1:   LD      A,0CCH      ;Information
          JR      LOAD3       
;*
LDCMT2:   LD      A,53H       ;Data
LOAD3:    LD      (SPSV+1),SP ;;;
          LD      SP,IBUFE    ;;;
          PUSH    DE          
          LD      D,0D2H      ; 'L'->Dreg
          LD      E,A         
          LD      A,B         
          OR      C           
          JR      Z,RET1      
          CALL    MOTOR       ; motor on
          DI      
          CALL    NC,TMARK    ; read gap & tape mark
          CALL    NC,RTAPE    ; read Inf. or Data
          JR      WRI3        

;*-----------
;* CMT VERIFY
;*-----------
CMTVRF:   PUSH    HL          
          LD      DE,VFNGMS   ; "Verifying"
          LD      HL,ELMD     
          CALL    FNMPRT      ; ? file name
          POP     HL          
          CALL    CHKTAP      
          RET     NC          ; ok!
          CP      2           
          JP      NZ,BREAKX   ; break!
          LD      A,3+80H     
          JP      ERRORJ      ; error!


CHKTAP:   LD      (SPSV+1),SP 
          LD      SP,IBUFE    
          PUSH    DE          
          LD      D,0D2H      
          LD      E,53H       
          LD      A,B         
          OR      C           
          JR      Z,RET1      
          CALL    CKSUM       ; check sum set
          CALL    MOTOR       ; motor on
          DI      
          CALL    NC,TMARK    ; read gap & tape mark
          CALL    NC,TVRFY    ; verify
          JR      WRI3        

;*----------------------------------------
;* motor on
;*    exit CF=0:ok
;*         CF=1:break
;*----------------------------------------
MOTOR:    CALL    PUSHR       
          RST     18H         
          DB      .DI         
          LD      A,0F8H      
          OUT     (LSD0),A    ; break set
          LD      B,10        
MOT1:     IN      A,(LSD2)    
          AND     10H         
          JR      Z,MOT4      
MOT2:     LD      B,0FFH      ; 2sec delay
MOT3:     CALL    DLY7        ; 7ms delay
          DJNZ    MOT3        ; motor entry adjust
          XOR     A           ; CF=0
          RET     

MOT4:     LD      A,6         
          OUT     (LSD3),A    
          INC     A           
          OUT     (LSD3),A    
          DJNZ    MOT1        
          LD      A,(CMTMSG)  
          OR      A           
          JR      NZ,MOT6     
          RST     18H         
          DB      .CR2        
          LD      A,7FH       ; Play mark
          RST     18H         
          DB      .CRT1X      
          LD      A,20H       
          RST     18H         
          DB      .CRT1C      
          LD      A,D         
          CP      0D7H        ; 'W'
          LD      DE,RECMES   ; "RECORD."
          JR      Z,MOT5      ; write
          LD      DE,PLYMES   ; "PLAY"
MOT5:     RST     18H         ;LABEL 'MOT5' MISSING IN THE ORIGINAL SOURCE
          DB      .CRTMS      
          RST     18H         
          DB      .CR2        
MOT6:     IN      A,(LSD2)    
          AND     10H         
          JR      NZ,MOT2     
          IN      A,(LSD1)    
          AND     80H         
          JR      NZ,MOT6     
          SCF                 ; CF=1,break!
          RET     

;*--------------------
;* write tape
;*   in   BC=byte size
;*        HL=adr.
;*   exit CF=0:ok.
;*        CF=1:break
;*--------------------
WTAPE:    PUSH    DE          
          PUSH    BC          
          PUSH    HL          
          LD      D,2         ; repeat set
          LD      A,0F8H      
          OUT     (LSD0),A    ; break set
WTAP1:    LD      A,(HL)      
          CALL    WBYTE       ; 1 byte write
          IN      A,(LSD1)    
          AND     80H         ; break check
          SCF     
          JR      Z,RTP5      ; break!
          INC     HL          
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,WTAP1    
          LD      HL,(SUMDT)  ; check sum write
          LD      A,H         
          CALL    WBYTE       ; high
          LD      A,L         
          CALL    WBYTE       ; low
          CALL    LONG        
          XOR     A           
          DEC     D           
          JR      Z,RTP5      ; ok!
          LD      B,A         ; Breg=256
WTAP2:    CALL    SHORT       ; write short 256
          DJNZ    WTAP2       
          POP     HL          
          POP     BC          
          PUSH    BC          
          PUSH    HL          
          JR      WTAP1       ; repeat

;*------------------------
;* read tape
;*   in   BC=byte size
;*        HL=load adr.
;*   exit CF=0:ok
;*        CF=1,Acc=2:error
;*        else:break
;*------------------------
RTAPE:    PUSH    DE          
          PUSH    BC          
          PUSH    HL          
          LD      D,2         ; repeat set
RTP1:     CALL    EDGE        ; edge search:(49c)
          JR      C,RTP5      ; break!:7c
;* reading point search
          CALL    DLY3        ; 17c (1232c)
          IN      A,(LSD2)    
          AND     20H         
          JR      Z,RTP1      ; again
          LD      HL,0        
          LD      (SUMDT),HL  
          POP     HL          
          POP     BC          
          PUSH    BC          
          PUSH    HL          
RTP3:     CALL    RBYTE       ; 1 byte read
          JR      C,RTP5      ; error!
          LD      (HL),A      ; data->(mem.)
          INC     HL          
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,RTP3     
          LD      HL,(SUMDT)  ; check sum
          CALL    RBYTE       ; high
          JR      C,RTP5      ; error!
          CP      H           
          JR      NZ,RTP6     ; error!
          CALL    RBYTE       ; low
          JR      C,RTP5      ; error!
          CP      L           
          JR      NZ,RTP6     ; error!
RTP4:     XOR     A           
RTP5:     POP     HL          
          POP     BC          
          POP     DE          
          RET     

RTP6:     DEC     D           
          JR      NZ,RTP1     ; repeat
VFERR:    LD      A,2         ; error
          SCF     
          JR      RTP5        

;*------------------------
;* verify tape
;*   in   BC=byte size
;*        HL=adr.
;*   exit CF=0:ok
;*        CF=1,Acc=2:error
;*        else:break
;*------------------------
TVRFY:    PUSH    DE          
          PUSH    BC          
          PUSH    HL          
          LD      D,2         ; repeat set
TVF1:     CALL    EDGE        ; edge search:(49c)
          JR      C,RTP5      ; break!:7c
;* reading point search
          CALL    DLY3        ; 17c (1232c)
          IN      A,(LSD2)    
          AND     20H         
          JR      Z,TVF1      ; again
          POP     HL          
          POP     BC          
          PUSH    BC          
          PUSH    HL          
TVF2:     CALL    RBYTE       ; 1 byte read
          JR      C,RTP5      ; error!
          CP      (HL)        ; CP A.(mem.)
          JR      NZ,VFERR    ; verify error!
          INC     HL          
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,TVF2     
          LD      HL,(CSMDT)  ; Check sum.
          CALL    RBYTE       ; high
          JR      C,RTP5      ; error!
          CP      H           
          JR      NZ,VFERR    ; error!
          CALL    RBYTE       ; low
          JR      C,RTP5      ; error!
          CP      L           
          JR      NZ,VFERR    ; error!
          DEC     D           
          JR      NZ,TVF1     ; repeat
          JR      RTP4        ; ok!

RECMES:   DB      "RECORD."   

PLYMES:   DB      "PLAY"      
          DB      0           

;*----------------
;* file name print
;*----------------
FNMPRT:   LD      A,(CMTMSG)  
          OR      A           
          RET     NZ          
          RST     18H         
          DB      .CR2        
          RST     18H         
          DB      .CRTMS      
          PUSH    HL          
          INC     HL          
          LD      A,'"'       
          RST     18H         
          DB      .CRT1C      
          LD      D,16        
FNMLP:    LD      A,(HL)      
          CP      0DH         
          JR      Z,FNMLE     
          RST     18H         
          DB      .CRT1C      
          INC     HL          
          DEC     D           
          JR      NZ,FNMLP    
FNMLE:    LD      A,'"'       
          RST     18H         
          DB      .CRT1C      
          RST     18H         
          DB      .CR2        
          POP     HL          
          RET     

;*----------------------------------------------------------------
;* NOTE - In the message strings below,  (05) changes subsequent
;*        characters to lower/case, and  (06) restores upper-case
;*----------------------------------------------------------------
WRTMES:   DB      "WRITING   " 
          DB      0           
FINMES:   DB      "FOUND     " 
          DB      0           
LDNGMS:   DB      "LOADING   " 
          DB      0           
VFNGMS:   DB      "VERIFYING " 
          DB      0           

;*-------------------------------------------------
;* diagrams showing pulse timimg, tape format, etc.
;*-------------------------------------------------
;*          <LONG>     <SHORT>
;*   ÊS | 460  | 496  |240|264|
;*       ______        ___     ___     
;*      |      |      |   |   |   |   |
;*  ____|      |______|   |___|   |___|
;*     
;*      |    |        |     |
;*      |    |        |     |
;*      |   Read point|    Read point
;*      |     368us   |      368us
;*      Read edge     Read edge
;*
;*-----------------------------------------
;*
;* Information format  : Data format
;*                     :
;* * gap               : * gap
;*     short 10 sec    :     short 5 sec
;*           (22000)   :           (11000)
;* * tape mark         : * tape mark
;*     long  40        :     long  20
;*     short 40        :     short 20
;* * long 1            : * long 1
;* * Information       : * Data
;*               block :             block
;*     (128 bytes)     :     (???? bytes)
;* * check sum         : * check sum
;*     (2 bytes)       :     (2 bytes)
;* * long 1            : * long 1
;* * short 256         : * short 256
;* * Information       : * Data
;*               block :             block
;*     (128 bytes)     :     (???? bytes)
;* * check sum         : * check sum
;*     (2 bytes)       :     (2 bytes)
;* * long 1            : * long 1

;*---------------------------------------
;*   EDGE   (tape data edge search)
;*          (85c+111c)/4= 49 cycles
;*
;*   exit CF=0:ok
;*        CF=1:break
;*---------------------------------------

EDGE:     LD      A,0F8H      
          OUT     (LSD0),A    ; break set
          NOP     
EDG1:     IN      A,(LSD1)    
          AND     81H         ; shift & break
          JR      NZ,EDG2     
          SCF     
          RET     

EDG2:     IN      A,(LSD2)    ; 11c
          AND     20H         ; 7c
          JR      NZ,EDG1     ; CSTR D5=0: 7c/12c
EDG3:     IN      A,(LSD1)    ; 11c
          AND     81H         ; 7c
          JR      NZ,EDG4     ; 7c/12c
          SCF     
          RET     

EDG4:     IN      A,(LSD2)    ; 7c
          AND     20H         ; 7c
          JR      Z,EDG3      ; CSTR D5=1: 7c/12c
          RET                 ; 10c

;*--------------
;*   1 byte read
;*     exit  SUMDT=Store
;*           CF=1:break
;*           CF=0:data=Acc
;*--------------
RBYTE:    PUSH    DE          
          PUSH    BC          
          PUSH    HL          
          LD      HL,0800H    ; 8 repeat set
RBY1:     CALL    EDGE        ; edge search:(49c)
          JP      C,TM4       ; break!:7c
;* reading point search:17c(1232c)
          CALL    DLY3        ; 17c (1232c)
          IN      A,(LSD2)    ; data read
          AND     20H         ; CF=0
          JP      Z,RBY2      ; again
          PUSH    HL          
          LD      HL,(SUMDT)  ; check sum set
          INC     HL          
          LD      (SUMDT),HL  
          POP     HL          
          SCF                 ; CF=1
RBY2:     LD      A,L         
          RLA                 ; rotate left
          LD      L,A         
          DEC     H           
          JP      NZ,RBY1     ; repeat
          CALL    EDGE        
          LD      A,L         
          JR      TM4         ; ok!

;*---------------
;*  1 byte write
;*    in Acc=data
;*---------------
WBYTE:    PUSH    BC          
          LD      B,8         ; 8 repeat set
          CALL    LONG        ; write long
WBY1:     RLCA                ; rotate left
          CALL    C,LONG      ; 'H' long
          CALL    NC,SHORT    ; 'L' short
          DEC     B           
          JP      NZ,WBY1     ; repeat
          POP     BC          
          RET     

;*------------------------------------
;*   tape mark read
;*     in   E=CCH:Inf.  long40,short40
;*           else:Data  long20,short20
;*     exit CF=0:ok
;*          CF=1:break
;*------------------------------------
TMARK:    CALL    GAPCK       
          PUSH    DE          
          PUSH    BC          
          PUSH    HL          
          LD      HL,2828H    ; H=40,L=40
          LD      A,E         
          CP      0CCH        ;'L'
          JR      Z,TM0       
          LD      HL,1414H    ; H=20,L=20
TM0:      LD      (TMCNT),HL  
TM1:      LD      HL,(TMCNT)  
TM2:      CALL    EDGE        ; edge search:(49c)
          JR      C,TM4       ; break!:7c
;* reading point search:17c(1232c)
          CALL    DLY3        ; 17c (1232c)
          IN      A,(LSD2)    
          AND     20H         
          JR      Z,TM1       ; again
          DEC     H           
          JR      NZ,TM2      
TM3:      CALL    EDGE        ; edge search:(49c)
          JR      C,TM4       ; break!:7c
;* reading point search:17c(1232c)
          CALL    DLY3        ; 17c (1232c)
          IN      A,(LSD2)    
          AND     20H         
          JR      NZ,TM1      ; again
          DEC     L           
          JR      NZ,TM3      
          CALL    EDGE        
TM4:      POP     HL          
TM5:      POP     BC          
          POP     DE          
          RET     

;*---------------------
;*   check sum set
;*    in   BC=byte size
;*         HL=adr.
;*    exit SUMDT=store
;*         CSMDT=store
;*--------------------
CKSUM:    PUSH    DE          
          PUSH    BC          
          PUSH    HL          
          LD      DE,0        
CKS1:     LD      A,B         
          OR      C           
          JR      NZ,CKS2     
          EX      DE,HL       
          LD      (SUMDT),HL  
          LD      (CSMDT),HL  
          JR      TM4         ; ret
CKS2:     LD      A,(HL)      
          PUSH    BC          
          LD      B,8         ; 8 bits
CKS3:     RLCA                ; rotate left
          JR      NC,CKS4     
          INC     DE          
CKS4:     DJNZ    CKS3        
          POP     BC          
          INC     HL          
          DEC     BC          
          JR      CKS1        

;*----------------------------------
;*   gap + tape mark
;*
;*     in   E=CCH:short gap (10 sec)
;*           else:short GAP ( 5 sec)
;*----------------------------------
GAP:      PUSH    DE          
          PUSH    BC          
          LD      A,E         
          LD      BC,55F0H    ; Inf. 22000(10 sec)
          LD      DE,2828H    ;      short40,long40
          CP      0CCH        ;'L'
          JP      Z,GAP1      
          LD      BC,2AF8H    ; Data 11000( 5 sec)
          LD      DE,1414H    ;short20,long20
GAP1:     CALL    SHORT       ; write short
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,GAP1     
GAP2:     CALL    LONG        ; write long
          DEC     D           
          JR      NZ,GAP2     
GAP3:     CALL    SHORT       ; write short
          DEC     E           
          JR      NZ,GAP3     
          CALL    LONG        
          JR      TM5         

;*-------------------
;*   GAP check
;*   (long100 search)
;*-------------------
GAPCK:    PUSH    DE          
          PUSH    BC          
          PUSH    HL          
GAPCK1:   LD      H,100       ; 100 repeat set
GAPCK2:   CALL    EDGE        ; edge search:(49c)
          JR      C,TM4       ; error!:7c
          CALL    DLY3        ; reading point search:17c(1232c)
          IN      A,(LSD2)    
          AND     20H         
          JR      NZ,GAPCK1   ; again
          DEC     H           
          JR      NZ,GAPCK2   
          JR      TM4         

;*----------------------------------------
;*  SHORT AND LONG PULSE FOR 1 BIT WRITE
;*----------------------------------------
SHORT:    PUSH    AF          ; 11c
          LD      A,03H       ; 7c
          OUT     (LSD3),A    ; 11c
          CALL    DLY1        ; 17c (408c)
          CALL    DLY1        ; 17c (408c)
          LD      A,02H       ; 7c
          OUT     (LSD3),A    ; 11c
          CALL    DLY1        ; 17c (408c)
          CALL    DLY1        ; 17c (408c)
          POP     AF          ; 10c
          RET                 ; 10c

LONG:     PUSH    AF          ; 11c
          LD      A,03H       ; 7c
          OUT     (LSD3),A    ; 11c
          CALL    DLY4        ; 17c (1704c)
          LD      A,02H       ; 7c
          OUT     (LSD3),A    ; 11c
          CALL    DLY4        ; 17c (1704c)
          POP     AF          ; 10c
          RET                 ; 10c

;*-----------------
;*  TAPE MOTOR STOP
;*-----------------
TMSTOP:   PUSH    AF          
          PUSH    BC          
          PUSH    DE          
          LD      B,10        
MST1:     IN      A,(LSD2)    ; motor check
          AND     10H         
          JR      Z,MST3      ; ok
          LD      A,06H       ; motor off
          OUT     (LSD3),A    
          INC     A           
          OUT     (LSD3),A    
          DJNZ    MST1        
MST3:     POP     DE          
          POP     BC          
          POP     AF          
          RET     

;*----------------------------
;*   7.046 ms delay ... 24989c
;*----------------------------
DLY7:     PUSH    BC          ; 11c
          LD      B,20        ; 7c
DLY.7:    CALL    DLY3        ; 17*19+17 (23332c)
          CALL    DLY0        ; 17*19+17 (  226c)
          DJNZ    DLY.7       ; 13*19+8
          POP     BC          ; 10c
          RET                 ; 10c

;*-----------------
;*   14 clock delay
;*-----------------
DLY0:     NOP                 ; 4c
          RET                 ; 10c
;*---------------------------
;*   347.4 us delay ... 1232c
;*---------------------------
DLY3:     NOP                 ; 4c
          LD      A,76        ; 7c
DLYA:     DEC     A           ;  4*XX+4
          JR      NZ,DLYA     ; 12*XX+7
          RET                 ; 10c
;*-----------------
;* Delay for short.
;*   115.0 us delay ... 408c
;*-----------------
DLY1:     LD      A,24        ; 7c
          JR      DLYA        ; 12c
;*----------------
;* Delay for long.
;*   480.4 us delay ... 1704c
;*----------------
DLY4:     LD      A,105       ; 7c
          JR      DLYA        ; 12c

;*       END of original module H-CMT.ASM
;*============================================================================
;*     START of original module H-FD.ASM
;*-----------------------------
;* PL-monitor  FD dummy
;* FI:DMY-FD   ver 003  3.28.84
;*-----------------------------

SFD:      DW      SQD         ;address of next table in chain
          DB      0           ;name of THIS table (0 = not available)

;* The Labels below are mainly dummies that identify the missing FD routines
CLX:      
DUST:     
FLOFF:    
FREEX:    
INREC:    
INX1B:    
LD.DIR:   
LDX:      
LOPX:     
OPX:      
PRREC:    
PRX1B:    
RECST:    
SVX:      OR      A           
          RET     
FLOCK:    
FSWAP:    JP      ER59M       

;*------------------
;*  SVC .DELET
;*------------------
FDELET:   CALL    PUSHR       
          LD      HL,(ZDELT)  ;SEQ
          LD      A,L         
          OR      H           
          JR      Z,FREN2     
          PUSH    HL          
          RST     18H         
          DB      .LOPEN      
          LD      A,2         
          LD      (ZRWX),A    
          CALL    QOPEND      
          JR      FREN4       
;*--------------
;* SVC .RENAM
;*--------------
FRENAM:   CALL    PUSHR       
          LD      HL,(ZWDIR)  
          LD      A,L         
          OR      H           
FREN2:    JP      Z,ER59M     
          PUSH    HL          
          RST     18H         
          DB      .LOPEN      
          LD      HL,ELMD     
          CALL    SETFNAM     
          LD      HL,200H     
          LD      (ZLOG),HL   
          CALL    SERFLW      ;check already exist
FREN4:    POP     IX          
          JP      IOCALL      

          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0          

;*       END of original module H-FD.ASM
;*============================================================================
;*     START of original module MON4.ASM 

          ORG     3C00H       ;ensures that this section starts on 3C00H

;*-------------------------
;* ascii display code trans
;*-------------------------
QADCN:    CP      10H         ;EX only
          JR      C,QAD3      ; <10H ==> F0H
          CP      80H         
          JR      Z,QAD7      ; 80H ==> 40H
          CP      0C0H        
          JR      Z,QAD7      ; C0H ==> 80H
          DI      
          OUT     (LSE2),A    
          CALL    0BB9H       
          OUT     (LSE0),A    
          EI      
          RET     
QAD3:     LD      A,0F0H      
          RET     
QAD7:     SUB     40H         
          RET     

QDACN:    CP      0F0H        
          JR      NC,QDA3     
          CP      73H         
          JR      Z,QAD3      ; 73H ==> F0H
          CP      40H         ;EX only
          JR      Z,QDA7      ; 40H ==> 80H
          CP      80H         
          JR      Z,QDA7      ; 80H ==> C0H
          DI      
          OUT     (LSE2),A    
          CALL    0BCEH       
          OUT     (LSE0),A    
          EI      
          CP      0F0H        
          RET     NZ          
QDA3:     LD      A,20H       
          RET     

QDA7:     ADD     A,40H       
          RET     

QKYTBL:   PUSH    AF          
          LD      A,L         
          SUB     8           
          JR      C,QKY0      
          SUB     48          
          JR      C,QKY1      
QKY0:     ADD     A,10        
          LD      L,A         
          ADD     HL,BC       
          LD      C,(HL)      
          POP     AF          
          RET     

QKY1:     LD      A,(BC)      
          PUSH    AF          
          INC     BC          
          LD      A,(BC)      
          LD      B,A         
          POP     AF          
          LD      C,A         ;BC=ROM adrs
          ADD     HL,BC       
          DI      
          OUT     (LSE2),A    
          LD      A,(HL)      
          OUT     (LSE0),A    
          EI      
          CALL    QDACN       
          LD      C,A         
          POP     AF          
          RET     


;*       END of original module MON4.ASM
;*============================================================================
;*     START of original module MON-RS.ASM
;*-----------------------------
;* MZ-800      RS-232C driver
;* FI:MON-RS   ver 001  8.02.84
;*-----------------------------

          IF     RSYS = 0     ;this EQUATE IS NOT assembled for the MZ-800
RMCH:     EQU    3            ;channels 0,1,2,3
          ENDIF

          IF     RSYS = 1     ;this EQUATE IS assembled for the MZ-800
RMCH:     EQU     1           ;channels 0 and 1
          ENDIF

SRS:      DW      SRAM        ;address of the NEXT table in the chain
          DB      "RS"        ;name of THIS table
          DW      0           
          DB      8FH         ;Stream, O1C, I1C, W, R
          DB      RMCH        ;ch.
          DB      0           
          DW      RSINI       ;INIT
          DW      RSRO        ;ROPEN
          DW      RSWO        ;WOPEN
          DW      RSCL        ;CLOSE
          DW      RSKL        ;KILL
          DW      RSINP       ;INP1C
          DW      RSOUT       ;OUT1C
          DW      .RET        ;POS

RSINI:    RET     C           
          PUSH    IY          
          CALL    SETIY       
          CALL    RSINT0      
          CALL    RSPARM      
          JR      RETIY       

RSINT0:   RST     18H         
          DB      .DEASC      
          LD      (IY+MONITN),E ;THIS WAS (IY+XMONITIN) (a mistake!) 
          CALL    TEST1       
          DB      ','         
          JP      NZ,ER03M    
          RST     18H         
          DB      .DEASC      
          LD      (IY+INITN),E 
          CALL    TEST1       
          DB      0           
          RET     Z           
          CALL    TEST1       
          DB      ','         
          JP      NZ,ER03M    
          RST     18H         
          DB      .DEASC      
          LD      (IY+CRLFN),E 
          RET     

RSRO:     
RSWO:     PUSH    IY          
          CALL    SETIY       
          LD      A,(IY+STATN) 
          INC     (IY+STATN)  
          OR      A           
          CALL    Z,RSOPEN    
          JR      RETIY       

;*------------------------------------------------------
;* Top of p.220 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
RSCL:     
RSKL:     PUSH    IY          
          CALL    SETIY       
          DEC     (IY+STATN)  
          LD      A,(IY+STATN) 
          OR      A           
          CALL    Z,RCLOSE    
          JR      RETIY2      

RSINP:    PUSH    IY          
          CALL    SETIY       
          CALL    RSINP0      
          JP      C,IOERR     
          CP      (IY+CRLFN)  
          JR      NZ,RETIY2   
          LD      A,0DH       
RETIY2:   OR      A           
RETIY:    POP     IY          
          RET     

RSINP0:   BIT     6,(IY+INITN) 
          JP      Z,GET1C     
          LD      IX,GET1C    
          PUSH    IY          
          POP     HL          
          LD      DE,JISRN    
          ADD     HL,DE       
          JP      JISR        

RSOUT:    PUSH    IY          
          CALL    SETIY       
          CP      0DH         
          JR      NZ,RSOUTC   
          LD      A,(IY+CRLFN) 
RSOUTC:   CALL    RSOUT0      
          JR      RETIY       

RSOUT0:   BIT     6,(IY+INITN) 
          JP      Z,PUT1C     
          LD      IX,PUT1C    
          PUSH    IY          
          POP     HL          
          LD      DE,JISXN    
          ADD     HL,DE       
          LD      DE,(DISPX)  
          JP      JISX        

SETIY:    PUSH    AF          
          PUSH    DE          
          LD      A,(ZCH)     
          INC     A           
          LD      IY,MARKA-TBLN 
          LD      DE,TBLN     
SETIY2:   ADD     IY,DE       
          DEC     A           
          JR      NZ,SETIY2   
          LD      C,(IY+0)    
          POP     DE          
          POP     AF          
          RET     

;*------------------------------
;*   RS PORT ADDRESS EQUATES
;*------------------------------
CHADT:    EQU     0B0H        
CHACT:    EQU     0B1H        
CHBDT:    EQU     0B2H        
CHBCT:    EQU     0B3H        

CHCDT:    EQU     0D0H        
CHCCT:    EQU     0D1H        
CHDDT:    EQU     0D2H        
CHDCT:    EQU     0D3H        

CRLFN:    EQU     -8          ; 0FFF8H      
JISXN:    EQU     -7          ; 0FFF9H      
JISRN:    EQU     -5          ; 0FFFBH      
MONITN:   EQU     -3          ; 0FFFDH      
INITN:    EQU     -2          ; 0FFFEH      
STATN:    EQU     -1          ; 0FFFFH      

          DB      0           ;CR or LF (was DEFS 1)
          DB      0,0         ;for JISX (was DEFS 2)
          DB      0,0         ;for JISR(was DEFS 2)
          DB      0           ;monitor (was DEFS 1)
          DB      0           ;init code (was DEFS 1)
          DB      0           ;status (was DEFS 1)
MARKA:    DB      CHACT       ;0
          DB      CHADT       ;1
          DB      0           ;2 Mask Pattern (was DEFS 1)
          DW      1010H       ;3,4
          DW      4004H       ;5,6 WR4
          DW      0C003H      ;7,8 WR3
          DW      6005H       ;9,10 WR5
          DB      30H         
          DB      3           
;*
          DB      0,0,0,0,0,0,0,0 ;(was DEFS 8)


MARKB:    DB      CHBCT       
          DB      CHBDT       
          DB      0           ;(was DEFS 1)
          DW      1010H       
          DW      4004H       
          DW      0C003H      
          DW      6005H       
          DB      30H         
          DB      3           

          IF      RSYS = 0        ;start of section NOT assembled for MZ-800
          DB      0,0,0,0,0,0,0,0
MARKC:    DB      CHCCT           ;0 (channel C)
          DB      CHCDT           ;1
          DB      0               ;2 Mask Pattern
          DW      1010H           ;3,4
          DW      4004H           ;5,6 WR4
          DW      0C003H          ;7,8 WR3
          DW      6005H           ;9,10 WR5
          DB      30H
          DB      3

          DB      0,0,0,0,0,0,0,0
MARKD:    DB      CHDCT           ;(channel D)
          DB      CHDDT
          DB      0
          DW      1010H
          DW      4004H
          DW      0C003H
          DW      6005H
          DB      30H
          DB      3
          ENDIF                  ;end of section not assembled for MZ-800

TBLN:     EQU     MARKB-MARKA 
;*--------------
;*   Break Check
;*--------------
BRK:      CALL    BRKCHK      
          RET     NZ          
          JP      BREAKZ      

;*---------------------
;*  sio  parameter  set
;*---------------------
RSPARM:   LD      A,18H       ;channel reset
          OUT     (C),A       
          LD      A,30H       ;err reset
          OUT     (C),A       
          LD      A,(IY+INITN) ;inital bit
          AND     0CH         ;stop bit
          JR      NZ,RSP0     
          SET     2,(IY+INITN) ;1 bit/chr
RSP0:     LD      A,(IY+INITN) ;initial bit
          LD      B,A         ;B=init code
          AND     0FH         ;mask
          OR      40H         ;clock rate *16
          LD      (IY+6),A    ;wr4
          LD      A,B         
          AND     80H         ;rx disable d7 bit/chr
          OR      40H         
          LD      (IY+8),A    ;wr3
          RRA     
          AND     7FH         ;dtroff
          OR      0AH         ;tx enable rtson dtroff
          LD      (IY+10),A   ;wr5
          LD      A,B         
          OR      7FH         
          LD      (IY+2),A    ;bit mask
          CALL    RSSUB       
RSTBUF:   IN      A,(C)       
          RRCA    
          RET     NC          
          DEC     C           
          IN      A,(C)       
          INC     C           
          LD      A,1         
          OUT     (C),A       
          IN      A,(C)       
          AND     70H         
          JR      Z,RSTBUF    
          RET     

;*-----------
;*  SIO close
;*-----------
RCLOSE:   RES     0,(IY+8)    ;rx disable
          RES     7,(IY+10)   ;rdy off
          LD      (IY+STATN),0 
RSSUB:    LD      B,10        
          PUSH    IY          
          POP     HL          
          LD      DE,3        
          ADD     HL,DE       
          OTIR    
          RET     

;*----------
;*  SIO open
;*----------
RSOPEN:   LD      A,30H       
          OUT     (C),A       ;err reset
          RET     

;*----------------------------
;*  in IY=channel data
;*      C=channel control port
;*----------------------------
RSEN:     SET     0,(IY+8)    ;wr3 RX enable
          LD      A,13H       
          OUT     (C),A       ;ext/int reset
          LD      A,(IY+8)    ;wr3
          OUT     (C),A       ;wr5
          LD      A,35H       ;err reset
          OUT     (C),A       
          LD      A,(IY+10)   ;wr5
          OR      88H         ;dtr,rts on tx enable
          LD      (IY+10),A   ;wr5
          OUT     (C),A       
          RET     

RSDIS:    LD      A,3         
          OUT     (C),A       
          RES     0,(IY+8)    ;wr3 RX disenable
          LD      A,(IY+8)    ;wr3
          OUT     (C),A       
RDYOF:    RES     7,(IY+10)   ;wr5 dtr reset
          JR      WR5OUT      

RTSON:    SET     1,(IY+10)   ;wr5 rts set
          JR      WR5OUT      
;*
RTSOFF:   RES     1,(IY+10)   ;wr5 rts reset
          JR      WR5OUT      
;*
RDYON:    SET     7,(IY+10)   ;wr5 dtr set
WR5OUT:   LD      A,5         
          OUT     (C),A       
          LD      A,(IY+10)   ;wr5
          OUT     (C),A       
          OR      A           
          RET     

;*-------------------
;*     Receive 1 char
;*-------------------
GET1C:    CALL    PUSHR       
          LD      C,(IY+0)    
GET1:     CALL    BRK         
          CALL    DRCKR       
          JR      C,GET1      
          CALL    RSEN        
CHIN:     CALL    BRK         
          IN      A,(C)       
          RRCA    
          JR      NC,CHIN     ;skip if no data
          DEC     C           
          IN      A,(C)       ;data input
          INC     C           
          AND     (IY+2)      ;mask
          PUSH    AF          
          LD      A,1         
          OUT     (C),A       
          IN      A,(C)       
          AND     70H         
          JR      NZ,RSER     ;skip if err
          CALL    RDYOF       
          POP     AF          
          RET     

RSER:     LD      B,A         
          POP     AF          
          PUSH    BC          
          CALL    RSPARM      
          POP     BC          
          LD      A,29        ;framing err
          RLC     B           
          RLC     B           
          RET     C           
          INC     A           ;overrun err
          RLC     B           
          RET     C           
          INC     A           ;parity err
          SCF     
          RET     

;*----------------
;*     Send 1 char
;*----------------
PUT1C:    CALL    PUSHR       
          LD      C,(IY+0)    
          LD      D,A         
          CALL    RTSON       
PUT1:     CALL    BRK         
          CALL    DRCKS       
          CALL    NC,CTSCK    
          JR      C,PUT1      
          IN      A,(C)       
          BIT     2,A         ;tx buf empty ?
          JR      Z,PUT1      
          BIT     7,(IY+MONITN) ;all chr send?
          JR      Z,PUT2      
          LD      A,1         
          OUT     (C),A       
          IN      A,(C)       
          RRCA    
          JR      NC,PUT1     
PUT2:     DEC     C           
          OUT     (C),D       ;data out
          INC     C           
          BIT     6,(IY+MONITN) ;rts on/off?
          JR      Z,PUT3      
          CALL    RTSOFF      
PUT3:     OR      A           
          RET     

;*-----------
;*  DCD check
;*-----------
DRCKR:    OR      A           
          BIT     0,(IY+MONITN) ;moniter dr ?
          JR      DRCK1       
;*
DRCKS:    OR      A           ;carry clear
          BIT     1,(IY+MONITN) ;moniter dr ?
DRCK1:    RET     Z           
          LD      A,10H       ;ext/int reset
          OUT     (C),A       
          IN      A,(C)       
          AND     8           
          RET     NZ          ;cy=0
          SCF     
          RET     

;*----------
;* CTS check
;*----------
CTSCK:    OR      A           
          BIT     2,(IY+MONITN) ;moniter cts ?
          RET     Z           
          LD      A,10H       
          OUT     (C),A       
          IN      A,(C)       
          AND     20H         
          RET     NZ          
          SCF     
          RET     

;*       END of original module MON-RS.ASM
;*============================================================================
;*     START of original module MON-EMM.ASM    
;*-----------------------------
;* Lx-monitor  EMM driver
;* FI:MON-EMM  ver 005  4.27.84
;*-----------------------------

;*----------------------
;* DEVICE TABLE FOR RAM:
;*----------------------
SRAM:     DW      SFD         ;address of the NEXT table in the chain
          DB      "RAM"       ;name of THIS table
          DB      0           
          DB      5FH         
          DB      20H         ;WOPN1
          DB      32          ;Max dir
          DW      EMINI       ;INIT
          DW      EMRINF      
          DW      EMWINF      
          DW      EMON        
          DW      1024        
          DW      EMRDAT      
          DW      EMWDAT      
          DW      EMDEL       
          DW      EMWDIR      
          DW      EMFRKB      

;*------------------------------------------------------
;* Top of p.230 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
EMFRKB:   CALL    PATCH2      ; DI; CALL EMFRB;EI; RET
          LD      C,H         
          LD      B,0         ;/256
          SRL     C           ;/512
          SRL     C           ;/1024
          OR      A           
          RET     

EMFRB:    PUSH    DE          
          LD      HL,0        ;free area(bytes)
          CALL    EMLD2       ;max
          PUSH    DE          
          INC     HL          
          INC     HL          
          CALL    EMLD2       ;use
          POP     HL          
          SBC     HL,DE       
          JP      C,ER41      ;I/O ERR
          POP     DE          
          RET     

EMCLR:    LD      DE,10H      
EMSETU:   LD      HL,2        
          CALL    EMSV2       ;Set used mem
          EX      DE,HL       
          LD      DE,0        
          JP      EMSV2       ;File end mark

EMINI:    RET     C           
          LD      A,(EMFLG)   
          OR      A           
          JP      Z,ER50      
          CALL    OKYN        
          CALL    TEST1       
          DB      ','         
          PUSH    HL          
          CALL    PATCH3      ; DI; CALL EMLCR; EI; RET
          POP     HL          
          CALL    TEST1       
          DB      0           
          RET     Z           ;INIT "EM:"
          RST     18H         ;INIT "EM:$hhhh"
          DB      .DEASC      
EMINI2:   LD      HL,0        
          DI      
          LD      B,1         
          LD      A,D         
          AND     0FCH        
          CP      0FCH        
          LD      HL,0FFFFH   
          JR      Z,EMINI3    ;if >=FC00 then FFFF
          LD      B,3         
          LD      A,D         
          OR      A           
          LD      HL,20H      
          JR      NZ,EMINI4   ;if <=00FF then 0020
EMINI3:   EX      DE,HL       
EMINI4:   LD      A,B         
          LD      (EMFLG),A   ;WAS EMFL (error)
          LD      HL,0        
          CALL    EMSV2       ;Set max mem
          CALL    PBCCLR      ;WAS PBCCL (error)
          EI      
          RET     

;*----------------------
;*  EMM power on routine
;*----------------------
EMMPWR:   LD      HL,8        
          LD      B,L         
          LD      C,0         
EMPWR2:   CALL    EMLD1       
          SUB     L           
          OR      C           
          LD      C,A         
          LD      A,L         
          CALL    EMSV1       
          INC     L           
          DJNZ    EMPWR2      
          LD      A,C         
          OR      A           
          JR      NZ,EMPWR4   
          LD      HL,0        ;already initialized
          CALL    EMLD2       
          LD      A,2         
          INC     D           
          JR      Z,EMPWR3    
          INC     A           
EMPWR3:   LD      (EMFLG),A   
          JP      PBCCLR      

EMPWR4:   CALL    EMCLR       
          LD      HL,0        ;check EMM installed?
          LD      A,5AH       
          CALL    EMSV1       
          CALL    EMLD1       
          SUB     5AH         
          LD      DE,0C000H   ;Initial set 48KB
          JR      Z,EMINI2    
          XOR     A           
          LD      (EMFLG),A   
          RET     

;*------------------
;*  RAM Dir search
;*------------------
EMON:     LD      A,(EMFLG)   
          OR      A           
          JP      Z,ER50      
          LD      HL,10H      
          LD      (EMPTR),HL  
          RET     

;*---------------
;*  Read RAM info
;*    ent HL:adrs
;*---------------
EMRINF:   LD      B,H         
          LD      C,L         
          LD      HL,(EMPTR)  
          CALL    PATCH4      ; DI; JP EMLD2
          LD      A,D         
          OR      E           
          SCF     
          RET     Z           
          INC     HL          
          INC     HL          
          PUSH    HL          
          ADD     HL,DE       
          JP      C,ER41      ;I/O ERR
          LD      (EMPTR),HL  
          POP     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          LD      D,B         
          LD      E,C         
          LD      BC,32-2     
          CALL    EMLDD       
          LD      BC,32+2     
          ADD     HL,BC       
          EX      DE,HL       
          LD      (HL),E      ;Save data area adrs
          INC     HL          
          JP      PATCH5      ;LD (HL),D; OR A; EI; RET

;*----------------------
;*  Read RAM data
;*    ent HL:buffer adrs
;*        BC:byte size
;*----------------------
EMRDAT:   EX      DE,HL       
          LD      L,(IY+30)   
          LD      H,(IY+31)   
          INC     HL          
          INC     HL          
          INC     HL          
          CALL    PATCH6      ;DI; CALL EMLDD; EI; RET
          LD      (IY+30),L   
          LD      (IY+31),H   
          OR      A           
          RET     

;*----------------
;*  Write RAM file
;*    HL:inf adrs
;*----------------
EMWINF:   PUSH    AF          
          CALL    SERFLW      
          PUSH    HL          
          LD      HL,2        
          CALL    PATCH7      ; DI; JP EMLD2
          LD      (EMWP0),DE  
          PUSH    DE          
          LD      HL,64+7     
          ADD     HL,DE       
          CALL    EMFREQ      ;Check file space
          POP     DE          
          INC     DE          
          INC     DE          
          POP     HL          ;inf adrs
          LD      BC,64       
          POP     AF          
          CALL    PATCH8      ; CALL EMSVB; EI; RET
          LD      (EMWP1),DE  
          RET     

;*-----------------
;*  Write RAM data
;*    HL:data adrs
;*    BC:data bytes
;*    A0:close flag
;*-----------------
EMWDAT:   PUSH    AF          
          PUSH    HL          
          PUSH    BC          
          LD      HL,(EMWP1)  
          INC     BC          
          INC     BC          
          INC     BC          
          ADD     HL,BC       
          CALL    EMFREQ      
          POP     BC          
          POP     HL          
          LD      DE,(EMWP1)  
          POP     AF          
          PUSH    AF          
          OR      01H         ;data block
          CALL    EMSVB       
          LD      (EMWP1),DE  
          POP     AF          
          BIT     2,A         ;close ?
          RET     Z           ;no
          PUSH    DE          ;yes
          CALL    EMSETU      
          POP     HL          
          LD      DE,(EMWP0)  
          DEC     HL          
          DEC     HL          
          OR      A           
          SBC     HL,DE       
          EX      DE,HL       
          JP      EMSV2       

EMFREQ:   JR      C,ER53A     
          PUSH    HL          
          LD      HL,0        
          CALL    EMLD2       
          OR      A           
          POP     HL          
          SBC     HL,DE       
          RET     C           
ER53A:    JP      ER53        ;No file pace

;*-----------------
;*  delete RAM file
;*-----------------
EMDEL:    LD      HL,(ELMD30) 
          LD      DE,0FFBBH   ; - 69
          ADD     HL,DE       ;HL:=move destination
          CALL    EMLD2       ;DE:=delete size - 2
          EX      DE,HL       ;DE:=move destination
          ADD     HL,DE       
          INC     HL          
          INC     HL          ;HL:=move source
          PUSH    DE          
          PUSH    HL          
          LD      HL,2        
          CALL    EMLD2       
          EX      DE,HL       ;HL:=last use
          POP     DE          ;DE:=move source
          PUSH    DE          
          OR      A           
          SBC     HL,DE       
          INC     HL          
          INC     HL          
          LD      B,H         
          LD      C,L         ;BC:=move bytes
          POP     HL          ;HL:=move source
          POP     DE          ;DE:=move destination
          CALL    EMLDIR      
          DEC     DE          
          DEC     DE          ;DE:=new last-use
          LD      HL,2        
          JP      EMSV2       

;*---------------
;*  write RAM dir
;*---------------
EMWDIR:   LD      HL,(ELMD30) 
          LD      DE,-64      
          ADD     HL,DE       
          EX      DE,HL       
          LD      HL,ELMD     
          LD      BC,32       
          JP      EMSVD       

EM.P0:    EQU     0EAH        
EM.P1:    EQU     0EBH        
;*------------------
;* EMM 1 Byte Write
;*   ent A: data
;*       HL:EMM adrs
;*------------------
EMSV1:    PUSH    BC          
          LD      C,EM.P1     
          LD      B,H         
          OUT     (C),L       
          OUT     (EM.P0),A   
          POP     BC          
          OR      A           
          RET     

;*------------------
;* EMM 1 Byte Read
;*   ent HL:EMM adrs
;*   ext A: dat
;*------------------
EMLD1:    PUSH    BC          
          LD      C,EM.P1     
          LD      B,H         
          OUT     (C),L       
          IN      A,(EM.P0)   
          POP     BC          
          OR      A           
          RET     

;*------------------
;* EMM 2 Byte Write
;*   ent DE:data
;*       HL:EMM adrs
;*------------------
EMSV2:    LD      A,E         
          CALL    EMSV1       
          INC     HL          
          LD      A,D         
          CALL    EMSV1       
          DEC     HL          
          RET     

;*------------------
;* EMM 2 Byte Read
;*   ent HL:EMM adrs
;*       DE:data
;*------------------
EMLD2:    CALL    EMLD1       
          LD      E,A         
          INC     HL          
          CALL    EMLD1       
          LD      D,A         
          DEC     HL          
          RET     

;*---------------------
;* EMM write block
;*   ent HL :data Top
;*       DE :EMM Adrs
;*       BC :byte Size
;*       A  :block flag
;*---------------------
EMSVB:    EX      DE,HL       
          CALL    EMSV1       
          INC     HL          
          LD      A,C         
          CALL    EMSV1       
          INC     HL          
          LD      A,B         
          CALL    EMSV1       
          INC     HL          
          EX      DE,HL       
EMSVD:    EX      DE,HL       
EMSVE:    LD      A,(DE)      
          CALL    EMSV1       
          INC     HL          
          INC     DE          
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,EMSVE    
          EX      DE,HL       
          RET     

;*--------------------
;* EMM BC Byte Read
;*   ent DE :Store Top
;*       HL :EMM Adrs
;*       BC :Byte Size
;*--------------------
EMLDD:    CALL    EMLD1       
          LD      (DE),A      
          INC     HL          
          INC     DE          
          DEC     BC          
          LD      A,B         
          OR      C           
          RET     Z           
          JR      EMLDD       

;*------------------------------
;* EMM BC Byte LDIR
;*   ent HL :EMM source top
;*       DE :EMM destination top
;*       BC :Byte Size
;*------------------------------
EMLDIR:   CALL    EMLD1       ;EMM (HL) Data => Acc
          EX      DE,HL       
          CALL    EMSV1       ;Acc => (DE) EMM
          EX      DE,HL       
          INC     HL          
          INC     DE          
          DEC     BC          
          LD      A,B         
          OR      C           
          RET     Z           ;End
          JR      EMLDIR      

;*       END of original module MON-EMM.ASM
;*============================================================================
;*     START of original module MON-PSG.ASM
;*-----------------------------
;* MZ800-monitor  PSG handler
;* FI:MON-PSG  ver 001  7.26.84
;*-----------------------------
;*
NMAX:     EQU     83          ;µ›√≤ max
PSGA:     EQU     0F2H        
PSG3:     EQU     3F2H        
PSG9:     EQU     9F2H        

          IF      SYS = 0
MUSCH:    EQU     6              ;these EQUATES are NOT assembled for MZ-800
MAXCH:    EQU     8
PSGALL:   EQU     0E9H
PSGOFF:   EQU     4E9H
          ENDIF

          IF     SYS = 1
MUSCH:    EQU     3           ;these EQUATES ARE assembled for the MZ-800
MAXCH:    EQU     4           
PSGALL:   EQU     0F2H        
PSGOFF:   EQU     4F2H        
          ENDIF

;*-----------------------------
;* INTM (music interrupt mode )
;*0 no operation
;*1 music or noise
;*2 sound n.time
;*-----------------------------
INTM:     DB      0           
SBUSY:    DB      0           ;music or noise only
INTC:     DB      0           
;*--------------------------
;*   sound out current table
;*--------------------------
;*    tone 1a
STBL:     DB      80H         ;frequency (l)
          DB      00H         ;frequency (h)
          DB      9FH         ;attenation
;*    tone 2a
          DB      0A0H        ;frequency (l)
          DB      00H         ;frequency (h)
          DB      0BFH        ;attenation
;*    tone 3a
          DB      0C0H        ;frequency (l)
          DB      00H         ;frequency (h)
STN0:     DB      0DFH        ;attenation
          ;*
          IF     SYS = 0      ;table not assembled for the MZ-800
          ;* tone 1b
          DB     80H          ;frequency (l)
          DB     00H          ;frequency (h)
          DB     9FH          ;attenation
          ;* tone 2b
          DB     0A0H         ;frequency (l)
          DB     00H          ;frequency (h)
          DB     0BFH         ;attenation
          ;* tone 3b
          DB     0C0H         ;frequency (l)
          DB     00H          ;frequency (h)
STN1:     DB     0DFH         ;attenation
          ENDIF

;**-----------
;* play table
;*-----------
PTBL:     DB      00H         ;ch no.
          DB      00H         ;atc0
          DB      255         ;atc1
          DB      00H         ;emva(l)
          DB      00H         ;emva(h)
          DB      00H         ;att
          DB      00H         ;length0
          DB      00H         ;tempo0
          DB      08H         ;length1
          DB      0DH         ;tempo1
          DB      00H         ;qbuf(l)
          DB      00H         ;qbuf(h)
          DB      08H         ;emvp
          DB      00H         ;status
          DB      00H         ;vol
          DB      00H         ;reserve
          DB      01H         ;ch no.
          DB      0,255,0,0,0,0,0,8 ;ch1 (was DEFS 15)
          DB      13,0,0,8,0,0,0 
          DB      02H         ;ch no.
          DB      0,255,0,0,0,0,0,8 ;ch2 (was DEFS 15)
          DB      13,0,0,8,0,0,0 
          DB      03H         ;ch no.
          DB      0,255,0,0,0,0,0,8 ;noise (was DEFS 15)
          DB      13,0,0,8,0,0,0 

          IF      SYS = 0     ;table not assembled for the MZ-800
          DB      04H         ;ch no.
          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;ch3
          DB      05H         ;ch no.
          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;ch4
          DB      06H         ;ch no.
          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;ch5
          DB      07H         ;ch no.
          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;noise2
          ENDIF

;*-----------------
;*  ontyo     table
;*-----------------
LTBL:     DB      1           ;0
          DB      2           ;1
          DB      3           ;2
          DB      4           ;3
          DB      6           ;4
          DB      8           ;5
          DB      12          ;6
          DB      16          ;7
          DB      24          ;8
          DB      32          ;9
;*------------
;* tempo table
;*------------
          DB      23          ;1  64
          DB      20          ;2  74
          DB      17          ;3  90
          DB      13          ;4  114
          DB      10          ;5  152
          DB      7           ;6  222
          DB      3           ;7  450
;*-------------------------
;*    emvelop pattern table
;*---------------------
;*    ATT Õ›Ãﬁ›    code
;*           0        3
;*          -1        4
;*          +1        5
;*           r        0
;*         max        1
;*         min        2
;*---------------------
ETBL:     DB      00H         ;emvp 0
          DB      05H         
          DB      03H         
          DB      03H         ;dummy

          DB      0FH         ;emvp 1
          DB      04H         
          DB      01H         
          DB      03H         ;dummy

          DB      00H         ;emvp 2
          DB      05H         
          DB      02H         
          DB      00H         

          DB      0FH         ;emvp 3
          DB      04H         
          DB      01H         
          DB      00H         

          DB      00H         ;emvp 4
          DB      05H         
          DB      02H         
          DB      03H         

          DB      0FH         ;emvp 5
          DB      04H         
          DB      03H         
          DB      03H         ;dummy

          DB      00H         ;emvp 6
          DB      05H         
          DB      04H         
          DB      00H         

          DB      0FH         ;emvp 7
          DB      04H         
          DB      05H         
          DB      00H         

          DB      00H         ;emvp 8
          DB      03H         
          DB      03H         
          DB      00H         

;*-----------------
;*  frequency table
;*-----------------
NTBL:     DW      3F00H       ; A
          DW      3B07H       ; A#
          DW      3802H       ; B
;*--------------
;*      octave 1
;*--------------
          DW      340FH       ; C
          DW      3200H       ; C#
          DW      2F03H       ; D
          DW      2C09H       ; D#
          DW      2A01H       ; E
          DW      270BH       ; F
          DW      2507H       ; F#
          DW      2306H       ; G
          DW      2106H       ; G#
          DW      1F08H       ; A
          DW      1D0CH       ; A#
          DW      1C01H       ; B
;*--------------
;*      octave 2
;*--------------
          DW      1A08H       ; C
          DW      1900H       ; C#
          DW      1709H       ; D
          DW      1604H       ; D#
          DW      1500H       ; E
          DW      130DH       ; F
          DW      120CH       ; F#
          DW      110BH       ; G
          DW      100BH       ; G#
          DW      0F0CH       ; A
          DW      0E0EH       ; A#
          DW      0E00H       ; B
;*--------------
;*      octave 3
;*--------------
          DW      0D04H       ; C
          DW      0C08H       ; C#
          DW      0B0DH       ; D
          DW      0B02H       ; D#
          DW      0A08H       ; E
          DW      090FH       ; F
          DW      0906H       ; F#
          DW      080DH       ; G
          DW      0805H       ; G#
          DW      070EH       ; A
          DW      0707H       ; A#
          DW      0700H       ; B
;*--------------
;*      octave 4
;*--------------
          DW      060AH       ; C
          DW      0604H       ; C#
          DW      050EH       ; D
          DW      0509H       ; D#
          DW      0504H       ; E
          DW      040FH       ; F
          DW      040BH       ; F#
          DW      0407H       ; G
          DW      0403H       ; G#
          DW      030FH       ; A
          DW      030BH       ; A#
          DW      0308H       ; B
;*--------------
;*      octave 5
;*--------------
          DW      0305H       ; C
          DW      0302H       ; C#
          DW      020FH       ; D
          DW      020DH       ; D#
          DW      020AH       ; E
          DW      0208H       ; F
          DW      0205H       ; F#
          DW      0203H       ; G
          DW      0201H       ; G#
          DW      010FH       ; A
          DW      010EH       ; A#
          DW      010CH       ; B
;*--------------
;*      octave 6
;*--------------
          DW      010AH       ; C
          DW      0109H       ; C#
          DW      0108H       ; D
          DW      0106H       ; D#
          DW      0105H       ; E
          DW      0104H       ; F
          DW      0103H       ; F#
          DW      0102H       ; G
          DW      0101H       ; G#
          DW      0100H       ; A
          DW      000FH       ; A#
          DW      000EH       ; B
;*--------------------
MSTBL:    DW      0BF9FH      
          DW      0FFDFH      
;*--------------------
TSOUT:    DB      80H         ;ch 0
          DB      00H         
          DB      90H         ;att
TSOUTC:   DB      00H         ;counter(l)
          DB      00H         ;counter(h)
;*------------------------
;* Music interrupt routine
;*------------------------
PSGINT:   PUSH    IY          
          CALL    INT0        
          POP     IY          
          EI      
          RETI    

INT0:     CALL    PUSHRA      
          CALL    MSTART      ;8253 intialize
          LD      A,(INTM)    
          OR      A           
          JP      Z,MSTOP0    
          DEC     A           
          JP      NZ,SDINT    ;skip if sound out
          LD      BC,PSG9     ;psg data out
          LD      HL,STBL     
          OTIR    

          IF      SYS = 0     ;instructions not assembled for the MZ-800
          LD      B,9
          INC     C
          OTIR
          ENDIF

          LD      B,8         
          LD      A,(SBUSY)   
          OR      A           
          JP      Z,MSTOP0    ;channel all close
          LD      C,A         
INT1:     DEC     B           
          RET     M           
          RLC     C           
          JR      NC,INT1     
          PUSH    BC          
          LD      A,B         
          CALL    INTER       
          BIT     0,(IY+13)   
          CALL    Z,NINT      
          CALL    MINT        
          POP     BC          
          JR      INT1        

;*-----------------
;*  Envelop control
;*-----------------
NINT:     DEC     (HL)        ;HL=chx act0
          RET     NZ          
          INC     HL          ;new couter set
          LD      A,(HL)      ;load atc1
          DEC     HL          
          LD      (HL),A      ;save atc0
          INC     HL          
          INC     HL          
          LD      E,(HL)      ;HL=enva
          INC     HL          
          LD      D,(HL)      ;HL=enva+1
          EX      DE,HL       
NINT1:    LD      A,(HL)      ;env Õ›Ãﬁ› data
          OR      A           ;data check 0
          JR      NZ,NINT2    ;noskip if repeat
          DEC     HL          
          DEC     HL          
          JR      NINT1       

NINT2:    EX      DE,HL       ;de=curent emva
          INC     HL          
          DEC     A           
          JR      Z,NINT3     ;skip if max Acc=1
          DEC     A           
          JR      Z,NINT5     ;skip if min Acc=2
          DEC     A           
          RET     Z           ;Õ›Ãﬁ› 0  Acc=3
          DEC     A           ;Acc=4
          LD      A,(HL)      ;att data
          JR      Z,NINT4     ;skip if dec att
          INC     A           ;Acc=5
          CP      15          ;max
          JR      Z,NINT7     
          JR      C,NINT7     
NINT3:    LD      A,15        ;maximam
          JR      NINT6       
NINT4:    DEC     A           ;dec att
          JP      M,NINT5     
          LD      C,(IY+14)   ;vol minimum
          CP      C           
          JR      NC,NINT7    
NINT5:    LD      A,(IY+14)   ;minimum
NINT6:    INC     DE          ;de=next curent emva
NINT7:    LD      (HL),A      ;new att data
          DEC     HL          
          LD      (HL),D      
          DEC     HL          
          LD      (HL),E      
ATTSET:   AND     0FH         
          LD      B,A         ;acc=att data
ATTS1:    LD      A,(IX+2)    ;stbl att
          AND     0F0H        
          OR      B           
          LD      (IX+2),A    ;stbl att
          RET     

;*------------------------------
;*  new data interpret routine
;*------------------------------
MINT:     DEC     (IY+6)      ;length0
          RET     NZ          
          DEC     (IY+7)      ;tempo0
          LD      A,(IY+8)    ;length1
          LD      (IY+6),A    ;length counter preset
          RET     NZ          
          LD      A,(IY+9)    ;tempo1
          LD      (IY+7),A    ;tempo counter preset
          LD      E,(IY+10)   ;que addr(l)
          LD      D,(IY+11)   ;que addr(h)
MINT1:    LD      A,(DE)      
          INC     DE          
          CP      0FFH        
          JR      Z,MINT2     
          CP      0A0H        
          JR      Z,MINT3     
          CP      90H         
          JR      NC,MINT4    
          CP      80H         
          JR      NC,MINT5    
          CP      60H         
          JR      NC,MINT6    
          SUB     9           
          LD      (IY+10),E   ;que addr (l)
          LD      (IY+11),D   ;que addr (h)
          SET     0,(IY+13)   ;rflag set
          JR      C,MINT7     
          RES     0,(IY+13)   ;rflag reset
          CALL    SETNO       ;Nn
MINT7:    LD      A,(IY+2)    ;att
          LD      (IY+1),A    
          LD      A,(IY+8)    ;length
          LD      (IY+6),A    
          LD      A,(IY+9)    ;tempo
          LD      (IY+7),A    
          BIT     0,(IY+13)   
          JR      NZ,MEND     
          LD      A,(IY+12)   ;emv pattern
          LD      BC,ETBL     
          ADD     A,A         ;*2
          ADD     A,A         ;*4
          LD      H,0         
          LD      L,A         
          ADD     HL,BC       ;HL=ETBL+4*A
          LD      A,(HL)      
          OR      A           
          JR      NZ,MINT71   
          LD      A,(IY+14)   ;vol minimum
MINT71:   LD      (IY+5),A    ;att
          CALL    ATTSET      
          INC     HL          
          LD      (IY+3),L    ;emva (l)
          LD      (IY+4),H    ;emva (h)
          RET     

MINT3:    LD      A,(DE)      ;Mn
          INC     DE          
          LD      (IY+2),A    ;atc1
MINT11:   JR      MINT1       

MINT2:    CALL    BRESET      ;channel reset
MEND:     LD      A,0FH       
          JP      ATTSET      

MINT4:    SUB     90H         ;Sn
          LD      (IY+12),A   ;curent emv no.
          JR      MINT11      

MINT5:    SUB     80H         ;Vn
          CPL     
          AND     0FH         
          LD      (IY+14),A   ;vol minimum
          JR      MINT11      

;*------------------
;*  tempo  &  length
;*------------------
MINT6:    SUB     60H         ;Tn,Ln
          LD      B,0         
          LD      C,A         
          LD      HL,LTBL     
          ADD     HL,BC       
          CP      0AH         
          LD      A,(HL)      
          JR      NC,MINT61   
          LD      (IY+8),A    ;length1
          JR      MINT11      
MINT61:   LD      (IY+9),A    ;tempo1
          JR      MINT11      

;*----------------------------
;*    onpu  set
;*     acc  = onpu map data
;*     ix   = set mout tbladdr
;*----------------------------
SETNO:    ADD     A,A         ;*2
          LD      HL,NTBL     
          LD      B,0         
          LD      C,A         
          ADD     HL,BC       
          LD      B,(HL)      
          LD      A,(IX+0)    
          AND     0F0H        
          OR      B           
          LD      (IX+0),A    
          INC     HL          
          LD      A,(HL)      
          LD      (IX+1),A    
          RET     

;*---------------------
;*  SOUND=(reg,data)
;*    ent A.... reg+80H
;*        DE... data
;*
;*  SOUND n,time
;*    ent A.... n
;*        DE... time
;*---------------------

MSOUND:   OR      A           
          JP      P,SOUT      
          AND     0FH         
          LD      C,PSGA      ;psg-a

          IF      SYS = 0     ;instructions not assembled for the MZ-800
          CP      8
          JR      C,MSND.P
          SUB     8
          INC     C           ;C=psg sel, A=reg#.
          ENDIF

MSND.P:   ADD     A,A         
          ADD     A,A         
          ADD     A,A         
          ADD     A,A         
          OR      80H         
          LD      B,A         ;B = 1rrr0000
          BIT     4,A         
          JR      NZ,MSND.A   ;att
          CP      0E0H        
          JR      Z,MSND.N    ;noise ctrl
          LD      A,D         ;freq
          CP      04H         
          JR      NC,MER3     
          LD      A,E         
          AND     0FH         
          OR      B           ;1rrrffff
          OUT     (C),A       
          LD      A,D         
          LD      B,4         
MSND.R    RL      E           
          RLA     
          DJNZ    MSND.R      
          OUT     (C),A       ;0fffffff
          RET     

;*------------------------------------------------------
;* Top of p.254 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
MSND.N:   BIT     3,E         
          JR      NZ,MER3     
MSND.A:   LD      A,E         
          AND     0F0H        
          OR      D           
          JR      NZ,MER3     
          LD      A,E         
          OR      B           
          OUT     (C),A       ;1rrrcccc
          RET     

MER3:     JP      ER03M       

;*--------
;*  sout
;*--------

SDINT:    LD      HL,(TSOUTC) 
          DEC     HL          
          LD      (TSOUTC),HL 
          LD      A,L         
          OR      H           
          RET     NZ          
          JP      MSTOP0      

;*----------
;* SOUND n,l
;*----------
SOUT:     LD      C,A         
          LD      A,D         
          OR      E           
          RET     Z           
          LD      A,C         
          LD      IX,TSOUT    
          CP      NMAX+1      
          RET     NC          
          SUB     9           
          PUSH    AF          
          LD      A,90H       
          JR      NC,SOUT1    
          LD      A,9FH       
SOUT1:    LD      (IX+2),A    ;TSOUT att
          CALL    MWAIT0      
          POP     AF          
          CALL    NC,SETNO    ;skip if not rest
          DI      
          LD      A,2         
          LD      (INTM),A    
          LD      (TSOUTC),DE 
          LD      HL,TSOUT    
          LD      BC,PSG3     ;psg-a out
          OTIR    
          CALL    MSTART      
          EI      
          RET     

;*-------------------------
;*     Interpret  point set
;*   in Acc=channel
;*   exit ix:stbl
;*        iy:ptbl
;*        hl:ptbl+1
;*-------------------------
INTER:    PUSH    BC          
          PUSH    AF          
          CP      3           
          JR      C,INTER1    
          DEC     A           

          IF      SYS = 0            ;instructions not assembled for the MZ-800
          CP      6
          JR      NZ,INTER1
          DEC     A
          ENDIF

INTER1:   LD      HL,STBL     
          LD      B,A         
          ADD     A,A         ;*2
          ADD     A,B         ;*3
          LD      C,A         
          LD      B,0         
          ADD     HL,BC       
          PUSH    HL          
          POP     IX          
          POP     AF          
          ADD     A,A         ;*2
          ADD     A,A         ;*4
          ADD     A,A         ;*8
          ADD     A,A         ;*16
          LD      HL,PTBL     
          LD      B,0         
          LD      C,A         
          ADD     HL,BC       
          PUSH    HL          
          POP     IY          
          INC     HL          
          POP     BC          
          RET     

;*-------------
;*  play, noise
;*-------------

PLAY:     CP      0FFH        
          JR      NZ,PLY0     
          LD      A,MAXCH-1   
PLYALL:   PUSH    AF          
          PUSH    DE          
          CALL    PLY0        
          POP     DE          
          POP     AF          
          DEC     A           
          JP      M,PSGON     
          JR      PLYALL      

PLY0:     PUSH    AF          
          LD      HL,STN0     

          IF      SYS = 0       ;instructions not assembled for the MZ-800
          CP      4
          JR      C,PLY00
          LD      HL,STN1
          ENDIF

PLY00:    CP      3           
          JR      Z,PLY1      

          IF      SYS = 0       ;instructions not assembled for the MZ-800
          CP      7
          JR      Z,PLY1
          ENDIF

          LD      A,0DFH      
          JR      PLY2        

PLY1:     LD      A,0E7H      ;noise channel out
          OUT     (PSGALL),A  
          LD      A,0FFH      
PLY2:     LD      (HL),A      ;STN0 or STN1
          DI      
          LD      A,1         
          LD      (INTM),A    
          POP     AF          
          CALL    INTER       
          CALL    BSET        
          CALL    MINT1       
          EI      
          RET     

PSGON:    DI      
          LD      A,(INTM)    
          OR      A           
          CALL    NZ,MSTART   
          EI      
          RET     

BRESET:   LD      B,86H       
          JR      BSET0       

BSET:     LD      B,0C6H      
BSET0:    LD      HL,SBUSY    
          LD      A,(IY+0)    
          OR      A           
          RLCA    
          RLCA    
          RLCA                ;00xxx000
          OR      B           ;10xxx110 or 11xxx110
          LD      (BSET1),A   
          DB      0CBH        ;SET n,(HL) or reset
BSET1:    DB      0           
          RET     

;*----------------------------------
;* sft+break or error or music stop
;*----------------------------------
MLDSP:    
MSTOP:    CALL    PUSHR       ;routine called by RAM Monitor as MLDSP !
MSTOP0:   XOR     A           
          LD      (INTM),A    
          LD      (SBUSY),A   
          LD      BC,PSGOFF   
          LD      HL,MSTBL    
          OTIR    
          LD      B,MUSCH     
          LD      HL,STBL+2   
MSTOP1:   LD      A,(HL)      
          AND     0F0H        
          OR      0FH         
          LD      (HL),A      
          INC     HL          
          INC     HL          
          INC     HL          
          DJNZ    MSTOP1      
          LD      A,3         
          OUT     (0FCH),A    ;pio disenable
          XOR     A           

          IF      SYS = 1     ;RET instruction assembled for the MZ-800
          RET                 ;8253 gate no effect
          ENDIF

          IF      SYS = 0     ;instructions not assembled for the MZ-800
          LD      HL,0E008H   ;mz-700 compatible mode
          LD      (HL),A      ;8253 gate disable
          RET
          ENDIF

;*-----------
;* music wait
;*-----------
MWAIT:    
MWAIT0:   LD      A,(INTM)    
          OR      A           
          RET     Z           
MWAIT1:   RST     18H         
          DB      .BREAK      
          JR      NZ,MWAIT    
          JP      BREAKZ      

;*----------------------------------
;*  SVC .MCTRL ; music control
;*    B=0: init
;*    B=1: psgon
;*    B=2: stop
;*    B=3: wait
;*----------------------------------
MCTRL:    DEC     B           ;this routine is called only by DF 23H !
          JP      Z,PSGON     
          DEC     B           
          JR      Z,MSTOP     ;1
          DEC     B           
          JR      Z,MWAIT0    ;2
;*------------------
;* PSG power on init
;*------------------
PSGPWR:   CALL    MSTOP       
          LD      BC,5FCH     
          IF      SYS = 0
          LD      HL,PIOTBL1
          ENDIF
          IF      SYS = 1
          LD      HL,PIOTBL2
          ENDIF
          OTIR    
          LD      DE,MUINID   
          LD      A,0FFH      
          JP      PLAY        

PIOTBL1:  IF      SYS = 0       ;instruction not assembled for the MZ-800
          DB      0FCH          ;Vector
          DB      0FFH          ;mode 3 (bit mode)
          DB      3FH           ;I/O
          DB      37H           ;interrupt control
          DB      0EFH          ;interrupt mask
          ENDIF

MSTART:   ; Global scope for label needs to be outside IF block.
          IF      SYS = 0       ;instruction not assembled for the MZ-800
          OUT     (0E3H),A
          LD      A,30H
          LD      HL,0E007H
          LD      (HL),A        ;8253 control
          LD      BC,22A5H      ;10ms =22F6H
          LD      L,4           ;HL=E004H
          LD      (HL),C        ;8253 time const
          LD      (HL),B
          DEC     HL            ;HL=E003H
          LD      (HL),4        ;8253 int disable
          LD      (HL),0        ;8253 music disable
          LD      A,01H
          LD      L,8           ;HL=E008H
          LD      (HL),A        ;8253 gate enable
          LD      A,83H
          OUT     (0FCH),A      ;pio int enable
          OUT     (0E1H),A
          RET
          ENDIF                 ;END of section not assembled for the MZ-800
;MSTART:
          IF      SYS = 1       ;start of section assembled for the MZ-800
          LD      HL,PIOTBL2   
          LD      BC,5FCH     
          OTIR    
          LD      HL,CTCTBL   
          LD      B,6         
          JP      IOOUT       
          ENDIF

PIOTBL2:  IF      SYS = 1        ;start of section assembled for the MZ-800
          DB      0FCH        ;Vector
          DB      0FFH        ;mode 3 (bit mode)
          DB      3FH         ;I/O
          DB      17H         ;interrupt control
          DB      0EFH        ;interrupt mask
          ENDIF
;*
CTCTBL:   IF      SYS = 1        ;start of section assembled for the MZ-800
          DW      0D730H      
          DW      0D4B0H      ;10 ms =2B4CH
          DW      0D42AH      
          DW      0D304H      
          DW      0D300H      
          DW      0FC83H      
          ENDIF
;*
MUINID:   DB      65H         ;L5
          DB      6DH         ;T4
          DB      98H         ;S8
          DW      0FFA0H      ;M255
          DB      0FFH        ;END

CTRLG:    ; Defined outside the IF block to be globally visible.
          IF      SYS = 0     ;this section is not assembled for the MZ-800
          CALL    PUSHR
          LD      (CTRLG9+1),SP
          RST     18H
          DB      .DI
          LD      SP,IBUFE
          OUT     (0E4H),A    ;K/C mapping
          CALL    02BEH       ;ROM MLDSP
          LD      A,1
          LD      DE,0E003H
          LD      (DE),A      ;8253 music gate on
          LD      HL,03F9H
          CALL    02AEH       ;ROM MLDST+3
          LD      BC,18H
CTRLG2:   EX      (SP),HL     ;wait
          DJNZ    CTRLG2
          DEC     C
          JR      NZ,CTRLG2
          CALL    02BEH       ;ROM MLDSP
          XOR     A
          LD      (DE),A      ;8253 music gate off
          OUT     (0E0H),A    ;K/C mapping
          OUT     (0E1H),A
          RST     18H
          DB      .EI
CTRLG9:   LD      SP,0        ;xxx
          RET
          ENDIF               ;end of section not assembled for the MZ-800

;*------------------------------------------------------
;* Top of p.261 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
;* BELL (BEEP)  uses 8253
;*-----------------------
          IF     SYS = 1      ;this section is assembled for the MZ-800
          CALL    PUSHR       
          RST     18H         
          DB      .DI         
          LD      HL,BEEP0    
          LD      B,4         
          CALL    IOOUT       
          LD      BC,18H      
CTRLG1:   EX      (SP),HL     
          DJNZ    CTRLG1      
          DEC     C           
          JR      NZ,CTRLG1   
          LD      HL,BEEP1    
          LD      B,2         
          CALL    IOOUT       
          RST     18H         
          DB      .EI         
          RET     

BEEP0:    DW      0D736H      
          DW      0D301H      
          DW      0D4F9H      
          DW      0D403H      

BEEP1:    DW      0D736H      
          DW      0D300H      
          ENDIF
;*-----------------
;*  tempo set
;*         acc=1-7
;*----------------
QTEMP:    IF      SYS = 1
          CALL    PUSHRA      
          LD      DE,TEMPOW   
          AND     0FH         
          ADD     A,69H       
          LD      (DE),A      
          LD      B,3         
          RST     18H         ;MWAIT
          DB      .MCTRL      
          LD      A,0FFH      ;Channel all
          RST     18H         
          DB      .PLAY       
          LD      B,1         
          RST     18H         ;PSGON
          DB      .MCTRL      
          RET     

TEMPOW:   DB      0           ;(was DEFS 1)
          DB      0FFH        

          ENDIF                  ;End of section assembled on the MZ-800

;*       END of original module MON-PSG.ASM
;*============================================================================
;*    START of original module MON-GRPH.ASM    
;*--------------------------------
;* MZ-800 Monitor  Graphic-package
;* FI:MON-GRPH  ver 1.0A 9.05.84
;*--------------------------------
;*------------
;* INIT "CRT:
;*------------
CRTINI:   CALL    TEST1       
          DB      'M'         
          JR      Z,CRMD      
          OR      A           
          JR      Z,ICRT      
          CP      'B'         
          JP      NZ,ER03M    
;*------------------
;* CRT palette block
;*------------------
PBLOCK:   XOR     A           
          LD      (PALBK),A   
          LD      A,(CRTMD2)  
          CP      2           
          JP      NZ,ER68     
          INC     HL          
          LD      B,4         
          CALL    DEVASC      
          LD      (PALBK),A   
          RST     18H         
          DB      .DPLBK      
          JR      CRTLP       
;*-----------------------
;* CRT mode
;* 1.....320x200  4 Color
;* 2.....320x200 16 Color
;* 3.....640x200  2 Color
;* 4.....640x200  4 Color
;*-----------------------
CRMD:     LD      B,5         
          CALL    DEVASC      
          OR      A           
          JR      Z,ER3JP     
          LD      B,A         
          RST     18H         
          DB      .DSMOD      
          JP      C,ER68      
          LD      A,B         
          LD      (CRTMD2),A  
          XOR     A           
          LD      (INPFLG),A  
          SCF     
CRMD1:    ADC     A,A         
          DJNZ    CRMD1       
          LD      (CRTMD1),A  
          CALL    ICRT2       
CRTLP:    CALL    TEST1       
          DB      0           
          RET     Z           
          CP      ','         
          INC     HL          
          JR      Z,CRTINI    
ER3JP:    JP      ER03M       

ICRT:     LD      A,(CRTMD2)  
          RST     18H         
          DB      .DSMOD      
ICRT2:    CALL    COLINI      
          XOR     A           
          LD      (PALBK),A   
          RST     18H         
          DB      .DPLBK      
          RET     

COLINI:   LD      A,(CRTMD1)  
          LD      B,3         
          RRA     
          JR      C,CI1       
          LD      B,15        
          RRA     
          JR      C,CI1       
          LD      B,1         
          RRA     
          JR      C,CI1       
          LD      B,3         
CI1:      LD      A,B         
          LD      (SELCOL),A  
          RST     18H         
          DB      .DCOL       
          RET     

;*-------------------
;* BYTE CONVERT TABLE
;*-------------------
TDOTL:    DB      0FFH        
          DB      0FEH        
          DB      0FCH        
          DB      0F8H        
          DB      0F0H        
          DB      0E0H        
          DB      0C0H        
          DB      80H         
;*
TDOTR:    DB      01H         
          DB      03H         
          DB      07H         
          DB      0FH         
          DB      1FH         
          DB      3FH         
          DB      7FH         
          DB      0FFH        
;*
TDOTN:    DB      01H         
          DB      02H         
          DB      04H         
          DB      08H         
          DB      10H         
          DB      20H         
          DB      40H         
          DB      80H         

;*--------------------------
;*   //  64 - 32  TRANS   //
;*--------------------------
CHGRPH:   LD      BC,703H     
          LD      HL,CHGTBL   
          JP      PATCH       
;*
CHGTBL:   DW      SYMS42+1    ;word patch table
          DW      0BE80H      
          DW      9F40H       

          DW      RNGCK0+1    
          DW      -640        
          DW      -320        

          DW      LRBSR       
          DW      640         
          DW      320         

          DW      BFL0+1      
          DW      80          
          DW      40          

          DW      BFL1+1      
          DW      80          
          DW      40          

          DW      BFC0+1      
          DW      -640        
          DW      -320        

          DW      BFC1+1      
          DW      639         
          DW      319         

;*------------------
;*  byte patch table
;*------------------
          DW      ADCH        ;adrs
          DB      29H         ;640 ADD HL,HL
          DB      00H         ;320

          DW      SYMS21+1    
          DB      80          
          DB      40          

          DW      SYMS41+1    
          DB      80          
          DB      40          
;*--------------------------------
;*     address  calc
;*       ent.   de=x (0-13FH,27FH)
;*              hl=y (0-C7H)
;*
;*       ext.   hl=vram addr
;*               a=vram bit
;*               c=de/8
;*--------------------------------
ADCH:     ADD     HL,HL       ;NOP
          LD      A,E         
          AND     7           
          LD      B,A         
          LD      A,E         
          AND     0F8H        
          ADD     A,D         
          RRCA    
          RRCA    
          RRCA    
          LD      C,A         
          LD      A,B         
          LD      B,80H       ;vramh
          LD      D,H         
          LD      E,L         
          ADD     HL,HL       
          ADD     HL,HL       
          ADD     HL,DE       
          ADD     HL,HL       
          ADD     HL,HL       
          ADD     HL,HL       ;HL=HL*40
          ADD     HL,BC       
          RET     

;*--------------------------
;*   READ  POINT
;*    Ent:DE=X (0-13FH,27EH)
;*        HL=Y (0-C7H)
;*--------------------------
QPOINT:   CALL    RNGCK       
          JP      C,OVER      
          CALL    ADCH        
          RLCA    
          RLCA    
          RLCA    
          OR      46H         
          LD      (PNT2+1),A  
          LD      C,LSRF      
          LD      A,(MAXCF)   
          LD      B,A         
          DI      
          IN      A,(LSE0)    
          XOR     A           
PNT1:     RR      B           
          JR      C,PNT4      
          OUT     (C),B       
          OR      A           
PNT2:     BIT     0,(HL)      ;bit n,(hl)
          JR      Z,PNT3      
          SCF     
PNT3:     RLA     
          JR      PNT1        

PNT4:     LD      B,A         
          IN      A,(LSE1)    
          EI      
          LD      A,(CPLANE)  
          AND     B           
          LD      B,A         
          LD      A,(DMD)     
          CP      6           
          LD      A,B         
          RET     NZ          
          CP      4           
          RET     C           
          SUB     2           
          RET     

;*-------------------------
;*  MODE SET (PWMODE,GMODE)
;*    ent.   A= 0  RESET
;*           A<>0  SET
;*-------------------------
SETW:     LD      A,0FFH      
MODSET:   PUSH    BC          
          OR      A           
          LD      A,(GMODE)   
          LD      C,A         
          LD      A,(PWMODE)  
          JR      Z,RSET1     
          OR      A           
          LD      A,0C0H      ;w0 pset
          JR      Z,SET1      
          LD      A,40H       ;w1 or
SET1:     OR      C           
          OUT     (LSWF),A    ;Write mode set
          POP     BC          
          RET     

RSET1:    OR      A           
          LD      A,60H       ;w1 reset
          JR      NZ,SET1     
          LD      A,(CPLANE)  
          LD      B,A         
          LD      A,C         ;reverse  color
          CPL     
          AND     B           ;mask color
          OR      0C0H        ;w0 pset mode
          OUT     (LSWF),A    ;Write mode set
          POP     BC          
          RET     

;*--------------------------
;* Point Write/Erase
;*    Ent:DE=X (0-13FH,27EH)
;*       HL=Y (0-C7H)
;*--------------------------
PSET:     CALL    MODSET      
PSET0:    CALL    RNGCK       
          JP      C,OVER      
          CALL    ADCH        
          EX      DE,HL       
          LD      HL,TDOTN    
          LD      B,0         
          LD      C,A         
          ADD     HL,BC       
          DI      
          IN      A,(LSE0)    
          LDI     
          IN      A,(LSE1)    
          EI      
          XOR     A           
          RET     

;*--------------------------
;* RANGE  CHECK
;*    Ent:DE=X (0-13FH,27EH)
;*        HL=Y (0-C7H)
;*    ext:if over then  CF=1
;*--------------------------
RNGCK:    PUSH    BC          
          PUSH    DE          
          PUSH    HL          
          LD      A,H         
          RLCA    
          JR      C,RNGER     
          LD      BC,-200     
          ADD     HL,BC       
          JR      C,RNGER     
          LD      A,D         
          RLCA    
          JR      C,RNGER     
          EX      DE,HL       
RNGCK0:   LD      BC,-640     ;-320
          ADD     HL,BC       
RNGER:    POP     HL          
          POP     DE          
          POP     BC          
          RET     

;*----------------------
;* Draw  line
;*    ent  DE':X0, DE:X
;*         HL':Y0, HL:Y
;*         A  := 0 BLINE
;*             <>0  LINE
;*    ext  DE':X
;*         HL':Y
;*----------------------
X0:       EQU     KEYBF       ;2
DX:       EQU     X0+2        ;2
XDIRE:    EQU     DX+2        ;1
Y0:       EQU     XDIRE+1     ;2
DY:       EQU     Y0+2        ;2
YDIRE:    EQU     DY+2        ;1

WLINE0:   LD      A,0FFH      
;*------------------------------------------------------
;* Top of p.272 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
WLINE:    CALL    MODSET      
          PUSH    DE          
          PUSH    HL          
          EXX     
          LD      (X0),DE     
          LD      (Y0),HL     
          EXX     
          PUSH    HL          ;y
          PUSH    DE          ;x
          EX      DE,HL       
          LD      HL,(Y0)     
          CALL    PLS         
          LD      (YDIRE),A   
          LD      (DY),HL     
          POP     DE          ;x
          JP      NC,WYLIN    ;skip if y=y0
          PUSH    HL          ;dy
          LD      HL,(X0)     
          CALL    PLS         
          LD      (XDIRE),A   
          LD      (DX),HL     
          POP     BC          ;dy
          POP     DE          ;y
          JP      NC,WTLIN    ;skip if x=x0
          XOR     A           
          SBC     HL,BC       
          JR      NC,WLIN04   ;skip if dx>dy
          LD      HL,X0       ;parameter change
          LD      DE,Y0       
          LD      B,5         
WLIN02:   LD      A,(DE)      
          LD      C,(HL)      
          LD      (HL),A      
          LD      A,C         
          LD      (DE),A      
          INC     HL          
          INC     DE          
          DJNZ    WLIN02      
          LD      A,0EBH      ;ex de,hl
WLIN04:   LD      (PLOT0),A   
          LD      (PLOT1),A   
          LD      A,(YDIRE)   
          AND     A           
          LD      A,23H       ;inc hl
          JR      Z,DIRE1     
          LD      A,2BH       ;dec hl
DIRE1:    LD      (PP2),A     
          LD      A,(XDIRE)   
          AND     A           
          LD      A,13H       ;inc de
          JR      Z,DIRE2     
          LD      A,1BH       ;dec de
DIRE2:    LD      (PP1),A     
          EXX     
          LD      HL,(DX)     ;initial parm set
          LD      D,H         
          LD      E,L         
          SRL     H           
          RR      L           
          LD      BC,(DY)     
          EXX     
          LD      HL,(Y0)     ;first point  set
          LD      DE,(X0)     
          LD      BC,(DX)     
;*---------------------------------------------------------
;* The original source names the entry point below as PLOT
;* This creates a very nasty problem with duplicate labels !
;*---------------------------------------------------------
PLOT0:    EX      DE,HL       ;dynamic byte EX DE,HL or NOP
          PUSH    HL          
          PUSH    DE          
          PUSH    BC          
          CALL    PSET0       
          POP     BC          
          POP     DE          
          POP     HL          
PLOT1:    EX      DE,HL       ;dynamic byte EX DE,HL or NOP
          DEC     BC          
          LD      A,B         
          INC     A           
          JR      Z,FINW      ;skip if end of line
;*-------------
;* pointer calc
;*-------------
PP1:      DB      0           ;INC DE or DEC DE (was DEFS 1)
          EXX     
          OR      A           
          SBC     HL,BC       
          EXX     
          JP      NC,PLOT0    
          EXX     
          ADD     HL,DE       
          EXX     
PP2:      DB      0           ;INC HL or DEC HL (was DEFS 1)
          JP      PLOT0       

FINW:     EXX     
          POP     HL          
          POP     DE          
          EXX     
          RET     

WYLIN:    POP     HL          ;Y
WYLIN0:   CALL    WBOXSB      
          CALL    WBOXSB      
          CALL    YLINE       
          JR      FINW        

WTLIN:    EX      DE,HL       
          LD      DE,(X0)     
          JR      WYLIN0      

PLS:      LD      A,H         
          ADD     A,40H       
          LD      H,A         
          LD      A,D         
          ADD     A,40H       
          LD      D,A         
          OR      A           
          SBC     HL,DE       
          JR      C,PLS1      
          LD      A,H         
          OR      L           
          RET     Z           
OVER:     LD      A,0FFH      
          SCF     
          RET     

PLS1:     OR      A           
          EX      DE,HL       
          LD      HL,0        
          SBC     HL,DE       
          XOR     A           
          SCF     
          RET     

;*------------------------------------------------------
;* Top of p.276 in German Listing of MZ-2Z046 Disk Basic
;* Write one sector of a circle or an ellipse
;*------------------------------------------------------
WSECTR:   CALL    WSPUT       
          LD      HL,(POINTX) 
          PUSH    HL          
          PUSH    BC          ;POINTY
          EXX     
          CALL    WSPUT       
          LD      B,2         
          JP      WBOX2       

WSPUT:    POP     IX          ;Ret adrs
          EX      DE,HL       
          CP      2           
          CALL    Z,WSCTRH    
          LD      BC,(POINTX) 
          ADD     HL,BC       
          PUSH    HL          ;X
          EX      DE,HL       
          CP      1           
          CALL    Z,WSCTRH    
          LD      BC,(POINTY) 
          ADD     HL,BC       
          PUSH    HL          ;Y
          JP      (IX)        

WSCTRH:   BIT     7,H         
          JP      Z,HIRITU    
          CALL    WSCTRV      
          CALL    HIRITU      
;*------------------------------------------------------
;* Top of p.277 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
WSCTRV:   EX      AF,AF'      
          CALL    NEGHL       
          EX      AF,AF'      
          RET     

;*-----------------------------
;* Circle Write
;*  ent DE:End X    DE':Start X
;*      HL:End Y    HL':Start Y
;*      IX:R        BC':Hiritu
;*      A:Angle flag
;*      if CF then sector
;*  uses KEYBUF
;*-----------------------------
WCIRCL:   PUSH    AF          
          CALL    SETW        ;set pwmode
          POP     AF          
          PUSH    AF          
          LD      (CIR3+1),IX ;R
          LD      (SYUX),DE   
          LD      (SYUY),HL   
          EXX     
          LD      (CIR.HF),BC 
          LD      (KAIX),DE   
          LD      (KAIY),HL   
          LD      A,C         ;CIR.HF
          CALL    C,WSECTR    
          LD      HL,(KAIX)   
          LD      DE,(KAIY)   
;*                             ;Å BLOCK NO.ª›º≠¬ÉBL º√›
          CALL    BLCKRU      
          LD      (KBL),A     
          LD      HL,(SYUX)   
          LD      DE,(SYUY)   
;*                             ;Å BLOCK NO.ª›º≠¬ÉSBL º≠≥√›
          CALL    BLCKRU      
          LD      (SBL),A     
          LD      HL,CIR.BK   
          LD      B,8         
          CALL    QCLRHL      
          LD      HL,KBL      
          POP     AF          
          LD      B,A         
          AND     0FH         
          JR      Z,CIR4      ;KK=SK
          CP      3           
          JR      Z,CIR15     ;2PI <= ABS(KK-SK)
          LD      A,(HL)      
          INC     HL          
          CP      (HL)        
          JR      NZ,CIR4     
          LD      A,B         
          CP      81H         
          JR      Z,CIR4      
          JR      CIR14       

CIR15:    LD      A,9         
          LD      (HL),A      
          INC     HL          
          LD      (HL),A      
CIR14:    LD      B,8         
          LD      HL,CIR.BK   
          INC     A           
          CALL    QSETHL      
          LD      A,0B0H      ;OR B
          CALL    CHENGE      
          JR      CIR3        

CIR4:     LD      A,0A0H      ;AND B
          CALL    CHENGE      
          LD      D,00H       
          LD      HL,(KBL)    
          LD      B,H         
          LD      A,L         
CIR2:     LD      HL,CIR.BK-1 
          LD      E,A         
          ADD     HL,DE       
          LD      (HL),1      
          CP      B           ;∂≤ºÃﬁ€Ø∏ƒ º≠≥Ãﬁ€Ø∏¶ À∂∏
          JR      Z,CIR3      
          AND     7           
          INC     A           
          JR      CIR2        

CIR3:     LD      HL,0        
          LD      (DYY),HL    
          LD      (XX),HL     
          LD      HL,1        
          LD      (CI.D),HL   
          LD      (YY),HL     
CIR7:     LD      HL,(DYY)    
          LD      DE,(CI.D)   
          XOR     A           
          SBC     HL,DE       
          LD      (DYY),HL    
          LD      HL,(YY)     
          DEC     HL          
          LD      (CYE),HL    
          LD      A,(CIR.HF)  
          OR      A           
          LD      D,H         
          LD      E,L         
          CALL    NZ,HIRITU   
          CP      1           
          JR      Z,CIR8      
          EX      DE,HL       
CIR8:     LD      (YYY),DE    
          LD      (YYHI),HL   
          LD      HL,(XX)     
          OR      A           
          LD      D,H         
          LD      E,L         
          CALL    NZ,HIRITU   
          CP      1           
          JR      Z,CIR9      
          EX      DE,HL       
CIR9:     LD      (XXX),DE    
          LD      (XXHI),HL   
          LD      HL,(XXX)    
          CALL    NEGHL       
          LD      (FUXX),HL   ;FUXX = -XXX
          LD      HL,(YYY)    
          CALL    NEGHL       
          LD      (FUYE),HL   ;FUYE = -YYY
          LD      HL,(YYHI)   
          CALL    NEGHL       
          LD      (FUYYHI),HL ;FUYYHI = -YYHI
          LD      HL,(XXHI)   
          CALL    NEGHL       
          LD      (FUXXHI),HL ;FUXXHI = -XXHI
          LD      HL,(CYE)    
          CALL    NEGHL       
          LD      (FUNOYE),HL ;FUNOYE = -YE
          LD      HL,CIR.BK   

          LD      A,(HL)      ;BLOCK NO.1
          OR      A           
          INC     HL          
          JR      Z,P222      
          EXX     
          LD      HL,(XXX)    
          LD      (PL1+1),HL  
          LD      B,0         
          LD      DE,(FUNOYE) 
          BIT     7,D         
          JR      Z,P12       
          LD      A,(KBL)     
          CP      1           
          JR      NZ,P11      
          LD      HL,(KAIY)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P11       
          JR      C,P12       
P11:      INC     B           
P12:      LD      A,(SBL)     
          CP      1           
          JR      NZ,P13      
          LD      HL,(SYUY)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P13       
          JR      NC,P14      
P13:      LD      A,1         
P14:      AND     B           
          JR      Z,P15       
          LD      HL,(FUYYHI) 
          CALL    PLALL       
P15:      EXX     

P222:     LD      A,(HL)      ;BLOCK NO.2
          OR      A           
          INC     HL          
          JR      Z,P3        
          EXX     
          LD      B,0         
          LD      HL,(YYY)    
          LD      (PL1+1),HL  
          LD      DE,(CYE)    
          LD      A,(KBL)     
          CP      2           
          JR      NZ,P21      
          LD      HL,(KAIX)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P21       
          JR      C,P22       
P21:      INC     B           
P22:      LD      A,(SBL)     
          CP      2           
          JR      NZ,P23      
          LD      HL,(SYUX)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P23       
          JR      NC,P24      
P23:      LD      A,1         
P24:      AND     B           
          JR      Z,P25       
          LD      HL,(FUXXHI) 
          CALL    PLALL       
P25:      EXX     

P3:       LD      A,(HL)      ;BLOCK NO.3
          OR      A           
          INC     HL          
          JR      Z,P4        
          EXX     
          LD      B,0         
          LD      HL,(FUYE)   
          LD      (PL1+1),HL  
          LD      DE,(FUNOYE) 
          BIT     7,D         
          JR      Z,P32       
          LD      A,(KBL)     
          CP      3           
          JR      NZ,P31      
          LD      HL,(KAIX)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P31       
          JR      C,P32       
P31:      INC     B           
P32:      LD      A,(SBL)     
          CP      3           
          JR      NZ,P33      
          LD      HL,(SYUX)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P33       
          JR      NC,P34      
P33:      LD      A,1         
P34:      AND     B           
          JR      Z,P35       
          LD      HL,(FUXXHI) 
          CALL    PLALL       
P35:      EXX     

P4:       LD      A,(HL)      ;BLOCK NO.4
          OR      A           
          INC     HL          
          JR      Z,P5        
          EXX     
          LD      B,0         
          LD      HL,(FUXX)   
          LD      (PL1+1),HL  
          LD      DE,(FUNOYE) 
          LD      A,(KBL)     
          CP      4           
          JR      NZ,P41      
          LD      HL,(KAIY)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P41       
          JR      NC,P42      
P41:      INC     B           
P42:      XOR     A           
          BIT     7,D         
          JR      Z,P44       
          LD      A,(SBL)     
          CP      4           
          JR      NZ,P43      
          LD      HL,(SYUY)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P43       
          JR      C,P44       
P43:      LD      A,1         
P44:      AND     B           
          JR      Z,P45       
          LD      HL,(FUYYHI) 
          CALL    PLALL       
P45:      EXX     

P5:       LD      A,(HL)      ;BLOCK NO.5
          OR      A           
          INC     HL          
          JR      Z,P6        
          EXX     
          LD      B,0         
          LD      HL,(FUXX)   
          LD      (PL1+1),HL  
          LD      DE,(CYE)    
          LD      A,(KBL)     
          CP      5           
          JR      NZ,P51      
          LD      HL,(KAIY)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P51       
          JR      NC,P52      
P51:      INC     B           
P52:      LD      A,(SBL)     
          CP      5           
          JR      NZ,P53      
          LD      HL,(SYUY)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P53       
          JR      C,P54       
P53:      LD      A,1         
P54:      AND     B           
          JR      Z,P55       
          LD      HL,(YYHI)   
          CALL    PLALL       
P55:      EXX     

P6:       LD      A,(HL)      ;BLOCK NO.6
          OR      A           
          INC     HL          
          JR      Z,P7        
          EXX     
          LD      B,0         
          LD      HL,(FUYE)   
          LD      (PL1+1),HL  
          LD      DE,(FUNOYE) 
          LD      A,(KBL)     
          CP      6           
          JR      NZ,P61      
          LD      HL,(KAIX)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P61       
          JR      NC,P62      
P61:      INC     B           
P62:      XOR     A           
          BIT     7,D         
          JR      Z,P64       
          LD      A,(SBL)     
          CP      6           
          JR      NZ,P63      
          LD      HL,(SYUX)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P63       
          JR      C,P64       
P63:      LD      A,1         
P64:      AND     B           
          JR      Z,P65       
          LD      HL,(XXHI)   
          CALL    PLALL       
P65:      EXX     

P7:       LD      A,(HL)      ;BLOCK NO.7
          OR      A           
          INC     HL          
          JR      Z,P8        
          EXX     
          LD      HL,(YYY)    
          LD      (PL1+1),HL  
          LD      DE,(CYE)    
          LD      B,0         
          LD      A,(KBL)     
          CP      7           
          JR      NZ,P71      
          LD      HL,(KAIX)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P71       
          JR      NC,P72      
P71:      INC     B           
P72:      LD      A,(SBL)     
          CP      7           
          JR      NZ,P73      
          LD      HL,(SYUX)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P73       
          JR      C,P74       
P73:      LD      A,1         
P74:      AND     B           
          JR      Z,P75       
          LD      HL,(XXHI)   
          CALL    PLALL       
P75:      EXX     

P8:       LD      A,(HL)      ;BLOCK NO.8
          OR      A           
          INC     HL          
          JR      Z,PECMD        
          EXX     
          LD      HL,(XXX)    
          LD      (PL1+1),HL  
          LD      DE,(CYE)    
          LD      B,0         
          LD      A,(KBL)     
          CP      8           
          JR      NZ,P81      
          LD      HL,(KAIY)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P81       
          JR      C,P82       
P81:      INC     B           
P82:      LD      A,(SBL)     
          CP      8           
          JR      NZ,P83      
          LD      HL,(SYUY)   
          XOR     A           
          SBC     HL,DE       
          JR      Z,P83       
          JR      NC,P84      
P83:      LD      A,1         
P84:      AND     B           
          JR      Z,P85       
          LD      HL,(YYHI)   
          CALL    PLALL       
P85:      EXX     

PECMD:    LD      HL,(DYY)    ;π≤ª›º∑
          BIT     7,H         
          JR      Z,CIR10     
          LD      DE,(YY)     
          LD      HL,(XX)     
          DEC     HL          
          LD      (XX),HL     
          BIT     7,H         
          RET     NZ          
          XOR     A           
          SBC     HL,DE       
          RET     C           
          LD      HL,(XX)     
          ADD     HL,HL       
          LD      DE,(DYY)    
          ADD     HL,DE       
          LD      (DYY),HL    
CIR10:    LD      HL,(YY)     
          INC     HL          
          LD      (YY),HL     
          LD      HL,(CI.D)   
          INC     HL          
          INC     HL          
          LD      (CI.D),HL   
          JP      CIR7        

;*-----------------------------------------------------------
;* Near Top of p.288 in German Listing of MZ-2Z046 Disk Basic
;*-----------------------------------------------------------
;*                              ;CIRCLE ªÃﬁŸ-¡›
;*                              ;BLOCK NUMBER π›º≠¬ ªÃﬁŸ-¡›
BLCKRU:   PUSH    HL          
          PUSH    DE          
          CALL    ABSHL       
          EX      DE,HL       
          CALL    ABSHL       
          EX      DE,HL       
          OR      A           
          SBC     HL,DE       
          POP     DE          
          POP     HL          
          JR      C,BLCK1     
          BIT     7,H         
          JR      NZ,BLCK2    
          BIT     7,D         
          LD      A,8         
          RET     Z           
          LD      A,1         
          RET     

BLCK2:    BIT     7,D         
          LD      A,5         
          RET     Z           
          LD      A,4         
          RET     

BLCK1:    BIT     7,H         
          JR      NZ,BLCK5    
          BIT     7,D         
          LD      A,7         
          RET     Z           
          LD      A,2         
          RET     

BLCK5:    BIT     7,D         
          LD      A,6         
          RET     Z           
          LD      A,3         
          RET     

ABSHL:    BIT     7,H         
          RET     Z           
NEGHL:    LD      A,H         
          CPL     
          LD      H,A         
          LD      A,L         
          CPL     
          LD      L,A         
          INC     HL          
          RET     

;*---------
;*PLOT Ÿ-¡›
;*---------
PLALL:    LD      DE,(POINTY) 
          ADD     HL,DE       
          LD      DE,65336    
          LD      B,H         
          LD      C,L         
          ADD     HL,DE       
          RET     C           
PL1:      LD      HL,0000H    ;LKD HL,XXXXH
          LD      DE,(POINTX) 
          ADD     HL,DE       
          EX      DE,HL       
          LD      HL,64896    
          ADD     HL,DE       
          RET     C           
          LD      H,B         
          LD      L,C         
          JP      PSET0       

;*                              ;Àÿ¬ π≤ª› Ÿ-¡›
HIRITU:   PUSH    AF          ;correction routine for ellipse
          PUSH    DE          
          LD      B,8         
          LD      C,L         
          LD      E,H         
          XOR     A           
          LD      D,A         
          LD      H,A         
          LD      L,A         
          EX      AF,AF'      
          LD      A,(CIR.HD)  
HR1:      RRA     
          JR      NC,HR2      
          ADD     HL,DE       
          EX      AF,AF'      
          ADD     A,C         
          JR      NC,HR3      
          INC     HL          
HR3:      EX      AF,AF'      
HR2:      SLA     C           
          RL      E           
          RL      D           
          DJNZ    HR1         
          EX      AF,AF'      
          BIT     7,A         
          JR      Z,HR4       
          INC     HL          
HR4:      POP     DE          
          POP     AF          
          RET     

CHENGE:   LD      (P14),A     
          LD      (P24),A     
          LD      (P34),A     
          LD      (P44),A     
          LD      (P54),A     
          LD      (P64),A     
          LD      (P74),A     
          LD      (P84),A     
          RET     

;*-------------------------
;* CIRCLE Work Area EQUATES
;*-------------------------
CI.D:     EQU     KEYBF       ;2
DYY:      EQU     CI.D+2      ;2
XX:       EQU     DYY+2       ;2
YY:       EQU     XX+2        ;2
CYE:      EQU     YY+2        ;2
KBL:      EQU     CYE+2       ;1 º√›… BLOCK NO.
SBL:      EQU     KBL+1       ;1 º≠≥√›… BLOCK NO.

;*                              ;Ã… CYE ∑ﬁ¨∏Ω≥ Õ›∂
FUYE:     EQU     SBL+1       ;2
;*                              ;Ã… XX ∑ﬁ¨∏Ω≥ Õ›∂
FUXX:     EQU     FUYE+2      ;2
;*                              ;Ã… CYE Àÿ¬ ∑ﬁ¨∏Ω≥ Õ›∂
FUYYHI:   EQU     FUXX+2      ;2
;*                              ;Ã… XX Àÿ¬ ∑ﬁ¨∏Ω≥ Õ›∂
FUXXHI:   EQU     FUYYHI+2    ;2

FUNOYE:   EQU     FUXXHI+2    ;2
CIR.BK:   EQU     FUNOYE+2    ;9 Block data

KAIX:     EQU     CIR.BK+9    ;2 º√› X
KAIY:     EQU     KAIX+2      ;2 º√› Y
SYUX:     EQU     KAIY+2      ;2 º≠≥√› X
SYUY:     EQU     SYUX+2      ;2 º≠≥√› Y
XXHI:     EQU     SYUY+2      ;2 XX… Àÿ¬ DATA
YYHI:     EQU     XXHI+2      ;2 YE… Àÿ¬ DATA

XXX:      EQU     YYHI+2      ;2
YYY:      EQU     XXX+2       ;2

CIR.HF:   EQU     YYY+2       ;1
CIR.HD:   EQU     CIR.HF+1    ;1
;*--------------------------------
;* End of CIRCLE Work Area EQUATES
;*--------------------------------

;*------------------------------------------------------
;* pp.291-292 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
;*-------------------------------
;* Box Write
;*    ext DE':xs, DE:xe
;*        HL':ys, HL:ye
;*        if CF then A:fill color
;*-------------------------------
LSTA:     EQU     KEYBF       
RSTA:     EQU     LSTA+2      
SPBOX:    EQU     RSTA+2      

WBOX:     LD      (SPBOX),SP  
          EX      AF,AF'      
          CALL    WBOXSB      
          CALL    WBOXSB      
          EXX     
          PUSH    DE          ;XS Upper
          PUSH    HL          ;YS
          PUSH    DE          ;XS Lower
          EXX     
          PUSH    HL          ;YE
          PUSH    DE          ;XE Lower
          PUSH    HL          ;YE
          PUSH    DE          ;XE Upper
          EXX     
          PUSH    HL          ;YS
          PUSH    DE          ;XS Upper Left
          PUSH    HL          ;YS
          EXX     
          EX      AF,AF'      
          CALL    C,BOXF      ;Box fill
          LD      B,4         
WBOX2:    EXX     
          POP     HL          
          POP     DE          
          EXX     
WBOX4:    POP     HL          
          POP     DE          
          PUSH    BC          
          CALL    WLINE0      ;Box bound
          POP     BC          
          DJNZ    WBOX4       
          RET     

WBOXSB:   EX      DE,HL       
          LD      A,H         ;Compare HL,HL'
          EXX     
          EX      DE,HL       
          CP      H           
          EXX     
          JR      Z,WBOXS2    
          RET     P           
          JR      WBOXS4      
WBOXS2:   LD      A,L         
          EXX     
          CP      L           
          EXX     
          RET     NC          
WBOXS4:   PUSH    HL          
          EXX     
          EX      (SP),HL     
          EXX     
          POP     HL          
          RET     

;*---------------------------------------------------------
;* Middle of p.293 in German Listing of MZ-2Z046 Disk Basic
;*---------------------------------------------------------
;*--------------------------
;*   BOX FILL
;*    ent DE':xs, DE:xe
;*        HL':ys, HL:ye
;*        A:fill color
;*--------------------------
BOXF:     CALL    COLS        ;Fill Color Set
          LD      B,A         
          LD      A,(GMODE)   
          CP      B           
          JR      NZ,BOXC     
          LD      SP,(SPBOX)  ;line routions pop
BOXC:     LD      A,(PWMODE)  
          OR      A           
          LD      A,0C0H      ;w0 pset
          JR      Z,BOXF0     
          LD      A,40H       ;w0 or
BOXF0:    OR      B           
          OUT     (LSWF),A    ;Write mode set
YLINE:    LD      A,H         ;draw line parallel to axis
          OR      D           
          RET     M           
          CALL    BFCHK       
          LD      A,L         ;ye
          EXX                 ;hl=ys,de=xs
          BIT     7,H         
          JR      Z,YLINE1    
          LD      HL,0        
YLINE1:   BIT     7,D         
          JR      Z,YLINE2    
          LD      DE,0        
YLINE2:   EX      AF,AF'      
          CALL    BFCHK       
          RET     C           
          EX      AF,AF'      ;ye
          INC     A           
          SUB     L           ;acc=lines(ye-ys+1)
          RET     C           
          RET     Z           
          EX      AF,AF'      ;acc'=lines
          PUSH    HL          ;ye
          CALL    ADCH        
          LD      (LSTA),HL   
          EXX     
          POP     HL          ;ye
          LD      B,A         ;left
          PUSH    BC          
          CALL    ADCH        
          POP     BC          
          LD      (RSTA),HL   
          LD      C,A         ;right
          LD      DE,(LSTA)   
HLINE:    OR      A           
          SBC     HL,DE       
          JR      Z,BOXI      
          DEC     HL          
          INC     DE          ;next point
          LD      A,L         
          OR      A           
          CALL    NZ,BOXL     ;a' reserve
BOXH:     LD      HL,TDOTR    
          LD      A,B         
          LD      B,0         
          ADD     HL,BC       
          LD      L,(HL)      
          LD      C,A         
          LD      A,L         
          LD      HL,TDOTL    
          ADD     HL,BC       
          LD      B,(HL)      
          LD      DE,(RSTA)   
          PUSH    BC          
          CALL    BOXW        
          POP     BC          
          LD      DE,(LSTA)   
          LD      A,B         
          JR      BOXW        

BOXI:     LD      HL,TDOTR    
          LD      A,B         
          LD      B,0         
          ADD     HL,BC       
          LD      C,A         
          LD      A,0FFH      
          AND     (HL)        
          LD      HL,TDOTL    
          ADD     HL,BC       
          AND     (HL)        
BOXW:     LD      C,A         
          EX      AF,AF'      
          LD      B,A         
          EX      AF,AF'      
          EX      DE,HL       
          DI      
BFL0:     LD      DE,80       ;dynamic - 80 or 40
          IN      A,(LSE0)    
BOXW1:    LD      (HL),C      
          ADD     HL,DE       
          DJNZ    BOXW1       
          IN      A,(LSE1)    
          EI      
          RET     

BOXL:     PUSH    BC          
          EX      DE,HL       ;hl=start
          LD      B,A         ;yoko counter
          EX      AF,AF'      
          LD      C,A         ;tate counter
          EX      AF,AF'      
BFL1:     LD      DE,80       ;dynamic - 80 or 40
          DI      
BOXL1:    PUSH    HL          
          PUSH    BC          
          IN      A,(LSE0)    
          LD      A,0FFH      
BOXL0:    LD      (HL),A      
          INC     HL          
          DJNZ    BOXL0       
          IN      A,(LSE1)    
          POP     BC          
          POP     HL          
          ADD     HL,DE       
          DEC     C           
          JR      NZ,BOXL1    
          EI      
          POP     BC          
          RET     

;*----------------------
;*  box fill range check
;*----------------------
BFCHK:    LD      A,H         
          OR      A           
          JR      NZ,BFCHK0   
          LD      A,199       
          CP      L           
          JR      NC,BFCHK1   ;skip if hl>199
BFCHK0:   LD      HL,199      
          SCF     
BFCHK1:   RRA                 ;push cf
          PUSH    HL          
BFC0:     LD      HL,-640     ;dynamic -640 or -320
          ADD     HL,DE       
          POP     HL          
          JR      NC,BFCHK3   ;skip if de>639,319
BFC1:     LD      DE,639      ;dynamic 319 or 639
          RET     


BFCHK3:   RLA                 ;pop cf
          RET     

;*---------------------------------------------------------
;* Bottom of p.297 in German Listing of MZ-2Z046 Disk Basic
;*---------------------------------------------------------
;*---------------
;* Position check
;*---------------
POSCK:    EXX     
          CALL    RNGCK       
          EXX     
          RET     NC          ;OK
          LD      A,3         
          JP      ERRORJ      

;*--------------
;* Position save
;*--------------
POSSV:    EXX                 ;Position save
          LD      (POINTX),DE 
          LD      (POINTY),HL 
          EXX     
          RET     

;*--------------------------
;*  SYMBOL
;*    Ent. A:angle
;*         B:string length
;*         H:Y ratio
;*         L:X ratio
;*         DE:string address
;*--------------------------
;*------------------------------------------
;* EQUATES and DEFW's for the SYMBOL COMMAND
;*------------------------------------------
SBDTAP:   DB      0,0,0,0,0,0,0,0 ;(was DEFS 8)

SDT0:     EQU     1200H       
SDT7:     EQU     1207H       
SCNT:     EQU     1208H       ;1
HCNT:     EQU     SCNT+1      ;1
VCNT:     EQU     HCNT+1      ;1
BCNT:     EQU     VCNT+1      ;1
STRAP:    EQU     BCNT+1      ;2
SDTAP:    EQU     STRAP+2     ;2
BDTAP:    EQU     SDTAP+2     ;2
DEFX0:    EQU     BDTAP+2     ;1
DEFY0:    EQU     DEFX0+1     ;1
DEFX8:    EQU     DEFY0+1     ;2
DEFY8:    EQU     DEFX8+2     ;2
PX:       EQU     DEFY8+2     ;2
PY:       EQU     PX+2        ;2
VADD:     EQU     PY+2        ;2
LDOT:     EQU     VADD+2      ;1
DEFX:     EQU     LDOT+1      ;1
DEFY:     EQU     DEFX+1      ;1
DEF8:     EQU     DEFY+1      ;2
NSDT:     EQU     DEF8+2      ;2

CLLADD:   DW      LOD00       
          DW      LOD90       
          DW      LOD18       
          DW      LOD27       

SYMBOL:   PUSH    BC          ;SYMBOL command
          PUSH    DE          ;string address
          LD      BC,PX       
          LD      D,L         
          LD      E,H         
          BIT     0,A         
          JR      Z,SYMB10    ;skip acc=0,2
          EX      DE,HL       ;exchange milti
          INC     BC          
          INC     BC          ;bc=py
SYMB10:   LD      (SYMB18+1),BC 
          LD      (DEFX0),HL  
          LD      H,0         
          ADD     HL,HL       
          ADD     HL,HL       
          ADD     HL,HL       ;defx8=defx*8
          LD      (DEFX8),HL  
          LD      L,E         
          LD      H,0         
          ADD     HL,HL       
          ADD     HL,HL       
          ADD     HL,HL       ;defy8=defy*8
          LD      (DEFY8),HL  
;*---------------
;*   set py, def8
;*---------------
          LD      DE,0        
          EX      DE,HL       ;de=defy8
          SBC     HL,DE       ;hl=-defy8
          LD      (DEF8),HL   ;def8=-defy8
          BIT     1,A         
          JR      Z,SYMB11    ;skip if acc=0,1
          LD      (DEF8),DE   ;def8=defy8
SYMB11:   OR      A           ;HL=-defy8
          JP      PO,SYMB12   ;skip if acc=1,2
          LD      HL,0        
SYMB12:   LD      DE,(POINTY) 
          ADD     HL,DE       ;pointy or pointy-defy8
          LD      (PY),HL     ;set py
;*--------------
;*  set px, def8
;*--------------
          LD      DE,(DEFX8)  
          LD      HL,0        
          OR      A           ;de=defx8
          SBC     HL,DE       ;hl=-defx8
          BIT     0,A         
          JR      NZ,SYMB13   ;skip if acc=1,3
          BIT     1,A         
          LD      (DEF8),DE   ;DE=defx8
          JR      Z,SYMB13    ;skip if acc=0
          LD      (DEF8),HL   ;hl=-defx8
SYMB13:   EX      DE,HL       ;de=-defx8
          LD      HL,(POINTX) 
          BIT     1,A         
          JR      Z,SYMB15    ;skip if acc=0,1
          ADD     HL,DE       ;pointx or pointx-defx8
SYMB15:   LD      (PX),HL     ;set px
;*---------------------------
;* calc rotation program addr
;*---------------------------
          ADD     A,A         
          LD      HL,CLLADD   
          LD      D,0         
          LD      E,A         
          ADD     HL,DE       
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      (SYMS10+1),DE 
          CALL    SETW        ;set pwmode
          POP     HL          
          POP     BC          
SYMB17:   DEC     B           ;string count down
          RET     M           
          PUSH    HL          
          PUSH    BC          
          CALL    SYMS        
SYMB18:   LD      HL,PX       ;py
          LD      E,(HL)      ;calc px(py)=px(py)+def8
          INC     HL          
          LD      D,(HL)      
          PUSH    HL          
          LD      HL,(DEF8)   
          ADD     HL,DE       
          EX      DE,HL       
          POP     HL          
          LD      (HL),D      
          DEC     HL          
          LD      (HL),E      ;set next disp addr
          POP     BC          
          POP     HL          
          INC     HL          ;next string pointer
          JR      SYMB17      

;*-------------------
;* SYMBOL  SUBROUTINE
;*-------------------
SYMS:     LD      IY,SCNT     
          LD      A,(HL)      ;mz ascii -> display
          RST     18H         ;font addr calc
          DB      DQADCN      
          LD      H,0         
          LD      L,A         
          ADD     HL,HL       
          ADD     HL,HL       
          ADD     HL,HL       
          LD      A,10H       
          ADD     A,H         
          LD      H,A         ;hl=hl+1000H
          LD      DE,SBDTAP   ;xfer cg data
          LD      BC,8        
          DI      
          IN      A,(LSE0)    
          LDIR    
          IN      A,(LSE1)    
          EI      
          LD      B,8         ;rotation pro.
SYMS10:   CALL    LOD00       ;LODXX
          LD      HL,808H     
          LD      (HCNT),HL   ;set hcnt,vcnt
          LD      DE,(DEFX0)  
          LD      (DEFX),DE   
          LD      HL,(PX)     
          BIT     7,H         
          JR      Z,SYMS20    ;skip if PX>=0
          CALL    SSYMB       
          RET     C           ;error position
SYMS11:   EXX                 ;data area rotate
          LD      B,8         
          LD      HL,SDT0     
SYMS12:   RLC     (HL)        
          INC     HL          
          DJNZ    SYMS12      
          EXX     
          DJNZ    SYMS11      
          LD      HL,0        
SYMS20:   LD      (SYMS23+1),HL 
          LD      A,0F8H      
          AND     L           
          OR      H           
          RRC     A           
          RRC     A           
          RRC     A           
SYMS21:   SUB     80          ;dynamic - 80 or 40
          RET     NC          ;buffer full check?
          LD      L,A         ;SEND DATA ADD.
          LD      H,11H       
          LD      (BDTAP),HL  
          LD      HL,(PY)     
          XOR     A           
          BIT     7,H         
          JR      Z,SYMS22    
          INC     IY          
          CALL    SSYMB       
          DEC     IY          
          RET     C           ;error position
          LD      HL,0        
          LD      A,8         
          SUB     B           
SYMS22:   LD      (SYMS24+1),A 
SYMS23:   LD      DE,0        ;XXH
          PUSH    HL          
          PUSH    DE          
          CALL    RNGCK       
          POP     DE          
          POP     HL          
          RET     C           ;error position
          CALL    ADCH        
          LD      (VADD),HL   
          LD      HL,TDOTN    
          LD      D,0         
          LD      E,A         
          ADD     HL,DE       
          LD      A,(HL)      
          LD      (LDOT),A    
SYMS24:   LD      HL,SDT0     
SYMS25:   LD      DE,(BDTAP)  
          LD      BC,(LDOT)   ;b defx c ldot
          XOR     A           
          EXX     
          LD      B,(IY+1)    ;hcnt
SYMS30:   EXX     
          LD      (DE),A      
          XOR     A           
          RRC     (HL)        
          JR      NC,SYMS31   
          LD      A,0B1H      ;OR C
SYMS31:   LD      (SYMS32),A  
          LD      A,(DE)      
SYMS32:   OR      C           ;nop
          RLC     C           
          JR      NC,SYMS33   
          LD      (DE),A      
          INC     E           ;next data addr
          JR      Z,SYMS34    ;skip if buffer full
          XOR     A           
SYMS33:   DJNZ    SYMS32      
SYMS3A:   LD      B,(IY+0AH)  ;defx0
          EXX     
          DJNZ    SYMS30      ;hcnt
          EXX     
          LD      (DE),A      
          INC     E           
SYMS34:   DEC     E           
          INC     L           
          LD      (SDTAP),HL  
          LD      HL,(BDTAP)  
          EX      DE,HL       
          XOR     A           
          SBC     HL,DE       
          INC     HL          
          LD      (NSDT),HL   
          LD      A,(DEFY)    
          LD      B,A         ;loop counter set
SYMS40:   EXX     
          LD      DE,(VADD)   
          LD      HL,(BDTAP)  
          LD      BC,(NSDT)   
          DI      
          IN      A,(LSE0)    
          OUT     (LSE0),A    
          LDIR    
          IN      A,(LSE1)    
          EI      
SYMS41:   LD      DE,80       ;dynamic - 80 or 40
          LD      HL,(VADD)   
          ADD     HL,DE       
          LD      (VADD),HL   ;next disp addr
SYMS42:   LD      DE,0BE80H   ;dynamic - 9F40H or BE80H
          OR      A           
          SBC     HL,DE       
          RET     NC          ;position error check
          EXX     
          DJNZ    SYMS40      
SYMS43:   LD      A,(DEFY0)   ;
          LD      (DEFY),A    ;set loop counter
          LD      HL,(SDTAP)  
          DEC     (IY+2)      ;VCNT
          JP      NZ,SYMS25   
          RET     

;*-----------------------------------------
;* Bottom of p.304, German Listing of 2Z046
;*-----------------------------------------
LOD00:    LD      HL,SBDTAP   ;rotation subroutine
          LD      DE,SDT0     
          LD      C,B         
          LD      B,0         
          LDIR    
          RET     

LOD90:    LD      DE,SDT0     
LOD901:   EXX     
          LD      HL,SBDTAP   
          LD      B,8         
          XOR     A           
LOD902:   RLC     (HL)        
          RRA     
          INC     HL          
          DJNZ    LOD902      
          EXX     
          LD      (DE),A      
          INC     DE          
          DJNZ    LOD901      
          RET     

LOD18:    LD      DE,SDT7     
          LD      HL,SBDTAP   
LOD181:   LD      A,(HL)      
          EXX     
          LD      C,A         
          LD      B,8         
          XOR     A           
LOD182:   RR      C           
          RL      A           
          DJNZ    LOD182      
          EXX     
          LD      (DE),A      
          INC     HL          
          DEC     DE          
          DJNZ    LOD181      
          RET     

LOD27:    LD      DE,SDT7     
LOD271:   EXX     
          LD      HL,SBDTAP   
          XOR     A           
          LD      B,8         
LOD272:   RLC     (HL)        
          RLA     
          INC     HL          
          DJNZ    LOD272      
          EXX     
          LD      (DE),A      
          DEC     DE          
          DJNZ    LOD271      
          RET     

;*---------------
;*  calc position
;*---------------
SSYMB:    LD      B,8         
          LD      E,(IY+0AH)  ;defx0,defy0
          LD      D,0         
SSYMB1:   ADD     HL,DE       
          BIT     7,H         
          JR      Z,SSYMB2    
          DJNZ    SSYMB1      
SSYMB4:   SCF     
          RET     

SSYMB2:   LD      A,H         
          OR      L           
          JR      NZ,SSYMB3   
          LD      L,E         
          DEC     B           
          JR      Z,SSYMB4    
SSYMB3:   LD      (IY+17H),L  ;defx,defy
          LD      (IY+1),B    ;HCNT,VCNT
          OR      A           
          RET     

;*-------------------------------
;* PATTERN
;*  ent A:Heighth
;*      B:String length
;*      H:Direction
;*     DE:String adrs
;*-------------------------------
POINTW:   EQU     KEYBF       ;2
STRAD:    EQU     POINTW+2    ;2
PATDA1:   EQU     POINTW+250  
PATDA2:   EQU     POINTW+251  
PATDA3:   EQU     POINTW+252  
PATDA4:   EQU     POINTW+263  
;*
CHARW:    OR      A           ;no mode ?
          RET     Z           ;yes
          LD      (STRAD),DE  
          LD      E,A         ;E'=Height
          LD      C,A         ;C'=Height(work)
          LD      A,H         
          OR      A           
          LD      A,23H       ;INC HL
          JR      NZ,PATT1    ;DOWN
          LD      A,2BH       ;DEC HL
PATT1:    LD      (PATTA),A   
          LD      (PATTC),A   
          LD      A,B         
          OR      A           ;no string ?
          RET     Z           ;yes
          LD      HL,(POINTX) 
          LD      A,07H       
          AND     L           
          LD      D,A         
          EXX                 ;keep c',e',b',d'
          LD      HL,TDOTL    
          LD      D,0         
          LD      E,A         
          ADD     HL,DE       
          LD      A,(HL)      
          LD      (PATTB+1),A ;MASK DATA
PATT3:    LD      HL,(POINTY) 
PATT4:    LD      (POINTW),HL ;save (POINTY)
PATTB:    LD      C,0FFH      ;C=mask data
          LD      HL,(STRAD)  ;read DATA
          LD      A,(HL)      
          EXX                 ;keep c',e',b',d'
          LD      H,A         
          LD      A,D         
          OR      A           ;X=0 ?
          JR      Z,PATT6     ;yeS
PATT7:    RRC     H           
          DEC     A           
          JR      NZ,PATT7    
PATT6:    LD      A,H         
          EXX                 ;A=pattern data
          LD      HL,PATDA1   
          LD      B,8         ;DATA sift
          LD      D,A         
PATT80:   SRL     D           
          RLA     
          DJNZ    PATT80      
          LD      D,A         ;C^D
          AND     C           
          LD      (HL),A      ;left set data
          LD      A,D         
          CPL     
          LD      B,A         ;B=CPL(D)=CPL(STRAD)
          AND     C           ;C^CPL(D)
          INC     HL          
          LD      (HL),A      ;left reset data
          LD      A,C         
          CPL     
          LD      C,A         
          AND     D           ;CPL(C)^D
          INC     HL          
          LD      (HL),A      ;right set data
          LD      A,C         
          AND     B           ;CPL(C)^CPL(D)
          INC     HL          
          LD      (HL),A      ;right reset data
          LD      DE,(POINTX) 
          LD      HL,(POINTW) 
          PUSH    DE          
          PUSH    HL          
          EX      DE,HL       ;X=X+1
          LD      BC,8        
          ADD     HL,BC       
          EX      DE,HL       
          LD      A,1         ;right mode
          CALL    PATT90      
          POP     HL          
          POP     DE          
          XOR     A           ;left mode
          CALL    PATT90      
          LD      HL,(STRAD)  ;next data
          INC     HL          
          LD      (STRAD),HL  
          EXX     
          DJNZ    PATT5       ;B'
          DEC     C           ;C' X-->END
          EXX     
          JP      Z,PATT70    ;X=X+8 & END
          LD      HL,(POINTW) 
PATTC:    INC     HL          ;DEC HL
          LD      (POINTY),HL 
          XOR     A           ;end
          RET     


PATT5:    DEC     C           ;C'
          JR      NZ,PATT2    ;next Xposition
          LD      C,E         ;C' E'
          EXX     
          CALL    PATT70      ;X=X+8
          JR      PATT3       
PATT2:    EXX     
          LD      HL,(POINTW) 
PATTA:    INC     HL          ;DEC HL
          JR      PATT4       

;*----------
;*  pointx+8
;*----------
PATT70:   LD      HL,(POINTX) 
          LD      BC,8        
          ADD     HL,BC       
          LD      (POINTX),HL 
          RET     

;*-----------------------------------------------------------
;* Near Top of p.310 in German Listing of MZ-2Z046 Disk Basic
;*-----------------------------------------------------------
;*----------------------
;*     V-RAM write
;*         non keep
;*       A=0 ----->left
;*         1 ----->right
;*       DE=X positin
;*       HL=y position
;*----------------------
PATT90:   EX      AF,AF'      ;PUSH AF !
          CALL    RNGCK       
          RET     C           ;address err
          CALL    ADCH        ;get V-RAM address
          LD      B,A         ;B=0 -->no right data
;*------------------------------
;* at this point HL=VRAM address
;*------------------------------
          LD      DE,PATDA1   ;(DE)=write data
          EX      AF,AF'      ;pop AF
          OR      A           ;left data ?
          JR      Z,PATT91    ;yes
          LD      A,B         ;non right data
          OR      A           
          RET     Z           
          INC     DE          ;DE,PATDA3
          INC     DE          
PATT91:   CALL    SETW        ;mode set
          DI      
          IN      A,(LSE0)    
          OUT     (LSE0),A    ;get V-RAM
          LD      A,(DE)      ;B=right data
          LD      (HL),A      
          LD      A,(PWMODE)  
          OR      A           ;OR mode ?
          JR      NZ,PATT92   ;YES
          LD      A,(CPLANE)  ;read color data
          OR      60H         
          OUT     (LSWF),A    
          INC     DE          
          LD      A,(DE)      ;C=reset data
          LD      (HL),A      
PATT92:   IN      A,(LSE1)    
          EI      
          RET     

;*-------------------------------
;*    PAINT   ROUTINE  ( 9.5/84 )
;*            HL: COLOR ADD.
;*            B : NUM. of COLOR
;*-------------------------------
DIRAR:    EQU     27D0H       
ENKYB:    EQU     12A0H       
NDSP:     EQU     KEYBF       ;2
DSP:      EQU     NDSP+2      ;2
NSSP:     EQU     DSP+2       ;1
SSP:      EQU     NSSP+1      ;2
PBXL:     EQU     SSP+2       ;2
PBXR:     EQU     PBXL+2      ;2

Y:        EQU     PBXR+2      ;2
BXL:      EQU     Y+2         ;2
BXR:      EQU     BXL+2       ;2
DIRECT:   EQU     BXR+2       ;1
JCONT:    EQU     DIRECT+1    ;1
JSAVE:    EQU     JCONT+1     ;1
JSAVE1:   EQU     JSAVE+1     ;1
BUFF:     EQU     JSAVE1+1    ;11 DATA BUFF.

;*------------------------------------------------------
;* The original source names the first EQUATE below as PEEK
;* This creates a very nasty problem with duplicate labels !
;*------------------------------------------------------
WAREA:    EQU     DIRAR       ;Workspace for copied routine
;*
WORK:     EQU     Y           
;*-------------------------------------------
;* Middle of p.311 in German Listing of 2Z046
;*-------------------------------------------
WPAINT:   LD      A,(GMODE)   ;Main PAINT routine
          OR      0C0H        
          OUT     (LSWF),A    ;Write mode set
          EXX     
          LD      DE,WAREA    ;copy 1st part of routine to WAREA
          LD      HL,DPEEK    
          LD      BC,DPEEK1-DPEEK 
          LDIR    
          EXX     
PAIN0:    LD      A,(HL)      ;COLOR SELECT
          CALL    COLS        ;Bound Color Set
          OR      80H         ;SEARCH MODE SET
          LD      (DPEEK1+1),A 
          INC     HL          
          EXX     
          LD      HL,DPEEK1   ;copy 2nd part of routine to WAREA
          LD      BC,DPEEK2-DPEEK1 
          LDIR    
          EXX     
          DJNZ    PAIN0       
          EXX     
          LD      BC,DPEEK3-DPEEK2+1 ;copy 3rd part of routine to WAREA
          LDIR    
          LD      HL,(TMPEND) 
          LD      (DSP),HL    
          LD      (CSAVE+2),HL 
          LD      HL,(PAIWED) 
          LD      DE,-6       
          ADD     HL,DE       
          LD      (SVDT0+1),HL 
          LD      HL,(POINTX) 
          DEC     HL          
          LD      (BXL),HL    ;BXL=POINTX-1
          INC     HL          
          INC     HL          
          LD      (BXR),HL    ;BXR=POINTX+1
          DEC     HL          
          EX      DE,HL       
          LD      HL,0        
          LD      (NDSP),HL   
          LD      HL,(POINTY) 
          LD      (Y),HL      
          CALL    RNGCK       
          CCF     
          RET     NC          ;START OUT RANGE
          LD      (SOVER1),SP 
          LD      SP,DIRAR+700H 
          CALL    ADCH        
          LD      DE,TDOTN    
          PUSH    HL          
          LD      H,0         
          LD      L,A         
          ADD     HL,DE       
          LD      C,(HL)      
          POP     HL          
          CALL    WAREA       
          AND     C           
          JP      NZ,PAINCE   ;ON BOUND
          CALL    RBSR        
          LD      (BXR),IX    ;SET R.BOUND
          CALL    LBSR        
          LD      (BXL),IX    ;SET L.BOUND
          LD      A,0FFH      
          LD      (DIRECT),A  ;DOWN
          CALL    SVDT        
          LD      HL,ENKYB    
          LD      (SSP),HL    
          XOR     A           
          LD      (DIRECT),A  
          LD      (NSSP),A    
PAIN1:    LD      A,(DIRECT)  
          CALL    CHDIR0      
          LD      A,199       
          CP      L           
          JR      C,PAINA     ;OUT RANGE
          CALL    NBSRCH      
          JR      C,PAINA     ;CLOSE
          LD      (JCONT),A   
          AND     9           
          CALL    NZ,PAIND    
          CALL    CSAVE       
          LD      A,(JSAVE)   
          OR      A           
          JR      NZ,PAINA    
PAIN3:    CALL    PSRCH       
          JR      Z,PAIN1     
          LD      HL,(BXR)    
          PUSH    HL          
          PUSH    DE          
          CALL    RBSR0       
          LD      (BXR),IX    
          CALL    SVDT        
          POP     HL          
          LD      (BXL),HL    
          POP     HL          
          LD      (BXR),HL    
          JR      PAIN1       

PAINA:    LD      HL,(DSP)    
          DEC     HL          
          LD      DE,-7       
          LD      BC,(NDSP)   
PAINA1:   LD      A,B         
          OR      C           
          JR      Z,PAINC     
          LD      A,0FH       
          DEC     BC          
          CP      (HL)        
          ADD     HL,DE       
          JR      Z,PAINA1    
          INC     HL          
          PUSH    HL          
          LD      (PAINA2+1),HL 
          LD      DE,WORK     
          LD      BC,7        
          LDIR    
          EX      DE,HL       
          LD      HL,(DSP)    
          XOR     A           
          POP     BC          
          LD      (DSP),BC    
          SBC     HL,DE       
          JR      Z,PAINA3    
          LD      B,H         
          LD      C,L         
PAINA2:   LD      HL,00H      ;XXH
          EX      DE,HL       
          LDIR    
          LD      (DSP),DE    
PAINA3:   LD      HL,(NDSP)   
          DEC     HL          
          LD      (NDSP),HL   
          JP      PAIN3       

PAINC:    LD      HL,(NDSP)   
          LD      A,L         
          OR      H           
          JR      NZ,PAINC0   
PAINCE:   LD      SP,(SOVER1) ;END JOB
          RET     

PAINC0:   DEC     HL          
          LD      (NDSP),HL   
          LD      HL,(DSP)    
          DEC     HL          
          LD      DE,WORK+6   
          LD      BC,7        
          LDDR    
          INC     HL          
          LD      (DSP),HL    
PAINC1:   CALL    PSRCH       
          JR      Z,PAINC     
          CALL    RBSR0       
          LD      (BXR),IX    
          JR      PAINC1      

PAIND:    LD      HL,PBXL     ;DATA SAVE
          LD      DE,BUFF     
          CALL    PAIND3      
          LD      A,(JCONT)   
          BIT     0,A         
          JR      Z,PAIND1    
LTW:      LD      HL,(PBXL)   
          LD      (BXR),HL    
          CALL    TWR         
          JR      C,LTW1      ;CLOSE
          BIT     0,A         
          JR      NZ,LTW      
LTW1:     CALL    PAIND2      
          LD      A,(JCONT)   
          CP      9           
          RET     NZ          
PAIND1:   LD      HL,(PBXR)   
          LD      (BXL),HL    
          CALL    TWR         
          JR      C,PAIND2    
          BIT     3,A         
          JR      NZ,PAIND1   
PAIND2:   LD      HL,BUFF     
          LD      DE,PBXL     
PAIND3:   LD      BC,11       
          LDIR    
          RET     

;*-----------------------------------------
;* Middle p.316, German Listing of 2Z046
;* CHECK  SAVE  DATA
;*-----------------------------------------
CSAVE:    LD      IY,00H      ;dynamic byte xxH
          LD      BC,(NDSP)   
          LD      HL,00H      
          LD      (JSAVE),HL  ;STATUS CLEAR
CSAVE1:   CALL    DSAVE       
          LD      A,(NSSP)    
          OR      A           
          RET     Z           
          DEC     A           
          LD      (NSSP),A    
          LD      (CSAVE2+1),SP 
          LD      SP,(SSP)    
          POP     IY          
          POP     BC          
          POP     HL          
          LD      (BXR),HL    
          POP     HL          
          LD      (BXL),HL    
          LD      (SSP),SP    
CSAVE2:   LD      SP,00H      ;XXH
          JR      CSAVE1      

DSAVE:    LD      A,B         
          OR      C           
          LD      (DSAVEC+1),BC 
          JP      Z,DSAVE3    
          LD      HL,(Y)      
          LD      E,(IY+0)    
          LD      D,(IY+1)    
          XOR     A           
          SBC     HL,DE       
          JR      NZ,DSAVE2   
          CALL    COMP        
          CP      5           
          JR      Z,DSAVE1    
          CP      0FH         
          JR      NZ,DSAVE4   
          LD      L,(IY+2)    ;SBXL
          LD      H,(IY+3)    
          LD      DE,(BXR)    
          XOR     A           
          SBC     HL,DE       
          JR      NC,DSAVE2   
          LD      HL,(BXL)    
          PUSH    HL          
          LD      L,(IY+2)    
          LD      H,(IY+3)    
          PUSH    HL          
          LD      (BXL),HL    
          LD      A,3         
          CALL    ESAVE       
          POP     HL          
          LD      (BXR),HL    
          POP     HL          
          LD      (BXL),HL    
          CALL    RBSR        
          LD      (BXR),IX    
          JR      DSAVE2      

DSAVE1:   LD      E,(IY+4)    ;SBXR
          LD      D,(IY+5)    
          LD      HL,(BXL)    
          XOR     A           
          SBC     HL,DE       
          JR      NC,DSAVE2   
          LD      HL,(BXR)    
          PUSH    HL          
          LD      L,(IY+4)    
          LD      H,(IY+5)    
          PUSH    HL          
          LD      (BXR),HL    
          LD      A,4         
          CALL    ESAVE       
          POP     HL          
          LD      (BXL),HL    
          POP     HL          
          LD      (BXR),HL    
          CALL    LBSR        
          LD      (BXL),IX    
DSAVE2:   LD      DE,7        
          ADD     IY,DE       
DSAVEC:   LD      BC,00H      ;XXH
          DEC     BC          
          JP      DSAVE       

DSAVE3:   LD      A,(JSAVE1)  
          OR      A           
          CALL    NZ,SVDT     
          RET     

DSAVE4:   EX      AF,AF'      
          LD      A,0FH       
          LD      (JSAVE),A   
          EX      AF,AF'      
          OR      A           
          JR      NZ,DSAVE5   
          LD      A,0FH       
          LD      (IY+6),A    
          RET     

DSAVE5:   CP      1           
          JR      NZ,DSAVE6   
          LD      L,(IY+4)    ;SBXR
          LD      H,(IY+5)    
          LD      (BXL),HL    
          CALL    LBSR        
          LD      (BXL),IX    
          JR      DSAVE8      

DSAVE6:   CP      0CH         
          JR      NZ,DSAVE9   
DSAVE7:   LD      L,(IY+2)    ;SBXL
          LD      H,(IY+3)    
          LD      (BXR),HL    
          CALL    RBSR        
          LD      (BXR),IX    
DSAVE8:   LD      A,0FH       
          LD      (IY+6),A    
          LD      (JSAVE1),A  ;SAVE DATA AFTER JOB
          JR      DSAVE2      

DSAVE9:   CP      0DH         
          JP      NZ,ESAVE    
          LD      A,(NSSP)    
          INC     A           
          CP      27          
          CCF     
          JP      C,SOVER     ;STACK OVER
          LD      (NSSP),A    
          LD      HL,(BXL)    
          PUSH    HL          ;SAVE BXL
          LD      L,(IY+4)    
          LD      H,(IY+5)    
          LD      (BXL),HL    
          CALL    LBSR        
          LD      (DSAVEB+2),IY 
          LD      DE,7        
          ADD     IY,DE       
          LD      BC,(DSAVEC+1) 
          DEC     BC          
          LD      (DSAVEA+1),SP 
          LD      SP,(SSP)    
          PUSH    IX          ;BXL
          LD      DE,(BXR)    
          PUSH    DE          
          PUSH    BC          
          PUSH    IY          
          LD      (SSP),SP    
DSAVEA:   LD      SP,00H      ;XXH
DSAVEB:   LD      IY,00H      ;XXH
          POP     HL          
          LD      (BXL),HL    
          JP      DSAVE7      

ESAVE:    EX      AF,AF'      
          CALL    SVDT        
          DEC     DE          
          LD      A,0FH       
          LD      (DE),A      
          EX      AF,AF'      
          CP      3           
          JR      NZ,ESAVE2   
ESAVE1:   LD      HL,(BXR)    
          LD      (BXL),HL    
          LD      L,(IY+4)    
          LD      H,(IY+5)    ;SBXR
          LD      (BXR),HL    
          CALL    LBSR        
          PUSH    IX          
          POP     HL          
          LD      (IY+2),L    
          LD      (IY+3),H    
          RET     

ESAVE2:   CP      4           
          JR      Z,ESAVE3    
          LD      HL,(DSP)    
          PUSH    HL          
          LD      (SVDT1+1),IY 
          CALL    SVDT        
          LD      HL,WORK     
          LD      (SVDT1+1),HL 
          LD      HL,(BXL)    
          PUSH    HL          
          CALL    ESAVE1      
          POP     HL          
          LD      (BXR),HL    
          POP     IY          
          JR      ESAVE4      

ESAVE3:   LD      HL,(BXL)    
          LD      (BXR),HL    
ESAVE4:   LD      L,(IY+2)    
          LD      H,(IY+3)    
          LD      (BXL),HL    
          CALL    RBSR        
          PUSH    IX          
          POP     HL          
          LD      (IY+4),L    
          LD      (IY+5),H    
          RET     

;*------------------------------------------------------
;* Top of p.322 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
;*-----------------------
;* NEXT  BOUNDARY  SEARCH
;*-----------------------
NBSRCH:   LD      HL,(BXL)    
          LD      (PBXL),HL   
          LD      HL,(BXR)    
          LD      (PBXR),HL   
          CALL    LBSR        
          RET     C           ;CLOSE
          LD      (BXL),IX    
          CALL    RBSR        
          LD      (BXR),IX    
          CALL    CONT0       ;CF=0
          LD      A,B         
          RET     

;*-----------------------
;*    CHANGE  Y DIRECTON
;*           &
;*    NEXT  Y CO-ORDINATE
;*-----------------------
CHDIR:    LD      A,(DIRECT)  
          CPL     
          LD      (DIRECT),A  
CHDIR0:   LD      HL,(Y)      
          INC     L           
          OR      A           
          JR      NZ,CHDIR1   
          DEC     L           
          DEC     L           
CHDIR1:   LD      (Y),HL      
          RET     

TWR:      CALL    CHDIR       
          CALL    NBSRCH      
          RET     C           
          PUSH    AF          
          LD      HL,(BXL)    
          PUSH    HL          
          LD      HL,(BXR)    
          PUSH    HL          
          CALL    CSAVE       
          LD      A,(JSAVE)   
          OR      A           
          CALL    Z,SVDT      
          POP     HL          
          LD      (BXR),HL    
          POP     HL          
          LD      (BXL),HL    
          POP     AF          
          RET     

;*---------------------
;* LEFT BOUNDARY SEARCH
;*---------------------
LBSR:     LD      DE,(BXR)    
          LD      HL,(BXL)    
          PUSH    HL          
          LD      (BSRCH4+1),DE 
          LD      HL,00H      
          LD      (BSRCH6+1),HL 
          LD      A,2BH       ;DEC IX
          LD      (BSRCH3+1),A 
          LD      A,2FH       ;CPL
          LD      (BSRCH5),A  
          XOR     A           
          LD      (BSRCH7),A  
          LD      HL,BSRCHL   
          LD      (BSRCH1+1),HL 
          LD      HL,BSRCHR   
          LD      (BSRCH2+1),HL 
          POP     DE          
          INC     DE          
          JR      BSRCH       
;*-----------------------------------------------------------
;* Near Top of p.324 in German Listing of MZ-2Z046 Disk Basic
;*-----------------------------------------------------------
;*----------------------
;* RIGHT BOUNDARY SEARCH
;*----------------------
RBSR:     LD      DE,(BXR)    
RBSR0:    LD      HL,(BXL)    
          LD      (BSRCH6+1),HL 
          DB      21H         ;LD HL,640 or 320
LRBSR:    DW      0280H       ;dynamic 0280H or 0140H (WAS 8002H!!)
          LD      (BSRCH4+1),HL 
          LD      A,23H       ;INC IX
          LD      (BSRCH3+1),A 
          LD      A,2FH       ;CPL
          LD      (BSRCH7),A  
          XOR     A           
          LD      (BSRCH5),A  
          LD      HL,BSRCHR   
          LD      (BSRCH1+1),HL 
          LD      HL,BSRCHL   
          LD      (BSRCH2+1),HL 
          DEC     DE          
;*----------------
;*  SEARCH ROUTINE
;*----------------
BSRCH:    LD      HL,(Y)      
          PUSH    DE          
          POP     IX          
          CALL    ADCH        
          LD      DE,TDOTN    
          PUSH    HL          
          LD      H,0         
          LD      L,A         
          ADD     HL,DE       
          LD      C,(HL)      
          POP     HL          
          CALL    WAREA       
          LD      E,A         
          AND     C           
BSRCH1:   JP      Z,BSRCHL    ;JP BSRCHR
BSRCH2:   CALL    BSRCHR      ;CALL BSRCHL
BSRCH3:   DEC     IX          ;INC IX
          RET     

;*--------------
;*  SEARCH  LEFT
;*--------------
BSRCHL:   DEC     IX          
          RRC     C           
          JR      NC,BSRCHC   
          PUSH    IX          
          EXX     
          POP     DE          
          INC     DE          
BSRCH6:   LD      HL,00H      ;BX
          INC     HL          
          SBC     HL,DE       
          EXX     
          RET     NC          
          DEC     HL          
          CALL    WAREA       
          LD      E,A         
BSRCHC:   LD      A,E         
BSRCH7:   NOP                 ;CPL
          AND     C           
          JP      Z,BSRCHL    
          RET     

;*---------------
;*  SEARCH  RIGHT
;*---------------
BSRCHR:   INC     IX          
          RLC     C           
          JR      NC,BSRCHA   
          CALL    BSRCHD      
          RET     C           
          INC     HL          
          CALL    WAREA       
          LD      E,A         
BSRCHA:   LD      A,E         
BSRCH5:   CPL                 ;NOP
          AND     C           
          JR      Z,BSRCHR    
BSRCHD:   PUSH    IX          
          EXX     
          POP     HL          
BSRCH4:   LD      DE,BXR      
          XOR     A           
          SBC     HL,DE       
          EXX     
          CCF     
          RET     

;*-------------
;*  CONT. CHECK
;*-------------
;*-----------------------------------------------------
;* The original source shows the routine below as CONT
;* This creates a nasty problem with duplicate labels !
;*-----------------------------------------------------
CONT0:    LD      B,0H        
          LD      HL,(PBXR)   
          LD      DE,(BXR)    
          CALL    CONT1       
          LD      HL,(PBXL)   
          LD      DE,(BXL)    
          INC     HL          ;FOR  HL=FFH
          INC     DE          ;FOR  DE=FFH
CONT1:    PUSH    HL          
          XOR     A           
          INC     HL          
          SBC     HL,DE       
          POP     HL          
          RL      B           
          INC     DE          
          EX      DE,HL       
          SBC     HL,DE       
          RL      B           
          RET     

;*---------------
;*   POINT DATA
;*   SAVE & LOAD
;*---------------
;*------------
;*  DATA  SAVE
;*------------
SVDT:     LD      DE,(DSP)    
SVDT0:    LD      HL,0000     ; XX  END ADD
          XOR     A           
          SBC     HL,DE       
          JR      NC,SVDT1    
SOVER:    DB      31H         ;STACK POINTER
SOVER1:   DW      00H         ;LD SP,xxH
          SCF     
          RET     

SVDT1:    LD      HL,WORK     
          LD      BC,0007H    
          LDIR    
          LD      (DSP),DE    
          LD      HL,(NDSP)   
          INC     HL          
          LD      (NDSP),HL   
          RET     

;*----------------
;*  PAINT & SEARCH
;*----------------
PSRCH:    LD      HL,(Y)      
          LD      DE,(BXR)    
          DEC     DE          
          CALL    ADCH        
          LD      DE,TDOTR    
          PUSH    HL          
          LD      H,0         
          LD      L,A         
          ADD     HL,DE       
          INC     C           
          LD      B,C         
          LD      C,(HL)      
          POP     HL          
PSRCH1:   CALL    WAREA       
          AND     C           
          JR      NZ,PSRCH2   ;BOUND
          DI      
          IN      A,(LSE0)    
          LD      (HL),C      
          IN      A,(LSE1)    
          EI      
          LD      C,0FFH      
          DEC     HL          
          DJNZ    PSRCH1      
          LD      DE,-1       
          JR      PSRCH5      

PSRCH2:   LD      E,B         
          LD      B,7H        
          LD      D,00H       
PSRCH3:   RLC     A           
          JR      C,PSRCH4    
          SCF     
          RR      D           
          DJNZ    PSRCH3      
PSRCH4:   IN      A,(LSE0)    
          LD      A,C         
          AND     D           
          LD      (HL),A      
          IN      A,(LSE1)    
          LD      A,E         
          DEC     A           
          RLC     A           
          RLC     A           
          RLC     A           
          LD      C,A         
          LD      A,07H       
          AND     C           
          LD      D,A         
          LD      A,0F8H      
          AND     C           
          OR      B           
          LD      E,A         
PSRCH5:   XOR     A           
          LD      HL,(BXL)    
          SBC     HL,DE       
          RET     

;*-------------------------------------------
;* Routine at DPEEK: below is copied to WAREA
;*-------------------------------------------
DPEEK:    PUSH    HL          
          EXX     
          POP     HL          
          DI      
          IN      A,(LSE0)    
          LD      C,LSRF      
          XOR     A           
DPEEK1:   LD      B,00H       ;RE DATA
          OUT     (C),B       
          OR      (HL)        
DPEEK2:   LD      E,A         
          IN      A,(LSE1)    
          EI      
          LD      A,E         
          EXX     
DPEEK3:   RET     

;*---------------
;*  COMP. BXL,BXR
;*---------------
COMP:     LD      HL,(BXL)    
          LD      E,(IY+2)    
          LD      D,(IY+3)    
          INC     HL          
          INC     DE          
          XOR     A           
          CALL    COMP1       
          LD      HL,(BXR)    
          LD      E,(IY+4)    
          LD      D,(IY+5)    
COMP1:    SBC     HL,DE       
          RLA     
          RLA     
          RET     Z           
          OR      1           
          RET     

;*       END of code in the original module MON-GRPH.ASM
;*=============================================================================
;*    START of NEW module containing PATCHES 1 to 8 and a large SPARE AREA

;*---------------------------------
;* MZ-800 QUICKDISK BASIC MZ- 5Z009
;*Patches to convert v1.0A to v1.0B
;*Added to ASM file 24 January 2004
;*---------------------------------

PATCH1:   LD      A,0C0H      
          OUT     (SIOAC),A   
          RET     

PATCH2:   DI      
          CALL    EMFRB       
          EI      
          RET     

PATCH3:   DI      
          CALL    EMCLR       
          EI      
          RET     

PATCH4:   DI      
          JP      EMLD2       

PATCH5:   LD      (HL),D      
          OR      A           
          EI      
          RET     

PATCH6:   DI      
          CALL    EMLDD       
          EI      
          RET     

PATCH7:   DI      
          JP      EMLD2       

PATCH8:   CALL    EMSVB       
          EI      
          RET     

;*============================================================================

          DB      0,0,0,0,0,0,0,0,0,0,0,0,0 ; SPARE AREA 55B3H to 57FFH



H55C0:    DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



H5600:    DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



H5700:    DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 



          DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 




;*      END of additional module containing PATCHES 1 to 8 and SPARE AREA
;*============================================================================
;*       START of original module XSYS.ASM

          ORG     5800H       ;set start of main BASIC module

BSTART:   
;*
;*       END of original module XSYS.ASM
;*============================================================================
;*Original module MONEQU.ASM was here, omitted as it created duplicate labels
;*============================================================================
;*    START of original module BASIC.ASM    
;*
;*---------------------------
;* MZ-800 BASIC  Main program
;* FI:BASIC  ver 1.0A 9.06.84
;* Programmed by T.Miho
;*---------------------------

CHYEN:    EQU     7DH         ;YEN character (on Japanese machines)

SBASIC:   PUSH    BC          
          CALL    CLSHET      
          POP     BC          
          LD      HL,NEWAD0   
          LD      (TEXTST),HL 
          LD      HL,CLSST    
          LD      (SYSSTA),HL 
          LD      A,B         
          OR      A           
COLDRT:   JP      Z,SBAS2     ;JP SBAS3  Change
          CP      1           
          JR      Z,SBAS2     
          LD      HL,ARUN     
          LD      DE,INBUFL   
          LD      BC,16       
          LDIR    
SBAS2:    LD      DE,IMDBUF   
          RST     18H         
          DB      .CRTMS      
          RST     18H         
          DB      .BELL       
          LD      A,0C3H      
          LD      (COLDRT),A  
          LD      HL,SBAS3    
          LD      (COLDRT+1),HL 
SBAS3:    LD      HL,NEWAD0   
MEMCLI:   LD      (HL),0      
          INC     HL          
          LD      A,H         
          CP      0FFH        ;mem max
          JR      C,MEMCLI    
          CALL    MEMSET      
          CALL    NEWTXT      
          CALL    IOINIT      
          JR      HOTENT      

ARUN:     DB      15          
          DB      "RUN \"AUTO RUN\"" 
          DB      0DH         

CLSHET:   LD      A,1         ;INIT "CRT:M1"
          RST     18H         
          DB      .DSMOD      
          XOR     A           
          LD      (PWMODE),A  
          INC     A           
          LD      (CRTMD2),A  
          LD      (CRTMD1),A  
          RST     18H         
          DB      .ICRT       
          RET     

CLSST:    CALL    CLSHET      
HOTENT:   LD      HL,ERRORA   
          LD      (ERRORP),HL 
OK:       RST     18H         
          DB      .CR2        
          LD      DE,OKMES    
          RST     18H         
          DB      .CRTMS      
          RST     18H         
          DB      .CR1        
INPAGN:   LD      A,(CONTFG)  
          OR      A           
          JR      NZ,INPAG2   
          LD      SP,(INTFAC) 
          LD      HL,0FFFFH   
          PUSH    HL          
          LD      (STACK),SP  
INPAG2:   LD      HL,0        ;Set direct-mode
          LD      (LNOBUF),HL 
          XOR     A           
          LD      (CMTMSG),A  
          CALL    AUTODS      
          RST     18H         ;FD,QD motor off
          DB      .ERCVR      
          LD      DE,KEYBUF   
          RST     18H         
          DB      .GETL       
          JR      NC,NORINP   
AUTOFF:   LD      HL,AUTOFG   
          LD      A,(HL)      
          OR      A           
          LD      (HL),0      
          JR      NZ,OK       
          JR      INPAGN      

NORINP:   CALL    SKPDE       
          OR      A           
          JR      Z,INPAGN    
          CALL    TSTNUM      
          JP      NC,EDITOR   
          LD      HL,IMDBUF   ;Direct command
          PUSH    HL          
          CALL    CVIMTX      
          INC     HL          
          LD      (NXTLPT),HL 
          CALL    LDHL00      
          POP     HL          
          JR      MAIN        

;*--------
;* Execute
;*--------
MAIN9:    CALL    CHKEND      
MAIN:     LD      (STACK),SP  
MAIN0:    LD      DE,MAIN9    
          PUSH    DE          
MAIN2:    LD      (TEXTPO),HL 
          CALL    BRKCHK      
          JP      Z,BREAKZ    
MAIN4:    LD      A,(HL)      
          INC     HL          
          CP      80H         
          JR      NC,STATEM   
          CP      27H         ; REM
          JP      Z,DATA      
          CP      20H         ; SP
          JR      Z,MAIN4     
          CP      3AH         ; colon
          JR      Z,MAIN2     
          OR      A           
          JR      Z,ENDLIN    ;END OF LINE
          DEC     HL          
          SUB     41H         
          CP      26          
          JP      C,LET       
          JP      ER01        

ENDLIN:   LD      HL,(NXTLPT) 
NXLINE:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      A,D         
          OR      E           
          JR      Z,ENDPRG    ;END OF PROGRAM
          LD      (CMTMSG),A  
          EX      DE,HL       
          ADD     HL,DE       
          DEC     HL          
          LD      (NXTLPT),HL 
          EX      DE,HL       
          INC     HL          
          CALL    LDDEMI      
          LD      (LNOBUF),DE 
          CALL    TRDISP      
          POP     DE          
          JR      MAIN        

ENDPRG:   POP     HL          
          CALL    QDIRECT     
          JP      Z,OK        
          XOR     A           
          LD      (CONTFG),A  
          LD      A,(ERRORF)  
          CP      2           
          JP      Z,ER20      
          PUSH    HL          
          JP      ENDCMD      ;end command

STATEM:   CP      0FFH        ;command jp
          JP      Z,PFUNCT    
          LD      DE,GJPTBL   
          CP      0FEH        
          JR      NZ,NROSTM   
          LD      A,(HL)      
          INC     HL          
          JR      MIDFJP      

NROSTM:   CP      0E0H        
          JP      NC,ER01     
          LD      DE,SJPTBL   
MIDFJP:   ADD     A,A         
          PUSH    HL          
          EX      DE,HL       
          LD      E,A         
          LD      D,0         
          ADD     HL,DE       
          LD      A,(HL)      
          INC     HL          
          LD      H,(HL)      
          LD      L,A         
          EX      (SP),HL     
ENDCHK:   CALL    HLFTCH      
ENDCK0:   OR      A           
          RET     Z           
          CP      ':'         
          RET     

QDIRECT:  PUSH    HL          ;Direct mode ?
          LD      HL,(LNOBUF) 
          LD      A,L         
          OR      H           
          POP     HL          
          RET     

;*---------------------
;* BASIC KEYWORD  TABLE
;*---------------------
CTBL1:    DB      "GOT"       ; TOKEN 80H
          DB      'O'+80H     
          DB      "GOSU"      
          DB      'B'+80H     
          DB      80H         
          DB      "RU"        
          DB      'N'+80H     
          DB      "RETUR"     

          DB      'N'+80H     
          DB      "RESTOR"    

          DB      'E'+80H     
          DB      "RESUM"     

          DB      'E'+80H     
          DB      "LIS"       
          DB      'T'+80H     
          DB      80H         ; TOKEN 88H
          DB      "DELET"     

          DB      'E'+80H     
          DB      "RENU"      
          DB      'M'+80H     
          DB      "AUT"       
          DB      'O'+80H     
          DB      "EDI"       
          DB      'T'+80H     
          DB      "FO"        
          DB      'R'+80H     
          DB      "NEX"       
          DB      'T'+80H     
          DB      "PRIN"      
          DB      'T'+80H     
          DB      80H         ; TOKEN 90H (NOT USED)
          DB      "INPU"      
          DB      'T'+80H     
          DB      80H         
          DB      "I"         
          DB      'F'+80H     
          DB      "DAT"       
          DB      'A'+80H     
          DB      "REA"       
          DB      'D'+80H     
          DB      "DI"        
          DB      'M'+80H     
          DB      "RE"        
          DB      'M'+80H     
          DB      "EN"        ; TOKEN 98H
          DB      'D'+80H     
          DB      "STO"       
          DB      'P'+80H     
          DB      "CON"       
          DB      'T'+80H     
          DB      "CL"        
          DB      'S'+80H     
          DB      80H         
          DB      "O"         
          DB      'N'+80H     
          DB      "LE"        
          DB      'T'+80H     
          DB      "NE"        
          DB      'W'+80H     
          DB      "POK"       ; TOKEN A0H
          DB      'E'+80H     
          DB      "OF"        
          DB      'F'+80H     
          DB      "PMOD"      
          DB      'E'+80H     
          DB      "PSKI"      
          DB      'P'+80H     
          DB      "PLO"       
          DB      'T'+80H     
          DB      "PLIN"      
          DB      'E'+80H     
          DB      "RLIN"      
          DB      'E'+80H     
          DB      "PMOV"      
          DB      'E'+80H     
          DB      "RMOV"      ; TOKEN A8H
          DB      'E'+80H     
          DB      "TRO"       
          DB      'N'+80H     
          DB      "TROF"      
          DB      'F'+80H     
          DB      "INP"       
          DB      '@'+80H     
          DB      "DEFAUL"    

          DB      'T'+80H     
          DB      "GE"        
          DB      'T'+80H     
          DB      "PCOLO"     

          DB      'R'+80H     
          DB      "PHOM"      
          DB      'E'+80H     
          DB      "HSE"       ; TOKEN B0H
          DB      'T'+80H     
          DB      "GPRIN"     

          DB      'T'+80H     
          DB      "KE"        
          DB      'Y'+80H     
          DB      "AXI"       
          DB      'S'+80H     
          DB      "LOA"       
          DB      'D'+80H     
          DB      "SAV"       
          DB      'E'+80H     
          DB      "MERG"      
          DB      'E'+80H     
          DB      "CHAI"      
          DB      'N'+80H     
          DB      "CONSOL"    ; TOKEN B8H      

          DB      'E'+80H     
          DB      "SEARC"     

          DB      'H'+80H     
          DB      "OUT"       
          DB      '@'+80H     
          DB      "PCIRCL"    

          DB      'E'+80H     
          DB      "PTES"      
          DB      'T'+80H     
          DB      "PAG"       
          DB      'E'+80H     
          DB      "WAI"       
          DB      'T'+80H     
          DB      "SWA"       
          DB      'P'+80H     
          DB      80H         ; TOKEN C0H (NOT USED)
          DB      "ERRO"      
          DB      'R'+80H     
          DB      "ELS"       
          DB      'E'+80H     
          DB      "US"        
          DB      'R'+80H     
          DB      "BY"        
          DB      'E'+80H     
          DB      80H         
          DB      80H         
          DB      "DE"        
          DB      'F'+80H     
          DB      80H         ; TOKEN C8H (NOT USED)
          DB      80H         
          DB      "LABE"      
          DB      'L'+80H     
          DB      80H         
          DB      80H         
          DB      80H         
          DB      "WOPE"      
          DB      'N'+80H     
          DB      "CLOS"      
          DB      'E'+80H     
          DB      "ROPE"      ; TOKEN D0H
          DB      'N'+80H     
          DB      "XOPE"      
          DB      'N'+80H     
          DB      80H         
          DB      80H         
          DB      80H         
          DB      "DI"        
          DB      'R'+80H     
          DB      80H         
          DB      80H         
          DB      "RENAM"     ; TOKEN D8H

          DB      'E'+80H     
          DB      "KIL"       
          DB      'L'+80H     
          DB      "LOC"       
          DB      'K'+80H     
          DB      "UNLOC"     

          DB      'K'+80H     
          DB      "INI"       
          DB      'T'+80H     
          DB      80H         
          DB      80H         
          DB      80H         
          DB      'T'         ; TOKEN E0H
          DB      'O'+80H     
          DB      "STE"       
          DB      'P'+80H     
          DB      "THE"       
          DB      'N'+80H     
          DB      "USIN"      
          DB      'G'+80H     
          DB      80H         ; TOKEN E4H (RESERVED FOR PI)
          DB      "AL"        
          DB      'L'+80H     
          DB      "TA"        
          DB      'B'+80H     
          DB      "SP"        
          DB      'C'+80H     
          DB      80H         ; TOKEN E8H
          DB      80H         
          DB      ".XO"       
          DB      'R'+80H     
          DB      ".O"        
          DB      'R'+80H     
          DB      ".AN"       
          DB      'D'+80H     
          DB      ".NO"       
          DB      'T'+80H     
          DB      ">"         
          DB      '<'+80H     
          DB      "<"         
          DB      '>'+80H     
          DB      "="         ; TOKEN F0H
          DB      '<'+80H     
          DB      "<"         
          DB      '='+80H     
          DB      "="         
          DB      '>'+80H     
          DB      ">"         
          DB      '='+80H     
          DB      '='+80H     
          DB      '>'+80H     
          DB      '<'+80H     
          DB      '+'+80H     
          DB      '-'+80H     ; TOKEN F8H
          DB      '\\'+80H    ; THIS WAS '%YEN' in Japanese source code
          DB      ".MO"       
          DB      'D'+80H     
          DB      '/'+80H     
          DB      '*'+80H     
          DB      '^'+80H     
          DB      0FFH        ;FF marks the END of CTBL1

GTABL:    DB      80H         ; DOUBLE TOKEN FE 80
          DB      "CSE"       
          DB      'T'+80H     
          DB      "CRESE"     

          DB      'T'+80H     
          DB      "CCOLO"     

          DB      'R'+80H     
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         ; DOUBLE TOKEN FE 88 (NOT USED)
          DB      80H         
          DB      "SOUN"      
          DB      'D'+80H     
          DB      80H         
          DB      "NOIS"      
          DB      'E'+80H     
          DB      "BEE"       
          DB      'P'+80H     
          DB      80H         ; MZ-1500 VOICE
          DB      80H         
          DB      "COLO"      ; DOUBLE TOKEN FE 90
          DB      'R'+80H     
          DB      80H         ; MZ-1500 PRTY
          DB      "SE"        
          DB      'T'+80H     
          DB      "RESE"      
          DB      'T'+80H     
          DB      "LIN"       
          DB      'E'+80H     
          DB      "BLIN"      
          DB      'E'+80H     
          DB      "PA"        
          DB      'L'+80H     
          DB      "CIRCL"     

          DB      'E'+80H     
          DB      "BO"        ; DOUBLE TOKEN FE 98      
          DB      'X'+80H     
          DB      "PAIN"      
          DB      'T'+80H     
          DB      "POSITIO"   

          DB      'N'+80H     
          DB      "PATTER"    

          DB      'N'+80H     
          DB      "HCOP"      
          DB      'Y'+80H     
          DB      80H         ; MZ-1500 KPATTERN
          DB      80H         ; MZ-1500 FPRINT
          DB      80H         
          DB      "SYMBO"     ; DOUBLE TOKEN FE A0

          DB      'L'+80H     
          DB      80H         
          DB      "MUSI"      
          DB      'C'+80H     
          DB      "TEMP"      
          DB      'O'+80H     
          DB      "CURSO"     

          DB      'R'+80H     
          DB      "VERIF"     

          DB      'Y'+80H     
          DB      "CL"        
          DB      'R'+80H     
          DB      "LIMI"      
          DB      'T'+80H     
          DB      80H         ; DOUBLE TOKEN FE A8
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      "BOO"       
          DB      'T'+80H     
          DB      0FFH        ; FFH marks the END of GTABL 

CTBL2:    DB      "IN"        ; DOUBLE TOKEN FF 80
          DB      'T'+80H     
          DB      "AB"        
          DB      'S'+80H     
          DB      "SI"        
          DB      'N'+80H     
          DB      "CO"        
          DB      'S'+80H     
          DB      "TA"        
          DB      'N'+80H     
          DB      "L"         
          DB      'N'+80H     
          DB      "EX"        
          DB      'P'+80H     
          DB      "SQ"        
          DB      'R'+80H     
          DB      "RN"        ; DOUBLE TOKEN FF 88
          DB      'D'+80H     
          DB      "PEE"       
          DB      'K'+80H     
          DB      "AT"        
          DB      'N'+80H     
          DB      "SG"        
          DB      'N'+80H     
          DB      "LO"        
          DB      'G'+80H     
          DB      "FRA"       
          DB      'C'+80H     
          DB      "PA"        
          DB      'I'+80H     
          DB      "RA"        
          DB      'D'+80H     
          DB      80H         ; DOUBLE TOKEN FF 90
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         ; DOUBLE TOKEN FF 98
          DB      80H         
          DB      80H         
          DB      80H         
          DB      "STIC"      
          DB      'K'+80H     
          DB      "STRI"      
          DB      'G'+80H     
          DB      80H         ; MZ-1500 JOY
          DB      80H         
          DB      "CHR"       ; DOUBLE TOKEN FF A0  
          DB      '$'+80H     
          DB      "STR"       
          DB      '$'+80H     
          DB      "HEX"       
          DB      '$'+80H     
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      80H         
          DB      "SPACE"     ; DOUBLE TOKEN FF A8

          DB      '$'+80H     
          DB      80H         
          DB      80H         ; MZ-1500 ASCCHR$
          DB      "AS"        
          DB      'C'+80H     
          DB      "LE"        
          DB      'N'+80H     
          DB      "VA"        
          DB      'L'+80H     
          DB      80H         
          DB      80H         
          DB      80H         ; DOUBLE TOKEN FF B0
          DB      80H         
          DB      80H         ; MZ-1500 HEXCHR$
          DB      "ER"        
          DB      'N'+80H     
          DB      "ER"        
          DB      'L'+80H     
          DB      "SIZ"       
          DB      'E'+80H     
          DB      "CSR"       
          DB      'H'+80H     
          DB      "CSR"       
          DB      'V'+80H     
          DB      "POS"       ; DOUBLE TOKEN FF B8
          DB      'H'+80H     
          DB      "POS"       
          DB      'V'+80H     
          DB      "LEFT"      
          DB      '$'+80H     
          DB      "RIGHT"     

          DB      '$'+80H     
          DB      "MID"       
          DB      '$'+80H     
          DB      80H         ; MZ-1500 FONT$
          DB      80H         
          DB      80H         
          DB      80H         ; DOUBLE TOKEN FF C0
          DB      80H         
          DB      80H         
          DB      80H         
          DB      "TI"        
          DB      '$'+80H     
          DB      "POIN"      
          DB      'T'+80H     
          DB      "EO"        
          DB      'F'+80H     
          DB      "F"         
          DB      'N'+80H     
          DB      0FFH        ; FFH marks the END of CTBL2

;*-----------------------------
;* BASIC KEYWORDS ADDRESS TABLE
;*-----------------------------
SJPTBL:   DW      GOTO        ; 80
          DW      GOSUB       
          DW      ER01        
          DW      RUN         
          DW      RETURN      
          DW      RESTOR      
          DW      RESUME      
          DW      LIST        
          DW      ER01        ; 88
          DW      DELETE      
          DW      RENUM       
          DW      AUTO        
          DW      EDIT        
          DW      FOR         
          DW      NEXT        
          DW      PRINT       

          DW      ER01        ; 90
          DW      INPUT       
          DW      ER01        
          DW      IF          
          DW      DATA        
          DW      READ        
          DW      DIM         
          DW      REM         
          DW      ENDCMD      ; 98
          DW      STOP        
          DW      CONT        
          DW      CLS         
          DW      ER01        
          DW      ON          
          DW      LET         
          DW      NEW         

          DW      POKE        ; A0
          DW      ER01        
          DW      PMODE       ;WAS 'MODE' (error)
          DW      SKIP        
          DW      PLOT        
          DW      PLINE       
          DW      RLINE       
          DW      PMOVE       
          DW      RMOVE       ; A8
          DW      TRON        
          DW      TROFF       
          DW      INP@        
          DW      DEFAULT     
          DW      GETOP       
          DW      PCOLOR      
          DW      PHOME       

          DW      HSET        ; B0
          DW      GPRINT      
          DW      KLIST       
          DW      AXIS        
          DW      LOAD        
          DW      SAVE        
          DW      MERGE       
          DW      CHAIN       
          DW      CONSOL      ; B8
          DW      SEARCH      
          DW      OUT@        
          DW      PCIRCLE     
          DW      TEST        
          DW      PAGE        
          DW      PAUSE       
          DW      SWAP        

          DW      ER01        ; C0
          DW      ERRORCMD       
          DW      ELSECMD        
          DW      USR         
          DW      BYE         
          DW      ER01        
          DW      ER01        
          DW      DEFOP       
          DW      ER01        ; C8
          DW      ER01        
          DW      LABEL       
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      WOPEN       
          DW      CLOSE       

          DW      ROPEN       ; D0
          DW      XOPEN       
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      DIR         
          DW      ER01        
          DW      ER01        
          DW      RENAME      ; D8
          DW      KILL        
          DW      LOCK        
          DW      UNLOCK      
          DW      INIT        
          DW      ER01        
          DW      ER01        
          DW      ER01        

GJPTBL:   DW      ER01        ; FE 80
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        ; FE 88
          DW      ER01        
          DW      SOUND       
          DW      ER01        
          DW      NOISE       
          DW      BEEP        
          DW      ER01        
          DW      ER01        

          DW      COLOR       ; FE 90
          DW      ER01        
          DW      SETCMD         
          DW      RESET       
          DW      LINE        
          DW      BLINE       
          DW      PALET       
          DW      CIRCLE      
          DW      BOX         ; FE 98
          DW      PAINT       
          DW      POSITION    
          DW      PATTERN     
          DW      HCOPY       
          DW      ER01        
          DW      ER01        
          DW      ER01        

          DW      SMBOL       ; FE A0
          DW      ER01        
          DW      MUSIC       
          DW      TEMPO       
          DW      CURSOR      
          DW      VERIFY      
          DW      CLR         
          DW      LIMIT       
          DW      ER01        ; FE A8
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      BOOT        

FJPTBL:   DW      INTOPR      ; FF 80
          DW      ABS         
          DW      SIN         
          DW      COS         
          DW      TAN         
          DW      LOG         ;LN (to base 'e')
          DW      EXP         
          DW      SQR         
          DW      RND         ; FF 88
          DW      PEEK        
          DW      ATN         
          DW      SGN         
          DW      LOGD        ;LOG (to base 10)
          DW      FRACT       
          DW      PAI         
          DW      RAD         

          DW      ER01        ; FF 90
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        ; FF 98
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      STCK        
          DW      STIG        
          DW      ER01        
          DW      ER01        

          DW      ER01        ; FF A0 CHR$
          DW      STR$        
          DW      HEX$        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      SPACE$      ; FF A8
          DW      ER01        
          DW      ER01        
          DW      ASC         
          DW      LEN         
          DW      VAL         
          DW      ER01        
          DW      ER01        

          DW      ER01        ; FF B0
          DW      ER01        
          DW      ER01        
          DW      ERR         
          DW      ERL         
          DW      SIZE        
          DW      CSRH        
          DW      CSRV        
          DW      POSH        ; FF B8
          DW      POSV        
          DW      LEFT$       
          DW      RIGHT$      
          DW      MID$        
          DW      ER01        
          DW      ER01        
          DW      ER01        

          DW      ER01        ; FF C0
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      TI$         
          DW      POINT       
          DW      EOF         
          DW      FNEXP       ; FN
          DW      ER01        ; FF C8
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        
          DW      ER01        

;*--------------
;* GET LINE ADRS
;*--------------
GETLIN:   CALL    TEST1       
          DB      0CH         
          JR      NZ,GLIN2    
          CALL    LDDEMI      
          OR      0FFH        
          RET     

GLIN2:    INC     HL          
          CP      0BH         
          JR      NZ,GLIN4    
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          INC     HL          
          LD      A,E         
          OR      D           
          RET     Z           
          EX      DE,HL       
          CALL    LNOSER      
          JP      C,ER16      
          EX      DE,HL       
          DEC     HL          
          LD      (HL),D      
          DEC     HL          
          LD      (HL),E      
          DEC     HL          
          LD      (HL),0CH    
          INC     HL          
          INC     HL          
          INC     HL          
          OR      0FFH        
          LD      (REFFLG),A  
          RET     

GLIN4:    CP      '"'         
          JP      NZ,ER01     
          LD      (LABA+1),HL 
          LD      B,0         
GLIN6:    LD      A,(HL)      
          OR      A           
          JR      Z,GLIN8     
          INC     HL          
          CP      '"'         
          JR      Z,GLIN8     
          INC     B           
          JR      GLIN6       
GLIN8:    LD      A,B         
          OR      A           
          JP      Z,ER01      
          LD      (LABN+1),A  
          EX      DE,HL       
          CALL    LABSER      
          JP      C,ER16      
          EX      DE,HL       
          OR      0FFH        
          RET     

;*-----------------------
;* LABSER .. Label search
;* LNOSER .. Line# search
;*-----------------------
LABSER:   PUSH    BC          
          LD      BC,LABSUB   
          JR      LNOSR0      
LNOSER:   PUSH    BC          
          LD      BC,LNOSUB   
LNOSR0:   LD      (LNOSRQ+1),BC 
          PUSH    DE          
          EX      DE,HL       
          LD      HL,(TEXTST) 
LNOSR2:   LD      C,(HL)      
          INC     HL          
          LD      B,(HL)      
          LD      A,B         
          OR      C           
          SCF     
          JR      Z,LNOSR9    
          DEC     HL          
          PUSH    HL          
          ADD     HL,BC       
          EX      (SP),HL     
LNOSRQ:   CALL    0           
          JR      C,LNOSR8    
          JR      Z,LNOSR8    
          POP     HL          
          JR      LNOSR2      
LNOSR8:   POP     DE          ;DMY
LNOSR9:   POP     DE          
          POP     BC          
          RET     

LNOSUB:   INC     HL          
          INC     HL          
          INC     HL          
          LD      A,D         
          CP      (HL)        
          RET     NZ          
          DEC     HL          
          LD      A,E         
          CP      (HL)        
          DEC     HL          
          DEC     HL          
          RET     

LABSUB:   PUSH    HL          
          INC     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          CALL    TEST1       ;LABEL
          DB      0CAH        
          JR      NZ,LABSR9   
          CALL    TEST1       
          DB      '"'         
          JR      NZ,LABSR9   
LABN:     LD      B,0         ;Label length
LABA:     LD      DE,0        ;Label adrs
LABSR2:   LD      A,(DE)      
          CP      (HL)        
          JR      NZ,LABSR9   
          INC     HL          
          INC     DE          
          DJNZ    LABSR2      
          LD      A,(HL)      
          CP      '"'         
          JR      Z,LABSR9    
          OR      A           
LABSR9:   SCF     
          CCF     
          POP     HL          
          RET     

;*----------------------
;* START.LINE - END.LINE
;*----------------------
GTSTED:   LD      DE,0000H    
          LD      BC,0FFFFH   
          CALL    END2C       
          RET     Z           
          CP      '-'         
          JR      Z,GTNXNM    
          CP      '.'         
          LD      DE,(EDLINE) 
          JR      Z,NX2C2D    
          CALL    TESTX       
          DB      0BH         
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
NX2C2D:   INC     HL          
          CALL    END2C       
          JR      Z,ONELLN    
          CP      '-'         
          JR      Z,GTNXNM    
ONELLN:   LD      C,E         
          LD      B,D         
          RET     

GTNXNM:   INC     HL          
          CALL    END2C       
          RET     Z           
          CP      '.'         
          JR      NZ,GTEDNO   
          LD      BC,(EDLINE) 
          INC     HL          
          RET     

GTEDNO:   CALL    TESTX       
          DB      0BH         
          LD      C,(HL)      
          INC     HL          
          LD      B,(HL)      
          INC     HL          
          RET     

END2C:    CALL    ENDCHK      
          RET     Z           
          CP      ','         
          RET     

;*------------------------------
;*  REFADR ... Line ref = Adrs
;*  REFLNO ... Line ref = Number
;*------------------------------
REFADR:   CALL    PUSHR       
          LD      A,0FFH      
          LD      (REFFLG),A  
          LD      HL,CVASUB   
          JR      REFL2       

REFLNO:   CALL    PUSHR       
          CALL    CLRFLG      
REFLNX:   LD      A,(REFFLG)  
          OR      A           
          RET     Z           
          XOR     A           
          LD      (REFFLG),A  
          LD      HL,CVLSUB   
REFL2:    LD      (CVRTLN+1),HL 
          LD      HL,(TEXTST) 
          DEC     HL          
REFL4:    INC     HL          
          LD      A,(HL)      
          INC     HL          
          OR      (HL)        
          RET     Z           
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      (CVALN+1),DE 
REFL6:    CALL    IFSKSB      
          OR      A           
          JR      Z,REFL4     
CVRTLN:   JP      0           

CVLSUB:   CP      0CH         
          JR      NZ,REFL6    
          DEC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          PUSH    HL          
          EX      DE,HL       
          INC     HL          
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          POP     HL          
          LD      (HL),D      
          DEC     HL          
          LD      (HL),E      
          DEC     HL          
          LD      (HL),0BH    
          INC     HL          
          INC     HL          
          JR      REFL6       

CVASUB:   CP      0BH         
          JR      NZ,REFL6    
          DEC     HL          
          PUSH    HL          
          CALL    INDRCT      
          LD      E,L         
          LD      D,H         
          LD      A,L         
          OR      H           
          JR      Z,CVAS9     
          CALL    LNOSER      
          JR      C,CVASE     
          EX      DE,HL       
          POP     HL          
          DEC     HL          
          LD      (HL),0CH    
          INC     HL          
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          JR      REFL6       

CVASE:    PUSH    DE          
          LD      A,16        ;UNDEF LINE
          RST     18H         
          DB      .ERRX       
          LD      A,20H       
          RST     18H         
          DB      .CRT1C      
          POP     HL          
          CALL    ASCFIV      
          RST     18H         
          DB      .CRTMS      
CVALN:    LD      HL,0        ;xxx
          CALL    P.ERL       
          RST     18H         
          DB      .CR2        
CVAS9:    POP     HL          
          INC     HL          
          JR      REFL6       

REFFLG:   DB      0           
;*---------------------------------------------------------
;* Middle of p.359 in German Listing of MZ-2Z046 Disk Basic
;*---------------------------------------------------------
EDITOR:   RST     18H         
          DB      .CLRIO      
          CALL    REFLNO      
          CALL    CVBCAS      
          LD      A,B         
          OR      C           
          JP      Z,INPAGN    
          LD      (EDLINE),BC 
          LD      A,(DE)      
          CP      20H         
          JR      NZ,EDIT1    
          INC     DE          
EDIT1:    PUSH    AF          
          LD      HL,IMDBUF   
          CALL    CVIMTX      
          PUSH    HL          
          LD      HL,(EDLINE) 
          LD      E,L         
          LD      D,H         
          CALL    DELSUB      
          POP     HL          ; END POINT
          POP     AF          
          OR      A           
          JR      Z,EDIT9     
          LD      DE,IMDBUF   
          OR      A           
          SBC     HL,DE       
          LD      DE,5        
          ADD     HL,DE       
          LD      B,H         
          LD      C,L         
          LD      HL,IMDBUF   
          CALL    INSTLIN     
EDIT9:    LD      A,(AUTOFG)  
          OR      A           
          JP      Z,INPAGN    
          LD      DE,(EDSTEP) 
          LD      HL,(EDLINE) 
          ADD     HL,DE       
          LD      (EDLINE),HL 
          JP      NC,INPAGN   
          JP      AUTOFF      

;*--------------------------
;* INSTLIN  HL .. IMD ADRS
;*          BC .. IMD LENGTH
;*--------------------------
INSTLIN:  LD      (INS.P+1),HL
          PUSH    BC          
          LD      BC,(EDLINE) 
          LD      HL,(TEXTST) 
          JR      INSL4       
INSL2:    CALL    LDDEMD      
          ADD     HL,DE       
INSL4:    CALL    LDDEMD      
          LD      A,D         
          OR      E           
          JR      Z,INSL6     
          INC     HL          
          INC     HL          
          CALL    LDDEMD      
          EX      DE,HL       
          SBC     HL,BC       
          DEC     DE          
          DEC     DE          
          EX      DE,HL       
          JR      C,INSL2     
INSL6:    POP     DE          ;DE:=open bytes
          PUSH    HL          ;Push inst-point
          PUSH    DE          
          LD      HL,40       ;memory check ofset
          ADD     HL,DE       
          LD      BC,(VARED)  
          LD      (TMPEND),BC 
          ADD     HL,BC       
          JP      C,ER06A     
          EX      DE,HL       
          CALL    MEMECK      
          POP     DE          ;DE=open bytes
          RST     18H         
          DB      .ADDP0      
          POP     HL          ;HL=inst point
          PUSH    DE          ;DE=open bytes
          PUSH    BC          
          EX      (SP),HL     ;HL=old VARED
          POP     BC          ;BC=inst point
          PUSH    HL          
          OR      A           
          SBC     HL,BC       
          LD      B,H         
          LD      C,L         ;BC=xfer bytes
          POP     HL          ;HL=old VARED
          LD      DE,(VARED)  ;DE=new VARED
          INC     BC          
          LDDR    
          INC     HL          ;HL=inst point
          POP     BC          ;BC=open bytes
          LD      (HL),C      
          INC     HL          
          LD      (HL),B      
          INC     HL          
          LD      DE,(EDLINE) 
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          INC     HL          
          EX      DE,HL       
INS.P:    LD      HL,IMDBUF   ;xxx
          DEC     BC          
          DEC     BC          
          DEC     BC          
          DEC     BC          
          LDIR    
          RET     

RUN:      JR      Z,RUN0      ;RUN
          CALL    LINEQ2      
          JP      Z,GOTO      ;RUN linenumber
          JP      FRUN        ;RUN "filename"

RUN0:     CALL    CLR         
RUNX:     CALL    RUNINT      
          LD      DE,(TEXTST) 
          LD      SP,(INTFAC) 
          LD      HL,0FFFFH   
          PUSH    HL          
          PUSH    HL          
          EX      DE,HL       
          JP      NXLINE      

RUNINT:   PUSH    HL          
          CALL    CLRFLG      
          LD      (AUTOFG),A  
          LD      HL,10       
          LD      (EDLINE),HL 
          LD      (EDSTEP),HL 
          POP     HL          
          RET     

CLRFLG:   LD      HL,0        
          LD      (ERRLNO),HL 
          XOR     A           
          LD      (DATFLG),A  
          LD      (CONTFG),A  
          LD      (ERRORF),A  
          LD      (ERRCOD),A  
          LD      (LSWAP),A   
          RET     

ENDCMD:   LD      A,(LSWAP)   
          OR      A           
          JP      NZ,BSWAP    
          RST     18H         ;END command
          DB      .CLRIO      
          XOR     A           
          LD      (CONTFG),A  
          POP     BC          
          JP      OK          

;*------------------------------------------------------
;* Top of p.364 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
AUTO:     CALL    CKCOM       
          LD      DE,10       ;AUTO start,step
          LD      BC,10       
          JR      Z,AUTO6     
          CP      ','         
          JR      NZ,AUTO2    
          INC     HL          
          CALL    IDEEXP      
          LD      B,D         
          LD      C,E         
          LD      DE,10       
          JR      AUTO6       

AUTO2:    CP      '.'         
          LD      DE,(EDLINE) 
          JR      Z,AUTO4     
          CP      0BH         
          JP      NZ,ER01     
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
AUTO4:    INC     HL          
          CALL    TEST1       
          DB      ','         
          JR      NZ,AUTO6    
          PUSH    DE          
          CALL    IDEEXP      
          LD      C,E         
          LD      B,D         
          POP     DE          
AUTO6:    CALL    CHKEND      
          LD      A,C         
          OR      B           
          JP      Z,ER03      
          LD      (EDLINE),DE 
          LD      (EDSTEP),BC 
          LD      A,1         
          LD      (AUTOFG),A  
          POP     AF          
          JP      INPAGN      

AUTOFG:   DB      0           ;(was DEFS 1)
AUTODS:   LD      A,(AUTOFG)  ;Disp auto line
          OR      A           
          RET     Z           
          XOR     A           
          JR      EDITL       

EDIT:     CALL    EDITL       ;EDIT linenumber
          JP      INPAGN      

EDITL:    LD      DE,(EDLINE) 
          CALL    NZ,GTSTED   
          PUSH    DE          
          EX      DE,HL       
          CALL    LNOSER      
          POP     DE          
          INC     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          JR      NC,EDL1     
          LD      HL,.NOP     
EDL1:     EX      DE,HL       
          PUSH    DE          
          LD      (EDLINE),HL 
          CALL    ASCFIV      
          RST     18H         
          DB      .CRTMS      
          LD      A,20H       
          RST     18H         
          DB      .CRT1C      
          POP     HL          
          LD      DE,KEYBUF   
          PUSH    DE          
          CALL    CVTXIM      
          POP     DE          
          LD      B,0         
EDL2:     LD      A,(DE)      
          OR      A           
          JR      Z,EDL6      
          INC     B           
          RST     18H         
          DB      .CRT1X      
          INC     DE          
          JR      EDL2        

EDL6:     LD      A,B         
          OR      A           
          RET     Z           
EDL7:     LD      A,14H       ; CURSOR BACK
          RST     18H         
          DB      .CRT1C      
          DJNZ    EDL7        ; erroneous DJNZ corrected here !
          RET     

MEMSET:   PUSH    DE          
          LD      DE,-16      
          ADD     HL,DE       
          POP     DE          
          LD      (MEMLMT),HL 
          DEC     H           
          LD      (INTFAC),HL 
          XOR     A           
          LD      (LSWAP),A   
          RET     

NEWTXT:   LD      HL,(TEXTST) 
          CALL    LDHL00      
          LD      (POOL),HL   
          CALL    RUNINT      
          JR      CLR         

NEW:      CALL    TEST1       ;NEW command
          DB      9DH         
          CALL    Z,NEWON     
          CALL    NEWTXT      
          JP      HOTENT      

CLR:      PUSH    HL          ;CLR command
          CALL    CLPTR2      
          POP     HL          
          RST     18H         
          DB      .CLRIO      
          RET     

CLPTR:    LD      HL,(TEXTST) 
          CALL    LDHL00      
          LD      (POOL),HL   
CLPTR2:   LD      HL,(POOL)   
          LD      (HL),0      
          INC     HL          
          LD      (VARST),HL  
          LD      (HL),0      
          INC     HL          
          LD      (STRST),HL  
          CALL    LDHL00      
          LD      (VARED),HL  
          LD      (TMPEND),HL 
          RET     

LDHL00:   LD      (HL),0      
          INC     HL          
          LD      (HL),0      
          INC     HL          
          RET     

;*------------------------------------------------------
;* Top of p.369 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
TRON:     CALL    ENDCHK      
          LD      A,1         
          JR      Z,TROFF+1   
          CALL    TESTX       
          DB      0FBH        ;/
          CALL    TESTX       
          DB      'P'         
          LD      A,2         
          JR      TRONF       

TROFF:    XOR     A           ;TROFF
TRONF:    LD      (TRDISP+1),A 
          RET     

TRDISP:   LD      A,0         ;0,1,2
          OR      A           
          RET     Z           
          DEC     A           
          LD      (FILOUT),A  
          JR      Z,TRDSP2    
          LD      A,(PNMODE)  
          CP      2           
          JR      Z,TRDSP9    ;MODE GR
TRDSP2:   PUSH    HL          
          LD      A,'['       
          RST     18H         
          DB      DH1C        
          LD      HL,(LNOBUF) 
          CALL    ASCFIV      
          RST     18H         
          DB      DHMSG       
          LD      A,']'       
          RST     18H         
          DB      DH1C        
          POP     HL          
TRDSP9:   XOR     A           
          LD      (FILOUT),A  
          RET     

DELETE:   CALL    END2C       ;DELETE command
          JP      Z,ER01      ;DELETE, is error
          CALL    LINEQ2      
          JR      Z,DELLIN    
          CP      '-'         
          JR      Z,DELLIN    
          CP      '.'         
          JP      NZ,FDEL     ;DELETE "filename"
DELLIN:   CALL    GTSTED      ;DELETE lines xxx-yyy
          EX      DE,HL       
          LD      E,C         
          LD      D,B         
          CALL    DELSUB      
          JP      OK          

;*--------------------------
;* Delete Lines (HL) to (DE)
;*--------------------------
DELSUB:   PUSH    AF          
          PUSH    BC          
          PUSH    HL          
          PUSH    DE          
          CALL    REFLNO      
          LD      C,L         
          LD      B,H         
          LD      HL,(TEXTST) 
FSTLOP:   CALL    LDDEMI      
          LD      A,E         
          OR      D           
          JR      NZ,FDDLST   
RTDLTE:   POP     DE          
          POP     HL          
          POP     BC          
          POP     AF          
          RET     

POPDLR:   POP     DE          
          JR      RTDLTE      

FDDLST:   EX      DE,HL       
          ADD     HL,DE       
          DEC     HL          
          DEC     HL          
          EX      DE,HL       
          PUSH    DE          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          EX      DE,HL       
          LD      (LNOTBF),HL 
          SBC     HL,BC       
          POP     HL          
          JR      C,FSTLOP    
          DEC     DE          
          DEC     DE          
          DEC     DE          
          POP     BC          ; DELSUB END LINE NO.
          PUSH    BC          
          PUSH    DE          ; DELSUB START ADRS
          PUSH    HL          ; NEXT LINE ADRS

          DB      21H         ;dynamic LD HL,xxxxH
LNOTBF:   DB      0,0         ;(was DEFS 2)

          SBC     HL,BC       
          POP     HL          
          JR      Z,DLSTRT    ; DEL-LINE END FOUND
          JR      NC,POPDLR   ; NOTHING OCCUR
SNDDLP:   CALL    LDDEMI      
          LD      A,D         
          OR      E           
          JR      Z,DLEFD     
          EX      DE,HL       
          ADD     HL,DE       
          EX      DE,HL       
          DEC     DE          
          DEC     DE          
          PUSH    DE          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          EX      DE,HL       
          SBC     HL,BC       
          POP     HL          
          JR      C,SNDDLP    
          JR      Z,DLSTRT    
          EX      DE,HL       
          DEC     HL          
DLEFD:    DEC     HL          
          DEC     HL          
DLSTRT:   POP     DE          
          PUSH    DE          ;Delete (DE)-(HL)
          PUSH    HL          
          OR      A           
          EX      DE,HL       
          SBC     HL,DE       
          EX      DE,HL       ;DE = - bytes
          LD      BC,(VARED)  ;old VARED
          RST     18H         
          DB      .ADDP0      
          POP     DE          ;DE = del end
          LD      H,B         
          LD      L,C         ;HL = old VARED
          OR      A           
          SBC     HL,DE       
          LD      B,H         
          LD      C,L         ;BC = move bytes
          EX      DE,HL       ;HL = del end
          POP     DE          ;DE = del start
          LDIR    
          JR      RTDLTE      

IDEEX0:   CALL    IDEEXP      
          LD      A,D         
          OR      E           
          RET     NZ          
          JP      ER03        

RENUM:    CALL    CKCOM       ;RENUMBER command
          LD      DE,10       ;RENUM xxx,yyy,zzz
          LD      (NEWNO),DE  
          LD      (ADDNO),DE  
          LD      E,0         
          LD      (STLNO),DE  
          JR      Z,RNSTRT    
          CP      ','         
          JR      Z,SKIRE1    
          CALL    IDEEX0      
          LD      (NEWNO),DE  
          CALL    ENDCHK      
          JR      Z,RNSTRT    
          CALL    HCH2CH      
          DEC     HL          
SKIRE1:   CALL    INCHLF      
          CP      ','         
          JR      Z,SKMRNU    
          CALL    IDEEX0      
          LD      (STLNO),DE  
          CALL    ENDCHK      
          JR      Z,RNSTRT    
          CALL    HCH2CH      
          DEC     HL          
SKMRNU:   INC     HL          
          CALL    IDEEX0      
          LD      (ADDNO),DE  
RNSTRT:   PUSH    HL          
          LD      HL,(STLNO)  
          EX      DE,HL       
          LD      HL,(NEWNO)  
          OR      A           
          SBC     HL,DE       
          JP      C,ER03      
          CALL    REFADR      
          LD      HL,(TEXTST) 
BEGRNS:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      A,D         
          OR      E           
          JR      Z,RNUMED    
          EX      DE,HL       
          ADD     HL,DE       
          DEC     HL          
          EX      DE,HL       
          INC     HL          
          LD      C,(HL)      
          INC     HL          
          LD      B,(HL)      
          PUSH    HL          
          DB      21H         
STLNO:    DB      0,0         ;(was DEFS 2)
          OR      A           
          SBC     HL,BC       
          POP     HL          
          JR      Z,BEGREN    
          JR      C,BEGREN    
          EX      DE,HL       
          JR      BEGRNS      

BEGREN:   DEC     HL          
          DEC     HL          
          DEC     HL          
          DB      01H         
NEWNO:    DB      0,0         ;(was DEFS 2)
          OR      A           
          PUSH    AF          
RENUML:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      A,D         
          OR      E           
          JR      Z,RNUMED    
          EX      DE,HL       
          ADD     HL,DE       
          DEC     HL          
          EX      DE,HL       
          POP     AF          
          JR      C,RENOVR    
          INC     HL          
          LD      (HL),C      
          INC     HL          
          LD      (HL),B      
          DB      21H         
ADDNO:    DB      0,0         ;(was DEFS 2)
          ADD     HL,BC       
          PUSH    AF          
          LD      C,L         
          LD      B,H         
          EX      DE,HL       
          JR      RENUML      

RNUMED:   POP     AF          
          CALL    REFLNX      
          POP     HL          
          RET     

RENOVR:   LD      HL,10       
          LD      (ADDNO),HL  
          LD      (NEWNO),HL  
          LD      L,0         
          LD      (STLNO),HL  
          CALL    RNSTRT      
          JP      ER03        

;*--------------------------
;* Error message & exception
;*--------------------------
MAXERR:   EQU     70          

ER01:     LD      A,01        
          DB      21H         
ER02:     LD      A,02        
          DB      21H         
ER03:     LD      A,03        
          DB      21H         
ER04:     LD      A,04        
          DB      21H         
ER05:     LD      A,05        
          DB      21H         
ER06:     LD      A,06        
          DB      21H         
ER07:     LD      A,07        
          DB      21H         
ER08:     LD      A,08        
          DB      21H         
ER13:     LD      A,13        
          DB      21H         
ER14:     LD      A,14        
          DB      21H         
ER15:     LD      A,15        
          DB      21H         
ER16:     LD      A,16        
          DB      21H         
ER17:     LD      A,17        
          DB      21H         
ER18:     LD      A,18        
          DB      21H         
ER19:     LD      A,19        
          DB      21H         
ER20:     LD      A,20        
          DB      21H         
ER21:     LD      A,21        
          DB      21H         
ER22:     LD      A,22        
          DB      21H         
ER24:     LD      A,24        
          DB      21H         
ER25:     LD      A,25        
          DB      21H         
ER58:     LD      A,58        
          DB      21H         
ER64:     LD      A,64        
          JR      ERRJ2       

ER06A:    LD      A,6         ;Nesting error
NESTER:   LD      SP,(INTFAC) 
          LD      HL,0FFFFH   
          PUSH    HL          
          LD      (STACK),SP  
ERRJ2:    JR      ERRJ1       

LPTMER:   LD      HL,(DSLPT)  ;LPT: Mode error
          DB      0DDH        
CRTMER:   LD      HL,(DSCRT)  ;CRT: Mode error
          LD      (ZEQT),HL   
          XOR     A           
          LD      (ZFLAG2),A  
          LD      A,68+80H    ;+80H is I/O err
          DB      21H         
ER59:     LD      A,59+80H    
          DB      21H         
ER59A:    LD      A,59        
          DB      21H         
ER60:     LD      A,60+80H    
          DB      21H         
ER61:     LD      A,61+80H    
ERRJ1:    JP      ERRORJ      

P.ERL:    LD      A,L         ;Print "IN line#"
          OR      H           
          RET     Z           
          LD      DE,MESIN    
          RST     18H         
          DB      .CRTMS      
          CALL    ASCFIV      
          RST     18H         
          DB      .CRTMS      
          RET     

MESIN:    DB      " IN "      
          DB      0           
MESBR:    DB      "BREAK"    
          DB      0           
OKMES:    DB      "READY"    
CONTFG:   DB      0           
          DB      0           

ERRORCMD: CALL    IBYTE       ;"ERROR" command
          DEC     A           
          CP      MAXERR      
          JR      C,ERRORX    
          LD      A,69-1      
ERRORX:   INC     A           

ERRORA:   LD      SP,(STACK)  ;jump from monitor
          PUSH    AF          
          RST     18H         
          DB      .ERCVR      
          CALL    LOAD10      ;WAS CALL LDEND (a duplicate label !) 
          POP     AF          
          OR      A           
          JR      Z,.BRKX     
          CP      80H         
          JR      Z,.BRKZ     
          LD      C,A         
          LD      HL,0        
          LD      (FNVRBF),HL 
          CALL    QDIRECT     
          LD      A,C         
          JR      Z,ERR2      
          LD      HL,(LNOBUF) 
          LD      (ERRLNO),HL 
          LD      (EDLINE),HL 
          LD      HL,(NXTLPT) 
          LD      (ERRLPT),HL 
          LD      HL,(TEXTPO) 
          LD      (ERRPNT),HL 
          AND     7FH         
          LD      (ERRCOD),A  
          LD      A,(ERRORF)  
          INC     A           
          CP      02H         
          JR      Z,ERROPR    
          XOR     A           
          LD      (CONTFG),A  
          LD      (LSWAP),A   
          LD      A,C         
ERR2:     RST     18H         
          DB      .ERRX       
ERR4:     LD      HL,(LNOBUF) 
          CALL    P.ERL       
          JP      OK          

ERROPR:   LD      (ERRORF),A  ;Error trap
          LD      HL,(ERRORV) 
          PUSH    HL          
          JP      NXLINE      

.BRKZ:    LD      A,'.'       ;can CONT
.BRKX:    LD      HL,(TEXTPO) ;can't CONT
          JR      BREAK2      

STOP:     LD      A,'.'       ;STOP command (can CONT)
          POP     DE          ;dummy POP
BREAK2:   PUSH    AF          
          PUSH    HL          
          RST     18H         
          DB      .CR2        
          RST     18H         
          DB      .BELL       
          LD      DE,MESBR    
          RST     18H         
          DB      .CRTMS      
          POP     HL          
          CALL    QDIRECT     
          JR      Z,BREAK4    
          LD      (BREAKT+1),HL ;Text pointer
          LD      HL,(NXTLPT) 
          LD      (BREAKN+1),HL ;Next line
          LD      HL,(LNOBUF) 
          LD      (BREAKL+1),HL ;Line No.
          LD      (EDLINE),HL 
          POP     AF          
          LD      (CONTFG),A  
          JP      ERR4        
BREAK4:   POP     AF          
          JP      OK          

CONT:     POP     DE          ;"CONT" command
          LD      HL,CONTFG   
          LD      A,(HL)      
          OR      A           
          JP      Z,ER17      
          LD      (HL),0      
BREAKL:   LD      HL,0        ;Line No.
          LD      (LNOBUF),HL 
BREAKN:   LD      HL,0        ;Next line
          LD      (NXTLPT),HL 
BREAKT:   LD      HL,0        ;Text pointer
          JP      MAIN        

RESUME:   LD      A,(ERRORF)  ;"RESUME" command
          CP      2           
          JP      C,ER21      
          DEC     A           
          LD      (ERRORF),A  
          CALL    ENDCHK      
          EX      DE,HL       
          LD      HL,(ERRLNO) 
          LD      (LNOBUF),HL 
          LD      HL,(ERRLPT) 
          LD      (NXTLPT),HL 
          LD      HL,(ERRPNT) 
          JR      NZ,RESUM2   
          POP     BC          
          JP      MAIN0       ;RESUME
RESUM2:   CP      8EH         
          JP      Z,DATA      ;RESUME NEXT
          EX      DE,HL       
          JP      GOTO        ;RESUME line#

ONERRG:   CALL    TESTX       ;GOTO
          DB      80H         
          CALL    GETLIN      
          JR      Z,OFFER     
          LD      (ERRORV),DE 
          LD      A,1         
ONER9:    LD      (ERRORF),A  
          RET     

OFFER:    LD      A,(ERRORF)  
          DEC     A           
          JR      Z,ONER9     
          XOR     A           
          LD      (ERRORF),A  
          LD      HL,(ERRLNO) 
          LD      (LNOBUF),HL 
          LD      A,(ERRCOD)  
          JP      ERRORA      

;*       END of original module BASIC.ASM
;*============================================================================
;*     START of original module STMNT.ASM
;*----------------------------------
;* MZ-800 BASIC  Statement Interpret
;* FI:STMNT  ver 1.0A 9.06.84
;* Programmed by T.Miho
;*----------------------------------

LET:      CALL    TEST1       
          DB      0FFH        
          JP      Z,PFUNCT    
          CALL    INTGTV      
          PUSH    BC          
          PUSH    BC          
          PUSH    AF          
          CALL    TESTX       
          DB      0F4H        ;=
          CALL    EXPR        
          POP     BC          
          LD      A,(PRCSON)  
          CP      B           
          JP      NZ,ER04     
          EX      (SP),HL     ; VAR ADRS<>TEXTPOINT
          EX      DE,HL       
          CP      05H         
          JR      Z,DAIBCK    
          PUSH    BC          
          CALL    STRDAI      
          POP     AF          
          POP     HL          
          POP     BC          
          RET     

DAIBCK:   LD      C,A         
          LD      B,0         
          LDIR    
          POP     HL          
          POP     BC          
          RET     

PFUNCT:   CALL    TESTX       
          DB      0C4H        
          JP      TIMDAI      ;TI$=...

STRLET:   PUSH    DE          
          EX      DE,HL       
          JR      STRDI2      

STRDAI:   PUSH    DE          
          CALL    CVTSDC      
STRDI2:   LD      HL,KEYBM1   
          LD      (HL),A      
          LD      B,A         
          LD      C,A         
          INC     HL          
          CALL    LDHLDE      
          POP     HL          
          LD      A,(HL)      
          CP      C           
          JR      Z,SMLNST    
          PUSH    HL          
          OR      A           
          CALL    NZ,DELSTR   
          POP     HL          
          LD      A,(KEYBM1)  
          OR      A           
          JR      Z,STRNL1    
          PUSH    HL          
          LD      BC,(VARST)  
          SBC     HL,BC       
          EX      DE,HL       
          LD      HL,(VARED)  
          DEC     HL          
          DEC     HL          
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          INC     HL          
          LD      BC,(STRST)  
          OR      A           
          POP     DE          
          PUSH    HL          
          SBC     HL,BC       
          EX      DE,HL       
          LD      (HL),A      
          LD      B,A         
          INC     HL          
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          POP     HL          
          LD      DE,KEYBM1   
          INC     DE          
          CALL    STRENT      
          CALL    LDHL00      
          LD      (TMPEND),HL 
          LD      (VARED),HL  
          RET     

STRNL1:   LD      (HL),0      
          RET     

SMLNST:   INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      HL,(STRST)  
          ADD     HL,DE       
          LD      DE,KEYBM1   
          LD      B,C         
          INC     DE          
          JP      STRENT      

DELSTR:   LD      C,(HL)      
          LD      B,0         
          INC     BC          
          INC     BC          
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      HL,(STRST)  
          ADD     HL,DE       
          DEC     HL          
          DEC     HL          
          LD      E,L         
          LD      D,H         
          ADD     HL,BC       
          PUSH    BC          
          PUSH    DE          
          EX      DE,HL       
          LD      HL,(VARED)  
          OR      A           
          SBC     HL,DE       
          LD      C,L         
          LD      B,H         
          EX      DE,HL       
          POP     DE          
          PUSH    DE          
          JR      Z,STRDE0    
          LDIR    
STRDE0:   POP     DE          
          POP     BC          
          LD      HL,(VARED)  
          OR      A           
          SBC     HL,BC       
          LD      (VARED),HL  
          EX      DE,HL       
STRDE1:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      A,D         
          OR      E           
          RET     Z           
          LD      HL,(VARST)  
          ADD     HL,DE       
          LD      A,(HL)      
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          OR      A           
          EX      DE,HL       
          SBC     HL,BC       
          EX      DE,HL       
          LD      (HL),D      
          DEC     HL          
          LD      (HL),E      
          PUSH    BC          
          LD      C,A         
          LD      B,0         
          LD      HL,(STRST)  
          ADD     HL,DE       
          ADD     HL,BC       
          POP     BC          
          JR      STRDE1      

FOR:      POP     BC          ;FOR - TO - STEP
          LD      (FORRTA),BC 
          CALL    LET         
          LD      IX,0        
          ADD     IX,SP       
          LD      (FRTXPT),HL 
          CALL    VAROFST     
          LD      (FORVAD+1),BC 
FOR3:     LD      E,(IX+0)    
          LD      D,(IX+1)    
          LD      HL,0FF12H   
          OR      A           
          SBC     HL,DE       
          JR      NZ,FOR1     
          LD      E,(IX+6)    
          LD      D,(IX+7)    
          EX      DE,HL       
          OR      A           
          SBC     HL,BC       
          JR      Z,FOR2      ;EQL FORVAR
          LD      DE,012H     
          ADD     IX,DE       
          JR      FOR3        

FOR2:     LD      DE,012H     
          ADD     IX,DE       
          LD      SP,IX       
FOR1:     LD      HL,(FRTXPT) 
          CALL    TESTX       ;TO
          DB      0E0H        
          CALL    EXPR        
          PUSH    AF          
          PUSH    HL          
          EX      DE,HL       
          LD      DE,TODTBF   
          CALL    LDIR5       
          POP     HL          
          POP     AF          
          CP      0E1H        ;STEP
          LD      DE,FLONE    
          JR      NZ,SSTEP1   
          INC     HL          
          CALL    EXPR        
SSTEP1:   LD      (FRTXPT),HL 
          LD      HL,0FFF6H   ;-10
          ADD     HL,SP       
          LD      SP,HL       
          EX      DE,HL       
          CALL    LDIR5       
          LD      HL,TODTBF   
          CALL    LDIR5       
FORVAD:   LD      HL,0        
          PUSH    HL          
          DB      21H         
FRTXPT:   DB      0,0         ;(was DEFS 2)
          PUSH    HL          
          LD      HL,(NXTLPT) 
          PUSH    HL          
          LD      HL,0FF12H   ;FOR MARK
          PUSH    HL          
          LD      HL,-512     
          ADD     HL,SP       
          LD      DE,(TMPEND) 
          SBC     HL,DE       
          LD      A,11        ;FOR..NEXT ERR
          JP      C,NESTER    
          LD      HL,(FRTXPT) 
          DB      0C3H        ;dynamic JP xxxxH
FORRTA:   DB      0,0         ;(was DEFS 2)

NEXT:     LD      A,5         ;NEXT
          LD      (PRCSON),A  
          POP     BC          
          LD      (NEXRTA),BC 
NEXT6:    PUSH    AF          
          POP     BC          
          LD      (FRTXPT),HL 
          LD      IX,0        
          ADD     IX,SP       
          LD      (FORSTK),IX 
          LD      E,(IX+0)    
          LD      D,(IX+1)    
          LD      HL,0FF12H   
          OR      A           
          SBC     HL,DE       
          JP      NZ,ER13     
          PUSH    BC          
          POP     AF          
          JR      NZ,NEXT1    
          LD      E,(IX+4)    ;FOR TEXTPO
          LD      D,(IX+5)    
          EX      DE,HL       
          LD      (NEXT4+1),HL 
          LD      E,(IX+6)    ;FORVAD
          LD      D,(IX+7)    
          LD      HL,(VARST)  
          ADD     HL,DE       
          LD      BC,8        ;STEP ADR
          ADD     IX,BC       
          PUSH    IX          
          POP     DE          
          CALL    ADDCMD         
          INC     DE          
          LD      A,(DE)      
          LD      IX,(FORSTK) 
          LD      DE,0DH      
          ADD     IX,DE       
          PUSH    IX          
          POP     DE          
          BIT     7,A         
          JR      NZ,NEXT7    
          EX      DE,HL       
NEXT7:    CALL    CMP         
          JR      C,NEXT3     ;END

          DB      31H         ;dynamic LD SP, xxxxH (set FOR stack)
FORSTK:   DB      0,0         ;(was DEFS 2)

          LD      HL,2        
          ADD     HL,SP       
          LD      A,(HL)      
          INC     HL          
          LD      H,(HL)      
          LD      L,A         
          LD      (NXTLPT),HL 
NEXT4:    LD      HL,0        ;TEXTPO
NEXT5:    DB      0C3H        ;dynamic JP xxxxH
NEXRTA:   DB      0,0         ;(was DEFS 2)

NEXT3:    LD      DE,012H     
          LD      HL,(FORSTK) 
          ADD     HL,DE       
          LD      SP,HL       
          LD      HL,(FRTXPT) 
          CALL    TEST1       
          DB      ','         
          JR      NZ,NEXT5    
          LD      (FRTXPT),HL 
NEXT1:    LD      IX,0        
          ADD     IX,SP       
          LD      (FORSTK),IX 
          LD      HL,(FRTXPT) 
          CALL    TEST1       
          DB      ','         
          JP      Z,NEXT6     
          CALL    INTGTV      
          LD      (FRTXPT),HL 
          CALL    VAROFST     
          LD      IX,(FORSTK) 
NEXT12:   LD      E,(IX+0)    
          LD      D,(IX+1)    
          LD      HL,0FF12H   
          OR      A           
          SBC     HL,DE       
          JP      NZ,ER13     
          LD      L,(IX+6)    
          LD      H,(IX+7)    
          OR      A           
          SBC     HL,BC       
          LD      HL,(FRTXPT) 
          JP      Z,NEXT6     
          LD      DE,012H     
          ADD     IX,DE       
          LD      (FORSTK),IX 
          LD      SP,(FORSTK) 
          JR      NEXT12      

VAROFST:  LD      H,B         
          LD      L,C         
          LD      BC,(VARST)  
          OR      A           
          SBC     HL,BC       
          LD      B,H         
          LD      C,L         
          RET     

TODTBF:   DB      0,0,0,0,0   ;(was DEFS 5)


FRLNBF:   DB      0,0         ;(was DEFS 2)
FRNLPT:   DB      0,0         ;(was DEFS 2)

FORSKS:   CALL    IFSKSB      
          OR      A           
          RET     NZ          
          INC     HL          
          PUSH    DE          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      A,D         
          OR      E           
          INC     HL          
          LD      (FRNLPT+1),DE 
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      (FRLNBF+1),DE 
          POP     DE          
          SCF     
          RET     Z           
          JR      FORSKS      

USR:      CALL    CH28H       ;USR command - USR(adrs,source$,dest$)
          CALL    IDEEXP      ;adrs
          LD      (USRADR+1),DE 
          CALL    TEST1       
          DB      ','         
          JR      NZ,USR2     
          CALL    EXPR        ;source$
          CALL    STROK       
          LD      (USRSRC+1),DE 
          CALL    TEST1       
          DB      ','         
          JR      NZ,USR2     
          CALL    INTGTV      ;dest$
          CALL    STROK       
          LD      (USRDST+1),BC 
          XOR     A           
USR2:     PUSH    HL          
          PUSH    AF          
USRSRC:   LD      HL,0        ;xxx
          CALL    CVTSDC      
          LD      IX,ERRORJ   
          XOR     A           
USRADR:   CALL    0           ;xxx
          POP     AF          
          JR      NZ,USR8     
          LD      A,B         ;dest$ exist
          EX      DE,HL       
USRDST:   LD      DE,0        ;xxx
          CALL    STRLET      
USR8:     POP     HL          
          JP      HCH29H      

PAUSE:    CALL    IDEEXP      ;PAUSE command
PAUSE2:   LD      A,D         
          OR      E           
          RET     Z           
          LD      B,0FBH      ;Interval 0.1 sec approx (JAPAN 00H)
PAUSE3:   DJNZ    PAUSE3      ;Loop!
          RST     18H         
          DB      .BREAK      
          RET     Z           
          DEC     DE          
          JR      PAUSE2      

;*------------------------------------------------------
;* Multiple entry point for REM, LABEL, DATA and GOSUB
;* Top of p.395 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
REM:      
LABEL:    
DATA:     
GSUB:     DEC     HL          ;GOSUB
DATA0:    CALL    IFSKSB      
          OR      A           
          SCF     
          RET     Z           
          CP      ':'         
          RET     Z           
          JR      DATA0       

OUT@:     CALL    IBYTE       ;OUT @port,data
          SUB     0E0H        
          CP      7           
          JP      C,ER03      ;E0H .. E6H
          CALL    HCH2CH      
          PUSH    DE          
          CALL    IBYTE       
          POP     BC          
          OUT     (C),A       
          RET     

INP@:     CALL    IBYTE       ;INP @port,data
          CALL    HCH2CH      
          PUSH    DE          
          CALL    INTGTV      
          CP      5           
          JP      NZ,ER04     
          EX      (SP),HL     
          PUSH    BC          
          EX      (SP),HL     
          POP     BC          
          IN      E,(C)       
          LD      D,0         
          CALL    FLTHEX      
          POP     HL          
          RET     

CURSOR:   CALL    CSRXY       ;CURSOR x,y
          EX      DE,HL       
          RST     18H         
          DB      .CURMV      
          EX      DE,HL       
          RET     

CSRXY:    LD      B,24        
          LD      C,39        
          LD      A,(CRTMD2)  ;80 char. mode change
          CP      3           
          JR      C,CSRXY3    
          LD      C,79        
CSRXY3:   CALL    CSRXY2      
          JP      C,ER03      
          RET     

CSRXY2:   PUSH    BC          
          CALL    IBYTE       
          PUSH    AF          
          CALL    HCH2CH      
          CALL    IBYTE       
          LD      D,E         
          POP     AF          
          LD      E,A         
          POP     BC          
          LD      A,C         
          CP      E           
          RET     C           
          LD      A,B         
          CP      D           
          RET     

GETOP:    CALL    INTGTV      ;GET Var
          LD      (PRCSON),A  
          CP      5           
          JR      Z,GETSUJ    
          PUSH    HL          ;GET STR
          PUSH    BC          
          LD      A,0FFH      
          RST     18H         
          DB      .INKEY      
          OR      A           
          JR      Z,NLGTKY    
          LD      HL,(TMPEND) 
          LD      (HL),A      
          LD      A,1         
NLGTKY:   POP     DE          
          CALL    STRLET      
          POP     HL          
          RET     

GETSUJ:   PUSH    HL          
          PUSH    BC          
          LD      A,0FFH      
          RST     18H         
          DB      .INKEY      
          SUB     30H         
          CP      0AH         
          JR      C,GETSU2    
          XOR     A           
GETSU2:   LD      E,A         
          LD      D,0         
          POP     HL          
          CALL    FLTHEX      
          POP     HL          
          RET     

POKE:     CALL    IDEEXP      ;POKE ad,d1,d2,d3,...
          CALL    CH2CH       
POKELP:   PUSH    DE          
          CALL    IBYTE       
          POP     DE          
          LD      (DE),A      
          INC     DE          
          CALL    TEST1       
          DB      ','         
          RET     NZ          
          JR      POKELP      

LIMIT:    PUSH    HL          ;LIMIT addr.
          CALL    TEST1       
          DB      'M'         
          JR      NZ,LIMIT1   
          CALL    TEST1       
          DB      'A'         
          JR      NZ,LIMIT1   
          CALL    TEST1       
          DB      'X'         
          JR      NZ,LIMIT1   
          EX      (SP),HL     
          LD      HL,(MEMMAX) 
          JR      LIMIT2      

LIMIT1:   POP     HL          
          CALL    IDEEXP      
          PUSH    HL          
          LD      HL,(MEMMAX) 
          OR      A           
          SBC     HL,DE       
          JP      C,ER06A     
          LD      HL,(TMPEND) 
          INC     H           
          INC     H           
          INC     H           
          INC     H           
          OR      A           
          SBC     HL,DE       
          JP      NC,ER03     
          EX      DE,HL       
LIMIT2:   CALL    MEMSET      
          POP     HL          
          POP     DE          
          LD      SP,(INTFAC) 
          LD      BC,0FFFFH   
          PUSH    BC          
          PUSH    DE          
          RET     

RETURN:   POP     IX          ;RETURN line no.
RETRN2:   POP     BC          
          PUSH    BC          
          LD      A,B         
          INC     A           
          JP      NZ,ER14     
          LD      A,C         
          CP      12H         
          JR      Z,RETRN6    
          CP      0FEH        
          JP      NZ,ER14     
          POP     BC          
          CALL    ENDCHK      
          EX      DE,HL       
          POP     HL          
          LD      (LNOBUF),HL 
          POP     HL          
          LD      (NXTLPT),HL 
          POP     HL          
          PUSH    IX          
          RET     Z           
          EX      DE,HL       
          JP      GOTO        
RETRN6:   EX      DE,HL       
          LD      HL,12H      
          ADD     HL,SP       
          LD      SP,HL       
          EX      DE,HL       
          JR      RETRN2      

GOSUB:    PUSH    HL          ;GOSUB line no.
          CALL    GSUB        
          EX      DE,HL       
          POP     HL          
          POP     BC          
          PUSH    DE          
          EXX     
          LD      HL,(NXTLPT) 
          PUSH    HL          
          LD      HL,(LNOBUF) 
          PUSH    HL          
          LD      HL,0FFFEH   
          PUSH    HL          
          LD      HL,-512     
          ADD     HL,SP       
          LD      DE,(TMPEND) 
          SBC     HL,DE       
          LD      A,10        
          JP      C,NESTER    
          EXX     
          PUSH    BC          
          JR      GOTO        

ON:       CALL    TEST1       ;ON command
          DB      0C1H        
          JP      Z,ONERRG    ;ON ERROR
          CALL    IDEEXP      
          LD      C,E         
          LD      B,D         
          CP      87H         
          JP      NC,ER01     
          CP      82H         
          JR      NZ,ON.4     
          CALL    INCHLF      
          LD      E,81H       
          CP      0E4H        
          JR      Z,ON.2      
          CP      0E0H        
          JP      NZ,ER01     
          DEC     E           
ON.2:     LD      A,E         
ON.4:     PUSH    HL          
          LD      HL,SJPTBL   
          SUB     80H         
          ADD     A,A         
          LD      E,A         
          LD      D,0         
          ADD     HL,DE       
          CALL    INDRCT      
          EX      (SP),HL     
          INC     HL          
          LD      A,B         
          OR      A           
          JR      NZ,ON.9     
          LD      A,C         
          OR      A           
          JR      Z,ON.9      
          LD      B,A         
ON.6:     DEC     B           
          RET     Z           
          CALL    HLFTCH      
          CALL    LINEQ       
          JP      NZ,ER01     
          CALL    DTSKL1      
          OR      A           
          RET     Z           
          INC     HL          
          CALL    TEST1       
          DB      ','         
          JR      Z,ON.6      
          POP     DE          
          JP      CHKEND      

ON.9:     POP     DE          
          JP      DATA        

GOTO:     CALL    GETLIN      ;GOTO line no.
          EX      DE,HL       
          JR      NZ,GONUM    
          LD      HL,(TEXTST) ;GOTO 0
GONUM:    LD      (NXTLPT),HL 
          XOR     A           
          LD      (CONTFG),A  
          JP      NXLINE      

IF:       CALL    EXPR        ;IF-THEN-ELSE
          EX      AF,AF'      
          LD      A,(DE)      
          OR      A           
          JR      Z,IFALSE    
          EX      AF,AF'      
          CP      0E2H        ;THEN
          JR      NZ,IF.4     
IF.2:     CALL    INCHLF      
          CALL    LINEQ       
          JR      Z,GOTO      
IF.4:     POP     AF          
          JP      MAIN        

LINEQ:    CP      '"'         
          RET     Z           
LINEQ2:   CP      0BH         
          RET     Z           
          CP      0CH         
          RET     

ELSECMD:  CALL    IFSKIP      
          JR      NC,ELSECMD     
          RET     

IFALSE:   DEC     HL          
          CALL    IFSKIP      
          JR      NC,IF.2     
          JP      ENDLIN      

IFSKIP:   CALL    IFSKSB      
          OR      A           
          SCF     
          RET     Z           
          CP      0C2H        ;ELSE
          RET     Z           
          CP      93H         ;IF
          JR      NZ,IFSKIP   
          CALL    IFSKIP      
          RET     C           
          JR      IFSKIP      

DTSKSB:   INC     HL          
          LD      A,(HL)      
          JR      DTSKL1      

IFSKSB:   INC     HL          
          LD      A,(HL)      
          CP      94H         ;DATA
          JR      Z,IFDASK    
DTSKL1:   OR      A           
          RET     Z           
          CP      '"'         
          JR      Z,IFDQSK    
          CP      0FEH        ;FUNC/OPTION
          JR      NC,IFFNRT   
          CP      97H         ;REM
          JR      Z,IFDASK    
          CP      27H         ;'
          JR      Z,IFDASK    
          CP      20H         
          RET     NC          
          CP      0BH         
          RET     C           
          CP      15H         
          JR      NC,ISKFLT   
          INC     HL          
IFFNRT:   INC     HL          
          RET     

IFDASK:   LD      A,(HL)      
          OR      A           
          RET     Z           
          CP      3AH         
          RET     Z           
          CP      '"'         
          JR      Z,DADQSK    
          INC     HL          
          JR      IFDASK      

DADQSK:   CALL    IFDQSK      
          OR      A           
          RET     Z           
          INC     HL          
          JR      IFDASK      

ISKFLT:   AND     0FH         
          ADD     A,L         
          LD      L,A         
          LD      A,20H       
          RET     NC          
          INC     H           
          RET     

IFDQSK:   INC     HL          
          LD      A,(HL)      
          OR      A           
          RET     Z           
          CP      '"'         
          RET     Z           
          JR      IFDQSK      

BEEP:     RST     18H         ;BEEP command
          DB      .BELL       
          RET     

BYE:      CALL    CHKEND      ;BYE command
          RST     18H         
          DB      .CLRIO      
          RST     18H         
          DB      .MONOP      
          RET     

CONSOL:   JR      Z,CONSOI    ;CONSOLE x,xl,y,yl
          LD      A,(YS)      
          LD      D,0         
          LD      E,A         
          CALL    TEST1       
          DB      ','         
          JR      Z,CONSOK    
          CALL    IBYTE       
          CALL    HCH2CH      
CONSOK:   LD      C,E         
          PUSH    BC          
          CALL    IBYTE       
          POP     BC          
          DEC     A           
          JP      M,ER03      
          ADD     A,C         
          CP      25          
          JP      NC,ER03     
          LD      B,A         
          PUSH    HL          
          LD      H,B         
          LD      L,C         
          RST     18H         
          DB      .DWIND      
          POP     HL          
          RET     
CONSOI:   PUSH    HL          ;CONSOLE init.
          LD      HL,1800H    
          RST     18H         
          DB      .DWIND      
          POP     HL          
          RET     

BOOT:     DI                  ;BOOT command
          OUT     (0E4H),A    
          JP      0           

SEARCH:   XOR     A           ;SEARCH#n "xxxx"
          DB      1           
LIST:     LD      A,1         ;LIST#n   Start-End
          LD      (SELTF),A   
          PUSH    AF          
          CALL    GETLU       
          RST     18H         
          DB      .LUCHK      
          JP      C,ER64      
          BIT     1,A         ;W?
          JP      Z,ER64      
          CALL    TEST1       
          DB      ','         
          POP     AF          
          OR      A           
          JR      NZ,LIST10   
          CALL    STREXP      ;SEARCH command only
          LD      A,B         
          LD      (SECLEN),A  
          LD      (SESTR),DE  
          CALL    CHKEND      
          JR      LIST10      

LIST0:    LD      A,2         
          LD      (SELTF),A   
LIST10:   CALL    GTSTED      
          LD      (LISTSN),DE 
          LD      (LISTEN),BC 
          LD      A,0FFH      
          LD      (DISPX),A   
          CALL    PUSHR       
          LD      HL,(TEXTST) 
LIST20:   CALL    LDDEMI      
          LD      A,D         
          OR      E           
          RET     Z           
          EX      DE,HL       
          ADD     HL,DE       
          DEC     HL          
          DEC     HL          
          EX      DE,HL       
          PUSH    DE          
          CALL    LDDEMI      
          PUSH    HL          
          DB      21H         
LISTSN:   DB      0,0         ;(was DEFS 2)
          OR      A           
          SBC     HL,DE       
          JR      C,LIST30    
          JR      Z,LIST30    
          POP     HL          
          POP     HL          
          JR      LIST20      

LIST30:   DB      21H         
LISTEN:   DB      0,0         ;(was DEFS 2)
          OR      A           
          SBC     HL,DE       
          JR      NC,LIST40   
          POP     HL          
          POP     HL          
          RET     

LIST40:   EX      DE,HL       
          CALL    ASCFIV      
          RST     18H         
          DB      .COUNT      
          LD      HL,KEYBUF   
          CALL    LDHLDE      
          LD      (HL),20H    
          INC     HL          
          EX      DE,HL       
          POP     HL          
          CALL    CVTXIM      
          LD      A,(SELTF)   
          OR      A           
          JR      NZ,LIST50   
          CALL    SSEST       
          JR      NC,LIST60   
LIST50:   LD      DE,KEYBUF   
          RST     18H         
          DB      .COUNT      
          RST     18H         
          DB      .PRSTR      
          CALL    PRTCR       
LIST60:   POP     HL          
          LD      A,(SELTF)   
          CP      2           
          JR      Z,LIST20    ;ASCII SAVE
          RST     18H         
          DB      .HALT       
          JR      LIST20      

;*----------------------
;* HL=TEXT START ADDRESS
;*----------------------
SSEST:    EX      DE,HL       
SSESTL:   PUSH    HL          
          CALL    SSESTS      
          POP     HL          
          RET     C           
          RET     Z           
          INC     HL          
          JR      SSESTL      

;*-------------------------------------
;*  ent HL:CMP pointer
;*  ext CY=1  same string
;*      CY=0  Acc=0 not same & text end
;*            Acc=FFH not same chr
;*-------------------------------------
SSESTS:   LD      A,(SECLEN)  ;String Length
          LD      B,A         
          LD      DE,(SESTR)  ;String address
SSEST0:   LD      A,(HL)      
          INC     HL          
          OR      A           
          RET     Z           
          CP      5           
          JR      Z,SSEST1    
          CP      6           
          JR      NZ,SSEST2   
SSEST1:   JR      SSEST0      

SSEST2:   PUSH    HL          
          LD      C,A         
SSEST4:   LD      A,(DE)      
          INC     DE          
          CP      5           
          JR      Z,SSEST3    
          CP      6           
          JR      NZ,SSEST5   
SSEST3:   DEC     B           
          SCF     
          POP     HL          
          RET     Z           
          PUSH    HL          
          JR      SSEST4      
SSEST5:   SUB     C           
          POP     HL          
          OR      A           
          RET     NZ          ;1 Chr not same
          DEC     B           
          SCF     
          RET     Z           
          JR      SSEST0      

SECLEN:   DB      0           ;String length (was DEFS 1)
SESTR:    DB      0,0         ;String Address (was DEFS 2)
SSESTW:   DB      0,0         ;Line No. (was DEFS 2)
SELTF:    DB      0           ;0:SEARCH , 1:LIST (was DEFS 1)

;*---------------------------------------------------------
;* Middle of p.412 in German Listing of MZ-2Z046 Disk Basic
;*---------------------------------------------------------
KLIST:    CALL    TESTX       ;KEY command
          DB      87H         ;LIST ?
          CALL    TESTP       
          PUSH    HL          
          LD      C,0         
KLSTLP:   RST     18H         ;LABEL missing in original source !
          DB      DHCR        
          LD      A,C         
          ADD     A,'1'       
          LD      D,A         
          LD      E,20H       
          CP      3AH         
          JR      NZ,KLIST1   
          LD      DE,3031H    ;'10'
KLIST1:   LD      (KEYME2),DE 
          LD      DE,KEYME1   ;'DEF KEY('
          RST     18H         
          DB      DHMSG       
          LD      A,C         
          CALL    KEYBCL      
          LD      B,(HL)      
          INC     HL          
          PUSH    BC          
          CALL    STKYMS      ;(DE)=MSTRING
          POP     BC          
          INC     C           
          LD      A,C         
          CP      10          
          JR      NZ,KLSTLP   
          RST     18H         
          DB      DHCR        
          POP     HL          
          RET     

STKYMS:   LD      A,B         
          OR      A           
          LD      C,0         
          JR      NZ,STKYM1   
          LD      A,'"'       
          RST     18H         
          DB      DH1CX       
          RST     18H         
          DB      DH1CX       
          RET     

STKYM1:   LD      A,(HL)      
          CP      20H         
          JR      C,CHRME1    
          CP      '"'         
          JR      Z,CHRME1    
          LD      A,C         
          CP      1           
          JR      Z,CHRM22    
          OR      A           
          LD      DE,KEYME3   
          JR      NZ,STKYM2   
          INC     DE          
          INC     DE          
STKYM2:   RST     18H         
          DB      DHMSG       
CHRM22:   LD      A,(HL)      
          RST     18H         
          DB      DH1CX       
          INC     HL          
          LD      C,1         
          DJNZ    STKYM1      
STKYE2:   LD      A,'"'       
STKYE3:   RST     18H         
          DB      DH1CX       
          RET     

CHRME1:   LD      A,C         
          CP      0FFH        
          JR      Z,CHRM12    
          OR      A           
          LD      DE,KEYME4   
          JR      NZ,CHRME2   
          INC     DE          
          INC     DE          
CHRME2:   RST     18H         
          DB      DHMSG       
CHRM16:   PUSH    BC          
          PUSH    HL          
          LD      L,(HL)      
          LD      H,0         
          CALL    ASCFIV      
          RST     18H         
          DB      DHMSG       
          POP     HL          
          POP     BC          
          INC     HL          
          LD      C,0FFH      
          DJNZ    STKYM1      
          LD      A,')'       
          JP      STKYE3      

CHRM12:   LD      A,','       
          RST     18H         
          DB      DH1CX       
          JR      CHRM16      

KEYME1:   DB      "DEF KEY("  
KEYME2:   DB      0,0         ;(was DEFS 2)
          DB      ")="        
          DB      0           
KEYME3:   DB      ")+\""       
          DB      0           
KEYME4:   DB      "\"+CHR$("   
          DB      0           

DEFOP:    CALL    TEST1       ;DEF command
          DB      0B2H        
          JR      Z,DEFKEY    ;DEF KEY(n)="..."
          CALL    TESTX       
          DB      0FFH        
          CALL    TESTX       
          DB      0C7H        
          JP      DEFFN       ;DEF FNx(x)=expr

DEFKEY:   CALL    TESTX       
          DB      '('         
          CALL    IBYTE       
          CALL    TESTX       
          DB      ')'         
          CALL    TESTX       
          DB      0F4H        ;=
          LD      A,E         
          DEC     A           
          CP      10          
          JP      NC,ER03     
          PUSH    HL          
          CALL    KEYBCL      
          EX      (SP),HL     
          CALL    STREXP      ;A,DE
          EX      (SP),HL     
          LD      A,B         
          CP      16          
          JR      C,DFKEY2    
          LD      A,15        
DFKEY2:   LD      (HL),A      
          OR      A           
          JR      Z,ESCKPT    
          LD      B,A         
          INC     HL          
DFKEY3:   LD      A,(DE)      
          LD      (HL),A      
          INC     DE          
          INC     HL          
          DJNZ    DFKEY3      
ESCKPT:   POP     HL          
          EI      
          RET     

KEYBCL:   ADD     A,A         
          ADD     A,A         
          ADD     A,A         
          ADD     A,A         
          LD      HL,FUNBUF   
          JP      ADDHLA      

;*       END of original module STMNT.ASM
;*============================================================================
;*     START of original module IOCS.ASM    
;*---------------------------
;* MZ-800 BASIC  IOCS command
;* FI:IOCS  ver 1.0B 9.20.84
;* Programmed by T.Miho
;*---------------------------

RUNRFL:   EQU     11A4H       ;KEYBUF   label
BKEYBF:   EQU     11A5H       ;KEYBUF+1 label

;* ZFLAG1 bit position (all 3 EQUATES defined in a previous module)

;*RAND:  EQU    5               ;FD
;*SEQU:  EQU    6               ;CMT, QD, RAM
;*STREM: EQU    7               ;CRT, KB, LPT, RS, USR

;* ZRWX bit position (all except LDALU and DATLU defined in a previous module)

;*ROPNAA: EQU    0              ;duplicated elsewhere
;*WOPNAA: EQU    1              ;duplicated elsewhere
;*XOPNAA: EQU    2              ;duplicated elsewhere
;*EOFAA:  EQU    7              ;duplicated elsewhere

;*CMTLU:  EQU    80H            ;duplicated elsewhere
LDALU:    EQU     81H         
;*CRTLU:  EQU    88H            ;duplicated elsewhere 
;*LPTLU:  EQU    89H            ;duplicated elsewhere
DATLU:    EQU     8AH         
;*-------------------------------------------------------------------------
CRTDUP:   LD      A,(ZLOG)    ;This routine duplicates CRTLUQ: but it is
          CP      CRTLU       ;retained and used to keep the code aligned
          RET                 ;with existing versions of QDBASIC MZ-5Z009
;*-------------------------------------------------------------------------
PRTEXP:   CALL    EXPR        
          LD      A,(PRCSON)  
          CP      3           
          PUSH    HL          
          EX      DE,HL       
          JR      Z,PRTEX2    
          CALL    CVNMFL      
          POP     HL          
          RST     18H         
          DB      .COUNT      
          RET     

PRTEX2:   CALL    CVTSDC      
          POP     HL          
          RET     

;*---------------
;*  PRINT command
;*---------------
PRINT:    XOR     A           
          LD      (DISPX),A   
          CALL    GETLU       
          RST     18H         
          DB      .LUCHK      
          JP      C,ER44      ;not open
          BIT     2,A         ;X?
          JP      NZ,PRX      
          BIT     1,A         ;W?
          JP      Z,ER59DU    ;can't exec
          CALL    LU2CH       
          CALL    CRTDUP      
          JR      NZ,PRT04    
          LD      A,(SELCOL)  
          LD      (COL),A     
          CALL    TEST1       
          DB      '['         
          JR      NZ,PRT04    
          CALL    COLCHK      
          LD      (COL),A     
          CALL    TESTX       
          DB      ']'         
PRT04:    CALL    ENDCHK      
          JP      Z,PRTCR     
PRT10:    LD      A,(HL)      
          CP      0E3H        ;USING
          JR      Z,PRUSNG    
          LD      BC,PRT20    
          PUSH    BC          ;Return adrs
          CP      ';'         
          RET     Z           
          CP      ','         
          RET     Z           
          CP      0E6H        ;TAB
          JR      Z,PRTAB     
          CALL    PRTEXP      
          JP      PRTMS2      

PRT20:    CALL    ENDCHK      
          JP      Z,PRTCR     
          CP      ','         
          JR      NZ,PRT30    
          CALL    CRTDUP      
          JR      C,PRT25     
          LD      IX,(ZPOS)   ; TAB10
          CALL    IOCALL      
          LD      B,A         
PRT22:    SUB     10          
          JR      NC,PRT22    
          NEG     
          LD      B,A         
          CALL    PRTAB2      
          JR      PRT30       

PRT25:    CALL    PRTCR       
PRT30:    LD      A,(HL)      
          CP      ','         
          JR      Z,PRT33     
          CP      ';'         
PRT33:    JR      NZ,PRT35    
          INC     HL          
PRT35:    CALL    ENDCHK      
          RET     Z           
          JR      PRT10       

PRTAB:    CALL    CRTDUP      
          JP      C,ER59DU    
          CALL    ICH28H      
          CALL    IBYTE       
          CALL    HCH29H      
          LD      IX,(ZPOS)   
          CALL    IOCALL      
          SUB     E           
          RET     NC          
          NEG     
          LD      B,A         
          CALL    CRTDUP      
          LD      A,13H       ;Cursor right
          JR      Z,PRTAB3    
PRTAB2:   LD      A,20H       
PRTAB3:   LD      DE,BKEYBF   
          PUSH    BC          
          PUSH    DE          
          CALL    QSETDE      
          POP     DE          
          POP     BC          
          JR      PRTMS2      

PRUSNG:   INC     HL          ;PRINT USING
          CALL    STREXP      
          LD      A,B         
          OR      A           
          JP      Z,ER03      
          PUSH    HL          
          LD      HL,BKEYBF   
          PUSH    HL          
          PUSH    BC          
          CALL    LDHLDE      
          POP     BC          
          LD      A,0F0H      
          LD      E,B         
          LD      D,0         
          INC     DE          
          RST     18H         
          DB      .OPSEG      
          LD      (USINGS),HL 
          LD      (USINGP),HL 
          POP     DE          
          CALL    LDHLDE      
          LD      (HL),0      
          POP     HL          
PRUSG2:   CALL    ENDCHK      
          JR      Z,PRUSG8    
          INC     HL          
          CP      ','         
          JR      Z,PRUSG4    
          CP      ';'         
          JP      NZ,ER01     
PRUSG4:   CALL    ENDCHK      
          JR      Z,PRUSG9    
          CALL    EXPRNX      
          PUSH    HL          
          LD      BC,(TMPEND) 
          PUSH    BC          
          CALL    USNGSB      
          POP     DE          
          CALL    PRTMSG      
          POP     HL          
          JR      PRUSG2      
PRUSG8:   CALL    PRTCR       
PRUSG9:   LD      A,0F0H      
          RST     18H         
          DB      .DLSEG      
          RET     

.CR:      DW      0DH         ;FMP

PRTCR:    LD      DE,.CR      
PRTMSG:   RST     18H         ;print message
          DB      .COUNT      
PRTMS2:   CALL    CRTDUP      
          JR      Z,PRTMC     
          RST     18H         
          DB      .PRSTR      
          RET     

PRTMC:    PUSH    AF          
          LD      A,(COL)     
          RST     18H         
          DB      .DCOL       
          POP     AF          
          RST     18H         
          DB      .PRSTR      
          LD      A,(SELCOL)  
          RST     18H         
          DB      .DCOL       
          RET     

;*--------------
;*  READ command
;*--------------
READ:     LD      A,DATLU     
          LD      (ZLOG),A    
          JR      INP10       

;*---------------
;*  INPUT command
;*---------------
INPUT:    CALL    GETLU       ;INPUT command
          RST     18H         
          DB      .LUCHK      
          JP      C,ER44      ;not open
          BIT     2,A         ;X?
          JP      NZ,INX      
          BIT     0,A         ;R?
          JP      Z,ER59DU    ;can't exec
          CALL    LU2CH       
          CALL    CRTDUP      
          JR      NZ,INP10    
          CALL    HLFTCH      
          CP      '"'         
          LD      DE,MEMQIN   
          LD      B,2         
          JR      NZ,INP05    
          CALL    STREXP      
          CALL    TESTX       
          DB      ';'         
INP05:    LD      A,B         
          OR      A           
          JR      Z,INP10     
INP07:    LD      A,(DE)      
          INC     DE          
          RST     18H         
          DB      .CRT1C      
          DJNZ    INP07       
INP10:    LD      (INPSP+1),SP 
          LD      DE,(VARED)  
          LD      (TMPEND),DE 
INP15:    LD      DE,(TMPEND) 
          CALL    MEMECK      
          CALL    INTGTV      
          PUSH    AF          
          PUSH    BC          
          CALL    ENDCHK      
          JR      Z,INP20     
          CALL    CH2CH       
          JR      INP15       

ER44:     LD      A,44        ;not opened
          DB      21H         
;*-----------------------------------------------------
;* THE ERROR TRAP BELOW DUPLICATES ER59: but is retained
;* & used to keep the code aligned with existing versions
;*-----------------------------------------------------
ER59DU:   LD      A,59+80H    ;can't exec
          JP      ERRORJ      

MEMQIN:   DB      "? "        

INP20:    XOR     A           
          PUSH    AF          ;END=00
          PUSH    HL          
          RST     18H         
          DB      .INSTT      
          LD      HL,(INPSP+1) 
          DEC     HL          
INP24:    LD      A,(HL)      
          OR      A           
          JR      Z,INP30     
          DEC     HL          
          DEC     HL          
          LD      B,(HL)      
          DEC     HL          
          LD      C,(HL)      
          DEC     HL          
          PUSH    HL          
          PUSH    AF          ;Type
          PUSH    BC          ;Adrs
          LD      DE,(TMPEND) 
          CALL    INPMX       
          LD      H,0         
          LD      L,B         
          ADD     HL,DE       
          LD      (HL),0      
          POP     DE          ;Adrs
          POP     AF          ;Type
          CALL    INSUB       
          POP     HL          
          JR      INP24       

INP30:    POP     HL          
INPSP:    LD      SP,0        ;dynamic address xxxxH
          RET     

INPMX:    LD      A,(ZLOG)    
          CP      DATLU       
          JR      Z,DATINP    
          RST     18H         
          DB      .INMSG      
          RET     

INSUB:    CP      3           ;String ?
          JR      NZ,INSUB4   ; No
          LD      HL,(TMPEND) ; Yes
          LD      A,B         
          JP      STRLET      

INSUB4:   PUSH    DE          
          LD      HL,(INTFAC) 
          LD      DE,(TMPEND) 
          EX      DE,HL       
          CALL    HLFTCH      
          CP      'E'         
          JP      Z,ER03      
          EX      DE,HL       
          CALL    CVFLAS      
          EX      DE,HL       
          CALL    TEST1       
          DB      0           
          JP      NZ,ER03     
          EX      DE,HL       
          POP     DE          
          JP      LDIR5       

;*-----------------
;*  RESTORE command
;*-----------------
RESTOR:   XOR     A           
          LD      (DATFLG),A  
          CALL    ENDCHK      
          CALL    NZ,GETLIN   
          EX      DE,HL       
          CALL    NZ,DTSRCX   
          EX      DE,HL       
          JP      DATA        ;ON RESTORE

DATINP:   PUSH    HL          
          PUSH    DE          
          CALL    DATINX      
          POP     DE          
          POP     HL          
          RET     

DATIN0:   LD      HL,(TEXTST) 
          CALL    DTSRCX      
DATINX:   LD      A,(DATFLG)  ;read flag
          CP      1           ;0 is restore top
          JP      Z,ER24      ;1 is out of data
          JR      C,DATIN0    ;2 is ok
          LD      HL,(DATPTR) ;read pointer
          LD      C,':'       
          RST     18H         
          DB      .INDAT      
          LD      (DATPTR),HL ;read pointer
          CALL    ENDCHK      
          SCF     
          CCF     
          RET     NZ          
          DEC     HL          
DTSRCH:   CALL    DTSKSB      ;DATA search
          OR      A           
          JR      NZ,DTSRC4   
          INC     HL          
DTSRCX:   LD      A,(HL)      
          INC     HL          
          OR      (HL)        
          LD      A,1         
          JR      Z,DTSRC9    
          INC     HL          
          INC     HL          
          JR      DTSRCH      
DTSRC4:   CP      94H         ;DATA
          JR      NZ,DTSRCH   
          INC     HL          
          LD      (DATPTR),HL ;read pointer
          LD      A,2         
DTSRC9:   LD      (DATFLG),A  ;read flag
          RET     

;*--------------------------------
;*  GETLU ... interpret #n, /P, /T
;*    ent HL: pointer
;*    ext HL: pointer
;*        A:  LU#
;*--------------------------------
GETLU:    CALL    TEST1       
          DB      '#'         
          JR      NZ,GETLU2   
          CALL    HLFTCH      
          CP      20H         
          JP      NC,ER01     
          PUSH    DE          
          PUSH    BC          
          LD      DE,ZFAC     
          PUSH    DE          
          CALL    FACNUM      
          EX      (SP),HL     
          CALL    HLFLT       
          LD      A,H         
          OR      A           
          JP      NZ,ER64     
          OR      L           
          JP      Z,ER64      
          JP      M,ER64      
          POP     HL          
          POP     BC          
          POP     DE          
          RET     

GETLU2:   CALL    TEST1       ;/
          DB      0FBH        
          LD      A,CRTLU     
          RET     NZ          
          CALL    TEST1       
          DB      'P'         
          LD      A,LPTLU     
          RET     Z           
          CALL    TESTX       
          DB      'T'         
          LD      A,CMTLU     
          RET     

LU2CH:    LD      A,(ZLOG)    
          OR      A           
          RET     M           
          JP      HCH2CH      

;*----------------
;*  DEFAULT "dev:"
;*----------------
DEFAULT:  CALL    DEVNAM       ;set default device
          RST     18H         
          DB      .SETDF      
          RET     

;*--------------------
;*  INIT "dev:command"
;*--------------------
INIT:     CALL    ENDCHK      
          LD      B,0         
          CALL    NZ,STREXP   
INIT2:    PUSH    HL          
          RST     18H         
          DB      .DEVNM      
          RST     18H         
          DB      .FINIT      
          POP     HL          
          RET     

;*------------------------------------------------------
;* Top of p.430 in German Listing of MZ-2Z046 Disk Basic
;* Entry point for file commands ROPEN, WOPEN and XOPEN
;*------------------------------------------------------
ROPEN:    LD      A,1         
          DB      1           
WOPEN:    LD      A,2         
          DB      1           
XOPEN:    LD      A,4         
          PUSH    AF          
          LD      (ZRWX),A    
          CALL    GETLU       
          CP      CRTLU       
          JR      NZ,OPEN.A   
          LD      A,CMTLU     
OPEN.A:   LD      (ZLOG),A    
          CALL    LU2CH       
          CALL    ELMT        
          POP     AF          
          CP      4           ;X
          JR      Z,OPEN.C    
OPEN.B:   LD      A,3         ;BSD
OPEN.C:   LD      (ELMD),A    
          PUSH    AF          
          RST     18H         
          DB      .RWOPN      
          LD      A,(ELMD)    
          POP     BC          
          CP      B           
          JP      NZ,ER61     
          RET     

;*--------------------
;*  CLOSE/KILL command
;*--------------------
CLOSE:    DB      0F6H        
KILL:     XOR     A           
          LD      B,A         
          CALL    ENDCHK      
          JR      Z,CLALL     ;all files
CLKL2:    CALL    GETLU       
          CP      CRTLU       
          RET     NC          
          RST     18H         
          DB      .CLKL       
          CALL    TEST1       
          DB      ','         
          JR      CLKL2       

CLALL:    XOR     A           
          RST     18H         
          DB      .CLKL       
          RET     

ELMT:     CALL    END2C       
          LD      B,0         
          CALL    NZ,STREXP   
          PUSH    HL          
          RST     18H         
          DB      .DEVFN      
          POP     HL          
          RET     

DEVNAM:   PUSH    HL          
          CALL    HLFTCH      
          LD      DE,ELMWRK   
          LD      B,1         
          CALL    ELMCK       
          CALL    NC,ELMCK    
          JR      C,DEVNM2    
          CALL    ELMCK       
          CALL    TSTNUM      
          CALL    ELMCK2      
          CALL    ENDCHK      
          JR      NZ,DEVNM2   
          LD      A,':'       
          LD      (DE),A      
          POP     AF          ;dummy
          LD      DE,ELMWRK   
          JR      DEVNM4      

DEVNM2:   POP     HL          
          CALL    ENDCHK      
          LD      B,0         
          CALL    NZ,STREXP   
DEVNM4:   PUSH    HL          
          RST     18H         
          DB      .DEVNM      
          INC     (HL)        
          DEC     (HL)        
          JP      NZ,ER58     
          POP     HL          
          RET     

ELMCK:    CP      41H         ;'A'
          RET     C           
          CP      5BH         ;'Z'+ 1
          CCF     
ELMCK2:   RET     C           
          LD      (DE),A      
          INC     HL          
          INC     DE          
          LD      A,(HL)      
          INC     B           
          RET     

ELMWRK:   DB      0,0,0,0     ;(was DEFS 4)

;*--------------------
;* LOAD "dev:filename"
;*--------------------
LOAD:     CALL    TEST1       ;ALL
          DB      0E5H        
          JR      NZ,LOAD2    
          XOR     A           
SVC.LS:   RST     18H         
          DB      .LSALL      
          RET     

LOAD2:    CALL    ELMT        
          CALL    TEST1       
          DB      ','         
          JP      Z,LOADA     
          PUSH    HL          
          CALL    LDRDY       
          DEC     A           
          JR      Z,LDOBJ     
          DEC     A           
          JP      NZ,ER61     ;il file mode
          CALL    CKCOM       
          CALL    CLRVAR      
          CALL    LDFIL       
          JR      LOAD9       

LDOBJ:    LD      HL,(ELMD22) ;load addr
          PUSH    HL          
          LD      DE,(MEMLMT) 
          CALL    COMPR       
          LD      DE,(ELMD20) ;size
          LD      BC,(MEMMAX) 
          CALL    NC,MEMOBJ   
          JP      C,ER18      
          POP     HL          
          RST     18H         
          DB      .LOADF      
LOAD9:    CALL    LOAD10      
          POP     HL          
          RET     

MEMOBJ:   ADD     HL,DE       
          RET     C           
          EX      DE,HL       
          LD      H,B         
          LD      L,C         
COMPR:    PUSH    HL          
          OR      A           
          SBC     HL,DE       
          POP     HL          
          RET     

;*---------------------
;* CHAIN "dev:filename"
;*---------------------
CHAIN:    CALL    ELMT        
          CALL    LDRDY       
          CP      2           
          JP      NZ,ER61     ;illegal file mode
          LD      A,(LSWAP)   
          OR      A           
          JP      Z,RUN2      
          JP      SWAP2       

;*---------------------
;* MERGE "dev:filename"
;*---------------------
MERGE:    CALL    CKCOM       
          CALL    ELMT        
          CALL    TEST1       
          DB      ','         
          JR      Z,MERGEA    
          RST     18H         
          DB      .LOPEN      
          CP      2           
          JP      NZ,ER61     
          PUSH    HL          
          LD      HL,(VARED)  
          LD      (TMPEND),HL 
          LD      BC,1000     
          ADD     HL,BC       
          JP      C,ER06A     
          PUSH    HL          
          LD      BC,(ELMD20) ;size
          INC     B           
          ADD     HL,BC       
          JP      C,ER06A     
          SBC     HL,SP       
          JP      NC,ER06A    
          POP     HL          
          PUSH    HL          
          RST     18H         
          DB      .LOADF      
          POP     HL          
          CALL    MERGE0      
          POP     HL          
          RET     

MERGE0:   CALL    LDDEMI      
          LD      A,D         
          OR      E           
          RET     Z           
          PUSH    DE          
          CALL    LDDEMI      
          PUSH    HL          
          LD      H,D         
          LD      L,E         
          LD      (EDLINE),HL 
          CALL    DELSUB      
          POP     HL          
          POP     BC          
          PUSH    BC          
          PUSH    HL          
          CALL    INSTLIN     
          POP     HL          
          POP     BC          
          ADD     HL,BC       
          DEC     HL          
          DEC     HL          
          DEC     HL          
          DEC     HL          
          JR      MERGE0      

;*-----------------------
;*  LOAD/MERGE/RUN  ascii
;*-----------------------
LOADA:    CALL    CKCOM       
          LD      A,1         
          DB      1           
MERGEA:   LD      A,0         
          DB      1           
RUNA:     LD      A,2         
          PUSH    AF          
          CALL    TESTX       
          DB      'A'         
          CALL    CHKEND      
          LD      A,1         
          LD      (ZRWX),A    
          LD      A,LDALU     
          LD      (ZLOG),A    
          CALL    OPEN.B      
          POP     AF          
          PUSH    AF          
          PUSH    HL          ;RJOB
          LD      HL,0        
          LD      DE,0FFFFH   
          OR      A           
          CALL    NZ,DELSUB   ;load/run only
          LD      A,LDALU     
          RST     18H         
          DB      .LUCHK      
          LD      HL,(VARED)  
          LD      (TMPEND),HL 
          LD      BC,1000     
          ADD     HL,BC       
          JP      C,ER06      
          PUSH    HL          ;load start adrs
          LD      (LDAPTR),HL 
LDA2:     LD      HL,-512     
          ADD     HL,SP       
          LD      DE,(LDAPTR) 
          SBC     HL,DE       
          JP      C,ER06      
          LD      DE,(TMPEND) 
          RST     18H         
          DB      .INMSG      
          LD      A,B         
          OR      A           
          JR      Z,LDA4      
          CALL    CVBCAS      
          LD      A,B         
          OR      C           
          JP      Z,ER03      
          LD      HL,(LDAPTR) 
          PUSH    HL          ;load pointer
          INC     HL          
          INC     HL          
          LD      (HL),C      
          INC     HL          
          LD      (HL),B      
          INC     HL          
          PUSH    HL          
          LD      H,D         
          LD      L,E         
          CALL    TEST1       
          DB      0           
          JP      Z,ER03      
          POP     HL          
          LD      A,(DE)      
          CP      20H         
          JR      NZ,LDA3     
          INC     DE          
LDA3:     CALL    CVIMTX      
          LD      (HL),0      
          INC     HL          
          LD      (LDAPTR),HL 
          POP     DE          ;old load pointer
          OR      A           
          SBC     HL,DE       
          EX      DE,HL       ;DE := length
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          JR      LDA2        

LDA4:     LD      HL,(LDAPTR) 
          CALL    LDHL00      
          CALL    CLR         
          POP     HL          ;load start adrs
          CALL    MERGE0      
          POP     HL          ;RJOB
          POP     AF          
          CP      2           ;RUN ?
          RET     NZ          ;no (load/merge)
          JP      RUNX        ;RUN from text-top

LDAPTR:   DB      0,0         ;(was DEFS 2)

;*-------------------
;* RUN "dev:filename"
;*-------------------
FRUN:     CALL    ELMT        
          PUSH    HL          
          CALL    TEST1       
          DB      ','         
          JR      NZ,RUN1     
          CALL    HLFTCH      
          CP      'A'         
          JP      Z,RUNA      
RUN1:     CALL    LDRDY       
          POP     HL          
          DEC     A           
          JR      Z,RUNOBJ    
          DEC     A           
          JP      NZ,ER61     ;il file mode
          CALL    CLRVAR      
RUN2:     CALL    LDFIL       ;jump from CHAIN
          CALL    LOAD10      
          JP      RUNX        

;*----------------------------------------------
;* Middle of p.440 in German Listing of MZ-2Z046
;* Floppy-Disk Basic - Run Machine-code Program
;*----------------------------------------------
RUNOBJ:   LD      D,0         ; normal
          LD      BC,0FF00H   
          CALL    TEST1       
          DB      ','         
          JR      NZ,RUNOB2   
          CALL    TESTX       
          DB      'R'         
          LD      D,1         ;,R
          LD      BC,0CFF0H   
RUNOB2:   LD      A,D         
          LD      (RUNRFL),A  ;,R flag
          LD      HL,(ELMD20) ;size
          LD      DE,(ELMD22) ;load addr
          PUSH    HL          
          CALL    MEMOBJ      
          POP     DE          ;size
          LD      HL,SBASIC   ;load file area
          LD      BC,0FF00H   
          CALL    NC,MEMOBJ   
          JP      C,ER06A     
          LD      SP,0        
          CALL    CLPTR       
          XOR     A           
          LD      (LOADFG),A  
          LD      A,36H       ;count0 mode3
          OUT     (0D7H),A    ;8253 mode set
          LD      A,1         
          OUT     (0D3H),A    ;8253 music enable
          LD      HL,(ELMD22) ;load addr
          LD      DE,(TMPEND) 
          CALL    COMPR       
          JR      NC,RUNOB3   
;*--------------
;* destroy BASIC
;*--------------
          PUSH    HL          
          LD      HL,SBASIC   ;load file area
          LD      (TEXTST),HL 
          CALL    CLPTR       
          LD      HL,RUNOBE-PRXFER+BKEYBF 
          LD      (ERRORP),HL 
          POP     HL          
RUNOB3:   LD      DE,(TMPEND) 
          CALL    COMPR       
          JR      NC,RUNOB6   
          EX      DE,HL       
RUNOB6:   PUSH    AF          
          PUSH    HL          
          LD      HL,PRXFER   
          LD      DE,BKEYBF   
          PUSH    DE          
          LD      BC,RUNTBE-PRXFER 
          LDIR    
          RET                 ;JP BKEYBF

;*------------
;*  ORG BKEYBF
;*------------
PRXFER:   POP     HL          
          RST     18H         
          DB      .LOADF      
          LD      A,0C3H      ;int tbl make
          LD      HL,038DH    
          LD      (1038H),A   
          LD      (1039H),HL  
          LD      A,01H       ;320*200 4 color
          RST     18H         
          DB      .DSMOD      
          RST     18H         
          DB      .DI         
          EX      AF,AF'      
          LD      A,(RUNRFL)  ;run"  " ,r
          OR      A           
          CALL    NZ,INITIO-PRXFER+BKEYBF 
          EX      AF,AF'      
          LD      HL,(ELMD24) ;exec addr
          LD      A,H         
          OR      L           
          EXX     
          LD      HL,(TMPEND) ;data store addr
          LD      DE,(ELMD22) ;load addr
          LD      BC,(ELMD20) ;size
          OR      D           
          OR      E           
          JR      Z,PROX0     
          LD      A,0E9H      ;jp (hl)
          LD      (PRO70P-PRXFER+BKEYBF),A 
PROX0:    EXX     
          POP     AF          ;ldir flg
          PUSH    HL          ;store exec addr
          LD      HL,PROFF-PRXFER+BKEYBF 
          LD      DE,0FF00H   
          LD      BC,PRO80E-PROFF 
          LDIR    
          EXX     
          JP      0FF00H      
;*-------------------------------------------------------------------
;*  ORG FF00H (the code below is copied to $FF00H and run from there)
;*-------------------------------------------------------------------
PROFF:    JR      NC,RUNOB4   
          LDIR    
RUNOB4:   EX      AF,AF'      
          RET     Z           ;,R
          IN      A,(LSDMD)   ;check dipsw
          AND     2           
          LD      A,0         ;mode 800
          OUT     (LSDMD),A   ;800 mode
          LD      HL,PRO800-PROFF+0FF00H 
          LD      BC,PRO80E-PRO800 
          JR      NZ,RUNOB5   
          LD      A,8         ;mode 700
          OUT     (LSDMD),A   ;700 or 800 mode
          IN      A,(LSE0)    ;CG xfer
          LD      HL,1000H    
          LD      DE,0C000H   
          LD      BC,1000H    
          LDIR    
          IN      A,(LSE1)    
          LD      HL,PRO700-PROFF+0FF00H 
          LD      BC,PRO70E-PRO700 
RUNOB5:   LD      DE,0CFF0H   
          LDIR    
          POP     HL          
          LD      SP,IBUFE    
          LD      DE,0D800H   ;vram2 for 700 mode
          JP      0CFF0H      
;*
RUNOBE:   RST     18H         
          DB      .ERRX       
          RST     18H         
          DB      .ERCVR      
          RST     18H         
          DB      .DI         
          HALT    

;*-------------
;*    ORG CFF0H
;*-------------
PRO700:   OUT     (LSE4),A    
PRO701:   LD      A,71H       ;blue and white
          LD      (DE),A      ;vram2 clr
          INC     DE          
          LD      A,D         
          CP      0E0H        
          JR      NZ,PRO701   
PRO70P:   OUT     (LSE0),A    ;jp (hl)
          JP      (HL)        

;*--------------------------------------------------------------------
;*    ORG CFF0H (the code below is copied to CFF0H and run from there)
;*--------------------------------------------------------------------
PRO70E:   
PRO800:   OUT     (LSE0),A    ;700mon rom bank off
          OUT     (LSE3),A    ;800mon rom bank on
          JP      (HL)        

PRO80E:   
INITIO:   PUSH    AF          
          DI                  ;run "file name",r
          IM      1           
          LD      HL,RUNTBL-PRXFER+BKEYBF 
          LD      B,17        
          RST     18H         ;io dev init
          DB      .IOOUT      
          POP     AF          
          RET     

RUNTBL:   
;*   pio channel a
          DW      0FC00H      ; int vecter
          DW      0FCCFH      ; mode 3 (bit mode)
          DW      0FC3FH      ; i/o reg. set
          DW      0FC07H      ; int seqence (disenable)
;*   pio channel b
          DW      0FD00H      ; int vecter
          DW      0FDCFH      ; mode 3 (bit mode)
          DW      0FD00H      ; i/o reg. set
          DW      0FD07H      ; int seqence (disenable)
;*
          DW      0D774H      ;8253 C1 mode 2
          DW      0D7B0H      ;     C2 mode 0
          DW      0D6C0H      ;counter2  12h
          DW      0D6A8H      ;
          DW      0D5FBH      ;counter1   1s
          DW      0D53CH      ;
          DW      0D305H      ;8253 int ok
          DW      0CD01H      ;RF mode 700
          DW      0CC01H      ;WF mode 700

RUNTBE:   
LDRDY0:   LD      HL,(VARED)  
          LD      (TMPEND),HL 
          LD      DE,(POOL)   
          LD      (OLDPOOL),DE 
          OR      A           
          SBC     HL,DE       
          LD      (VARLN),HL  
          LD      HL,-256     
          ADD     HL,SP       
          LD      (LAST),HL   
          LD      DE,(VARED)  
          PUSH    HL          
          OR      A           
          SBC     HL,DE       
          JP      C,ER06A     
          EX      (SP),HL     
          EX      DE,HL       
          LD      BC,(VARLN)  
          INC     BC          
          LDDR    
          POP     DE          
          RST     18H         
          DB      .ADDP0      
          LD      A,1         
          LD      (LOADFG),A  
          RET     

LDRDY:    CALL    LDRDY0      
          RST     18H         
          DB      .LOPEN      
          LD      A,(ELMD)    
          RET     

CLRVAR:   LD      HL,(VARED)  
          XOR     A           
          DEC     HL          
          LD      (HL),A      
          DEC     HL          
          LD      (HL),A      
          LD      (STRST),HL  
          DEC     HL          
          LD      (HL),A      
          LD      (VARST),HL  
          DEC     HL          
          LD      (HL),A      
          LD      (POOL),HL   
          LD      HL,4        
          LD      (VARLN),HL  
          RET     

OLDPOOL:  DB      0,0         ;(was DEFS 2)
VARLN:    DB      0,0         ;(was DEFS 2)
LAST:     DB      0,0         ;(was DEFS 2)
LOADFG:   DB      0           

CKCOM:    PUSH    AF          
          CALL    QDIRECT     
          JP      NZ,ER19     
          POP     AF          
          RET     

LDFIL:    LD      BC,(ELMD20) 
          PUSH    BC          
          LD      HL,(POOL)   
          LD      DE,(TEXTST) 
          OR      A           
          SBC     HL,DE       ;HL := text area size
          LD      L,0         
          SBC     HL,BC       
          JP      C,ER06A     
          LD      HL,0        
          LD      (OLDPOOL),HL 
          CALL    RUNINT      
          LD      HL,0        
          LD      (LNOBUF),HL 
          LD      HL,(TEXTST) 
          RST     18H         
          DB      .LOADF      
          POP     BC          
          LD      HL,(TEXTST) 
          ADD     HL,BC       
          LD      (OLDPOOL),HL 
          RET     

LOAD10:   LD      A,LDALU     
          LD      B,0         
          RST     18H         
          DB      .CLKL       
          LD      HL,LOADFG   
          LD      A,(HL)      
          OR      A           
          RET     Z           
          LD      (HL),0      
          LD      HL,(OLDPOOL) 
          LD      A,H         
          OR      L           
          JR      NZ,LOAD11   
          LD      HL,(TEXTST) 
          CALL    LDHL00      
LOAD11:   EX      DE,HL       
          LD      HL,(POOL)   
          LD      BC,(VARLN)  
          LDIR    
          EX      DE,HL       
          OR      A           
          SBC     HL,DE       
          EX      DE,HL       
          RST     18H         
          DB      .ADDP0      
          RET     

;*----------------------
;* VERIFY "CMT:filename"
;*----------------------
VERIFY:   PUSH    HL          
          CALL    REFLNX      
          POP     HL          
          CALL    ELMT        
          PUSH    HL          
          RST     18H         
          DB      .LOPEN      
          CP      2           
          JP      NZ,ER61     
          LD      HL,(TEXTST) 
          RST     18H         
          DB      .VRFYF      
          POP     HL          
          RET     

;*---------------------
;*  SAVE "dev:filename"
;*---------------------
SAVE:     CALL    TEST1       ;ALL
          DB      0E5H        
          LD      A,1         
          JP      Z,SVC.LS    
          PUSH    HL          
          CALL    REFLNX      
          POP     HL          
          CALL    ELMT        
          CALL    TEST1       
          DB      ','         
          JR      Z,SAVEA     
          PUSH    HL          
          LD      A,2         
          LD      (ELMD),A    
          LD      HL,(TEXTED) 
          LD      DE,(TEXTST) 
          OR      A           
          SBC     HL,DE       
          LD      (ELMD20),HL 
          LD      A,(ELMD1)   
          CP      0DH         
          JP      Z,ER60      
          RST     18H         
          DB      .SAVEF      
          POP     HL          
          RET     

SAVEA:    CALL    TESTX       
          DB      'A'         
          PUSH    HL          
          LD      A,2         
          LD      (ZRWX),A    
          LD      A,LDALU     
          LD      (ZLOG),A    
          CALL    OPEN.B      
          POP     HL          
          CALL    LIST0       
          CALL    PRTCR       
          LD      B,1         
          LD      A,LDALU     
          RST     18H         
          DB      .CLKL       
          RET     

;*----------------------------
;*  LOCK/UNLOCK "dev:filename"
;*----------------------------
UNLOCK:   XOR     A           
          DB      1           
LOCK:     LD      A,1         
          PUSH    AF          
          CALL    STREXP      
          RST     18H         
          DB      .DEVFN      
          POP     AF          
          RST     18H         
          DB      .LOCK       
          RET     

;*---------------
;* DIR[#n] "dev:"
;* DIR[/P] dev
;*---------------
DIR:      CALL    GETLU       
          PUSH    AF          ;lu#
          RST     18H         
          DB      .LUCHK      
          JP      C,ER44      
          BIT     1,A         ;W?
          JP      Z,ER59DU    
          CALL    LU2CH       
          CALL    DEVNAM      
          LD      B,A         ;ch#
          XOR     A           
          RST     18H         ;read directory
          DB      .DIR        
          LD      A,B         ;A=ch#
          RST     18H         ;set default
          DB      .SETDF      
          POP     AF          ;A=lu#
          RST     18H         ;print directory
          DB      .DIR        
          RET     

;*-----------------------
;*  DELETE "dev:filename"
;*-----------------------
FDEL:     CALL    STREXP      
          RST     18H         
          DB      .DEVFN      
          RST     18H         
          DB      .DELET      
          RET     

;*--------------------------------
;*  RENAME "dev:oldname","newname"
;*--------------------------------
RENAME:   CALL    STREXP      
          RST     18H         
          DB      .DEVFN      
          CALL    HCH2CH      
          CALL    STREXP      
          RST     18H         
          DB      .RENAM      
          RET     

;*-------------------
;* random file access
;*-------------------
PRX:      CALL    RAN0        
PRX2:     CALL    PRTEXP      
          RST     18H         
          DB      .PRREC      
          CALL    ENDCHK      
          RET     Z           
          CALL    CH2CH       
          JR      PRX2        

INX:      CALL    RAN0        
          LD      DE,(TMPEND) 
          CALL    MEMECK      
INX2:     CALL    INTGTV      
          PUSH    HL          
          PUSH    AF          
          PUSH    BC          
          LD      DE,(TMPEND) 
          RST     18H         
          DB      .INREC      
          POP     DE          
          POP     AF          
          CALL    INSUB       
          POP     HL          
          CALL    ENDCHK      
          RET     Z           
          CALL    CH2CH       
          JR      INX2        

RAN0:     CALL    TEST1       
          DB      '('         
          RET     NZ          
          CALL    IDEEXP      
          LD      A,D         
          OR      E           
          JP      Z,ER03      
          RST     18H         
          DB      .RECST      
          CALL    HCH29H      
          CALL    TEST1       
          DB      ','         
          RET     

;*---------------------
;*  SWAP "dev:filename"
;*---------------------
SWAP:     LD      A,(LSWAP)   
          OR      A           
          JP      NZ,ER25     
          PUSH    HL          
          LD      B,0         
          RST     18H         
          DB      .DEVNM      
          LD      (SWAPDV),DE 
          LD      (SWAPCH),A  
          LD      HL,(TEXTED) 
          LD      DE,(TEXTST) 
          XOR     A           
          SBC     HL,DE       
          LD      (ELMD20),HL 
          RST     18H         
          DB      .SWAP       
          POP     HL          
          CALL    ELMT        
          CALL    CHKEND      
          LD      A,(ZFLAG1)  
          BIT     RAND,A      
          JP      Z,ER59DU    
          PUSH    HL          ;RJOB
          LD      HL,(SWAPNB) 
          ADD     HL,SP       
          LD      SP,HL       
          EX      DE,HL       
          LD      HL,SWAPDS   
          LD      BC,(SWAPBY) 
          LDIR    
          CALL    LDRDY       
          CP      2           
          JP      NZ,ER61     
          LD      (SWAP2+1),SP 
SWAP2:    LD      SP,0        ;jump from CHAIN
          CALL    LDFIL       
          CALL    LOAD10      
          LD      HL,0FFFDH   
          PUSH    HL          ;SWAP flag
          PUSH    HL          
          LD      A,1         
          LD      (LSWAP),A   
          LD      HL,(TEXTST) 
          JP      NXLINE      

;*-------------
;* Recover SWAP
;*-------------
BSWAP:    XOR     A           
          LD      (LSWAP),A   
          POP     IX          
BSWAP2:   POP     BC          
          LD      A,B         
          CP      0FFH        
          JP      NZ,ER25     
          LD      A,C         
          CP      0FDH        
          JR      Z,BSWAP6    
          CP      0FEH        
          LD      HL,4        
          JR      Z,BSWAP4    
          CP      12H         
          LD      HL,10H      
          JP      NZ,ER25     
BSWAP4:   ADD     HL,SP       
          LD      SP,HL       
          JR      BSWAP2      

BSWAP6:   LD      DE,(SWAPDV) 
          LD      A,(SWAPCH)  
          RST     18H         
          DB      .SETDF      
          LD      B,0         
          RST     18H         
          DB      .DEVNM      
          CALL    LDRDY0      
          OR      0FFH        
          RST     18H         
          DB      .SWAP       
          CALL    LDFIL       
          CALL    LOAD10      
          LD      HL,0        
          ADD     HL,SP       
          LD      DE,SWAPDS   
          LD      BC,(SWAPBY) 
          LDIR    
          LD      SP,HL       
          POP     HL          ;RJOB
          RET     

SWAPDV:   DB      0,0         ;(was DEFS 2)
SWAPCH:   DB      0           ;(was DEFS 1)

;*---------------------------
;* I/O initial for cold-start
;*---------------------------
IOINIT:   POP     HL          
          PUSH    HL          
          LD      (ERRORP),HL 
          LD      A,'1'       
          CALL    IOINI2      
          LD      A,'2'       
          CALL    IOINI2      
          LD      DE,INITD3   
          LD      B,INITD4-INITD3 
          JR      IOINI4      

IOINI2:   LD      (INITD1+2),A 
          LD      DE,INITD1   
          LD      B,INITD3-INITD1 
IOINI4:   JP      INIT2       

INITD1:   DB      "RS?:0,$8C,13" 
INITD3:   DB      "CMT:T"     


INITD4:   

;*       END of original module IOCS.ASM
;*============================================================================
;*     START of original module GRPH.ASM
;*------------------------------
;* MZ-800 BASIC  Graphic command
;* FI:GRPH  ver 1.0B 9.21.84
;* Programmed by T.Miho
;*------------------------------


BITFU2:   DB      0           ;Default W0/W1
COL:      DB      03H         ;color code

;*-------------------
;* SET/RESET [c,w]x,y
;*-------------------
SETCMD:   DB      0F6H        
RESET:    XOR     A           
          PUSH    AF          
          CALL    COORD0      
          RST     18H         
          DB      .POSSV      
          POP     AF          ;SET/RESET
          PUSH    HL          
          EXX     
          RST     18H         
          DB      .PSET       
          POP     HL          
          RET     

;*-----------------------------------
;* LINE/BLINE [c,w] x0,y0,x1,y1,.....
;*-----------------------------------
LINE:     DB      0F6H        
BLINE:    XOR     A           
          LD      (LINE4+1),A 
          CALL    COORD0      
          CALL    HCH2CH      
LINE2:    EXX     
          PUSH    HL          ;YS
          PUSH    DE          ;XS
          EXX     
          CALL    COORD       
          POP     DE          ;XS
          EX      (SP),HL     ;YS,Text
          EXX     
LINE4:    LD      A,0         ;LINE/BLINE
          RST     18H         
          DB      .LINE       
          POP     HL          
          CALL    TEST1       
          DB      ','         
          JR      Z,LINE2     
          RST     18H         
          DB      .POSSV      
          RET     

;*-------------------
;* PATTERN [C,W] N,X$
;*-------------------
PATTERN:  CALL    COLCON      ;PATTERN command
          CALL    IDEEXP      
          XOR     A           
          BIT     7,D         
          JR      Z,GRDSP4    
          PUSH    HL          
          LD      H,A         
          LD      L,A         
          SBC     HL,DE       
          EX      DE,HL       
          POP     HL          
          LD      A,1         
GRDSP4:   EX      AF,AF'      
          LD      A,D         
          OR      A           
          JR      NZ,ER03A    
          LD      A,E         
          PUSH    AF          
          EX      AF,AF'      
          PUSH    AF          
          CALL    HCH2CH      
          CALL    STREXP      
          POP     AF          
          LD      C,A         
          POP     AF          
          PUSH    HL          
          LD      H,C         
          RST     18H         
          DB      .PATTR      
          POP     HL          
          CALL    ENDCHK      
          JR      NZ,PATTERN  
          RET     

;*--------------
;*  POSITION x,y
;*--------------
POSITION: CALL    COORD       ;POSITION command
          RST     18H         
          DB      .POSSV      
          RET     

;*--------------------
;*  Get X-Y coordinate
;*--------------------
COORD0:   CALL    COLCON      
COORD:    CALL    COORD1      ;Get x,y coordinate
          PUSH    DE          
          CALL    TEST1       
          DB      ','         
          CALL    COORD1      
          PUSH    DE          
          EXX     
          POP     HL          
          POP     DE          
          EXX     
          RET     

COORD1:   CALL    IDEEXP      
          LD      A,D         ;0000 ... 3FFF
          ADD     A,40H       ;C000 ... FFFF
          RET     P           
ER03A:    JP      ER03        

;*--------------
;* color palette
;*--------------
PALET:    CALL    ENDCHK      
          JP      Z,ER01      
          CALL    PALRD       
          CALL    COLCK2      
          AND     03H         
          PUSH    AF          
          LD      A,(PALBK)   
          LD      D,E         
          SRL     D           
          SRL     D           
          CP      D           
          JP      NZ,ER22     
          CALL    TESTX       
          DB      ','         
          CALL    PALRD       
          LD      B,A         
          POP     AF          
          RST     18H         
          DB      .DPLST      
          RET     

PALRD:    CALL    IBYTE       
          CP      16          ;0 .. 15 check
          JR      NC,ER03A    
          RET     

;*-----------------------
;*  BOX [c,w] xs,ys,xe,ye
;*-----------------------
BOX:      CALL    COORD0      
          EXX     
          PUSH    HL          ;YS
          PUSH    DE          ;XS
          EXX     
          CALL    HCH2CH      
          CALL    COORD       
          EXX     
          PUSH    HL          ;YE
          PUSH    DE          ;XE
          EXX     
          CALL    ENDCHK      
          JR      Z,BOX9      
          CALL    CH2CH       
          CALL    ENDCHK      
          LD      A,(COL)     
          CALL    NZ,COLCHK   
          SCF     
BOX9:     EXX     
          POP     DE          
          POP     HL          
          EXX     
          POP     DE          
          EX      (SP),HL     
          RST     18H         
          DB      .BOX        
          POP     HL          
          RET     

;*----------
;* COLOR c,w
;*----------
COLOR:    CALL    COLSUB      
          LD      A,(COL)     
          RST     18H         
          DB      .DCOL       
          LD      (SELCOL),A  
          LD      A,(PWMODE)  
          LD      (BITFU2),A  
          CALL    CHKEND      
          RET     

;*------------------
;* COLOR CONTROL EXP
;*------------------
COLCON:   CALL    TEST1       
          DB      ','         
          CALL    TEST1       
          DB      '['         
          JR      NZ,COLCN1   
          CALL    COLSUB      
          LD      A,(COL)     
          RST     18H         
          DB      .DGCOL      
          CALL    TESTX       
          DB      ']'         
          CALL    TEST1       
          DB      ','         
          RET     

COLCN1:   LD      A,(SELCOL)  
          LD      (COL),A     
          RST     18H         
          DB      .DGCOL      
COLCN2:   LD      A,(BITFU2)  
          LD      (PWMODE),A  
          RET     

COLSUB:   CALL    TEST1       
          DB      ','         
          JR      Z,COLC8     
          CALL    COLCHK      
          LD      (COL),A     
          CALL    TEST1       
          DB      ','         
          JR      NZ,COLCN2   
COLC9:    CALL    IBYTE       
          CP      2           
          JR      NC,ER03B    
          LD      (PWMODE),A  
          RET     

COLC8:    LD      A,(SELCOL)  
          LD      (COL),A     
          JR      COLC9       

COLCHK:   PUSH    BC          
          CALL    IBYTE       
          POP     BC          
COLCK2:   LD      A,(CRTMD1)  
          RRA     
          JR      C,CMD1      
          RRA     
          JR      C,CMD2      
          RRA     
          JR      C,CMD3      
CMD1:     LD      A,E         
          CP      4           
          JR      NC,ER03B    
          RET     

CMD2:     LD      A,E         
          CP      16          
          JR      NC,ER03B    
          RET     

CMD3:     LD      A,E         
          CP      2           
          RET     C           
ER03B:    JP      ER03        

;*------------------------------------------------------
;* Top of p.466 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
;*-------------
;*PAINT COMMAND
;*-------------
PAINT:    CALL    COLCON      
          CALL    POSITION    
          LD      B,0         
          LD      DE,PAINTB   
          PUSH    DE          
          CALL    ENDCHK      
          JR      Z,PAINT3    
PAINT1:   CALL    CH2CH       
          PUSH    DE          
          CALL    COLCHK      
          POP     DE          
          LD      (DE),A      
          INC     DE          
          INC     B           
          LD      A,B         
          CP      16          
          JP      Z,ER01      
          CALL    ENDCHK      
          JR      NZ,PAINT1   
PAINT2:   EX      (SP),HL     ;data adrs
          PUSH    HL          
          LD      HL,-527     
          ADD     HL,SP       
          LD      (PAIWED),HL 
          POP     HL          
          RST     18H         
          DB      .PAINT      
          JP      C,ER06      
          POP     HL          
          RET     

PAINT3:   LD      A,(COL)     
          LD      (DE),A      
          INC     B           ; data count
          JR      PAINT2      

PAINTB:   DB      0,0,0,0,0,0,0,0 ;(was DEFS 16)

          DB      0,0,0,0,0,0,0,0 


;*------------------------------------------------------
;* Top of p.467 in German Listing of MZ-2Z046 Disk Basic
;*------------------------------------------------------
;*--------------
;*CIRCLE COMMAND
;*--------------
CIRCLE:   PUSH    HL          
          LD      HL,0        
          LD      (CW.H+1),HL 
          LD      (CW.XS+1),HL 
          LD      (CW.YS+1),HL 
          LD      (CW.XE+1),HL 
          LD      (CW.YE+1),HL 
          LD      HL,KK       
          CALL    CLRFAC      
          LD      HL,FLT2PI   
          LD      DE,SK       ;º≠≥ÿÆ≥∂∏=2PAI
          CALL    LDIR5       
          POP     HL          
          CALL    COORD0      ;∂≤º¨∏ Ω¿-ƒ
          RST     18H         
          DB      .POSSV      
          CALL    HCH2CH      
          CALL    IDEEXP      
          PUSH    HL          
          LD      A,D         
          AND     0C0H        
          JP      NZ,ER03     
          EX      DE,HL       
          LD      (CW.R+2),HL ; ›π≤
          LD      (CW.XS+1),HL 
          LD      (CW.XE+1),HL 
          LD      HL,(INTFAC) 
          LD      DE,CIR.R    
          CALL    LDIR5       
          POP     HL          
          CALL    ENDCHK      
          JP      Z,CW        
          CALL    CH2CH       
          CALL    TEST1       
          DB      ','         
          JR      Z,CIRCL2    
          CALL    HIRIT       
          CALL    ENDCHK      
          JP      Z,CW        
          CALL    CH2CH       
CIRCL2:   CALL    TEST1       
          DB      ','         
          JR      Z,CIRCL8    
          LD      IX,CW.XS+1  
          LD      IY,KK       
          CALL    STX         
          CALL    ENDCHK      
          JP      Z,CW        
          CALL    CH2CH       
CIRCL8:   CALL    TEST1       
          DB      ','         
          JR      Z,CIRCL4    
          LD      IX,CW.XE+1  
          LD      IY,SK       
          CALL    STX         
          CALL    ENDCHK      
          JP      Z,CW        
          CALL    CH2CH       
CIRCL4:   CALL    TESTX       
          DB      'O'         
          SCF     
          JR      CW1         

CW:       XOR     A           
CW1:      PUSH    HL          
          PUSH    AF          
          LD      HL,KK       
          LD      DE,SK       
          CALL    SUBCMD         
          CALL    LDIR5       
          LD      A,(KK)      
          OR      A           
          LD      B,0         
          JR      Z,CW2       ;KK=SK
          LD      HL,KK+1     
          RES     7,(HL)      
          DEC     HL          ;HL:= ABS(KK-SK)
          LD      DE,FLTPAI   
          CALL    CMP         
          LD      B,1         
          JR      C,CW2       ;        ABS() < PI
          LD      DE,FLT2PI   
          CALL    CMP         
          LD      B,2         
          JR      C,CW2       ;PI  <= ABS() < 2*PI
          LD      B,3         ;2*PI <= ABS()
CW2:      LD      A,(SK+1)    
          AND     80H         
          OR      B           
          LD      B,A         
          POP     AF          ;CF='O'
          LD      A,B         
          EXX     
CW.XS:    LD      DE,0        ;Start X
CW.YS:    LD      HL,0        ;Start Y
CW.H:     LD      BC,0        ;HIRITU
          EXX     
CW.XE:    LD      DE,0        ;End X
CW.YE:    LD      HL,0        ;End Y
CW.R:     LD      IX,0        ;R
          RST     18H         
          DB      .CIRCL      
          POP     HL          
          OR      A           
          RET     

HIRIT:    CALL    IDEEXP      
          CALL    PUSHR       
          LD      HL,(INTFAC) 
          INC     HL          
          BIT     7,(HL)      
          JP      NZ,ER03     
          DEC     HL          
          LD      DE,FLONE    
          CALL    CMP         
          RET     Z           
          LD      A,1         
          JR      C,HI        
          LD      HL,FLONE    
          LD      DE,CIRW3    
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          LD      DE,(INTFAC) 
          CALL    DIV         
          LD      A,2         
HI:       LD      (CW.H+1),A  
          LD      DE,LOG256   
          CALL    MUL         
          LD      DE,LOGHLF   
          CALL    ADDCMD
          CALL    HLFLT       
          LD      A,L         
          LD      (CW.H+2),A  
          BIT     0,H         
          RET     Z           
          XOR     A           
          LD      (CW.H+1),A  
          RET     

STX:      PUSH    IX          
          PUSH    IY          
          CALL    IDEEXP      
          POP     DE          ;KK/SK
          POP     IX          
          PUSH    HL          
          PUSH    IX          
          LD      HL,(INTFAC) 
          CALL    LDIR5       
          LD      HL,(INTFAC) 
          LD      D,H         
          LD      E,L         
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          CALL    LDIR5       
          CALL    COS         ;HL=(INTFAC)+5
          LD      DE,CIR.R    
          CALL    MUL         
          CALL    STXSUB      
          LD      HL,(INTFAC) 
          CALL    SIN         
          LD      DE,CIR.R    
          CALL    MUL         
          CALL    NEGCMD         
          CALL    STXSUB      
          POP     IX          
          POP     HL          
          RET     

STXSUB:   INC     HL          
          BIT     7,(HL)      
          PUSH    AF          
          RES     7,(HL)      
          DEC     HL          
          LD      DE,LOGHLF   
          CALL    ADDCMD         
          POP     AF          
          INC     HL          
          JR      Z,STXSUC    
          SET     7,(HL)      
STXSUC:   DEC     HL          
          CALL    HLFLT       
          EX      DE,HL       
          POP     HL          ;RET ADRS
          EX      (SP),HL     ;Save coordinate
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          INC     HL          
          INC     HL          
          EX      (SP),HL     
          JP      (HL)        

;*-----------------------
;*CIRCLE WORK AREA PART-2
;*-----------------------
CIR.R:    DB      0,0,0,0,0   ;(was DEFS 5)


CIRW3:    DB      0,0,0,0,0   ;(was DEFS 5)


LOG256:   DW      0089H       
          DW      0000H       
          DB      00H         
LOGHLF:   DW      0080H       
          DW      0A700H      
          DB      0C6H        

KK:       DB      0,0,0,0,0   ;(was DEFS 5)

SK:       DB      0,0,0,0,0   ;(was DEFS 5)


;*------------------
;* SYMBOL command
;*------------------
;*DIRARE: EQU    27D0H          ;DUPLICATE LABEL (commentd out)

SMBOL:    CALL    COORD0      ;position load
          RST     18H         ;position input
          DB      .POSSV      
          CALL    HCH2CH      
;*string pointer load
          CALL    STREXP      
;*string zero check
          LD      A,B         
          OR      A           
          PUSH    BC          
          PUSH    HL          
          LD      C,B         
          LD      B,0         
          LD      HL,DIRARE   
          EX      DE,HL       
          JR      Z,SMBL2     
          LDIR                ;string data xfer
SMBL2:    POP     HL          
          CALL    HCH2CH      
          CALL    IBYTE       ;yoko bairitsu
          LD      A,D         
          OR      E           
          JR      Z,ERJP3     ;zero error
          PUSH    DE          
          CALL    HCH2CH      
          CALL    IBYTE       ;tate bairitsu
          LD      A,D         
          OR      E           
ERJP3:    JP      Z,ER03      ;zero error
          LD      A,E         
          POP     DE          
          LD      D,A         
          CALL    ENDCHK      ;end check
          PUSH    DE          
          JR      Z,SMBL1     
          CALL    HCH2CH      
          CALL    IBYTE       ;angle load
          LD      A,3         
          CP      E           
          JP      C,ER03      
          LD      A,E         
          DB      06H         
SMBL1:    XOR     A           
          POP     DE          
          POP     BC          
          LD      C,A         ;angle push
          LD      A,B         ;string length
          OR      A           
          RET     Z           ;zero return
          LD      A,C         ;angle pop
          PUSH    HL          
          EX      DE,HL       
          LD      DE,DIRARE   
          RST     18H         
          DB      .SYMBL      
          POP     HL          
          RET     

;*-------------
;*  HCOPY 1/2/3
;*  CLS   1/2/3
;*-------------
HCOPY:    CALL    CHKEND      
          PUSH    HL          
          LD      A,00H       ;ASAHI modify
          RST     18H         
          DB      .HCPY       
          POP     HL          
          RET     

CLS:      CALL    CHKEND      
          PUSH    HL          
          RST     18H         
          DB      .CLS        
          POP     HL          
          RET     

;*       END of original module GRPH.ASM
;*============================================================================
;*     START of original module CONV.ASM
;*------------------------------
;* MZ-800 BASIC  Data Conversion
;* FI:CONV  ver 1.0A 7.18.84
;* Programmed by T.Miho
;*------------------------------

CHBAR:    EQU     0C4H        ; Sharp ASCII code for graphic '_'
;*%YEN:   EQU    7DH            ; DUPLICATE EQUATE (commented out)
CHUKP:    EQU     0FBH        ; Sharp ASCII code for 'ú' sign

CHKEND:   CALL    ENDCHK      
          RET     Z           
          JP      ER01        

TESTP:    XOR     A           
          LD      (FILOUT),A  
          CALL    TEST1       ;/
          DB      0FBH        
          RET     NZ          ;ZF=0
          CALL    TESTX       
          DB      'P'         
          CALL    LPTTMD      ;Check text mode
          LD      A,'P'       
          LD      (FILOUT),A  
          CP      A           ;ZF=1
          RET     

ASCFIV:   LD      DE,DGBF00   
          LD      B,0         ;Zero sup.
          PUSH    DE          
          RST     18H         
          DB      .ASCHL      
          POP     DE          
          RET     

;*------------------
;* Fetch subroutines
;*------------------
ICH28H:   INC     HL          
HCH28H:   CALL    HLFTCH      
CH28H:    CP      '('         
          JR      CHXX2       

HCH29H:   CALL    HLFTCH      
CH29H:    CP      ')'         
          JR      CHXX2       

HCH2CH:   CALL    HLFTCH      
CH2CH:    CP      ','         

CHXX2:    INC     HL          
          RET     Z           
          JP      ER01        

SKPDI:    INC     DE          
SKPDE:    LD      A,(DE)      
          CP      ' '         
          JR      Z,SKPDI     
          RET     

LDIR1:    LD      HL,FLONE    ;(DE)=1.0
LDIR5:    LD      BC,5        ;(DE)=(HL) 5BYTES SET
          LDIR    
          RET     

FLTHEX:   CALL    CLRFAC      ;EXT(FLOAT) - (HL)=DE
          LD      A,E         
          OR      D           
          RET     Z           
          BIT     7,D         
          LD      A,7FH       
          JR      Z,NORFLH    
          LD      A,D         
          CPL     
          LD      D,A         
          LD      A,E         
          CPL     
          LD      E,A         
          INC     DE          
          LD      A,0FFH      
NORFLH:   LD      B,91H       
SFL:      DEC     B           
          BIT     7,D         
          JR      NZ,FLHXRT   
          RL      E           
          RL      D           
          JR      SFL         

FLHXRT:   LD      (HL),B      
          INC     HL          
          AND     D           
          LD      (HL),A      
          INC     HL          
          LD      (HL),E      
          DEC     HL          
          DEC     HL          
          RET     

TSTNUM:   CP      30H         ;if 0-9 THEN CY=0
          RET     C           
          CP      3AH         
          CCF     
          RET     

TSTVAR:   CP      5FH         ;if VAR THEN CY=0
          RET     Z           
          CP      30H         
          RET     C           
          CP      5BH         
          CCF     
          RET     C           
          CP      3AH         
          CCF     
          RET     NC          
          CP      41H         
          RET     

;*----------------------
;*CONV FLOAT(HL)_ASC(DE)
;*----------------------
CVFLAS:   CALL    CLRFAC      
          LD      (DGITCO),A  
          LD      (DGITFG),A  
          LD      (EXPFLG),A  
          LD      (PRODFL+1),A 
          LD      A,5         
          LD      (PRCSON),A  
DEFTCL:   CALL    SKPDE       
          INC     DE          
          CP      '+'         
          JR      Z,DEFTCL    
          CP      '-'         
          JR      NZ,CHKAND   
          CALL    DEFTCL      
          JP      TOGLE       

CHKAND:   CP      '$'         
          JR      NZ,ZRSKIP   
          PUSH    HL          
          EX      DE,HL       
          RST     18H         
          DB      .DEHEX      
          EX      (SP),HL     
          CALL    FLTHEX      
          POP     DE          
          LD      A,5         
          RET     

ZRSKIP:   CP      '0'         
          JR      NZ,MDLAG    
          LD      A,(DE)      
          INC     DE          
          JR      ZRSKIP      

FTCHL:    LD      A,(DE)      
          INC     DE          
MDLAG:    CP      20H         
          JR      Z,FTCHL     
          CP      '.'         
          JR      Z,DECNUM    ;Label here was POINTS, changed to DECNUM
          CALL    TSTNUM      
          JR      C,TST23H    
          SUB     30H         
          CALL    MULTEN      
          CALL    MULDEC      
          LD      A,1         
          LD      (DGITFG),A  
          LD      A,(DGITCO)  
          INC     A           
          LD      (DGITCO),A  
          JR      FTCHL       

DECNUM:   LD      A,1         ;Label here was POINTS
          LD      (PRODFL+1),A 
          LD      C,A         
SKIPSP:   LD      A,(DE)      ;Label here was POINT
          INC     DE          
          CP      20H         
          JR      Z,SKIPSP    
          CALL    TSTNUM      
          JR      C,PESC      
          INC     C           
          SUB     30H         
          JR      Z,SDFGRE    
          PUSH    AF          
          LD      A,1         
          LD      (DGITFG),A  
          POP     AF          
SDFGRE:   PUSH    AF          
          LD      A,(DGITFG)  
          LD      B,A         
          LD      A,(DGITCO)  
          ADD     A,B         
          LD      (DGITCO),A  
          POP     AF          
          CALL    MULTEN      
          CALL    MULDEC      
          JR      SKIPSP      ;Label here was POINT

PESC:     DEC     C           
          JR      Z,TST23H    
          CALL    DIVTEN      
          JR      PESC        

TST23H:   CP      'E'         
          JR      Z,EXPON1    

TSTPRC:   DEC     DE          
          LD      A,(EXPFLG)  
          OR      A           
          RET     NZ          
PRODFL:   LD      A,0         ;xxx
          OR      A           
          RET     NZ          
          LD      A,5         
          RET     

EXPON1:   LD      A,(DE)      
          CP      '-'         
          JR      Z,EXPON2    
          CP      '+'         
          JR      Z,EXPON2    
          CALL    TSTNUM      
          JR      C,TSTPRC    
EXPON2:   LD      A,1         
          LD      (PRODFL+1),A 
          PUSH    HL          
          LD      HL,MUL      
          LD      (EXJPVC),HL 
          LD      HL,0000H    
          LD      A,(DE)      
          INC     DE          
          CP      '+'         
          JR      Z,CBEGIN    
          CP      '-'         
          JR      NZ,CLMIDL   
          PUSH    HL          
          LD      HL,DIV      
          LD      (EXJPVC),HL 
          POP     HL          
CBEGIN:   LD      A,(DE)      
          INC     DE          
CLMIDL:   SUB     30H         
          JR      C,ESCPER    
          CP      0AH         
          JR      NC,ESCPER   
          PUSH    DE          
          CALL    ADHLCK      
          LD      E,L         
          LD      D,H         
          CALL    ADHLCK      
          CALL    ADHLCK      
          CALL    ADDECK      
          LD      E,A         
          LD      D,0         
          CALL    ADDECK      
          POP     DE          
          JR      CBEGIN      

ESCPER:   LD      A,H         
          OR      A           
          JR      NZ,OVRFL    
          LD      A,L         
          POP     HL          
          PUSH    DE          
          PUSH    BC          
          PUSH    HL          
          LD      DE,ZFAC     
          PUSH    DE          
          CALL    LDIR1       
          POP     HL          
          LD      B,A         
          INC     B           
          JR      ESCPR2      

ESCPR1:   CALL    MULTEN      
ESCPR2:   DJNZ    ESCPR1      
          EX      DE,HL       
          POP     HL          
          DB      0CDH        
EXJPVC:   DB      0,0         ;(was DEFS 2)
          POP     BC          
          POP     DE          
          JP      TSTPRC      

DIVTEN:   PUSH    AF          
          PUSH    BC          
          PUSH    DE          
          LD      DE,FLTEN    
          CALL    DIV         
          POP     DE          
          POP     BC          
          POP     AF          
          RET     

ADDECK:   ADD     HL,DE       
          RET     NC          
          JR      OVRFL       

ADHLCK:   ADD     HL,HL       
          RET     NC          
OVRFL:    JP      ER02        ;OVERFLOW

MULDEC:   PUSH    DE          
          PUSH    HL          
          LD      HL,ZFAC     ;*****
          LD      E,A         
          LD      D,0         
          CALL    FLTHEX      
          EX      DE,HL       
          POP     HL          
          PUSH    BC          
          CALL    ADDCMD         
          POP     BC          
          POP     DE          
          RET     

;*----------------------
;*CONV ASC(DE)_FLOAT(HL)
;*----------------------
CVNMFL:   LD      A,5         
          LD      (PRCSON),A  
          LD      A,(HL)      
          OR      A           
          JR      Z,ONLYZH    
          INC     HL          
          LD      A,(HL)      
          DEC     HL          
          RLCA    
ONLYZH:   LD      A,20H       
          JR      NC,PLUS     
          CALL    TOGLE       
          LD      A,'-'       
PLUS:     PUSH    AF          
          CALL    CVASF1      
          CALL    ADJDGT      
          POP     AF          
          DEC     DE          
          LD      (DE),A      
          RET     

CMP2:     PUSH    BC          
          CALL    CMP         
          POP     BC          
          RET     

INT:      CALL    PUSHR       
          LD      A,(HL)      
          CP      81H         
          JP      C,CLRFAC    
          LD      A,(HL)      
          CP      0A0H        
          RET     NC          
          INC     HL          
          CALL    RCHLBC      
          PUSH    HL          
          LD      L,(HL)      
          LD      B,0         
INTSFL:   SRL     E           
          RR      D           
          RR      C           
          RR      L           
          INC     A           
          INC     B           
          CP      0A0H        
          JR      NZ,INTSFL   
INTSBL:   SLA     L           
          RL      C           
          RL      D           
          RL      E           
          DJNZ    INTSBL      
          LD      A,L         
          POP     HL          
          LD      (HL),A      
          DEC     HL          
          LD      (HL),C      
          DEC     HL          
          LD      (HL),D      
          DEC     HL          
          LD      (HL),E      
          RET     

RCHLBC:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          INC     HL          
          LD      C,(HL)      
          INC     HL          
          RET     

FRACT:    LD      A,(HL)      
          CP      81H         
          RET     C           
          PUSH    DE          
          PUSH    HL          
          LD      DE,FRACW    
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          CALL    INT         
          EX      DE,HL       
          POP     HL          
          CALL    SUBCMD         
          POP     DE          
          RET     

FRACW:    DB      0,0,0,0,0   ;(was DEFS 5)


MULTEN:   PUSH    AF          
          PUSH    BC          
          PUSH    DE          
          LD      DE,FLTEN    
          CALL    MUL         
          POP     DE          
          POP     BC          
          POP     AF          
          RET     

HLFLT:    INC     HL          
          BIT     7,(HL)      
          JR      Z,NORHLC    
          CALL    NORHLC      
          LD      A,H         
          CPL     
          LD      H,A         
          LD      A,L         
          CPL     
          LD      L,A         
          INC     HL          
          RET     

NORHLC:   DEC     HL          
          LD      A,(HL)      
          CP      91H         
          JP      NC,ER02     ;OVERFLOW
          CP      81H         
          JR      C,HXZRRT    
          PUSH    AF          
          INC     HL          
          LD      A,(HL)      
          INC     HL          
          LD      L,(HL)      
          LD      H,A         
          POP     AF          
          SET     7,H         
HXFLSL:   CP      90H         
          RET     Z           
          INC     A           
          SRL     H           
          RR      L           
          JR      HXFLSL      

HXZRRT:   CCF     
          LD      HL,0        
          RET     

SNGMXO:   DW      3E9BH       
          DW      20BCH       
          DB      00H         
SNGMXP:   DW      1898H       
          DW      8096H       
          DB      00H         
          DW      7494H       
          DW      0024H       
          DB      00H         
          DW      4391H       
          DW      0050H       
          DB      00H         
          DW      1C8EH       
          DW      0040H       
          DB      00H         
          DW      7A8AH       
          DW      0000H       
          DB      00H         
          DW      4887H       
          DW      0000H       
          DB      00H         

FLTEN:    DW      2084H       
          DW      0000H       
          DB      00H         

FLONE:    DW      0081H       
          DW      0000H       
          DB      00H         
          DW      4C7DH       
          DW      0CCCCH      
          DB      0CDH        

SLLMT:    DW      2B66H       
          DW      77CCH       
          DB      12H         

EXPASC:   LD      HL,(HLBUF2) 
          LD      B,0         
TENCOM:   LD      DE,FLTEN    
          CALL    CMP2        
          JR      C,ONECOM    
          CALL    DIVTEN      
          INC     B           
          JR      TENCOM      

ONECOM:   LD      DE,FLONE    
          CALL    CMP2        
          JR      NC,COMOK    
          CALL    MULTEN      
          DEC     B           
          JR      ONECOM      

COMOK:    PUSH    BC          
          CALL    CVASF1      
          CALL    ADJDGT      
          POP     BC          
          PUSH    DE          
          EX      DE,HL       
SERNOP:   LD      A,(HL)      
          OR      A           
          JR      Z,SEROK     
          INC     HL          
          JR      SERNOP      

SEROK:    DEC     HL          
          LD      A,(HL)      
          INC     HL          
          CP      '0'         
          JR      NZ,USEXPE   
          INC     B           
          DEC     HL          
USEXPE:   LD      A,'E'       
          LD      (HL),A      
          INC     HL          
          LD      A,B         
          LD      B,'+'       
          BIT     7,A         
          JR      Z,EXSGPT    
          NEG     
          LD      B,'-'       
EXSGPT:   LD      (HL),B      
          INC     HL          
          LD      (HL),'0'    
EXTNPT:   SUB     0AH         
          JR      C,EXONPT    
          INC     (HL)        
          JR      EXTNPT      

EXONPT:   ADD     A,3AH       
          INC     HL          
          LD      (HL),A      
          INC     HL          
          LD      (HL),0      
          POP     DE          
          RET     

INTPAR:   PUSH    HL          
          CALL    HLFLT       
          LD      DE,DGBF11   
          PUSH    DE          
          LD      B,1         ;Non zero-sup.
          RST     18H         
          DB      .ASCHL      
          POP     HL          
          LD      A,'0'       
          LD      B,5         
INT22:    CP      (HL)        
          JR      NZ,INTDGO   
          INC     HL          
          DJNZ    INT22       
          JR      INTDGE      

INTDGO:   LD      A,B         
          LD      (DGITCO),A  
          LD      A,1         
          LD      (DGITFG),A  
INTDGE:   LD      A,'.'       
          LD      (DGBF16),A  
          POP     HL          
          CALL    FRACT       
          JP      FRACDG      

CVASF1:   LD      (HLBUF2),HL 
          XOR     A           
          LD      (DGITCO),A  
          LD      (DGITFG),A  
          PUSH    HL          
          LD      HL,DGBF07   
          LD      (HL),0FFH   
          LD      B,33        ;fill buffer with 0's
          LD      A,'0'       
CVASF2:   INC     HL          
          LD      (HL),A      
          DJNZ    CVASF2      
          LD      A,'.'       
          LD      (DGBF16),A  
          POP     HL          
          LD      A,(HL)      
          OR      A           
          RET     Z           
          LD      DE,SNGMXO   
          CALL    CMP         
          CCF     
          RET     C           
          LD      DE,SLLMT    
          CALL    CMP         
          RET     C           
          LD      DE,ZFAC1    
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          LD      A,(HL)      
          CP      81H         
          JR      C,FRACDG    ;
          CP      90H         
          JP      C,INTPAR    ;
          LD      IX,DGBF08   
          LD      DE,SNGMXP   
          CALL    GENDGT      
          CALL    GENDQ       
          RET     NC          ;C=0
FRACDG:   LD      IX,DGBF17   
FRCAGN:   LD      DE,SNGMXO   
          PUSH    BC          
          PUSH    IX          
          CALL    MUL         
          POP     IX          
          POP     BC          
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          CALL    GENDGT      
          CALL    GENDQ       
          JR      C,FRCAGN    
          RET     

CVASFL:   LD      A,5         
          LD      (PRCSON),A  
          PUSH    HL          
          LD      DE,ZFAC2    
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          CALL    CVASF1      
          CALL    ADJDG2      
          POP     HL          
          RET     

ZERADJ:   LD      DE,DGBF16   
          LD      (DE),A      
          DEC     DE          
          RET     

ADJDG2:   JP      C,EXPASC    
ADJDGT:   LD      HL,(HLBUF2) 
          LD      A,(HL)      
          OR      A           
          JR      Z,ZERADJ    
          LD      DE,DGBF08   
          DEC     DE          
          EX      DE,HL       
          LD      DE,1        
SSNTO1:   INC     HL          
          LD      A,(HL)      
          CP      '.'         
          JR      NZ,TST30H   
          LD      DE,0        
          JR      SSNTO1      

TST30H:   CP      '0'         
          JR      Z,SSNTO1    
          ADD     HL,DE       
          LD      DE,8        
          ADD     HL,DE       
          LD      A,(HL)      
FRCASL:   LD      (HL),'0'    
          CP      35H         
          JR      C,BCKSER    
ADDLOP:   DEC     HL          
          LD      A,(HL)      
          CP      '.'         
          JR      Z,ADDLOP    
          INC     A           
          JR      Z,MAXNO     
          LD      (HL),A      
          CP      ':'         
          JR      Z,FRCASL    
          INC     HL          
BCKSER:   LD      DE,DGBF16   
          EX      DE,HL       
          OR      A           
          SBC     HL,DE       
          EX      DE,HL       
          JR      C,KUMI      
          LD      HL,DGBF16   
          JR      INTDI2      
KUMI:     DEC     HL          
          LD      A,(HL)      
          CP      '.'         
          DEC     HL          
          JR      Z,INTDIS    
          INC     HL          
          CP      '0'         
          JR      Z,BCKSER    
          PUSH    HL          
          LD      DE,DGBF25   
          SBC     HL,DE       
          POP     HL          
          JP      NC,EXPASC   
INTDIS:   INC     HL          
INTDI2:   LD      (HL),0      
          LD      DE,DGBF08   
TSTFST:   LD      A,(DE)      
          CP      '0'         
          JR      NZ,ZEONLY   
          INC     DE          
          JR      TSTFST      
ZEONLY:   OR      A           
          RET     NZ          
          DEC     DE          
          LD      A,'0'       
          LD      (DE),A      
          RET     

MAXNO:    LD      HL,DGBF00   
          LD      DE,M1E08    
          PUSH    BC          
          LD      BC,6        
          LDIR    
          POP     BC          
          LD      DE,DGBF00   
          RET     

M1E08:    DB      "1E+08"     

          DB      0           

GENDGT:   LD      A,(DE)      
          CP      7DH         
          RET     Z           
INTGDL:   CALL    CMP         
          JR      C,GTESTB    
          INC     (IX+0)      
          PUSH    IX          
          PUSH    BC          
          CALL    SUBCMD         
          POP     BC          
          POP     IX          
          LD      A,1         
          LD      (DGITFG),A  
          JR      INTGDL      

GTESTB:   INC     IX          
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          LD      A,(DGITFG)  
          LD      B,A         
          LD      A,(DGITCO)  
          ADD     A,B         
          LD      (DGITCO),A  
          CALL    GENDQ       
          RET     NC          
          JR      GENDGT      

GENDQ:    LD      A,(HL)      
          OR      A           
          RET     Z           
          LD      A,(DGITCO)  
          CP      9           
          RET     

DGITCO:   DB      0           ;(was DEFS 1)
DGITFG:   DB      0           ;(was DEFS 1)
EXPFLG:   DB      0           ;(was DEFS 1)
HLBUF2:   DB      0,0         ;(was DEFS 2)
;*-------------------------------------
;* Top p.498 in German Listing of 2Z046
;*-------------------------------------
;*-----------------
;* USING CONVERSION
;*-----------------
USINGS:   DB      0,0         ;USING START (was DEFS 2)
USINGP:   DB      0,0         ;USING POINTER (was DEFS 2)

USNGSB:   LD      HL,(USINGP) 
          PUSH    DE          
USNGS2:   LD      A,(HL)      
          OR      A           
          JP      Z,ER03      
          CALL    USGCD1      
          JR      Z,USNGS4    
          LD      (BC),A      
          INC     BC          
          INC     HL          
          JR      USNGS2      
USNGS4:   EX      AF,AF'      
          LD      A,(PRCSON)  
          CP      3           
          JP      NZ,FLTUSG   
          EX      AF,AF'      
          CP      '!'         
          JP      Z,OUT1CH    
          CP      '&'         
          JP      Z,OUT2CH    
          JP      ER04        

OUT1CH:   EX      (SP),HL     
          PUSH    BC          
          CALL    CVTSDC      
          OR      A           
          LD      A,20H       
          JR      Z,OUT1CJ    
          LD      A,(DE)      
OUT1CJ:   POP     BC          
          LD      (BC),A      
          INC     BC          
AFTPR0:   POP     HL          
          INC     HL          
AFTPRT:   LD      A,(HL)      
          OR      A           
          JR      Z,BRTUSG    
          CALL    USGCD1      
          JR      Z,RETUSG    
          LD      (BC),A      
          INC     BC          
          INC     HL          
          JR      AFTPRT      

BRTUSG:   LD      HL,(USINGS) 
RETUSG:   LD      (USINGP),HL 
          XOR     A           
          LD      (BC),A      
          RET     

OUT2CH:   LD      D,2         
OUT22:    INC     HL          
          LD      A,(HL)      
          CP      '&'         
          JR      Z,FOUN26    
          INC     D           
          CP      20H         
          JR      Z,OUT22     
          JP      ER03        

FOUN26:   EX      (SP),HL     
          LD      A,(HL)      
          CP      D           
          JR      C,TRIZHH    
          INC     HL          
          CALL    INDRCT      
          PUSH    BC          
          LD      BC,(STRST)  
          ADD     HL,BC       
          POP     BC          
HPRLOP:   LD      A,(HL)      
          LD      (BC),A      
          INC     BC          
          INC     HL          
          DEC     D           
          JR      NZ,HPRLOP   
          JP      AFTPR0      

TRIZHH:   LD      E,(HL)      
          INC     HL          
          CALL    INDRCT      
          LD      A,E         
          OR      A           
          JR      Z,HHSPCF    
          PUSH    BC          
          LD      BC,(STRST)  
          ADD     HL,BC       
          POP     BC          
PRHHL1:   LD      A,(HL)      
          LD      (BC),A      
          INC     BC          
          INC     HL          
          DEC     E           
          JR      Z,HHSPC     
          DEC     D           
          JR      NZ,PRHHL1   
          JP      AFTPR0      

HHSPCF:   LD      A,20H       
          LD      (BC),A      
          INC     BC          
HHSPC:    DEC     D           
          JR      NZ,HHSPCF   
          JP      AFTPR0      

;*-----------------
;* Check using code
;*-----------------
USGCD1:   CALL    CHKACC      
          DB      4           
          DB      "!&#+"      
          RET     Z           
          LD      E,A         
          CP      2AH         ;[*]
          JR      Z,USGCD2    
          CALL    QMONEY      
          JR      Z,USGCD2    
          CP      '.'         
          LD      E,'#'       
          JR      Z,USGCD2    
          CP      CHBAR       
          RET     NZ          
          INC     HL          
          LD      A,(HL)      
          OR      A           
          JP      Z,ER03      
          RET     

USGCD2:   INC     HL          
          LD      A,(HL)      
          CP      E           
          DEC     HL          
          LD      A,(HL)      
          RET     

FLTUSG:   XOR     A           
          LD      (FPLUSF),A  
          LD      (PUASTF),A  ;PUT * FLG
          LD      (PUYENF),A  ;]
          LD      (PUAFMF),A  ;AFTER-FLG
          LD      (PUCOMF),A  ;PUT , FLG
          LD      (INTLEN),A  ;INT LENGTH
          LD      (RPLUSF),A  ;###+
          LD      (PUEXPF),A  ;^^^^
          DEC     A           
          LD      (FRCLEN),A  ;FRAC LENGTH
          EX      AF,AF'      
          LD      D,0         
          CP      '#'         
          JP      Z,PFLENG    
          CP      2AH         ;[*]
          JP      Z,ASTRSK    
          CALL    QMONEY      
          JP      Z,YENUSG    
          CP      '.'         
          JP      Z,PULSLS    
          CP      '+'         
          JP      Z,PLUSUS    
          JP      ER04        

ASTRSK:   LD      A,1         
          LD      (PUASTF),A  
          INC     HL          
          INC     D           
          INC     HL          
          INC     D           
          LD      A,(HL)      
          CALL    QMONEY      
          JR      NZ,PULSLS   
          JR      YENUS2      

YENUSG:   INC     HL          
          INC     D           
YENUS2:   INC     HL          
          INC     D           
          LD      (PUYENF),A  
          JR      PULSLS      

PLUSUS:   LD      A,1         
          LD      (FPLUSF),A  

PFLENG:   INC     HL          
          INC     D           

PULSLS:   EX      DE,HL       
          DEC     H           
PUGTFC:   INC     H           
          LD      A,(DE)      
          INC     DE          
          CP      '#'         
          JR      Z,PUGTFC    
          CP      ','         
          JR      NZ,PUCONP   
          LD      A,1         
          LD      (PUCOMF),A  
          JR      PUGTFC      

PUCONP:   CP      '.'         
          JR      Z,PUPOIT    
          CP      '-'         
          JR      NZ,PUAFMO   
          LD      A,1         
          LD      (PUAFMF),A  
          INC     DE          
          JR      PUAFQO      

PUAFMO:   CP      '+'         
          JR      NZ,PUAFQO   
          LD      A,(FPLUSF)  
          OR      A           
          JR      NZ,PUAFQO   
          LD      A,1         
          LD      (RPLUSF),A  
          INC     DE          
PUAFQO:   DEC     DE          
          LD      A,H         
          LD      (INTLEN),A  
          JR      BEGUSG      

PUPOIT:   LD      A,H         
          LD      (INTLEN),A  
          LD      H,0FFH      
PUPOFC:   INC     H           
          LD      A,(DE)      
          INC     DE          
          CP      '#'         
          JR      Z,PUPOFC    
          CP      '-'         
          JR      NZ,PUCOPQ   
          LD      A,1         
          LD      (PUAFMF),A  
          INC     DE          
          JR      PUCOPP      

PUCOPQ:   CP      '+'         
          JR      NZ,PUCOPP   
          LD      A,(FPLUSF)  
          OR      A           
          JR      NZ,PUCOPP   
          LD      A,1         
          LD      (RPLUSF),A  
          INC     DE          
PUCOPP:   DEC     DE          
          LD      A,H         
          LD      (FRCLEN),A  
          JR      BEGUSG      

NEXPP0:   POP     DE          
          JR      NEXPPU      

BEGUSG:   LD      H,4         
          PUSH    DE          
CHEXPU:   LD      A,(DE)      
          INC     DE          
          CP      '^'         
          JR      NZ,NEXPP0   
          DEC     H           
          JR      NZ,CHEXPU   
          POP     AF          
          LD      A,1         
          LD      (PUEXPF),A  
NEXPPU:   POP     HL          
          PUSH    DE          
          INC     HL          
          LD      A,(HL)      
          RES     7,(HL)      
          DEC     HL          
          LD      (USGSGN),A  
          LD      A,(INTLEN)  
          LD      D,A         
          DB      3EH         
FRCLEN:   DB      0           ;(was DEFS 1)
          LD      E,A         
          DB      3EH         
PUEXPF:   DB      0           ;(was DEFS 1)
          PUSH    BC          
          CALL    USNGCV      
          POP     BC          
          DB      3EH         
PUCOMF:   DB      0           ;(was DEFS 1)
          OR      A           
          JR      Z,LADJS1    
          PUSH    BC          
          PUSH    DE          
          LD      A,(INTLEN)  
          LD      L,A         
          LD      H,0         
          ADD     HL,DE       
          LD      DE,DGBF00   
          LD      C,0         
          DEC     HL          
COMN3D:   LD      B,3         
COMSK3:   LD      A,(HL)      
          CP      20H         
          JR      Z,ESCPUC    
          INC     C           
          LD      (DE),A      
          INC     DE          
          DEC     HL          
          DJNZ    COMSK3      
          LD      A,(HL)      
          CP      20H         
          JR      Z,ESCPUC    
          LD      A,','       
          LD      (DE),A      
          INC     DE          
          INC     C           
          JR      COMN3D      

ESCPUC:   DB      3EH         
INTLEN:   DB      0           ;(was DEFS 1)
          CP      C           
          JP      C,ER02      
          LD      B,C         
          LD      L,A         
          LD      H,0         
          POP     DE          
          PUSH    DE          
          ADD     HL,DE       
          LD      DE,DGBF00   
          DEC     HL          
INTLN2:   LD      A,(DE)      
          LD      (HL),A      
          DEC     HL          
          INC     DE          
          DJNZ    INTLN2      
          POP     DE          
          POP     BC          
LADJS1:   DB      3EH         
PUAFMF:   DB      0           ;(was DEFS 1)
          OR      A           
          JR      NZ,LADJS2   
          DB      3EH         
RPLUSF:   DB      0           ;(was DEFS 1)
          OR      A           
          JR      NZ,LADJS2   
          DB      3EH         
FPLUSF:   DB      0           ;(was DEFS 1)
          OR      A           
          JR      NZ,PTPLS1   
          LD      A,(USGSGN)  
          RLCA    
          JR      NC,LADJS2   
          LD      A,(DE)      
          CP      20H         
          LD      H,'-'       
          JR      Z,FPUTER    
          CP      30H         
          JP      NZ,ER02     
FPUTER:   PUSH    DE          
PUPTML:   LD      A,(DE)      
          INC     DE          
          CP      20H         
          JR      Z,PUPTML    
          CP      30H         
          JR      Z,PUPTML    
          OR      A           
          JR      NZ,LADJ11   
          DEC     DE          
LADJ11:   DEC     DE          
          DEC     DE          
          LD      A,H         
          LD      (DE),A      
          POP     DE          
          JR      LADJS2      

PTPLS1:   DB      3EH         
USGSGN:   DB      0           ;(was DEFS 1)
          RLCA    
          LD      H,'+'       
          JR      NC,FPUTER   
          LD      H,'-'       
          JR      FPUTER      

LADJS2:   DB      3EH         
PUYENF:   DB      0           ;(was DEFS 1)
          OR      A           
          JR      Z,LADJS3    
          LD      A,(DE)      
          CP      20H         
          JR      NZ,LADJS3   
          PUSH    DE          
LADJ22:   LD      A,(DE)      
          INC     DE          
          CP      20H         
          JR      Z,LADJ22    
          DEC     DE          
          DEC     DE          
          LD      A,(PUYENF)  
          LD      (DE),A      
          POP     DE          
LADJS3:   DB      3EH         
PUASTF:   DB      0           ;(was DEFS 1)
          OR      A           
          JR      Z,LADJS4    
          PUSH    DE          
ASTFIL:   LD      A,(DE)      
          CP      20H         
          JR      NZ,LADJ3    
          LD      A,2AH       ;[*]
          LD      (DE),A      
          INC     DE          
          JR      ASTFIL      
LADJ3:    POP     DE          
LADJS4:   LD      A,(DE)      
          OR      A           
          JR      Z,USPRL8    
          LD      (BC),A      
          INC     BC          
          INC     DE          
          JR      LADJS4      
USPRL8:   LD      A,(RPLUSF)  
          OR      A           
          JR      Z,TST2DH    ;-
          LD      A,(USGSGN)  
          RLCA    
          LD      A,'+'       
LSDVZR:   JR      NC,PULSTX   
          LD      A,'-'       
PULSTX:   LD      (BC),A      
          INC     BC          
          JR      RETPU$      

TST2DH:   LD      A,(PUAFMF)  ;-
          OR      A           
          JR      Z,RETPU$    
          LD      A,(USGSGN)  
          RLCA    
          LD      A,20H       
          JR      LSDVZR      

RETPU$:   POP     HL          
          JP      AFTPRT      

;*---------------------------------------
;*Top of p.510 in German Listing of 2Z046
;*---------------------------------------
QMONEY:   CP      CHUKP       ; Sharp ASCII code for 'ú' sign
          RET     Z           
          CP      '$'         ; Sharp ASCII code for U.S. Dollar Sign
          RET     

USNGCV:   OR      A           
          JP      Z,USGCV2    
          PUSH    DE          
          LD      A,(HL)      
          OR      A           
          JR      Z,USCMOK    
          PUSH    HL          
          LD      A,D         
          LD      DE,ZFAC1    
          PUSH    AF          
          CALL    LDIR1       
          POP     AF          
          OR      A           
          JR      Z,BMULED    
          LD      B,A         
          LD      HL,ZFAC1    
          JR      USNEXT      

USLOOP:   CALL    MULTEN      
USNEXT:   DJNZ    USLOOP      
BMULED:   POP     HL          
          LD      B,0         
USTNCM:   LD      DE,ZFAC1    
          CALL    CMP2        
          JR      C,USTOCM    
          CALL    DIVTEN      
          INC     B           
          JR      USTNCM      
USTOCM:   PUSH    HL          
          LD      HL,ZFAC1    
          CALL    DIVTEN      
          POP     HL          
USONCM:   LD      DE,ZFAC1    
          CALL    CMP2        
          JR      NC,USCMOK   
          CALL    MULTEN      
          DEC     B           
          JR      USONCM      
USCMOK:   POP     DE          
          PUSH    BC          
          CALL    USGCV1      
          POP     BC          
          PUSH    DE          
          LD      A,(DE)      
          CP      '.'         
          JR      NZ,FLADSR   
          LD      DE,DGBF16   
          DEC     DE          
          LD      A,(DE)      
          CP      31H         
          POP     DE          
          PUSH    DE          
          JR      NZ,USEX0C   
          EX      DE,HL       
          INC     HL          
          LD      (HL),31H    
          DEC     HL          
          JR      MIDDCX      

FLADSR:   LD      A,(DE)      
          CP      31H         
          JR      NZ,USEX0C   
          EX      DE,HL       
          INC     HL          
          LD      A,(HL)      
          DEC     HL          
          CP      '.'         
          LD      A,'0'       
          JR      Z,FLAD22    
          LD      A,20H       
FLAD22:   LD      (HL),A      
FLAD33:   INC     HL          
          LD      A,(HL)      
          CP      '.'         
          JR      Z,FLAD33    
          LD      (HL),31H    
MIDDCX:   EX      DE,HL       
          INC     B           
USEX0C:   LD      A,(DE)      
          INC     DE          
          OR      A           
          JR      NZ,USEX0C   
          DEC     DE          
          JP      USEXPE      

USGCV2:   PUSH    DE          
          CALL    USGCV1      
          POP     AF          
          OR      A           
          RET     NZ          
          PUSH    HL          
          LD      HL,DGBF16   
          DEC     HL          
          LD      A,'0'       
          CP      (HL)        
FOVVXC:   JP      NZ,ER02     
          DEC     HL          
          LD      A,20H       
          CP      (HL)        
          JR      NZ,FOVVXC   
          POP     HL          
          RET     

USGCV1:   PUSH    DE          
          CALL    CVASF1      
          JP      C,ER02      
          POP     HL          
          PUSH    HL          
          LD      H,0         
          INC     L           
          JR      Z,USGCV3    
          DEC     L           
USGCV3:   LD      DE,DGBF17   
          ADD     HL,DE       
          LD      A,(HL)      
          LD      (HL),0      
          DB      11H         
FRCASU:   LD      (HL),'0'    
          CP      35H         
          JR      C,BCKSEU    
USGCV4:   DEC     HL          
          LD      A,(HL)      
          CP      '.'         
          JR      Z,USGCV4    
          INC     A           
          JP      Z,ER02      
          LD      (HL),A      
          CP      ':'         
          JR      Z,FRCASU    
BCKSEU:   LD      HL,KEYBM1   ;∆∆KEYBUF
          LD      DE,2000H    
USGCV5:   LD      (HL),D      
          INC     HL          
          DEC     E           
          JR      NZ,USGCV5   
          POP     HL          
          PUSH    HL          
          LD      E,H         
          LD      D,0         
          LD      HL,KEYBUF   
          ADD     HL,DE       
          PUSH    HL          
          LD      HL,DGBF07   
          LD      (HL),20H    
          INC     HL          
          LD      D,7         
BF00SP:   LD      A,(HL)      
          CP      30H         
          JR      NZ,BF00ED   
          LD      (HL),20H    
          INC     HL          
          DEC     D           
          JR      NZ,BF00SP   
BF00ED:   POP     HL          
          PUSH    HL          
          LD      B,E         
          LD      A,B         
          OR      A           
          JR      Z,BFST11    
          LD      DE,DGBF16   
BFSTL1:   DEC     HL          
          DEC     DE          
          LD      A,(DE)      
          LD      (HL),A      
          CP      20H         
          JR      Z,BFST11    
          DJNZ    BFSTL1      
          DEC     DE          
          LD      A,(DE)      
          CP      20H         
          JR      Z,BFST11    
          INC     A           
          JP      NZ,ER02     
BFST11:   POP     HL          
          POP     DE          
          INC     E           
          JR      Z,EDSTRT    
          LD      B,E         
          LD      DE,DGBF17   
          LD      (HL),'.'    
BFSTL2:   INC     HL          
          DEC     B           
          JR      Z,EDSTRT    
          LD      A,(DE)      
          INC     DE          
          LD      (HL),A      
          JR      BFSTL2      
EDSTRT:   LD      (HL),0      
          LD      DE,KEYBUF   
          RET     

;*       END of original module CONV.ASM
;*===========================================================================
;*     START of original module EDIT.ASM
;*-------------------------------------
;* MZ-800 BASIC  Interm.code conversion
;* FI:EDIT  ver 1.0A 7.18.84
;* Programmed by T.Miho
;*-------------------------------------

CVIMTX:   PUSH    DE          
          PUSH    BC          
          LD      C,0         
          DEC     DE          
CVIM10:   INC     DE          
CVIM12:   CALL    IMSPACE     
          OR      A           
          JR      Z,IMEND     
          CP      0FFH        
          JR      Z,IMPAI     
          CP      80H         
          JP      NC,ER01     
          CP      20H         
          JR      C,CVIM10    
          LD      IX,CVIM12   
          PUSH    IX          
          CP      '"'         
          JR      Z,IMSTR     
          CP      27H         
          JR      Z,IMREM     
          CP      '?'         
          JR      Z,IMPRT     
          CP      '.'         
          JP      Z,IMFLT     
          CP      '$'         
          JP      Z,IMHEX     
          CALL    TSTNUM      
          JR      C,IMRSV     
          JP      IMNUM       

IMEND:    LD      (HL),A      
          POP     BC          
          POP     DE          
          RET     

IMPAI:    LD      (HL),0E4H   
          CALL    IM3R        
          JR      CVIM12      

IMPRT:    LD      A,8FH       
          CALL    IM3RS       
          JR      IMRSV6      

IMREM:    LD      (HL),':'    
          CALL    IM3R        
          LD      (HL),27H    
          CALL    IM3RH       
          JP      IMDATA      

IMSTR:    LD      (HL),A      
          CALL    IM3R        
IMSTR2:   LD      A,(DE)      
          OR      A           
          RET     Z           
          CP      '"'         
          JR      NZ,IMSTR    
IM3RS:    LD      (HL),A      
IM3R:     INC     DE          
IM3RH:    INC     HL          
IM3RC:    INC     C           
          RET     NZ          
          JP      ER08        ;LINE LENGTH

IMVAR:    POP     BC          
          LD      A,(DE)      
          CALL    TSTVAR      
          JR      C,IM3RS     
IMVAR2:   CALL    IM3RS       
          LD      A,(DE)      
          CP      '$'         
          JR      Z,IM3RS     
          CALL    TSTNUM      
          RET     C           
          JR      IMVAR2      

IMRSV:    PUSH    BC          
          LD      BC,CTBL1    
          CALL    IMSER       
          JR      NC,IMRSV4   
          LD      BC,GTABL    
          CALL    IMSER       
          LD      C,0FEH      
          JR      NC,IMRSV2   
          LD      BC,CTBL2    
          CALL    IMSER       
          LD      C,0FFH      
          JR      C,IMVAR     
IMRSV2:   LD      (HL),C      
          INC     HL          
          LD      (HL),A      
          POP     BC          
          CALL    IM3RC       
          CALL    IM3RH       
          CP      0B4H        ; ERL ******
          RET     NZ          
          CALL    IMSPACE     
          CP      '='         
          RET     NZ          
          LD      (HL),0F4H   ; = ******
          CALL    IM3R        
          JR      IMLNO       

IMRSV4:   POP     BC          
          CALL    IM3RH       
IMRSV6:   CP      97H         ; REM
          JR      Z,IMDATA    
          CP      94H         ; DATA
          JR      Z,IMDATA    
          CP      0C2H        ; ELSE
          JR      Z,IMELSE    
          CP      0E2H        ; THEN
          JR      Z,IMLNO     
          CP      0E0H        
          RET     NC          
          PUSH    AF          
          CALL    IMSPACE     
          CP      '/'         
          JR      NZ,IMRSV7   
          LD      (HL),0FBH   ;/
          CALL    IM3R        
          CALL    SKPDE       
          CALL    IM3RS       
          JR      IMRSV8      

IMRSV7:   CP      '#'         
          JR      NZ,IMRSV8   
          CALL    IM3RS       
          CALL    SKPDE       
          CALL    TSTNUM      
          CALL    NC,IMNUM    
IMRSV8:   POP     AF          
          CP      8DH         ; FOR
          RET     NC          
IMLNO:    CALL    IMSPACE     
          CP      '"'         
          JR      NZ,IMLNO2   
          CALL    IMSTR       
          JR      IMLNO       
IMLNO2:   CP      2CH         
          RET     C           
          CP      2FH         
          JR      C,IMLNO4    ;",-."
          CALL    TSTNUM      
          RET     C           
          CALL    IMINT       
          JR      IMLNO       
IMLNO4:   CALL    IM3RS       
          JR      IMLNO       

IMELSE:   DEC     HL          
          LD      (HL),':'    
          INC     HL          
          LD      (HL),A      
          CALL    IM3RH       
          JR      IMLNO       

IMDATA:   LD      A,(DE)      
          CALL    ENDCK0      
          RET     Z           
          CALL    IM3RS       
          CP      '"'         
          CALL    Z,IMSTR2    
          JR      IMDATA      

IMSER:    PUSH    HL          ;Search in tabale
          PUSH    DE          
          LD      H,B         
          LD      L,C         
          LD      B,7FH       
IMSER2:   POP     DE          
          PUSH    DE          
          INC     B           
          LD      A,(HL)      
          CP      0FFH        
          JR      NZ,IMSER3   
          POP     DE          ;Table end
          POP     HL          
          SCF     
          RET     

IMSER3:   CP      '.'         
          JR      NZ,IMSER4   
          INC     HL          ;AND OR XOR NOT
          DEC     DE          
          LD      A,(DE)      
          INC     DE          
          CALL    TSTVAR      
          JR      NC,IMSER6   
IMSER4:   LD      A,(DE)      
          CP      20H         
          JR      NZ,IMSER5   
          LD      A,(HL)      
          AND     7FH         
          SUB     'A'         
          CP      26          
          JR      C,IMSER6    
          CALL    SKPDI       
IMSER5:   LD      C,(HL)      
          INC     HL          
          INC     DE          
          CP      '.'         
          JR      Z,IMSER8    
          SUB     C           
          JR      Z,IMSER4    
          CP      80H         
          JR      Z,IMSER9    
IMSER6:   DEC     HL          ;Not match
IMSER7:   BIT     7,(HL)      
          INC     HL          
          JR      Z,IMSER7    
          JR      IMSER2      

IMSER8:   LD      A,B         
          CP      0E8H        ;operator
          JR      NC,IMSER6   
          CCF     
IMSER9:   POP     HL          ;Found
          POP     HL          
          LD      (HL),B      
          LD      A,B         
          RET     

IMSPACE:  LD      A,(DE)
          CP      20H         
          RET     NZ          
          LD      (HL),A      
          CALL    IM3R        
          JR      IMSPACE     

IMNUM:    EX      AF,AF'      
          PUSH    DE          
          CALL    SKPDI       
          POP     DE          
          CALL    TSTNUM      ;check if one-digit
          JR      NC,IMFLT    
          CP      '.'         
          JR      Z,IMFLT     
          CP      'E'         
          JR      Z,IMFLT     
          EX      AF,AF'      
          SUB     30H-1       
          JP      IMFLT       ;ok, JP IM3RS

IMFLT:    PUSH    BC          
          LD      (HL),15H    
          INC     HL          
          PUSH    HL          
          CALL    CVFLAS      
          POP     HL          
          LD      BC,5        
          ADD     HL,BC       
          LD      A,6         
          JR      BCKSPS      

IMINT:    PUSH    BC          
          CALL    CVBCAS      
          LD      (HL),0BH    
          INC     HL          
          JR      PPOLNO      

IMHEX:    LD      (HL),A      
          INC     DE          
          LD      A,(DE)      
          RST     18H         
          DB      .CKHEX      
          JP      C,IM3RH     
          PUSH    BC          
          LD      (HL),11H    
          INC     HL          
          PUSH    HL          
          EX      DE,HL       
          RST     18H         
          DB      .DEHEX      
          LD      B,D         
          LD      C,E         
          EX      DE,HL       
          POP     HL          
PPOLNO:   LD      A,3         
          LD      (HL),C      
          INC     HL          
          LD      (HL),B      
          INC     HL          
BCKSPS:   POP     BC          
          ADD     A,C         
          JP      C,ER08      ;LINE LENGTH
          LD      C,A         
BCKSKP:   DEC     DE          
          LD      A,(DE)      
          CP      20H         
          JR      Z,BCKSKP    
          INC     DE          
          RET     

CVTXIM:   PUSH    HL          
          PUSH    DE          
          PUSH    BC          
          EXX     
          LD      B,0         
          EXX     
          LD      C,0         
CVTX10:   LD      A,(HL)      
          OR      A           
          JR      Z,TXEND     
          LD      BC,CVTX10   
          PUSH    BC          
          CP      27H         
          JR      Z,TXDAT2    
          INC     HL          
          LD      BC,CTBL1    
          CP      20H         
          JR      C,TXNUM     
          CP      '"'         
          JR      Z,TXSTR     
          CP      ':'         
          JR      Z,TX3AH     
          CP      97H         ;REM
          JR      Z,TXDATA    
          CP      94H         ;DATA
          JR      Z,TXDATA    
          CP      0E4H        ;PI
          JR      Z,TXPAI     
          CP      0FEH        
          JR      NC,TXRSV0   
          CP      80H         
          JP      NC,TXRSV    
          JP      STRDE       

TXEND:    LD      (DE),A      
          POP     BC          
          POP     DE          
          POP     HL          
          RET     

TXPAI:    LD      A,0FFH      
          JP      STRDE       

TXRSV0:   LD      BC,CTBL2    
          JR      NZ,TXRSV1   
          LD      BC,GTABL    
TXRSV1:   LD      A,(HL)      
          INC     HL          
          JR      TXRSV       

TXDATA:   CALL    TXRSV       
          RET     Z           
TXDAT2:   LD      A,(HL)      
          CALL    ENDCK0      
          RET     Z           
          CALL    STRDE       
          LD      A,(HL)      
          INC     HL          
          CP      '"'         
          CALL    Z,TXSTR2    
          JR      TXDAT2      

TXSTR:    CALL    STRDE       
TXSTR2:   LD      A,(HL)      
          OR      A           
          RET     Z           
          INC     HL          
          CP      '"'         
          JR      NZ,TXSTR    
          JR      STRDE       

TX3AH:    LD      (DE),A      
          LD      A,(HL)      
          CP      0C2H        ; ELSE
          RET     Z           
          CP      27H         
          RET     Z           
          JR      STRDE2      

TXNUM:    CP      15H         
          JR      Z,TXFLT     
          CP      0BH         
          JR      NC,TXINT    
          DEC     A           
          OR      30H         
          JR      STRDE       

TXINT:    PUSH    DE          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          INC     HL          
          PUSH    HL          
          CP      12H         
          JR      Z,TXINT2    
          CP      0CH         
          JR      C,TXINT2    
          JR      NZ,TXHEX    
          EX      DE,HL       
          INC     HL          
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
TXINT2:   EX      DE,HL       
          CALL    ASCFIV      
          LD      B,D         
          LD      C,E         
          POP     HL          
          POP     DE          
TXINT4:   LD      A,(BC)      
          OR      A           
          RET     Z           
          CALL    STRDE       
          INC     BC          
          JR      TXINT4      

TXFLT:    PUSH    HL          
          PUSH    DE          
          CALL    CVASFL      
          LD      B,D         
          LD      C,E         
          POP     DE          
          POP     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          JR      TXINT4      

TXRSV:    CP      80H         
          JR      Z,TXRSV4    
          EX      AF,AF'      
TXRSV2:   LD      A,(BC)      
          RLCA    
          INC     BC          
          JR      NC,TXRSV2   
          EX      AF,AF'      
          DEC     A           
          JR      TXRSV       
TXRSV4:   LD      A,(BC)      
          BIT     7,A         
          JR      NZ,STRDES   
          CP      '.'         
          CALL    NZ,STRDE    
          INC     BC          
          JR      TXRSV4      

STRDES:   AND     7FH         
STRDE:    LD      (DE),A      
          OR      A           
          RET     Z           
STRDE2:   INC     DE          
          EXX     
          INC     B           
          EXX     
          RET     NZ          
          XOR     A           
          LD      (DE),A      
          DEC     DE          
          EXX     
          DEC     B           
          EXX     
          RET     

TXHEX:    LD      A,'$'       
          EX      AF,AF'      
          EX      DE,HL       
          CALL    HEXHL       
          LD      B,D         
          LD      C,E         
          POP     HL          
          POP     DE          
          EX      AF,AF'      
          CALL    STRDE       
          JR      TXINT4      

HEXHL:    LD      DE,DGBF12   
          PUSH    DE          
          LD      A,H         
          CALL    HEXACC      
          LD      A,L         
          CALL    HEXACC      
          XOR     A           
          LD      (DE),A      
          POP     DE          
          LD      B,3         

ZRSUP:    LD      A,(DE)      
          CP      '0'         
          RET     NZ          
          INC     DE          
          DJNZ    ZRSUP       
          RET     

;*-------------------------------------------
;* Middle of p.530 in German Listing of 2Z046
;* Convert Byte in A to 2-hex at DE
;*-------------------------------------------
HEXACC:   PUSH    AF          
          RRCA    
          RRCA    
          RRCA    
          RRCA    
          AND     0FH         
          CALL    HEXAC2      
          POP     AF          
          AND     0FH         
HEXAC2:   ADD     A,30H       
          CP      3AH         
          JR      C,HEXAC3    
          ADD     A,7         
HEXAC3:   LD      (DE),A      
          INC     DE          
          RET     

CVBCAS:   PUSH    HL          
          EX      DE,HL       
          RST     18H         
          DB      .DEASC      
          LD      B,D         
          LD      C,E         
          EX      DE,HL       
          POP     HL          
          JP      BCKSKP      

;*       END of original module EDIT.ASM
;*============================================================================
;*     START of original module EXPR.ASM     
;*------------------------------
;* MZ-800 BASIC  Expression part
;* FI:EXPR  ver 1.0A 8.25.84
;* Programmed by T.Miho
;*------------------------------

IBYTE:    CALL    IDEEXP      ;0-255
DCHECK:   LD      A,D         
          OR      A           
          JP      NZ,ER03     
          LD      A,E         
          RET     

DEEXP:    CALL    EXPR8       
          DEC     DE          
          DEC     DE          
          DEC     DE          
          DEC     DE          
          DEC     DE          
          JR      STDEFC      

IDEEXP:   CALL    EXPR        ;DE=(HL)
STDEFC:   PUSH    AF          
          PUSH    HL          
          EX      DE,HL       
          CALL    STROMT      
          CALL    HLFLT       
          EX      DE,HL       
          POP     HL          
          POP     AF          
          RET     

STREXP:   CALL    EXPR        
          PUSH    AF          
          CALL    STROK       
          PUSH    HL          
          EX      DE,HL       
          CALL    CVTSDC      
          POP     HL          
          POP     AF          
          RET     

CVTSDC:   LD      B,(HL)      
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      HL,(STRST)  
          ADD     HL,DE       
          EX      DE,HL       
          LD      A,B         
          RET     

EXPR:     LD      DE,(VARED)  
          LD      (TMPEND),DE 
EXPRNX:   LD      DE,(INTFAC) 
          PUSH    DE          
          CALL    EXPR8       
          POP     DE          
          RET     

EXPR8:    PUSH    DE          
          LD      DE,(TMPEND) 
          CALL    MEMECK      
          POP     DE          

EXPR7:    CALL    EXPR6       
EXPR7L:   CP      0EAH        ;XOR
          RET     NZ          
          LD      A,(PRCSON)  
          PUSH    AF          
          INC     HL          
          CALL    EXPR6       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    .XOR.       
          POP     HL          
          POP     AF          
          JR      EXPR7L      

EXPR6:    CALL    EXPR5       
EXPR6L:   CP      0EBH        ;OR
          RET     NZ          
          LD      A,(PRCSON)  
          PUSH    AF          
          INC     HL          
          CALL    EXPR5       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    .OR.        
          POP     HL          
          POP     AF          
          JR      EXPR6L      

EXPR5:    CALL    EXPR4       
EXPR5L:   CP      0ECH        ;AND
          RET     NZ          
          LD      A,(PRCSON)  
          PUSH    AF          
          INC     HL          
          CALL    EXPR4       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    .AND.       
          POP     HL          
          POP     AF          
          JR      EXPR5L      

EXPR4:    CALL    TEST1       ;NOT
          DB      0EDH        
          JR      NZ,EXPR3    
          CALL    EXPR3       
          PUSH    AF          
          PUSH    HL          
          LD      HL,-5       
          ADD     HL,DE       
          CALL    .NOT.       
          POP     HL          
          POP     AF          
          RET     

EXPR3:    CALL    EXPR2       
EXPR3L:   CP      0EEH        ;><
          RET     C           
          PUSH    AF          ;stk OPC
          LD      A,(PRCSON)  
          PUSH    AF          ;stk OPC, PRCSON
          INC     HL          
          CALL    EXPR2       
          POP     BC          ;stk OPC*      B=PRCSON
          EX      (SP),HL     ;stk RJOB*     HL=OPC
          PUSH    AF          ;stk RJOB,NEXT
          PUSH    HL          ;stk RJOB,NEXT,OPC
          CALL    ADJUST      
          CALL    CMP         
          EX      AF,AF'      ;AF' = result
          POP     AF          ;stk RJOB,NEXT; A=OPC
          CP      0F6H        ;<
          JR      NZ,NXTCP1   
          EX      AF,AF'      
          JR      C,TRUE      
FALSE:    LD      BC,0        
RLBACK:   LD      (HL),C      
          INC     HL          
          LD      (HL),B      
          INC     HL          
          XOR     A           
          LD      (HL),A      
          INC     HL          
          LD      (HL),A      
          INC     HL          
          LD      (HL),A      
          LD      A,5         
          LD      (PRCSON),A  
          POP     AF          ;POP NEXT
          POP     HL          ;POP RJOB
          JR      EXPR3L      

TRUE:     LD      BC,8081H    
          JR      RLBACK      

NXTCP1:   CP      0F5H        ;>
          JR      NZ,NXTCP2   
          EX      AF,AF'      
          JR      Z,FALSE     
          JR      C,FALSE     
          JR      TRUE        

NXTCP2:   CP      0F4H        ;=
          JR      NZ,NXTCP3   
          EX      AF,AF'      
          JR      Z,TRUE      
          JR      FALSE       

NXTCP3:   CP      0F2H        ;=>,>=
          JR      C,NXTCP4    
          EX      AF,AF'      
          JR      NC,TRUE     
          JR      FALSE       

NXTCP4:   CP      0F0H        ;=<,<=
          JR      C,NXTCP5    
          EX      AF,AF'      
          JR      Z,TRUE      
          JR      C,TRUE      
          JR      FALSE       

NXTCP5:   EX      AF,AF'      ;<>,><
          JR      Z,FALSE     
          JR      TRUE        

EXPR2:    CALL    EXPR1       
EXPR2L:   CP      0F7H        ;+,-
          RET     C           
          LD      A,(PRCSON)  
          PUSH    AF          
          INC     HL          
          JR      Z,EXPR2A    ;+
          CALL    EXPR1       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    SUBCMD         
EXPR2X:   POP     HL          
          POP     AF          
          JR      EXPR2L      

EXPR2A:   CALL    EXPR1       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    ADDCMD         
          JR      EXPR2X      

EXPR1:    CALL    EXPR0       
EXPR1L:   CP      0F9H        ;MOD, YEN
          RET     C           
          LD      A,(PRCSON)  
          PUSH    AF          
          INC     HL          
          JR      Z,EXPR1A    ;YEN
          CALL    EXPR0       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    MOD         
EXPR1X:   POP     HL          
          POP     AF          
          JR      EXPR1L      

EXPR1A:   CALL    EXPR0       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    YEN         
          JR      EXPR1X      

EXPR0:    CALL    EXPRZ       
EXPR0L:   CP      0FBH        ;/,*
          RET     C           
          LD      A,(PRCSON)  
          PUSH    AF          
          INC     HL          
          JR      Z,EXPR0A    ;/
          CALL    EXPRZ       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    MUL         
EXPR0X:   POP     HL          
          POP     AF          
          JR      EXPR0L      
EXPR0A:   CALL    EXPRZ       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      
          CALL    DIV         
          JR      EXPR0X      

EXPRZ:    CALL    TEST1       ;+
          DB      0F7H        
          JR      Z,EXPRZ     
          CP      0F8H        ;-
          JR      NZ,EXPRY    
          INC     HL          
          CALL    EXPRY       
          JR      EXPRX2      

EXPRY:    CALL    FACTOR      
EXPRYL:   CP      0FDH        ;^
          RET     NZ          
          LD      A,(PRCSON)  
          PUSH    AF          
          INC     HL          
          CALL    EXPRX       
          POP     BC          
          PUSH    AF          
          PUSH    HL          
          CALL    ADJUST      ;
          CALL    POWERS      ;(HL)^(DE)
          POP     HL          
          POP     AF          
          JR      EXPRYL      

EXPRX:    CALL    TEST1       ;+
          DB      0F7H        
          JR      Z,EXPRX     
          CP      0F8H        ;-
          JR      NZ,FACTOR   
          INC     HL          
          CALL    FACTOR      
EXPRX2:   PUSH    AF          
          PUSH    HL          
          LD      HL,-5       
          ADD     HL,DE       
          CALL    NEGCMD         
          POP     HL          
          POP     AF          
          RET     

FACTOR:   CALL    ENDCHK      
          JP      Z,ER01      
          CALL    FAC0        
          JP      HLFTCH      

FAC0:     PUSH    HL          
          LD      HL,(MEMLMT) 
          SCF     
          SBC     HL,DE       
          JP      C,ER06      ;TOO COMPLEX EXPR
          POP     HL          
          CP      0E4H        ;PI
          JR      Z,FACPAI    
          CP      20H         
          JR      NC,VARFNC   ;IM 20 ....

FACNUM:   INC     HL          ;factor(numeric)
          CP      15H         
          JR      C,FACINT    
          CALL    LDIR5       ;IM 15
          JR      FACR5       

FACPAI:   INC     HL          
          PUSH    HL          
          LD      HL,FLTPAI   
          CALL    LDIR5       
          POP     HL          
FACR5:    LD      A,5         
FACRX:    LD      (PRCSON),A  
          RET     

FACINT:   CP      0BH         ;IM 00 .. 14
          JR      NC,FACI4    
          DEC     A           
          JP      M,ER01      ;IM 00
          LD      B,0         
          LD      C,A         
          JR      FACI6       

FACI4:    LD      C,(HL)      ;IM 0B .. 14
          INC     HL          
          LD      B,(HL)      
          INC     HL          
          CP      0CH         
          JR      NZ,FACI6    
          INC     BC          
          INC     BC          
          LD      A,(BC)      
          INC     BC          
          EX      AF,AF'      
          LD      A,(BC)      
          LD      B,A         
          EX      AF,AF'      
          LD      C,A         
FACI6:    PUSH    HL          
          PUSH    DE          
          EX      DE,HL       
          LD      E,C         
          LD      D,B         
          CALL    FLTHEX      
          POP     DE          
          POP     HL          
          LD      A,5         
FACRX5:   INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          JR      FACRX       

VARFNC:   CP      '"'         
          JR      NZ,VARFN1   
          INC     HL          
          PUSH    HL          
          CALL    STRLCK      ;B=len(HL str.)
          EX      (SP),HL     ;New text point
          PUSH    HL          ;Old text point
          LD      HL,(TMPEND) 
          PUSH    BC          
          LD      BC,(STRST)  
          OR      A           
          SBC     HL,BC       ;HL=OFSET+ADR
          POP     BC          
          EX      DE,HL       
          LD      (HL),B      ;FAC set len.
          INC     HL          
          LD      (HL),E      ;FAC set adrs
          INC     HL          
          LD      (HL),D      
          INC     HL          
          INC     HL          
          INC     HL          
          POP     DE          ;Old text point
          PUSH    HL          ;New expr point
          LD      HL,(TMPEND) 
          CALL    STRENT      ;(HL)_(DE),B
          LD      (TMPEND),HL 
          POP     DE          ;New expr point
          POP     HL          ;New text point
          LD      A,3         
          LD      (PRCSON),A  
          RET     

VARFN1:   CP      '('         
          JR      NZ,FUNC     
          INC     HL          ;( ... )
          CALL    EXPR8       
          JP      CH29H       

FUNC:     OR      A           ;Function
          JP      P,VARFN2    
          CP      0E7H        ;SPC ==>
          INC     HL          
          JR      NZ,FUNC1    
          LD      B,5         ;param is numeric
          LD      A,0A8H      ;   SPACE$
          PUSH    AF          
          JR      FUNC2       

FUNC1:    CP      0FFH        
          JP      NZ,ER01     
          LD      A,(HL)      
          INC     HL          
          CP      0A0H        
          JP      Z,CHR$OP    ;CHR$
          CP      0C8H        
          JP      NC,ER01     
          CP      0BAH        
          JR      NC,GETJPA   ;complex
          CP      9CH         ;JOY STICK
          JR      Z,GETJPA    
          CP      9DH         ;JOY STRIG
          JP      Z,GETJPA    
          PUSH    AF          
          CP      0B3H        
          JR      NC,SYSV     ;system var
          LD      B,3         
          CP      0ABH        
          JR      NC,FUNC2    ;param is string
          LD      B,5         ;param is numeric
          CP      88H         ;RND
          JR      Z,RNDONL    
FUNC2:    CALL    HCH28H      
FUNC4:    PUSH    BC          
          CALL    EXPR8       
          CALL    CH29H       
          POP     AF          
          CALL    STRCK       
FUNC6:    POP     AF          
          PUSH    DE          
          PUSH    HL          
          LD      HL,-5       
          ADD     HL,DE       
          CALL    GETJPA      
          POP     HL          
          POP     DE          
          RET     

RNDONL:   CALL    TEST1       
          DB      '('         
          JR      Z,FUNC4     
SYSV:     LD      A,5         
          LD      (PRCSON),A  
          PUSH    HL          
          LD      HL,FLONE    
          CALL    LDIR5       
          POP     HL          
          JR      FUNC6       

GETJPA:   PUSH    HL          
          ADD     A,A         
          LD      L,A         
          LD      H,0         
          LD      BC,FJPTBL   
          ADD     HL,BC       
          LD      A,(HL)      
          INC     HL          
          LD      H,(HL)      
          LD      L,A         
          EX      (SP),HL     
          RET     

SIZE:     EX      DE,HL       
          LD      HL,-527     
          ADD     HL,SP       
          LD      BC,(TMPEND) 
          OR      A           
          SBC     HL,BC       
          EX      DE,HL       
          JR      NC,PUT2B    
          XOR     A           
          JR      PUT1B       

CSRH:     LD      A,(CURX)    
          JR      PUT1B       

CSRV:     LD      A,(CURY)    
          JR      PUT1B       

POSH:     LD      DE,(POINTX) 
          JR      PUT2B       

POSV:     LD      DE,(POINTY) 
          JR      PUT2B       

ERR:      LD      A,(ERRCOD)  
PUT1B:    LD      E,A         
          LD      D,0         
PUT2B:    LD      A,5         
          LD      (PRCSON),A  
          JP      FLTHEX      

ERL:      LD      DE,(ERRLNO) 
          CALL    FLTHEX      
          INC     HL          
          BIT     7,(HL)      
          DEC     HL          
          RET     Z           
          LD      DE,FL64K    
          JP      ADDCMD         

FL64K:    DW      0091H       ;65536
          DW      0000H       
          DB      00H         

CHR$OP:   CALL    HCH28H      
          LD      B,0         
CHR$LP:   PUSH    BC          ;counter
          PUSH    DE          ;FAC
          CALL    DEEXP       
          CALL    DCHECK      
          POP     DE          ;FAC
          POP     BC          ;counter
          PUSH    AF          ;data
          INC     B           
          CALL    TEST1       
          DB      ','         
          JR      Z,CHR$LP    
          CALL    CH29H       
          LD      A,B         ;length
          EXX     
          LD      B,A         
          LD      HL,(TMPEND) ;string start
          CALL    ADDHLA      
          LD      D,H         
          LD      E,L         ;string end+1
          CALL    MEMECK      
CHR$4:    DEC     HL          
          POP     AF          ;data
          LD      (HL),A      
          DJNZ    CHR$4       
          EXX     
          LD      A,B         ;length
          EXX     
          LD      B,A         
;*----------------
;*HL=String start
;*DE=String end+1
;*B =String length
;*DE'=FAC
;*HL'=TEXT,??
;*----------------
STEXR2:   LD      (TMPEND),DE 
          LD      DE,(STRST)  
          OR      A           
          SBC     HL,DE       
          PUSH    HL          
          LD      A,B         
          EXX     
          EX      DE,HL       
          LD      (HL),A      
          INC     HL          
          POP     BC          
          LD      (HL),C      
          INC     HL          
          LD      (HL),B      
          LD      BC,3        ;
          ADD     HL,BC       
STRPRS:   EX      DE,HL       
          LD      A,3         
          LD      (PRCSON),A  
          RET     

HEX$:     PUSH    HL          
          CALL    HLFLT       
          CALL    HEXHL       
          RST     18H         
          DB      .COUNT      
;*------------------
;* DE:adrs
;* B:length
;* (SP):Text pointer
;*------------------
PUTSTR:   LD      A,B         
          OR      A           
          JR      Z,NULSPC    
          LD      HL,(TMPEND) 
          PUSH    HL          
          PUSH    BC          
          CALL    STRENT      
          POP     BC          
          EX      DE,HL       
          POP     HL          
          EXX     
          POP     DE          
          EXX     
          JR      STEXR2      
NULSPC:   POP     HL          
          CALL    CLRFAC      
          JR      STRPRS      

;*----------------------------------------
;* Top of p.552 in German Listing of 2Z046
;*----------------------------------------
SPACE$:   PUSH    HL          
          CALL    HLINCK      
          LD      B,A         
          LD      C,A         
          OR      A           
          LD      A,20H       
          PUSH    DE          
          CALL    NZ,QSETDE   
          POP     DE          
          LD      B,C         
          JR      PUTSTR      

HLINCK:   CALL    HLFLT       
          LD      DE,KEYBUF   
          LD      A,H         
          OR      A           
          JP      NZ,ER03     
          LD      A,L         
          RET     

STR$:     PUSH    HL          
          CALL    CVNMFL      
          LD      A,(DE)      
          CP      20H         
          JR      NZ,STR1     
          INC     DE          
STR1:     RST     18H         
          DB      .COUNT      
          JR      PUTSTR      

EOF:      CALL    HCH28H      
          CALL    GETLU       
          LD      B,A         
          CALL    HCH29H      
          LD      A,B         
          PUSH    HL          
          PUSH    DE          
          RST     18H         
          DB      .SEGAD      
          LD      DE,-1       
          JR      C,EOF2      
          INC     HL          
          BIT     EOFAA,(HL)  
          JR      NZ,EOF2     
          LD      DE,0        
EOF2:     POP     HL          
          CALL    FLTHEX      
          LD      A,5         
          LD      (PRCSON),A  
EOF8:     INC     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          EX      DE,HL       
          POP     HL          
          RET     

POINT:    CALL    HCH28H      ;POINT command
          PUSH    DE          ;EXPR pointer
          CALL    DEEXP       ;X
          LD      B,D         
          LD      C,E         ;X
          POP     DE          ;EXPR pointer
          PUSH    DE          ;EXPR pointer
          PUSH    BC          ;X
          CALL    CH2CH       
          CALL    DEEXP       ;Y
          CALL    CH29H       
          EX      (SP),HL     ;HL=X
          EX      DE,HL       
          RST     18H         
          DB      .POINT      
          INC     A           
          JP      Z,ER03      ;Out of range
          DEC     A           
          POP     DE          ;TEXT pointer
          POP     HL          ;EXPR pointer
          PUSH    DE          ;TEXT pointer
          CALL    PUT1B       
          JR      EOF8        

ASC:      PUSH    HL          
          CALL    CVTSDC      
          OR      A           
          JR      Z,ASC1      
          LD      A,(DE)      
ASC1:     JR      LEN2        

LEN:      PUSH    HL          
          CALL    CVTSDC      
LEN2:     POP     HL          
          JP      PUT1B       

;*----------------------------------------
;* Top of p.555 in German Listing of 2Z046
;*----------------------------------------
VAL:      PUSH    HL          
          CALL    CVTSDC      
          LD      HL,(TMPEND) 
          PUSH    HL          
          CALL    STRENT      
          LD      (HL),0      
          POP     DE          
          POP     HL          
          JP      CVFLAS      

LEFT$:    CALL    CH28EX      
          CALL    CH29H       
          CALL    BCHECK      
          EX      DE,HL       
          LD      A,(HL)      
          CP      C           
          JR      NC,LEFT1    
          LD      C,A         
LEFT1:    LD      (HL),C      
          LD      BC,5        
FACSTR:   LD      A,3         
          ADD     HL,BC       
          EX      DE,HL       
          LD      (PRCSON),A  
          JP      HLFTCH      

RIGHT$:   CALL    CH28EX      
          CALL    CH29H       
          CALL    BCHECK      
          EX      DE,HL       
          LD      A,(HL)      
          SUB     C           
          JR      NC,MID$EE   
          XOR     A           
          LD      C,(HL)      
MID$EE:   LD      (HL),C      
          INC     HL          
          ADD     A,(HL)      
          LD      (HL),A      
          INC     HL          
          JR      NC,RIGHT1   
          INC     (HL)        
RIGHT1:   LD      BC,3        
          JR      FACSTR      

MID$:     CALL    CH28EX      
          CALL    BCHECK      
          OR      A           
          JP      Z,ER03      
          PUSH    AF          
          CALL    TEST1       
          DB      ')'         
          LD      A,0FFH      
          JR      Z,MID$2     
          CALL    HCH2CH      
          PUSH    DE          
          EX      DE,HL       
          LD      BC,5        
          ADD     HL,BC       
          EX      DE,HL       
          CALL    DEEXP       
          CALL    CH29H       
          CALL    DCHECK      
          POP     DE          
MID$2:    POP     BC          
          LD      C,A         
          EX      DE,HL       
          LD      A,(HL)      
          SUB     B           
          JR      C,MIDNUL    
          INC     A           
          CP      C           
          JR      NC,MIDD3    
          LD      C,A         
MIDD3:    LD      A,B         
          DEC     A           
          JR      MID$EE      

MIDNUL:   XOR     A           
          LD      C,A         
          JR      MID$EE      

BCHECK:   LD      A,B         
          OR      A           
          JP      NZ,ER03     
          LD      A,C         
          RET     

CH28EX:   CALL    HCH28H      
          PUSH    DE          
          CALL    EXPR8       
          CALL    CH2CH       
          CALL    STROK       
          CALL    DEEXP       
          LD      C,E         
          LD      B,D         
          POP     DE          
          RET     

TI$:      PUSH    HL          
          PUSH    DE          
          LD      HL,(TMPEND) 
          PUSH    HL          
          LD      A,'0'       
          LD      B,6         
          CALL    QSETHL      
          RST     18H         ;A,DE
          DB      .TIMRD      
          POP     HL          
          OR      A           
          JR      Z,TI$2      
          INC     (HL)        
          INC     HL          
          INC     (HL)        
          INC     (HL)        
          DEC     HL          
TI$2:     EX      DE,HL       
          LD      BC,8CA0H    ;10H
          CALL    CLDGIT      
          LD      BC,0E10H    ;1H
          CALL    CLDGIT      
          CP      3AH         
          JR      C,TI$4      
          SUB     10          
          DEC     DE          
          LD      (DE),A      
          DEC     DE          
          LD      A,(DE)      
          INC     A           
          LD      (DE),A      
          INC     DE          
          INC     DE          
TI$4:     DEC     DE          
          DEC     DE          
          LD      A,(DE)      
          INC     DE          
          LD      B,A         
          LD      A,(DE)      
          INC     DE          
          LD      C,A         
          LD      A,B         
          CP      32H         
          JR      NZ,TI$6     
          LD      A,C         
          CP      34H         
          JR      NZ,TI$6     
          LD      HL,(TMPEND) 
          LD      A,'0'       
          LD      B,6         
          CALL    QSETHL      
          JR      TI$8        

TI$6:     LD      BC,258H     ;10M
          CALL    CLDGIT      
          LD      BC,3CH      ;1M
          CALL    CLDGIT      
          LD      BC,0AH      ;10S
          CALL    CLDGIT      
          LD      A,30H       
          ADD     A,L         
          LD      (DE),A      
TI$8:     LD      HL,(TMPEND) 
          LD      DE,6        
          EX      DE,HL       
          ADD     HL,DE       
          LD      (TMPEND),HL 
          EX      DE,HL       
          LD      DE,(STRST)  
          OR      A           
          SBC     HL,DE       
          EX      DE,HL       
          POP     HL          
          LD      (HL),6      
          INC     HL          
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          INC     HL          
          INC     HL          
          INC     HL          
          EX      DE,HL       
          POP     HL          
          LD      A,3         
          LD      (PRCSON),A  
          JP      HLFTCH      

CLDGIT:   OR      A           
          SBC     HL,BC       
          JR      C,CLDGRT    
          LD      A,(DE)      
          INC     A           
          LD      (DE),A      
          JR      CLDGIT      

CLDGRT:   ADD     HL,BC       
          INC     DE          
          RET     

TIMDAI:   CALL    TESTX       ;TI$=....
          DB      0F4H        
          CALL    STREXP      
          LD      A,B         
          CP      6           
          JP      NZ,ER03     
          PUSH    HL          
          PUSH    DE          
          LD      HL,0        
          CALL    TIMASC      
          CP      24          
          JP      NC,ER03     
          CP      12          
          LD      A,0         
          JR      C,TIMDA2    
          PUSH    DE          
          LD      DE,12       
          OR      A           
          SBC     HL,DE       
          POP     DE          
          INC     A           
TIMDA2:   PUSH    AF          
          CALL    TIMASC      
          CP      60          
          JP      NC,ER03     
          CALL    TIMASC      
          CP      60          
          JP      NC,ER03     
          POP     AF          
          EX      DE,HL       
          RST     18H         
          DB      .TIMST      
          POP     DE          
          POP     HL          
          RET     

TIMASC:   PUSH    DE          
          LD      D,H         
          LD      E,L         
          ADD     HL,HL       
          ADD     HL,HL       
          ADD     HL,DE       
          LD      D,H         
          LD      E,L         
          ADD     HL,HL       
          ADD     HL,DE       
          ADD     HL,HL       
          ADD     HL,HL       
          POP     DE          
          LD      A,(DE)      
          INC     DE          
          SUB     30H         
          JP      C,ER03      
          CP      0AH         
          JP      NC,ER03     
          PUSH    BC          
          LD      C,A         
          ADD     A,A         
          ADD     A,A         
          ADD     A,C         
          ADD     A,A         
          LD      C,A         
          LD      A,(DE)      
          INC     DE          
          SUB     30H         
          JP      C,ER03      
          CP      0AH         
          JP      NC,ER03     
          ADD     A,C         
          LD      C,A         
          LD      B,0         
          ADD     HL,BC       
          POP     BC          
          RET     

INTGTV:   LD      DE,(VARED)  
          LD      (TMPEND),DE 
          LD      DE,(INTFAC) 
GETVAR:   PUSH    DE          
          CALL    VSRTST      
GETFNV:   LD      A,(HL)      
          CP      '('         
          JP      Z,ARRAY     
          PUSH    HL          
          CALL    CHVRNM      
          JR      NC,CRNVAR   
          LD      A,C         
          LD      C,L         
          LD      B,H         
          POP     HL          
          POP     DE          
          RET     

CRNVAR:   LD      A,(DE)      
          ADD     A,C         ;VAR.LEN.+TYPE
          ADD     A,2         
          PUSH    BC          
          EX      DE,HL       
          LD      HL,(TMPEND) 
          PUSH    HL          
          OR      A           
          SBC     HL,DE       
          INC     HL          
          LD      C,L         
          LD      B,H         
          POP     HL          
          PUSH    DE          
          EX      DE,HL       
          LD      L,A         
          LD      H,0         
          ADD     HL,DE       
          EX      DE,HL       
          CALL    MEMECK      
          LDDR    
          LD      E,A         
          LD      D,0         
          RST     18H         
          DB      .ADDP2      
          POP     HL          
          POP     BC          
          LD      DE,KEYBUF   
          LD      (HL),C      ;TYPE SET
          INC     HL          
          SCF     
          SBC     A,C         ;B=A-C-1
          LD      B,A         
VARSL1:   LD      A,(DE)      ;VAR.LEN.&NAME
          LD      (HL),A      
          INC     DE          
          INC     HL          
          DJNZ    VARSL1      
          PUSH    HL          
          LD      B,C         
          CALL    QCLRHL      ;VAR.CLR
          LD      (HL),A      ;VAR.END MARK
          LD      A,C         
          POP     BC          
          POP     HL          
          POP     DE          
          RET     

VSRTST:   CALL    HLFTCH      
          SUB     'A'         
          CP      26          
          JP      NC,ER01     
          LD      DE,KEYBUF   
          LD      B,0         
VSRTS1:   INC     DE          
          LD      A,(HL)      
          CALL    TSTVAR      
          JR      C,TSTTYP    
          LD      (DE),A      
          INC     B           
          LD      A,B         
          CP      3           
          JR      C,VSRTS2    
          DEC     B           
VSRTS2:   INC     HL          
          JR      VSRTS1      

TSTTYP:   LD      DE,KEYBUF   
          EX      DE,HL       
          LD      (HL),B      
          EX      DE,HL       
          LD      C,5         
          CP      24H         ;$
          RET     NZ          
          LD      C,3         
          INC     HL          
          RET     

ADJUST:   LD      HL,-5       
          EX      DE,HL       
          ADD     HL,DE       
          EX      DE,HL       
          ADD     HL,DE       
          LD      A,B         
          JP      STRCK       

STRLCK:   LD      B,0FFH      
STRLL1:   INC     B           
          LD      A,(HL)      
          OR      A           
          RET     Z           
          INC     HL          
          CP      '"'         
          RET     Z           
          JR      STRLL1      

STRENT:   LD      A,B         
          OR      A           
          RET     Z           
          CALL    LDHLDE      
          EX      DE,HL       
          CALL    MEMECK      
          EX      DE,HL       
          RET     

MEMECK:   PUSH    HL          ;SBC SP,DE
          LD      HL,-512     
          ADD     HL,SP       
          SBC     HL,DE       
          POP     HL          
          RET     NC          
          JP      ER06A       

;*------------------
;* PUSH DE
;* KEYBUF..LEN. NAME
;* HL=(
;*------------------

ARRAY0:   LD      DE,(INTFAC) 
          PUSH    DE          
          JR      ARRAY2      

ARRAY:    XOR     A           
          LD      (AUTDIM),A  
          INC     HL          
          LD      (ARYTXT),HL 
ARRAY2:   LD      B,0         
          EXX     
          POP     HL          ;POP FAC
          PUSH    HL          ;PUSH FAC
          PUSH    HL          ;PUSH FAC1
          LD      HL,(TMPEND) 
          LD      DE,KEYBUF   
          PUSH    HL          
          LD      A,(DE)      
          LD      (HL),A      
          INC     DE          
          INC     HL          
          LD      B,A         
          CALL    STRENT      
          POP     DE          
          LD      (TMPEND),HL 
          LD      HL,(STRST)  
          EX      DE,HL       
          OR      A           
          SBC     HL,DE       
          EX      (SP),HL     ;NAME ADR.
          PUSH    HL          ;PUSH FAC1
          EXX     
TSALOP:   POP     DE          ;POP FAC1
          PUSH    DE          ;PUSH FAC1
          PUSH    BC          ;PUSH B,TYPE(C)
          LD      BC,(ARYTXT) 
          LD      A,(AUTDIM)  
          PUSH    BC          
          PUSH    AF          
          LD      BC,(DGBF00) 
          PUSH    BC          
          CALL    DEEXP       ;∆∆DE=EXP(INT)
          BIT     7,D         
          JP      NZ,ER03     
          EX      AF,AF'      
          POP     BC          
          LD      (DGBF00),BC 
          POP     AF          
          LD      (AUTDIM),A  
          POP     BC          
          LD      (ARYTXT),BC 
          EX      AF,AF'      
          INC     HL          
          CP      ')'         
          JR      Z,TSFARY    
          CP      ','         
          JP      NZ,ER01     
          POP     BC          ;POP B,TYPE(C)
          INC     B           ;(.,.,.,.)
          LD      A,B         
          CP      4           
          JP      NC,ER03     
          EXX     
          POP     HL          ;POP FAC1
          POP     DE          ;POP NAME ADR.
          EXX     
          PUSH    DE          ;ANS
          EXX     
          PUSH    DE          ;PUSH NAME ADR.
          PUSH    HL          ;PUSH FAC1
          EXX     
          JR      TSALOP      

TSFARY:   POP     BC          ;POP B,TYPE(C)
          EXX     
          POP     HL          ;POP FAC1
          POP     DE          ;POP NAME ADR.
          EXX     
          INC     B           ;ARRAY POINT
          PUSH    DE          ;ANS
          PUSH    HL          ;PUSH TEXT POINT
          EXX     
          LD      HL,(STRST)  
          ADD     HL,DE       
          LD      B,(HL)      
          INC     B           
          LD      DE,KEYBUF   
          CALL    LDDEHL      
          EXX     
          SET     7,C         
          CALL    CHVRNM      
          RES     7,C         
          JR      NC,ARYDIM   
          LD      A,B         
          CP      (HL)        
          JP      NZ,ER07     ;DUPLICATE
;*----------------------------------------------------
;*       LD     A,(AUTDIM)      ;these three lines are
;*       OR A                   ;commented out of the
;*       JP NZ,ER07             ;original source code
;*----------------------------------------------------
          INC     HL          
          EX      DE,HL       
          POP     HL          
          LD      (DGBF00),HL ;TEXT END
          EXX     
          LD      HL,0000H    
          EXX     
          EX      DE,HL       
ADRCL:    LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          INC     HL          
          EX      (SP),HL     
          PUSH    DE          
          EXX     
          POP     DE          
          CALL    DIMMUL      
          EXX     
          PUSH    HL          
          OR      A           
          SBC     HL,DE       
          JP      NC,ER03     
          EXX     
          POP     DE          
          CALL    DIMADD      
          EXX     
          POP     HL          
          DJNZ    ADRCL       
          PUSH    HL          
          EXX     
          LD      A,C         
          LD      D,B         
          BIT     6,A         
          JR      NZ,VARDIM   
          AND     0FH         
          LD      E,A         
          PUSH    AF          
          CALL    DIMMUL      
          PUSH    HL          
          EXX     
          POP     BC          
          POP     AF          
          POP     HL          
          ADD     HL,BC       
          LD      C,L         
          LD      B,H         
VARDME:   LD      HL,(DGBF00) 
          POP     DE          
          RET     

VARDIM:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          POP     HL          
          LD      C,L         
          LD      B,H         
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          AND     0FH         
          JR      VARDME      

ARYDIM:   EXX     
          LD      A,(AUTDIM)  
          OR      A           
          JP      Z,ER03      
          POP     HL          ;TEXT POINT
          LD      (DGBF00),HL 
          EXX     
          LD      DE,(TMPEND) 
          LD      L,B         
          LD      H,0         
          ADD     HL,HL       
          ADD     HL,DE       
          EX      DE,HL       
          INC     DE          
          CALL    MEMECK      
          LD      (HL),B      
          INC     HL          
          EXX     
          LD      HL,1        
          EXX     
ADRCL2:   POP     DE          
          LD      A,(AUTDIM)  
          OR      A           
          JR      NZ,ADRCL3   
          PUSH    HL          ;1
          EX      DE,HL       
          LD      DE,10       
          SCF     
          SBC     HL,DE       
          JP      NC,ER03     
          POP     HL          ;1
ADRCL3:   INC     DE          
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          INC     HL          
          PUSH    DE          
          EXX     
          POP     DE          
          CALL    DIMMUL      
          EXX     
          DJNZ    ADRCL2      
          LD      E,C         
          LD      D,0         
          PUSH    BC          
          PUSH    DE          
          EXX     
          POP     DE          
          CALL    DIMMUL      
          PUSH    HL          
          EXX     
          POP     BC          
          PUSH    BC          ;2 A*B*C*D
          EX      DE,HL       
          LD      HL,(TMPEND) ;(.,.,.)*2
          LD      L,(HL)      
          LD      H,0         
          ADD     HL,HL       
          LD      A,(KEYBUF)  ;+NAME
          ADD     A,5         ;+TY+LN+NL+(.,.)
          ADD     A,L         
          LD      L,A         
          LD      A,0         
          ADC     A,H         
          LD      H,A         
          JR      C,DIMOVM    
          ADD     HL,BC       
          JR      C,DIMOVM    
          PUSH    HL          ;3 LEN
          ADD     HL,DE       ;+TEMPEND
DIMOVM:   JP      C,ER06A     
          EX      DE,HL       
          CALL    MEMECK      
          PUSH    HL          ;4 TMPEND
          EXX     
          POP     HL          ;4 TMPEND
          LD      BC,(STRST)  ;VAR END
          DEC     BC          
          OR      A           
          SBC     HL,BC       
          PUSH    HL          ;4 TRANS LEN
          EXX     
          POP     BC          ;4 TRANS LEN
          LDDR    
          POP     DE          ;3 LEN
          RST     18H         
          DB      .ADDP2      
          POP     BC          ;2 CLR LEN
          PUSH    DE          ;2 LEN
          EXX     
          POP     DE          ;2 LEN
          LD      H,B         
          LD      L,C         
          POP     BC          ;1 TYPE
          LD      A,C         
          OR      80H         
          LD      (HL),A      
          INC     HL          
          DEC     DE          
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          INC     HL          
          LD      DE,KEYBUF   
          LD      A,(DE)      
          INC     A           
          LD      B,A         
          CALL    LDHLDE      
          LD      DE,(TMPEND) 
          LD      A,(DE)      
          LD      (HL),A      
          INC     HL          
          INC     DE          
          ADD     A,A         
          LD      B,A         
          CALL    LDHLDE      
          PUSH    HL          
          EXX     
          POP     HL          
DIMCLR:   XOR     A           
          LD      (HL),A      
          INC     HL          
          DEC     BC          
          LD      A,B         
          OR      C           
          JR      NZ,DIMCLR   
          LD      (HL),A      
          EXX     
          POP     DE          
          LD      A,(AUTDIM)  
          OR      A           
          JR      Z,VARCUL    
          LD      HL,(DGBF00) 
          RET     

VARCUL:   LD      HL,(ARYTXT) 
          PUSH    DE          
          JP      ARRAY2      

DIM:      LD      A,0FFH      
          LD      (AUTDIM),A  
NXTDIM:   CALL    VSRTST      
          LD      A,(HL)      
          CALL    CH28H       
          CALL    ARRAY0      
          CALL    HLFTCH      
          CP      ','         
          RET     NZ          
          INC     HL          
          JR      NXTDIM      

DIMADD:   ADD     HL,DE       
          RET     NC          
          JR      SORDIM      

DIMMUL:   PUSH    BC          
          EX      DE,HL       
          LD      C,L         
          LD      A,H         
          LD      HL,0        
          CALL    DMMULS      
          LD      A,C         
          CALL    DMMULS      
          POP     BC          
          RET     

DMMULS:   OR      A           
          JR      Z,SKPMUL    
          LD      B,8         
DMMULP:   ADD     HL,HL       
          JR      C,SORDIM    
          RLCA    
          JR      NC,DMMULE   
          ADD     HL,DE       
          JR      C,SORDIM    
DMMULE:   DJNZ    DMMULP      
          RET     

SKPMUL:   LD      A,H         
          LD      H,L         
          LD      L,0         
          OR      A           
          RET     Z           
SORDIM:   JP      ER06        

ARYTXT:   DB      0,0         ;(was DEFS 2)
AUTDIM:   DB      0           ;(was DEFS 1)

VARFN2:   SUB     'A'         
          CP      26          
          JP      NC,ER01     
          LD      BC,(FNVRBF) 
          LD      A,B         
          OR      C           
          JR      NZ,FNGTVR   
          CALL    GETVAR      
FNGTV2:   PUSH    DE          
          PUSH    HL          
          LD      L,C         
          LD      H,B         
          LD      B,A         
          LD      C,A         
          CALL    LDDEHL      
          POP     HL          
          LD      A,C         
          POP     DE          
          JP      FACRX5      

FNGTVR:   PUSH    DE          
          CALL    VSRTST      
          PUSH    HL          
          INC     B           
          LD      DE,KEYBUF   
          LD      HL,(TMPEND) 
          CALL    STRENT      
          LD      B,0         
          LD      HL,(FNVRBF) 
          CALL    HLFTCH      
          CP      0F4H        
          JR      Z,FNSHNO    
          CP      '('         
          JR      NZ,SERROL   ;∆∆JP NZ,ER01
FNGTL1:   INC     HL          
          INC     B           
          PUSH    BC          
          CALL    VSRTST      
          LD      A,C         
          POP     DE          
          CP      E           ;TYPE
          LD      C,E         ;∆∆
          JR      NZ,FNGTL2   
          PUSH    DE          
          LD      C,B         
          INC     C           
          PUSH    HL          
          LD      HL,(TMPEND) 
          LD      DE,KEYBUF   
          CALL    HLDECH      
          POP     HL          
          POP     BC          
          JR      Z,FNSHOK    
FNGTL2:   CALL    HLFTCH      
          CP      ')'         
          JR      Z,FNSHNO    
          CP      ','         
          JR      Z,FNGTL1    ;∆∆∆
SERROL:   JP      ER01        ;∆∆

FNSHNO:   LD      HL,(TMPEND) 
          LD      DE,KEYBUF   
          LD      A,(HL)      
          LD      (DE),A      
          LD      B,A         
FNSH05:   INC     HL          
          INC     DE          
          LD      A,(HL)      
          LD      (DE),A      
          DJNZ    FNSH05      
          POP     HL          
          POP     DE          
          CALL    FNGTV1      
          JR      FNGTV2      

FNSHOK:   LD      HL,(FNTXBF) 
          CALL    HCH28H      
          DEC     B           
          JR      Z,FNSH13    
          DEC     HL          
FNSH11:   PUSH    BC          
FNSH12:   CALL    IFSKSB      
          CALL    ENDCHK      
          JP      Z,ER01      
          CP      ')'         
          JP      Z,ER01      
          CP      ','         
          JR      NZ,FNSH12   
          POP     BC          
          DJNZ    FNSH11      
          INC     HL          
FNSH13:   EX      DE,HL       
          POP     HL          
          EX      (SP),HL     
          EX      DE,HL       
          LD      BC,(FNVRBF) 
          PUSH    BC          
          LD      BC,0        
          LD      (FNVRBF),BC 
          CALL    EXPR8       
          POP     HL          
          LD      (FNVRBF),HL 
          POP     HL          
          JP      HLFTCH      

FNGTV1:   PUSH    DE          
          JP      GETFNV      

CHVRNM:   LD      HL,(VARST)  
ASLOP:    LD      DE,KEYBUF   
          LD      A,(HL)      
          OR      A           
          RET     Z           
          CP      40H         
          JR      NC,ARYATA   
          CP      C           
          JR      NZ,SKIPUS   
          INC     HL          
          LD      A,(DE)      
          CP      (HL)        
          JR      NZ,SKIPU2   
          LD      B,A         
VARCL1:   INC     DE          
          INC     HL          
          LD      A,(DE)      ;»»
          CP      (HL)        ;»»
;*       CALL NZ,SMALCH         ; commented out
          JR      NZ,SKIPU3   
          DJNZ    VARCL1      
          INC     HL          
          SCF     
          RET     

SKIPU3:   INC     HL          
          DJNZ    SKIPU3      
          LD      A,C         
          JR      ARSKFN      
SKIPU2:   LD      A,C         
          DEC     HL          
SKIPUS:   AND     0FH         ;TYPE
          INC     HL          
          ADD     A,(HL)      ;NAME LEN.
          INC     HL          
ARSKFN:   LD      E,A         
          LD      D,0         
          ADD     HL,DE       
          JR      ASLOP       

ARYATA:   CP      C           ;TYPE
          JR      Z,ARMSN1    
          INC     HL          
MIDNAM:   LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          DEC     HL          
          ADD     HL,DE       
          JR      ASLOP       

NXTVR1:   LD      A,C         
          SUB     B           
          CPL     
          LD      C,A         
          LD      B,0FFH      
          ADD     HL,BC       
          POP     BC          
NXTVR:    DEC     HL          
          DEC     HL          
          JR      MIDNAM      

ARMSN1:   LD      A,(HL)      
          EXX     
          LD      C,A         
          LD      B,00H       
          EXX     
          INC     HL          
          PUSH    DE          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          INC     HL          
          EX      DE,HL       
          ADD     HL,DE       
;*       LD     (ARYEDA),HL     ;this instruction is commented out
          EX      DE,HL       
          POP     DE          
          LD      A,(DE)      
          CP      (HL)        ;NAME LEN.
          JR      NZ,NXTVR    
          PUSH    BC          
          LD      B,A         
          LD      C,A         
AYNMCK:   INC     HL          
          INC     DE          
          LD      A,(DE)      ;»»
          CP      (HL)        ;»»
          JR      NZ,NXTVR1   
          DJNZ    AYNMCK      
          INC     HL          
          POP     BC          
          SCF     
          RET     

DEFFN:    CALL    VSRTST      
          SET     6,C         
          PUSH    HL          
          CALL    CHVRNM      
          JP      C,ER07      ;ARY DEF ERR
          LD      (HL),C      
          EX      (SP),HL     
          PUSH    HL          
          DEC     HL          
FNSKP1:   CALL    IFSKSB      
          OR      A           
          JR      Z,FNSKED    
          CP      3AH         ;:
          JR      NZ,FNSKP1   
FNSKED:   POP     DE          
          PUSH    HL          
          INC     HL          
          SBC     HL,DE       
          LD      A,(KEYBUF)  
          ADD     A,4         
          LD      C,A         
          LD      B,0         
          LD      A,L         
          ADD     HL,BC       
          LD      B,A         
          PUSH    HL          
          EXX     
          POP     BC          
          PUSH    BC          
          PUSH    HL          
          PUSH    DE          
          PUSH    BC          
          LD      HL,0        
          ADD     HL,SP       
          LD      DE,(TMPEND) 
          DEC     H           
          OR      A           
          SBC     HL,DE       
          LD      A,12        
          JP      C,NESTER    
          POP     BC          
          POP     DE          
          POP     HL          
          LD      HL,(TMPEND) 
          PUSH    HL          
          ADD     HL,BC       
          EX      (SP),HL     
          PUSH    HL          
          LD      DE,(STRST)  ;VAR END
          OR      A           
          SBC     HL,DE       
          LD      C,L         
          LD      B,H         
          POP     HL          
          POP     DE          
          LDDR    
          POP     DE          
          RST     18H         
          DB      .ADDP2      
          DEC     DE          
          POP     HL          
          EX      (SP),HL     
          INC     HL          
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          INC     HL          
          LD      DE,KEYBUF   
          LD      A,(DE)      
          LD      (HL),A      
          LD      B,A         
DEFFN2:   INC     DE          
          INC     HL          
          LD      A,(DE)      
          LD      (HL),A      
          DJNZ    DEFFN2      
          INC     HL          
          PUSH    HL          
          EXX     
          POP     HL          
          CALL    LDHLDE      
          LD      (HL),0      
          POP     HL          
          RET     

FNEXP:    PUSH    DE          
          CALL    VSRTST      
          POP     IX          
          PUSH    BC          
          SET     6,C         
          LD      DE,(FNTXBF) 
          LD      (FNTXBF),HL 
          PUSH    DE          
          CALL    CHVRNM      
          JP      NC,ER15     ;UNDEF FN
          LD      DE,(FNVRBF) 
          LD      (FNVRBF),HL 
          PUSH    DE          
          PUSH    IX          
          DEC     HL          
FNEQSK:   CALL    IFSKSB      
          CALL    ENDCHK      
          JP      Z,ER01      
          CP      0F4H        ;=
          JR      NZ,FNEQSK   
          INC     HL          
          POP     DE          
          PUSH    DE          
          CALL    EXPR8       
          POP     DE          
          LD      HL,(FNTXBF) 
          POP     BC          
          LD      (FNVRBF),BC 
          POP     BC          
          LD      (FNTXBF),BC 
          EX      DE,HL       
          POP     BC          
          LD      A,C         
          CALL    STRCK       
          LD      BC,5        
          ADD     HL,BC       
          EX      DE,HL       
          CALL    HLFTCH      
          CP      '('         
          RET     NZ          
          PUSH    DE          
          LD      B,1         
SK29LP:   PUSH    BC          
          CALL    IFSKSB      
          POP     BC          
          CALL    ENDCK0      
          JP      Z,ER01      
          CP      '('         
          JR      NZ,FNEXP1   
          INC     B           
FNEXP1:   CP      ')'         
          JR      NZ,SK29LP   
          DJNZ    SK29LP      
          INC     HL          
          CALL    HLFTCH      
          POP     DE          
          RET     

STRCK:    CP      3           
          JR      NZ,STROMT   
STROK:    LD      A,(PRCSON)  
          CP      3           
          RET     Z           
          JP      ER04        ;TYPE MISMATCH

STROMT:   LD      A,(PRCSON)  
          CP      3           
          RET     NZ          
          JP      ER04        

FNVRBF:   DW      0           
FNTXBF:   DB      0,0         ;(was DEFS 2)

;*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
HLDECH:   LD      A,(DE)      ;this routine is duplicated as HLDECK: but
          CP      (HL)        ;both routines have been left in and used,
          RET     NZ          ;to keep the code aligned with existing
          PUSH    BC          ;versions of MZ-800 QDBASIC MZ-5Z009
          PUSH    DE          
          PUSH    HL          
          LD      B,C         
HLDE1:    LD      A,(DE)      
          CP      (HL)        
          JR      NZ,HLDE2    
          INC     DE          
          INC     HL          
          DJNZ    HLDE1       
          XOR     A           
HLDE2:    POP     HL          
          POP     DE          
          POP     BC          
          RET                 ;END of duplicate routine
;*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;*------------------
;* Joy stick command
;*------------------
STCK:     CALL    HCH28H      
          PUSH    DE          
          CALL    DEEXP       
          CALL    DCHECK      
          CP      3           
          JP      NC,ER03     
          POP     DE          
          PUSH    AF          
          CALL    HCH29H      
          POP     AF          
          RST     18H         
          DB      .STICK      
          EX      DE,HL       
          PUSH    DE          
          CALL    PUT1B       
          JP      EOF8        

STIG:     CALL    HCH28H      
          PUSH    DE          
          CALL    DEEXP       
          CALL    DCHECK      
          CP      5           
          JP      NC,ER03     
          POP     DE          
          PUSH    AF          
          CALL    HCH29H      
          POP     AF          
          RST     18H         
          DB      .STRIG      
          EX      DE,HL       
          PUSH    DE          
          CALL    PUT1B       
          JP      EOF8        

;*       END of original module EXPR.ASM
;*============================================================================
;*     START of original module FLOAT.ASM    
;*-----------------------------
;* MZ-800 BASIC  Floating point
;* FI:FLOAT  ver 1.0A 7.18.84
;* Programmed by T.Miho
;*-----------------------------

CLRFAC:   PUSH    HL          
          LD      B,5         
          CALL    QCLRHL      
          POP     HL          
          RET     

NEGCMD:   CALL    STROMT      
TOGLE:    LD      A,(HL)      
          OR      A           
          RET     Z           
          INC     HL          
          LD      A,(HL)      
          XOR     80H         
          LD      (HL),A      
          DEC     HL          
          RET     

;*--------------
;*(HL)=(HL)-(DE)
;*--------------
SUBCMD:   CALL    STROMT      
          LD      C,A         
          LD      A,80H       
          JP      ADDSUB      

;*--------------
;*(HL)=(HL)+(DE)
;*--------------
ADDCMD:   LD      A,(PRCSON)  
          CP      03H         
          JP      Z,STRADD    
          LD      C,A         
          XOR     A           
ADDSUB:   LD      (HLBUF),HL  
          PUSH    DE          
          PUSH    HL          
          LD      (SPBUF),SP  
          INC     HL          
          INC     DE          
          LD      B,(HL)      
          XOR     (HL)        
          EX      DE,HL       
          XOR     (HL)        
          DEC     HL          
          DEC     DE          
          EX      DE,HL       
          RLCA    
          LD      A,B         
          LD      (SIGN),A    
          JP      C,FSUB      ;HL-DE
FADD:     XOR     A           ;HL+DE
          CP      (HL)        
          JP      Z,MOVEIT    ;(HL)_(DE)
          LD      A,(DE)      
          OR      A           
          JR      Z,FLEXIT    ;SIGN SET RET
          SUB     (HL)        ;DE-HL
          JP      SFADD       

FLEXIT:   LD      SP,(SPBUF)  
          POP     HL          
          POP     DE          
          EI      
          LD      A,(HL)      
          OR      A           
          JP      Z,ABS       
          LD      A,(SIGN)    
          AND     80H         
          INC     HL          
          RES     7,(HL)      
          OR      (HL)        
          LD      (HL),A      
          DEC     HL          
          RET     

MOVEIT:   LD      B,0         
          LD      A,5         
          LD      C,A         
          EX      DE,HL       
          LDIR    
          JP      FLEXIT      

STRADD:   LD      B,(HL)      
          LD      A,(DE)      
          ADD     A,B         
          JP      C,ER05      ;STRING TOO LONG
          LD      C,A         
          PUSH    DE          
          PUSH    HL          
          PUSH    DE          
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      HL,(STRST)  
          ADD     HL,DE       
          EX      DE,HL       
          LD      HL,(TMPEND) 
          CALL    STRENT      
          EX      (SP),HL     
          LD      B,(HL)      
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      HL,(STRST)  
          ADD     HL,DE       
          EX      DE,HL       
          POP     HL          
          CALL    STRENT      
          LD      A,C         
          LD      DE,(TMPEND) 
          LD      BC,(STRST)  
          EX      DE,HL       
          OR      A           
          SBC     HL,BC       
          EX      DE,HL       
          LD      (TMPEND),HL 
          POP     HL          
          LD      (HL),A      
          INC     HL          
          LD      (HL),E      
          INC     HL          
          LD      (HL),D      
          DEC     HL          
          DEC     HL          
          POP     DE          
          RET     

;*-------------------------------------------
;* Middle of p.592 in German Listing of 2Z046
;* Compare strings at (DE) & (HL)
;*-------------------------------------------
CMP:      LD      A,(PRCSON)  
          CP      3           
          JR      NZ,FLTCP2   
          PUSH    DE          
          PUSH    HL          
          LD      A,(DE)      
          OR      (HL)        
          JR      Z,STCMPE    
          LD      A,(DE)      
          CP      (HL)        
          JR      C,CMP1      
          LD      A,(HL)      
CMP1:     OR      A           
          JR      Z,STCMPF    
          INC     HL          
          LD      C,(HL)      
          INC     HL          
          LD      B,(HL)      
          EX      DE,HL       
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          LD      D,(HL)      
          LD      HL,(STRST)  
          EX      DE,HL       
          ADD     HL,DE       
          EX      DE,HL       
          ADD     HL,BC       
          EX      DE,HL       
          LD      B,A         
          OR      A           
          JR      Z,STCMPE    
STCMPL:   LD      A,(DE)      
          CP      (HL)        
          JR      NZ,STCMPE   
          INC     DE          
          INC     HL          
          DJNZ    STCMPL      
STCMPF:   POP     DE          
          POP     HL          
          LD      A,(DE)      
          CP      (HL)        
          EX      DE,HL       
          RET     

STCMPE:   POP     HL          
          POP     DE          
          RET     

FLTCP2:   INC     DE          
          INC     HL          
          LD      A,(DE)      
          DEC     DE          
          XOR     (HL)        
          RLCA    
          JR      NC,FLTCP3   
          LD      A,(HL)      
          DEC     HL          
          RLCA    
          RET     

FLTCP3:   LD      A,(HL)      
          DEC     HL          
          RLCA    
          JR      NC,FLTCMP   
          CALL    FLTCMP      
          RET     Z           
          CCF     
          RET     

FLTCMP:   PUSH    DE          
          PUSH    HL          
          EX      DE,HL       
          LD      A,(DE)      
          CP      (HL)        
          JR      NZ,SUBNZ    
          INC     DE          
          INC     HL          
          LD      A,(HL)      
          OR      80H         
          LD      B,A         
          LD      A,(DE)      
          OR      80H         
          CP      B           
          JR      NZ,SUBNZ    
          LD      A,(PRCSON)  
          LD      B,A         
          DEC     B           
          DEC     B           
CMPL:     INC     DE          
          INC     HL          
          LD      A,(DE)      
          CP      (HL)        
          JR      NZ,SUBNZ    
          DJNZ    CMPL        
SUBNZ:    POP     HL          
          POP     DE          
          RET     

ZERO:     POP     HL          
          PUSH    HL          
          CALL    CLRFAC      
          JP      FLEXIT      

FSUB:     CALL    FLTCMP      
          JR      Z,ZERO      
          JR      NC,SUBOK    
          LD      A,(SIGN)    
          XOR     80H         
          LD      (SIGN),A    
          SCF     
SUBOK:    EX      AF,AF'      
          LD      A,(HL)      
          OR      A           
          JP      Z,MOVEIT    
          LD      A,(DE)      
          OR      A           
          JP      Z,FLEXIT    
          SUB     (HL)        
          JR      C,FSUB11    
          CP      32          
          JP      NC,MOVEIT   
          JR      SUBOK2      

FSUB11:   NEG     
          CP      32          
          JP      NC,FLEXIT   
SUBOK2:   EX      AF,AF'      
          JR      C,SUBOK3    
          EX      DE,HL       
SUBOK3:   EX      AF,AF'      
          JP      SSUB        

OVERF:    LD      SP,(SPBUF)  
          EI      
          POP     HL          
          POP     DE          
          LD      A,(OFLAG)   
          OR      A           
          JP      Z,ER02      
;*SET MAX NUM HERE *****
          RET     

SFADD:    JR      NC,SNSH     
          NEG     
          CP      32          
          JP      NC,FLEXIT   
          EX      DE,HL       
          JR      SADD1       

SNSH:     CP      32          
          JP      NC,MOVEIT   

SADD1:    CALL    SSHIFT      
          LD      A,H         
          EXX     
          ADC     A,H         ; ADJUST WITH CARRY
          EXX     
          LD      H,A         
          LD      A,L         
          EXX     
          ADC     A,L         
          EXX     
          LD      L,A         
          LD      A,D         
          EXX     
          ADC     A,D         
          EXX     
          LD      D,A         
          LD      A,E         
          EXX     
          ADC     A,E         
          EXX     
          JR      NC,SSTORE   
          RRA     
          RR      D           
          RR      L           
          RR      H           
          INC     C           
          JP      Z,OVERF     
SSTORE:   LD      E,A         
          LD      A,C         
          EXX     
          LD      BC,5        
          LD      HL,(HLBUF)  
          LD      (HL),A      
          ADD     HL,BC       
          DI      
          LD      SP,HL       
          EXX     
          PUSH    HL          
          PUSH    DE          
          JP      FLEXIT      

SSHIFT:   DI      
          LD      (SPBF),SP   
          EX      AF,AF'      
          INC     HL          
          LD      SP,HL       
          EXX     
          POP     DE          ;E,D,L,H
          SET     7,E         ;CY=0
          POP     HL          
          OR      A           
SHFLP2:   EX      AF,AF'      
          CP      8           
          JR      C,BITET2    
          SUB     8           
          EX      AF,AF'      
          RL      H           
          LD      H,L         
          LD      L,D         
          LD      D,E         
          LD      E,0         
          JR      SHFLP2      

BITET2:   OR      A           
          JR      Z,BITSE2    
BITST2:   EX      AF,AF'      
          OR      A           
          RR      E           
          RR      D           
          RR      L           
          RR      H           
          EX      AF,AF'      
          DEC     A           
          JR      NZ,BITST2   
BITSE2:   EXX     
          EX      DE,HL       
          LD      C,(HL)      
          INC     HL          
          LD      SP,HL       
          POP     DE          
          SET     7,E         
          POP     HL          
          EX      AF,AF'      
          LD      SP,(SPBF)   
          EI      
          RET     

SSUB:     CP      32          
          JP      NC,FLEXIT   
          CALL    SSHIFT      
          LD      A,H         
          EXX     
          SBC     A,H         
          EXX     
          LD      H,A         
          LD      A,L         
          EXX     
          SBC     A,L         
          EXX     
          LD      L,A         
          LD      A,D         
          EXX     
          SBC     A,D         
          EXX     
          LD      D,A         
          LD      A,E         
          EXX     
          SBC     A,E         
          EXX     
SSFL2:    OR      A           
          JR      Z,BSIFT     
SSFL3:    BIT     7,A         
          JR      NZ,SSTOR2   
          RL      H           
          RL      L           
          RL      D           
          RLA     
          DEC     C           
          JP      NZ,SSFL3    
          JP      ZERO        

SSTOR2:   LD      E,A         
          JP      SSTORE      

BSIFT:    LD      A,C         
          SUB     8           
          LD      C,A         
          LD      A,D         
          LD      D,L         
          LD      L,H         
          LD      H,0         
          JR      Z,SADDX     
          JR      NC,SSFL2    
SADDX:    JP      ZERO        

EXPCHK:   LD      C,A         
          INC     HL          
          INC     DE          
          LD      A,(DE)      
          XOR     (HL)        
          LD      (SIGN),A    
          DEC     HL          
          DEC     DE          
          RET     

;*----------------------------------------
;* Top of p.601 in German Listing of 2Z046
;*----------------------------------------
MUL:      CALL    STROMT      
          CALL    EXPCHK      
          PUSH    DE          
          PUSH    HL          
          LD      (SPBUF),SP  
          LD      A,(HL)      
          OR      A           
          JP      Z,ZERO      
          LD      A,(DE)      
          OR      A           
          JP      Z,ZERO      
          INC     DE          
          PUSH    DE          
          POP     IX          
          ADD     A,(HL)      
          LD      E,A         
          LD      A,0         
          ADC     A,A         
          LD      D,A         
          LD      (EXPSGN),DE 
          INC     HL          
          XOR     A           
          LD      (CYFLG),A   
          LD      D,(HL)      
          SET     7,D         
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          PUSH    HL          
          LD      H,A         
          LD      L,A         
          EXX     
          POP     HL          
          LD      D,(HL)      
          INC     HL          
          LD      E,(HL)      
          LD      B,A         
          LD      C,A         
          LD      H,A         
          LD      L,A         
          EXX     
          LD      A,(IX+0)    
          OR      80H         
          LD      C,4         ;BYTES COUNTER
SMULL1:   LD      B,8         ;BIT COUNTER
          OR      A           
          JP      Z,SMULL5    
SMULL2:   RLCA    
          JR      NC,SMULL4   
          EX      AF,AF'      
          EXX     
          LD      A,C         
          ADD     A,B         
          LD      C,A         
          ADC     HL,DE       
          EXX     
          ADC     HL,DE       
          JR      NC,SMULL3   
          LD      A,1         
          LD      (CYFLG),A   
SMULL3:   EX      AF,AF'      
SMULL4:   SRL     D           
          RR      E           
          EXX     
          RR      D           
          RR      E           
          RR      B           
          EXX     
          DJNZ    SMULL2      
SMULL6:   INC     IX          
          LD      A,(IX+0)    
          DEC     C           
          JR      NZ,SMULL1   
          EXX     
          LD      A,(CYFLG)   
          OR      A           
          JR      Z,SMULL7    
          LD      DE,(EXPSGN) 
          INC     DE          
          LD      (EXPSGN),DE 
          EXX     
          SCF     
          RR      H           
          RR      L           
          EXX     
          RR      H           
          RR      L           
          RR      C           
SMULL7:   BIT     7,C         
          JR      Z,SMULL8    
          LD      DE,1        
          ADD     HL,DE       
          EXX     
          LD      DE,0        
          ADC     HL,DE       
          EXX     
          JR      NC,SMULL8   
          LD      DE,(EXPSGN) 
          INC     DE          
          LD      (EXPSGN),DE 
          EXX     
          LD      H,80H       
          EXX     
SMULL8:   POP     IX          
          PUSH    IX          
          LD      (IX+4),L    
          LD      (IX+3),H    
          EXX     
          LD      (IX+2),L    
          LD      (IX+1),H    
          LD      HL,(EXPSGN) 
          OR      A           
          LD      DE,81H      
          SBC     HL,DE       
          LD      A,H         
          ADD     A,0         
          JP      M,UNDRFL    
          JP      NZ,OVERF    
          LD      (IX+0),L    
          JP      FLEXIT      

SMULL5:   LD      A,E         
          EXX     
          LD      B,E         
          LD      E,D         
          LD      D,A         
          EXX     
          LD      E,D         
          LD      D,0         
          JP      SMULL6      

UNDRFL:   LD      SP,(SPBUF)  ;****
          JP      ZERO        

DIV:      CALL    STROMT      
          CALL    EXPCHK      
          PUSH    DE          
          PUSH    HL          
          LD      (SPBUF),SP  
          LD      A,(DE)      
          OR      A           
          JP      Z,ER02      ;DIVID BY ZERO
          EX      AF,AF'      
          LD      A,(HL)      
          OR      A           
          JP      Z,ZERO      
          EXX     
          ADD     A,81H       
          LD      B,A         
          LD      A,0         
          ADC     A,A         
          EX      AF,AF'      
          LD      C,A         
          LD      A,B         
          SUB     C           
          LD      C,A         
          EX      AF,AF'      
          LD      B,A         
          EX      AF,AF'      
          LD      A,B         
          SBC     A,0         
          JP      C,UNDRFL    
          JP      NZ,OVERF    
          LD      A,C         
          PUSH    AF          ;PUSH A(EXP)
          EXX     
          INC     DE          
          INC     HL          
          LD      B,(HL)      
          SET     7,B         
          INC     HL          
          LD      C,(HL)      
          INC     HL          
          PUSH    HL          
          EX      DE,HL       
          LD      D,(HL)      
          SET     7,D         
          INC     HL          
          LD      E,(HL)      
          INC     HL          
          PUSH    HL          
          LD      H,B         
          LD      L,C         
          EXX     
          POP     HL          
          LD      D,(HL)      
          INC     HL          
          LD      E,(HL)      
          POP     HL          
          LD      A,(HL)      
          INC     HL          
          LD      L,(HL)      
          LD      H,A         
          EXX                 ;HLH'L'/DED'E'
          LD      C,5         ;C=5
SDIVL1:   LD      B,8         ;B=8
          XOR     A           
SDIVL2:   BIT     7,H         
          JR      NZ,SDIVL3   
          OR      A           
SDIVL4:   RLA     
          EXX     
          ADD     HL,HL       
          EXX     
          ADC     HL,HL       
          DJNZ    SDIVL2      
          PUSH    AF          
          DEC     C           
          JR      NZ,SDIVL1   
          JP      SDIVED      

SDIVL3:   OR      A           
          EXX     
          SBC     HL,DE       
          EXX     
          SBC     HL,DE       
          CCF     
          JR      C,SDIVL4    
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
          DJNZ    SDIVL5      
          PUSH    AF          
          LD      B,8         
          DEC     C           
          JP      Z,SDIVED    
SDIVL5:   EXX     
          OR      A           
          SBC     HL,DE       
          EXX     
          SBC     HL,DE       
          SCF     
          RLA     
          DJNZ    SDIVL6      
          PUSH    AF          
          LD      B,8         
          DEC     C           
          JR      Z,SDIVED    
SDIVL6:   EXX     
          ADD     HL,HL       
          EXX     
          ADC     HL,HL       
          JR      C,SDIVL5    
          JP      SDIVL2      

SDIVED:   POP     AF          
          LD      H,A         ;H'
          EXX     
          POP     AF          
          LD      E,A         ;E
          POP     AF          
          LD      D,A         ;D
          POP     AF          
          LD      C,A         ;C
          POP     AF          
          LD      B,A         ;B
          POP     AF          ;A(EXP)
SDIVL9:   BIT     7,B         
          JR      NZ,SDIVE2   
          EXX     
          SLA     H           
          EXX     
          RL      E           
          RL      D           
          RL      C           
          RL      B           
          DEC     A           
          JP      NZ,SDIVL9   
          JP      ZERO        

SDIVE2:   EXX     
          RL      H           
          EXX     
          JR      NC,SDIVL8   
          LD      HL,1        
          ADD     HL,DE       
          EX      DE,HL       
          LD      HL,0        
          ADC     HL,BC       
          LD      B,H         
          LD      C,L         
          JR      NC,SDIVL8   
          LD      B,80H       
          INC     A           
SDIVL8:   POP     HL          
          PUSH    HL          
          LD      (HL),A      
          INC     HL          
          LD      (HL),B      
          INC     HL          
          LD      (HL),C      
          INC     HL          
          LD      (HL),D      
          INC     HL          
          LD      (HL),E      
          JP      FLEXIT      

HLBUF:    DB      0,0         ;(was DEFS 2)
SIGN:     DB      0           ;(was DEFS 1)
SPBUF:    DB      0,0         ;(was DEFS 2)
SPBF:     DB      0,0         ;(was DEFS 2)
CYFLG:    DB      0           ;(was DEFS 1)
EXPSGN:   DB      0,0         ;(was DEFS 2)
OFLAG:    DB      0           ;(was DEFS 1)

TSTSGN:   INC     HL          
          BIT     7,(HL)      
          DEC     HL          
          RET     

MULTWO:   INC     (HL)        
          RET     NZ          
          JP      ER02        

DIVTWO:   LD      A,(HL)      
          OR      A           
          RET     Z           
          DEC     (HL)        
          RET     NZ          
          JP      CLRFAC      

ADDHL5:   PUSH    HL          
          INC     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          INC     HL          
          EX      DE,HL       
          LD      HL,(MEMMAX) 
          DEC     HL          
          SBC     HL,DE       
          JP      C,ER06      
          POP     HL          
          RET     

FACSET:   PUSH    HL          
          LD      (SNFAC0),HL 
          CALL    ADDHL5      
          EX      DE,HL       
          LD      (SNFAC1),HL 
          CALL    ADDHL5      
          EX      DE,HL       
          LD      (SNFAC2),HL 
          CALL    ADDHL5      
          LD      (SNFAC3),DE 
          POP     HL          
          RET     

POWERS:   CALL    STROMT      ;(HL)^(DE)
          EX      DE,HL       
          LD      A,(HL)      
          OR      A           
          JP      Z,POWR1     
          EX      DE,HL       
          LD      A,(HL)      
          OR      A           
          JP      Z,CLRFAC    
          CALL    TSTSGN      
          JR      Z,POWER1    
          CALL    TOGLE       
          EX      DE,HL       
          PUSH    DE          
          PUSH    HL          
          LD      DE,ZFAC1    
          CALL    LDIR5       ;(ZFAC1)=(DE)
          LD      HL,ZFAC1    
          CALL    FRACT       
          LD      A,(HL)      
          OR      A           
          JP      NZ,ER03     
          POP     HL          
          PUSH    HL          
          CALL    HLFLT       
          BIT     0,L         
          POP     DE          
          POP     HL          
          JR      Z,POWER1    
          CALL    POWER1      
          JP      TOGLE       

POWER1:   EX      DE,HL       
          LD      A,(HL)      
          OR      A           
          JR      Z,POWR1     
          CALL    TSTSGN      
          JR      Z,POWER2    
          CALL    TOGLE       
          CALL    POWER2      
          PUSH    DE          
          PUSH    HL          
          LD      DE,ZFAC1    
          CALL    LDIR1       ;(ZFAC1)=1
          LD      HL,ZFAC1    
          POP     DE          
          CALL    DIV         ;(ZFAC1)/(HL)
          PUSH    DE          
          CALL    LDIR5       ;(HL)=(ZFAC1)
          POP     HL          
          POP     DE          
          RET     

POWR1:    PUSH    DE          
          CALL    LDIR1       
          POP     HL          
          RET     

POWER2:   PUSH    DE          
          LD      DE,ZFAC1    
          CALL    LDIR5       ;(ZFAC1)=(DE)
          POP     HL          
          CALL    LOG         ;LOG(HL)
          LD      DE,ZFAC1    
          CALL    MUL         ;(HL)*(DE)
          JP      EXP         ;EXP(HL)

.NOT.:    CALL    STROMT      
          PUSH    DE          
          PUSH    HL          
          CALL    HLFLT       
          LD      A,L         
          CPL     
          LD      E,A         
          LD      A,H         
          CPL     
          LD      D,A         
          JR      AND9        

.AND.:    LD      A,0A2H      ;AND D
          DB      1           
.OR.:     LD      A,0B2H      ;OR D
          DB      1           
.XOR.:    LD      A,0AAH      ;XOR D
          LD      (AND2),A    
          INC     A           
          LD      (AND4),A    
          CALL    STROMT      
          PUSH    DE          
          PUSH    HL          
          CALL    HLFLT       
          EX      DE,HL       
          CALL    HLFLT       
          LD      A,H         
AND2:     AND     D           ;AND, OR, XOR
          LD      D,A         
          LD      A,L         
AND4:     AND     E           ;AND, OR, XOR
          LD      E,A         
AND9:     POP     HL          
          CALL    FLTHEX      
          POP     DE          
          RET     

ABS:      INC     HL          
          RES     7,(HL)      
          DEC     HL          
          RET     

INTOPR:   CALL    TSTSGN      
          JP      Z,INT       
          CALL    MVFAC1      
          CALL    INT         
          LD      DE,ZFAC1    
          CALL    CMP         
          RET     Z           
ONESUB:   LD      DE,FLONE    
          JP      SUBCMD         

ONEADD:   LD      DE,FLONE    
          JP      ADDCMD         

ONECMP:   LD      DE,FLONE    
          JP      CMP         

MVFAC1:   PUSH    HL          
          PUSH    DE          
          LD      DE,ZFAC1    
          CALL    LDIR5       
          POP     DE          
          POP     HL          
          RET     

MOD:      CALL    INT         
          EX      DE,HL       
          CALL    INT         
          EX      DE,HL       
          CALL    MVFAC1      
          CALL    DIV         
          CALL    INT         
          CALL    MUL         
          PUSH    DE          
          LD      DE,ZFAC1    
          CALL    SUBCMD        
          POP     DE          
          JP      TOGLE       

YEN:      CALL    INT         
          EX      DE,HL       
          CALL    INT         
          EX      DE,HL       
          CALL    DIV         
          JP      INT         

SQR:      LD      A,(HL)      
          OR      A           
          RET     Z           
          CALL    TSTSGN      
          JP      NZ,ER03     
          CALL    LOG         
          CALL    DIVTWO      
          JP      EXP         

RETONE:   PUSH    HL          
          EX      DE,HL       
          CALL    LDIR1       
          POP     HL          
          POP     BC          
          RET     

ATNLM1:   DB      7EH         
          DB      4CH         

ATNLM2:   DB      80H         
          DB      2BH         

ATN:      PUSH    BC          
          INC     HL          
          LD      A,(HL)      
          RES     7,(HL)      
          DEC     HL          
          PUSH    AF          
          CALL    ATN1        
          POP     AF          
          POP     BC          
          RLCA    
          RET     NC          
          JP      TOGLE       

ATN1:     CALL    ONECMP      
          JR      C,ATN2      
          CALL    ADDHL5      
          PUSH    DE          
          PUSH    HL          
          CALL    LDIR5       
          POP     DE          
          PUSH    DE          
          CALL    LDIR1       
          POP     HL          
          POP     DE          
          CALL    DIV         
          CALL    ATN2        
          LD      DE,FLTHPI   ;PI/2
          CALL    SUBCMD        
          JP      ABS         

ATN2:     LD      A,0FFH      
          LD      (SINSGN),A  
          LD      DE,ATNLM1   
          CALL    CMP         
          JR      C,ATNCUL    
          LD      DE,ATNLM2   
          CALL    CMP         
          PUSH    AF          
          CALL    ADDHL5      
          POP     AF          
          PUSH    HL          
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          JR      C,ATNMID    
          CALL    ONEADD      
          EX      (SP),HL     
          CALL    SUBCMD        
          POP     DE          
          CALL    DIV         
          CALL    ATNCUL      
          LD      DE,FLTQPI   ;PI/4
          JP      ADDCMD         

ATNMID:   LD      DE,SQRTMO   
          CALL    MUL         
          CALL    ONEADD      
          EX      (SP),HL     
          LD      DE,SQRTMO   
          CALL    SUBCMD         
          POP     DE          
          CALL    DIV         
          CALL    ATNCUL      
          CALL    MULTWO      
          LD      DE,FLTQPI   ;PI/4
          CALL    ADDCMD         
          JP      DIVTWO      

SQRTMO:   DW      547FH       
          DW      0CC13H      
          DB      0D0H        

ATNCUL:   PUSH    BC          
          PUSH    HL          
          CALL    FACSET      
          POP     HL          
          PUSH    HL          
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          LD      E,L         
          LD      D,H         
          CALL    MUL         
          LD      DE,(SNFAC2) 
          POP     HL          
          PUSH    HL          
          CALL    LDIR5       
          LD      A,(PRCSON)  
          DEC     A           
          CP      04H         
          LD      B,A         
          LD      HL,TANTBL   
          JP      Z,SIN6      
          LD      B,10        
          JP      SIN6        

COS:      PUSH    BC          
          LD      A,(HL)      
          OR      A           
          JP      Z,RETONE    
          LD      DE,FLTHPI   ;PI/2
          CALL    SUBCMD         
          CALL    TOGLE       
          POP     BC          
SIN:      PUSH    BC          
          INC     HL          
          LD      A,(HL)      
          RES     7,(HL)      
          AND     80H         
          CPL     
          LD      (SINSGN),A  
          DEC     HL          
          LD      DE,FLT2PI   ;PI*2
          PUSH    HL          
          CALL    CMP         
          JR      C,SIN1      
          CALL    DIV         
          CALL    FRACT       
          CALL    MUL         
SIN1:     LD      DE,FLTPAI   
          CALL    CMP         
          JR      C,SIN2      
          CALL    SUBCMD         
          LD      A,(SINSGN)  
          XOR     80H         
          LD      (SINSGN),A  
SIN2:     LD      DE,FLTHPI   ;PI/2
          CALL    CMP         
          JR      C,SIN4      
          LD      DE,FLTPAI   
          CALL    SUBCMD         
          CALL    ABS         
SIN4:     CALL    FACSET      
          POP     HL          
          PUSH    DE          
          LD      DE,FLTQPI   ;PI/4
          CALL    CMP         
          JR      NC,COSCUL   
          POP     DE          
          PUSH    HL          
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          LD      E,L         
          LD      D,H         
          CALL    MUL         
          LD      DE,(SNFAC2) 
          POP     HL          
          PUSH    HL          
          CALL    LDIR5       
          LD      A,(PRCSON)  
          LD      B,A         
          LD      HL,SINTBL   
SIN6:     PUSH    BC          
          PUSH    HL          
          LD      HL,(SNFAC2) 
          LD      DE,(SNFAC3) 
          CALL    MUL         
          POP     HL          
          PUSH    HL          
          LD      DE,(SNFAC1) 
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          LD      DE,(SNFAC2) 
          CALL    MUL         
          EX      DE,HL       
          LD      HL,(SNFAC0) 
          CALL    ADDCMD         
          POP     HL          
          LD      DE,5        
          ADD     HL,DE       
          POP     BC          
          DJNZ    SIN6        
          POP     HL          
          POP     BC          
          LD      A,(SINSGN)  
          INC     HL          
          XOR     (HL)        
          CPL     
          LD      (HL),A      
          DEC     HL          
          LD      A,(PRCSON)  
          CP      08H         
          LD      A,(HL)      
          JR      Z,SIN9      
          CP      5CH         ; ADJUST
SIN8:     RET     NC          
          JP      CLRFAC      

SIN9:     CP      4DH         ; ADJUST
          JR      SIN8        

COSCUL:   LD      DE,FLTHPI   ;PI/2
          CALL    SUBCMD         
          CALL    ABS         
          POP     DE          
          PUSH    HL          
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          LD      E,L         
          LD      D,H         
          CALL    MUL         
          LD      DE,(SNFAC2) 
          CALL    LDIR1       
          POP     DE          
          PUSH    DE          
          CALL    LDIR1       
          LD      A,(PRCSON)  
          LD      B,A         
          LD      HL,COSTBL   
          JR      SIN6        

SINSGN:   DB      0           ;(was DEFS 1)

TAN:      PUSH    BC          
          PUSH    HL          
          CALL    ADDHL5      
          EX      DE,HL       
          LD      (SNFAC4),HL 
          CALL    ADDHL5      
          LD      (SNFAC5),DE 
          POP     HL          
          PUSH    HL          
          CALL    LDIR5       
          LD      HL,(SNFAC4) 
          EX      DE,HL       
          POP     HL          
          PUSH    HL          
          CALL    LDIR5       
          LD      HL,(SNFAC5) 
          CALL    SIN         
          POP     DE          
          PUSH    DE          
          CALL    LDIR5       
          LD      HL,(SNFAC4) 
          CALL    COS         
          EX      DE,HL       
          POP     HL          
          CALL    DIV         
          POP     BC          
          RET     

SINTBL:   DW      0AA7EH      
          DW      0AAAAH      
          DB      0ABH        
          DW      087AH       
          DW      8888H       
          DB      89H         
          DW      0D074H      
          DW      000DH       
          DB      0D0H        
          DW      386EH       
          DW      1DEFH       
          DB      2BH         
          DW      0D767H      
          DW      2B32H       
          DB      40H         
          DW      3060H       
          DW      3092H       
          DB      9DH         
          DW      0D758H      
          DW      9F3FH       
          DB      3AH         
          DW      4A50H       
          DW      3B96H       
          DB      82H         

COSTBL:   DW      8080H       
          DW      0000H       
          DB      00H         
          DW      2A7CH       
          DW      0AAAAH      
          DB      0ABH        
          DW      0B677H      
          DW      600BH       
          DB      0B6H        
          DW      5071H       
          DW      000DH       
          DB      0D0H        
          DW      0936BH      
          DW      7DF2H       
          DB      0BCH        
          DW      0F64H       
          DW      0C776H      
          DB      80H         
          DW      0C95CH      
          DW      0A5CBH      
          DB      46H         
          DW      5754H       
          DW      9F3FH       
          DB      3AH         

TANTBL:   DW      0AA7FH      
          DW      0AAAAH      
          DB      0ABH        
          DW      4C7EH       
          DW      0CCCCH      
          DB      0CDH        
          DW      927EH       
          DW      2449H       
          DB      92H         
          DW      637DH       
          DW      388EH       
          DB      0E4H        
          DW      0BA7DH      
          DW      8B2EH       
          DB      0A3H        
          DW      1D7DH       
          DW      0D889H      
          DB      9EH         
          DW      887DH       
          DW      8888H       
          DB      89H         
          DW      707CH       
          DW      0F0F0H      
          DB      0F1H        
          DW      0D77CH      
          DW      3594H       
          DB      0E5H        
          DW      437CH       
          DW      300CH       
          DB      0C3H        

SGN:      LD      DE,0        
          LD      A,(HL)      
          OR      A           
          JR      Z,SGNSET    
          CALL    TSTSGN      
          INC     DE          
          JR      Z,SGNSET    
          DEC     DE          
          DEC     DE          
SGNSET:   CALL    FLTHEX      
          RET     

;*----------------------------------------
;* Top of p.627 in German Listing of 2Z046
;*----------------------------------------
RAD:      LD      DE,FLTRAD   
          JR      PAI2        

PAI:      LD      DE,FLTPAI   
PAI2:     PUSH    BC          
          CALL    MUL         
          POP     BC          
          RET     

FLT2PI:   DW      4983H       ;PI*2
          DW      0DA0FH      
          DB      0A2H        
FLTPAI:   DW      4982H       ;PI
          DW      0DA0FH      
          DB      0A2H        
FLTHPI:   DW      4981H       ;PI/2
          DW      0DA0FH      
          DB      0A2H        
FLTQPI:   DW      4980H       ;PI/4
          DW      0DA0FH      
          DB      0A2H        

FLTRAD:   DW      0E7BH       
          DW      35FAH       
          DB      13H         

PEEK:     PUSH    HL          
          CALL    HLFLT       
          LD      E,(HL)      
          LD      D,0         
          POP     HL          
          CALL    FLTHEX      
          RET     

RND:      LD      A,(HL)      
          OR      A           
          JR      Z,RNDMIZ    
          CALL    TSTSGN      
          JR      Z,NORRND    
RNDMIZ:   PUSH    HL          
          LD      HL,4193H    
          LD      (SEED),HL   
          POP     HL          
          XOR     A           
          LD      R,A         
NORRND:   PUSH    BC          
          LD      DE,(SEED)   
          LD      A,R         
          XOR     D           
          RRC     A           
          RRC     A           
          RRC     A           
          LD      D,A         
          LD      A,R         
          XOR     E           
          RLC     A           
          RLC     A           
          LD      E,D         
          LD      D,A         
          LD      (SEED),DE   
          PUSH    HL          
          INC     HL          
          RES     7,D         
          LD      (HL),D      
          INC     HL          
          LD      (HL),E      
          INC     HL          
          LD      A,R         
          LD      (HL),A      
          POP     HL          
          LD      (HL),81H    
          CALL    ONESUB      
          POP     BC          
          RET     

SEED:     DW      4193H       

EXP:      PUSH    BC          
          LD      A,(HL)      
          OR      A           
          JP      Z,RETONE    
          INC     HL          
          LD      A,(HL)      
          LD      (EXPSIN),A  
          RES     7,(HL)      
          DEC     HL          
          LD      DE,LNTWOI   
          CALL    MUL         
          PUSH    HL          
          CALL    ADDHL5      
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          CALL    INT         
          PUSH    HL          
          CALL    HLFLT       
          XOR     A           
          CP      H           
          JP      NZ,ER02     
          LD      A,L         
          LD      (EXPOFF),A  
          POP     DE          
          POP     HL          
          PUSH    HL          
          CALL    SUBCMD         
          PUSH    DE          
          PUSH    HL          
          CALL    LDIR1       
          POP     DE          
          POP     HL          
          CALL    DIVTWO      
          EX      DE,HL       
          XOR     A           
          LD      B,8         
EXPLP1:   PUSH    BC          
          PUSH    AF          
          CALL    CMP         
          JR      C,EXPNL1    
          CALL    SUBCMD         
          POP     AF          
          SET     7,A         
          PUSH    AF          
EXPNL1:   POP     AF          
          RLC     A           
          EX      DE,HL       
          PUSH    AF          
          CALL    DIVTWO      
          POP     AF          
          EX      DE,HL       
          POP     BC          
          DJNZ    EXPLP1      
          LD      (EXPHBT),A  
          PUSH    DE          
          LD      DE,LNTWOA   
          LD      A,(PRCSON)  
          BIT     3,A         
          JR      NZ,EXPNL2   
          LD      DE,LNTWOB   
EXPNL2:   CALL    MUL         
          POP     DE          
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          LD      A,(PRCSON)  
          BIT     3,A         
          JP      Z,EXPSKP    
          CALL    MULTWO      
          LD      DE,FLTEN    
          CALL    ADDCMD         
          CALL    DIVTWO      
          POP     DE          
          PUSH    DE          
          CALL    MUL         
          LD      DE,FLTEN    
          CALL    DIVTWO      
          CALL    ADDCMD         
          CALL    MULTWO      
          POP     DE          
          PUSH    DE          
          CALL    MUL         
          LD      DE,FLT120   
          CALL    MUL         
          CALL    MULTWO      
          CALL    ONEADD      
          CALL    DIVTWO      
          POP     DE          
          PUSH    DE          
          CALL    MUL         
          CALL    ONEADD      
          POP     DE          
          PUSH    DE          
          CALL    MUL         
EXPSKQ:   CALL    ONEADD      
          EX      (SP),HL     
          EX      DE,HL       
          PUSH    DE          
          CALL    LDIR1       
          POP     HL          
          LD      DE,EXDTBL   
          LD      A,(EXPHBT)  
          LD      B,8         
EXPCLP:   RLC     A           
          JR      NC,SKPEXP   
          PUSH    AF          
          PUSH    BC          
          CALL    MUL         
          POP     BC          
          POP     AF          
SKPEXP:   INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          DJNZ    EXPCLP      
          LD      A,(EXPOFF)  
          ADD     A,(HL)      
          JP      C,ER02      
          LD      (HL),A      
          POP     DE          
          CALL    MUL         
          POP     BC          
          LD      A,(EXPSIN)  
          RLC     A           
          RET     NC          
          PUSH    BC          
          PUSH    DE          
          PUSH    HL          
          CALL    LDIR5       
          POP     DE          
          PUSH    DE          
          CALL    LDIR1       
          POP     HL          
          POP     DE          
          CALL    DIV         
          POP     BC          
          RET     

EXPSKP:   POP     DE          
          PUSH    DE          
          CALL    MUL         
          LD      A,(HL)      
          OR      A           
          CALL    NZ,DIVTWO   
          CALL    ADDCMD         
          JP      EXPSKQ      

EXPOFF:   DB      0           ;(was DEFS 1)
EXPSIN:   DB      0           ;(was DEFS 1)
EXPHBT:   DB      0           ;(was DEFS 1)

LOGD:     PUSH    BC          
          CALL    LOG         
          LD      DE,LOGE10   
          CALL    MUL         
          POP     BC          
          RET     

LOG:      PUSH    BC          ;LN(HL)
          CALL    TSTSGN      
          JP      NZ,ER03     
          LD      A,(HL)      
          OR      A           
          JP      Z,ER03      
          SUB     81H         
          LD      (LOGEXP),A  
          LD      (HL),81H    
          XOR     A           
          LD      B,8         
          LD      DE,EXDTBL   
LOGCLL:   PUSH    BC          
          PUSH    AF          
          CALL    CMP         
          JR      C,LOGNCL    
          PUSH    HL          
          LD      HL,40       
          ADD     HL,DE       
          EX      DE,HL       
          EX      (SP),HL     
          CALL    MUL         
          POP     DE          
          POP     AF          
          SET     7,A         
          PUSH    AF          
LOGNCL:   POP     AF          
          RLC     A           
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          INC     DE          
          POP     BC          
          DJNZ    LOGCLL      
          LD      (SNFAC0),HL 
          CALL    ADDHL5      
          EX      DE,HL       
          LD      E,A         
          LD      D,0         
          CALL    FLTHEX      
          LD      A,(HL)      
          OR      A           
          JR      Z,NOTDCR    
          SUB     08H         
          LD      (HL),A      
NOTDCR:   LD      A,(LOGEXP)  
          CP      80H         
          JR      C,LOG2      
          NEG     
LOG2:     PUSH    HL          
          CALL    ADDHL5      
          EX      DE,HL       
          LD      (SNFAC1),HL 
          LD      E,A         
          LD      D,0         
          CALL    FLTHEX      
          LD      A,(LOGEXP)  
          AND     80H         
          INC     HL          
          OR      (HL)        
          LD      (HL),A      
          DEC     HL          
          EX      DE,HL       
          POP     HL          
          CALL    ADDCMD         
          LD      A,(PRCSON)  
          LD      DE,LNTWOC   
          CP      05H         
          JR      Z,LOG3      
          LD      DE,LNTWOA   
LOG3:     CALL    MUL         
          PUSH    HL          
          LD      DE,(SNFAC1) 
          LD      HL,(SNFAC0) 
          PUSH    HL          
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          CALL    ONEADD      
          EX      (SP),HL     
          CALL    SUBCMD         
          POP     DE          
          CALL    DIV         
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          PUSH    DE          
          LD      E,L         
          LD      D,H         
          CALL    MUL         
          POP     DE          
          PUSH    HL          
          PUSH    DE          
          CALL    LDIR5       
          POP     HL          
          LD      DE,FIV3RD   
          CALL    ADDCMD         
          EX      DE,HL       
          POP     HL          
          CALL    MUL         
          LD      DE,FLTEN    
          CALL    MULTWO      
          CALL    ADDCMD         
          CALL    DIVTWO      
          EX      DE,HL       
          LD      HL,(SNFAC0) 
          CALL    MUL         
          LD      DE,TWO5TH   
          CALL    MUL         
          POP     DE          
          CALL    ADDCMD         
          POP     BC          
          RET     

LOGEXP:   DB      0           ;(was DEFS 1)

LOGE10:   DW      5E7FH       ;Log of 'e' to the base 10
          DW      0D85BH      
          DB      0A9H        

TWO5TH:   DW      4C7FH       ;2/5
          DW      0CCCCH      
          DB      0CDH        

FIV3RD:   DW      5581H       ;5/3
          DW      5555H       
          DB      56H         

EXDTBL:   DW      3581H       ;2^(1/2)
          DW      0F304H      
          DB      34H         

          DW      1881H       ;2^(1/4)
          DW      0F037H      
          DB      52H         

          DW      0B81H       ;2^(1/8)
          DW      0C195H      
          DB      0E4H        

          DW      0581H       ;2^(1/16)
          DW      0C3AAH      
          DB      68H         

          DW      0281H       ;2^(1/32)
          DW      86CDH       
          DB      99H         

          DW      0181H       ;2^(1/64)
          DW      0D164H      
          DB      0F4H        

          DW      0081H       ;2^(1/128)
          DW      0EDB1H      
          DB      50H         

          DW      0081H       ;2^(1/256)
          DW      0D758H      
          DB      0D3H        

          DW      3580H       
          DW      0F304H      
          DB      34H         

          DW      5780H       
          DW      0FC44H      
          DB      0CBH        

          DW      6A80H       
          DW      0C6C0H      
          DB      0E8H        

          DW      7580H       
          DW      7D25H       
          DB      16H         

          DW      7A80H       
          DW      0B283H      
          DB      0DCH        

          DW      7D80H       
          DW      0C3EH       
          DB      0DH         

          DW      7E80H       
          DW      119EH       
          DB      5DH         

          DW      7F80H       
          DW      0CB4EH      
          DB      5AH         

FLT120:   DW      087AH       
          DW      8888H       
          DB      89H         

LNTWOA:   DW      3180H       ;LN(2)                
          DW      1772H       
          DB      0F8H        

LNTWOB:   DW      3180H       ;LN(2) again
          DW      1772H       
          DB      0F8H        

LNTWOI:   DW      3881H       ;1/LN(2)
          DW      3BAAH       
          DB      2AH         

LNTWOC:   DW      3180H       ;LN(2) again !
          DW      1772H       
          DB      0F8H        

SNFAC0:   DB      0,0         ;(was DEFS 2)
SNFAC1:   DB      0,0         ;(was DEFS 2)
SNFAC2:   DB      0,0         ;(was DEFS 2)
SNFAC3:   DB      0,0         ;(was DEFS 2)
SNFAC4:   DB      0,0         ;(was DEFS 2)
SNFAC5:   DB      0,0         ;(was DEFS 2)

;*       END of original module FLOAT.ASM
;*============================================================================
;*     START of original module MUSIC.ASM
;*----------------------------
;* MZ-800 BASIC  Music command
;* FI:MUSIC  ver 1.0A 7.18.84
;* Programmed by T.Miho
;*----------------------------

;*DIRARE: EQU    27D0H          ;already defined
;*NMAX:   EQU    83             ;already defined (µ›√≤ max)

;*-------------------------
;* SOUND m,l /  SOUND=(r,d)
;*-------------------------
SOUND:    CALL    TEST1       ;=
          DB      0F4H        
          JR      NZ,SOUND1   
          CALL    HCH28H      ;(
          CALL    IBYTE       
          CP      16          
          SET     7,A         
          JR      SOUND2      

SOUND1:   CALL    IBYTE       
          CP      NMAX+1      
SOUND2:   JP      NC,ER03     
          PUSH    AF          
          CALL    HCH2CH      ;,
          CALL    IDEEXP      
          POP     AF          
          PUSH    AF          
          OR      A           
          CALL    M,HCH29H    ;)
          POP     AF          
          PUSH    HL          
          RST     18H         
          DB      .SOUND      
          POP     HL          
          RET     

;*----------------------
;* TEMPO n  (n= 1 to 7 )
;*----------------------
TEMPO:    CALL    IBYTE       
          DEC     A           
          CP      7           
          INC     A           
          JP      ATEMPO      

;*-------------------------------
;* NOISE  A1$;A2$;B1$;...
;* MUSIC  A1$;A2$;...;A6$;B1$;...
;*-------------------------------
NOISE:    LD      A,08H       ;pattern (3)
          DB      1           

MUSIC:    LD      A,07H       ;pattern (0,1,2)
          LD      (MUNOF),A   ;channel pattern
          CALL    HLFTCH      
          LD      B,3         
          CP      0BEH        ;WAIT
          JR      Z,MCTRLA    
          DEC     B           
          CP      99H         ;STOP
          JR      Z,MCTRLA    
          CP      0DCH        ;INIT
          JR      NZ,MUSIC1   
          LD      DE,MUSCHO   
          LD      B,4         
          LD      A,2         
          CALL    QSETDE      
MCTRLA:   PUSH    HL          
          RST     18H         
          DB      .MCTRL      
          POP     HL          
          INC     HL          
          RET     

MUSIC1:   CALL    ENDCHK      
          RET     Z           
          XOR     A           
          LD      (MUDNO),A   
          LD      (MUCHNO),A  
          LD      B,A         
          LD      A,0DH       
          LD      DE,DIRARE   
          LD      (MMBU1A),DE 
          LD      (DE),A      
          CALL    QSETDE      
          LD      A,(MUNOF)   
          LD      (MUNOF2),A  
MUSI1:    LD      DE,MUNOF2   
          LD      A,(DE)      
          RRC     A           
          LD      (DE),A      
          PUSH    AF          
          LD      B,0         
          JR      NC,MUSI3    
          CALL    HLFTCH      
          CP      ';'         
          JR      Z,MUSI3     
          CALL    STREXP      
MUSI3:    PUSH    HL          
          LD      A,(MUCHNO)  
          CP      4           
          JP      Z,ER01      ;Ch no over
          INC     A           
          LD      (MUCHNO),A  
          INC     B           
          JP      Z,ER05      
          LD      A,(MUDNO)   
          ADD     A,B         
          JP      C,ER05      ;data no. over
          LD      (MUDNO),A   
          LD      HL,(MMBU1A) 
          CALL    LDHLDE      
          LD      (MMBU1A),HL 
          DEC     HL          
          LD      (HL),0DH    
          POP     HL          
          POP     AF          
          JR      NC,MUSI1    
          CALL    ENDCHK      
          JR      Z,MUSI4     
          CALL    TEST1       
          DB      ','         
          JR      Z,MUSI4     
          CALL    TEST1       
          DB      ';'         
          JR      MUSI1       

MUSI4:    PUSH    HL          
          LD      HL,DIRARE   
          PUSH    HL          
          POP     IX          
          LD      IY,MUSCHO   
          LD      B,4         
MUSI5:    PUSH    BC          
          PUSH    HL          
          PUSH    IX          
          POP     HL          
          LD      DE,DIRARE   
          XOR     A           
          SBC     HL,DE       
          LD      (IY+4),L    
          POP     HL          
          LD      (MUSI6+1),SP 
          CALL    MML.EN      
MUSI6:    LD      SP,0        ;xxx
          POP     BC          
          INC     HL          
          INC     IY          
          DJNZ    MUSI5       
          LD      B,3         
          RST     18H         ;MWAIT
          DB      .MCTRL      
MUSI8:    LD      BC,100H     
          LD      HL,DIRARE   
          LD      DE,DIRARE+700H 
          LDIR    
          LD      B,4         
          LD      HL,MMCHDA   
MUSDS:    LD      E,(HL)      
          LD      D,0         
          INC     HL          
          PUSH    HL          
          LD      HL,DIRARE+700H 
          ADD     HL,DE       
          LD      A,(HL)      
          CP      0FFH        
          JR      Z,MUSDS1    
          LD      A,4         
          SUB     B           
          PUSH    BC          
          EX      DE,HL       
          RST     18H         
          DB      .PLAY       
          POP     BC          
MUSDS1:   POP     HL          
          DJNZ    MUSDS       
          LD      B,1         
          RST     18H         ;PSGON
          DB      .MCTRL      
          POP     HL          
          JP      MUSIC1      

MUSCHO:   DW      0202H       ;Oct data eny ch.
          DW      0202H       

MMCHDA:   DB      0,0,0,0     ;Play & Noise Data addr (was DEFS 4)

MUDNO:    DB      0           ;total data No. (was DEFS 1)
MUCHNO:   DB      0           ;ch no.(was DEFS 1)
MMBU1A:   DB      0,0         ;MML data buffer (was DEFS 2)
MUNOF:    DB      0           ;07:MUSIC 08:NOISE (was DEFS 1)
MUNOF2:   DB      0           ;rotate(MUNOF) (was DEFS 1)

;*---------------------------
;* MML(HL) => IOCSM(IX) trans
;* END code=00H or 0DH or C8H
;*---------------------------

MML.EN:   CALL    MML.WC      
MML.E0:   CALL    HLFTCH      
          CALL    MMAGCH      
          JR      C,MMTCAL    
          LD      C,0         
          CALL    MML.AG      ;String:A-G
          JR      MMTCA9      

MMTCAL:   CALL    MMENCH      
          JP      Z,MMLEND    
          LD      B,12        
          EX      DE,HL       
          LD      HL,MMTCAT   ;Call address table
MMTCA0:   CP      (HL)        ;cmp chr
          INC     HL          
          JR      Z,MMTCAJ    
          DEC     B           
          JP      Z,ER03      
          INC     HL          
          INC     HL          
          JR      MMTCA0      
MMTCAJ:   LD      C,(HL)      
          INC     HL          
          LD      B,(HL)      
          EX      DE,HL       
          INC     HL          
          CALL    .BC         
MMTCA9:   JP      C,ER03      
          JR      MML.E0      

.BC:      PUSH    BC          
          RET     

MMTCAT:   DB      '#'         
          DW      MML.SH      
          DB      '+'         
          DW      MML.UO      
          DB      0D7H        
          DW      MML.UO      
          DB      '-'         
          DW      MML.DO      
          DB      0CFH        
          DW      MML.DO      
          DB      'O'         
          DW      MML.O       
          DB      'N'         
          DW      MML.N       
          DB      'T'         
          DW      MML.T       
          DB      'V'         
          DW      MML.V       
          DB      'S'         
          DW      MML.S       
          DB      'M'         
          DW      MML.M       
          DB      'L'         
          DW      MML.L       

MML.DO:   LD      C,0F4H      ;-
          DB      11H         

MML.UO:   LD      C,12        ;+
          CALL    TEST1       
          DB      '#'         
          JR      NZ,LD.DE    
          INC     C           
LD.DE:    DB      11H         

MML.SH:   LD      C,1         ;#
          CALL    HLFTCH      
          CALL    MMAGCH      
          RET     C           
MML.AG:   LD      B,A         
          INC     HL          
          CALL    MML.DL      
          CCF     
          CALL    C,MML.L1    
          RET     C           
          LD      A,B         
          CP      'R'         
          JR      Z,MML.R     
          PUSH    HL          
          LD      HL,ONCTT-41H ;A-G
          CALL    ADDHLA      
          LD      B,(IY+0)    
          INC     B           
          LD      A,(HL)      
          POP     HL          
          ADD     A,C         
          SUB     12          
MML.11:   ADD     A,12        
          DJNZ    MML.11      
          JR      MML.N0      

MML.R:    XOR     A           
MML.R0:   PUSH    AF          
          CALL    MML.WO      
          POP     AF          
MML.W1:   LD      (IX+0),A    
          INC     IX          
          RET     

MML.O:    CALL    MML.DL      ;O
          JR      NC,MML.O1   
          LD      A,2         
MML.O1:   CP      7           
          CCF     
          RET     C           
          LD      (IY+0),A    ;oct No.
          RET     

MML.N:    CALL    MML.DL      ;N
          RET     C           
MML.N0:   CP      NMAX+1      
          CCF     
          RET     C           
          JR      MML.R0      

MML.T:    CALL    MML.DL      ;T
          JR      NC,MML.T1   
          LD      A,4         
MML.T1:   DEC     A           
          CP      7           
          CCF     
          RET     C           
          ADD     A,6AH       
          LD      (MML.W),A   
          RET     

MML.V:    CALL    MML.DL      ;V
          JR      NC,MML.V1   
          LD      A,15        
MML.V1:   CP      16          
          CCF     
          RET     C           
          ADD     A,80H       
          LD      (MML.W+1),A 
          RET     

MML.L:    CALL    MML.DL      ;L
          JR      NC,MML.L1   
          LD      A,5         
MML.L1:   CP      10          
          CCF     
          RET     C           
MML.L2:   ADD     A,60H       
          LD      (MML.W+2),A 
          RET     

MML.S:    CALL    MML.DL      ;S
          RET     C           
          CP      9           
          CCF     
          RET     C           
          ADD     A,90H       
          LD      (MML.W+3),A 
          RET     

MML.M:    CALL    MML.DL      ;M
          RET     C           
          OR      A           
          SCF     
          RET     Z           
          LD      B,A         
          LD      C,0A0H      
          LD      (MML.W+4),BC 
          OR      A           
          RET     

MML.DL:   CALL    HLFTCH      
          CALL    MMENCH      
          SCF     
          CALL    NZ,TSTNUM   
          RET     C           ;RET not number
          RST     18H         
          DB      .DEASC      
          JP      DCHECK      

MMAGCH:   CP      'R'         ;A-G & R check
          RET     Z           
          CP      'A'         
          RET     C           
          CP      'H'         
          CCF     
          RET     

MMENCH:   OR      A           
          RET     Z           
          CP      0DH         
          RET     Z           
          CP      0C8H        
          RET     

MMLEND:   CALL    MML.WO      
          LD      A,0FFH      ;Music Data end
          CALL    MML.W1      
          JP      MUSI6       

MML.WO:   LD      DE,MML.W    
          LD      B,6         
MML.W2:   LD      A,(DE)      
          OR      A           
          CALL    NZ,MML.W1   
          INC     DE          
          DJNZ    MML.W2      
MML.WC:   LD      DE,MML.W    
          LD      B,6         
          JP      QCLRDE      

ONCTT:    DB      9           ;A
          DB      11          ;B
          DB      0           ;C
          DB      2           ;D
          DB      4           ;E
          DB      5           ;F
          DB      7           ;G
;*
MML.W:    DB      0           ;T
          DB      0           ;V
          DB      0           ;L
          DB      0           ;S
          DB      0           ;Mn
          DB      0           

;*       END of original module MUSIC.ASM
;*============================================================================
;*     START of original module WORKQ.ASM
;*---------------------------
;* MZ-800 BASIC  Work area
;* FI:WORKQ  ver 1.0A 9.25.84
;* Programmed by T.Miho
;*---------------------------
;* The Label SWAPDS points to the start of the SWAP data

SWAPDS:   
NXTLPT:   DB      0,0         ;(was DEFS 2)
EDLINE:   DB      0,0         ;(was DEFS 2)
EDSTEP:   DB      0,0         ;(was DEFS 2)
LNOBUF:   DB      0,0         ;(was DEFS 2)
;*
ERRCOD:   DB      0           ;(was DEFS 1)
ERRORF:   DB      0           ;(was DEFS 1)
ERRLNO:   DB      0,0         ;(was DEFS 2)
ERRLPT:   DB      0,0         ;(was DEFS 2)
ERRPNT:   DB      0,0         ;(was DEFS 2)
ERRORV:   DB      0,0         ;(was DEFS 2)
;*
DATFLG:   DB      0           ;(was DEFS 1)
DATPTR:   DB      0,0         ;(was DEFS 2)
SWAPDE:   
;* The Label SWAPDE comes 1 after the end of the SWAP data

SWAPBY:   DW      SWAPDE-SWAPDS ;number of SWAP data bytes
SWAPNB:   DW      SWAPDS-SWAPDE ; -(SWAPBY)

STACK:    DB      0,0         ;(was DEFS 2)
TEXTPO:   DB      0,0         ;(was DEFS 2)
LSWAP:    DB      0           

DGBFM1:   DB      0           ;(was DEFS 1)
DGBF00:   DB      0,0,0,0,0,0,0 ;(was DEFS 7)

DGBF07:   DB      0           ;(was DEFS 1)
DGBF08:   DB      0,0,0       ;(was DEFS 3)
DGBF11:   DB      0           ;(was DEFS 1)
DGBF12:   DB      0,0,0,0     ;(was DEFS 4)
DGBF16:   DB      0           ;(was DEFS 1)
DGBF17:   DB      0,0,0,0,0,0,0,0 ;(was DEFS 8)

DGBF25:   DB      0,0,0,0,0,0,0,0 ;(was DEFS 25)

          DB      0,0,0,0,0,0,0,0 

          DB      0,0,0,0,0,0,0,0 

          DB      0           

PRCSON:   DB      8           
ZFAC:     DB      0,0,0,0,0,0,0,0 ;(was DEFS 8)

ZFAC1:    DB      0,0,0,0,0,0,0,0 ;(was DEFS 8)

ZFAC2:    DB      0,0,0,0,0,0,0,0 ;(was DEFS 8)


;*----------------------------------------------------------------------
;*   Opening Screen for BASIC MZ-5Z009 v1.0B (overwritten after boot-up)
;*----------------------------------------------------------------------
IMDBUF:   DB      16H         ;CLR
          DB      0DH         
          DB      " ◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊◊ " 
          DB      "   BASIC INTERPRETER  MZ-5Z009" 
TTJPEX:   DB      " V1.0B  "  
          DB      0DH         
          DB      "   COPYRIGHT (C) 1984 BY SHARP CORP.    " 
          DB      " œœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœœ " 
          DB      0DH         
          DB      " 22340 BYTES FREE" 
          DW      0D0DH       
H9F71:    DB      0           
H9F72:    DB      0,0,0,0,0,0,0,0 ;(was DEFS 5CH = 92)
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0,0,0,0,0 
          DB      0,0,0,0     

;*       END of original module WORKQ.ASM
;*===========================================================================
;*     START of original module PLT.ASM (optional) 
;*------------------------------
;* MZ-800 BASIC  Plotter package
;* FI:PLT  ver 1.0A 8.25.84
;* Programmed by T.Miho
;*------------------------------
          ORG     9FCEH       

;*P.PLT: EQU    0               ;This EQUATE defined in a previous module
PNCHNM:   DB      'N'         ;N,S,L

NEWON:    LD      BC,ER59A    
          LD      DE,NEWONT   ;NEW ON
NEWON2:   LD      A,(DE)      ; omit plotter
          INC     DE          
          ADD     A,A         
          JR      Z,NEWON4    
          LD      HL,SJPTBL   
          CALL    ADDHLA      
          LD      (HL),C      
          INC     HL          
          LD      (HL),B      
          JR      NEWON2      

NEWON4:   XOR     A           ; PLOT OFF
          LD      (INPFLG),A  
          LD      A,(PNMODE)  
          DEC     A           
          CALL    NZ,MODETX   ; PMODE TX
          LD      HL,NEWAD2   
NEWON9:   LD      (TEXTST),HL 
          RET     

NEWONT:   DB      0A2H        ;PMODE
          DB      0A3H        ;PSKIP
          DB      0A4H        ;PLOT
          DB      0A5H        ;PLINE
          DB      0A6H        ;RLINE
          DB      0A7H        ;PMOVE
          DB      0A8H        ;RMOVE
          DB      0AEH        ;PCOLOR
          DB      0AFH        ;PHOME
          DB      0B0H        ;HSET
          DB      0B1H        ;GPRINT
          DB      0B3H        ;AXIS
          DB      0BBH        ;PCIRCLE
          DB      0BCH        ;PTEST
          DB      0BDH        ;PAGE
          DB      0           

LPTTMD:   LD      B,1         ;Check text mode
          JR      LPTMD       

LPTGMD:   LD      B,2         ;Check graph mode
LPTMD:    LD      A,(PNMODE)  
          CP      B           
          RET     Z           
          JP      LPTMER      

NEWAD2:   
PMODE:    CALL    MODE0       ;PMODE command
          XOR     A           
          LD      (LPOSB),A   ;LPT TAB
          RET     

MODE0:    LD      A,(INPFLG)  
          OR      A           
          JP      NZ,LPTMER   
          CALL    PPCHCK      
          CALL    TEST1       
          DB      'G'         
          JP      Z,PGRAPH    
          CALL    TESTX       
          DB      'T'         
          CALL    TEST1       
          DB      'N'         
          JR      Z,TEXTN     
          CALL    TEST1       
          DB      'L'         
          JR      Z,TEXTN     
          CALL    TESTX       
          DB      'S'         
TEXTN:    LD      (PNCHNM),A  
          CALL    CHKEND      
          CALL    OUTA3H      
MODETX:   LD      A,1         
          LD      (PNMODE),A  
          RST     18H         
          DB      .LPTOT      
          LD      A,(PNCHNM)  
          CP      'N'         
          RET     Z           
          CP      'L'         
          LD      A,0BH       
          JR      Z,XLPTOT    
T80CH:    LD      A,9         
          RST     18H         
          DB      .LPTOT      
          RST     18H         
          DB      .LPTOT      
XLPTOT:   RST     18H         
          DB      .LPTOT      
          RET     

OUTA3H:   LD      A,0AH       
          RST     18H         
          DB      .LPTOT      
          LD      A,3         
          JR      XLPTOT      

PGRAPH:   INC     HL          ;Graphic mode
          CALL    CHKEND      
          LD      A,2         
          LD      (PNMODE),A  
          JR      XLPTOT      

SKIP:     CALL    PPCHCK      
          CALL    LPTTMD      ;SKIP n
          CALL    IDEEXP      
          LD      A,E         
          OR      A           
          RET     Z           
          CP      0ECH        ;-20
          JR      NC,SKIPPS   
          CP      21          
          JP      NC,ER03     
SKIPPS:   CALL    CHKEND      
          BIT     7,E         
          JR      NZ,SKIPD    
SKIPI:    LD      A,0AH       
          RST     18H         
          DB      .LPTOT      
          DEC     E           
          JR      NZ,SKIPI    
          RET     

SKIPD:    LD      A,03H       
          RST     18H         
          DB      .LPTOT      
          INC     E           
          JR      NZ,SKIPD    
          RET     

PNMX99:   PUSH    HL          
          LD      HL,999      
          JR      PNMX1       

PNMX48:   PUSH    HL          
          LD      HL,480      
PNMX1:    PUSH    HL          
          ADD     HL,DE       
          POP     HL          
          JR      C,PNMX2     
          SBC     HL,DE       
          JP      C,ER03      
PNMX2:    POP     HL          
          RET     

PLINE:    LD      C,'D'       ; PLINE %n,x,y
          DB      11H         
RLINE:    LD      C,'J'       ; RLINE %n,x,y"
          DB      11H         
PMOVE:    LD      C,'M'       ; PMOVE x,y
          DB      11H         
RMOVE:    LD      C,'R'       ; RMOVE x,y
          CALL    PPCHCK      
          CALL    LPTGMD      
          LD      A,C         
          LD      (LINEC+1),A 
          CP      'M'         
          JR      NC,LINE5    ;"M","R"
          CALL    TEST1       
          DB      '%'         
          JR      NZ,LINE5    
          CALL    IBYTE       
          LD      A,E         
          DEC     A           
          CP      16          
          JP      NC,ER03     
          DEC     DE          
          LD      A,'L'       
          RST     18H         
          DB      .LPTOT      
          CALL    NUMPLT      
          CALL    LPTCR       
          CALL    ENDCHK      
          RET     Z           
          CALL    CH2CH       
LINE5:    CALL    IDEEXP      
          CALL    CH2CH       
          CALL    PNMX48      
          PUSH    DE          
          CALL    IDEEXP      
          CP      ','         
          JR      Z,LINEXY    
          CALL    CHKEND      
LINEXY:   CALL    PNMX99      
          POP     BC          
          PUSH    DE          
LINEC:    LD      A,0         ;Plotter command
          RST     18H         
          DB      .LPTOT      
          LD      E,C         
          LD      D,B         
          CALL    NUMPLT      ;X
          CALL    LPTCOM      
          POP     DE          
          CALL    NUMPLT      ;Y
          CALL    LPTCR       
          CALL    ENDCHK      
          RET     Z           
          INC     HL          
          JR      LINE5       

PCOLOR:   CALL    PPCHCK      
          CALL    IBYTE       ;PCOLOR n
          LD      A,E         
          CP      4           
          JP      NC,ER03     
          CALL    CHKEND      
          LD      A,(PNMODE)  
          CP      2           
          JR      Z,PNMBR2    
          CALL    OUTA3H      
          LD      A,2         
          RST     18H         
          DB      .LPTOT      
          CALL    PNMBR2      
          JP      PRTTX       

PNMBR2:   LD      A,'C'       
          RST     18H         
          DB      .LPTOT      
          LD      A,E         
          OR      30H         
          RST     18H         
          DB      .LPTOT      
LPTCR:    LD      A,0DH       
          JR      LPTTX       

LPTCOM:   LD      A,','       
LPTTX:    RST     18H         
          DB      .LPTOT      
          RET     

PHOME:    LD      C,'H'       
          DB      11H         
HSET:     LD      C,'I'       
          CALL    LPTGMD      ;PHOME / HSET
          CALL    CHKEND      
          LD      A,C         
          JR      LPTTX       ;WAS JP YLPTOT !! (error in original source code)

GPRINT:   CALL    PPCHCK      
          CALL    LPTGMD      ;GPRINT [n,s],x$
          CALL    TEST1       
          DB      '['         
          JR      NZ,SYMBL2   
          CALL    IBYTE       
          CP      64          
          JP      NC,ER03     
          PUSH    DE          
          CALL    HCH2CH      
          CALL    IBYTE       
          CP      4           
          JP      NC,ER03     
          PUSH    DE          
          CALL    TESTX       
          DB      ']'         
          POP     BC          
          POP     DE          
          PUSH    BC          
          LD      A,'S'       
          RST     18H         
          DB      .LPTOT      
          CALL    NUMPLT      
          CALL    LPTCOM      
          POP     DE          
          LD      A,'Q'       
          RST     18H         
          DB      .LPTOT      
          CALL    NUMPLT      
          CALL    LPTCR       
          CALL    ENDCHK      
          RET     Z           
          CALL    CH2CH       
SYMBL2:   CALL    STREXP      
          CALL    ENDCHK      
          JR      Z,SYMBL5    
          CALL    CH2CH       
          DEC     HL          
SYMBL5:   LD      A,B         
          OR      A           
          JR      Z,SYMBL4    
          LD      A,'P'       
          RST     18H         
          DB      .LPTOT      
SYMBL3:   LD      A,(DE)      
          RST     18H         
          DB      .LPTOT      
          INC     DE          
          DJNZ    SYMBL3      
          CALL    LPTCR       
SYMBL4:   CALL    ENDCHK      
          RET     Z           
          INC     HL          
          JR      SYMBL2      

AXIS:     CALL    LPTGMD      ;AXIS x,p,r
          CALL    IBYTE       
          CP      2           
          JP      NC,ER03     
          PUSH    AF          
          CALL    HCH2CH      
          CALL    IDEEXP      
          PUSH    DE          
          CALL    CH2CH       
          CALL    IBYTE       
          OR      A           
          JP      Z,ER03      
          CALL    CHKEND      
          LD      A,'X'       
          RST     18H         
          DB      .LPTOT      
          POP     BC          
          POP     AF          
          PUSH    DE          
          PUSH    BC          
          OR      30H         
          RST     18H         
          DB      .LPTOT      
          CALL    LPTCOM      
          POP     DE          
          CALL    PNMX99      
          CALL    NUMPLT      
          CALL    LPTCOM      
          POP     DE          
          CALL    NUMPLT      
          JP      LPTCR       

PCIRCLE:  CALL    LPTGMD                       ;PCIRCLE x,y,r,s,e,d
          PUSH    HL          
          LD      DE,0        
          LD      HL,CRS      
          CALL    FLTHEX      
          LD      DE,360      
          LD      HL,CRE      
          CALL    FLTHEX      
          LD      HL,FLTEN    
          LD      DE,CRTEN    
          CALL    LDIR5       
          POP     HL          
          CALL    EXPR        ;X
          CALL    CH2CH       
          PUSH    HL          
          LD      HL,CRX      
          EX      DE,HL       
          CALL    LDIR5       
          POP     HL          
          CALL    EXPR        ;Y
          CALL    CH2CH       
          PUSH    HL          
          LD      HL,CRY      
          EX      DE,HL       
          CALL    LDIR5       
          POP     HL          
          CALL    EXPR        ;R
          PUSH    HL          
          PUSH    AF          
          LD      HL,CRR      
          EX      DE,HL       
          CALL    LDIR5       
          LD      A,(CRR+1)   
          RLCA    
          JP      C,ER03      
          POP     AF          
          CP      ','         
          JR      NZ,CIREND   
          POP     HL          
          INC     HL          
          CALL    EXPR        ;S
          PUSH    HL          
          PUSH    AF          
          LD      HL,CRS      
          EX      DE,HL       
          CALL    LDIR5       
          POP     AF          
          CP      ','         
          JR      NZ,CIREND   
          POP     HL          
          INC     HL          
          CALL    EXPR        ;E
          PUSH    HL          
          PUSH    AF          
          LD      HL,CRE      
          EX      DE,HL       
          CALL    LDIR5       
          POP     AF          
          CP      ','         
          JR      NZ,CIREND   
          POP     HL          
          INC     HL          
          CALL    EXPR        ;D
          PUSH    HL          
          LD      HL,CRTEN    
          EX      DE,HL       
          CALL    LDIR5       
          LD      A,(CRTEN+1) 
          RLCA    
          JP      C,ER03      
CIREND:   POP     HL          
          CALL    CHKEND      
          PUSH    HL          
          LD      HL,CRE      
          LD      DE,CRS      
          LD      A,(CRTEN)   
          OR      A           
          CALL    NZ,CMP      
          JP      C,ER03      
          CALL    CRXYRS      ;CAL X,Y
          LD      HL,CRXX     ;MOVE X,Y
          LD      (CRMOVX+1),HL 
          LD      HL,CRYY     
          LD      (CRMOVY+1),HL 
          CALL    CRMOVE      
          LD      A,(CRTEN)   
          OR      A           
          JR      Z,CREDLI    
CRCLP:    LD      HL,CRS      ;S+D
          LD      DE,CRTEN    
          CALL    ADDCMD         
          LD      DE,CRE      
          CALL    CMP         
          JR      NC,ENCRCL   
          CALL    CRXYRS      
          CALL    CRLINE      
          RST     18H         
          DB      .BREAK      
          JR      NZ,CRCLP    
          POP     HL          
          RET     

ENCRCL:   CALL    CREDST      
          CALL    CRLINE      
          POP     HL          
          RET     

CREDST:   LD      HL,CRE      
          LD      DE,CRS      
          LD      BC,5        
          LDIR    
          JR      CRXYRS      

CREDLI:   LD      HL,CRX      
          LD      (CRMOVX+1),HL 
          LD      HL,CRY      
          LD      (CRMOVY+1),HL 
          CALL    CRLINE      
          CALL    CREDST      
          LD      HL,CRXX     
          LD      (CRMOVX+1),HL 
          LD      HL,CRYY     
          LD      (CRMOVY+1),HL 
          CALL    CRLINE      
          POP     HL          
          RET     

CRLINE:   LD      A,'D'       
          DB      21H         
CRMOVE:   LD      A,'M'       
          PUSH    AF          
CRMOVX:   LD      HL,CRX      
          CALL    HLFLT       
          PUSH    HL          
          EX      DE,HL       
          CALL    PNMX99      
CRMOVY:   LD      HL,CRY      
          CALL    HLFLT       
          PUSH    HL          
          EX      DE,HL       
          CALL    PNMX99      
          POP     HL          
          POP     DE          
          POP     AF          
          RST     18H         
          DB      .LPTOT      
          PUSH    HL          
          CALL    NUMPLT      
          CALL    LPTCOM      
          POP     DE          
          CALL    NUMPLT      
          JP      LPTCR       

CRXYRS:   LD      DE,(INTFAC) 
          LD      HL,CRS      
          CALL    LDIR5       
          LD      HL,(INTFAC) 
          CALL    RAD         
          CALL    COS         
          LD      DE,CRR      
          CALL    MUL         
          LD      DE,CRX      
          CALL    ADDCMD         
          LD      DE,CRXX     
          CALL    LDIR5       
          LD      DE,(INTFAC) 
          LD      HL,CRS      
          CALL    LDIR5       
          LD      HL,(INTFAC) 
          CALL    RAD         
          CALL    SIN         
          LD      DE,CRR      
          CALL    MUL         
          LD      DE,CRY      
          CALL    ADDCMD         
          LD      DE,CRYY     
          JP      LDIR5       

CRX:      DB      0,0,0,0,0   ;(was DEFS 5)

CRY:      DB      0,0,0,0,0   ;(was DEFS 5)

CRR:      DB      0,0,0,0,0   ;(was DEFS 5)

CRS:      DB      0,0,0,0,0   ;(was DEFS 5)

CRE:      DB      0,0,0,0,0   ;(was DEFS 5)

CRTEN:    DB      0,0,0,0,0   ;(was DEFS 5)

CRXX:     DB      0,0,0,0,0   ;(was DEFS 5)

CRYY:     DB      0,0,0,0,0   ;(was DEFS 5)

          DB      0,0,0,0,0   ;(was DEFS 5)


NUMPLT:   PUSH    AF          
          PUSH    HL          
          LD      HL,(INTFAC) 
          CALL    FLTHEX      
          CALL    CVNMFL      
          RST     18H         
          DB      .COUNT      
NUMPL2:   LD      A,(DE)      
          RST     18H         
          DB      .LPTOT      
          INC     DE          
          DJNZ    NUMPL2      
          POP     HL          
          POP     AF          
          RET     

TEST:     CALL    PPCHCK      
          CALL    LPTTMD      ;TEST command
          CALL    CHKEND      
          LD      A,04H       
          RST     18H         
          DB      .LPTOT      
          RET     

PAGE:     CALL    LPTTMD      ;PAGE n
          CALL    IDEEXP      
          LD      A,E         
          OR      A           
          JP      Z,ER03      
          CP      73          
          JP      NC,ER03     
          CALL    CHKEND      
          LD      A,9         
          RST     18H         
          DB      .LPTOT      
          RST     18H         
          DB      .LPTOT      
          LD      A,(PSEL)    
          BIT     P.PLT,A     
          JR      Z,PAGE2     
          CALL    NUMPLT      ;Plotter only
          JP      LPTCR       

PAGE2:    LD      A,E         ;Except plotter
          LD      DE,KEYBUF   
          CALL    HEXACC      
          DEC     DE          
          DEC     DE          
          LD      A,(DE)      
          RST     18H         
          DB      .LPTOT      
          INC     DE          
          LD      A,(DE)      
          RST     18H         
          DB      .LPTOT      
          RET     

PLOT:     LD      A,(HL)      
          CP      9DH         ;PLOT ON/OFF
          JR      Z,PLOT2     
          CP      0A1H        ;OFF
          JP      NZ,ER01     
          XOR     A           
PLOTOK:   LD      (INPFLG),A  
          INC     HL          
          RET     

PLOT2:    CALL    LPTTMD      
          CALL    PPCHCK      
          LD      A,(PNCHNM)  
          CP      'L'         
          JP      Z,LPTMER    
          CALL    PRTTX       
PL40C:    LD      A,(INPFLG)  
          OR      A           
          JR      NZ,PLOTOK   
          CALL    CONSOI      
          LD      A,16H       
          RST     18H         
          DB      .CRT1C      
          OR      01H         
          JR      PLOTOK      

PRTTX:    LD      A,1         
          RST     18H         
          DB      .LPTOT      
          LD      A,(CRTMD2)  
          CP      3           
          RET     C           
          CALL    T80CH       
          RET     

PPCHCK:   LD      A,(PSEL)    
          BIT     P.PLT,A     ;if not plotter
          JP      Z,LPTMER    ; then err
          RET     

NEWAD0:   
BASICEND:
;*       END of original module PLT.ASM and of Sharp MZ-800 QD BASIC MZ-5Z009
;*============================================================================
