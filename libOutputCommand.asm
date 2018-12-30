;*******************************************************************************
;* Output Operation                                                            *
;*******************************************************************************
;* Syntax : O (y or n) 
;*******************************************************************************

;** output -- syntax :- o (y or n) **
COM_OUTPUT
    jsr INPUT_COMMAND           ; Get next character
    cmp #"y"                    ; Is it Y
    beq BeginPrinterOutput      ; Yes, then set up printer output
    jsr krljmp_CLRCHN$          ; Then its a No then
    lda #4                      ; Load Printer Channel Number
    jsr krljmp_CLOSE$           ; Close Output Channel
    jmp READY                   ; Jump to Command Line

BeginPrinterOutput
    lda #4                      ; Load File Number
    tax                         ; Transfer to Device Number
    ldy #255                    ; Set secondary address
    jsr krljmp_SETLFS$          ; Set up File Number
    lda #0                      ; Set No Filename, not required for printer
    ldx #255
    ldy #255
    jsr krljmp_SETNAM$          ; Set filename that does not exist, but still required
    jsr krljmp_OPEN$            ; Open channel
    ldx #4                      ; Set Channel Number
    jsr krljmp_CHKOUT$          ; Open Channel for output
    jmp READY                   ; Jump To Command Line, and all output will be printed.