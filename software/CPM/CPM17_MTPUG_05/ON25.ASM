	title	@on25
esc	equ	1bh
bdos	equ	5

on25::	ld	de,o1
	ld	c,9
	jp	bdos
o1:	db	esc,'x1$'
	end
