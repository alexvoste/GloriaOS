bits 64
default rel
global kmalloc
extern heap_current_ptr

HEAP_START equ 0x30000000
HEAP_END equ 0x40000000

section .text
kmalloc:
    push rbx
    push rcx
    push rdx
    mov rbx, [heap_current_ptr]
    mov rax, rbx
    add rax, rdi
    add rax, 15
    and rax, -16
    mov rcx, HEAP_END
    cmp rax, rcx
    ja .allocation_failed
    mov [heap_current_ptr], rax
    mov rax, rbx
    jmp .allocation_successful
.allocation_failed:
    xor rax, rax
.allocation_successful:
    pop rdx
    pop rcx
    pop rbx
    ret
