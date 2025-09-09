;-------------------------------------------------------------------------------
; SPINNING SQUARE ANIMATION
; Program generates an animation of a full screen of 5 lines of 5 4x4 rotating
; squares. Animation handled by updating vram in response to a timer interrupt.
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

	; DEBUG - not necessary, after learning about SEI & CLI
	;INC IRQDB
	;LDA IRQDB
	;STA SCR1_RAM	; print a char to screen each irq; if this char changes,
			; then we know irqs are piling up
	LDA #$00 ; reset counter
	STA CNTR
	JSR SCRNUPDT

	;DEC IRQDB

IRQEND
	JMP $EABF

; IRQ DATA
CNTR	.BYTE	$00
CURFRM	.BYTE	$00

;---- MAIN ---------------------------------------------------------------------
MAIN
	JSR CLR_SCREEN

	;LDA #64         ; loads the offset to beginning of frame #5 char blk
	;LDA #47         ; loads the offset to '/' which inc -> '0' (testing w/
	;STA SCR1_RAM	; regular charset)

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

	PHA	  ; Push A to stack so we can retore it & Y for each row

	LDX #0    ; for upcoming loops after branch

DRAWLP1
	CLC
	STA LIN1_RAM, X
	STA LIN1_RAM + 4, X
	STA LIN1_RAM + 8, X
	STA LIN1_RAM + 12, X
	STA LIN1_RAM + 16, X
	ADC #$04
	STA LIN1_RAM + 22, X
	STA LIN1_RAM + 26, X
	STA LIN1_RAM + 30, X
	STA LIN1_RAM + 34, X
	STA LIN1_RAM + 38, X
	ADC #$04
	STA LIN1_RAM + 44, X
	STA LIN1_RAM + 48, X
	STA LIN1_RAM + 52, X
	STA LIN1_RAM + 56, X
	STA LIN1_RAM + 60, X
	ADC #$04
	STA LIN1_RAM + 66, X
	STA LIN1_RAM + 70, X
	STA LIN1_RAM + 74, X
	STA LIN1_RAM + 78, X
	STA LIN1_RAM + 82, X
	ADC #$04
	INY
	TYA
	INX
	CPX #$04
	BNE DRAWLP1
	LDX #0
	PLA	; reset A and Y for each row
	TAY
	PHA	; preserve A & Y for next row
DRAWLP2
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
	BNE DRAWLP2
	LDX #0
	PLA	; reset A and Y for each row
	TAY
	PHA	; preserve A & Y for next row
DRAWLP3
	CLC
	STA LIN3_RAM, X
	STA LIN3_RAM + 4, X
	STA LIN3_RAM + 8, X
	STA LIN3_RAM + 12, X
	STA LIN3_RAM + 16, X
	ADC #$04
	STA LIN3_RAM + 22, X
	STA LIN3_RAM + 26, X
	STA LIN3_RAM + 30, X
	STA LIN3_RAM + 34, X
	STA LIN3_RAM + 38, X
	ADC #$04
	STA LIN3_RAM + 44, X
	STA LIN3_RAM + 48, X
	STA LIN3_RAM + 52, X
	STA LIN3_RAM + 56, X
	STA LIN3_RAM + 60, X
	ADC #$04
	STA LIN3_RAM + 66, X
	STA LIN3_RAM + 70, X
	STA LIN3_RAM + 74, X
	STA LIN3_RAM + 78, X
	STA LIN3_RAM + 82, X
	ADC #$04
	INY
	TYA
	INX
	CPX #$04
	BNE DRAWLP3
	LDX #0
	PLA	; reset A and Y for each row
	TAY
	PHA	; preserve A & Y for next row
DRAWLP4
	CLC
	STA LIN4_RAM, X
	STA LIN4_RAM + 4, X
	STA LIN4_RAM + 8, X
	STA LIN4_RAM + 12, X
	STA LIN4_RAM + 16, X
	ADC #$04
	STA LIN4_RAM + 22, X
	STA LIN4_RAM + 26, X
	STA LIN4_RAM + 30, X
	STA LIN4_RAM + 34, X
	STA LIN4_RAM + 38, X
	ADC #$04
	STA LIN4_RAM + 44, X
	STA LIN4_RAM + 48, X
	STA LIN4_RAM + 52, X
	STA LIN4_RAM + 56, X
	STA LIN4_RAM + 60, X
	ADC #$04
	STA LIN4_RAM + 66, X
	STA LIN4_RAM + 70, X
	STA LIN4_RAM + 74, X
	STA LIN4_RAM + 78, X
	STA LIN4_RAM + 82, X
	ADC #$04
	INY
	TYA
	INX
	CPX #$04
	BNE DRAWLP4
	LDX #0
	PLA	; reset A and Y for next row
	TAY	; NOTE: no need to push A for final row; doing so => unbalanced stack
DRAWLP5
	CLC
	STA LIN5_RAM, X
	STA LIN5_RAM + 4, X
	STA LIN5_RAM + 8, X
	STA LIN5_RAM + 12, X
	STA LIN5_RAM + 16, X
	ADC #$04
	STA LIN5_RAM + 22, X
	STA LIN5_RAM + 26, X
	STA LIN5_RAM + 30, X
	STA LIN5_RAM + 34, X
	STA LIN5_RAM + 38, X
	ADC #$04
	STA LIN5_RAM + 44, X
	STA LIN5_RAM + 48, X
	STA LIN5_RAM + 52, X
	STA LIN5_RAM + 56, X
	STA LIN5_RAM + 60, X
	ADC #$04
	STA LIN5_RAM + 66, X
	STA LIN5_RAM + 70, X
	STA LIN5_RAM + 74, X
	STA LIN5_RAM + 78, X
	STA LIN5_RAM + 82, X
	ADC #$04
	INY
	TYA
	INX
	CPX #$04
	BNE DRAWLP5
DRAWEND
	RTS
