;--------------------------------------------------------------------------------------------------------
;-
;- Name:            tzfs_bank2.asm
;- Created:         July 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series tzfs (tranZPUter Filing System).
;-                  Bank 2 - F000:FFFF - Help and messages
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
            ; TZFS BANK 2 - Help and message functions.
            ;
            ;============================================================
            ORG     BANKRAMADDR

            ;-------------------------------------------------------------------------------
            ; START OF ADDITIONAL TZFS COMMANDS
            ;-------------------------------------------------------------------------------

            ; Method to set the video mode.
            ; Param: 0 - Enable FPGA and set to MZ-80K mode.
            ;        1 - Enable FPGA and set to MZ-80C mode.
            ;        2 - Enable FPGA and set to MZ-1200 mode.
            ;        3 - Enable FPGA and set to MZ-80A mode (base mode on MZ-80A hardware).
            ;        4 - Enable FPGA and set to MZ-700 mode (base mode on MZ-700 hardware).
            ;        5 - Enable FPGA and set to MZ-800 mode.
            ;        6 - Enable FPGA and set to MZ-80B mode.
            ;        7 - Enable FPGA and set to MZ-2000 mode.
            ;        O - Turn off FPGA Video, turn on mainboard video.
SETVMODE:   IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            JP      Z,NOFPGAERR                                          ; No hardware so cannot change mode.
            PUSH    DE                                                   ; Preserve DE in case no number given.
            POP     BC
            CALL    ConvertStringToNumber                                ; Convert the input into 0 (disable) or frequency in KHz.
            JR      NZ,SETVMODEOFF
            LD      A,H
            CP      0
            JP      NZ,BADNUMERR                                         ; Check that the given mode is in range 0 - 7.
            LD      A,L
            CP      7
            JP      NC,BADNUMERR
            ;
            IN      A,(CPLDCFG) 
            OR      MODE_VIDEO_FPGA                                      ; Set the tranZPUter CPLD hardware to enable the FPGA video mode.
            OUT     (CPLDCFG),A                                 
            ;
            IN      A,(VMCTRL)                                           ; Get current setting.
            AND     0F8H                                                 ; Clear old mode setting.
            OR      L                                                    ; Add in new setting.
            OUT     (VMCTRL),A
            RLC     L                                                    ; Shift mode to position for SCRNMODE storage.
            RLC     L
            RLC     L
            LD      A,(SCRNMODE)                                         ; Repeat for the screen mode variable, used when resetting or changing display settings.
            AND     0C7H                                                 ; Clear video mode setting.
            OR      L                                                    ; Add in new setting.
            SET     2,A                                                  ; Set flag to indicate video mode override - ie, dont use base machine mode.
            SET     1, A                                                 ; Ensure flag set so on restart the FPGA video mode is selected.
            LD      (SCRNMODE),A
            LD      A, 016H                                              ; Clear the screen so we start from a known position.
            CALL    PRNT
            LD      A,071H                                               ; Blue background and white characters.
            LD      HL,ARAM
            CALL    CLR8
            RET
SETVMODEOFF:LD      A,(DE)
            CP      'O'
            JR      Z,SETVMODE1
            CP      'o'
            JP      NZ,BADNUMERR
SETVMODE1:  LD      A,(SCRNMODE)                                         ; Disable flag to enable FPGA on restart.
            RES     1,A
            LD      (SCRNMODE),A
            IN      A,(CPLDCFG) 
            AND     ~MODE_VIDEO_FPGA                                     ; Set the tranZPUter CPLD hardware to disable the FPGA video mode.
            OUT     (CPLDCFG),A                                 
            RET
            
            ; Method to set the VGA output mode of the external display.
