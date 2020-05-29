	title	@day

day::	pop	ix		;RETURN
	pop	hl		;get var addr.
	in	a,(0e6h)	;get day of week
	and	7
	cp	7
	jr	nc,error	;in range?
	push	hl		;need hl for computing
	add	a,a		;double the value and clear carry
	ld	hl,table
	ld	d,0
	ld	e,a
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	pop	de		;get again var addr.= destination
	ld	b,0
	ld	c,(hl)		;get length
	inc	c		;transfer length is stringlength+1
	ldir			;and transfer
	jp	(ix)		;we are ready


error:	ld	(hl),0		;stringlength set to 0
	jp	(ix)		;ret


table:	dw	mo
	dw	di
	dw	mi
	dw	do
	dw	fr
	dw	sa
	dw	so

mo:	db	6,'Montag'
di:	db	8,'Dienstag'
mi:	db	8,'Mittwoch'
do:	db	9,'Donnerstag'
fr:	db	7,'Freitag'
sa:	db	7,'Samstag'
so:	db	7,'Sonntag'



	end
