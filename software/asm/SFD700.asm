; ROM of K&P SFD700 interface

; data areas

; 1000 1 Latest FDC command byte 
; 1001 1 Motor on flag, 01 = on, 00 = off 
; 1002 4 Track 0 flags for each drive ( 1 to 4 ) 
; 1006 1 Retry count 
; 1007 1 Not sure of this one? 
; 1008 1 Drive Number ( 0 to 3 ) 
; 1009 2 Logical Sector Number ( 0 to 1119 ) 
; 100B 1 Bytes to read (after all sectors are read)
; 100C 1 Number of sectors to read
; or
; 100B 2 Bytes to read
; 100D 2 Memory Load address 
; 100F 1 Current track No. ( 0 to 69 ) 
; 1010 1 Current Sector No. ( 1 to 16 ) 
; 1011 1 Start track No. ( 0 to 69 ) 
; 1012 1 Start Sector No. ( 1 to 16 )


; Controller register
; $D8	; Command Register (write)
; $D8	; Status Register (read)
; $D9	; Track Register (write)
: $DA	; Sector Register (write)
: $DB	; Data Register	(read/write)
; $DC	; Drive/Motor select (write)
; $DD	; Side/Head select (write)


f000 00        NOP     			;ID for interface detection
f001 110810    LD      DE,1008H		;nach
f004 21DDF0    LD      HL,0F0DDH	;von
f007 010B00    LD      BC,000BH		;11 bytes 00 00 00 00 01 00 CE 00 00 00 00
f00a EDB0      LDIR    			;BC=0, HL=F0E8, DE=1013
f00c CD51F1    CALL    0F151H		;init 1001-1005, port $DC mit $00
f00f CD0900    CALL    0009H		;NL
f012 11A1F0    LD      DE,0F0A1H	;msg BOOT DRIVE?
f015 CD1500    CALL    0015H		;prt
f018 11A311    LD      DE,11A3H		;kbd buffer
f01b CD0300    CALL    0003H		;get line
f01e 1A        LD      A,(DE)		;get 1st char
f01f FE1B      CP      1BH		;brk?
f021 CA8900    JP      Z,0098H		;yes
f024 210C00    LD      HL,000CH
f027 19        ADD     HL,DE		;skip around msg, 11A3+0C=11AF
f028 7E        LD      A,(HL)		;get char
f029 FE0D      CP      0DH		;CR?
f02b 280D      JR      Z,0F03AH		;yes, default drive 1
f02d CDF903    CALL    03F9H		;ASCII to hex (A)
f030 38DD      JR      C,0F00FH		;nohex, error, again
f032 3D        DEC     A		;-1
f033 FE04      CP      04H		;drive >4?
f035 30D8      JR      NC,0F00FH	;error, again
f037 320810    LD      (1008H),A	;save drive no -1 (0 to 3)
f03a DD210810  LD      IX,1008H		;drive no
f03e CDBAF1    CALL    0F1BAH		;read sector 1 of trk 0
f041 2100CE    LD      HL,0CE00H	;dsk buffer
f044 11CCF0    LD      DE,0F0CCH	;=02 mst dsk flag (changed to 03)
f047 0607      LD      B,07H		;check for #02,"IPLPRO"
f049 4E        LD      C,(HL)
f04a 1A        LD      A,(DE)
f04b B9        CP      C
f04c C28CF0    JP      NZ,0F08CH	;error no master dsk	
f04f 23        INC     HL		;nxt char
f050 13        INC     DE		;nxt char
f051 10F6      DJNZ    0F049H		;nxt char
f053 CD0900    CALL    0009H		;NL
f056 11BCF0    LD      DE,0F0BCH
f059 CD1500    CALL    0015H		;msg K&P IS LOADING
f05c 1107CE    LD      DE,0CE07H
f05f CD1500    CALL    0015H		;prt prog name
f062 2A16CE    LD      HL,(0CE16H)	;load address
f065 DD7505    LD      (IX+05H),L	;to 100D/100E
f068 DD7406    LD      (IX+06H),H
f06b 2A14CE    LD      HL,(0CE14H)	;size
f06e DD7503    LD      (IX+03H),L	;to 100B/100C
f071 DD7404    LD      (IX+04H),H
f074 2A1ECE    LD      HL,(0CE1EH)	;logical sector number
f077 DD7501    LD      (IX+01H),L	;to 1009/100A
f07a DD7402    LD      (IX+02H),H
f07d CDBAF1    CALL    0F1BAH
f080 CD51F1    CALL    0F151H
f083 2A18CE    LD      HL,(0CE18H)	;exec address
f086 E9        JP      (HL)

f087 11AEF0    LD      DE,0F0AEH	;msg LOADING ERROR
f08a 1803      JR      0F08FH

f08c 11E8F0    LD      DE,0F0E8H	;msg THIS DISKETTE IS NOT MASTER
f08f CD0900    CALL    0009H
f092 CD1500    CALL    0015H
f095 CD0900    CALL    0009H
f098 11D3F0    LD      DE,0F0D3H
f09b CD3000    CALL    0030H		;play melody
f09e C3A200    JP      00A2H		;warm start

f0a1	       db      "BOOT DRIVE ?",#0D

f0ae           db      "LOADING ERROR",#0D

f0bc           db      "K&P IS LOADING ",#0D

f0cc           db      #02 ; changed to 03
f0cd           db      "IPLPRO"

;melody data
f0d3	       db      "A0",#D7,"ARA",#D7,"AR",#0D
f0dd	       db      ,#00,#00,#00,#00,#01,#00,#CE,#00,#00,#00,#00
 
f0e8           db      "THIS DISKETTE IS NOT MASTER",#0D

f104 3A0110    LD      A,(1001H)	;motor on flag
f107 0F        RRCA    			;motor off?
f108 D438F1    CALL    NC,0F138H	;yes, set motor on and wait
f10b DD7E00    LD      A,(IX+00H)	;drive no
f10e F684      OR      84H		;
f110 D3DC      OUT     (0DCH),A		;Motor on for drive 0-3
f112 AF        XOR     A
f113 320010    LD      (1000H),A	;clr latest FDC command byte
f116 210000    LD      HL,0000H
f119 2B        DEC     HL
f11a 7C        LD      A,H
f11b B5        OR      L
f11c CA9DF2    JP      Z,0F29DH		;reset and msg THIS DISKETTE IS NOT MASTER
f11f DBD8      IN      A,(0D8H)		;state reg
f121 2F        CPL     
f122 07        RLCA    
f123 38F4      JR      C,0F119H		;wait on motor off (bit 7)
f125 DD4E00    LD      C,(IX+00H)	;drive no
f128 210210    LD      HL,1002H		;1 track 0 flag for each drive
f12b 0600      LD      B,00H
f12d 09        ADD     HL,BC		;compute related flag 1002/1003/1004/1005
f12e CB46      BIT     0,(HL)		;
f130 2005      JR      NZ,0F137H	;no
f132 CD64F1    CALL    0F164H		;
f135 CBC6      SET     0,(HL)		;set bit 0 of trk 0 flag
f137 C9        RET     

