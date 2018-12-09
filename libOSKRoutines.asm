;******************************************************************************
;* Output a space                                                             *
;******************************************************************************
;* Outputs :                                                                  *
;*         None                                                               *
;******************************************************************************
SPACE
    lda #CHR_Space      ; Load Space
    jmp krljmp_CHROUT$  ; Print Space

;******************************************************************************
;* Print Two Bytes In HEX (PBYTE2)                                            *
;******************************************************************************
;* Inputs :                                                                   *
;*         Acc = Hi Byte                                                      *
;*         X Reg = Lo Byte                                                    *
;******************************************************************************

PBYTE2
    pha         ; Push Hi byte to stack temporarily 
    txa         ; Transfer Lo byte to accumulator
    jsr PBYTE1  ; Print out Lo byte first
    pla         ; Get back Hi byte from stack and print that

;******************************************************************************
;* Print Byte In HEX (PBYTE1)                                                 *
;******************************************************************************
;* Inputs :                                                                   *
;*         Acc = Byte                                                         *
;******************************************************************************

PBYTE1
    pha         ; Push Byte to stack temporarily 
    lsr         ; divide by 2
    lsr         ; divide by 4
    lsr         ; divide by 8
    lsr         ; divide by 16
    jsr PBYTE   ; print most siginificant nibble value (most significant 4 bits)
    tax         ; transfor Acc to X
    pla         ; get back orginal value from stack
    and #15     ; mask out only least significant nibble (4 bits) and print that

PBYTE
    clc         
    adc #$F6    ; check if greater than 10
    bcc @PBYTE  ; if carry is clear
    adc #6      ; addes the Ascii code 'A' offset
@PBYTE
    adc #$3A    ; add ascii code '0' value
    jmp krljmp_CHROUT$  ; print out accumulator

;******************************************************************************
;* Inputs Two Bytes In HEX (IBYTE2)                                           *
;******************************************************************************
;* Outputs :                                                                  *
;*         Acc = Hi Byte                                                      *
;*         X Reg = Lo Byte                                                    *
;******************************************************************************

IBYTE2
    jsr IBYTE1  ; gets Hi Byte
    pha         ; store away temporarily
    jsr IBYTE1  ; gets Lo Byte
    tax         ; move to X
    pla         ; get back Hi Byte
    rts 

;******************************************************************************
;* Input Byte In HEX (IBYTE1)                                                 *
;******************************************************************************
;* Outputs :                                                                  *
;*         Acc = Byte                                                         *
;******************************************************************************

IBYTE1
    jsr INPUT_COMMAND   ; get character
    cmp #CHR_Return     ; is it 'Return'?
    bne @IBYTE1         ; No
    jmp ERROR           ; Yes, jump to Error

@IBYTE1
    jsr IBYTE           ; Get Most Significant nibble (4 Bits)
    asl                 ; Multiply by 2
    asl                 ; Multiply by 4
    asl                 ; Multiply by 8
    asl                 ; Multiply by 16
    sta TEMP            ; Store in Temp Byte
    jsr INPUT_COMMAND   ; Get Next Character
    cmp #CHR_Return     ; is it 'Return'?
    bne @IBYTE2         ; No
    jmp ERROR           ; Yes, jump to error

@IBYTE2
    jsr IBYTE           ; Get Least Siginificant nibble (4 bits)
    ora TEMP            ; Merge with what we have already got
    rts                 ; Return complete inputted byte value

IBYTE                   
    clc 
    adc #$D0            ; Normalise Number
    cmp #10             ; Test for 10
    bcc @IBYTE          ; Is lower than
    sec
    sbc #7              ; Relign number
@IBYTE
    rts 

;******************************************************************************
;* Show Error prompt                                                          *
;******************************************************************************
;* Outputs :                                                                  *
;*         None                                                               *
;******************************************************************************
ERROR
    lda #"?"
    jsr krljmp_CHROUT$

;******************************************************************************
;* Show Ready prompt                                                          *
;******************************************************************************
;* Outputs :                                                                  *
;*         None                                                               *
;******************************************************************************
READY
    jsr PrintCarrageReturnAndLineFeed

READY1
    lda #">"
    jsr krljmp_CHROUT$
    jmp TOKANISER_COMMAND

;******************************************************************************
;* Input Command from command line                                            *
;******************************************************************************
;* Outputs :                                                                  *
;*         Acc = Command                                                      *
;******************************************************************************
INPUT_COMMAND
    jsr krljmp_CHRIN$   ; Get Command
    cmp #CHR_Return     ; Check for 'Enter'
    beq @INPUT          ; Yes, finish input reading
    cmp #CHR_Space
    beq INPUT_COMMAND
    ;cmp #"!"            ; check for '!'
    ;bcc INPUT_COMMAND   ; go back and fetch next command
    ;cmp #"["            ; check for '['
    ;bcs INPUT_COMMAND   ; go back and fetch next command
@INPUT
    rts 

