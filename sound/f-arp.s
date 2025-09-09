;-------------------------------------------------------------------------------
; F major scale arpeggiator
; Program to generate a small varitey of arpeggios based on the F major scale.
;
; REQUIRED FILES
;
;
; TO RUN: (copied from square animations; NEED TO UPDATE)
; Load the character from disc: eg LOAD"CHARS",8,1
; Load the main program from disc: eg LOAD"SQRLN.PRG",8,1
; Relocate character RAM to $1800 (6144): POKE 36869,254
; RUN
;-------------------------------------------------------------------------------

; Structure
;	ADDRESS SYMBOLS
;	JMP MAIN
;	CODE:
;		IRQ CODE
;		MAIN
;		SCREEN ANIMATION CODE


;                              >>> ADDRESSES <<<
;
; ZERO PAGE
IRQDB = $FE ; zp free bytes: $FB-FE

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
LOW_VC   = $900A
MID_VC   = $900B
HIH_VC   = $900C
WNOISE   = $900D
AUXC_VOL = $900E ; [7:4] AUX color in multicolor mode :: [3:0] Audio Vol


;                              >>> JMP MAIN <<<
;
; Makes tass assembler add these two bytes at start of binary (little endian)
	* = $1001
; SYS 4111 - this byte sequence launchs prg by running BASIC: SYS 4111
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JMP MAIN


;                                >>> CODE <<<
;
;---- IRQINIT ------------------------------------------------------------------
; can be found by assembling the code and inspecting the symbol table.
IRQINIT
	SEI
	LDA #$24	; set lo-byte of IRQ wedge subroutine
	STA $0314
	LDA #$10	; set hi-byte of IRQ wedge subroutine
	STA $0315
	LDA #$0
	STA CNTR	; initialize variables used by irq handler
	CLI
	RTS

;---- IRQS ---------------------------------------------------------------------
; IRQ wedge (ie interrupt handler) that calls animation subroutine
IRQS
	INC CNTR
	LDA CNTR
	CMP #10 ; -> IRQ fires every 1/60 sec; qnote = 60 -> CNTR == 60 => beat
		 ; -> let's count 1/8th notes (CNTR == 30)
	BNE IRQEND

	; play next 1/8th note
	JSR NEXTNOTE

	; reset CNTR and increment current beat (CURBT)
	LDA #$00 ; reset counter
	STA CNTR
IRQEND
	JMP $EABF

; IRQ DATA
CNTR	.BYTE	$00

;---- MAIN ---------------------------------------------------------------------
MAIN
	JSR CLR_SCREEN
	JSR IRQINIT
	LDA #$0A
	JSR VOL_SET ; turn sound on
WAIT
	NOP		; Spin in a loop while animation runs
	JMP WAIT

;---- CLR_SCREEN ---------------------------------------------------------------
; Clears screen by writing spaces to character matrix and setting the character
; color to blue. In effect, turns every cell 'on' so that writes to screen RAM
; are immediately visible (no need to set color each time).
CLR_SCREEN
	LDX #$00
	LDA #$20		; PETSCII space char
CLR_LP1
	STA SCR1_RAM, X		; splits screen in half to use 8bit counter
	STA SCR1_RAM + $0100, X
	INX
	BNE CLR_LP1

	; Do color RAM next
	LDX #$00
	LDA #$06		; blue
CLR_LP2
	STA COLR_RAM, X		; splits screen in half to use 8bit counter
	STA COLR_RAM + $0100, X
	INX
	BNE CLR_LP2

	RTS

;---- VOL_SET ------------------------------------------------------------------
; Set Audio Oscillator Global Volume. Range: 0 (OFF) - 15 (FULL)
; Assumes desired vol passed in A reg
VOL_SET
	AND #$0F ; remove upper bits for safety
	STA VTMP
	LDA AUXC_VOL
	AND #$F0 ; clear current vol bits
	ORA VTMP ; OR upper AUX color nibble w/ lower nibble for desired vol
	STA AUXC_VOL
	STA SCR1_RAM+3
	RTS

VTMP	.BYTE	$00

;---- NEXTNOTE -----------------------------------------------------------------
; Plays the next programmed notes from table
NEXTNOTE
	LDX CURBT
	LDA N_TBLE, X
	STA LOW_VC
	STA SCR1_RAM

	INC CURBT ; increment beat counter
	LDA CURBT
	CMP #32   ; beat counter reset @ total num of beats (length of table)
	BNE NN_END
	LDA #0
	STA CURBT
NN_END
	RTS
CURBT 	.BYTE	$00

;---- NOTES TABLE --------------------------------------------------------------
; F arpeggio + arp on 2nd (G)
; F2-A-C-F3 -> G2-Bb-D-G3 :: [VIC chip LOW voice]
; then: C3-E-G-(C4 or B3), Bb3-G-D-Bb2
; Each number is the value for an 1/8th note, so values must be repeated to
; sound for longer durations (eg a quarter note)
N_TBLE	.BYTE	209, 209, 219, 219, 224, 224, 232, 232, 214, 214, 221, 221
	.BYTE	228, 228, 235, 235 
	.BYTE	224, 224, 231, 231, 235, 235, 239, 237, 238, 238, 235, 235
	.BYTE	228, 228, 221, 221
