	title	@xic
esc	equ	1bh
bdos	equ	5


xic::	ld	de,xinc		;cursor home 
	ld	c,9
	jp	bdos
xinc:	db	esc,'O$'
	end
