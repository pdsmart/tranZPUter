	title	@ceol
esc	equ	1bh
bdos	equ	5

ceol::	ld	de,cleol	;clear to end of line
	ld	c,9
	jp	bdos
cleol:	db	esc,'K$'
	end
