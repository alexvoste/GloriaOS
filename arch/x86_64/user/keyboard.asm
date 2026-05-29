[bits 64]
default rel
%include "arch/x86_64/system/opcodes.inc"

section .data
global kbd_buffer_head
global kbd_buffer_tail
kbd_buffer_head: dq 0
kbd_buffer_tail: dq 0

section .bss
kbd_buffer: resb 256

section .text
align 16
global keyboard_isr
global keyboard_read_char

keymap:
    db 0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x08
    db 0x09, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x0A
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', 0
    db '\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '
    times 128 - ($ - keymap) db 0

keyboard_isr:
    push rax
    push rbx
    push rcx
    push rdx

    in al, 0x60
    test al, 0x80
    jnz .done

    movzx rbx, al
    lea rcx, [rel keymap]
    mov al, [rcx + rbx]
    cmp al, 0
    je .done

    mov rbx, [rel kbd_buffer_head]
    lea rcx, [rel kbd_buffer]
    mov [rcx + rbx], al

    inc rbx
    and rbx, 0xFF
    mov [rel kbd_buffer_head], rbx

.done:
    mov al, PIC_EOI_COMMAND
    out PIC1_COMMAND_PORT, al

    pop rdx
    pop rcx
    pop rbx
    pop rax
    iretq

keyboard_read_char:
    push rbx
    push rcx
.wait_loop:
    mov rbx, [rel kbd_buffer_tail]
    mov rcx, [rel kbd_buffer_head]
    cmp rbx, rcx
    je .wait_loop

    lea rcx, [rel kbd_buffer]
    mov al, [rcx + rbx]

    inc rbx
    and rbx, 0xFF
    mov [rel kbd_buffer_tail], rbx

    pop rcx
    pop rbx
    ret
