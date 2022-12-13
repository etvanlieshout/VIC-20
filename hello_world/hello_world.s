;-------------------------------------------------------------------------------
; Hello World from scratch on VIC-20
;-------------------------------------------------------------------------------

; Structure
;	Constants
;	JMP MAIN
;	DATA
;	MAIN

; Constants (none needed?)
PRINT_CHAR = $FFD2 ; kernel sR for outputing chars to screen
SCREEN_RAM = $1E00

	* = $1001

; SYS 4111 - this byte sequence should launch prg (taken directly from
;            the disassembled and WORKING metagalactic llamas code)
	;.BYTE $00,$A0,$9E,$28,$34,$31,$31,$31,$29,$00
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JMP MAIN

; DATA
; Hello World + carr rtrn + cursor down + NUL term
DATA	.BYTE	$48,$45,$4C,$4C,$4F,$20,$57,$4F,$52,$4C,$44,$11,$0D,$00

MAIN
	JSR CLR_SCREEN

	LDX #$00	; use X as offset
LOOP
	TXA
	PHA		; push X to stack
	LDA DATA, X	; loads A w/ char
	BEQ DONE	; If byte in A is zero, we're done string
	JSR PRINT_CHAR
	PLA
	TAX		; PUll X off stack
	INX		; increment X (offset into char data)
	JMP LOOP
DONE
	;JMP MAIN
	;BRK
	JMP DONE	; infinite loop to keep the message on the screen

CLR_SCREEN
	LDX #$00
CLR_LP
	LDA #$00
	STA SCREEN_RAM, X	; splits screen in half to use 8bit counter
	STA SCREEN_RAM + $0100, X
	DEX ; see if you can do it with INCREMENT X
	BNE CLR_LP
	RTS

;PRINT_CHAR

;***********************************************************************************;
;
;## output character to screen, taken from kernel sR

;AB_E742
;       PHA				; save character
;       STA	LAB_D7		; save temporary last character
;       TXA				; copy X
;       PHA				; save X
;       TYA				; copy Y
;       PHA				; save Y
;       LDA	#$00			; clear A
;       STA	LAB_D0		; clear input from keyboard or screen, $xx = screen,
;       				; $00 = keyboard
;       LDY	LAB_D3		; get cursor column
;       LDA	LAB_D7		; restore last character
;       BPL	LAB_E756		; branch if unshifted

;       JMP	LAB_E800		; do shifted characters and return

;AB_E756
;       CMP	#$0D			; compare with [CR]
;       BNE	LAB_E75D		; branch if not [CR]

;       JMP	LAB_E8D8		; else output [CR] and return

;AB_E75D
;       CMP	#' '			; compare with [SPACE]
;       BCC	LAB_E771		; branch if < [SPACE]

;       CMP	#$60			;.
;       BCC	LAB_E769		; branch if $20 to $5F

;       				; character is $60 or greater
;       AND	#$DF			;.
;       BNE	LAB_E76B		;.

;AB_E769
;       AND	#$3F			;.
;AB_E76B
;       JSR	LAB_E6B8		; if open quote toggle cursor direct/programmed flag
;       JMP	LAB_E6C7		;.

;       				; character was < [SPACE] so is a control character
;       				; of some sort
;AB_E771
;       LDX	LAB_D8		; get insert count
;       BEQ	LAB_E778		; branch if no characters to insert

;       JMP	LAB_E6CB		; insert reversed character

;AB_E778
;       CMP	#$14			; compare with [INSERT]/[DELETE]
;       BNE	LAB_E7AA		; branch if not [INSERT]/[DELETE]

;       TYA				;.
;       BNE	LAB_E785		;.

;       JSR	LAB_E72D		; back onto previous line if possible
;       JMP	LAB_E79F		;.

;AB_E785
;       JSR	LAB_E8E8		; test for line decrement

;       				; now close up the line
;       DEY				; decrement index to previous character
;       STY	LAB_D3		; save cursor column
;       JSR	LAB_EAB2		; calculate pointer to colour RAM
;AB_E78E
;       INY				; increment index to next character
;       LDA	(LAB_D1),Y		; get character from current screen line
;       DEY				; decrement index to previous character
;       STA	(LAB_D1),Y		; save character to current screen line
;       INY				; increment index to next character
;       LDA	(LAB_F3),Y		; get colour RAM byte
;       DEY				; decrement index to previous character
;       STA	(LAB_F3),Y		; save colour RAM byte
;       INY				; increment index to next character
;       CPY	LAB_D5		; compare with current screen line length
;       BNE	LAB_E78E		; loop if not there yet

