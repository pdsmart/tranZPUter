; Disassembly of the file "D:\MZ80AFI.BIN"
; 
; CPU Type: Z80
; 
; Using the opcode map file "D:\DZ80-INI.MAP"
; ; Created with dZ80 2.0
; 
; on Thursday, 06 of February 2020 at 01:38 PM
; 
i          ; Bring in additional resources.
           INCLUDE "TZFS_Definitions.asm"
           INCLUDE "Macros.asm"


           ;======================================
           ;
           ; Floppy Disk Interface
           ;
           ;======================================
           ORG      0E800H

FLOPPY:    NOP
           LD       DE,01008H
           LD       HL,PRMBLK
           LD       BC,0000BH
           LDIR     
           CALL     L0151
L000F:     CALL     NL
           LD       DE,BOOTDRV
           CALL     MSG
           LD       DE,011A3H
           CALL     GETL
           LD       A,(DE)
           CP       01BH
           JP       Z,SS
           LD       HL,0000CH
           ADD      HL,DE
           LD       A,(HL)
           CP       00DH
           JR       Z,L003A                 ; (+00dh)
           CALL     03F9H
           JR       C,L000F                 ; (-023h)
           DEC      A
           CP       004H
           JR       NC,L000F                ; (-028h)
           LD       (01008H),A
L003A:     LD       IX,01008H
           CALL     L01BA
           LD       HL,0CE00H
           LD       DE,DSKID
           LD       B,007H
L0049:     LD       C,(HL)
           LD       A,(DE)
           CP       C
           JP       NZ,L008C
           INC      HL
           INC      DE
           DJNZ     L0049                   ; (-00ah)
           CALL     NL
           LD       DE,IPLLOAD
           CALL     MSG
           LD       DE,0CE07H
           CALL     MSG
           LD       HL,(0CE16H)
           LD       (IX+005H),L
           LD       (IX+006H),H
           LD       HL,(0CE14H)
           LD       (IX+003H),L
           LD       (IX+004H),H
           LD       HL,(0CE1EH)
           LD       (IX+001H),L
           LD       (IX+002H),H
           CALL     L01BA
           CALL     L0151
           LD       HL,(0CE18H)
           JP       (HL)

L0087:     LD       DE,LOADERR
           JR       L008F                   ; (+003h)

L008C:     LD       DE,DSKNOTMST
L008F:     CALL     NL
           CALL     MSG
           CALL     NL
           LD       DE,DSKDAT
           CALL     MELDY
           JP       SS

BOOTDRV:   DB       "BOOY DRIVE ?", 00DH
LOADERR:   DB       "LOADING ERROR", 00DH
IPLLOAD:   DB       "IPL IS LOADING ", 00DH
DSKID:     DB       002H, "IPLPRO"
DSKDAT:    DB       "A0", 0D7H, "ARA", 0D7H, "AR", 00DH
PRMBLK:    DB       000H, 000H, 000H, 000H, 001H, 000H, 0CEH, 000H, 000H, 000H, 000H
DSKNOTMST: DB       "THIS DISKETTE IS NOT MASTER", 00Dh

L0104:     LD       A,(01001H)
           RRCA     
           CALL     NC,L0138
           LD       A,(IX+000H)
           OR       084H
           OUT      (0DCH),A
           XOR      A
           LD       (01000H),A
           LD       HL,00000H
L0119:     DEC      HL
           LD       A,H
           OR       L
           JP       Z,L029D
           IN       A,(0D8H)
           CPL      
           RLCA     
           JR       C,L0119                 ; (-00ch)
           LD       C,(IX+000H)
           LD       HL,01002H
           LD       B,000H
           ADD      HL,BC
           BIT      0,(HL)
           JR       NZ,L0137                ; (+005h)
           CALL     L0164
           SET      0,(HL)
L0137:     RET      
 
L0138:     LD       A,080H
           OUT      (0DCH),A
           LD       B,010H
L013E:     CALL     L02C7
           DJNZ     L013E                   ; (-005h)
           LD       A,001H
           LD       (01001H),A
           RET      

L0149:     LD       A,01BH
           CALL     L0171
           AND      099H
           RET      

L0151:     XOR      A
           OUT      (0DCH),A
           LD       (01002H),A
           LD       (01003H),A
           LD       (01004H),A
           LD       (01005H),A
           LD       (01001H),A
           RET      

L0164:     LD       A,00BH
           CALL     L0171
           AND      085H
           XOR      004H
           RET      Z
           JP       L029D

L0171:     LD       (01000H),A
           CPL      
           OUT      (0D8H),A
           CALL     L017E
           IN       A,(0D8H)
           CPL      
           RET      

L017E:     PUSH     DE
           PUSH     HL
           CALL     L02C0
           LD       E,007H
L0185:     LD       HL,00000H
L0188:     DEC      HL
           LD       A,H
           OR       L
           JR       Z,L0196                 ; (+009h)
           IN       A,(0D8H)
           CPL     
           RRCA    
           JR       C,L0188                 ; (-00bh)
           POP      HL
           POP      DE
           RET     

