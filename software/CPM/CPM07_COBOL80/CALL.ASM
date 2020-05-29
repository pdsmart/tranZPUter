; Program "Call" called by "Testcall"; this is assembler version;
; compare with functionally equivalent COBOL version.

	cseg

	ldax	b			; read first param: A = text length
loop:
	dcr	a			; count down length
	rm				; finished
	push	psw
	ldax	d			; next byte from second param = text
	inx	d
	push	d
	mov	e,a
	mvi	c,6			; CP/M function code
	call	5			; call CP/M to send character
	pop	d
	pop	psw
	jmp	loop

; End of demonstration program "Call"

end
