;-------------------------------------------------------------------------------
; Program displays cool loading screen animation
;
; Program uses the jiffy clock interrupt for animation
;-------------------------------------------------------------------------------

;00A0-00A2  160-162  3 byte jiffy clock. The Tl and Tl$

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
LFRM	.BYTE	$00
; none

; --- initially: just copied from Mastering VIC20 demo on using the timer
IRQINIT
	SEI
	LDA #$2C     ; set lo-byte of IRQ Subroutine
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
; Interrupt handler begins @ addr $102C
IRQS
	INC CNTR
	LDA CNTR
	CMP #$3C ; == 60 ticks = 1 sec
	BNE I3
I1
	LDA #$00 ; reset counter
	STA CNTR
	JSR TIMER
	JSR LOADING
I2
	JSR FLASHON
I3
	LDA CNTR
	CMP #$1E ; == 30
	BNE I4
	JSR FLASHOFF
	JSR LOADING
I4
	LDA CNTR
	CMP #10
	BNE I5
	JSR LOADING
I5
	LDA CNTR
	CMP #20
	BNE I6
	JSR LOADING
I6
	LDA CNTR
	CMP #40
	BNE I7
	JSR LOADING
I7
	LDA CNTR
	CMP #50
	BNE IRQEND
	JSR LOADING
IRQEND
	JMP $EABF


; Loading animation
;  0 / $1FC2     1 \ $1FC3
;  2 \ $1FD8     3 / $1FD9
LOADING
	INC LFRM
	LDA LFRM
	CMP #$01
	BNE LFRM1
	; load char bytes
	LDA #85 ; 'U'
	STA $1FC2
	LDA #32 ; ' '
	STA $1FD8
	LDA #06 ; color: blue
	STA $97C2
	STA $97D8
	JMP LFRMEND
LFRM1
	CMP #$02
	BNE LFRM2
	; load char bytes
	LDA #73 ; 'I'
	STA $1FC3
	LDA #32 ; ' '
	STA $1FC2
	LDA #06 ; color: blue
	STA $97C3
	STA $97C2
	JMP LFRMEND
LFRM2
	CMP #$03
	BNE LFRM3
	; load char bytes
	LDA #75 ; 'K'
	STA $1FD9
	LDA #32 ; ' '
	STA $1FC3
	LDA #06 ; color: blue
	STA $97D9
	STA $97C3
	JMP LFRMEND
LFRM3
	LDA #$00
	STA LFRM ; reset frame counter
	; load char bytes
	LDA #74 ; 'J'
	STA $1FD8
	LDA #32 ; ' '
	STA $1FD9
	LDA #06 ; color: blue
	STA $97D8
	STA $97D9
LFRMEND
	; insert loading msg here
	LDA CNTR
LMSGON
	CMP #00
	BNE LMSGOFF
	LDA #12 ;L
	STA $1FEA
	LDA #15 ;O
	STA $1FEB
	LDA #1  ;A
	STA $1FEC
	LDA #4  ;D
	STA $1FED
	LDA #9  ;I
	STA $1FEE
	LDA #14 ;N
	STA $1FEF
	LDA #7  ;G
	STA $1FF0
	LDA #46 ;.
	STA $1FF1
	LDA #46 ;.
	STA $1FF2
	LDA #46 ;.
	STA $1FF3
	LDA #06
	LDX #00
LMSGL1
	CPX #10
	BEQ LMSGEND
	STA $97EA,X
	INX
	JMP LMSGL1
LMSGOFF
	CMP #30
	BNE LMSGEND
	LDA #01
	LDX #00
LMSGL2
	CPX #10
	BEQ LMSGEND
	STA $97EA,X
	INX
	JMP LMSGL2
LMSGEND
	RTS

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
