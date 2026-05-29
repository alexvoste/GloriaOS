[bits 64]
default rel

global kmalloc
global heap_current_ptr

extern pmm_alloc_page
extern vmm_map_page

HEAP_START equ 0x30000000
HEAP_END   equ 0x40000000

section .data
heap_current_ptr: dq HEAP_START

section .text

; kmalloc(uint64_t size)
; RDI = requested size in bytes
; Returns RAX = virtual address of allocated memory (or 0 on error)
kmalloc:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    push r13
    push r14

    mov r12, rdi
    test r12, r12
    jz .failed

    mov r13, [rel heap_current_ptr]

    mov r14, r13
    add r14, r12
    add r14, 15
    and r14, -16

    mov rcx, HEAP_END
    cmp r14, rcx
    ja .failed

    mov rbx, r13
    and rbx, ~0xFFF

.map_loop:
    cmp rbx, r14
    jae .mapping_done

    mov rdi, rbx
    xor rsi, rsi
    mov rdx, 3
    call vmm_map_page

    add rbx, 4096
    jmp .map_loop

.mapping_done:
    mov [rel heap_current_ptr], r14

    mov rax, r13
    jmp .exit

.failed:
    xor rax, rax

.exit:
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
