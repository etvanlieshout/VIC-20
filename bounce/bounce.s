;-------------------------------------------------------------------------------
; Tiling Spiral Animation
; Program creates an inward-outward spiralling animation by flipping the
; background color of chars. This allows the animation to run underneath other
; animations.
;
; Animation handled by updating vram in response to a timer interrupt.
;
; TO RUN:
; Load the character from disc: eg LOAD"SQRCHARS",8,1
; Load the main program from disc: eg LOAD"BOUNCE",8,1
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
XPOS = $FB ; zp free bytes: $FB-FE
YPOS = $FC

; Memory Locations and Kernel subRs
SCR1_RAM = $1E00
LIN1_RAM = $1E01 ; Selecting from these addresses picks which line the square
LIN2_RAM = $1E59 ; appear on.
LIN3_RAM = $1EB1
LIN4_RAM = $1F09
LIN5_RAM = $1F61
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
	JMP MAIN


;                                >>> CODE <<<
;
;---- IRQINIT ------------------------------------------------------------------
; Initialize IRQ wedge: adapted from Mastering VIC20 demo on using the timer.
; Init code updates irq vector to point to custom irq wedge (handler); Address
; can be found by assembling the code and inspecting the symbol table.
IRQINIT
	SEI
	LDA #$31	; set lo-byte of IRQ wedge subroutine
	STA $0314
	LDA #$10	; set hi-byte of IRQ wedge subroutine
	STA $0315
	LDA #$0
	STA CNTR1	; initialize variables used by irq handler
	STA CURFRM
	LDA #$01
	STA CNTR2
	LDA #$03
	STA POSDIR
	CLI
	RTS

;---- IRQS ---------------------------------------------------------------------
; IRQ wedge (ie interrupt handler) that calls animation subroutine
IRQS
SQUARE_IRQ
	INC CNTR1
	LDA CNTR1
	CMP #$06 ; -> 60 ticks = 1 sec; 6 ticks = 1/10 s
	BNE BOUNCE_IRQ

	LDA #$00 ; reset counter
	STA CNTR1
	JSR SCRNUPDT

BOUNCE_IRQ
	INC CNTR2
	LDA CNTR2
	CMP #30
	BNE IRQEND

	LDA #$00
	STA CNTR2
	JSR BOUNCE

IRQEND
	JMP $EABF

; IRQ DATA
CNTR1	.BYTE	$00 ; for rotating squares| Starting counters at different nums
CNTR2	.BYTE	$01 ; for bouncing block  | keeps the all animation from happening together.
CURFRM	.BYTE	$00

;---- MAIN ---------------------------------------------------------------------
MAIN
	JSR INIT_SCREEN
	JSR BOUNCE_INIT
	JSR IRQINIT
WAIT
	NOP		; Spin in a loop while animation runs
	JMP WAIT

;---- INIT_SCREEN --------------------------------------------------------------
; Reverses color mode (all char fg are same color, each char can have unique bg)
; and then clears screen.
INIT_SCREEN
	LDA #$64 ; sets inverted mode, shared char fg to red, border to blk
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

POSDIR .BYTE $03 ; bit 1 is y direction, bit 0 is x direction; 1=right/down

;---- BOUNCE UPDATE ------------------------------------------------------------
; Screen too big for 8-bits, so will need two versions, one with the VRAM addr
; for the top half of the screen, one for the bottom half
; NEW PLAN: SAT JAN 18: three subroutine calls: GET_SCREEN_HALF, GET_POS_OFFSET, NEXT_POS
BOUNCE
CLR_PREV_BOX
	LDA #1 ; white
	JSR DRAW_BOX_FROM_COORD
	JSR NXT_POS
	JSR PRINT_POS
	LDA #3 ; blue=6, cyan=3
	JSR DRAW_BOX_FROM_COORD
BOUNCE_END
	RTS

NXT_POS ; this should be a subroutine -> can be any parametric equations/formula
NXT_X
	LDA POSDIR
	AND #$01
	CMP #$00	; 0->DEC, 1->INC
	BNE XINC
