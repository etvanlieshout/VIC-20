;-------------------------------------------------------------------------------
; Halloween 2026 Demo                      
; Halloween demo with flying bat and (maybe?) jack-o-lantern animation.        
;
; BAT 'sprite' fits into a 1x2 box.
;
; Animation handled by updating vram in response to a timer interrupt.
;
; TO RUN:
; Load the character from disc: eg LOAD"SPIRITS",8,1
; Load the main program from disc: eg LOAD"SPOOKY",8,1
; Relocate character RAM to $1800 (6144): POKE 36869,254
; RUN
;
; TODO: CLEAN UP
;       -- remove commented out lines from earlier versions (broken arithmetic)
;       -- remove old comments and other things from original bounce development
;
;       MODIFY to handle 2 bats simultaneously
;       -- add 2 sets of X/Y POS vars & dir vars
;
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
XTMP = $FD

; Memory Locations and Kernel subRs
SCR1_RAM = $1E00
LIN1_RAM = $1E17 ; Selecting from these addresses picks which line the square
LIN2_RAM = $1E6F ; appear on.
LIN3_RAM = $1EC7
LIN4_RAM = $1F1F
LIN5_RAM = $1F77
COLR_RAM = $9600
LN5_CRAM = $9777
CHAR_MEM = $1800
SCRN_SEL = $9002
COLR_CTL = $900F
CHAR_ROM = $8000


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
	CMP #$07 ; -> 60 ticks = 1 sec; 6 ticks = 1/10 s
	BNE BOUNCE_IRQ

	LDA #$00 ; reset counter
	STA CNTR1
	; JSR SCRNUPDT    ; For testing bouncing bat, leave out bg animation for now
	JMP BAT1

BOUNCE_IRQ
	INC CNTR2
	LDA CNTR2
	CMP #7
	BNE IRQEND_JMP ; irq tooo fat for a branch to jump all the bat info loadings
	JMP BAT2
IRQEND_JMP
	JMP IRQEND

BATS
BAT1
	LDA #$00
	STA CNTR1
	; BAT 1
	; Load the different bats location data into XPOS, YPOS, and POSDIR before calling BOUNCE SR
	LDA B1X
	STA XPOS
	LDA B1Y
	STA YPOS
	LDA B1D
	STA POSDIR
	LDA B1PRVCR
	STA PREV_CHARS				; Load prev char data to restore
	LDA B1PRVCR+1
	STA PREV_CHARS+1
	LDA B1PRVCL
	STA PREV_COLRS				; Load prev char color data to restore
	LDA B1PRVCL+1
	STA PREV_COLRS+1
	JSR BOUNCE
	; Made sure to store bats updated XPOS, YPOS, and POSDIR vars
	LDA XPOS
	STA B1X
	LDA YPOS
	STA B1Y
	LDA POSDIR
	STA B1D
	LDA PREV_CHARS				; Load prev char data to restore next update
	STA B1PRVCR
	LDA PREV_CHARS+1
	STA B1PRVCR+1
	LDA PREV_COLRS				; Load prev char color data to restore next update
	STA B1PRVCL
	LDA PREV_COLRS+1
	STA B1PRVCL+1
	JMP IRQEND
BAT2
	; BAT 2
	LDA #$00
	STA CNTR2
	; Load the different bats location data into XPOS, YPOS, and POSDIR before calling BOUNCE SR
	LDA B2X
	STA XPOS
	LDA B2Y
	STA YPOS
	LDA B2D
	STA POSDIR
	LDA B2PRVCR
	STA PREV_CHARS				; Load prev char data to restore
	LDA B2PRVCR+1
	STA PREV_CHARS+1
	LDA B2PRVCL
	STA PREV_COLRS				; Load prev char color data to restore
	LDA B2PRVCL+1
	STA PREV_COLRS+1
	JSR BOUNCE
	; Made sure to store bats updated XPOS, YPOS, and POSDIR vars
	LDA XPOS
	STA B2X
	LDA YPOS
	STA B2Y
	LDA POSDIR
	STA B2D
	LDA PREV_CHARS				; Load prev char data to restore next update
	STA B2PRVCR
	LDA PREV_CHARS+1
	STA B2PRVCR+1
	LDA PREV_COLRS				; Load prev char color data to restore next update
	STA B2PRVCL
	LDA PREV_COLRS+1
	STA B2PRVCL+1

IRQEND
	JMP $EABF

; IRQ DATA
CNTR1	.BYTE	$00 ; for Bat 1           | Starting counters at different nums
CNTR2	.BYTE	$00 ; for Bar 2           | keeps the all animation from happening together.
CURFRM	.BYTE	$00

