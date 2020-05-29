	title	@dc
esc	equ	1bh
bdos	equ	5

dc::	ld	de,ddc		;DELETE character
	ld	c,9
	jp	bdos
ddc:	db	esc,'N$'
	end
