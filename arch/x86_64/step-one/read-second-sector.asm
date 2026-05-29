
read_second_sector:
    pushf
    pusha

    xor ax, ax
    mov dl, [boot_drive]
    int 13h
    jc .disk_error

    mov ax, 0x0000
    mov es, ax
    mov bx, 0x7E00

    mov ah, 02h
    mov al, 64
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    int 13h
    jc .disk_error

    popa
    popf
    ret

.disk_error:
    cli
    mov ax, 0xB800
    mov es, ax
    mov edi, 0
    mov ecx, 80 * 25
.err_loop:
    mov word [es:edi], 0x4F45
    add edi, 2
    loop .err_loop
    hlt
    jmp $