;motor on
f138 3E80      LD      A,80H
f13a D3DC      OUT     (0DCH),A		;Motor on
f13c 0610      LD      B,10H		
f13e CDC7F2    CALL    0F2C7H		;wait loop2
f141 10FB      DJNZ    0F13EH		;16 times
f143 3E01      LD      A,01H
f145 320110    LD      (1001H),A	;motor on flag on
f148 C9        RET     

;command 1b output
f149 3E1B      LD      A,1BH		;1x = SEEK
f14b CD71F1    CALL    0F171H		;command 1b output
f14e E699      AND     99H
f150 C9        RET     

;init/reset flags, set motor off
f151 AF        XOR     A
f152 D3DC      OUT     (0DCH),A		;Motor on/off
f154 320210    LD      (1002H),A	;track 0 flag drive 1
f157 320310    LD      (1003H),A	;track 0 flag drive 2
f15a 320410    LD      (1004H),A	;track 0 flag drive 3
f15d 320510    LD      (1005H),A	;track 0 flag drive 4
f160 320110    LD      (1001H),A	:motor on flag
f163 C9        RET     

f164 3E0B      LD      A,0BH		;0x = RESTORE (seek track 0)
f166 CD71F1    CALL    0F171H
f169 E685      AND     85H		;
f16b EE04      XOR     04H		;
f16d C8        RET     Z		;
f16e F3        DI      
f16f 9D        SBC     A,L
f170 C23200    JP      NZ,0032H		;???

f171 320010    ld      (1000H),a	;latest FDC command 0b/1b

f173 2F        CPL			;f4/e4
f175 D3D8      OUT     (0D8H),A		;Command reg
f177 CD7EF1    CALL    0F17EH		;wait on ready
f17a DBD8      IN      A,(0D8H)		;state reg
f17c 2F        CPL
f17d C9        RET     

;Wait on ready
f17e D5        PUSH    DE
f17f E5        PUSH    HL
f180 CDC0F2    CALL    0F2C0H		;wait loop1
f183 1E07      LD      E,07H
f185 210000    LD      HL,0000H
f188 2B        DEC     HL
f189 7C        LD      A,H
f18a B5        OR      L
f18b 2809      JR      Z,0F196H
f18d DBD8      IN      A,(0D8H)		;state reg
f18f 2F        CPL     
f190 0F        RRCA    
f191 38F5      JR      C,0F188H		;wait on busy (bit 0)
f193 E1        POP     HL
f194 D1        POP     DE
f195 C9        RET     

f196 1D        DEC     E
f197 20EC      JR      NZ,0F185H
f199 C39DF2    JP      0F29DH

;wait on bit1=0 of state reg
f19c D5        PUSH    DE
f19d E5        PUSH    HL
f19e CDC0F2    CALL    0F2C0H		;wait loop1
f1a1 1E07      LD      E,07H		;init next wait loop
f1a3 210000    LD      HL,0000H
f1a6 2B        DEC     HL
f1a7 7C        LD      A,H
f1a8 B5        OR      L
f1a9 2809      JR      Z,0F1B4H
f1ab DBD8      IN      A,(0D8H)		;state reg
f1ad 2F        CPL     
f1ae 0F        RRCA    
f1af 30F5      JR      NC,0F1A6H	;wait on not busy (bit 0)
f1b1 E1        POP     HL
f1b2 D1        POP     DE
f1b3 C9        RET     

f1b4 1D        DEC     E
f1b5 20EC      JR      NZ,0F1A3H	;wait loop
f1b7 C39DF2    JP      0F29DH

f1ba CD20F2    CALL    0F220H	;compute logical sector-no to track-no & sector-no, retries=10
f1bd CD29F2    CALL    0F229H	;set current track & sector, get load address to HL
f1c0 CD49F2    CALL    0F249H	;set side reg
f1c3 CD49F1    CALL    0F149H	;command 1b output (seek)
f1c6 204E      JR      NZ,0F216H	;
f1c8 CD59F2    CALL    0F259H		;set track & sector reg
f1cb DDE5      PUSH    IX		;save 1008
f1cd DD2100F3  LD      IX,0F300H
f1d1 FD21DFF1  LD      IY,0F1DFH	;ret addr
f1d5 F3        DI      
f1d6 3E94      LD      A,94H		;latest FDC command byte
f1d8 CD8AF2    CALL    0F28AH		;set command reg, wait ready
f1db 0600      LD      B,00H
f1dd DDE9      JP      (IX)		;to F300 & return to f1df

;get chars from disk sector to area beginning at CE00
f1df EDA2      INI     
f1e1 C200F3    JP      NZ,0F300H
f1e4 DDE1      POP     IX
f1e6 DD3408    INC     (IX+08H)		;current sector number
f1e9 DD7E08    LD      A,(IX+08H)	;current sector number
f1ec DDE5      PUSH    IX		;save 1008
f1ee DD2100F3  LD      IX,0F300H
f1f2 FE11      CP      11H		;sector 17?
f1f4 2805      JR      Z,0F1FBH
f1f6 15        DEC     D
f1f7 20E2      JR      NZ,0F1DBH
f1f9 1801      JR      0F1FCH

f1fb 15        DEC     D
f1fc CD94F2    CALL    0F294H
f1ff CDD2F2    CALL    0F2D2H
f202 DDE1      POP     IX		;1008
f204 DBD8      IN      A,(0D8H)		;state reg
f206 2F        CPL     
f207 E6FF      AND     0FFH
f209 200B      JR      NZ,0F216H
f20b CD78F2    CALL    0F278H
f20e CA1BF2    JP      Z,0F21BH		;if D=0
f211 DD7E07    LD      A,(IX+07H)	;current track no
f214 18AA      JR      0F1C0H

;
f216 CD6AF2    CALL    0F26AH
f219 18A2      JR      0F1BDH

f21b 3E80      LD      A,80H
f21d D3DC      OUT     (0DCH),A		;Motor on
f21f C9        RET     

f220 CDA3F2    CALL    0F2A3H		;compute logical sector no to track no & sector no
f223 3E0A      LD      A,0AH
f225 320610    LD      (1006H),A	;10 retries
f228 C9        RET     

;set current track & sector, get load address to HL
f229 CD04F1    CALL    0F104H
f22c DD5604    LD      D,(IX+04H)	;number of sectors to read
f22f DD7E03    LD      A,(IX+03H)	;bytes to read
f232 B7        OR      A		;0?
f233 2801      JR      Z,0F236H		;yes
f235 14        INC     D		;number of sectors to read + 1
f236 DD7E0A    LD      A,(IX+0AH)	;start sector number
f239 DD7708    LD      (IX+08H),A	;to current sector number
f23c DD7E09    LD      A,(IX+09H)	;start track number
f23f DD7707    LD      (IX+07H),A	;to current track number
f242 DD6E05    LD      L,(IX+05H)	;load address low byte
f245 DD6606    LD      H,(IX+06H)	;load address high byte
f248 C9        RET     

