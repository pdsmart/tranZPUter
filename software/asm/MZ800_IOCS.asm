              ;
              ;
              ; SHARPMZ - 821
              ; (ROM contents, upper monitor E000-F3FF)
              ;
              ;
              ; Input / Output address
              INCLUDE "Macros.asm"

BRKEY:        EQU     0001EH

              ORG     0F400H

              JP      LF6C8
              JP      LF8FF
              JP      LF96A
              JP      LF9DC
              JP      LFA3D
              JP      LF7D0
              JP      LF5C1
              JP      LF5AD
              JP      LF47A
              JP      LF62F
              JP      LF566
              JP      LF543
              JP      LF551
              JP      LF53C
              JP      LF512
              JP      LFA90
              JP      LFA62
              JP      LF905
              JP      LF961
              ADD     A,007H
              SRL     A
              SRL     A
              SRL     A
              RET     

              XOR     A
              LD      B,003H
LF445:        SLA     C
              RLA     
              DJNZ    LF445                   ; (-005H)
              LD      B,A
              RET     

LF44C:        PUSH    BC
              LD      C,A
              LD      B,000H
              ADD     HL,BC
              POP     BC
              RET     

LF453:        LD      A,(HL)
              LD      (DE),A
              INC     HL
              INC     DE
              DJNZ    LF453                   ; (-006H)
              RET     

LF45A:        EX      (SP),IX
              PUSH    HL
              PUSH    BC
              PUSH    DE
              PUSH    AF
              PUSH    HL
              LD      HL,LF473
              EX      (SP),HL
              JP      (IX)
LF467:        EX      (SP),IX
              PUSH    HL
              PUSH    BC
              PUSH    DE
              PUSH    HL
              LD      HL,LF474
              EX      (SP),HL
              JP      (IX)
LF473:        POP     AF
LF474:        POP     DE
              POP     BC
              POP     HL
              POP     IX
              RET     

LF47A:        LD      HL,(012AEH)
              RET     C

              CALL    LF737
              NOP     
              JP      Z,LF566
              PUSH    HL
LF486:        POP     HL
LF487:        CALL    LF737
              NOP     
              RET     Z

              INC     HL
              CP      02CH
              JR      Z,LF487                 ; (-00aH)
              CP      04DH
              JR      Z,LF4E3                 ; (+04eH)
              CP      053H
              JR      Z,LF4CC                 ; (+033H)
              CP      051H
              JR      Z,LF4B1                 ; (+014H)
              DEC     HL
              CP      024H
              JR      Z,LF4A8                 ; (+006H)
              SUB     030H
              CP      00AH
              JR      NC,LF4FF                ; (+057H)
LF4A8:        CALL    LF76F
              LD      A,E
              LD      (01093H),A
              JR      LF487                   ; (-02aH)
LF4B1:        LD      B,008H
              CALL    LF4F5
              XOR     A
              LD      A,E
              AND     001H
              LD      (013CAH),A
              LD      A,E
              RR      A
              RRC     A
              RRC     A
              LD      (013CBH),A
              CALL    LF566
              JR      LF487                   ; (-045H)
LF4CC:        LD      A,(013D8H)
              LD      B,A
              CALL    LF4F5
              LD      B,A
              INC     B
              XOR     A
              SCF     
LF4D7:        ADC     A,A
              DJNZ    LF4D7                   ; (-003H)
              LD      (01092H),A
              XOR     A
              LD      (0108FH),A
              JR      LF487                   ; (-05cH)
LF4E3:        LD      B,003H
              CALL    LF4F5
              PUSH    HL
              LD      HL,LF486
              PUSH    HL
              OR      A
              JR      Z,LF50F                 ; (+01fH)
              DEC     A
              JR      Z,LF525                 ; (+032H)
              JR      LF51B                   ; (+026H)
LF4F5:        CALL    LF76F
              LD      A,D
              OR      A
              JR      NZ,LF4FF                ; (+003H)
              LD      A,E
              CP      B
              RET     C

LF4FF:        LD      A,003H
LF501:        LD      B,0FFH
LF503:        LD      HL,013D9H
              LD      (HL),B
              LD      SP,012A8H
              RET     

LF50B:        LD      A,03BH
              JR      LF501                   ; (-00eH)
LF50F:        CALL    LF566
LF512:        CALL    LF70F
LF515:        LD      HL,013D6H
              RES     7,(HL)
              RET     

LF51B:        LD      A,(013D6H)
              BIT     7,A
              RET     Z

              LD      B,002H
              JR      LF503                   ; (-022H)
LF525:        LD      HL,013D6H
              BIT     7,(HL)
              RET     NZ

              CALL    LF70F
              LD      A,(013C3H)
              CP      003H
              JR      NZ,LF50B                ; (-02aH)
              LD      A,083H
              OUT     (0FDH),A
              SET     7,(HL)
              RET     

