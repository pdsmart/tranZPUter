	title	@cuoff
esc	equ	1bh
bdos	equ	5

cuoff::	ld	de,cuo2
	ld	c,9
	jp	bdos
	dseg
cuo2:	db	esc,'x5$'
	cseg
	end
