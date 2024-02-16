;-------------------------------------------------------------------------------
; Hello World in 6502 assembly on the VIC-20
;
; Best version w/o kernel sr, with all I know
;-------------------------------------------------------------------------------

; Structure
;	CONSTANTS
;	BASIC LAUNCH PROGRAM
;	DATA
;	MAIN

;== CONSTANTS ==================================================================
PRINT_CHAR = $FFD2 ; kernel subroutine for outputing chars to screen
SCR_RAM    = $1E00 ; Mem addr for start of vram matrix
CLR_RAM    = $9600 ; Mem addr for start of color ram matrix

	* = $1001  ; compiler directive that puts this values @ first 2 bytes
		   ; used to determine where in memory prg is loaded

;== BASIC LAUNCH PROGRAM =======================================================
	; A 1-line BASIC program that launches the program with SYS 4111 ($100F)
	; Two zero-bytes ends the 1-line BASIC prg: BRK #00 == .BYTE 00,00
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JMP MAIN

;== DATA =======================================================================
; Hello World where chars are specified by their index into char_rom
DATA	.BYTE	08,05,12,12,15,32,23,15,18,12,04,00

;== MAIN =======================================================================
MAIN
CHARLD ; Load chars from DATA into vram matrix \ 2x label = 2 symbols for addr
	LDX #$00	; use X as offset
LOOPA
	TXA
	PHA		; push X to stack
	LDA DATA, X	; loads A w/ char
	BEQ CHARON	; If byte in A is zero, we're done string, go to char on
	STA SCR_RAM, X	; Store char to screen ram
	PLA
	TAX		; pull X off stack
	INX		; increment X (offset into char data)
	JMP LOOPA

CHARON ; 'Turn on' chars by setting to blue the fg color of the char positions
	LDA #$06 ; bLuE
LOOPB
	CPX #$00
	BEQ DONE
	DEX
	STA CLR_RAM, X
	JMP LOOPB
DONE
	NOP
	JMP DONE	; loop to keep msg on screen; CTRL+C or RESTORE to quit
