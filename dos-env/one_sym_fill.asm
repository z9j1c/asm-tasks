.model tiny
.code

SCREEN_WIDTH equ 80       ; Screen width in symbols
SCREEN_HEIGHT equ 25       ; Screen height in symbols
BPS equ 2                 ; Bytes per symbol (place)

LEFT_POS equ 4            ; Left position of border
TOP_POS equ 4             ; Top position of border

BORDER_WIDTH equ SCREEN_WIDTH - 2 * LEFT_POS
BORDER_WIDTH equ SCREEN_WIDTH - 2 * LEFT_POS


org 100h

Start:
        mov cx, BORDER_WIDTH

        mov ax, 0b800h          ; Put vram adress into es
        mov es, ax

        mov di, (SCREEN_WIDTH * TOP_POS + LEFT_POS) * BPS ; Compute offset of left top corner of the border

        mov al, ' '             ; Put space symbol as one to be displayed
        mov ah, 20h             ; Terminate

        mov word ptr es:[di], ax
        int 20h

end   Start
