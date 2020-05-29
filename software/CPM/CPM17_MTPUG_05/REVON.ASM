	title	@revon
esc	equ	1bh
bdos	equ	5


revon::	ld	de,rev		;cursor home 
	ld	c,9
	jp	bdos
rev:	db	esc,'p$'
	end
