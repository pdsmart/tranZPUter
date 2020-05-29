	title	@il
esc	equ	1bh
bdos	equ	5

il::	ld	de,iil		;INSERT line
	ld	c,9
	jp	bdos
iil:	db	esc,'L$'
	end
