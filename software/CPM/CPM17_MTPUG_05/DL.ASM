	title	@dl
esc	equ	1bh
bdos	equ	5

dl::	ld	de,ddl		;DELETE line
	ld	c,9
	jp	bdos
ddl:	db	esc,'M$'
	end
