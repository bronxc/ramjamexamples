;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Lezione7a.s		VISUALIZZAZIONE DI UNO SPRITE


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Setup 1 bitplane

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Setup 1 sprite pointer

	MOVE.L	#MYSPRITE,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
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


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
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
	dc.w	$100,%0001001000000000	; bit 12 acceso!! 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.
	; sprite colours					
	dc.w	$1A2,$F00	; color17, ossia COLOR1 dello sprite0 - ROSSO
	dc.w	$1A4,$0F0	; color18, ossia COLOR2 dello sprite0 - VERDE
	dc.w	$1A6,$FF0	; color19, ossia COLOR3 dello sprite0 - GIALLO

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco lo sprite: OVVIAMENTE deve essere in CHIP RAM! ************

MYSPRITE:		; lunghezza 13 linee
VSTART:
	dc.b $2c+128	; Vertical sprite start position ($2c to $f2)
HSTART:
	dc.b $40+(160/2)	; Horizontal sprite start position ($ 40 to $ d8)
VSTOP:
	dc.b $2c+128+13	; $30+13=$3d	; vertical position of end of sprite
	dc.b $00
 dc.w	%0000000000000000,%0000110000110000 ; Formato binario per modifiche
 dc.w	%0000000000000000,%0000011001100000
 dc.w	%0000000000000000,%0000001001000000
 dc.w	%0000000110000000,%0011000110001100 ;BINARIO 00=COLORE 0 (TRASPARENTE)
 dc.w	%0000011111100000,%0110011111100110 ;BINARIO 10=COLORE 1 (ROSSO)
 dc.w	%0000011111100000,%1100100110010011 ;BINARIO 01=COLORE 2 (VERDE)
 dc.w	%0000110110110000,%1111100110011111 ;BINARIO 11=COLORE 3 (GIALLO)
 dc.w	%0000011111100000,%0000011111100000
 dc.w	%0000011111100000,%0001111001111000
 dc.w	%0000001111000000,%0011101111011100
 dc.w	%0000000110000000,%0011000110001100
 dc.w	%0000000000000000,%1111000000001111
 dc.w	%0000000000000000,%1111000000001111
 dc.w	0,0	; 2 word azzerate definiscono la fine dello sprite.


	SECTION	PLANEVUOTO,BSS_C	; The reset bitplane we use, 
	; because to see the sprites it is necessary 
	; that there are bitplanes enabled

BITPLANE:
	ds.b	40*256		; bitplane reset lowres

	end

This is the first sprite we check in the course, you can easily
define your own by changing its 2 floors, which in this listing are
defined in binary; the color resulting from the various overlaps
binary can be guessed by reading the comment next to the sprite.
The colors of sprite 0 are defined by the COLOR registers 17,18 and 19:

	dc.w	$1A2,$F00	; color17, ossia COLOR1 dello sprite0 - ROSSO
	dc.w	$1A4,$0F0	; color18, ossia COLOR2 dello sprite0 - VERDE
	dc.w	$1A6,$FF0	; color19, ossia COLOR3 dello sprite0 - GIALLO

Per cambiare la posizione dello sprite, agite sui suoi primi byte:

MYSPRITE:		; length 13 lines
VSTART:
	dc.b $2c	; Vertical sprite start position ($2c to $f2)
HSTART:
	dc.b $90	; Horizontal sprite start position ($40 to $d8)
VSTOP:
	dc.b $3d	; $30+13=$3d	; vertical position of end sprite
	dc.b $00

Basta ricordarsi queste due cose:

1) The top left corner of the screen is not the $00, $00 position
in fact the screen with the overscan can be wider; in the case of
normal width screen the initial horizontal position (HSTART) can
go from $40 to $d8, otherwise the sprite gets "cut" or goes right out
from the visible screen. Similarly the initial vertical position, ie
the VSTART, must be selected starting from $2c, that is, from the beginning of the window
video defined in DIWSTART (which here is $2c81).
To position the sprite on the 320x256 screen, for example at the coordinate
central 160,128 it is necessary to take into account that the first coordinate in the upper left
is $40, $2c instead of 0.0 so you have to add $ 40 to the X coordinate and $2c
to the Y coordinate.
In fact, $40 + 160, $2c + 128, correspond to the coordinate 160,128 of a screen
320x256 not overscan.
Not yet having control of the horizontal position at level 1
pixels, but every 2 pixels, we need to add up not 160, but 160/2 at the beginning for
locate the center of the screen:

HSTART:
	dc.b $40+(160/2)	; located in the center of the screen

So for other horizontal coordinates, for example position 50:

	dc.b $40+(50/2)

Later we will see how to position horizontally 1 pixel at a time.

2) The horizontal position can be varied by itself to move to the right and a
left a sprite, while if you intend to move the sprite up or down
it is necessary every time to act on two bytes, ie on VSTART and VSTOP, ie the
vertical position of start and end sprite. In fact, while the width of
a sprite is always 16, so the horizontal starting position is determined
the end position is always 16 pixels further to the right, as far as the
vertical length, being at will, it is necessary to define it by communicating
the start and end position each time, so if we want to move it
sprite at the top we have to subtract 1 from both VSTART and VSTOP if we want
move it down instead you need to add 1 to both.
For example if you want to change the VSTART to $55, to determine VSTOP
it will be necessary to add the length of the sprite (this is 13 lines high) a
VSTART, so $55 + 13 = $62.

Move the sprite to various positions on the screen to check if you have
understood or if you only have the illusion of having understood.
Don't forget that HSTART moves 2 pixels each time and not 1
pixels as it might seem.

