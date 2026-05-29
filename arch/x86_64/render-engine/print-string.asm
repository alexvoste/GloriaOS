bits 64
global print_string_64
extern put_char_64

section .text
print_string_64:
    push rax
    push rdi
    push rsi

    mov rsi, rdi
.loop:
    mov al, [rsi]
    test al, al
    je .done
    mov dil, al
    call put_char_64
    inc rsi
    jmp .loop
.done:
    pop rsi
    pop rdi
    pop rax
    ret
