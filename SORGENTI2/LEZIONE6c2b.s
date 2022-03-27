;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Lezione6c2.s	STAMPIAMO VARIE RIGHE DI TESTO SULLO SCHERMO!!!
;		- con font in binario MODIFICABILE FACILMENTE!!

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist vecchia

;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0	; in d0 mettiamo l'indirizzo della PIC,
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane

	move.l	#COPPERLIST,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
	move.w	#0,$dff1fc		; Disattiva l'AGA
	move.w	#$c00,$dff106		; Disattiva l'AGA

	bsr.w	PRINT		; Stampa le linee di testo sullo schermo

mouse:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	GfxBase(PC),a1	; Base della libreria da chiudere
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts			; USCITA DAL PROGRAMMA

;	Dati

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0

;	Routine che stampa caratteri larghi 8x8 pixel

PRINT:
	LEA	TESTO(PC),A0	; Indirizzo del testo da stampare in a0
	LEA	BITPLANE,A3	; Indirizzo del bitplane destinazione in a3
	MOVEQ	#25-1,D3	; NUMERO RIGHE DA STAMPARE: 25
PRINTRIGA:
	MOVEQ	#40-1,D0	; NUMERO COLONNE PER RIGA: 40
PRINTCHAR2:
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	MULU.W	#8,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.w	#1,A3		; A1+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

	DBRA	D0,PRINTCHAR2	; STAMPIAMO D0 (40) CARATTERI PER RIGA

	ADD.W	#40*7,A3	; ANDIAMO A CAPO

	DBRA	D3,PRINTRIGA	; FACCIAMO D3 RIGHE

	RTS

;			CARATTERI DISPONIBILI NEL FONT:
;
;	  !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ
;
;		CARATTERI CHE NON SONO NEL FONT, DA NON USARE:
;
;	           [\]^_`abcdefghijklmnopqrstuvwxyz{|}~
;
;
; NOTA: il carattere "@" stampa una faccia sorridente... perche' no?

		; numero caratteri per linea: 40
TESTO:							 ;40 caratteri
	dc.b	"    this is a test                      " ; 1
	dc.b	"                                        " ; 2
	dc.b	"                                        " ; 3
	dc.b	"                                        " ; 4
	dc.b	"                                        " ; 5
	dc.b	"                                        " ; 6
	dc.b	"                                        " ; 7
	dc.b	"                                        " ; 8
	dc.b	"                                        " ; 9
	dc.b	"                                        " ; 10
	dc.b	"                                        " ; 11
	dc.b	"                                        " ; 12
	dc.b	"                                        " ; 15
	dc.b	"                                        " ; 25
	dc.b	"                                        " ; 16
	dc.b	"                                        " ; 17
	dc.b	"                                        " ; 18
	dc.b	"                                        " ; 19
	dc.b	"                                        " ; 20
	dc.b	"                                        " ; 21
	dc.b	"                                        " ; 22
	dc.b	"                                        " ; 23
	dc.b	"                                        " ; 24
	dc.b	"                                        " ; 25
	dc.b	"                                        " ; 26
	dc.b	"                                        " ; 27

	EVEN

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; 1 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$345	; color0 - SFONDO
	dc.w	$0182,$bdf	; color1 - SCRITTE

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Il FONT caratteri 8x8

;	caratteri:  !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ
;	ATTENZIONE! non ci sono: [\]^_`abcdefghijklmnopqrstuvwxyz{|}~

; CONSIGLIO: Per scorrere in basso usate il cursore giu' + SHIFT e fate una
; pagina alla volta!!!

FONT:
; ' '
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '!'
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00000000
; '"'
	dc.b	%00011011
	dc.b	%00011011
	dc.b	%00011011
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; '#'
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%01111111
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%00000000
; '$'
	dc.b	%00001000
	dc.b	%00011110
	dc.b	%00100000
	dc.b	%00011100
	dc.b	%00000010
	dc.b	%00111100
	dc.b	%00001000
	dc.b	%00000000
; '%'
	dc.b	%00000001
	dc.b	%00110011
	dc.b	%00110110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110110
	dc.b	%01100110
	dc.b	%00000000
; '&'
	dc.b	%00011000
	dc.b	%00100100
	dc.b	%00011000
	dc.b	%00011001
	dc.b	%00100110
	dc.b	%00111110
	dc.b	%00011001
	dc.b	%00000000
; "'"
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "("
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%00110000
	dc.b	%00110000
	dc.b	%00011000
	dc.b	%00001100
	dc.b	%00000000
; ")"
	dc.b	%00110000
	dc.b	%00011000
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%00000000
; "*"
	dc.b	%01100011
	dc.b	%00110110
	dc.b	%00011100
	dc.b	%01111111
	dc.b	%00011100
	dc.b	%00110110
	dc.b	%01100011
	dc.b	%00000000
