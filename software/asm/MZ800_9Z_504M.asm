              ;
              ;
              ; SHARPMZ - 821
              ; (ROM contents, upper monitor E000-F3FF)
              ;
              ;
              ; Input / Output address


              INCLUDE "Macros.asm"


              ;
              ; Printer interface
PCPR:         EQU   0FCH                        ; Z80 / PIO
PLPT:         EQU   PCPR+3                      ; printer data output
PLPTS:        EQU   PCPR+2                      ; printer strobe
PLPTI:        EQU   PCPR+1                      ; printer data port inic
PLPTSI:       EQU   PCPR+0                      ; printer strobe port inic
              ; Program sound generator
PPSG:         EQU   0F2H                        ; Prog. Sound Gen.
              ; Joystick registers
PJ1:          EQU   0F1H                        ; joystick-2 input port
PJ0:          EQU   0F0H                        ; joystick-1 input port
              ; Pallet write
PPAL:         EQU   0F0H                        ; pallet write
              ; Memory managerment ports OUT
PMMC6:        EQU   0E6H                        ; condition from hill protection
PMMC5:        EQU   0E5H                        ; protect the hill
PMMC4:        EQU   0E4H                        ; maximum neRAM as far as possible
PMMC3:        EQU   0E3H                        ; ROM up
PMMC2:        EQU   0E2H                        ; ROM down
              ; Memory managerment ports OUT / IN
PMMC1:        EQU   0E1H                        ; DRAM up / VRAM pryc
PMMC0:        EQU   0E0H                        ; DRAM up / VRAM
              ; Folppy disk
PFD:          EQU   0D8H                                         
PFDSIZ:       EQU   PFD+5                       ; floppy side settings
PFDMOT:       EQU   PFD+4                       ; drive on / off
PFDDAT:       EQU   PFD+3                       ; register that
PFDSEC:       EQU   PFD+2                       ; sector register
PFDTRK:       EQU   PFD+1                       ; track register
PFDCTR:       EQU   PFD+0                       ; driving word
              ; 8253 I / O. mapped. - interupt, clock, etc.
P8253:        EQU   0D4H                        ; 8253 I / O. Mapped 
PCTCC:        EQU   P8253+3                     ; control word 8253
PCTC2:        EQU   P8253+2                     ; counter 2
PCTC1:        EQU   P8253+1                     ; counter 1
PCTC0:        EQU   P8253+0                     ; counter 0
              ; 8255 I / O mapped - keyboard, joystick, CMT
P8255:        EQU   0D0H                                         
PCWR55:       EQU   P8255+3                     ; control word 8255
PPORTC:       EQU   P8255+2                     ; port C - CMT and control
PKBDIN:       EQU   P8255+1                     ; keyboard input
PKBOUT:       EQU   P8255+0                     ; keyboard strobe
              ; GDG I / O ports
PCRTC:        EQU   0CFH                        ; CRTC register
PDMD:         EQU   0CEH                        ; display mod register
PRF:          EQU   0CDH                        ; read format register
PWF:          EQU   0CCH                        ; write format register
              ;
              ; Memory mapping
              ;
MGATE0:       EQU   0E008H                      ; disable / enable melody
              ; 8253 mem. mapped - Interupt, clock
M8253:        EQU   0E004H                      ; 8253 Mem. Mapped 
MCTCC:        EQU   M8253+3                     ; control word 8253
MCTC2:        EQU   M8253+2                     ; counter 2
MCTC1:        EQU   M8253+1                     ; counter 1
MCTC0:        EQU   M8253+0                     ; counter 0
              ; 8255 mem. mapped - keyboard, joystick, CMT
M8255:        EQU   0E000H                                       
MCWR55:       EQU   M8255+3                     ; control word 8255
MPORTC:       EQU   M8255+2                     ; port C - CMT and control
MKBDIN:       EQU   M8255+1                     ; keyboard input
MKBOUT:       EQU   M8255+0                     ; keyboard strobe
              ;
              ; definition of ASCII constants
CR:           EQU   0DH                                          
SPACE:        EQU   20H                                          
ESC:          EQU   1BH                                          
CLS:          EQU   16H                                           
CRD:          EQU   0CDH                                         
              ; definition of display addresses
ADRCRT:       EQU   0D000H                      ; address MZ-700 VRAM
ADRATB:       EQU   0D800H                      ; the address of the CRS attribute
IMPATB:       EQU   71H                         ; default display attribute
              ;
              ORG   0E000H                                       
              ;
              ; Ports D0-D7 are mapped here in MZ-700 mode
              ;
              DB    0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH      
              DB    0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH      
              ;----------------------------------------------------
              ;
              ; QUICKDISK
              ;
              ;----------------------------------------------------
@QDISK:                                                          
              LD    A,5                                          
              LD    (M1145),A                                    
JE015:                                                           
              DI                                                 
              CALL  JE06A                                        
              RET   NC                                           
              PUSH  AF                                           
              CP    28H                                          
              JR    Z,JE068                                      
              CALL  JE2E8                                        
              LD    A,(M1130)                                    
              CP    4                                            
              JR    NZ,JE045                                     
              LD    A,(M1141)                                    
              OR    A                                            
              JR    Z,JE045                                      
              XOR   A                                            
              LD    (M1141),A                                    
              LD    A,(M1142)                                    
              PUSH  HL                                           
              LD    (OLDSP),SP                                   
              POP   HL                                           
              DI                                                 
              CALL  JE268                                        
              JR    C,JE062                                      
              CALL  JE2E8                                        
JE045:                                                           
              CP    3                                            
              JR    NZ,JE04D                                     
              LD    HL,113DH                                     
              DEC   (HL)                                         
JE04D:                                                           
              POP   AF                                           
              PUSH  AF                                           
              CP    29H                                          
              JR    NZ,JE062                                     
              LD    HL,1145H                                     
              DEC   (HL)                                         
              JR    Z,JE062                                      
              POP   AF                                           
              LD    A,(M1140)                                    
              LD    (M113F),A                                    
              JR    JE015                                        
              ;
JE062:                                                           
              CALL  JE1DB                                        
              CALL  JE083                                        
JE068:                                                           
              POP   AF                                           
              RET                                                 
              ;
JE06A:                                                           
              LD    (OLDSP),SP                                   
              LD    A,(M1130)                                    
              DEC   A                                            
              JR    Z,JE08A                                      
              DEC   A                                            
              JR    Z,JE090                                      
              DEC   A                                            
              JR    Z,JE0DA                                      
              DEC   A                                            
              JP    Z,JE14E                                      
              DEC   A                                            
              JR    Z,JE083                                      
              JR    JE0D3                                        
              ;
JE083:                                                           
              PUSH  AF                                           
              XOR   A                                            
              LD    (M113D),A                                    
              POP   AF                                           
              RET                                                
              ;
JE08A:                                                           
              LD    A,(M1131)                                    
              JP    JE23C                                        
              ;
JE090:                                                           
              XOR   A                                            
              CALL  JE268                                        
              CALL  JE365                                        
              LD    BC,0EFFFH                                    
              LD    A,0AAH                                       
JE09C:                                                           
              CPL                                                
              LD    D,A                                          
              CALL  JE3DB                                        
              DEC   BC                                           
              LD    A,B                                          
              OR    C                                            
              JR    Z,JE0A9                                      
              LD    A,D                                          
              JR    JE09C                                         
              ;
JE0A9:                                                           
              CALL  JE3B2                                        
              CALL  JE2E8                                        
              CALL  JE29B                                        
              LD    A,(M1143)                                    
              DEC   A                                            
              JR    NZ,JE0D6                                     
              CALL  JE2FD                                        
              LD    BC,0EFFFH                                    
              LD    E,55H                                        
JE0C0:                                                           
              CP    E                                            
              JR    NZ,JE0D6                                     
              DEC   BC                                           
              LD    A,B                                          
              OR    C                                            
              JR    Z,JE0D0                                      
              LD    A,E                                          
              CPL                                                
              LD    E,A                                          
              CALL  JE3F0                                        
              JR    JE0C0                                        
              ;
JE0D0:                                                           
              CALL  JE3C3                                        
JE0D3:                                                           
              JP    JE2E8                                        
              ;
JE0D6:                                                           
              LD    A,29H                                        
              SCF                                                
              RET                                                
              ;
JE0DA:                                                           
              LD    A,(M1144)                                    
              OR    A                                            
              CALL  Z,JE29B                                      
              CALL  JE114                                        
              RET   C                                            
              CALL  JE435                                        
              CALL  JE3F0                                        
              LD    C,A                                           
              CALL  JE3F0                                        
              LD    B,A                                          
              OR    C                                            
              JP    Z,JE1E5                                      
              LD    HL,(M1134)                                   
              SBC   HL,BC                                        
              JP    C,JE1E5                                      
              LD    HL,(M1132)                                   
JE0FF:                                                           
              CALL  JE3F0                                        
              LD    (HL),A                                       
              INC   HL                                           
              DEC   BC                                           
              LD    A,B                                          
              OR    C                                            
              JR    NZ,JE0FF                                     
              CALL  JE3C3                                        
              LD    A,(M1131)                                    
              BIT   0,A                                          
              JR    NZ,JE0D3                                     
              RET                                                
              ;
JE114:                                                           
              LD    HL,1143H                                     
              DEC   (HL)                                         
              JR    Z,JE14A                                      
              CALL  JE2FD                                        
              LD    C,A                                          
              LD    A,(M113D)                                    
              LD    HL,113EH                                     
              CP    (HL)                                         
              JR    NZ,JE147                                     
              INC   A                                            
              LD    (M113D),A                                    
              LD    (HL),A                                       
              LD    A,(M1131)                                    
              XOR   C                                            
              RRA                                                
              RET   NC                                           
JE132:                                                            
              CALL  JE3F0                                        
              LD    C,A                                          
              CALL  JE3F0                                        
              LD    B,A                                          
JE13A:                                                           
              CALL  JE3F0                                        
              DEC   BC                                           
              LD    A,B                                          
              OR    C                                            
              JR    NZ,JE13A                                     
              CALL  JE3C3                                        
              JR    JE114                                        
              ;
JE147:                                                           
              INC   (HL)                                         
              JR    JE132                                        
              ;
JE14A:                                                           
              LD    A,28H                                        
              SCF                                                
              RET                                                
              ;
JE14E:                                                           
              LD    A,(M113F)                                    
              LD    (M1140),A                                    
              LD    A,(M1144)                                    
              OR    A                                            
              JR    NZ,JE171                                     
              CALL  JE29B                                        
              LD    A,(M113F)                                    
              LD    HL,1143H                                     
              ADD   A,(HL)                                       
              LD    (M1143),A                                    
              INC   A                                            
              LD    (M113D),A                                    
              CALL  JE114                                        
              JP    NC,JE1E5                                     
JE171:                                                           
              LD    A,(M1131)                                    
              LD    B,A                                          
              AND   1                                            
              JR    NZ,JE185                                      
              LD    DE,1132H                                     
              LD    A,B                                          
              RES   2,A                                          
              CALL  JE1ED                                        
              CALL  JE435                                        
JE185:                                                           
              LD    DE,1136H                                     
              LD    A,(M1131)                                    
              SET   0,A                                          
              CALL  JE1ED                                        
              CALL  JE2E8                                        
              CALL  JE435                                        
              LD    A,(M1131)                                    
              AND   4                                            
              JR    Z,JE1E8                                      
              LD    A,(M1142)                                    
              LD    HL,113FH                                     
              ADD   A,(HL)                                       
              CALL  JE268                                        
              LD    A,1                                           
              LD    (M1141),A                                    
JE1AC:                                                           
              LD    A,(M1142)                                    
              LD    HL,1140H                                     
              ADD   A,(HL)                                       
              INC   A                                            
              LD    (M1143),A                                    
              INC   A                                            
              LD    (M113D),A                                    
              CALL  JE114                                        
              JR    NC,JE1E5                                     
              LD    A,(M1131)                                    
              AND   1                                            
              JR    NZ,JE1CE                                     
              LD    DE,1132H                                     
              CALL  JE21B                                        
              RET   C                                            
JE1CE:                                                           
              LD    DE,1136H                                     
              CALL  JE21B                                         
              RET   C                                            
              LD    A,(M1141)                                    
              OR    A                                            
              JR    Z,JE1E2                                      
JE1DB:                                                           
              XOR   A                                            
              LD    (M113F),A                                    
              LD    (M1141),A                                    
JE1E2:                                                           
              JP    JE2E8                                        
              ;
JE1E5:                                                           
              JP    JE0D6                                        
              ;
JE1E8:                                                           
              CALL  JE29B                                        
              JR    JE1AC                                        
              ;
JE1ED:                                                           
              PUSH  AF                                           
              LD    HL,113FH                                     
              INC   (HL)                                          
              CALL  JE365                                        
              POP   AF                                           
              CALL  JE3DB                                        
              CALL  JE211                                        
              LD    A,C                                          
              CALL  JE3DB                                        
              LD    A,B                                          
              CALL  JE3DB                                        
JE204:                                                           
              LD    A,(HL)                                       
              CALL  JE3DB                                        
              INC   HL                                           
              DEC   BC                                           
              LD    A,B                                          
              OR    C                                            
              JR    NZ,JE204                                     
              JP    JE3B2                                        
              ;
JE211:                                                           
              EX    DE,HL                                        
              LD    E,(HL)                                        
              INC   HL                                           
              LD    D,(HL)                                       
              INC   HL                                           
              LD    C,(HL)                                       
              INC   HL                                           
              LD    B,(HL)                                       
              EX    DE,HL                                        
              RET                                                
              ;
