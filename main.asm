org 0x7c00

mov si, STR
call printf

mov si, STR_T
call printf

mov si, STR_TH
call printf

call readDisk

jmp $

printf:
  pusha
  str_loop:
    mov al, [si]
    cmp al, 0
    jne print_char
    popa
    ret

  print_char:
    mov ah, 0x0e
    int 0x10
    add si, 1
    jmp str_loop

readDisk:
  pusha    	
  mov ah, 0x02
  mov dl, 0x80
  mov ch, 0
  mov dh, 0
  mov al, 1
  mov cl, 2

  push bx
  mov bx, 0
  mov es, bx
  pop bx
  mov bx, 0x7c00 + 512

  jc disk_err
  popa
  ret

  disk_err:
    mov si, DISK_ERR_MSG
    call printf
    jmp $

STR: db "Loaded in 16-bit Real Mode to memory location 0x7c00.", 0x0a, 0x0d, 0
STR_T: db "These messages use the BIOS interrupt 0x10 with the ah register sent to 0x0e.", 0x0a, 0x0d, 0
STR_TH: db "Heraclitus test boot complete. Power off this machine and load a real OS, dummy.", 0
DISK_ERR_MSG: db "Error Loading Disk.", 0x0a, 0x0d, 0

times 510-($-$$) db 0
dw 0xaa55
