global start_step_two
extern print_string_64
extern send_debug_char_64
extern pic_init
extern shell_entry_point
extern load_idt 
%include "arch/x86_64/system/opcodes.inc"

[bits 16]

pml4 equ 0x9000
pdpt equ 0xA000
pd equ 0xB000
pt  equ 0xC000

CODE_SEG equ 0x08
DATA_SEG equ 0x10

section .text
start_step_two:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:init_pm

align 8
gdt_start:
    dq 0
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    mov ax, 0x0C58
    mov [0xB8000], ax
    mov al, 'D'
    mov dx, 0x03F8
    out dx, al

    call setup_page_tables
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    call dump_regs_32
    mov ecx, MSR_EFER
    rdmsr
    or eax, 1 << EFER_LME_BIT
    wrmsr

    mov eax, pml4
    mov cr3, eax
    call dump_regs_32
    mov eax, cr0
    or eax, 1 << 31
    call dump_regs_32
    mov cr0, eax

    lgdt [gdt64_descriptor]

    push 0x08
    push start64
    retf

setup_page_tables:
    mov edi, pml4
    xor eax, eax
    mov ecx, 4096
    cld
    rep stosd

    mov eax, pdpt
    or eax, 3
    mov [pml4], eax
    mov dword [pml4 + 4], 0

    mov eax, pd
    or eax, 3
    mov [pdpt], eax
    mov dword [pdpt + 4], 0

    mov eax, pt
    or eax, 3
    mov [pd], eax
    mov dword [pd + 4], 0

    mov edi, pt
    mov eax, 0x1B
    mov ecx, 512
.pte_loop:
    mov [edi], eax
    mov dword [edi + 4], 0
    add eax, 0x1000
    add edi, 8
    loop .pte_loop
    ret

dump_hex32:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, 8
    mov ebx, eax
.dump_hex32_loop:
    mov edx, ebx
    and edx, 0xF0000000
    shr edx, 28
    add dl, '0'
    cmp dl, '9'
    jbe .dump_hex32_emit
    add dl, 7
.dump_hex32_emit:
    mov al, dl
    mov dx, 0x03F8
    out dx, al
    shl ebx, 4
    loop .dump_hex32_loop

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

dump_regs_32:
    push eax
    push ebx
    push ecx
    push edx

    mov al, 'R'
    mov dx, 0x03F8
    out dx, al

    mov eax, cr0
    call dump_hex32
    mov al, ','
    out dx, al

    mov eax, cr3
    call dump_hex32
    mov al,','
    out dx, al

    mov ecx, MSR_EFER
    rdmsr
    mov ebx, eax
    mov eax, edx
    call dump_hex32
    mov al, '|'
    out dx, al
    mov eax, ebx
    call dump_hex32

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

align 8
gdt64:
    dq 0
    dq 0x00209A0000000000
    dq 0x0000920000000000
gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64 - 1
    dd gdt64

[bits 64]
default rel
global start64
start64:
    cli
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x70000

    call pic_init
    call load_idt
    sti 

    mov rbx, 0xB8000
    mov rax, 0x0C58
    mov [rbx], ax

    wbinvd

    mov rdi, 'X'
    call send_debug_char_64

    mov rcx, 2000
    mov rdi, 0xB8000
    mov ax, 0x0720
    rep stosw

    lea rdi, [rel gloria_message]
    call shell_entry_point

halt_loop:
    hlt
    jmp halt_loop

section .data
gloria_message: db 'GloriaOS', 0
