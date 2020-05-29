	title	@savec
esc	equ	1bh
bdos	equ	5

savec::	ld	de,sve		;save cursor
	ld	c,9
	jp	bdos
sve:	db	esc,'j$'
	end
