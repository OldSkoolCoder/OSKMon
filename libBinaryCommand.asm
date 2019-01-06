;*******************************************************************************
;* Binary Convertor Operation                                                  *
;*******************************************************************************
;* Syntax : % (16 bit no.)
;*******************************************************************************

;** binary conv. -- syntax :- % (16 bit no.) **

COM_BINARY
    ldy #0          ; Initialise Storage
    sty HT + 1      ; Hi Byte
    sty HT          ; Lo Byte

BIN2
    jsr krljmp_CHRIN$   ; Get Character From Keyboard Buffer
    cmp #CHR_Return ; Is it Return
    bne BIN3        ; No, process this character
    jmp ERROR       ; Yes, Then Display Error

BIN3
    sec             ; Set Carry
    sbc #"1"        ; Subtract ASCII Code "1"
    rol HT          ; Rotate Left Lo byte
    rol HT + 1      ; Rotate Left Hi Byte
    iny             ; Increase Y
    cpy #16         ; Have done this 16 times
    bne BIN2        ; No, then process next character
    jsr PrintCarrageReturnAndLineFeed
    jsr DECPR       ; Display Decimal Number
    jsr PrintCarrageReturnAndLineFeed
    jsr HEXPR       ; Display HexaDecimal Number
    jsr PrintCarrageReturnAndLineFeed
    jsr OCTPR       ; Display Octal Number
    jmp READY       ; Goto Command Line

;*******************************************************************************
BINPR
    lda #"%"
    jsr krljmp_CHROUT$  ; Print Character
    lda #CHR_Equals
    jsr krljmp_CHROUT$  ; Print Character
    jsr SPACE
    lda HT              ; Load Lo Value
    sta ADDVEC          ; Store in Lo Address
    lda HT + 1          ; Load Hi Value
    sta ADDVEC + 1      ; Store In Hi Address
    ldy #0              ; Initialise Counter

BINPR4
    asl ADDVEC          ; Logical Shift Left into Carry
    rol ADDVEC + 1      ; Rotate Left Hi Byte
    lda #0              ; Load 0
    adc #"0"            ; Add Ascii "0" = "0" or "1" (if Carry Set)
    jsr krljmp_CHROUT$  ; Print Character
    iny                 ; increase counter
    cpy #8              ; 8 times hit
    bne BINPR5          ; No, so process next Bit
    jsr SPACE

BINPR5
    cpy #16             ; 16 bits hit
    bne BINPR4          ; No, Process next Bit
    rts