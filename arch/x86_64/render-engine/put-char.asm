bits 64
global put_char_64

extern send_debug_char_64

section .data
global current_cursor_x
global current_cursor_y
current_cursor_x: db 0
current_cursor_y: db 0

section .text
put_char_64:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r12

    mov r12b, dil

    cmp r12b, 0x0A
    jne .not_newline
    mov byte [rel current_cursor_x], 0
    inc byte [rel current_cursor_y]
    cmp byte [rel current_cursor_y], 25
    jl .newline_done
    mov byte [rel current_cursor_y], 0
.newline_done:
    jmp .done_pop
.not_newline:

    movzx rbx, byte [current_cursor_x]
    movzx rcx, byte [current_cursor_y]

    mov rax, rcx
    mov rdx, 80
    mul rdx
    add rax, rbx
    shl rax, 1
    
    mov rdi, 0xB8000
    add rdi, rax
    mov rsi, rdi

    movzx edi, r12b
    call send_debug_char_64
    
    mov edi, ':'
    call send_debug_char_64

    mov rbx, rsi
    mov rcx, 8
.hex_push_loop:
    mov rdx, rbx
    and rdx, 0xF
    cmp rdx, 9
    jg .hex_letter
    add dl, '0'
    jmp .hex_pushed
.hex_letter:
    add dl, 0x37
.hex_pushed:
    push rdx
    shr rbx, 4
    loop .hex_push_loop

    mov rcx, 8
.hex_pop_loop:
    pop rdx
    movzx edi, dl
    call send_debug_char_64
    loop .hex_pop_loop

    mov edi, 10
    call send_debug_char_64

    mov rdi, rsi
    mov al, r12b
    mov ah, 0x0F
    mov [rdi], ax

    inc byte [current_cursor_x]
    cmp byte [current_cursor_x], 80
    jl .done
    mov byte [current_cursor_x], 0
    inc byte [current_cursor_y]
    cmp byte [current_cursor_y], 25
    jl .done
    mov byte [current_cursor_y], 0

.done:
    pop r12
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

.done_pop:
    pop r12
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
