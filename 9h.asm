CSEG segment
assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG
org 100h
.186
Start:
jmp Init

int_handler proc far 
    pusha 
    push es
    push ds
    push cs
    pop ds
    pushf 
    mov bx,0
    mov dx,0        

    call dword ptr cs:[Int_9h_vect]
    mov ax, 40h 
    mov es, ax
    mov bx, es:[1Ch]   
    dec bx  
    dec bx  
    cmp bx, 1Eh 
    jae go
    mov bx, 3Ch 
                
go:
    mov ax, es:[bx]
    mov dx, ax
    
    cmp dl, 1bh
    jne noEsc
    lds dx, Int_9h_vect 
    mov ax,2509h       
    int 21h   
    iret 
noEsc:
    cmp dl, 97
    jl contin1
    cmp dl, 122
    jg contin1
    push cx
    xor cx, cx
    mov cl, cs:pitch
oneMore:
    cmp cl, 26
    jle rightPitch
    sub cl, 26
    jmp oneMore
rightPitch:
    add dl, cl
    cmp dl, 122
    jle normal
    sub dl, 122
    push bx
    mov bl, 97
    add bl, dl
    dec bl
    mov dl, bl
    pop bx
normal:
    pop cx
    jmp exit
contin1:
    cmp dl, 65
    jl contin2
    cmp dl, 90
    jg contin2
    push cx
    xor cx, cx
    mov cl, cs:pitch
repeatIter:
    cmp cl, 26
    jle right
    sub cl, 26
    jmp repeatIter
right:
    add dl, cl
    cmp dl, 90
    jle norma2
    push bx
    sub dl, 90
    mov bl, 65
    add bl, dl
    mov dl, bl
    pop bx
    norma2:
    pop cx
    jmp exit
contin2:
    cmp dl, '0'
    jl exit
    cmp dl, '9'
    jg exit
    push cx
    xor cx, cx
    mov cl, cs:pitch
repeatMore:
    cmp cl, 10
    jle right1
    sub cl, 10
    inc cl
    jmp repeatMore
right1:
    add dl, cl
    cmp dl, '9'
    jle great
    sub dl, '9'
    add dl, '1'
    dec dl
great:
    pop cx
exit:
    mov word ptr es:[bx], dx  
    pop ds
    pop es
    popa
    iret
    
    Int_9h_vect dd ?
    pitch db 0
int_handler endp

getPitch proc
    push bx
    push ax
    push cx 
    mov bl, 10
    mov al, [ds:82h]
    sub al, '0'
    mov ah, [ds:83h]
    cmp ah, 0Dh
    jz oneSymbol
    mov cl, ah
    sub cl, '0'
    mul bl
    add al, cl
    oneSymbol:
    mov cs:[pitch], al
    pop cx
    pop ax
    pop bx
    ret
getPitch endp

Init:
    call getPitch
    
    mov ah, 35h
    mov al, 9h
    int 21h
    
    mov word ptr Int_9h_vect, bx
    mov word ptr Int_9h_vect+2, es
    
    mov ah, 25h
    mov al, 9h
    mov dx, offset int_handler
    int 21h
    
    mov dx, offset Init
    int 27h
    
CSEG ends
end Start