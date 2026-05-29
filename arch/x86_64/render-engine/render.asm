bits 64

%include "structures-drafts/GraphCanvas.inc"

global render_64
global sync_hardware_cursor_64
global init_canvas

RenderProc equ 0x30000

section .text

render_64:
    push rsi
    push rdi
    push rcx
    push rax
    push rdx

    mov rdi, 0xB8000

    mov rsi, RenderProc
    add rsi, GraphCanvas.backlog

    mov rcx, 2000
    cld
    rep movsw

    call sync_hardware_cursor_64

    pop rdx
    pop rax
    pop rcx
    pop rdi
    pop rsi
    ret

sync_hardware_cursor_64:
    push rax
    push rbx
    push rdx
    push rsi

    mov rsi, RenderProc
    add rsi, GraphCanvas.pointer

    xor rax, rax
    xor rbx, rbx

    mov al, [rsi + CursorParameters.y]
    mov bl, 80
    mul bl

    xor rdx, rdx
    mov dl, [rsi + CursorParameters.x]
    add ax, dx

    mov bx, ax

    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al

    mov dx, 0x3D5
    mov al, bh
    out dx, al

    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al

    mov dx, 0x3D5
    mov al, bl
    out dx, al

    pop rsi
    pop rdx
    pop rbx
    pop rax
    ret

init_canvas:
    push rdi
    push rcx
    push rax
    push rsi

    mov rsi, RenderProc

    mov byte [rsi + GraphCanvas.display_settings + CanvasParameters.background_color], 0
    mov byte [rsi + GraphCanvas.display_settings + CanvasParameters.text_color], 15

    mov byte [rsi + GraphCanvas.pointer + CursorParameters.x], 0
    mov byte [rsi + GraphCanvas.pointer + CursorParameters.y], 0

    mov rdi, rsi
    add rdi, GraphCanvas.backlog
    mov rcx, 2000
    mov ax, 0x0F20
    cld
    rep stosw

    call render_64

    pop rsi
    pop rax
    pop rcx
    pop rdi
    ret

