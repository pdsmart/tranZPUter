	title	@ic
esc	equ	1bh
bdos	equ	5


ic::	ld	de,inc		;cursor home 
	ld	c,9
	jp	bdos
inc:	db	esc,'@$'
	end
