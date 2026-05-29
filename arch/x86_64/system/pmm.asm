[bits 64]
default rel

global pmm_init
global pmm_alloc_page
global pmm_free_page

section .data
PMM_BITMAP_ADDR equ 0x400000
PMM_TOTAL_PAGES equ 32768
PMM_BITMAP_SIZE  equ 4096

section .text

pmm_init:
    push rax
    push rcx
    push rdi

    mov rdi, PMM_BITMAP_ADDR
    xor rax, rax
    mov rcx, PMM_BITMAP_SIZE / 8
    cld
    rep stosq

    mov rdi, PMM_BITMAP_ADDR
    mov al, 0xFF
    mov rcx, 128
    rep stosb

    pop rdi
    pop rcx
    pop rax
    ret

pmm_alloc_page:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    mov rdi, PMM_BITMAP_ADDR
    xor rcx, rcx

.byte_loop:
    cmp rcx, PMM_BITMAP_SIZE
    je .out_of_memory

    mov al, [rdi + rcx]
    cmp al, 0xFF
    je .next_byte

    xor rdx, rdx
.bit_loop:
    mov rbx, 1
    shl rbx, cl
    test al, bl
    jz .found_bit

    inc rdx
    cmp rdx, 8
    jl .bit_loop

.next_byte:
    inc rcx
    jmp .byte_loop

.found_bit:
    or al, bl
    mov [rdi + rcx], al

    shl rcx, 3
    add rcx, rdx

    shl rcx, 12
    mov rax, rcx
    jmp .exit

.out_of_memory:
    xor rax, rax

.exit:
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

pmm_free_page:
    push rax
    push rbx
    push rcx
    push rdx

    shr rdi, 12

    mov rcx, rdi
    shr rcx, 3

    mov rdx, rdi
    and rdx, 7

    mov rax, 1
    shl rax, cl
    not rax

    mov rbx, PMM_BITMAP_ADDR
    mov dl, [rbx + rcx]
    and dl, al
    mov [rbx + rcx], dl

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
