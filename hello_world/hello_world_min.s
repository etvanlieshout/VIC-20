;-------------------------------------------------------------------------------
; Hello World in 6502 assembly on the VIC-20
;-------------------------------------------------------------------------------

; Structure
;	CONSTANTS
;	JMP MAIN (Launch)
;	DATA
;	MAIN

;== CONSTANTS ==================================================================
PRINT_CHAR = $FFD2 ; kernel subroutine for outputing chars to screen

	* = $1001  ; compiler directive that puts this values @ first 2 bytes

;== JUMP MAIN (LAUNCH) =========================================================
	; A 1-line BASIC program that launches the program with SYS 4111 ($100F)
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00,$00,$00
	JMP MAIN

;== DATA =======================================================================
; Hello World + carr rtrn + cursor down + NUL term
DATA	.BYTE	$48,$45,$4C,$4C,$4F,$20,$57,$4F,$52,$4C,$44,$11,$0D,$00

;== MAIN =======================================================================
MAIN

	LDX #$00	; use X as offset
LOOP
	TXA
	PHA		; push X to stack
	LDA DATA, X	; loads A w/ char
	BEQ DONE	; If byte in A is zero, we're done string
	JSR PRINT_CHAR
	PLA
	TAX		; pull X off stack
	INX		; increment X (offset into char data)
	JMP LOOP
DONE
	;JMP DONE 	; loop to keep message on screen
	NOP
