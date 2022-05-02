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

	bsr.w MoveSprite

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

MoveSprite:
	addq.l #1,TABLE_VELOCITY_JUMP_PTR
	move.l TABLE_VELOCITY_JUMP_PTR,A0

	cmp.l END_TABLE_VELOCITY_JUMP-1,A0
	bne.s DoMove
	move.l #TABLE_VELOCITY_JUMP-1,TABLE_VELOCITY_JUMP_PTR
DoMove:
	moveq #0,d0
	move.b (A0),d0
	add.b d0,VSTART
	add.b #13,d0
	add.b d0,VSTOP
	rts

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

	SECTION	GRAPHICS,DATA_C

TABLE_VELOCITY_JUMP_PTR:
	dc.l TABLE_VELOCITY_JUMP-1

TABLE_VELOCITY_JUMP:
	dc.b	$10,$8,$6,$4,$3,$2
END_TABLE_VELOCITY_JUMP

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
	dc.b $40+10
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