LF53C:        LD      HL,013D6H
              BIT     0,(HL)
              JR      Z,LF551                 ; (+00eH)
LF543:        PUSH    HL
              LD      HL,013D6H
              BIT     0,(HL)
              JR      Z,LF564                 ; (+019H)
              RES     0,(HL)
              RES     1,(HL)
              JR      LF564                   ; (+013H)
LF551:        PUSH    HL
              LD      HL,013D6H
              BIT     7,(HL)
              JR      Z,LF564                 ; (+00bH)
              BIT     0,(HL)
              JR      NZ,LF564                ; (+007H)
              SET     0,(HL)
              BIT     1,(HL)
              CALL    NZ,LF6BE
LF564:        POP     HL
              RET     

LF566:        CALL    LF467
              CALL    LF543
              LD      HL,00000H
              LD      (013CEH),HL
              LD      HL,00000H
              CALL    LF764
              EX      DE,HL
              LD      (013D0H),HL
              LD      (013D2H),HL
              LD      (013D4H),HL
              EX      DE,HL
              LD      HL,VERSION
              SBC     HL,DE
              LD      (013CCH),HL
              XOR     A
              LD      (013D7H),A
              LD      A,(013C3H)
              CP      003H
              CALL    NZ,LF515
              CALL    LF705
              RET     

LF59B:        LD      A,(01093H)
              CALL    LF62F
              BIT     4,C
              LD      A,01AH
              CALL    NZ,LF636
              XOR     A
              LD      (01095H),A
              RET     

LF5AD:        CALL    LF45A
              LD      B,A
              LD      A,(0108FH)
              OR      A
              LD      A,B
              LD      E,0FFH
              JR      Z,LF5CC                 ; (+012H)
              RET     

LF5BB:        LD      IX,LF636
              JP      (IY)
LF5C1:        CALL    LF45A
              LD      B,A
              LD      A,(0108FH)
              OR      A
              LD      E,000H
              RET     NZ

LF5CC:        LD      A,(01097H)
              DEC     A
              LD      A,044H
              JP      NZ,LF657
              LD      A,(01092H)
              LD      C,A
              LD      A,B
              CP      00DH
              JR      Z,LF59B                 ; (-043H)
              LD      HL,01095H
              INC     (HL)
              BIT     2,C
              JR      NZ,LF5BB                ; (-02bH)
              CP      020H
              JR      NC,LF636                ; (+04cH)
              BIT     0,E
              JR      Z,LF5FE                 ; (+010H)
              SUB     011H
              CP      006H
              JR      C,LF637                 ; (+043H)
              SUB     0F4H
              CP      002H
              JR      NC,LF634                ; (+03aH)
              LD      A,02EH
              JR      LF636                   ; (+038H)
LF5FE:        BIT     3,C
              JR      NZ,LF636                ; (+034H)
              LD      HL,01095H
              DEC     (HL)
              LD      A,B
              CP      015H
              LD      B,00FH
              JR      Z,LF637                 ; (+02aH)
              CP      00CH
              JR      Z,LF637                 ; (+026H)
              CP      011H
              LD      B,009H
              JR      Z,LF637                 ; (+020H)
              CP      012H
              LD      B,00BH
              JR      Z,LF637                 ; (+01aH)
              CP      016H
              JR      NZ,LF636                ; (+015H)
              LD      A,00CH
              CALL    LF636
              LD      A,00AH
              CALL    LF636
              LD      A,003H
              JR      LF636                   ; (+007H)
LF62F:        CALL    LF45A
              JR      LF636                   ; (+002H)
LF634:        LD      A,020H
LF636:        LD      B,A
LF637:        LD      A,(01092H)
              BIT     1,A
              JR      Z,LF662                 ; (+024H)
              LD      HL,013D7H
              LD      A,(HL)
              CP      002H
              JR      Z,LF650                 ; (+00aH)
              LD      A,B
              INC     (HL)
              CP      00BH
              JR      Z,LF662                 ; (+016H)
              LD      (HL),000H
              JR      LF662                   ; (+012H)
LF650:        LD      A,(013D6H)
              BIT     7,A
              JR      Z,LF662                 ; (+00bH)
LF657:        LD      A,0C4H
              LD      HL,(0106EH)
              LD      (01044H),HL
              JP      LF501
LF662:        LD      A,(013D6H)
              BIT     7,A
              JR      NZ,LF670                ; (+007H)
              CALL    LF70F
              LD      A,B
              JP      LF6F0
LF670:        CALL    LF551
              LD      A,(01094H)
              LD      C,A
