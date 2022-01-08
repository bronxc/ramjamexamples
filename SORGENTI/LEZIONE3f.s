;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Lesson3f.s BAR UNDER THE $FF LINE

; This listing is identical to Lesson3d.s, except for
; the fact that the finger is below the $FF line which is not
; we never overstepped.

	SECTION	CiriCop,CODE

Init:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC routine that opens
				; the libraries, and outputs the address
				; of that library to make the
				; addressing distances (Offset)
	move.l	d0,GfxBase	; save the GFX base address in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; we save the address of the copperlist
				; di sistema
	move.l	#COPPERLIST,$dff080	; We point to our COP
	move.w	d0,$dff088		; Let's start the COP
WaitForFrame:
	cmpi.b	#$ff,$dff006	; Are we on line 255?
	bne.s	WaitForFrame		; If not yet, don't move on

	bsr.s	MoveCopper	; Routine that takes advantage of the WAIT masking

Wait:
	cmpi.b	#$ff,$dff006	; Are we on line 255?
	beq.s	Wait		; If yes, don't go ahead, wait for the line
					; following, otherwise MoveCopper runs more than 
					; once per frame

	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	WaitForFrame		; if not, back to WaitForFrame:

	move.l	OldCop(PC),$dff080	; We target the system cop
	move.w	d0,$dff088		; let's start the cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - re-enable Multitasking
	move.l	GfxBase(PC),a1	; Base of the library to close
				; (libraries must be opened and closed !!!)
	jsr	-$19e(a6)	; Closelibrary - close the graphics lib
	rts

; The MoveCopper routine is the same, only the values of the
; maximum reachable height, ie $0a and of the bottom of the screen, $2c.

MoveCopper:
	LEA	BAR,a0 		;a0 holds memory address of BAR and we use offsets
	TST.B	DirectionFlag		; Should we go up or down? if DirectionFlag is
				; cleared, (i.e. the TST checks the BEQ)
				; then let's jump to VAIGIU, if it's $FF instead
				; (if this TST is not verified)
				; we keep going up (doing subqs)
	beq.w	VAIGIU
	cmpi.b	#$0a,(a0)	; did we get to the $ 0a + $ ff line? (265)
	beq.s	MoveDown	; if yes, we are at the top and we have to go down
	subq.b	#1,(a0)
	subq.b	#1,8(a0)	; now let's change the other wait: the distance
	subq.b	#1,8*2(a0)	; between one wait and another it is 8 bytes
	subq.b	#1,8*3(a0)
	subq.b	#1,8*4(a0)
	subq.b	#1,8*5(a0)
	subq.b	#1,8*6(a0)
	subq.b	#1,8*7(a0)	; here we have to modify all 9 waits of the
	subq.b	#1,8*8(a0)	; red bar every time to make it go up!
	subq.b	#1,8*9(a0)
	rts

MoveDown:
	clr.b	DirectionFlag		; By resetting DirectionFlag, the BEQ
	rts			; will jump to the VAIGIU routine, and
				; the bar will drop

VAIGIU:
	cmpi.b	#$2c,8*9(a0)	; Did we get to the $ 2c line?
	beq.s	MoveUp		; if yes, we are at the bottom and we have to go back up
	addq.b	#1,(a0)
	addq.b	#1,8(a0)	; now let's change the other wait: the distance
	addq.b	#1,8*2(a0)	;between one wait and another it is 8 bytes
	addq.b	#1,8*3(a0)
	addq.b	#1,8*4(a0)
	addq.b	#1,8*5(a0)
	addq.b	#1,8*6(a0)
	addq.b	#1,8*7(a0)	; here we have to modify all 9 waits of the
	addq.b	#1,8*8(a0)	; red bar every time to make it go down!
	addq.b	#1,8*9(a0)
	rts

MoveUp:
	move.b	#$ff,DirectionFlag	; When the DirectionFlag label is not zero,
	rts			; it means we have to go back up.

