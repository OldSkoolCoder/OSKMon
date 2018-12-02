;*******************************************************************************
;* OldSkoolCoder Machine Code Monitor                                          *
;*                                                                             *
;* Writtern By John C. Dale                                                    *
;*                                                                             *
;* Date 16th April 2018                                                        *
;*******************************************************************************
;*                                                                             *
;* Change History                                                              *
;* 16th Apr 2018 : Created new project for use in the new Machine Code Monitor *
;*                 Video Series                                                *
;* 18th Apr 2018 : Added Break, Tokaniser and Register Command                 *
;*******************************************************************************

;*******************************************************************************
;* Includes                                                                    *
;*******************************************************************************

ifdef TGT_C64
    *= $9000
CARTSTART = $9000
endif

         
ifdef TGT_VIC20_8K
    *= $B000
CARTSTART = $B000
endif

    jmp STARTMON

incasm "libOpCodesArray.asm"
incasm "libCharacterASCIIConst.asm"
incasm "libROMRoutines.asm"

;*******************************************************************************
;* Variables                                                                   *
;*******************************************************************************

CINV    = $0314
CBINV   = $0316
NMINV   = $0318

HT      = $14
HTVEC   = $0014

;*******************************************************************************
;* Code                                                                        *
;*******************************************************************************

STARTMON
    ldy #>TITLE             ; Load Title Start Location
    lda #<TITLE
    jsr bas_PrintString$    ; Print out Title to screen
    lda #<BREAK_VECTOR      ; Load BRK Vector locations
    ldy #>BREAK_VECTOR
    sei 
    sta CBINV               ; Set Break Vectors
    sty CBINV + 1
    cli 
    brk 
 
;*******************************************************************************
;* Break Operation                                                             *
;*******************************************************************************

BREAK_VECTOR
    pla                     ; Get X Reg from Stack 
    sta YREG
    pla                     ; Get Y Reg from Stack
    sta XREG
    pla                     ; Get Acc From Stack
    sta ACCREG
    pla                     ; Get Status Register From Stack
    sta STREG
    pla                     ; Get Program Counter Lo From Stack
    sta PCLOREG
    pla                     ; Get Program Counter Hi From Stack
    sta PCHIREG             
    tsx                     ; Get Current Status Register
    stx STPTREG             
    lda CINV                ; Get current IRQ Pointer Vector
    ldy CINV + 1
    sta IRQINT
    sty IRQINT + 1
    lda NMINV               ; Get Current NMI Pointer Vector
    ldy NMINV + 1
    sta NMIINT
    sty NMIINT + 1
    lda PCLOREG             ; Load PC Counter Lo
    sec 
    sbc #2                  ; Subtract 2
    sta PCLOREG             ; Store back to PC Counter Lo
    bcs @BREAK
    dec PCHIREG             ; Dec PC Counter Hi if Carry Clear
@BREAK
    jmp COM_REGISTER

TITLE
ifdef TGT_C64
    BYTE CHR_ClearScreen
    TEXT "oldskoolcoder machine code monitor"
    BYTE 13, CHR_CursorDown
    TEXT "for the commodore 64 by j.c.dale"
    BYTE 13, CHR_CursorDown
    TEXT "(c) april 2018 oldskoolcoder"
    BYTE CHR_CursorDown
    brk 
endif

ifdef TGT_VIC20_8K
    BYTE CHR_ClearScreen
    TEXT "machine code monitor"
    BYTE 13, CHR_CursorDown
    TEXT "for vic20 by j.c.dale"
    BYTE 13, CHR_CursorDown
    TEXT "(c) april 2018 osk"
    BYTE CHR_CursorDown
    brk 
endif


;*******************************************************************************
;* Storage Locations                                                           *
;*******************************************************************************

YREG    = $02A7
XREG    = $02A8
ACCREG  = $02A9
STREG   = $02AA
PCLOREG = $02AB
PCHIREG = $02AC
STPTREG = $02AD
IRQINT  = $02AE
NMIINT  = $02B0
TEMP    = $0282

STREGISTER = $0283

incasm "libOSKRoutines.asm"
incasm "libRegisterCommand.asm"