SETVGAMODE: IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            JP      Z,NOFPGAERR                                          ; No hardware so cannot change mode.
            CALL    ConvertStringToNumber                                ; Convert the input into 0-3, 0 = off, 1 = 640x480, 2=1024x768, 3=800x600.
            JP      NZ,BADNUMERR
            LD      A,H
            CP      0
            JR      NZ,BADNUMERR                                         ; Check that the given mode is in range 0 - 3.
            LD      A,L
            CP      4
            JR      NC,BADNUMERR
            ;
            IN      A,(CPLDCFG) 
            OR      MODE_VIDEO_FPGA                                      ; Set the tranZPUter CPLD hardware to enable the FPGA video mode.
            OUT     (CPLDCFG),A                                 
            ;
            RRC     L
            RRC     L                                                    ; Value to top 2 bits.
            IN      A,(VMCTRL)                                           ; Get current setting.
            AND     03FH                                                 ; Clear VGA setting.
            OR      L                                                    ; Add in new setting.
            OUT     (VMCTRL),A
            LD      A,(SCRNMODE)                                         ; Repeat for the screen mode variable, used when resetting or changing display settings.
            AND     03FH                                                 ; Clear VGA setting.
            OR      L                                                    ; Add in new setting.
            SET     1, A                                                 ; Ensure flag set so on restart the FPGA video mode is selected.
            LD      (SCRNMODE),A
            RET

            ; Method to set the VGA border colour on the external display.
SETVBORDER: IN      A,(CPLDINFO)                                         ; Get configuration of hardware.
            BIT     3,A
            JP      Z,NOFPGAERR                                          ; No hardware so cannot change mode.
            CALL    ConvertStringToNumber                                ; Convert the input into 0 - 7, bit 2 = Red, 1 = Green, 0 = Blue.
            JP      NZ,BADNUMERR
            LD      A,H
            CP      0
            JR      NZ,BADNUMERR                                         ; Check that the given mode is in range 0 - 7.
            LD      A,L
            CP      7
            JR      NC,BADNUMERR
            ;
            IN      A,(CPLDCFG) 
            OR      MODE_VIDEO_FPGA                                      ; Set the tranZPUter CPLD hardware to enable the FPGA video mode.
            OUT     (CPLDCFG),A                                 
            ;
            LD      A,L
            OUT     (VMBORDER),A
            RET

            ; Method to enable/disable the alternate CPU frequency and change it's values.
            ;
SETFREQ:    CALL    ConvertStringToNumber                                ; Convert the input into 0 (disable) or frequency in KHz.
            JR      NZ,BADNUMERR
            LD      (TZSVC_CPU_FREQ),HL                                  ; Set the required frequency in the service structure.
            LD      A,H
            CP      L
            JR      NZ,SETFREQ1
            LD      A, TZSVC_CMD_CPU_BASEFREQ                            ; Switch to the base frequency.
            JR      SETFREQ2
SETFREQ1:   LD      A, TZSVC_CMD_CPU_ALTFREQ                             ; Switch to the alternate frequency.
SETFREQ2:   CALL    SVC_CMD
            OR      A
            JR      NZ,SETFREQERR
            LD      A,H
            CP      L
            RET     Z                                                    ; If we are disabling the alternate cpu frequency (ie. = 0) exit.
            LD      A, TZSVC_CMD_CPU_CHGFREQ                             ; Switch to the base frequency.
            CALL    SVC_CMD
            OR      A
            JR      NZ,SETFREQERR
            RET

            ; Simple routine to clear screen or attributes.
CLR8:       LD      BC,00800H
            PUSH    DE
            LD      D,A
CLR8_1:     LD      (HL),D
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,CLR8_1
            POP     DE
            RET  
            ;
NOFPGAERR:  LD      DE,MSGNOFPGA
            JR      BADNUM2
SETFREQERR: LD      DE,MSGFREQERR
            JR      BADNUM2
BADNUMERR:  LD      DE,MSGBADNUM
BADNUM2:    CALL    PRINTMSG
            RET

            ;-------------------------------------------------------------------------------
            ; END OF ADDITIONAL TZFS COMMANDS
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF PRINT ROUTINE METHODS
            ;-------------------------------------------------------------------------------

            ; Method to print out a true ASCII character, not the Sharp values. This is done using the mapping table ATBL for the
            ; range 0..127, 128.. call the original Sharp routine.
            ; Input: A = Ascii character.
PRINTASCII: PUSH    HL
            PUSH    BC
            CP      080H                                                 ; Anything above 080H isnt ascii so call original routine.
            JR      NC,PRINTASCII1
            CP      00DH                                                 ; Carriage Return? Dont map just execute via original Sharp call.
            JR      Z,PRINTASCII1
            LD      HL,ATBL
            LD      C,A
            LD      B,0
            ADD     HL,BC
            LD      A,(HL)
            CALL    ?DSP
PRINTASCII0:POP     BC
            POP     HL
            RET
