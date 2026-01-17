;-------------------------------------------------------------------------------
; TEST SIMPLE BEE CHATACTER SET      
; Test our simple 2x3 character bee graphic by printing it, including color
;-------------------------------------------------------------------------------

	* = $1001

; =>   >   >>  >>  >>> >>> >>> >>>> ADDRESSES <<<< <<< <<< <<<  <<  <<   <   <=
;
; ZERO PAGE
XPOS = $FB ; zp free bytes: $FB-FE
YPOS = $FC
XTMP = $FD

; Memory Locations and Kernel subRs
SCR1_RAM = $1E00
LIN1_RAM = $1E17 ; Selecting from these addresses picks which line the square
LIN2_RAM = $1E6F ; appear on.
LIN3_RAM = $1EC7
LIN4_RAM = $1F1F
LIN5_RAM = $1F77
COLR_RAM = $9600
CHAR_MEM = $1800
SCRN_SEL = $9002
COLR_CTL = $900F


;                              >>> JMP MAIN <<<
;
; Makes tass assembler add these two bytes at start of binary (little endian)
	* = $1001
; SYS 4111 - this byte sequence launchs prg by running BASIC: SYS 4111
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JSR MAIN


;                                >>> CODE <<<
;
;---- MAIN ---------------------------------------------------------------------
MAIN
	JSR INIT_SCREEN
	JSR PRINT_BEE
WAIT
	NOP		; Spin in a loop while animation runs
	JMP WAIT

;---- INIT_SCREEN --------------------------------------------------------------
; Reverses color mode (all char fg are same color, each char can have unique bg)
; and then clears screen.
INIT_SCREEN
	LDA #$00 ; sets inverted mode, shared char fg to red, border to blk
	STA COLR_CTL ; red chosen for testing

	LDX #$00
	LDA #$20		; PETSCII space char
CLR_LP1
	STA SCR1_RAM, X		; splits screen in half to use 8bit counter
	STA SCR1_RAM + $0100, X
	INX
	BNE CLR_LP1

	; Do color RAM next
	LDX #$00 ; redudant, X shsould be 0 here anyway
	LDA #$01		; white
CLR_LP2
	STA COLR_RAM, X		; splits screen in half to use 8bit counter
	STA COLR_RAM + $0100, X
	INX
	BNE CLR_LP2

	RTS

;---- PRINT_BEE ----------------------------------------------------------------
;
PRINT_BEE
	LDX #0
	STX SCR1_RAM + 44
	STX SCR1_RAM + 45
	STX SCR1_RAM + 46
	STX SCR1_RAM
	INX
	STX SCR1_RAM + 1
	INX
	STX SCR1_RAM + 2
	INX
	STX SCR1_RAM + 22
	INX
	STX SCR1_RAM + 23
	INX
	STX SCR1_RAM + 24

	LDX #7 ;7-Yellow;8-Orange;9-LtOrange;15-LTYellow
	STX COLR_RAM + 23

	RTS

;---- CLR_SCREEN ---------------------------------------------------------------
; Clears screen by writing spaces to character matrix and setting the character
; color to blue. In effect, turns every cell 'on' so that writes to screen RAM
; are immediately visible (no need to set color each time).
;CLR_SCREEN
;	LDX #$00
;	LDA #$20		; PETSCII space char
;CLR_LP1
;	STA SCR1_RAM, X		; splits screen in half to use 8bit counter
;	STA SCR1_RAM + $0100, X
;	INX
;	BNE CLR_LP1
;
;	; Do color RAM next
;	LDX #$00
;	LDA #$06		; blue
;CLR_LP2
;	STA COLR_RAM, X		; splits screen in half to use 8bit counter
;	STA COLR_RAM + $0100, X
;	INX
;	BNE CLR_LP2
;
;	RTS
