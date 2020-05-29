	title	@cls

esc	equ	1bh
bdos	equ	5

cls::	ld	de,clearsc	;clear screan
	ld	c,9
	jp	bdos
clearsc:db	esc,'E$'
	end
