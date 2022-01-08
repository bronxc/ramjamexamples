;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Lezione3h.s	SCORRIMENTO A DESTRA E SINISTRA TRAMITE IL WAIT del COPPER

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary, routine della EXEC che apre
				; le librerie, e da in uscita l'indirizzo
				; di base di quella libreria da cui fare le
				; distanze di indirizzamento (Offset)
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist
				; di sistema
	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti

	bsr.w	CopperDestSin	; Routine di scorrimento destra/sinistra

Aspetta:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	beq.s	Aspetta		; Se si, non andare avanti, aspetta la linea
				; seguente, altrimenti MuoviCopper viene
				; rieseguito

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	GfxBase(PC),a1	; Base della libreria da chiudere
				; (vanno aperte e chiuse le librerie!!!)
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts

; The routine is like in LESSON3g.s, the only difference is that you act on
; 29 wait instead of 1 through a DBRA loop that changes a wait, jumps to the wait
; next, change the wait, jump to the next wait, etc.

CopperDestSin:
	CMPI.W	#30,DestraFlag		; VAIDESTRA performed 85 times?
	BNE.S	VAIDESTRA		; if not yet, run it again
						; if it has already been performed 85
						; sometimes it continues on

	CMPI.W	#30,SinistraFlag	; VAISINISTRA eseguita 85 volte?
	BNE.S	VAISINISTRA		; se non ancora, rieseguila

	CLR.W	DestraFlag	; la routine VAISINISTRA e' stata eseguita
	CLR.W	SinistraFlag	; 85 volte, dunque a questo punto la barra
				; grigia e' tornata indietro e il ciclo
				; destra-sinistra e' finito, dunque azzeriamo
				; i due flag e usciamo: al prossimo FRAME
				; verra' rieseguita VAIDESTRA, dopo 85 frame
				; vaisinistra 85 volte per 85 frame, eccetera.
	RTS			; TORNIAMO AL LOOP mouse


VAIDESTRA:			; this routine moves the bar to the RIGHT 
	lea	CopBar+1,A0	; We put in A0 the address of the first XX value 
				; of the first wait, which is precisely 1 byte after CopBar

	move.w	#29-1,D2	; we have to change 29 wait (we use a DBRA)
DestraLoop:
	addq.b	#2,(a0)		; aggiungiamo 2 alla coordinata X del wait
	ADD.W	#16,a0		; andiamo al prossimo wait da cambiare
	dbra	D2,DestraLoop	; ciclo eseguito d2 volte
	addq.w	#1,DestraFlag	; segnamo che abbiamo eseguito un'altra volta
				; VAIDESTRA: in DestraFlag sta il numero
				; di volte che abbiamo eseguito VAIDESTRA.
	RTS			; TORNIAMO AL LOOP mouse


VAISINISTRA:			; questa routine sposta la barra verso SINISTRA
	lea	CopBar+1,A0
	move.w	#29-1,D2	; dobbiamo cambiare 29 wait
SinistraLoop:
	subq.b	#2,(a0)		; sottraiamo 2 alla coordinata X del wait
	ADD.W	#16,a0		; andiamo al prossimo wait da cambiare
	dbra	D2,SinistraLoop	; ciclo eseguito d2 volte
	addq.w	#1,SinistraFlag ; Aggiungiamo 1 al numero di volte che e'
				; stata eseguita VAISINISTRA.
	RTS			; TORNIAMO AL LOOP mouse

; Pay attention to one thing: we change 1 wait every 2 only, not all
; i wait. We only change half of it because, unlike when we do
; scroll a bar up and down, where 1 wait per line is enough
;
; dc.w $YY07, $FFFE; wait line YY, start of line (07)
; dc.w $180, $0RGB; color
; dc.w $YY07, $FFFE; wait line YY, start of line (07)
; ...
;
; In this case we have to put 2 waits for each line, ie one at the beginning
; of the line and another that slides left and right on that line:
;
; dc.w $YY07, $FFFE; wait line YY, start of line (07)
; dc.w $180, $0RGB; Color: Grey
; dc.w $YYXX, $FFFE; wait line YY, to the horizontal position
; ; that we decide, by advancing the
; ; GRAY on RED.
; dc.w $180, $0RGB; RED
;


