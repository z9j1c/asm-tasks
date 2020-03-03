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
    mov bx, 'o'
    mov cx, 6
    call memchr
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

    mov di, offset StrlenLine
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

    mov di, offset StrchrLine
    mov bl, 'e'
    call strchr
    mov di, ax
    mov dl, byte ptr [di]
    mov ah, 02h
    int 21h

    mov di, offset StrcmpLin1
    mov si, offset StrcmpLin2
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
    memcpy_loop_:
        mov al, byte ptr [si]
        mov byte ptr [di], al
        inc si
        inc di
        loop memcpy_loop_
    ret
memcpy ENDP

; ============
; di - addr
; bl - target byte
; cx - max bytes count
; ax - return addr
; ============
memchr PROC
    memchr_loop_:
        mov al, byte ptr [di]
        cmp bl, al
        je memchr_return_addr_
        inc di
        loop memchr_loop_
    mov ax, 0h
    jmp memchr_end_

    memchr_return_addr_:
        mov ax, di
    
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
    memcmp_loop_:
        mov al, byte ptr [di]
        mov bl, byte ptr [si]

        cmp al, bl
        jne memcmp_return_value_
        
        inc di
        inc si
        loop memcmp_loop_
    
    mov ax, 0h
    jmp memcmp_end_

    memcmp_return_value_:
        xor ax, ax
        xor dx, dx
        mov al, byte ptr [di]
        mov dl, byte ptr [si]
        sub ax, dx

    memcmp_end_:
    ret
memcmp ENDP

; ============
; di - str addr
; ============
strlen PROC
    mov ax, 0h
    strlen_loop_:
        mov dl, byte ptr [di]
        cmp dl, 0h
        je strlen_end_

        inc ax
        inc di
        jmp strlen_loop_

    strlen_end_:
    ret
strlen ENDP

; ============
; si - addr1
; di - addr2
; ============
strcpy PROC
    push di
    push si
    mov di, si
    call strlen
    
    pop si
    pop di
    inc ax
    
    mov cx, ax
    call memcpy

    ret
strcpy ENDP

; ============
; di - addr
; bl - target byte
; ax - return addr
; ============
strchr PROC
    push bx
    push di
    call strlen
    
    pop di
    pop bx
    inc ax
    mov cx, ax
    
    call memchr
    ret
strchr ENDP

; ============
; di - addr1
; si - addr2
; ============
strcmp PROC
    push di
    
    call strlen
    push ax
    
    mov di, si
    call strlen
    
    pop cx
    pop di

    cmp ax, cx
    mov bx, ax
    sub bx, cx
    push bx
    
    jle strcmp_after_len_swap
    mov ax, cx
    
    xor dx, dx
    pop bx
    sub dx, bx
    push dx

    strcmp_after_len_swap:
    call memcmp
    pop bx

    cmp ax, 0h
    jne strcmp_end_
    cmp bx, 0h
    je strcmp_end_
    mov ax, -1h

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