PRINTASCII1:CALL    PRNT
            JR      PRINTASCII0

            ; Method to print out a string residing in this bank.
            ;
            ; As string messages take up space and banks are limited, it makes sense to locate all strings in one
            ; bank and print them out from here, hence this method.
            ;
            ; Also, as strings often require embedded values to be printed (aka printf), a basic mechanism for printing out stack
            ; parameters is provided. A PUSH before calling this method followed by an embedded marker (ie. 0xFF) will see the stack
            ; value printed in hex at the point in the string where the marker appears.
            ;
            ; Input:  DE = Address, in this bank or any other location EXCEPT another bank.
            ;         BC = Value to print with marker 0xFB if needed.
            ;         Upto 4 stack values accessed by markers 0xFF, 0xFE, 0xFD, 0xFC
PRINTMSG:   LD      A,(DE)
            CP      000H                                                 ; End of string?
            RET     Z
            CP      0FFH                                                 ; Marker to print out first stack parameter.
            JR      Z,PRINTMSG3
            CP      0FEH                                                 ; Marker to print out second stack parameter.
            JR      Z,PRINTMSG6
            CP      0FDH                                                 ; Marker to print out third stack parameter.
            JR      Z,PRINTMSG7
            CP      0FCH                                                 ; Marker to print out fourth stack parameter.
            JR      Z,PRINTMSG8
            CP      0FBH                                                 ; Marker to print out BC.
            JR      Z,PRINTMSG9
            CP      0FAH                                                 ; Marker to print out a filename with filename address stored in BC.
            JR      Z,PRINTMSG10
            CALL    PRINTASCII
PRINTMSG2:  INC     DE
            JR      PRINTMSG
PRINTMSG3:  LD      HL,6+0                                               ; Get first stack parameter, there are 2 pushes on the stack plus return address before the parameters.
PRINTMSG4:  ADD     HL,SP
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
PRINTMSG5:  CALL    PRTHL
            JR      PRINTMSG2
PRINTMSG6:  LD      HL,6+2
            JR      PRINTMSG4
PRINTMSG7:  LD      HL,6+4
            JR      PRINTMSG4
PRINTMSG8:  LD      HL,6+6
            JR      PRINTMSG4
PRINTMSG9:  PUSH    BC                                                   ; Print out contents of BC as 4 digit hex.
            POP     HL
            JR      PRINTMSG5
PRINTMSG10: PUSH    DE                                                   ; Print out a filename with pointer stored in BC.
            PUSH    BC
            POP     DE
            CALL    PRTFN
            POP     DE
            JR      PRINTMSG2


            ; Method to print out the filename within an MZF header or SD Card header.
            ; The name may not be terminated as the full 17 chars are used, so this needs
            ; to be checked. Also, the filename uses Sharp Ascii so call the original Sharp 
            ; print routine.
            ;
            ; Input: DE = Address of filename.
            ;
PRTFN:      PUSH    BC
            LD      B,FNSIZE                                             ; Maximum size of filename.
PRTMSG:     LD      A,(DE)
            INC     DE
            CP      000H                                                 ; If there is a valid terminator, exit.
            JR      Z,PRTMSGE
            CP      00DH
            JR      Z,PRTMSGE
            CALL    PRNT
            DJNZ    PRTMSG                                               ; Else print until 17 chars have been processed.
            CALL    NL
PRTMSGE:    POP     BC
            RET

            ; A modified print string routine with full screen pause to print out the help screen text. The routine prints out true ascii
            ; as opposed to Sharp modified ascii.
            ; A string is NULL terminated.
PRTSTR:     PUSH    AF
            PUSH    BC
            PUSH    DE
            LD      A,0
            LD      (TMPLINECNT),A
PRTSTR1:    LD      A,(DE)
            CP      000H                                                 ; NULL terminates the string.
            JR      Z,PRTSTRE
            CP      00DH                                                 ; As does CR.
            JR      Z,PRTSTR3
PRTSTR2:    CALL    PRINTASCII
            INC     DE
            JR      PRTSTR1                   
PRTSTR3:    PUSH    AF
            LD      A,(TMPLINECNT)
            CP      23                                                   ; Check to see if a page of output has been displayed, if it has, pause.
            JR      Z,PRTSTR5
            INC     A
PRTSTR4:    LD      (TMPLINECNT),A
            POP     AF
            JR      PRTSTR2
PRTSTR5:    CALL    GETKY
            CP      ' '
            JR      NZ,PRTSTR5
            XOR     A
            JR      PRTSTR4
