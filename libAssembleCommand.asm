;*******************************************************************************
;* Assemble Operation                                                          *
;*******************************************************************************
;* Syntax : A (addr) (opcode) (operand) <RETURN>
;*******************************************************************************

COM_ASSEMBLE
    jsr IBYTE2          ; get address word
    stx ADDVEC          ; store address 
    sta ADDVEC + 1
    ldy #0              ; initialise length = 0
ASS1
    jsr INPUT_COMMAND   ; get next command character
    cmp #CHR_Return     ; is RETURN?
    beq ASS2            ; Yes
    sta COM_TEXT,y      ; No, store character into buffer
    iny                 ; add 1 to number of characters
    jmp ASS1            ; get next character
 
ASS2
    sty COM_L           ; store buffer length
    cpy #0              ; no characters stored?
    bne @ASS2           ; No, 
    jmp READY           ; Yes, return back to command line

@ASS2
    jsr MODE_HUNT       ; Determine which addressing mode this command is
    sta COM_MODE
    cmp #MODE_ERROR     ; check for invalid addressign mode
    bne @ASS3           ; No, valid mode
    jmp ERROR           ; Yes, display error

@ASS3
    jsr OPCODE_SEARCH   ; Search for OpCode
    sta COM_CODE
    jsr NOBYT           ; Detemine Number Of Bytes for the mode
    ldy #0              ; Initialise Index
    lda COM_CODE        ; load OpCode
    sta (ADDVEC),y      ; store in address location
    lda COM_NB          ; Load Number Of Bytes
    cmp #1              ; Is only 1 byte
    bne @ASS4           ; No, Continue On
    jmp ASSEND          ; Goto Assembler Line End

@ASS4
    lda COM_MODE        ; Load Mode
    cmp #MODE_RELATIVE  ; Is it Relative
    bne @ASS5           ; No, try another
    jsr BRANCH          ; Run Branch Routine
    lda COM_MODE        ; Load Mode
    cmp #MODE_ERROR     ; Is Mode Error
    bne @ASS5           ; No, Continue
    jmp ERROR           ; Yes, Display Error

@ASS5
    lda COM_MODE        ; Load Mode
    cmp #MODE_RELATIVE  ; Is it Relative
    bne @ASS6           ; No, Try Another
    ldy #1              ; Load Index of 1
    lda COM_L           ; Load Command L
    sta (ADDVEC),y      ; Store after OpCode
    jmp ASSEND          ; Jump To Assembler Line End

@ASS6
    lda COM_MODE            ; Load Mode
    sec 
    sbc #MODE_IMPLIED       ; Subtract Lowest Mode Value 'a'
    asl                     ; Multiply By 2
    tay                     ; Move To Y Index
    lda MODE_JUMP_TABLE,y   ; Load Lo Jump Value
    sta MODE_JUMP_VEC       ; Store in Lo Jump Vector
    lda MODE_JUMP_TABLE+1,y ; Load Hi Jump Value
    sta MODE_JUMP_VEC + 1   ; Store in Hi Jump Vector
    jsr JSRG                ; GoSub Jump Vector
    lda COM_NB              ; Load No Of Bytes
    cmp #2                  ; is it 2
    bne @JSRG               ; No, Try Again
    lda LOCATION            ; Yes, Load Location
    ldy #1                  ; Load Y with 1
    sta (ADDVEC),y          ; Store In Opcode + 1

@JSRG
    lda COM_NB          ; Load No Of Bytes
    cmp #3              ; Is It 3
    bne ASSEND          ; No, goto Assembler Line End
    ldy #1              ; Initialise Y = 1
    lda LOCATION        ; Load Location
    sta (ADDVEC),y      ; Store in Opcode + 1
    lda LOCATION + 1    ; Load Location + 1
    iny                 ; Increase Index Y
    sta (ADDVEC),y      ; Store In OpCode + 2

ASSEND
    jsr ASS6            ;
    jsr ADDNB           ; Add No Of Bytes To Address Location
    jsr PrintCarrageReturnAndLineFeed
    lda #">"            ; Command Line
    jsr krljmp_CHROUT$  ; Print Character
    lda #"a"            ; Assemble Command
    jsr krljmp_CHROUT$  ; Print Character
    jsr SPACE           ; print Space
    lda ADDVEC          ; Load Address Vector Lo
    ldx ADDVEC + 1      ; Load Address Vector Hi
    jsr PBYTE2          ; Print Next Address Location
    jsr SPACE           ; Print space

ASSLINE
    lda #CHR_Return     ; Load Carriage Return
    jsr krljmp_CHROUT$  ; Print Character
    lda #CHR_CursorUp   ; Load Cursor Up
    jsr krljmp_CHROUT$  ; Print Character
    ldy #0              ; Initialise Index

