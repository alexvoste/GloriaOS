[bits 64]
default rel
%include "arch/x86_64/system/opcodes.inc"

section .data
prompt: db '> ', 0
welcome: db 'GloriaOS Interactive Shell. Write something!', 0x0A, 0

section .text
global shell_entry_point
extern print_string_64
extern put_char_64
extern keyboard_read_char

shell_entry_point:
    lea rdi, [rel welcome]
    call print_string_64

.loop_prompt:
    lea rdi, [rel prompt]
    call print_string_64

    xor r12, r12

.read_loop:
    call keyboard_read_char

    cmp al, 0x0A
    je .handle_enter

    cmp al, 0x08
    je .handle_backspace

    cmp r12, 63
    jge .read_loop

    movzx rdi, al
    call put_char_64
    inc r12
    jmp .read_loop

.handle_backspace:
    cmp r12, 0
    je .read_loop
    dec r12
    extern current_cursor_x
    dec byte [rel current_cursor_x]
    mov rdi, ' '
    call put_char_64
    dec byte [rel_cursor_re_dec]
    jmp .read_loop

.handle_enter:
    mov rdi, 0x0A
    call put_char_64
    
    jmp .loop_prompt

section .text
rel_cursor_re_dec:
    dec byte [rel current_cursor_x]
    ret