; '+'
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%01111110
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
	dc.b	%00000000
; ","
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%00000000
; "-"
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%01111110
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; "."
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00000000
; "/"
	dc.b	%00000001
	dc.b	%00000011
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%01100000
	dc.b	%00000000
; '0'
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%00000000
; '1'
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000000
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000000
; '2'
	dc.b	%01111111
	dc.b	%00000000
	dc.b	%00000011
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%00000000
; '3'
	dc.b	%01111111
	dc.b	%00000000
	dc.b	%00000011
	dc.b	%00011111
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111111
	dc.b	%00000000
; '4'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000000
; '5'
	dc.b	%01111111
	dc.b	%00000000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111111
	dc.b	%00000000
; '6'
	dc.b	%01111111
	dc.b	%00000000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%00000000
; '7'
	dc.b	%01111111
	dc.b	%00000000
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000000
; '8'
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%00000000
; '9'
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111111
	dc.b	%00000000
; ':'
	dc.b	%00000000
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00000000
; ';'
	dc.b	%00000000
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00000000
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00000000
; "<"
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00011000
	dc.b	%00110000
	dc.b	%00011000
	dc.b	%00001100
	dc.b	%00000110
	dc.b	%00000000
; "="
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%01111110
	dc.b	%00000000
	dc.b	%01111110
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ">"
	dc.b	%00011000
	dc.b	%00001100
	dc.b	%00000110
	dc.b	%00000011
	dc.b	%00000110
	dc.b	%00001100
	dc.b	%00110000
	dc.b	%00000000
; '?'
	dc.b	%01111111
	dc.b	%00000000
	dc.b	%00000011
	dc.b	%00001111
	dc.b	%00001100
	dc.b	%00000000
	dc.b	%00001100
	dc.b	%00000000
; "@"
	dc.b	%00000000	; sorriso
	dc.b	%11100111
	dc.b	%11100111
	dc.b	%00000000
	dc.b	%00010000
	dc.b	%00011000
	dc.b	%10000001
	dc.b	%01111110
; "A"
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
; "B"
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111110
	dc.b	%01111110
; 'C'
	dc.b	%00111111
	dc.b	%00111111
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
; 'D'
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
; 'E'
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111 
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111000
	dc.b	%01111000
; 'F'
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111 
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111000
	dc.b	%01111000
; 'G'
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01101111
	dc.b	%01101111
; 'H'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111
; 'I'
	dc.b	%00111111
	dc.b	%00111111
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
; 'J'
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00000011
; 'K'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100111
	dc.b	%01100111
	dc.b	%01101110
	dc.b	%01101110
	dc.b	%01111100
	dc.b	%01111100
; 'L'
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
; 'M'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%01110111
	dc.b	%01110111
	dc.b	%01111111
	dc.b	%01101011
	dc.b	%00001000
; 'N'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110011
	dc.b	%01110011
	dc.b	%01111011
	dc.b	%01111011
	dc.b	%01101111
	dc.b	%01101111
; 'O'
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
; 'P'
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
; 'Q'
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01101011
	dc.b	%01101011
; 'R'
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
; 'S'
	dc.b	%00111111
	dc.b	%00111111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%00111110
	dc.b	%00111110
; 'T'
	dc.b	%00111111
	dc.b	%00111111
	dc.b	%00111111
	dc.b	%00111111
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
; 'U'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
; 'V'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%01110111
; 'W'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01101011
	dc.b	%01101011
; 'X'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01110111
	dc.b	%01110111
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%00011100
	dc.b	%00011100
; 'Y'
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00110111
	dc.b	%00110111
	dc.b	%00111110
	dc.b	%00111110
; 'Z'
	dc.b	%01111111	;58
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00001110
	dc.b	%00001110
	dc.b	%00011100
	dc.b	%00011100
; ' '
	dc.b	%00000000	;
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ' '
	dc.b	%00000000	;
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ' '
	dc.b	%00000000	;
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ' '
	dc.b	%00000000	;
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ' '
	dc.b	%00000000	;
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ' '
	dc.b	%00000000	;
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; 'a'
	dc.b	%01111111	;65
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'b'
	dc.b	%01111111	;66
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111110
	dc.b	%01111110
; 'c'
	dc.b	%01100000	;67
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00111111
	dc.b	%00111111
	dc.b	%00000000
; 'd'
	dc.b	%01100011	;68
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%00000000
; 'e'
	dc.b	%01111000	;69
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00000000
; 'f'
	dc.b	%01111000	;70
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000	
	dc.b	%00000000
; 'g'
	dc.b	%01101111	;71
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%00000000
; 'h'
	dc.b	%01111111	;72
	dc.b	%01111111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'i'
	dc.b	%00001100	;73
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00111111
	dc.b	%00111111
	dc.b	%00000000
