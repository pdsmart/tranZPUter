	title 'wd1797 w/ Z80 DMA Single density diskette handler'

;    CP/M-80 Version 3     --  Modular BIOS

;	Disk I/O Module for wd1797 based diskette systems

	;	Initial version 0.01,
	;		Single density floppy only.	- jrp, 4 Aug 82

	dseg

    ; Disk drive dispatching tables for linked BIOS

	public	fdsd0,fdsd1

    ; Variables containing parameters passed by BDOS

	extrn	@adrv,@rdrv
	extrn	@dma,@trk,@sect
	extrn	@dbnk

    ; System Control Block variables

	extrn	@ermde		; BDOS error mode

    ; Utility routines in standard BIOS

	extrn	?wboot	; warm boot vector
	extrn	?pmsg	; print message @<HL> up to 00, saves <BC> & <DE>
	extrn	?pdec	; print binary number in <A> from 0 to 99.
	extrn	?pderr	; print BIOS disk error header
	extrn	?conin,?cono	; con in and out
	extrn	?const		; get console status


    ; Port Address Equates

	maclib ports

    ; CP/M 3 Disk definition macros

	maclib cpm3

    ; Z80 macro library instruction definitions

	maclib z80

    ; common control characters

cr	equ 13
lf	equ 10
bell	equ 7


    ; Extended Disk Parameter Headers (XPDHs)

	dw	fd$write
	dw	fd$read
	dw	fd$login
	dw	fd$init0
	db	0,0		; relative drive zero
fdsd0	dph     trans,dpbsd,16,31

	dw	fd$write
	dw	fd$read
	dw	fd$login
	dw	fd$init1
	db	1,0		; relative drive one
fdsd1	dph	trans,dpbsd,16,31

	cseg	; DPB must be resident

dpbsd	dpb 128,26,77,1024,64,2

	dseg	; rest is banked

trans	skew 26,6,1



    ; Disk I/O routines for standardized BIOS interface

; Initialization entry point.

;		called for first time initialization.


fd$init0:
	lxi h,init$table
fd$init$next:
	mov a,m ! ora a ! rz
	mov b,a ! inx h ! mov c,m ! inx h
	outir
	jmp fd$init$next

fd$init1:	; all initialization done by drive 0
	ret

init$table	db 4,p$zpio$1A
		db	11001111b, 11000010b, 00010111b,11111111b
		db 4,p$zpio$1B
		db	11001111b, 11011101b, 00010111b,11111111b
		db 0


fd$login:
		; This entry is called when a logical drive is about to
		; be logged into for the purpose of density determination.

		; It may adjust the parameters contained in the disk
		; parameter header pointed at by <DE>

	ret	; we have nothing to do in
		;	simple single density only environment.


; disk READ and WRITE entry points.

		; these entries are called with the following arguments:

			; relative drive number in @rdrv (8 bits)
			; absolute drive number in @adrv (8 bits)
			; disk transfer address in @dma (16 bits)
			; disk transfer bank	in @dbnk (8 bits)
			; disk track address	in @trk (16 bits)
			; disk sector address	in @sect (16 bits)
			; pointer to XDPH in <DE>

		; they transfer the appropriate data, perform retries
		; if necessary, then return an error code in <A>

fd$read:
	lxi h,read$msg		; point at " Read "
	mvi a,88h ! mvi b,01h	; 1797 read + Z80DMA direction
	jmp rw$common

fd$write:
	lxi h,write$msg		; point at " Write "
	mvi a,0A8h ! mvi b,05h	; 1797 write + Z80DMA direction
    ;	jmp wr$common

rw$common:			; seek to correct track (if necessary),
				;	initialize DMA controller,
				;	and issue 1797 command.

	shld operation$name		; save message for errors
	sta disk$command		; save 1797 command
	mov a,b ! sta zdma$direction	; save Z80DMA direction code
	lhld @dma ! shld  zdma$dma	; get and save DMA address
	lda @rdrv ! mov l,a ! mvi h,0	; get controller-relative disk drive
	lxi d,select$table ! dad d	; point to select mask for drive
	mov a,m ! sta select$mask	; get select mask and save it
	out p$select			; select drive
