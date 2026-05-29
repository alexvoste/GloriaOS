VGA_init:
    pushf
    pusha

    mov ax, 003h
    int 10h

    .checkout:
        call is_VGA
        jmp .exit

    .exit:
        popa
        popf
        ret

is_VGA:
    pushf
    pusha

    .check:
        mov ah, 0Fh
        int 10h
        cmp al, 3h

        je  .on
        jmp .off

    .on:
        mov si, SyncPoint
        mov byte [si + BootControl.is_VGA], 1
        jmp .exit

    .off:
        FATAL VGA_ERR_401

    .exit:
        popa
        popf
        ret

VGA_ERR_401     dw 401
