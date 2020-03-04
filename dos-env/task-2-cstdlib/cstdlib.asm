.model tiny
.code

org 100h
Start:

    mov ax, '*'
    mov di, offset MemsetLine
    mov cx, 4h
    call memset
    mov ah, 09h
    mov dx, offset MemsetLine
    int 21h

    mov si, offset MemcpySRC
    mov di, offset MemcpyTGT
    mov cx, 4h
    call memcpy
    mov ah, 09h
    mov dx, offset MemcpyTGT
    int 21h

    mov di, offset MemchrLine
    mov al, 'o'
    mov cx, 6
    call memchr
    mov di, bx
    mov dx, [di]
    mov ah, 02h
    int 21h

    mov di, offset MemcmpLine1
    mov si, offset MemcmpLine2
    mov cx, 4h
    call memcmp
    mov dx, ax
    add dx, 40h
    mov ah, 02h
    int 21h

    mov si, offset StrlenLine
    call strlen
    mov dx, ax
    add dx, 30h
    mov ah, 02h
    int 21h

    mov si, offset StrcpyLine1
    mov di, offset StrcpyLine2
    call strcpy
    mov dx, offset StrcpyLine2
    mov ah, 09h
    int 21h

    mov si, offset StrchrLine
    mov dl, 'e'
    call strchr
    mov dl, byte ptr [bx]
    mov ah, 02h
    int 21h

    mov si, offset StrcmpLin1
    mov di, offset StrcmpLin2
    call strcmp
    mov dx, ax
    add dx, 40h
    mov ah, 02h
    int 21h

    int 20h

; ============
; al - target byte
; di - addr
; cx - bytes count
; ============
memset PROC
    cld
    rep stosb
    ret
memset ENDP

; ============
; si - source addr
; di - target addr
; cx - bytes count
; ============
memcpy PROC
    cld
    rep movsb
    ret
memcpy ENDP

; ============
; di - addr
; al - target byte
; cx - max bytes count
; bx - return addr
; ============
memchr PROC
    cld
    mov bx, 0h
    repne scasb

    cmp cx, 0h
    je memchr_end_

    mov bx, di
    sub bx, 01h
    
    memchr_end_:
    ret
memchr ENDP

; ============
; di - addr 1
; si - addr 2
; cx - max bytes count
; ax - return value
; ============
memcmp PROC
    cld
    repe cmpsb
    
    dec di
    dec si
    
    mov ax, [di]
    sub ax, [si]
    ret
memcmp ENDP

; ============
; si - str addr
; ============
strlen PROC
    cld
    xor bx, bx
    
    strlen_loop_:
        lodsb
        cmp al, 0h
        je strlen_end_

        inc bx
        jmp strlen_loop_

    strlen_end_:
    mov ax, bx
    ret
strlen ENDP

; ============
; si - addr1
; di - addr2
; ============
strcpy PROC
    cld

    strcpy_loop_:
        lodsb
        mov byte ptr [di], al
        inc di

        cmp al, 0h
        je strcpy_end_
        jmp strcpy_loop_

    strcpy_end_:
    ret
strcpy ENDP

; ============
; si - addr
; dl - target byte
; bx - return addr
; ============
strchr PROC
    strchr_loop_:
        lodsb
        cmp al, dl
        je strchr_found_

        cmp al, 0h
        jne strchr_loop_
        
        mov bx, 0h
        jmp strchr_end_

    strchr_found_:
        mov bx, si
        dec bx

    strchr_end_:
    ret
strchr ENDP

; ============
; si - addr1
; di - addr2
; ax - return value
; ============
strcmp PROC
    strcmp_loop_:
        mov al, byte ptr [si]       ; Get two bytes and shift pointers
        mov dl, byte ptr [di]
        inc si
        inc di

        cmp al, dl
        jg strcmp_second_           ; Obviously the second line is less
        jl strcmp_first_            ; Obviously the first line is less

        cmp al, 0h                  ; Compare with endline
        jne strcmp_loop_            ; If not -> loop
        jmp strcmp_equal_           ; Else -> equal (shorter-greater lines case is handled previously)

    strcmp_second_:
        mov ax, 1h
        jmp strcmp_end_

    strcmp_first_:
        mov ax, -1h
        jmp strcmp_end_

    strcmp_equal_:
        xor ax, ax

    strcmp_end_:
    ret
strcmp ENDP

MemsetLine: db 'meow', 13, 10, '$'
MemcpySRC: db 'meow', 13, 10, '$'
MemcpyTGT: db 'wuff', 13, 10, '$'
MemchrLine: db 'hello', 13, 10, '$'
MemcmpLine1: db 'abaa', 13, 10, '$'
MemcmpLine2: db 'aaaa', 13, 10, '$'

StrlenLine: db 'line', 0, 13, 10, '$'

StrcpyLine1: db 'hehe', 0, 13, 10, '$'
StrcpyLine2: db 'hohoho', 0, 13, 10, '$'

StrchrLine: db 'search', 0, 13, 10, '$'

StrcmpLin1: db 'nono', 0, 13, 10, '$'
StrcmpLin2: db 'nonok', 0, 13, 10, '$'

end Start