	title	@date

date::	pop	ix		;save return addr.
	ld	bc,3000h+'.'	;preset for "or '0'" and save '.'
	pop	hl		;get addr. of var
	ld	(hl),10		;save length in var[0]
	inc	hl		;and start transfer of data
	in	a,(0e8h)	;day10
	and	03h		;0,1,2 or 3
	or	b		;get ascii
	ld	(hl),a		;save it
	inc	hl		;for the next val
	in	a,(0e7h)	;and go on for the other's
	and	0fh
	or	b
	ld	(hl),a
	inc	hl
	ld	(hl),c		;put '.' in string
	inc	hl
	in	a,(0eah)
	and	01h
	or	b
	lä	(hl),a
	inc	hl
	in	a,(0e9h)
	and	0fh
	or	b
	ld	(hl),a
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),'1'
	inc	hl
	ld	(hl),'9'
	inc	hl
	in	a,(0ech)
	and	0fh
	or	b
	ld	(hl),a
	inc	hl
	in	a,(0ebh)
	and	0fh
	or	b
	ld	(hl),a
	jp	(ix)		;this means RETURN (popped before)

	end
