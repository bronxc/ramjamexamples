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
	dc.b	$91,$93,$96,$98,$9A,$9C,$9F,$A1,$A3,$A5,$A7,$A9 ; 200 values
	dc.b	$AC,$AE,$B0,$B2,$B4,$B6,$B8,$B9,$BB,$BD,$BF,$C0
	dc.b	$C2,$C4,$C5,$C7,$C8,$CA,$CB,$CC,$CD,$CF,$D0,$D1
	dc.b	$D2,$D3,$D3,$D4,$D5,$D5,$D6,$D7,$D7,$D7,$D8,$D8
	dc.b	$D8,$D8,$D8,$D8,$D8,$D8,$D7,$D7,$D7,$D6,$D5,$D5
	dc.b	$D4,$D3,$D3,$D2,$D1,$D0,$CF,$CD,$CC,$CB,$CA,$C8
	dc.b	$C7,$C5,$C4,$C2,$C0,$BF,$BD,$BB,$B9,$B8,$B6,$B4
	dc.b	$B2,$B0,$AE,$AC,$A9,$A7,$A5,$A3,$A1,$9F,$9C,$9A
	dc.b	$98,$96,$93,$91,$8F,$8D,$8A,$88,$86,$84,$81,$7F
	dc.b	$7D,$7B,$79,$77,$74,$72,$70,$6E,$6C,$6A,$68,$67
	dc.b	$65,$63,$61,$60,$5E,$5C,$5B,$59,$58,$56,$55,$54
	dc.b	$53,$51,$50,$4F,$4E,$4D,$4D,$4C,$4B,$4B,$4A,$49
	dc.b	$49,$49,$48,$48,$48,$48,$48,$48,$48,$48,$49,$49
	dc.b	$49,$4A,$4B,$4B,$4C,$4D,$4D,$4E,$4F,$50,$51,$53
	dc.b	$54,$55,$56,$58,$59,$5B,$5C,$5E,$60,$61,$63,$65
	dc.b	$67,$68,$6A,$6C,$6E,$70,$72,$74,$77,$79,$7B,$7D
	dc.b	$7F,$81,$84,$86,$88,$8A,$8D,$8F
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
	DC.B	$8E,$91,$94,$97,$9A,$9D,$A0,$A3,$A6,$A9,$AC,$AF,$B2,$B4,$B7,$BA
	DC.B	$BD,$BF,$C2,$C5,$C7,$CA,$CC,$CE,$D1,$D3,$D5,$D7,$D9,$DB,$DD,$DF
	DC.B	$E0,$E2,$E3,$E5,$E6,$E7,$E9,$EA,$EB,$EC,$EC,$ED,$EE,$EE,$EF,$EF
	DC.B	$EF,$EF,$F0,$EF,$EF,$EF,$EF,$EE,$EE,$ED,$EC,$EC,$EB,$EA,$E9,$E7
	DC.B	$E6,$E5,$E3,$E2,$E0,$DF,$DD,$DB,$D9,$D7,$D5,$D3,$D1,$CE,$CC,$CA
	DC.B	$C7,$C5,$C2,$BF,$BD,$BA,$B7,$B4,$B2,$AF,$AC,$A9,$A6,$A3,$A0,$9D
	DC.B	$9A,$97,$94,$91,$8E,$8B,$88,$85,$82,$7F,$7C,$79,$76,$73,$70,$6D
	DC.B	$6A,$68,$65,$62,$5F,$5D,$5A,$57,$55,$52,$50,$4E,$4B,$49,$47,$45
	DC.B	$43,$41,$3F,$3D,$3C,$3A,$39,$37,$36,$35,$33,$32,$31,$30,$30,$2F
	DC.B	$2E,$2E,$2D,$2D,$2D,$2D,$2C,$2D,$2D,$2D,$2D,$2E,$2E,$2F,$30,$30
	DC.B	$31,$32,$33,$35,$36,$37,$39,$3A,$3C,$3D,$3F,$41,$43,$45,$47,$49
	DC.B	$4B,$4E,$50,$52,$55,$57,$5A,$5D,$5F,$62,$65,$68,$6A,$6D,$70,$73
	DC.B	$76,$79,$7C,$7F,$82,$85,$88,$8B
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
