
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
CURSCR      = $10   ; 0=SCR1, 1=SCR2
CURFRM      = $11   ; current frame number

; Addresses
SCR1_RAM = $1E00
SCR2_RAM = $1C00
CHAR_MEM = $1800
SCRN_SEL = $9002

; Kernel Subroutines
PRINT_CHAR  = $FFD2 ; kernel sR for outputing chars to screen
CRSR_G_S    = $FFF0 ; kernel sR to get/set screen cursor

	* = $1BD6

; SYS 4111 - this byte sequence should launch prg
	;.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	;BRK #$00
	;JMP MAIN

;== CODE =======================================================================
; --- initialize IRQ wedge: copied from Mastering VIC20 demo on using the timer
IRQINIT
	SEI
	LDA #$ED     ; set lo-byte of IRQ Subroutine
	STA $0314
	LDA #$1B
	STA $0315
	LDA #$0
	STA CNTR
	LDA #$30
	STA NUM
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
NUM	.BYTE	$00

