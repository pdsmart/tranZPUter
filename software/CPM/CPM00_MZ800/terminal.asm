; simple minded terminal emulator (with no buffering)
	org	100h
boot	equ	0
bdos	equ	5

auxin	equ	3
auxout	equ	4
auxist	equ	7
auxost	equ	8

dcio	equ	6
input	equ	0FFh
status	equ	0FEh

term:			;start of main program
con$char:
	mvi	e,input		;get character or status via function #6
	mvi	c,dcio
	call	bdos
	ora	a		;which returns zero to indictate nothing
	jz	Aux$ready$chk	;available, so branch to Auxin Stat test

	cpi	3		;or returns the keyboard character which we
	jz	boot		;test for control "C" meaning exit program now.

	mov	e,a
send$aux:
	push	d		;save character
	mvi	c,auxost	;call aux_out_status function
	call	bdos
	pop	d
	ora	a
	jz	send$aux     	;wait for auxout to be ready

	mvi	c,auxout	;send (e)'s character out Aux
	call	bdos

Aux$ready$chk:
	mvi	c,auxist	;check if Aux has any characters available
	call	bdos
	ora	a		;if return ==false then go back to top of loop
	jz	con$char

	mvi	c,auxin		; else, get the character from Auxin
	call	bdos
	ani	7Fh		;mask any bit 7 parity bits
	mov	e,a
	mvi	c,dcio		; then send the character to the console
	call	bdos
	jmp	con$char	;jump back to main loop for more.

	end