LF677:        LD      HL,03390H
LF67A:        CALL    LF6B0
              JR      NC,LF68A                ; (+00bH)
              DEC     HL
              LD      A,H
              OR      L
              JR      NZ,LF67A                ; (-00aH)
              DEC     C
              JR      NZ,LF677                ; (-010H)
              JP      LF731
LF68A:        LD      HL,(013CEH)
              LD      A,H
              OR      L
              INC     HL
              LD      (013CEH),HL
              JR      NZ,LF69D                ; (+008H)
              CALL    LF70F
              LD      A,B
              CALL    LF6F0
              RET     

LF69D:        LD      HL,(013D0H)
              LD      A,B
              CALL    LF743
              INC     HL
              LD      A,H
              OR      L
              JR      NZ,LF6AC                ; (+003H)
              LD      HL,(013D4H)
LF6AC:        LD      (013D0H),HL
              RET     

LF6B0:        CALL    LF467
              LD      HL,(013CCH)
              LD      DE,(013CEH)
              OR      A
              SBC     HL,DE
              RET     

LF6BE:        PUSH    AF
              PUSH    HL
              PUSH    BC
              CALL    LF6C8
              POP     BC
              POP     HL
              POP     AF
              RET     

LF6C8:        LD      HL,013D6H
              SET     1,(HL)
              BIT     0,(HL)
              RET     Z

              LD      HL,(013CEH)
              LD      A,H
              OR      L
              RET     Z

              DEC     HL
              LD      A,H
              OR      L
              LD      (013CEH),HL
              RET     Z

              LD      HL,(013D2H)
              CALL    LF74E
              LD      B,A
              INC     HL
              LD      A,H
              OR      L
              JR      NZ,LF6EC                ; (+003H)
              LD      HL,(013D4H)
LF6EC:        LD      (013D2H),HL
              LD      A,B
LF6F0:        OUT     (0FFH),A
              LD      A,080H
              CALL    LF706
              LD      A,(013CAH)
              OR      A
              JR      NZ,LF705                ; (+008H)
LF6FD:        IN      A,(0FEH)
              AND     00DH
              CP      001H
              JR      NZ,LF6FD                ; (-008H)
LF705:        XOR     A
LF706:        PUSH    HL
              LD      HL,013CBH
              XOR     (HL)
              POP     HL
              OUT     (0FEH),A
              RET     

LF70F:        XOR     A
              CALL    LF467
              LD      C,A
              LD      A,(01094H)
              LD      B,A
LF718:        LD      HL,0E678H
LF71B:        IN      A,(0FEH)
              AND     00DH
              CP      C
              RET     Z

              DEC     HL
              LD      A,H
              OR      L
              NOP     
              NOP     
              JR      NZ,LF71B                ; (-00dH)
              DJNZ    LF718                   ; (-012H)
              XOR     A
              LD      (0108FH),A
              CALL    LF705
LF731:        LD      A,041H
              JP      LF501
LF736:        INC     HL
LF737:        LD      A,(HL)
              CP      020H
              JR      Z,LF736                 ; (-006H)
              EX      (SP),HL
              CP      (HL)
              INC     HL
              EX      (SP),HL
              RET     NZ

              INC     HL
              RET     

LF743:        PUSH    BC
              LD      C,0EBH
              LD      B,H
              OUT     (C),L
              OUT     (0EAH),A
              POP     BC
              OR      A
              RET     

LF74E:        PUSH    BC
              LD      C,0EBH
              LD      B,H
              OUT     (C),L
              IN      A,(0EAH)
              POP     BC
              OR      A
              RET     

              LD      A,E
              CALL    LF743
              INC     HL
              LD      A,D
              CALL    LF743
              DEC     HL
              RET     

LF764:        CALL    LF74E
              LD      E,A
              INC     HL
              CALL    LF74E
              LD      D,A
              DEC     HL
              RET     

LF76F:        CALL    LF737
              INC     H
              JR      Z,LF79F                 ; (+02aH)
              LD      DE,00000H
LF778:        CALL    LF7CA
              SUB     030H
              CP      00AH
              RET     NC

              INC     HL
              PUSH    HL
              LD      H,D
              LD      L,E
              ADD     HL,HL
              JR      C,LF79A                 ; (+013H)
              ADD     HL,HL
              JR      C,LF79A                 ; (+010H)
              ADD     HL,DE
              JR      C,LF79A                 ; (+00dH)
              ADD     HL,HL
              JR      C,LF79A                 ; (+00aH)
              LD      E,A
              LD      D,000H
              ADD     HL,DE
              JR      C,LF79A                 ; (+004H)
              EX      DE,HL
              POP     HL
              JR      LF778                   ; (-022H)
LF79A:        LD      A,002H
              JP      LF501
