;*******************************************************************************
;* Gosub Operation                                                             *
;*******************************************************************************
;* Syntax : G (addr)<RETURN>
;*******************************************************************************

COM_GOSUB
    jsr INPUT_COMMAND       ; get command line character
    cmp #CHR_Return         ; is it return
    beq GO3                 ; Yes
    jsr ibyte1+3            ; get address word
    jsr ibyte2+3
    sta ADDVEC + 1          ; Store in Address Vector
    stx ADDVEC
    jmp GO_STACK_ADDRESS

GO3
    ldy #0
    lda (ADDVEC),y          ; load Address value
    cmp #0                  ; is it a break BRK instruction
    bne GO_STACK_ADDRESS    ; No, Continue the command

PREPARE_TO_GO
    lda PCHIREG             ; Load PC Counter with Address
    pha                     ; Store it on the stack
    lda PCLOREG
    pha 
    sei                     ; Set Interrupts
    lda IRQINT
    ldx IRQINT + 1
    sta CINV                ; Reset IRQ back to brk values
    stx CINV + 1
    lda NMIINT              ; Reset NMI back to BRK Values
    ldx NMIINT + 1
    sta NMINV
    stx NMINV + 1
    cli                     ; Clear Interrupts
    lda ACCREG              ; Load Registers
    ldx XREG
    ldy YREG
    rts                     ; Return to Stack Address

GO_STACK_ADDRESS
    sec 
    lda ADDVEC              ; Load Address
    sbc #1                  ; Minus 1 as rts is always Address -1
    sta PCLOREG             ; Store Back
    lda ADDVEC + 1
    sbc #0
    sta PCHIREG
    jmp PREPARE_TO_GO