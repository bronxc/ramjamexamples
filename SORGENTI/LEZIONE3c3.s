;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Lesson3c3.s; DROP DOWN BAR MADE WITH COPPER MOVE & WAIT
; (TO MOVE IT DOWN USE THE RIGHT BUTTON OF THE MOUSE)


	SECTION	SfumaCop,CODE	; also in Fast is fine

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC routine that opens
				; the libraries, and outputs the address
				; of that library to make the
				; addressing distances (Offset)
	move.l	d0,GfxBase	; save the GFX base address in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; we save the address of the system copperlist

	move.l	#COPPERLIST,$dff080	; COP1LC - We pont to our COP
	move.w	d0,$dff088		; COPJMP1 - Facciamo partire la COP
mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we on line 255?
	bne.s	mouse		; If not yet, don't move on

	btst	#2,$dff016	; POTINP - Right mouse button pressed?
	bne.s	Wait		; If not, don't run Muovicopper

	bsr.s	MuoviCopper	; 1 frame timed routine

Wait:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we on line 255?
	beq.s	Wait		; If yes, don't go ahead, wait for the line
				; following, otherwise MoveCopper comes
				; rerun

	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	mouse		; if not, back to mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - We target the system cop
	move.w	d0,$dff088		; COPJMP1 - let's start the cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - re-enable Multitasking
	move.l	GfxBase(PC),a1	; Base of the library to close
					; (libraries must be opened and closed !!!)
	jsr	-$19e(a6)	; Closelibrary - I close the graphics lib
	rts


;	This routine moves down a bar consisting of 10 waits

MuoviCopper:
	cmpi.b	#$fa,BARRA10	; is the last line of the bar at the bottom of the screen?
	beq.s	Finish		; if yes, we are at the bottom and we do not continue
	addq.b	#1,BARRA	; WAIT 1 changed
	addq.b	#1,BARRA2	; WAIT 2 changed
	addq.b	#1,BARRA3	; WAIT 3 changed
	addq.b	#1,BARRA4	; WAIT 4 changed
	addq.b	#1,BARRA5	; WAIT 5 changed
	addq.b	#1,BARRA6	; WAIT 6 changed
	addq.b	#1,BARRA7	; WAIT 7 changed
	addq.b	#1,BARRA8	; WAIT 8 changed
	addq.b	#1,BARRA9	; WAIT 9 changed
	addq.b	#1,BARRA10	; WAIT 10 changed
Finish:
	rts

	; From here we put the data ...


GfxName:
	dc.b	"graphics.library",0,0	; NOTE: to put in memory
							; characters always use the dc.b
							; and put them between "", or ''

GfxBase:		; The base address for Offsets
	dc.l	0	; of graphics.library

OldCop:			; The address of the old system COP
	dc.l	0


; Here is the COPPERLIST, pay attention to the BARRA labels !!!!


	SECTION	CoppyMagic,DATA_C ; Copperlists MUST be in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - background color only
	dc.w	$180,$000	; COLOR0 - I start the copy with the color BLACK

BARRA:
	dc.w	$7907,$FFFE	; WAIT - Wait for the $79 line
	dc.w	$180,$300	; COLOR0 - Start the red bar: red at 3
BARRA2:
	dc.w	$7a07,$FFFE	; WAIT - next line
	dc.w	$180,$600	; COLOR0 - red at 6
BARRA3:
	dc.w	$7b07,$FFFE
	dc.w	$180,$900	; red at 9
BARRA4:
	dc.w	$7c07,$FFFE
	dc.w	$180,$c00	; red at 12
BARRA5:
	dc.w	$7d07,$FFFE
	dc.w	$180,$f00	; red at 15 (at highest)
BARRA6:
	dc.w	$7e07,$FFFE
	dc.w	$180,$c00	; red at 12
BARRA7:
	dc.w	$7f07,$FFFE
	dc.w	$180,$900	; red at 9
BARRA8:
	dc.w	$8007,$FFFE
	dc.w	$180,$600	; red at 6
BARRA9:
	dc.w	$8107,$FFFE
	dc.w	$180,$300	; red at 3
BARRA10:
	dc.w	$8207,$FFFE
	dc.w	$180,$000	; colore black

	dc.w	$FFFF,$FFFE	; END OF COPPER LIST


	end

To make the bar go down just change the COPPERLIST, in particular
in this example the various WAITs that make up the bar are changed to
their first byte, i.e. the one that defines the vertical line to wait:

BARRA:
	dc.w	$7907,$FFFE	; WAIT - aspetto la linea $79
	dc.w	$180,$300	; COLOR0 - inizio la barra rossa: red at 3
BARRA2:
	dc.w	$7a07,$FFFE	; linea seguente
	dc.w	$180,$600	; red at 6
	...

By putting a label on that byte, you can change that byte by acting on the
label itself, in this case BAR.

*******************************************************************************

I advise you to make many changes, even the most random, for
get familiar with COPPER: I recommend some of them:

EDIT1: try to put some; to the first 5 ADDQ.b in this way:

;	addq.b	#1,BARRA	; WAIT 1 cambiato
;	addq.b	#1,BARRA2	; WAIT 2 cambiato
;	addq.b	#1,BARRA3	; WAIT 3 cambiato
;	addq.b	#1,BARRA4	; WAIT 4 cambiato
;	addq.b	#1,BARRA5	; WAIT 5 cambiato
	addq.b	#1,BARRA6	; WAIT 6 cambiato
	addq.b	#1,BARRA7	; WAIT 7 cambiato
	....

You will get the effect "CLOSE THE CURTAIN", in fact the descent starts in this way
from the middle of the bar, and, since the last color is valid until not
it is changed, in this case the last color before the wait of the part
bottom of the bar that goes to the bottom is RED, so it seems that the bar does
stretch all the way to the bottom of the screen. Remove the; and let's move on to modification 2.

EDIT2: To obtain a "ZOOM" effect, modify as follows: (use Amiga + b + c + i)

	addq.b	#1,BARRA
	addq.b	#2,BARRA2
	addq.b	#3,BARRA3
	addq.b	#4,BARRA4
	addq.b	#5,BARRA5
	addq.b	#6,BARRA6
	addq.b	#7,BARRA7
	addq.b	#8,BARRA8
	addq.b	#8,BARRA9
	addq.b	#8,BARRA10

Did you understand why the bar expands? Because instead of going low
together the waits have different "speeds", so the lower ones are separated
from the higher ones.


EDIT3: This time we will "expand" the bar not down, as in
previous case, but centrally:

	subq.b	#5,BARRA
	subq.b	#4,BARRA2
	subq.b	#3,BARRA3
	subq.b	#2,BARRA4
	subq.b	#1,BARRA5
	addq.b	#1,BARRA6
	addq.b	#2,BARRA7
	addq.b	#3,BARRA8
	addq.b	#4,BARRA9
	addq.b	#5,BARRA10

In fact we have changed the first 5 addq to subq, therefore the upper part
of the bar in this case goes up instead of going down, and goes up in a similar way
to that of the previous "zoom", in fact the "speeds" are 5,4,3,2,1,
while the 5 addqs do the same for the lower part.


