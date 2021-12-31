;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Lezione3c.s	; DROP DOWN BAR MADE WITH COPPER MOVE & WAIT
				; (TO LET IT DOWN USE THE RIGHT BUTTON OF THE MOUSE)

	SECTION	MyCode,CODE	; also in Fast is fine for our code

Init:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)		; Disable multitasking
	lea	GfxName(PC),a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC routine that opens
				; the libraries, and outputs the address
				; base of that library to make the
				; addressing distances (Offset)
	move.l	d0,GfxBase	; save the GFX base address in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; we save the address of the system copperlist
					
	move.l	#COPPERLIST,$dff080	; COP1LC - set special register to point to our COP
	move.w	d0,$dff088		; COPJMP1 - Start our COP

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we on line 255?
	bne.s	mouse		; If not yet, don't move on

	btst	#2,$dff016	; POTINP - Right mouse button pressed?
	bne.s	WaitUp		; If not, don't run MoveCopper

	bsr.s	MoveCopper	; The first movement on the screen !!!!!
				; This subroutine drops the WAIT!
				; and runs 1 time every frame
				; in fact bsr.s MoveCopper
				; performs the routine named MoveCopper,
				; at the end, with RTS, the 68000
				; come back here to execute the WaitUp routine,
				; and so on.


WaitUp:			; if we are always on the $ff line we have
				; WaitUpto first, don't go ahead.

	cmpi.b	#$ff,$dff006	; are we at $FF yet? if yes, WaitUp the line
	beq.s	WaitUp		; following ($00), otherwise MoveCopper comes
				; rerun. This problem is only for
				; the very short routines that can be
				; performed in less than "one scan line", called" raster line ": the
				; mouse loop: WaitUp the $FF line, then '
				; runs MoveCopper, but if it runs too 
				; quickly we are always on the $FF line
				; and when we go back to the mouse, to the $FF line
				; we are already there and re-runs MoveCopper,
				; therefore the routine is executed more than one
				; time to the FRAME !!! Especially on A4000!
				; this check avoids the WaitUpndo problem
				; the line after, so returning to the mouse:
				; to reach the line $ff it is necessary
				; the classic fiftieth of a second.
				; NOTE: All monitors and TVs
				; draw the screen at the same speed,
				; while from computer to computer it can vary
				; the speed of the processor. And for this
				; with a timed program using $dff006
				; it goes at the same speed on an A500 and
				; an A4000. The timing will be
				; better addressed later, for now
				; take care to understand the copper and the
				; operation.


	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	mouse		; if not, back to mouse:

	move.l	OldCop(PC),$dff080	; We target the system cop
	move.w	d0,$dff088	; let's start the cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - re-enable Multitasking
	move.l	GfxBase(PC),a1	; Base of the library to close
				; (libraries must be opened and closed !!!)
	jsr	-$19e(a6)	; Closelibrary - close the graphics lib
	rts

;
; This little routine brings down the copper wait by increasing it,
; in fact the first time it will be executed it will change the
;
;	dc.w	$2007,$FFFE	; I wait for line $20
;
;	to:
;
;	dc.w	$2107,$FFFE	; wait for line $21! (then $22, $23 etc.)
;
; NOTE: once the maximum value for one byte, that is $ FF, is reached,
; if a further ADDQ.B #1 is performed, BAR restarts from 0,
; until you return to $ff and so on.

MoveCopper:
	addq.b	#1,BAR	; WAIT 1 changed, the bar drops 1 line
	add.w	#1,COLOUR ;change the colour each time also
	rts

; Try to change this ADDQ to SUBQ and the bar will go up !!!!

; Try changing the addq / subq # 1, BAR to # 2, # 3 or more and the speed
; it will increase, as each FRAME the wait will move by 2,3 or more lines.
; (if the number is greater than 8 instead of ADDQ.B you must use ADD.B)


;	DATA...


GfxName:
	dc.b	"graphics.library",0,0	; NOTE: to put in memory
									; characters always use the dc.b
									; and put them between "", or ''

