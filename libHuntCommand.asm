;*******************************************************************************
;* Hunt Operation                                                              *
;*******************************************************************************
;* Syntax : H (addr) (addr) (text) <RETURN>
;*******************************************************************************

COM_HUNT
    jsr IBYTE2          ; Get Start Address
    sta ADDVEC + 1      ; Store Start Address
    stx ADDVEC
    jsr IBYTE2          ; Get End Address
    sta DIS_END + 1     ; Store End Address
    stx DIS_END
    ldy #0              ; Initialise String Index
    sty COM_L
    jsr INPUT_COMMAND   ; Get NExt Command Character
    cmp #CHR_Quote      ; Is it Quotes
    beq HUN2            ; Yes, then goto ASCII Search
    bne HUN7            ; No, goto byte search

HUN3
    jsr INPUT_COMMAND   ; Get Next Command Character  
    cmp #CHR_Return     ; Is it Return
    beq HUN4            ; Yes, goto Searching

HUN7
    jsr IBYTE1+3        ; Get Byte Data To Search On
    sta COM_TEXT,y      ; Store in Buffer
    inc COM_L           ; increase number of byte counter
    ldy COM_L           ; load byte counter
    ;iny 
    ;sty COM_L
    cpy #11             ; 11 characters
    beq HUN8            ; Yes, then error
    jmp HUN3            ; No, then get next character

HUN8
    jmp ERROR           ; Error

HUN2
    jsr krljmp_CHRIN$   ; Get next ASCII Character
    cmp #CHR_Return     ; Is it Return
    beq HUN4            ; Yes, then start Searching
    sta COM_TEXT,y      ; Store in buffer
    inc COM_L           ; increase number of characters
    ldy COM_L           ; load number of characters
    ;iny 
    ;sty COM_L
    cpy #20             ; 20 ?
    beq HUN9            ; Yes, goto Error
    jmp HUN2            ; Get next character

HUN9
    jmp ERROR           ; Error

HUN4
    sty COM_L           ; store number of bytes
    jsr PrintCarrageReturnAndLineFeed

HUN5
    ldy #0              ; initialise index
HUN13
    lda (ADDVEC),y      ; load value from memory
    cmp COM_TEXT,y      ; compare with buffer
    beq HUN10           ; its the same, try the next character
    lda #1              ; No, set add nb to 1
    sta COM_NB          ; store it
    jsr ADDNB           ; increase Address with NB value
    jmp HUN6            ; Goto Test to see if we hit the end

HUN10
    iny                 ; increase index 
    cpy COM_L           ; the same as the buffer
    bne HUN13           ; No, continue testing
    lda ADDVEC          ; Yup, found the string, load addesss
    ldx ADDVEC + 1
    jsr PBYTE2          ; Print Address where string found
    jsr SPACE
    lda COM_L           ; load string length
    sta COM_NB          ; store in nb for add
    jsr ADDNB           ; add to address vectors

HUN6
    lda ADDVEC + 1      ; load addess hi
    cmp DIS_END + 1     ; is it the same as end address hi
    beq HUN11           ; Yes, better test lo byte
    jmp HUN5            ; No, carry on searching

HUN11
    lda ADDVEC          ; load address lo
    cmp DIS_END         ; test end address lo
    bcs HUN12           ; greater then, then finish
    jmp HUN5            ; less than, carry on searching

HUN12
    jmp READY           ; Back to Command Line
