bits 64
default rel
%include "arch/x86_64/system/opcodes.inc"
global pic_init
section .text
pic_init:
    mov al, 0x11
    out PIC1_COMMAND_PORT, al
    out PIC2_COMMAND_PORT, al
    mov al, 0x20
    out PIC1_DATA_PORT, al
    mov al, 0x28
    out PIC2_DATA_PORT, al
    mov al, 0x04
    out PIC1_DATA_PORT, al
    mov al, 0x02
    out PIC2_DATA_PORT, al
    mov al, 0x01
    out PIC1_DATA_PORT, al
    mov al, 0x01
    out PIC2_DATA_PORT, al
    
    mov al, 0b11111100
    out PIC1_DATA_PORT, al
    call .delay
    mov al, 0xFF
    out PIC2_DATA_PORT, al
    call .delay
    ret
.delay:
    push rcx
    mov rcx, 0x1000
.delay_loop:
    dec rcx
    jnz .delay_loop
    pop rcx
    ret
