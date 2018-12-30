;*******************************************************************************
;* Memory Operation                                                            *
;*******************************************************************************
;* Syntax : M (addr) (addr) <RETURN>
;*******************************************************************************

;** memory -- syntax :- m (addr) (addr) **

COM_MEMORY
    jsr IBYTE2          ; Get start Address
    sta ADDVEC + 1
    stx ADDVEC
    jsr IBYTE2          ; Get End Address
    sta DIS_END + 1
    stx DIS_END

MEMNEXTLINE
    jsr DISPLAYMEMNEXTLINE ; Display Next Line

ifdef TGT_C64
    lda #10             ; Show 10 bytes per line
endif
ifdef TGT_VIC20_8K
    lda #04             ; Show 4 bytes per line
endif

    sta COM_NB          ; Store Screen Row Byte Value
    lda $c5
    cmp #63             ; Check for runstop key
    bne MEM1            ; No, carry on
    jmp READY           ; Yes, Jump back to Command Line

MEM1
    jsr ADDNB           ; Add Screen Row Byte Value to Master Location
    lda ADDVEC + 1
    cmp DIS_END + 1     ; Check if reached End location
    bne MEMNEXTLINE     ; No, then start new line
    lda ADDVEC
    cmp DIS_END         ; Deffo Check End location
    bcs MEM4            ; Yes, Then exit back to command line
    jmp MEMNEXTLINE     ; No, then start new line

MEM4
    jmp READY           ; Jump back to Command Line

; Display Memory Line on the screen
DISPLAYMEMNEXTLINE
    jsr BUILDMEMLINECOMMANDSTRUCTURE
    ldy #0

DISPLAYMEMNEXTBYTE
    lda (ADDVEC),y      ; Load Byte
    pha                 ; Temp store on stack
    jsr SPACE           ; Display Space
    pla                 ; bring back from stack
    jsr PBYTE1          ; Display Byte as 00 Hex value
    iny                 ; increase row byte number

ifdef TGT_C64
    cpy #10             ; Check 10 bytes per line
endif
ifdef TGT_VIC20_8K
    cpy #04             ; Check 4 bytes per line
endif

    bne DISPLAYMEMNEXTBYTE
    rts 

; This Builds the command line Memory structure (>: 0000)
BUILDMEMLINECOMMANDSTRUCTURE
    jsr PrintCarrageReturnAndLineFeed
    lda #">"
    jsr krljmp_CHROUT$
    lda #CHR_Colon
    jsr krljmp_CHROUT$
    jsr SPACE
    lda ADDVEC
    ldx ADDVEC + 1
    jsr PBYTE2
    rts

;*******************************************************************************
;* Memory Put ation                                                            *
;*******************************************************************************
;* Syntax 64 : : (addr) (byte)(byte)(byte)(byte)(byte)(byte)(byte)(byte)(byte)(byte) <RETURN>
;* Syntax VIC20 : : (addr) (byte)(byte)(byte)(byte) <RETURN>
;*******************************************************************************

COM_MEMORYPUT
    jsr IBYTE2          ; Get Memory Address
    sta ADDVEC + 1      ; Store Memory Address
    stx ADDVEC

MEMP2
    ldy #0
    sty COM_L           ; Begin Byte Counter at 0

MEMP1
    jsr INPUT_COMMAND   ; Get First Character
    cmp #CHR_Return     ; Do we have a Return Key?
    bne MEMP3           ; No, then Continue
    jmp READY           ; Yes, Go back to Command Line

MEMP3
    jsr IBYTE1 + 3      ; Get Current Byte Value
    ldy COM_L           ; Load Row Byte Value
    sta (ADDVEC),y      ; Store byte Value in Address + offset
    iny                 ; Increase Row Byte Value
    sty COM_L

ifdef TGT_C64
    cpy #10             ; Check 10 bytes per line
endif
ifdef TGT_VIC20_8K
    cpy #04             ; Check 4 bytes per line
endif

    bne MEMP1           ; No, Carry On Then

ifdef TGT_C64
    lda #10             ; Show 10 bytes per line
endif
ifdef TGT_VIC20_8K
    lda #04             ; Show 4 bytes per line
endif

    sta COM_NB          ; Store Bytes Per Line Allowed
    jsr ADDNB           ; Work Out New Address Location based on byte per line
    jsr BUILDMEMLINECOMMANDSTRUCTURE
    jmp ASSLINE