LF79F:        LD      DE,00000H
LF7A2:        LD      A,(HL)
              CALL    LF7BA
              RET     C

              INC     HL
              EX      DE,HL
              ADD     HL,HL
              JR      C,LF79A                 ; (-012H)
              ADD     HL,HL
              JR      C,LF79A                 ; (-015H)
              ADD     HL,HL
              JR      C,LF79A                 ; (-018H)
              ADD     HL,HL
              JR      C,LF79A                 ; (-01bH)
              ADD     A,L
              LD      L,A
              EX      DE,HL
              JR      LF7A2                   ; (-018H)
LF7BA:        SUB     030H
              CP      00AH
              CCF     
              RET     NC

              SUB     011H
              CP      006H
              CCF     
              RET     C

              ADD     A,00AH
              RET     

LF7C9:        INC     HL
LF7CA:        LD      A,(HL)
              CP      020H
              JR      Z,LF7C9                 ; (-006H)
              RET     

LF7D0:        LD      (011ACH),A
              LD      HL,08000H
              LD      (011AAH),HL
              LD      A,(01092H)
              AND     012H
              LD      A,03BH
              JP      Z,LF501
              CALL    BRKEY
              JR      Z,LF825                 ; (+03dH)
              LD      A,009H
              CALL    LF62F
              LD      C,019H
LF7EF:        CALL    LF8B1
              LD      A,(0136BH)
              LD      B,A
LF7F6:        PUSH    BC
              CALL    LF857
              POP     BC
              DJNZ    LF7F6                   ; (-007H)
              CALL    BRKEY
              JR      Z,LF825                 ; (+023H)
              LD      B,007H
              LD      A,(0136BH)
              LD      E,A
              LD      D,000H
LF80A:        ADD     HL,DE
              DJNZ    LF80A                   ; (-003H)
              DEC     C
              JR      NZ,LF7EF                ; (-021H)
LF810:        CALL    LF8F1
              DEC     B
              ADD     HL,BC
              ADD     HL,BC
              DEC     BC
              LD      A,(BC)
              DEC     C
              LD      A,(01092H)
              BIT     4,A
              RET     Z

              LD      A,01AH
              CALL    LF62F
              RET     

LF825:        LD      A,001H
              LD      (013D9H),A
              LD      SP,012A8H
              JR      LF810                   ; (-01fH)
LF82F:        LD      D,000H
              LD      BC,(0109DH)
LF835:        RRC     C
              LD      A,C
              RET     C

              AND     B
              JR      Z,LF835                 ; (-007H)
              OUT     (0CDH),A
              LD      A,(HL)
              OR      D
              LD      D,A
              JR      LF835                   ; (-00eH)
LF843:        PUSH    HL
              XOR     A
              LD      HL,01098H
              BIT     2,(HL)
              JR      NZ,LF855                ; (+009H)
              INC     A
              LD      HL,011ACH
              BIT     0,(HL)
              JR      Z,LF855                 ; (+001H)
              INC     A
LF855:        POP     HL
              RET     

LF857:        LD      B,008H
              LD      DE,011B4H
              PUSH    DE
              IN      A,(0E0H)
              OUT     (0E0H),A
              PUSH    HL
LF862:        PUSH    BC
              PUSH    DE
              CALL    LF82F
              LD      A,(0136BH)
              LD      E,A
              LD      A,D
              LD      D,000H
              ADD     HL,DE
              POP     DE
              LD      (DE),A
              INC     DE
              POP     BC
              DJNZ    LF862                   ; (-013H)
              POP     HL
              INC     HL
              IN      A,(0E1H)
              POP     DE
              PUSH    HL
              EX      DE,HL
              LD      DE,011C4H
              PUSH    DE
              LD      C,008H
LF882:        LD      B,008H
              PUSH    HL
LF885:        RRC     (HL)
              RRA     
              INC     HL
              DJNZ    LF885                   ; (-006H)
              LD      (DE),A
              INC     DE
              EX      AF,AF'
              CALL    LF843
              CP      002H
              JR      NZ,LF898                ; (+003H)
              EX      AF,AF'
              LD      (DE),A
              INC     DE
LF898:        POP     HL
              DEC     C
              JR      NZ,LF882                ; (-01aH)
              POP     HL
              LD      B,008H
              CALL    LF843
              CP      002H
              JR      NZ,LF8A8                ; (+002H)
              SLA     B
LF8A8:        LD      A,(HL)
              CALL    LF8D6
              INC     HL
              DJNZ    LF8A8                   ; (-007H)
              POP     HL
              RET     

LF8B1:        CALL    LF843
              LD      DE,(0136DH)
              EX      AF,AF'
              CALL    LF8F1
              INC     BC
              ADD     HL,BC
              ADD     HL,BC
              ADD     HL,BC
              EX      AF,AF'
              CP      002H
              JR      NZ,LF8C9                ; (+004H)
              SLA     E
              RL      D
