;*******************************************************************************
;* Decimal Convertor Operation                                                 *
;*******************************************************************************
;* Syntax : # (number)
;*******************************************************************************

;** decimal conv. -- syntax :- # (number) **

COM_DECIMAL
    jsr bas_InLine$         ; Get 16 Bit Decimal Number from command line
    lda #0
    ldx #2
    sta $7a
    stx $7b
    jsr bas_FrmNum$         ; Convert from Floating Point Number in FAC1
    jsr bas_GetAddr$        ; Get 16 Bit Address from FAC1
    jsr PrintCarrageReturnAndLineFeed
    jsr HEXPR               ; Print Hexadecimal Number
    jsr PrintCarrageReturnAndLineFeed
    jsr BINPR               ; Print Binary Number
    jsr PrintCarrageReturnAndLineFeed
    jsr OCTPR               ; Display Octal Number
    jmp READY

;*******************************************************************************
DECPR
    lda #"#"                ; Load Hash
    jsr krljmp_CHROUT$      ; Print Character
    lda #CHR_Equals         ; Load Equals
    jsr krljmp_CHROUT$      ; Print Character
    jsr SPACE
    lda HT + 1              ; Load Hi Value
    ldx HT                  ; Load Lo Value
    jmp bas_LinePrint$      ; Print Decimal Number