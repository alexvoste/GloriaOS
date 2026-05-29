%include "structures-drafts/BootControl.inc"

[bits 16]
org 0x7C00

jmp start
nop

SyncPoint:
    istruc BootControl
        at BootControl.is_VGA,     db 0
        at BootControl.is_A20,     db 0
        at BootControl.is_error,   db 0
        at BootControl.ERROR_CODE, dw 0
    iend

start:
    cli
    xor ax, ax
    mov ss, ax
    mov sp, 0x7BFF
    mov ds, ax
    mov es, ax
    mov [boot_drive], dl
    sti

    mov ax, 0x0003
    int 0x10

    call VGA_init
    call A20_init
    call read_second_sector

    jmp 0x0000:0x7E00

boot_drive: db 0

%include "tools/err-proc.asm"
%include "step-one/VGA-init.asm"
%include "step-one/A20-init.asm"
%include "step-one/read-second-sector.asm"

times 510-($-$$) db 0
dw 0xAA55
