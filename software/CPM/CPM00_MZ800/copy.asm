	page	55
	title	'Sample file-to-file copy program'
;      tstcpy:  test copy program ( file-to-file )	     
;      		at the ccp level, the command		     
;     			copy a:x.y b:u.v		     
;     		copies the file named x.y from		     
;     		drive a to a file named u.v on		     
;     		drive b.				     
;
;      address equates					     
;
boot	equ	0000h		;system reboot address
bdos	equ	0005h		;bdos entry point
fcb1	equ	005ch		;1st file name (default fcb)
sfcb	equ	fcb1		;source file name
fcb2	equ	006ch		;2nd file name (from command)
dbuff	equ	0080h		;default buffer
tpa	equ	0100h		;beginning of tpa
;
;      bdos function numbers 				     
;
printf	equ	9		;print buffer 
openf	equ	15		;open file 
closef	equ	16		;close file 
deletef	equ	19		;delete file 
readf	equ	20		;sequential read
writef	equ	21		;sequential read
makef	equ	22		;make file
;
;      start program:  tstcpy				     
;
	org	tpa		;beginning of tpa
	lxi	sp,stack	;initialize local stack
;
;      move 2nd file name to dfcb			     
;
	mvi	c,16		;half an fcb
	lxi	d,fcb2		;source of move
	lxi	h,dfcb		;destination fcb
mfcb	ldax	d		;source fcb
	inx	d		;ready next
	mov	m,a		;dest fcb
	inx	h		;ready next
	dcr	c		;byte count down
	jnz	mfcb		;loop 16 times
;
;      name has been moved, zero cr			     
;
	xra	a		;a = 00
	sta	dfcbcr		;current rec = 0
;
;      source and destination fcb's ready		     
;
	lxi	d,sfcb		;source fcb
	call	open		;error if 255
	lxi	d,nofile	;ready message
	inr	a		;255 becomes 0
	cz	finis		;done if no file
;
;      source file open, prep destination		     
;
	lxi	d,dfcb		;destination
	call	make		;create the file
	lxi	d,nodir		;ready message
	inr	a		;255 becomes 0
	cz	finis		;done if no dir space
;
;      source file open, dest file open;		     
;      copy until end of file on source			     
;
copy	lxi	d,sfcb		;source
	call	read		;read next record
	ora	a		;end of file ?
	jnz	eofile		;skip write if eof
;
;      not end of file, write the record		     
;
	lxi	d,dfcb		;destination
	call	write		;write record
	lxi	d,space		;ready message
	ora	a		;00 if write OK
	cnz	finis		;end if not OK
	jmp	copy		;loop until EOF
;
;      end of file, close destination			     
;
eofile:
	lxi	d,dfcb		;destination
	call	close		;255 if error
	lxi	h,wrprot		;ready message
	inr	a		;255 becomes 0
	cz	finis		;shouldn't happen
;
;      copy operation complete, end			     
;
	lxi	d,normal	;ready message
;
;      write message given by de & reboot		     
;
finis:
	mvi	c,printf	;print line funct
	call	bdos		;write message
	jmp	boot		;reboot system
;
;      system interface sub routines			     
;      (all return directly from bdos)			     
;
open	mvi	c,openf		;open file fnct
	jmp	bdos
;
close	mvi	c,closef	;close file fnct
	jmp	bdos
;
delete	mvi	c,deletef	;delete file fnct
	jmp	bdos
;
read	mvi	c,readf		;read file fnct
	jmp	bdos
;
write	mvi	c,writef	;write file fnct
	jmp	bdos
;
make	mvi	c,makef		;make file fnct
	jmp	bdos
;
;      console messages					     
;
nofile	db	'no source file$'
nodir	db	'no directory space$'
space	db	'out of data space$'
wrprot	db	'write protected ?$'
normal	db	'copy complete$'
;
;      data areas					     
;
dfcb	ds	33		;destination fcb
dfcbcr	equ	dfcb+32		;current record
;
	ds	32		;16 level stack
stack:
	end
