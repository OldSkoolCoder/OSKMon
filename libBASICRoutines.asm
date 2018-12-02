;*******************************************************************************
;* Get Number From Command Line Routine                                        *
;* Output Variables :                                                          *
;*                    Accumulator has HiByte Value                             *
;*                    X Register has LoByte Value                              *
;*******************************************************************************

LineNumberLo    = $14
LineNumberHi    = $15

GetNumberFromCommandLine
    jsr CHRGOT
    bcs GNFCL_Return        ; No number on command line
    jsr bas_LineGet$        ; Get Integer Value From Command Line
    lda LineNumberHi        ; Stores Hi Integer Value
    ldx LineNumberLo        ; Stores Lo Integer Value
    clc

GNFCL_Return 
    rts

ABIE
    sty 248
    sta 247

@ABIELooper
    ldy #0
    lda (247),y
    cmp #0
    beq @ABIE_EXIT
    jsr krljmp_CHROUT$
    inc 247
    bne @ABIE
    inc 248

@ABIE
    jmp @ABIELooper

@ABIE_EXIT
    jmp ready
