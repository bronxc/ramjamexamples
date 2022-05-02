;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Lesson7g.s A 16-COLOR SPRITE IN ATTACCHED MODE MOVED ON THE SCREEN
; USING TWO TABLES OF VALUES (i.e. vertical coordinates
; and horizontal) PRESET.


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	We target sprites 0 and 1, which ATTACCATI will form a 
;	single 16-color sprite. Sprite1, the odd one, 
;	must have bit 7 of the second word at 1.

	MOVE.L	#MIOSPRITE0,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE1,d0		; indirizzo dello sprite in d0
	addq.w	#8,a1			; prossimi SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	bset	#7,MIOSPRITE1+3		; Set the attach bit to 
	;	sprite 1. By removing this instruction, the sprites 
	;	are not attached, but two 3-color overlapping ones.

	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Linea 255?
	bne.s	mouse

	bsr.s	MuoviSpriteX	; Move sprite 0 horizontally
	bsr.w	MuoviSpriteY	; Move sprite 0 vertically

Aspetta:
	cmpi.b	#$ff,$dff006	; linea 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse pressed?
	bne.s	mouse

	; keep old copper, start my copper
	move.l	OldCop(PC),$dff080	
	move.w	d0,$dff088		

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

; This routine moves the sprite by acting on its 
; HSTART byte, that is the byte of its X position, 
; by entering the coordinates already established in the 
; TABX table. (Shots of 2 pixels at a time)

MuoviSpriteX:
	ADDQ.L	#1,TABXPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABXPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABX-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTX	; non ancora? allora continua
	MOVE.L	#TABX-1,TABXPOINT ; Riparti a puntare dal primo byte-1
NOBSTARTX:
	MOVE.b	(A0),MIOSPRITE0+1 ; copia il byte dalla tabella ad HSTART0
	MOVE.b	(A0),MIOSPRITE1+1 ; copia il byte dalla tabella ad HSTART1
	rts

TABXPOINT:
	dc.l	TABX-1		; NOTA: i valori della tabella sono bytes

; Tabella con coordinate X dello sprite precalcolate.

TABX:
	incbin	"hd1:develop/projects/dischi/SORGENTI3/XCOORDINAT.TAB"	; 334 valori
FINETABX:


; This routine moves the sprite up and down by acting on its VSTART and 
; VSTOP bytes, i.e. the bytes of its Y position of start and end, 
; by entering the coordinates already established in the TABY table

MuoviSpriteY:
	ADDQ.L	#1,TABYPOINT	 ; Fai puntare al byte successivo
	MOVE.L	TABYPOINT(PC),A0 ; indirizzo contenuto in long TABXPOINT
				 ; copiato in a0
	CMP.L	#FINETABY-1,A0  ; Siamo all'ultima longword della TAB?
	BNE.S	NOBSTARTY	; non ancora? allora continua
	MOVE.L	#TABY-1,TABYPOINT ; Riparti a puntare dal primo byte (-1)
NOBSTARTY:
	moveq	#0,d0		; Pulisci d0
	MOVE.b	(A0),d0		; copia il byte dalla tabella in d0
	MOVE.b	d0,MIOSPRITE0	; copia il byte in VSTART0
	MOVE.b	d0,MIOSPRITE1	; copia il byte in VSTART1
	ADD.B	#15,D0		; Aggiungi la lunghezza dello sprite per
				; determinare la posizione finale (VSTOP)
	move.b	d0,MIOSPRITE0+2	; Muovi il valore giusto in VSTOP0
	move.b	d0,MIOSPRITE1+2	; Muovi il valore giusto in VSTOP1
	rts

TABYPOINT:
	dc.l	TABY-1		; NOTA: i valori della tabella sono bytes

; Tabella con coordinate Y dello sprite precalcolate.

TABY:
	incbin	"hd1:develop/projects/dischi/SORGENTI3/YCOORDINAT.TAB"	; 200 valori
FINETABY:


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

;	Palette della PIC

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

;	Palette degli SPRITE attacched

	dc.w	$1A2,$FFC	; color17, COLORE 1 per gli sprite attaccati
	dc.w	$1A4,$EEB	; color18, COLORE 2 per gli sprite attaccati
	dc.w	$1A6,$CD9	; color19, COLORE 3 per gli sprite attaccati
	dc.w	$1A8,$AC8	; color20, COLORE 4 per gli sprite attaccati
	dc.w	$1AA,$8B6	; color21, COLORE 5 per gli sprite attaccati
	dc.w	$1AC,$6A5	; color22, COLORE 6 per gli sprite attaccati
	dc.w	$1AE,$494	; color23, COLORE 7 per gli sprite attaccati
	dc.w	$1B0,$384	; color24, COLORE 7 per gli sprite attaccati
	dc.w	$1B2,$274	; color25, COLORE 9 per gli sprite attaccati
	dc.w	$1B4,$164	; color26, COLORE 10 per gli sprite attaccati
	dc.w	$1B6,$154	; color27, COLORE 11 per gli sprite attaccati
	dc.w	$1B8,$044	; color28, COLORE 12 per gli sprite attaccati
	dc.w	$1BA,$033	; color29, COLORE 13 per gli sprite attaccati
	dc.w	$1BC,$012	; color30, COLORE 14 per gli sprite attaccati
	dc.w	$1BE,$001	; color31, COLORE 15 per gli sprite attaccati

	dc.w	$FFFF,$FFFE	; Fine della copperlist


