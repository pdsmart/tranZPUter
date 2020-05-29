	title	@ctop
esc	equ	1bh
bdos	equ	5

ctop::	ld	de,cltop	;clear to top of screen
	ld	c,9
	jp	bdos
cltop:	db	esc,'b$'
	end
