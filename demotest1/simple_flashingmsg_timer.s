
;00A0-00A2  160-162  3 byte jiffy clock. The Tl and Tl$

;-------------------------------------------------------------------------------
; Program that flashes the message 'HELLO' in the top left of the screen while
; running a 1-second counter in the top right.
;
; Program uses a single large interrupt wedge
; assemble with 64tass --cbm-prg --list=out.txt -o timer timer.s
;-------------------------------------------------------------------------------

; Structure
;	CONSTANTS
;	BASIC LAUNCH PROGRAM
;	DATA
;	CODE

;== CONSTANTS ==================================================================
; Zero Page
;CURSCR      = $10   ; 0=SCR1, 1=SCR2
;CURFRM      = $11   ; current frame number

;*00A0-00A2  160-162  Jiffy Clock (HML)
; Addresses
SCR1_RAM = $1E00
SCR2_RAM = $1C00
CHAR_MEM = $1800
SCRN_SEL = $9002

; Kernel Subroutines
PRINT_CHAR  = $FFD2 ; kernel sR for outputing chars to screen
CRSR_G_S    = $FFF0 ; kernel sR to get/set screen cursor

	* = $1001


;== BASIC LAUNCH PROGRAM =======================================================
	.BYTE $0C,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00  ; not actual BRK but acts as a double $00 byte to end BASIC
	JMP MAIN

;== DATA =======================================================================
CNTR	.BYTE	$00
NUM	.BYTE	$30

;== CODE =======================================================================
; Interrupt handler: Single custom interrupt wedge containing counter and
; flashing message. Interrupt 'Init' subroutine and counter interrupt wedge
; slightly modified from section 7.3 'Interrupts and Their Applications' in
; Mastering the VIC-20 by Jones, Coley, and Cole (Ellis Horwood / Wiley 1983).
; Interrupt handler begins @ addr $102B

; Intial your interrupt wedge by disabling the interrupt, updating the IRQ sR,
; and then enabling the IRQ interrupt.
IRQINIT
	SEI
	LDA #$2B     ; set lo-byte of IRQ Subroutine
	STA $0314
	LDA #$10
	STA $0315
	LDA #$0
	STA CNTR
	LDA #$30
	STA NUM
	CLI
	RTS

; Interrupt Wedge: First puts a timer/ counter in the upper right corner of the
; screen, then flashes the "HELLO" message printed in the MAIN routine.
TIMER
	INC CNTR
	LDA CNTR
	CMP #$3C ; == 60 ticks = 1 sec
	BNE FLASHOFF; hope my math is correct for that jump addr
	LDA #$00
	STA CNTR
	INC NUM
	LDA NUM
	CMP #$3A ; is it 10?
	BNE $1049
	LDA #$30
	STA NUM
	STA $1E15 ; print char to scrn
	LDA #$02  ; 6=Blu,2=Red,0=BLK,1=WT,4=Magnta
	STA $9615

; Turn off the msg chars at the half second by setting their fg color to white
FLASHOFF
	LDA CNTR
	CMP #$1E ; == 30
	BNE FLASHON
	LDX #$00
	LDA #$01  ; White
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X

; Turn on the msg chars at the second by setting their fg color to blue
FLASHON
	LDA CNTR
	CMP #$00 ; == 60 or 00
	BNE IRQEND
	LDX #$00
	LDA #$06  ; Blue
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X

IRQEND
	JMP $EABF ; jump to system interrupt handler


MSG	.BYTE 8, 5, 12, 12, 15

MAIN
	JSR IRQINIT

	; turn on screen
	LDX #$00
	LDA #$06  ;Blue
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX

	LDX #$00
	LDA MSG,X
	STA SCR1_RAM,X
	INX
	LDA MSG,X
	STA SCR1_RAM,X
	INX
	LDA MSG,X
	STA SCR1_RAM,X
	INX
	LDA MSG,X
	STA SCR1_RAM,X
	INX
	LDA MSG,X
	STA SCR1_RAM,X
	INX

WAIT
	; wait for Q pressed
	LDA #$00
	JMP  WAIT
