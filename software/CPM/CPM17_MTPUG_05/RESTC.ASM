	title	@restc
esc	equ	1bh
bdos	equ	5

restc::	ld	de,rest		;restore cursor
	ld	c,9
	jp	bdos
rest:	db	esc,'k$'
	end
