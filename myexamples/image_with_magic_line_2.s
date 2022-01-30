;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
; My Program to draw a single line on the screen that moves up and down 
; as well as change colour on the x axis
; with an image displayed on top
; this time with added colours for the image taken from the file!

; Let Amiga decide where to put our code
	SECTION MyCode,CODE

Start:
	move.l	4.w,a6		; Store Execbase in a6
	jsr	-$78(a6)		; Disable multitasking
	lea	GfxName(PC),a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC routine that opens
				; the libraries, and outputs the base
				; addresss of that library to d0 so we can use offsets
	move.l	d0,GfxBase	; save the GFX base address in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save the address of the system copperlist
			

	MOVE.L	#PIC,d0
	LEA	BPLPOINTERS,A1
	MOVEQ	#2,D1		
				
SETUPBP:
	move.w	d0,6(a1)			
	swap	d0						
	move.w	d0,2(a1)			
	swap	d0				
	ADD.L	#40*256,d0		
	addq.w	#8,a1					
	dbra	d1,SETUPBP

	move.l	#MyCopperList,$dff080	; COP1LC - point to my copper list
	move.w	d0,$dff088		; COPJMP1 - Start our copperlist

	;load colours from the image file
	move.l #PIC,d0
       add.l  #40*256*3,d0         ;skips size of all 3 bitplanes
       move.l d0,a0

       lea    GameScreenColours,a1
       moveq #7,d1                       ;loop counter, 16 colours
       .NextColour:
              move.w (a0)+,(a1)
              addq.l #4,a1
              dbra   d1,.NextColour


	; DISABLE AGA
	move.w	#0,$dff1fc
	move.w	#$c00,$dff106	

Loop1:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we on line 255?
	bne.s	Loop1

	btst	#2,$dff016	; only move the bar when right mouse is clicked
	bne.s	Loop2

	bsr.s	MoveBar

Loop2:
	cmpi.b	#$ff,$dff006	; frame sync again
	beq.s	Loop2

	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	Loop1		; if not, back to mouse:

	; Put system cop back and quit
	move.l	OldCop(PC),$dff080	; We target the system cop
	move.w	d0,$dff088	; let's start the cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - re-enable Multitasking
	move.l	GfxBase(PC),a1	; Base of the library to close
				; (libraries must be opened and closed !!!)
	jsr	-$19e(a6)	; Closelibrary - close the graphics lib
	rts

MoveBar:
	LEA	BAR,a0 	;Load address of BAR label then work with offsets

	; Should we be adding or subtracting?
	TST.B 	VertDirectionFlag
	beq.w	BarGoDown

	jmp	BarGoUp

BarGoDown:
	addq.b	#1,(a0)	; Add 1 to the Y for the green line
	addq.b	#1,8(a0)	; Add 1 to the Y for setting to black
	addq.b	#1,16(a0)

	cmpi.b	#$ff,8(a0)	; If we reached bottom, need to go up
	beq.s	SetVertFlagUp

	jmp	MoveColour

	rts

BarGoUp
	subq.b	#1,(a0)	; Add 1 to the Y for the green line
	subq.b	#1,8(a0)	; Add 1 to the Y for setting to black
	subq.b	#1,16(a0)

	cmpi.b	#$2c,8(a0) ; if we are at the top, go down
	beq.s 	SetVertFlagDown

	jmp	MoveColour

	rts

MoveColour:

	;LEA	BAR,a0 	;Already loaded into a0

	; Should we be adding or subtracting?
	TST.B 	HorizDirectionFlag
	beq.w	ColourGoRight

	jmp	ColourGoLeft
	rts

ColourGoRight:

	addq.b	#2,9(a0)	; Add 1 to the X for the green line

	cmpi.b	#$e1,9(a0)	;if we reached the end of the line, go left
	beq.s 	SetHorizFlagLeft

	rts

ColourGoLeft:
	subq.b	#2,9(a0)	; Subtract 1 to the X for the green line

	cmpi.b	#$07,9(a0)
	beq.s 	SetHorizFlagRight
	
	rts

SetVertFlagUp
	move.b	#$ff,VertDirectionFlag
	rts

SetVertFlagDown
	clr.b	VertDirectionFlag
	rts

SetHorizFlagLeft
	move.b	#$ff,HorizDirectionFlag
	rts

SetHorizFlagRight
	clr.b	HorizDirectionFlag
	rts

VertDirectionFlag:
	dc.b	0,0

HorizDirectionFlag:
	dc.b 	0,0

GfxName:
	dc.b	"graphics.library",0,0	;Name of library to load

GfxBase:		; Base address for the graphics.library
	dc.l	0	; 

OldCop:			; Address of the old system COP
	dc.l	0

	;Copperlist must be in chipmem
	SECTION MyCopper,CODE_C

MyCopperList:
	; clear all sprites or we get flickering
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registers with normal values)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	; want 3 bitplanes
	dc.w	$100,%0011001000000000

	BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;first bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;second bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;third bitplane - BPL2PT

	; default image colours
	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7


	dc.w	$180,$000	; COLOR0 - start with black

BAR:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79 then draw green line
	dc.w	$180
	dc.w	$0F0

	dc.w	$7981,$FFFE ; WAIT - wait for part way along the green line
	dc.w	$180,$F00		; and set background to red

	dc.w	$7A07,$FFFE ; Wait for line after the green/red line, ($7A on very fist run, then code increments)
	dc.w	$180,$000	; and go back to black background

	dc.w	$0180
GameScreenColours:
    dc.w    $0000						; color00 - plane 1
	dc.w	$0182,$0ff0					; color01 - plane 1 
	dc.w	$0184,$000f					; color02 - plane 2
	dc.w	$0186,$0008					; color03 - plane 2
	dc.w	$0188,$0004					; color04 - plane 3
	dc.w	$018A,$0004					; color05 - plane 3
	dc.w	$018C,$0008					; color06 - plane 3
	dc.w	$018E,$0800					; color07 - plane 3
	dc.w	$0190,$0080					; color08 - plane 4

	dc.w	$FFFF,$FFFE	; END OF COPPERLIST

PIC:
	incbin	"hd1:develop/projects/dischi/myimages/earth_320x256x3.raw"	
	; here we load the figure in RAW,
	; converted with KEFCON, made of
	; 3 consecutive bitplanes

	end
	end
