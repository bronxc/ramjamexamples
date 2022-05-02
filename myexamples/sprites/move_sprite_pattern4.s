;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
; Sprite test

	SECTION CODE,CODE
Init:
	;Get execbase and load graphics lib etc
	move.l	4.w,a6
	jsr	-$78(a6)
	lea	GfxName(PC),a1
	jsr	-$198(a6)
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop

	;setup 1 bitplane
	MOVE.L	#BitPlane,d0
	LEA	BPLPointers,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	;setup 1 sprite
	MOVE.L	#MySprite,d0
	LEA	SpritePointers,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	;setup & start copperlist, no AGA
	move.l	#CopperList,$dff080
	move.w	d0,$dff088
	move.w	#0,$dff1fc
	move.w	#$c00,$dff106

MainLoop:
	;wait for a frame
	cmpi.b	#$ff,$dff006
	bne.s MainLoop

	;right mouse pressed?
	btst	#2,$dff016
	bne.s	DetectExitProgram

	bsr.w MoveSpriteOnX
	bsr.w MoveSpriteOnY

;Cleanup, put back old copper and exit
DetectExitProgram:
	cmpi.b	#$ff,$dff006
	beq.s	DetectExitProgram

	btst	#6,$bfe001	; left mouse pressed?
	bne.s	MainLoop

	move.l	OldCop(PC),$dff080	
	move.w	d0,$dff088		

	move.l	4.w,a6
	jsr	-$7e(a6)
	move.l	GfxBase(PC),a1
	jsr	-$19e(a6)
	rts

MoveSpriteOnX:
	ADDQ.L	#1,TABXPOINTER	 ; Point to the next byte
	MOVE.L	TABXPOINTER(PC),A0 ; contained in long TABXPOINTER copied to a0
	CMP.L	#ENDTABX-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	UPDATEX	; not yet? then continue
	MOVE.L	#TABX-1,TABXPOINTER ; You start again from the first byte-1
UPDATEX:
	MOVE.b	(A0),HSTART	; copy the byte from the table to HSTART
	rts
	rts

TABXPOINTER:
	dc.l	TABX-1

; My table of precalculated X axis values. Display window means 
; values must be between $40 and $d8 to be seen on screen
TABX:
	dc.b	$CF,$CD,$CA,$C8,$C6,$C4,$C1,$BF,$BD,$BB,$B8,$B6
	dc.b	$B4,$B2,$AF,$AD,$AB,$A9,$A7,$A5,$A2,$A0,$9E,$9C
	dc.b	$9A,$98,$96,$94,$92,$90,$8E,$8C,$8A,$88,$86,$84
	dc.b	$82,$80,$7E,$7C,$7A,$79,$77,$75,$73,$72,$70,$6E
	dc.b	$6D,$6B,$69,$68,$66,$65,$63,$62,$60,$5F,$5E,$5C
	dc.b	$5B,$5A,$58,$57,$56,$55,$53,$52,$51,$50,$4F,$4E
	dc.b	$4D,$4C,$4B,$4B,$4A,$49,$48,$47,$47,$46,$45,$45
	dc.b	$44,$44,$43,$43,$42,$42,$42,$41,$41,$41,$41,$40
	dc.b	$40,$40,$40,$40,$40,$40,$40,$40,$40,$41,$41,$41
	dc.b	$41,$42,$42,$42,$43,$43,$44,$44,$45,$45,$46,$47
	dc.b	$47,$48,$49,$4A,$4B,$4B,$4C,$4D,$4E,$4F,$50,$51
	dc.b	$52,$53,$55,$56,$57,$58,$5A,$5B,$5C,$5E,$5F,$60
	dc.b	$62,$63,$65,$66,$68,$69,$6B,$6D,$6E,$70,$72,$73
	dc.b	$75,$77,$79,$7A,$7C,$7E,$80,$82,$84,$86,$88,$8A
	dc.b	$8C,$8E,$90,$92,$94,$96,$98,$9A,$9C,$9E,$A0,$A2
	dc.b	$A5,$A7,$A9,$AB,$AD,$AF,$B2,$B4,$B6,$B8,$BB,$BD
	dc.b	$BF,$C1,$C4,$C6,$C8,$CA,$CD,$CF
ENDTABX:

	EVEN;

MoveSpriteOnY:
	ADDQ.L	#1,TABYPOINTER
	MOVE.L	TABYPOINTER(PC),A0
	CMP.L	#ENDTABY-1,A0
	BNE.S	UPDATEY
	MOVE.L	#TABY-1,TABYPOINTER
UPDATEY:
	moveq	#0,d0
	MOVE.b	(A0),d0
	MOVE.b	d0,VSTART
	ADD.B	#13,D0 ; sprinte is 13 pixels high
	move.b	d0,VSTOP
	rts

TABYPOINTER:
	dc.l	TABY-1

TABY:


	DC.B	$8E,$87,$7F,$78,$70,$69,$62,$5B,$55,$4F,$49,$44,$3F,$3B,$37,$34
	DC.B	$31,$2F,$2E,$2D,$2C,$2D,$2E,$2F,$31,$34,$37,$3B,$3F,$44,$49,$4F
	DC.B	$55,$5B,$62,$69,$70,$78,$7F,$87

ENDTABY:

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

	SECTION	GRAPHICS,DATA_C

CopperList:
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

	;1 low res bitplane
	dc.w	$100,%0001001000000000

BPLPointers:
	dc.w $e0,0,$e2,0	;1st BitPlane

	dc.w	$180,$000	;Col1
	dc.w	$182,$123	;Col1

	;sprite 0 colours 17, 18, 19
	dc.w	$1A2,$F00
	dc.w	$1A4,$0F0
	dc.w	$1A6,$FF0

	;end copperlist
	dc.w	$FFFF,$FFFE

;13 lines long sprite
MySprite:
VSTART:
	dc.b $2c+128
HSTART:
	dc.b $40+(160/2)
VSTOP:
	dc.b $2c+128+13
	dc.b $00

	dc.w	%0000000000000000,%0000110000110000
	dc.w	%0000000000000000,%0000011001100000
	dc.w	%0000000000000000,%0000001001000000
	dc.w	%0000000110000000,%0011000110001100
	dc.w	%0000011111100000,%0110011111100110
	dc.w	%0000011111100000,%1100100110010011
	dc.w	%0000110110110000,%1111100110011111
	dc.w	%0000011111100000,%0000011111100000
	dc.w	%0000011111100000,%0001111001111000
	dc.w	%0000001111000000,%0011101111011100
	dc.w	%0000000110000000,%0011000110001100
	dc.w	%0000000000000000,%1111000000001111
	dc.w	%0000000000000000,%1111000000001111
	dc.w	0,0	;end of sprite

	SECTION	PLANEVUOTO,BSS_C

BitPlane:
	ds.b	40*256

	end
