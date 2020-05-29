	title	@ebl
esc	equ	1bh
bdos	equ	5

ebl::	ld	de,erbl		;erase to begin of line
	ld	c,9
	jp	bdos
erbl:	db	esc,'o$'
	end