DestraFlag:		; In questa word viene tenuto il conto delle volte
	dc.w	0	; che e' stata eseguita VAIDESTRA

SinistraFlag:		; In questa word viene tenuto il conto delle volte
	dc.w    0	; che e' stata eseguita VAISINISTRA


;	dati per salvare la copperlist di sistema.

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0
	dc.w	$180,$000	; COLOR0 - Inizio la cop col colore NERO

	dc.w	$2c07,$FFFE	; WAIT - a small fixed green bar
	dc.w	$180,$010	; COLOR0
	dc.w	$2d07,$FFFE	; WAIT
	dc.w	$180,$020	; COLOR0
	dc.w	$2e07,$FFFE	; WAIT
	dc.w	$180,$030	; COLOR0
	dc.w	$2f07,$FFFE	; WAIT
	dc.w	$180,$040	; COLOR0
	dc.w	$3007,$FFFE
	dc.w	$180,$030
	dc.w	$3107,$FFFE
	dc.w	$180,$020
	dc.w	$3207,$FFFE
	dc.w	$180,$010
	dc.w	$3307,$FFFE
	dc.w	$180,$000


	dc.w	$9007,$fffe	; we wait for the beginning of the gray line 
	dc.w	$180,$000	; to the minimum, that is BLACK !!!
