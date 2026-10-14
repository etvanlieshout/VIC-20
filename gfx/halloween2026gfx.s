;-------------------------------------------------------------------------------
; HALLOWEEN 2026 DEMO CHARACTER SET
;
; Includes:
;				- A simple 1x2 character bat graphic
;				- An empty space char for clearing char tiles
;				- Space for letters for Happy Halloween to be copied from char rom
;				- Characters for jack'o'lantern face
;-------------------------------------------------------------------------------


	* = $1800	; Char set should be loaded to ADDR $1800 (6144)

; Component Char Structure & Naming:
;	1x2 chars (16px wide, 8px tall): Left half & Right half
;	Could be shifted to be in the center of a 2x2 (16px x 16px) char square

; ~~~~ 2 CHAR BAT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; BASE OFFSET: 0
.BYTE $00,$00,$72,$39,$1F,$0B,$01,$00	; Left Half
.BYTE $00,$00,$9C,$38,$F0,$A0,$00,$00	; Right Half
;
;
; ***  * |*  ***
;  ***  *|  ***
;   *****|****
;    * **|* *
;       *|
;
; -> bat itself is 13px width x 5px height

; ~~~~ MISC CHARS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; BASE OFFSET: 2
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Empty Space for custom char set
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Space for 'A'
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Space for 'E'
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Space for 'H'
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Space for 'L'
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Space for 'N'
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Space for 'O'
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Space for 'P'
.BYTE $00,$00,$00,$00,$00,$00,$00,$00	; Space for 'Y'
.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; Filled Space

; ~~~~ JACK'O'LANTERN CHARS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; BASE OFFSET: 12
.BYTE $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; Filled Space