GfxBase:		; Here goes the base address for
	dc.l	0	; the graphics.library Offset

OldCop:			; Here goes the address of the old system COP
	dc.l	0


;	GRAPHICS DATA...


	SECTION	GRAPHIC,DATA_C	; This command causes the system to load
							; this data segment
							; in CHIP RAM,
							; Copperlists MUST be in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, only background.

	dc.w	$180,$004	; COLOR0 - I start the copy with the DARK BLUE color

BAR:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79

	dc.w 	$180

COLOUR:
	dc.w	$600	; COLOR0 - I start the red zone: red at 6

	dc.w	$FFFF,$FFFE	; END OF COPPERLIST

	end


Ahh! I forgot to put the (PC) to "lea GfxName, a1", but now it's there.
Those who realized that it could be put in took a positive note.
In this program, a movement synchronized with the
electronic brush, in fact the bar goes down smoothly.

NOTE1: In this listing you can confuse the loop structure with the test
of the mouse plus the test of the position of the electron beam that
what you must be clear about is that the routines, or subroutines that are between
the mouse loop: and the WaitUp loop: are executed once every video frame:
in fact try to replace the bsr.s MoveCopper with the subroutine itself,
without the final RTS of course:

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we on line 255?
	bne.s	mouse		; If not yet, don't move on

;	bsr.s	MoveCopper	; A routine performed every frame
;				;(For fluidity)

	addq.b	#1,BAR	; WAIT 1 changed, the bar drops 1 line

WaitUp:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we on line 255?
	beq.s	WaitUp		; If yes, don't go ahead, WaitUp the line
				; following, otherwise MoveCopper is re-run

In this case the result does not change because instead of performing the ADDQ as
subroutine we execute it directly, and perhaps in this case it is even more
comfortable; but when the subroutines are longer it is worth doing several BSRs for
orient yourself. For example if you duplicate the MoveCopper bsr.s the routine will be
performed 2 times per frame, and it will double the speed:

	bsr.s	MoveCopper	; A routine performed every frame
	bsr.s	MoveCopper	; A routine performed every frame

The utility of subroutines lies in the greater clarity of the program,
imagine if our routines to put between mouse: and WaitUp: were of
thousands of lines! the succession of things would appear less clear. Instead
if we call each single routine by name, everything will appear easier.

*

To make the bar go down just change the COPPERLIST, in particular
in this example the WAIT is changed, in its first byte, that is
which defines the vertical line to wait for:

BAR:
	dc.w	$2007,$FFFE	; WAIT - I wait for line $20
	dc.w	$180,$600	; COLOR0 - I start the red zone: red at 6

By putting a label on that byte, you can change that byte by acting on the
label itself, in this case BAR.

CHANGES:
Try to change the color instead of the wait: just put a label
where you want in the copperlist and you can change what you like.
Bar the color like this:

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, only background.

	dc.w	$180,$004	; COLOR0 - I start the copy with the DARK BLUE color

;;;;BAR:			; ** CANCEL THE OLD LABEL with ;;
	dc.w	$7907,$FFFE	; WAIT - I wait for line $79

	dc.w	$180		; COLOR0
BAR:				; ** I PUT THE NEW LABEL TO THE VALUE OF COLOR.
	dc.w	$600	; I start the red zone: red at 6

	dc.w	$FFFF,$FFFE	; END OF COPPERLIST

You will get a variation of the intensity of the red, in fact we change the
first byte to the left of the color: $ 0RGB, that is the $ 0R, that is the RED !!!!

Now try to act on the entire color WORD: change the routine like this:

	addq.w	#1,BAR	; instead of .b we operate on .w
	rts

Try it and we will verify that the colors follow each other irregularly, 
in fact they are the result of the number 
that increases: $601, $602 ... $631, $632 ... generating colors not neatly.

NOTE: the dc.w command stores bytes, words or longs in memory,
therefore the same result can be obtained by writing:

	dc.w	$180,$600	; Color0

	OR:

	dc.w	$180	; Registro Color0
	dc.w	$600	; valore del color0

There are no syntax problems like with MOVE

