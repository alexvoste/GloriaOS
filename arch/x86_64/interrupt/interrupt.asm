[bits 64]
default rel
%include "arch/x86_64/system/opcodes.inc"
section .text
global load_idt
global divide_error_isr
global double_fault_isr
global general_protection_isr
global page_fault_isr
global timer_isr
extern keyboard_isr

IDT_BASE equ 0x20000

align 16
idt_descriptor:
    dw 256 * 16 - 1
    dq 0x20000

section .data
divide_error_str: db 'Divide Error',0
double_fault_str: db 'Double Fault',0
general_protection_str: db 'General Protection',0
page_fault_str: db 'Page Fault',0

section .text

register_interrupt:
    mov rcx, rdi
    shl rcx, 4
    add rcx, IDT_BASE
    mov rdx, rsi
    mov word [rcx], dx
    mov word [rcx+2], CODE_SEG_64
    mov byte [rcx+4], 0
    mov byte [rcx+5], 0x8E
    shr rdx, 16
    mov word [rcx+6], dx
    mov rax, rsi
    shr rax, 32
    mov dword [rcx+8], eax
    mov dword [rcx+12], 0
    ret

load_idt:
    push rdi
    push rsi
    push rcx
    push rax
    mov rdi, IDT_BASE
    xor rax, rax
    mov rcx, 512
    cld
    rep stosq

    mov rdi, 0
    mov rsi, divide_error_isr
    call register_interrupt
    mov rdi, 8
    mov rsi, double_fault_isr
    call register_interrupt
    mov rdi, 13
    mov rsi, general_protection_isr
    call register_interrupt
    mov rdi, 14
    mov rsi, page_fault_isr
    call register_interrupt
    mov rdi, 32
    mov rsi, timer_isr
    call register_interrupt
    mov rdi, 33
    mov rsi, keyboard_isr
    call register_interrupt

    lidt [rel idt_descriptor]
    pop rax
    pop rcx
    pop rsi
    pop rdi
    ret

divide_error_isr:
    mov word [0xB8000], 0x0F44 ; 'D' attr 0x0F
    mov word [0xB8002], 0x0F45 ; 'E'
    cli
    hlt
    jmp $

double_fault_isr:
    mov word [0xB8000], 0x0F44 ; 'D'
    mov word [0xB8002], 0x0F46 ; 'F'
    cli
    hlt
    jmp $

general_protection_isr:
    mov word [0xB8000], 0x0F47 ; 'G'
    mov word [0xB8002], 0x0F50 ; 'P'
    cli
    hlt
    jmp $

page_fault_isr:
    mov word [0xB8000], 0x0F50 ; 'P'
    mov word [0xB8002], 0x0F46 ; 'F'
    cli
    hlt
    jmp $

timer_isr:
    mov al, PIC_EOI_COMMAND
    out PIC1_COMMAND_PORT, al
    iretq

