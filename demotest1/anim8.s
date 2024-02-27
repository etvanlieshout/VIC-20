;-------------------------------------------------------------------------------
; Program that attempts to animate some rotating squares by flipping between the
; VIC-20's 2 screens
;-------------------------------------------------------------------------------

; Structure
;	Constants
;	JMP MAIN
;	DATA
;	MAIN

; Constants (none needed?)
; Zero Page
;CURSCR      = $10   ; 0=SCR1, 1=SCR2
;CURFRM      = $11   ; current frame number

; Addresses
SCR1_RAM = $1E00
SCR2_RAM = $1C00
CHAR_MEM = $1800
SCRN_SEL = $9002

; Kernel Subroutines
PRINT_CHAR  = $FFD2 ; kernel sR for outputing chars to screen
CRSR_G_S    = $FFF0 ; kernel sR to get/set screen cursor

	* = $1XXX

; SYS 4111 - this byte sequence should launch prg
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JMP MAIN

;== CODE =======================================================================
; --- initialize IRQ wedge: copied from Mastering VIC20 demo on using the timer
IRQINIT
	SEI
	LDA #$XX     ; set lo-byte of IRQ Subroutine
	STA $0314
	LDA #$XX
	STA $0315
	LDA #$0
	STA CNTR
	; move top of RAM down
	; addr: Lo: 00 Hi: 18
	LDA #$00
	STA $37
	LDA #$18
	STA $38
	; move charrom to $1800
	LDA $9005
	AND $F0
	ORA $0E
	STA $9005
	CLI
	RTS

; Interrupt handler: calls interrupts as subroutines
; Interrupt handler begins @ addr $102B
IRQS
	INC CNTR
	LDA CNTR
	CMP #$3C ; == 60 ticks = 1 sec
	BNE IRQEND

	LDA #$00 ; reset counter
	STA CNTR
	LDA SCRN_SEL
	EOR #$80 ; slip screen select bit
	STA SCRN_SEL

IRQEND
	JMP $EABF

; IRQ DATA
CNTR	.BYTE	$00
CURSCR	.BYTE	$00
CURFRM	.BYTE	$00

CHARSET1 ; update chars for screen 1 - should this be part of the interrupt routine? called from
	PHA
	LDX #0
	LDA $11  ; get frame num, since ultimately cyclic with 8 frames
	AND $7   ; this takes the modulus giving us the offset into charmem
	TAY ; for counter
mloop
	ADC #16
	DEY
	BPL mloop ; should only branch on Y >= 0
	SBC #16
	TAY       ; Y should be pointing to start of frame in charmem
	          ; so: char addr = SCR1_RAM + Y w/ Y = 16*FrameNum + X
	          ; With Frame number zero-indexed
	
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X ;completes line
	TXA
	ADC #19 ; 3 + 19 = 22 goes to next line down
	TAX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X ;completes line
	TXA
	ADC #19 ; 3 + 19 = 22 goes to next line down
	TAX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X ;completes line
	TXA
	ADC #19 ; 3 + 19 = 22 goes to next line down
	TAX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X ;completes line
	; DONE, UPDATE FRAME NUM
	INC $11 ; update frame num

	PLA ; pull A off stack
	RTS

