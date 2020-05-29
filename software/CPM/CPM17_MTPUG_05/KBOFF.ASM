	title	@kboff
esc	equ	1bh
bdos	equ	5

kboff::	ld	de,kb2		;keayboard off
	ld	c,9
	jp	bdos
kb2:	db	esc,'}$'
	end
