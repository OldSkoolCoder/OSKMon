;*******************************************************************************
;* Exit Operation                                                              *
;*******************************************************************************
;* Syntax : X 
;*******************************************************************************

;** exit -- syntax :- x **
COM_EXIT
    jsr bas_LinkProgram$        ; Relink BASIC Program
    jmp bas_ReadyPrompt$        ; Jump To Basic READY Prompt