; ************ Ecco gli sprite: OVVIAMENTE in CHIP RAM! **********

MIOSPRITE0:		; lunghezza 15 linee
VSTART0:
	dc.b $00	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART0:
	dc.b $00	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP0:
	dc.b $00	; posizione verticale di fine sprite
	dc.b $00

	dc.w $0380,$0650,$04e8,$07d0,$0534,$1868,$1e5c,$1636 ; dati dello
	dc.w $377e,$5514,$43a1,$1595,$0172,$1317,$6858,$5035 ; sprite 0
	dc.w $318c,$0c65,$7453,$27c9,$5ece,$5298,$0bfe,$2c32
	dc.w $005c,$13c4,$0be8,$0c18,$03e0,$03e0

	dc.w	0,0	; 2 word azzerate definiscono la fine dello sprite.



MIOSPRITE1:		; lunghezza 15 linee
VSTART1:
	dc.b $00	; Posizione verticale di inizio sprite (da $2c a $f2)
HSTART1:
	dc.b $00	; Posizione orizzontale di inizio sprite (da $40 a $d8)
VSTOP1:
	dc.b $00	; $50+13=$5d	; posizione verticale di fine sprite
	dc.b $00	; settare il bit 7 per attaccare sprite 0 ed 1.

	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e ; dati dello
	dc.w $58f2,$600e,$5873,$600f,$5cf1,$600f,$1ff3,$600f ; sprite 1
	dc.w $4fe3,$701f,$47c7,$783f,$6286,$7d7e,$300e,$3ffe
	dc.w $1c3c,$1ffc,$0ff8,$0ff8,$03e0,$03e0

	dc.w	0,0	; 2 word azzerate definiscono la fine dello sprite.


	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

Apart from the novelty of the ATTACCHED bit to make a 16-color sprite 
instead of two 4-color sprites, a couple of things should be noted:
1) The X and Y tables have been saved with the "WB" command and are 
loaded with the incbin, in this way the tables can be loaded from the 
various lists that require them, as long as they are on the disk!
2) The labels VSTART0, VSTART1, HSTART0, HSTART1 etc. are no longer 
used. to move the sprite. The labels remain in place in the sprite 
in this listing, but it is more convenient to "reach" the control 
bytes like this:

	MIOSPRITE	; Per VSTART
	MIOSPRITE+1	; Per HSTART
	MIOSPRITE+2	; Per VSTOP

In questo modo si puo' semplicemente cominciare lo sprite con:

MIOSPRITE:
	DC.W	0,0
	..dati...

Without dividing the two words into single bytes, each with a LABEL that lengthens
the listing.
Also to set bit 7 of word 2 of SPRITE1, that of ATTACCHED, this instruction 
was enough:

	bset	#7,MIOSPRITE1+3

Otherwise we could have set it "by hand" in the fourth byte:

MIOSPRITE1:
VSTART1:
	dc.b $00
HSTART1:
	dc.b $00
VSTOP1:
	dc.b $00
	dc.b %10000000		; oppure dc.b $80 ($80=%10000000)

If you have to use all 8 sprites you save a lot of label e
of space. Even better would be to put the address of the
sprites and offsets from that register:

	lea	MIOSPRITE,a0
	MOVE.B	#yy,(a0)	; Per VSTART
	MOVE.B	#xx,1(A0)	; Per HSTART
	MOVE.B	#y2,2(A0)	; Per VSTOP

Defining a 16-color sprite in binary becomes problematic.
So you have to resort to a drawing program, just remember 
to use a 16-color screen and to draw sprites no wider than 
16 pixels. Once you have saved the 16-color PIC (or a 
smaller BRUSH with the sprite) in IFF format, 
converting it with the IFFCONVERTER is as easy as converting a figure.

NOTE: By BRUSH we mean a piece of figure of variable size.

Here's how you can convert a sprite with KEFCON:

1) Load the IFF file, which must be 16 colors
2) You have to select only the sprite, to do this press the 
right button, then position yourself on the upper left corner 
of the future sprite, and press the left button. By moving the 
mouse, a grid will appear which, as it happens, is divided into 
strips 16 pixels wide. However, you can control the width and 
length of the selected block. To include the sprite well you have to
consider that you have to pass through the sprite border with the 
rectangle selection "strip", the last line included in the 
rectangle is the one that passes through the border strip, it 
is not the one inside the strip:

	<----- 16 pixel ----->

	|========####========| /\
	||     ########	    || ||
	||   ############   || ||
	|| ################ || ||
	||##################|| ||
	###################### ||
	###################### Lunghezza dello sprite, massimo 256 pixel
	###################### ||
	||##################|| ||
	|| ################ || ||
	||   ############   || ||
	||     ########     || ||
	|========####========| \/