;compute side/head
f249 CB3F      SRL     A		;track number even?
f24b 2F        CPL     			;
f24c D3DB      OUT     (0DBH),A		;output track no
f24e 3004      JR      NC,0F254H	;yes, even, set side/head 0
f250 3E01      LD      A,01H		;no, odd, set side/head 1
f252 1801      JR      0F255H

;set side/head reg
f254 AF        XOR     A
f255 2F        CPL     			;
f256 D3DD      OUT     (0DDH),A		;side/head reg
f258 C9        RET     

;set track & sector reg
f259 0EDB      LD      C,0DBH
f25b DD7E07    LD      A,(IX+07H)	;current track number
f25e CB3F      SRL     A		;
f260 2F        CPL     			;
f261 D3D9      OUT     (0D9H),A		;track reg
f263 DD7E08    LD      A,(IX+08H)	;current sector number
f266 2F        CPL     			;
f267 D3DA      OUT     (0DAH),A		;sector reg
f269 C9        RET     

f26a 3A0610    LD      A,(1006H)	;retry count - 1
f26d 3D        DEC     A
f26e 320610    LD      (1006H),A	;retry count
f271 CA9DF2    JP      Z,0F29DH
f274 CD64F1    CALL    0F164H
f277 C9        RET     

f278 DD7E08    LD      A,(IX+08H)	;current sector number
f27b FE11      CP      11H
f27d 2008      JR      NZ,0F287H	;no, not 17
f27f 3E01      LD      A,01H
f281 DD7708    LD      (IX+08H),A	;current sector number = 1
f284 DD3407    INC     (IX+07H)		;current track number + 1
f287 7A        LD      A,D
f288 B7        OR      A		;
f289 C9        RET     

;output to command reg and wait on ready
f28a 320010    LD      (1000H),A	;latest FDC command byte
f28d 2F        CPL     
f28e D3D8      OUT     (0D8H),A		;command reg
f290 CD9CF1    CALL    0F19CH		;wait on not busy
f293 C9        RET     

:force interrupt
f294 3ED8      LD      A,0D8H		;force interrupt code
f296 2F        CPL     
f297 D3D8      OUT     (0D8H),A		;force interrupt
f299 CD7EF1    CALL    0F17EH
f29c C9        RET     

f29d CD51F1    CALL    0F151H		;reset flags
f2a0 C387F0    JP      0F087H		;loading error

; compute logical sector no to physical track no and sector no
f2a3 0600      LD      B,00H
f2a5 111000    LD      DE,0010H		;no of sectors per trk (16)
f2a8 DD6E01    LD      L,(IX+01H)	;logical sector number
f2ab DD6602    LD      H,(IX+02H)	;2 bytes in length
f2ae AF        XOR     A
f2af ED52      SBC     HL,DE		;subtract 16 sectors/trk
f2b1 3803      JR      C,0F2B6H		;yes, negative value
f2b3 04        INC     B		;count track
f2b4 18F9      JR      0F2AFH		;loop

f2b6 19        ADD     HL,DE		;reset HL to the previous
f2b7 60        LD      H,B		;track
f2b8 2C        INC     L		;correction +1
f2b9 DD7409    LD      (IX+09H),H	;start track no
f2bc DD750A    LD      (IX+0AH),L	;start sector no
f2bf C9        RET     

;wait loop1
f2c0 D5        PUSH    DE
f2c1 110700    LD      DE,0007H
f2c4 C3CBF2    JP      0F2CBH		;wait loop

; Wait loop2
f2c7 D5        PUSH    DE
f2c8 111310    LD      DE,1013H
f2cb 1B        DEC     DE		;see f2c0, value set to 0007
f2cc 7B        LD      A,E
f2cd B2        OR      D
f2ce 20FB      JR      NZ,0F2CBH	;wait loop
f2d0 D1        POP     DE
f2d1 C9        RET     

f2d2 F5        PUSH    AF
f2d3 3A9C11    LD      A,(119CH)	;time flag
f2d6 FEF0      CP      0F0H
f2d8 2001      JR      NZ,0F2DBH
f2da FB        EI      
f2db F1        POP     AF
f2dc C9        RET     


;should never be executed automatically!
f2dd 11E5F2    LD      DE,0F2E5H
f2e0 CD1500    CALL    0015H		;msg (C) 1983 F.Scheider
f2e3 1824      JR      0F309H

f2e5           db      "(C) 1983 F.Scheider ",#0D

f2f9 FF        RST     38H
f2fa FF        RST     38H
f2fb FF        RST     38H
f2fc FF        RST     38H
f2fd FF        RST     38H
f2fe FF        RST     38H
f2ff FF        RST     38H

;wait on bit 0 and bit 1 = 0 of state reg
f300 DBD8      IN      A,(0D8H)		;state reg
f302 0F        RRCA    
f303 38FB      JR      C,0F300H		;wait on not busy
f305 0F        RRCA    
f306 38F8      JR      C,0F300H		;wait on data reg ready
f308 FDE9      JP      (IY)		;to f1df


;should never be executed automatically!!
f30a 1112F3    LD      DE,0F312H
f30d CD1500    CALL    0015H		;msg Hardware: K.Minor
f310 1812      JR      0F324H

f312           db      "Hardware: K.Minor",#0D


;should never be executed automatically!!
f324 112CF3    LD      DE,0F32CH
f327 CD1500    CALL    0015H		;msg K&P,West Germany
f32a 18B1      JR      0F2DDH

f32c           db      "K&P,West Germany ",#0D