L0196:     DEC      E
           JR       NZ,L0185                ; (-014h)
           JP       L029D

L019C:     PUSH     DE
           PUSH     HL
           CALL     L02C0
           LD       E,007H
L01A3:     LD       HL,00000H
L01A6:     DEC      HL
           LD       A,H
           OR       L
           JR       Z,L01B4                 ; (+009h)
           IN       A,(0D8H)
           CPL     
           RRCA    
           JR       NC,L01A6                ; (-00bh)
           POP      HL
           POP      DE
           RET      

L01B4:     DEC      E
           JR       NZ,L01A3                ; (-014h)
           JP       L029D

L01BA:     CALL     L0220
L01BD:     CALL     L0229
L01C0:     CALL     L0249
           CALL     L0149
           JR       NZ,L0216                ; (+04eh)
           CALL     L0259
           PUSH     IX
           LD       IX,L03FE
           LD       IY,L01DF
           DI      
           LD       A,094H
           CALL     L028A
L01DB:     LD       B,000H
           JP       (IX)

L01DF:     INI     
           JP       NZ,L03FE
           POP      IX
           INC      (IX+008H)
           LD       A,(IX+008H)
           PUSH     IX
           LD       IX,L03FE
           CP       011H
           JR       Z,L01FB                 ; (+005h)
           DEC      D
           JR       NZ,L01DB                ; (-01eh)
           JR       L01FC                   ; (+001h)
L01FB:     DEC      D
L01FC:     CALL     L0294
           CALL     L02D2
           POP      IX
           IN       A,(0D8H)
           CPL      
           AND      0FFH
           JR       NZ,L0216                ; (+00bh)
           CALL     L0278
           JP       Z,L021B
           LD       A,(IX+007H)
           JR       L01C0                   ; (-056h)
L0216:     CALL     L026A
           JR       L01BD                   ; (-05eh)

L021B:     LD       A,080H
           OUT      (0DCH),A
           RET     

L0220:     CALL     L02A3
           LD       A,00AH
           LD       (01006H),A
           RET     

L0229:     CALL     L0104
           LD       D,(IX+004H)
           LD       A,(IX+003H)
           OR       A
           JR       Z,L0236                 ; (+001h)
           INC      D
L0236:     LD       A,(IX+00AH)
           LD       (IX+008H),A
           LD       A,(IX+009H)
           LD       (IX+007H),A
           LD       L,(IX+005H)
           LD       H,(IX+006H)
           RET     

L0249:     SRL      A
           CPL     
           OUT      (0DBH),A
           JR       NC,L0254                ; (+004h)
           LD       A,001H
           JR       L0255                   ; (+001h)
L0254:     XOR      A
L0255:     CPL     
           OUT      (0DDH),A
           RET     

L0259:     LD       C,0DBH
           LD       A,(IX+007H)
           SRL      A
           CPL     
           OUT      (0D9H),A
           LD       A,(IX+008H)
           CPL     
           OUT      (0DAH),A
           RET     

L026A:     LD       A,(01006H)
           DEC      A
           LD       (01006H),A
           JP       Z,L029D
           CALL     L0164
           RET     

L0278:     LD       A,(IX+008H)
           CP       011H
           JR       NZ,L0287                ; (+008h)
           LD       A,001H
           LD       (IX+008H),A
           INC      (IX+007H)
L0287:     LD       A,D
           OR       A
           RET     

L028A:     LD       (01000H),A
           CPL     
           OUT      (0D8H),A
           CALL     L019C
           RET      

L0294:     LD       A,0D8H
           CPL     
           OUT      (0D8H),A
           CALL     L017E
           RET     

L029D:     CALL     L0151
           JP       L0087

L02A3:     LD       B,000H
           LD       DE,00010H
           LD       L,(IX+001H)
           LD       H,(IX+002H)
           XOR      A
L02AF:     SBC      HL,DE
           JR       C,L02B6                 ; (+003h)
           INC      B
           JR       L02AF                   ; (-007h)
L02B6:     ADD      HL,DE
           LD       H,B
           INC      L
           LD       (IX+009H),H
           LD       (IX+00AH),L
           RET     

L02C0:     PUSH     DE
           LD       DE,00007H
           JP       L02CB

L02C7:     PUSH     DE
           LD       DE,01013H
L02CB:     DEC      DE
           LD       A,E
           OR       D
           JR       NZ,L02CB                ; (-005h)
           POP      DE
           RET     

L02D2:     PUSH     AF
           LD       A,(0119CH)
           CP       0F0H
           JR       NZ,L02DB                ; (+001h)
           EI      
L02DB:     POP      AF
           RET     

           ALIGN    0EBFDh
           DB       0FFh

L03FE:     JP       (IY)
;DB       0DDH
;           DB       0E9H

           ; Ensure we fill the entire 1K by padding with FF's.
           ALIGN    0EFFDh
           DB       0FFh

LF7FE:     DB       0fDH
           DB       0E9H
