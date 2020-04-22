.intel_syntax noprefix

.section .text
.global zprintf

zprintf:
# Prologue
    pop r10 # Get return address

    # Save decimal arguments on stack
    push  r9
    push  r8
    push  rcx
    push  rdx
    push  rsi

    mov r9, rsp # R9 will be pointer at integer arguments

    # Save double arguments on stack
    movq rdx, xmm0
    push  rdx
    movq rdx, xmm1
    push  rdx
    movq rdx, xmm2
    push  rdx
    movq rdx, xmm3
    push  rdx
    movq rdx, xmm4
    push  rdx
    movq rdx, xmm5
    push  rdx
    movq rdx, xmm6
    push  rdx
    movq rdx, xmm7
    push  rdx

    mov r11, rsp # R11 will be pointer at double arguments

    push  r10 # Place return address back
    push  rbp # Usual prologue
    mov rbp, rsp

    dec rdi # Trick to inc RDI in every loop iteration
.Lparse_loop:
    inc rdi

    # Check end of line
    mov bl, byte ptr [rdi]
    cmp bl, 0x0
    je .Lepilogue

    # Check format modifier %
    cmp bl, '%'
    jne .Lprint_symbol
    
    # Go to the next symbol
    inc rdi
    mov bl, byte ptr [rdi]

    # Check double %
    cmp bl, '%'
    je .Lprint_symbol

    # Check line modifier
    cmp bl, 's'
    je .Lprint_line

    # Check binary modifier
    cmp bl, 'b'
    je .Lprint_bin

    # Check oct modifier
    cmp bl, 'o'
    je .Lprint_oct

    # Check oct modifier
    cmp bl, 'x'
    je .Lprint_hex

    # Check ec modifier
    cmp bl, 'd'
    je .Lprint_dec

.Lprint_symbol:
    push rdi
    push r9
    push r11

    # Write syscall
    mov rax, 0x1
    mov rsi, rdi
    mov rdi, 0x1
    mov rdx, 0x1
    syscall

    pop r11
    pop r9
    pop rdi
    jmp .Lparse_loop


# === Print line by ptr [R9] ===
.Lprint_line:
    # Save arguments ptr's
    push rdi
    push r9
    push r11
    
    mov r9, [r9] # Load line addr
    .Lprint_line_loop:
        # Check line end
        cmp byte ptr [r9], 0x0
        je .Lprint_line_end

        # Print symbol
        push r9
        mov rax, 0x1
        mov rsi, r9
        mov rdi, 0x1
        mov rdx, 0x1
        syscall

        # Shift symbol ptr and go into loop
        pop r9
        inc r9
        jmp .Lprint_line_loop

    .Lprint_line_end:
        # Restore arguments ptr's
        pop r11
        pop r9
        add r9, 0x8
        pop rdi
        jmp .Lparse_loop


# === Print integer [R9] in binary format ===
.Lprint_bin:
    # Save arguments ptr's
    push rdi
    push r9
    push r11

    mov r9, [r9]
    xor rcx, rcx
    .Lprint_bin_produce_loop:
        mov r11, r9
        and r11, 0x1
        
        push r11
        inc rcx

        shr r9, 0x1
        cmp r9, 0x0
        je .Lprint_bin_loop
        jmp .Lprint_bin_produce_loop

    .Lprint_bin_loop:
        mov rax, 0x1
        pop rsi
        add rsi, offset TranslateLine
        mov rdi, 0x1
        mov rdx, 0x1

        push rcx
        syscall
        pop rcx
        loop .Lprint_bin_loop

    # Restore arguments ptr's
    pop r11
    pop r9
    add r9, 0x8
    pop rdi
    jmp .Lparse_loop


# === Print integer [R9] in oct format ===
.Lprint_oct:
    # Save arguments ptr's
    push rdi
    push r9
    push r11

    mov r9, [r9]
    xor rcx, rcx
    .Lprint_oct_produce_loop:
        mov r11, r9
        and r11, 0x7
        
        push r11
        inc rcx

        shr r9, 0x3
        cmp r9, 0x0
        je .Lprint_oct_loop
        jmp .Lprint_oct_produce_loop

    .Lprint_oct_loop:
        mov rax, 0x1
        pop rsi
        add rsi, offset TranslateLine
        mov rdi, 0x1
        mov rdx, 0x1

        push rcx
        syscall
        pop rcx
        loop .Lprint_oct_loop

    # Restore arguments ptr's
    pop r11
    pop r9
    add r9, 0x8
    pop rdi
    jmp .Lparse_loop


# === Print integer [R9] in hex format ===
.Lprint_hex:
    # Save arguments ptr's
    push rdi
    push r9
    push r11

    mov r9, [r9]
    xor rcx, rcx
    .Lprint_hex_produce_loop:
        mov r11, r9
        and r11, 0xF
        
        push r11
        inc rcx

        shr r9, 0x4
        cmp r9, 0x0
        je .Lprint_hex_loop
        jmp .Lprint_hex_produce_loop

    .Lprint_hex_loop:
        mov rax, 0x1
        pop rsi
        add rsi, offset TranslateLine
        mov rdi, 0x1
        mov rdx, 0x1

        push rcx
        syscall
        pop rcx
        loop .Lprint_hex_loop

    # Restore arguments ptr's
    pop r11
    pop r9
    add r9, 0x8
    pop rdi
    jmp .Lparse_loop


# === Print [R9] in decimal format ===
.Lprint_dec:
    # Save arguments ptr's
    push rdi
    push r9
    push r11

    mov r9, [r9]
    xor rcx, rcx
    .Lprint_dec_produce_loop:
        # Push remainder and continue with quotient
        mov rax, r9
        xor rdx, rdx
        mov r11, 0xA
        div r11
        push rdx
        mov r9, rax
        inc rcx

        cmp r9, 0x0
        je .Lprint_dec_loop
        jmp .Lprint_dec_produce_loop

    # Print stacked values
    .Lprint_dec_loop:
        mov rax, 0x1
        pop rsi
        add rsi, offset TranslateLine
        mov rdi, 0x1
        mov rdx, 0x1

        push rcx
        syscall
        pop rcx
        loop .Lprint_hex_loop

    # Restore arguments ptr's
    pop r11
    pop r9
    add r9, 0x8
    pop rdi
    jmp .Lparse_loop


# Modified epilogue
.Lepilogue:
    leave
    pop r10
    add rsp, 0x68
    push  r10
    ret

.section .data
    TranslateLine: .ascii "0123456789ABCDEF"