; PROGRAM DATA
B1X			.BYTE $00				; Bat 1 x position
B1Y			.BYTE $00				; Bat 1 y position
B1D			.BYTE $03				; Bat 1  direction
B1PRVCR	.BYTE $02, $02	; Bat 1 overwritten chars
B1PRVCL	.BYTE $00, $00	; Bat 1 overwritten chars colors
B2X			.BYTE  19				; Bat 2 x position
B2Y			.BYTE  02				; Bat 2 y position
B2D			.BYTE $02				; Bat 2  direction
B2PRVCR	.BYTE $02, $02	; Bat 2 overwritten chars
B2PRVCL	.BYTE $00, $00	; Bat 2 overwritten chars colors

;---- MAIN ---------------------------------------------------------------------
MAIN
	JSR INIT_SCREEN
	JSR BOUNCE_INIT
	JSR GET_CHARS
	JSR MSG_PRINT
	JSR JACK_PRINT
	JSR IRQINIT
WAIT
	NOP		; Spin in a loop while animation runs
	;JSR MSG_PRINT
	;JSR JACK_PRINT
	JMP WAIT

;---- INIT_SCREEN --------------------------------------------------------------
; Reverses color mode (all char fg are same color, each char can have unique bg)
; and then clears screen.
INIT_SCREEN
	LDA #$98 ; sets noninverted mode, shared char bg to light orange, border to blk
	STA COLR_CTL

	LDX #$00
	LDA #$02		; space char in custom char set
CLR_LP1
	STA SCR1_RAM, X		; splits screen in half to use 8bit counter
	STA SCR1_RAM + $0100, X
	INX
	BNE CLR_LP1

	; Do color RAM next
	LDX #$00 ; redudant, X shsould be 0 here anyway
	LDA #$00		; Black fg against orange bg
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
PREV_CHARS			.BYTE $00, $00	; store char matrix indices for any characters
																; overwritten by previous frame. Used to restore
														    ; overwritten characters (if desired).
PREV_COLRS			.BYTE $00, $00	; Same deal as prev_chars directly above

;---- BOUNCE UPDATE ------------------------------------------------------------
; Screen too big for 8-bits, so will need two versions, one with the VRAM addr
; for the top half of the screen, one for the bottom half
; NEW PLAN: SAT JAN 18: three subroutine calls: GET_SCREEN_HALF, GET_POS_OFFSET, NEXT_POS
BOUNCE
CLR_PREV_BOX
RESTORE_START
	; Clear prev box picture
	;LDA #2 ; load space char to clear
	LDA PREV_CHARS				; load prev char (ie, index into char rom)
	CLC
	CMP #2								; COMPARE w/ 2: if idx < 2 -> bat char is prev char -> skip
	BCC	RESTORE_NEXT			; BCC == strictly less than -> Take Branch (skip) if < 2

	STA COORD_CHAR				; store char to print
	LDA PREV_COLRS				; load prev color
	LDX XPOS
	LDY YPOS
	JSR DRAW_BOX_FROM_COORD
RESTORE_NEXT
	;LDA #2 ; load space char to clear
	LDA PREV_CHARS+1			; load prev char
	CLC
	CMP #2								; COMPARE w/ 2: if idx < 2 -> bat char is prev char -> skip
	BCC	INCREMENT			; BCC == strictly less than -> Take Branch (skip) if < 2
	STA COORD_CHAR				; store char to print
	LDA PREV_COLRS+1			; load prev color
	LDX XPOS
	LDY YPOS
	INX
	JSR DRAW_BOX_FROM_COORD

INCREMENT
	; increment pos
	JSR NXT_POS
	;JSR DB_PRINT_POS ; debuggin info

	; Once x,y incremented -> save new to-be-overwritten chars back to PREV_CHARS


	; Draw next box picture
	LDA #0 ; load first bat char
	STA  COORD_CHAR  ; store char to print
	LDA #0 ; black=0; blue=6, cyan=3, orange=8, yellow=7, light o=9, light yellow=15
	LDX XPOS
	LDY YPOS
	JSR DRAW_BOX_FROM_COORD
	; store old char data
	STA		PREV_CHARS
	STY		PREV_COLRS

	LDA #1 ; load second bat char
	STA  COORD_CHAR  ; store char to print
	LDA #0
	LDX XPOS
	LDY YPOS
	INX
	JSR DRAW_BOX_FROM_COORD
	; store old char data
	STA		PREV_CHARS+1
	STY		PREV_COLRS+1
BOUNCE_END
	RTS

; Comment out changing x coordinate, will just test y direction movmement
NXT_POS ; this should be a subroutine -> can be any parametric equations/formula
	CLC
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
	CMP #21 ; off screen (1x2 square)
	BNE NXT_Y ; if not 23, nothing to change, continue to Y
	JSR XDR_TOG ; 23 -> offscreen, so flip direction
	DEC XPOS ; dec once to undo inc to 23
	JMP XDEC
	CLC
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


