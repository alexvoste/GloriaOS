%ifndef GRAPHCANVAS_INC
%define GRAPHCANVAS_INC

%define BLACK  0x00
%define WHITE  0x0F
%define BLUE   0x01
%define GREEN  0x02
%define YELLOW 0x0E
%define RED    0x04


struc CanvasParameters 
    .background_color: resb 1
    .text_color:       resb 1
endstruc

struc CursorParameters
    .x:        resb 1
    .y:        resb 1     
    .x_border: resb 1
    .y_border: resb 1
    .shape:    resb 1
    .isBlink:  resb 1 
endstruc

struc StringParameters
    .text_ptr:    resw 1
endstruc

struc CharParameters
    .symbol:  resb 1
endstruc

struc GraphCanvas
    .display_settings: resb CanvasParameters
    .pointer:          resb CursorParameters
    .str_container:    resb StringParameters
    .char_container:   resb CharParameters
    .backlog:          resb 4000
endstruc

%endif