PRTSTRE:    POP     DE
            POP     BC
            POP     AF
            RET     

            ; TRUE ASCII TO DISPLAY CODE TABLE
            ;
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
ATBLE:      EQU     $

            ;-------------------------------------------------------------------------------
            ; END OF PRINT ROUTINE METHODS
            ;-------------------------------------------------------------------------------


            ; The FDC controller uses it's busy/wait signal as a ROM address line input, this
            ; causes a jump in the code dependent on the signal status. It gets around the 2MHz Z80 not being quick
            ; enough to process the signal by polling.
            ALIGN_NOPS FDCJMP1BLK
            ORG      FDCJMP1BLK
            ALIGN_NOPS FDCJMP1
            ORG      FDCJMP1
FDCJMPL2:   JP       (IX)      


            ; The FDC controller uses it's busy/wait signal as a ROM address line input, this
            ; causes a jump in the code dependent on the signal status. It gets around the 2MHz Z80 not being quick
            ; enough to process the signal by polling.
            ALIGN_NOPS FDCJMP2BLK
            ORG      FDCJMP2BLK
            ALIGN_NOPS FDCJMP2
            ORG      FDCJMP2               
FDCJMPH2:   JP       (IY)


            ;-------------------------------------------------------------------------------
            ; START OF HELP SCREEN FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Simple help screen to display commands.
HELP:       ;CALL    NL
            LD      DE, HELPSCR
            CALL    PRTSTR
            RET

            ; Help text. Use of lower case, due to Sharp's non standard character set, is not easy, you have to manually code each byte
            ; hence using upper case.
HELPSCR:    ;       "--------- 40 column width -------------"
            DB      "4     - 40 col mode.",                                 00DH
            DB      "8     - 80 col mode.",                                 00DH
            DB      "40A   - Select MZ-80A 40col Mode.",                    00DH
            DB      "80A   - Select MZ-80A 80col Mode.",                    00DH
            DB      "80B   - Select MZ-80B Mode.",                          00DH
            DB      "700   - Select MZ-700 40col Mode.",                    00DH
            DB      "7008  - Select MZ-700 80col Mode.",                    00DH
            DB      "B     - toggle keyboard bell.",                        00DH
            DB      "BASIC - Load BASIC SA-5510.",                          00DH
            DB      "C[b]  - clear memory $1200-$D000.",                    00DH
            DB      "CPM   - Load CPM.",                                    00DH
            DB      "DXXXX[YYYY] - dump mem XXXX to YYYY.",                 00DH
            DB      "EC[fn]- erase file, fn=No or Filename",                00DH
            DB      "EX    - Exit TZFS, reset as original.",                00DH
            DB      "F[x]  - boot fd drive x.",                             00DH
            DB      "FREQ[n]-set CPU to nKHz, 0 for default.",              00DH
            DB      "H     - this help screen.",                            00DH
            DB      "IC[wc]- SD dir listing, wc=wildcard.",                 00DH
            DB      "JXXXX - jump to location XXXX.",                       00DH
            DB      "LT[fn]- load tape, fn=Filename",                       00DH
            DB      "LC[fn]- load from SD, fn=No or Filename",              00DH
            DB      "      - add NX for no exec, ie.LCNX.",                 00DH
            DB      "MXXXX - edit memory starting at XXXX.",                00DH
            DB      "P     - test printer.",                                00DH
            DB      "R     - test dram memory.",                            00DH
            DB      "SDD[d]- change to SD dir 'd'.",                        00DH
            DB      "SD2T  - copy sd card to tape.",                        00DH
            DB      "ST[XXXXYYYYZZZZ] - save mem to tape.",                 00DH
            DB      "SC[XXXXYYYYZZZZ] - save mem to card.",                 00DH
            DB      "        XXXX=start,YYYY=end,ZZZZ=exec",                00DH
            DB      "T     - test timer.",                                  00DH
            DB      "T2SD  - copy tape to sd card.",                        00DH
            DB      "V     - verify tape save.",                            00DH
            DB      "VBORDER[n] - set vga border colour.",                  00DH
            DB      "VMODE[n] - set video mode.",                           00DH
            DB      "VGA[n]- Set VGA mode.",                                00DH
            DB      000H

            ;-------------------------------------------------------------------------------
            ; END OF HELP SCREEN FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ;
            ; Message table
            ;
            ;-------------------------------------------------------------------------------
