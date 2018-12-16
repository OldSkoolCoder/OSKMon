;*******************************************************************************
;* Command Operation                                                           *
;*******************************************************************************
;* Syntax : C (opcode)<RETURN>
;*******************************************************************************

COM_COMMAND
    ldy #0          ; Initialise Index

@COMMAND1
    jsr INPUT_COMMAND   ; Get Command Character
    sta COM_TEXT,y      ; Store into Buffer
    iny                 ; Increase Index
    cpy #3              ; Only capture 3 characters
    bne @COMMAND1       ; No, not hit 3 yet
    jsr PrintCarrageReturnAndLineFeed   ; Print Line
    lda #<OPCodes       ; Initialise OpCode Array Lo
    sta HT
    lda #>OPCodes       ; Initialise OpCode Array Hi
    sta HT + 1

COM1
    ldy #0              ; Initialise Index

COM2
    lda (HT),y          ; Get Character From Array
    cmp #0              ; Are we at end Of array
    beq COM9            ; Yes, then Jump Out
    cmp COM_TEXT,y      ; Compare with Buffer Text Item
    bcc COM4            ; If less then goto next OpCode
    beq COM9            ; If Equal, test next character
    jmp READY           ; No OpCode Found, Jump to Ready Prompt

COM9
    iny                 ; Increase Index
    cpy #3              ; Have we hit 3 characters
    bne COM2            ; Nope, continue testing
    lda (HT),y          ; Load Mode from array
    sta COM_MODE        ; Store in Command Mode
    jmp COM6            ; Goto Display OpCode Variants

COM4
    clc
    lda HT              ; Add 5 to OpCode Array for next opcode
    adc #5
    sta HT
    bcc COM10
    inc HT + 1

COM10
    jmp COM1            ; Search New Opcode

COM6
    lda COM_MODE        ; Load Command Mode
    sec 
    sbc #MODE_IMPLIED   ; Subtract First Mode to create index
    sta COM_MODE        ; Store back into Command Mode
    asl                 ; multiply by 2
    tax                 ; Move to X Index
    lda DISASSEMBLE_JUMP_TABLE,x    ; Get Lo Byte Jump Location
    sta MODE_JUMP_VEC   ; Store away
    lda DISASSEMBLE_JUMP_TABLE+1,x  ; Get Hi Byte Jump Location
    sta MODE_JUMP_VEC + 1   ; Store away

    lda #<PLACE-1       ; Load Demo Address Location Lo
    sta ADDVEC          ; Store In Address Lo
    lda #>PLACE         ; Load Demo Address Location Hi
    sta ADDVEC + 1      ; Store In Address Hi
    lda HT + 1          
    sta DIS_END + 1
    lda HT
    sta DIS_END
    ldy #0              ; initialise Index

COM8
    lda COM_TEXT,y      ; Load OpCode Character
    jsr krljmp_CHROUT$  ; Print Character
    iny                 ; Increase Y
    cpy #3              ; Dont Pass 3 characters
    bne COM8            ; Go back for next character
    jsr SPACE           ; Print Space

COM7
    jsr JSRG            ; GoSub Jump Vector
    sec 
    jsr krljmp_PLOT$    ; Get Cursor Location
    clc 
    ldy #12             ; Change Y Position to Col 12
    jsr krljmp_PLOT$    ; Set New Cursor Location
    lda COM_mode        ; Load OpCode Mode
    asl                 ; Multiply by 2
    tax                 ; Transfer to X
    lda COM_CTXT+1,x    ; Load Control Text Vector Hi
    tay                 ; Move To Y
    lda COM_CTXT,x      ; Load Control Text Vector Lo
    jsr bas_PrintString$; Print The String @ Location Y*256+A
    jsr PrintCarrageReturnAndLineFeed   ; Print Line
    lda DIS_END + 1
    sta HT + 1
    lda DIS_END
    sta HT
    jmp COM4            ; Is there another Mode to show

PLACE
    WORD $dcba

COM_CTXT
    WORD imp
    WORD abs
    WORD absx
    WORD absy
    WORD immi
    WORD indi
    WORD indx
    WORD indy
    WORD zer
    WORD zerx
    WORD zery
    WORD rela
IMP
    TEXT "implied/accumulator"
    brk 
ABS
    TEXT "absolute"
    brk 
ABSX
    TEXT "absolute,x"
    brk 
ABSY
    TEXT "absolute,y"
    brk 
IMMI
    TEXT "immediate"
    brk 
INDI
    TEXT "indirect"
    brk 
INDX
    TEXT "(indirect,x)"
    brk 
INDY
    TEXT "(indirect),y"
    brk 
ZER
    TEXT "zero-page"
    brk 
ZERX
    TEXT "zero-page,x"
    brk 
ZERY
    TEXT "zero-page,y"
    brk 
RELA
    TEXT "relative"
    brk 
