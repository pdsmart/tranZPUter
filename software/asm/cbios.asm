;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This is the CPM CBIOS for the Sharp MZ80A hardware plus RFS/80 char upgrades.
;-                  It makes extensive use of the paged roms to add functionality and conserve
;-                  RAM for the CPM applications.
;-
;- Credits:         Some of the comments and parts of the standard CPM deblocking/blocking algorithm 
;-                  come from the Z80-MBC2 project, (C) SuperFabius.
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

            ; Bring in additional macros.
            INCLUDE "CPM_Definitions.asm"
            INCLUDE "Macros.asm"

            ; Start of the CBIOS area is RAM for variables, disk parameters and scratch areas and buffers.
            ; 2K is provided for CBIOS RAM.
            ;
            ORG     CBIOSSTART


            ; The CBIOS code resides in Memory mode 16 andstarts at 0xF000:0xF7FFF, the common variable and
            ; buffer area is stored in the top 2K, ie. 0xF800:0xFFFF. The CBIOS code is mainly hooks, the main
            ; logic is stored in the bank 0x0000:0xD000 in Memory mode 17. Memory mode 16 is a contiguous block
            ; of RAM from 0x0000:0xFFFF, all Sharp MZ80A hardware is paged out.
            ;
            ; One caveat due to the FDC controller, blocks 0xF3C0-0xF3FF and 0xF7C0-0xF7FF 
            ; are not useable as the code in locations 0xF3FE:0xF3FF and 0xF7FE:0xF7FF are
            ; hardware controlled by the floppy controller. The design of the tranZPUter only
            ; allows RAM configuration down to 64byte chunks hence the 2x64byte blocks being 
            ; unuseable.

            ;-------------------------------------------------------------------------------
            ;                                                                              
            ;  BIOS jump table                                                             
            ;                                                                              
            ;-------------------------------------------------------------------------------
            JP      ?BOOT_
            JP      ?WBOOT_
            JP      ?CONST_
            JP      ?CONIN_
            JP      ?CONOUT_
            JP      ?LIST_
            JP      ?PUNCH_
            JP      ?READER_
            JP      ?HOME_
            JP      ?SELDSK_
            JP      ?SETTRK_
            JP      ?SETSEC_
            JP      ?SETDMA_
            JP      ?READ_
            JP      ?WRITE_
            JP      ?LISTST_
            JP      ?SECTRN_
            JP      ?DEBUG_

            ;-------------------------------------------------------------------------------
            ; TIMER INTERRUPT                                                                      
            ;                                                                              
            ; This is the RTC interrupt, which interrupts every 100msec. RTC is maintained
            ; by keeping an in memory count of seconds past 00:00:00 and an AMPM flag.
            ;-------------------------------------------------------------------------------
TIMIN:      LD      (SPISRSAVE),SP                                       ; CP/M has a small working stack, an interrupt could exhaust it so save interrupts stack and use a local stack.
            LD      SP,ISRSTACK
            ;
            PUSH    AF                                                   ; Save used registers.
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      A,TZMM_CPM2                                          ; We meed to be in memory mode 7 to process the interrupts as this allows us access to the hardware.
            OUT     (MMCFG),A
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
            JR      Z,TIMIN2
            ;
FLSHCTL0:   LD      A,(KEYPC)                                            ; Flashing component, on each timer tick, display the cursor or the original screen character.
            LD      C,A
            XOR     (HL)                                                 ; Detect a cursor change signal.
            RLCA    
            RLCA    
            JR      NC,TIMIN2                                            ; No change, skip.

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
            ; FDC Motor Off Timer
            ;
TIMIN2:     LD      A,(MTROFFTIMER)                                      ; Is the timer non-zero?
            OR      A
            JP      Z,TIMIN3
            DEC     A                                                    ; Decrement.
            LD      (MTROFFTIMER),A                                      
            JP      NZ,TIMIN3                                            ; If zero after decrement, turn off the motor.
            OUT     (FDC_MOTOR),A                                        ; Turn Motor off
            LD      (MOTON),A                                            ; Clear Motor on flag

            ;
            ; Keyboard processing.
            ;
TIMIN3:     
            ;
            ; Keyboard routine for the Sharp MZ-80A hardware.
            ;
            IF      BUILD_MZ80A = 1                                           ; Perform keyboard sweep - inline to avoid overhead of a call.
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
ISREXIT:    LD      A,(MMCFGVAL)                                         ; Return to the memory mode prior to interrupt call.
            OUT     (MMCFG),A
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
ISRKEY55:   LD      A,(HL)
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
            DB      NULL
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
            DB      NULL
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
            DB      NULL
            DB      '3'
            DB      NULL
            DB      ','         

KTBLS:      ; Strobe 0          
            DB      '2'         
            DB      '1'         
            DB      'w'         
            DB      'q'         
            DB      'a'         
            DB      DELETE      
            DB      NULL        
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
            DB      NULL        
            DB      '?'         

