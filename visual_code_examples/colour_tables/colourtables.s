;------------------------------
; Example inspired by Photon's Tutorial:
;  https://www.youtube.com/user/ScoopexUs
;
;---------- Includes ----------
              INCDIR      "include"
              INCLUDE     "hw.i"
              INCLUDE     "funcdef.i"
              INCLUDE     "exec/exec_lib.i"
              INCLUDE     "graphics/graphics_lib.i"
              INCLUDE     "hardware/cia.i"
;---------- Const ----------

	SECTION	CiriCop,CODE

Init:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	btst	#2,$dff016	; tasto destro?
	beq.s	Wait

	bsr.w	Flashing	; Flashes Color0 in copperlist

Wait:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Wait

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	GfxBase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

;	Flashing routine that uses a TABLE of ready-made shades. The TABLE 
;	is nothing more than a series of words containing the various RGB 
;	values that COLOR1 will have to assume in the various frames.
;	Note that the table is "read" in this way: we start by copying 
;	the first word, then every time it is re-executed in the following 
;	frames the routine copies the second word, the third, the 
;	fourth and so on, until it reachs the last value of the 
;	table, at the ENDCOLORTAB label, then it reverses the direction with
;	BCHG.B #1, DIRECTIONFLAG, and proceeds by reading "backwards" each time
;	until it goes back to the first word, then it changes DIRECTIONFLAG again
;	and resumes reading "forward".
;	NOTE: this routine is useful when the "increasing" values of the
;	table, once the "maximum" is reached, they reverse equally
;	how they increased: in this case, we should have written
;	a table like this:;	

;	dc.w 0,1,2,3,4,5,6,7,8,9,10; progression up to the maximum
;	dc.w 10,9,8,7,6,5,4,3,2,1,0; drop to a minimum;	

;	But with this routine you can write only half of the TABLE,
;	ie until 10, it will be the routine to "go back" once
;	reached the maximum: 9,8,7,6,5,4 ..., saving space in the
;	listing, and time if the values are written "by hand".
;	If the table was not "mirrored", that is, of this type:;	

;	dc.b 0,2,3,5,6,7,8,9,10
;	dc.b 9,8,7,6,4,3,2,1,0;	

;	A routine would have been used that reads the whole table, from the first
;	value at the last, but which instead of re-reading backwards once
;	when the deadline is reached, you start over.

Flashing:
	BTST	#1,DIRECTIONFLAG	; do we have to read the 
	BEQ.S	GOUP		; words of the table forwards backwards ??
GODOWN:
	SUBQ.L	#2,COLTABPOINTER	; Point to the previous word
	MOVE.L	COLTABPOINTER(PC),A0 ; address contained in long COLTABPOINTER
                                   ; copied to a0
	CMP.L	#COLORTAB,A0	; Have we arrived at the first value of the TABLE?
	BNE.S	NOBSTART2
	BCHG.B	#1,DIRECTIONFLAG	; change direction, go forward!
NOBSTART2:
	MOVE.W	(A0),COLORE0	; copy the word from the table to the color COP
	rts

GOUP:
	ADDQ.L	#2,COLTABPOINTER	   ; Point to the next word Address in COLTABPOINTER copied to a0
	MOVE.L	COLTABPOINTER(PC),A0 ; copied to a0. 
	CMP.L	#ENDCOLORTAB-2,A0 ; Are we at the last word of the TAB?
	BNE.S	DONOTCHANGEDIRECTION ; If not yet, don't change anything change direction, go backwards
	BCHG.B	#1,DIRECTIONFLAG	   
DONOTCHANGEDIRECTION:
	MOVE.W	(A0),COLORE0	; copy the word from the table to the color COP
	rts

DIRECTIONFLAG:			; FLAG label used to indicate direction
	DC.W	0		; of reading


COLTABPOINTER:			; This longword "POINTS" to COLORTAB,  
	dc.l	COLORTAB-2	; ie it contains the address of COLORTAB.
				; Keep the address of the last word "read" inside the table.

;The table with the "pre-calculated" values of the flashing of color0

COLORTAB:
	dc.w	$000,$000,$001,$011,$011,$011,$012,$012	; starting dark
	dc.w	$022,$022,$022,$023,$023
	dc.w	$033,$033,$034
	dc.w	$044,$044
	dc.w	$045,$055,$055
	dc.w	$056,$056,$066,$066,$066
	dc.w	$167,$167,$177,$177,$177,$177,$177
	dc.w	$278,$278,$278,$288,$288,$288,$288,$288
	dc.w	$389,$389,$399,$399,$399,$399
	dc.w	$39a,$39a,$3aa,$3aa,$3aa
	dc.w	$3ab,$3bb,$3bb,$3bb
	dc.w	$4bc,$4cc,$4cc,$4cc
	dc.w	$4cd,$4cd,$4dd,$4dd,$4dd
	dc.w	$5de,$5de,$5ee,$5ee,$5ee,$5ee
	dc.w	$6ef,$6ff,$6ff,$7ff,$7ff,$8ff,$8ff,$9ff	
	dc.w	$aff,$bff,$cff,$dff,$eff,$fff ; maximum is white!
ENDCOLORTAB:


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
              ; 5432109876543210
	dc.w	$100,%0000001000000000	; 0 bitplane LOWRES

	dc.w	$180,$000	; color0

	dc.w	$a007,$fffe	; Wait linea $a0
	dc.w	$180
COLORE0:
	dc.w	$000	; color0

	dc.w	$c007,$fffe	;Wait linea $c0
	dc.w	$180,$000	; color0

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	end