JE21B:                                                           
              CALL  JE2FD                                        
              CALL  JE211                                        
              CALL  JE3F0                                        
              CP    C                                            
              JR    NZ,JE1E5                                     
              CALL  JE3F0                                        
              CP    B                                            
              JR    NZ,JE1E5                                     
JE22D:                                                           
              CALL  JE3F0                                        
              CP    (HL)                                         
              JR    NZ,JE1E5                                     
              INC   HL                                           
              DEC   BC                                           
              LD    A,B                                          
              OR    C                                            
              JR    NZ,JE22D                                     
              JP    JE3C3                                        
              ;
JE23C:                                                           
              LD    B,A                                          
              LD    A,2                                          
              OUT   (0F7H),A                                     
              LD    A,81H                                        
              OUT   (0F7H),A                                     
              LD    A,2                                          
              OUT   (0F7H),A                                     
              IN    A,(0F7H)                                     
              AND   81H                                          
              CP    81H                                          
              JP    NZ,JE406                                      
              LD    A,10H                                        
              OUT   (0F6H),A                                     
              IN    A,(0F6H)                                     
              LD    C,A                                          
              AND   8                                            
              JP    Z,JE406                                      
              LD    A,B                                          
              OR    A                                            
              RET   Z                                            
              LD    A,C                                          
              AND   20H                                          
              RET   NZ                                           
              JP    JE403                                        
              ;
JE268:                                                           
              PUSH  AF                                           
              LD    HL,0E42CH                                    
              LD    B,9                                          
              CALL  JE2D8                                        
JE271:                                                           
              LD    A,10H                                         
              OUT   (0F6H),A                                     
              IN    A,(0F6H)                                     
              AND   8                                            
              JP    Z,JE406                                      
              LD    A,10H                                        
              OUT   (0F7H),A                                     
              IN    A,(0F7H)                                     
              AND   8                                            
              JR    Z,JE271                                      
              LD    BC,0E9H                                      
              CALL  @944BC                                       
              CALL  JE39A                                        
              CALL  JE37E                                        
              POP   AF                                           
              CALL  JE3DB                                        
              CALL  JE3B2                                        
              JR    JE2CE                                        
              ;
JE29B:                                                           
              LD    HL,0E421H                                    
              LD    B,0BH                                        
              CALL  JE2D8                                        
JE2A3:                                                           
              LD    A,10H                                        
              OUT   (0F6H),A                                     
              IN    A,(0F6H)                                     
              AND   8                                            
              JP    Z,JE406                                      
              CALL  JE435                                        
              LD    A,10H                                        
              OUT   (0F7H),A                                     
              IN    A,(0F7H)                                     
              AND   8                                            
              JR    Z,JE2A3                                      
              LD    BC,0E9H                                      
              CALL  @944BC                                       
              CALL  JE313                                        
              LD    (M1142),A                                    
              INC   A                                            
              LD    (M1143),A                                     
              CALL  JE3C3                                        
JE2CE:                                                           
              LD    HL,1147H                                     
              SET   3,(HL)                                       
              XOR   A                                            
              LD    (M113E),A                                    
              RET                                                
              ;
JE2D8:                                                           
              LD    C,0F6H                                       
              OTIR                                               
              LD    A,5                                          
              LD    (M1144),A                                    
              OUT   (0F7H),A                                     
              LD    A,80H                                        
              OUT   (0F7H),A                                     
              RET                                                
              ;
JE2E8:                                                           
              PUSH  AF                                           
              LD    A,5                                          
              OUT   (0F6H),A                                      
              LD    A,60H                                        
              OUT   (0F6H),A                                     
              LD    A,5                                          
              OUT   (0F7H),A                                     
              XOR   A                                            
              LD    (M1144),A                                    
              OUT   (0F7H),A                                     
              POP   AF                                           
              RET                                                
              ;
JE2FD:                                                           
              LD    A,58H                                        
              LD    B,0BH                                        
              LD    HL,0E421H                                    
              CALL  JE3A3                                        
              LD    HL,1147H                                     
              BIT   3,(HL)                                       
              LD    BC,3                                         
              JR    Z,JE316                                      
              RES   3,(HL)                                       
JE313:                                                           
              LD    BC,0A0H                                      
JE316:                                                           
              CALL  @944BC                                       
              LD    A,5                                          
              OUT   (0F7H),A                                     
              LD    A,82H                                        
              OUT   (0F7H),A                                     
              LD    A,3                                          
              OUT   (0F6H),A                                     
              LD    A,0D3H                                       
              OUT   (0F6H),A                                     
              LD    BC,2CC0H                                     
JE32C:                                                           
              LD    A,10H                                        
              OUT   (0F6H),A                                     
              IN    A,(0F6H)                                     
              AND   10H                                          
              JR    Z,JE33D                                      
              DEC   BC                                            
              LD    A,B                                          
              OR    C                                            
              JR    NZ,JE32C                                     
              JR    JE354                                        
              ;
JE33D:                                                           
              LD    A,3                                          
              OUT   (0F6H),A                                     
              LD    A,0C3H                                       
              OUT   (0F6H),A                                     
              LD    B,9FH                                        
JE347:                                                           
              LD    A,10H                                        
              OUT   (0F6H),A                                     
              IN    A,(0F6H)                                     
              AND   1                                            
              JR    NZ,JE357                                     
              DEC   B                                            
              JR    NZ,JE347                                     
JE354:                                                           
              JP    JE40C                                         
              ;
JE357:                                                           
              LD    A,3                                          
              OUT   (0F6H),A                                     
              LD    A,0C9H                                       
              OUT   (0F6H),A                                     
              CALL  JE3F0                                        
              JP    JE3F0                                        
              ;
JE365:                                                           
              LD    A,98H                                        
              LD    B,9                                          
              LD    HL,0E42CH                                    
              CALL  JE3A3                                        
              CALL  JE39A                                        
              LD    HL,1147H                                     
              BIT   3,(HL)                                       
              LD    BC,1DH                                       
              JR    Z,JE381                                      
              RES   3,(HL)                                       
JE37E:                                                            
              LD    BC,140H                                      
JE381:                                                           
              CALL  @944BC                                       
              LD    A,5                                          
              OUT   (0F6H),A                                     
              LD    A,0EFH                                       
              OUT   (0F6H),A                                     
              LD    BC,1                                         
              CALL  @944BC                                       
              LD    A,0A5H                                       
              CALL  JE3DB                                        
              JP    JF380                                        
              ;
JE39A:                                                           
              LD    A,5                                          
              OUT   (0F6H),A                                     
              LD    A,0FFH                                       
              OUT   (0F6H),A                                     
              RET                                                
              ;
JE3A3:                                                           
              LD    C,0F6H                                        
              OUT   (C),A                                        
              LD    A,5                                          
              OUT   (0F7H),A                                     
              LD    A,80H                                        
              OUT   (0F7H),A                                     
              OTIR                                               
              RET                                                
              ;
JE3B2:                                                           
              LD    BC,1                                         
              CALL  @944BC                                       
              LD    A,10H                                        
              OUT   (0F7H),A                                     
              IN    A,(0F7H)                                     
              AND   8                                            
              RET   NZ                                           
              JR    JE409                                        
              ;
JE3C3:                                                           
              LD    B,3                                          
JE3C5:                                                            
              CALL  JE3F0                                        
              DJNZ  JE3C5                                        
JE3CA:                                                           
              IN    A,(0F6H)                                     
              RRCA                                               
              JR    NC,JE3CA                                     
              LD    A,1                                          
              OUT   (0F6H),A                                     
              IN    A,(0F6H)                                     
              AND   40H                                          
              JR    NZ,JE400                                     
              OR    A                                            
              RET                                                
              ;
JE3DB:                                                           
              PUSH  AF                                           
JE3DC:                                                           
              IN    A,(0F6H)                                     
              AND   4                                            
              JR    Z,JE3DC                                      
              POP   AF                                            
              OUT   (0F4H),A                                     
JE3E5:                                                           
              LD    A,10H                                        
              OUT   (0F6H),A                                     
              IN    A,(0F6H)                                     
              AND   8                                            
              JR    Z,JE406                                      
              RET                                                
              ;
JE3F0:                                                           
              CALL  JE3E5                                        
              IN    A,(0F6H)                                     
              RLCA                                               
              JR    C,JE400                                      
              RRCA                                               
              RRCA                                               
              JR    NC,JE3F0                                     
              IN    A,(0F4H)                                     
              OR    A                                            
              RET                                                
              ;
JE400:                                                           
              LD    A,29H                                        
              LD    HL,2E3EH                                     
JE403:        EQU   0E403H                                       
              LD    HL,323EH                                     
JE406:        EQU   0E406H                                       
              LD    HL,353EH                                     
JE409:        EQU   0E409H                                       
              LD    HL,363EH                                     
JE40C:        EQU   0E40CH                                       
              LD    SP,(OLDSP)                                   
              SCF                                                
              RET                                                
              ;
@944BC:                                                          
              PUSH  AF                                           
JE415:                                                           
              LD    A,96H                                        
JE417:                                                           
              DEC   A                                            
              JR    NZ,JE417                                      
              DEC   BC                                           
              LD    A,B                                          
              OR    C                                            
              JR    NZ,JE415                                     
              POP   AF                                           
              RET                                                
              ;
              LD    E,B                                          
              INC   B                                            
              DJNZ  JE42A                                        
              INC   B                                            
              INC   BC                                           
              RET   NC                                           
              LD    B,16H                                        
JE42A:                                                           
              RLCA                                               
              LD    D,98H                                        
              INC   B                                            
              DJNZ  JE436                                        
              LD    D,7                                          
              LD    D,5                                          
              LD    L,L                                          
JE435:                                                           
              LD    A,0E8H                                       
JE436:        EQU   0E436H                                       
              LD    (MKBOUT),A                                   
              NOP                                                
              LD    A,(MKBDIN)                                   
              AND   81H                                          
              RET   NZ                                           
              CALL  JE1DB                                        
              LD    SP,(OLDSP)                                   
              SCF                                                
              RET                                                
              ;----------------------------------------------------
              ;
              ; FLOPPYDISK
              ;
              ;----------------------------------------------------
              ;
              ; Most subroutines use error returns,
              ; for this case it is necessary to set the return
              ; address to FDARET and be aware that the CAP will change
              ;
              ;
              ; Read the program from FD and run
              ; The program can pass control back to the RET instruction.
              ; The program name must start with IPLPRO, otherwise it will be executed
              ; error return FDERR1. Only the rest is shown on the display
              ; names.
              ;
              ; nothing: everything
              ;
@FDBOOT:      ; floppy disc BOOT
              EX    (SP),HL                      ;
              LD    (FDARET),HL                 ; return address
              CALL  @???FD                      ; fdc?
              JP    NZ,FDERR0                                    
              LD    DE,FDCB                     ; parameter block
              LD    HL,TFDTAB                   ; initial values
              LD    BC,11                       ; 11 Byte
              LDIR                              ; move ...
              CALL  @FDDESL                     ; deselect
              LD    IX,FDCB                     ; parameters
              CALL  @FDREAD                     ; read ...
              LD    HL,FDHEAD                   ; compared to
              LD    DE,TIPLPR                   ; 03 "IPLPRO"
              LD    B,7                          ;
JE471:        LD    C,(HL)                       ;
              LD    A,(DE)                       ;
              CP    C                            ;
              JP    NZ,FDERR1                   ; IPLPRO not found
              INC   HL                           ;
              INC   DE                           ;
              DJNZ  JE471                       ; comparison loop
              LD    DE,IPLM0                    ; "IPL IS LOADING"
              RST   18H                          ;
              LD    DE,FDHEAD+7                 ; filename, the other half
              RST   18H                          ;
              LD    HL,MGBASE                    ;
              LD    (IX+005H),L                 ; boot address of the program
              LD    (IX+006H),H                  ;
              LD    HL,(FDHEAD+14H)                 ;
              LD    (IX+003H),L                 ; block length
              LD    (IX+004H),H                  ;
              LD    HL,(FDHEAD+1EH)                 ;
              LD    (IX+001H),L                 ; sector number calculated
              LD    (IX+002H),H                 ; from the beginning of the block
              CALL  @FDREAD                     ; honor data
              CALL  @FDDESL                     ; disconnect disks
              LD    BC,200H                     ; starts from FD
              EXX                                                
              LD    HL,FDHEAD+14H                ; address to the header file
              JP    QGOPGM                                       
              ;
              ; Error correction
              ;
FDERR1:                                                          
              CALL  @FDDESL                     ; disconnect disks
              LD    DE,ERRM1                    ; FD: not master
              JR    FDCERR                                       
FDERR3:                                                          
              CP    32H                         ; diskette request?
              JR    NZ,JE4BF                    ; no, it's a mistake
FDERR0:                                         ; request to turn on the floppy disk
              LD    DE,IPLM3                    ; Make ready FD
              JR    FDCERR                                       
JE4BF:        LD    DE,ERRM0                    ; FD: loading error
FDCERR:       LD    SP,NEWSP-2                  ; almost initialize the clip
              LD    HL,(FDARET)                 ; return address
              EX    (SP),HL                     ; to the clip instead of something
              RET                                                
              ;
              ; The name of the file with the FD loader
              ;
TIPLPR:       DB    03H                         ; type BSD
              DB    "IPLPRO"                    ; the name of the bootloader
              ;
              ; Sample FD disk table, used by the FDBOOT routine
              ; is copied to RAM
              ;
TFDTAB:       DB    0                           ; disc number (0-3)
              DW    00                          ; block number from the beginning of the disc
              DW    256                         ; the length of the read block
              DW    FDHEAD                      ; boot address
              DB    0                           ; current rate
              DB    0                           ; current sector
              DB    0                           ; initial rate
              DB    0                           ; initial sector
              ;
              ; Select a disk and perform a restore if selected
              ; first
              ;
              ; nothing: what is possible
              ;
