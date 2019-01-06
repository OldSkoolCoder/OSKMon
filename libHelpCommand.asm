;*******************************************************************************
;* Help Operation                                                              *
;*******************************************************************************
;* Syntax : ? 
;*******************************************************************************

;COM_HELP
;    lda #<HELPTEXT
;    ldy #>HELPTEXT
;    jsr bas_PrintString$
;    jmp READY

;HELPTEXT
;    BYTE CHR_Return
;    TEXT "assemble : a (addr) (opcode) (operand)", CHR_Return
;    TEXT "command : c (opcode)", CHR_Return
;    TEXT "disassemble : d (addr) (addr)", CHR_Return
;    TEXT "fill : f (addr) (addr) (value)", CHR_Return
;    TEXT "go : g or g (addr)", CHR_Return
;    TEXT "hunt : h (addr) (addr) (data) [up to 11 pieces of data or 25 characters]", CHR_Return
;    TEXT "interpret : i (addr) (addr)", CHR_Return
;    TEXT "load : l ", 34, "filename", 34, " (dev)", CHR_Return
;    TEXT "memory : m (addr) (addr)", CHR_Return
;    TEXT "output : o (y or n)", CHR_Return
;    TEXT "register : r", CHR_Return
;    TEXT "save : s ", 34, "filename", 34, " (dev) (addr) (addr)", CHR_Return
;    TEXT "transfer : t (addr) (addr) (addr)", CHR_Return
;    TEXT "exit : x", CHR_Return
;    TEXT "decimal convertor : # (no.) (range 0 – 65535)", CHR_Return
;    TEXT "hexadecimal convertor : $ (addr) (range 0000 – FFFF)", CHR_Return
;    TEXT "binary convertor : % (16 bit no.) (two sets of eight)", CHR_Return
;    TEXT "octal convertor : @ (6 octal chars) (range 000000-188888)", CHR_Return
;    BRK