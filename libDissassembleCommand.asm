;*******************************************************************************
;* Disassemble Operation                                                       *
;*******************************************************************************
;* Syntax : D (addr) (addr) <RETURN>
;*******************************************************************************

COM_DISASSEMBLE
    jsr IBYTE2          ; Get Start Address Word
    sta ADDVEC + 1      ; Store Hi Byte
    stx ADDVEC          ; Store Lo Byte
    jsr IBYTE2          ; Get End Address Word
    sta DIS_END + 1     ; Store Hi Byte
    stx DIS_END         ; Store Lo Byte

DIS2
    jsr DIS1            ; Dissassemble One Line of Code
    jsr ADDNB           ; Update Memeory Address
    lda $c5             ; Listen to Keyboard Map
    cmp #63             ; Test for RUN/STOP Key
    bne DIS9            ; Not the Key, then continue
    jmp READY           ; Jump back to Command Line

DIS9
    lda ADDVEC + 1      ; Load Current Memory Address
    cmp DIS_END + 1     ; Test if its bigger that END Address
    beq DIS10           ; Yes, its the same
    jmp DIS2            ; No, Carry on Dissassembling

DIS10
    lda ADDVEC          ; Load Current Memory Address
    cmp DIS_END         ; Test if its Bigger than END Address
    bcc DIS2            ; if less than, continue dissassemble
    jmp READY           ; Goto Comamnd Line

DIS1
    ldy #0              ; initialise index
    lda (ADDVEC),y      ; Load OpCode from Memory Address
    sta COM_P           ; Store in Common P Address
    jsr modsea          ; Get the appropriate mode for this OpCode
    jsr PrintCarrageReturnAndLineFeed
    lda #">"            ; Load Command Line
    jsr krljmp_CHROUT$  ; Print Character
    jsr Print_Comma     ; Print Comma
    jsr SPACE
    lda ADDVEC          ; Load Lo Byte of Address
    ldx ADDVEC + 1      ; Load Hi Byte of Address
    jsr PBYTE2          ; Print Hexadecimal Word
    jsr SPACE
    jsr NOBYT           ; Update Memory Address for next Line

DIS3
    ldy #0              ; Initialise Index

@DIS3
    lda COM_TEXT,y      ; load OpCode Character
    jsr krljmp_CHROUT$  ; Print Character
    iny                 ; increase Y
    cpy #3              ; OpCode is only 3
    bne @DIS3           ; No, then continue printing
    jsr SPACE
    lda COM_MODE        ; Load Mode
    sec 
    sbc #MODE_IMPLIED   ; Subtract Initial Mode to get index
    asl                 ; Multiply by 2
    tay                 ; Transfer to Y index
    lda DISASSEMBLE_JUMP_TABLE,y    ; Get Dissassembly Print Routine
    sta HT
    lda DISASSEMBLE_JUMP_TABLE+1,y
    sta HT + 1
    jmp (HTVEC)         ; Jump to Dissassembly Print Routine

MODSEA
    lda #<OPCodes       ; Initialise OpCode Array Vectors
    sta HT
    lda #>OpCodes
    sta HT + 1

DIS4
    ldy #4              ; initialise index for OpCode Search

DIS5
    lda (HT),y          ; Get OpCode
    cmp COM_P           ; Is it what we have found
    bne dis6            ; No, change vector to next OpCode
    dey                 ; Yes, then decrease index for mode
    lda (HT),y          ; Load Mode for OpCode
    sta COM_MODE        ; Store in Command Mode

DIS7
    dey                 ; Decrease Index
    lda (HT),y          ; Get OpCode Characters
    sta COM_TEXT,y      ; Store in Buffer
    cpy #255            ; Is Index Ended
    bne dis7            ; No, the continue OpCode Instruction Retreival
    rts                 ; Return

DIS6
    ldy #0              ; initialise index
    lda (HT),y          ; Load Memeory Address Value
    beq DIS11           ; Is it Zero, then Error
    clc 
    lda HT              ; Update OpCode Search Vector, for next OpCode
    adc #5
    sta HT
    bcc DIS12
    inc HT + 1

DIS12
    jmp DIS4            ; Continue OpCode Search

DIS11
    ldy #0              ; Initialise Index