;AB_E79F
;       LDA	#' '			; set [SPACE]
;       STA	(LAB_D1),Y		; clear last character on current screen line
;       LDA	LAB_0286		; get current colour code
;       STA	(LAB_F3),Y		; save to colour RAM
;       BPL	LAB_E7F7		; branch always

;AB_E7AA
;       LDX	LAB_D4		; get cursor quote flag, $xx = quote, $00 = no quote
;       BEQ	LAB_E7B1		; branch if not quote mode

;       JMP	LAB_E6CB		; insert reversed character

;AB_E7B1
;       CMP	#$12			; compare with [RVS ON]
;       BNE	LAB_E7B7		; branch if not [RVS ON]

;       STA	LAB_C7		; set reverse flag
;AB_E7B7
;       CMP	#$13			; compare with [CLR HOME]
;       BNE	LAB_E7BE		; branch if not [CLR HOME]

;       JSR	LAB_E581		; home cursor
;AB_E7BE
;       CMP	#$1D			; compare with [CURSOR RIGHT]
;       BNE	LAB_E7D9		; branch if not [CURSOR RIGHT]

;       INY				; increment cursor column
;       JSR	LAB_E8FA		; test for line increment
;       STY	LAB_D3		; save cursor column
;       DEY				; decrement cursor column
;       CPY	LAB_D5		; compare cursor column with current screen line length
;       BCC	LAB_E7D6		; exit if less

;       				; else the cursor column is >= the current screen line
;       				; length so back onto the current line and do a newline
;       DEC	LAB_D6		; decrement cursor row
;       JSR	LAB_E8C3		; do newline
;       LDY	#$00			; clear cursor column
;AB_E7D4
;       STY	LAB_D3		; save cursor column
;AB_E7D6
;       JMP	LAB_E6DC		; restore registers, set quote flag and exit

;AB_E7D9
;       CMP	#$11			; compare with [CURSOR DOWN]
;       BNE	LAB_E7FA		; branch if not [CURSOR DOWN]

;       CLC				; clear carry for add
;       TYA				; copy cursor column
;       ADC	#$16			; add one line
;       TAY				; copy back to A
;       INC	LAB_D6		; increment cursor row
;       CMP	LAB_D5		; compare cursor column with current screen line length
;       BCC	LAB_E7D4		; save cursor column and exit if less

;       BEQ	LAB_E7D4		; save cursor column and exit if equal

;       				; else the cursor has moved beyond the end of this line
;       				; so back it up until it's on the start of the logical line
;       DEC	LAB_D6		; decrement cursor row
;AB_E7EC
;       SBC	#$16			; subtract one line
;       BCC	LAB_E7F4		; exit loop if on previous line

;       STA	LAB_D3		; else save cursor column
;       BNE	LAB_E7EC		; loop if not at start of line

;AB_E7F4
;       JSR	LAB_E8C3		; do newline
;AB_E7F7
;       JMP	LAB_E6DC		; restore registers, set quote flag and exit

;AB_E7FA
;       JSR	LAB_E912		; set the colour from the character in A
;       JMP	LAB_ED21		;.

;AB_E800
;       NOP				; just a few wasted cycles
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       AND	#$7F			; mask 0xxx xxxx, clear b7
;       CMP	#$7F			; was it $FF before the mask
;       BNE	LAB_E81D		; branch if not

;       LDA	#$5E			; else make it $5E
;AB_E81D
;       NOP				; just a few wasted cycles
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       NOP				;
;       CMP	#' '			; compare with [SPACE]
;       BCC	LAB_E82A		; branch if < [SPACE]

;       JMP	LAB_E6C5		; insert uppercase/graphic character and return

;       				; character was $80 to $9F and is now $00 to $1F
;AB_E82A
;       CMP	#$0D			; compare with [CR]
;       BNE	LAB_E831		; branch if not [CR]

;       JMP	LAB_E8D8		; else output [CR] and return

;       				; was not [CR]
;AB_E831
;       LDX	LAB_D4		; get cursor quote flag, $xx = quote, $00 = no quote
;       BNE	LAB_E874		; branch if quote mode

