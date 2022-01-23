
; Lezione5a.s	SCORRIMENTO DI UNA FIGURA A DESTRA E SINISTRA COL $dff102

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	 PUNTIAMO I NOSTRI BITPLANES

	MOVE.L	#PIC,d0		; in d0 mettiamo l'indirizzo della PIC,
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	MOVEQ	#2,D1		; numero di bitplanes -1 (qua sono 3)
POINTBP:
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 3412 > 1234)
	ADD.L	#40*256,d0	; + lunghezza bitplane -> prossimo bitplane
	addq.w	#8,a1		; andiamo ai prossimi bplpointers nella COP
	dbra	d1,POINTBP	; Rifai D1 volte POINTBP (D1=num of bitplanes)

;

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP

	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	btst	#2,$dff016	; se il tasto destro e' premuto salta
	beq.s	Aspetta		; la routine dello scroll, bloccandolo

	bsr.s	MuoviCopper	; fa scorrere col $dff102 la figura a destra
				; e a sinistra (massimo 16 pixel)

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta!

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts			; USCITA DAL PROGRAMMA

;	Dati

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

; This routine is similar to that of Lesson3d.s, in this case
; we modify the value of the scroll register BPLCON1 $dff102 for
; scroll the figure back and forth.
; Being possible to act separately on the even bitplanes and on those
; odd, to move all the bitplanes we have to move them
; simultaneously: $0011, $0022, $0033 instead of $0001, $0002, $0003 which
; would only move the odd bitplanes (1,3,5), or $0010, $0020, $0030 which
; would only move the even bitplanes (2,4,6).
; Try a "= c 102" to see the bits of the $dff102

MuoviCopper:
	TST.B	FLAG		; Dobbiamo avanzare o indietreggiare? se
				; FLAG e' azzerata, (cioe' il TST verifica il
				; BEQ)
				; allora saltiamo a AVANTI, se invece e' a $FF
				; (se cioe' questo TST non e' verificato)
				; continuiamo indietreggiando (con dei sub)
	beq.w	AVANTI
	cmpi.b	#$00,MIOCON1	; siamo arrivati alla posizione normale, ossia
				; tutto indietro?
	beq.s	MettiAvanti	; se si, dobbiamo avanzare!
	sub.b	#$11,MIOCON1	; sottraiamo 1 allo scroll dei bitplanes
	rts			; dispari ($ff,$ee,$dd,$cc,$bb,$aa,$99....)
				; andando a SINISTRA
MettiAvanti:
	clr.b	FLAG		; Azzerando FLAG, al TST.B FLAG il BEQ
	rts			; fara' saltare alla routine AVANTI, e
				; la figura avanzera' (verso destra)

AVANTI:
	cmpi.b	#$ff,MIOCON1	; siamo arrivati allo scroll massimo in
				; avanti, ossia $FF? ($f pari e $f dispari)
	beq.s	MettiIndietro	; se si, siamo dobbiamo tornare indietro
	add.b	#$11,MIOCON1	; aggiungiamo 1 allo scroll dei bitplanes
				; pari e dispari ($11,$22,$33,$44 etc..)
	rts			; ANDANDO A DESTRA

MettiIndietro:
	move.b	#$ff,FLAG	; Quando la label FLAG non e' a zero,
	rts			; significa che dobbiamo indietreggiare
				; verso sinistra

; This byte is a FLAG, that is, it is used to 
; indicate whether to go ahead or backards.

FLAG:
	dc.b	0,0


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registri con valori normali)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop


	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIOCON1:
	dc.b	$00		; BplCon1 - IL BYTE UTILIZZATO!!!


	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210	; BPLCON0:
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)
					; 3 bitplanes lowres, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane - BPL2PT

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

PIC:
	incbin	"hd1:develop/projects/dischi/myimages/earth_320x256x3.raw"	
			; here we load the figure in RAW, made of
			; 3 consecutive bitplanes

	end

Moving the screen forward 16 pixels on the Amiga is a joke! enough
modify one byte, that of $dff102, and that's it. On other systems
computer graphics such as the MSDOS PC instead you have to change everything
the figure and "move it", with a lot of instructions that slow everything down.
In addition, even and odd planes can be moved separately
so you can easily create parallax effects, just slide more
slowly the background, made by the odd bitplanes, and faster the
close-up, made for example by the even bitplanes. Not for nothing to make one
parallax on the PC it is necessary to do very complicated and slow routines.
We verify that it is possible to scroll the odd and even bitplanes separately
with these two changes; to scroll ONLY the EVEN bitplanes (here is the 2
only) change these instructions


	sub.b	#$11,MIOCON1	; sottraiamo 1 allo scroll dei bitplanes

	cmpi.b	#$ff,MIOCON1	; siamo arrivati allo scroll massimo in

	add.b	#$11,MIOCON1	; aggiungiamo 1 allo scroll dei bitplanes
				; pari e dispari ($11,$22,$33,$44 etc..)

in questo modo:


	sub.b	#$10,MIOCON1	; solo i planes PARI!

	cmpi.b	#$f0,MIOCON1

	add.b	#$10,MIOCON1

You will notice that only one bitplane moves, the 2, while the first and the third
they remain in place. In moving, bitplane 2 remains "in the open",
ie it loses the overlap with the other 2 showing its "TRUE FACE",
and assuming COLOR2, which is at $FFF in the copperlist as you can see,
in fact it is white. It assumes color2 because moving bitplane 2 does
finds "only" with the background, ie:% 010, with bitplanes 1 and 3 cleared.
The binary number% 010 equals 2, so its color will be decided by the
color register 2, the $dff184. change its value in the copperlist 
you will verify that bitplane 2 "alone" is controlled by that
register:

	dc.w	$0184,$fff	; color2

In fact, putting, for example, a $ff0, it will become yellow. On the other hand the figure
it remains "HOLE" in the points where the bitplane2 "IF IT GOES", you can see it better
pressing the right button that blocks the scrolling: in particular the holes
you can see where the WHITE appears, that is where there was only the bitplane2 without
overlaps. In other cases, instead of forming a HOLE, the color changes.

To slide only the ODD bitplanes (1 and 3 in our figure), instead,
modify the routine like this:

	subq.b	#$01,MIOCON1	; only the ODD planes!

	cmpi.b	#$0f,MIOCON1

	addq.b	#$01,MIOCON1

In this case the bitplane2, the only even one, remains stationary and the planes move
1 and 3, the odd ones.
With this example you have also been able to verify the overlapping method
bitplanes to display the various colors.
