	title	@cpos
esc	equ	1bh
bdos	equ	5

cpos::	pop	bc	;return addr
	pop	de	;e= column
	pop	hl	;l= line
	push	bc	;return addr. on stack
	xor	a
	cp	e
	ret	z
	cp	l
	ret	z
	ld	a,80
	cp	e
	ret	c
	ld	a,25
	cp	l
	ret	c
	ld	h,e	;now l=line and h=colmn
	push	hl
	ld	de,pos1
	ld	c,9
	call	bdos
	pop	hl
	push	hl
	ld	a,1fh
	add	a,l
	ld	e,a
	ld	c,2
	call	bdos
	pop	hl
	ld	a,1fh
	add	a,h
	ld	e,a
	ld	c,2
	jp	bdos
pos1:	db	esc,'Y$'
	end
