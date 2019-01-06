ifdef TGT_C64
; BASIC Rom starts at $A000
bas_ROMError$       = $A437
bas_CustomError$    = $A447
bas_DecimalPrint$   = $BDCD
bas_PrintString$    = $AB1E
bas_ReadyPrompt$    = $A474
bas_LineGet$        = $A96B
bas_NEWCommand$     = $A642
bas_FindLine$       = $A613
bas_LinkProgram$    = $A533
bas_InLine$         = $A560
bas_FrmNum$         = $AD8A
bas_GetAddr$        = $B7F7
bas_LinePrint$      = $BDCD
endif

         
ifdef TGT_VIC20_8K
; BASIC Rom Starts at $C000
bas_ROMError$       = $C437
bas_CustomError$    = $C447
bas_DecimalPrint$   = $DDCD
bas_PrintString$    = $CB1E
bas_ReadyPrompt$    = $C474
bas_LineGet$        = $C96B
bas_NEWCommand$     = $C642
bas_FindLine$       = $C613
bas_LinkProgram$    = $C533
bas_InLine$         = $C560
bas_FrmNum$         = $CD8A
bas_GetAddr$        = $D7F7
bas_LinePrint$      = $DDCD
endif

; Kernel Jump Vectors
krljmp_PCINT$       = $FF81
krljmp_IOINIT$      = $FF84
krljmp_RAMTAS$      = $FF87
krljmp_RESTOR$      = $FF8A
krljmp_VECTOR$      = $FF8D
krljmp_SETMSG$      = $FF90
krljmp_SECOND$      = $FF93
krljmp_TKSA$        = $FF96
krljmp_MEMTOP$      = $FF99
krljmp_MEMBOT$      = $FF9C
krljmp_SCNKEY$      = $FF9F
krljmp_SETTMO$      = $FFA2
krljmp_ACPTR$       = $FFA5
krljmp_CIOUT$       = $FFA8
krljmp_UNTALK$      = $FFAB
krljmp_UNLSN$       = $FFAE
krljmp_LISTEN$      = $FFB1
krljmp_TALK$        = $FFB4
krljmp_READST$      = $FFB7
krljmp_SETLFS$      = $FFBA
krljmp_SETNAM$      = $FFBD
krljmp_OPEN$        = $FFC0
krljmp_CLOSE$       = $FFC3
krljmp_CHKIN$       = $FFC6
krljmp_CHKOUT$      = $FFC9
krljmp_CLRCHN$      = $FFCC
krljmp_CHRIN$       = $FFCF
krljmp_CHROUT$      = $FFD2
krljmp_LOAD$        = $FFD5
krljmp_SAVE$        = $FFD8
krljmp_SETTIM$      = $FFDB
krljmp_RDTIM$       = $FFDE
krljmp_STOP$        = $FFE1
krljmp_GETIN$       = $FFE4
krljmp_CLALL$       = $FFE7
krljmp_UDTIM$       = $FFEA
krljmp_SCREEN$      = $FFED
krljmp_PLOT$        = $FFF0
krljmp_BASE$        = $FFF3

jmpvec_Error        = $0300
jmpvec_Main         = $0302
jmpvec_Crunch       = $0304
jmpvec_List         = $0306
jmpvec_Run          = $0308

jmpvec_irq          = $0314
jmpvec_brk          = $0316
jmpvec_nmi          = $0318
