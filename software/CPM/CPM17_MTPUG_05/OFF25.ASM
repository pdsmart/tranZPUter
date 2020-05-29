	title	@off25
esc	equ	1bh
bdos	equ	5

off25::	ld	de,o2
	ld	c,9
	jp	bdos
o2:	db	esc,'y1$'

	end