f33e FF        RST     38H
f33f FF        RST     38H
f340 FF        RST     38H
f341 FF        RST     38H
f342 FF        RST     38H
f343 FF        RST     38H
f344 FF        RST     38H
f345 FF        RST     38H
f346 FF        RST     38H
f347 FF        RST     38H
f348 FF        RST     38H
f349 FF        RST     38H
f34a FF        RST     38H
f34b FF        RST     38H
f34c FF        RST     38H
f34d FF        RST     38H
f34e FF        RST     38H
f34f FF        RST     38H
f350 FF        RST     38H
f351 FF        RST     38H
f352 FF        RST     38H
f353 FF        RST     38H
f354 FF        RST     38H
f355 FF        RST     38H
f356 FF        RST     38H
f357 FF        RST     38H
f358 FF        RST     38H
f359 FF        RST     38H
f35a FF        RST     38H
f35b FF        RST     38H
f35c FF        RST     38H
f35d FF        RST     38H
f35e FF        RST     38H
f35f FF        RST     38H
f360 FF        RST     38H
f361 FF        RST     38H
f362 FF        RST     38H
f363 FF        RST     38H
f364 FF        RST     38H
f365 FF        RST     38H
f366 FF        RST     38H
f367 FF        RST     38H
f368 FF        RST     38H
f369 FF        RST     38H
f36a FF        RST     38H
f36b FF        RST     38H
f36c FF        RST     38H
f36d FF        RST     38H
f36e FF        RST     38H
f36f FF        RST     38H
f370 FF        RST     38H
f371 FF        RST     38H
f372 FF        RST     38H
f373 FF        RST     38H
f374 FF        RST     38H
f375 FF        RST     38H
f376 FF        RST     38H
f377 FF        RST     38H
f378 FF        RST     38H
f379 FF        RST     38H
f37a FF        RST     38H
f37b FF        RST     38H
f37c FF        RST     38H
f37d FF        RST     38H
f37e FF        RST     38H
f37f FF        RST     38H
f380 FF        RST     38H
f381 FF        RST     38H
f382 FF        RST     38H
f383 FF        RST     38H
f384 FF        RST     38H
f385 FF        RST     38H
f386 FF        RST     38H
f387 FF        RST     38H
f388 FF        RST     38H
f389 FF        RST     38H
f38a FF        RST     38H
f38b FF        RST     38H
f38c FF        RST     38H
f38d FF        RST     38H
f38e FF        RST     38H
f38f FF        RST     38H
f390 FF        RST     38H
f391 FF        RST     38H
f392 FF        RST     38H
f393 FF        RST     38H
f394 FF        RST     38H
f395 FF        RST     38H
f396 FF        RST     38H
f397 FF        RST     38H
f398 FF        RST     38H
f399 FF        RST     38H
f39a FF        RST     38H
f39b FF        RST     38H
f39c FF        RST     38H
f39d FF        RST     38H
f39e FF        RST     38H
f39f FF        RST     38H
f3a0 FF        RST     38H
f3a1 FF        RST     38H
f3a2 FF        RST     38H
f3a3 FF        RST     38H
f3a4 FF        RST     38H
f3a5 FF        RST     38H
f3a6 FF        RST     38H
f3a7 FF        RST     38H
f3a8 FF        RST     38H
f3a9 FF        RST     38H
f3aa FF        RST     38H
f3ab FF        RST     38H
f3ac FF        RST     38H
f3ad FF        RST     38H
f3ae FF        RST     38H
f3af FF        RST     38H
f3b0 FF        RST     38H
f3b1 FF        RST     38H
f3b2 FF        RST     38H
f3b3 FF        RST     38H
f3b4 FF        RST     38H
f3b5 FF        RST     38H
f3b6 FF        RST     38H
f3b7 FF        RST     38H
f3b8 FF        RST     38H
f3b9 FF        RST     38H
f3ba FF        RST     38H
f3bb FF        RST     38H
f3bc FF        RST     38H
f3bd FF        RST     38H
f3be FF        RST     38H
f3bf FF        RST     38H
f3c0 FF        RST     38H
f3c1 FF        RST     38H
f3c2 FF        RST     38H
f3c3 FF        RST     38H
f3c4 FF        RST     38H
f3c5 FF        RST     38H
f3c6 FF        RST     38H
f3c7 FF        RST     38H
f3c8 FF        RST     38H
f3c9 FF        RST     38H
f3ca FF        RST     38H
f3cb FF        RST     38H
f3cc FF        RST     38H
f3cd FF        RST     38H
f3ce FF        RST     38H
f3cf FF        RST     38H
f3d0 FF        RST     38H
f3d1 FF        RST     38H
f3d2 FF        RST     38H
f3d3 FF        RST     38H
f3d4 FF        RST     38H
f3d5 FF        RST     38H
f3d6 FF        RST     38H
f3d7 FF        RST     38H
f3d8 FF        RST     38H
f3d9 FF        RST     38H
f3da FF        RST     38H
f3db FF        RST     38H
f3dc FF        RST     38H
f3dd FF        RST     38H
f3de FF        RST     38H
f3df FF        RST     38H
f3e0 FF        RST     38H
f3e1 FF        RST     38H
f3e2 FF        RST     38H
f3e3 FF        RST     38H
f3e4 FF        RST     38H
f3e5 FF        RST     38H
f3e6 FF        RST     38H
f3e7 FF        RST     38H
f3e8 FF        RST     38H
f3e9 FF        RST     38H
f3ea FF        RST     38H
f3eb FF        RST     38H
f3ec FF        RST     38H
f3ed FF        RST     38H
f3ee FF        RST     38H
f3ef FF        RST     38H
f3f0 FF        RST     38H
f3f1 FF        RST     38H
f3f2 FF        RST     38H
f3f3 FF        RST     38H
f3f4 FF        RST     38H
f3f5 FF        RST     38H
f3f6 FF        RST     38H
f3f7 FF        RST     38H
f3f8 FF        RST     38H
f3f9 FF        RST     38H
f3fa FF        RST     38H
f3fb FF        RST     38H
f3fc FF        RST     38H
f3fd FF        RST     38H

f3fe FDE9      JP      (IY)

