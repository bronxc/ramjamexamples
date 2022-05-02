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

	DC.B	$8E,$8E,$8F,$90,$91,$91,$92,$93,$94,$94,$95,$96,$97,$97,$98,$99
	DC.B	$9A,$9B,$9B,$9C,$9D,$9E,$9E,$9F,$A0,$A1,$A1,$A2,$A3,$A4,$A4,$A5
	DC.B	$A6,$A7,$A7,$A8,$A9,$AA,$AA,$AB,$AC,$AD,$AD,$AE,$AF,$AF,$B0,$B1
	DC.B	$B2,$B2,$B3,$B4,$B4,$B5,$B6,$B7,$B7,$B8,$B9,$B9,$BA,$BB,$BB,$BC
	DC.B	$BD,$BD,$BE,$BF,$BF,$C0,$C1,$C1,$C2,$C3,$C3,$C4,$C5,$C5,$C6,$C6
	DC.B	$C7,$C8,$C8,$C9,$CA,$CA,$CB,$CB,$CC,$CD,$CD,$CE,$CE,$CF,$CF,$D0
	DC.B	$D1,$D1,$D2,$D2,$D3,$D3,$D4,$D4,$D5,$D5,$D6,$D6,$D7,$D8,$D8,$D9
	DC.B	$D9,$D9,$DA,$DA,$DB,$DB,$DC,$DC,$DD,$DD,$DE,$DE,$DF,$DF,$DF,$E0
	DC.B	$E0,$E1,$E1,$E1,$E2,$E2,$E3,$E3,$E3,$E4,$E4,$E4,$E5,$E5,$E6,$E6
	DC.B	$E6,$E6,$E7,$E7,$E7,$E8,$E8,$E8,$E9,$E9,$E9,$E9,$EA,$EA,$EA,$EA
	DC.B	$EB,$EB,$EB,$EB,$EC,$EC,$EC,$EC,$EC,$ED,$ED,$ED,$ED,$ED,$ED,$EE
	DC.B	$EE,$EE,$EE,$EE,$EE,$EE,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF
	DC.B	$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$F0,$EF,$EF,$EF,$EF,$EF,$EF,$EF
	DC.B	$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EE,$EE,$EE,$EE,$EE
	DC.B	$EE,$EE,$ED,$ED,$ED,$ED,$ED,$ED,$EC,$EC,$EC,$EC,$EC,$EB,$EB,$EB
	DC.B	$EB,$EA,$EA,$EA,$EA,$E9,$E9,$E9,$E9,$E8,$E8,$E8,$E7,$E7,$E7,$E6
	DC.B	$E6,$E6,$E6,$E5,$E5,$E4,$E4,$E4,$E3,$E3,$E3,$E2,$E2,$E1,$E1,$E1
	DC.B	$E0,$E0,$DF,$DF,$DF,$DE,$DE,$DD,$DD,$DC,$DC,$DB,$DB,$DA,$DA,$D9
	DC.B	$D9,$D9,$D8,$D8,$D7,$D6,$D6,$D5,$D5,$D4,$D4,$D3,$D3,$D2,$D2,$D1
	DC.B	$D1,$D0,$CF,$CF,$CE,$CE,$CD,$CD,$CC,$CB,$CB,$CA,$CA,$C9,$C8,$C8
	DC.B	$C7,$C6,$C6,$C5,$C5,$C4,$C3,$C3,$C2,$C1,$C1,$C0,$BF,$BF,$BE,$BD
	DC.B	$BD,$BC,$BB,$BB,$BA,$B9,$B9,$B8,$B7,$B7,$B6,$B5,$B4,$B4,$B3,$B2
	DC.B	$B2,$B1,$B0,$AF,$AF,$AE,$AD,$AD,$AC,$AB,$AA,$AA,$A9,$A8,$A7,$A7
	DC.B	$A6,$A5,$A4,$A4,$A3,$A2,$A1,$A1,$A0,$9F,$9E,$9E,$9D,$9C,$9B,$9B
	DC.B	$9A,$99,$98,$97,$97,$96,$95,$94,$94,$93,$92,$91,$91,$90,$8F,$8E
	DC.B	$8E,$8E,$8D,$8C,$8B,$8B,$8A,$89,$88,$88,$87,$86,$85,$85,$84,$83
	DC.B	$82,$81,$81,$80,$7F,$7E,$7E,$7D,$7C,$7B,$7B,$7A,$79,$78,$78,$77
	DC.B	$76,$75,$75,$74,$73,$72,$72,$71,$70,$6F,$6F,$6E,$6D,$6D,$6C,$6B
	DC.B	$6A,$6A,$69,$68,$68,$67,$66,$65,$65,$64,$63,$63,$62,$61,$61,$60
	DC.B	$5F,$5F,$5E,$5D,$5D,$5C,$5B,$5B,$5A,$59,$59,$58,$57,$57,$56,$56
	DC.B	$55,$54,$54,$53,$52,$52,$51,$51,$50,$4F,$4F,$4E,$4E,$4D,$4D,$4C
	DC.B	$4B,$4B,$4A,$4A,$49,$49,$48,$48,$47,$47,$46,$46,$45,$44,$44,$43
	DC.B	$43,$43,$42,$42,$41,$41,$40,$40,$3F,$3F,$3E,$3E,$3D,$3D,$3D,$3C
	DC.B	$3C,$3B,$3B,$3B,$3A,$3A,$39,$39,$39,$38,$38,$38,$37,$37,$36,$36
	DC.B	$36,$36,$35,$35,$35,$34,$34,$34,$33,$33,$33,$33,$32,$32,$32,$32
	DC.B	$31,$31,$31,$31,$30,$30,$30,$30,$30,$2F,$2F,$2F,$2F,$2F,$2F,$2E
	DC.B	$2E,$2E,$2E,$2E,$2E,$2E,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D
	DC.B	$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2C,$2D,$2D,$2D,$2D,$2D,$2D,$2D
	DC.B	$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2E,$2E,$2E,$2E,$2E
	DC.B	$2E,$2E,$2F,$2F,$2F,$2F,$2F,$2F,$30,$30,$30,$30,$30,$31,$31,$31
	DC.B	$31,$32,$32,$32,$32,$33,$33,$33,$33,$34,$34,$34,$35,$35,$35,$36
	DC.B	$36,$36,$36,$37,$37,$38,$38,$38,$39,$39,$39,$3A,$3A,$3B,$3B,$3B
	DC.B	$3C,$3C,$3D,$3D,$3D,$3E,$3E,$3F,$3F,$40,$40,$41,$41,$42,$42,$43
	DC.B	$43,$43,$44,$44,$45,$46,$46,$47,$47,$48,$48,$49,$49,$4A,$4A,$4B
	DC.B	$4B,$4C,$4D,$4D,$4E,$4E,$4F,$4F,$50,$51,$51,$52,$52,$53,$54,$54
	DC.B	$55,$56,$56,$57,$57,$58,$59,$59,$5A,$5B,$5B,$5C,$5D,$5D,$5E,$5F
	DC.B	$5F,$60,$61,$61,$62,$63,$63,$64,$65,$65,$66,$67,$68,$68,$69,$6A
	DC.B	$6A,$6B,$6C,$6D,$6D,$6E,$6F,$6F,$70,$71,$72,$72,$73,$74,$75,$75
	DC.B	$76,$77,$78,$78,$79,$7A,$7B,$7B,$7C,$7D,$7E,$7E,$7F,$80,$81,$81
	DC.B	$82,$83,$84,$85,$85,$86,$87,$88,$88,$89,$8A,$8B,$8B,$8C,$8D,$8E


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
