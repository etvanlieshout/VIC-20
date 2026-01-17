;-------------------------------------------------------------------------------
; SIMPLE BAT CHATACTER SET      
; A simple 1x2 character bat graphic
;-------------------------------------------------------------------------------


	* = $1800	; Char set should be loaded to ADDR $1800 (6144)

; Component Char Structure & Naming:
;	1x2 chars (16px wide, 8px tall): Left half & Right half
;	Could be shifted to be in the center of a 2x2 (16px x 16px) char square

; ~~~~ 2 CHAR BAT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


