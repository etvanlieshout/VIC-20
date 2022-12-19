;-------------------------------------------------------------------------------
; Short program that dumps the VIC-20 character rom conents to the screen
;-------------------------------------------------------------------------------

; CONSTANTS --------------------------------------------------------------------
PRINT_CHAR = $FFD2
VRAM       = $1E00
LAST_KEY   = $C5  ;zp addr
CHAR_ROM_START = $9005 ;addr storing the start addr of char rom, change the
                       ; value stored here to access different areas of charrom

; LAUNCH -----------------------------------------------------------------------
	*  = $1001	; Ensures program begins at addr $1001, unexpanded RAM

	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JMP MAIN

; DATA -------------------------------------------------------------------------


; MAIN -------------------------------------------------------------------------
;	PROGRAM: prints the contents of vram, as chars, to screen in order to
;	view the contents of the VIC-20 character rom. VRAM stores offsets into
;	the char ROM, so storing an incrementing counter to each successive
;	location of VRAM will print everything to the screen.
;	VIC-20 screen is 22 x 23 = 506 chars (default), plenty of space for all
;	the chars (?).

MAIN

	LDX #$00	; initialize X as our counter

; print the first 256 chars
VRAM_WRITE_LOOP1
	TXA
	STA VRAM, X
	;STA VRAM + $0100, X
	INX
	BNE VRAM_WRITE_LOOP1 ; break loop when X wraps back around to zero again

; print next 250 chars
;VRAM_WRITE_LOOP2
	;TXA
	;STA VRAM, X
	;STA VRAM + $0100, X
	;INX
	;BNE VRAM_WRITE_LOOP2

	; NOTE: even though the display can only output 506 chars, VRAM itself
	; is 512 bytes, so we don't need to worry about those last 5 bytes
	; beyond what the screen can print being written to VRAM. Assumedly they
	; are just ignored

; keep program on screen until 'q' pressed
DONE_LOOP
	LDA LAST_KEY
	CMP #$30	; Q == $30
	BNE DONE_LOOP
	BRK
