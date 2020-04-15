.model tiny
.386

.data
    RegAccumLine: db 'ax: ----hbx: ----hcx: ----hdx: ----hdi: ----hsi: ----hse: ----hsp: ----hbp: ----h', 10, 13, '$', 0
    TranslationLine: db '0123456789ABCDEF'
    LongMode: dw 0h ; Long Mode flag (9 registers instead of 4)
    ShowFlag: db 1h

.code

SCREEN_WIDTH equ 80d                                ; Screen width in symbols
SCREEN_HEIGHT equ 25d                               ; Screen height in symbols

; Symbols set
HOR_LINE_SYM            equ 40CDh                   ; Black ═ on red
VERT_LINE_SYM           equ 40BAh                   ; Black ║ on red

TOP_LEFT_CORNER_SYM     equ 40C9h                   ; Black ╔ on red    
TOP_RIGHT_CORNER_SYM    equ 40BBh                   ; Black ╗ on red

BOT_LEFT_CORNER_SYM     equ 40C8h                   ; Black ╚ on red
BOT_RIGHT_CORNER_SYM    equ 40BCh                   ; Black ╝ on red

FILLER_SYM              equ 3021h

LABEL_WIDTH             equ 0Bh

; ========================================================================
; ***********
; *ax: FFFFh*
; *bx: FFFFh*
; *cx: FFFFh*
; *dx: FFFFh*
; ========================================================================
FormCornerLabel MACRO LABEL_HEIGHT
    DrawBorder LABEL_HEIGHT
    FillRegAccumLine LABEL_HEIGHT-2
    PrintRegsLine LABEL_HEIGHT-2
ENDM


; ========================================================================
; Draws border with given height
; ========================================================================
DrawBorder MACRO LABEL_HEIGHT
    LOCAL LabelFillingLoop, L1
    std

    mov ax, 0B800h
    mov es, ax

    ; Paint top line
    mov di, 2 * (SCREEN_WIDTH - 1)
    mov cx, LABEL_WIDTH - 2
    DrawLine TOP_RIGHT_CORNER_SYM, HOR_LINE_SYM, TOP_LEFT_CORNER_SYM

    ; Paint middle part
    mov cx, LABEL_HEIGHT - 2
    LabelFillingLoop:
        add di, 2 * (SCREEN_WIDTH + LABEL_WIDTH)
        mov si, cx

        mov cx, LABEL_WIDTH - 2
        DrawLine VERT_LINE_SYM, FILLER_SYM, VERT_LINE_SYM

        mov cx, si
        loop LabelFillingLoop

    ; Paint bottom line
    add di, 2 * (SCREEN_WIDTH + LABEL_WIDTH)
    mov cx, LABEL_WIDTH - 2
    DrawLine BOT_RIGHT_CORNER_SYM, HOR_LINE_SYM, BOT_LEFT_CORNER_SYM

    
ENDM

; ========================================================================
; cx /* line length */, es:di /* address in video memory */ and DF
; must be set previously (DF may be cleared)
; ========================================================================
DrawLine MACRO begin_sym, mid_sym, last_sym
    mov ax, begin_sym
    stosw

    mov ax, mid_sym
    rep stosw

    mov ax, last_sym
    stosw
ENDM

; ========================================================================
; Fills RegAccumLine with HEX values from stack:
; --> ax, bx, cx, dx, di, si, es, sp, bp, [sp] -->
;
; REGS_COUNT - how many regs to be translated
; ========================================================================
FillRegAccumLine MACRO REGS_COUNT
    LOCAL RegsFillingLoop

    mov cx, REGS_COUNT
    
    ; BX points at firstly pushed register
    mov bx, sp
    add bx, 10h

    ; Set offset in RegAccumLine
    mov dx, 4h

    RegsFillingLoop:
        mov ax, [bx]

        push bx
        push cx
        push dx
        TranslateRegister
        pop dx
        pop cx
        pop bx

        add dx, 9h
        sub bx, 2h
        loop RegsFillingLoop
ENDM