CopBar:
	dc.w	$9031,$fffe	; wait we change ($9033, $9035, $9037 ...)
	dc.w	$180,$100	; colore rosso, che partira' da posizioni
				; sempre piu' verso destra, preceduto dal
				; grigio che avanzera' di conseguenza.
	dc.w	$9107,$fffe	; wait che non cambiamo (Inizio linea)
	dc.w	$180,$111	; colore GRIGIO (parte dall'inizio linea fino
	dc.w	$9131,$fffe	; a questo WAIT, che noi cambiaremo...
	dc.w	$180,$200	; dopo il quale comincia il ROSSO

; let's continue saving space, look at the diagram:

; note: with a "dc.w $1234" we store 1 word, with "dc.w $1234, $1234"
; we store 2 consecutive words in memory, that is the longword "dc.l $12341234"
; that we could have stored with a "dc.b $12, $34, $12, $34", so
; we can also store 8 or more words in memory with a single dc.w line!
; for example line 3 could be rewritten with dc.l in this way:
; dc.l $9207fffe, $1800222, $9231fffe, $1800300 i.e .:
; dc.l $9207fffe, $01800222, $9231fffe, $01800300 with zeros * INITIALS *
; pay attention to the leading zeros! a dc.w $0180 I write it with dc.w $180
; simply for convenience, but zero exists, it must be borne in mind!
; To clarify, line 3 complete with leading zeros would be:
; dc.w $9207, $fffe, $0180, $0222, $9231, $fffe, $0180, $0300 (1 word = $xxxx)
; Ultimately the "useless" leading zeros of .b, .w, .l are OPTIONAL.

; WAIT FISSI (then gray) - WAIT TO CHANGE (followed by red)

	dc.w	$9207,$fffe,$180,$222,$9231,$fffe,$180,$300 ; line 3
	dc.w	$9307,$fffe,$180,$333,$9331,$fffe,$180,$400 ; line 4
	dc.w	$9407,$fffe,$180,$444,$9431,$fffe,$180,$500 ; line 5
	dc.w	$9507,$fffe,$180,$555,$9531,$fffe,$180,$600 ; ....
	dc.w	$9607,$fffe,$180,$666,$9631,$fffe,$180,$700
	dc.w	$9707,$fffe,$180,$777,$9731,$fffe,$180,$800
	dc.w	$9807,$fffe,$180,$888,$9831,$fffe,$180,$900
	dc.w	$9907,$fffe,$180,$999,$9931,$fffe,$180,$a00
	dc.w	$9a07,$fffe,$180,$aaa,$9a31,$fffe,$180,$b00
	dc.w	$9b07,$fffe,$180,$bbb,$9b31,$fffe,$180,$c00
	dc.w	$9c07,$fffe,$180,$ccc,$9c31,$fffe,$180,$d00
	dc.w	$9d07,$fffe,$180,$ddd,$9d31,$fffe,$180,$e00
	dc.w	$9e07,$fffe,$180,$eee,$9e31,$fffe,$180,$f00
	dc.w	$9f07,$fffe,$180,$fff,$9f31,$fffe,$180,$e00
	dc.w	$a007,$fffe,$180,$eee,$a031,$fffe,$180,$d00
	dc.w	$a107,$fffe,$180,$ddd,$a131,$fffe,$180,$c00
	dc.w	$a207,$fffe,$180,$ccc,$a231,$fffe,$180,$b00
	dc.w	$a307,$fffe,$180,$bbb,$a331,$fffe,$180,$a00
	dc.w	$a407,$fffe,$180,$aaa,$a431,$fffe,$180,$900
	dc.w	$a507,$fffe,$180,$999,$a531,$fffe,$180,$800
	dc.w	$a607,$fffe,$180,$888,$a631,$fffe,$180,$700
	dc.w	$a707,$fffe,$180,$777,$a731,$fffe,$180,$600
	dc.w	$a807,$fffe,$180,$666,$a831,$fffe,$180,$500
	dc.w	$a907,$fffe,$180,$555,$a931,$fffe,$180,$400
	dc.w	$aa07,$fffe,$180,$444,$aa31,$fffe,$180,$300
	dc.w	$ab07,$fffe,$180,$333,$ab31,$fffe,$180,$200
	dc.w	$ac07,$fffe,$180,$222,$ac31,$fffe,$180,$100
	dc.w	$ad07,$fffe,$180,$111,$ad31,$fffe,$180,$000
	dc.w	$ae07,$fffe,$180,$000

; WAIT FISSI (then gray) - WAIT TO CHANGE (followed by red)
;
; As you can see, for each line it takes 2 waits, one to wait for the start
; of the line and one, the one we modify, to define in which
; point of the line change color, i.e. go from gray which is
; present from position 07, to red starting after position
; assumed by the wait that we change.
;
	dc.w	$fd07,$FFFE	; aspetto la linea $FD
	dc.w	$180,$00a	; blu intensita' 10
	dc.w	$fe07,$FFFE	; linea seguente
	dc.w	$180,$00f	; blu intensita' massima (15)
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end


Ultima cosuccia: se non avete ancora chiaro il discorso degli zeri iniziali
affrontato prima eccovi alcune conversioni "giuste" e "sbagliate":

	dc.b	1,2	=	dc.w	$0102	ossia	dc.w	$102

	dc.b	42,$2	=	dc.w	$2a02	(42 decimale = $2a Hex)

	dc.b	12,$2,$12,41 = dc.w $c02,$1229 = dc.l $c021229

	dc.b	12,$22,0 = dc.w $000c,$2200 = dc.w $c,$2200 = dc.l $c2200

	dc.w	1,2,3,432 = dc.l $00010002,$000301b0 = dc.l $10002,$301b0

	dc.l	$1234567=	dc.b	1,$23,$45,$67

	dc.l	$2342	=	dc.b	0,0,$23,$42

	dc.l	4	=	dc.b	0,0,0,4

	Attenzione all'ultimo esempio:

	un dc.l 4 in memoria diventa $00000004, un dc.b 4 diventa $04
	per cui mentre lo 04 nel dc.l si trova preceduto da 3 bytes $00,
	nel caso del dc.b 4 il 4 si posiziona al primo posto, il che e'
	completamente diverso in ASSEMBLER, nonostante si parli sempre
	di un 4!!!!

