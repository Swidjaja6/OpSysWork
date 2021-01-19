[org 0x7c00] ;org sets the assembler location counter, specifies the base address of the section of file 
[bits 16] ;Instructions which use 32 bits prefixed with 0x66 byte

section .text ;text section keeps the actual code

  global main ;Symbol should be visible to linker b/c other object files will use it

main: ;Linker entry point

cli
jmp 0x0000:ZeroSeg
ZeroSeg:
  xor ax, ax
  mov ss, ax
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov sp, main
  cld
sti

;push ax
xor ax, ax
;int 0x13
;pop ax
mov dl, 0x80
int 0x13
;mov si, STR
;call printf

;mov si, STR_T
;call printf

;mov si, STR_TH
;call printf
mov al, 1
mov cl, 2
call readDisk

mov ax, 0x2400
int 0x15

;mov dx, [0x7c00 + 510]

call testA20
mov dx, ax
call printh

call enableA20
mov dx, ax
call printh

jmp sTwo

jmp $

%include "./printf.asm"
%include "./readDisk.asm"
%include "./printh.asm"
%include "./testA20.asm"
%include "./enableA20.asm"

;STR: db "Loaded in 16-bit Real Mode to memory location 0x7c00.", 0x0a, 0x0d, 0
;STR_T: db "These messages use the BIOS interrupt 0x10 with the ah register sent to 0x0e.", 0x0a, 0x0d, 0
;STR_TH: db "Heraclitus test boot complete. Power off this machine and load a real OS, dummy.", 0
DISK_ERR_MSG: db "Error Loading Disk.", 0x0a, 0x0d, 0
TEST_STR: db "You are in the second sector.", 0x0a, 0x0d, 0
NO_A20: db "No A20 Line.", 0x0a, 0x0d, 0
NO_LM: db "Long mode not supported.", 0x0a, 0x0d, 0
YES_LM: db "Long mode supported.", 0x0a, 0x0d, 0

times 510-($-$$) db 0
dw 0xaa55

sTwo:
mov si, TEST_STR
call printf

call checklm

cli

mov edi, 0x1000
mov cr3, edi
xor eax, eax
mov ecx, 4096
rep stosd
mov edi, 0x1000

;PML4T -> 0x1000
;PDPT -> 0x2000
;PDT-> 0x3000
;PT -> 0x4000

mov dword [edi], 0x2003
add edi, 0x1000
mov dword [edi], 0x3003
add edi, 0x1000
mov dword [edi], 0x4003
add edi, 0x1000

mov dword ebx, 3
mov ecx, 512

.setEntry:
  mov dword [edi], ebx
  add ebx, 0x1000
  add edi, 8
  loop .setEntry

mov eax, cr4
or eax, 1 << 5
mov cr4, eax

mov ecx, 0xc0000080
rdmsr
or eax, 1 << 8
wrmsr

mov eax, cr0
or eax, 1 << 31
or eax, 1 << 0
mov cr0, eax

lgdt [GDT.Pointer]
jmp GDT.Code:LongMode

%include "./checklm.asm"
%include "./gdt.asm"

[bits 64]
LongMode:

VID_MEM equ 0xb8000
mov edi, VID_MEM
mov rax, 0x1f201f201f201f20
mov ecx, 500
rep stosq

mov rax, 0x1f741f731f651f54
mov [VID_MEM], rax

hlt
times 512 db 0
