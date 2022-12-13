;-------------------------------------------------------------------------------
; Short program to learn about vram on the VIC-20
;
; Program prints hello world to the screen, then dumps the contents of vram
; into an array, then prints that array to the screen
;-------------------------------------------------------------------------------

; Structure
;	Constants
;	JMP MAIN
;	DATA
;	MAIN

; Constants (none needed?)
PRINT_CHAR = $FFD2 ; kernel sR for outputing chars to screen
SCREEN_RAM = $1E00
CRSR_G_S   = $FFF0 ; kernel sR to get/set screen cursor

	* = $1001

; SYS 4111 - this byte sequence should launch prg (taken directly from
;            the disassembled and WORKING metagalactic llamas code)
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JMP MAIN

; DATA
; Hello World + carr rtrn + cursor down + NUL term
DATA	.BYTE	$48,$45,$4C,$4C,$4F,$20,$57,$4F,$52,$4C,$44,$11,$0D,$00
; array for storing vram contents
VRAM	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.BYTE	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00



MAIN
	JSR CLR_SCREEN

	; ** Print Hello World **
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
	; ** copy vram (512 bytes) into array
	LDX #$00
READ_LP
	LDA SCREEN_RAM, X
	STA VRAM, X
	;LDA SCREEN_RAM + $0100, X ; we'll ignore half for now
	;STA VRAM + $0100, X
	INC X
	BNE READ_LP

	;JSR CLR_SCREEN

	; ** print vram to screen byte by byte
	LDX #$00
PRT_LP
	TXA
	PHA		; push X to stack
	LDA VRAM, X
	JSR BYTE_2_HEX
	PLA
	TAX		; PUll X off stack
	INX
	CPX #$20  ;print first 32 bytes of vram
	BNE PRT_LP

DONE2
	NOP
	JMP DONE2 ; infinite loop

; ------------------------------------------------------------------------------
; USR SUBROUTINES
CLR_SCREEN
	LDX #$00
CLR_LP
	LDA #$00
	STA SCREEN_RAM, X	; splits screen in half to use 8bit counter
	STA SCREEN_RAM + $0100, X
	DEX ; see if you can do it with INCREMENT X
	BNE CLR_LP
	RTS

; coverts a byte to hex digits and prints them
BYTE_2_HEX
	PHA ; Push A to stack so we can get/set screen cursor for nice printing
	SEC ; Set carry to get cursor pos
	JSR CRSR_G_S
	CLC
	CPY #18
	BCC GET_NIBS ;if not 21, no need to change cursor, so jmp ahead
	INX ; move Y position down a line
	LDY #$00 ; reset X position to start on line
	CLC ; clear carry to set cursor pos
	JSR CRSR_G_S

GET_NIBS
	PLA ; pull byte back off stack
	TAY ; mov original byte to Y
	; print upper nybble
	AND #$F0
	CLC ; make sure carry is 0 when we shift right
	LSR A ; shift right 1 bit x4
	LSR A
	LSR A
	LSR A
	JSR GET_HEX
	JSR PRINT_CHAR

	; print lower nybble
	TYA
	AND #$0F
	JSR GET_HEX
	JSR PRINT_CHAR

	; print a space
	LDA #32
	JSR PRINT_CHAR
	RTS

; based on value in acc, returns corresponding hex char in acc
GET_HEX
	ADC #$30
	CMP #$3A ; if greater than $39, char is ltter and carry flag set
	BCS LTR  ; branch on carry to letter
	RTS      ; otherwise, we can just return
LTR
	ADC #$06 ; add an additional 7 to move to ascii letter range
	RTS
