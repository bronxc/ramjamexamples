;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Lesson4b.s DISPLAY OF A FIGURE IN 320 * 256 a 3 plane (8 colors)

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;*****************************************************************************
;	LET THE BPLPOINTERS POINT IN THE COPPERLIST AT OUR BITPLANES
;*****************************************************************************


	MOVE.L	#PIC,d0		; in d0 we put the address of the PIC,
					; that is, where the first bitplane begins

	LEA	BPLPOINTERS,A1	; in a1 we put the address of
					; pointers to the COPPERLIST planes
	MOVEQ	#2,D1		; number of bitplanes -1 (there are 3)
					; to run the cycle with the DBRA
POINTBP:
	move.w	d0,6(a1)	; copies the LOW word of the plane address
					; in the right word in the copperlist
	swap	d0		; swap the 2 words of d0 (ex: 1234> 3412)
				; putting the word HIGH in place of that
				; LOW, allowing copying with move.w !!
	move.w	d0,2(a1)	; copies the word HIGH of the address of the plane
				; in the right word in the copperlist
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
				; rimettendo a posto l'indirizzo.
	ADD.L	#40*256,d0	; We add 10240 to D0, making it point
			; to the second bitplane (after the first)
			; (i.e. we add the length of a plane)
			; In the cycles following the first we will make a bet
			; to the third, to the fourth bitplane and so on.

	addq.w	#8,a1		; a1 now contains the address of the next ones
				; bplpointers in the copperlist to be written.
	dbra	d1,POINTBP	; Redo D1 times POINTBP (D1 = num of bitplanes)

	move.l	#COPPERLIST,$dff080	; Point to our COP
	move.w	d0,$dff088		; Let's start the COP

	move.w	#0,$dff1fc		; FMODE - Disable AGA
	move.w	#$c00,$dff106		; BPLCON3 - Disable AGA

mouse:
	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	mouse		; if not, back to mouse:

	move.l	OldCop(PC),$dff080	; We target the system cop
	move.w	d0,$dff088		; let's start the old cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - re-enable Multitasking
	move.l	GfxBase(PC),a1	; Base of the library to close
	jsr	-$19e(a6)	; Closelibrary - close the graphics lib
	rts			; EXIT FROM THE PROGRAM

;	Dati

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

	SECTION	GRAPHIC,DATA_C

COPPERLIST:

	; We point the sprites to ZERO, to eliminate them or there
	; is flickering

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

; the BPLCON0 ($dff100) For a 3 bitplanes screen: (8 colors)

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 and 12 on !! (3 =% 011)

; We point the bitplanes directly by placing them in the copperlist
; the $dff0e0 and following registers below with the addresses
; of the bitplanes that will be placed by the POINTBP routine

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;first	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;second bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;third	 bitplane - BPL2PT

;	Gli 8 colori della figura sono definiti qui:

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

; Enter any WAIT effects here

	BAR:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79 then draw green line

	dc.w	$180
	dc.w	$060

	dc.w	$7A07,$FFFE ; Wait for line $7A
	dc.w	$180,$000	; go back to black

	dc.w	$FFFF,$FFFE	; Finish copperlist


; Remember to select the directory where the figure is located
; in this case just write: "V df0: SOURCES2"


PIC:
	incbin	"hd1:develop/projects/dischi/myimages/earth_320x256x3.raw"	
	; here we load the figure in RAW,
	; converted with KEFCON, made of
	; 3 consecutive bitplanes

	end

As you may have seen, there are no synchronized routines in this example, but
only the routines that target the bitplanes and the copperlist.
First try to eliminate with gods; sprite pointers:

;	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000
;	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
;	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
;	dc.w	$13e,$0000

You will notice that every now and then they pass like STRIPES, those are sprites
without control madly. We will learn to tame them later.

Now try to add some WAIT before the end of the copperlist,
and you will notice how useful WAIT + COLOR are to ADD HORIZONTAL SHADES
o CHANGE COLORS totally FREE, that is, with an 8-color figure like
this we can work with MOVE + WAIT making it a background with a hundred
of colors by blending them, or by changing the "superimposed" colors,
i.e. the $182, $184, $186, $188, $18a, $18c, $18e.

