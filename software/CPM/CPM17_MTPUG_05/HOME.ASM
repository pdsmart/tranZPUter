	title	@home
esc	equ	1bh
bdos	equ	5


home::	ld	de,hom		;cursor home 
	ld	c,9
	jp	bdos
hom:	db	esc,'H$'
	end