more$retries:
	mvi c,10			; allow 10 retries
retry$operation:
	push b				; save retry counter

	lda select$mask ! lxi h,old$select ! cmp m
	mov m,a
	jnz new$track			; if not same drive as last, seek

	lda @trk ! lxi h,old$track ! cmp m
	mov m,a
	jnz new$track			; if not same track, then seek

	in p$fdmisc ! ani 2 ! jnz same$track	; head still loaded, we are OK

new$track:	; or drive or unloaded head means we should . . .
	call check$seek		; . . read address and seek if wrong track

	lxi b,16667		; 100 ms / (24 t states*250 ns)
spin$loop:			; wait for head/seek settling
	dcx b
	mov a,b ! ora c
	jnz spin$loop

same$track:
	lda @trk ! out p$fdtrack	; give 1797 track
	lda @sect ! out p$fdsector	;	and sector

	lxi h,dma$block			; point to dma command block
	lxi b,dmab$length*256 + p$zdma	; command block length and port address
	outir				; send commands to Z80 DMA

	in p$bankselect			; get old value of bank select port
	ani 3Fh ! mov b,a		; mask off DMA bank and save
	lda @dbnk ! rrc ! rrc		; get DMA bank to 2 hi-order bits
	ani 0C0h ! ora b		; merge with other bank stuff
	out p$bankselect		; and select the correct DMA bank

	lda disk$command	; get 1797 command
	call exec$command	; start it then wait for IREQ and read status
	sta disk$status		; save status for error messages

	pop b			; recover retry counter
	ora a ! rz		; check status and return to BDOS if no error

	ani 0001$0000b		; see if record not found error
	cnz check$seek		; if a record not found, we might need to seek

	dcr c ! jnz retry$operation

    ; suppress error message if BDOS is returning errors to application...

	lda @ermde ! cpi 0FFh ! jz hard$error

    ; Had permanent error, print message like:

		; BIOS Err on d: T-nn, S-mm, <operation> <type>, Retry ?

	call ?pderr		; print message header

	lhld operation$name ! call ?pmsg		; last function

		; then, messages for all indicated error bits

	lda disk$status		; get status byte from last error
	lxi h,error$table	; point at table of message addresses
errm1:
	mov e,m ! inx h ! mov d,m ! inx h ; get next message address
	add a ! push psw	; shift left and push residual bits with status
	xchg ! cc ?pmsg ! xchg	; print message, saving table pointer
	pop psw	! jnz errm1	; if any more bits left, continue

	lxi h,error$msg ! call ?pmsg	; print "<BEL>, Retry (Y/N) ? "
	call u$conin$echo	; get operator response
	cpi 'Y' ! jz more$retries ; Yes, then retry 10 more times
hard$error:			; otherwise,
	mvi a,1 ! ret		; 	return hard error to BDOS

cancel:				; here to abort job
	jmp ?wboot		; leap directly to warmstart vector


		; subroutine to seek if on wrong track
		; called both to set up new track or drive

check$seek:
	push b				; save error counter
	call read$id 			; try to read ID, put track in <B>
	jz id$ok			; if OK, we're OK
	call step$out			; else step towards Trk 0
	call read$id			; and try again
	jz id$ok			; if OK, we're OK
	call restore			; else, restore the drive
	mvi b,0				; and make like we are at track 0
id$ok:
	mov a,b ! out p$fdtrack		; send current track to track port
	lda @trk ! cmp b ! pop b ! rz	; if its desired track, we are done
	out p$fddata			; else, desired track to data port
	mvi a,00011010b			; seek w/ 10 ms. steps
	jmp exec$command



step$out:
	mvi a,01101010b			; step out once at 10 ms.
	jmp exec$command

restore:
	mvi a,00001011b			; restore at 15 ms
      ; jmp exec$command


