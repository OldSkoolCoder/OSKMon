;*******************************************************************************
;* Interpret Operation                                                         *
;*******************************************************************************
;* Syntax : I (addr) (addr) <RETURN>
;*******************************************************************************

COM_INTERP
    jsr IBYTE2          ; get start address
    sta ADDVEC + 1      ; store start address
    stx ADDVEC
    jsr IBYTE2          ; get end address
    sta DIS_END + 1     ; store end address
    stx DIS_END

INT10
    jsr INT1            ; display one line of memory

ifdef TGT_C64
    lda #31
endif
ifdef TGT_VIC20_8K
    lda #13
endif

    sta COM_NB          ; add nb to address
    lda $c5             ; get current key mapping
    cmp #63             ; is it runstop
    bne INT3            ; carry on displaying next line
    jmp READY           ; goto command line

INT3
    jsr ADDNB           ; update address
    lda ADDVEC + 1      ; load address hi
    cmp DIS_END + 1     ; compare with end address hi
    beq INT4            ; if equal test lo byte
    jmp INT10           ; display next line

INT4
    lda ADDVEC          ; load address lo
    cmp DIS_END         ; compare with end address lo
    bcs INT9            ; greater then, 
    jmp INT10           ; display next line

INT9
    jmp READY           ; jump to command line

INT1
    jsr PrintCarrageReturnAndLineFeed
    lda #">"
    jsr krljmp_CHROUT$
    lda ADDVEC          ; load address
    ldx ADDVEC + 1
    jsr PBYTE2          ; print hexadecimal address
    jsr SPACE
    lda #CHR_Quote  
    jsr krljmp_CHROUT$  ; print character
    jsr SPACE           
    ldy #0

INT2
    lda (ADDVEC),y              ; load address value
    jsr ShowOnlyValidCharacters ; filter out bad characters
    jsr krljmp_CHROUT$          ; print character
    iny 

ifdef TGT_C64
    cpy #31                     ; 31 characters reached
endif

ifdef TGT_VIC20_8K
    cpy #13                     ; 13 characters reached
endif

    bne INT2                    ; no, carry on
    rts                         ; return
 
ShowOnlyValidCharacters
    cmp #224
    bcs int6            ; Branch if greater than, to show invalid character ( >= 224)
    cmp #160
    bcs int7            ; Branch if greater than, to show valid character ( >= 160 and < 224)
    cmp #91
    bcs int6            ; Branch if greater than, to show invalid character ( >=91 and < 160)
    cmp #34
    beq int6            ; Branch if equal to, then show invalid character
    cmp #32
    bcs int7            ; Branch if Grater than, then show valid character ( >=32 and < 91 and <> 34)

INT6
    lda #46             ; Invalid Character 

INT7
    rts 