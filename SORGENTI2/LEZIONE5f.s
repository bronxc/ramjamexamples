
; Lezione5f.s	EFFETTO "SCIOGLIMENTO" O "FLOOD" FATTO CON I MODULI NEGATIVI

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

	bsr.w	Flood		; Muove in alto e in basso un wait seguito
				; da un modulo -40, che causa l'effetto FLOOD

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

; Effetto definibile come "Metallo fuso", ottenuto con i moduli -40

Flood:
	TST.B	SuGiu		; Dobbiamo salire o scendere?
	beq.w	VAIGIU
	cmp.b	#$30,FWAIT	; siamo arrivati abbastanza in ALTO?
	beq.s	MettiGiu	; se si, siamo in cima e dobbiamo scendere
	subq.b	#1,FWAIT	; scorriamo in ALTO
	rts

MettiGiu:
	clr.b	SuGiu		; Azzerando SuGiu, al TST.B SuGiu il BEQ
	rts

VAIGIU:
	cmp.b	#$f0,FWAIT	; siamo arrivati abbastanza in BASSO?
	beq.s	MettiSu		; se si, siamo in fondo e dobbiamo risalire
	addq.b	#1,FWAIT	; scorriamo in ALTO
	rts

MettiSu:
	move.b	#$ff,SuGiu	; Quando la label SuGiu non e' a zero,
	rts			; significa che dobbiamo risalire.


;	Questo byte, indicato dalla label SuGiu, e' un FLAG.

SuGiu:
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
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)
					; 3 bitplanes lowres, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

FWAIT:
	dc.w	$3007,$FFFE	; WAIT che precede il modulo negativo
	dc.w	$108,-40
	dc.w	$10a,-40

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

Da notare che -40 viene assemblato come $ffd8 (provate con un "?-40").
Provate a bloccare col tasto destro la routine e verificherete che avviene un
"allungamento" dell'ultima riga fino alla fine dello schermo.
Abbiamo verificato che con un modulo negativo di -40 il copper non avanza,
infatti va avanti di 40 e torna indietro di 40. Ma se mettiamo il modulo a -80,
cosa succede??? Legge alla rovescia!!! infatti legge e visualizza 40 bytes, poi
indietreggia di 80 bytes, andando all'inizio della linea precedente, che viene
visualizzata, dopodiche' salta alla linea precedente eccetera. Questo sistema
e' il piu' usato per gli effetti SPECCHIO tanto frequenti sull'Amiga proprio
perche' basta mettere un paio di istruzioni copper:

	dc.w	$108,-80
	dc.w	$10a,-80

provate a cambiare i due -40 dei moduli in questo esempio in due -80, e lo
"SPECCHIO" apparira', anche se stavolta il problema e' che viene visualizzato
anche qualcosa che sta sopra la figura (procedendo all'indietro).
Una curiosita': noterete che nella prima linea dello "SPORCO" che appare dopo
la figura specchiata c'e' un movimento che interessa dei pixel: si tratta del
wait nella copperlist che cambiamo ogni frame! Infatti cosa c'e' in memoria
prima della nostra figura?? La copperlist!! Dunque procedendo all'indietro
nella lettura (modulo -80), cosa sara' visualizzato?? I byte della copperlist,
poi quello che viene prima.

Se aumentiamo la negativita' otterremo specchiature sempre piu' schiacciate,
infatti avviene lo stesso effetto dei moduli positivi, ma al rovescio.

	dc.w	$108,-40*3
	dc.w	$10a,-40*3

Per la figura rispecchiata dimezzata, eccetera.

