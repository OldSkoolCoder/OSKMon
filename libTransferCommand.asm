;*******************************************************************************
;* Transfer Operation                                                          *
;*******************************************************************************
;* Syntax : T (addr) (addr) (addr) 
;*******************************************************************************

;** transfer -- syntax :- t (addr) (addr) (addr) **
COM_TRANSFER
    jsr IBYTE2          ; Get Start Address Word Value
    sta ADDVEC + 1      ; Store Start Address
    stx ADDVEC
    jsr IBYTE2          ; Get End Address Word Value
    sta DIS_END + 1     ; Store End Address
    stx DIS_END
    jsr IBYTE2          ; Get New Start Address Word Value
    sta HTVEC + 1       ; Store New Start Address
    stx HTVEC

StartTransferLooper
    ldy #0
    lda (ADDVEC),y      ; Load Byte from the Old Address
    sta (HTVEC),y       ; Store Byte in the New Address
    lda #1
    sta COM_NB
    jsr ADDNB           ; Update Old Address Counter
    clc 
    inc HTVEC           ; Update New Address Counter
    bne @TRN2
    inc HTVEC + 1

@TRN2
    lda ADDVEC + 1
    cmp DIS_END + 1     ; Have we hit the end Address
    beq @TRN3           ; Yes, then lets be sure
    jmp StartTransferLooper ; No, then please continue

@TRN3
    lda ADDVEC
    cmp DIS_END             ; have we deffo hit the end address
    bcs TransferFinished    ; Yes, then, thats all folks!!!!
    jmp StartTransferLooper ; No, then carry on with the next byte move

TransferFinished
    jmp READY               ; Jump To The Command Line