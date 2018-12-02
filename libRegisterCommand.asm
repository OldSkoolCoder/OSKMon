;*******************************************************************************
;* Break Operation                                                             *
;*******************************************************************************
;* Syntax : R <RETURN>
;*******************************************************************************

COM_REGISTER
    ldy #>REGISTER_TEXT
    lda #<REGISTER_TEXT
    jsr bas_PrintString$
    lda PCLOREG
    ldx PCHIREG
    jsr PBYTE2
    jsr SPACE
ifdef TGT_C64
    lda IRQINT
    ldx IRQINT + 1
    jsr PBYTE2
    jsr SPACE
    lda NMIINT
    ldx NMIINT + 1
    jsr PBYTE2
    jsr SPACE
endif
    lda STREG
    jsr PBYTE1
    jsr SPACE
    lda ACCREG
    jsr PBYTE1
    jsr SPACE
    lda XREG
    jsr PBYTE1
    jsr SPACE
    lda YREG
    jsr PBYTE1
    jsr SPACE
    lda STPTREG
    jsr PBYTE1
ifdef TGT_C64
    jsr SPACE
    lda STREG
    jsr STATUS_REGISTER
endif
    jmp READY1

REGISTER_TEXT
ifdef TGT_C64
    BYTE 13
    TEXT "b*"
    BYTE 13
    TEXT "   pc   irq nmi  sr ac xr yr sp nv-bdizc"
;    BYTE 13
    WORD $3b3e
    brk 
endif

ifdef TGT_VIC20_8K
    BYTE 13
    TEXT "b*"
    BYTE 13
    TEXT "   pc   sr ac xr yr sp"
;    BYTE 13
    WORD $3b3e
    brk 
endif

;*******************************************************************************
;*                                                                             *
;* status_register                                                             *
;*                                                                             *
;*******************************************************************************
;* This routine prints the contents of the status register                     *
;*******************************************************************************
;*  Inputs : Accumulator : Status Register                                     *
;*******************************************************************************
;* Variables : STREGISTER                                                      *
;*******************************************************************************
;* Code                                                                        *
STATUS_REGISTER
    ldy #0                  ; Initialise Y Register
@STREG1
    sta STREGISTER          ; Store Acc. into Status Register Variable
@STREG3 
    asl STREGISTER          ; logically shift the acc left, and carry set or not
    lda #0                  ; Load Zero into Accu.
    adc #"0"                ; Add "0" to Acc. with  carry
    cpy #2                  ; is y = 2
    bne @STREG2             ; if yes, branch past the '-' symbol
    lda #"-"                ; Load Acc with "-"
@STREG2
    jsr krljmp_CHROUT$      ; Print The contents of the Acc
    iny                     ; increase the index Y
    cpy #8                  ; test for 8 (8th bit of the number)
    bne @STREG3             ; Branch if not equal back to next bit
    rts                     ; Return Back
;*******************************************************************************