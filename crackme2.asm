.model tiny
.code
.286
locals @@
org 100h

start:
    cli
    mov cs:[inf_loop_seg], cs

    xor bx, bx
    mov es, bx
    mov bx, 4h * 9h

    mov ax, es:[bx]
    mov cs:[int09_old_ofs], ax
    mov ax, es:[bx + 2]
    mov cs:[int09_old_seg], ax

    mov es:[bx], offset inp_int09
    mov ax, cs
    mov es:[bx + 2], ax
    sti

    cmp ax, ax
inf_loop:
    db 0EAh
inf_loop_ofs dw offset inf_loop
inf_loop_seg dw 0h

end_inf_loop:

    mov dx, offset err_msg
    
    mov ax, 0h
    mov si, offset buf + 1h
    mov cl, cs:[index_buf]
    xor ch, ch
    sub cx, 2h

hash_loop:
    shl ax, 1h

    mov bx, ax
    shl bx, 1h
    add ax, bx

    mov bx, ax
    shl ax, 1h
    add ax, bx
    shl ax, 1h
    add ax, bx

    mov bl, cs:[si]
    xor bh, bh
    add ax, bx
    inc si

    loop hash_loop

    cmp ax, cs:[hash_orig]
    jne no_ok
        mov dx, offset ok_msg
no_ok:
    mov ah, 09h
    int 21h
    
    mov ax, 4C00h
    int 21h

inp_int09 proc
    push ax

    in al, 60h
    cmp al, 1Ch
    je restore_int09
    
    push bx si

    mov si, offset index_buf

    mov bl, cs:[si]
    xor bh, bh
    dec al
    mov cs:[offset buf + bx], al
    inc bl
    mov cs:[index_buf], bl

    pop si bx

    jmp end_inp

restore_int09:

    cli
    push es bx
    xor bx, bx
    mov es, bx

    mov bx, 4h * 9h

    db 26h, 0C7h, 07h
int09_old_ofs dw 0FFFFh

    db 26h, 0C7h, 47h, 02h
int09_old_seg dw 0FFFFh

    mov cs:[inf_loop_ofs], offset end_inf_loop
    sti

    pop bx es

end_inp:

    in al, 61h
    or al, 80h
    out 61h, al
    and al, not 80h
    out 61h, al

    mov al, 20h
    out 20h, al
    pop ax

    iret

endp

.data

ok_msg    db 0Dh, "Access granted", "$"
err_msg   db 0Dh, "Wrong password", "$"
index_buf db 0h
buf       db 20h dup (0h)
hash_orig dw 0BA14h

end start

