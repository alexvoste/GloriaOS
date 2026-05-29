%macro FATAL 1
    PUSHA
    PUSHF

    mov si, SyncPoint

    mov ax, %1
    mov byte [si + BootControl.is_error], 1
    mov word [si + BootControl.ERROR_CODE], ax

    cli
%%dead_hanger:
    jmp %%dead_hanger
%endmacro
