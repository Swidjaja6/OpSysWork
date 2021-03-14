print:
    mov ah, 0x0e
    .loop:
    mov cx, [bx]
   ; cmp [bx], 0
    or cx, cx
    jz .Exit
      mov al, [bx]
      int 0x10
      inc bx
      jmp .loop
    .Exit:
    ret
TestSTR: db "Hello World", 0