; 'j'
	dc.b	%00000011	;74
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%00110011
	dc.b	%00110011
	dc.b	%00011110
	dc.b	%00011110
	dc.b	%00000000
; 'k'
	dc.b	%01111100	;75
	dc.b	%01111100
	dc.b	%01111100
	dc.b	%01101110
	dc.b	%01101110
	dc.b	%01100111
	dc.b	%01100111
	dc.b	%00000000
; 'l'
	dc.b	%01100000	;76
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00000000
; 'm'
	dc.b	%01101011	;77
	dc.b	%01101011
	dc.b	%01101011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'n'
	dc.b	%01101111	;78
	dc.b	%01100111
	dc.b	%01100111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'o'
	dc.b	%01100011	;79
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%00000000
; 'p'
	dc.b	%01111110	;80
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%01100000
	dc.b	%00000000
; 'q'
	dc.b	%01101011	;81
	dc.b	%01100111
	dc.b	%01100111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%00000000
; 'r'
	dc.b	%01111110	;82
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 's'
	dc.b	%00011110	;83
	dc.b	%00000011
	dc.b	%00000011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111110
	dc.b	%01111110
	dc.b	%00000000
; 't'
	dc.b	%00001100	;84
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00001100
	dc.b	%00000000
; 'u'
	dc.b	%01100011	;85
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00111111
	dc.b	%00111110
	dc.b	%00000000
; 'v'
	dc.b	%01111111	;86
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%00011100
	dc.b	%00011100
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00000000
; 'w'
	dc.b	%01111111	;87
	dc.b	%01101011
	dc.b	%01101011
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%00000000
; 'x'
	dc.b	%00011100	;88
	dc.b	%00111110
	dc.b	%00111110
	dc.b	%01110111
	dc.b	%01110111
	dc.b	%01100011
	dc.b	%01100011
	dc.b	%00000000
; 'y'
	dc.b	%00011100	;89
	dc.b	%00011100
	dc.b	%00011100
	dc.b	%01111000
	dc.b	%01111000
	dc.b	%01110000
	dc.b	%01110000
	dc.b	%00000000
; 'z'
	dc.b	%00111000	;90
	dc.b	%00111000
	dc.b	%00111000
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%01111111
	dc.b	%00000000
; ' '
	dc.b	%00000000	;91
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ' '
	dc.b	%00000000	;
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
; ' '
	dc.b	%00000000	;
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000
	dc.b	%00000000






;
; mancano i caratteri in minuscolo... se avete la pazienza di disegnarli, fate
; pure! Oppure potete fare disegnini da comporre insieme...
;

	SECTION	MIOPLANE,BSS_C	; Le SECTION BSS devono essere fatte di
				; soli ZERI!!! si usa il DS.b per definire
				; quanti zeri contenga la section.

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

	end

Questo listato e' uguale a Lezione6c.s, ma il font e' "FATTO A MANO", infatti
anziche' caricarlo e' nel listato in forma di dc.b in binario

		;12345678
; "A"
	dc.b	%01111111	;1
	dc.b	%00000011	;2
	dc.b	%01100011	;3
	dc.b	%01111111	;4
	dc.b	%01100011	;5
	dc.b	%01100011	;6
	dc.b	%01100011	;7
	dc.b	%00000000	;8

Questa per esempio e' la "A". Attenzione a non usare caratteri minuscoli nel
testo, perche' non sono nel font, in quanto chi lo ha fatto si deve essere
stancato alla "Z" maiuscola. In realta' non c'erano nemmeno molti simboli
come "*;<>=" e li ho aggiunti io. Ora apparira' piu' chiara anche come e'
fatto il font! E intuirete che per fare un font di 16x16 dovete fare cosi':


		;1234567890123456
; "A"
	dc.w	%0000111111111100	;1
	dc.w	%0011111111111111	;2
	dc.w	%0011110000001111	;3
	dc.w	%0011110000001111	;4
	dc.w	%0011110000001111	;5
	dc.w	%0011110000001111	;6
	dc.w	%0011111111111111	;7
	dc.w	%0011111111111111	;8
	dc.w	%0011110000001111	;9
	dc.w	%0011110000001111	;10
	dc.w	%0011110000001111	;11
	dc.w	%0011110000001111	;12
	dc.w	%0011110000001111	;13
	dc.w	%0011110000001111	;14
	dc.w	%0000000000000000	;15
	dc.w	%0000000000000000	;16

Ma conviene disegnarlo e convertirlo in RAW!

In questo listato vi consiglio di modificare il FONT, aggiungendo disegnini e
simboli strani. Potreste farvi il FONT personale!

