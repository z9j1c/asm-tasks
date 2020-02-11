.model tiny
.code

SCREEN_WIDTH equ 80d       ; Screen width in symbols
SCREEN_HEIGHT equ 25d      ; Screen height in symbols
BPS equ 2d                 ; Bytes per symbol (place)

LEFT_POS equ 4d            ; Left position of border
TOP_POS equ 4d             ; Top position of border

BORDER_WIDTH equ SCREEN_WIDTH - 2 * LEFT_POS
BORDER_HEIGHT equ SCREEN_HEIGHT - 2 * TOP_POS


org 100h

Start:
        mov ax, 0b800h              ; Put vram adress into es
        mov es, ax

        ; *** Draw top border line ***
        ; Compute offset of left top corner of the border
        ; Here the start place for top horizontal line is set
        mov di, (SCREEN_WIDTH * TOP_POS + LEFT_POS) * BPS
        mov al, 0CDh                ; Put space symbol as one to be displayed
        mov ah, 40h                 ; Set symbol attribute
        call HorLineDraw            ; Draw line

        ; *** Draw bottom border line ***
        mov di, (SCREEN_WIDTH * (SCREEN_HEIGHT - TOP_POS) + LEFT_POS) * BPS
        mov ax, HOR_LINE_SYM        ; Put symbol
        call HorLineDraw            ; Draw line

        ; *** Draw filled middle rectangle ***
        mov di, (SCREEN_WIDTH * (TOP_POS + 1) + LEFT_POS) * BPS
        mov cx, BORDER_HEIGHT - 1
        mov al, ' '
        mov ah, 70h
        call FillRect

        ; *** Draw left border line ***
        mov di, (SCREEN_WIDTH * (TOP_POS + 1) + LEFT_POS) * BPS
        mov cx, BORDER_HEIGHT - 1
        mov ax, VERT_LINE_SYM
        call VertLineDraw

        ; *** Draw right border line ***
        mov di, (SCREEN_WIDTH * (TOP_POS + 1) + LEFT_POS + BORDER_WIDTH - 1) * BPS
        mov cx, BORDER_HEIGHT - 1
        mov ax, VERT_LINE_SYM
        call VertLineDraw

        ; *** Draw special symbols on corners ***
        mov di, (SCREEN_WIDTH * TOP_POS + LEFT_POS) * BPS
        mov ax, TOP_LEFT_CORNER_SYM
        cld
        stosw

        add di, (BORDER_WIDTH - 2) * BPS
        mov ax, TOP_RIGHT_CORNER_SYM
        cld
        stosw

        add di, (BORDER_HEIGHT * SCREEN_WIDTH - 1) * BPS
        mov ax, BOT_RIGHT_CORNER_SYM
        cld
        stosw

        sub di, BORDER_WIDTH * BPS
        mov ax, BOT_LEFT_CORNER_SYM
        cld
        stosw


        int 20h                     ; Terminate

HOR_LINE_SYM            dw 40CDh
VERT_LINE_SYM           dw 40BAh

TOP_LEFT_CORNER_SYM     dw 40C9h
TOP_RIGHT_CORNER_SYM    dw 40BBh

BOT_LEFT_CORNER_SYM     dw 40C8h
BOT_RIGHT_CORNER_SYM    dw 40BCh

; ========================================================================
; Draw horizontal line
; start place, symbol, attribute should be set previously
HorLineDraw PROC
        mov cx, BORDER_WIDTH        ; Set counter for symbols
    
    HorLineLoop:
        ;mov word ptr es:[di], ax    ; Write symbol in video ram
        cld
        stosw
        loop HorLineLoop
        ret

HorLineDraw ENDP
; ========================================================================

; ========================================================================
; Draw filled rectangle
; start place, symbol, attribute and height should be set previously
FillRect PROC
    RectLoop:
        push cx
        
        call HorLineDraw
        
        pop cx
        add di, 2 * LEFT_POS * BPS
        
        loop RectLoop
        ret
        
FillRect ENDP
; ========================================================================

; ========================================================================
; Draw vertical line
; start place, symbol, attribute and height should be set previously
VertLineDraw PROC
    VertLineLoop:
        cld
        stosw
        add di, BPS * (SCREEN_WIDTH - 1)
        loop VertLineLoop
        ret

VertLineDraw ENDP

end   Start