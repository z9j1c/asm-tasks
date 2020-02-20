.model tiny
.code

SCREEN_WIDTH equ 80d                                ; Screen width in symbols
SCREEN_HEIGHT equ 25d                               ; Screen height in symbols

;
; Symbols set
HOR_LINE_SYM            equ 40CDh                   ; Black ═ on red
VERT_LINE_SYM           equ 40BAh                   ; Black ║ on red

TOP_LEFT_CORNER_SYM     equ 40C9h                   ; Black ╔ on red
TOP_RIGHT_CORNER_SYM    equ 40BBh                   ; Black ╗ on red

BOT_LEFT_CORNER_SYM     equ 40C8h                   ; Black ╚ on red
BOT_RIGHT_CORNER_SYM    equ 40BCh                   ; Black ╝ on red

FILLER_SYM              equ 7020h                   ; Gray background space

org 100h

Start:
; Start values for enternal border
    push 16
    push 4
    push 7
    push 22

    call DrawEnclosuredBorders

    int 20h                         ; Terminate process

;****************************
;*  Draw rectangle borders  *
;*  [bp + 10] --- x         *
;*  [bp + 8] --- y          *
;*  [bp + 6] --- h          *
;*  [bp + 4] --- w          *
;****************************
DrawEnclosuredBorders PROC
    push bp
    mov bp, sp

    mov cx, [bp + 6]
    ManyBordersLoop:
        push cx
        push [bp + 10]
        push [bp + 8]
        push [bp + 6]
        push [bp + 4]

        call DrawBorder

        add sp, 8
        pop cx

        mov ax, [bp + 10]           ; Correct x-coord
        inc ax
        mov [bp + 10], ax

        mov ax, [bp + 8]            ; Correct y-coord
        inc ax
        mov [bp + 8], ax

        mov ax, [bp + 6]            ; Correct height
        sub ax, 2
        cmp ax, 1
        jle SkipPoint
        mov [bp + 6], ax

        ;mov ax, [bp + 6]            ; Alternative correction of height
        ;adds ax, 2
        ;cmp ax, 1
        ;jle SkipPoint
        ;mov [bp + 6], ax

        mov ax, [bp + 4]            ; Correct width
        sub ax, 2
        cmp ax, 1
        jle SkipPoint
        mov [bp + 4], ax

        jmp ManyBordersLoop

    SkipPoint:

    mov sp, bp
    pop bp
    ret
DrawEnclosuredBorders ENDP

;****************************
;*  Draw rectangle border   *
;*  [bp + 10] --- x         *
;*  [bp + 8] --- y          *
;*  [bp + 6] --- h          *
;*  [bp + 4] --- w          *
;****************************
DrawBorder PROC
    push bp                         ; Prologue
    mov bp, sp

    mov ax, 0b800h                  ; Set start drawing point
    mov es, ax

    mov dx, SCREEN_WIDTH            ; Set offset for (x; y)
    mov ax, [bp + 8]
    mul dx
    add ax, [bp + 10]
    mov dx, 2
    mul dx
    mov di, ax

    push [bp + 4]                   ; Draw top line
    push TOP_LEFT_CORNER_SYM
    push HOR_LINE_SYM
    push TOP_RIGHT_CORNER_SYM
    call DrawLine

    mov dx, SCREEN_WIDTH
    sub dx, [bp + 4]
    mov ax, 2
    mul dx
    
    mov cx, [bp + 6]                ; Set counter for middle part loop
    sub cx, 2
    
    MiddleLoop:
        add di, ax
        push ax
        push cx                     ; Save counter

        push [bp + 4]               ; Fill args for DrawLine
        push VERT_LINE_SYM
        push FILLER_SYM
        push VERT_LINE_SYM

        call DrawLine
        add sp, 8
        pop cx
        pop ax
        loop MiddleLoop

    add di, ax
    push [bp + 4]
    push BOT_LEFT_CORNER_SYM
    push HOR_LINE_SYM
    push BOT_RIGHT_CORNER_SYM
    call DrawLine

    mov sp, bp                      ; Epilogue
    pop bp
    ret
DrawBorder ENDP

;****************************
;*  Draw line               *
;*  [bp + 10] --- len       *
;*  [bp + 8] --- left sym   *
;*  [bp + 6] --- mid_sym    *
;*  [bp + 4] --- right sym  *
;****************************
DrawLine PROC
    push bp
    mov bp, sp

    cld

    mov ax, [bp + 8]                ; Left symbol
    stosw

    mov ax, [bp + 6]                ; Middle symbols
    mov cx, [bp + 10]
    sub cx, 2
    rep stosw

    mov ax, [bp + 4]                ; Right symbol
    stosw

    mov sp, bp
    pop bp
    ret
DrawLine ENDP

end Start