KTBLCL:     ; Strobe 0          
            DB      '2'         
            DB      '1'         
            DB      'W'         
            DB      'Q'         
            DB      'A'         
            DB      DELETE      
            DB      NULL        
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
            DB      NULL        
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
            ENDIF

            ;
            ; Keyboard routine for the MZ-700 hardware.
            ;
            IF      BUILD_MZ700 = 1
            ;
            ;    KEY BOARD SWEEP
            ;    EXIT B,D7=0  NO DATA
            ;             =1  DATA
            ;           D6=0  SHIFT OFF
            ;             =1  SHIFT ON
            ;           D5=0  CTRL OFF
            ;             =1  CTRL ON
            ;           D4=0  SHIFT+CTRL OFF
            ;             =1  SHIFT+CTRL ON
            ;         C   = ROW & COLUMN
            ;        7 6 5 4 3 2 1 0
            ;        * * ^ ^ ^ < < <
            XOR     A
            LD      B,0F8H
            LD      D,A

            ;    BREAK KEY CHECK
            ;    AND SHIFT, CTRL KEY CHECK
            ;    EXIT BREAK ON : ZERO=1
            ;               OFF: ZERO=0
            ;         NO KEY   : CY  =0
            ;         KEY IN   : CY  =1
            ;          A D6=1  : SHIFT ON
            ;              =0  :       OFF
            ;            D5=1  : CTRL ON
            ;              =0  :      OFF
            ;            D4=1  : SHIFT+CNT ON
            ;              =0  :           OFF
            ;            D3=1  : BREAK ON
            ;              =0  :       OFF
BREAK:      LD      A,0F8H                                               ; LINE 8SWEEP
            LD      (KEYPA),A
            NOP     
            LD      A,(KEYPB)
            CP      03EH                                                 ; BREAK + CTRL + SHIFT = RESET TO MONITOR
            JP      Z, REBOOT
            OR      A
            RRA     
            JP      C,BREAK2                                             ; SHIFT ?
            RLA     
            RLA     
            JR      NC,BREAK1                                            ; BREAK ?
            LD      A,40H                                                ; SHIFT D6=1
            SCF     
            JR      SWEP6

BREAK1:     XOR     A                                                    ; SHIFT ?
            JR      SWEP6

            ;    BREAK SUBROUTINE BYPASS 1
            ;    CTRL OR NOT KEY
BREAK2:     BIT     5,A                                                  ; NOT OR CTRL
            JR      Z,BREAK3                                             ; CTRL
            OR      A                                                    ; NOTKEY A=7FH
            JR      SWEP6

BREAK3:     LD      A,20H                                                ; CTRL D5=1
            OR      A                                                    ; ZERO FLG CLR
            SCF     
            JR      SWEP6

SWEP1:      LD      D,88H                                                ; BREAK ON
            JR      SWEP9

SWEP6:      JR      NC,SWEP0
            LD      D,A
            JR      SWEP0

SWEP01:     SET     7,D
SWEP0:      DEC     B
            LD      A,B
            LD      (KEYPA),A
            CP      0EFH                                                 ; MAP SWEEP END ?
            JR      NZ,SWEP3
            CP      0F8H                                                 ; BREAK KEY ROW
            JR      Z,SWEP0
SWEP9:      LD      B,D
            JP      ISRKEY0

SWEP3:      LD      A,(KEYPB)
            LD      E,A
            CPL     
            OR      A
            JR      Z,SWEP0
            LD      E,A
SWEP2:      LD      H,8
            LD      A,B
            AND     0FH
            RLCA    
            RLCA    
            RLCA    
            LD      C,A
            LD      A,E
L0A89:      DEC     H
            RRCA    
            JR      NC,L0A89
            LD      A,H
            ADD     A,C
            LD      C,A
            JR      SWEP01

ISRKEY0:    LD      A,B
            RLCA    
            JP      C,ISRKEY2                                            ; CY=1 then data available.
            XOR     A
            LD      (KEYRPT),A                                           ; No key held then clear the auto repeat initial pause counter.
            LD      A,NOKEY                                              ; No key code.
            JR      ISRKEY10
            ;
ISRKEY1:    LD      E, A
            LD      A,(KEYLAST)
            CP      E
            JR      Z, ISRAUTORPT
            LD      A, E
ISRKEY10:   CP      NOKEY
            LD      (KEYLAST),A
            JR      Z,ISREXIT
            CP      GRAPHKEY
            JR      Z,LOCKTOGGLE
            CP      ALPHAKEY
            JR      Z,ALPHATOGGLE
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
ISREXIT:    LD      A,(MMCFGVAL)                                         ; Return to the memory mode prior to interrupt call.
            OUT     (MMCFG),A
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

            ; Method to alternate between NO LOCK and CAPSLOCK.
ALPHATOGGLE:LD      HL,FLSDT
            LD      A,(SFTLK)
            INC     A
            AND     001H
            JR      LOCK0


