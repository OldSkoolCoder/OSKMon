;*******************************************************************************
;* Save Operation                                                              *
;*******************************************************************************
;* Syntax : S "(filename)" (dev) (addr) (addr)
;*******************************************************************************

;** save -- syntax :- s (filename) (dev) (addr) (addr) **
COM_SAVE
    jsr krljmp_CHRIN$
    ldy #0
SAV1
    jsr krljmp_CHRIN$
    cmp #CHR_Quote
    beq SAV2
    sta COM_TEXT,y
    iny 
    cpy #16
    bne SAV1
    jmp ERROR

SAV2
    sty COM_L
    jsr IBYTE1
    tax 
    lda #1
    ldy #1
    jsr krljmp_SETLFS$
    lda COM_L
    ldx #<COM_TEXT
    ldy #>COM_TEXT
    jsr krljmp_SETNAM$
    jsr IBYTE2
    sta ADDVEC + 1
    stx ADDVEC
    jsr IBYTE2
    pha 
    txa 
    pha 
    jsr PrintCarrageReturnAndLineFeed
    pla 
    tax 
    pla 
    tay 
    lda #ADDVEC
    jsr krljmp_SAVE$
    jmp READY