[bits 64]
default rel
%include "arch/x86_64/system/opcodes.inc"

section .data
prompt: db 0x0A, '> ', 0
welcome: db 'GloriaOS Interactive Shell v1.0. Ready.', 0x0A, 0
help_text: db 'Available commands:', 0x0A, '  help   - Show this help', 0x0A, '  clear  - Clear the screen', 0x0A, '  reboot - Hard reboot the system', 0x0A, 0
unknown_cmd: db 'Unknown command. Type "help" for a list of commands.', 0x0A, 0

cmd_help: db 'help', 0
cmd_clear: db 'clear', 0
cmd_reboot: db 'reboot', 0

section .bss
cmd_buffer: resb 64

section .text
global shell_entry_point
extern print_string_64
extern put_char_64
extern keyboard_read_char

shell_entry_point:
    call do_clear
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

    cmp r12, 62
    jge .read_loop

    lea rbx, [rel cmd_buffer]
    mov [rbx + r12], al
    inc r12

    movzx rdi, al
    call put_char_64
    jmp .read_loop

.handle_backspace:
    cmp r12, 0
    je .read_loop
    dec r12

    lea rbx, [rel cmd_buffer]
    mov byte [rbx + r12], 0

    mov rdi, 0x08
    call put_char_64
    jmp .read_loop

.handle_enter:
    lea rbx, [rel cmd_buffer]
    mov byte [rbx + r12], 0

    mov rdi, 0x0A
    call put_char_64

    cmp r12, 0
    je .loop_prompt

    lea rdi, [rel cmd_buffer]
    lea rsi, [rel cmd_help]
    call strcmp
    test rax, rax
    jz .exec_help

    lea rdi, [rel cmd_buffer]
    lea rsi, [rel cmd_clear]
    call strcmp
    test rax, rax
    jz .exec_clear

    lea rdi, [rel cmd_buffer]
    lea rsi, [rel cmd_reboot]
    call strcmp
    test rax, rax
    jz .exec_reboot

    lea rdi, [rel unknown_cmd]
    call print_string_64
    jmp .loop_prompt

.exec_help:
    lea rdi, [rel help_text]
    call print_string_64
    jmp .loop_prompt

.exec_clear:
    call do_clear
    jmp .loop_prompt

.exec_reboot:
    call do_reboot
    jmp .loop_prompt

strcmp:
    xor rax, rax
.loop:
    mov al, [rdi]
    mov bl, [rsi]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc rdi
    inc rsi
    jmp .loop
.not_equal:
    mov rax, 1
    ret
.equal:
    xor rax, rax
    ret

do_clear:
    mov rcx, 2000
    mov rdi, 0xB8000
    mov ax, 0x0F20
    rep stosw

    extern current_cursor_x
    extern current_cursor_y
    mov byte [rel current_cursor_x], 0
    mov byte [rel current_cursor_y], 0

    mov dx, 0x3D4
    mov al, 14
    out dx, al
    mov dx, 0x3D5
    xor al, al
    out dx, al
    mov dx, 0x3D4
    mov al, 15
    out dx, al
    mov dx, 0x3D5
    xor al, al
    out dx, al
    ret

do_reboot:
.wait_1:
    in al, 0x64
    test al, 2
    jnz .wait_1

    mov al, 0xFE
    out 0x64, al

.halt:
    hlt
    jmp .halt
