	title	@revof
esc	equ	1bh
bdos	equ	5


revoff::ld	de,xrev		;cursor home 
	ld	c,9
	jp	bdos
xrev:	db	esc,'q$'
	end