; This byte, indicated by the DirectionFlag label, is a FLAG, that is a
; flag (in jargon), in fact once it is a $ff and another time it is a
; $00, depending on the DirectionFlag to follow (up or down!). It is indeed
; like a flag, which when lowered ($00) indicates that we must
; go down and when it is raised ($FF) we have to go up. It comes in fact
; a comparison of the reached line was carried out to verify if
; we got to the top or bottom, and if we got there we change
; the DirectionFlag (with clr.b DirectionFlag or move.b # $ ff, DirectionFlag)

DirectionFlag:
	dc.b	0,0

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Here goes the base address for 
	dc.l	0	; the graphics.library Offset

OldCop:			; Here goes the address of the old system COP
	dc.l	0

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0
	dc.w	$180,$000	; COLOR0 - I start the copy with the color BLACK

	dc.w	$2c07,$FFFE	; WAIT - a small green fixed finger
	dc.w	$180,$010	; COLOR0
	dc.w	$2d07,$FFFE	; WAIT
	dc.w	$180,$020	; COLOR0
	dc.w	$2e07,$FFFE
	dc.w	$180,$030
	dc.w	$2f07,$FFFE
	dc.w	$180,$040
	dc.w	$3007,$FFFE
	dc.w	$180,$030
	dc.w	$3107,$FFFE
	dc.w	$180,$020
	dc.w	$3207,$FFFE
	dc.w	$180,$010
	dc.w	$3307,$FFFE
	dc.w	$180,$000

	dc.w	$ffdf,$fffe	; ATTENTION! WAIT AT THE END OF THE $FF LINE!
					; the waits after this are below the line
					; $FF and start at $00 !!

	dc.w	$0107,$FFFE	; a green fixed bar UNDER the $FF line!
	dc.w	$180,$010
	dc.w	$0207,$FFFE
	dc.w	$180,$020
	dc.w	$0307,$FFFE
	dc.w	$180,$030
	dc.w	$0407,$FFFE
	dc.w	$180,$040
	dc.w	$0507,$FFFE
	dc.w	$180,$030
	dc.w	$0607,$FFFE
	dc.w	$180,$020
	dc.w	$0707,$FFFE
	dc.w	$180,$010
	dc.w	$0807,$FFFE
	dc.w	$180,$000

BAR:
	dc.w	$0907,$FFFE	; I wait for the $ 79 line
	dc.w	$180,$300	; start the red bar: red at 3
	dc.w	$0a07,$FFFE	; next line
	dc.w	$180,$600	; red at 6
	dc.w	$0b07,$FFFE
	dc.w	$180,$900	; red at 9
	dc.w	$0c07,$FFFE
	dc.w	$180,$c00	; red at 12
	dc.w	$0d07,$FFFE
	dc.w	$180,$f00	; red at (al massimo)
	dc.w	$0e07,$FFFE
	dc.w	$180,$c00	; red at 12
	dc.w	$0f07,$FFFE
	dc.w	$180,$900	; red at9
	dc.w	$1007,$FFFE
	dc.w	$180,$600	; red at 6
	dc.w	$1107,$FFFE
	dc.w	$180,$300	; red at 3
	dc.w	$1207,$FFFE
	dc.w	$180,$000	; color BLACK

	dc.w	$FFFF,$FFFE	; end of copperlist


	end

MIRACLE! We've put colored bars under the flamenco $ FF line!
And just put the command:

	dc.w	$ffdf,$fffe

And start at $0107, $fffe to wait at the bottom of the screen.
This is because as you know a byte contains only 255 values, that is up
to $ FF, so to wait for a line higher than $ ff just get there
with $FFdf, $FFFE, then the numbering restarts from 0, up to where it arrives
visible screen, around $30. note that the American television standard
NTSC goes up to the $FF line only, or a little more in overscan, then
Americans don't see the bottom of the screen on the TV, but
it doesn't matter to us, because the Amiga is widespread especially in Europe where there is
the PAL standard, in fact the demos and games are almost always in PAL. In certain
cases programmers make NTSC versions of the game exclusively for
distribution in the USA.

NOTE: For now we could wait with the $DFF006 only one line included
from $01 to $ FF; I will explain later how to wait with $ dffxxx one
line after the $ FF correctly.

