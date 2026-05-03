[org 0x7c00]
[bits 16]

; Константы
KERNEL_OFFSET equ 0x1000  ; Адрес загрузки ядра

start:
    ; Настройка сегментов
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    
    ; Очистка экрана
    mov ax, 0x0003
    int 0x10
    
    ; Вывод сообщения загрузчика
    mov si, msg_bootmgr
    call print

menu_wait:
    mov ah, 0x00
    int 0x16
    cmp al, '1'
    je do_reboot
    cmp al, '2'
    je do_boot
    mov si, msg_invalid
    call print
    jmp menu_wait

do_reboot:
    mov si, msg_reboot
    call print
    mov ah, 0x00
    int 0x16
    jmp 0xffff:0x0000

do_boot:
    ; Очистка экрана
    mov ax, 0x0003
    int 0x10
    
    mov si, msg_loading
    call print
    
    ; Сброс дисковой системы
    mov ah, 0x00
    mov dl, 0x80
    int 0x13
    
    ; Загрузка ядра с диска
    call load_kernel
    
    ; Переход на ядро
    jmp KERNEL_OFFSET

; Загрузка ядра с диска
load_kernel:
    mov bx, KERNEL_OFFSET  ; Буфер для загрузки
    mov ah, 0x02           ; Функция чтения
    mov al, 20             ; Количество секторов (10KB)
    mov ch, 0              ; Цилиндр 0
    mov cl, 2              ; Сектор 2 (после загрузчика)
    mov dh, 0              ; Головка 0
    mov dl, 0x80           ; Диск C:
    
    int 0x13
    jc .error              ; Если ошибка - CF=1
    cmp al, 20             ; Проверяем, сколько секторов прочитали
    jne .error
    ret
    
.error:
    mov si, msg_load_error
    call print
    mov ah, 0x00
    int 0x16
    jmp 0xffff:0x0000

; Функции вывода
print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

; Данные
msg_bootmgr  db '===MiOS Boot MGR===',13,10,'1-Reboot',13,10,'2-Boot',13,10,'Choice: ',0
msg_invalid  db 13,10,'Invalid',13,10,0
msg_reboot   db 13,10,'Rebooting...',0
msg_loading  db 'Loading kernel...',13,10,0
msg_load_error db 13,10,'Kernel load error! Press any key to reboot...',0

times 510-($-$$) db 0
dw 0xAA55