@FDSEL:                                         ; Drive selct & restore if desired
              LD    A,(FDON?)                                    
              RRCA                              ; engine ON?
              CALL  NC,@FDON                    ; NO =M turn ON
              LD    A,(IX+000H)                 ; disk number
              OR    10000100B                   ; pricist prikaz
              OUT   (PFDMOT),A                  ; select disk
              XOR   A                                            
              LD    (FDCMD),A                   ; disk selected
              CALL  @D60MS                      ; I'd rather wait
              LD    HL,0                                         
JE4F4:        DEC   HL                                           
              LD    A,H                                           
              OR    L                                            
              JR    Z,JE512                     ; TO expired
              IN    A,(PFDCTR)                  ; status read
              CPL                                                
              RLCA                                               
              JR    C,JE4F4                     ; is waiting for the FDC
              LD    C,(IX+000H)                 ; disk number
              LD    HL,TFDRES                                    
              LD    B,0                                          
              ADD   HL,BC                       ; index table
              BIT   0,(HL)                      ; connected disks
              JR    NZ,JE511                    ; the disk has been connected
              CALL  @FDTR0                      ; restore
              SET   0,(HL)                      ; but come to restore no
JE511:        RET                                                
JE512:        LD    A,32H                       ; TO expired
              JP    FDERR2                                       
              ;
              ; Turn on the floppy disk motor
              ;
@FDON:                                                           
              LD    A,80H                                        
              OUT   (PFDMOT),A                  ; start the engine
              LD    B,16                                         
JE51D:        CALL  @D60MS                      ; delay approx. 960 MS
              DJNZ  JE51D                                        
              LD    A,1                                          
              LD    (FDON?),A                   ; on flag
              RET                                                
              ;
              ; Search for the drive of the selected track
              ;
@FDSEEK:                                                         
              LD    A,1BH                       ; track search display
              CALL  @FDCOPE                                      
              AND   10011001B                   ; edit status
              RET                                                
              ;
              ; Disconnected floppy disks
              ;
@FDDESL:                                                         
              PUSH  AF                                           
              CALL  @D1200                                       
              XOR   A                                            
              OUT   (PFDMOT),A                  ; disconnect display
              LD    (TFDRES),A                  ; reset all flags
              LD    (TFDRES+1),A                ; for all disks before work
              LD    (TFDRES+2),A                ; will have to perform FDTR0
              LD    (TFDRES+3),A                                 
              LD    (FDON?),A                   ; and also turn off the engine
              POP   AF                                           
              RET                                                
              ;
              ; Restore floppy (to 0th track)
              ;
@FDTR0:                                                          
              LD    A,0BH                       ; RESTORE display
              CALL  @FDCOPE                     ; exhibit
              AND   10000101B                   ; mask status
              XOR   00000100B                                    
              RET   Z                           ; everything OK
              JP    FDERR4                                       
              ;
              ; Send the display to the FD controller, also save the display and status
              ; to the appropriate variables
              ;
              ; input: A = display for FD
              ; output: A = status
              ;
@FDCOPE:                                                         
              LD    (FDCMD),A                   ; save your display
              CPL                                                
              OUT   (PFDCTR),A                  ; to radice
              CALL  @FDWT1                      ; wait for not busy
              CALL  @D60MS                      ; delay
              IN    A,(PFDCTR)                  ; status
              CPL                                                
              LD    (FDSTAT),A                  ; impose
              RET                                                
              ;
              ; Wait for FDC ready
              ; if it doesn't, end with an error
              ;
              ; nici: AF
              ;
@FDWT1:                                                          
              PUSH  DE                                           
              PUSH  HL                                           
              CALL  @FDREPC                     ; delay 125 microseconds
JE56D:        LD    HL,0                        ; E = 7 ... number of repetitions
JE570:        DEC   HL                                           
              LD    A,H                                          
              OR    L                                            
              JR    Z,JE57D                     ; IT has expired
              IN    A,(PFDCTR)                  ; status
              RRCA                                               
              JR    NC,JE570                    ; you are not ready
              POP   HL                          ; FDC ready, all right
              POP   DE                                           
              RET                                                
JE57D:        DEC   E                                            
              JR    NZ,JE56D                                     
JE580:        LD    A,29H                       ; error 29H, disk does not boot
              POP   HL                                           
              POP   DE                                           
              JP    FDERR2                                       
              ;
              ; Wait for the FDC to be busy,
              ; if it doesn't finish, it ends with an error
              ;
              ; nici: AF
              ;
@FDWT2:                                                          
              PUSH  DE                                           
              PUSH  HL                                           
              CALL  @FDREPC                     ; delay, E = 7
JE58C:        LD    HL,0                                         
JE58F:        DEC   HL                                           
              LD    A,H                                          
              OR    L                                            
              JR    Z,JE59C                                      
              IN    A,(PFDCTR)                  ; status
              RRCA                                               
              JR    C,JE58F                     ; still ready
              POP   HL                                            
              POP   DE                                           
              RET                                                
JE59C:        DEC   E                           ; it is still necessary to wait
              JR    NZ,JE58C                                     
              JR    JE580                       ; end, error ERR 29H
              ;
              ; Delay 125 microseconds and 7 -M E
              ;
@FDREPC:                                                         
              CALL  @D125                       ; wait
              LD    E,7                         ; that's the length of the next wait
              RET                                                
              ;
              ; Reads data from a floppy disk
              ;
@FDREAD:                                                         
              CALL  @FDTR?                      ; calculate the footprint and the sector
              CALL  @FDPREP                     ; prepare disk and registers
JE5AD:        CALL  @FDTR                       ; set the track
              CALL  @FDSEEK                     ; look for her physically
              JP    NZ,FDERR2                   ; failed
              CALL  @FDSEC                      ; set sector
              DI                                ; do not interrupt, therefore
              LD    A,94H                       ; allow interruption
              CALL  FDSTRT                      ; start reading the sector
JE5BF:        LD    B,0                         ; 256 apartments
JE5C1:        IN    A,(PFDCTR)                  ; status
              RRCA                                               
              JR    C,JE5E0                     ; error
              RRCA                                               
              JR    C,JE5C1                     ; not ready
              INI                               ; precist byte
              JR    NZ,JE5C1                    ; you are reading more
              INC   (IX+008H)                   ; read everything, another sector
              LD    A,(IX+008H)                                  
              CP    17                                           
              JR    Z,JE5DC                     ; go to the next track
              DEC   D                                             
              JR    NZ,JE5BF                    ; honor another sector
              JR    JE5DD                                        
JE5DC:        DEC   D                                            
JE5DD:        CALL  @FDSTOP                     ; stop FD
JE5E0:        NOP                                                
              IN    A,(PFDCTR)                  ; status
              CPL                                                
              LD    (FDSTAT),A                                   
              AND   0FFH                                         
              JR    NZ,FDERR4                                    
              CALL  @FDNEXT                     ; dalsi stop
              JP    Z,JE5F6                     ; end of disc
              LD    A,(IX+007H)                 ; it should do FDPREP
              JR    JE5AD                       ; and cte se dal
JE5F6:        LD    A,80H                       ; end of disc
              OUT   (PFDMOT),A                                   
              RET                                                
              ;
              ; Prepare a floppy disk and file parameters to the registry
              ;
              ; output: D = number of file sectors
              ; HL = boot address
              ; A = rate
              ;
@FDPREP:                                                         
              CALL  @FDSEL                      ; select disc
              LD    D,(IX+004H)                                  
              LD    A,(IX+003H)                                  
              OR    A                           ; length MOD 256
              JR    Z,JE608                     ; it is a multiple of 256
              INC   D                           ; this short is also read
JE608:        LD    A,(IX+00AH)                 ; in D is now the number of sectors
              LD    (IX+008H),A                 ; copy initial number
              LD    A,(IX+009H)                 ; tracks to the current
              LD    (IX+007H),A                  ;
              LD    L,(IX+005H)                 ; boot address
              LD    H,(IX+006H)                                  
              RET                                                
              ;
              ; Set the physical track and side of the floppy, odd tracks
              ; they are on one side and the barrel on the other side
              ;
              ; input: A = logical track number
              ; nici: AF
              ;
@FDTR:                                                           
              SRL   A                           ; rate / 2
              CPL                                                
              OUT   (PFDDAT),A                  ; set a track
              JR    NC,JE626                                     
              LD    A,1                         ; licha stopa
              JR    JE627                                        
JE626:        XOR   A                           ; suda stopa
JE627:        CPL                                                
              OUT   (PFDSIZ),A                  ; set page
              RET                                                
              ;
              ; Set the track and sector according to the data in the FDCB
              ;
              ; output: C = PFDDAT
              ; A = sector
              ;
@FDSEC:                                                          
              LD    C,PFDDAT                    ; THIS IS NOT NEEDED 
              LD    A,(IX+007H)                 ; track
              SRL   A                           ; / 2, on the side of the coffin
              CPL                                                
              OUT   (PFDTRK),A                  ; set
              LD    A,(IX+008H)                 ; sector
              CPL                                                
              OUT   (PFDSEC),A                  ; set
              RET                                                 
              ;
              ; Parameters in FDCB on the next track
              ;
              ; output: A = D ... number of sectors to transmit
              ; F ....... set according to A and therefore also D
              ;
@FDNEXT:                                                         
              LD    A,(IX+008H)                 ; sector
              CP    17                          ; is the last one?
              JR    NZ,JE64B                    ; no
              LD    A,1                         ; Sector 1
              LD    (IX+008H),A                                  
              INC   (IX+007H)                   ; another footprint
JE64B:        LD    A,D                         ; you will transfer me
              OR    A                                            
              RET                                                
              ;
              ; Show on FD
              ;
FDSTRT:                                                          
              LD    (FDCMD),A                   ; save the display
              CPL                                                
              OUT   (PFDCTR),A                  ; send
              CALL  @FDWT2                      ; wait for it to work
              RET                                                
              ;
              ; Stop FD
              ;
              ; nici: AF
              ;
@FDSTOP:                                                         
              LD    A,PFDCTR                    ; stop display
              CPL                                                
              OUT   (PFDCTR),A                  ; stop
              CALL  @FDWT1                      ; wait for it to stop
              RET                                                
              ;
              ; Errors when working with FD
              ;
FDERR4:                                                           
              LD    A,(FDCMD)                   ; last view
              CP    0BH                                          
              JR    Z,JE683                                      
              CP    1BH                                          
              JR    Z,JE683                                      
              CP    0F4H                                         
              JR    Z,JE683                                      
              LD    A,(FDSTAT)                  ; status
              BIT   7,A                                          
              JR    NZ,JE68E                                     
              BIT   6,A                                          
              JR    NZ,JE68A                                     
              BIT   4,A                                          
              LD    A,36H                                        
              JR    NZ,FDERR2                                    
              JR    JE68A                                        
JE683:        LD    A,(FDSTAT)                                   
              BIT   7,A                                          
              JR    NZ,JE68E                                     
JE68A:        LD    A,29H                                        
              JR    FDERR2                                       
JE68E:        LD    A,32H                                        
FDERR2:       CALL  @FDDESL                                      
              JP    FDERR3                                       
              ;
              ; The computed trace number from the sector address on the FDCB (1) a
              ; FDCB (2). The result will be FDCB (9) = foot
              ; FDCB (10) = sector
              ; output: H = B = initial track of the file
              ; L = initial sector of the file
              ; DE = 16
              ; A = 0
              ;
@FDTR?:                                                          
              LD    B,0                                          
              LD    DE,16                       ; sector on track
              LD    L,(IX+001H)                 ; sector address
              LD    H,(IX+002H)                                  
              XOR   A                            ;
JE6A2:        SBC   HL,DE                       ; about 16 sectors
              JR    C,JE6A9                                      
              INC   B                           ; means 1 foot more
              JR    JE6A2                       ; and again
JE6A9:        ADD   HL,DE                       ; sector number remains in L
              LD    H,B                         ; the track number will be in H
              INC   L                           ; sectors are counted from 1
              LD    (IX+009H),H                 ; save to FDCB
              LD    (IX+00AH),L                                  
              RET                                                
              ;
              ; delay approx. 125 microseconds
              ;
@D125:                                                           
              PUSH  DE                                           
              LD    DE,0FH                                       
              JR    D60MS1                                        
              ;
              ; delay approx. 1.2 milliseconds
              ;
@D1200:                                                          
              PUSH  DE                                           
              LD    DE,0A0H                                      
              JR    D60MS1                                       
              ;
              ; Delay approx. 60 milliseconds
              ;
@D60MS:                                                          
              PUSH  DE                                           
              LD    DE,2026H                                     
D60MS1:       DEC   DE                                           
              LD    A,E                                          
              OR    D                                            
              JR    NZ,D60MS1                                    
              POP   DE                                           
              RET                                                
              ;----------------------------------------------------
              ;
              ; RAMDISK
              ;
              ;----------------------------------------------------
              ;
              ; Load the program from the house
              ;
QEB:                                                             
              CALL  @RDLOAD                     ; honor program from RD
              JP    NZ,CMTERR                   ; error
QGORD:                                                           
              LD    BC,0                        ; and run it
              EXX                                                
              LD    HL,FSIZE                    ; GOPGM needs it
              JP    QGOPGM                                       
              ;
              ; Read the program from the Ram disk
              ;
              ; input: C = I / O address
              ; input: Z = 1 ... program read OK
              ; 0 ... checksum error
              ;
