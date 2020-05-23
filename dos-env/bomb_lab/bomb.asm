.model tiny

.data
Greeting: db 'Bomb has been planted. Enter pass', 10, 13, '> $'
Phase1Buff: db '@@@@@@@@@@$#####'
PhaseOnePass: db 'phase1pass'

Phase1Win: db 10, 13, 'Wow, phase 1 passed. Try one more time?', 10, 13, '> $'
Phase2Win: db 10, 13, 'Ok, phase 2 also passed. Are you serious, Sam?', 10, 13, '> $'
Phase3Win: db 10, 13, 'Meine Respektirung', 10, 13, '$'
ExplodeMsg: db 10, 13, 'BO-O-O-O-O-O-O-OM$'

Phase2Buff: db '@@@@'
Phase2Pass: db '@@@@'

Phase3Pass: db 'MMMMM'
Phase3Buff: db '@@@@@'

.code

org 100h

Start:
    jmp Phase1

    ; ======== Phase 3 ========
    Phase3:
        ; Phase 2 congrats
        mov dx, offset Phase2Win
        mov ah, 09h
        int 21h

        ; Get phase 3 password
        mov cx, 05h
        mov dx, offset Phase3Buff
        call GetPass

        ; Check if argument was given
        mov al, ds:[80h]
        cmp al, 02h
        jne Explode

        ; Get XOR arg from SPS
        mov bl, byte ptr ds:[82h]

        ; Check phase 3 password
        mov cx, 05h
        mov di, offset Phase3Buff
        mov si, offset Phase3Pass
        Check3Loop:
            mov al, byte ptr [di]
            or al, bl
            cmp al, byte ptr [si]
            jne Explode
            inc di
            inc si
            loop Check3Loop

        ; Final congrats
        mov dx, offset Phase3Win
        mov ah, 09h
        int 21h

        jmp EndC

    ; ======== Phase 1 ========    
    Phase1:
    ; Greeting
    mov dx, offset Greeting
    mov ah, 09h
    int 21h

    ; Get phase 1 password
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

        ; Check phase 2
        mov cx, 4h
        mov si, offset Phase2Buff
        mov di, offset Phase2Pass

        Check2Loop:
            cmpsb
            jne Explode
            loop Check2Loop
        jmp Phase3

    ; Some internal data
    jmp InnerShortJmp1
    HjKU88 db 'p7aGe6poiu'
    InnerShortJmp1:
    jmp EndC

    ; Phase 1 checker
    CheckPhase1:
        mov cx, 8h
        mov si, offset Phase1Buff
        mov di, offset HjKU88
        
        Check1Loop:
            cmpsb
            jne Explode
            loop Check1Loop
        jmp Phase2

    ; ======== Explode section ========
    Explode:
        mov dx, offset ExplodeMsg
        mov ah, 09h
        int 21h
        jmp EndC

    EndC:
    ret

    ; ======== Get password procedure ========
    ; cx - bytes in password
    ; di - buffer addr
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