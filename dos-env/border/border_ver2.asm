; TODO make border function

.model tiny
.code

SCREEN_WIDTH equ 80d                                ; Screen width in symbols
SCREEN_HEIGHT equ 25d                               ; Screen height in symbols

TOP_POS equ 4d                                      ; Top position of border
LEFT_POS equ 4d                                     ; Left position of border

BORDER_WIDTH equ SCREEN_WIDTH - 2 * LEFT_POS
BORDER_HEIGHT equ SCREEN_HEIGHT - 2 * TOP_POS

; Symbols set
HOR_LINE_SYM            equ 40CDh                   ; Black ═ on red
VERT_LINE_SYM           equ 40BAh                   ; Black ║ on red

TOP_LEFT_CORNER_SYM     equ 40C9h                   ; Black ╔ on red
TOP_RIGHT_CORNER_SYM    equ 40BBh                   ; Black ╗ on red

BOT_LEFT_CORNER_SYM     equ 40C8h                   ; Black ╚ on red
BOT_RIGHT_CORNER_SYM    equ 40BCh                   ; Black ╝ on red

FILLER_SYM              equ 7020h                   ; Gray background space

; ========================================================================================
; Macro that draws line with given symbols, user shoud set correct es:di address for it
; ========================================================================================
DrawLineMacro MACRO left_sym, mid_sym, right_sym, line_length
    cld                     ; Clear direction flag
    
    mov ax, left_sym
    stosw

    mov cx, line_length - 2
    mov ax, mid_sym
    rep stosw

    mov ax, right_sym
    stosw
ENDM


org 100h                                                ; Respect DOS PSP

Start:
    mov ax, 0b800h                                      ; Set address of vram
    mov es, ax

    mov di, (SCREEN_WIDTH * TOP_POS + LEFT_POS) * 2 ; Set start position (top left corner) of the border

    ; *** Draw top line ***
    DrawLineMacro TOP_LEFT_CORNER_SYM, HOR_LINE_SYM, TOP_RIGHT_CORNER_SYM, BORDER_WIDTH

    ; *** Draw middle part ***
    mov cx, BORDER_HEIGHT - 2
MiddleLoop:
    add di, LEFT_POS * 4

    push cx
    DrawLineMacro VERT_LINE_SYM, FILLER_SYM, VERT_LINE_SYM, BORDER_WIDTH
    pop cx

    loop MiddleLoop
    add di, LEFT_POS * 2 * 2

    ;  *** Draw bottom line ***
    DrawLineMacro BOT_LEFT_CORNER_SYM, HOR_LINE_SYM, BOT_RIGHT_CORNER_SYM, BORDER_WIDTH
    

    int 20h                                         ; Terminates

end Start