ASS3
    lda #CHR_CursorRight    ; Load Cursor Right
    sta $0277,y             ; Store in the Keyboard Buffer
    iny                     ; increase index
    cpy #8                  ; is it 8 
    bne ass3                ; No, do it again
    sty 198                 ; Yes, Store number characters
    jmp TOKANISER_COMMAND   ; Goto Command Line

JSRG
    jmp (MODE_JUMP_VEC) ; Jump To Assembler Mode Indirect Jump

;*******************************************************************************
;* MODE Execution Table                                                        *
;*******************************************************************************
MODE_JUMP_TABLE
    WORD amoda
    WORD amodb
    WORD amodb
    WORD amodb
    WORD amode
    WORD amodf
    WORD amode
    WORD amode
    WORD amodi
    WORD amodi
    WORD amodi
    WORD amodl

AMODA
    rts                 ; Implied Mode, No Bytes need getting 

AMODB
    ldy #5              ; Absolute Mode, Get Word Value
    jsr GET_HEX_2BYTE_VALUE
    stx LOCATION        ; Store Location Lo Byte
    sta LOCATION + 1    ; Store Location Hi Byte
    rts 

AMODE
    ldy #6              ; Immediate Mode, Get Byte Value
    jmp AMODI + 2

AMODF
    ldy #6              ; Indirect Mode, Get Byte Value
    jmp AMODB + 2

AMODI
    ldy #5              ; Zero Page Mode, Get Byte Value
    jsr GET_HEX_1BYTE_VALUE
    sta LOCATION
    rts 

BRANCH
    jsr AMODB           ; Relative Mode, Get Word Value           
    lda LOCATION        ; Get Location Lo Vector
    sec 
    sbc ADDVEC          ; Subtract Address Lo Vector
    sta LOCATION        ; Store back into Location Lo
    lda LOCATION + 1    ; Get Location Hi Vector
    sbc ADDVEC + 1      ; Subtract Address Hi
    sta LOCATION + 1    ; Store back into location Hi
    sec 
    lda LOCATION
    sbc #2              ; Subtract 2 from Location Lo Vector
    sta LOCATION
    lda LOCATION + 1
    sbc #0
    sta LOCATION + 1
    cmp #0              ; Is Hi Byte Zero
    beq AMODL1          ; Yes, Continue Working Out Relative Position
    cmp #255            ; Is Hi Byte Negative Value
    beq @BRANCH         ; Yes, Continue Working Out Negative Relative Position
    jmp AMODL1          ; Continue

@BRANCH
    lda LOCATION        ; Get Location Lo Value
    bpl AMODL1          ; Value Positive
    jmp AMODL2          ; Value Negative

AMODL
    lda LOCATION        ; Get Location Lo Value
    bmi AMODL1          ; Value Negative
    jmp AMODL2          ; Value Positive

AMODL1
    lda #MODE_ERROR     ; This is in Error
    sta COM_MODE
    rts 

AMODL2
    lda LOCATION        ; Get Relative Branch Value
    sta COM_L           ; Store in Command Length
    rts 

;*******************************************************************************
;* MODE Evaluation of the A line entered                                       *
;*******************************************************************************
MODE_HUNT
    lda COM_L               ; Load String Command Length
    cmp #3                  ; Is only 3 characters -- E.g. tax
    bne MODE_NOTIMPLIED     ; No, Test Again               ^^^
    lda #MODE_IMPLIED       ; This is an Implied OpCode
    rts 

MODE_NOTIMPLIED
    cmp #6                  ; Is Only 6 Characters - E.g. lda$60
    bne MODE_NOTZEROPAGE    ; No, Test Again              ^^^^^^
    lda #MODE_ZEROPAGE      ; This is a ZeroPage OpCode
    rts 

MODE_NOTZEROPAGE
    cmp #7                  ; Is Only 7 Characters - E.g. lda#$00
    bne MODE_NOTIMMEDIATE   ; No, Test Again              ^^^^^^^
    lda #MODE_IMMEDIATE     ; This is an Immediate OpCode
    rts 

MODE_NOTIMMEDIATE
    lda COM_TEXT+7          ; Look at keyboard buffer Index 7 - E.g. lda$70,x
    cmp #"x"                ; is it an x                                    ^
    bne MODE_NOTZEROPAGEX   ; No, Test Again
    lda #MODE_ZEROPAGE_X    ; This is a ZeroPage Indexed By X
    rts 

MODE_NOTZEROPAGEX
    cmp #"y"                ; is it an Y - E.g. lda$70,y
    bne MODE_NOTZEROPAGEY   ; No, Test Again           ^
    lda #MODE_ZEROPAGE_Y    ; This is a ZeroPage Indexed By Y
    rts 