;******************************************************************************
;* Get 2 Byte Hex Value from Assembly Temp Text Store                         *
;******************************************************************************
;* Inputs  :                                                                  *
;*         Y Reg = Starting Index in COM_TEXT                                 *
;* Outputs :                                                                  *
;*         Acc = Hi Byte                                                      *
;*         X Reg = Lo Byte                                                    *
;******************************************************************************
GET_HEX_2BYTE_VALUE
    jsr GET_HEX_1BYTE_VALUE
    pha 
    iny 
    jsr GET_HEX_1BYTE_VALUE
    tax 
    pla 
    rts 

;******************************************************************************
;* Get 1 Byte Hex Value from Assembly Temp Text Store                         *
;******************************************************************************
;* Inputs  :                                                                  *
;*         Y Reg = Starting Index in COM_TEXT                                 *
;* Outputs :                                                                  *
;*         Acc = Byte                                                         *
;******************************************************************************
GET_HEX_1BYTE_VALUE
    lda COM_TEXT-1,y
    jsr IBYTE
    asl 
    asl 
    asl 
    asl 
    sta TEMP
    iny 
    lda COM_TEXT-1,y
    jsr IBYTE
    ora TEMP
    rts 

;******************************************************************************
;* NoByt                                                                      *
;*       This determines how many bytes to add for next instruction based on  *
;*       mode.                                                                *
;******************************************************************************
;* Inputs  :                                                                  *
;* Outputs :                                                                  *
;******************************************************************************
NOBYT
    lda #2              ; Default to 2 bytes
    sta COM_NB          ; Store in Command NoBytes
    lda COM_MODE        ; Load Mode
    cmp #MODE_ABSOLUTE  ; is it Absolute
    bne NOB2            ; No, try another mode
    jmp NOB1            ; Yes, then jump to absolute

NOB2
    cmp #MODE_ABSOLUTE_X; is it Absolute,x
    bne NOB3            ; No, try another mode
    jmp NOB1            ; jump to absolute

NOB3
    cmp #MODE_ABSOLUTE_Y; is it Absolute,y
    bne NOB4            ; No, try another mode
    jmp NOB1            ; Jump to Absolute mode 

NOB4
    cmp #MODE_INDIRECT  ; is it Indirect
    bne NOB5            ; No, try another mode

NOB1
    lda #3              ; 3 byte opCodes
    sta COM_NB          ; Store in Command NoBytes

NOB5
    lda COM_MODE        ; Load Mode
    cmp #MODE_IMPLIED   ; Is it implied
    bne NOB6            ; No, Jump out of routine
    lda #1              ; Yes, then ist only 1 byte
    sta COM_NB          ; Store in Command NoBytes

NOB6
    rts 

;******************************************************************************
;* Tokanise the command aquired from command line                             *
;******************************************************************************
;* Outputs :                                                                  *
;*         Y = Command Index                                                  *
;******************************************************************************
TOKANISER_COMMAND
    jsr INPUT_COMMAND   ; Get Command
    cmp #CHR_Return     ; Check For 'Return'
    beq READY           ; Goto Ready Sign
    ldy #0              ; Reset Comamnd Counter
TOK1
    cmp COMMANDS,y      ; Compare with command list
    beq TOK2            ; identified the command
    iny                 ; No match, so check next one
    cpy #COMMANDPOINTERS - COMMANDS ; Number Of Commands
    bne TOK1            ; keep trying
    jmp ERROR           ; no command found, so error

TOK2
    tya                 ; Command found 
    asl                 ; multply by 2
    tay                 ; move to index offset
    lda COMMANDPOINTERS,y   ; load command pointer lo
    sta HT  
    lda COMMANDPOINTERS+1,y ; load command pointer hi
    sta HT + 1
    jmp (HTVEC)         ; jump to the command

PrintCarrageReturnAndLineFeed
    lda #CHR_Return
    jmp krljmp_CHROUT$

;******************************************************************************
;* ADDNB                                                                      *
;*         Add Com_NB to AddVec                                               *
;******************************************************************************
;* Inputs  : Com_NB : No of bytes to add                                      *
;*         : AddVec : The Vector to Add Com_NB too                            *
;* Outputs : AddVec : The resulting Vector                                    *
;******************************************************************************
ADDNB
    lda ADDVEC
    clc 
    adc COM_NB
    sta ADDVEC
    bcc @ADDNB
    inc ADDVEC + 1

@ADDNB
    rts 

COMMANDS
    TEXT ">racdfghilmostx"
    BYTE $3A, $3B, $2C, $23, $24, $25, $40;, $3F
    BYTE $00

COMMANDPOINTERS
    WORD TOKANISER_COMMAND
    WORD COM_REGISTER
;    WORD COM_ASSEMBLE
;    WORD COM_COMMAND
;    WORD COM_DISASSEMBLE
;    WORD COM_FILL
;    WORD COM_GOSUB
;    WORD COM_HUNT
;    WORD COM_INTERP
;    WORD COM_LOAD
;    WORD COM_MEMORY
;    WORD COM_OUTPUT
;    WORD COM_SAVE
;    WORD COM_TRANSFER
;    WORD COM_EXIT
;    WORD COM_MEMORYPUT
;    WORD COM_REGISTERPUT
;    WORD COM_ASSEMBLE
;    WORD COM_DECIMAL
;    WORD COM_HEXDEC
;    WORD COM_BINARY
;    WORD COM_OCTAL
;    WORD COM_HELP
