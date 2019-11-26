;*******************************************************************************
;* Register Operation                                                          *
;*******************************************************************************
;* Syntax : R <RETURN>
;*******************************************************************************

COM_REGISTER
    ldy #>REGISTER_TEXT             ; Load Address of Registry Header
    lda #<REGISTER_TEXT
    jsr bas_PrintString$            ; Print Registry Header
    lda PCLOREG                     ; Load Programm Counter
    ldx PCHIREG
    jsr PBYTE2                      ; Print as HEX Word Value
    jsr SPACE

ifdef TGT_C64
    lda IRQINT                      ; Load IRQ Vector Address Value
    ldx IRQINT + 1
    jsr PBYTE2                      ; Print as HEX Word Value
    jsr SPACE
    lda NMIINT                      ; Load MNI Vector Address Value
    ldx NMIINT + 1
    jsr PBYTE2                      ; Print as HEX Word Value
    jsr SPACE
endif

    lda STREG                       ; Load Status Register Value
    jsr PBYTE1                      ; Print as HEX Byte Value
    jsr SPACE
    lda ACCREG                      ; Load Accumulator Value
    jsr PBYTE1                      ; Print as HEX Byte Value
    jsr SPACE
    lda XREG                        ; Load X Register Value
    jsr PBYTE1                      ; Print as HEX Byte Value
    jsr SPACE
    lda YREG                        ; Load Y Register Value
    jsr PBYTE1                      ; Print as HEX Byte Value
    jsr SPACE
    lda STPTREG                     ; Load Stack Pointer Value
    jsr PBYTE1                      ; Print as HEX Byte Value

ifdef TGT_C64
    jsr SPACE
    lda STREG                       ; Load Status Register Value
    jsr STATUS_REGISTER             ; Print Status Flags
    jmp READY1                      ; Jump back to Command Line
endif

ifdef TGT_VIC20_8K
    jmp READY
endif


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
    TEXT "   pc  sr ac xr yr sp"
    BYTE 13
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

;*******************************************************************************
;* Register Put Operation                                                      *
;*******************************************************************************
;* Syntax : ; <RETURN>
;*******************************************************************************

COM_REGISTERPUT
    jsr IBYTE2              ; Get Hex Word Value
    sta PCHIREG             ; Store in PC Address
    stx PCLOREG
    
ifdef TGT_C64
    jsr IBYTE2              ; Get Hex Word Value
    sei
    sta IRQINT + 1          ; Store in IRQ Vector location
    stx IRQINT
    jsr IBYTE2              ; Get Hex Word Value
    sta NMIINT + 1          ; Store in NMI Vector Location
    stx NMIINT
    cli
endif

    jsr IBYTE1              ; Get Hex Byte Value
    sta STREG               ; Store in Status Register
    jsr IBYTE1              ; Get Hex Byte Value
    sta ACCREG              ; Store in Accumulator
    jsr IBYTE1              ; Get Hex Byte Value
    sta XREG                ; Store in X Register
    jsr IBYTE1              ; Get Hex Byte Value
    sta YREG                ; Store In Y Register
    jsr IBYTE1              ; Get Hex Byte Value
    sta STPTREG             ; Store in Stck Pointer
    jmp READY               ; Jump to Command Line
