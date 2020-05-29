	title	@time

time::	pop	ix		;save return addr.
	ld	bc,3000h+':'	;preset for "or '0'" and save ':'
	pop	hl		;get addr. of var
	ld	(hl),8		;save length in var[0]
	inc	hl		;and start transfer of data
	in	a,(0e5h)	;h10
	and	03h		;0,1 or 2
	or	b		;get ascii
	ld	(hl),a		;save it
	inc	hl		;for the next val
	in	a,(0e4h)	;and go on for the other's
	and	0fh
	or	b
	ld	(hl),a
	inc	hl
	ld	(hl),c		;put ':' in string
	inc	hl
	in	a,(0e3h)
	and	07h
	or	b
	lä	(hl),a
	inc	hl
	in	a,(0e2h)
	and	0fh
	or	b
	ld	(hl),a
	inc	hl
	ld	(hl),c
	inc	hl
	in	a,(0e1h)
	and	07h
	or	b
	ld	(hl),a
	inc	hl
	in	a,(0e0h)
	and	0fh
	or	b
	ld	(hl),a
	jp	(ix)		;this means RETURN (popped before)

	end