exec$command:		; issue 1797 command, and wait for IREQ
			;	return status
	out p$fdcmnd			; send 1797 command
wait$IREQ:				; spin til IREQ
	in p$fdint ! ani 40h ! jz wait$IREQ
	in p$fdstat			; get 1797 status and clear IREQ
	ret

read$id:
	lxi h,read$id$block	; set up DMA controller
	lxi b,length$id$dmab*256 + p$zdma ; for READ ADDRESS operation
	outir
	mvi a,11000100b		; issue 1797 read address command
	call exec$command	; wait for IREQ and read status
	ani 10011101b		; mask status
	lxi h,id$buffer ! mov b,m	; get actual track number in <B>
	ret			; and return with Z flag true for OK


u$conin$echo:	; get console input, echo it, and shift to upper case
	call ?const ! ora a ! jz u$c1	; see if any char already struck
	call ?conin ! jmp u$conin$echo	; yes, eat it and try again
u$c1:
	call ?conin ! push psw
	mov c,a ! call ?cono
	pop psw ! cpi 'a' ! rc
	sui 'a'-'A'		; make upper case
	ret


disk$command	ds	1	; current wd1797 command
select$mask	ds	1	; current drive select code
old$select	ds	1	; last drive selected
old$track	ds	1	; last track seeked to

disk$status	ds	1	; last error status code for messages

select$table	db	0001$0000b,0010$0000b ; for now use drives C and D


	; error message components

read$msg	db	', Read',0
write$msg	db	', Write',0

operation$name	dw	read$msg

	; table of pointers to error message strings
	;	first entry is for bit 7 of 1797 status byte

error$table	dw	b7$msg
		dw	b6$msg
		dw	b5$msg
		dw	b4$msg
		dw	b3$msg
		dw	b2$msg
		dw	b1$msg
		dw	b0$msg

b7$msg		db	' Not ready,',0
b6$msg		db	' Protect,',0
b5$msg		db	' Fault,',0
b4$msg		db	' Record not found,',0
b3$msg		db	' CRC,',0
b2$msg		db	' Lost data,',0
b1$msg		db	' DREQ,',0
b0$msg		db	' Busy,',0

error$msg	db	' Retry (Y/N) ? ',0



	; command string for Z80DMA device for normal operation

dma$block	db	0C3h	; reset DMA channel
		db	14h	; channel A is incrementing memory
		db	28h	; channel B is fixed port address
		db	8Ah	; RDY is high, CE/ only, stop on EOB
		db	79h	; program all of ch. A, xfer B->A (temp)
zdma$dma	ds	2	; starting DMA address
		dw	128-1	; 128 byte sectors in SD
		db	85h	; xfer byte at a time, ch B is 8 bit address
		db	p$fddata ; ch B port address (1797 data port)
		db	0CFh	; load B as source register
		db	05h	; xfer A->B
		db	0CFh	; load A as source register
zdma$direction	ds	1	; either A->B or B->A
		db	0CFh	; load final source register
		db	87h	; enable DMA channel
dmab$length	equ	$-dma$block



read$id$block	db	0C3h	; reset DMA channel
		db	14h	; channel A is incrementing memory
		db	28h	; channel B is fixed port address
		db	8Ah	; RDY is high, CE/ only, stop on EOB
		db	7Dh	; program all of ch. A, xfer A->B (temp)
		dw	id$buffer ; starting DMA address
		dw	6-1	; Read ID always xfers 6 bytes
		db	85h	; byte xfer, ch B is 8 bit address
		db	p$fddata ; ch B port address (1797 data port)
		db	0CFh	; load dest (currently source) register
		db	01h	; xfer B->A
		db	0CFh	; load source register
		db	87h	; enable DMA channel
length$id$dmab	equ	$-read$id$block

	cseg	; easier to put ID buffer in common

id$buffer	ds	6	; buffer to hold ID field
	; track
	; side
	; sector
	; length
	; CRC 1
	; CRC 2

	end
