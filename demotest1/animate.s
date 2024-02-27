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

; Kernel Subroutines
PRINT_CHAR  = $FFD2 ; kernel sR for outputing chars to screen
CRSR_G_S    = $FFF0 ; kernel sR to get/set screen cursor

	* = $1001

; SYS 4111 - this byte sequence should launch prg
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JMP MAIN

; DATA


; sequences:
;	 0  - TUL - TUR -  0
;	LUL - CUL - CUR - RUR
;	LLL - CLL - CLR - RLR
;	 0  - BLL - BLR -  0

VRM1WR	; Write next square gen to Screen 1 video ram
	LDX #$00
	TAX
	STA SCR1_RAM, X


; Screen Flips ; should be an interrupt routine triggered by the jiffy clock
	LDA #22   ; screen2
	STA $9002
	LDA #150  ; screen1
	STA $9002

; Need to put charrom @ $1800
MVCHMEM
	PHA	; push A to stack
	LDA $9005
	AND $F0
	ORA $0E
	STA $9005
	PLA	; pop A from stack
	RTS

CHARSET1 ; update chars for screen 1 - should this be part of the interrupt routine? called from
	PHA
	LDX #0
	LDA $11  ; get frame num, since ultimately cyclic with 8 frames
	AND $7   ; this takes the modulus giving us the offset into charmem
	TAY ; for counter
mloop
	ADC #16
	DEY
	BPL mloop ; should only branch on Y >= 0
	SBC #16
	TAY       ; Y should be pointing to start of frame in charmem
	          ; so: char addr = SCR1_RAM + Y w/ Y = 16*FrameNum + X
	          ; With Frame number zero-indexed
	
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X ;completes line
	TXA
	ADC #19 ; 3 + 19 = 22 goes to next line down
	TAX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X ;completes line
	TXA
	ADC #19 ; 3 + 19 = 22 goes to next line down
	TAX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X ;completes line
	TXA
	ADC #19 ; 3 + 19 = 22 goes to next line down
	TAX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X
	INX
	INY
	LDA CHAR_MEM, Y
	STA SCR1_RAM, X ;completes line
	; DONE, UPDATE FRAME NUM
	INC $11 ; update frame num

	PLA ; pull A off stack
	RTS

;-------------------------------------------------------------------------------
; CHARACTER SET
; Should be located at ADDR $1800 (6144)

	* = $1800

; ~~~~ FRAME 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; TUL 1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; TUR 1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; LUL 1
.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; CUL 1
.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; CUR 1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; RUR 1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; LLL 1
.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; CLL 1
.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; CLR 1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; RLR 1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; BLL 1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; BLR 1
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  1

; ~~~~ FRAME 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  2
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; TUL 2
.BYTE $00,$00,$00,$00,$00,$00,$00,$3E	; TUR 2
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  2
.BYTE $00,$01,$01,$01,$01,$01,$00,$00	; LUL 2
.BYTE $0F,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; CUL 2
.BYTE $FE,$FE,$FE,$FE,$FF,$FF,$FF,$FF	; CUR 2
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; RUR 2
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; LLL 2
.BYTE $FF,$FF,$FF,$FF,$0F,$0F,$0F,$0F   ; CLL 2
.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0   ; CLR 2
.BYTE $00,$00,$80,$80,$80,$80,$80,$00	; RLR 2
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  2
.BYTE $7C,$00,$00,$00,$00,$00,$00,$00	; BLL 2
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; BLR 2
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  2

; ~~~~ FRAME 3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  3
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; TUL 3
.BYTE $00,$00,$00,$00,$00,$00,$0C,$FC	; TUR 3
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  3
.BYTE $00,$00,$03,$03,$01,$01,$01,$01	; LUL 3
.BYTE $01,$1F,$FF,$FF,$FF,$FF,$FF,$FF	; CUL 3
.BYTE $FC,$FC,$FE,$FE,$FE,$FF,$FF,$FF	; CUR 3
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; RUR 3
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; LLL 3
.BYTE $FF,$FF,$FF,$FF,$7F,$7F,$3F,$3F	; CLL 3
.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$F8,$80	; CLR 3
.BYTE $80,$80,$80,$80,$C0,$C0,$00,$00	; RLR 3
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  3
.BYTE $3F,$30,$00,$00,$00,$00,$00,$00	; BLL 3
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; BLR 3
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  3

; ~~~~ FRAME 4 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  4
.BYTE $00,$00,$00,$00,$00,$00,$01,$07	; TUL 4
.BYTE $00,$00,$00,$00,$00,$30,$F0,$F8	; TUR 4
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  4
.BYTE $00,$00,$00,$01,$07,$07,$03,$03	; LUL 4
.BYTE $01,$0F,$7F,$FF,$FF,$FF,$FF,$FF	; CUL 4
.BYTE $F8,$FC,$FC,$FE,$FE,$FE,$FF,$FF	; CUR 4
.BYTE $00,$00,$00,$00,$00,$80,$80,$C0	; RUR 4
.BYTE $03,$01,$01,$00,$00,$00,$00,$00	; LLL 4
.BYTE $FF,$FF,$7F,$7F,$7F,$3F,$3F,$0F	; CLL 4
.BYTE $FF,$FF,$FF,$FF,$FF,$FE,$F0,$80	; CLR 4
.BYTE $C0,$C0,$E0,$E0,$80,$00,$00,$00	; RLR 4
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  4
.BYTE $1F,$0F,$0C,$00,$00,$00,$00,$00	; BLL 4
.BYTE $E0,$80,$00,$00,$00,$00,$00,$00	; BLR 4
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  4

; ~~~~ FRAME 5 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  5
.BYTE $00,$00,$00,$00,$01,$03,$07,$0F	; TUL 5
.BYTE $00,$00,$00,$00,$80,$C0,$E0,$F0	; TUR 5
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  5
.BYTE $00,$00,$00,$00,$01,$03,$07,$0F	; LUL 5
.BYTE $0F,$1F,3FF,$7F,$FF,$FF,$FF,$FF	; CUL 5
.BYTE $F0,$F8,$FC,$FE,$FF,$FF,$FF,$FF	; CUR 5
.BYTE $00,$00,$00,$00,$80,$C0,$E0,$F0	; RUR 5
.BYTE $0F,$07,$03,$01,$00,$00,$00,$00	; LLL 5
.BYTE $FF,$FF,$FF,$FF,$7F,$3F,$1F,$0F	; CLL 5
.BYTE $FF,$FF,$FF,$FF,$FE,$FC,$F8,$F0	; CLR 5
.BYTE $F0,$E1,$C1,$80,$00,$00,$00,$00	; RLR 5
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  5
.BYTE $0F,$07,$03,$01,$00,$00,$00,$00	; BLL 5
.BYTE $F0,$E1,$C1,$80,$00,$00,$00,$00	; BLR 5
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; 00  5
