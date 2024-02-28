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
;CURSCR      = $10   ; 0=SCR1, 1=SCR2
;CURFRM      = $11   ; current frame number

; Addresses
SCR1_RAM = $1E00
SCR0_RAM = $1C00
CHAR_MEM = $1800
SCRN_SEL = $9002

; Kernel Subroutines
PRINT_CHAR  = $FFD2 ; kernel sR for outputing chars to screen
CRSR_G_S    = $FFF0 ; kernel sR to get/set screen cursor

	* = $1XXX

; SYS 4111 - this byte sequence should launch prg
	.BYTE $0D,$10,$0A,$00,$9E,$28,$34,$31,$31,$31,$29,$00
	BRK #$00
	JMP MAIN

;== CODE =======================================================================
; --- initialize IRQ wedge: copied from Mastering VIC20 demo on using the timer
IRQINIT
	SEI
	LDA #$XX     ; set lo-byte of IRQ Subroutine
	STA $0314
	LDA #$XX
	STA $0315
	LDA #$0
	STA CNTR
	; move top of RAM down
	; addr: Lo: 00 Hi: 18
	LDA #$00
	STA $37
	LDA #$18
	STA $38
	; move charrom to $1800
	LDA $9005
	AND $F0
	ORA $0E
	STA $9005
	CLI
	RTS

; Interrupt handler: calls interrupts as subroutines
; Interrupt handler begins @ addr $XXXX
;IRQS
;	INC CNTR
;	LDA CNTR
;	CMP #$06 ; == 60 ticks = 1 sec, 6 == 1/10
;	BNE IRQEND
;
;	LDA #$00 ; reset counter
;	STA CNTR
;	LDA SCRN_SEL
;	EOR #$80 ; flip screen select bit
;	STA SCRN_SEL
;	LDA CURSCR
;	EOR #$01
;	STA CURSCR
;
;IRQEND
;	JMP $EABF
;
;; IRQ DATA
;CNTR	.BYTE	$00
;CURSCR	.BYTE	$00
;CURFRM	.BYTE	$00

ANIM8:
	; loop here
	; coordinate CURSCR and CURFRM: even frames for scr 0, odd for scr 1
	LDA CURFRM ; CURFRM updated by CHARUPDT, CURSCR updated by IRQ
	CMP #6
	BNE continue
	LDA #$00   ; reset CURFRM at 5
	STA CURFRM
continue
	AND #$01   ; mask to get at parity of FRM number
	EOR CURSCR ; if CURSCR & CURFRM parity is different, result is 1
	BEQ ANIM8  ; if same parity, nothing to update
	LDA #$08   ; need to update; note this means the result of prev EOR leaves 1 in A
	EOR SRAM_P+1
	STA SRAM_P+1 ; toggle pointer to screen ram
	JSR CHARUPDT
	JMP ANIM8

CHARUPDT
CHARSET1 ; update chars for screen 1 - should this be part of the interrupt routine? called from
; should this be generic, not screen number specific?
	LDA CURFRM  ; get frame num, since ultimately cyclic with 8 frames
	AND #$7   ; this takes the modulus giving us the offset into charmem
	STA CURFRM ; not really needed everytime
	INC CURFRM ; increment current frame!

; expects current fram number in A
SCR0UPDT
	TAY ; use frame no for multiply loop counter
	LDA #$00
mloop   ; multiply loop for charrom offset
	ADC #16
	DEY
	BPL mloop ; should only branch on Y >= 0
	SBC #16
	TAY       ; Y should be offset pointing to start of frame in charmem
	          ; so: char index = Y + X w/ Y = 16*FrameNum
	          ; With Frame number zero-indexed
	
	; Y should hold the base ofset at top here
	LDX #0

; NOTE: Can use ($ADDR) mode to LDA/STA to a pointer saved in memory!
inlp0 	; inner update loop for screen zero
	STY SCR0_RAM, X ; Y should hold the cahr index offset at top here
	INY
	INX
	TYA
	AND #$0F	; mod 16, tells us if we're done frame
	BEQ scr0end
	AND #$03
	BNE inlp0	; Loop if % 4 result is not zero.
	TXA      	; if not @ end but @ end of row, move X to A,
	ADC #19 	; add 19 to get to next row in SCRNRAM & continue.
	TAX
	JMP  inlp0
scr0end
	RTS