@RDLOAD:                                                         
              CALL  JE729                       ; check the CRC on the RD
              RET   NZ                                           
              IN    A,(C)                                        
              INC   C                           ; entry address
              LD    HL,FSIZE                                     
              LD    B,9                                          
              INIR                              ; piece of head here
              LD    DE,(FSIZE)                                   
              LD    HL,MGBASE                                    
              LD    A,E                                          
              OR    A                           ; length MOD 256
              JR    Z,JE6F6                     ; it's in whole blocks
              LD    B,A                                          
JE6F4:        INIR                                               
JE6F6:        LD    B,0                                          
              DEC   D                                             
              JP    P,JE6F4                     ; for each block
              LD    DE,MGBASE                                    
              LD    BC,(FSIZE)                                   
              CALL  @RDCRC                      ; counted CRC
              LD    DE,(RDCRC)                                   
              OR    A                                            
              SBC   HL,DE                       ; and compare with read
              RET                                                
              ;
              ; Count checksum
              ;
              ; input: BC = block length in bytes
              ; DE = block address
              ;
              ; output: BC = 8
              ; DE = DE '
              ; HL = calculated CRC
              ; BC '= 0
              ; DE '= address after the data block
              ; HL '= HL
              ; A = 0
              ;
@RDCRC:                                                          
              EXX                                                
              LD    HL,0                        ; they will feel the same here
              LD    C,8                         ; byte ma 8 bit
              EXX                                                
JE715:        LD    A,B                                          
              OR    C                                            
              JR    Z,JE727                     ; everything is already calculated
              LD    A,(DE)                      ; another byte from the file
              EXX                                                
              LD    B,C                         ; it's 8
JE71C:        RLCA                                               
              JR    NC,JE720                                      
              INC   HL                          ; it's one
JE720:        DJNZ  JE71C                       ; 8 times
              EXX                                                
              INC   DE                          ; on the next byte
              DEC   BC                          ; and the length is shortened
              JR    JE715                       ; repeat
JE727:        EXX                                                
              RET                                                
              ;
              ; Check the CRC header on the RD, read from the beginning of the RD
              ; 8 bytes, 9th byte is considered the number of units
              ;
              ; input: C = I / O port
              ; output: Z = 1 ... CRC agrees
              ; 0 ... checksum error
              ; A = read CRC from RD
              ; D = calculated CRC
              ; B = 0
              ;
JE729:                                                           
              IN    A,(C)                       ; pointer to the beginning
              LD    B,8                                          
              LD    D,0                                          
              INC   C                           ; cteci port
JE730:        IN    A,(C)                                        
              PUSH  BC                                           
              LD    B,8                                          
JE735:        RLCA                                               
              JR    NC,JE739                                     
              INC   D                           ; we feel one
JE739:        DJNZ  JE735                       ; 8 times
              LD    A,D                                          
              POP   BC                                            
              LD    D,A                                          
              DJNZ  JE730                       ; 8 times
              IN    A,(C)                       ; cti CRC
              DEC   C                           ; turn control port
              CP    D                           ; compare with CRC calculated
              RET                                                
              ;
              ; Read the program from the CMT and save it to the RAM disk
              ;
QES:                                                             
              LD    DE,SRCPRG                   ; Ramcard prog.
              CALL  IFNL?                                        
              RST   18H                                          
              CALL  IFNL?                                        
              LD    DE,SMASTS                   ; Master tape set
              RST   18H                                          
              CALL  IFNL?                                        
              CALL  @RHEAD                      ; header from CMT
              JR    C,JE769                     ; failed
              LD    DE,MSGLD                    ; Loading
              CALL  IFNL?                                        
              RST   18H                                          
              LD    DE,FNAME                    ; listing file name
              RST   18H                                          
              CALL  @RDATA                      ; and honor data from CMT
JE769:        JP    C,CMTERR                    ; CMT error
              IN    A,(C)                       ; at the beginning of the RAM disk
              LD    (RDADR),BC                  ; save the IIO address of the RD
              LD    DE,(BEGIN)                                   
              LD    BC,(FSIZE)                                   
              PUSH  DE                                            
              PUSH  BC                                           
              CALL  @RDCRC                      ; counted CRC
              LD    (RDCRC),HL                  ; save to header
              LD    HL,FSIZE                                     
              LD    BC,(RDADR)                  ; restore I / O address
              LD    B,8                                          
              INC   C                                            
              INC   C                           ; data output port
              PUSH  HL                                           
              PUSH  BC                          ; 8 byte headers =
              OTIR                              ; length, address, start, CRC
              POP   BC                          ; B = 8 C = I / O
              POP   HL                                           
              PUSH  DE                                           
              LD    D,0                         ; calculate the CRC header
JE796:        PUSH  BC                                           
              LD    B,8                                          
              LD    A,(HL)                                       
JE79A:        RLCA                                               
              JR    NC,JE79E                                     
              INC   D                           ; another one found
JE79E:        DJNZ  JE79A                       ; 8 times
              INC   HL                                           
              POP   BC                                           
              DJNZ  JE796                       ; 8 times
              LD    A,D                                          
              POP   DE                                            
              OUT   (C),A                       ; CRC to RD
              POP   DE                          ; file length
              POP   HL                          ; boot address
              LD    A,E                         ; length MOD 256
              OR    A                                            
              JR    Z,JE7B1                     ; only whole blocks
              LD    B,E                         ; the piece first
JE7AF:        OTIR                                               
JE7B1:        LD    B,0                         ; and now only whole blocks
              DEC   D                                            
              JP    P,JE7AF                     ; send another block
              JP    QPRMPT                                       
              ;
              ; Check if a RAM disk is present
              ;
              ; input: C = I / O address
              ; output: CY = 1 ... ram disk no
              ; 0 ... ram disk is
              ; nici: AF, if the ram disk is not, so is C
              ;
@???RD:                                                          
              XOR   A                                            
              IN    A,(C)                       ; at the beginning of the house
              INC   C                           ; cteci port
              IN    A,(C)                       ; honor byte
              EX    AF,AF'                                       
              DEC   C                                            
              IN    A,(C)                       ; again at the beginning
              LD    B,0A5H                                       
              INC   C                                            
              INC   C                           ; write port
              OUT   (C),B                       ; business A5
              DEC   C                                            
              DEC   C                                            
              IN    A,(C)                       ; at the beginning
              INC   C                                             
              IN    A,(C)                       ; honor, it should
              CP    B                           ; apartment A5
              JR    NZ,JE7DF                    ; but it's not
              DEC   C                           ; control port
              IN    A,(C)                       ; again at the beginning
              EX    AF,AF'                      ; what was read
              INC   C                           ; will have to go back
              INC   C                                            
              OUT   (C),A                                        
              DEC   C                                            
              DEC   C                           ; and the original C
              RET                               ; mame RD =M CY = 0
JE7DF:        XOR   A                           ; RD not connected
              SCF                               ; CY = 1
              RET                                                
              ;
SRCPRG:       DB    'R',0A1H,0B3H,9FH,0A1H,9DH,9CH,' '           
              DB    9EH,9DH,0B7H,97H,'.',CR                    
              ; Ramcard prog.
SMASTS:       DB    4DH,0A1H,0A4H,96H,92H,9DH,' ',96H            
              DB    0A1H,9EH,92H,' ',0A4H,92H,96H,CR  ; Master tape set


              ;----------------------------------------------------
              ;
              ; Cold start monitor 
              ;
              ;----------------------------------------------------
              ORG   0E800H                                         
COLD:                                                            
              NOP                                                
              JP    JE813                       ; skip JUMP vector
              JP    QPRMPT                      ; monitor prompt