LF8C9:        LD      A,00BH
              CALL    LF62F
              CALL    LF62F
              LD      A,E
              CALL    LF8D6
              LD      A,D
LF8D6:        PUSH    HL
              LD      HL,012AEH
              LD      (HL),A
              CALL    LF8E3
              CALL    LF8E3
              POP     HL
              RET     

LF8E3:        XOR     A
              RLD     
              ADD     A,030H
              CP      03AH
              JR      C,LF8EE                 ; (+002H)
              ADD     A,007H
LF8EE:        JP      LF62F
LF8F1:        EX      (SP),HL
              PUSH    BC
              LD      B,(HL)
              INC     HL
LF8F5:        LD      A,(HL)
              INC     HL
              CALL    LF62F
              DJNZ    LF8F5                   ; (-007H)
              POP     BC
              EX      (SP),HL
              RET     

LF8FF:        CALL    LF467
              LD      HL,01366H
LF905:        LD      (HL),A
              INC     HL
              LD      (HL),E
              INC     HL
              LD      (HL),D
              LD      HL,TF949
              LD      B,006H
              CALL    LF940
              LD      HL,0A8C1H
              CALL    LF92D
              LD      HL,TF955
              LD      B,003H
              CALL    LF940
              LD      HL,0A8C0H
              CALL    LF92D
              LD      HL,TF95B
              LD      B,003H
              JR      LF940                   ; (+013H)
LF92D:        LD      C,0D7H
              LD      A,080H
              OUT     (C),A
              DEC     C
              IN      E,(C)
              IN      D,(C)
              OR      A
              PUSH    HL
              SBC     HL,DE
              POP     HL
              JR      NZ,LF92D                ; (-012H)
              RET     

LF940:        LD      A,(HL)
              INC     HL
              LD      C,(HL)
              INC     HL
              OUT     (C),A
              DJNZ    LF940                   ; (-008H)
              RET     

TF949:        DB      0b4H, 0d7H, 0c1H, 0d6H, 0a8H, 0d6H, 074H, 0d7H, 002H, 0d5H, 000H, 0d5H 
TF955:        DB      0b4H, 0d7H, 0c0H, 0d6H, 0a8H, 0d6H
TF95B:        DB      074H, 0d7H, 0f6H, 0d5H, 079H, 0d5H

LF961:        PUSH    IX
              PUSH    BC
              PUSH    HL
              PUSH    HL
              POP     IX
              JR      LF972                   ; (+008H)
LF96A:        PUSH    IX
              PUSH    BC
              PUSH    HL
              LD      IX,01366H
LF972:        LD      C,0D7H
              LD      A,080H
              OUT     (C),A
              LD      A,040H
              OUT     (C),A
              DEC     C
              IN      E,(C)
              IN      D,(C)
              DEC     C
              IN      A,(C)
              IN      B,(C)
              LD      C,A
              PUSH    BC
              LD      A,D
              OR      E
              JR      NZ,LF98F                ; (+003H)
              LD      DE,0A8C0H
LF98F:        LD      HL,0A8C0H
              LD      A,(IX+000H)
              OR      A
              SBC     HL,DE
              LD      DE,05460H
              CALL    LF9D2
              OR      A
              LD      E,(IX+001H)
              LD      D,(IX+002H)
              RR      D
              RR      E
              PUSH    AF
              ADD     HL,DE
              LD      DE,05460H
              CALL    LF9D2
              LD      C,A
              ADD     HL,HL
              EX      DE,HL
              POP     AF
              LD      A,C
              POP     BC
              PUSH    AF
              OR      A
              LD      HL,03CFBH
              SBC     HL,BC
              JR      C,LF9C1                 ; (+001H)
              INC     DE
LF9C1:        POP     AF
              JR      NC,LF9C5                ; (+001H)
              INC     DE
LF9C5:        EX      DE,HL
              LD      DE,0A8C0H
              CALL    LF9D2
              EX      DE,HL
              POP     HL
              POP     BC
              POP     IX
              RET     

LF9D2:        OR      A
              SBC     HL,DE
              JR      NC,LF9D9                ; (+002H)
              ADD     HL,DE
              RET     

LF9D9:        XOR     001H
              RET     

LF9DC:        CALL    LF467
              DEC     A
              JP      M,LF9F0
              CALL    LF9FF
              LD      HL,TFA1D
LF9E9:        AND     00FH
              CALL    LF44C
              LD      A,(HL)
              RET     

LF9F0:        LD      A,0F7H
              CALL    LFA15
              CPL     
              AND     03CH
              RRCA    
              RRCA    
              LD      HL,TFA2D
              JR      LF9E9                   ; (-016H)
