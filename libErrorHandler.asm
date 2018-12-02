;*******************************************************************************
;*  Error Handler                                                              *
;*******************************************************************************
;* Input Registers :                                                           *
;*  X = Error Number                                                           *
;*******************************************************************************

ErrorHandlerLo  = $22
ErrorHandlerHi  = $23

ErrorHandler
    txa
    pha                     ; Store Away Error Code
    cmp #31
    bcc @ROMError           ; less than 30
    sec
    sbc #31                 ; Subtract Our Error Code start
    asl                     ; Multiply By Two
    tax
    lda @ErrorCodes,x
    sta ErrorHandlerLo
    lda @ErrorCodes+1,x
    sta ErrorHandlerHi
    pla                     ; Retrieve Back Error Code
    jmp bas_CustomError$

@ROMError
    pla                     ; Retrieve Back Error Code
    tax
    jmp bas_ROMError$

@ErrorCodes
    WORD ERRORCODE_31        ; Error Code 31
    WORD ERRORCODE_32        ; Error Code 32
    WORD ERRORCODE_33        ; Error Code 33
    WORD ERRORCODE_34        ; Error Code 34
    WORD ERRORCODE_35        ; Error Code 35
    WORD ERRORCODE_36        ; Error Code 36

ERRORCODE_31
    TEXT "invalid device numbeR"

ERRORCODE_32
    TEXT "chain verifying erroR"

ERRORCODE_33
    TEXT "device not readY"

ERRORCODE_34
    TEXT "33 code erroR"

ERRORCODE_35
    TEXT "34 code erroR"

ERRORCODE_36
    TEXT "35 code erroR"

;*******************************************************************************
;* Show Syntax Error                                                           *
;*******************************************************************************
SYNTAX_ERROR
    lda #32
    sta 129
    ldx #11                 ; Code for Syntax Error
    jmp (jmpvec_Error)      ; Display Error Message