f400 00        NOP     
f401 FF        RST     38H
f402 00        NOP     
f403 00        NOP     
f404 FF        RST     38H
f405 FF        RST     38H
f406 00        NOP     
f407 00        NOP     
f408 FF        RST     38H
f409 FF        RST     38H
f40a 00        NOP     
f40b 00        NOP     
f40c FF        RST     38H
f40d FF        RST     38H
f40e 00        NOP     
f40f 00        NOP     
f410 FF        RST     38H
f411 FF        RST     38H
f412 00        NOP     
f413 00        NOP     
f414 FF        RST     38H
f415 FF        RST     38H
f416 00        NOP     
f417 00        NOP     
f418 FF        RST     38H
f419 FF        RST     38H
f41a 00        NOP     
f41b 00        NOP     
f41c FF        RST     38H
f41d FF        RST     38H
f41e 00        NOP     
f41f 00        NOP     
f420 FF        RST     38H
f421 FF        RST     38H
f422 00        NOP     
f423 00        NOP     
f424 FF        RST     38H
f425 FF        RST     38H
f426 00        NOP     
f427 00        NOP     
f428 FF        RST     38H
f429 FF        RST     38H
f42a 00        NOP     
f42b 00        NOP     
f42c FF        RST     38H
f42d FF        RST     38H
f42e 00        NOP     
f42f 00        NOP     
f430 FF        RST     38H
f431 FF        RST     38H
f432 00        NOP     
f433 00        NOP     
f434 FF        RST     38H
f435 FF        RST     38H
f436 00        NOP     
f437 00        NOP     
f438 FF        RST     38H
f439 FF        RST     38H
f43a 00        NOP     
f43b 00        NOP     
f43c FF        RST     38H
f43d FF        RST     38H
f43e 00        NOP     
f43f 00        NOP     
f440 FF        RST     38H
f441 FF        RST     38H
f442 00        NOP     
f443 00        NOP     
f444 FF        RST     38H
f445 FF        RST     38H
f446 00        NOP     
f447 00        NOP     
f448 FF        RST     38H
f449 FF        RST     38H
f44a 00        NOP     
f44b 00        NOP     
f44c FF        RST     38H
f44d FF        RST     38H
f44e 00        NOP     
f44f 00        NOP     
f450 FF        RST     38H
f451 FF        RST     38H
f452 00        NOP     
f453 00        NOP     
f454 FF        RST     38H
f455 FF        RST     38H
f456 00        NOP     
f457 00        NOP     
f458 FF        RST     38H
f459 FF        RST     38H
f45a 00        NOP     
f45b 00        NOP     
f45c FF        RST     38H
f45d FF        RST     38H
f45e 00        NOP     
f45f 00        NOP     
f460 FF        RST     38H
f461 FF        RST     38H
f462 00        NOP     
f463 00        NOP     
f464 FF        RST     38H
f465 FF        RST     38H
f466 00        NOP     
f467 00        NOP     
f468 FF        RST     38H
f469 FF        RST     38H
f46a 00        NOP     
f46b 00        NOP     
f46c FF        RST     38H
f46d FF        RST     38H
f46e 00        NOP     
f46f 00        NOP     
f470 FF        RST     38H
f471 FF        RST     38H
f472 00        NOP     
f473 00        NOP     
f474 FF        RST     38H
f475 FF        RST     38H
f476 00        NOP     
f477 00        NOP     
f478 FF        RST     38H
f479 FF        RST     38H
f47a 00        NOP     
f47b 00        NOP     
f47c FF        RST     38H
f47d FF        RST     38H
f47e 00        NOP     
f47f 00        NOP     
f480 FF        RST     38H
f481 FF        RST     38H
f482 00        NOP     
f483 00        NOP     
f484 FF        RST     38H
f485 FF        RST     38H
f486 00        NOP     
f487 00        NOP     
f488 FF        RST     38H
f489 FF        RST     38H
f48a 00        NOP     
f48b 00        NOP     
f48c FF        RST     38H
f48d FF        RST     38H
f48e 00        NOP     
f48f 00        NOP     
f490 FF        RST     38H
f491 FF        RST     38H
f492 00        NOP     
f493 00        NOP     
f494 FF        RST     38H
f495 FF        RST     38H
f496 00        NOP     
f497 00        NOP     
f498 FF        RST     38H
f499 FF        RST     38H
f49a 00        NOP     
f49b 00        NOP     
f49c FF        RST     38H
f49d FF        RST     38H
f49e 00        NOP     
f49f 00        NOP     
f4a0 FF        RST     38H
f4a1 FF        RST     38H
f4a2 00        NOP     
f4a3 00        NOP     
f4a4 FF        RST     38H
f4a5 FF        RST     38H
f4a6 00        NOP     
f4a7 00        NOP     
f4a8 FF        RST     38H
f4a9 FF        RST     38H
f4aa 00        NOP     
f4ab 00        NOP     
f4ac FF        RST     38H
f4ad FF        RST     38H
f4ae 00        NOP     
f4af 00        NOP     
f4b0 FF        RST     38H
f4b1 FF        RST     38H
f4b2 00        NOP     
f4b3 00        NOP     
f4b4 FF        RST     38H
f4b5 FF        RST     38H
f4b6 00        NOP     
f4b7 00        NOP     
f4b8 FF        RST     38H
f4b9 FF        RST     38H
f4ba 00        NOP     
f4bb 00        NOP     
f4bc FF        RST     38H
f4bd FF        RST     38H
f4be 00        NOP     
f4bf 00        NOP     
f4c0 FF        RST     38H
f4c1 FF        RST     38H
f4c2 00        NOP     
f4c3 00        NOP     
f4c4 FF        RST     38H
f4c5 FF        RST     38H
f4c6 00        NOP     
f4c7 00        NOP     
f4c8 FF        RST     38H
f4c9 FF        RST     38H
f4ca 00        NOP     
f4cb 00        NOP     
f4cc FF        RST     38H
f4cd FF        RST     38H
f4ce 00        NOP     
f4cf 00        NOP     
f4d0 FF        RST     38H
f4d1 FF        RST     38H
f4d2 00        NOP     
f4d3 00        NOP     
f4d4 FF        RST     38H
f4d5 FF        RST     38H
f4d6 00        NOP     
f4d7 00        NOP     
f4d8 FF        RST     38H
f4d9 FF        RST     38H
f4da 00        NOP     
f4db 00        NOP     
f4dc FF        RST     38H
f4dd FF        RST     38H
f4de 00        NOP     
f4df 00        NOP     
f4e0 FF        RST     38H
f4e1 FF        RST     38H
f4e2 00        NOP     
f4e3 00        NOP     
f4e4 FF        RST     38H
f4e5 FF        RST     38H
f4e6 00        NOP     
f4e7 00        NOP     
f4e8 FF        RST     38H
f4e9 FF        RST     38H
f4ea 00        NOP     
f4eb 00        NOP     
f4ec FF        RST     38H
f4ed FF        RST     38H
f4ee 00        NOP     
f4ef 00        NOP     
f4f0 FF        RST     38H
f4f1 FF        RST     38H
f4f2 00        NOP     
f4f3 00        NOP     
f4f4 FF        RST     38H
f4f5 FF        RST     38H
f4f6 00        NOP     
f4f7 00        NOP     
f4f8 FF        RST     38H
f4f9 FF        RST     38H
f4fa 00        NOP     
f4fb 00        NOP     
f4fc FF        RST     38H
f4fd FF        RST     38H
f4fe 00        NOP     
f4ff 00        NOP     
f500 00        NOP     
f501 00        NOP     
f502 FF        RST     38H
f503 FF        RST     38H
f504 00        NOP     
f505 00        NOP     
f506 FF        RST     38H
f507 FF        RST     38H
f508 00        NOP     
f509 00        NOP     
f50a FF        RST     38H
f50b FF        RST     38H
f50c 00        NOP     
f50d 00        NOP     
f50e FF        RST     38H
f50f FF        RST     38H
f510 00        NOP     
f511 00        NOP     
f512 FF        RST     38H
f513 FF        RST     38H
f514 00        NOP     
f515 00        NOP     
f516 FF        RST     38H
f517 FF        RST     38H
f518 00        NOP     
f519 00        NOP     
f51a FF        RST     38H
f51b FF        RST     38H
f51c 00        NOP     
f51d 00        NOP     
f51e FF        RST     38H
f51f FF        RST     38H
f520 00        NOP     
f521 00        NOP     
f522 FF        RST     38H
f523 FF        RST     38H
f524 00        NOP     
f525 00        NOP     
f526 FF        RST     38H
f527 FF        RST     38H
f528 00        NOP     
f529 00        NOP     
f52a FF        RST     38H
f52b FF        RST     38H
f52c 00        NOP     
f52d 00        NOP     
f52e FF        RST     38H
f52f FF        RST     38H
f530 00        NOP     
f531 00        NOP     
f532 FF        RST     38H
f533 FF        RST     38H
f534 00        NOP     
f535 00        NOP     
f536 FF        RST     38H
f537 FF        RST     38H
f538 00        NOP     
f539 00        NOP     
f53a FF        RST     38H
f53b FF        RST     38H
f53c 00        NOP     
f53d 00        NOP     
f53e FF        RST     38H
f53f FF        RST     38H
f540 00        NOP     
f541 00        NOP     
f542 FF        RST     38H
f543 FF        RST     38H
f544 00        NOP     
f545 00        NOP     
f546 FF        RST     38H
f547 FF        RST     38H
f548 00        NOP     
f549 00        NOP     
f54a FF        RST     38H
f54b FF        RST     38H
f54c 00        NOP     
f54d 00        NOP     
f54e FF        RST     38H
f54f FF        RST     38H
f550 00        NOP     
f551 00        NOP     
f552 FF        RST     38H
f553 FF        RST     38H
f554 00        NOP     
f555 00        NOP     
f556 FF        RST     38H
f557 FF        RST     38H
f558 00        NOP     
f559 00        NOP     
f55a FF        RST     38H
f55b FF        RST     38H
f55c 00        NOP     
f55d 00        NOP     
f55e FF        RST     38H
f55f FF        RST     38H
f560 00        NOP     
f561 00        NOP     
f562 FF        RST     38H
f563 FF        RST     38H
f564 00        NOP     
f565 00        NOP     
f566 FF        RST     38H
f567 FF        RST     38H
f568 00        NOP     
f569 00        NOP     
f56a FF        RST     38H
f56b FF        RST     38H
f56c 00        NOP     
f56d 00        NOP     
f56e FF        RST     38H
f56f FF        RST     38H
f570 00        NOP     
f571 00        NOP     
f572 FF        RST     38H
f573 FF        RST     38H
f574 00        NOP     
f575 00        NOP     
f576 FF        RST     38H
f577 FF        RST     38H
f578 00        NOP     
f579 00        NOP     
f57a FF        RST     38H
f57b FF        RST     38H
f57c 00        NOP     
f57d 00        NOP     
f57e FF        RST     38H
f57f FF        RST     38H
f580 00        NOP     
f581 00        NOP     
f582 FF        RST     38H
f583 FF        RST     38H
f584 00        NOP     
f585 00        NOP     
f586 FF        RST     38H
f587 FF        RST     38H
f588 00        NOP     
f589 00        NOP     
f58a FF        RST     38H
f58b FF        RST     38H
f58c 00        NOP     
f58d 00        NOP     
f58e FF        RST     38H
f58f FF        RST     38H
f590 00        NOP     
f591 00        NOP     
f592 FF        RST     38H
f593 FF        RST     38H
f594 00        NOP     
f595 00        NOP     
f596 FF        RST     38H
f597 FF        RST     38H
f598 00        NOP     
f599 00        NOP     
f59a FF        RST     38H
f59b FF        RST     38H
f59c 00        NOP     
f59d 00        NOP     
f59e FF        RST     38H
f59f FF        RST     38H
f5a0 00        NOP     
f5a1 00        NOP     
f5a2 FF        RST     38H
f5a3 FF        RST     38H
f5a4 00        NOP     
f5a5 00        NOP     
f5a6 FF        RST     38H
f5a7 FF        RST     38H
f5a8 00        NOP     
f5a9 00        NOP     
f5aa FF        RST     38H
f5ab FF        RST     38H
f5ac 00        NOP     
f5ad 00        NOP     
f5ae FF        RST     38H
f5af FF        RST     38H
f5b0 00        NOP     
f5b1 00        NOP     
f5b2 FF        RST     38H
f5b3 FF        RST     38H
f5b4 00        NOP     
f5b5 00        NOP     
f5b6 FF        RST     38H
f5b7 FF        RST     38H
f5b8 00        NOP     
f5b9 00        NOP     
f5ba FF        RST     38H
f5bb FF        RST     38H
f5bc 00        NOP     
f5bd 00        NOP     
f5be FF        RST     38H
f5bf FF        RST     38H
f5c0 00        NOP     
f5c1 00        NOP     
f5c2 FF        RST     38H
f5c3 FF        RST     38H
f5c4 00        NOP     
f5c5 00        NOP     
f5c6 FF        RST     38H
f5c7 FF        RST     38H
f5c8 00        NOP     
f5c9 00        NOP     
f5ca FF        RST     38H
f5cb FF        RST     38H
f5cc 00        NOP     
f5cd 00        NOP     
f5ce FF        RST     38H
f5cf FF        RST     38H
f5d0 00        NOP     
f5d1 00        NOP     
f5d2 FF        RST     38H
f5d3 FF        RST     38H
f5d4 00        NOP     
f5d5 00        NOP     
f5d6 FF        RST     38H
f5d7 FF        RST     38H
f5d8 00        NOP     
f5d9 00        NOP     
f5da FF        RST     38H
f5db FF        RST     38H
f5dc 00        NOP     
f5dd 00        NOP     
f5de FF        RST     38H
f5df FF        RST     38H
f5e0 00        NOP     
f5e1 00        NOP     
f5e2 FF        RST     38H
f5e3 FF        RST     38H
f5e4 00        NOP     
f5e5 00        NOP     
f5e6 FF        RST     38H
f5e7 FF        RST     38H
f5e8 00        NOP     
f5e9 00        NOP     
f5ea FF        RST     38H
f5eb FF        RST     38H
f5ec 00        NOP     
f5ed 00        NOP     
f5ee FF        RST     38H
f5ef FF        RST     38H
f5f0 00        NOP     
f5f1 00        NOP     
f5f2 FF        RST     38H
f5f3 FF        RST     38H
f5f4 00        NOP     
f5f5 00        NOP     
f5f6 FF        RST     38H
f5f7 FF        RST     38H
f5f8 00        NOP     
f5f9 00        NOP     
f5fa FF        RST     38H
f5fb FF        RST     38H
f5fc 00        NOP     
f5fd 00        NOP     
f5fe FF        RST     38H
f5ff FF        RST     38H
f600 FF        RST     38H
f601 FF        RST     38H
f602 00        NOP     
f603 00        NOP     
f604 FF        RST     38H
f605 FF        RST     38H
f606 00        NOP     
f607 00        NOP     
f608 FF        RST     38H
f609 FF        RST     38H
f60a 00        NOP     
f60b 00        NOP     
f60c FF        RST     38H
f60d FF        RST     38H
f60e 00        NOP     
f60f 00        NOP     
f610 FF        RST     38H
f611 FF        RST     38H
f612 00        NOP     
f613 00        NOP     
f614 FF        RST     38H
f615 FF        RST     38H
f616 00        NOP     
f617 00        NOP     
f618 FF        RST     38H
f619 FF        RST     38H
f61a 00        NOP     
f61b 00        NOP     
f61c FF        RST     38H
f61d FF        RST     38H
f61e 00        NOP     
f61f 00        NOP     
f620 FF        RST     38H
f621 FF        RST     38H
f622 00        NOP     
f623 00        NOP     
f624 FF        RST     38H
f625 FF        RST     38H
f626 00        NOP     
f627 00        NOP     
f628 FF        RST     38H
f629 FF        RST     38H
f62a 00        NOP     
f62b 00        NOP     
f62c FF        RST     38H
f62d FF        RST     38H
f62e 00        NOP     
f62f 00        NOP     
f630 FF        RST     38H
f631 FF        RST     38H
f632 00        NOP     
f633 00        NOP     
f634 FF        RST     38H
f635 FF        RST     38H
f636 00        NOP     
f637 00        NOP     
f638 FF        RST     38H
f639 FF        RST     38H
f63a 00        NOP     
f63b 00        NOP     
f63c FF        RST     38H
f63d FF        RST     38H
f63e 00        NOP     
f63f 00        NOP     
f640 FF        RST     38H
f641 FF        RST     38H
f642 00        NOP     
f643 00        NOP     
f644 FF        RST     38H
f645 FF        RST     38H
f646 00        NOP     
f647 00        NOP     
f648 FF        RST     38H
f649 FF        RST     38H
f64a 00        NOP     
f64b 00        NOP     
f64c FF        RST     38H
f64d FF        RST     38H
f64e 00        NOP     
f64f 00        NOP     
f650 FF        RST     38H
f651 FF        RST     38H
f652 00        NOP     
f653 00        NOP     
f654 FF        RST     38H
f655 FF        RST     38H
f656 00        NOP     
f657 00        NOP     
f658 FF        RST     38H
f659 FF        RST     38H
f65a 00        NOP     
f65b 00        NOP     
f65c FF        RST     38H
f65d FF        RST     38H
f65e 00        NOP     
f65f 00        NOP     
f660 FF        RST     38H
f661 FF        RST     38H
f662 00        NOP     
f663 00        NOP     
f664 FF        RST     38H
f665 FF        RST     38H
f666 00        NOP     
f667 00        NOP     
f668 FF        RST     38H
f669 FF        RST     38H
f66a 00        NOP     
f66b 00        NOP     
f66c FF        RST     38H
f66d FF        RST     38H
f66e 00        NOP     
f66f 00        NOP     
f670 FF        RST     38H
f671 FF        RST     38H
f672 00        NOP     
f673 00        NOP     
f674 FF        RST     38H
f675 FF        RST     38H
f676 00        NOP     
f677 00        NOP     
f678 FF        RST     38H
f679 FF        RST     38H
f67a 00        NOP     
f67b 00        NOP     
f67c FF        RST     38H
f67d FF        RST     38H
f67e 00        NOP     
f67f 00        NOP     
f680 FF        RST     38H
f681 FF        RST     38H
f682 00        NOP     
f683 00        NOP     
f684 FF        RST     38H
f685 FF        RST     38H
f686 00        NOP     
f687 00        NOP     
f688 FF        RST     38H
f689 FF        RST     38H
f68a 00        NOP     
f68b 00        NOP     
f68c FF        RST     38H
f68d FF        RST     38H
f68e 00        NOP     
f68f 00        NOP     
f690 FF        RST     38H
f691 FF        RST     38H
f692 00        NOP     
f693 00        NOP     
f694 FF        RST     38H
f695 FF        RST     38H
f696 00        NOP     
f697 00        NOP     
f698 FF        RST     38H
f699 FF        RST     38H
f69a 00        NOP     
f69b 00        NOP     
f69c FF        RST     38H
f69d FF        RST     38H
f69e 00        NOP     
f69f 00        NOP     
f6a0 FF        RST     38H
f6a1 FF        RST     38H
f6a2 00        NOP     
f6a3 00        NOP     
f6a4 FF        RST     38H
f6a5 FF        RST     38H
f6a6 00        NOP     
f6a7 00        NOP     
f6a8 FF        RST     38H
f6a9 FF        RST     38H
f6aa 00        NOP     
f6ab 00        NOP     
f6ac FF        RST     38H
f6ad FF        RST     38H
f6ae 00        NOP     
f6af 00        NOP     
f6b0 FF        RST     38H
f6b1 FF        RST     38H
f6b2 00        NOP     
f6b3 00        NOP     
f6b4 FF        RST     38H
f6b5 FF        RST     38H
f6b6 00        NOP     
f6b7 00        NOP     
f6b8 FF        RST     38H
f6b9 FF        RST     38H
f6ba 00        NOP     
f6bb 00        NOP     
f6bc FF        RST     38H
f6bd FF        RST     38H
f6be 00        NOP     
f6bf 00        NOP     
f6c0 FF        RST     38H
f6c1 FF        RST     38H
f6c2 00        NOP     
f6c3 00        NOP     
f6c4 FF        RST     38H
f6c5 FF        RST     38H
f6c6 00        NOP     
f6c7 00        NOP     
f6c8 FF        RST     38H
f6c9 FF        RST     38H
f6ca 00        NOP     
f6cb 00        NOP     
f6cc FF        RST     38H
f6cd FF        RST     38H
f6ce 00        NOP     
f6cf 00        NOP     
f6d0 FF        RST     38H
f6d1 FF        RST     38H
f6d2 00        NOP     
f6d3 00        NOP     
f6d4 FF        RST     38H
f6d5 FF        RST     38H
f6d6 00        NOP     
f6d7 00        NOP     
f6d8 FF        RST     38H
f6d9 FF        RST     38H
f6da 00        NOP     
f6db 00        NOP     
f6dc FF        RST     38H
f6dd FF        RST     38H
f6de 00        NOP     
f6df 00        NOP     
f6e0 FF        RST     38H
f6e1 FF        RST     38H
f6e2 00        NOP     
f6e3 00        NOP     
f6e4 FF        RST     38H
f6e5 FF        RST     38H
f6e6 00        NOP     
f6e7 00        NOP     
f6e8 FF        RST     38H
f6e9 FF        RST     38H
f6ea 00        NOP     
f6eb 00        NOP     
f6ec FF        RST     38H
f6ed FF        RST     38H
f6ee 00        NOP     
f6ef 00        NOP     
f6f0 FF        RST     38H
f6f1 FF        RST     38H
f6f2 00        NOP     
f6f3 00        NOP     
f6f4 FF        RST     38H
f6f5 FF        RST     38H
f6f6 00        NOP     
f6f7 00        NOP     
f6f8 FF        RST     38H
f6f9 FF        RST     38H
f6fa 00        NOP     
f6fb 00        NOP     
f6fc FF        RST     38H
f6fd FF        RST     38H
f6fe 00        NOP     
f6ff 00        NOP     
f700 00        NOP     
f701 00        NOP     
f702 FF        RST     38H
f703 FF        RST     38H
f704 00        NOP     
f705 00        NOP     
f706 FF        RST     38H
f707 FF        RST     38H
f708 00        NOP     
f709 00        NOP     
f70a FF        RST     38H
f70b FF        RST     38H
f70c 00        NOP     
f70d 00        NOP     
f70e FF        RST     38H
f70f FF        RST     38H
f710 00        NOP     
f711 00        NOP     
f712 FF        RST     38H
f713 FF        RST     38H
f714 00        NOP     
f715 00        NOP     
f716 FF        RST     38H
f717 FF        RST     38H
f718 00        NOP     
f719 00        NOP     
f71a FF        RST     38H
f71b FF        RST     38H
f71c 00        NOP     
f71d 00        NOP     
f71e FF        RST     38H
f71f FF        RST     38H
f720 00        NOP     
f721 00        NOP     
f722 FF        RST     38H
f723 FF        RST     38H
f724 00        NOP     
f725 00        NOP     
f726 FF        RST     38H
f727 FF        RST     38H
f728 00        NOP     
f729 00        NOP     
f72a FF        RST     38H
f72b FF        RST     38H
f72c 00        NOP     
f72d 00        NOP     
f72e FF        RST     38H
f72f FF        RST     38H
f730 00        NOP     
f731 00        NOP     
f732 FF        RST     38H
f733 FF        RST     38H
f734 00        NOP     
f735 00        NOP     
f736 FF        RST     38H
f737 FF        RST     38H
f738 00        NOP     
f739 00        NOP     
f73a FF        RST     38H
f73b FF        RST     38H
f73c 00        NOP     
f73d 00        NOP     
f73e FF        RST     38H
f73f FF        RST     38H
f740 00        NOP     
f741 00        NOP     
f742 FF        RST     38H
f743 FF        RST     38H
f744 00        NOP     
f745 00        NOP     
f746 FF        RST     38H
f747 FF        RST     38H
f748 00        NOP     
f749 00        NOP     
f74a FF        RST     38H
f74b FF        RST     38H
f74c 00        NOP     
f74d 00        NOP     
f74e FF        RST     38H
f74f FF        RST     38H
f750 00        NOP     
f751 00        NOP     
f752 FF        RST     38H
f753 FF        RST     38H
f754 00        NOP     
f755 00        NOP     
f756 FF        RST     38H
f757 FF        RST     38H
f758 00        NOP     
f759 00        NOP     
f75a FF        RST     38H
f75b FF        RST     38H
f75c 00        NOP     
f75d 00        NOP     
f75e FF        RST     38H
f75f FF        RST     38H
f760 00        NOP     
f761 00        NOP     
f762 FF        RST     38H
f763 FF        RST     38H
f764 00        NOP     
f765 00        NOP     
f766 FF        RST     38H
f767 FF        RST     38H
f768 00        NOP     
f769 00        NOP     
f76a FF        RST     38H
f76b FF        RST     38H
f76c 00        NOP     
f76d 00        NOP     
f76e FF        RST     38H
f76f FF        RST     38H
f770 00        NOP     
f771 00        NOP     
f772 FF        RST     38H
f773 FF        RST     38H
f774 00        NOP     
f775 00        NOP     
f776 FF        RST     38H
f777 FF        RST     38H
f778 00        NOP     
f779 00        NOP     
f77a FF        RST     38H
f77b FF        RST     38H
f77c 00        NOP     
f77d 00        NOP     
f77e FF        RST     38H
f77f FF        RST     38H
f780 00        NOP     
f781 00        NOP     
f782 FF        RST     38H
f783 FF        RST     38H
f784 00        NOP     
f785 00        NOP     
f786 FF        RST     38H
f787 FF        RST     38H
f788 00        NOP     
f789 00        NOP     
f78a FF        RST     38H
f78b FF        RST     38H
f78c 00        NOP     
f78d 00        NOP     
f78e FF        RST     38H
f78f FF        RST     38H
f790 00        NOP     
f791 00        NOP     
f792 FF        RST     38H
f793 FF        RST     38H
f794 00        NOP     
f795 00        NOP     
f796 FF        RST     38H
f797 FF        RST     38H
f798 00        NOP     
f799 00        NOP     
f79a FF        RST     38H
f79b FF        RST     38H
f79c 00        NOP     
f79d 00        NOP     
f79e FF        RST     38H
f79f FF        RST     38H
f7a0 00        NOP     
f7a1 00        NOP     
f7a2 FF        RST     38H
f7a3 FF        RST     38H
f7a4 00        NOP     
f7a5 00        NOP     
f7a6 FF        RST     38H
f7a7 FF        RST     38H
f7a8 00        NOP     
f7a9 00        NOP     
f7aa FF        RST     38H
f7ab FF        RST     38H
f7ac 00        NOP     
f7ad 00        NOP     
f7ae FF        RST     38H
f7af FF        RST     38H
f7b0 00        NOP     
f7b1 00        NOP     
f7b2 FF        RST     38H
f7b3 FF        RST     38H
f7b4 00        NOP     
f7b5 00        NOP     
f7b6 FF        RST     38H
f7b7 FF        RST     38H
f7b8 00        NOP     
f7b9 00        NOP     
f7ba FF        RST     38H
f7bb FF        RST     38H
f7bc 00        NOP     
f7bd 00        NOP     
f7be FF        RST     38H
f7bf FF        RST     38H
f7c0 00        NOP     
f7c1 00        NOP     
f7c2 FF        RST     38H
f7c3 FF        RST     38H
f7c4 00        NOP     
f7c5 00        NOP     
f7c6 FF        RST     38H
f7c7 FF        RST     38H
f7c8 00        NOP     
f7c9 00        NOP     
f7ca FF        RST     38H
f7cb FF        RST     38H
f7cc 00        NOP     
f7cd 00        NOP     
f7ce FF        RST     38H
f7cf FF        RST     38H
f7d0 00        NOP     
f7d1 00        NOP     
f7d2 FF        RST     38H
f7d3 FF        RST     38H
f7d4 00        NOP     
f7d5 00        NOP     
f7d6 FF        RST     38H
f7d7 FF        RST     38H
f7d8 00        NOP     
f7d9 00        NOP     
f7da FF        RST     38H
f7db FF        RST     38H
f7dc 00        NOP     
f7dd 00        NOP     
f7de FF        RST     38H
f7df FF        RST     38H
f7e0 00        NOP     
f7e1 00        NOP     
f7e2 FF        RST     38H
f7e3 FF        RST     38H
f7e4 00        NOP     
f7e5 00        NOP     
f7e6 FF        RST     38H
f7e7 FF        RST     38H
f7e8 00        NOP     
f7e9 00        NOP     
f7ea FF        RST     38H
f7eb FF        RST     38H
f7ec 00        NOP     
f7ed 00        NOP     
f7ee FF        RST     38H
f7ef FF        RST     38H
f7f0 00        NOP     
f7f1 00        NOP     
f7f2 FF        RST     38H
f7f3 FF        RST     38H
f7f4 00        NOP     
f7f5 00        NOP     
f7f6 FF        RST     38H
f7f7 FF        RST     38H
f7f8 00        NOP     
f7f9 00        NOP     
f7fa FF        RST     38H
f7fb FF        RST     38H
f7fc 00        NOP     
f7fd 00        NOP     
f7fe FF        RST     38H
f7ff FF        RST     38H