MODE_NOTZEROPAGEY
    cmp #CHR_Comma          ; is it a Comma - E.g. lda($70,x)
    bne MODE_NOTINDIRECTX   ; No, Test Again              ^
    lda #MODE_INDIRECT_X    ; This is a InDirect OpCode Indexed By X
    rts
 
MODE_NOTINDIRECTX
    cmp #CHR_ClosedBracket  ; Is it a Closed Bracket - E.g. lda($70),y
    bne MODE_NOTINDIRECTY   ; No, Test Again                       ^
    lda #MODE_INDIRECT_Y    ; This is an IndDirect OpCode Index By Y
    rts 

MODE_NOTINDIRECTY
    ldy COM_L               ; Load Number Characters in Buffer
    dey                     ; Minus One
    lda COM_TEXT,y          ; Load That Character  - E.g. lda$1234,x
    cmp #"x"                ; Is it x                              ^
    bne MODE_NOTABSOLUTEX   ; No, Try Again
    lda #MODE_ABSOLUTE_X    ; This is an Absolute OpCode Index By X 
    rts 

MODE_NOTABSOLUTEX
    cmp #"y"                ; Is it Y - E.g. lda$1234,y
    bne MODE_NOTABSOLUTEY   ; No, Try Again           ^
    lda #MODE_ABSOLUTE_Y    ; This is an Absolute OpCode Index By Y
    rts 

MODE_NOTABSOLUTEY
    cmp #CHR_ClosedBracket  ; Is it a Closed Bracket - E.g. jmp($1234)
    bne MODE_NOTINDIRECT    ; No, Try Again                          ^
    lda #MODE_INDIRECT      ; This is an InDirect OpCode
    rts 

MODE_NOTINDIRECT
    lda COM_TEXT            ; Load First Character - E.g. bne$1234
    cmp #"b"                ; Is it a b                   ^
    bne MODE_NOTRELATIVE    ; No, Try Again
    lda COM_TEXT+1          ; load Second Character - E.g. bit$1234
    cmp #"i"                ; Is it i                       ^
    beq MODE_NOTRELATIVE    ; Yes, then not a branch OpCode
    lda #MODE_RELATIVE
    rts

MODE_NOTRELATIVE 
    lda COM_L               ; Load Number Of Charaters In Buffer - E.g. lda$1234
    cmp #8                  ; Does it equal 8
    bne MODE_NOTABSOLUTE    ; No, Try Again
    lda #MODE_ABSOLUTE      ; Yes, then its a Absolute OpCode
    rts 

MODE_NOTABSOLUTE
    lda #MODE_ERROR         ; We Could Not Evaluate The Addressing Mode
    rts

ASS6
    jsr PrintCarrageReturnAndLineFeed   ; Print Carriage Return
    lda #CHR_CursorUp                   ; Cursor up
    jsr krljmp_CHROUT$                  ; Print Character
    lda #CHR_CursorUp                   ; Cursor up
    jsr krljmp_CHROUT$                  ; Print Character
    jmp DIS1                            ; Disassemble Last OpCode to Format Correctly

;*******************************************************************************
OPCODE_SEARCH
    lda #<OPCodes               ; Loads Start Address of the OpCode Array
    sta HT
    lda #>OpCodes
    sta HT + 1

GET_NEXT_OPCODE 
    ldy #0                      ; Initialise Index

GET_NEXT_OPCODE_CHAR 
    lda (HT),y                  ; Load Character
    cmp #0                      ; End Of Array 
    beq OPCODE_ERROR            ; Yes, Jump To End of Function
    cmp COM_TEXT,y              ; Compare with Keyboard buffer character
    bcc WORKOUT_NEXT_OPCODE     ; The character is less
    beq OPCODE_CHECK            ; The character is equal

OPCODE_ERROR
    jmp ERROR                   ; No OpCode Found, Display Error

OPCODE_CHECK 
    iny                         ; Match Character, lets try next character
    cpy #3                      ; Have we hit OpCode Max Characters
    bne GET_NEXT_OPCODE_CHAR    ; No, not hit OpCode limit
    lda (HT),y                  ; Yes, we have a match, Get OpCode Mode
    cmp COM_MODE                ; Is it the same as what we have evaluated
    bne WORKOUT_NEXT_OPCODE     ; No, then find next Mode Type for OpCode
    iny                         ; Increase Index By 1
    lda (HT),y                  ; Get OpCode Value
    rts 

WORKOUT_NEXT_OPCODE 
    lda HT                      ; Load OpCode Lo Address
    clc 
    adc #5                      ; Add 5, for next Record
    sta HT                      ; Store Back into Lo Address
    bcc @WORKOUT_NEXT_OPCODE    ; Did we use the Carry
    inc HT + 1                  ; Yes, Increase Hi Record By 1

@WORKOUT_NEXT_OPCODE
    jmp GET_NEXT_OPCODE         ; Jump back to Test Next OpCode
