	title	@cuon
esc	equ	1bh
bdos	equ	5

cuon::	ld	de,cuo1
	ld	c,9
	jp	bdos
cuo1:	db	esc,'y5$'
	end