As a first 'embellishment' copy and insert this pre-made piece of
nuance between the colors and the end of the copperlist: (dc.w $FFFF, $FFFE)
I REMEMBER THAT YOU MUST SELECT THE BLOCK WITH Amiga + b, Amiga + c, then
place the cursor where you want to copy the text, and insert it with Amiga + i.


	dc.w	$a907,$FFFE	; Aspetto la linea $a9
	dc.w	$180,$001	; blu scurissimo
	dc.w	$aa07,$FFFE	; linea $aa
	dc.w	$180,$002	; blu un po' piu' intenso
	dc.w	$ab07,$FFFE	; linea $ab
	dc.w	$180,$003	; blu piu' chiaro
	dc.w	$ac07,$FFFE	; prossima linea
	dc.w	$180,$004	; blu piu' chiaro
	dc.w	$ad07,$FFFE	; prossima linea
	dc.w	$180,$005	; blu piu' chiaro
	dc.w	$ae07,$FFFE	; prossima linea
	dc.w	$180,$006	; blu a 6
	dc.w	$b007,$FFFE	; salto 2 linee
	dc.w	$180,$007	; blu a 7
	dc.w	$b207,$FFFE	; sato 2 linee
	dc.w	$180,$008	; blu a 8
	dc.w	$b507,$FFFE	; salto 3 linee
	dc.w	$180,$009	; blu a 9
	dc.w	$b807,$FFFE	; salto 3 linee
	dc.w	$180,$00a	; blu a 10
	dc.w	$bb07,$FFFE	; salto 3 linee
	dc.w	$180,$00b	; blu a 11
	dc.w	$be07,$FFFE	; salto 3 linee
	dc.w	$180,$00c	; blu a 12
	dc.w	$c207,$FFFE	; salto 4 linee
	dc.w	$180,$00d	; blu a 13
	dc.w	$c707,$FFFE	; salto 7 linee
	dc.w	$180,$00e	; blu a 14
	dc.w	$ce07,$FFFE	; salto 6 linee
	dc.w	$180,$00f	; blu a 15
	dc.w	$d807,$FFFE	; salto 10 linee
	dc.w	$180,$11F	; schiarisco...
	dc.w	$e807,$FFFE	; salto 16 linee
	dc.w	$180,$22F	; schiarisco...
	dc.w	$ffdf,$FFFE	; FINE ZONA NTSC (linea $FF)
	dc.w	$180,$33F	; schiarisco...
	dc.w	$2007,$FFFE	; linea $20+$FF = linea $1ff (287)
	dc.w	$180,$44F	; schiarisco...

We have created from scratch, without counterproductive effects, a nuance
bringing the actual colors on the screen from 8 to 27 !!!!
Let's add another 7 colors, this time changing not the background color,
the $dff180, but the other 7 colors: insert this piece of copperlist between
bitplane pointers and colors: (leave the other change as well)

	dc.w	$0180,$000	; color0
	dc.w	$0182,$550	; color1	; ridefiniamo il colore della
	dc.w	$0184,$ff0	; color2	; scritta COMMODORE! GIALLA!
	dc.w	$0186,$cc0	; color3
	dc.w	$0188,$990	; color4
	dc.w	$018a,$220	; color5
	dc.w	$018c,$770	; color6
	dc.w	$018e,$440	; color7

	dc.w	$7007,$fffe	; Aspettiamo la fine della scritta COMMODORE

With 45 "dc.w" added to the copperlist we have transformed a harmless PIC of
only 8 colors in a 34-color PIC, even exceeding the limit of 32 colors
some pic to 5 bitplanes !!!

Only by programming copperlists in assembler you can make the most of it
Amiga graphics: now you could also make 320-color figures
clean clean simply by changing the entire palette of a figure at 32
colors 10 times, putting a wait + palette every 25 lines ...
Now maybe you will explain why certain games have 64, 128 or more colors
on the screen!!! They have very long copperlists where they change color
at different heights of the video!

Make some changes, which are always good, and if you like, try to
putting the examples in the "background" with the bars of Lesson 3, that's enough
load them into other buffers and insert the pieces of routines and copperlists
right, it's a good workout. Try to make the finger walk "under"
the drawing, if you can, you are tough.

