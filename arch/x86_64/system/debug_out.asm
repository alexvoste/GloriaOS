bits 64
global send_debug_char_64
section .text
send_debug_char_64:
    push rax
    push rdx
    mov rax, rdi
    mov dx, 0x03F8
    out dx, al
    pop rdx
    pop rax
    ret