;       CMP	#$14			; compare with [INSERT DELETE]
;       BNE	LAB_E870		; branch if not [INSERT DELETE]

;       LDY	LAB_D5		; get current screen line length
;       LDA	(LAB_D1),Y		; get character from current screen line
;       CMP	#' '			; compare with [SPACE]
;       BNE	LAB_E845		; branch if not [SPACE]

;       CPY	LAB_D3		; compare current column with cursor column
;       BNE	LAB_E84C		; if not cursor column go open up space on line

;AB_E845
;       CPY	#$57			; compare current column with max line length
;       BEQ	LAB_E86D		; exit if at line end

;       JSR	LAB_E9EE		; else open space on screen
;       				; now open up space on the line to insert a character
;AB_E84C
;       LDY	LAB_D5		; get current screen line length
;       JSR	LAB_EAB2		; calculate pointer to colour RAM
;AB_E851
;       DEY				; decrement index to previous character
;       LDA	(LAB_D1),Y		; get character from current screen line
;       INY				; increment index to next character
;       STA	(LAB_D1),Y		; save character to current screen line
;       DEY				; decrement index to previous character
;       LDA	(LAB_F3),Y		; get current screen line colour RAM byte
;       INY				; increment index to next character
;       STA	(LAB_F3),Y		; save current screen line colour RAM byte
;       DEY				; decrement index to previous character
;       CPY	LAB_D3		; compare with cursor column
;       BNE	LAB_E851		; loop if not there yet

;       LDA	#' '			; set [SPACE]
;       STA	(LAB_D1),Y		; clear character at cursor position on current screen line
;       LDA	LAB_0286		; get current colour code
;       STA	(LAB_F3),Y		; save to cursor position on current screen line colour RAM
;       INC	LAB_D8		; increment insert count
;AB_E86D
;       JMP	LAB_E6DC		; restore registers, set quote flag and exit

;AB_E870
;       LDX	LAB_D8		; get insert count
;       BEQ	LAB_E879		; branch if no insert space

;AB_E874
;       ORA	#$40			; change to uppercase/graphic
;       JMP	LAB_E6CB		; insert reversed character

;AB_E879
;       CMP	#$11			; compare with [CURSOR UP]
;       BNE	LAB_E893		; branch if not [CURSOR UP]

;       LDX	LAB_D6		; get cursor row
;       BEQ	LAB_E8B8		; branch if on top line

;       DEC	LAB_D6		; decrement cursor row
;       LDA	LAB_D3		; get cursor column
;       SEC				; set carry for subtract
;       SBC	#$16			; subtract one line length
;       BCC	LAB_E88E		; branch if stepped back to previous line

;       STA	LAB_D3		; else save cursor column ..
;       BPL	LAB_E8B8		; .. and exit, branch always

;AB_E88E
;       JSR	LAB_E587		; set screen pointers for cursor row, column ..
;       BNE	LAB_E8B8		; .. and exit, branch always

;AB_E893
;       CMP	#$12			; compare with [RVS OFF]
;       BNE	LAB_E89B		; branch if not [RVS OFF]

;       LDA	#$00			; clear A
;       STA	LAB_C7		; clear reverse flag
;AB_E89B
;       CMP	#$1D			; compare with [CURSOR LEFT]
;       BNE	LAB_E8B1		; branch if not [CURSOR LEFT]

;       TYA				; copy cursor column
;       BEQ	LAB_E8AB		; branch if at start of line

;       JSR	LAB_E8E8		; test for line decrement
;       DEY				; decrement cursor column
;       STY	LAB_D3		; save cursor column
;       JMP	LAB_E6DC		; restore registers, set quote flag and exit

;AB_E8AB
;       JSR	LAB_E72D		; back onto previous line if possible
;       JMP	LAB_E6DC		; restore registers, set quote flag and exit

;AB_E8B1
;       CMP	#$13			; compare with [CLR]
;       BNE	LAB_E8BB		; branch if not [CLR]

;       JSR	LAB_E55F		; clear screen
;AB_E8B8
;       JMP	LAB_E6DC		; restore registers, set quote flag and exit

;AB_E8BB
;       ORA	#$80			; restore b7, colour can only be black, cyan, magenta
;       				; or yellow
;       JSR	LAB_E912		; set the colour from the character in A
;       JMP	LAB_ED30		;.

