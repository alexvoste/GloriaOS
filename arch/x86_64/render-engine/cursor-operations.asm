%macro SET_CURSOR_COORDINATES_64 2
    push rsi
    push rax

    mov rsi, RenderProc + GraphCanvas.pointer

    mov al, %1
    mov byte [rsi + CursorParameters.x], al

    mov al, %2
    mov byte [rsi + CursorParameters.y], al

    pop rax
    pop rsi
%endmacro

%macro MOVE_CURSOR_Y_64 0
    push rsi
    push rax
    push rbx
    push rcx

    mov rsi, RenderProc + GraphCanvas.pointer

    movzx rax, byte [rsi + CursorParameters.x]
    movzx rbx, byte [rsi + CursorParameters.y]

    xor rax, rax

    movzx rcx, byte [rsi + CursorParameters.y_border]
    inc rbx

    cmp rbx, rcx
    jae %%scroll_up
    jmp %%save_res

%%scroll_up:
    mov rbx, rcx
    dec rbx
    call scroll_up_64
    jmp %%save_res

%%save_res:
    mov [rsi + CursorParameters.x], al
    mov [rsi + CursorParameters.y], bl

    pop rcx
    pop rbx
    pop rax
    pop rsi
%endmacro

%macro MOVE_CURSOR_X_64 0
    push rsi
    push rax
    push rbx
    push rcx

    mov rsi, RenderProc + GraphCanvas.pointer

    movzx rax, byte [rsi + CursorParameters.x]
    movzx rbx, byte [rsi + CursorParameters.y]

    movzx rcx, byte [rsi + CursorParameters.x_border]
    inc rax
    cmp rax, rcx
    jae %%move_new_string
    jmp %%save_res

%%move_new_string:
    xor rax, rax

    movzx rcx, byte [rsi + CursorParameters.y_border]
    inc rbx

    cmp rbx, rcx
    jae %%scroll_up
    jmp %%save_res

%%scroll_up:
    mov rbx, rcx
    dec rbx
    call scroll_up_64
    jmp %%save_res

%%save_res:
    mov [rsi + CursorParameters.x], al
    mov [rsi + CursorParameters.y], bl

    pop rcx
    pop rbx
    pop rax
    pop rsi
%endmacro