DIS8
    lda #"?"            ; Load Error Symbol
    sta COM_TEXT,y      ; Store in Buffer
    iny 
    cpy #3
    bne dis8
    lda #MODE_IMPLIED   ; Load Implied Mode
    sta COM_MODE        ; Store in Command Mode
    rts 

DISASSEMBLE_JUMP_TABLE
    WORD dmoda
    WORD dmodb
    WORD dmodc
    WORD dmodd
    WORD dmode
    WORD dmodf
    WORD dmodg
    WORD dmodh
    WORD dmodi
    WORD dmodj
    WORD dmodk
    WORD dmodl

NUM2
    ldy #2              ; Set For Hi Byte Index
    jsr Print_Dollar    ; Print Dollar Sign
    lda (ADDVEC),y      ; Load Hi Byte Value
    tax                 ; Transfer to X
    dey                 ; Decrease Index
    lda (ADDVEC),y      ; Load Lo Byte Value
    jmp PBYTE2          ; Print Hexadecimal Word

NUM1
    ldy #1              ; Set for Lo Byte Index
    jsr Print_Dollar    ; Print Dollar Sign
    lda (ADDVEC),y      ; Load Lo Byte Value
    jmp PBYTE1          ; Print Hexadecimal Byte

Print_Dollar
    lda #"$"
    BYTE 44

Print_OpenBracket
    lda #CHR_OpenBracket
    BYTE 44

Print_ClosedBracket
    lda #CHR_ClosedBracket
    BYTE 44

Print_Comma
    lda #CHR_Comma
    BYTE 44

Print_X
    lda #"x"
    BYTE 44

Print_Y
    lda #"y"
    jmp krljmp_CHROUT$  ; Print Character

DMODA
    rts                 ; Return immediatly

DMODB
    jmp NUM2            ; Print Hexadecimal Word (Absolute Mode)

DMODC
    jsr NUM2            ; Print Hexadecimal Word (Absolute,X Mode)
    jsr Print_Comma     ; Print Comma
    jmp Print_X         ; Print X

DMODD
    jsr NUM2            ; Print Hexadecimal Word (Absolute,Y Mode)
    jsr Print_Comma     ; Print Comma
    jmp Print_Y         ; Print Y

DMODE
    lda #"#"
    jsr krljmp_CHROUT$  ; Print Character
    jmp NUM1            ; Print Hexadecimal Byte

DMODF
    jsr Print_OpenBracket   ; Print Open Bracket
    jsr NUM2                ; Print Hexadecimal Word
    jmp Print_ClosedBracket ; Print Closed Bracket

DMODG
    jsr Print_OpenBracket   ; Print Open Bracket
    jsr NUM1                ; Print Hexadecimal Byte
    jsr Print_Comma         ; Print Comma
    jsr Print_X             ; Print X
    jmp Print_ClosedBracket ; Print Closed Bracket

DMODH
    jsr Print_OpenBracket   ; Print Open Bracket
    jsr NUM1                ; Print Hexadecimal Byte
    jsr Print_ClosedBracket ; Print Closed Bracket
    jsr Print_Comma         ; Print Comma
    jmp Print_Y             ; Print Y

DMODI
    jmp NUM1                ; Print Hexadecimal Byte

DMODJ
    jsr NUM1                ; Print Hexadecimal Byte
    jsr Print_Comma         ; Print Comma
    jmp Print_X             ; Print X

DMODK
    jsr NUM1                ; Print Hexadecimal Byte
    jsr Print_Comma         ; Print Comma
    jmp Print_Y             ; Print Y

DMODL
    ldy #1
    lda (ADDVEC),y          ; Load Relative Value
    bmi DMODL2              ; Negative Value
    clc 
    adc ADDVEC              ; Add Value to Address
    sta COM_L
    lda ADDVEC + 1
    adc #0
    sta COM_L + 1
    jmp dmodl1              ; Goto Final Workout

DMODL2
    clc 
    adc ADDVEC              ; Sub Value from Address
    sta COM_L
    lda ADDVEC + 1
    sbc #0
    sta COM_L + 1

DMODL1
    clc 
    lda COM_L               ; Add Offset to Address
    adc #2
    sta COM_L
    lda COM_L + 1
    adc #0
    sta COM_L + 1
    jsr Print_Dollar        ; Print Dollar
    ldx COM_L + 1
    lda COM_L
    jmp PBYTE2              ; Print Hexadecimal Word.