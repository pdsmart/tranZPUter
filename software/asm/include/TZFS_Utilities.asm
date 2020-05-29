;--------------------------------------------------------------------------------------------------------
;-
;- Name:            RFS_Utilities.asm
;- Created:         September 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series tzfs (tranZPUter Filing System).
;-                  This assembly language program is a branch from the original RFS written for the
;-                  MZ80A_RFS upgrade board. It is adapted to work within the similar yet different 
;-                  environment of the tranZPUter SW which has a large RAM capacity (512K) and an
;-                  I/O processor in the K64F/ZPU.
;-
;- Credits:         
;- Copyright:       (c) 2019-20 Philip Smart <philip.smart@net2net.org>
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

           ; Comparing Strings
           ; IN    HL     Address of string1.
           ;       DE     Address of string2.
           ;       BC     Max bytes to compare, 0x00 or 0x0d will early terminate.
           ; OUT   zero   Set if string1 = string2, reset if string1 != string2.
           ;       carry  Set if string1 > string2, reset if string1 <= string2.
CMPSTRING: IF USE_CMPSTRING = 1
           PUSH     HL
           PUSH     DE

CMPSTR1:   LD       A, (DE)          ; Compare bytes.
           CP       000h             ; Check for end of string.
           JR       Z,  CMPSTR3
           CP       00Dh
           JR       Z,  CMPSTR3
           CPI                       ; Compare bytes.
           JR       NZ, CMPSTR2      ; If (HL) != (DE), abort.
           INC      DE               ; Update pointer.
           JP       PE, CMPSTR1      ; Next byte if BC not zero.

CMPSTR2:   DEC      HL
           CP       (HL)            ; Compare again to affect carry.
CMPSTR4:   POP      DE
           POP      HL
           RET

CMPSTR3:   LD       A, (HL)
           CP       000h             ; Check for end of string.
           JR       Z, CMPSTR4
           CP       00Dh
           JR       Z, CMPSTR4
           SCF                       ; String 1 greater than string 2
           JR       CMPSTR4
           ENDIF


           ; IN   HL   Address of source string, length-prefixed.
           ;      DE   Address of destination string, length-prefixed.
           ;      B    Start index. 1 = first character.
           ;      C    Length of substring to return.
           ;
           ; OUT  carry    Set if an error condition happened:
           ;                 If B is zero, then uses index of 1.
           ;                 If index > source length, an empty string is returned.
           ;                 If index + return length > source length, returns all
           ;                 characters from index to end-of-string.
    
SUBSTRING: IF USE_SUBSTRING = 1
           PUSH     DE        ; It would be convenient to keep DE pointing to
                              ; the start of the destination string
           OR       A         ; Boolean OR resets carry
           PUSH     AF        ; Save carry
           LD       A, B       ; Is index beyond source length?
           CP       (HL)
           DEC      A         ; Decrement A so NC can be used
           JR       NC,SUBST3

           ADD      A, C       ; If index+len is > 255, error
           JR       C, SUBST1
           INC      A         ; Increment A so C can be used
           CP       (HL)      ; If index+len is beyond source length, then error
           JR       C, SUBST2

SUBST1:    POP      AF        ; Set carry flag
           SCF
           PUSH     AF
           LD       A, (HL)    ; Get source length
           SUB      B         ; Subtract start index
           INC      A         ; Compensate
           LD       C, A       ; New size of string

SUBST2:    LD       A, C       ; Size of sting to get
           LD       (DE), A    ; Save length index
           INC      DE        ; To body of string
           LD       A, B       ; Get index
           LD       B, 0       ; Zero-extend BC for LDIR

           ADD      A, L       ; This is a sneaky way to add A to HL
           LD       L, A       ; without using up another 16-bit register
           ADC      A, H       ;
           SUB      L         ;
           LD       H, A       ;

           LDIR             ; Copy substring over
           POP      AF        ; Restore flags
           POP      DE        ; Restore destination
           RET