If the sprite is smaller than 16 pixels you must leave an empty margin 
on the sides, or on one side only, so that the width of the block is always 16.

Once the sprite inside the rectangle has been selected, it must be 
saved as SPRITE16 if it is a 16-color sprite, or as SPRITE4 if it is 
a four-color sprite. The sprite is saved in "dc.b", ie in TEXT format, 
which you can include in the listing with the "I" command of the 
Asmone or by loading it in another text buffer and copying it with Amiga + b + c + i.

Here's how the KEFCON saves the attacked sprite (16 colors):

	dc.w $0000,$0000
	dc.w $0380,$0650,$04e8,$07d0,$0534,$1868,$1e5c,$1636
	dc.w $377e,$5514,$43a1,$1595,$0172,$1317,$6858,$5035
	dc.w $318c,$0c65,$7453,$27c9,$5ece,$5298,$0bfe,$2c32
	dc.w $005c,$13c4,$0be8,$0c18,$03e0,$03e0
	dc.w 0,0

	dc.w $0000,$0000
	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e
	dc.w $58f2,$600e,$5873,$600f,$5cf1,$600f,$1ff3,$600f
	dc.w $4fe3,$701f,$47c7,$783f,$6286,$7d7e,$300e,$3ffe
	dc.w $1c3c,$1ffc,$0ff8,$0ff8,$03e0,$03e0
	dc.w 0,0

As you can see, these are the two sprites with the two control words
cleared, the data in hexadecimal format and the two words cleared of END SPRITE.
Just put the two labels "MIOSPRITE0:" and "MIOSPRITE1:" at the beginning 
of the two sprites, after which working with MIOSPRITE + x to reach 
the byte of the coordinates it is not necessary to add other LABELS. 
The only particular is that you have to set the ATTACCHED bit 
with a BSET # 7, MIOSPRITE + 3 or directly in the sprite:

MIOSPRITE1:
	dc.w $0000,$0080	; $80, ossia %10000000 -> ATTACCHED!
	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e
	...

If you want to draw and convert the sprites to 4 colors too, the 
problem does not exist, because only one sprite is saved and t
here is no need to set the bit!

As for the color palette of the sprites, you have to save them 
from the KEFCON after saving the SPRITE16 or SPRITE4, with the 
COPPER option, just like for normal figures. The problem is 
that the palette is saved as a 16-COLOR FIGURE, and not as a SPRITE.
Here's how the KEFCON saves the palette:

	dc.w $0180,$0000,$0182,$0ffc,$0184,$0eeb,$0186,$0cd9
	dc.w $0188,$0ac8,$018a,$08b6,$018c,$06a5,$018e,$0494
	dc.w $0190,$0384,$0192,$0274,$0194,$0164,$0196,$0154
	dc.w $0198,$0044,$019a,$0033,$019c,$0012,$019e,$0001

The colors are fair, but the color registers refer to the first 16 colors
and not the last 16. Just rewrite them "by hand" in the right color registers:

	dc.w	$1A2,$FFC	; color17, COLORE 1 per gli sprite attaccati
	dc.w	$1A4,$EEB	; color18, COLORE 2 per gli sprite attaccati
	dc.w	$1A6,$CD9	; color19, COLORE 3 per gli sprite attaccati
	dc.w	$1A8,$AC8	; color20, COLORE 4 per gli sprite attaccati
	dc.w	$1AA,$8B6	; color21, COLORE 5 per gli sprite attaccati
	dc.w	$1AC,$6A5	; color22, COLORE 6 per gli sprite attaccati
	dc.w	$1AE,$494	; color23, COLORE 7 per gli sprite attaccati
	dc.w	$1B0,$384	; color24, COLORE 7 per gli sprite attaccati
	dc.w	$1B2,$274	; color25, COLORE 9 per gli sprite attaccati
	dc.w	$1B4,$164	; color26, COLORE 10 per gli sprite attaccati
	dc.w	$1B6,$154	; color27, COLORE 11 per gli sprite attaccati
	dc.w	$1B8,$044	; color28, COLORE 12 per gli sprite attaccati
	dc.w	$1BA,$033	; color29, COLORE 13 per gli sprite attaccati
	dc.w	$1BC,$012	; color30, COLORE 14 per gli sprite attaccati
	dc.w	$1BE,$001	; color31, COLORE 15 per gli sprite attaccati

Note that in $1a2 you have to copy the color in $182, in $1a4 the color in $184 and so on.

Try replacing the 16-color sprite in this listing with your own, 
with your own color palette, and also converting a 4-color sprite from
replace that of the previous lessons. Doing it will serve as verification !!!

