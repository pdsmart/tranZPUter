; Configurable parameters.
COLW:   EQU     80                      ; Width of the display screen (ie. columns).
ROW:    EQU     25                      ; Number of rows on display screen.
SCRNSZ: EQU     COLW * ROW              ; Total size, in bytes, of the screen display area.
MODE80C:EQU     1

		INCLUDE "1Z-013A.asm"