SUBST3:    XOR      A         ; Set a length index of zero
           LD       (DE), A
           POP      AF        ; Clean off stack and set carry
           POP      DE
           SCF
           RET
           ENDIF

           ; IN  HL       Address of string to look in, length prefixed.
           ;     DE       Address of string to find, length prefixed.
           ;
           ; OUT
           ;  If found:
           ;     A        Offset into look-up string where the target string was found.
           ;              The first byte (ignoring length prefix) is offset 1.
           ;     carry    Reset.
           ;
           ;  If not found:
           ;     A    = 0
           ;     carry    Set.
           
INDEX:     IF USE_INDEX = 1
           LD       A, (DE)    ; Abort if string to find is too big
           CP       (HL)
           INC      A
           JR       NC, IDXABORT

           DEC      A         ; Save length of string to find
           LD       IXL, A

           LD       B, 0       ; Put length of string to search in BC
           LD       C, (HL)

           INC      HL        ; Advance pointers
           INC      DE
           PUSH     HL        ; Save start of search string

IDXRST:    PUSH     DE        ; Save start of key string

           LD       A, IXL     ; Initialize matched characters counter
           LD       IXH, A

           LD       A, (DE)    ; Get a character to match
           CPIR             ; Look for it
           JR       NZ, IDXNF    ; Abort if not found

IDXLOOP:   DEC      IXH       ; Update counter and see if done
           JR       Z, IDXFOUND

           INC      DE        ; Get next character in key string
           LD       A, (DE) 
           CPI              ; See if it matches next char in master
           JR       Z, IDXLOOP
           JP       PO, IDXNF    ; Abort if we ran out of characters

           POP      DE        ; If a mismatch, restart from the beginning
           JR       IDXRST

IDXNF:     POP      DE        ; Clean stack
           POP      HL

IDXABORT:  XOR      A         ; Report failure
           SCF
           RET

IDXFOUND:  POP      DE
           POP      BC        ; BC = address of master

           XOR      A         ; Put size of key string in DE
           LD       D, A
           LD       E, IXL

           SBC      HL, DE     ; Find index
           SBC      HL, BC    
           LD       A, L
           INC      A
           RET
           ENDIF

           ; IN   HL      Address of string to be inserted
           ;      DE      Address of string to receive insertion
           ;      C       Index. Start of string is 0
           ; OUT
           ;  If successful:
           ;      carry   Reset
           ;      HL      Input DE
           ;  If unsuccessful:
           ;      carry   Set. If new string length is > 255.
           ;
           ; Notes        If index > string length, string is appended.
           ;              Data after the string is destroyed.

STRINSERT: IF USE_STRINSERT = 1
           LD       A, (DE)    
           LD       B, A

           INC      A
           CP       C
           JR       NC, STRINSERT1
           LD       C, B

STRINSERT1:DEC      A
           ADD      A, (HL)
           RET      C
           LD       (DE), A    ; Update length

           PUSH     DE        ; Make room
           PUSH     HL
           LD       A, (HL)
           INC      C

           LD       H, 0
           LD       L, C
           ADD      HL, DE

           LD       D, H
           LD       E, L
           PUSH     AF
           ADD      A, E
           LD       E, A
           ADC      A, D
           SUB      E
           LD       D, A
           POP      AF

           LD       B, 0
           LD       C, A
           PUSH     HL
           LDIR

           POP      DE        ; Copy string over
           POP      HL
           LD       C, (HL)
           INC      HL
           LDIR
           POP      HL
           RET
           ENDIF

           ; IN  HL       Address of string.
           ;     B        Index of first character to delete. First character is 0.
           ;     C        Number of characters to kill.
           ; OUT
           ;  If successful:
           ;     carry    Reset
           ;  If unsuccessful:
           ;     carry    Set
           ;
           ; Notes        If B > string length, then error.
           ;              If B + C > string length, deletion
           ;              stops at end of string.

STRDELETE: IF USE_STRDELETE = 1
           LD       A, B       ; See if index is too big
           CP       (HL)
           CCF              ; Flip for error
           RET      C

           ADD      A, C       ; See if too many chars on chopping block
           CP       (HL)
           JR       C, STRDELETE1

           INC      B         ; Set index as length
           LD       (HL), B
           RET

