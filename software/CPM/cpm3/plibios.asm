
	name	'PLIBIOS'
	title	'Direct BIOS Calls From PL/I-80'
;
;***********************************************************
;*                                                         *
;*	bios calls from pl/i for track, sector io          *
;*                                                         *
;***********************************************************
	public  seldsk	;select disk drive
	public	settrk	;set track number
	public	setsec	;set sector number
	public	rdsec	;read sector
	public	wrsec	;write sector
	public  sectrn	;translate sector number
	public	bstdma	;set dma
	public	bflush	;flush deblocking buffers
;
;
	extrn	?boot	;system reboot entry point
	extrn	?bdos	;bdos entry point
;
;***********************************************************
;*                                                         *
;*        equates for interface to cp/m bios               *
;*                                                         *
;***********************************************************
cr	equ	0dh	;carriage return
lf	equ	0ah	;line feed
eof	equ	1ah	;end of file
;
base	equ	0
wboot	equ	base+1h	;warm boot entry point stored here
sdsk	equ	18h	;bios select disk entry point
strk	equ	1bh	;bios set track entry point
ssec	equ	1eh	;bios set sector entry point
sdma	equ	21h	;bios set dma entry point
read	equ	24h	;bios read sector entry point
write	equ	27h	;bios write sector entry point
stran	equ	2dh	;bios sector translation entry point
;
;	utility functions
;
;***********************************************************
;***********************************************************
;*                                                         *
;*       general purpose routines used upon entry          *
;*                                                         *
;***********************************************************
;
;
getp:	;get parameter
	mov	e,m	;low (addr)
	inx	h
	mov	d,m	;high (addr)
	inx	h
	push	h	;save for next parameter
	xchg		;hl = .char
	mov	e,m	;to register e
	inx	h
	mov	d,m	;get high byte as well
	pop	h	;ready for next parameter
	ret
;
;
;***********************************************************
;*                                                         *
;***********************************************************
seldsk:	;select drive number 0-15, in C
	;1-> drive no.
	;returns-> pointer to translate table in HL
	call getp
	mov c,e		;c = drive no.
	lxi d,sdsk
	jmp gobios
;
;***********************************************************
;*                                                         *
;***********************************************************
settrk:	;set track number 0-76, 0-65535 in BC
	;1-> track no.
	call getp
	mov b,d
	mov c,e		;bc = track no.
	lxi d,strk
	jmp gobios
;
;***********************************************************
;*                                                         *
;***********************************************************
setsec:	;set sector number 1 - sectors per track
	;1-> sector no.
	call getp
	mov b,d
	mov c,e		;bc = sector no.
	lxi d,ssec
	jmp gobios
;
;***********************************************************
;*                                                         *
;***********************************************************
rdsec:	;read current sector into sector at dma addr
	;returns in A register:	0 if no errors 
	;			1 non-recoverable error
	lxi d,read
	jmp gobios
;***********************************************************
;*                                                         *
;***********************************************************
wrsec:	;writes contents of sector at dma addr to current sector
	;returns in A register:	0 errors occured
	;			1 non-recoverable error
	lxi d,write
	jmp gobios
;
;***********************************************************
;*                                                         *
;***********************************************************
sectrn:	;translate sector number
	;1-> logical sector number (fixed(15))
	;2-> pointer to translate table
	;returns-> physical sector number
	call getp	;first parameter
	mov b,d	
	mov c,e		;bc = logical sector no.
	call getp	;second parameter
	push d		;save it
	lxi d,stran
	lhld wboot
	dad d		;hl = sectran entry point
	pop d		;de = .translate-table 
	pchl
;
;***********************************************************
;*
;*
;***********************************************************
bstdma:	;set dma
	call	getp
	mov	b,d
	mov	c,e
	lxi	d,sdma
	jmp	gobios	
;
bflush:	;flush deblocking buffers
;	lxi	b,0ffffh
;	lxi	d,setdmf
;	jmp	gobios
	ret

;***********************************************************
;***********************************************************
;***********************************************************
;*                                                         *
;*       compute offset from warm boot and jump to bios    *
;*                                                         *
;***********************************************************
;
;
gobios:	;jump to bios entry point
	;de ->  offset from warm boot entry point
	lhld	wboot
	dad	d
	pchl
;
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	db	0	
	end