XDEC
	DEC XPOS
	LDA XPOS
	CMP #$FF ; $FF = -1 / $FE = -2
	BNE NXT_Y
	JSR XDR_TOG ; pos == -1, flip direction
	INC XPOS    ; inc once to undo dec to -1
	JMP XINC    ; now increment; not needed, can just fall thru
XINC
	INC XPOS
	LDA XPOS
	CMP #22 ; off screen
	BNE NXT_Y ; if not 23, nothing to change, continue to Y
	JSR XDR_TOG ; 23 -> offscreen, so flip direction
	DEC XPOS ; dec once to undo inc to 23
	JMP XDEC

NXT_Y
	LDA POSDIR
	AND #$02
	CMP #$00	; 0->DEC, 1->INC
	BNE YINC
YDEC
	DEC YPOS
	LDA YPOS
	CMP #$FF ; -1
	BNE NXT_POS_END
	JSR YDR_TOG ; pos == -1, flip direction
	INC YPOS    ; inc once to undo dec to -1
	JMP YINC    ; now increment; not needed, can just fall thru
YINC
	INC YPOS
	LDA YPOS
	CMP #23 ; off screen
	BNE NXT_POS_END ; if not 23, nothing to change, continue to Y
	JSR YDR_TOG ; 23 -> offscreen, so flip direction
	DEC YPOS ; dec once to undo inc to 23
	JMP YDEC
NXT_POS_END
	RTS


; takes color in A
DRAW_BOX_FROM_COORD
	PHA ; put color on stack
	JSR GET_SCREEN_HALF ; maybe try an actual ret_val instead of flag?
	BCS DRAW_LOWR
DRAW_UPPR
	LDY YPOS
	LDA #0
	;CLC
UL
	CPY #0
	BEQ UL_END
	ADC #21
	DEY
	JMP UL
UL_END
	ADC XPOS
	;SBC #1
	TAX ; Now X holds offset in scrn ram for prev box
	PLA ; pull color off stack
	STA COLR_RAM, X
	RTS

DRAW_LOWR ; for this half, our origin is at y=11, x=14, so just subtract 14 at end
	LDA YPOS
	SBC #11
	TAY
	LDA #0
	CLC
LL
	CPY #0
	BEQ LL_END
	ADC #21
	DEY
	JMP LL
LL_END
	ADC XPOS
	SBC #15
	;SBC #2
	TAX ; Now X holds offset in scrn ram for prev box
	PLA ; pull color off stack
	STA COLR_RAM + $0100, X
	RTS



; tells you which half of screen ram you're in by setting the carry flag:
; Carry set -> 2nd half of screen RAM
GET_SCREEN_HALF
; GET SCREEN HALF LOGIC DRAFT
; 256 = 11*22 + 14 -> if y > 11, 2nd half; if y == 11 && x >= 14, 2nd half
	CLC
	LDY YPOS
	CPY #11
	BMI RET_UPPR ; if y - 11 sets N flag, y < 11 -> all good
	BNE RET_LOWR
	;BPL RET_LOWR
	LDX XPOS
	CPX #14
	BPL RET_LOWR ; y==11 && x < 14 -> all good
RET_UPPR
	LDA #79
	STA SCR1_RAM + 22
	LDA #4
	STA COLR_RAM + 22
	CLC
	RTS
RET_LOWR
	LDA #76
	STA SCR1_RAM + 22
	LDA #4
	STA COLR_RAM + 22
	SEC
	RTS


XDR_TOG
	LDA POSDIR
	EOR #$01
	STA POSDIR
	RTS

YDR_TOG
	LDA POSDIR
	EOR #$02
	STA POSDIR
	RTS

BOUNCE_INIT
	LDA #$00
	STA XPOS
	STA YPOS
	JSR PRINT_POS
	LDA #3
	STA COLR_RAM
	RTS

PRINT_POS
	LDA XPOS
	ADC #01 ; '0'
	STA SCR1_RAM
	LDA #58
	STA SCR1_RAM+1
	LDA YPOS
	ADC #01 ; '0'
	STA SCR1_RAM+2
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
