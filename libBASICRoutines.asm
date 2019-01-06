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

;*******************************************************************************
;* My Verion of BASIC Routine $AB1E, but mine does not stop at Page Boundary   *
;* Input Variables :                                                           *
;*                    Accumulator has LoByte Value                             *
;*                    Y Register has HiByte Value                              *
;*******************************************************************************
ABIE
    sty 248                 ; Store Hi String Vector Byte
    sta 247                 ; Store Lo String Vector Byte

@ABIELooper
    ldy #0                  ; Initialise Index
    lda (247),y             ; Get String Character
    cmp #0                  ; Is it End Of String Byte 0
    beq @ABIE_EXIT          ; Yes, Exit Function
    jsr krljmp_CHROUT$      ; No, Print Character
    inc 247                 ; Increase Lo By 1
    bne @ABIE               ; Did I cross Page Boundary
    inc 248                 ; Yes, Increase Hi Byte By 1

@ABIE
    jmp @ABIELooper         ; Loop round for next Character

@ABIE_EXIT
    jmp ready               ; Exit back to Command Line
