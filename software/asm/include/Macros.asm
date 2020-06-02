;--------------------------------------------------------------------------------------------------------
;-
;- Name:            Macros.asm
;- Created:         July 2019
;- Author(s):       Philip Smart
;- Description:     Z80 Assembler Macros Library
;-                  This is an aassembly language macro source file containing resusable code in the form
;                   of Macros for the various Z80 projects under development.
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

            ; the following is only to get the original length of 2048 bytes
ALIGN:      MACRO    ?boundary
            DS       ?boundary - 1 - ($ + ?boundary - 1) % ?boundary, 0FFh
            ENDM

            ; the following is only to get the original length of 2048 bytes
ALIGN_NOPS: MACRO    ?boundary
            DS       ?boundary - 1 - ($ + ?boundary - 1) % ?boundary, 000h
            ENDM

            ;
            ; Pads up to a certain address.
            ; Gives an error message if that address is already exceeded.
            ;
PAD:        MACRO ?address
	        IF $ > ?address
		        ERROR "Alignment exceeds %s"; % ?address
	        ENDIF
	        DS ?address - $
	        ENDM

            ;
            ; Pads up to the next multiple of the specified address.
            ;
            ;ALIGN: MACRO ?boundary
            ;	ds ?boundary - 1 - ($ + ?boundary - 1) % ?boundary
            ;	ENDM

            ;
            ; Pads to ensure a section of the given size does not cross a 100H boundary.
            ;
ALIGN_FIT8: MACRO ?size
	        DS      (($ + ?size - 1) >> 8) != ($ >> 8) && (100H - ($ & 0FFH)) || 0
	        ENDM

            ; Macro to create a Jump table entry point for a Bank to Bank function call.
            ; The address of the real function in the required page is given as ?addr
            ; and the bank in which it will reside is given in ?bank. The logic then takes
            ; care of stack and memory mode manipulation to call the method and return to the
            ; caller with all registers unaffected going to the called function and returning from
            ; the called function. This allows any method to be placed in a bank as space dictates.
CALLBNK:    MACRO ?addr, ?bank
            EXX
            EX      AF,AF'
            LD      HL,?addr                                             ; Real function to call.
            LD      A,?bank                                              ; Bank in which the function resides.
            JP      BANKTOBANK_
	        ENDM

            ; As above but just jump to the required location in the alternate bank, no return.
JMPBNK:     MACRO ?addr, ?bank
            EX      AF,AF'
            LD      A,?bank                                              ; Bank in which the function resides.
            LD      (MMCFGVAL),A                                         ; Store the value in a memory variable as we cant read the latch once programmed.
            OUT     (MMCFG),A                                            ; Switch to the TZFS memory mode, SA1510 is now in RAM at 0000H
            EX      AF,AF'
            LD      HL,?addr                                             ; Real function to jump to.
            JP      (HL)
	        ENDM

            ; Method to allow one bank to call a routine in another bank with all registers preserved in and out and
            ; reentrant so banks can call banks. It is costly in processing time and should only be
            ; used infrequently.
            ;
            ; Input: A       = Memory mode to switch into.
            ;        (HLSAVE)= Original HL to pass to caller.
            ;        HL      = Address to call.
            ;        AF      = Stored on stack to pass to called function.
            ;        All other registers passed to called function.
            ; All registers are passed untouched to the caller.
            ; Stack; BKTOBKRET:AF (original memory mode) : Caller return address.
            ; Output: All registers and flags returned to caller.
            ;
JMPTOBNK:   MACRO
            LD      (FNADDR),HL                                          ; Save the function to call address stored in HL
            LD      L,A                                                  ; Save A to retrieve the old Memory mode and push it on the stack so it can be restored after return.
            LD      A,(MMCFGVAL)
            PUSH    AF
            LD      A,L
            ; NB. Dont disable interrupts, goes to mode 7 then returns to MMCFGVAL,so apart from a double switch there should be no race state.
            LD      (MMCFGVAL),A                                         ; Store the value in a memory variable as we cant read the latch once programmed.
            OUT     (MMCFG),A                                            ; Switch to the TZFS memory mode, SA1510 is now in RAM at 0000H
            LD      HL,BKTOBKRET                                         ; Store the return address which must come back to this functionality before original caller.
            PUSH    HL
            LD      HL,(FNADDR)                                          ; Push the address of the function to call onto the stack.
            PUSH    HL
            EXX
            EX      AF,AF'
            RET                                                          ; Call the required function by popping address off stack.
BKTOBKRET:  EX      (SP),HL                                              ; Retrieve original memory mode from stack.
            EX      AF,AF'
            LD      A,H
            LD      (MMCFGVAL),A                                         ; Store the value in a memory variable as we cant read the latch once programmed.
            OUT     (MMCFG),A                                            ; Switch to the TZFS memory mode, SA1510 is now in RAM at 0000H
            EX      AF,AF'
            POP     HL                                                   ; Restore HL.
            RET
            ENDM

            ; Alternate version which preserves caller stack and creates local stack, used in CPM where the caller (CPM) has a tiny stack
            ; and the CBIOS needs more space. This version isnt reentrant, it is only used one way, CPM -> CBIOS.
JMPTOBNK2:  MACRO
            LD      (STKSAVE),SP
            LD      SP,CBIOSSTACK
            LD      (FNADDR),HL                                          ; Save the function to call address stored in HL
            ; NB. Dont disable interrupts, goes to mode 7 then returns to MMCFGVAL,so apart from a double switch there should be no race state.
            LD      A,TZMM_CPM2
            LD      (MMCFGVAL),A                                         ; Store the value in a memory variable as we cant read the latch once programmed.
            OUT     (MMCFG),A                                            ; Switch to the TZFS memory mode, SA1510 is now in RAM at 0000H
            LD      HL,BKTOBKRET2                                        ; Store the return address which must come back to this functionality before original caller.
            PUSH    HL
            LD      HL,(FNADDR)                                          ; Push the address of the function to call onto the stack.
            PUSH    HL
            EXX
            EX      AF,AF'
            RET                                                          ; Call the required function by popping address off stack.
BKTOBKRET2: EX      AF,AF'
            LD      A,TZMM_CPM
            LD      (MMCFGVAL),A                                         ; Store the value in a memory variable as we cant read the latch once programmed.
            OUT     (MMCFG),A                                            ; Switch to the TZFS memory mode, SA1510 is now in RAM at 0000H
            EX      AF,AF'
            LD      SP,(STKSAVE)
            RET
            ENDM
