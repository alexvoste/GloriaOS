bits 64
default rel

global vmm_map_page
extern pmm_alloc_page

pml4_addr equ 0x9000

section .text

; vmm_map_page(uint64_t virtual_addr, uint64_t physical_addr, uint64_t flags)
; RDI = virtual address
; RSI = physical address
; RDX = flags (ex: 0x03 = Present | R/W)
vmm_map_page:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10

    mov r8, rdi
    mov r9, rsi
    mov r10, rdx

    ; PML4 index = (virtual_addr >> 39) & 0x1FF
    mov rax, r8
    shr rax, 39
    and rax, 0x1FF
    mov rbx, rax

    ; PDPT index = (virtual_addr >> 30) & 0x1FF
    mov rax, r8
    shr rax, 30
    and rax, 0x1FF
    mov rcx, rax

    ; PD index = (virtual_addr >> 21) & 0x1FF
    mov rax, r8
    shr rax, 21
    and rax, 0x1FF
    mov rdx, rax

    ; PT index = (virtual_addr >> 12) & 0x1FF
    mov rax, r8
    shr rax, 12
    and rax, 0x1FF
    mov rdi, rax

    ; PML4 -> PDPT
    mov rsi, pml4_addr
    shl rbx, 3
    add rsi, rbx
    mov rax, [rsi]
    test rax, 1
    jnz .pdpt_exists

    call pmm_alloc_page
    test rax, rax
    jz .failed
    or rax, 0x03
    mov [rsi], rax

.pdpt_exists:
    and rax, ~0xFFF
    mov rsi, rax

    ; PDPT -> PD
    shl rcx, 3
    add rsi, rcx
    mov rax, [rsi]
    test rax, 1
    jnz .pd_exists

    call pmm_alloc_page
    test rax, rax
    jz .failed
    or rax, 0x03
    mov [rsi], rax
.pd_exists:
    and rax, ~0xFFF 
    mov rsi, rax 

    shl rdx, 3 
    add rsi, rdx 
    mov rax, [rsi]

    test rax, 1 
    jnz .pt_exists

    call pmm_alloc_page
    test rax, rax 
    jz .failed 
    or rax, 0x03 
    mov [rsi], rax 


.pt_exists:
    and rax, ~0xFFF
    mov rsi, rax

    ; ---- PT --> Physical page ---- 
    shl rdi, 3 ; PT 
    add rsi, rdi   ; RSI -> PT(PTE)

    cmp r9, 0
    jne .use_provided_phys

    call pmm_alloc_page
    test rax, rax
    jz .failed
    mov r9, rax



.use_provided_phys:
    mov rax, r9
    or rax, r10
    mov [rsi], rax

    invlpg [r8]

.failed:
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
