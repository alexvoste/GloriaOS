bits 64
default rel

global put_char_64
global current_cursor_x
global current_cursor_y

extern send_debug_char_64

section .data
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
    call check_scroll
    jmp .done
    
.not_newline:
    cmp r12b, 0x08
    jne .not_backspace
    cmp byte [rel current_cursor_x], 0
    je .done
    dec byte [rel current_cursor_x]
    
    call get_screen_offset
    mov rdi, rax
    mov word [rdi], 0x0F20
    jmp .done

.not_backspace:
    call get_screen_offset
    mov rdi, rax
    mov al, r12b
    mov ah, 0x0F
    mov [rdi], ax

    inc byte [rel current_cursor_x]
    cmp byte [rel current_cursor_x], 80
    jl .done
    mov byte [rel current_cursor_x], 0
    inc byte [rel current_cursor_y]
    call check_scroll

.done:
    call update_hardware_cursor
    pop r12
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

get_screen_offset:
    movzx rbx, byte [rel current_cursor_x]
    movzx rcx, byte [rel current_cursor_y]
    mov rax, rcx
    mov rdx, 80
    mul rdx
    add rax, rbx
    shl rax, 1
    add rax, 0xB8000
    ret

check_scroll:
cmp byte [rel current_cursor_y], 25
    jl .no_scroll

    mov rsi, 0xB8000 + 160
    mov rdi, 0xB8000
    mov rcx, 480
    cld
    rep movsq

    mov rdi, 0xB8000 + 3840
    mov ax, 0x0F20
    mov rcx, 80
    rep stosw

    mov byte [rel current_cursor_y], 24
.no_scroll:
    ret

update_hardware_cursor:
    push rax
    push rbx
    push rdx

    movzx rax, byte [rel current_cursor_y]
    mov rdx, 80
    mul rdx
    movzx rbx, byte [rel current_cursor_x]
    add rbx, rax

    mov dx, 0x3D4
    mov al, 14
    out dx, al
    mov dx, 0x3D5
    mov al, bh
    out dx, al

    mov dx, 0x3D4
    mov al, 15
    out dx, al
    mov dx, 0x3D5
    mov al, bl
    out dx, al

    pop rdx
    pop rbx
    pop rax
    ret