ISRKEY2:    LD      DE,KTBLSL                                            ; KEY TABLE WITH SHIFT LOCK
            LD      A,B
            CP      88H                                                  ; BREAK IN (SHIFT & BRK)
            JR      Z,ISRBRK
            LD      H,0                                                  ; HL=ROW & COLUMN
            LD      L,C
            BIT     5,A                                                  ; CTRL CHECK
            JR      NZ,ISRKEY15                                          ; YES, CTRL
            LD      A,(SFTLK)                                            ; CAPSLOCK=1, SHIFTLOCK=2, NO LOCK=0
            RRCA
            JR      C,ISRKEY3
            RRCA
            JR      C,ISRKEY6
            LD      A, B
            BIT     6, A
            LD      DE,KTBLSL                                            ; Shift lock.
            JR      NZ, ISRKEY5
            LD      DE,KTBLNS                                            ; Lower case.
            JR      ISRKEY5

            ; Setup pointer to Control Key mapping.
ISRKEY15:   LD      DE,KTBLC
            ; Add in offset.
ISRKEY5:    ADD     HL,DE
            ; Get key.
ISRKEY55:   LD      A,(HL)
            JP      ISRKEY1                   

            ; Setup pointer to Caps Lock mapping.
ISRKEY3:    LD      A, B
            BIT     6, A                                                 ; Shift pressed when caps lock on?
            LD      DE, KTBLSL
            JR      NZ, ISRKEY5
            LD      DE,KTBLCL
            JR      ISRKEY5

            ; Setup pointer to Shift Lock mapping.
ISRKEY6:    LD      A, B
            BIT     6, A                                                 ; Shift pressed when shift lock on?
            LD      DE, KTBLNS
            JR      NZ, ISRKEY5
            LD      DE,KTBLSL
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

KTBLSL:     ; SHIFT LOCK.
            ;S0   00 - 07
            DB      0BFH                                                 ; SPARE
            DB      GRAPHKEY                                             ; GRAPH
            DB      58H                                                  ; 
            DB      ALPHAKEY                                             ; ALPHA
            DB      NOKEY                                                ; NO
            DB      ';'                                                  ; ;
            DB      ':'                                                  ; :
            DB      CR                                                   ; CR
            ;S1   08 - 0F
            DB      'Y'                                                  ; Y
            DB      'Z'                                                  ; Z
            DB      '@'                                                  ; @
            DB      '('                                                  ; [
            DB      ')'                                                  ; ]
            DB      NOKEY                                                ; NULL
            DB      NOKEY                                                ; NULL
            DB      NOKEY                                                ; NULL
            ;S2   10 - 17
            DB      'Q'                                                  ; Q
            DB      'R'                                                  ; R
            DB      'S'                                                  ; S
            DB      'T'                                                  ; T
            DB      'U'                                                  ; U
            DB      'V'                                                  ; V
            DB      'W'                                                  ; W
            DB      'X'                                                  ; X
            ;S3   18 - 1F
            DB      'I'                                                  ; I
            DB      'J'                                                  ; J
            DB      'K'                                                  ; K
            DB      'L'                                                  ; L
            DB      'M'                                                  ; M
            DB      'N'                                                  ; N
            DB      'O'                                                  ; O
            DB      'P'                                                  ; P
            ;S4   20 - 27
            DB      'A'                                                  ; A
            DB      'B'                                                  ; B
            DB      'C'                                                  ; C
            DB      'D'                                                  ; D
            DB      'E'                                                  ; E
            DB      'F'                                                  ; F
            DB      'G'                                                  ; G
            DB      'H'                                                  ; H
            ;S5   28 - 2F
            DB      '!'                                                  ; !
            DB      '"'                                                  ; "
            DB      '#'                                                  ; #
            DB      '$'                                                  ; $
            DB      '%'                                                  ; %
            DB      '&'                                                  ; &
            DB      '\''                                                 ; '
            DB      '('                                                  ; (
            ;S6   30 - 37
            DB      '\\'                                                 ; \
            DB      '#'                                                  ; POND MARK
            DB      2BH                                                  ; YEN
            DB      ' '                                                  ; SPACE
            DB      ' '                                                  ; ¶
            DB      ')'                                                  ; )
            DB      '<'                                                  ; <
            DB      '>'                                                  ; >
            ;S7   38 - 3F
            DB      INSERT                                               ; INST.
            DB      DELETE                                               ; DEL.
            DB      CURSUP                                               ; CURSOR UP
            DB      CURSDOWN                                             ; CURSOR DOWN
            DB      CURSRIGHT                                            ; CURSOR RIGHT
            DB      CURSLEFT                                             ; CURSOR LEFT
            DB      '?'                                                  ; ?
            DB      '/'                                                  ; /
            ;

            ;
