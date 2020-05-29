	title	@kbon
esc	equ	1bh
bdos	equ	5

kbon::	ld	de,kb1		;keyboard on
	ld 	c,9
	jp	bdos
kb1:	db	esc,'{$'
	end
