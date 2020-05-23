.model tiny

.data
Greeting: db 'Bomb has been planted. Enter pass:', 13, 10, '$'
Phase1Buff: db '@@@@@@@@@@$#####'
PhaseOnePass: db 'phase1pass'

Phase1Win: db 10, 13, 'Wow, phase 1 passed. Try one more time? >$'
ExplodeMsg: db 10, 13, 'BO-O-O-O-O-O-O-OM$'

Phase2Buff: db '@@@@@@@@$'

.code

org 100h

Start:

    ; ======== Phase 1 ========
    
    ; Greeting
    mov dx, offset Greeting
    mov ah, 09h
    int 21h

    ; Get password
    mov cx, 8h
    mov di, offset Phase1Buff
    call GetPass

    jmp CheckPhase1

    ; ======== Phase 2 ========
    Phase2:
        ; Phase 1 congratulations
        mov dx, offset Phase1Win
        mov ah, 09h
        int 21h

        ; Enter phase 2 password
        mov cx, 8h
        mov di, offset Phase2Buff
        call GetPass

        jmp EndC

    jmp InnerShortJmp1
    HjKU88 db 'p7aGe6poiu'
    InnerShortJmp1:
    jmp EndC

    ; Phase 1 checker
    CheckPhase1:
        mov cx, 8h
        mov si, offset Phase1Buff
        mov di, offset HjKU88
        xor ax, ax
        
        Check1Loop:
            cmpsb
            jne Explode
            loop Check1Loop
        jmp Phase2

    Explode:
        mov dx, offset ExplodeMsg
        mov ah, 09h
        int 21h
        jmp EndC

    EndC:
    ret

    GetPass PROC
    GetPassLoop:
        mov ah, 01h
        int 21h
        mov byte ptr [di], al
        inc di
        loop GetPassLoop
    ret
    ENDP
end Start