MSGSON:     DB      "+ TZFS v1.3  **",                                              00DH, 000H                     ; Version 1.0-> first split from RFS v2.0
MSGNOTFND:  DB      "Not Found",                                                    00DH, 000H
MSGBADCMD:  DB      "???",                                                          00DH, 000H
MSGSDRERR:  DB      "SD Read error, Sec:",0FBH,                                           000H
MSGSVFAIL:  DB      "Save failed.",                                                 00DH, 000H
MSGERAFAIL: DB      "Erase failed.",                                                00DH, 000H
MSGCDFAIL:  DB      "Directory invalid.",                                           00DH, 000H
MSGERASEDIR:DB      "Deleted dir entry:",0FBH,                                            000H
MSGCMTDATA: DB      "Load:",0FEH,",Exec:",0FFH, ",Size:",                     0FBH, 00DH, 000H
MSGNOTBIN:  DB      "Not binary",                                                   00DH, 000H
MSGLOAD:    DB      00DH, "Loading ",'"',0FAH,'"',                                  00DH, 000H
MSGSAVE:    DB      00DH, "Filename: ",                                                   000H
MSGE1:      DB      00DH, "Check sum error!",                                       00DH, 000H                      ; Check sum error.
MSGCMTWRITE:DB      00DH, "Writing ", '"',0FAH,'"',                                 00DH, 000H
MSGOK:      DB      00DH, "OK!",                                                    00DH, 000H
MSGSAVEOK:  DB      "Tape image saved.",                                            00DH, 000H
MSGBOOTDRV: DB      00DH, "Floppy boot drive ?",                                          000H
MSGLOADERR: DB      00DH, "Disk loading error",                                     00DH, 000H
MSGIPLLOAD: DB      00DH, "Disk loading ",                                                000H
MSGDSKNOTMST:DB     00DH, "This is not a boot disk",                                00Dh, 000H
MSGINITM:   DB      "Init memory",                                                  00DH, 000H
MSGREAD4HEX:DB      "Bad hex number",                                               00DH, 000H
MSGT2SDERR: DB      "Copy from Tape to SD Failed",                                  00DH, 000H
MSGSD2TERR: DB      "Copy from SD to Tape Failed",                                  00DH, 000H
MSGT2SDOK:  DB      "Success, Tape to SD done.",                                    00DH, 000H
MSGSD2TOK:  DB      "Success, SD to Tape done.",                                    00DH, 000H
MSGUNKNHW:  DB      "Unknown hardware, cannot change!",                             00DH, 000H
MSGFAILBIOS:DB      "Failed to load alternate BIOS!",                               00DH, 000H
MSGFAILEXIT:DB      "TZFS exit failed, I/O proc error!",                            00DH, 000H
MSGFREQERR: DB      "Error, failed to change frequency!",                           00DH, 000H
MSGBADNUM:  DB      "Error, bad number supplied!",                                  00DH, 000H
MSGNOFPGA:  DB      "Error, no FPGA video module!",                                 00DH, 000H
;
OKCHECK:    DB      ", CHECK: ",                                                    00Dh, 000H
OKMSG:      DB      " OK.",                                                         00Dh, 000H
DONEMSG:    DB      11h
            DB      "RAM TEST COMPLETE.",                                           00Dh, 000H
BITMSG:     DB      " BIT:  ",                                                      00Dh, 000H
BANKMSG:    DB      " BANK: ",                                                      00Dh, 000H
MSG_TIMERTST:DB     "8253 TIMER TEST",                                              00Dh, 000H
MSG_TIMERVAL:DB     "READ VALUE 1: ",                                               00Dh, 000H
MSG_TIMERVAL2:DB    "READ VALUE 2: ",                                               00Dh, 000H
MSG_TIMERVAL3:DB    "READ DONE.",                                                   00Dh, 000H

SVCRESPERR: DB      "I/O Response Error, time out!",00DH, 000H
SVCIOERR:   DB      "I/O Error, time out!",         00DH, 000H


TESTMSG:  DB      "HL is:",0FBH,    00DH,       000H
TESTMSG2:  DB      "DE is:",0FBH,    00DH,       000H
TESTMSG3:  DB      "BC is:",0FBH,    00DH,       000H
TESTMSG4:  DB      "4 is:",0FBH,    00DH,       000H
            ;
            ; Ensure we fill the entire 4K by padding with FF's.
            ;
            ALIGN_NOPS      10000H