; Parameters w/ reg location: A:Color, X:X pos, Y:Y pos
; NEW: subroutine also has petscii char idx pushed to stack, so we can get it
; by popping from the stack directly after poping the bg color off the stack...
; ... at least in theory... didnt work... PHA -> JSR STACK FRAME -> Subroutine
; Instead, just create a mem location
COORD_CHAR			.BYTE $00				; holds the char to be printed @ coordinate
; MODIFIED TO RETURN PREV CHAR IN A AND PREV CHAR COLOR IN Y
DRAW_BOX_FROM_COORD
	PHA ; SETUP: put color on stack...
	TXA ; ...then...
	STA XTMP ; move xpos from x to a, then store in XTMP
	;TXA ; move xpos to a
	;PHA ; push xpos to stack
	;TYA ; move ypos to a
	;PHA ; push ypos to stack
	JSR GET_SCREEN_HALF ; doesn't modify any regs, so shouldn't need to push x,y
	BCS DRAW_LOWR
DRAW_UPPR
	CLC
	; SHOULD ALREADY HAVE YPOS in Y REG & XPOS in X REG
	;LDY YPOS
	LDA #0
UL
	CPY #0
	BEQ UL_END
	CLC ; MUST HAVE THIS! BEQ will set carry flag once per loop, causing an
	    ;  off-by-one error every loop, so off by +y on any given line
	ADC #22
	DEY
	JMP UL
UL_END
	CLC
	ADC XTMP
	;SBC #1
	TAX ; Now X holds offset in scrn ram for prev box
	; MODIFICATION: PULL PREV CHAR DATA FOR LATER RESTORATION
	LDA COLR_RAM, X
	TAY ; NOW Y HOLDS PREV CHAR COLOR INFO
	PLA ; pull color off stack
	STA COLR_RAM, X
	LDA SCR1_RAM, X ; get prev char
	PHA ; push prev char to stack
	LDA COORD_CHAR ; load new char to A
	STA SCR1_RAM, X ; write new char to SCREEN RAM
	PLA ; Pull prev char back to A
	RTS		; should now return w/ prev char in A and prev color in Y

DRAW_LOWR ; for this half, our origin is at y=11, x=14, so just subtract 14 at end
	CLC
	TYA ; move y to a to perform the subtraction
	;LDA YPOS
	SEC
	SBC #11 ; subtracts an extra 1 b/c CLC, helps us skip the 11th row
	;CMP #0
	;BEQ LL0END
	TAY
	LDA #0
LL
	CPY #0
	BEQ LL_END
	CLC
	ADC #22
	DEY
	JMP LL
LL_END
	SEC
	SBC #14 ;
	CLC	
	ADC XTMP
	;ADC #08
	TAX ; Now X holds offset in scrn ram for prev box
	; MODIFICATION: PULL PREV CHAR DATA FOR LATER RESTORATION
	LDA COLR_RAM + $0100, X
	TAY ; NOW Y HOLDS PREV CHAR COLOR INFO
	PLA ; pull color off stack
	STA COLR_RAM + $0100, X
	LDA SCR1_RAM + $0100, X ; get prev char
	PHA ; push prev char to stack
	LDA COORD_CHAR ; load new char to A
	STA SCR1_RAM + $0100, X ; write new char back to SCREEN RAM
	PLA ; Pull prev char back to A
	RTS		; should now return w/ prev char in A and prev color in Y

; tells you which half of screen ram you're in by setting the carry flag:
; Carry set -> 2nd half of screen RAM
; @ start: have xpos in x, ypos in y
GET_SCREEN_HALF
; GET SCREEN HALF LOGIC DRAFT
; 256 = 11*22 + 14 -> if y > 11, 2nd half; if y == 11 && x >= 14, 2nd half
	CLC
	SEC
	;LDY YPOS
	CPY #11
	BMI RET_UPPR ; if y - 11 sets N flag, y < 11 -> all good
	BNE RET_LOWR
	;BPL RET_LOWR
	;LDX XPOS
	SEC
	CPX #14
	BPL RET_LOWR ; y==11 && x < 14 -> all good
RET_UPPR
	;LDA #79
	;STA SCR1_RAM + 22
	;LDA #4
	;STA COLR_RAM + 22
	CLC
	RTS
RET_LOWR
	;LDA #76
	;STA SCR1_RAM + 22
	;LDA #4
	;STA COLR_RAM + 22
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
	;JSR DB_PRINT_POS
	;LDA #8
	;STA COLR_RAM+66
	RTS

DB_PRINT_POS ; print alphabetical coordinate position on screen for debugging
	LDA XPOS
	ADC #01 ; 'A'
	STA SCR1_RAM
	LDA #58 ; ':'
	STA SCR1_RAM+1
	LDA YPOS
	ADC #01 ; 'A'
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

