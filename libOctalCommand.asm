;*******************************************************************************
;* Octal Convertor Operation                                                   *
;*******************************************************************************
;* Syntax : @ (5 bit no.)
;*******************************************************************************

;** octal conv. -- syntax :- @ (5 bit no.) **

COM_OCTAL
    ldy #0          ; initalise Number
    sty HT + 1
    sty HT

OCTAL1
    jsr krljmp_CHRIN$   ; Get Character
    cmp #CHR_Return     ; Is it Return
    bne OCTAL2          ; No, then Continue
    jmp ERROR           ; Yes, Jump to ERROR

OCTAL2
    sec 
    sbc #"0"            ; Subtract "0" from character value leaving just values 1 or 0
    lsr                 ; Logically shift it to carry bit
    rol HT              ; Rol carry into Number Byte
    rol HT + 1

OCTAL3
    ldx #0              ; Initialise Caracter Index

OCTAL4
    jsr krljmp_CHRIN$   ; Get next Character
    cmp #CHR_Return     ; Is it Return
    bne OCTAL5          ; No, then carry on
    jmp ERROR           ; Yes, then Jump to ERROR

OCTAL5
    sec 
    sbc #"0"            ; Subtract "0" from character value leaving just values 7 -> 0
    ror                 ; Divide by 2
    ror                 ; Divide by 4
    ror                 ; Divide by 8
    ror                 ; rol this bit into carry bit
OCTAL6
    rol                 ; rol the carry into the byte
    rol HT
    rol HT + 1
    inx                 ; increase character index
    cpx #3              ; Check for 4th bit move
    bne OCTAL6          ; No, then we are ok to continue
    iny                 ; Yes, increase chacter counter
    cpy #5              ; Total of 5 characters
    bne OCTAL3          ; No, lets carry on then
                        ; Yes, then print the results
    jsr PrintCarrageReturnAndLineFeed
    jsr DECPR           ; Print Decimal Number
    jsr PrintCarrageReturnAndLineFeed
    jsr HEXPR           ; Print Hex Number
    jsr PrintCarrageReturnAndLineFeed
    jsr BINPR           ; Print Binary Number
    jmp READY

;*******************************************************************************
OCTPR
    lda #"@"
    jsr krljmp_CHROUT$  ; Print Character
    lda #61
    jsr krljmp_CHROUT$  ; Print Character
    jsr SPACE
    lda HT              ; Load Lo value
    sta ADDVEC          ; Store Lo Address
    lda HT + 1          ; Load Hi Value
    sta ADDVEC + 1      ; Store Hi Address

    lda #0              ; Work out fifth Digit
    asl ADDVEC
    rol ADDVEC + 1
    adc #"0"
    jsr krljmp_CHROUT$  ; Print '0' -> '7'
    ldy #0

OCTPR1
    lda #0
    asl ADDVEC          ; Mult by 2
    rol ADDVEC + 1
    rol
    asl ADDVEC          ; Mult by 4
    rol ADDVEC + 1
    rol
    asl ADDVEC          ; Mult by 8
    rol ADDVEC + 1
    rol                 ; this should now have 3 bits in
    adc #"0"
    jsr krljmp_CHROUT$  ; Print '0' -> '7'
    iny                 ; increase character counter
    cpy #5              ; At fifth character
    bne OCTPR1          ; no, then Carry On
    rts                 ; Yes

