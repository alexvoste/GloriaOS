[bits 64]

%include "structures-drafts/GraphCanvas.inc"


global scroll_up_64
extern RenderProc
extern render_64

scroll_up_64:
    push rsi
    push rdi
    push rcx
    push rax

    mov rsi, RenderProc + GraphCanvas.backlog + 160
    mov rdi, RenderProc + GraphCanvas.backlog
    mov rcx, 1920
    cld
    rep movsw

    mov ah, [RenderProc + GraphCanvas.display_settings + CanvasParameters.background_color]
    mov al, ' '
    mov rcx, 80
    rep stosw

    call render_64

    pop rax
    pop rcx
    pop rdi
    pop rsi
    ret
