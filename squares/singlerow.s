;-------------------------------------------------------------------------------
; SPINNING SQUARE ANIMATION
; Program generates an animation of a single line of 5 4x4 rotating squares.
; Animation handled by updating vram in response to a timer interrupt.
;
; CHARACTER FILE REQUIRED: Requires character file laying out the bitmaps for
; the different characters of the animation. The file should be organized by
; animation frame, with the bitmap bytes of each character in the 4x4 frame
; organized left to right, top to bottom.
;
; TO RUN:
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
SCR1_RAM = $1E00
LIN1_RAM = $1E01 ; Selecting from these addresses picks which line the square
LIN2_RAM = $1E59 ; appear on.
LIN3_RAM = $1EB1
LIN4_RAM = $1F09
LIN5_RAM = $1F61
COLR_RAM = $9600
CHAR_MEM = $1800
SCRN_SEL = $9002


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
; Initialize IRQ wedge: adapted from Mastering VIC20 demo on using the timer.
; Init code updates irq vector to point to custom irq wedge (handler); Address
; can be found by assembling the code and inspecting the symbol table.
IRQINIT
	SEI
	LDA #$27	; set lo-byte of IRQ wedge subroutine
	STA $0314
	LDA #$10	; set hi-byte of IRQ wedge subroutine
	STA $0315
	LDA #$0
	STA CNTR	; initialize variables used by irq handler
	STA CURFRM
	CLI
	RTS

;---- IRQS ---------------------------------------------------------------------
; IRQ wedge (ie interrupt handler) that calls animation subroutine
IRQS
	INC CNTR
	LDA CNTR
	CMP #$06 ; -> 60 ticks = 1 sec
	BNE IRQEND

	LDA #$00 ; reset counter
	STA CNTR
	JSR SCRNUPDT

IRQEND
	JMP $EABF

; IRQ DATA
CNTR	.BYTE	$00
CURFRM	.BYTE	$00

;---- MAIN ---------------------------------------------------------------------
MAIN
	JSR CLR_SCREEN
	JSR IRQINIT
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


;---- SCRNUPDT -----------------------------------------------------------------
; Updates the screen with the next frame in the animation
SCRNUPDT
	INC CURFRM
	LDA CURFRM
	CMP #$08
	BNE MULT
	LDA #$00
	STA CURFRM
MULT
	CLC   ; since we know fram number <= 7, won't need to CLC each ROL
	ROL A
	ROL A
	ROL A
	ROL A ; multiply frame # by 16 == left shift x4

	TAY       ; Y should be offset pointing to start of frame in charmem
	          ; so: char index = Y + X w/ Y = 16*FrameNum
	          ; With Frame number zero-indexed
		  ; Y should hold the frame base offset at top of loop (here)

	LDX #0    ; for upcoming loops after branch

DRAWLP
	CLC
	STA LIN2_RAM, X
	STA LIN2_RAM + 4, X
	STA LIN2_RAM + 8, X
	STA LIN2_RAM + 12, X
	STA LIN2_RAM + 16, X
	ADC #$04
	STA LIN2_RAM + 22, X
	STA LIN2_RAM + 26, X
	STA LIN2_RAM + 30, X
	STA LIN2_RAM + 34, X
	STA LIN2_RAM + 38, X
	ADC #$04
	STA LIN2_RAM + 44, X
	STA LIN2_RAM + 48, X
	STA LIN2_RAM + 52, X
	STA LIN2_RAM + 56, X
	STA LIN2_RAM + 60, X
	ADC #$04
	STA LIN2_RAM + 66, X
	STA LIN2_RAM + 70, X
	STA LIN2_RAM + 74, X
	STA LIN2_RAM + 78, X
	STA LIN2_RAM + 82, X
	ADC #$04
	INY
	TYA
	INX
	CPX #$04
	BNE DRAWLP
DRAWEND
	RTS
