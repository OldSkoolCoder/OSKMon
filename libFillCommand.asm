;*******************************************************************************
;* Fill Operation                                                              *
;*******************************************************************************
;* Syntax : F (addr) (addr) (byte) <RETURN>
;*******************************************************************************

COM_FILL
    jsr IBYTE2          ; Get Start Address Word
    sta ADDVEC + 1
    stx ADDVEC
    jsr IBYTE2          ; Get End Address Word
    sta DIS_END + 1
    stx DIS_END
    jsr IBYTE1          ; Get Byte
    sta TEMP

FILL1
    ldy #0              ; initialise Index
    lda TEMP            ; Load Byte Value
    sta (ADDVEC),y      ; Store Value
    lda #1              ; Add 1 to Address
    sta COM_NB
    jsr ADDNB           ; Update Address
    lda ADDVEC + 1
    cmp DIS_END + 1     ; Have we hit the End
    beq FILL2           ; Yes
    jmp FILL1           ; No, keep going

FILL2
    lda ADDVEC
    cmp DIS_END         ; Have we deffo hit the end?
    bne FILL1           ; No
    jmp READY           ; Yes