@COPYL:       JP    COPYL                       ; load file from CMT:
@COPYS:       JP    COPYS                       ; save file to CMT:
@COPYV:       JP    COPYV                       ; verify file on CMT:
              JP    @QDISK                      ; some EXEC (?, ...
              ;
JE813:                                                           
              DI                                                 
              IM    1                                                
              LD    A,8                                          
              OUT   (PDMD),A                    ; MZ-700 mode settings
              LD    A,1                         ; CRT settings:
              OUT   (PRF),A                     ; single color
              OUT   (PWF),A                     ; MZ-700 = DATA, ATB, CG
              OUT   (PMMC4 ),A                  ; mapped ROM, CGROM, VRAM
              LD    SP,NEWSP                                     
              CALL  @INI55                                       
              XOR   A                                            
              LD    DE,0                                         
              CALL  TIMST                       ; we start at midnight
              LD    BC,37                                        
              CALL  @944BC                      ; delay approx. 16.28 ms
              LD    BC,4*256+PCPR                ; control PIO port
              LD    HL,TPIO                     ; bit mode, 6th and 7th bit as
              OTIR                              ; output, other input, DI
              LD    BC,4*256+PCPR+1                ; PIO data port
              OTIR                              ; bit mode, all output, DI
              LD    A,1                                          
              OUT   (0F7H),A                                     
              XOR   A                                            
              OUT   (0F7H),A                    ; turn off QD:
              CALL  BRKEY                       ; test CTRL
              JR    NC,JE862                    ; CTRL not pressed
              CP    20H                                          
              JP    NZ,JE862                    ; just SHIFT, we don't care
              IN    A,(PDMD)                    ; state of switch MZ-700
              AND   2                           ; is ON?
              JR    Z,JE85F                     ; is, we leave the MZ-700
              XOR   A                                            
              OUT   (PDMD),A                    ; no, so MZ-800
              CALL  @BLACK                      ; black display
JE85F:        JP    GORAM                       ; jump to RAM at 0
JE862:        LD    B,4                         ; turn off PSG
              LD    A,9FH                                        
JE866:        OUT   (PPSG),A                                     
              ADD   A,20H                                        
              DJNZ  JE866                       ; all registers are turned off
              LD    A,1                                          
              LD    (MCWR55),A                  ; ban on whistling from 8253
              LD    A,5                                          
              LD    (MCWR55),A                  ; permission interrupted
              LD    B,0FFH                      ; zero
              LD    HL,FNAME                    ; buffer
              CALL  @F0B                        ; CMT control block
              LD    A,16H                                        
              CALL  @PRNTC                                       
              LD    A,71H                       ; filling VRAM
              LD    HL,ADRATB                   ; attribute 71H
              CALL  @FILLA                                       
              LD    HL,38DH                     ; initialization
              LD    A,0C3H                      ; jump RST38
              LD    (INTSRQ),A                  ; in RAM on
              LD    (INTADR),HL                 ; patricna mista
              LD    A,4                                          
              LD    (TEMPO),A                   ; medium speed tune
              CALL  MSTP                        ; stop MZ 700 music
              CALL  @IFNL?                                       
              CALL  BEEP                        ; beep
              LD    A,1                         ; beep on each key
              LD    (BPFLG),A                   ; will not
              IN    A,(PMMC0 )                  ; mapping CGROM, CGRAM
              LD    DE,0C000H                   ; copied
              LD    HL,1000H                    ; character
              LD    BC,1000H                    ; degenerator
              LDIR                              ; to VRAM
              IN    A,(PMMC1)                   ; unmaps CG
              CALL  @GETKY                      ; key pressed during RESET?
              CP    'M'                                          
              JR    Z,QMONIT                    ; to the monitor now
              CP    'Q'                                          
              JR    Z,JE91B                     ; clean from QD:
              CP    'C'                                          
              JR    Z,IPLCMT                    ; clean from CMT:
              CALL  @???FD                      ; we have floppy disks
              JR    NZ,IPLRD                    ; we don't
IPLFD:        CALL  @CLRS                       ; delete CRT:
              CALL  @FDBOOT                     ; cti program IPLPRO
              JP    QIPL                        ; return voice printing and RET
              ;
              ; Find out if we have FD:
              ;
              ; output: Z = 1 ... floppy disk found
              ; Z = 0 ... we don't have a floppy disk
              ;
              ; nici: AF, B
              ;
@???FD:                                                          
              LD    A,0A5H                      ; some constant
              LD    B,A                                          
              OUT   (PFDTRK),A                  ; to the trace register
              CALL  @D125                       ; wait for a while
              IN    A,(PFDTRK)                  ; and we read it back
              CP    B                           ; did she stay there?
              RET                               ; if so, we have FD
              ;
              ; The entire MZ 800 screen will be black
              ;
              ; output: BC = 6CFH, A = 0
              ;
@BLACK:                                                          
              PUSH  HL                                           
              LD    BC,5*256+PPAL                ; pallet settings
              LD    HL,TBLACK                   ; all black
              OTIR                                               
              XOR   A                                            
              LD    BC,6*256+PCRTC                ; border register
              OUT   (C),A                       ; border take black
              POP   HL                                           
              RET                                                
              ;
              ; Load the program from the RD disk, if it exists
              ;
IPLRD:                                                           
              LD    C,0F8H                                       
              CALL  @???RD                      ; do we have RD?
              JP    C,IPLQD                     ; we don't
              CALL  @RDLOAD                     ; The house is here, try to clean
              LD    DE,ERMG12                    ; SRAM: check sum error
              JP    NZ,QIPL                     ; we don't have a ram disk
              JP    QGORD                       ; program from the RD and run
              ;
              CALL  CLR3L                       ; delete the CRT and three times the CRLF
              ;
              ;
              ; Display the initialization screen and wait for it to press
              ; keys of any of the listed displays
              ;
IPLKEY:       CALL  @MSGIN                      ; initialize screen
              CALL  @WNKEY                      ; until the key is pressed
JE90F:        CALL  @???QD                                       
              JR    NZ,JE91E                    ; QD not connected
              LD    A,2                                          
              CALL  QKBD??                                       
              CP    7FH                         ; pressed Q?
JE91B:        JP    Z,IPLQD                     ; Yes
JE91E:        LD    A,4                                          
              CALL  QKBD??                                       
              CP    0DFH                        ; C pressed?
              JR    Z,IPLCMT                    ; Yes
              LD    C,A                                          
              CALL  @???FD                                       
              JR    NZ,JE932                    ; FDs are not
              LD    A,C                                          
              CP    0FBH                        ; pressed F?
              JR    Z,IPLFD                     ; Yes
JE932:        LD    A,3                                          
              CALL  QKBD??                                       
              CP    0F7H                        ; pressed M?
              JR    NZ,JE90F                    ; No
              ;
              ; List the header of the monitor and jump to its reading display
              ;
QMONIT:                                                          
              CALL  @CLRS                                        
              LD    DE,MONMSG                                     
              RST   18H                                          
              JP    QPRMPT                                       
              ;
              ; Program implementation from CMT
              ;
IPLCMT:                                                          
              LD    HL,MPORTC                   ; is CMT?
              LD    A,(HL)                                       
              AND   10H                                          
              JR    NZ,JE972                    ; yes, you can start cleaning immediately
              INC   HL                                            
              LD    A,6                                          
              LD    (HL),A                      ; up
              INC   A                                            
              LD    (HL),A                      ; down
              DEC   HL                                           
              LD    A,(HL)                                       
              AND   10H                         ; now he should go
              JR    NZ,JE972                    ; yes, now he eats
              CALL  @CLRS                                        
              CALL  @LETNL                                       
              CALL  @LETNL                                       
              LD    DE,IPLM1                    ; Make ready CMT
              CALL  MSG12                                        
JE968:                                                           
              CALL  @BRKEY                                       
              JR    Z,CMTER2                    ; break
              LD    A,(HL)                                       
              AND   10H                                          
              JR    Z,JE968                     ; we are waiting for them to turn it on
JE972:                                                           
              CALL  @CLRS                                        
              CALL  @LETNL                                       
              LD    DE,IPLM4                    ; IPL is looking ...
              RST   18H                                          
              CALL  @RHEAD                                        
              JP    C,CMTER1                                     
              CALL  @CLRS                                        
              LD    DE,IPLM0                    ; IPL is loading ..
              RST   18H                                          
              LD    DE,FNAME                    ; file name
              RST   18H                                          
              LD    HL,(BEGIN)                                   
              EXX                                                
              LD    HL,MGBASE                   ; boot address
              LD    (BEGIN),HL                  ; for now in the header
              CALL  @RDATA                      ; clean data from 1200
              JP    C,CMTER1                    ; error
              ;
              ; run the program loaded from CMT
              ;
QGOCMT:                                                          
              LD    BC,100H                     ; tape recorder
              EXX                               ; to BC '
              LD    (BEGIN),HL                  ; actual boot address
              LD    HL,FSIZE                    ; to the header points to the length
              JP    QGOPGM                      ; start
              ;
              ; error returns
              ;
CMTER1:                                                          
              CP    2                                            
CMTER2:                                                          
              LD    DE,IPLM1                    ; Make ready CMT
              JR    Z,JE9B4                                      
              LD    DE,ERRM2                    ; CMT loading err.
JE9B4:                                                           
              JP    QIPL                                         
              ;
              ; Load a program from QD
              ;
IPLQD:                                                           
              CALL  @???QD                      ; mame QD?
              LD    A,2                                          
              JR    NZ,CMTER1                   ; we don't, read from CMT
              CALL  JEEEC                                        
              CALL  JEF27                                        
              LD    DE,IPLM2                    ; Make ready QD
              JR    C,QIPL                                       
              CALL  @CLRS                                        
              LD    A,0DH                                        
              LD    (IOBUF),A                                    
              CALL  JF25F                                        
              LD    A,1                                          
              LD    (M113A),A                                    
              LD    HL,0EA04H                                    
              LD    SP,NEWSP-2                                   
              EX    (SP),HL                                      
              CALL  JEEF7                                        
              JP    C,JF202                                      
              LD    A,(HEAD)                                     
              CP    1                                            
              LD    DE,ERRM4                    ; QD: File mode error
              JR    NZ,QDERR                    ; the mistake is really
              LD    DE,IPLM0                    ; IPL is loading
              RST   18H                                          
              JP    JEEC2                                        
              ;
              LD    DE,IPLM2                                     
              ;
              ; Error working with QD
              ;
QDERR:                                                           
              PUSH  DE                                           
              LD    A,6                                          
              LD    (M1130),A                                    
              CALL  @QDISK                                       
              POP   DE                                           
              JR    QIPL                                         
              ;
              ; List on the initialization message display without
              ; 1. radku. According to the available equipment
              ; writes a menu for selecting a display
              ; Nothing all registers
              ;
@MSGIN:                                                          
              CALL  @LETNL                                       
              LD    DE,SELM0                    ; Please push key
              CALL  MSG12                                        
              CALL  @LETNL                                       
              CALL  @???FD                                       
              JR    NZ,JEA1D                    ; not floppy
              LD    DE,SELM1                    ; F: floppy disk
              CALL  MSG12                                        
JEA1D:        CALL  @???QD                                       
              JR    NZ,JEA28                    ; not QD
              LD    DE,SELM2                    ; Q: quick disk
              CALL  MSG12                                        
JEA28:        LD    DE,SELM3                    ; C: tape cassette
              CALL  MSG12                                        
              LD    DE,SELM4                    ; M: monitor
              JP    MSG12                       ; list and RET
              ;
              ; List of messages from DE on the display, list of help menus
              ; MGIN and waiting for the keyboard to press
              ;
QIPL:                                                            
              CALL  @CLRS                                        
              CALL  @LETNL                                       
              CALL  @LETNL                                       
              CALL  MSG12                                        
              JP    IPLKEY                                       
              ;
              ; Clear the display and CRLF 3 times on it
              ;
CLR3L:                                                           
              CALL  @CLRS                                        
              LD    B,3                                          
JEA48:        CALL  @LETNL                                       
              DJNZ  JEA48                                        
              RET                                                
              ;
              ; Printing twelve spaces and messages on the display, which
              ; the address is in the DE register
              ;
MSG12:                                                           
              LD    B,12                        ; number of spaces
JEA50:        CALL  @PRNTS                      ; gap
              DJNZ  JEA50                                        
              RST   18H                         ; message from the DE register
              JP    @LETNL                                       
              ;
              ; Clear the screen
              ;
              ; nici: AF
              ;
@CLRS:                                                           
              LD    A,0C6H                                       
              JP    @?DPCT                                       

              ;----------------------------------------------------
              ;
              ; MONITOR 9Z-504M
              ;
              ;----------------------------------------------------
QPRMPT:                                                          
              LD    SP,NEWSP                    ; SP is in the area through which
              CALL  @IFNL?                      ; is mapping CG-ROMT
              LD    A,'*'                                        
              CALL  @PRNTC                                       
              LD    DE,IOBUF                    ; input buffer address
              CALL  @GETL                                        
QPRMLOP:                                                         
              LD    A,(DE)                                       
              INC   DE                                            
              CP    CR                                         
              JR    Z,QPRMPT                                     
              CP    'J'                                          
              JR    Z,QJUMP                     ; jump to the program
              CP    'L'                                          
              JP    Z,QLOAD                     ; honor the program from CMT
              CP    'F'                                          
              JR    Z,QFLOPY                    ; honor the program from FD
              CP    'B'                                          
              JP    Z,QBEEP                     ; controlled keyboards
              CP    'M'                                          
              JP    Z,QMODIF                    ; memory modification
              CP    'S'                                          
              JP    Z,QSAVE                     ; save the program to a tape
              CP    'V'                                          
              JP    Z,QVERIF                    ; program verification
              CP    'D'                                          
              JP    Z,QDUMP                     ; HEXA memory dump
              CP    'Q'                                          
              JR    Z,QQDISK                    ; work with quick disk
              CP    'E'                                          
              JR    Z,QRCARD                    ; work with ram disk
              CP    'G'                                          
              JR    Z,QGOSUB                    ; jump to subroutine
              JR    QPRMLOP                                      
              ;----------------------------------------------------
              ;
              ; J = jump
              ;
              ;----------------------------------------------------
QJUMP:                                                           
              CALL  QHEXHL                      ; decode the address
QJPHL:        JP    (HL)                        ; and jump on her
              ;
              ; Called subroutines
              ;
              ;----------------------------------------------------
              ;
              ; G = gosub (subroutine call)
              ;
              ;----------------------------------------------------
QGOSUB:                                                          
              CALL  QHEXHL                      ; decode the address
              CALL  QJPHL                       ; call JP (HL)
              JR    QPRMPT                                       
              ;----------------------------------------------------
              ;
              ; Q = quick disk (works with QD :)
              ;
              ;----------------------------------------------------
QQDISK:                                                          
              CALL  @???QD                      ; mame QD:
              JR    NZ,QPRMPT                   ; no, that's why we won't be with him
              CALL  JEEEC                       ; work
              LD    HL,0                                         
              LD    (M113A),HL                                   
              LD    A,(DE)                      ; kinds of display character
              CP    'L'                                          
              JP    Z,QQL                       ; read the program
              CP    'S'                                          
              JP    Z,QQS                       ; save the program
              CP    'C'                                          
              JP    Z,QQC                       ; program copy
              CP    'F'                                           
              JP    Z,QQF                       ; disk formatting
              CP    'X'                                          
              JP    Z,QQX                       ; program copy
              CP    'D'                                          
              JP    Z,QQD                       ; directory listing
QPRMP1:                                                          
              JP    QPRMPT                                       
              ;----------------------------------------------------
              ;
              ; E = read and save program to RAM disk =
              ;
              ;----------------------------------------------------
              ;
              ; E .... Work with RD
              ;
              ; ES ... Save the program from the cassette to the RD
              ; EB ... Run program from RD
              ;
QRCARD:                                                          
              LD    C,0F8H                      ; this is perhaps an I / O address
              CALL  @???RD                      ; RAM disk
              JR    NC,JEAF3                    ; No, let's try
              LD    C,0A8H                      ; such an I / O address
              CALL  @???RD                                       
              JR    C,QPRMP1                    ; again, we probably don't have it
JEAF3:                                                           
              LD    A,(DE)                      ; 2nd character of the display
              CP    'B'                                          
              JP    Z,QEB                       ; run the program from the RD
              CP    'S'                                          
              JP    Z,QES                       ; program from CMT to RD
              JR    QPRMP1                                       
              ;----------------------------------------------------
              ;
              ; F = floppy (load program from floppy)
              ;
              ;----------------------------------------------------
QFLOPY:                                                          
              LD    A,(DE)                                       
              CP    CR                                         
              JR    NZ,QPRMP1                   ; must not be parameters
              CALL  @???FD                      ; do we have FD?
              JR    NZ,QPRMP1                   ; No
              CALL  @FDBOOT                     ; read the file
              CALL  @IFNL?                                       
              RST   18H                                          
              JR    QPRMP1                                       
              ;
              ; Find out if QD is connected
              ;
              ; output: Z = 1 ... QD connected
              ; 0 ... QD does not exist
              ;
              ; nici: AF
              ;
@???QD:                                                          
              LD    A,2                                          
              OUT   (0F7H),A                                     
              LD    A,0A5H                      ; sample
              OUT   (0F7H),A                    ; write a sample
              LD    A,2                                          
              OUT   (0F7H),A                                     
              IN    A,(0F7H)                    ; clean with QD
              CP    0A5H                        ; compare with the sent sample
              RET                               ; if there is a QD, it has to be equal
              ;
              ; statement CHECK SUM ERR. or BREAKT according to the error number,
              ; return to monitor
              ;
CMTERR:                                                           
              LD    DE,MGBRK                    ; BREAKT
              CP    2                                            
              JR    Z,JEB2E                     ; it really was a break
              LD    DE,SCHECK                   ; check sum error
JEB2E:        CALL  @IFNL?                                       
              RST   18H                                          
              JR    QPRMP1                      ; to the monitor
              ;
QGETL:                                                           
              EX    (SP),HL                     ; return address in HL
              POP   BC                          ; BC: = HL
              LD    DE,IOBUF                                     
              CALL  @GETL                                        
              LD    A,(DE)                                       
              CP    1BH                                          
              JR    Z,QPRMP1                    ; break
              JP    (HL)                        ; return
              ;
              ; Decodes 4 HEXA bytes from the input chain,
              ; returns in HL. If the number cannot be decoded,
              ; monitor control sales.
              ; Nici: AF, IY
              ;
QHEXHL:                                                          
              EX    (SP),IY                     ; return address
              POP   AF                                           
              CALL  @HLHEX                      ; decode
              JR    C,QPRMP1                    ; error
              JP    (IY)                                         
              ;----------------------------------------------------
              ;
              ; L = load (load RAM on CMT)
              ;
              ;----------------------------------------------------
QLOAD:                                                           
              CALL  @RFILE                      ; cti program
              JR    C,CMTERR                    ; failed
              JP    QGOCMT                      ; launch him
              ;
              ; Read CMT file from MGBASE (1200H)
              ;
              ; output: HL '= actual boot address
              ; HL = address where the program was loaded (1200H)
              ;
              ; nici: DE
              ;
@RFILE:                                                          
              CALL  RHEAD                       ; header
              RET   C                           ; not possible
              CALL  @IFNL?                                       
              LD    DE,MSGLD                    ; Loading
              RST   18H                                          
              LD    DE,FNAME                                     
              RST   18H                         ; listing file name
              LD    HL,(BEGIN)                  ; actual boot address
              EXX                               ; keep
              LD    HL,MGBASE                   ; always from 1200H
              LD    (BEGIN),HL                                   
              JP    RDATA                       ; with honored data
              ;
              ; Copier - Load
              ;
COPYL:                                                           
              CALL  @RFILE                      ; honor file
              JR    C,CMTERR                    ; error
              EXX                               ; the correct address must
              LD    (BEGIN),HL                  ; data in the header for
              JR    @OKT                        ; COPYS and COPYV
              ;----------------------------------------------------
              ;
              ; M = modify
              ;
              ;----------------------------------------------------
QMODIF:                                                           
              CALL  QHEXHL                      ; starting address
JEB7E:        CALL  @?NLHL                      ; write on new line
              CALL  @MHEX                       ; and byte to her
              CALL  PRNTS                                        
              CALL  QGETL                                        
              CALL  @HLHEX                                       
              JR    C,JEBAA                                      
              CALL  @IC4DE                                       
              INC   DE                                           
              CALL  @2HEX                                        
              JR    C,JEB7E                                      
              CP    (HL)                                         
              JR    NZ,JEB7E                                     
              INC   DE                                           
              LD    A,(DE)                                       
              CP    0DH                                          
              JR    Z,JEBA7                                      
              CALL  @2HEX                                        
              JR    C,JEB7E                                      
              LD    (HL),A                                       
JEBA7:        INC   HL                                           
              JR    JEB7E                                         
JEBAA:        LD    H,B                                          
              LD    L,C                                          
              JR    JEB7E                                        
              ;----------------------------------------------------
              ;
              ; S = save (save program to tape)
              ;
              ;----------------------------------------------------
QSAVE:                                                           
              CALL  QFNAME                      ; honor name
              LD    HL,IOBUF                                     
              LD    DE,FNAME                                     
              LD    BC,11H                                       
              LDIR                              ; move to header
              CALL  QTOPA                       ; boot address
              LD    (BEGIN),HL                                   
              CALL  QENDA                       ; end address
              LD    BC,(BEGIN)                                   
              SCF                                                
              SBC   HL,BC                       ; calculate the length
              INC   HL                                           
              INC   HL                          ; THIS INSTRUCTION IS IN ADDITION 
              LD    (FSIZE),HL                                   
              CALL  QEXCA                       ; start address
              LD    (ENTRY),HL                                   
              LD    A,1                         ; type always 1 = ORDER NO
              LD    (HEAD),A                                     
              CALL  WHEAD                       ; write the header
JEBDF:        JP    C,CMTERR                                     
              CALL  QWDATA                      ; write down the data
JEBE5:        JP    QPRMPT                                       
              ;
              ; Kopirka - Save
              ;
COPYS:                                                           
              CALL  WHEAD                       ; write header
              JR    C,JEBDF                                      
              LD    HL,MGBASE                   ; the program is from 1200
              LD    (BEGIN),HL                  ; impose
              ;
              ; Write data to the tape, in case of error make a report
              ; sell monitor control
              ;
QWDATA:                                                          
              CALL  WDATA                       ; write down the data
              JR    C,JEBDF                     ; error bounce
              ;
              ; List OKT on display
              ;
              ; nici: DE
              ;
@OKT:                                                            
              CALL  @IFNL?                                       
              LD    DE,942H                                      
              RST   18H                                          
              RET                                                
              ;----------------------------------------------------
              ;
              ; V = verify (check the program on the tape
              ;
              ;----------------------------------------------------
QVERIF:                                                          
              CALL  VERIF                       ; verify normally
JEC03:        JP    C,CMTERR                                      
              JP    QOKT                                         
              ;
              ; Copier - Verify
              ;
COPYV:                                                           
              CALL  @VER12                      ; This is to verify, however
              JR    C,JEC03                     ; boot address 1200H
              JR    @OKT                                         
              ;
              ; Verify with boot address 1200H
              ;
@VER12:                                                          
              DI                                                 
              PUSH  DE                                           
              PUSH  BC                                           
              PUSH  HL                                           
              LD    BC,(FSIZE)                  ; length
              LD    HL,MGBASE                   ; replacement address
              JP    VERIF1                      ; to the lower monitor
              ;----------------------------------------------------
              ;
              ; B = beep (controlled whistling after each key)
              ;
              ;----------------------------------------------------
QBEEP:                                                           
              LD    A,(BPFLG)                                    
              RRA                                                
              CCF                                                
              RLA                               ; kind of condition than it was
              LD    (BPFLG),A                                    
JEC27:        JR    JEBE5                                        
              ;----------------------------------------------------
              ;
              ; D = dump
              ;
              ;----------------------------------------------------
QDUMP:                                                           
              CALL  QHEXHL                                       
              CALL  @IC4DE                                       
              PUSH  HL                                           
              CALL  @HLHEX                                       
              POP   DE                                           
              JR    C,JEC87                                      
JEC36:        EX    DE,HL                                        
JEC37:        LD    B,8                                          
              LD    C,17H                                        
              CALL  @?NLHL                                       
JEC3E:        CALL  @MHEX                                        
              INC   HL                                           
              PUSH  AF                                           
              LD    A,(CURSOR)                                   
              ADD   A,C                                          
              LD    (CURSOR),A                                    
              POP   AF                                           
              CP    20H                                          
              JR    NC,JEC51                                     
              LD    A,2EH                                        
JEC51:        CALL  @?ADCN                                       
              CALL  PRNTA                                        
              LD    A,(CURSOR)                                   
              INC   C                                            
              SUB   C                                            
              LD    (CURSOR),A                                   
              DEC   C                                            
              DEC   C                                            
              DEC   C                                            
              PUSH  HL                                           
              SBC   HL,DE                                        
              POP   HL                                           
              JR    Z,JEC84                                      
              LD    A,0F8H                                       
              LD    (MKBOUT),A                                   
              NOP                                                 
              LD    A,(MKBDIN)                                   
              CP    0FEH                                         
              JR    NZ,JEC78                                     
              CALL  @?BLNK                                       
JEC78:        DJNZ  JEC3E                                        
JEC7A:        CALL  @GETKD                                       
              OR    A                                            
              JR    Z,JEC7A                                      
              CALL  BRKEY                                        
              JR    NZ,JEC37                                     
JEC84:        EQU   0EC84H                                       
              JR    JEC27                                        
JEC87:        LD    HL,0A0H                                      
              ADD   HL,DE                                        
              JR    JEC36                                        
              ;
              ; Read the name of the file on the keyboard
              ;
QFNAME:                                                          
              CALL  @IFNL?                                       
              LD    DE,MSGV0                    ; Filename?
              RST   18H                                          
              LD    DE,IOBUF                                      
              CALL  @GETL                                        
              LD    A,(DE)                                       
              CP    1BH                         ; break?
              JR    NZ,JECA4                    ; No, all right
JEC9F:        LD    HL,QPRMPT                                    
              EX    (SP),HL                     ; return to monitor
              RET                                                
              ;
JECA4:        LD    B,0                         ; name read
              LD    DE,IOBUF+10                 ; this is where the name starts with
              LD    HL,IOBUF                                     
              LD    A,(DE)                      ; name sign
              CP    CR                                         
              JR    Z,JECD1                     ; end of string
JECB1:                                          ; ignore spaces before name
              CP    SPACE                                        
              JR    NZ,JECB9                    ; no gap
              INC   DE                          ; ignore space
              LD    A,(DE)                                       
              JR    JECB1                       ; another sign
JECB9:        CP    '"'                                          
              JR    Z,JECC5                     ; quotation marks as the 1st character
JECBD:        LD    (HL),A                      ; save the character at the beginning of the buffer
              INC   HL                                           
              INC   B                           ; increase the length
              LD    A,17                                         
              CP    B                           ; bigger length than it should be?
              JR    Z,QFNAME                    ; yes, honor again
JECC5:        INC   DE                                           
              LD    A,(DE)                      ; another sign
              CP    '"'                                          
              JR    Z,JECCF                       ; quotes or CRs close
              CP    CR                        ; name
              JR    NZ,JECBD                    ; save the character and continue
JECCF:        LD    A,CR                      ; you have to save CR
JECD1:        LD    (HL),A                                       
              RET                                                
              ;
              ; Honor the loading address
              ;
QTOPA:                                                           
              LD    DE,MSGTA                    ; Top?
              JR    QHEXIN                                       
              ;
              ; Honor the end address
              ;
QENDA:                                                           
              LD    DE,MSGEA                    ; End?
              JR    QHEXIN                                       
              ;
              ; Honor the start address
              ;
QEXCA:                                                           
              LD    DE,MSGXA                    ; Exc?
              ;
              ; Print the string DE on the display and honor the HEXA number as follows
              ; as long as it fails
              ;
QHEXIN:                                                          
              CALL  @IFNL?                                       
              RST   18H                         ; list the appropriate voice
              PUSH  DE                                           
              LD    DE,IOBUF                                     
              CALL  @GETL                       ; honor string
              LD    A,(DE)                                       
              CP    1BH                                          
              POP   DE                                            
              JR    Z,JEC9F                     ; it was a break
              PUSH  DE                          ; permanent address introductory voice
              LD    DE,IOBUF+10                 ; the number starts here
              CALL  @HLHEX                      ; try to decode
              POP   DE                                           
              JR    C,QHEXIN                    ; wrong input
              RET                                                
              ;
              ; Sales of program loaded from 1200H, first
              ; place where it belongs
              ;
              ; input: HL = address of the file size in the header
              ; BC '= parameter sold by the program
              ;
QGOPGM:                                                          
              IN    A,(PDMD)                                     
              BIT   1,A                                          
              JR    Z,JED08                     ; MZ 700 mod
              XOR   A                                            
              OUT   (PDMD),A                    ; MZ 800 mod
              CALL  @BLACK                      ; black screen
JED08:        LD    C,(HL)                      ; BC: = length
              INC   HL                                           
              LD    B,(HL)                                       
              INC   HL                                           
              LD    E,(HL)                      ; DE: = address
              LD    A,(HL)                                       
              INC   HL                                           
              LD    D,(HL)                                       
              OR    (HL)                                         
              PUSH  DE                          ; hide address
              INC   HL                                           
              LD    E,(HL)                      ; DE: = start address
              OR    (HL)                                         
              INC   HL                                           
              LD    D,(HL)                                       
              OR    (HL)                                         
              PUSH  DE                                           
              POP   IX                          ; IX = start address
              POP   DE                          ; boot address
              JR    NZ,JED20                    ; if the bootloader and boot address are
              OUT   (PMMC0 ),A                  ; zero, map down to RAM
JED20:        LD    HL,MGBASE                                    
              LD    A,MGBASE/256                ; address of the program page
              CP    D                                            
              JR    C,JED2E                     ; the program will be over 1200
              JR    NZ,JED3E                    ; the program will be below 1200
              XOR   A                           ; will be from 1200 to 12FF
              CP    E                           ; CURRENT, ADMINISTRATELY APARTMENT
              JR    NC,JED3E                    ; JR NC, JED40 
JED2E:        DEC   BC                          ; the program will be over 1200
              PUSH  HL                          ; addresses must be edited
              LD    HL,0                        ; reading length
              ADD   HL,DE                       ; and reading the unit
              ADD   HL,BC                                        
              PUSH  HL                                           
              POP   DE                                           
              POP   HL                                           
              ADD   HL,BC                                        
              INC   BC                                           
              LDDR                                                
              JR    JED40                       ; run
JED3E:                                          ; program below 1200, it's easy
              LDIR                                               
JED40:                                                           
              EXX                               ; to the BC start parameter
              JP    (IX)                                         


              ; Please push key
SELM0:        DB    050H, 0b8H, 092H, 0a1H, 0a4H, 092H, 020H, 09eH, 0a5H, 0a4H, 098H, 020H, 0a9H, 092H, 0bdH, CR
              ; F: Floppy disk
SELM1:        DB    046H, 03aH, 046H, 0b8H, 0b7H, 09eH, 09eH, 0bdH, 020H, 09cH, 0a6H, 0a4H, 0a9H, CR
              ; Q: Quick disk
SELM2:        DB    051H, 03aH, 051H, 0a5H, 0a6H, 09fH, 0a9H, 020H, 09cH, 0a6H, 0a4H, 0a9H, CR
              ; C: Cassette tape
SELM3:        DB    043H, 03aH, 043H, 0a1H, 0a4H, 0a4H, 092H, 096H, 096H, 092H, 020H, 096H, 0a1H, 09eH, 092H, CR
              ; M: Monitor
SELM4:        DB    04dH, 03aH, 04dH, 0b7H, 0b0H, 0a6H, 096H, 0b7H, 09dH, CR
              ; IPL is loading
IPLM0:        DB    049H, 050H, 04cH, 020H, 0a6H, 0a4H, 020H, 0b8H, 0b7H, 0a1H, 09cH, 0a6H, 0b0H, 097H, 020H, CR
              ; Make ready CMT
IPLM1:        DB    04dH, 0a1H, 0a9H, 092H, 020H, 09dH, 092H, 0a1H, 09cH, 0bdH, 020H, 043H, 04dH, 054H, CR
              ; Make ready QD
IPLM2:        DB    04dH, 0a1H, 0a9H, 092H, 020H, 09dH, 092H, 0a1H, 09cH, 0bdH, 020H, 051H, 044H, CR
              ; Make ready FD
IPLM3:        DB    04dH, 0a1H, 0a9H, 092H, 020H, 09dH, 092H, 0a1H, 09cH, 0bdH, 020H, 046H, 044H, CR
              ; IPL is looking for a program
IPLM4:        DB    020H, 020H, 020H, 020H, 020H, 049H, 050H, 04cH, 020H, 0a6H, 0a4H, 020H, 0b8H, 0b7H, 0b7H, 0a9H, 0a6H, 0b0H, 097H, 020H, 0aaH, 0b7H, 09dH, 020H, 0a1H, 020H, 09eH, 09dH, 0b7H, 097H, 09dH, 0a1H, 0b3H, CR
              ; FD: Loading err
ERRM0:        DB    046H, 044H, 03aH, 04cH, 0b7H, 0a1H, 09cH, 0a6H, 0b0H, 097H, 020H, 092H, 09dH, 09dH, 0b7H, 09dH, CR
              ; FD: Not master
ERRM1:        DB    046H, 044H, 03aH, 04eH, 0b7H, 096H, 020H, 0b3H, 0a1H, 0a4H, 096H, 092H, 09dH, CR
              ; CMT: Loading error
ERRM2:        DB    043H, 04dH, 054H, 03aH, 04cH, 0b7H, 0a1H, 09cH, 0a6H, 0b0H, 097H, 020H, 092H, 09dH, 09dH, 0b7H, 09dH, CR
              ; QD: Loading error
ERRM3:        DB    051H, 044H, 03aH, 04cH, 0b7H, 0a1H, 09cH, 0a6H, 0b0H, 097H, 020H, 092H, 09dH, 09dH, 0b7H, 09dH, CR
              ; QD: File mode error
ERRM4:        DB    051H, 044H, 03aH, 046H, 0a6H, 0b8H, 092H, 020H, 0b3H, 0b7H, 09cH, 092H, 020H, 092H, 09dH, 09dH, 0b7H, 09dH, CR
              ; SRAM: Checksum error
ERMG12:       DB    053H, 052H, 041H, 04dH, 03aH, 043H, 098H, 092H, 09fH, 0a9H, 020H, 0a4H, 0a5H, 0b3H, 020H, 092H, 09dH, 09dH, CR
              ; ** MONITOR 9Z-504M **
MONMSG:       DB    "**  MONITOR 9Z-504MA **", CR
              ; Filename?
MSGV0:        DB    046H, 0a6H, 0b8H, 092H, 0b0H, 0a1H, 0b3H, 092H, 03fH, 020H, CR
              ; Top address?
MSGTA:        DB    054H, 0b7H, 09eH, 020H, 0a1H, 09cH, 09dH, 0a4H, 03fH, 020H, CR
              ; Exc address?
MSGEA:        DB    045H, 0b0H, 09cH, 020H, 0a1H, 09cH, 09dH, 0a4H, 03fH, 020H, CR
              ; End address?
MSGXA:        DB    045H, 09bH, 09fH, 020H, 0a1H, 09cH, 09dH, 0a4H, 03fH, 020H, CR
              ; Loading
MSGLD:        DB    04cH, 0b7H, 0a1H, 09cH, 0a6H, 0b0H, 097H, 020H, CR

              ;
              ;
              ; Initialization tables for PIO
              ;
TPIO:         DB    0,0CFH,3FH,7                                 
              DB    0,0CFH,0,7                                   
              ;
              ; Initialization table for PAL
              ;
TBLACK:       DB    0,10H,20H,30H,40H                            

              ;----------------------------------------------------
              ;
              ; Monitoring displays for QD
              ;
              ;----------------------------------------------------
QQL:                                                             
              CALL  JEF27                                        
              JR    C,JEEE0                                      
              CALL  QFNAME                                       
              CALL  JF25F                                        
              LD    DE,MSGLD                                     
              RST   18H                                          
JEEB6:                                                           
              CALL  JEEF7                                        
              JR    C,JEEE0                                      
              LD    A,(HEAD)                                     
              CP    1                                            
              JR    NZ,JEEB6                                     
JEEC2:                                                           
              LD    DE,FNAME                                     
              RST   18H                                          
              LD    HL,MGBASE                                    
              JR    JEECE                                         
              ;
              LD    HL,(ENTRY)                                   
JEECE:                                                           
              LD    (M1132),HL                                   
              LD    HL,(BEGIN)                                   
              LD    (M1134),HL                                   
              LD    HL,103H                                      
              LD    (M1130),HL                                   
              CALL  @QDISK                                       
JEEE0:                                                           
              JR    C,JEF31                                      
              LD    BC,300H                                      
              EXX                                                
              LD    HL,BEGIN                                     
              JP    QGOPGM                                       
              ;
JEEEC:                                                           
              XOR   A                                            
              LD    (M1144),A                                    
              LD    (M113F),A                                    
              LD    (M1141),A                                    
              RET                                                
              ;
JEEF7:                                                           
              LD    HL,3                                         
              LD    (M1130),HL                                   
              LD    HL,HEAD                                      
              LD    (M1132),HL                                   
              LD    HL,40H                                       
              LD    (M1134),HL                                   
JEF09:                                                           
              CALL  @QDISK                                       
              RET   C                                            
              LD    A,(IOBUF)                                    
              CP    0DH                                          
              RET   Z                                            
              LD    HL,IOBUF                                     
              LD    DE,FNAME                                     
              LD    B,11H                                        
JEF1B:                                                           
              LD    A,(DE)                                       
              CP    (HL)                                          
              JR    NZ,JEF09                                     
              CP    0DH                                          
              RET   Z                                            
              INC   DE                                           
              INC   HL                                           
              DJNZ  JEF1B                                        
              RET                                                
              ;
JEF27:                                                           
              XOR   A                                            
              LD    (M1131),A                                    
              JP    JEFE6                                        
              ;
QQS:                                                             
              CALL  JEFE1                                        
JEF31:                                                           
              JR    C,JEF92                                      
              CALL  QFNAME                                       
              LD    A,(IOBUF)                                    
              CP    0DH                                          
              JR    Z,QQS                                        
              LD    HL,IOBUF                                     
              LD    DE,FNAME                                     
              LD    BC,11H                                       
              LDIR                                               
              CALL  QTOPA                                        
              LD    (ENTRY),HL                                   
              CALL  QENDA                                        
              OR    A                                            
              LD    BC,(ENTRY)                                   
              SBC   HL,BC                                        
              INC   HL                                           
              LD    (BEGIN),HL                                   
              CALL  QEXCA                                        
              LD    (RDCRC),HL                                   
              LD    A,1                                          
              LD    (HEAD),A                                     
              CALL  JEF9F                                        
              JR    C,JEF92                                      
              CP    28H                                          
              JP    NZ,JF202                                      
              LD    HL,(ENTRY)                                   
JEF74:                                                           
              LD    (M1136),HL                                   
              LD    HL,404H                                      
              LD    (M1130),HL                                   
              LD    HL,HEAD                                      
              LD    (M1132),HL                                   
              LD    HL,40H                                       
              LD    (M1134),HL                                   
              LD    HL,(BEGIN)                                   
              LD    (M1138),HL                                   
              CALL  @QDISK                                       
JEF92:                                                           
              JP    C,JF028                                      
QOKT:                                                            
              CALL  @IFNL?                                       
              LD    DE,TTYP                                      
              RST   18H                                          
              JP    QPRMPT                                       
              ;
JEF9F:                                                            
              CALL  JF25F                                        
              LD    HL,3                                         
              LD    (M1130),HL                                   
              LD    HL,IOBUF                                     
              LD    (M1132),HL                                   
              LD    HL,40H                                       
              LD    (M1134),HL                                   
              XOR   A                                            
              LD    (M113C),A                                    
JEFB8:                                                           
              LD    A,(M113C)                                    
              INC   A                                            
              CP    21H                                          
              LD    (M113C),A                                    
              LD    A,33H                                        
              RET   NC                                           
              CALL  @QDISK                                       
              CCF                                                
              RET   NC                                           
              LD    DE,11A4H                                      
              LD    HL,FNAME                                     
              LD    B,11H                                        
JEFD1:                                                           
              LD    A,(DE)                                       
              CP    (HL)                                         
              JR    NZ,JEFB8                                     
              CP    0DH                                          
              JR    Z,JEFDD                                      
              INC   DE                                           
              INC   HL                                           
              DJNZ  JEFD1                                        
JEFDD:                                                           
              LD    A,2AH                                        
              SCF                                                
              RET                                                
              ;
JEFE1:                                                           
              LD    A,0FFH                                       
              LD    (M1131),A                                    
JEFE6:                                                           
              LD    A,1                                          
              LD    (M1130),A                                    
              CALL  @QDISK                                       
              RET                                                
              ;
QQD:                                                             
              CALL  JEF27                                        
              JR    C,JF028                                      
              CALL  JF25F                                        
              LD    B,0                                          
              CALL  @IFNL?                                       
              LD    DE,DIRMSG                                     
              RST   18H                                          
              LD    HL,DIRQD                                     
JF003:                                                           
              LD    (M1132),HL                                   
              LD    HL,3                                         
              LD    (M1130),HL                                   
              LD    HL,40H                                       
              LD    (M1134),HL                                   
              PUSH  BC                                            
              CALL  @QDISK                                       
              POP   BC                                           
              JR    C,JF023                                      
              INC   B                                            
              LD    HL,(M1132)                                   
              LD    DE,12H                                       
              ADD   HL,DE                                        
              JR    JF003                                        
              ;
JF023:                                                           
              CP    28H                                          
              JR    Z,JF02B                                      
              SCF                                                
JF028:                                                           
              JP    C,JF0C9                                      
JF02B:                                                           
              LD    A,6                                          
              LD    (M1130),A                                    
              PUSH  BC                                           
              CALL  @QDISK                                       
              POP   BC                                            
              XOR   A                                            
              CP    B                                            
              JR    NC,JF0B2                                     
              CALL  @IFNL?                                       
              LD    HL,DIRQD                                     
JF03F:                                                           
              LD    A,(HL)                                       
              LD    DE,TTYP+1*4                                  
              DEC   A                                            
              JR    Z,JF07C                                      
              LD    DE,TTYP+2*4                                  
              DEC   A                                            
              JR    Z,JF07C                                      
              LD    DE,TTYP+3*4                                  
              DEC   A                                            
              JR    Z,JF07C                                      
              LD    DE,TTYP+4*4                                  
              DEC   A                                            
              JR    Z,JF07C                                      
              LD    DE,TTYP+5*4                                   
              DEC   A                                            
              JR    Z,JF07C                                      
              DEC   A                                            
              JR    Z,JF079                                      
              LD    DE,TTYP+6*4                                  
              DEC   A                                            
              JR    Z,JF07C                                      
              DEC   A                                            
              JR    Z,JF079                                      
              DEC   A                                            
              JR    Z,JF079                                      
              LD    DE,TTYP+7*4                                  
              DEC   A                                            
              JR    Z,JF07C                                      
              LD    DE,TTYP+8*4                                  
              DEC   A                                            
              JR    Z,JF07C                                      
JF079:                                                           
              LD    DE,TTYP+9*4                                  
JF07C:                                                           
              PUSH  BC                                           
              LD    B,4                                          
JF07F:                                                           
              CALL  @PRNTS                                       
              DJNZ  JF07F                                        
              POP   BC                                           
              RST   18H                                          
              CALL  @PRNTS                                       
              CALL  @PRNTS                                       
              CALL  @PRNTS                                       
              LD    A,22H                                        
              CALL  @PRNTC                                       
              INC   HL                                           
              PUSH  HL                                           
              POP   DE                                           
              RST   18H                                          
              LD    A,22H                                        
              CALL  @PRNTC                                       
              CALL  @IFNL?                                       
              LD    DE,11H                                       
              ADD   HL,DE                                        
JF0A4:                                                           
              CALL  @GETKD                                       
              OR    A                                            
              JR    Z,JF0A4                                      
              CALL  BRKEY                                        
              JP    Z,QPRMPT                                     
              DJNZ  JF03F                                        
JF0B2:                                                           
              JP    QOKT                                         
              ;
QQF:                                                             
              LD    DE,0F330H                                    
              RST   18H                                          
              CALL  JF0CE                                        
              CALL  JEFE1                                        
              JR    C,JF0C9                                      
              LD    A,2                                          
              LD    (M1130),A                                    
              CALL  @QDISK                                        
JF0C9:                                                           
              JP    C,JF160                                      
              JR    JF0B2                                        
              ;
JF0CE:                                                           
              CALL  @IFNL?                                       
              LD    DE,QDCM0                                     
              RST   18H                                          
              CALL  @WNKEY                                       
              CALL  @?PONT                                      
              LD    A,0EFH                                       
JF0DD:                                                           
              LD    (HL),A                                       
              CALL  JF0EB                                        
              JR    C,JF0E8                                      
              LD    A,(HL)                                       
              XOR   0EFH                                         
              JR    JF0DD                                        
              ;
JF0E8:                                                           
              XOR   A                                            
              LD    (HL),A                                       
              RET                                                
              ;
JF0EB:                                                           
              LD    BC,6                                         
JF0EE:                                                           
              DEC   BC                                           
              LD    A,B                                          
              OR    C                                            
              RET   Z                                            
              LD    A,1                                          
              CALL  QKBD??                                       
              CP    7FH                                          
              SCF                                                
              RET   Z                                            
              LD    A,3                                          
              CALL  QKBD??                                       
              CP    0FBH                                         
              JR    Z,JF10D                                      
              LD    A,8                                          
              CALL  QKBD??                                        
              CP    7EH                                          
              JR    NZ,JF0EE                                     
JF10D:                                                           
              XOR   A                                            
              LD    (HL),A                                       
              LD    SP,NEWSP                                     
              JP    QPRMPT                                       
              ;
QKBD??:                                                          
              PUSH  HL                                           
              LD    HL,MKBOUT                                    
              LD    (HL),A                                       
              INC   HL                                           
JF11B:        LD    A,(HL)                                       
              PUSH  AF                                           
              PUSH  BC                                           
              LD    B,14H                                        
JF120:                                                           
              CALL  @D1200                                       
              DJNZ  JF120                                        
              POP   BC                                            
              POP   AF                                           
              CP    (HL)                                         
              JR    NZ,JF11B                                     
              POP   HL                                           
              RET                                                
              ;
QQC:                                                             
              CALL  JEF27                                        
              JR    C,JF160                                      
              CALL  QFNAME                                       
              LD    A,(IOBUF)                                    
              CP    0DH                                          
              JR    Z,QQC                                        
              CALL  JF25F                                        
              LD    DE,MSGLD                                     
              RST   18H                                          
              CALL  JEEF7                                        
              JR    C,JF160                                      
              LD    DE,FNAME                                     
              RST   18H                                          
              LD    HL,MGBASE                                    
              LD    (M1132),HL                                   
              LD    HL,(BEGIN)                                   
              LD    (M1134),HL                                   
              LD    HL,103H                                      
              LD    (M1130),HL                                   
              CALL  @QDISK                                       
JF160:                                                           
              JR    C,JF183                                      
              CALL  @BELL                                        
              CALL  @IFNL?                                       
              LD    DE,QDQCM                                     
              RST   18H                                          
              LD    A,2                                          
              LD    (M113A),A                                    
              LD    HL,0F16CH                                    
              LD    SP,NEWSP-2                                   
              EX    (SP),HL                                      
              CALL  JF0CE                                        
JF17B:                                                            
              CALL  JEFE1                                        
              JR    C,JF183                                      
              CALL  JEF9F                                        
JF183:                                                           
              JP    C,JF202                                      
              CP    28H                                          
              JP    NZ,JF202                                     
              LD    HL,MGBASE                                    
              JP    JEF74                                        
              ;
@WNKEY:                                                          
              LD    B,0AH                                        
JF193:                                                           
              LD    HL,MKBOUT                                    
              DEC   B                                            
              LD    (HL),B                                       
              INC   B                                            
              INC   HL                                           
              LD    A,(HL)                                       
              CP    0FFH                                         
              JR    NZ,@WNKEY                                     
              DJNZ  JF193                                        
              RET                                                
              ;
QQX:                                                             
              CALL  @RFILE                                       
              JP    C,CMTERR                                     
              EXX                                                
              LD    (BEGIN),HL                                   
              CALL  @BELL                                        
JF1AF:                                                           
              CALL  QFNAME                                       
              LD    A,(IOBUF)                                    
              CP    0DH                                          
              JR    Z,JF1AF                                      
              LD    HL,IOBUF                                     
              LD    DE,FNAME                                     
              LD    BC,11H                                       
              LDIR                                               
              CALL  @IFNL?                                       
              LD    DE,QDQCM                                     
              RST   18H                                           
              LD    A,(HEAD)                                     
              CP    4                                            
              JR    Z,JF1D8                                      
              CP    5                                            
              JR    NZ,JF1DC                                     
              DEC   A                                            
              DEC   A                                            
JF1D8:                                                           
              DEC   A                                            
              LD    (HEAD),A                                     
JF1DC:                                                           
              LD    HL,112EH                                     
              LD    DE,1130H                                     
              LD    BC,2DH                                       
              LDDR                                               
              LD    HL,0                                         
              LD    (FSIZE),HL                                   
              LD    A,2                                          
              LD    (M113A),A                                    
              LD    HL,0F1EDH                                    
              LD    SP,NEWSP-2                                   
              EX    (SP),HL                                      
              CALL  JF0CE                                        
              CALL  JEEEC                                        
              JP    JF17B                                        
              ;
JF202:                                                           
              LD    DE,0F290H                                    
              CP    28H                                          
              JR    Z,JF244                                      
              LD    DE,MGBDE                                     
              CP    39H                                          
              JR    Z,JF244                                      
              LD    DE,MGWPT                                     
              CP    2EH                                          
              JR    Z,JF244                                      
              LD    DE,MGNRE                                     
              CP    32H                                          
              JR    Z,JF244                                      
              LD    DE,MGNSE                                      
              CP    35H                                          
              JR    Z,JF244                                      
              LD    DE,MGUFE                                     
              CP    36H                                          
              JR    Z,JF244                                      
              LD    DE,MGALE                                     
              CP    2AH                                          
              JR    Z,JF244                                      
              LD    DE,MGTME                                     
              CP    33H                                          
              JR    Z,JF244                                      
              LD    DE,MGBRK                                     
              CP    0                                            
              JR    Z,JF244                                      
              LD    DE,MGHDE                                     
JF244:                                                           
              LD    A,6                                          
              LD    (M1130),A                                    
              CALL  @QDISK                                       
              CALL  JF25F                                         
              LD    A,(M113A)                                    
              RRA                                                
              RET   C                                            
              PUSH  AF                                           
              CALL  @IFNL?                                       
              RST   18H                                          
              POP   AF                                           
              RRA                                                
              RET   C                                            
              JP    QPRMPT                                       
              ;
JF25F:                                                           
              LD    A,5                                          
              LD    (M1130),A                                    
              CALL  @QDISK                                       
              RET                                                
              ;
              ; Program type table.
              ;
TTYP:         DB   "OK!"                                         
              DB   0DH                                           
              DB   "OBJ"                                         
              DB   0DH                                            
              DB   "BTX"                                         
              DB   0DH                                           
              DB   "BSD"                                         
              DB   0DH                                           
              DB   "BRD"                                         
              DB   0DH                                           
              DB   "RB "                                         
              DB   0DH                                           
              DB   "LIB"                                         
              DB   0DH                                           
              DB   "SYS"                                         
              DB   0DH                                           
              DB   "GR "                                         
              DB   0DH                                           
              DB   "???"                                         
              DB   0DH                                           

              ; QD: File not found
MGNFE:        DB   051H, 044H, 03aH, 046H, 0a6H, 0b8H, 092H, 020H, 0b0H, 0b7H, 096H, 020H, 0aaH, 0b7H, 0a5H, 0b0H, 09cH, CR
              ; QD: Too many files
MGTME:        DB   051H, 044H, 03aH, 054H, 0b7H, 0b7H, 020H, 0b3H, 0a1H, 0b0H, 0bdH, 020H, 0aaH, 0a6H, 0b8H, 092H, 0a4H, 020H, 092H, 09dH, 09dH, CR
              ; QD: Hard err
MGHDE:        DB   051H, 044H, 03aH, 048H, 0a1H, 09dH, 09cH, 020H, 092H, 09dH, 09dH, CR
              ; Already exist err
MGALE:        DB   041H, 0b8H, 09dH, 092H, 0a1H, 09cH, 0bdH, 020H, 092H, 09bH, 0a6H, 0a4H, 096H, 020H, 092H, 09dH, 09dH, CR
              ; QD: Write protect
MGWPT:        DB   051H, 044H, 03aH, 057H, 09dH, 0a6H, 096H, 092H, 020H, 09eH, 09dH, 0b7H, 096H, 092H, 09fH, 096H, CR
              ; QD: Not ready
MGNRE:        DB   051H, 044H, 03aH, 04eH, 0b7H, 096H, 020H, 09dH, 092H, 0a1H, 09cH, 0bdH, CR
              ; QD: No file space
MGNSE:        DB   051H, 044H, 03aH, 04eH, 0b7H, 020H, 0aaH, 0a6H, 0b8H, 092H, 020H, 0a4H, 09eH, 0a1H, 09fH, 092H, 020H, 092H, 09dH, 09dH, CR
              ; QD: Unformat err
MGUFE:        DB   051H, 044H, 03aH, 055H, 0b0H, 0aaH, 0b7H, 09dH, 0b3H, 0a1H, 096H, 020H, 092H, 09dH, 09dH, CR
              ; QD: Bad disk err
MGBDE:        DB   051H, 044H, 03aH, 042H, 0a1H, 09cH, 020H, 09cH, 0a6H, 0a4H, 0a9H, 020H, 092H, 09dH, 09dH, CR
              ; BreakT
MGBRK:        DB   042H, 09dH, 092H, 0a1H, 0a9H, 021H, CR
              ; QD: Formatting
QDFMG:        DB   051H, 044H, 03aH, 046H, 0b7H, 09dH, 0b3H, 0a1H, 096H, 096H, 0a6H, 0b0H, 097H, CR
              ; Set destination disk
QDQCM:        DB   053H, 092H, 096H, 020H, 09cH, 092H, 0a4H, 096H, 0a6H, 0b0H, 0a1H, 096H, 0a6H, 0b7H, 0b0H, 020H, 09cH, 0a6H, 0a4H, 0a9H, CR
              ; OK? (Y / N)
QDCM0:        DB   04fH, 04bH, 03fH, 028H, 059H, 02fH, 04eH, 029H, CR
              ; Directory of QD:
DIRMSG:       DB   044H, 0a6H, 09dH, 092H, 09fH, 096H, 0b7H, 09dH, 0bdH, 020H, 0b7H, 0aaH, 020H, 051H, 044H, 03aH, CR
                                                                 
              ;
              ALIGN 0F380H
              ;
JF380:                                                           
              LD    A,0C0H                                       
              OUT   (0F6H),A                                     
              RET                                                

              ALIGN 0F400H
              ;
              ;
              ; EQU table, they are described in detail
              ; in the lower monitor
              ;
INTSRQ:       EQU   01038H                                       
INTADR:       EQU   01039H                                       
HEAD:         EQU   010F0H                                       
NEWSP:        EQU   HEAD                                         
FNAME:        EQU   010F1H                                       
FSIZE:        EQU   01102H                                       
BEGIN:        EQU   01104H                                        
ENTRY:        EQU   01106H                                       
RDCRC:        EQU   01108H                                       
RDADR:        EQU   0110AH                                       
MGBASE:       EQU   01200H                                       
OLDSP:        EQU   01148H                                       
CONMOD:       EQU   01170H                                       
CURSOR:       EQU   01171H                                       
CURCH:        EQU   01192H                                       
CSRH:         EQU   01194H                                       
TMLONG:       EQU   01195H                                       
MGCRC:        EQU   01197H                                       
MGCRCV:       EQU   01199H                                       
AMPM:         EQU   0119BH                                       
EIFLG:        EQU   0119CH                                       
BPFLG:        EQU   0119DH                                       
TEMPO:        EQU   0119EH                                       
OKTNUM:       EQU   011A0H                                       
FREQ:         EQU   011A1H                                       
IOBUF:        EQU   011A3H                                       
              ;
              ; Variables for working with QD:
              ;
M1130:        EQU   01130H                                       
M1131:        EQU   01131H                                       
M1132:        EQU   01132H                                       
M1134:        EQU   01134H                                       
M1136:        EQU   01136H                                       
M1138:        EQU   01138H                                       
M113A:        EQU   0113AH                                       
M113C:        EQU   0113CH                                       
M113D:        EQU   0113DH                                       
M113E:        EQU   0113EH                                       
M113F:        EQU   0113FH                                       
M1140:        EQU   01140H                                       
M1141:        EQU   01141H                                       
M1142:        EQU   01142H                                       
M1143:        EQU   01143H                                       
M1144:        EQU   01144H                                       
M1145:        EQU   01145H                                       
              ;
DIRQD:        EQU   0CD90H                      ; buffer for QD directory
              ;
              ; Variables used by FD subroutines
              ;
FDCB:         EQU   0CEE9H                      ; FD parameter block
FDCMD:        EQU   0CEF4H                      ; last view of the controller
FDON?:        EQU   0CEF5H                      ; mechanic on flag
TFDRES:       EQU   0CEF6H                      ; table of mounted disks
FDSTAT:       EQU   0CEFBH                      ; status read last
FDARET:       EQU   0CEFEH                      ; return address in case of error
FDHEAD:       EQU   0CF00H                      ; program header on FD
              ;
              ; BINDINGS HORNI ==M DOLNI
              ;
SCHECK:       EQU   0147H                                        
@2HEX:        EQU   041FH                                        
@??KEY:       EQU   09B3H                                        
@?ADCN:       EQU   0BB9H                                        
@?BLNK:       EQU   0DA6H                                        
@?DACN:       EQU   0BCEH                                        
@?DPCT:       EQU   0DDCH                                        
@?PONT:       EQU   0FB1H                                        
@ASC:         EQU   03DAH                                        
@BELL:        EQU   003EH                                        
@BRKEY:       EQU   001EH                                        
@IFNL?:       EQU   0009H                                        
IFNL?:        EQU   0918H                                        
@GETKY:       EQU   001BH                                        
@GETL:        EQU   0003H                                        
@HEX:         EQU   03F9H                                        
@HLHEX:       EQU   0410H                                        
@LETNL:       EQU   0006H                                        
@MELDY:       EQU   0030H                                        
@MSG:         EQU   0015H                                        
@MSTA:        EQU   0044H                                        
@MSTP:        EQU   0047H                                        
@PRNTC:       EQU   0012H                                        
@PRNTS:       EQU   000CH                                        
@TIMRD:       EQU   003BH                                        
@TIMST:       EQU   0033H                                        
@XTEMP:       EQU   0041H                                        
@RHEAD:       EQU   0027H                                        
@RDATA:       EQU   002AH                                        
GORAM:        EQU   005BH                                        
@IC4DE:       EQU   02A6H                                        
MSTP:         EQU   02BEH                                        
TIMST:        EQU   0308H                                        
@MHEX:        EQU   03B1H                                        
WHEAD:        EQU   0436H                                        
WDATA:        EQU   0475H                                        
RHEAD:        EQU   04D8H                                        
RDATA:        EQU   04F8H                                        
BEEP:         EQU   0577H                                        
VERIF:        EQU   0588H                                        
VERIF1:       EQU   0593H                                        
@?NLHL:       EQU   05FAH                                        
@INI55:       EQU   073EH                                        
@GETKD:       EQU   08CAH                                        
PRNTS:        EQU   0920H                                        
PRNTA:        EQU   096CH                                        
@FILLA:       EQU   09D5H                                        
BRKEY:        EQU   0A32H                                        
@F0B:         EQU   0FD8H                    ; END MARKER
              END                                                                                                                                                                                                                  


