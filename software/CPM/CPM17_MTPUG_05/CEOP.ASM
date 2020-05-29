	title	@ceop
esc	equ	1bh
bdos	equ	5

ceop::	ld	de,cleop	;clear to end of page
	ld	c,9
	jp	bdos
cleop:	db	esc,'J$'
	end