LF9FF:        PUSH    AF
              LD      A,0CFH
              OUT     (0D0H),A
              POP     AF
              CP      002H
              JR      C,LFA0B                 ; (+002H)
              SUB     002H
LFA0B:        LD      C,0F0H
              DEC     A
              JP      M,LFA12
              INC     C
LFA12:        IN      A,(C)
              RET     

LFA15:        LD      C,0D0H
              OUT     (C),A
              INC     C
              IN      A,(C)
              RET     

TFA1D:        DB      000H, 005H, 001H, 000H, 003H, 004H, 002H, 003H, 007H, 006H, 008H, 007H, 000H, 005H, 001H, 000H 
TFA2D:        DB      000H, 007H, 003H, 000H, 005H, 006H, 004H, 005H, 001H, 008H, 002H, 001H, 000H, 007H, 003H, 000H

LFA3D:        CALL    LF467
              DEC     A
              JP      M,LFA58
              PUSH    AF
              CALL    LF9FF
              CPL     
              POP     BC
              DEC     B
              DEC     B
              LD      B,010H
              JP      M,LFA53
              LD      B,020H
LFA53:        AND     B
LFA54:        RET     Z

              LD      A,001H
              RET     

LFA58:        LD      A,0F6H
              CALL    LFA15
              CPL     
              AND     010H
              JR      LFA54                   ; (-00eH)
LFA62:        LD      D,A
              XOR     A
              LD      C,A
              LD      B,00EH
LFA67:        LD      HL,0E678H
LFA6A:        IN      A,(0FEH)
              AND     00DH
              CP      C
              JR      Z,LFA7D                 ; (+00cH)
              DEC     HL
              LD      A,H
              OR      L
              NOP     
              NOP     
              JR      NZ,LFA6A                ; (-00eH)
              DJNZ    LFA67                   ; (-013H)
              LD      A,0FFH
              RET     

LFA7D:        LD      A,D
              OUT     (0FFH),A
              LD      A,080H
              OUT     (0FEH),A
LFA84:        IN      A,(0FEH)
              AND     00DH
              CP      001H
              JR      NZ,LFA84                ; (-008H)
              XOR     A
              OUT     (0FEH),A
              RET     

LFA90:        LD      HL,TFAA9
              LD      B,004H
              CALL    LF940
              LD      C,D
              LD      B,000H
LFA9B:        EX      (SP),HL
              DJNZ    LFA9B                   ; (-003H)
              DEC     C
              JR      NZ,LFA9B                ; (-006H)
              LD      HL,TFAB1
              LD      B,002H
              JP      LF940

TFAA9:        DB      036H
              DB      0D7H
              DB      001H
              DB      0D3H
              DB      0F9H
              DB      0D4H
              DB      003H
              DB      0D4H
