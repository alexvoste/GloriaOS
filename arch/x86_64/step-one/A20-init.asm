A20_init:
    pushf
    push ds
    push es
    pusha

    mov ax, 2401h
    int 15h

    jnc .check_bios
    jmp .retry

    .check_bios:
        cmp ah, 00h
        je .checkout
        jmp .retry

    .retry:
        in al, 92h
        or al, 02h
        out 92h, al
        jmp .checkout

    .checkout:
        call is_A20
        jmp .exit

    .exit:
        popa
        pop es
        pop ds
        popf
        sti
        ret

is_A20:
    pushf
    pusha
    cli

    mov ax, ADDR_LOW_SEG
    mov ds, ax
    mov si, ADDR_LOW_OFF

    mov ax, ADDR_HIGH_SEG
    mov es, ax
    mov di, ADDR_HIGH_OFF

    mov ax, [ds:si]
    push ax
    mov ax, [es:di]
    push ax

    .check:
        mov word [ds:si], 0x1234
        mov word [es:di], 0xABCD

        mov ax, [ds:si]
        cmp ax, 0xABCD
        je .off

    .on:
        mov bx, SyncPoint
        mov byte [bx + BootControl.is_A20], 1
        jmp .exit

    .off:
        FATAL A20_ERR_201

    .exit:
        pop ax
        mov [es:di], ax
        pop ax
        mov [ds:si], ax
        popa
        popf
        sti
        ret

ADDR_LOW_SEG equ 0x0000
ADDR_LOW_OFF equ 0x0500
ADDR_HIGH_SEG equ 0xFFFF
ADDR_HIGH_OFF equ 0x0510
A20_ERR_201 dw 201