STRDELETE1:PUSH     HL
           LD       A, (HL)
           SUB      C
           LD       (HL), A
           INC      HL
 
           LD       E, C
           LD       C, B
           LD       B, 0
           ADD      HL, BC

           SUB      C
           LD       C, E
           LD       D, H
           LD       E, L
           ADD      HL, BC
           LD       C, A
           LDIR

           POP      HL
           RET
           ENDIF

           ; IN    HL       Address of first string.
           ;       DE       Address of second string.
           ; OUT
           ;  If successful:
           ;       carry    Reset
           ;  If unsuccessful:
           ;       carry    Set
           ;
           ; Notes        If new string lenght is > 255, error.
           ;        HL is saved.

CONCAT:    IF USE_CONCAT = 1
           LD       A, (DE)     ; Combine lengths
           ADD      A, (HL)
           RET      C
           LD       C, (HL)
           LD       (HL), A

           LD       B, 0
           INC      C
           PUSH     HL
           ADD      HL, BC
           EX       DE, HL
           LD       C, (HL)
           INC      HL
           LDIR

           POP      HL
           RET
           ENDIF

; Utility: Convert character to upper case
;   On entry: A = Character in either case
;   On exit:  A = Character in upper case
;             BC DE HL IX IY I AF' BC' DE' HL' preserved
ConvertCharToUCase: IF USE_CNVUPPER = 1
           CP       'a'            ;Character less than 'a'?
           RET      C              ;Yes, so finished
           CP       'z'+1          ;Character greater than 'z'?
           RET      NC             ;Yes, so finished
           SUB      'a'-'A'        ;Convert case
           RET
           ENDIF
;
; Utility: Convert character to numberic value
;   On entry: A = ASCII character (0-9 or A-F)
;   On exit:  If character is a valid hex digit:
;               A = Numberic value (0 to 15) and Z flagged
;             If character is not a valid hex digit:
;               A = 0xFF and NZ flagged
;             BC DE HL IX IY I AF' BC' DE' HL' preserved
;             Interrupts not enabled
ConvertCharToNumber: IF USE_CNVCHRTONUM = 1
           CALL ConvertCharToUCase
           CP       '0'            ;Character < '0'?
           JR       C,@Bad         ;Yes, so no hex character
           CP       '9'+1          ;Character <= '9'?
           JR       C,@OK          ;Yes, got hex character
           CP       'A'            ;Character < 'A'
           JR       C,@Bad         ;Yes, so not hex character
           CP       'F'+1          ;Character <= 'F'
           JR       C,@OK          ;No, not hex
; Character is not a hex digit so return 
@Bad:      LD       A,0FFh         ;Return status: not hex character
           OR       A              ;  A = 0xFF and NZ flagged
           RET
; Character is a hex digit so adjust from ASCII to number
@OK:       SUB      '0'            ;Subtract '0'
           CP       00Ah           ;Number < 10 ?
           JR       C,@Finished    ;Yes, so finished
           SUB      007h           ;Adjust for 'A' to 'F'
@Finished: CP       A              ;Return A = number (0 to 15) and Z flagged to
           RET                     ;  indicate character is a valid hex digital
           ENDIF

; Utility: Is character numeric?
;   On entry: A = ASCII character
;   On exit:  Carry flag set if character is numeric (0 to 9)
;             A BC DE HL IX IY I AF' BC' DE' HL' preserved
IsCharNumeric: IF USE_ISNUMERIC = 1
           CP       '0'            ;Less than '0'?
           JR       C,@Not2        ;Yes, so go return NOT numeric
           CP       '9'+1          ;Less than or equal to '9'?
           RET      C              ;Yes, so numeric (C flagged)
@Not2:     OR       A              ;No, so NOT numeric (NC flagged)
           RET
           ENDIF