TFAB1:        DB      036H
              DB      0D7H
              DB      000H
              DB      0D3H

              ALIGN_NOPS 0FDA0H

              DB      053H
              DB      005H
              DB      059H
              DB      04EH
              DB      054H
              DB      041H
              DB      0D8H
              DB      04FH
              DB      005H
              DB      056H
              DB      045H
              DB      052H
              DB      020H
              DB      046H
              DB      04CH
              DB      04FH
              DB      0D7H
              DB      049H
              DB      005H
              DB      04CH
              DB      04CH
              DB      045H
              DB      047H
              DB      041H
              DB      04CH
              DB      020H
              DB      044H
              DB      041H
              DB      054H
              DB      0C1H
              DB      054H
              DB      005H
              DB      059H
              DB      050H
              DB      045H
              DB      020H
              DB      04DH
              DB      049H
              DB      053H
              DB      04DH
              DB      041H
              DB      054H
              DB      043H
              DB      0C8H
              DB      053H
              DB      005H
              DB      054H
              DB      052H
              DB      049H
              DB      04EH
              DB      047H
              DB      020H
              DB      04CH
              DB      045H
              DB      04EH
              DB      047H
              DB      054H
              DB      0C8H
              DB      04DH
              DB      005H
              DB      045H
              DB      04DH
              DB      04FH
              DB      052H
              DB      059H
              DB      020H
              DB      043H
              DB      041H
              DB      050H
              DB      041H
              DB      043H
              DB      049H
              DB      054H
              DB      0D9H
              DB      041H
              DB      005H
              DB      052H
              DB      052H
              DB      041H
              DB      059H
              DB      020H
              DB      044H
              DB      045H
              DB      046H
              DB      0AEH
              DB      04CH
              DB      005H
              DB      049H
              DB      04EH
              DB      045H
              DB      04CH
              DB      045H
              DB      04EH
              DB      047H
              DB      054H
              DB      0C8H
              DB      080H
              DB      047H
              DB      04FH
              DB      053H
              DB      055H
              DB      042H
              DB      020H
              DB      005H
              DB      04EH
              DB      045H
              DB      053H
              DB      054H
              DB      049H
              DB      04EH
              DB      0C7H
              DB      046H
              DB      04FH
              DB      052H
              DB      02DH
              DB      04EH
              DB      045H
              DB      058H
              DB      0D4H
              DB      044H
              DB      045H
              DB      046H
              DB      020H
              DB      046H
              DB      04EH
              DB      020H
              DB      005H
              DB      04EH
              DB      045H
              DB      053H
              DB      054H
              DB      049H
              DB      04EH
              DB      0C7H
              DB      04EH
              DB      045H
              DB      058H
              DB      0D4H
              DB      052H
              DB      045H
              DB      054H
              DB      055H
              DB      052H
              DB      0CEH
              DB      055H
              DB      005H
              DB      04EH
              DB      020H
              DB      044H
              DB      045H
              DB      046H
              DB      02EH
              DB      020H
              DB      046H
              DB      055H
              DB      04EH
              DB      043H
              DB      054H
              DB      049H
              DB      04FH
              DB      0CEH
              DB      055H
              DB      005H
              DB      04EH
              DB      020H
              DB      044H
              DB      045H
              DB      046H
              DB      02EH
              DB      020H
              DB      04CH
              DB      049H
              DB      04EH
              DB      0C5H
              DB      043H
              DB      005H
              DB      041H
              DB      04EH
              DB      027H
              DB      054H
              DB      020H
              DB      006H
              DB      043H
              DB      04FH
              DB      04EH
              DB      0D4H
              DB      04DH
              DB      005H
              DB      045H
              DB      04DH
              DB      04FH
              DB      052H
              DB      059H
              DB      020H
              DB      050H
              DB      052H
              DB      04FH
              DB      054H
              DB      045H
              DB      043H
              DB      054H
              DB      049H
              DB      04FH
              DB      0CEH
              DB      049H
              DB      005H
              DB      04EH
              DB      053H
              DB      054H
              DB      052H
              DB      055H
              DB      043H
              DB      054H
              DB      049H
              DB      04FH
              DB      0CEH
              DB      043H
              DB      005H
              DB      041H
              DB      04EH
              DB      027H
              DB      054H
              DB      020H
              DB      006H
              DB      052H
              DB      045H
              DB      053H
              DB      055H
              DB      04DH
              DB      0C5H
              DB      052H
              DB      045H
              DB      053H
              DB      055H
              DB      04DH
              DB      0C5H
              DB      050H
              DB      041H
              DB      0CCH
              DB      080H
              DB      052H
              DB      045H
              DB      041H
              DB      0C4H
              DB      053H
              DB      057H
              DB      041H
              DB      050H
              DB      020H
              DB      005H
              DB      04CH
              DB      045H
              DB      056H
              DB      045H
              DB      0CCH
              DB      080H
              DB      080H
              DB      053H
              DB      005H
              DB      059H
              DB      053H
              DB      054H
              DB      045H
              DB      04DH
              DB      020H
              DB      049H
              DB      0C4H
              DB      046H
              DB      005H
              DB      052H
              DB      041H
              DB      04DH
              DB      049H
              DB      04EH
              DB      0C7H
              DB      04FH
              DB      005H
              DB      056H
              DB      045H
              DB      052H
              DB      052H
              DB      055H
              DB      0CEH
              DB      050H
              DB      005H
              DB      041H
              DB      052H
              DB      049H
              DB      054H
              DB      0D9H
              DB      080H
              DB      080H
              DB      080H
              DB      080H
              DB      080H
              DB      080H
              DB      080H
              DB      080H
              DB      046H
              DB      005H
              DB      049H
              DB      04CH
              DB      045H
              DB      020H
              DB      04EH
              DB      04FH
              DB      054H
              DB      020H
              DB      046H
              DB      04FH
              DB      055H
              DB      04EH
              DB      0C4H
              DB      048H
              DB      005H
              DB      041H
              DB      052H
              DB      044H
              DB      057H
              DB      041H
              DB      052H
              DB      0C5H
              DB      041H
              DB      005H
              DB      04CH
              DB      052H
              DB      045H
              DB      041H
              DB      044H
              DB      059H
              DB      020H
              DB      045H
              DB      058H
              DB      049H
              DB      053H
              DB      0D4H
              DB      041H
              DB      005H
              DB      04CH
              DB      052H
              DB      045H
              DB      041H
              DB      044H
              DB      059H
              DB      020H
              DB      04FH
              DB      050H
              DB      045H
              DB      0CEH
              DB      04EH
              DB      005H
              DB      04FH
              DB      054H
              DB      020H
              DB      04FH
              DB      050H
              DB      045H
              DB      0CEH
              DB      080H
              DB      057H
              DB      005H
              DB      052H
              DB      049H
              DB      054H
              DB      045H
              DB      020H
              DB      050H
              DB      052H
              DB      04FH
              DB      054H
              DB      045H
              DB      043H
              DB      0D4H
              DB      080H
              DB      080H
              DB      080H
              DB      04EH
              DB      005H
              DB      04FH
              DB      054H
              DB      020H
              DB      052H
              DB      045H
              DB      041H
              DB      044H
              DB      0D9H
              DB      054H
              DB      005H
              DB      04FH
              DB      04FH
              DB      020H
              DB      04DH
              DB      041H
              DB      04EH
              DB      059H
              DB      020H
              DB      046H
              DB      049H
              DB      04CH
              DB      045H
              DB      0D3H
              DB      044H
              DB      005H
              DB      049H
              DB      053H
              DB      04BH
              DB      020H
              DB      04DH
              DB      049H
              DB      053H
              DB      04DH
              DB      041H
              DB      054H
              DB      043H
              DB      0C8H
              DB      04EH
              DB      005H
              DB      04FH
              DB      020H
              DB      046H
              DB      049H
              DB      04CH
              DB      045H
              DB      020H
              DB      053H
              DB      050H
              DB      041H
              DB      043H
              DB      0C5H
              DB      055H
              DB      005H
              DB      04EH
              DB      046H
              DB      04FH
              DB      052H
              DB      04DH
              DB      041H
              DB      0D4H
              DB      054H
              DB      005H
              DB      04FH
              DB      04FH
              DB      020H
              DB      04CH
              DB      04FH
              DB      04EH
              DB      047H
              DB      020H
              DB      046H
              DB      049H
              DB      04CH
              DB      0C5H
              DB      080H
              DB      080H
              DB      044H
              DB      005H
              DB      045H
              DB      056H
              DB      02EH
              DB      020H
              DB      04EH
              DB      041H
              DB      04DH
              DB      0C5H
              DB      043H
              DB      005H
              DB      041H
              DB      04EH
              DB      027H
              DB      054H
              DB      020H
              DB      045H
              DB      058H
              DB      045H
              DB      043H
              DB      055H
              DB      054H
              DB      0C5H
              DB      049H
              DB      005H
              DB      04CH
              DB      04CH
              DB      045H
              DB      047H
              DB      041H
              DB      04CH
              DB      020H
              DB      046H
              DB      049H
              DB      04CH
              DB      045H
              DB      04EH
              DB      041H
              DB      04DH
              DB      0C5H
              DB      049H
              DB      005H
              DB      04CH
              DB      04CH
              DB      045H
              DB      047H
              DB      041H
              DB      04CH
              DB      020H
              DB      046H
              DB      049H
              DB      04CH
              DB      045H
              DB      04DH
              DB      04FH
              DB      044H
              DB      0C5H
              DB      080H
              DB      04FH
              DB      005H
              DB      055H
              DB      054H
              DB      020H
              DB      04FH
              DB      046H
              DB      020H
              DB      046H
              DB      049H
              DB      04CH
              DB      0C5H
              DB      04CH
              DB      005H
              DB      04FH
              DB      047H
              DB      049H
              DB      043H
              DB      041H
              DB      04CH
              DB      020H
              DB      04EH
              DB      055H
              DB      04DH
              DB      042H
              DB      045H
              DB      0D2H
              DB      04CH
              DB      050H
              DB      054H
              DB      03AH
              DB      04EH
              DB      005H
              DB      04FH
              DB      054H
              DB      020H
              DB      052H
              DB      045H
              DB      041H
              DB      044H
              DB      0D9H
              DB      080H
              DB      080H
              DB      044H
              DB      005H
              DB      045H
              DB      056H
              DB      02EH
              DB      020H
              DB      04DH
              DB      04FH
              DB      044H
              DB      0C5H
              DB      055H
              DB      005H
              DB      04EH
              DB      050H
              DB      052H
              DB      049H
              DB      04EH
              DB      054H
              DB      041H
              DB      042H
              DB      04CH
              DB      0C5H
              DB      043H
              DB      005H
              DB      048H
              DB      045H
              DB      043H
              DB      04BH
              DB      020H
              DB      053H
              DB      055H
              DB      0CDH
              DB      000H
              DB      000H
              DB      000H
              DB      000H

VERSION:      DB      020H
              DB      038H
              DB      034H
              DB      02EH
              DB      031H
              DB      030H
              DB      02EH
              DB      030H
              DB      038H
              DB      020H
              DB      056H
              DB      031H
              DB      02EH
              DB      030H
              DB      043H
              DB      020H
