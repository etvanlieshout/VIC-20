
;00A0-00A2  160-162  3 byte jiffy clock. The Tl and Tl$

;-------------------------------------------------------------------------------
; Program that flashes the message 'HELLO' in the top left of the screen while
; running a 1-second counter in the top right.
;
; Program uses a main IRQ handler that calls desired subroutines
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

; assemble with 64tass --cbm-prg --list=out.txt -o timer timer.s

; SYS 41xx - this byte sequence launches prg (SYS4111)
	.BYTE $0C,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00  ; not actual BRK but acts as a double $00 byte to end BASIC
	JMP MAIN

; DATA
CNTR	.BYTE	$00
NUM	.BYTE	$30
; none

;== CODE =======================================================================
; --- initially: just copied from Mastering VIC20 demo on using the timer
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

; Interrupt handler: calls interrupts as subroutines
; Interrupt handler begins @ addr $102B
IRQS
	INC CNTR
	LDA CNTR
	CMP #$3C ; == 60 ticks = 1 sec
	BNE I3
I1
	LDA #$00 ; reset counter
	STA CNTR
	JSR TIMER
I2
	JSR FLASHON
I3
	LDA CNTR
	CMP #$1E ; == 30
	BNE IRQEND
	JSR FLASHOFF
IRQEND
	JMP $EABF

; Put timer in top-left
TIMER
	INC NUM
	LDA NUM
	CMP #$3A ; is it 10?
	BNE PRTTMR
	LDA #$30
	STA NUM
PRTTMR
	STA $1E15 ; print char to scrn
	LDA #$02  ; 6=Blu,2=Red,0=BLK,1=WT,4=Magnta
	STA $9615
	RTS

; turn off screen
FLASHOFF
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
	RTS

; turn on screen
FLASHON
	LDX #$00
	LDA #$06  ; White
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	INX
	STA $9600,X
	RTS

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