; Utility: Convert hexadecimal or decimal text to number
;   On entry: DE = Pointer to start of ASCII string
;   On exit:  If valid number found:
;               A = 0 and Z flagged
;               HL = Number found
;             If valid number not found:
;               A != 0 and NZ flagged
;               HL = Not specified
;             DE = Not specified
;             HL = Number
;             BC DE IX IY I AF' BC' DE' HL' preserved
; Hexadecmal numbers can be prefixed with either "$" or "0x"
; Decimal numbers must be prefixed with "+"
; A number without a prefix is assumed to be hexadecimal
; Hexadecimal number without a prefix must start with "0" to "9"
; ... this is to stop the assembler getting confused between
; ... register names and constants which could be fixed by
; ... re-ordering the (dis)assebmer's instruction table
; Numbers can be terminated with ")", space, null or control code
; Negative numbers, preceded with "-", are not supported
; Text must be terminated with ')', space or control char.
ConvertStringToNumber: IF USE_CNVSTRTONUM = 1
           PUSH     BC
           LD       HL,0           ;Build result here
           LD       A,(DE)         ;Get character from string
           CP       '+'            ;Does string start with '+' ?
           JR       Z,@Decimal     ;Yes, so its decimal
           CP       '$'            ;Does string start with '$' ?
           JR       Z,@Hdecimal    ;Yes, so its hexadecimal
           CP       39             ;Does string start with apostrophe?
           JR       Z,@Char        ;Yes, so its a character
           CP       '"'            ;Does string start with '"' ?
           JR       Z,@Char        ;Yes, so its a character
;;         CALL     IsCharNumeric  ;Is first character '0' to '9' ?
;;         JR       NC,@Failure    ;No, so invalid number
;          CALL     IsCharHex      ;Is first character hexadecimal ?
;          JR       NC,@Failure    ;No, so invalid hex character
           CP       '0'            ;Is first character '0' ?
           JR       NZ,@HexNext    ;No, so default to hexadecimal
;          JR       NZ,@DecNext    ;No, so default to decimal
           INC      DE             ;Point to next character in string
           LD       A,(DE)         ;Get character from string
           CALL     ConvertCharToUCase
           CP       'X'            ;Is second character 'x' ?
           JR       NZ,@HexNext    ;No, so must be default format
;          JR       NZ,@DecNext    ;No, so must be default format
; Hexadecimal number...
@Hdecimal: INC      DE             ;Point to next character in string
@HexNext:  LD       A,(DE)         ;Get character from string
           CP       ')'            ;Terminated with a bracket?
           JR       Z,@Success     ;yes, so success
           CP       32+1           ;Space or control character?
           JR       C,@Success     ;Yes, so successld hl
           CALL     ConvertCharToNumber  ;Convert character to number
           JR       NZ,@Failure    ;Return if failure (NZ flagged)
           INC      DE             ;Point to next character in string
           ADD      HL,HL          ;Current result = 16 * current result..
           ADD      HL,HL
           ADD      HL,HL
           ADD      HL,HL
           OR       L              ;Add new number (0 to 15)..
           LD       L,A
           JR       @HexNext
; Decimal number...
@Decimal:  INC      DE             ;Point to next character in string
@DecNext:  LD       A,(DE)         ;Get character from string
           CP       ')'            ;Terminated with a bracket?
           JR       Z,@Success     ;yes, so success
           CP       32+1           ;Space or control character?
           JR       C,@Success     ;Yes, so success
           CALL     IsCharNumeric  ;Is first character '0' to '9' ?
           JR       NC,@Failure    ;No, so invalid number
           CALL     ConvertCharToNumber  ;Convert character to number
           JR       NZ,@Failure    ;Return if failure (NZ flagged)
           INC      DE             ;Point to next character in string
           PUSH     DE
           LD       B,9            ;Current result = 10 * current result..
           LD       D,H
           LD       E,L
@DecLoop:  ADD      HL,DE          ;Add result to itself 9 times
           DJNZ     @DecLoop
           POP      DE
           ADD      A,L            ;Add new number (0 to 15)..
           LD       L,A
           JR       NC,@DecNext
           INC      H
           JR       @DecNext
; Character...
@Char:     INC      DE             ;Point to next character in string
           LD       A,(DE)         ;Get ASCII character
           LD       L,A            ;Store ASCII value as result
           LD       H,0
;          JR       @Success
; Return result...
@Success:  POP      BC
           XOR      A              ;Return success with A = 0 and Z flagged
           RET
@Failure:  POP      BC
           LD       A,0FFh         ;Return failure with A != 0
           OR       A              ;  and NZ flagged
           RET
    ENDIF
