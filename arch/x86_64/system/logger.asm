bits 64
default rel
%include "arch/x86_64/system/opcodes.inc"

global log_message
extern print_string_64
extern put_char_64

section .data
.log_prefix_error_str: db 'ERROR: ', 0
.log_prefix_info_str:  db 'INFO: ', 0
.log_prefix_debug_str: db 'DEBUG: ', 0

section .text
log_message:
    push rax
    push rdi
    push rsi
    push rbp
    mov rbp, rsp
    mov rdx, rsi
    cmp dil, LOG_LEVEL_ERROR
    je .log_error
    cmp dil, LOG_LEVEL_DEBUG
    je .log_debug
    mov rsi, .log_prefix_info_str
    call print_string_64
    jmp .print_message
.log_error:
    mov rsi, .log_prefix_error_str
    call print_string_64
    jmp .print_message
.log_debug:
    mov rsi, .log_prefix_debug_str
    call print_string_64
.print_message:
    mov rsi, rdx
    call print_string_64
    mov dil, ASCII_CR
    call put_char_64
    mov dil, ASCII_LF
    call put_char_64
    mov rsp, rbp
    pop rbp
    pop rsi
    pop rdi
    pop rax
    ret