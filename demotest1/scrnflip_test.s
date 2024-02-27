
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
CLEAR    = $C65C ; $C65E, back up to the LDA @ $C65C
NEW      = $C642 ; subroutine to reset BASIC
; Kernel Subroutines
PRINT_CHAR  = $FFD2 ; kernel sR for outputing chars to screen
CRSR_G_S    = $FFF0 ; kernel sR to get/set screen cursor

	* = $1BB0

; SYS 4111 - this byte sequence should launch prg
	;.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	;BRK #$00
	;JMP MAIN

;== CODE =======================================================================
; --- initialize IRQ wedge: copied from Mastering VIC20 demo on using the timer
IRQINIT
	SEI
	LDA #$CF     ; set lo-byte of IRQ Subroutine
	STA $0314
	LDA #$1B
	STA $0315
	LDA #$0
	STA CNTR
	LDA #$30
	STA NUM
	; move top of RAM down
	; addr: Lo: A0 Hi: 1B
	LDA #$A0
	STA $37
	LDA #$1B
	STA $38
	;LDA #$A0
	;STA $283
	;LDA #$1B
	;STA $284
	;LDA #$A0
	;STA $33
	;LDA #$1B
	;STA $34
	;JSR NEW
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

;; kernel code for CLR BASIC commande (reinits BASIC with lowered mem top)
;;***********************************************************************************;
;;
;; perform CLR
;; CLR kernel subroutine, with absolute addresses
;
;LAB_C659
;	JSR	LAB_C68E		; set BASIC execute pointer to start of memory - 1
;	LDA	#$00			; set Zb for CLR entry
;
;LAB_C65E
;	BNE	LAB_C68D		; exit if following byte to allow syntax error
;
;LAB_C660
;	JSR	LAB_FFE7		; close all channels and files
;LAB_C663
;	LDA	LAB_37		; get end of memory low byte
;	LDY	LAB_38		; get end of memory high byte
;	STA	LAB_33		; set bottom of string space low byte, clear strings
;	STY	LAB_34		; set bottom of string space high byte
;	LDA	LAB_2D		; get start of variables low byte
;	LDY	LAB_2E		; get start of variables high byte
;	STA	LAB_2F		; set end of variables low byte, clear variables
;	STY	LAB_30		; set end of variables high byte
;	STA	LAB_31		; set end of arrays low byte, clear arrays
;	STY	LAB_32		; set end of arrays high byte
;
;;***********************************************************************************;
;;
;; do RESTORE and clear the stack
;
;LAB_C677
;	JSR	LAB_C81D		; perform RESTORE
;
;; flush BASIC stack and clear the continue pointer
;
;LAB_C67A
;	LDX	#LAB_19		; get descriptor stack start
;	STX	LAB_16		; set descriptor stack pointer
;	PLA				; pull return address low byte
;	TAY				; copy it
;	PLA				; pull return address high byte
;	LDX	#$FA			; set cleared stack pointer
;	TXS				; set stack
;	PHA				; push return address high byte
;	TYA				; restore return address low byte
;	PHA				; push return address low byte
;	LDA	#$00			; clear A
;	STA	LAB_3E		; clear continue pointer high byte
;	STA	LAB_10		; clear subscript/FNX flag
;LAB_C68D
;	RTS
;
;
;;***********************************************************************************;
;;
;; set BASIC execute pointer to start of memory - 1
;
;LAB_C68E
;	CLC				; clear carry for add
;	LDA	LAB_2B		; get start of memory low byte
;	ADC	#$FF			; add -1 low byte
;	STA	LAB_7A		; set BASIC execute pointer low byte
;	LDA	LAB_2C		; get start of memory high byte
;	ADC	#$FF			; add -1 high byte
;	STA	LAB_7B		; save BASIC execute pointer high byte
;	RTS
;