; ---- DRAW JACK'O'LANTERN -----------------------------------------------------
JACK_PRINT
	LDX #$00; offsef counter
	LDY #07 ; Yellow fg color
	LDA #12				; 'Filled Block'
	STA SCR1_RAM+72
	STY COLR_RAM+72
	STA SCR1_RAM+93
	STY COLR_RAM+93
	STA SCR1_RAM+94
	STY COLR_RAM+94
	STA SCR1_RAM+95
	STY COLR_RAM+95
	STA SCR1_RAM+82
	STY COLR_RAM+82
	STA SCR1_RAM+103
	STY COLR_RAM+103
	STA SCR1_RAM+104
	STY COLR_RAM+104
	STA SCR1_RAM+105
	STY COLR_RAM+105

	STA SCR1_RAM+226
	STY COLR_RAM+226
	RTS


; ---- PRINT TEXT --------------------------------------------------------------
MSG_PRINT
	LDY #$00 ; Black fg color
	LDX #$00
	LDA #5				; 'H'
	STA LIN5_RAM+2, X
	STY LN5_CRAM+2
	INX
	LDA #3				; 'A'
	STA LIN5_RAM+2, X
	STY LN5_CRAM+3
	INX
	LDA #9				; 'P'
	STA LIN5_RAM+2, X
	STY LN5_CRAM+4
	INX
	STA LIN5_RAM+2, X
	STY LN5_CRAM+5
	INX
	LDA #11				; 'Y'
	STA LIN5_RAM+2, X
	STY LN5_CRAM+6
	INX
	INX		; SKIP A SPAACE !!
	LDA #5				; 'H'
	STA LIN5_RAM+3, X
	STY LN5_CRAM+9
	INX
	LDA #3				; 'A'
	STA LIN5_RAM+3, X
	STY LN5_CRAM+10
	INX
	LDA #6				; 'L'
	STA LIN5_RAM+3, X
	STY LN5_CRAM+11
	INX
	STA LIN5_RAM+3, X
	STY LN5_CRAM+12
	INX
	LDA #8				; 'O'
	STA LIN5_RAM+3, X
	STY LN5_CRAM+13
	INX
	LDA #10				; 'W'
	STA LIN5_RAM+3, X
	STY LN5_CRAM+14
	INX
	LDA #4				; 'E'
	STA LIN5_RAM+3, X
	STY LN5_CRAM+15
	INX
	STA LIN5_RAM+3, X
	STY LN5_CRAM+16
	INX
	LDA #7				; 'N'
	STA LIN5_RAM+3, X
	STY LN5_CRAM+17

	RTS

; ---- GET LETTER CHARS FROM ROM -----------------------------------------------
; REMEMBER: EACH CHAR IS 8 BYTES !!
GET_CHARS
	LDX		#00
A_CHAR
	LDA		CHAR_ROM+8, X		; 'A' -> 1 * 8
	STA		CHAR_MEM+24, X	; First 3 chars are bat & blank chars; 3 * (8 bytes)
	INX
	CPX		#8
	BNE		A_CHAR

	LDX		#00
E_CHAR
	LDA		CHAR_ROM+40, X	; 'E' -> 5 * 8
	STA		CHAR_MEM+32, X	; Now 4 chars deep; 4 * 8
	INX
	CPX		#8
	BNE		E_CHAR

	LDX		#00
H_CHAR
	LDA		CHAR_ROM+64, X	; 'H'
	STA		CHAR_MEM+40, X
	INX
	CPX		#8
	BNE		H_CHAR

	LDX		#00
L_CHAR
	LDA		CHAR_ROM+96, X	; 'L'
	STA		CHAR_MEM+48, X
	INX
	CPX		#8
	BNE		L_CHAR

	LDX		#00
N_CHAR
	LDA		CHAR_ROM+112, X	; 'N'
	STA		CHAR_MEM+56, X
	INX
	CPX		#8
	BNE		N_CHAR

	LDX		#00
O_CHAR
	LDA		CHAR_ROM+120, X	; 'O'
	STA		CHAR_MEM+64, X
	INX
	CPX		#8
	BNE		O_CHAR

	LDX		#00
P_CHAR
	LDA		CHAR_ROM+128, X	; 'P'
	STA		CHAR_MEM+72, X
	INX
	CPX		#8
	BNE		P_CHAR

	LDX		#00
W_CHAR
	LDA		CHAR_ROM+184, X	; 'W'
	STA		CHAR_MEM+80, X
	INX
	CPX		#8
	BNE		W_CHAR

	LDX		#00
Y_CHAR
	LDA		CHAR_ROM+200, X	; 'Y'
	STA		CHAR_MEM+88, X
	INX
	CPX		#8
	BNE		Y_CHAR

	RTS