KTBLNS:     ; NO SHIFT
            ;S0   00 - 07
            DB      0BFH                                                 ; SPARE
            DB      GRAPHKEY                                             ; GRAPH
            DB      1BH                                                  ; POND
            DB      ALPHAKEY                                             ; ALPHA
            DB      NOKEY                                                ; NO
            DB      '+'                                                  ; +
            DB      '*'                                                  ; *
            DB      CR                                                   ; CR
            ;S1   08 - 0F
            DB      'y'                                                  ; y
            DB      'z'                                                  ; z
            DB      '`'                                                  ; `
            DB      '{'                                                  ; {
            DB      '}'                                                  ; }
            DB      NOKEY                                                ; NULL
            DB      NOKEY                                                ; NULL
            DB      NOKEY                                                ; NULL
            ;S2   10 - 17
            DB      'q'                                                  ; q
            DB      'r'                                                  ; r
            DB      's'                                                  ; s
            DB      't'                                                  ; t
            DB      'u'                                                  ; u
            DB      'v'                                                  ; v
            DB      'w'                                                  ; w
            DB      'x'                                                  ; x
            ;S3   18 - 1F
            DB      'i'                                                  ; i
            DB      'j'                                                  ; j
            DB      'k'                                                  ; k
            DB      'l'                                                  ; l
            DB      'm'                                                  ; m
            DB      'n'                                                  ; n
            DB      'o'                                                  ; o
            DB      'p'                                                  ; p
            ;S4   20 - 27
            DB      'a'                                                  ; a
            DB      'b'                                                  ; b
            DB      'c'                                                  ; c
            DB      'd'                                                  ; d
            DB      'e'                                                  ; e
            DB      'f'                                                  ; f
            DB      'g'                                                  ; g
            DB      'h'                                                  ; h
            ;S5   28 - 2F
            DB      '1'                                                  ; 1
            DB      '2'                                                  ; 2
            DB      '3'                                                  ; 3
            DB      '4'                                                  ; 4
            DB      '5'                                                  ; 5
            DB      '6'                                                  ; 6
            DB      '7'                                                  ; 7
            DB      '8'                                                  ; 8
            ;S6   30 - 37
            DB      '\\'                                                 ; \
            DB      CURSUP                                               ; 
            DB      '-'                                                  ; -
            DB      ' '                                                  ; SPACE
            DB      '0'                                                  ; 0
            DB      '9'                                                  ; 9
            DB      ','                                                  ; ,
            DB      '.'                                                  ; .
            ;S7   38 - 3F
            DB      CLRKEY                                               ; CLR.
            DB      HOMEKEY                                              ; HOME.
            DB      CURSUP                                               ; CURSOR UP
            DB      CURSDOWN                                             ; CURSOR DOWN
            DB      CURSRIGHT                                            ; CURSOR RIGHT
            DB      CURSLEFT                                             ; CURSOR LEFT
            DB      0C6H                                                 ; CLR
            DB      5AH                                                  ;
            DB      45H                                                  ;
            ;
            ;
KTBLCL:     ;   CAPS LOCK
            ;S0   00 - 07
            DB      0BFH                                                 ; SPARE
            DB      GRAPHKEY                                             ; GRAPH
            DB      58H                                                  ; 
            DB      ALPHAKEY                                             ; ALPHA
            DB      NOKEY                                                ; NO
            DB      ';'                                                  ; ;
            DB      ':'                                                  ; :
            DB      CR                                                   ; CR
            ;S1   08 - 0F
            DB      'Y'                                                  ; Y
            DB      'Z'                                                  ; Z
            DB      '@'                                                  ; @
            DB      '('                                                  ; [
            DB      ')'                                                  ; ]
            DB      NOKEY                                                ; NULL
            DB      NOKEY                                                ; NULL
            DB      NOKEY                                                ; NULL
            ;S2   10 - 17
            DB      'Q'                                                  ; Q
            DB      'R'                                                  ; R
            DB      'S'                                                  ; S
            DB      'T'                                                  ; T
            DB      'U'                                                  ; U
            DB      'V'                                                  ; V
            DB      'W'                                                  ; W
            DB      'X'                                                  ; X
            ;S3   18 - 1F
            DB      'I'                                                  ; I
            DB      'J'                                                  ; J
            DB      'K'                                                  ; K
            DB      'L'                                                  ; L
            DB      'M'                                                  ; M
            DB      'N'                                                  ; N
            DB      'O'                                                  ; O
            DB      'P'                                                  ; P
            ;S4   20 - 27
            DB      'A'                                                  ; A
            DB      'B'                                                  ; B
            DB      'C'                                                  ; C
            DB      'D'                                                  ; D
            DB      'E'                                                  ; E
            DB      'F'                                                  ; F
            DB      'G'                                                  ; G
            DB      'H'                                                  ; H
            ;S5   28 - 2F
            DB      '1'                                                  ; 1
            DB      '2'                                                  ; 2
            DB      '3'                                                  ; 3
            DB      '4'                                                  ; 4
            DB      '5'                                                  ; 5
            DB      '6'                                                  ; 6
            DB      '7'                                                  ; 7
            DB      '8'                                                  ; 8
            ;S6   30 - 37
            DB      '\\'                                                 ; \
            DB      CURSUP                                               ; 
            DB      '-'                                                  ; -
            DB      ' '                                                  ; SPACE
            DB      '0'                                                  ; 0
            DB      '9'                                                  ; 9
            DB      ','                                                  ; ,
            DB      '.'                                                  ; .
            ;S7   38 - 3F
            DB      INSERT                                               ; INST.
            DB      DELETE                                               ; DEL.
            DB      CURSUP                                               ; CURSOR UP
            DB      CURSDOWN                                             ; CURSOR DOWN
            DB      CURSRIGHT                                            ; CURSOR RIGHT
            DB      CURSLEFT                                             ; CURSOR LEFT
            DB      '?'                                                  ; ?
            DB      '/'                                                  ; /
            ;
            ;
KTBLC:      ; CONTROL CODE
            ;S0   00 - 07
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_CAPPA                                           ; ^
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            ;S1   08 - 0F
            DB      CTRL_Y                                               ; ^Y E3
            DB      CTRL_Z                                               ; ^Z E4 (CHECKER)
            DB      CTRL_AT                                              ; ^@
            DB      CTRL_LB                                              ; ^[ EB/E5
            DB      CTRL_RB                                              ; ^] EA/E7 
            DB      NOKEY                                                ; #NULL
            DB      NOKEY                                                ; #NULL
            DB      NOKEY                                                ; #NULL
            ;S2   10 - 17
            DB      CTRL_Q                                               ; ^Q
            DB      CTRL_R                                               ; ^R
            DB      CTRL_S                                               ; ^S
            DB      CTRL_T                                               ; ^T
            DB      CTRL_U                                               ; ^U
            DB      CTRL_V                                               ; ^V
            DB      CTRL_W                                               ; ^W E1
            DB      CTRL_X                                               ; ^X E2
            ;S3   18 - 1F
            DB      CTRL_I                                               ; ^I F9
            DB      CTRL_J                                               ; ^J FA
            DB      CTRL_K                                               ; ^K FB
            DB      CTRL_L                                               ; ^L FC
            DB      CTRL_M                                               ; ^M CD
            DB      CTRL_N                                               ; ^N FE
            DB      CTRL_O                                               ; ^O FF
            DB      CTRL_P                                               ; ^P E0
            ;S4   20 - 27
            DB      CTRL_A                                               ; ^A F1
            DB      CTRL_B                                               ; ^B F2
            DB      CTRL_C                                               ; ^C F3
            DB      CTRL_D                                               ; ^D F4
            DB      CTRL_E                                               ; ^E F5
            DB      CTRL_F                                               ; ^F F6
            DB      CTRL_G                                               ; ^G F7
            DB      CTRL_H                                               ; ^H F8
            ;S5   28 - 2F
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            ;S6   30 - 37 (ERROR? 7 VALUES ONLY!!)
            DB      NOKEY                                                ; ^YEN E6
            DB      CTRL_CAPPA                                           ; ^    EF
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_UNDSCR                                          ; ^,
            DB      NOKEY
            ;S7   38 - 3F
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_SLASH                                           ; ^/ EE
            ENDIF

            

            ;-------------------------------------------------------------------------------
            ; END OF TIMER INTERRUPT                                                                      
            ;-------------------------------------------------------------------------------


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
BANKTOBANK_:JMPTOBNK2            

            ;------------------------------------------------------------------------------------------
            ; Enhanced function Jump table.
            ; This table is generally used by a banked page to call a function within another banked
            ; page. The name is the same as the original function but prefixed by a ?. The original is
            ; prefixed by a Q.
            ; All registers are preserved going to the called function and returning from it.
            ;------------------------------------------------------------------------------------------
?BOOT_:     JMPBNK  QBOOT_,     TZMM_CPM2                                ;
?WBOOT_:    JMPBNK  QWBOOT_,    TZMM_CPM2                                ;
?CONST_:    CALLBNK QCONST_,    TZMM_CPM2                                ;
?CONIN_:    CALLBNK QCONIN_,    TZMM_CPM2                                ;
?CONOUT_:   CALLBNK QCONOUT_,   TZMM_CPM2                                ;
?LIST_:     CALLBNK QLIST_,     TZMM_CPM2                                ;
?PUNCH_:    CALLBNK QPUNCH_,    TZMM_CPM2                                ;
?READER_:   CALLBNK QREADER_,   TZMM_CPM2                                ;
?HOME_:     CALLBNK QHOME_,     TZMM_CPM2                                ;
?SELDSK_:   CALLBNK QSELDSK_,   TZMM_CPM2                                ;
?SETTRK_:   CALLBNK QSETTRK_,   TZMM_CPM2                                ;
?SETSEC_:   CALLBNK QSETSEC_,   TZMM_CPM2                                ;
?SETDMA_:   CALLBNK QSETDMA_,   TZMM_CPM2                                ;
?READ_:     CALLBNK QREAD_,     TZMM_CPM2                                ;
?WRITE_:    CALLBNK QWRITE_,    TZMM_CPM2                                ;

            ;-------------------------------------------------------------------------------
            ; The FDC controller uses it's busy/wait signal as a ROM address line input, this
            ; causes a jump in the code dependent on the signal status. It gets around the 2MHz
            ; Z80 not being quick enough to process the signal by polling.
            ;------------ 0xF3C0 -----------------------------------------------------------
            IF $ > FDCJMP1
                ERROR "Code overlaps the FDC Jump Vector 1, need to move or optimise code. Addr=%s, required=%s"; % $, FDCJMP1BLK
            ENDIF
;            ALIGN_NOPS FDCJMP1BLK
            ALIGN_NOPS FDCJMP1
FDCJMPL:    JP       (IX)    
            ;------------ 0xF400 -----------------------------------------------------------


            ;------------------------------------------------------------------------------------------
            ; Enhanced function Jump table (continued).
            ;------------------------------------------------------------------------------------------
?LISTST_:   CALLBNK QLISTST_,   TZMM_CPM2                                ;
?SECTRN_:   CALLBNK QSECTRN_,   TZMM_CPM2                                ;
?DEBUG_:    CALLBNK DEBUG,      TZMM_CPM2
            ;-----------------------------------------

            ;------------------------------------------------------------------------------------------
            ; Cold boot takes place in memory mode 7 bank and once initialised passes control to 
            ; this fixed point to switch into memory mode 6 and start CPM.
            ;------------------------------------------------------------------------------------------
BOOT_:      EX      AF,AF'
            ;
            LD      A,05H                                                ; Enable interrupts at hardware level, this must be done before switching memory mode.
            LD      (KEYPF),A
            ;
            LD      A,TZMM_CPM                                           ; Switch to primary CPM memory.
            LD      (MMCFGVAL),A
            OUT     (MMCFG),A
            ;
            EX      AF,AF'
            ;
GOCPM:      EI
            JP      CCP                                                  ; Start the CCP.


            ; Method to copy a block of memory from the common shared RAM into CPM memory in mode 6.
            ; This method is called by code running in memory mode 7 which needs to copy data into the potentially
            ; same location but in another RAM block.
            ; This is the inverted copy routine, used for FDC copies where the data is inverted.
            ;
            ; Inputs:
            ;     DE = Source memory address (common area).
            ;     HL = Destination memory address (memory in mode 6).
            ;      C = Number of bytes to copy.
            ; Outputs:
            ;
MEMCPYINV:  DI                                                           ; Disable interrupts, TIMIN switches bank to memory mode 7 which we dont want during the copy and returns to the original bank which may be 7.
            LD      A,TZMM_CPM
            OUT     (MMCFG),A
MEMCPYINV1: LD      A, (DE)                                              ; source character
            CPL                                                          ; Change to positive values.
            INC     DE
            LD      (HL), A                                              ; to dest
            INC     HL
            DEC     C                                                    ; loop 128 times
            JR      NZ, MEMCPYINV1
MEMCPYINV2: LD      A,TZMM_CPM2
            OUT     (MMCFG),A
            EI
            RET

            ; Method to copy a block of memory from the common shared RAM into CPM memory in mode 6.
            ; This method is called by code running in memory mode 7 which needs to copy data into the potentially
            ; same location but in another RAM block.
            ;
            ; Inputs:
            ;     DE = Source memory address (common area).
            ;     HL = Destination memory address (memory in mode 6).
            ;      C = Number of bytes to copy.
            ; Outputs:
            ;
MEMCPY:     DI                                                           ; Disable interrupts, TIMIN switches bank to memory mode 7 which we dont want during the copy and returns to the original bank which may be 7.
            LD      A,TZMM_CPM
            OUT     (MMCFG),A
MEMCPY1:    LD      A, (DE)                                              ; source character
            INC     DE
            LD      (HL), A                                              ; to dest
            INC     HL
            DEC     C                                                    ; loop 128 times
            JR      NZ, MEMCPY1
            JR      MEMCPYINV2

;-----------------------------------------------------------------------------------------------------------------------------------------
; RAM STORAGE AREA
;-----------------------------------------------------------------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; VARIABLES AND STACK SPACE
            ;-------------------------------------------------------------------------------

            IF $ > TZVARMEM
                ERROR "Global var not aligned, addr=%s, required=%s"; % $, TZVARMEM
            ENDIF
            ALIGN_NOPS TZVARMEM

GVARSTART   EQU     $                                                    ; Start of variables.
MMCFGVAL:   DS      1                                                    ; Current memory model value.
FNADDR:     DS      2                                                    ; Function to be called address.
SPISRSAVE:  DS      2
            ; Stack space for the Interrupt Service Routine.
            DS      16                                                   ; Max 8 stack pushes.
ISRSTACK    EQU     $
GVAREND     EQU     $                                                    ; End of common variables

            ;-------------------------------------------------------------------------------
            ; END OF VARIABLES AND STACK SPACE
            ;-------------------------------------------------------------------------------

            ;------------------------------------------------------------------------------------------------------------
            ; DISK PARAMETER HEADER
            ;
            ; Disk parameter headers for disk 0 to 3                                      
            ;                                                                             
            ; +-------+------+------+------+----------+-------+-------+-------+
            ; |  XLT  | 0000 | 0000 | 0000 |DIRBUF    | DPB   | CSV   | ALV   |
            ; +------+------+------+-------+----------+-------+-------+-------+      
            ;   16B     16B    16B    16B    16B        16B     16B     16B
            ;
            ; -XLT    Address of the logical-to-physical translation vector, if used for this particular drive,
            ;         or the value 0000H if no sector translation takes place (that is, the physical and
            ;         logical sectornumbers are the same). Disk drives with identical sector skew factors share
            ;         the same translatetables.
            ; -0000   Scratch pad values for use within the BDOS, initial value is unimportant.
            ; -DIRBUF Address of a 128-byte scratch pad area for directory operations within BDOS. All DPHs
            ;         address the same scratch pad area. 
            ; -DPB    Address of a disk parameter block for this drive. Drives with identical disk characteristics
            ;         address the same disk parameter block.
            ; -CSV    Address of a scratch pad area used for software check for changed disks. This address is
            ;         different for each DPH.
            ; -ALV    Address of a scratch pad area used by the BDOS to keep disk storage allocation information.
            ;         This address is different for each DPH.
            ;------------------------------------------------------------------------------------------------------------

            ; NB. The Disk Parameter Blocks are stored in CBIOS ROM to save RAM space.
            ; Space for 2xFD, 3xSD or upto 8 drives total.
            ; These entries are created dynamically based on hardware available.
DPBASE:
DPBLOCK0:   DS     DPSIZE                                                ; Location of the 1st DPB in the CBIOS Rom.
DPBLOCK1:   DS     DPSIZE 
DPBLOCK2:   DS     DPSIZE 
DPBLOCK3:   DS     DPSIZE 
DPBLOCK4:   DS     DPSIZE 
DPBLOCK5:   DS     DPSIZE 
DPBLOCK6:   DS     DPSIZE
;DPBLOCK7:   DS     DPSIZE


            ;-------------------------------------------------------------------------------
            ; TZ SERVICE STRUCTURE AND VARIABLES
            ;-------------------------------------------------------------------------------

            IF $ > TZSVCMEM
                ERROR "TZ Service Record not aligned, addr=%s, required=%s"; % $, TZSVCMEM
            ENDIF
            ALIGN   TZSVCMEM
TZSVCCMD:       DS  1,0aah                                               ; Service command.
TZSVCRESULT:    DS  1                                                    ; Service command result.
TZSVCDIRSEC:    DS  1                                                    ; Storage for the directory sector number.
TZSVC_FILE_SEC: EQU TZSVC_DIR_SEC                                        ; Union of the file and directory sector as only one can be used at a time.
TZSVC_TRACK_NO: DS  2                                                    ; Storage for the virtual drive track number.
TZSVC_SECTOR_NO:DS  2                                                    ; Storage for the virtual drive sector number.
TZSVC_FILE_NO:  DS  1                                                    ; File number to be opened in a file service command.
TZSVC_FILE_TYPE:DS  1                                                    ; Type of file being accessed to differentiate between Sharp MZF files and other handled files.
TZSVC_LOADADDR  DS  2                                                    ; Dynamic load address for rom/images.
TZSVC_SAVEADDR: EQU TZSVC_LOADADDR                                       ; Union of the load address and the cpu frequency change value, the address  of data to be saved.
TZSVC_CPU_FREQ: EQU TZSVC_LOADADDR                                       ; Union of the load address and the save address value, only one can be used at a time.
TZSVC_LOADSIZE  DS  2                                                    ; Size of file to be loaded.
TZSVC_SAVESIZE: EQU TZSVC_LOADSIZE                                       ; Size of image to be saved.
TZSVC_DIRNAME:  DS  TZSVCDIRSZ                                           ; Service directory/file name.
TZSVC_FILENAME: DS  TZSVCFILESZ                                          ; Filename to be opened/created.
TZSVCWILDC:     DS  TZSVCWILDSZ                                          ; Directory wildcard for file pattern matching.
HSTBUF:         EQU $                                                    ; Host buffer for disk sector storage, shares same space as the service sector as they are the same.
TZSVCSECTOR:    DS  TZSVCSECSIZE, 0e5h                                   ; Service command sector - to store directory entries, file sector read or writes.
HSTBUFE:        EQU $


            ;-------------------------------------------------------------------------------
            ; END OF TZ SERVICE STRUCTURE AND VARIABLES
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; The FDC controller uses it's busy/wait signal as a ROM address line input, this
            ; causes a jump in the code dependent on the signal status. It gets around the 2MHz
            ; Z80 not being quick enough to process the signal by polling.
            ;------------ 0xF7C0 -----------------------------------------------------------
            IF $ > FDCJMP2
                ERROR "Code overlaps the FDC Jump Vector 2, need to move or optimise code. Addr=%s, required=%s"; % $, FDCJMP2BLK
            ENDIF
;            ALIGN_NOPS FDCJMP2BLK
            ALIGN_NOPS FDCJMP2 
FDCJMPH:    JP       (IY)    
            ;------------ 0xF800 -----------------------------------------------------------


            ;------------------------------------------------------------------------------------------------------------
            ; CPN Disk work areas.
            ;------------------------------------------------------------------------------------------------------------
CDIRBUF:    DS     128
CSVALVMEM:  DS     0680H
CSVALVEND:  EQU    $

            ; Allocate space for 8 disk parameter block definitions.
            ;
            ;------------------------------------------------------------------------------------------------------------
            ; DISK PARAMETER BLOCK
            ;
            ; +----+----+------+-----+-----+------+----+----+-----+----+
            ; |SPT |BSH |BLM   |EXM  |DSM  |DRM   |AL0 |AL1 |CKS  |OFF |
            ; +----+----+------+-----+-----+------+----+----+-----+----+  
            ;  16B  8B   8B     8B    16B   16B    8B   8B   16B   16B
            ;
            ; -SPT is the total number of sectors per track.   
            ; -BSH is the data allocation block shift factor, determined by the data block allocation size.   
            ; -BLM is the data allocation block mask (2[BSH-1]).   
            ; -EXM is the extent mask, determined by the data block allocation size and the number of disk blocks.   
            ; -DSM determines the total storage capacity of the disk drive.   
            ; -DRM determines the total number of directory entries that can be stored on this drive.    
            ; -AL0, AL1   determine reserved directory blocks.   
            ; -CKS is the size of the directory check vector.   
            ; -OFF is the number of reserved tracks at the beginning of the (logical) disk
            ;
            ; BLS   BSH BLM  EXM (DSM < 256)  EXM (DSM > 255)
            ; 1,024  3    7   0                N/A
            ; 2,048  4   15   1                 0
            ; 4,096  5   31   3                 1
            ; 8,192  6   63   7                 3
            ; 16,384 7  127  15                 7
            ;------------------------------------------------------------------------------------------------------------

            ; MZ-800 drive but using both heads per track rather than the original
            ; 1 head for all  tracks on side A switching to second head and
            ; restarting at track 0.
DPB0:       DW      64                                                   ; SPT - 128 bytes sectors per track
            DB      4                                                    ; BSH - block shift factor
            DB      15                                                   ; BLM - block mask
            DB      1                                                    ; EXM - Extent mask
            DW      155                                                  ; DSM - Storage size (blocks - 1)
            DW      63                                                   ; DRM - Number of directory entries - 1
            DB      128                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      16                                                   ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      1                                                    ; OFF - Reserved tracks
            DB      6                                                    ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 11 = SD Card, 10,01 = Unused
                                                                         
            ; 1.44MB Floppy
DPB3:       DW      144                                                  ; SPT - 128 bytes sectors per track (= 36 sectors of 512 bytes)
            DB      4                                                    ; BSH - block shift factor
            DB      15                                                   ; BLM - block mask
            DB      0                                                    ; EXM - Extent mask
            DW      719                                                  ; DSM - Storage size (blocks - 1)
            DW      127                                                  ; DRM - Number of directory entries - 1
            DB      192                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      32                                                   ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      7                                                    ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 11 = SD Card, 10,01 = Unused

            ; 16Mb SD Hard Disk drives (not hot-swappable).
            ; This drive has 2048 blocks (small due to size of RAM needed, more blocks more RAM) of 8192 bytes = 16Mb
            ; There are 1024 directory entries thus AL0/AL1 needs to ave the top four bits set as each block can hold 256 directory entries.
            ; This implementation limits the sectors per track to 255 (8 bit) even though CPM supports 16bit sectors, so the
            ; physical drive make up is: 32 Sectors (128 CPM sectors of 128 bytes each) x 1024 tracks, 1 head = 16777216bytes.
            ; This size has been chosen to maximise the use of the SD Card space and the number of files/programs which can be online
            ; at the same time. On the MZ80A, memory is more of a premium so keeping the DRM as low as possible saves RAM.
            ;
DPB4:       DW      128                                                  ; SPT - 128 bytes sectors per track (= 36 sectors of 512 bytes)
            DB      6                                                    ; BSH - block shift factor
            DB      63                                                   ; BLM - block mask
            DB      3                                                    ; EXM - Extent mask
            DW      2047                                                 ; DSM - Storage size (blocks - 1)
            DW      511                                                  ; DRM - Number of directory entries - 1
            DB      192                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      0                                                    ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      27                                                   ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 11 = SD Card, 10,01 = Unused

          
FILL:       DS 10000H - $, 0aaH
STKSAVE:    EQU     0FFFEH
CBIOSSTACK: EQU     0FFF8H                                               ; Bios stack at top of RAM - 8 = allows room for stack errors and can be viewed when debugging.
;-----------------------------------------------------------------------------------------------------------------------------------------
; END OF RAM STORAGE AREA
;-----------------------------------------------------------------------------------------------------------------------------------------

            ; Include all other banks which make up the CBIOS system.
            ;
            INCLUDE  "cbiosII.asm"
