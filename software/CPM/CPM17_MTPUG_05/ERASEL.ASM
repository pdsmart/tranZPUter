	title	@erasl
esc	equ	1bh
bdos	equ	5

erasel::ld	de,edl		;erase entire line
	ld	c,9
	jp	bdos
edl:	db	esc,'l$'
	end
