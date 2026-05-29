%ifndef BOOTCONTROL_INC
%define BOOTCONTROL_INC

struc BootControl
    .is_VGA:     resb 1
    .is_A20:     resb 1
    .is_error:   resb 1
    .ERROR_CODE: resw 1
endstruc

%endif
