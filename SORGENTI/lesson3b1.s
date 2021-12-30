;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
        SECTION MyCode,CODE     ; This command causes the system to load
                                ; the following code
                                ; in FAST ram, if it is free, or if there is
                                ; only CHIP loads it in CHIP.

Inizio:
        move.l  4.w,a6          ; Execbase in a6
        jsr     -$78(a6)        ; Disable - stop multitasking
        lea     GfxName,a1      ; Address of the name of the lib to open in a1
        jsr     -$198(a6)       ; OpenLibrary, EXEC routine that opens
                                ; the libraries, and the address is output to d0
                                ; as the base of that library to make the
                                ; addressing distances (Offset)
        move.l  d0,GfxBase      ; save the GFX base address in GfxBase
        move.l  d0,a6
        move.l  $26(a6),OldCop  ; save the address of the current system copperlist
                                ; (offset $26 from GfxBase)
        move.l  #COPPERLIST,$dff080     ; COP1LC - We point to our COP, $080 is the special register used for this
        move.w  d0,$dff088              ; COPJMP1 - Start the COP, you can write anything to this register to start running the chosen copper
mouse:
        btst    #6,$bfe001      ; left mouse button pressed?
        bne.s   mouse           ; if not, go back to mouse:

        move.l  OldCop(PC),$dff080      ; COP1LC - Point to the saved system COP (restore copper to what it was)
        move.w  d0,$dff088              ; COPJMP1 - let's start the COP

        move.l  4.w,a6
        jsr     -$7e(a6)        ; Enable - re-enable Multitasking
        move.l  GfxBase(PC),a1  ; Base of the library to close
                                ; (libraries must be opened and closed!!!)
        jsr     -$19e(a6)       ; Closelibrary - close the graphics lib
        rts

GfxName:
        dc.b    "graphics.library",0,0  ; NOTE: to store in memory
                                        ; a string of characters always use dc.b
                                        ; and must put them between "", or ''
                                        ; ending with ,0,0


GfxBase:                ; Where we will store the base address for Offsets
        dc.l    0       ; of graphics.library



OldCop:                 ; Where we will store the address of the old system COP
        dc.l    0

        SECTION GRAPHICS,DATA_C  ; This command causes the system to load
                                ; this data segment
                                ; in CHIP RAM
                                ; Copperlists MUST be in CHIP RAM!

COPPERLIST:
        dc.w    $100,$200	;turn off bitplanes
        dc.w    $180,$000	;set a black color to background, draws some black until
        dc.w    $4907,$FFFE     ;wait for this screen position
        dc.w    $180,$001       ;change the colour and then repeat wait for line/change colour
        dc.w    $4a07,$FFFE
        dc.w    $180,$002
        dc.w    $4b07,$FFFE
        dc.w    $180,$003
        dc.w    $4c07,$FFFE
        dc.w    $180,$004
        dc.w    $4d07,$FFFE
        dc.w    $180,$005
        dc.w    $4e07,$FFFE
        dc.w    $180,$006
        dc.w    $5007,$FFFE
        dc.w    $180,$007
        dc.w    $5207,$FFFE
        dc.w    $180,$008
        dc.w    $5507,$FFFE
        dc.w    $180,$009
        dc.w    $5807,$FFFE
        dc.w    $180,$00a
        dc.w    $5b07,$FFFE
        dc.w    $180,$00b
        dc.w    $5e07,$FFFE
        dc.w    $180,$00c
        dc.w    $6207,$FFFE
        dc.w    $180,$00d
        dc.w    $6707,$FFFE
        dc.w    $180,$00e
        dc.w    $6d07,$FFFE
        dc.w    $180,$00f
        dc.w    $7907,$FFFE
        dc.w    $180,$300
        dc.w    $7a07,$FFFE
        dc.w    $180,$600
        dc.w    $7b07,$FFFE
        dc.w    $180,$900
        dc.w    $7c07,$FFFE
        dc.w    $180,$c00
        dc.w    $7d07,$FFFE
        dc.w    $180,$f00
        dc.w    $7e07,$FFFE
        dc.w    $180,$c00
        dc.w    $7f07,$FFFE
        dc.w    $180,$900
        dc.w    $8007,$FFFE
        dc.w    $180,$600
        dc.w    $8107,$FFFE
        dc.w    $180,$300
        dc.w    $8207,$FFFE
        dc.w    $180,$000	;Put black ($000) into background colour
        dc.w    $fd07,$FFFE	
        dc.w    $180,$00a	;draw bottom blue line	
        dc.w    $feff,$FFFE 	;$FFFE = copper wait command
        dc.w    $180,$00f	;set blue colour for rest of bottom bar
        dc.w    $FFFF,$FFFE 	;END OF COPPER

        end