; ========================================================================
; AX - target byte
; DX must be set as offset in RegAccumLine
; ========================================================================
TranslateRegister MACRO
    mov cx, ax
    add dx, 2h

    mov ah, al
    TranslateByte2Hex
    mov bx, offset RegAccumLine
    add bx, dx
    sub dx, 2h
    mov [bx], ax

    mov ax, cx
    mov al, ah
    TranslateByte2Hex
    mov bx, offset RegAccumLine
    add bx, dx
    mov [bx], ax
ENDM


; ========================================================================
; AL and AH must be set equal to target byte
; ========================================================================
TranslateByte2Hex MACRO
    lea bx, cs:[TranslationLine]
    ; Get low & high parts of register in ah & al
    shr ah, 4h
    and al, 0Fh
    ; Translate bytes into hex codes
    xlat
    xchg al, ah
    xlat
ENDM

; ========================================================================
; Print the whole registers line
; ========================================================================
PrintRegsLine MACRO ROWS_COUNT
    LOCAL RegsLoop

    ; Get base addr for video memory & line
    mov dx, 2 * (SCREEN_WIDTH * 2 - LABEL_WIDTH + 1)
    mov si, offset RegAccumLine

    mov cx, ROWS_COUNT
    RegsLoop:
        mov di, dx
        push cx
        PrintOneRegister
        pop cx
        add dx, 2 * SCREEN_WIDTH
        loop RegsLoop
ENDM

; ========================================================================
; Prints one register infoline
; ========================================================================
PrintOneRegister MACRO
    LOCAL PrintLoop
    cld

    mov cx, 9h
    PrintLoop:
        mov al, byte ptr [si]

        mov byte ptr es:[di], al
        inc si
        add di, 02h
        loop PrintLoop
ENDM




org 100h

Start:
    ; Check command line arguments (and set long mode)
    mov al, ds:[80h]
    cmp al, 02h
    jne HandlersBlock

    mov al, ds:[82h]
    cmp al, 'L'
    jne HandlersBlock

    mov bx, offset LongMode
    mov byte ptr [bx], 01h

    HandlersBlock:

    ; Store current handler vector for 1Ch interrupt
    mov ax, 351Ch
    int 21h
    mov [PrevTimerINT], bx
    mov [PrevTimerINT + 2], es

    ; Store current handler vector for 09h interrupt
    mov ax, 3509h
    int 21h
    mov [PrevKeyDownINT], bx
    mov [PrevKeyDownINT + 02h], es

    ; Set my own handler for 1Ch interrupt
    cli
    mov ax, 251Ch
    lea dx, Z_TIMER_INT
    int 21h

    mov ax, 2509h
    lea dx, Z_KEYDOWN_INT
    int 21h
    sti

    ; Gone but not dead (go into TSR)
    mov ax, 3100h
    mov dx, 0FFh
    int 21h

; Old handler for 1Ch int
PrevTimerINT dw 0h, 0h

; Old handler for 09h int
PrevKeyDownINT dw 0h, 0h


Z_TIMER_INT PROC FAR
    pushf   ; Save flags register
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es
    push sp
    push bp

    push ds
    push cs
    pop ds

    mov bx, offset ShowFlag
    cmp byte ptr [bx], 01h
    jne PastBlock

    mov bx, offset LongMode
    xor ax, ax
    cmp ax, [bx]

    jne LongModeBlock
    FormCornerLabel 06h
    jmp PastBlock

    LongModeBlock:
    FormCornerLabel 0Bh

    PastBlock:
    pop ds

    pop bp
    pop sp
    pop es
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf

    push word ptr cs:[PrevTimerINT + 2]
    push word ptr cs:[PrevTimerINT]
    retf
ENDP

Z_KEYDOWN_INT PROC FAR
    pusha
    in AL, 60h

    cmp al, 3Ah ; CapsLock
    jne HandleKey

    push ds
    push cs
    pop ds
    mov bx, offset ShowFlag
    xor byte ptr [bx], 01h
    pop ds

    HandleKey:

    popa
    push word ptr cs:[PrevKeyDownINT + 2]
    push word ptr cs:[PrevKeyDownINT]
    retf
ENDP

END Start