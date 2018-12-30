;*******************************************************************************
;* Load Operation                                                              *
;*******************************************************************************
;* Syntax : L "(filename)" (dev) <RETURN>
;*******************************************************************************

;** load -- syntax :- l (filename) (dev) **

COM_LOAD
    jsr krljmp_CHRIN$       ; get character
    ldy #0                  ; initialise index
    
LO1
    jsr krljmp_CHRIN$       ; get character
    cmp #CHR_Quote          ; Is it a Quote
    beq LO2                 ; yes, the goto load routine
    sta COM_TEXT,y          ; store this character in filename buffer
    iny                     ; increase index
    cpy #16                 ; 16 characters
    bne LO1                 ; no, keep getting filename characters
    jmp ERROR               ; yes, display error

LO2
    sty COM_L               ; store length of filename
    jsr IBYTE1              ; get hexadecimal byte (device)
    tax                     ; transfer into X for SETLFS routine
    ldy #1                  ; Load Secondary Command 
    lda #1                  ; Load logical file number #1
    jsr krljmp_SETLFS$      ; Set up the LFS
    jsr PrintCarrageReturnAndLineFeed
    lda COM_L               ; Load filename length
    ldx #<COM_TEXT          ; load address of filename
    ldy #>COM_TEXT
    jsr krljmp_SETNAM$      ; Set filename for logical file number
    lda #0                  ; Set for load
    jsr krljmp_LOAD$        ; Perform Load
    jmp READY               ; back to command line