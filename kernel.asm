[org 0x1000]  ; Ядро загружается по адресу 0x1000
[bits 16]

kernel_start:

    mov ax, 0x0003
    int 0x10
    

    mov si, msg_kernel_loaded
    call print
    
    mov si, msg_welcome
    call print

    jmp shell


shell:
    mov si, msg_prompt
    call print
    call print_green_dollar
    call input
    
    mov si, buffer
    lodsb
    
    cmp al, 'help'
    je help_cmd
    cmp al, 'clear'
    je clear_cmd
    cmp al, 'reboot'
    je reboot_cmd
    cmp al, 'info'
    je info_cmd
    cmp al, 'ver'
    je ver_cmd
    cmp al, 'dir'
    je dir_cmd
    cmp al, 'xcopy'
    je xcp_cmd
    
    mov si, msg_unknown
    call print
    jmp shell


help_cmd:
    mov si, msg_help
    call print
    jmp shell


xcp_cmd:
    mov si, msg_xpc
    call print
    jmp shell


dir_cmd:
    mov si, msg_dir
    call print
    jmp shell

ver_cmd:
    mov si, msg_ver
    call print
    jmp shell

info_cmd:
    mov si, msg_info
    call print
    jmp shell

clear_cmd:
    mov ax, 0x0003
    int 0x10
    jmp shell

reboot_cmd:
    mov si, msg_reboot
    call print
    mov ah, 0x00
    int 0x16
    jmp 0xffff:0x0000


print_green_dollar:
    mov ah, 0x03
    mov bh, 0
    int 0x10
    mov ah, 0x09
    mov al, '$'
    mov bh, 0
    mov bl, 0x0A
    mov cx, 1
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    ret

input:
    mov di, buffer
    xor cx, cx
in_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je in_done
    cmp al, 0x08
    je in_bs
    cmp al, ' '
    jb in_loop
    mov ah, 0x0E
    int 0x10
    stosb
    inc cx
    jmp in_loop
in_bs:
    cmp cx, 0
    je in_loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp in_loop
in_done:
    mov byte [di], 0
    mov si, msg_newline
    call print
    ret

putc:
    mov ah, 0x0E
    int 0x10
    ret

print:
    lodsb
    or al, al
    jz .done
    call putc
    jmp print
.done:
    ret


msg_kernel_loaded db 'welcome to MiOS!',13,10,0
msg_welcome  db 'MiOS v4.0',13,10,0
msg_prompt   db 13,10,'MiOS_',0
msg_help     db 13,10,'all commands:',13,10
             db 'help   - Help',13,10
             db 'clear  - Clear screen',13,10
             db 'reboot - Reboot',13,10
             db 'info   - System info',13,10
             db 'ver    - Version',13,10
             db 'xcopy  - copy text',13,10
             db 'dir    - dir system',13,10,0
msg_unknown  db 13,10,'Unknown command. Type h for help',13,10,0
msg_info     db 13,10,'MiOS v4.0 - Operating System',13,10
             db 'MiOS v4.0 beta by Mikhail',13,10
msg_ver      db '2026',13,10,0
msg_reboot   db 13,10,'Rebooting system...',0
msg_newline  db 13,10,0
msg_dir     db 13,10,'ALL DIR',13,10
             db 'mios       <DIR> boot.bin',13,10
             db 'com        <DIR> none',13,10
             db 'boot_mgr   <DIR> boot.bin',13,10
             db 'com.kernel <DIR> kernel.bin',13,10
             db 'boot_mgr   <DIR> boot_mgr.txt',13,10
             db 'boot_mgr   <DIR> boot',13,10,0
msg_xpc      db 'There is no text to copy.',13,10,0
buffer       times 64 db 0
