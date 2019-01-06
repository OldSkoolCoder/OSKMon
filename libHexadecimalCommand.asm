;*******************************************************************************
;* Hexadecimal Convertor Operation                                             *
;*******************************************************************************
;* Syntax : $ (addr)
;*******************************************************************************

;** hex conv. -- syntax :- $ (addr) **

COM_HEXDEC
    jsr IBYTE2          ; Get Word Value
    sta HT + 1          ; Store Value
    stx HT
    jsr PrintCarrageReturnAndLineFeed
    jsr DECPR           ; Print Decimal Conversion
    jsr PrintCarrageReturnAndLineFeed
    jsr BINPR           ; Print Binanry Conversion
    jsr PrintCarrageReturnAndLineFeed
    jsr OCTPR           ; Print Octal Conversion
    jmp READY           ; Back To Command Line

;*******************************************************************************
HEXPR
    jsr Print_Dollar    ; Prints Dollar Sign
    lda #CHR_Equals
    jsr krljmp_CHROUT$  ; Prints Equals Sign
    jsr SPACE
    lda HT 
    ldx HT + 1
    jmp PBYTE2          ; Print Hex Word Value
